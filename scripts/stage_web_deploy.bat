@echo off
setlocal EnableExtensions
rem Stage deploy scripts into build/web after flutter build
rem Usage: scripts\stage_web_deploy.bat

set "SCRIPT_DIR=%~dp0"
set "APP_ROOT=%SCRIPT_DIR%.."
set "WEB_DIR=%APP_ROOT%\build\web"
set "DEPLOY=%APP_ROOT%\deploy"
set "PORTAL_SCRIPTS=%APP_ROOT%\..\family_smart_center_web\scripts"

if not exist "%WEB_DIR%\index.html" (
  echo ERROR: %WEB_DIR%\index.html not found.
  exit /b 1
)

if not exist "%WEB_DIR%\scripts" mkdir "%WEB_DIR%\scripts"
if not exist "%WEB_DIR%\scripts\lib" mkdir "%WEB_DIR%\scripts\lib"

copy /Y "%DEPLOY%\INSTALL.txt" "%WEB_DIR%\INSTALL.txt" >nul
for %%F in (service install) do (
  if exist "%DEPLOY%\%%F.bat" copy /Y "%DEPLOY%\%%F.bat" "%WEB_DIR%\%%F.bat" >nul
  if exist "%DEPLOY%\%%F.sh" copy /Y "%DEPLOY%\%%F.sh" "%WEB_DIR%\%%F.sh" >nul
)

copy /Y "%DEPLOY%\windows\*.bat" "%WEB_DIR%\scripts\" >nul
copy /Y "%DEPLOY%\linux\*.sh" "%WEB_DIR%\scripts\" >nul
copy /Y "%DEPLOY%\mac\*.sh" "%WEB_DIR%\scripts\" >nul
copy /Y "%DEPLOY%\lib\*.sh" "%WEB_DIR%\scripts\lib\" >nul
copy /Y "%DEPLOY%\mac\serve_web.py" "%WEB_DIR%\scripts\serve_web.py" >nul
copy /Y "%DEPLOY%\web\flutter_service_worker_uninstall.js" "%WEB_DIR%\flutter_service_worker.js" >nul
copy /Y "%APP_ROOT%\family-product.json" "%WEB_DIR%\family-product.json" >nul

set "PYTHON=python"
if exist "%APP_ROOT%\..\family_smart_center_web\.venv\Scripts\python.exe" (
  set "PYTHON=%APP_ROOT%\..\family_smart_center_web\.venv\Scripts\python.exe"
)

if exist "%PORTAL_SCRIPTS%\normalize_shell.py" (
  "%PYTHON%" "%PORTAL_SCRIPTS%\normalize_shell.py" "%WEB_DIR%\scripts" "%WEB_DIR%"
)

echo Staged deploy into: %WEB_DIR%
endlocal
