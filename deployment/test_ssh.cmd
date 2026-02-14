@echo off
echo Testing SSH connection to laguna.ku.lt...
echo.
echo Using: C:\Windows\System32\OpenSSH\ssh.exe
echo.
echo Running: ssh -v -o ConnectTimeout=10 razinka@laguna.ku.lt "echo SUCCESS"
echo.
"C:\Windows\System32\OpenSSH\ssh.exe" -v -o ConnectTimeout=10 razinka@laguna.ku.lt "echo SUCCESS"
echo.
echo Exit code: %ERRORLEVEL%
echo.
pause
