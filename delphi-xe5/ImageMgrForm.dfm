object frmImageManager: TfrmImageManager
  Left = 0
  Top = 0
  Caption = #22270#20687#26597#35810
  ClientHeight = 302
  ClientWidth = 804
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object ImagePreview: TImage
    Left = 465
    Top = 8
    Width = 333
    Height = 250
    Center = True
  end
  object ImagesListView: TListView
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
        AutoSize = True
        Caption = #25509#25910#26102#38388
      end
      item
        Caption = #21457#36865'ID'
      end
      item
        Caption = #29992#25143#32452
      end
      item
        Caption = #32626#21517
      end
      item
        AutoSize = True
        Caption = #23610#23544
      end
      item
        Caption = #19979#36733
      end
      item
        Caption = #26174#31034
      end
      item
        Caption = #19978#25253
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenuImg
    TabOrder = 0
    ViewStyle = vsReport
    OnContextPopup = ImagesListViewContextPopup
    OnSelectItem = ImagesListViewSelectItem
  end
  object GroupButtons: TGroupBox
    Left = 8
    Top = 260
    Width = 577
    Height = 41
    TabOrder = 1
    object BtnClearCommitted: TButton
      Left = 304
      Top = 9
      Width = 113
      Height = 25
      Action = ActionRemoveCommitted
      TabOrder = 0
    end
    object BtnCommitDisplayed: TButton
      Left = 151
      Top = 9
      Width = 113
      Height = 25
      Action = ActionCommitDisplayed
      TabOrder = 1
    end
    object BtnDownloadAll: TButton
      Left = 9
      Top = 9
      Width = 113
      Height = 25
      Action = ActionDownloadAll
      TabOrder = 2
    end
  end
  object Button1: TButton
    Left = 721
    Top = 269
    Width = 75
    Height = 25
    Caption = 'Local Test'
    TabOrder = 2
    OnClick = Button1Click
  end
  object PopupMenuImg: TPopupMenu
    Left = 376
    Top = 160
    object D1: TMenuItem
      Action = ActionDownload
    end
    object P1: TMenuItem
      Action = ActionDisplay
    end
    object U1: TMenuItem
      Action = ActionCommit
    end
    object X1: TMenuItem
      Action = ActionDiscard
    end
    object R1: TMenuItem
      Action = ActionRemove
    end
  end
  object ActionList: TActionList
    Left = 520
    Top = 104
    object ActionLoadListOK: TAction
      Caption = 'Callback for Fetch Images List'
      OnExecute = ActionLoadListOKExecute
    end
    object ActionDownloadAll: TAction
      Caption = #19979#36733#21382#21490#22270#29255'(&D)'
      OnExecute = ActionDownloadAllExecute
    end
    object ActionDownload: TAction
      Caption = #19979#36733#27492#22270'(&D)'
      OnExecute = ActionDownloadExecute
    end
    object ActionDisplay: TAction
      Caption = #26174#31034#27492#22270'(&P)'
      OnExecute = ActionDisplayExecute
    end
    object ActionCommit: TAction
      Caption = #19978#25253#25104#21151#26174#31034'(&U)'
      OnExecute = ActionCommitExecute
    end
    object ActionDiscard: TAction
      Caption = #19978#25253#19981#20104#26174#31034'(&X)'
      OnExecute = ActionDiscardExecute
    end
    object ActionRemove: TAction
      Caption = #20174#26412#22320#21015#34920#28165#38500'(&R)'
      OnExecute = ActionRemoveExecute
    end
    object ActionCommitDisplayed: TAction
      Caption = #19978#25253#20840#37096#24050#26174#31034'(&C)'
      OnExecute = ActionCommitDisplayedExecute
    end
    object ActionRemoveCommitted: TAction
      Caption = #28165#38500#20840#37096#24050#19978#25253'(&R)'
      OnExecute = ActionRemoveCommittedExecute
    end
  end
end
