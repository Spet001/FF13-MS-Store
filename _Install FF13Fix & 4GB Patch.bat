@echo off
setlocal enabledelayedexpansion

@echo This mod assists in the installation of the FF13Fix mod
@echo for MS STORE version of Final Fantasy XIII.  If you own a steam
@echo version, this installer wont work, use
@echo the original installer.
@echo.
@echo Do not use this mod if you have an AMD graphics card and are using the DXVK "fix" as
@echo the installation of the FF13Fix will overwrite one of the DXVK files.  You will need to
@echo read the FF13Fix instructions and install it manually.  If you do not know what DXVK is,
@echo then you are probably not using it.
@echo.
@echo This install process was initially developed for FF13Fix version 1.6.4 and may not work
@echo for newer versions if significant changes were made to the file structure/naming.
@echo.
CHOICE /C YN /N /M "Do you wish to continue? (Y/N) "

if %ERRORLEVEL% EQU 2 goto ENDBATCH

set currentdir="%~dp0"
set patch4gb=N
set localff13ver=0

@echo.

:NOTFF13
if not exist FFXIII_Dir.txt goto BEGINSEARCH

set /p ff13filepath=<FFXIII_Dir.txt

if exist "%ff13filepath%FFXiiiLauncher.exe" goto CHECKFIXVER

:BEGINSEARCH
if exist selectedPath.txt del selectedPath.txt > nul

@echo The Final Fantasy XIII game directory needs to be located.  This can either
@echo be done automatically by the mod, or you can manually select the path to the
@echo game.  Having the mod do this automatically can take some time if you have
@echo large or multiple hard drives.
@echo.
@echo Do you wish the mod to (A)utomatically find the directory, or do you wish to
CHOICE /C AM /N /M "(M)anually select the path? "

if %ERRORLEVEL% EQU 1 goto :AUTOFIND

@echo.
rem @echo Select the 'FFXIII_Launcher.exe' file in the FINAL FANTASY XIII game directory.
rem pause
SupportFiles\FFXIIIGetPath.exe FFXIIILauncher.exe Select the FFXIIILauncher.exe file in your Final Fantasy XIII game directory.
rem @echo.

if not exist selectedPath.txt goto NOTFF13
if exist FFXIII_Dir.txt del FFXIII_Dir.txt > nul

rename selectedPath.txt FFXIII_Dir.txt > nul
goto NOTFF13

:AUTOFIND
@echo Searching for the Steam Final Fantasy XIII Directory.  Please Wait...

set ff13filepath=

if not exist "C:\XboxGames\FINAL FANTASY XIII\Content" goto CHECKDIRS

set ff13filepath=C:\XboxGames\FINAL FANTASY XIII\Content
goto continue

:CHECKDIRS

for %%i in (C D E F A B G H I J K L M N O P Q R S T U V W X Y Z) DO @if exist %%i: (
	cd /d %%i:\
	for /R /d %%a in (*) do (
	if exist "%%a\FINAL FANTASY XIII" set directff13=%%a\FINAL FANTASY XIII\
	if exist "%%a\steamapps\common\FINAL FANTASY XIII" (
		set ff13filepath=%%a\steamapps\common\FINAL FANTASY XIII\
		goto continue )))

@echo Steam Final Fantasy XIII directory not found.

if not defined directff13 goto MANUALINPUT
@echo However a possible path was located at "%directff13%".
@echo.
CHOICE /C YN /N /M "Use this one? (Y/N) "

if %ERRORLEVEL% EQU 1 goto USEDIRECT

:MANUALINPUT
CHOICE /C YN /N /M "Do you wish to manaually enter the path? (Y/N) "

if %ERRORLEVEL% EQU 2 goto FF13NOTFOUND

@echo Enter the full path including the drive, path including a trailing \
@echo This path should be to the FF XIII launcher and should look similar to
@echo.
@echo C:\SomePath\FINAL FANTASY XIII\
@echo.

set /P "directff13=Enter Path: "

:USEDIRECT

set ff13filepath=%directff13%

if exist "%directff13%FFXiiiLauncher.exe" goto :continue

@echo FF XIII Launcher was not found in specified directory.
goto FF13NOTFOUND

:continue
cd /d !currentdir!

if not defined ff13filePath goto FF13NOTFOUND

@echo %ff13filePath%> FFXIII_Dir.txt
@echo Final Fantasy XXIII Directory found at %ff13filepath%
@echo.

:CHECKFIXVER
if not exist FF13Fix\ff13fix.ini goto FF13FIXNOTFOUND
if not exist FF13Fix\d3d9.dll goto FF13FIXNOTFOUND

for /f "tokens=1-3" %%a in (FF13Fix\ff13fix.ini) do (
  if [%%a] EQU [Config] set localff13ver=%%c
)

set gameff13ver=0

if not exist "%ff13filepath%prog\bin\ff13fix.ini" goto NOGAMEFIX

for /f "tokens=1-3" %%a in ("%ff13filepath%white_data\prog\bin\ff13fix.ini") do (
  if [%%a] EQU [Config] set gameff13ver=%%c
)

