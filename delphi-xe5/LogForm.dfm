object frmLog: TfrmLog
  Left = 1460
  Top = 665
  AlphaBlend = True
  AlphaBlendValue = 233
  BorderIcons = []
  Caption = #26085#24535
  ClientHeight = 362
  ClientWidth = 424
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 440
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object LogList: TListView
    Left = 10
    Top = 10
    Width = 400
    Height = 300
    Columns = <
      item
        Caption = #26102#38388
        MaxWidth = 80
        MinWidth = 60
        Width = 60
      end
      item
        Caption = #27169#22359
      end
      item
        Caption = #31867#21035
      end
      item
        Caption = #20449#24687
        Width = 220
      end>
    DoubleBuffered = True
    FlatScrollBars = True
    GridLines = True
    ReadOnly = True
    RowSelect = True
    ParentDoubleBuffered = False
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = LogListDblClick
  end
  object BtnHide: TButton
    Left = 335
    Top = 323
    Width = 75
    Height = 25
    Caption = #38544#34255'(&H)'
    TabOrder = 1
    OnClick = BtnHideClick
  end
  object ComboFilter: TComboBox
    Left = 10
    Top = 325
    Width = 129
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 2
    Text = #20840#37096
    OnChange = ComboFilterChange
    Items.Strings = (
      #20840#37096
      #35843#35797
      #20449#24687
      #35686#21578
      #38169#35823
      #24322#24120)
  end
  object BtnSaveLog: TButton
    Left = 255
    Top = 323
    Width = 75
    Height = 25
    Caption = #23548#20986'(&E)'
    TabOrder = 3
    OnClick = BtnSaveLogClick
  end
  object TimerLogUpdate: TTimer
    Enabled = False
    OnTimer = TimerLogUpdateTimer
    Left = 288
    Top = 24
  end
  object SaveLogFileDialog: TSaveTextFileDialog
    FileName = 'NamikoDanmaku.log'
    Filter = #26085#24535#25991#20214'|*.log|'#25991#26412#25991#20214'|*.txt'
    Title = #20445#23384#26085#24535#25991#20214
    Encodings.Strings = (
      'UTF-8'
      'Unicode'
      'Big Endian Unicode')
    Left = 368
    Top = 24
  end
end
