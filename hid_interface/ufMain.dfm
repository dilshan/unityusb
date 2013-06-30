object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 150
  ClientWidth = 150
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tmrUSB: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmrUSBTimer
    Left = 56
    Top = 56
  end
end
