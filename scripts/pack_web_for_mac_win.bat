@echo off
setlocal EnableExtensions

rem Deprecated: use family_smart_center_web\scripts\pack.bat
call "%~dp0..\..\family_smart_center_web\scripts\pack.bat"
exit /b %ERRORLEVEL%
