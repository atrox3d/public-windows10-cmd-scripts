cls
@echo off
echo ###############################################################################
echo # wsl-start.cmd^| START
echo ###############################################################################

set INFO=[ INFO]
set OK=[   OK]
set ERROR=[ERROR]

echo %INFO% shutdown docker desktop...
wmic process where "name like '%%docker desktop%%'" get processid, name, commandline
taskkill /im  "docker desktop.exe" /f

echo %INFO% shutdown wsl...
wsl --shutdown

set IPADDRESS=192.168.1.10
set UNCPATH=\\%IPADDRESS%\c$\users\***REMOVED***\code
set UNCUSER=***REMOVED***
set UNCPASSWORD=***REMOVED***

echo %INFO% check for host %IPADDRESS%...
ping %IPADDRESS% | find "TTL" >nul
if not errorlevel 1 (

	echo %OK% host %IPADDRESS% is online

	echo %INFO% check for %UNCPATH%...
	if exist %UNCPATH% (
	
		echo %OK% %UNCPATH% exists

		echo %INFO% umount %UNCPATH%...
		net use %UNCPATH% /d /y

		echo %INFO% mount %UNCPATH%...
		net use %UNCPATH% /u:%UNCUSER% %UNCPASSWORD%

		echo %INFO% umount Z:...
		net use Z: /d /y

		echo %INFO% mount z: %UNCPATH%
		net use z: %UNCPATH% /u:%UNCUSER% %UNCPASSWORD%

		echo ###############################################################################
		net use
		echo ###############################################################################

		echo %INFO% mount wsl ubuntu 18 fstab...
		wsl -d ubuntu18 -u root mount -a

		echo %INFO% mount wsl ubuntu 20 fstab...
		wsl -d ubuntu20 -u root mount -a
		
	) else (
		echo %ERROR% %UNCPATH% does NOT exist
		echo %ERROR% cannot mount network shares
	)
) else (
	echo %ERROR% address %IPADDRESS% is not available
)

echo %INFO%  start wsl ubuntu 18 and ssh...
wsl -d ubuntu18 -u root service ssh restart

echo %INFO% start wsl ubuntu 20 and ssh...
wsl -d ubuntu20 -u root service ssh restart

echo %INFO% start docker desktop
REM start /b "C:\Program Files\Docker\Docker\Docker Desktop.exe"
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

echo ###############################################################################
echo # wsl-start.cmd ^| END
echo ###############################################################################

if [%1] neq [-i] pause
