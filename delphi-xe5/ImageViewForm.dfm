object frmImage: TfrmImage
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'frmImage'
  ClientHeight = 338
  ClientWidth = 651
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object ImagePresentation: TImage
    Left = 0
    Top = 0
    Width = 651
    Height = 330
    Center = True
  end
  object LabelSignature: TLabel
    Left = 8
    Top = 302
    Width = 71
    Height = 13
    Caption = 'LabelSignature'
  end
  object ProgressBarRemaining: TProgressBar
    Left = 0
    Top = 321
    Width = 651
    Height = 17
    DoubleBuffered = False
    ParentDoubleBuffered = False
    Position = 100
    Smooth = True
    BarColor = clWhite
    BackgroundColor = clBlack
    TabOrder = 0
  end
  object TimerHide: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerHideTimer
    Left = 312
    Top = 152
  end
end
