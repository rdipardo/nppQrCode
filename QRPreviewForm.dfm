object QRPreview: TQrPreviewForm
  Left = 0
  Height = 662
  Top = 0
  Width = 936
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Preview'
  ClientHeight = 662
  ClientWidth = 936
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  OnResize = FormChangeBounds
  Scaled = False
  object QRCodePreview: TPaintBox
    Left = 0
    Height = 662
    Top = 0
    Width = 936
    Align = alClient
    OnPaint = QRCodePreviewPaint
  end
end
