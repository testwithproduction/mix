# mix

A collection of utility scripts for mixing and processing various types of media content.

## Overview

This repository contains scripts designed to help with mixing and processing different types of media files, particularly focusing on audio and video content.

## Features

- `mix-pic-audio.sh`: Create video from a static image and audio file with specified duration
- `mix-video-audio.sh`: Combine video with background audio, with loop support

## Getting Started

### Prerequisites

The following dependencies are required:

- `ffmpeg`: Media processing tool
  ```bash
  brew install ffmpeg
  ```

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mix.git
```
## Usage

### mix-pic-audio.sh
Create a video from a static image with looping background audio:
```bash
./mix-pic-audio.sh <image_file> <mp3_file> <target_duration_seconds> <output_file>
```

Run each script without any paramters to see its usage.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.