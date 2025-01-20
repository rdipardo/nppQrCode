@echo off
::
:: SPDX-FileCopyrightText: Copyright (c) 2025 Robert Di Pardo
:: SPDX-License-Identifier: GPL-3.0-or-later OR Apache-2.0
::
SETLOCAL

set "VERSION=0.0.0.2"
set "PLUGIN=NppQrCode"
set "PLUGIN_DLL=.\bin\i386-win32\Release\%PLUGIN%32.dll"
set "PLUGINX64_DLL=.\bin\x86_64-win64\Release\%PLUGIN%64.dll"
set "SLUG_NAME=.\bin\%PLUGIN%_v%VERSION%-win32"
set "SLUGX64_NAME=.\bin\%PLUGIN%_v%VERSION%-x64"
set "SLUG=%SLUG_NAME%.zip"
set "SLUGX64=%SLUGX64_NAME%.zip"
set "DOCS=README.md .\bin\Copyright"

IF NOT EXIST "%PLUGIN%.lpr" ( pushd %~dp0.. )
del /S /Q /F bin\*.zip 2>NUL:
echo D | xcopy /DIY *.txt ".\bin\Copyright"
echo D | xcopy /DIY "Interface\Source\Include\LICENSE.*" ".\bin\Copyright"
7z a -tzip "%SLUG%" "%PLUGIN_DLL%" %DOCS% -y
7z a -tzip "%SLUGX64%" "%PLUGINX64_DLL%" %DOCS% -y
IF NOT EXIST "%PLUGIN%.lpr" ( popd )

ENDLOCAL
