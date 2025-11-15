@echo off
chcp 65001 >nul

:: =========================================================================================
:: PREVENT AUTO-CLOSE (relaunched inside CMD /K)
:: =========================================================================================
if not defined inside_cmd (
    set inside_cmd=1
    start cmd /k "%~f0"
    exit /b
)

title Zalks Optimizer Installer
color 0B
cls

echo =========================================================
echo                ZALKS OPTIMIZER INSTALLER
echo =========================================================
echo.

set scriptDir=%~dp0
set installDir="C:\Program Files\ZalksOptimizer"

:MENU
echo 1) Install
echo 2) Update
echo 3) Remove
echo 4) Exit
echo.
set /p choice=Choose an option (1-4): 

if "%choice%"=="1" goto INSTALL
if "%choice%"=="2" goto UPDATE
if "%choice%"=="3" goto REMOVE
if "%choice%"=="4" exit

echo Invalid choice.
pause
cls
goto MENU


:: =========================================================================================
:: PROGRESS BAR FUNCTION
:: =========================================================================================
:progressbar
setlocal enabledelayedexpansion
set bar=
for /L %%i in (1,1,35) do (
    set bar=!bar!█
    cls
    echo Processing...
    echo.
    echo [!bar!]
    timeout /t 0 >nul
)
endlocal
exit /b


:: =========================================================================================
:: INSTALL
:: =========================================================================================
:INSTALL
cls
echo Starting installation...
timeout /t 1 >nul
call :progressbar

>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo Administrator rights required. Elevating...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

mkdir %installDir% >nul 2>&1

if not exist "%scriptDir%zalksoptimizer.exe" (
    echo ERROR: zalksoptimizer.exe NOT FOUND in %scriptDir%
    pause
    exit /b
)

copy "%scriptDir%zalksoptimizer.exe" %installDir% /Y >nul
goto SHORTCUT


:: =========================================================================================
:: UPDATE
:: =========================================================================================
:UPDATE
cls
echo Updating existing installation...
timeout /t 1 >nul
call :progressbar

copy "%scriptDir%zalksoptimizer.exe" %installDir% /Y >nul
goto SHORTCUT


:: =========================================================================================
:: REMOVE
:: =========================================================================================
:REMOVE
cls
echo Removing...
timeout /t 1 >nul
call :progressbar

del "%installDir%\zalksoptimizer.exe" /f /q >nul 2>&1
rmdir "%installDir%" /s /q >nul 2>&1

echo.
echo Zalks Optimizer removed.
pause
exit


:: =========================================================================================
:: SHORTCUT CREATION
:: =========================================================================================
:SHORTCUT
echo Creating desktop shortcut...
powershell -Command ^
 "$s=(New-Object -COM WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop')+'\ZalksOptimizer.lnk');" ^
 "$s.TargetPath='%installDir%\zalksoptimizer.exe'; $s.Save()"

echo.
echo Operation complete!
pause
exit
