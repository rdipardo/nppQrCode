# NppQrCode

![Built with Free Pascal][fpc]  [![cci-badge][]][cci-status]

A Notepad++ plugin for creating QR codes from selected text.
Just select some text and click the <img src="https://raw.githubusercontent.com/rdipardo/NppQrCode/master/img/qr.jpg"> button.

<div align="center">
	<a href="https://github.com/rdipardo/NppQrCode">
		<img src="https://raw.githubusercontent.com/rdipardo/NppQrCode/master/img/hello.jpg">
	</a>
</div>

## Installation

### Plugins Admin (recommended)

A builtin [plugin manager] is available in Notepad++ versions 7.6 and newer.

Find *Plugins* on the main menu bar and select *Plugins Admin...*.
Check the box beside *NpQrCode* and click *Install*.

### Manual installation

- Download a [release archive]

- __System-wide Notepad++ installation__

  + Create a folder named `NppQrCode64` under `%ProgramFiles%\Notepad++\plugins` (64-bit),
    or (for 32-bit versions) create a folder named `NppQrCode32` under `%ProgramFiles(x86)%\Notepad++\plugins`

- __Portable Notepad++__

  + Locate the `plugins` folder where `notepad++.exe` is installed
  + Create a folder named `NppQrCode64` (64-bit) or `NppQrCode32` (32-bit)

- Extract `NppQrCode64.dll` (64-bit) or `NppQrCode32.dll` (32-bit) from the downloaded ZIP archive

- Move `NppQrCode64.dll` (64-bit) or `NppQrCode32.dll` (32-bit) into the corresponding folder

- Restart Notepad++ if it’s already running

## Building

Clone this repo and all subprojects:

    git clone --recursive https://github.com/rdipardo/nppQrCode.git

or, from inside your local source tree:

    git submodule update --init --recursive

### Lazarus

Install [Lazarus](https://www.lazarus-ide.org) for 64-bit Windows from [SourceForge](https://sourceforge.net/projects/lazarus/files),
or *via* the [Scoop](https://scoop.sh/#/apps?q=lazarus) package manager.

> [!Note]
> A separate 32-bit installation is needed for building x86 Windows binaries. See [here][3] for more information.

Double-click the 'NppQrCode.lpi' file. If prompted, click the *Open project* button.

Expand the Lazarus IDE's [*Run* menu](https://wiki.lazarus.freepascal.org/Main_menu#Run) and click *Build*.

To build using `lazbuild.exe` at the command line, see [here][4] for a guide to setting up your environment.

### Delphi

> [!Important]
> You must have Delphi RAD Studio installed with support for the 64-bit Windows platform. Version 10.1 (Berlin) or newer is recommended.

#### Using the MSBuild CLI

#### Delphi 10.4 (Sydney)

    .\build.cmd [Debug,Release] [32,64]

#### Other Delphi versions

Edit 'build.cmd' and change the `BDS_ENV` variable to the full path of 'rsvars.bat' in the 'bin' directory of your RAD Studio installation.
Then run the script as above.

#### Using Delphi RAD Studio

<ol>
<li>Open NppQrCode.dpr</li>
<li>Build NppQrCode.dll [as a normal Delphi project]</li>
</ol>


## Copyright and licence

QRFormUnit and resources (c) 2018 Vladimir Korobenkov ([vladk1973](https://github.com/vladk1973))

Bug fixes and revisions (c) 2023 Robert Di Pardo

All updates to the source code since October 2023 are made available under the terms of the GNU General Public License, Version 3 or later.

This plugin uses a [Delphi port][0] of the [ZXing] barcode image processing library, as implemented by Michael Demidov in his [DelphiZXingQRCodeEx] demo project.
ZXing and DelphiZXingQRCodeEx are both made available under the terms of the Apache License, Version 2.0.

This plugin also uses a 64-bit-compatible rewrite of the [Delphi plugin template][2] by Damjan Zobo Cvetko, which is made available under the terms of
the GNU General Public License, Version 3 or later. Some individual files may alternatively be covered by the LGPL, Version 3 or later, or the Mozilla
Public License, Version 2.0. Visit [the template repository][1] for complete information.

[0]: https://github.com/foxitsoftware/DelphiZXingQRCode
[1]: https://bitbucket.org/rdipardo/DelphiPluginTemplate
[2]: https://sourceforge.net/projects/npp-plugins/files/DelphiPluginTemplate
[3]: https://bitbucket.org/rdipardo/delphiplugintemplate/wiki/Home#markdown-header-installing-lazarus
[4]: https://bitbucket.org/rdipardo/delphiplugintemplate/wiki/Home#markdown-header-at-the-command-line
[release archive]: https://github.com/rdipardo/nppQrCode/releases
[plugin manager]: https://npp-user-manual.org/docs/plugins/#install-using-plugins-admin
[DelphiZXingQRCodeEx]: https://github.com/MichaelDemidov/DelphiZXingQRCodeEx
[ZXing]: https://github.com/zxing
[cci-status]: https://circleci.com/gh/rdipardo/nppQrCode
[cci-badge]: https://circleci.com/gh/rdipardo/nppQrCode.svg?style=svg
[fpc]: https://img.shields.io/github/languages/top/rdipardo/nppQRCode?style=flat-square&color=lightblue&label=Free%20Pascal&logo=lazarus
