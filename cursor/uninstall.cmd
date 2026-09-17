@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "_SCHEME=Cursor Concept W11 Tail HDPi"
set "_AUTHOR=JepriCreations"
set "SCHEMES_KEY=HKCU\Control Panel\Cursors\Schemes"
set "CURSORS_KEY=HKCU\Control Panel\Cursors"

set "BASE_DIR=%LOCALAPPDATA%\Cursors\%_AUTHOR%"
if not exist "%BASE_DIR%" (
  echo [error] No installed cursor schemes found for %_AUTHOR%.
  exit /b 1
)

echo [info] Scanning installed schemes by %_AUTHOR%...
set /a COUNT=0
for /d %%D in ("%BASE_DIR%\*") do (
  set /a COUNT+=1
  set "SCHEME_!COUNT!=%%~nxD"
)
if !COUNT! equ 0 (
  echo [error] No installed schemes found in "%BASE_DIR%".
  exit /b 1
)

echo.
echo Select the scheme to uninstall:
for /l %%i in (1,1,!COUNT!) do echo   %%i. !SCHEME_%%i!
echo   A. Uninstall ALL schemes
:askChoice
set /p "CHOICE=Enter number or A for all: "
if /i "%CHOICE%"=="A" goto uninstall_all
if "%CHOICE%"=="" goto askChoice
if not defined SCHEME_%CHOICE% (
  echo [error] Invalid choice.
  goto askChoice
)
set "TARGET=!SCHEME_%CHOICE%!"
goto uninstall_one

:uninstall_one
echo.
echo [info] Preparing to uninstall: %TARGET%
set "TARGET_PATH=%BASE_DIR%\%TARGET%"
set "REG_NAME=%TARGET%"
call :get_current_scheme

if /i "%CURRENT_SCHEME%"=="%TARGET%" (
  echo [info] Currently active scheme is being uninstalled, reverting to Windows Default ^(system scheme^)...
  rem Set scheme name to Windows Default and Scheme Source to 2 (system scheme)
)
if /i "%CURRENT_SCHEME%"=="%TARGET%" call :restore_default_scheme

echo [info] Removing registry entry under Schemes...
reg delete "%SCHEMES_KEY%" /v "%REG_NAME%" /f >nul 2>nul

if exist "%TARGET_PATH%" (
  echo [info] Deleting folder: %TARGET_PATH%
  rmdir /s /q "%TARGET_PATH%"
)

echo [ok] Scheme "%TARGET%" uninstalled successfully.

if /i "%CURRENT_SCHEME%"=="%TARGET%" (
  call :open_mouse_properties
)

goto end

:uninstall_all
echo.
echo [info] Uninstalling all schemes under "%BASE_DIR%"...
call :get_current_scheme

for /d %%D in ("%BASE_DIR%\*") do (
  set "REG_NAME=%%~nxD"
  echo [info] Removing %%~nxD...
  reg delete "%SCHEMES_KEY%" /v "%%~nxD" /f >nul 2>nul
  rmdir /s /q "%%~fD"
  if /i "!CURRENT_SCHEME!"=="%%~nxD" (
    echo [info] Reverting to Windows Default ^(system scheme^) because %%~nxD was active.
    rem Set scheme name to Windows Default and Scheme Source to 2 (system scheme)
  )
  if /i "!CURRENT_SCHEME!"=="%%~nxD" call :restore_default_scheme
  if /i "!CURRENT_SCHEME!"=="%%~nxD" (
    call :open_mouse_properties
  )
)
echo [ok] All "%_AUTHOR%" schemes uninstalled.

:end
echo.
echo [info] Uninstallation finished.
set /p "DUMMY=Press Enter to exit, or close this window."
exit /b 0

rem ================== SUPPORT SUBROUTINES ==================

:open_mouse_properties
echo.
echo [info] Mouse Properties will open with "Windows Default (system scheme)" preselected. Press the "OK" button to apply the changes.
set /p "DUMMY=Press Enter to open Mouse Properties (Pointers tab)"
rundll32.exe shell32.dll,Control_RunDLL main.cpl,,1
goto :eof

:restore_default_scheme
reg add "%CURSORS_KEY%" /v "" /t REG_SZ /d "Windows Default" /f >nul
reg add "%CURSORS_KEY%" /v "Scheme Source" /t REG_DWORD /d 2 /f >nul
rem Restore default cursor paths
reg add "%CURSORS_KEY%" /v "AppStarting" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_working.ani" /f >nul
reg add "%CURSORS_KEY%" /v "Arrow"       /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_arrow.cur"     /f >nul
reg add "%CURSORS_KEY%" /v "Crosshair"   /t REG_SZ        /d ""                                          /f >nul
reg add "%CURSORS_KEY%" /v "Hand"        /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_link.cur"      /f >nul
reg add "%CURSORS_KEY%" /v "Help"        /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_helpsel.cur"   /f >nul
reg add "%CURSORS_KEY%" /v "IBeam"       /t REG_SZ        /d ""                                          /f >nul
reg add "%CURSORS_KEY%" /v "No"          /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_unavail.cur"   /f >nul
reg add "%CURSORS_KEY%" /v "NWPen"       /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_pen.cur"       /f >nul
reg add "%CURSORS_KEY%" /v "Person"      /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_person.cur"    /f >nul
reg add "%CURSORS_KEY%" /v "Pin"         /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_pin.cur"       /f >nul
reg add "%CURSORS_KEY%" /v "SizeAll"     /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_move.cur"      /f >nul
reg add "%CURSORS_KEY%" /v "SizeNESW"    /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_nesw.cur"      /f >nul
reg add "%CURSORS_KEY%" /v "SizeNS"      /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_ns.cur"        /f >nul
reg add "%CURSORS_KEY%" /v "SizeNWSE"    /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_nwse.cur"      /f >nul
reg add "%CURSORS_KEY%" /v "SizeWE"      /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_ew.cur"        /f >nul
reg add "%CURSORS_KEY%" /v "UpArrow"     /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_up.cur"        /f >nul
reg add "%CURSORS_KEY%" /v "Wait"        /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_busy.ani"      /f >nul
goto :eof

:get_current_scheme
set "CURRENT_SCHEME="
for /f "tokens=2*" %%a in ('reg query "%CURSORS_KEY%" /v "" 2^>nul') do set "CURRENT_SCHEME=%%b"
goto :eof