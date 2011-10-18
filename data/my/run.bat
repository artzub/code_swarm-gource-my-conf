echo on
set rundir=%~p0
set rundir=%~d0%rundir:~0,-1%

set curRes=%1
if "%curRes%" == "" (
    set curRes=%rundir%
)

if not "%2" == "" (
    call sh gen_log ./data/actions.xml

	call sh sort_log ./data/actions.log > data\gource.log
    del data\actions.log
)

pushd "%curRes%\png"
del *.png
popd
echo on

pushd ..\..
call run.bat data\my\my.config
popd

pushd "%curRes%\png"
call "%rundir%\tools\nt\mencoder" mf://*.png -mf fps=19:type=png -ovc x264 -x264encopts pass=1:bitrate=1000 -oac copy -audiofile "%rundir%\data\audio.wav" -o "%curRes%\results\result.avi"
popd

pushd "%curRes%\png"
del *.png
popd

pushd "tools\gource"
call gource.exe --bloom-intensity 0.35 -b 333333 --hide filenames,dirnames --user-scale 2 --output-framerate 25 --user-image-dir "logos" --follow-user "artzub" --default-user-image "default.png" --stop-position 1 --highlight-all-users --seconds-per-day 1 --output-ppm-stream "%curRes%\results\resultgource.ppm" "%rundir%\data\gource.log"
::--user-image-dir "logos" --follow-user "artzub" --default-user-image "default.png" 
popd

pushd "tools\nt"
call ffmpeg -y -b 9000K -f image2pipe -vcodec ppm -i "%curRes%\results\resultgource.ppm" -fpre "..\ll.ffpreset" -i "%curRes%\results\resultgource.ppm" -vcodec libx264 "%curRes%\results\resultgource.avi"

del "%curRes%\results\resultgource.ppm"

call mencoder "%curRes%\results\resultgource.avi" -ovc x264 -x264encopts pass=1:bitrate=10000 -ofps 19 -speed 2 -o "%curRes%\results\resultgource.fps"

call mencoder "%curRes%\results\resultgource.fps" -ovc x264 -x264encopts pass=1:bitrate=10000 -oac copy -audiofile "%rundir%\data\audio.wav" -o "%curRes%\results\resultgource.avi"
popd

del %curRes%\results\resultgource.fps