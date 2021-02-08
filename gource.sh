#!/bin/sh
scriptPath=$(realpath "$0")
scriptPath=$(dirname "$scriptPath")

"$scriptPath/tools/gource/gource.exe" --bloom-intensity 0.35 \
  -b 111111 \
  -1280x720 \
  --hide filenames,mouse,progress \
  --user-scale 3 \
  --stop-position 1 \
  --highlight-users \
  --highlight-dirs \
  --multi-sampling \
  --file-idle-time 0 \
  --seconds-per-day 1 \
  --auto-skip-seconds 1 \
  --time-scale 1 \
  --key \
  -e 0.000000001 \
  --bloom-multiplier 1.3 \
  --logo "$3" \
  --output-framerate 30 \
  --output-ppm-stream "$2" \
  "$1" || exit 1

#--file-idle-time 30 \
#--camera-mode track \
#--file-idle-time 0 \
#--hide dirnames,date,progress \
#--seconds-per-day 1 \
#--logo "E:\Downloads\DropBox\Dropbox\projects\olviz\images\logo.png" \
#--user-image-dir "D:\#Install\Icons\flags\32" \
