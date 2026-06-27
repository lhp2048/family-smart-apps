@echo off
setlocal EnableExtensions

rem Preview build/web locally (default :18027)
rem Usage: scripts\serve.bat [port]

set "SCRIPT_DIR=%~dp0"
set "APP_ROOT=%SCRIPT_DIR%.."
set "WEB_DIR=%APP_ROOT%\build\web"
set "PORT=%~1"
if "%PORT%"=="" set "PORT=18027"

if not exist "%WEB_DIR%\index.html" (
  echo ERROR: %WEB_DIR%\index.html not found.
  echo Run scripts\build.bat first.
  exit /b 1
)

where python >nul 2>&1
if errorlevel 1 (
  echo ERROR: python not found.
  exit /b 1
)

echo Web App: http://127.0.0.1:%PORT%/
cd /d "%WEB_DIR%"
if exist "%WEB_DIR%\scripts\serve_web.py" (
  python "%WEB_DIR%\scripts\serve_web.py" %PORT% 127.0.0.1
) else (
  python -m http.server %PORT% --bind 127.0.0.1
)

endlocal
