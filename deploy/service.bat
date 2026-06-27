@echo off
setlocal EnableExtensions
rem Service maintenance (single entry): install | start | stop | restart | status | uninstall
rem Usage: service.bat install

cd /d "%~dp0"

if "%~1"=="" goto :usage

set "ACTION=%~1"
shift

if /i "%ACTION%"=="install" (
  call "%~dp0scripts\install_service_win.bat" %*
  exit /b %ERRORLEVEL%
)
if /i "%ACTION%"=="start" (
  call "%~dp0scripts\start_service_win.bat" %*
  exit /b %ERRORLEVEL%
)
if /i "%ACTION%"=="stop" (
  call "%~dp0scripts\stop_service_win.bat" %*
  exit /b %ERRORLEVEL%
)
if /i "%ACTION%"=="restart" (
  call "%~dp0scripts\restart_service_win.bat" %*
  exit /b %ERRORLEVEL%
)
if /i "%ACTION%"=="status" (
  call "%~dp0scripts\install_service_win.bat" --status %*
  exit /b %ERRORLEVEL%
)
if /i "%ACTION%"=="uninstall" (
  call "%~dp0scripts\install_service_win.bat" --uninstall %*
  exit /b %ERRORLEVEL%
)

echo Unknown action: %ACTION%
goto :usage

:usage
echo Usage: service.bat install^|start^|stop^|restart^|status^|uninstall
exit /b 1
