@echo off
::
:: Copyright (C) 2023 Robert Di Pardo <dipardo.r@gmail.com>
::
:: Permission to use, copy, modify, and/or distribute this software for any purpose
:: with or without fee is hereby granted.
::
:: THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
:: REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
:: AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
:: INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
:: LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
:: OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
:: PERFORMANCE OF THIS SOFTWARE.
::
SETLOCAL
set "BDS_ENV=%ProgramFiles(x86)%\Embarcadero\Studio\21.0\bin\rsvars.bat"
call "%BDS_ENV%"
set "PLATFORM=Win64"
set "BUILD_TYPE=Debug"
set "PROJECT=%~dp0NppQrCode.dproj"

if "%1" NEQ "" ( set "BUILD_TYPE=%1" )
if "%2" NEQ "" ( set "PLATFORM=Win%2" )
call :%BUILD_TYPE% 2>NUL:
if %errorlevel%==1 ( goto :USAGE ) else ( goto :END )

:Release
"%FrameworkDir%\MSBuild.exe" "%PROJECT%" /t:Clean /p:config=%BUILD_TYPE%;Platform=%PLATFORM%;DCC_Hints=false /nologo /v:m
echo.

:Debug
"%FrameworkDir%\MSBuild.exe" "%PROJECT%" /t:Make /p:config=%BUILD_TYPE%;Platform=%PLATFORM% /nologo /v:m
goto :END

:USAGE
echo Usage: ".\%~n0 [Debug,Release] [32,64]"

:END
exit /B %errorlevel%
ENDLOCAL
