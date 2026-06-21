@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem family_smart_apps standalone web dev - kill port then flutter run
rem Usage: scripts\run_web_dev_win.bat [port]
rem Default: http://127.0.0.1:8080

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

set "PORT=8080"
if not "%~1"=="" set "PORT=%~1"

echo Flutter: %FLUTTER%
echo App: http://127.0.0.1:%PORT%/
echo.

rem Kill previous dev server on this port (errno 10048 if still bound)
echo [run_web_dev] Releasing port %PORT% ...
set "KILLED=0"
for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":%PORT%" ^| findstr "LISTENING"') do (
  if not "%%p"=="0" (
    echo [run_web_dev]   taskkill /F /PID %%p
    taskkill /F /PID %%p >nul 2>&1
    if not errorlevel 1 set "KILLED=1"
  )
)
if "!KILLED!"=="1" ping -n 2 127.0.0.1 >nul
if "!KILLED!"=="0" echo [run_web_dev]   port %PORT% is free

call "%FLUTTER%" run -d chrome --web-port=%PORT% --web-hostname=127.0.0.1
exit /b %ERRORLEVEL%
