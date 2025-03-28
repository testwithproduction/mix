#!/usr/bin/env python3
import os
import subprocess
import logging
import argparse

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.FileHandler("mix-batch.log"), logging.StreamHandler()],
)

# Parse command line arguments
parser = argparse.ArgumentParser(description="Process picture/video and audio files")
parser.add_argument("batch_file", help="Path to batch file")
parser.add_argument(
    "--duration", type=int, default=300, help="Duration of the video in seconds"
)
parser.add_argument(
    "--type",
    choices=["picture", "video"],
    default="picture",
    help="Type of media to process (picture or video)",
)
args = parser.parse_args()

# Define paths
input_batch_file = args.batch_file

PICTURES_DIR = "picture"
AUDIO_DIR = "audio"
VIDEO_DIR = "video"
FINAL_DIR = "final"
# Get the directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SCRIPT_PATH = os.path.join(
    SCRIPT_DIR, "mix-pic-audio.sh" if args.type == "picture" else "mix-video-audio.sh"
)

# Check if batch file exists
if not os.path.exists(input_batch_file):
    logging.error(f"Batch file '{input_batch_file}' not found")
    exit(1)

# Process each line in batch file
with open(input_batch_file, "r") as file:
    for line in file:
        prefix = line.strip()
        if not prefix:
            continue

        # Check for media files based on type
        media_file = None
        if args.type == "picture":
            extensions = [".png", ".jpg"]
            search_dir = PICTURES_DIR
        else:
            extensions = [".mp4", ".mov"]
            search_dir = VIDEO_DIR

        # Find files that start with prefix and have matching extension
        for ext in extensions:
            for file in os.listdir(search_dir):
                if file.startswith(prefix) and file.endswith(ext):
                    media_file = os.path.join(search_dir, file)
                    break
            if media_file:
                break

        if not media_file:
            logging.warning(f"No {args.type} file found for prefix {prefix}")
            continue

        # Check for audio file
        audio_file = None
        for file in os.listdir(AUDIO_DIR):
            if file.startswith(prefix) and file.endswith(".mp3"):
                audio_file = os.path.join(AUDIO_DIR, file)
                break

        if not audio_file:
            logging.warning(f"No audio file found for prefix {prefix}")
            continue

        # Prepare output file
        output_file = os.path.join(FINAL_DIR, prefix + ".mp4")

        # Run the mix script
        try:
            with open("mix-pic-batch.log", "a") as log_file:
                logging.info(
                    f"Processing {prefix}...with {media_file},{audio_file} and duration {args.duration}"
                )
                subprocess.run(
                    [
                        SCRIPT_PATH,
                        media_file,
                        audio_file,
                        str(args.duration),
                        output_file,
                    ],
                    check=True,
                    stdout=log_file,
                    stderr=log_file,
                )
            logging.info(f"Successfully created video: {output_file}")
        except subprocess.CalledProcessError as e:
            logging.error(f"Error processing {prefix}: {e}")
        except FileNotFoundError:
            logging.error(f"Script path {SCRIPT_PATH} not found")
            exit(1)
