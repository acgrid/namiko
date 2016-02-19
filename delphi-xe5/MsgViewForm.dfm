object frmMessages: TfrmMessages
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #20250#22330#28040#24687
  ClientHeight = 270
  ClientWidth = 628
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
  object MsgListView: TListView
    Left = 8
    Top = 8
    Width = 450
    Height = 250
    Columns = <
      item
        Caption = 'ID'
        Width = 0
      end
      item
        Caption = #25509#25910#26102#38388
      end
      item
        Caption = #21457#36865'ID'
      end
      item
        Caption = #29992#25143#32452
      end
      item
        Caption = #31867#21035
      end
      item
        AutoSize = True
        Caption = #35814#24773
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu
    TabOrder = 0
    ViewStyle = vsReport
    OnContextPopup = MsgListViewContextPopup
    OnSelectItem = MsgListViewSelectItem
  end
  object MsgDetail: TMemo
    Left = 464
    Top = 8
    Width = 156
    Height = 217
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object BtnDownload: TButton
    Left = 488
    Top = 237
    Width = 105
    Height = 25
    Action = ActionDownload
    TabOrder = 2
  end
  object PopupMenu: TPopupMenu
    Left = 304
    Top = 136
    object C1: TMenuItem
      Action = ActionCopyTo
      Default = True
    end
    object M1: TMenuItem
      Action = ActionMarkDone
    end
  end
  object ActionList: TActionList
    Left = 312
    Top = 144
    object ActionMarkDone: TAction
      Caption = #26631#35760#24050#23436#25104'(&M)'
      OnExecute = ActionMarkDoneExecute
    end
    object ActionCopyTo: TAction
      Caption = #22797#21046#21040#23448#26041#24377#24149'(&C)'
      OnExecute = ActionCopyToExecute
    end
    object ActionDownload: TAction
      Caption = #19979#36733#21382#21490#28040#24687'(&D)'
      OnExecute = ActionDownloadExecute
    end
  end
end
