@echo off
setlocal EnableExtensions
rem Stop static web on PORT (default 18027)
rem Usage: scripts\stop_service_win.bat

if not defined PORT set "PORT=18027"

echo Stopping listeners on port %PORT% ...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%PORT%" ^| findstr "LISTENING"') do (
  taskkill /F /T /PID %%a >nul 2>&1
)
echo Done.
exit /b 0
