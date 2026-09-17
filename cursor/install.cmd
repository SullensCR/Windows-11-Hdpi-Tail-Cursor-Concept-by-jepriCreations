@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem =====================================================
rem  Cursor Pack Installer (Non-Admin, Per-User)
rem  Author: Jepri Creations
rem =====================================================

set "_SCHEME=Cursor Concept W11 Tail HDPi"
set "_AUTHOR=JepriCreations"

set "THEME=%~1"
set "VARIANT=%~2"
set "SCHEME=%~3"
set "AUTHOR=%~4"
if "%SCHEME%"=="" set "SCHEME=%_SCHEME%"
if "%AUTHOR%"=="" set "AUTHOR=%_AUTHOR%"

set "SCRIPT_DIR=%~dp0"
set "ASSETS_BASE=%SCRIPT_DIR%assets\"
if not exist "%ASSETS_BASE%" (
  echo [error] Assets folder not found: %ASSETS_BASE%
  exit /b 1
)

if "%THEME%"=="" call :select_theme
rem Variants optional: only prompt if variants folder exists and has subfolders
set "VAR_DIR=%ASSETS_BASE%%THEME%\variants\"
if "%VARIANT%"=="" (
  if exist "!VAR_DIR!" (
    set "HAS_VARIANTS="
    for /d %%V in (!VAR_DIR!*) do set "HAS_VARIANTS=1"
    if defined HAS_VARIANTS (
      call :select_variant
    ) else (
      set "VARIANT="
    )
  ) else (
    set "VARIANT="
  )
)

set "ASSETS_THEME_DIR=%ASSETS_BASE%%THEME%\"
set "ASSETS_VARIANT_DIR=%ASSETS_THEME_DIR%variants\%VARIANT%\"

rem Normalize theme/variant to Title Case for display/registry consistency
for /f %%I in ('powershell -NoProfile -Command "$t=\"%THEME%\".Replace('-', ' ').Replace('_',' ');(Get-Culture).TextInfo.ToTitleCase($t)"') do set "THEME_TC=%%I"
for /f %%I in ('powershell -NoProfile -Command "$v=\"%VARIANT%\".Replace('-', ' ').Replace('_',' ');(Get-Culture).TextInfo.ToTitleCase($v)"') do set "VARIANT_TC=%%I"
set "FULL_SCHEME=%SCHEME% %THEME_TC%"
if not "%VARIANT_TC%"=="" set "FULL_SCHEME=%FULL_SCHEME% %VARIANT_TC%"
set "DEST_DIR_REAL=%LOCALAPPDATA%\Cursors"
if not "%AUTHOR%"=="" set "DEST_DIR_REAL=%DEST_DIR_REAL%\%AUTHOR%"
set "DEST_DIR_REAL=%DEST_DIR_REAL%\%FULL_SCHEME%"

echo [info] Installing scheme: %FULL_SCHEME%
echo [info] Destination: %DEST_DIR_REAL%

if not exist "%DEST_DIR_REAL%" mkdir "%DEST_DIR_REAL%" >nul 2>&1

for %%F in (
  arrow.cur help.cur crosshair.cur ibeam.cur nwpen.cur no.cur
  sizens.cur sizewe.cur sizenwse.cur sizenesw.cur sizeall.cur
  uparrow.cur hand.cur person.cur pin.cur
) do if exist "%ASSETS_THEME_DIR%%%F" copy /Y "%ASSETS_THEME_DIR%%%F" "%DEST_DIR_REAL%" >nul

rem Copy .ani from variant if present; else from theme
if not "%VARIANT%"=="" (
  for %%F in (appstarting.ani wait.ani) do if exist "%ASSETS_VARIANT_DIR%%%F" copy /Y "%ASSETS_VARIANT_DIR%%%F" "%DEST_DIR_REAL%" >nul
) else (
  for %%F in (appstarting.ani wait.ani) do if exist "%ASSETS_THEME_DIR%%%F" copy /Y "%ASSETS_THEME_DIR%%%F" "%DEST_DIR_REAL%" >nul
)

set "CURSORS_KEY=HKCU\Control Panel\Cursors"
set "SCHEMES_KEY=HKCU\Control Panel\Cursors\Schemes"

set "SCHEME_VALUE=%DEST_DIR_REAL%\arrow.cur,%DEST_DIR_REAL%\help.cur,%DEST_DIR_REAL%\appstarting.ani,%DEST_DIR_REAL%\wait.ani,%DEST_DIR_REAL%\crosshair.cur,%DEST_DIR_REAL%\ibeam.cur,%DEST_DIR_REAL%\nwpen.cur,%DEST_DIR_REAL%\no.cur,%DEST_DIR_REAL%\sizens.cur,%DEST_DIR_REAL%\sizewe.cur,%DEST_DIR_REAL%\sizenwse.cur,%DEST_DIR_REAL%\sizenesw.cur,%DEST_DIR_REAL%\sizeall.cur,%DEST_DIR_REAL%\uparrow.cur,%DEST_DIR_REAL%\hand.cur,%DEST_DIR_REAL%\person.cur,%DEST_DIR_REAL%\pin.cur"

