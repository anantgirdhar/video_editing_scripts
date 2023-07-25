# Generate Noise Profiles

## Introduction

To remove noise from audio files, we use a tool called `sox`. This tool can be
used to both generate noise profile files (from audio files that contain
"silence") as well as to denoise audio files (using these generated noise
profile files).

Each video file contains left and right audio channels. So we need to generate
noise profile files for both the left and right channels and then denoise both
audio channels in each video file.

## File structure

There is a folder for every date that we have a noise profile for. Under each
of these, we have `left` and `right` folders for each audio channel which will
contain the noise profile for that channel.

## Process

1. Split the video file into the two audio channels. Use the following command:

    ```sh
    ffmpeg
      -i SILENCE_VIDEO_FILE
      -filter_complex "[0:a] pan=mono|FC=FL [left], [0:a] pan=mono|FC=FR [right]"
      -map "[left]" -vn SILENCE_AUDIO_LEFT
      -map "[right]" -vn SILENCE_AUDIO_RIGHT
    ```

2. Extract a subsection of the audio that only contains silence (if there is
   some extraneous noise in the audio).
3. Generate the noise profile for each channel. Use the following command:

    ```sh
    sox SILENCE_AUDIO_LEFT -n noiseprof noise_profile_left
    ```

    Note that the silence audio file must be a `*wav` file.
