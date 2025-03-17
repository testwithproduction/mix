#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <video_file> <audio_file> <duration_seconds> <output_file>"
    echo "Example: $0 input.mp4 input.mp3 300 output.mp4"
    exit 1
fi

video_file="$1"
audio_file="$2"
target_duration="$3"
output_file="$4"

# Check if input files exist
if [ ! -f "$video_file" ]; then
    echo "Error: Video file '$video_file' not found"
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

# Get video duration
video_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video_file")
if [ $? -ne 0 ] || [ -z "$video_duration" ]; then
    echo "Error: Failed to get video duration"
    exit 1
fi

# Calculate the total duration of the final file.
video_loops_float=$(echo "($target_duration / $video_duration)" | bc -l)
video_loops=$(echo "scale=0; ($video_loops_float + 0.99)/1" | bc)
total_duration=$(echo "$video_duration * $video_loops" | bc)
echo "Video duration: $video_duration seconds, $video_loops loops, total duration: $total_duration seconds"

# Mix video and audio with looping
if ! ffmpeg -hide_banner \
    -stream_loop $video_loops -i "$video_file" \
    -stream_loop -1 -i "$audio_file" \
    -c:v copy -c:a aac -map 0:v -map 1:a -shortest \
    -y "$output_file"; then
    echo "Error: FFmpeg processing failed"
    exit 1
fi

echo "Mixed video created successfully: $output_file"