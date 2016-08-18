object FormDimSet: TFormDimSet
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #22823#23567#20301#32622#25511#21046
  ClientHeight = 178
  ClientWidth = 379
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LabelNotice: TLabel
    Left = 11
    Top = 157
    Width = 360
    Height = 13
    Caption = #22810#23631#24149#20197#20027#26700#38754#24038#19978#35282#20026'(0,0)'#20559#31227#65307#24377#24149#31383#21475#26356#25913#38656#35201#37325#21551#26174#31034#32447#31243
  end
  object ButtonCommit: TButton
    Left = 56
    Top = 120
    Width = 75
    Height = 25
    Caption = #26356#25913'(&G)'
    TabOrder = 0
    OnClick = ButtonCommitClick
  end
  object ButtonDiscard: TButton
    Left = 218
    Top = 120
    Width = 75
    Height = 25
    Caption = #25764#38144'(&D)'
    TabOrder = 1
    OnClick = ButtonDiscardClick
  end
  object EditWidth: TLabeledEdit
    Left = 218
    Top = 12
    Width = 137
    Height = 21
    EditLabel.Width = 57
    EditLabel.Height = 13
    EditLabel.Caption = #23485#24230'(&W) px'
    LabelPosition = lpLeft
    NumbersOnly = True
    TabOrder = 2
  end
  object EditHeight: TLabeledEdit
    Left = 218
    Top = 39
    Width = 137
    Height = 21
    EditLabel.Width = 54
    EditLabel.Height = 13
    EditLabel.Caption = #39640#24230'(&H) px'
    LabelPosition = lpLeft
    NumbersOnly = True
    TabOrder = 3
  end
  object EditLeft: TLabeledEdit
    Left = 218
    Top = 66
    Width = 137
    Height = 21
    EditLabel.Width = 45
    EditLabel.Height = 13
    EditLabel.Caption = #39030#28857'&X px'
    LabelPosition = lpLeft
    TabOrder = 4
  end
  object EditTop: TLabeledEdit
    Left = 218
    Top = 93
    Width = 137
    Height = 21
    EditLabel.Width = 45
    EditLabel.Height = 13
    EditLabel.Caption = #39030#28857'&Y px'
    LabelPosition = lpLeft
    TabOrder = 5
  end
  object RadioTarget: TRadioGroup
    Left = 8
    Top = 12
    Width = 123
    Height = 61
    Caption = #25511#21046#30446#26631
    ItemIndex = 0
    Items.Strings = (
      #24377#24149#31383#21475'(&W)'
      #26631#39064#25991#23383'(&C)')
    TabOrder = 6
    OnClick = RadioTargetClick
  end
end
