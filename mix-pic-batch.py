#!/usr/bin/env python3
import os
import subprocess
import logging
import argparse

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.FileHandler("mix-pic-batch.log"), logging.StreamHandler()],
)

# Parse command line arguments
parser = argparse.ArgumentParser(description="Process image and audio files")
parser.add_argument("batch_file", help="Path to batch file")
parser.add_argument(
    "--duration", type=int, default=300, help="Duration of the video in seconds"
)
args = parser.parse_args()

# Define paths
input_batch_file = args.batch_file

PICTURES_DIR = "picture"
AUDIO_DIR = "audio"
VIDEO_DIR = "video"
SCRIPT_PATH = "./mix-pic-audio.sh"

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

        # Check for image files
        image_extensions = [".png", ".jpg"]
        image_file = None
        for ext in image_extensions:
            possible_file = os.path.join(PICTURES_DIR, prefix + ext)
            if os.path.exists(possible_file):
                image_file = possible_file
                break

        if not image_file:
            logging.warning(f"No image file found for prefix {prefix}")
            continue

        # Check for audio file
        audio_file = os.path.join(AUDIO_DIR, prefix + ".mp3")
        if not os.path.exists(audio_file):
            logging.warning(f"No audio file found for prefix {prefix}")
            continue

        # Prepare output file
        output_file = os.path.join(VIDEO_DIR, prefix + ".mp4")

        # Run the mix script
        try:
            with open("mix-pic-batch.log", "a") as log_file:
                logging.info(
                    f"Processing {prefix}...with {image_file},{audio_file} and duration {args.duration}"
                )
                subprocess.run(
                    [
                        SCRIPT_PATH,
                        image_file,
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
