#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <video_file> <audio_file> <duration_seconds> <output_file>"
    exit 1
fi

video_file="$1"
audio_file="$2"
target_duration="$3"
output_file="$4"

# Get video duration
video_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video_file")

# Calculate the total duration of the final file.
video_loops_float=$(echo "($target_duration / $video_duration)" | bc -l)
video_loops=$(echo "scale=0; ($video_loops_float + 0.99)/1" | bc)
total_duration=$(echo "$video_duration * $video_loops" | bc)
echo "Video duration: $video_duration seconds, $video_loops loops, total duration: $total_duration seconds"

# Mix video and audio with looping
# Loop video multiple times and audio might get truncated at the end.
# copy original video, while MP3 need to re-encode to AAC
ffmpeg -hide_banner \
    -stream_loop $video_loops -i "$video_file" \
    -stream_loop -1 -i "$audio_file"\
    -c:v copy -c:a aac -map 0:v -map 1:a -shortest \
    -y "$output_file"

echo "Mixed video created successfully: $output_file"