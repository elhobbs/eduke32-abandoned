@echo off
setlocal ENABLEEXTENSIONS DISABLEDELAYEDEXPANSION

set targets=eduke32
set PATH=C:\devkitPro\devkitARM\bin;C:\MinGW\bin;C:\MinGW\msys\1.0\bin;C:\devkitPro\msys\bin;%PATH%
set DEVKITPPC=C:/devkitPro/devkitARM
set DEVKITPRO=C:/devkitPro

pushd "%~dp0.."
set 3dsdir=platform\3DS

:: Detect versioning systems and pull the revision number:
if "%rev%"=="" set vc=none
if "%rev%"=="" set rev=XXXX
if "%rev%"=="" set VC_REV=XXXX

:: Get the current date:
for /f "delims=" %%G in ('"C:\MinGW\msys\1.0\bin\date.exe" +%%Y%%m%%d') do @set currentdate=%%G

:: Build:
set commandline=make PLATFORM=3DS %* STRIP=""
echo %commandline%
%commandline%

for %%G in (%targets%) do if not exist "%%~G.elf" goto end

for %%G in (%targets%) do @echo "%%~G.elf" "%%G"

for %%G in (%targets%) do @3dsxtool.exe "%%~G.elf" "%%~G.3dsx"

goto end

:: Package data:
if not exist apps mkdir apps
for %%G in (%targets%) do xcopy /e /q /y %wiidir%\apps\%%~G apps\%%~G\
for %%G in (%targets%) do for %%H in (.dol) do if exist "%%~G%%~H" move /y "%%~G%%~H" "apps\%%~G\boot%%~H"
for %%G in (%targets%) do for %%H in (.elf.map) do if exist "%%~G%%~H" del /f /q "%%~G%%~H"
for %%G in (%targets%) do "echo.exe" -e "    <version>r%rev%</version>\n    <release_date>%currentdate%</release_date>" | "cat.exe" "%wiidir%\%%~G_meta_1.xml" - "%wiidir%\%%~G_meta_2.xml" >"apps\%%~G\meta.xml"

xcopy /e /q /y /EXCLUDE:%wiidir%\xcopy_exclude.txt package\common apps\eduke32\

xcopy /e /q /y /EXCLUDE:%wiidir%\xcopy_exclude.txt package\common apps\mapster32\
xcopy /e /q /y /EXCLUDE:%wiidir%\xcopy_exclude.txt package\sdk apps\mapster32\

"ls.exe" -l -R apps
7z.exe a -mx9 -t7z eduke32-wii-r%rev%-debug-elf.7z *.elf -xr!*.svn*
7z.exe a -mx9 -t7z eduke32-wii-r%rev%.7z apps -xr!*.svn*

:end

endlocal
goto :eof
