@echo off
setlocal EnableExtensions

rem Build Web Release and pack zip (family_smart_apps only)
rem Usage: scripts\build_and_pack_web_win.bat

call "%~dp0build_web_win.bat"
if errorlevel 1 exit /b 1

call "%~dp0pack_web_for_mac_win.bat"
exit /b %ERRORLEVEL%

