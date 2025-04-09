@echo off
cd /d "%~dp0"

rem This version of the Gameplay Tweaks .bat file enables the end-user to 
rem more easily create their own mod files, modify existing ones with new
rem names, or edit the custom weapon mod files and reload them.

rem Usage:

rem     Manual File Entry:
rem	    FFXIIIwdbLoad

rem	Automatic Single .txt File:
rem	    FFXIIIwdbLoad filename.txt

rem	User Selection from a List of Choices:
rem	    FFXIIIwdbLoad filename.txt
rem		where 'filename.txt' contains the description of the mod.
rem				(Can be one of the final .txt choices)
rem		define variable %select% (doesn't matter to what)
rem		define variable %selecttext% to be the text string that is
rem				displayed during the CHOICE command
rem		define variable %selectchoice% to be the valid character
rem				responses to the CHOICE command
rem		define variables %filename#% where # are values from 1 to
rem				the total number of selections and the
rem				variables contain the .txt filenames for
rem				each of the choices (in order)

if not exist "FFXIIIwdbMod.exe" GOTO NOGAMEPLAY
if exist "FFXIIIwdbSetup.bat" GOTO GAMEPLAYOK

:NOGAMEPLAY
echo The 'Gameplay Tweaks' mod is required for this batch file.  Please download
echo and install in this directory.  If you already have the 'Gameplay' mod,
echo then move this file into that directory.

goto ENDBATCH

:GAMEPLAYOK
if "%~1"=="" (
echo This batch file loads any of the mod .txt files into the Final Fantasy XIII
echo game.  The puropse of this is to enable you to make additional modifications
echo directly to the .txt file or create your own mod files and easily load/
echo test/play them in game.
echo.
)

call FFXIIIwdbSetup

setlocal enabledelayedexpansion

if %ERRORLEVEL% EQU 0 goto CONTINUESETUP

echo.
echo Error extracting game files into local directories.  Exiting.
goto ENDBATCH

:CONTINUESETUP
echo.

if "%~1"=="" (
	set /p filename=Enter filename [including .txt extension]:  
) else (
	set filename="%~1"
)

for /f "tokens=*" %%a in ('Type %filename%') do (
    set "string=%%a"
    if "!string:~0,2!"==":\" (
        echo.!string:~2!
    )
)

echo.

CHOICE /C CQ /N /M "Press (C)ontinue, or (Q)uit:"

if %ERRORLEVEL% EQU 2 goto ENDBATCH
if not defined select goto CHECKUNINSTALL

CHOICE /C %selectchoice% /N /M %selecttext%

set filename=!filename%ERRORLEVEL%!

:CHECKUNINSTALL
if exist "Uninstall%filename%" (
	CHOICE /C NYC /N /M "An uninstall file was found.  Uninstall mod instead (Y/N) or (C)ancel:"

	if !ERRORLEVEL! EQU 3 goto ENDBATCH

	set uichoice=!ERRORLEVEL!
	FFXIIIwdbMod.exe "Uninstall%filename%"

	if !uichoice! EQU 1 goto INSTALL

	if !ERRORLEVEL! NEQ 0 (
		echo Error Uninstalling
		goto ENDBATCH
)
	del /q "Uninstall%filename%" > nul
	@echo Mod being uninstalled.  Run this mod again if you wish to re-install.
	goto LOADFILES
)

:INSTALL
if exist "Uninstall%filename%" del /q "Uninstall%filename%" > nul
FFXIIIwdbMod.exe "%filename%"

if %ERRORLEVEL% NEQ 0 goto ENDBATCH
:LOADFILES
set /p ff13filepath=<FFXIII_Dir.txt
cd wdb_files\mod

@echo.
if not exist "%ff13filepath%white_data\sys\filelistu.win32.bin" @echo English audio files not found.
if not exist "%ff13filepath%white_data\sys\filelistc.win32.bin" @echo Japanese audio files not found.

for /f "tokens=*" %%a in ('Type ..\..\%filename%') do (
    set "string=%%a"
    if not "!string:.wdb=!"=="!string!" (
	if exist "%ff13filepath%white_data\sys\filelistu.win32.bin" ..\..\ff13tool -i "%ff13filepath%white_data\sys\filelistu.win32.bin" "%ff13filepath%white_data\sys\white_imgu.win32.bin" "%%a"
	if exist "%ff13filepath%white_data\sys\filelistc.win32.bin" ..\..\ff13tool -i "%ff13filepath%white_data\sys\filelistc.win32.bin" "%ff13filepath%white_data\sys\white_imgc.win32.bin" "%%a"
    )
)

cd ..\..

:ENDBATCH
pause
