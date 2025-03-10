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

# Get audio duration
audio_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file")

# Calculate the total duration of the final file
audio_loops_float=$(echo "($target_duration / $audio_duration)" | bc -l)
audio_loops=$(echo "scale=0; ($audio_loops_float + 0.99)/1" | bc)
total_duration=$(echo "$audio_duration * $audio_loops" | bc)
echo "Audio duration: $audio_duration seconds, $audio_loops loops, total duration: $total_duration seconds"

# Mix picture and audio with looping
ffmpeg -hide_banner \
    -loop 1 -i $pic_file \
    -stream_loop -1 -i $audio_file \
    -c:v h264_videotoolbox -tune stillimage -c:a aac -pix_fmt yuv420p \
    -t $total_duration \
    -y $output_file

echo "Mixed video created successfully: $output_file"