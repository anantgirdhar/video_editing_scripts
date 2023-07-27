#!/bin/sh

# Preprocess GT6000 video
# - Extract audio streams into separate files
# - Slow down the audio so that the sync is restored
# - Remove noise from clips based on the noise profile
#
# To run this script, specify the video file name, audio speed factor, and
# noise profile directory. If the corresponding audio files exist, this script
# will do nothing. To force run the script and overwrite the audio files, use
# the force argument.
#
# To specify whether or not to denoise the audio, specify a .denoise file at
# the same level as the video file. In the .denoise file, specify the path to
# folder containing the noise profile files relevant for the video. This path
# should be relative to the folder containing all the noise profile
# directories. Additionally, each noise profile folder should contain the
# following structure:
#
# noise_profile_folder
# |-- left
#     |-- noise_profile_left
# |-- right
#     |-- noise_profile_right
#
# The noise_profile_{left,right} files should be the outputs from sox. If no
# .denoise file is provided, the audio is not denoised.

video=$1
audioSpeedFactor=$2
noiseProfile=$3
force=$4

echo
echo ">> Processing $video..."
echo ">>> Starting at $(date)"

# Verify inputs exist and clean them
# Make sure the video file is specified
[ -z "$video" ] && echo ">> No video file specified. Aborting." && exit 1
# Next clean the audioSpeedFactor
[ -z "$audioSpeedFactor" ] && audioSpeedFactor=1
# Next check if the noiseProfile directory is specified or not
# If it is a "-" then blank it out
[ -z "$noiseProfile" ] && noiseProfile=""
[ "$noiseProfile" = "-" ] && noiseProfile=""
if [ ! -z "$noiseProfile" ]; then
  # Now make sure that the noise profile files exist
  noiseProfileLeft="$noiseProfile/left/noise_profile_left"
  noiseProfileRight="$noiseProfile/right/noise_profile_right"
  if [ ! -f "$noiseProfileLeft" ]; then
    echo ">> Left channel noise profile not found: $noiseProfileLeft. Aborting."
    exit 2
  fi
  if [ ! -f "$noiseProfileRight" ]; then
    echo ">> Right channel noise profile not found: $noiseProfileRight. Aborting."
    exit 2
  fi
fi
# Finally, check if we need to force re-make this
[ -z "$force" ] && force=""
[ "$force" = "force" ] || force=""

echo ">>> Cleaned inputs:"
echo ">>> - video: $video"
echo ">>> - audioSpeedFactor: $audioSpeedFactor"
echo ">>> - noiseProfile: $noiseProfile"
echo ">>> - force: $force"

# Set some file path aliases
audioLeftTemp=${video%.*}_audio_left_temp.wav
audioRightTemp=${video%.*}_audio_right_temp.wav
audioLeft=${video%.*}_audio_left.wav
audioRight=${video%.*}_audio_right.wav

if [ -f $audioLeft ] && [ -f $audioRight ] && [ -z "$force" ]; then
  # If the files already exist and we're not forcing, skip
  echo ">>> Files already exist. Skipping."
else
  echo ">>>> Extracting audio..."
  ffmpeg -y -i $video -filter_complex "[0:a] pan=mono|FC=FL, atempo=$audioSpeedFactor [left]; [0:a] pan=mono|FC=FR, atempo=$audioSpeedFactor [right]" -map "[left]" -vn $audioLeftTemp -map "[right]" -vn $audioRightTemp
  if [ ! -z "$noiseProfile" ]; then
    echo ">>>> Denoising audio..."
    sox $audioLeftTemp $audioLeft noisered $noiseProfileLeft 0.3
    sox $audioRightTemp $audioRight noisered $noiseProfileRight 0.3
    echo ">>>> Removing temp files..."
    rm $audioLeftTemp $audioRightTemp
  else
    mv $audioLeftTemp $audioLeft
    mv $audioRightTemp $audioRight
  fi
fi

echo ">>> Ended at $(date)"
