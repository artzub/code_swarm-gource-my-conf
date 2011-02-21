del data\actions_orign.xml
ren data\actions.xml actions_orign.xml

call sortDate.exe data\actions_orign.xml

ren data\actions_res.xml actions.xml

call genlogforgourcefromcodeswarm.exe data\actions.xml

pushd png
del *.png
popd

pushd ..\..
call run.bat data\my\my.config
popd

pushd png
call "..\tools\nt\mencoder" mf://*.png -mf fps=19:type=png -ovc x264 -x264encopts pass=1:bitrate=1000 -oac copy -audiofile "..\data\audio.wav" -o "..\results\result.avi"
popd

call gource --hide filenames,dirnames --user-scale 2 --output-framerate 25 --stop-position 1 --highlight-all-users --seconds-per-day 1 --output-ppm-stream "results\resultgource.ppm" "data\gource.log"
rem --user-image-dir "logos" --follow-user "artzub" --default-user-image "default.png" 
call "..\tools\nt\ffmpeg" -y -b 9000K -f image2pipe -vcodec ppm -i "results\resultgource.ppm" -fpre "..\tools\ll.ffpreset" -i "results\resultgource.ppm" -vcodec libx264 "results\resultgource.avi"

call "..\tools\nt\mencoder" "results\resultgource.avi" -ovc x264 -x264encopts pass=1:bitrate=10000 -ofps 19 -speed 2 -o "results\resultgource.fps"

call "..\tools\nt\mencoder" "results\resultgource.fps" -ovc x264 -x264encopts pass=1:bitrate=10000 -oac copy -audiofile "data\audio.wav" -o "results\resultgource.avi"