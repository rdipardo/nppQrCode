library NppQrCode;
(*
 Revised and updated by Robert Di Pardo, Copyright 2023

 This program is free software: you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation, either version
 3 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be
 useful, but WITHOUT ANY WARRANTY; without even the implied
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General
 Public License along with this program. If not, see
 <https://www.gnu.org/licenses/>.

 This software incorporates work covered by the following copyright and permission notice:

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

{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$ENDIF}

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

procedure DLLEntryPoint(dwReason: DWORD);
begin
  case dwReason of
    DLL_PROCESS_ATTACH:
    begin
      NPlugin := TQrPlugin.Create;
    end;
    DLL_PROCESS_DETACH:
    begin
      if (Assigned(NPlugin)) then NPlugin.Destroy;
    end;
  end;
end;

procedure setInfo(NppData: TNppData); cdecl;
begin
  NPlugin.SetInfo(NppData);
end;

function getName: nppPchar; cdecl;
begin
  Result := NPlugin.GetName;
end;

function getFuncsArray(var nFuncs:integer):Pointer; cdecl;
begin
  Result := NPlugin.GetFuncsArray(nFuncs);
end;

procedure beNotified(sn: PSciNotification); cdecl;
begin
  NPlugin.BeNotified(sn);
end;

function messageProc(msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; cdecl;
var
  Message: TMessage;
begin
  Message.Msg := msg;
  Message.WParam := wParam;
  Message.LParam := lParam;
  Message.Result := 0;
  NPlugin.MessageProc(Message);
  Result := Message.Result;
end;

function isUnicode: BOOL; cdecl;
begin
  Result := true;
end;

exports
  setInfo, getName, getFuncsArray, beNotified, messageProc, isUnicode;

begin
  { First, assign the procedure to the DLLProc variable }
  DllProc := @DLLEntryPoint;
  { Now invoke the procedure to reflect that the DLL is attaching to the process }
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.

