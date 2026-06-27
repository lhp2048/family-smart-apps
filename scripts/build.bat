@echo off
setlocal EnableExtensions

rem Build Web Release (Windows)
rem Usage: scripts\build.bat
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

call "%SCRIPT_DIR%stage_web_deploy.bat"
if errorlevel 1 exit /b 1

echo.
echo Done: %CD%\build\web
echo Pack zip:  scripts\pack.bat  -^>  dist_out\family_smart_apps_web.zip
echo One-shot:   scripts\build_and_pack.bat

endlocal
