// Extracted from TADrawerWMF.pas, part of the Lazarus Component Library, version 1.9.0
// See also https://wiki.lazarus.freepascal.org/TMetafile_/_TMetafileCanvas#License
unit Metafiles;
{
 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

  Authors: Luís Rodrigues, Alexander Klenin
}
interface

uses
  Classes, Types, Graphics, Windows;

type
  TMetafile = class(TGraphic)
  private
    FImageHandle: HENHMETAFILE;
    FImageMMWidth: integer;      // are in 0.01 mm logical pixels
    FImageMMHeight: integer;     // are in 0.01 mm logical pixels
    FImagePxWidth: integer;      // in device pixels
    FImagePxHeight: integer;     // in device pixels
    procedure DeleteImage;
    function GetAuthor: string;
    function GetDescription: string;
    function GetHandle: HENHMETAFILE;
    procedure SetHandle(Value: HENHMETAFILE);
    function GetMMHeight: integer;
    function GetMMWidth: integer;
    procedure SetMMHeight(Value: integer);
    procedure SetMMWidth(Value: integer);
  protected
    procedure Draw(ACanvas: TCanvas; const ARect: Types.TRect); override;
    function GetEmpty: boolean; override;
    function GetHeight: integer; override;
    function GetTransparent: boolean; override;
    function GetWidth: integer; override;
    procedure SetHeight(Value: integer); override;
    procedure SetTransparent({%H-}Value: boolean); override;
    procedure SetWidth(Value: integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear; override;
    procedure LoadFromStream({%H-}AStream: TStream); override;
    procedure SaveToFile(const AFileName: string); override; overload;
    procedure SaveToFile(const AFileName: unicodestring); overload;
    procedure SaveToStream({%H-}AStream: TStream); override;
    procedure CopyToClipboard;
    function ReleaseHandle: HENHMETAFILE;
    property Handle: HENHMETAFILE read GetHandle write SetHandle;
    property Empty: boolean read GetEmpty;
    property CreatedBy: string read GetAuthor;
    property Description: string read GetDescription;
    property MMWidth: integer read GetMMWidth write SetMMWidth;
    property MMHeight: integer read GetMMHeight write SetMMHeight;
  end;

  TMetafileCanvas = class(TCanvas)
  strict private
    FMetafile: TMetafile;
  public
    constructor Create(AMetafile: TMetafile; AReferenceDevice: HDC);
    constructor CreateWithComment(AMetafile: TMetafile; AReferenceDevice: HDC;
      const ACreatedBy, ADescription: string);
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils;

{ TMetafile }

procedure TMetafile.DeleteImage;
begin
  if FImageHandle <> 0 then
    DeleteEnhMetafile(FImageHandle);
  FImageHandle := 0;
end;

function TMetafile.GetAuthor: string;
var
  NC: integer;
begin
  Result := '';
  if FImageHandle = 0 then Exit;

  NC := GetEnhMetafileDescription(FImageHandle, 0, nil);
  if NC <= 0 then Exit
  else
  begin
    SetLength(Result, NC);
    GetEnhMetafileDescription(FImageHandle, NC, PChar(Result));
    SetLength(Result, StrLen(PChar(Result)));
  end;
end;

function TMetafile.GetDescription: string;
var
  NC: integer;
begin
  Result := '';
  if FImageHandle = 0 then Exit;

  NC := GetEnhMetafileDescription(FImageHandle, 0, nil);
  if NC <= 0 then Exit
  else
  begin
    SetLength(Result, NC);
    GetEnhMetafileDescription(FImageHandle, NC, PChar(Result));
    Delete(Result, 1, StrLen(PChar(Result)) + 1);
    SetLength(Result, StrLen(PChar(Result)));
  end;
end;

function TMetafile.GetEmpty: boolean;
begin
  Result := (FImageHandle = 0);
end;

function TMetafile.GetHandle: HENHMETAFILE;
begin
  Result := FImageHandle;
end;

function TMetafile.GetMMHeight: integer;
begin
  Result := FImageMMHeight;
end;

function TMetafile.GetMMWidth: integer;
begin
  Result := FImageMMWidth;
end;

procedure TMetafile.SetHandle(Value: HENHMETAFILE);
var
  EnhHeader: TEnhMetaHeader;
begin
  if (Value <> 0) and (GetEnhMetafileHeader(Value, sizeof(EnhHeader),
    @EnhHeader) = 0) then
    raise EInvalidImage.Create('Invalid Metafile');

  if FImageHandle <> 0 then DeleteImage;

  FImageHandle := Value;
  FImagePxWidth := 0;
  FImagePxHeight := 0;
  FImageMMWidth := EnhHeader.rclFrame.Right - EnhHeader.rclFrame.Left;
  FImageMMHeight := EnhHeader.rclFrame.Bottom - EnhHeader.rclFrame.Top;
end;

procedure TMetafile.SetMMHeight(Value: integer);
begin
  FImagePxHeight := 0;
  if FImageMMHeight <> Value then FImageMMHeight := Value;
end;

procedure TMetafile.SetMMWidth(Value: integer);
begin
  FImagePxWidth := 0;
  if FImageMMWidth <> Value then FImageMMWidth := Value;
end;

procedure TMetafile.Draw(ACanvas: TCanvas; const ARect: Types.TRect);
var
  RT: TRect;
begin
  if FImageHandle = 0 then Exit;
  RT := ARect;
  PlayEnhMetaFile(ACanvas.Handle, FImageHandle, RT);
end;

function TMetafile.GetHeight: integer;
var
  EMFHeader: TEnhMetaHeader;
begin
  if FImageHandle = 0 then
    Result := FImagePxHeight
  else
  begin               // convert 0.01mm units to device pixels
    GetEnhMetaFileHeader(FImageHandle, Sizeof(EMFHeader), @EMFHeader);
    Result := MulDiv(FImageMMHeight,               // metafile height in 0.01mm
      EMFHeader.szlDevice.cy,                      // device height in pixels
      EMFHeader.szlMillimeters.cy * 100);            // device height in mm
  end;
end;

function TMetafile.GetTransparent: boolean;
begin
  Result := False;
end;

procedure TMetafile.SetTransparent(Value: boolean);
begin
  // FIXME: implement SetTransparent
end;

function TMetafile.GetWidth: integer;
var
  EMFHeader: TEnhMetaHeader;
begin
  if FImageHandle = 0 then
    Result := FImagePxWidth
  else
  begin     // convert 0.01mm units to device pixels
    GetEnhMetaFileHeader(FImageHandle, Sizeof(EMFHeader), @EMFHeader);
    Result := MulDiv(FImageMMWidth,                // metafile width in 0.01mm
      EMFHeader.szlDevice.cx,                      // device width in pixels
      EMFHeader.szlMillimeters.cx * 100);            // device width in 0.01mm
  end;
end;

procedure TMetafile.SetHeight(Value: integer);
var
  EMFHeader: TEnhMetaHeader;
begin
  if FImageHandle = 0 then
    FImagePxHeight := Value
  else
  begin                 // convert device pixels to 0.01mm units
    GetEnhMetaFileHeader(FImageHandle, Sizeof(EMFHeader), @EMFHeader);
    MMHeight := MulDiv(Value,                       // metafile height in pixels
      EMFHeader.szlMillimeters.cy * 100,             // device height in 0.01mm
      EMFHeader.szlDevice.cy);                     // device height in pixels
  end;
end;

procedure TMetafile.SetWidth(Value: integer);
var
  EMFHeader: TEnhMetaHeader;
begin
  if FImageHandle = 0 then
    FImagePxWidth := Value
  else
  begin                 // convert device pixels to 0.01mm units
    GetEnhMetaFileHeader(FImageHandle, Sizeof(EMFHeader), @EMFHeader);
    MMWidth := MulDiv(Value,                      // metafile width in pixels
      EMFHeader.szlMillimeters.cx * 100,            // device width in mm
      EMFHeader.szlDevice.cx);                    // device width in pixels
  end;
end;

constructor TMetafile.Create;
begin
  inherited Create;
  FImageHandle := 0;
end;

destructor TMetafile.Destroy;
begin
  DeleteImage;
  inherited Destroy;
end;

procedure TMetafile.Assign(Source: TPersistent);
begin
  if (Source = nil) or (Source is TMetafile) then
  begin
    if FImageHandle <> 0 then DeleteImage;
    if Assigned(Source) then
    begin
      FImageHandle := TMetafile(Source).Handle;
      FImageMMWidth := TMetafile(Source).MMWidth;
      FImageMMHeight := TMetafile(Source).MMHeight;
      FImagePxWidth := TMetafile(Source).Width;
      FImagePxHeight := TMetafile(Source).Height;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TMetafile.Clear;
begin
  DeleteImage;
end;

procedure TMetafile.CopyToClipboard;
// http://www.olivierlanglois.net/metafile-clipboard.html
var
  Format: word;
begin
  if FImageHandle = 0 then exit;

  OpenClipboard(0);
  try
    EmptyClipboard;
    Format := CF_ENHMETAFILE;
    SetClipboardData(Format, FImageHandle);
  finally
    CloseClipboard;
  end;
end;

function TMetafile.ReleaseHandle: HENHMETAFILE;
begin
  DeleteImage;
  Result := FImageHandle;
  FImageHandle := 0;
end;

procedure TMetafile.SaveToFile(const AFileName: string);
begin
  SaveToFile(UTF8Decode(AFileName));
end;

procedure TMetafile.SaveToFile(const AFileName: unicodestring);
var
  outFile: HENHMETAFILE;
begin
  if FImageHandle = 0 then exit;
  try
    outFile := CopyEnhMetaFileW(FImageHandle, punicodechar(AFileName));
    try
      if outFile = 0 then
        RaiseLastWin32Error;
    except
      on E: Exception do
      begin
        MessageBoxW(0, punicodechar(UTF8Decode(E.Message)),
          punicodechar({$I %CURRENTROUTINE%}), MB_ICONERROR);
      end;
    end;
  finally
    DeleteEnhMetaFile(outFile);
  end;
end;

procedure TMetafile.LoadFromStream(AStream: TStream);
begin
  // FIXME: implement LoadFromStream
end;

procedure TMetafile.SaveToStream(AStream: TStream);
begin
  // FIXME: implement SaveToStream
end;

{ TMetafileCanvas }

constructor TMetafileCanvas.Create(AMetafile: TMetafile; AReferenceDevice: HDC);
begin
  CreateWithComment(AMetafile, AReferenceDevice, AMetafile.CreatedBy,
    AMetafile.Description);
end;

constructor TMetafileCanvas.CreateWithComment(AMetafile: TMetafile;
  AReferenceDevice: HDC; const ACreatedBy, ADescription: string);
var
  RefDC: HDC;
  R: TRect;
  Temp: HDC;
  P: PChar;
begin
  inherited Create;
  FMetafile := AMetafile;

  if AReferenceDevice = 0 then RefDC := GetDC(0)
  else
    RefDC := AReferenceDevice;

  try
    if FMetafile.MMWidth = 0 then
    begin
      if FMetafile.Width = 0 then //if no width get RefDC height
        FMetafile.MMWidth := GetDeviceCaps(RefDC, HORZSIZE) * 100
      else
        FMetafile.MMWidth := MulDiv(FMetafile.Width, //else convert
          GetDeviceCaps(RefDC, HORZSIZE) * 100, GetDeviceCaps(RefDC, HORZRES));
    end;

    if FMetafile.MMHeight = 0 then
    begin
      if FMetafile.Height = 0 then //if no height get RefDC height
        FMetafile.MMHeight := GetDeviceCaps(RefDC, VERTSIZE) * 100
      else
        FMetafile.MMHeight := MulDiv(FMetafile.Height, //else convert
          GetDeviceCaps(RefDC, VERTSIZE) * 100, GetDeviceCaps(RefDC, VERTRES));
    end;

    R := Types.Rect(0, 0, FMetafile.MMWidth, FMetafile.MMHeight);
    //lpDescription stores both author and description
    if (Length(ACreatedBy) > 0) or (Length(ADescription) > 0) then
      P := PChar(ACreatedBy + #0 + ADescription + #0#0)
    else
      P := nil;
    Temp := CreateEnhMetafile(RefDC, nil, @R, P);
    if Temp = 0 then raise EOutOfResources.Create('Out of Resources');
    ;
    Handle := Temp;
  finally
    if AReferenceDevice = 0 then ReleaseDC(0, RefDC);
  end;

end;

destructor TMetafileCanvas.Destroy;
begin
  FMetafile.Handle := CloseEnhMetafile(Handle);
  inherited Destroy;
end;

end.
