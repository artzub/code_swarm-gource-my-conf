#!/bin/bash
scriptPath=$(realpath "$0")
scriptPath=$(dirname "$scriptPath")

#$(mktemp)
config=$(mktemp)

pngPath=$(cygpath -w "$2" | sed 's/\\/\\\\/g')

log="${1#*.}"
log="${log%/*}"
log="$log.xml"

mv "$1" "$scriptPath/tools/codeswarm/data/$log"

echo "pngPath: $pngPath"

cat > "$config" << EOF
ColorAssign1="Source Code", "(.*tcl)|(.*php)|(.*htm)|(.*html)|(.*xml)|(.*sql)|(.*sln)|(.*dproj)|(.*dpr)|(.*pas)|(.*dfm)|(.*js)|(.*jsx)|(.*ts)|(.*tsx)|(.*cs)|(.*css)|(.*py)|(.*rb)|(.*erb)|(.*hs)|(.*c)|(.*cpp)|(.*h)|(.*m)|(.*d)|(.*pl)|(.*sh)|(.*java)|(.*lhs)|(.*hi)", 100,255,255, 120,200,200
ColorAssign2="Settings", "(.*in)|(.*setting)|(.*ini)|(.*config)|(.*conf)", 90,90,255, 90,110,200
ColorAssign3="Imeges/Resources", "(.*ico)|(.*xpm)|(.*resx)|(.*gif)|(.*png)|(.*svg)|(.*jpg)|(.*bmp)", 90,255,90, 90,200,110
ColorAssign4="Documents", "(.*po)|(.*txt)|(.*log)|(.*uml)|(.*erwin)|(.*hlp)|(.*md)", 255,90,90, 200,90,110

Width=1280
Height=720
InputFile=data/$log
SnapshotLocation=$pngPath
#E:/results/png/f-############.png
#cs-#############.png

PhysicsEngineConfigDir=physics_engine
PhysicsEngineSelection=PhysicsEngineOrderly
#ParticleSpriteFile=src/particle.png
Font=Helvetica
FontSize=16
BoldFontSize=16
#MillisecondsPerFrame=2254085
# Optional Method instead of MillisecondsPerFrame
FramesPerDay=24
MaxThreads=8
Background=0,0,0
TakeSnapshots=true

DrawNamesSharp=true
DrawNamesHalos=true
DrawFilesSharp=false
DrawFilesFuzzy=true
DrawFilesJelly=false

ShowLegend=true
ShowHistory=true
ShowUserName=true
ShowDate=true
ShowEdges=true
ShowDebug=false

EdgeLength=36

EdgeDecrement=-2
FileDecrement=-2
PersonDecrement=-2

FileSpeed=7.0
PersonSpeed=2.0

FileMass=2.0
PersonMass=10.0

EdgeLife=240
FileLife=500
PersonLife=260

HighlightPct=1
UseOpenGL=false
IsInputSorted=false

AvatarSize=32
#LocalAvatarDirectory=data/my/logos/
#LocalAvatarDefaultPic=default.png

#AvatarFetcher=NoAvatar
#AvatarFetcher=LocalAvatar
#AvatarFetcher=FreebaseAvatarFetcher
AvatarFetcher=GravatarFetcher
EOF



pushd "$scriptPath/tools/codeswarm/" || exit 1
./run.bat "$config" || exit 1
popd || exit 1
