@echo off
setlocal disabledelayedexpansion

set currentDir="%~dp0"

if not exist "..\..\..\FINAL FANTASY XIII\white_data\sys\%~nx0" goto NOTFF13

@echo Error: Can not run this batch file from the Final Fantasy directory.
exit /B 1

:NOTFF13

if not exist FFXIII_Dir.txt goto BEGINSEARCH

set /p ff13filepath=<FFXIII_Dir.txt

if exist "%ff13filepath%FFXiiiLauncher.exe" goto CHECKWDBDIR

:BEGINSEARCH
if exist selectedPath.txt del selectedPath.txt > nul

@echo The Final Fantasy XIII game directory needs to be located.  This can either
@echo be done automatically by the mod, or you can manually select the path to the
@echo game.  Having the mod do this automatically can take a while if you have
@echo large or multiple hard drives.
@echo.
@echo Do you wish the mod to (A)utomatically find the directory, or do you wish to
CHOICE /C AM /N /M "(M)anually select the path? "

if %ERRORLEVEL% EQU 1 goto :AUTOFIND

FFXIIIGetPath.exe FFXIIILauncher.exe Select the 'FFXiiiLauncher.exe' file in the FINAL FANTASY XIII game directory.
@echo.

if not exist selectedPath.txt goto NOTFF13
if exist FFXIII_Dir.txt del FFXIII_Dir.txt > nul

rename selectedPath.txt FFXIII_Dir.txt > nul
goto NOTFF13

:AUTOFIND
@echo Searching for the XboxMS Final Fantasy XIII Directory.  Please Wait...

set ff13filepath=

if not exist "C:\XboxGames\FINAL FANTASY XIII\Content" goto CHECKDIRS

set ff13filepath=C:\XboxGames\FINAL FANTASY XIII\Content\
goto continue

:CHECKDIRS
for %%i in (C D E F A B G H I J K L M N O P Q R S T U V W X Y Z) DO @if exist %%i: (
	cd /d %%i:\
	for /R /d %%a in (*) do (
	if exist "%%a\FINAL FANTASY XIII" set directff13=%%a\FINAL FANTASY XIII\
	if exist "%%a\XboxGames\FINAL FANTASY XIII\Content" (
		set ff13filepath=%%a\XboxGames\FINAL FANTASY XIII\Content\
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
cd /d %currentDir%

if not defined ff13filePath goto FF13NOTFOUND

@echo %ff13filePath%> FFXIII_Dir.txt
@echo Final Fantasy XXIII Directory found at %ff13filepath%

:CHECKWDBDIR
if not exist wdb_files\Orig goto CHECKTOOL
if exist wdb_files\Mod goto TMPFILE

:CHECKTOOL
set /p ff13filepath=<FFXIII_Dir.txt

if exist ff13tool.exe goto EXTRACTFILES
if not exist ff13tool.zip goto NOTOOL

set vbs="_.vbs"

>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace("%CD%\ff13tool.zip").items.item(2)
>>%vbs% echo objShell.NameSpace("%CD%\").CopyHere(FilesInZip)
>>%vbs% echo Set objShell = Nothing

cscript //nologo %vbs%

if exist %vbs% del /f /q %vbs%
if not exist ff13tool.exe goto NOTOOL

:EXTRACTFILES
@echo Making local copy of Final Fantasy XIII files...

if not exist "%ff13filepath%white_data\sys\filelistu.win32.bin" goto EXTRACTJAPANESE

copy "%ff13filepath%white_data\sys\filelistu.win32.bin" *.* > ff13log.txt
copy "%ff13filepath%white_data\sys\white_imgu.win32.bin" *.* >> ff13log.txt
@echo Unpacking Files...
ff13tool -x -ff13 filelistu.win32.bin white_imgu.win32.bin >> ff13log.txt

@echo Copying .wdb Files...
robocopy white_imgu wdb_files\orig *.wdb /S /XN >> ff13log.txt

if not exist wdb_files\mod robocopy wdb_files\orig wdb_files\mod /e /xf * >> ff13log.txt
rem if not exist wdb_files\mod\ff13tool.exe copy ff13tool.exe wdb_files\mod\*.* >> ff13log.txt

@echo Deleting Temporary Files...
del filelistu.win32.bin >> ff13log.txt
del white_imgu.win32.bin >> ff13log.txt
goto TMPFILE

:EXTRACTJAPANESE

if not exist "%ff13filepath%white_data\sys\filelistc.win32.bin" goto NOGAMEFILE

copy "%ff13filepath%white_data\sys\filelistc.win32.bin" *.* > ff13log.txt
copy "%ff13filepath%white_data\sys\white_imgc.win32.bin" *.* >> ff13log.txt
@echo Unpacking Files...
ff13tool -x -ff13 filelistc.win32.bin white_imgc.win32.bin >> ff13log.txt

@echo Copying .wdb Files...
robocopy white_imgc wdb_files\orig *.wdb /S /XN >> ff13log.txt

if not exist wdb_files\mod robocopy wdb_files\orig wdb_files\mod /e /xf * >> ff13log.txt
rem if not exist wdb_files\mod\ff13tool.exe copy ff13tool.exe wdb_files\mod\*.* >> ff13log.txt

@echo Deleting Temporary Files...
del filelistc.win32.bin >> ff13log.txt
del white_imgc.win32.bin >> ff13log.txt

:TMPFILE
if exist white_imgu (rd /s /q white_imgu >> ff13log.txt)
if exist white_imgc (rd /s /q white_imgc >> ff13log.txt)

exit /B 0

:NOGAMEFILE
@echo Unable to locate either English or Japanese game files.  Exiting.
exit /B 1

:FF13NOTFOUND
@echo Steam Final Fantasy XIII Directory Not Found!
exit /B 1

:NOTOOL
@echo FF13Tool.exe not found to extract WDB files
exit /B 1

