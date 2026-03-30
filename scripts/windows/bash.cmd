@echo off
setlocal

set "GIT_BASH=C:\Program Files\Git\bin\bash.exe"
if exist "%GIT_BASH%" (
  "%GIT_BASH%" %*
  exit /b %ERRORLEVEL%
)

set "GIT_BASH=C:\Program Files\Git\usr\bin\bash.exe"
if exist "%GIT_BASH%" (
  "%GIT_BASH%" %*
  exit /b %ERRORLEVEL%
)

set "GIT_BASH=C:\Users\%USERNAME%\scoop\apps\git\current\bin\bash.exe"
if exist "%GIT_BASH%" (
  "%GIT_BASH%" %*
  exit /b %ERRORLEVEL%
)

echo Git Bash was not found. Install Git for Windows and ensure bash.exe is available. 1>&2
exit /b 1
