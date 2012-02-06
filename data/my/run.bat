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
	::call sh gen_log ./data/actions.xml -o=./data/actlogs.log -l
pause
	del data\gource.log
	del data\logstalgia.log
	
	if not exist data\actions.log goto actlogs
	call sh sort_log ./data/actions.log > data\gource.log
:actlogs
	if not exist data\actlogs.log goto code_swarm
	call sh sort_log ./data/actlogs.log > data\logstalgia.log
    rem del data\actions.log
::)

:code_swarm

if not exist data\actions.xml goto gource

pushd "%png%"
del *.png
popd

pushd ..\..
call run.bat data\my\my.config
popd

pushd "%png%"
call "%mencoder%" mf://*.png -mf fps=12:type=png -ovc x264 -x264encopts pass=1:bitrate=5000 -oac copy -audiofile "%rundir%\data\audio.mp3" -o "%results%\result.avi"
popd

pushd "%curRes%\png"
del *.png
popd


:gource

if not exist data\gource.log goto logstalgia

pushd "tools\gource"
call gource.exe --bloom-intensity 0.35 -b 333333 -1280x720 --hide filenames,dirnames,mouse,progress --user-scale 2 --output-framerate 25 --user-image-dir "%rundir%\logos"  --stop-position 1 --highlight-users --seconds-per-day 1 --output-ppm-stream "%results%\resultgource.ppm" "%rundir%\data\gource.log" --key --multi-sampling --auto-skip-seconds 1 --time-scale 1 --follow-user "Pavel Roskin <proski@gnu.org>" -i 0 --user-image-dir "%rundir%\..\..\image_cache"
:: --default-user-image "default" --elasticity 1
popd

pushd "tools\nt"
call ffmpeg -y -b 9000K -f image2pipe -vcodec ppm -i "%results%\resultgource.ppm" -fpre "..\ll.ffpreset" -i "%results%\resultgource.ppm" -vcodec libx264 "%results%\resultgource.avi"

del "%results%\resultgource.ppm"

call mencoder "%results%\resultgource.avi" -ovc x264 -x264encopts pass=1:bitrate=10000 -ofps 19 -speed 2 -o "%results%\resultgource.fps"

call mencoder "%results%\resultgource.fps" -ovc x264 -x264encopts pass=1:bitrate=10000 -oac copy -audiofile "%rundir%\data\audio.mp3" -o "%results%\resultgource.avi"
popd

del "%results%\resultgource.fps"

:logstalgia

if not exist data\logstalgia.log goto :EOF

pushd "tools\logstalgia"
call logstalgia.exe --no-bounce --hide-paddle -b 111111 -1280x720 --glow-duration 1 --glow-multiplier 2 --glow-intensity 1 -g post,(.*\.post$),20,EEB211 -g share,(.*\.share$),20,3369E8 -g plus,(.*\.plus$),20,009939 -g comment,(.*\.comment$),20,D50F25 -g reshare,(.*\.reshare$),20,df73ff "%rundir%\data\logstalgia.log" --output-framerate 25 --output-ppm-stream "%results%\resultlogstalgia.ppm"
popd

pushd "tools\nt"
call ffmpeg -y -b 9000K -f image2pipe -vcodec ppm -i "%results%\resultlogstalgia.ppm" -fpre "..\ll.ffpreset" -i "%results%\resultlogstalgia.ppm" -vcodec libx264 "%results%\resultlogstalgia.avi"

del "%results%\resultlogstalgia.ppm"

call mencoder "%results%\resultlogstalgia.avi" -ovc x264 -x264encopts pass=1:bitrate=10000 -ofps 19 -speed 2 -o "%results%\resultlogstalgia.fps"

call mencoder "%results%\resultlogstalgia.fps" -ovc x264 -x264encopts pass=1:bitrate=10000 -oac copy -audiofile "%rundir%\data\audio.mp3" -o "%results%\resultlogstalgia.avi"
popd

del "%results%\resultlogstalgia.fps"

echo on