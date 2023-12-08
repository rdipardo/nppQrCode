# NppQrCode

A Notepad++ plugin for creating QR codes from selected text.
Just select some text and click the <img src="https://raw.githubusercontent.com/rdipardo/NppQrCode/master/img/qr.jpg"> button.

<div align="center">
	<a href="https://github.com/rdipardo/NppQrCode">
		<img src="https://raw.githubusercontent.com/rdipardo/NppQrCode/master/img/hello.jpg">
	</a>
</div>


## Building

> [!Important]
> You must have Delphi RAD Studio installed with support for the 64-bit Windows platform. Version 10.1 (Berlin) or newer is recommended.
>
> Make sure to clone all subprojects to your local source tree:
>
>     git submodule update --init --remote

### Using the MSBuild CLI

#### Delphi 10.4 (Sydney)

    .\build.cmd [Debug,Release] [32,64]

#### Other Delphi versions

Edit 'build.cmd' and change the `BDS_ENV` variable to the full path of 'rsvars.bat' in the 'bin' directory of your RAD Studio installation.
Then run the script as above.

### Using Delphi RAD Studio

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
[DelphiZXingQRCodeEx]: https://github.com/MichaelDemidov/DelphiZXingQRCodeEx
[ZXing]: https://github.com/zxing