reg add "%SCHEMES_KEY%" /v "%FULL_SCHEME%" /t REG_EXPAND_SZ /d "%SCHEME_VALUE%" /f >nul 2>&1
echo [ok] Registered scheme under Schemes: %FULL_SCHEME%

echo [info] Setting scheme as current selection...

rem -------------------------------------------
rem Parser for "Name=File" pairs
rem -------------------------------------------
for %%P in (
  "Arrow=arrow.cur"
  "Help=help.cur"
  "AppStarting=appstarting.ani"
  "Wait=wait.ani"
  "Crosshair=crosshair.cur"
  "IBeam=ibeam.cur"
  "NWPen=nwpen.cur"
  "No=no.cur"
  "SizeNS=sizens.cur"
  "SizeWE=sizewe.cur"
  "SizeNWSE=sizenwse.cur"
  "SizeNESW=sizenesw.cur"
  "SizeAll=sizeall.cur"
  "UpArrow=uparrow.cur"
  "Hand=hand.cur"
  "Person=person.cur"
  "Pin=pin.cur"
) do (
  call :_regpair "%%~P" "%DEST_DIR_REAL%"
)

reg add "%CURSORS_KEY%" /ve /t REG_SZ /d "%FULL_SCHEME%" /f >nul
reg add "%CURSORS_KEY%" /v "Scheme Source" /t REG_DWORD /d 1 /f >nul

rem -----------------------------------------------------
rem Launch Mouse Properties with scheme already selected
rem -----------------------------------------------------
echo [ok] Cursor scheme "%FULL_SCHEME%" installed.
echo.
echo [info] Mouse Properties will open with "%FULL_SCHEME%" preselected. Press the "OK" button to set the new cursor. 
echo [tip] If you want to activate the cursor shadow, check the "Enable pointer shadow" checkbox.
echo.
set /p "DUMMY=Press Enter to open Mouse Properties (Pointers tab)"

rundll32.exe shell32.dll,Control_RunDLL main.cpl,,1

echo.
echo [info] Installation finished.
set /p "DUMMY=Press Enter to exit, or close this window."
exit /b 0

rem ================== SUPPORT SUBROUTINES ==================

:_regpair
rem %~1 = "Name=File", %~2 = BaseDir
set "pair=%~1"
for /f "tokens=1,2 delims==" %%a in ("!pair!") do (
  reg add "HKCU\Control Panel\Cursors" /v "%%a" /t REG_EXPAND_SZ /d "%~2\%%b" /f >nul
)
goto :eof


:select_theme
set /a TCOUNT=0
echo You are about to install the cursor scheme: %SCHEME% by %AUTHOR%
pushd "%ASSETS_BASE%" >nul
for /d %%D in (*) do (
  set /a TCOUNT+=1
  set "THEME_!TCOUNT!=%%~nxD"
)
popd >nul
if %TCOUNT%==0 (
  echo [error] No themes found under %ASSETS_BASE%
  exit /b 3
)
echo.
echo Select Theme:
for /l %%i in (1,1,%TCOUNT%) do echo   %%i. !THEME_%%i!
:askTheme
set /p TCHOICE=Enter the number for theme: 
if "%TCHOICE%"=="" goto askTheme
if not defined THEME_%TCHOICE% goto askTheme
set "THEME=!THEME_%TCHOICE%!"
goto :eof


:select_variant
set "VAR_DIR=%ASSETS_BASE%%THEME%\variants\"
if not exist "!VAR_DIR!" (
  echo [error] No variants folder found for theme: !THEME!
  call :select_theme
  goto select_variant
)
set /a VCOUNT=0
pushd "%VAR_DIR%" >nul
for /d %%V in (*) do (
  set /a VCOUNT+=1
  set "VARIANT_!VCOUNT!=%%~nxV"
)
popd >nul
if %VCOUNT%==0 (
  echo [error] No variants found under !VAR_DIR!
  call :select_theme
  goto select_variant
)
echo.
echo Select Variant:
for /l %%i in (1,1,%VCOUNT%) do echo   %%i. !VARIANT_%%i!
:askVariant
set /p VCHOICE=Enter the number for variant: 
if "%VCHOICE%"=="" goto askVariant
if not defined VARIANT_%VCHOICE% goto askVariant
set "VARIANT=!VARIANT_%VCHOICE%!"
goto :eof