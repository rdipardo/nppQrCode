
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
procedure DLLEntryPoint(dwReason: Integer);
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

procedure setInfo(NppData: TNppData); cdecl; export;
begin
  NPlugin.SetInfo(NppData);
end;

function getName: nppPchar; cdecl; export;
begin
  Result := NPlugin.GetName;
end;

function getFuncsArray(var nFuncs:integer):Pointer;cdecl; export;
begin
  Result := NPlugin.GetFuncsArray(nFuncs);
end;

procedure beNotified(sn: PSciNotification); cdecl; export;
begin
  NPlugin.BeNotified(sn);
end;

function messageProc(msg: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; cdecl; export;
var
  Message:TMessage;
begin
  Message.Msg := msg;
  Message.WParam := wParam;
  Message.LParam := lParam;
  Message.Result := 0;
  NPlugin.MessageProc(Message);
  Result := Message.Result;
end;

function isUnicode : Boolean; cdecl; export;
begin
  Result := true;
end;

exports
  setInfo, getName, getFuncsArray, beNotified, messageProc, isUnicode;
