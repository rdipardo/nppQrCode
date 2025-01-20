library NppQrCode;
(*
 Copyright 2025 Robert Di Pardo

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

{$warn 2025 off}
{$if not declared(useheaptrace)}
  {$SetPEOptFlags $0040}
{$endif}

uses
  Windows, SysUtils, NppPlugin, QRFormUnit;

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
      if (Assigned(NPlugin)) then FreeAndNil(NPlugin);
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
  Dll_Process_Detach_Hook:= @DLLEntryPoint;
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.
