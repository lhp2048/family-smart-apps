@echo off
setlocal EnableExtensions
rem Stop static web on PORT (default 18027)
rem Usage: scripts\stop_service_win.bat

if not defined PORT set "PORT=18027"

echo Stopping listeners on port %PORT% ...
call "%~dp0kill_port_listener.bat" %PORT% python
echo Done.
exit /b 0