:NOGAMEFIX

if %localff13ver% LSS 6 goto NOTSUPPORTED

if %localff13ver% LSS %gameff13ver% (
@echo Local mod version of the FF13Fix appears to be older than the one located in
@echo your game directory.

CHOICE /C YN /N /M "Do you wish to use the older mod version? (Y/N) "

if %ERRORLEVEL% EQU 2 goto DO4GB
)

@echo The FF13Fix ini file contains a number of editable settings you can
@echo configure specifically for your game such as triple buffering, or
@echo controller vibration.  However for most installations, the defult
@echo installation will work fine.
@echo.

CHOICE /C YN /N /M "Do you wish to make any edits to the default .ini file? (Y/N) "

if %ERRORLEVEL% EQU 2 goto COPYFF13FIXFILES

@echo.
@echo Make your changes in notepad, then save.
@echo.
@echo Waiting for Notepad to exit...

NOTEPAD FF13Fix\ff13Fix.ini

:COPYFF13FIXFILES

copy /y FF13Fix\ff13fix.* "%ff13filepath%white_data\prog\win\bin\*.*" > nul
copy /y FF13Fix\d3d9.dll "%ff13filepath%white_data\prog\win\bin\*.*" > nul
set gameff13ver=%localff13ver%

@echo.
@echo FF13Fix files copied.
@echo.

:DO4GB

if not exist "%ff13filepath%white_data\prog\win\bin\untouched.exe" copy "%ff13filepath%white_data\prog\win\bin\ffxiiiimg.exe" "%ff13filepath%white_data\prog\win\bin\untouched.exe" > nul

"SupportFiles\ffxiii-4gb.exe" "%ff13filepath%white_data\prog\win\bin\untouched.exe" 0
set untouched=!ERRORLEVEL!
"SupportFiles\ffxiii-4gb.exe" "%ff13filepath%white_data\prog\win\bin\ffxiiiimg.exe" 0
set ffxiiiimg=!ERRORLEVEL!

if %ffxiiiimg% EQU 0 goto UNKNOWNSTATE

if %untouched% EQU 0 (
copy "%ff13filepath%white_data\prog\win\bin\ffxiiiimg.exe" "%ff13filepath%white_data\prog\win\bin\untouched.exe" > nul
set untouched=%ffxiiiimg%
)

if %untouched% NEQ 2 (
@echo 'Untouched.exe' version not in original state.  Attempting to correct.
copy /y "%ff13filepath%white_data\prog\win\bin\untouched.exe" "%ff13filepath%white_data\prog\win\bin\untouched_backup.exe" > nul
"SupportFiles\ffxiii-4gb.exe" "%ff13filepath%white_data\prog\win\bin\untouched.exe" 2

if !ERRORLEVEL! NEQ 2 (

copy /y "%ff13filepath%white_data\prog\win\bin\untouched_backup.exe" "%ff13filepath%white_data\prog\win\bin\untouched.exe" > nul

@echo Unable to correct issue.  This may be a non-steam version.  If you still wish to install
@echo the 4GB patch, you will need to download it directly from NTCore and manually install it.
@echo However the other functionality of the FF13Fix will still work properly.

goto ENDBATCH
)
)

:CONTINUE4GB

if %ffxiiiimg% EQU 1 goto IMPLEMENTED

@echo Implementing 4GB Patch
"SupportFiles\ffxiii-4gb.exe" "%ff13filepath%white_data\prog\win\bin\ffxiiiimg.exe" 1

if !ERRORLEVEL! EQU 1 goto IMPLEMENTED
@echo Error: Unable to implement 4GB patch
goto ENDBATCH

:UNKNOWNSTATE
@echo Unable to determine state of game files for 4GB Patch.  This may be a non-steam version.
@echo If you still wish to install the 4GB patch, you will need to download it directly from
@echo NTCore and manually install it.  However the other functionality of the FF13Fix will
@echo still work properly.
goto ENDBATCH

:NOTSUPPORTED
@echo FF13Fix version does not support the 4GB Patch
goto ENDBATCH

:IMPLEMENTED
@echo 4GB Patch Implemented
@echo.

set patch4gb=Y
goto ENDBATCH

:FF13NOTFOUND
@echo Steam Final Fantasy XIII Directory Not Found!
exit /B 1

:FF13FIXNOTFOUND
@echo Critical FF13Fix files not found in the mod's FF13Fix subdirectory (folder).
@echo.
@echo In order to use this installation mod, you must download the FF13Fix from Github
@echo and unzip it into the mod's FF13Fix\ subdirectory (folder).  At the time of this
@echo mod's creation, the FF13Fix could be found at
@echo.
@echo   https://github.com/rebtd7/FF13Fix/releases
@echo.

goto ENDBATCH

:ENDBATCH
if exist "%ff13filepath%white_data\prog\win\bin\untouched_backup.exe" del /q "%ff13filepath%white_data\prog\win\bin\untouched_backup.exe" > nul
pause


