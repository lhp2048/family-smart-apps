@echo off
setlocal EnableExtensions

rem Deprecated: use family_smart_center_web\scripts\serve.bat
echo NOTE: Web portal serve moved to family_smart_center_web
call "%~dp0..\..\family_smart_center_web\scripts\serve.bat"
exit /b %ERRORLEVEL%
