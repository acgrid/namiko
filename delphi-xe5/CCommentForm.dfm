object frmComment: TfrmComment
  Left = 0
  Top = 0
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  AutoScroll = False
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #24377#24149#31383#21475
  ClientHeight = 378
  ClientWidth = 822
  Color = clSilver
  TransparentColorValue = clSilver
  DockSite = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  PixelsPerInch = 96
  TextHeight = 13
  object NetCDemo: TTntLabel
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
  object OfficialCDemo: TTntLabel
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
  object TestLabel: TCoolLabel
    Left = 376
    Top = 0
    Width = 316
    Height = 38
    Caption = 'CT3.5 '#24392#24149#21520#27133#29256
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
  object Monitor: TMemo
    Left = 0
    Top = 280
    Width = 129
    Height = 97
    BorderStyle = bsNone
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentColor = True
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
  end
  object TimerMonitor: TTimer
    Interval = 500
    OnTimer = TimerMonitorTimer
    Left = 392
    Top = 136
  end
  object TimerMoving: TTimer
    Interval = 40
    OnTimer = TimerMovingTimer
    Left = 328
    Top = 136
  end
  object TimerDispatch: TTimer
    Interval = 10
    OnTimer = TimerDispatchTimer
    Left = 360
    Top = 136
  end
end
