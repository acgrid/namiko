object frmDemo: TfrmDemo
  Left = 0
  Top = 0
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #27979#35797#31383#21475
  ClientHeight = 378
  ClientWidth = 822
  Color = clSilver
  TransparentColor = True
  TransparentColorValue = clSilver
  DockSite = True
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  OnHide = FormHide
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object NetCDemo: TLabel
    Left = 6
    Top = 85
    Width = 149
    Height = 13
    Caption = #32593#32476#24377#24149' DEMO '#12487#12514' '#12395#12419#12435
    Color = clSilver
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object OfficialCDemo: TLabel
    Left = 5
    Top = 195
    Width = 149
    Height = 13
    Caption = #23448#26041#24377#24149' DEMO '#12487#12514' '#12395#12419#12435
    Color = clSilver
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object TestLabel: TLabel
    Left = 376
    Top = 0
    Width = 142
    Height = 37
    Caption = 'SAMPLE'
    Font.Charset = CHINESEBIG5_CHARSET
    Font.Color = clTeal
    Font.Height = -37
    Font.Name = #36229#30740#28580#20013#29305#22291
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    OnMouseDown = TestLabelMouseDown
    OnMouseMove = TestLabelMouseMove
    OnMouseUp = TestLabelMouseUp
  end
end
