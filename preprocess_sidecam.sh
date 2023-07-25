#!/bin/sh

# Preprocess GT6000 videos from the sidecam
# - Extract audio streams into separate files
# - Slow down the audio so that the sync is restored
#
# To run this script, specify the video file name.
# If the corresponding audio files exist, this script will do nothing. To force
# run the script and overwrite the audio files, use the force command.

video=$1
force=$2

# Verify inputs exist and clean them
[ -z "$force" ] && force=""
[ "$force" = "force" ] || force=""
[ -z "$video" ] && echo ">> No video file specified. Aborting." && exit 1

echo
echo ">> Processing $video..."
echo ">>> Starting at $(date)"

# Set some file path aliases
audioLeft=${video%.*}_audio_left.wav
audioRight=${video%.*}_audio_right.wav

# Factor to slow down audio by
# speedFactor=0.99839746
# speedFactor=0.9998358
# speedFactor=0.9982705211
speedFactor=0.9984371585

if [ -f $audioLeft ] && [ -f $audioRight ] && [ -z "$force" ]; then
  # If the files already exist and we're not forcing, skip
  echo ">>> Files already exist. Skipping."
else
  echo ">>>> Extracting audio..."
  ffmpeg -y -i $video -filter_complex "[0:a] pan=mono|FC=FL, atempo=$speedFactor [left]; [0:a] pan=mono|FC=FR, atempo=$speedFactor [right]" -map "[left]" -vn $audioLeft -map "[right]" -vn $audioRight
  echo ">>> Ended at $(date)"
fi
