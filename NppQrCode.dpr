library NppQrCode;
(*
 Copyright 2018 Vladimir Korobenkov (vladk1973)

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*)
uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  DelphiZXIngQRCode in 'DelphiZXIngQRCode\Source\DelphiZXIngQRCode.pas',
  QRGraphics in 'DelphiZXIngQRCode\Source\QRGraphics.pas',
  QRFormUnit in 'QRFormUnit.pas' {QrForm},
  QR_Win1251 in 'DelphiZXIngQRCode\Source\QR_Win1251.pas',
  QR_URL in 'DelphiZXIngQRCode\Source\QR_URL.pas',
  NppForms in 'Interface\Source\Forms\Common\NppForms.pas' {NppForm},
  nppplugin in 'Interface\Source\Units\Common\nppplugin.pas';

{$R *.res}

{$R NppQrCodeBMP.RES}

{$Include 'NppPluginInclude.pas'}

begin
  { First, assign the procedure to the DLLProc variable }
  DllProc := @DLLEntryPoint;
  { Now invoke the procedure to reflect that the DLL is attaching to the process }
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.

