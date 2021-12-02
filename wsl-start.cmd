cls
@echo off
echo ###############################################################################
echo # wsl-start.cmd^| START

set INFO=echo [ INFO]
set OK=echo [   OK]
set ERROR=echo [ERROR]
set DEBUG=REM echo [DEBUG]

REM echo ###############################################################################
REM %INFO% shutdown docker desktop...
REM wmic process where "name like '%%docker desktop%%'" get processid, name, commandline
REM taskkill /im  "docker desktop.exe" /f

echo ###############################################################################
%INFO% shutdown wsl...
%DEBUG% wsl --shutdown
wsl --shutdown

echo ###############################################################################
set IPADDRESS=192.168.1.10
set UNCPATH=\\%IPADDRESS%\c$\users\***REMOVED***\code
set UNCUSER=***REMOVED***
set UNCPASSWORD=***REMOVED***

%INFO% check for host %IPADDRESS%...
ping %IPADDRESS% | find "TTL" >nul
if not errorlevel 1 (

	%OK% host %IPADDRESS% is online

	%INFO% check for %UNCPATH%...
	if exist %UNCPATH% (
	
		%OK% %UNCPATH% exists

		%INFO% net delete %UNCPATH%...
		net use %UNCPATH% /d /y

		%INFO% net use %UNCPATH%...
		net use %UNCPATH% /u:%UNCUSER% %UNCPASSWORD%

		%INFO% net delete Z:...
		net use Z: /d /y

		%INFO% net use z: %UNCPATH%
		net use z: %UNCPATH% /u:%UNCUSER% %UNCPASSWORD%

		echo ###############################################################################
		net use
		echo ###############################################################################

		%INFO% mount wsl ubuntu 18 fstab...
		wsl -d ubuntu18 -u root mount -a

		%INFO% mount wsl ubuntu 20 fstab...
		wsl -d ubuntu20 -u root mount -a
		
	) else (
		%ERROR% %UNCPATH% does NOT exist
		%ERROR% cannot mount network shares
	)
) else (
	%ERROR% address %IPADDRESS% is not available
)

echo ###############################################################################
%INFO%  start wsl ubuntu 18 and ssh...
wsl -d ubuntu18 -u root service ssh restart

echo ###############################################################################
%INFO% start wsl ubuntu 20 and ssh...
wsl -d ubuntu20 -u root service ssh restart

REM %INFO% start docker desktop
REM REM start /b "C:\Program Files\Docker\Docker\Docker Desktop.exe"
REM start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

echo ###############################################################################
echo # wsl-start.cmd ^| END
echo ###############################################################################

if [%1] neq [-i] pause
