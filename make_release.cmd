@echo off
::
:: Copyright (C) 2023-2025 Robert Di Pardo <dipardo.r@gmail.com>
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
set "VERSION=0.0.0.3"
set "PLUGIN=NppQrCode"
set "PLUGIN_DLL=.\bin\Win32\Release\%PLUGIN%.32.dll"
set "PLUGINX64_DLL=.\bin\Win64\Release\%PLUGIN%.64.dll"
set "SLUG_NAME=bin\%PLUGIN%-%VERSION%-win32"
set "SLUGX64_NAME=bin\%PLUGIN%-%VERSION%-x64"
set "SLUG=%SLUG_NAME%.zip"
set "SLUGX64=%SLUGX64_NAME%.zip"
set "DOCS=CHANGELOG.md README.md .\bin\Copyright"

del /S /Q /F out\*.zip 2>NUL:
call %~dp0build.cmd Release
call %~dp0build.cmd Release 32

echo D | xcopy /DIY *.txt ".\bin\Copyright"
echo D | xcopy /DIY "Interface\Source\Include\LICENSE.*" ".\bin\Copyright"
echo F | xcopy /DVY "%PLUGIN_DLL%" %PLUGIN_DLL:~0,-7%32.dll
echo F | xcopy /DVY "%PLUGINX64_DLL%" %PLUGINX64_DLL:~0,-7%64.dll
7z a -tzip "%SLUG%" ".\bin\Win32\Release\%PLUGIN%32.dll" %DOCS% -y
7z a -tzip "%SLUGX64%" ".\bin\Win64\Release\%PLUGIN%64.dll" %DOCS% -y
ENDLOCAL
