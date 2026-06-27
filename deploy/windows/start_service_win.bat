@echo off
setlocal EnableExtensions
rem Start static web (foreground)
rem Usage: scripts\start_service_win.bat

cd /d "%~dp0.."
set "APP_ROOT=%CD%"
set "HOST=0.0.0.0"
if not defined PORT set "PORT=18027"

if not exist "%APP_ROOT%\index.html" (
  echo ERROR: index.html not found in %APP_ROOT%
  exit /b 1
)

call "%~dp0resolve_python.bat"
if errorlevel 1 exit /b 1

echo Web App: http://127.0.0.1:%PORT%/
echo Root: %APP_ROOT%
echo Press Ctrl+C to stop
%PY_BOOTSTRAP% "%APP_ROOT%\scripts\serve_web.py" %PORT% %HOST%
exit /b %ERRORLEVEL%
