@echo off
setlocal EnableExtensions

rem Pack family_smart_apps build/web into zip for Mac deployment
rem Usage: scripts\pack_web_for_mac_win.bat
rem Prerequisite: scripts\build_web_win.bat

set "SCRIPT_DIR=%~dp0"
set "APP_ROOT=%SCRIPT_DIR%.."
set "WEB_DIR=%APP_ROOT%\build\web"
set "OUT_DIR=%APP_ROOT%\dist_out"
set "ZIP_FILE=%OUT_DIR%\family_smart_apps_web.zip"

if not exist "%WEB_DIR%\index.html" (
  echo ERROR: %WEB_DIR%\index.html not found.
  echo Run scripts\build_web_win.bat first.
  exit /b 1
)

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
if exist "%ZIP_FILE%" del /f /q "%ZIP_FILE%"

powershell -NoProfile -Command "Compress-Archive -Path '%WEB_DIR%\*' -DestinationPath '%ZIP_FILE%' -Force"
if errorlevel 1 exit /b 1

echo.
echo Packed: %ZIP_FILE%

endlocal

