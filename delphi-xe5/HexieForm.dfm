object frmWordList: TfrmWordList
  Left = 306
  Top = 239
  Width = 330
  Height = 440
  Caption = #27827#34809#12398#35302#25163
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #24494#36719#38597#40657
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 17
  object LblDesc: TTntLabel
    Left = 8
    Top = 40
    Width = 290
    Height = 17
    Caption = #27599#34892#20445#23384#19968#20010'Perl'#20860#23481#27491#21017#34920#36798#24335'(PCRE) '#19981#38656#35201#39318#23614'//'
  end
  object LblTestResult: TTntLabel
    Left = 245
    Top = 12
    Width = 4
    Height = 17
  end
  object HexieList: TTntMemo
    Left = 8
    Top = 64
    Width = 300
    Height = 300
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btnDone: TTntButton
    Left = 112
    Top = 370
    Width = 89
    Height = 25
    Hint = #20445#23384#20851#38190#23383#21015#34920#12290
    Caption = #20928#21270#23436#20102'(&D)'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnClick = btnDoneClick
  end
  object EditTestSubject: TTntEdit
    Left = 8
    Top = 8
    Width = 160
    Height = 25
    TabOrder = 2
  end
  object btnPCRETest: TTntButton
    Left = 175
    Top = 8
    Width = 64
    Height = 25
    Caption = #27979#35797'(&T)'
    Default = True
    TabOrder = 3
    OnClick = btnPCRETestClick
  end
  object Hexie: TPerlRegEx
    Options = [preMultiLine]
    Left = 280
    Top = 32
  end
end
