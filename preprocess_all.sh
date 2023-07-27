#!/bin/sh

# Pre-process all Aroll video assets

# This script picks up whether or not to denoise a video file's audio based on
# a .denoise file saved at the same level as the video file. The .denoise file
# should specify the path to the folder containing the noise profile files
# corresponding to the video. This path should be relative to the folder
# containing all the noise profile directories for the project. Additionally,
# each noise profile folder should contain the following the structure:
#
# noise_profile_folder
# |-- left
#     |-- noise_profile_left
# |-- right
#     |-- noise_profile_right
#
# The noise_profile_{left,right} files should be the outputs from sox. If no
# .denoise file is found, the audio is not denoised.

logfile=log.$(date +%y%m%d%H%M)
ArollDir="../assets/Aroll"
noiseProfilesDir="../assets/noise_profile"

# for f in $(find ../../assets/Aroll -name "*maincam*.mov"); do
#   ./preprocess_maincam.sh "$f" | tee -a $logfile
# done

# for f in $(find ../../assets/Aroll/ -name "*sidecam*.mov"); do
#   ./preprocess_sidecam.sh "$f" | tee -a $logfile
# done

for f in $(find "$ArollDir" -name "*cam*.mov" ! -name "*_video_only.mov"); do
  echo | tee -a $logfile
  echo | tee -a $logfile
  echo "<> $f" | tee -a $logfile

  # Check if there is a .denoise file and, if so, get the noise profile
  denoiseRC=$(dirname "$f")/.denoise
  if [ -f "$denoiseRC" ]; then
    noiseProfile="$noiseProfilesDir"/$(cat "$denoiseRC")
  else
    noiseProfile="-"
  fi
  # Check if there is a .preprocess file and, if so, get the variables set in there
  preprocessRC=$(dirname "$f")/.preprocess
  if [ -f "$preprocessRC" ]; then
    . "$preprocessRC"
    [ ! -z "$noiseProfile" ] && noiseProfile="$noiseProfilesDir"/"$noiseProfile"
  else
    # If no noise profile was found but one was found in the denoiseRC then
    # don't reset it. If nothing has been found, then there's really nothing to
    # do.
    [ -z $noiseProfile ] && noiseProfile="-"
  fi
  echo "<> denoiseRC: $denoiseRC" | tee -a $logfile
  echo "<> preprocessRC: $preprocessRC" | tee -a $logfile
  echo "<> noiseProfile: $noiseProfile" | tee -a $logfile
  echo "<> audioSpeedFactor: $audioSpeedFactor" | tee -a $logfile
  echo "<> videoSpeedFactor: $videoSpeedFactor" | tee -a $logfile

  # Set the appropriate speed factor for each camera
  case "$f" in
    *maincam*)
      [ -z $audioSpeedFactor ] && audioSpeedFactor=0.96618
      [ -z $videoSpeedFactor ] && videoSpeedFactor=1.03331926269875
      ;;
    *sidecam*)
      [ -z $audioSpeedFactor ] && audioSpeedFactor=0.9984371585
      [ -z $videoSpeedFactor ] && videoSpeedFactor=1
      ;;
  esac

  ./preprocess_video.sh "$f" $audioSpeedFactor $videoSpeedFactor "$noiseProfile" | tee -a $logfile

done
