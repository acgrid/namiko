object frmConfig: TfrmConfig
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #37197#32622#32534#36753#22120
  ClientHeight = 448
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnHide = FormHide
  PixelsPerInch = 96
  TextHeight = 13
  object ValueListEditor: TValueListEditor
    Left = 8
    Top = 8
    Width = 378
    Height = 300
    DefaultColWidth = 300
    DropDownRows = 10
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
    Strings.Strings = (
      '=')
    TabOrder = 0
    TitleCaptions.Strings = (
      #35774#23450#39033
      #35774#23450#20540)
    OnClick = ValueListEditorClick
    ColWidths = (
      150
      222)
    RowHeights = (
      18
      18)
  end
  object GroupEdit: TGroupBox
    Left = 8
    Top = 314
    Width = 378
    Height = 95
    Caption = #20462#25913#37197#32622
    TabOrder = 1
    object LabelDescription: TLabel
      Left = 9
      Top = 17
      Width = 96
      Height = 13
      Caption = #35831#36873#25321#19968#20010#37197#32622#39033
    end
    object LabelNewValue: TLabel
      Left = 9
      Top = 65
      Width = 36
      Height = 13
      Caption = #24403#21069#20540
    end
    object EditString: TEdit
      Left = 56
      Top = 63
      Width = 240
      Height = 21
      TabOrder = 0
      Text = 'EditString'
      Visible = False
    end
    object UpDownInteger: TUpDown
      Left = 276
      Top = 64
      Width = 16
      Height = 21
      Associate = EditInteger
      TabOrder = 1
      Thousands = False
      Visible = False
    end
    object EditInteger: TEdit
      Left = 56
      Top = 64
      Width = 220
      Height = 21
      ImeMode = imClose
      NumbersOnly = True
      TabOrder = 2
      Text = '0'
      Visible = False
    end
    object RadioGroupBoolean: TRadioGroup
      Left = 55
      Top = 56
      Width = 240
      Height = 36
      Caption = #35774#23450#20540
      Columns = 2
      Items.Strings = (
        #26159'(&True)'
        #21542'(&False)')
      TabOrder = 3
      Visible = False
    end
    object BtnConfirm: TBitBtn
      Left = 300
      Top = 62
      Width = 75
      Height = 25
      Caption = #30830#35748'(&C)'
      Default = True
      TabOrder = 4
      OnClick = BtnConfirmClick
    end
  end
  object BtnReload: TButton
    Left = 161
    Top = 415
    Width = 75
    Height = 25
    Cancel = True
    Caption = #37325#36733'(&R)'
    TabOrder = 2
    OnClick = BtnReloadClick
  end
end
