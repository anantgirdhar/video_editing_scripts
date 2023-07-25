#!/bin/sh

# Preprocess GT6000 videos
# - Extract audio streams into separate files
# - Slow down the audio so that the sync is restored
# - Remove noise from clips based on the noise profile
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
audioLeftTemp=${video%.*}_audio_left_temp.wav
audioRightTemp=${video%.*}_audio_right_temp.wav
audioLeft=${video%.*}_audio_left.wav
audioRight=${video%.*}_audio_right.wav
noiseProfileLeft="../../assets/noise_profile/maincam/left/noise_profile_left"
noiseProfileRight="../../assets/noise_profile/maincam/right/noise_profile_right"

if [ -f $audioLeft ] && [ -f $audioRight ] && [ -z "$force" ]; then
  # If the files already exist and we're not forcing, skip
  echo ">>> Files already exist. Skipping."
else
  # ffmpeg -i $video -c copy -an ${video%%.*}_video_only.mov
  # ffmpeg -i $video -map_channel 0.1.0 ${video%%.*}_audio_left.m4a
  # ffmpeg -i $video -map_channel 0.1.1 ${video%%.*}_audio_right.m4a
  # ffmpeg -i $video -map_channel 0.1.0 -filter:a "atempo=0.96618" ${video%%.*}_audio_left_slowed.m4a
  # ffmpeg -i $video -map_channel 0.1.1 -filter:a "atempo=0.96618" ${video%%.*}_audio_right_slowed.m4a
  # ffmpeg -i ${video%%.*}_audio_left.m4a -filter:a "atempo=0.96618" ${video%%.*}_audio_left_slowed2.m4a
  # ffmpeg -i ${video%%.*}_audio_right.m4a -filter:a "atempo=0.96618" ${video%%.*}_audio_right_slowed2.m4a

  # ffmpeg -i ${video%%.*}_audio_left.m4a -filter:a "atempo=0.96618" -vn ${video%%.*}_audio_left_slowed3.m4a

  # ffmpeg -i ${video%%.*}_audio_left.m4a -filter_complex "[0:a:0] atempo=0.96618" -vn ${video%%.*}_audio_left_slowed4.m4a



  # ffmpeg -i $video -filter_complex "[0:a] pan=mono|FC=FL, atempo=0.96618 [left]; [0:a] pan=mono|FC=FR, atempo=0.96618 [right]" -map "[left]" -vn ${video%%.*}_audio_left.m4a -map "[right]" -vn ${video%%.*}_audio_right.m4a

  echo ">>>> Extracting audio..."
  ffmpeg -i $video -filter_complex "[0:a] pan=mono|FC=FL, atempo=0.96618 [left]; [0:a] pan=mono|FC=FR, atempo=0.96618 [right]" -map "[left]" -vn $audioLeftTemp -map "[right]" -vn $audioRightTemp

  echo ">>>> Denoising audio..."
  sox $audioLeftTemp $audioLeft noisered $noiseProfileLeft 0.3
  sox $audioRightTemp $audioRight noisered $noiseProfileRight 0.3

  echo ">>>> Removing temp files..."
  rm $audioLeftTemp $audioRightTemp

  echo ">>> Ended at $(date)"
fi
