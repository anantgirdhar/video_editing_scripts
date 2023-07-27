#!/bin/sh

# Extract audio channels

video=$1

audioLeft=${video%.*}_audio_left.m4a
audioRight=${video%.*}_audio_right.m4a

ffmpeg -i "$video" -filter_complex "[0:a] pan=mono|FC=FL [left], [0:a] pan=mono|FC=FR [right]" -map "[left]" -vn "$audioLeft" -map "[right]" -vn "$audioRight"
