@echo off
setlocal EnableExtensions
rem Pack build/web into zip + bump version + validate manifest + package-index
rem Usage: scripts\pack.bat

set "SCRIPT_DIR=%~dp0"
set "APP_ROOT=%SCRIPT_DIR%.."
set "WEB_DIR=%APP_ROOT%\build\web"
set "OUT_DIR=%APP_ROOT%\dist_out"
set "PORTAL_SCRIPTS=%APP_ROOT%\..\family_smart_center_web\scripts"

set "PYTHON=python"
if exist "%APP_ROOT%\..\family_smart_center_web\.venv\Scripts\python.exe" (
  set "PYTHON=%APP_ROOT%\..\family_smart_center_web\.venv\Scripts\python.exe"
)

for /f "usebackq delims=" %%v in (`"%PYTHON%" "%PORTAL_SCRIPTS%\read_manifest_field.py" "%APP_ROOT%\family-product.json" zipNameHint family_smart_apps_web.zip`) do set "ZIP_NAME=%%v"
if not defined ZIP_NAME set "ZIP_NAME=family_smart_apps_web.zip"
set "ZIP_FILE=%OUT_DIR%\%ZIP_NAME%"

if not exist "%WEB_DIR%\index.html" (
  echo ERROR: %WEB_DIR%\index.html not found. Run scripts\build.bat first.
  exit /b 1
)

if not exist "%WEB_DIR%\scripts\install_service_mac.sh" (
  echo Deploy scripts missing in build\web, running stage_web_deploy.bat ...
  call "%SCRIPT_DIR%stage_web_deploy.bat"
  if errorlevel 1 exit /b 1
)

"%PYTHON%" "%PORTAL_SCRIPTS%\bump_manifest_version.py" --manifest "%APP_ROOT%\family-product.json" --dist "%WEB_DIR%"
if errorlevel 1 exit /b 1

"%PYTHON%" "%PORTAL_SCRIPTS%\validate_manifest.py" "%APP_ROOT%\family-product.json" --dist "%WEB_DIR%"
if errorlevel 1 exit /b 1

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
if exist "%ZIP_FILE%" del /f /q "%ZIP_FILE%"

"%PYTHON%" "%PORTAL_SCRIPTS%\make_zip.py" "%WEB_DIR%" "%ZIP_FILE%"
if errorlevel 1 exit /b 1

"%PYTHON%" "%PORTAL_SCRIPTS%\write_package_info.py" --manifest "%APP_ROOT%\family-product.json" --zip "%ZIP_FILE%" --dist "%WEB_DIR%" --out-dir "%OUT_DIR%"
if errorlevel 1 exit /b 1

echo.
echo Packed: %ZIP_FILE%

endlocal
