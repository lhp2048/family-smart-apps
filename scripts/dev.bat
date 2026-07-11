@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Local Web dev — flutter run -d chrome
rem Usage: scripts\dev.bat [port]
rem Default: http://127.0.0.1:18027

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

set "PORT=18027"
if not "%~1"=="" set "PORT=%~1"

echo Flutter: %FLUTTER%
echo App: http://127.0.0.1:%PORT%/
echo.

echo [dev] Releasing port %PORT% ...
call "%APP_ROOT%\deploy\windows\kill_port_listener.bat" %PORT% dart
ping -n 2 127.0.0.1 >nul

call "%FLUTTER%" run -d chrome --web-port=%PORT% --web-hostname=127.0.0.1
exit /b %ERRORLEVEL%
