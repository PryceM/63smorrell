@echo off
setlocal
set "REPO=C:\Users\pmandel.ATTAIN\GitHub\63smorrell"
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%\scripts\pryce-site.ps1" %*
endlocal
