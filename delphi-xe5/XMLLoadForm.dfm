object frmLoadXML: TfrmLoadXML
  Left = 523
  Top = 210
  BorderStyle = bsDialog
  Caption = #35835#21462#36873#39033
  ClientHeight = 186
  ClientWidth = 231
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = #24494#36719#38597#40657
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object LblSample: TLabel
    Left = 16
    Top = 8
    Width = 18
    Height = 16
    Caption = '233'
  end
  object Label1: TLabel
    Left = 16
    Top = 160
    Width = 165
    Height = 16
    Caption = #23548#20837#30340#25968#25454#19981#32463#36807#27827#34809#20043#25163#35831#23567#24515
    Font.Charset = ANSI_CHARSET
    Font.Color = clFuchsia
    Font.Height = -11
    Font.Name = #24494#36719#38597#40657
    Font.Style = [fsBold]
    ParentFont = False
  end
  object GrpOptions: TRadioGroup
    Left = 16
    Top = 32
    Width = 201
    Height = 81
    Caption = #25991#20214#31867#22411
    Items.Strings = (
      #21382#21490#24377#24149#25968#25454#65288#32477#23545#26102#38388#36724#65289
      #21382#21490#24377#24149#25968#25454#65288#36716#25442#26102#38388#36724#65289
      #29305#25928#24377#24149#25968#25454#65288#20559#31227#26102#38388#36724#65289)
    TabOrder = 0
    OnClick = GrpOptionsClick
  end
  object EditDelay: TLabeledEdit
    Left = 68
    Top = 128
    Width = 25
    Height = 24
    EditLabel.Width = 11
    EditLabel.Height = 16
    EditLabel.Caption = #31186
    LabelPosition = lpRight
    TabOrder = 1
    Text = '3'
  end
  object btnOK: TButton
    Left = 128
    Top = 128
    Width = 75
    Height = 25
    Caption = #30830#23450
    Default = True
    TabOrder = 2
    OnClick = btnOKClick
  end
  object ComboTiming: TComboBox
    Left = 16
    Top = 128
    Width = 49
    Height = 24
    Style = csDropDownList
    ItemHeight = 16
    ItemIndex = 0
    TabOrder = 3
    Text = #24310#36831
    Items.Strings = (
      #24310#36831
      #25552#21069)
  end
  object OpenDialog: TOpenDialog
    Filter = #24377#24149#25968#25454'(*.xml)|*.xml'
    Title = #26085#35199#40657#21382#21490
    Left = 344
    Top = 72
  end
end
