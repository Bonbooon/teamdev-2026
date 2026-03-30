@echo off
setlocal

set "GIT_BASH=C:\Program Files\Git\bin\bash.exe"
if exist "%GIT_BASH%" (
  goto :run
)

set "GIT_BASH=C:\Program Files\Git\usr\bin\bash.exe"
if exist "%GIT_BASH%" (
  goto :run
)

set "GIT_BASH=C:\Users\%USERNAME%\scoop\apps\git\current\bin\bash.exe"
if exist "%GIT_BASH%" (
  goto :run
)

echo Git Bash was not found. Install Git for Windows and ensure bash.exe is available. 1>&2
exit /b 1

:run
if /I "%~1"=="-lc" (
  shift
  set "BASH_CMD=%*"
  "%GIT_BASH%" -lc "%BASH_CMD%"
  exit /b %ERRORLEVEL%
)

"%GIT_BASH%" %*
exit /b %ERRORLEVEL%
