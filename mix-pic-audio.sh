#!/bin/bash

# Check if all required parameters are provided
if [ $# -ne 4 ]; then
    echo "Usage: $0 <image_file> <mp3_file> <target_duration_seconds> <output_file>"
    echo "Example: $0 input.jpg input.mp3 300 output.mp4"
    exit 1
fi

pic_file="$1"
audio_file="$2"
target_duration="$3"
output_file="$4"

# Check if input files exist
if [ ! -f "$pic_file" ]; then
    echo "Error: Image file '$pic_file' not found"
    exit 1
fi

if [ ! -f "$audio_file" ]; then
    echo "Error: Audio file '$audio_file' not found"
    exit 1
fi

# Check if target duration is a positive number
if ! [[ "$target_duration" =~ ^[0-9]+([.][0-9]+)?$ ]] || [ "$(echo "$target_duration <= 0" | bc -l)" -eq 1 ]; then
    echo "Error: Target duration must be a positive number"
    exit 1
fi

# Get audio duration
audio_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file")
if [ $? -ne 0 ] || [ -z "$audio_duration" ]; then
    echo "Error: Failed to get audio duration"
    exit 1
fi

# Calculate the total duration of the final file
audio_loops_float=$(echo "($target_duration / $audio_duration)" | bc -l)
audio_loops=$(echo "scale=0; ($audio_loops_float + 0.99)/1" | bc)
total_duration=$(echo "$audio_duration * $audio_loops" | bc)
echo "Audio duration: $audio_duration seconds, $audio_loops loops, total duration: $total_duration seconds"

# Mix picture and audio with looping
if ! ffmpeg -hide_banner \
    -loop 1 -i "$pic_file" \
    -stream_loop -1 -i "$audio_file" \
    -c:v h264_videotoolbox -tune stillimage -pix_fmt yuv420p \
    -c:a aac \
    -t "$total_duration" \
    -y "$output_file"; then
    echo "Error: FFmpeg processing failed"
    exit 1
fi

echo "Mixed video created successfully: $output_file"