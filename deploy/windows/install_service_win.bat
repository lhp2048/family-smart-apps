@echo off
setlocal EnableExtensions
rem Windows: register logon scheduled task + start static web
rem Usage: scripts\install_service_win.bat [--uninstall] [--status]

cd /d "%~dp0.."
set "APP_ROOT=%CD%"
set "TASK_NAME=FamilySmartAppsWeb"
set "START_SCRIPT=%APP_ROOT%\scripts\run_web.bat"
if not defined PORT set "PORT=18027"

if /i "%~1"=="--uninstall" goto :uninstall
if /i "%~1"=="--status" goto :status

if not exist "%APP_ROOT%\index.html" (
  echo ERROR: run from install directory with index.html
  exit /b 1
)

call "%~dp0resolve_python.bat"
if errorlevel 1 exit /b 1

call "%~dp0stop_service_win.bat"

schtasks /Create /TN "%TASK_NAME%" /TR "\"%START_SCRIPT%\"" /SC ONLOGON /RL LIMITED /F
if errorlevel 1 (
  echo ERROR: schtasks failed. Try run start_service_win.bat manually.
  exit /b 1
)

call "%~dp0run_web.bat"
timeout /t 2 /nobreak >nul

echo Installed scheduled task: %TASK_NAME%
echo Local:  http://127.0.0.1:%PORT%/
echo LAN:    http://YOUR_LAN_IP:%PORT%/  (run ipconfig to find IP)
echo Restart: service.bat restart
echo Stop:    service.bat stop
echo Windows Firewall: allow Python if LAN access is blocked
exit /b 0

:status
schtasks /Query /TN "%TASK_NAME%" >nul 2>&1
if errorlevel 1 (
  echo Task not installed: %TASK_NAME%
) else (
  schtasks /Query /TN "%TASK_NAME%" /FO LIST /V
)
exit /b 0

:uninstall
schtasks /Delete /TN "%TASK_NAME%" /F >nul 2>&1
call "%~dp0stop_service_win.bat"
echo Uninstalled: %TASK_NAME%
exit /b 0
