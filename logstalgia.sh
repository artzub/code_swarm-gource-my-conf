#!/bin/sh
scriptPath=$(realpath "$0")
scriptPath=$(dirname "$scriptPath")

"$scriptPath/tools/logstalgia/logstalgia.exe" --no-bounce \
  --hide-paddle \
  -b 111111 \
  -1280x720 \
  --glow-duration 1 \
	--glow-multiplier 2 \
	--glow-intensity 1 \
	-s 5 \
	-p 0.1 \
	--path-abbr-depth -1 \
	-g Files,".*\b",100 \
  "$1" \
	--output-framerate 25 \
	--output-ppm-stream "$2" || exit 1
