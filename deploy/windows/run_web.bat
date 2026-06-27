@echo off
setlocal EnableExtensions
rem Background static web process (for scheduled task)
cd /d "%~dp0.."
set "APP_ROOT=%CD%"
if not defined HOST set "HOST=0.0.0.0"
if not defined PORT set "PORT=18027"

call "%~dp0resolve_python.bat"
if errorlevel 1 exit /b 1

if not exist "%APP_ROOT%\index.html" exit /b 1

start "" /B %PY_BOOTSTRAP% "%APP_ROOT%\scripts\serve_web.py" %PORT% %HOST%
exit /b 0
