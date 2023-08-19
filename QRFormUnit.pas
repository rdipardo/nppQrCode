unit QRFormUnit;
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
interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls,
  DelphiZXingQRCode, NppForms, NppPlugin;

type

  TQrPlugin = class(TNppPlugin)
  private
    { Private declarations }
    function SendMsg(const _hwnd: HWND; Message: UINT; _wParam: WPARAM = 0; _lParam: Pointer = nil): LRESULT;
    const cnstNoSelection = 'Please, select text before using';
    const cnstFunctionCaption = 'Encode selection to QR code';
    const cnstName = 'NppQrCode';
  public
    constructor Create;
    procedure DoNppnToolbarModification; override;
    function SelectedText: string;
    procedure FuncQr;
  end;

  TQrForm = class(TNppForm)
    cmbEncoding: TComboBox;
    lblEncoding: TLabel;
    lblQuietZone: TLabel;
    edtQuietZone: TEdit;
    cbbErrorCorrectionLevel: TComboBox;
    lblErrorCorrectionLevel: TLabel;
    edtCornerThickness: TEdit;
    udCornerThickness: TUpDown;
    lblCorner: TLabel;
    udQuietZone: TUpDown;
    grpSaveToFile: TGroupBox;
    dlgSaveToFile: TSaveDialog;
    edtFileName: TEdit;
    lblScaleToSave: TLabel;
    edtScaleToSave: TEdit;
    udScaleToSave: TUpDown;
    lblDrawingMode: TLabel;
    cbbDrawingMode: TComboBox;
    pnlDetails: TPanel;
    pgcQRDetails: TPageControl;
    tsPreview: TTabSheet;
    pbPreview: TPaintBox;
    tsEncodedData: TTabSheet;
    mmoEncodedData: TMemo;
    lblQRMetrics: TLabel;
    btnSaveToFile: TButton;
    pnlColors: TPanel;
    clrbxBackground: TColorBox;
    lblBackground: TLabel;
    lblForeground: TLabel;
    clrbxForeground: TColorBox;
    bvlColors: TBevel;
    btnCopy: TButton;
    procedure FormCreate(Sender: TObject);
    procedure cmbEncodingChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSaveToFileClick(Sender: TObject);
    procedure cbbDrawingModeChange(Sender: TObject);
    procedure cmbEncodingMeasureItem(Control: TWinControl; Index: Integer;
      var AHeight: Integer);
    procedure cmbEncodingDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure pbPreviewPaint(Sender: TObject);
    procedure clrbxBackgroundChange(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure pgcQRDetailsChange(Sender: TObject);
  private
    FQRCode: TDelphiZXingQRCode;
    FText: string;
    // to fix well-known Delphi 7 error with visually vanishing components
    // under Windows Vista, 7, and later
    FAltFixed: Boolean;
    procedure RemakeQR;

    procedure SetText(const Value: string);

  public
    property Text: string read FText write SetText;
  end;

var
  NPlugin: TQrPlugin;

implementation

uses
  QRGraphics, QR_Win1251, QR_URL, jpeg, Clipbrd, System.UITypes;

{$R *.dfm}

procedure _FuncQr; cdecl;
begin
  NPlugin.FuncQr;
end;

{ TQrPlugin }

constructor TQrPlugin.Create;
var
  sk: TShortcutKey;
begin
  inherited;
  PluginName := cnstName;
  AddFuncItem(cnstFunctionCaption, _FuncQr);
end;

function TQrPlugin.SendMsg(const _hwnd: HWND; Message: UINT; _wParam: WPARAM = 0; _lParam: Pointer = nil): LRESULT;
begin
  try
    if SendMessageTimeout(_hwnd, Message, WPARAM(_wParam), LPARAM(_lParam), SMTO_NORMAL, 5000, @Result) = 0 then
      RaiseLastOSError;
  except
    on E: EOSError do begin
      raise;
    end;
    on E: Exception do begin
      raise;
    end;
  end;
end;

function TQrPlugin.SelectedText: string;
var
  Editor: HWND;
  SelRange: Sci_Position;
  Chars: AnsiString;
begin
  Editor := CurrentScintilla;
  SelRange := SendMsg(Editor, SCI_GETSELTEXT);
  if Self.HasV5Apis then
    Inc(SelRange);
  Chars := AnsiString(StringOfChar(#0, SelRange));
  SendMsg(Editor, SCI_GETSELTEXT, 0, PAnsiChar(Chars));
  case SendMsg(Editor, SCI_GETCODEPAGE) of
    SC_CP_UTF8:
    begin
      Result := UTF8toString(Chars);
    end
    else
      Result := String(UTF8Encode(Chars))
  end;
end;

procedure TQrPlugin.DoNppnToolbarModification;
var
  tb: TToolbarIcons;
begin
  tb.ToolbarIcon := 0;
  tb.ToolbarBmp := LoadImage(Hinstance, 'QRBITMAP', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
  SendNppMessage(NPPM_ADDTOOLBARICON, self.CmdIdFromDlgId(0), @tb);
end;

procedure TQrPlugin.FuncQr;
var
  S: string;
  F: TQrForm;
begin
  S := SelectedText;
  if TrimRight(S).Length > 0 then
  begin
    F := TQrForm.Create(self);
    try
      F.Text := S;
      F.ShowModal;
    finally
      F.Free;
    end;
  end
  else
    if Assigned(Application) then
      Application.MessageBox(cnstNoSelection,nppPChar(PluginName),MB_ICONSTOP + MB_OK);
end;

{ TQrForm }

procedure TQrForm.cmbEncodingChange(Sender: TObject);
begin
  RemakeQR;
end;

procedure TQrForm.FormCreate(Sender: TObject);
var
  H: Integer;
begin
  FAltFixed := False;
  FQRCode := nil;

  // number edit
  SetWindowLong(edtQuietZone.Handle, GWL_STYLE,
    GetWindowLong(edtQuietZone.Handle, GWL_STYLE) or ES_NUMBER);
  SetWindowLong(edtCornerThickness.Handle, GWL_STYLE,
    GetWindowLong(edtCornerThickness.Handle, GWL_STYLE) or ES_NUMBER);
  SetWindowLong(edtScaleToSave.Handle, GWL_STYLE,
    GetWindowLong(edtScaleToSave.Handle, GWL_STYLE) or ES_NUMBER);

  Position := poScreenCenter;
  with cmbEncoding do
  begin
    H := ItemHeight;
    Style := csOwnerDrawVariable;
    ItemHeight := H;
    OnChange := nil;
    ItemIndex := 0;
    OnChange := cmbEncodingChange
  end;
  with cbbErrorCorrectionLevel do
  begin
    OnChange := nil;
    ItemIndex := 0;
    OnChange := cmbEncodingChange
  end;
  with cbbDrawingMode do
  begin
    OnChange := nil;
    ItemIndex := 0;
    OnChange := cbbDrawingModeChange
  end;

  // create and prepare QRCode component
  FQRCode := TDelphiZXingQRCode.Create;
  FQRCode.RegisterEncoder(ENCODING_WIN1251, TWin1251Encoder);
  FQRCode.RegisterEncoder(ENCODING_URL, TURLEncoder);

end;

procedure TQrForm.RemakeQR;
// QR-code generation
begin
  with FQRCode do
  try
    BeginUpdate;
    Data := FText;
    Encoding := cmbEncoding.ItemIndex;
    ErrorCorrectionOrdinal := TErrorCorrectionOrdinal
      (cbbErrorCorrectionLevel.ItemIndex);
    QuietZone := StrToIntDef(edtQuietZone.Text, 4);
    EndUpdate(True);
    lblQRMetrics.Caption := IntToStr(Columns) + 'x' + IntToStr(Rows) + ' (' +
      IntToStr(Columns - QuietZone * 2) + 'x' + IntToStr(Rows - QuietZone * 2) +
      ')';
  finally
    pbPreview.Repaint;
  end;
end;

procedure TQrForm.SetText(const Value: string);
begin
  FText := Value;
end;

procedure TQrForm.FormDestroy(Sender: TObject);
begin
  FQRCode.Free;
end;

procedure TQrForm.btnSaveToFileClick(Sender: TObject);
var
  Bmp: TBitmap;
  M: TMetafile;
  S: string;
  J: TJPEGImage;
begin
  if dlgSaveToFile.Execute then
  begin
    S := LowerCase(ExtractFileExt(dlgSaveToFile.FileName));
    if S = '' then
    begin
      case dlgSaveToFile.FilterIndex of
        0, 1: S := '.bmp';
        2: S := '.emf';
        3: S := '.jpg';
      end;
      dlgSaveToFile.FileName := dlgSaveToFile.FileName + S;
    end;

    edtFileName.Text := dlgSaveToFile.FileName;
    Bmp := nil;
    M := nil;
    J := nil;
    if S = '.bmp' then
    try
      Bmp := TBitmap.Create;
      MakeBmp(Bmp, udScaleToSave.Position, FQRCode, clrbxBackground.Selected,
        clrbxForeground.Selected, udCornerThickness.Position);
      Bmp.SaveToFile(dlgSaveToFile.FileName);
      Bmp.Free;
    except
      Bmp.Free;
      raise;
    end
    else
      if S = '.emf' then
      try
        M := TMetafile.Create;
        MakeMetafile(M, udScaleToSave.Position, FQRCode,
          clrbxBackground.Selected, clrbxForeground.Selected,
          TQRDrawingMode(cbbDrawingMode.ItemIndex div 2),
          udCornerThickness.Position);
        M.SaveToFile(dlgSaveToFile.FileName);
        M.Free;
      except
        M.Free;
        raise;
      end
      else
        if S = '.jpg' then
        try
          Bmp := TBitmap.Create;
          MakeBmp(Bmp, udScaleToSave.Position, FQRCode,
            clrbxBackground.Selected, clrbxForeground.Selected,
            udCornerThickness.Position);
          J := TJPEGImage.Create;
          J.Assign(Bmp);
          J.SaveToFile(dlgSaveToFile.FileName);
          J.Free;
          Bmp.Free;
        except
          J.Free;
          Bmp.Free;
          raise;
        end
  end;
end;

procedure TQrForm.cbbDrawingModeChange(Sender: TObject);
begin
  dlgSaveToFile.FilterIndex := Ord(TQRDrawingMode(cbbDrawingMode.ItemIndex
    div 2) <> drwBitmap) + 1;
  pbPreview.Repaint;
end;

procedure TQrForm.cmbEncodingMeasureItem(Control: TWinControl;
  Index: Integer; var AHeight: Integer);
begin
  AHeight := cmbEncoding.ItemHeight;
  if Index in [0, ENCODING_UTF8_BOM + 1] then
    AHeight := AHeight * 2;
end;

procedure TQrForm.cmbEncodingDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  R1, R2: TRect;
  IsSpecialLine: Boolean;
  OldColor, OldFontColor: TColor;
  S: string;
begin
  IsSpecialLine := (Index in [0, ENCODING_UTF8_BOM + 1]) and
    not (odComboBoxEdit in State);
  with Control as TComboBox do
  begin
    if IsSpecialLine then
    begin
      R1 := Rect;
      R2 := R1;
      R1.Bottom := (Rect.Bottom + Rect.Top) div 2;
      R2.Top := R1.Bottom;
    end
    else
      R2 := Rect;
    Canvas.FillRect(R2);
    if Index >= 0 then
    begin
      if IsSpecialLine then
      begin
        OldColor := Canvas.Brush.Color;
        OldFontColor := Canvas.Font.Color;
        Canvas.Brush.Color := clBtnFace;
        Canvas.Font.Style := [fsBold];
        Canvas.Font.Color := clGrayText;
        Canvas.FillRect(R1);
        if Index = 0 then
          S := 'Default'
        else
          S := 'Extended';
        Canvas.TextOut((R1.Left + R1.Right - Canvas.TextWidth(S)) div 2, R1.Top,
          S);
        Canvas.Font.Assign(Font);
        Canvas.Brush.Color := OldColor;
        Canvas.Font.Color := OldFontColor;
      end;
      Canvas.TextOut(R2.Left + 2, R2.Top, Items[Index]);
    end;
    if IsSpecialLine and (odFocused in State) then
      with Canvas do
      begin
        DrawFocusRect(Rect);
        DrawFocusRect(R2);
      end;
  end;
end;

procedure TQrForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  procedure InvalidateControl(W: TWinControl);
  var
    I: Integer;
  begin
    with W do
    begin
      for I := 0 to ControlCount - 1 do
        if Controls[I] is TWinControl then
          InvalidateControl(Controls[I] as TWinControl);
      Invalidate;
    end;
  end;

const KEY_ESC = 27;

begin
  if not FAltFixed and (ssAlt in Shift) then
  begin
    InvalidateControl(Self);
    FAltFixed := True;
  end;

  if Key = KEY_ESC then Close;

end;

procedure TQrForm.pbPreviewPaint(Sender: TObject);
begin
  with pbPreview.Canvas do
  begin
    Pen.Color := clrbxForeground.Selected;
    Brush.Color := clrbxBackground.Selected;
  end;
  DrawQR(pbPreview.Canvas, pbPreview.ClientRect, FQRCode,
    udCornerThickness.Position, TQRDrawingMode(cbbDrawingMode.ItemIndex div 2),
    Boolean(1 - cbbDrawingMode.ItemIndex mod 2));
end;

procedure TQrForm.pgcQRDetailsChange(Sender: TObject);
begin
  mmoEncodedData.Text := FQRCode.FilteredData;
end;

procedure TQrForm.clrbxBackgroundChange(Sender: TObject);
begin
  pbPreview.Repaint;
end;

procedure TQrForm.btnCopyClick(Sender: TObject);
var
  Bmp: TBitmap;
begin
  Bmp := nil;
  try
    Bmp := TBitmap.Create;
    MakeBmp(Bmp, udScaleToSave.Position, FQRCode, clrbxBackground.Selected,
      clrbxForeground.Selected, udCornerThickness.Position);
    Clipboard.Assign(Bmp);
    Bmp.Free;
  except
    Bmp.Free;
    raise;
  end;
end;

end.
