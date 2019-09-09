@echo off
::
:: Use screencap to take screenshot, output image will be stretching 
:: if the target device in landscape mode, for better landscape support
:: try adb_screenshot_v2.bat
::

set RawDate=%date:~3%
set FileNameDate=%RawDate:/=-%
set FileName=Screenshot_%FileNameDate%_%time::=-%.png
adb exec-out screencap -p > %FileName%
start %FileName%

echo Screenshot done...
pause
