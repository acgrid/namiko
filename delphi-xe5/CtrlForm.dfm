object frmControl: TfrmControl
  Left = 74
  Top = 452
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 
    'Namiko Danmaku Client [Unicode GDI+ UDP/HTTP PCRE Multi-threaded' +
    ']'
  ClientHeight = 517
  ClientWidth = 1053
  Color = clBtnFace
  Constraints.MaxHeight = 555
  Constraints.MaxWidth = 1180
  Constraints.MinHeight = 530
  Constraints.MinWidth = 870
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #24494#36719#38597#40657
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 17
  object grpCCWindow: TGroupBox
    Left = 8
    Top = 0
    Width = 281
    Height = 86
    Caption = #31383#21475#25511#21046
    TabOrder = 0
    object lblCallConsole: TLabel
      Left = 7
      Top = 56
      Width = 72
      Height = 17
      Caption = #25511#21046#21488#21484#21796#38190
    end
    object btnCCWork: TButton
      Left = 7
      Top = 24
      Width = 107
      Height = 25
      Caption = #27979#35797#31383#21475'(&W)'
      TabOrder = 0
      OnClick = btnCCWorkClick
    end
    object EditDispatchKey: THotKey
      Left = 85
      Top = 54
      Width = 111
      Height = 24
      Cursor = crIBeam
      Hint = #38544#34255#21518#20351#29992#36825#20010#24555#25463#38190#21484#21796#25105#12290
      HotKey = 8314
      InvalidKeys = [hcNone, hcShift, hcAlt]
      Modifiers = [hkShift]
      TabOrder = 1
      OnChange = EditDispatchKeyChange
    end
    object btnHideCtrl: TButton
      Left = 202
      Top = 53
      Width = 76
      Height = 25
      Caption = #38544#34255'(&D)'
      TabOrder = 2
      OnClick = btnHideCtrlClick
    end
  end
  object grpGuestCommentSet: TGroupBox
    Left = 9
    Top = 88
    Width = 281
    Height = 81
    Caption = #32593#32476#24377#24149#40664#35748#20540
    TabOrder = 1
    object cobNetCFontColor: TShape
      Left = 216
      Top = 18
      Width = 21
      Height = 21
      Brush.Color = clGreen
      OnMouseDown = cobNetCFontColorMouseDown
    end
    object cobNetCFontName: TComboBox
      Left = 8
      Top = 18
      Width = 153
      Height = 24
      Style = csDropDownList
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnChange = cobNetCFontNameChange
    end
    object cobNetCFontSize: TComboBox
      Left = 168
      Top = 17
      Width = 42
      Height = 25
      ItemIndex = 6
      TabOrder = 1
      Text = '18'
      OnChange = cobNetCFontSizeChange
      OnKeyPress = cobNetCFontSizeKeyPress
      Items.Strings = (
        '9'
        '10'
        '11'
        '12'
        '14'
        '16'
        '18'
        '20'
        '22'
        '24'
        '26'
        '28'
        '36'
        '40'
        '48'
        '50')
    end
    object cobNetCFontBold: TCheckBox
      Left = 241
      Top = 22
      Width = 35
      Height = 15
      Caption = #31895
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #24494#36719#38597#40657
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = cobNetCFontBoldClick
    end
    object editStdShowTime: TLabeledEdit
      Left = 83
      Top = 48
      Width = 37
      Height = 25
      EditLabel.Width = 73
      EditLabel.Height = 17
      EditLabel.Caption = #26174#31034#26102#38388'(ms)'
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 3
      Text = '3000'
      OnChange = editStdShowTimeChange
    end
    object EditStdShowTimeUpDown: TUpDown
      Left = 120
      Top = 48
      Width = 17
      Height = 25
      Associate = editStdShowTime
      Min = 1000
      Max = 8000
      Increment = 200
      Position = 3000
      TabOrder = 4
      Thousands = False
    end
    object EdtNetDelay: TLabeledEdit
      Left = 226
      Top = 48
      Width = 41
      Height = 25
      EditLabel.Width = 73
      EditLabel.Height = 17
      EditLabel.Caption = #24378#21046#24310#26102'(ms)'
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 5
      Text = '2000'
      OnChange = EdtNetDelayChange
    end
  end
  object grpOfficialComment: TGroupBox
    Left = 8
    Top = 175
    Width = 281
    Height = 185
    Caption = #23448#26041#24377#24149
    TabOrder = 2
    object cobOfficialCFontColor: TShape
      Left = 216
      Top = 54
      Width = 21
      Height = 20
      Brush.Color = clNavy
      OnMouseDown = cobOfficialCFontColorMouseDown
    end
    object editOfficialComment: TEdit
      Left = 8
      Top = 80
      Width = 257
      Height = 25
      TabOrder = 5
    end
    object cobOfficialCFontName: TComboBox
      Left = 8
      Top = 21
      Width = 201
      Height = 25
      Style = csDropDownList
      TabOrder = 0
      OnChange = cobOfficialCFontNameChange
    end
    object btnOfficialSend: TButton
      Left = 170
      Top = 150
      Width = 97
      Height = 25
      Caption = #21457#23556'(&K)'
      Default = True
      TabOrder = 9
      OnClick = btnOfficialSendClick
    end
    object grpSpecialEffects: TRadioGroup
      Left = 8
      Top = 104
      Width = 145
      Height = 73
      Caption = #25928#26524
      ItemIndex = 0
      Items.Strings = (
        #39134#34892#23383#24149'(&G)'
        #19978#26041#22266#23450'(&F)'
        #19979#26041#22266#23450'(&R)')
      TabOrder = 6
      OnClick = grpSpecialEffectsClick
    end
    object editOfficialCommentPara: TLabeledEdit
      Left = 168
      Top = 51
      Width = 25
      Height = 25
      EditLabel.Width = 48
      EditLabel.Height = 17
      EditLabel.Caption = #37325#22797#27425#25968
      ImeMode = imDisable
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 3
      Text = '1'
    end
    object cobOfficialCFontSize: TComboBox
      Left = 216
      Top = 21
      Width = 49
      Height = 25
      ItemIndex = 10
      TabOrder = 1
      Text = '26'
      OnChange = cobOfficialCFontSizeChange
      OnKeyPress = cobOfficialCFontSizeKeyPress
      Items.Strings = (
        '9'
        '10'
        '11'
        '12'
        '14'
        '16'
        '18'
        '20'
        '22'
        '24'
        '26'
        '28'
        '36'
        '40'
        '48'
        '50')
    end
    object cobOfficialCFontBold: TCheckBox
      Left = 241
      Top = 58
      Width = 35
      Height = 15
      Caption = #31895
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #24494#36719#38597#40657
      Font.Style = [fsBold]
      ParentFont = False
      State = cbChecked
      TabOrder = 4
      OnClick = cobOfficialCFontBoldClick
    end
    object editOfficialCommentParaUpDown: TUpDown
      Left = 193
      Top = 51
      Width = 16
      Height = 25
      Associate = editOfficialCommentPara
      Position = 1
      TabOrder = 8
    end
    object editOfficialCommentDuration: TLabeledEdit
      Left = 56
      Top = 51
      Width = 41
      Height = 25
      EditLabel.Width = 49
      EditLabel.Height = 17
      EditLabel.Caption = #26102#38388'(ms)'
      ImeMode = imDisable
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 2
      Text = '3000'
    end
    object editOfficialCommentDurationUpDown: TUpDown
      Left = 97
      Top = 51
      Width = 17
      Height = 25
      Associate = editOfficialCommentDuration
      Min = 1000
      Max = 10000
      Increment = 100
      Position = 3000
      TabOrder = 10
      Thousands = False
    end
    object btnSetFixedLabel: TButton
      Left = 170
      Top = 119
      Width = 97
      Height = 25
      Caption = #35774#23450#26631#39064'(&L)'
      TabOrder = 7
      OnClick = btnSetFixedLabelClick
    end
  end
  object grpTiming: TRadioGroup
    Left = 879
    Top = 411
    Width = 169
    Height = 81
    Caption = #26102#38388#36724#27169#24335
    Enabled = False
    ItemIndex = 0
    Items.Strings = (
      #23454#26102#65288#20351#29992#26412#22320#26102#38388#65289
      #23454#26102#65288#20351#29992#26381#21153#22120#26102#38388#65289
      #22238#25918#65288#20351#29992#33258#23450#20041#26102#38388#65289)
    TabOrder = 3
    OnClick = grpTimingClick
  end
  object Statusbar: TStatusBar
    Left = 0
    Top = 498
    Width = 1053
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 110
      end
      item
        Width = 170
      end
      item
        Width = 100
      end
      item
        Width = 100
      end
      item
        Width = 100
      end>
  end
  object ListComments: TListView
    Left = 292
    Top = 8
    Width = 577
    Height = 427
    Columns = <
      item
        Caption = 'Q'
        Width = 25
      end
      item
        Caption = 'ID'
        Width = 30
      end
      item
        Caption = #26412#22320#26102#38388
        Width = 90
      end
      item
        Caption = #20869#23481
        Width = 150
      end
      item
        Caption = #26469#28304
        Width = 80
      end
      item
        Caption = #26684#24335
        Width = 60
      end
      item
        AutoSize = True
        Caption = #27169#24335
      end
      item
        AutoSize = True
        Caption = #37325#22797
      end
      item
        AutoSize = True
        Caption = #29992#26102
      end>
    DoubleBuffered = True
    FlatScrollBars = True
    GridLines = True
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    ParentDoubleBuffered = False
    TabOrder = 5
    ViewStyle = vsReport
    OnDblClick = ListCommentsDblClick
    OnKeyDown = ListCommentsKeyDown
  end
  object grpComm: TGroupBox
    Left = 8
    Top = 360
    Width = 281
    Height = 135
    Caption = #36890#20449#35774#23450
    TabOrder = 6
    object editNetPassword: TLabeledEdit
      Left = 144
      Top = 75
      Width = 129
      Height = 25
      EditLabel.Width = 40
      EditLabel.Height = 17
      EditLabel.Caption = #23494#30721'(&B)'
      LabelPosition = lpLeft
      PasswordChar = '*'
      TabOrder = 0
      OnChange = editNetPasswordChange
    end
    object editNetPort: TLabeledEdit
      Left = 144
      Top = 14
      Width = 57
      Height = 25
      EditLabel.Width = 39
      EditLabel.Height = 17
      EditLabel.Caption = #31471#21475'(&P)'
      ImeMode = imClose
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 1
      OnChange = editNetPortChange
    end
    object editNetHost: TLabeledEdit
      Left = 144
      Top = 44
      Width = 129
      Height = 25
      EditLabel.Width = 41
      EditLabel.Height = 17
      EditLabel.Caption = #22320#22336'(&U)'
      ImeMode = imClose
      LabelPosition = lpLeft
      TabOrder = 2
    end
    object ChkAutoStartNet: TCheckBox
      Left = 145
      Top = 105
      Width = 129
      Height = 17
      Caption = #21551#21160#21518#24320#22987#36890#20449'(&C)'
      TabOrder = 3
    end
    object btnNetStart: TButton
      Left = 8
      Top = 102
      Width = 89
      Height = 24
      Caption = #24320#22987#36890#20449'(&M)'
      TabOrder = 4
      OnClick = btnNetStartClick
    end
    object RadioGroupModes: TRadioGroup
      Left = 7
      Top = 18
      Width = 88
      Height = 81
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Caption = #27169#24335
      Items.Strings = (
        'U&DP'#30417#21548
        'HTTP'#36718#35810
        'TCP'#36716#21457)
      TabOrder = 5
      OnClick = RadioGroupModesClick
    end
  end
  object btnOpenFilter: TButton
    Left = 376
    Top = 467
    Width = 81
    Height = 25
    Caption = #36807#28388#21015#34920'(&X)'
    TabOrder = 7
    OnClick = btnOpenFilterClick
  end
  object btnSaveComment: TButton
    Left = 295
    Top = 441
    Width = 75
    Height = 25
    Caption = #20445#23384#24377#24149'(&Y)'
    Enabled = False
    TabOrder = 8
    OnClick = btnSaveCommentClick
  end
  object btnLoadComment: TButton
    Left = 295
    Top = 467
    Width = 75
    Height = 25
    Caption = #36733#20837#24377#24149'(&Z)'
    Enabled = False
    TabOrder = 9
    OnClick = btnLoadCommentClick
  end
  object btnExit: TButton
    Left = 808
    Top = 467
    Width = 65
    Height = 25
    Caption = #36864#20986'(&E)'
    TabOrder = 10
    OnClick = btnExitClick
  end
  object btnEscAll: TButton
    Left = 376
    Top = 441
    Width = 81
    Height = 25
    Caption = #32039#24613#27827#34809'(&N)'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = #24494#36719#38597#40657
    Font.Style = []
    ParentFont = False
    TabOrder = 11
  end
  object BtnFreezing: TButton
    Left = 967
    Top = 388
    Width = 80
    Height = 25
    Hint = #24314#35758#20808#35774#23450#33258#23450#20041#26102#38388'0:0:0'#20877#24405#21046#12290
    Caption = #20923#32467#24320#20851'(&V)'
    Enabled = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 12
    OnClick = BtnFreezingClick
  end
  object DelayProgBar: TProgressBar
    Left = 879
    Top = 392
    Width = 81
    Height = 17
    BorderWidth = 1
    Smooth = True
    TabOrder = 13
  end
  object btnClearList: TButton
    Left = 463
    Top = 441
    Width = 82
    Height = 25
    Caption = #28165#31354#21015#34920'(&J)'
    TabOrder = 14
    OnClick = btnClearListClick
  end
  object ButtonStartThreads: TButton
    Left = 129
    Top = 24
    Width = 75
    Height = 25
    Caption = #21551#21160#32447#31243
    TabOrder = 15
    OnClick = ButtonStartThreadsClick
  end
  object ButtonTerminateThread: TButton
    Left = 210
    Top = 24
    Width = 75
    Height = 25
    Caption = #20572#27490#32447#31243
    TabOrder = 16
    OnClick = ButtonTerminateThreadClick
  end
  object BtnLogShow: TButton
    Left = 463
    Top = 467
    Width = 82
    Height = 25
    Caption = #26174#31034#26085#24535'(&R)'
    TabOrder = 17
    OnClick = BtnLogShowClick
  end
  object BtnConfig: TButton
    Left = 551
    Top = 467
    Width = 82
    Height = 25
    Caption = #20462#25913#37197#32622
    TabOrder = 18
    OnClick = BtnConfigClick
  end
  object BtnReloadCfg: TButton
    Left = 551
    Top = 441
    Width = 82
    Height = 25
    Caption = #37325#36733#37197#32622
    TabOrder = 19
    OnClick = BtnReloadCfgClick
  end
  object StatValueList: TValueListEditor
    Left = 879
    Top = 8
    Width = 166
    Height = 374
    DisplayOptions = [doColumnTitles]
    DoubleBuffered = True
    KeyOptions = [keyUnique]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goThumbTracking]
    ParentDoubleBuffered = False
    TabOrder = 20
    TitleCaptions.Strings = (
      #32479#35745#39033
      #20540)
    ColWidths = (
      96
      64)
  end
  object TimerGeneral: TTimer
    Interval = 500
    OnTimer = TimerGeneralTimer
    Left = 312
    Top = 32
  end
  object ColorDialog: TColorDialog
    Left = 312
    Top = 72
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'xml'
    Filter = #24377#24149#25968#25454'(*.xml)|*.xml'
    Title = #35760#24405#40657#21382#21490
    Left = 352
    Top = 72
  end
  object IdUDPServerCCRecv: TIdUDPServer
    Bindings = <>
    DefaultPort = 0
    Left = 312
    Top = 120
  end
end
