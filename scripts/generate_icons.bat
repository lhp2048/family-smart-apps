@echo off
setlocal EnableExtensions
rem Regenerate launcher icons and splash screens from assets/app_icon/app_icon_source.png
rem Usage: scripts\generate_icons.bat
rem Run after replacing app_icon_source.png (1024x1024 PNG).

set "SCRIPT_DIR=%~dp0"
set "APP_ROOT=%SCRIPT_DIR%.."
cd /d "%APP_ROOT%"

if defined FLUTTER_BIN (
  set "FLUTTER=%FLUTTER_BIN%"
) else if exist "C:\flutter\bin\flutter.bat" (
  set "FLUTTER=C:\flutter\bin\flutter.bat"
) else (
  set "FLUTTER=flutter"
)

for %%I in ("%FLUTTER%") do set "FLUTTER_DIR=%%~dpI"
if exist "%FLUTTER_DIR%dart.bat" (
  set "DART=%FLUTTER_DIR%dart.bat"
) else (
  set "DART=dart"
)

echo Flutter: %FLUTTER%
echo Workdir: %CD%
echo.

call "%FLUTTER%" pub get
if errorlevel 1 exit /b 1

python "%APP_ROOT%\tool\process_app_icon.py"
if errorlevel 1 exit /b 1

call "%DART%" run flutter_launcher_icons
if errorlevel 1 exit /b 1

call "%DART%" run flutter_native_splash:create
if errorlevel 1 exit /b 1

echo.
echo Done: launcher icons + splash screens regenerated from assets\app_icon\app_icon_source.png

endlocal
