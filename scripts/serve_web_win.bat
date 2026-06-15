@echo off
setlocal EnableExtensions

rem Serve built Web App locally (default :18027)
rem Usage: scripts\serve_web_win.bat
rem Build first: scripts\build_web_win.bat

set "SCRIPT_DIR=%~dp0"
set "WEB_DIR=%SCRIPT_DIR%..\build\web"
set "PORT=18027"

if not exist "%WEB_DIR%\index.html" (
  echo ERROR: %WEB_DIR%\index.html not found. Run scripts\build_web_win.bat first.
  exit /b 1
)

echo Web App: http://127.0.0.1:%PORT%
echo Press Ctrl+C to stop
echo.

cd /d "%WEB_DIR%"
python -m http.server %PORT%

endlocal
