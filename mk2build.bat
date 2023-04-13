@echo off

rem *** remember to update mknewdoc.bat & mk2-unicode.bat

setlocal

call "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcvarsall.bat"

echo hbmk2 lib.hbp
hbmk2 lib.hbp

endlocal
