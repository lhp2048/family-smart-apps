@echo off
setlocal EnableExtensions
rem Stop then start static web in background (Windows)
rem Usage: scripts\restart_service_win.bat

cd /d "%~dp0.."
set "APP_ROOT=%CD%"
if not defined PORT set "PORT=18027"

if not exist "%APP_ROOT%\index.html" (
  echo ERROR: index.html not found in %APP_ROOT%
  exit /b 1
)

call "%~dp0stop_service_win.bat"
call "%~dp0resolve_python.bat"
if errorlevel 1 exit /b 1
call "%~dp0run_web.bat"
timeout /t 2 /nobreak >nul
echo Restarted. Web App: http://127.0.0.1:%PORT%/
exit /b 0
