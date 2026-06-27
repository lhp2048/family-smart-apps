@echo off
setlocal EnableExtensions
rem Build Web Release and pack zip
rem Usage: scripts\build_and_pack.bat

call "%~dp0build.bat"
if errorlevel 1 exit /b 1

call "%~dp0pack.bat"
exit /b %ERRORLEVEL%
