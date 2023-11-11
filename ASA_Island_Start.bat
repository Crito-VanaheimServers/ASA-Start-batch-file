@echo off
COLOR 0a
SETLOCAL EnableExtensions enabledelayedexpansion

::Change the title for you monitor window with quotes
TITLE "VGS ASA Island Server Monitor"

::Change this to the hour you want server to restart. military (12=12pm 00=12am) https://www.ontheclock.com/convert-military-24-hour-time.aspx
Set restartHour = 00

::Change to name of your servers exe file.
::If you are using a name other than the default name this will not work I would suggest going and putting _ for spaces in your exe name
set ServerEXE=ArkAscendedServer.exe

::Set file path to the folder your server files are located or will be located.
::If your folder names have spaces this will not work I would suggest going and putting _ for spaces in folder names.
set GameserverPath=C:\VGS_Server_Files\ARK_Survival_Ascended\The_Island

::Set file path to the folder your steam cmd files are located
::If your folder names have spaces this will not work I would suggest going and putting _ for spaces in folder names.
set STEAMPATH=C:\VGS_Server_Files\Steam_CMD_Files

::Set the start up command line for your ark server. If you use quotes in your command line this may not work.
set CommandLine=TheIsland_WP?RCONEnabled=True?RCONPort=27020?listen?QueryPort=27015?SessionName="VGS Island PVE Boosted"?MaxPlayers=70?ServerAdminPassword=yourpasswordhere -automanagedmods -Mods=930404,928677,928621,929420,930128 -nosteamclient -game -server -log 

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Caution Do Not put spaces after the = on any of the set variables!!!	::
::Example of what not to do >>>>>>>>> CommandLine = TheIsland_WP		::
::Example of correct way to do it >>> CommandLine=TheIsland_WP			::
::Doing this wrong will cause error when starting server				::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::DONT TOUCH ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING OR YOU WILL BREAK THINGS!!
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set /A restartCounter=0

goto ServerUpdate

:ServerUpdate
set STEAMLOGIN=anonymous
set GameServerBRANCH=2430930

echo.
echo     You are about to update your server
echo        Dir: %GameserverPath%
echo        Branch: %GameServerBRANCH%
echo.
timeout 5 > NUL
%STEAMPATH%\steamcmd.exe +force_install_dir %GameserverPath%  +login %STEAMLOGIN% +"app_update %GameServerBRANCH%" validate +quit
timeout 5 > NUL
echo.
echo     Your server is now up to date
timeout 5 > NUL

goto StartServer

:StartServer
start /min %GameserverPath%\ShooterGame\Binaries\Win64\%ServerEXE% %CommandLine%

echo.
echo Server was started at %time% 
echo Server will auto restart at %restartHour%:00:00
echo Total Restarts %restartCounter%
timeout 5 >nul
powershell -window minimized -command ""
goto CheckServerRunning

:CheckServerRunning
FOR /F %%x IN ('tasklist /NH /FI "IMAGENAME eq %ServerEXE%"') DO IF %%x == %ServerEXE% goto ServerFound
goto ServerNotFound

:ServerFound
timeout 5 >nul
goto TimeCheck

:TimeCheck
for /F "tokens=1-3 delims=:." %%a in ("%time%") do (
   set timeHour=%%a
   set timeMinute=%%b
   set timeSeconds=%%c
)
set /A newTime=timeHour*60 + timeMinute
set /A timeHour=newTime/60, timeMinute=newTime%%60
if %timeHour% gtr 23 set timeHour=0
if %timeHour% lss 10 set timeHour=0%timeHour%
if %timeMinute% lss 10 set timeMinute=0%timeMinute%
::if statement 10 minutes before to trigger rcon restart warning
if %timeHour% EQU %restartHour% if %timeMinute% lss 01 if %timeSeconds% lss 20 goto ExecuteRestart
goto CheckServerRunning

:ExecuteRestart
::rcon trigger here
::timout 20sec
goto CheckServerRunning

:ServerNotFound
echo server not found
set /A restartCounter+=1
echo Please wait while the %GameName% server is restarted.
timeout 5 >nul
goto ServerUpdate
