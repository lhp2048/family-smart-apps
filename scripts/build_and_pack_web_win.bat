@echo off
setlocal EnableExtensions

rem Deprecated: use family_smart_center_web\scripts\build_and_pack.bat
echo NOTE: Web portal packaging moved to family_smart_center_web
call "%~dp0..\..\family_smart_center_web\scripts\build_and_pack.bat"
exit /b %ERRORLEVEL%
