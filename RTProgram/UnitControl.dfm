object frmControl: TfrmControl
  Left = 0
  Top = 0
  Caption = 'RT'#33410#30446#25511#21046
  ClientHeight = 451
  ClientWidth = 964
  Color = clBtnFace
  Constraints.MinHeight = 490
  Constraints.MinWidth = 980
  DoubleBuffered = True
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Meiryo'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 17
  object ListViewProgramList: TListView
    Left = 8
    Top = 8
    Width = 700
    Height = 250
    Columns = <
      item
        Caption = #29366#24577
      end
      item
        Caption = #22330#27425
        Width = 60
      end
      item
        Caption = #39034#24207
        Width = 40
      end
      item
        Caption = 'ID/'#22242#38431
        Width = 120
      end
      item
        Caption = #33410#30446#21517
      end
      item
        Caption = #26354#30446#21517
        Width = 180
      end
      item
        Caption = 'FB2K'
      end
      item
        Caption = 'MPC'
      end
      item
        Caption = 'LRC'
      end
      item
        Caption = 'LOGO'
      end>
    ColumnClick = False
    DoubleBuffered = True
    GridLines = True
    ReadOnly = True
    RowSelect = True
    ParentDoubleBuffered = False
    TabOrder = 0
    ViewStyle = vsReport
  end
  object ProgramValues: TValueListEditor
    Left = 710
    Top = 8
    Width = 248
    Height = 250
    Enabled = False
    ScrollBars = ssVertical
    TabOrder = 1
    TitleCaptions.Strings = (
      #39033#30446
      #20869#23481)
    ColWidths = (
      84
      158)
    RowHeights = (
      18
      18)
  end
  object StatusValues: TValueListEditor
    Left = 506
    Top = 265
    Width = 200
    Height = 163
    TabOrder = 2
    TitleCaptions.Strings = (
      #29366#24577
      #25968#25454)
    ColWidths = (
      82
      112)
    RowHeights = (
      18
      18)
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 432
    Width = 964
    Height = 19
    Panels = <
      item
        Text = 'JSON FILE'
        Width = 400
      end
      item
        Text = 'WORK MODE'
        Width = 150
      end
      item
        Text = 'TIME'
        Width = 50
      end>
  end
  object GroupProgramData: TGroupBox
    Left = 145
    Top = 265
    Width = 211
    Height = 53
    Caption = #33410#30446#25968#25454
    TabOrder = 4
    object BtnChooseJSON: TButton
      Left = 12
      Top = 16
      Width = 88
      Height = 25
      Action = ActionLoadJSON
      TabOrder = 0
    end
    object BtnReloadJSON: TButton
      Left = 110
      Top = 16
      Width = 87
      Height = 25
      Action = ActionReloadJSON
      Caption = #37325#36733'JS&ON'
      TabOrder = 1
    end
  end
  object GroupPlayControl: TGroupBox
    Left = 145
    Top = 320
    Width = 211
    Height = 105
    Caption = #25773#25918#25511#21046
    TabOrder = 5
    object BtnShowInfo: TButton
      Left = 11
      Top = 23
      Width = 90
      Height = 26
      Action = ActionShowInfo
      TabOrder = 0
    end
    object BtnHideInfo: TButton
      Left = 107
      Top = 23
      Width = 90
      Height = 26
      Action = ActionHideInfo
      TabOrder = 1
    end
    object BtnPlay: TButton
      Left = 11
      Top = 72
      Width = 90
      Height = 25
      Action = ActionPlay
      Default = True
      TabOrder = 2
    end
    object BtnStop: TButton
      Left = 107
      Top = 72
      Width = 90
      Height = 25
      Action = ActionStop
      Cancel = True
      Caption = #20572#27490#25773#25918'(&T)'
      TabOrder = 3
    end
    object BtnTimeMinus: TButton
      Left = 12
      Top = 46
      Width = 89
      Height = 25
      Action = ActionTimeMinus
      Caption = '&-0.1s'
      TabOrder = 4
    end
    object BtnTimePlus: TButton
      Left = 107
      Top = 46
      Width = 90
      Height = 25
      Action = ActionTimePlus
      TabOrder = 5
    end
  end
  object GroupControls: TGroupBox
    Left = 362
    Top = 265
    Width = 138
    Height = 163
    TabOrder = 6
    object BtnResetWindow: TButton
      Left = 6
      Top = 67
      Width = 129
      Height = 25
      Action = ActionResetWindow
      TabOrder = 0
    end
    object BtnResetFB2K: TButton
      Left = 6
      Top = 37
      Width = 129
      Height = 25
      Action = ActionResetFB2K
      TabOrder = 1
    end
    object BtnExit: TButton
      Left = 6
      Top = 127
      Width = 129
      Height = 25
      Action = ActionExit
      TabOrder = 2
    end
    object BtnConfig: TButton
      Left = 6
      Top = 97
      Width = 129
      Height = 25
      Action = ActionShowConfig
      TabOrder = 3
    end
    object BtnResetMPC: TButton
      Left = 6
      Top = 7
      Width = 129
      Height = 25
      Action = ActionResetMPC
      TabOrder = 4
    end
  end
  object ListSessions: TListBox
    Left = 8
    Top = 264
    Width = 128
    Height = 163
    ItemHeight = 17
    Items.Strings = (
      #20840#37096#22330#27425)
    TabOrder = 7
  end
  object MemoLog: TMemo
    Left = 710
    Top = 265
    Width = 248
    Height = 163
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 8
  end
  object TCPServer: TIdCmdTCPServer
    Bindings = <>
    DefaultPort = 0
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '200'
    Greeting.Text.Strings = (
      'Welcome')
    HelpReply.Code = '100'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '400'
    ReplyUnknownCommand.Text.Strings = (
      'Unknown Command')
    Left = 8
    Top = 32
  end
  object ActionList: TActionList
    Left = 120
    Top = 32
    object ActionLoadJSON: TAction
      Caption = #21152#36733'&JSON'
      OnExecute = ActionLoadJSONExecute
    end
    object ActionReloadJSON: TAction
      Caption = 'Action1'
      OnExecute = ActionReloadJSONExecute
    end
    object ActionShowInfo: TAction
      Caption = #26174#31034#20449#24687'(&I)'
      OnExecute = ActionShowInfoExecute
    end
    object ActionHideInfo: TAction
      Caption = #20851#38381#20449#24687'(&C)'
    end
    object ActionPlay: TAction
      Caption = #27491#24335#25773#25918'(&P)'
    end
    object ActionStop: TAction
      Caption = 'Action1'
    end
    object ActionResetMPC: TAction
      Caption = #37325#32622'&MPC'
    end
    object ActionResetFB2K: TAction
      Caption = #37325#32622'&FB2K'
    end
    object ActionResetWindow: TAction
      Caption = #37325#32622#31383#21475'(&W)'
    end
    object ActionShowConfig: TAction
      Caption = #37197#32622'(&N)'
      OnExecute = ActionShowConfigExecute
    end
    object ActionExit: TAction
      Caption = #36864#20986'(&X)'
    end
    object ActionTimeMinus: TAction
      Caption = '-0.1s'
    end
    object ActionTimePlus: TAction
      Caption = '&+0.1s'
    end
  end
  object OpenFile: TOpenTextFileDialog
    Filter = 'JSON File|*.json'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Title = #36873#25321#33410#30446#34920'JSON'#25991#20214
    Encodings.Strings = (
      'ASCII'
      'UTF-8')
    EncodingIndex = 1
    Left = 64
    Top = 32
  end
  object TimerSecond: TTimer
    OnTimer = TimerSecondTimer
    Left = 176
    Top = 32
  end
end
