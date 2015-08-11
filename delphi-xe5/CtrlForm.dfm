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
  ClientWidth = 1054
  Color = clBtnFace
  Constraints.MaxHeight = 555
  Constraints.MaxWidth = 1070
  Constraints.MinHeight = 530
  Constraints.MinWidth = 1070
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
  object lblCallConsole: TLabel
    Left = 8
    Top = 42
    Width = 60
    Height = 17
    Caption = #21484#21796#25511#21046#21488
  end
  object grpGuestCommentSet: TGroupBox
    Left = 8
    Top = 65
    Width = 278
    Height = 81
    Caption = #32593#32476#24377#24149#40664#35748#20540
    TabOrder = 0
    object cobNetCFontColor: TShape
      Left = 201
      Top = 48
      Width = 21
      Height = 21
      Brush.Color = clGreen
      OnMouseDown = cobNetCFontColorMouseDown
    end
    object cobNetCFontName: TComboBox
      Left = 8
      Top = 18
      Width = 201
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
      Left = 221
      Top = 17
      Width = 44
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
      Left = 230
      Top = 52
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
      Left = 60
      Top = 48
      Width = 37
      Height = 25
      EditLabel.Width = 48
      EditLabel.Height = 17
      EditLabel.Caption = #26174#31034#27627#31186
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 3
      Text = '3000'
      OnChange = editStdShowTimeChange
    end
    object EdtNetDelay: TLabeledEdit
      Left = 154
      Top = 48
      Width = 41
      Height = 25
      EditLabel.Width = 48
      EditLabel.Height = 17
      EditLabel.Caption = #24310#26102#27627#31186
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 4
      Text = '2000'
      OnChange = EdtNetDelayChange
    end
  end
  object grpOfficialComment: TGroupBox
    Left = 8
    Top = 152
    Width = 281
    Height = 202
    Caption = #23448#26041#24377#24149
    TabOrder = 1
    object cobOfficialCFontColor: TShape
      Left = 216
      Top = 54
      Width = 21
      Height = 20
      Brush.Color = clNavy
      OnMouseDown = cobOfficialCFontColorMouseDown
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
      Left = 211
      Top = 138
      Width = 54
      Height = 55
      Caption = #21457#23556'(&K)'
      Default = True
      TabOrder = 8
      OnClick = btnOfficialSendClick
    end
    object grpSpecialEffects: TRadioGroup
      Left = 8
      Top = 126
      Width = 113
      Height = 73
      Caption = #25928#26524
      ItemIndex = 0
      Items.Strings = (
        #39134#34892#23383#24149'(&F)'
        #19978#26041#22266#23450'(&T)'
        #19979#26041#22266#23450'(&B)')
      TabOrder = 5
      OnClick = grpSpecialEffectsClick
    end
    object editOfficialCommentPara: TLabeledEdit
      Left = 170
      Top = 51
      Width = 25
      Height = 25
      EditLabel.Width = 39
      EditLabel.Height = 17
      EditLabel.Caption = #37325#22797'(&Y)'
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
      TabOrder = 7
    end
    object editOfficialCommentDuration: TLabeledEdit
      Left = 83
      Top = 51
      Width = 41
      Height = 25
      EditLabel.Width = 65
      EditLabel.Height = 17
      EditLabel.Caption = #20572#30041#27627#31186'(&G)'
      ImeMode = imDisable
      LabelPosition = lpLeft
      NumbersOnly = True
      TabOrder = 2
      Text = '3000'
      OnChange = editOfficialCommentDurationChange
    end
    object btnSetFixedLabel: TButton
      Left = 127
      Top = 170
      Width = 78
      Height = 25
      Caption = #26631#39064#26684#24335'(&L)'
      TabOrder = 6
      OnClick = btnSetFixedLabelClick
    end
    object btnSetLabelText: TButton
      Left = 127
      Top = 139
      Width = 78
      Height = 25
      Caption = #26631#39064#25991#23383'(&N)'
      TabOrder = 9
      OnClick = btnSetLabelTextClick
    end
  end
  object grpTiming: TRadioGroup
    Left = 1060
    Top = 401
    Width = 169
    Height = 81
    Caption = #26102#38388#36724#27169#24335
    Enabled = False
    ItemIndex = 0
    Items.Strings = (
      #23454#26102#65288#20351#29992#26412#22320#26102#38388#65289
      #23454#26102#65288#20351#29992#26381#21153#22120#26102#38388#65289
      #22238#25918#65288#20351#29992#33258#23450#20041#26102#38388#65289)
    TabOrder = 2
    OnClick = grpTimingClick
  end
  object Statusbar: TStatusBar
    Left = 0
    Top = 498
    Width = 1054
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
    TabOrder = 4
    ViewStyle = vsReport
    OnDblClick = ListCommentsDblClick
    OnKeyDown = ListCommentsKeyDown
  end
  object grpComm: TGroupBox
    Left = 8
    Top = 360
    Width = 281
    Height = 135
    Caption = #36890#20449
    TabOrder = 5
    object editNetPassword: TLabeledEdit
      Left = 138
      Top = 75
      Width = 129
      Height = 25
      EditLabel.Width = 24
      EditLabel.Height = 17
      EditLabel.Caption = #23494#30721
      LabelPosition = lpLeft
      LabelSpacing = 5
      PasswordChar = '*'
      TabOrder = 0
      OnChange = editNetPasswordChange
    end
    object editNetPort: TLabeledEdit
      Left = 138
      Top = 13
      Width = 57
      Height = 25
      EditLabel.Width = 24
      EditLabel.Height = 17
      EditLabel.Caption = #31471#21475
      ImeMode = imClose
      LabelPosition = lpLeft
      LabelSpacing = 5
      MaxLength = 5
      NumbersOnly = True
      TabOrder = 1
      OnChange = editNetPortChange
    end
    object editNetHost: TLabeledEdit
      Left = 138
      Top = 44
      Width = 129
      Height = 25
      EditLabel.Width = 24
      EditLabel.Height = 17
      EditLabel.Caption = #22320#22336
      ImeMode = imClose
      LabelPosition = lpLeft
      LabelSpacing = 5
      TabOrder = 2
    end
    object ChkAutoStartNet: TCheckBox
      Left = 138
      Top = 106
      Width = 129
      Height = 17
      Caption = #21551#21160#21518#24320#22987#36890#20449'(&A)'
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
      Height = 80
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Caption = #27169#24335
      Items.Strings = (
        '&UDP'#30417#21548
        '&HTTP'#36718#35810
        'T&CP'#36716#21457)
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
    TabOrder = 6
    OnClick = btnOpenFilterClick
  end
  object btnSaveComment: TButton
    Left = 295
    Top = 441
    Width = 75
    Height = 25
    Caption = #20445#23384#24377#24149'(&3)'
    Enabled = False
    TabOrder = 7
    OnClick = btnSaveCommentClick
  end
  object btnLoadComment: TButton
    Left = 295
    Top = 467
    Width = 75
    Height = 25
    Caption = #36733#20837#24377#24149'(&4)'
    Enabled = False
    TabOrder = 8
    OnClick = btnLoadCommentClick
  end
  object btnExit: TButton
    Left = 231
    Top = 8
    Width = 55
    Height = 25
    Caption = #36864#20986'(&Q)'
    TabOrder = 9
    OnClick = btnExitClick
  end
  object btnEscAll: TButton
    Left = 376
    Top = 441
    Width = 81
    Height = 25
    Caption = #32039#24613#23631#34109'(&E)'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = #24494#36719#38597#40657
    Font.Style = []
    ParentFont = False
    TabOrder = 10
    OnClick = btnEscAllClick
  end
  object BtnFreezing: TButton
    Left = 788
    Top = 467
    Width = 85
    Height = 25
    Hint = #24314#35758#20808#35774#23450#33258#23450#20041#26102#38388'0:0:0'#20877#24405#21046#12290
    Caption = #20923#32467#24320#20851'(&Z)'
    Enabled = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 11
    OnClick = BtnFreezingClick
  end
  object DelayProgBar: TProgressBar
    Left = 788
    Top = 444
    Width = 81
    Height = 17
    BorderWidth = 1
    Smooth = True
    TabOrder = 12
  end
  object btnClearList: TButton
    Left = 463
    Top = 441
    Width = 82
    Height = 25
    Caption = #28165#31354#21015#34920'(&P)'
    TabOrder = 13
    OnClick = btnClearListClick
  end
  object BtnLogShow: TButton
    Left = 463
    Top = 467
    Width = 82
    Height = 25
    Caption = #26174#31034#26085#24535'(&O)'
    TabOrder = 14
    OnClick = BtnLogShowClick
  end
  object BtnConfig: TButton
    Left = 551
    Top = 467
    Width = 82
    Height = 25
    Caption = #20462#25913#37197#32622'(&I)'
    TabOrder = 15
    OnClick = BtnConfigClick
  end
  object BtnReloadCfg: TButton
    Left = 551
    Top = 441
    Width = 82
    Height = 25
    Caption = #37325#36733#37197#32622'(&5)'
    TabOrder = 16
    OnClick = BtnReloadCfgClick
  end
  object StatValueList: TValueListEditor
    Left = 879
    Top = 8
    Width = 166
    Height = 484
    DisplayOptions = [doColumnTitles]
    DoubleBuffered = True
    KeyOptions = [keyUnique]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goThumbTracking]
    ParentDoubleBuffered = False
    TabOrder = 17
    TitleCaptions.Strings = (
      #32479#35745#39033
      #20540)
    ColWidths = (
      73
      87)
  end
  object EditDispatchKey: THotKey
    Left = 74
    Top = 39
    Width = 87
    Height = 24
    Cursor = crIBeam
    Hint = #38544#34255#21518#20351#29992#36825#20010#24555#25463#38190#21484#21796#25105#12290
    HotKey = 8314
    InvalidKeys = [hcNone, hcShift, hcAlt]
    Modifiers = [hkShift]
    TabOrder = 18
    OnChange = EditDispatchKeyChange
  end
  object btnCCWork: TButton
    Left = 8
    Top = 8
    Width = 90
    Height = 25
    Caption = #27979#35797#31383#21475'(&W)'
    TabOrder = 19
    OnClick = btnCCWorkClick
  end
  object btnHideCtrl: TButton
    Left = 167
    Top = 39
    Width = 58
    Height = 25
    Caption = #38544#34255'(&D)'
    TabOrder = 20
    OnClick = btnHideCtrlClick
  end
  object ButtonStartThreads: TButton
    Left = 104
    Top = 8
    Width = 57
    Height = 25
    Caption = #21551#21160'(&1)'
    TabOrder = 21
    OnClick = ButtonStartThreadsClick
  end
  object ButtonTerminateThread: TButton
    Left = 167
    Top = 8
    Width = 58
    Height = 25
    Caption = #20572#27490'(&0)'
    TabOrder = 22
    OnClick = ButtonTerminateThreadClick
  end
  object editOfficialComment: TMemo
    Left = 16
    Top = 234
    Width = 259
    Height = 42
    MaxLength = 500
    TabOrder = 23
    OnKeyPress = editOfficialCommentKeyPress
  end
  object TimerGeneral: TTimer
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
