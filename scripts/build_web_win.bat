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

call "%FLUTTER%" build web --release --no-wasm-dry-run --base-href=/app/
if errorlevel 1 exit /b 1

echo.
echo Done: %CD%\build\web
echo One-shot pack: scripts\build_and_pack_web_win.bat
echo Or pack only: scripts\pack_web_for_mac_win.bat

endlocal
