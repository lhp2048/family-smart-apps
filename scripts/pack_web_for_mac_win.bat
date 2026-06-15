@echo off
setlocal EnableExtensions

rem Pack build\web + Mac service scripts into zip (LF line endings)
rem Usage: scripts\pack_web_for_mac_win.bat
rem Run build_web_win.bat first

set "SCRIPT_DIR=%~dp0"
set "APP_ROOT=%SCRIPT_DIR%.."
set "WEB_DIR=%APP_ROOT%\build\web"
set "WEB_SCRIPTS=%WEB_DIR%\scripts"
set "DEPLOY_MAC=%APP_ROOT%\deploy\mac"
set "DIST_DIR=%APP_ROOT%\dist"
set "ZIP_FILE=%DIST_DIR%\family_smart_center_web.zip"
set "NORMALIZE_PS=%SCRIPT_DIR%normalize_lf.ps1"

cd /d "%APP_ROOT%"

if not exist "%WEB_DIR%\index.html" (
  echo ERROR: %WEB_DIR%\index.html not found. Run scripts\build_web_win.bat first.
  exit /b 1
)

if not exist "%DEPLOY_MAC%\install_service_mac.sh" (
  echo ERROR: %DEPLOY_MAC%\install_service_mac.sh not found.
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%NORMALIZE_PS%" -Paths "%DEPLOY_MAC%\*.sh"

if not exist "%WEB_SCRIPTS%" mkdir "%WEB_SCRIPTS%"
copy /Y "%DEPLOY_MAC%\*.sh" "%WEB_SCRIPTS%\" >nul
copy /Y "%DEPLOY_MAC%\INSTALL.txt" "%WEB_DIR%\INSTALL.txt" >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%NORMALIZE_PS%" -Paths "%WEB_SCRIPTS%\*.sh"
echo Bundled Mac service scripts into build\web\scripts\ (LF)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"
if exist "%ZIP_FILE%" del /f /q "%ZIP_FILE%"

powershell -NoProfile -Command "Compress-Archive -Path '%WEB_DIR%\*' -DestinationPath '%ZIP_FILE%' -Force"
if errorlevel 1 exit /b 1

echo.
echo Packed: %ZIP_FILE%
echo.
echo Mac:
echo   unzip family_smart_center_web.zip -d ~/family_smart_center_web
echo   cd ~/family_smart_center_web
echo   chmod +x scripts/*.sh
echo   ./scripts/install_service_mac.sh

endlocal
