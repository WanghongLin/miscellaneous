@echo off
::
:: Use screenrecord to take screenshot, support landscape mode.
:: FFmpeg for windows must install and add to %path% environment
::

set BaseName=%time::=.%_%random%.mp4
set RemoteName=/data/local/tmp/%BaseName%
set RawDate=%date:~3%
set LocalName=Screenshot_%RawDate:/=-%_%time::=-%.png
adb shell screenrecord --time-limit 1 %RemoteName%
adb pull %RemoteName%
adb shell rm %RemoteName%
ffmpeg -i %BaseName% -vframes 1 %LocalName%
del /f %BaseName%
start %LocalName%

echo Screenshot done...
pause
