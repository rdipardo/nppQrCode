@echo off
SETLOCAL
set "FPC_TARGET=NppQrCode"
set "FPC_TARGET_ARCH=x86_64"
set "FPC_TARGET_PLATFORM=win64"
set "FPC_TARGET_EXT=64.dll"
set "FPC_BUILD_TYPE=Debug"

if "%1" NEQ "" ( set "FPC_TARGET_PLATFORM=%1" )
if "%2" NEQ "" ( set "FPC_BUILD_TYPE=%2" )
call :%FPC_TARGET_PLATFORM% 2>NUL:
if %errorlevel% NEQ 0 ( goto :USAGE ) else ( goto :END )

:win32
set "FPC_TARGET_ARCH=i386"
set "FPC_TARGET_EXT=32.dll"

:win64

:rename-dll
set "FPC_TARGET_DIR=%~dp0..\bin\%FPC_TARGET_ARCH%-%FPC_TARGET_PLATFORM%\%FPC_BUILD_TYPE%"
move /y "%FPC_TARGET_DIR%\%FPC_TARGET%.dll" "%FPC_TARGET_DIR%\%FPC_TARGET%%FPC_TARGET_EXT%"
goto :%FPC_TARGET_PLATFORM%-%FPC_BUILD_TYPE%

:win32-Debug
set "FPC_TARGET_EXT=32.dbg"
goto :rename-syms

:win64-Debug
set "FPC_TARGET_EXT=64.dbg"

:rename-syms
IF EXIST "%FPC_TARGET_DIR%\%FPC_TARGET%.dbg" (
  move /y "%FPC_TARGET_DIR%\%FPC_TARGET%.dbg" "%FPC_TARGET_DIR%\%FPC_TARGET%%FPC_TARGET_EXT%"
)

:win32-Release
:win64-Release
goto :END

:USAGE
echo Usage: ".\%~n0 [win32,win64] [Debug,Release]"

:END
exit /B %errorlevel%
ENDLOCAL
