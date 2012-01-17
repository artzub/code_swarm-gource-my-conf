@echo off
set rundir=%~p0
set rundir=%~d0%rundir:~0,-1%

set curRes=E:\results
::%1
if "%curRes%" == "" (
    set curRes=%rundir%
)

@echo usege path:
@echo curRes = %curRes%
set png=%curRes%\png
set mencoder=%rundir%\tools\nt\mencoder
set results=%curRes%\results

::if not "%2" == "" (
	::call sh gen_log ./data/actions.xml

	call sh sort_log ./data/actions.log > data\gource.log
    rem del data\actions.log
::)

pushd "%png%"
del *.png
popd

pushd ..\..
call run.bat data\my\my.config
popd

pushd "%png%"
call "%mencoder%" mf://*.png -mf fps=12:type=png -ovc x264 -x264encopts pass=1:bitrate=5000 -oac copy -audiofile "%rundir%\data\audio.wav" -o "%results%\result.avi"
popd

pushd "%curRes%\png"
del *.png
popd

pushd "tools\gource"
call gource.exe --bloom-intensity 0.35 -b 333333 --hide filenames,dirnames --user-scale 2 --output-framerate 25 --user-image-dir "%rundir%\logos"  --stop-position 1 --highlight-all-users --seconds-per-day 1 --output-ppm-stream "%results%\resultgource.ppm" "%rundir%\data\gource.log" --user-image-dir "%rundir%\logos" --follow-user "Larry Page"
:: --default-user-image "default" 
popd

pushd "tools\nt"
call ffmpeg -y -b 9000K -f image2pipe -vcodec ppm -i "%results%\resultgource.ppm" -fpre "..\ll.ffpreset" -i "%results%\resultgource.ppm" -vcodec libx264 "%results%\resultgource.avi"

del "%results%\resultgource.ppm"

call mencoder "%results%\resultgource.avi" -ovc x264 -x264encopts pass=1:bitrate=10000 -ofps 19 -speed 2 -o "%results%\resultgource.fps"

call mencoder "%results%\resultgource.fps" -ovc x264 -x264encopts pass=1:bitrate=10000 -oac copy -audiofile "%rundir%\data\audio.wav" -o "%results%\resultgource.avi"
popd

del "%results%\resultgource.fps"
echo on