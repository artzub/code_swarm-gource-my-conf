#!/bin/bash

scriptPath=$(realpath "$0")
scriptPath=$(dirname "$scriptPath")
tools="$scriptPath/tools"

usage="$0 -o resultFolder [-r gitWorkDir] -s -l -g -c"

ppmToVideo() {
  "$tools/ffmpeg/bin/ffmpeg.exe" -y -r 60 \
    -f image2pipe \
    -vcodec ppm \
    -i "$1" \
    -vcodec libx264 \
    -preset ultrafast \
    -pix_fmt yuv420p \
    -crf 1 \
    -threads 0 \
    -bf 0 \
    "$2" || exit 1
}

pngToVideo() {
  "$tools/ffmpeg/bin/ffmpeg.exe" -r 60 \
    -f image2 \
    -s 1280x720 \
    -i "$1" \
    -vcodec libx264 \
    -crf 25 \
    -pix_fmt yuv420p \
    "$2" || exit 1
}

speedUpVideo() {
  "$tools/ffmpeg/bin/ffmpeg.exe" -i "$1" \
    -filter:v "setpts=0.5*PTS" \
    "$2" || exit 1
}

addAudio() {
  "$tools/ffmpeg/bin/ffmpeg.exe" -i "$1" \
    -i "$2" \
    -map 0:v \
    -map 1:a \
    -c:v copy \
    -shortest \
    "$3" || exit 1
}

main() {
  resDir="$1"
  pngDir="$resDir/png"
  resPpm="$resDir/temp.ppm"
  pngFilePattern="$pngDir/f-############.png"
  videoTmp="$resDir/temp.mp4"
  videoLogstalgia="$resDir/logstalgia.mp4"
  videoGrouce="$resDir/gource.mp4"
  videoCodeSwarm="$resDir/codeswarm.mp4"

  echo "create png dir > $pngDir"
  mkdir "$pngDir"

  logstalgia="$scriptPath/logstalgia.sh"
  gource="$scriptPath/gource.sh"
  codeswarm="$scriptPath/codeswarm.sh"
  gen_log="$scriptPath/gen_log.py"

  tmpDir=$(mktemp -d)
  prefix="$tmpDir/actions"
  actions_c="$prefix""_codeswarm.xml"
  actions_g="$prefix""_gource.log"
  actions_l="$prefix""_logstalgia.log"

  pushd "$2" || exit
  py "$gen_log" -glce -p "$prefix"
  popd || exit

  doubleSpeed="$3"

  useLogstalgia="$4"
  useGource="$5"
  useCodeswarm="$6"

# Logstalgia
  [ -n "$useLogstalgia" ] && {
    sh "$logstalgia" "$actions_l" "$resPpm" || exit 1

    ppmToVideo "$resPpm" "$videoTmp"

    rm -f "$resPpm"

    [ -n "$doubleSpeed" ] && {
      speedUpVideo "$videoTmp" "$videoLogstalgia"
      mv -f "$videoLogstalgia" "$videoTmp"
    }

    addAudio "$videoTmp" "$scriptPath/data/deepSpace.mp3" "$videoLogstalgia"

    rm -f "$videoTmp"
  }

# Gource
  [ -n "$useGource" ] && {
    sh "$gource" "$actions_g" "$resPpm" "$scriptPath/logos/neto-logo.png" || exit 1

    ppmToVideo "$resPpm" "$videoTmp"

    rm -f "$resPpm"

    [ -n "$doubleSpeed" ] && {
      speedUpVideo "$videoTmp" "$videoGrouce"
      mv -f "$videoGrouce" "$videoTmp"
    }

    addAudio "$videoTmp" "$scriptPath/data/deepSpace.mp3" "$videoGrouce"

    rm -f "$videoTmp"
  }

# CodeSwarm
  [ -n "$useCodeswarm" ] && {
    sh "$codeswarm" "$actions_c" "$pngFilePattern" || exit 1

    pngToVideo "$pngDir/f-%012d.png" "$videoTmp"

    rm -rf "$pngDir"

    [ -n "$doubleSpeed" ] && {
      speedUpVideo "$videoTmp" "$videoCodeSwarm"
      mv -f "$videoCodeSwarm" "$videoTmp"
    }

    addAudio "$videoTmp" "$scriptPath/data/deepSpace.mp3" "$videoCodeSwarm"

    rm -f "$videoTmp"

    rm -fr "$tmpDir"
  }
}

printUsage() {
  echo -e "correct usage: $usage"
  exit
}

while [[ $# -gt 0 ]]
do
  case "$1" in
    -o)
      output="$2"
      shift 2
    ;;
    -r)
      gitWorkDir="$2"
      shift 2
    ;;
    -g)
      useGource=1
      shift 1
    ;;
    -l)
      useLogstalgia=1
      shift 1
    ;;
    -c)
      useCodeswarm=1
      shift 1
    ;;
    -s)
      doubleSpeed=1
      shift 1
    ;;
    *)
      shift
    ;;
  esac
done;

[ ! -d "$output" ] && printUsage
[ ! -d "$gitWorkDir" ] && {
  echo "argument '-g gitWorkDir' is not passed, will be used $(pwd)"
  gitWorkDir=$(pwd)
}

main "$output" "$gitWorkDir" "$doubleSpeed" "$useLogstalgia" "$useGource" "$useCodeswarm"
