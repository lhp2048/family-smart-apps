@echo off
setlocal EnableExtensions

rem family_smart_center - Build Web Release (Windows)
rem Usage: scripts\build_web_win.bat
rem Optional: set FLUTTER_BIN=C:\path\to\flutter.bat

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

if exist "%FLUTTER%" goto :flutter_ok
where flutter >nul 2>&1
if errorlevel 1 (
  echo ERROR: flutter not found. Install Flutter SDK or set FLUTTER_BIN.
  exit /b 1
)
:flutter_ok

echo Flutter: %FLUTTER%
echo Workdir: %CD%
echo.

call "%FLUTTER%" pub get
if errorlevel 1 exit /b 1

call "%DART%" run tool/generate_build_stamp.dart
if errorlevel 1 exit /b 1

call "%FLUTTER%" build web --release --no-wasm-dry-run --base-href=/ --pwa-strategy=none
if errorlevel 1 exit /b 1

if not exist "%APP_ROOT%\build\web\scripts" mkdir "%APP_ROOT%\build\web\scripts"
copy /Y "%APP_ROOT%\deploy\mac\*.sh" "%APP_ROOT%\build\web\scripts\" >nul
copy /Y "%APP_ROOT%\deploy\mac\serve_web.py" "%APP_ROOT%\build\web\scripts\serve_web.py" >nul
copy /Y "%APP_ROOT%\deploy\web\flutter_service_worker_uninstall.js" "%APP_ROOT%\build\web\flutter_service_worker.js" >nul
copy /Y "%APP_ROOT%\deploy\mac\INSTALL.txt" "%APP_ROOT%\build\web\INSTALL.txt" >nul

echo.
echo Done: %CD%\build\web
echo Pack zip:  scripts\pack_web_for_mac_win.bat  -^>  dist_out\family_smart_apps_web.zip
echo One-shot:   scripts\build_and_pack_web_win.bat

endlocal
