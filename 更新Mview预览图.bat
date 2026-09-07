@echo off
cd /d "%~dp0"
echo Updating cover images from model.mview files...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\extract-mview-thumbnails.ps1" -ProjectRoot "%CD%"
echo.
if errorlevel 1 (
  echo Update failed. Please check the message above.
) else (
  echo Update complete. Previous covers are saved as cover.backup.jpg.
)
echo.
pause
