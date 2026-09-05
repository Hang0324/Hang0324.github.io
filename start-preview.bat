@echo off
cd /d "%~dp0"
start "HangPreviewServer" /min python -m http.server 4173 --bind 127.0.0.1
ping 127.0.0.1 -n 2 >nul
start "" "http://127.0.0.1:4173/"
exit
