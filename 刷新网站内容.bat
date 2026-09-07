@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -Command "Start-Process ('http://127.0.0.1:4173/?refresh=' + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds())"
exit
