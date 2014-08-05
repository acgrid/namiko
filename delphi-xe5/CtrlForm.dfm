object frmControl: TfrmControl
  Left = 74
  Top = 452
  Width = 1180
  Height = 530
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 
    'Namiko '#23454#26102#24377#24149#26700#38754#31471' for CQU 2011 [RC233] ANSI-Unicode Hybird Hexied V' +
    'ersion'
  Color = clBtnFace
  Constraints.MaxHeight = 530
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
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 17
  object DelayLabel: TTntLabel
    Left = 1032
    Top = 8
    Width = 18
    Height = 17
    Caption = 'XD'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = #24494#36719#38597#40657
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
  end
  object grpCCWindow: TTntGroupBox
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
    object btnCCWork: TTntButton
      Left = 84
      Top = 21
      Width = 121
      Height = 25
      Caption = #36827#20837#36816#20316#27169#24335'(&W)'
      TabOrder = 0
      OnClick = btnCCWorkClick
    end
    object btnCCShow: TButton
      Left = 5
      Top = 21
      Width = 75
      Height = 25
      Caption = #26174#31034'(&S)'
      TabOrder = 1
      OnClick = btnCCShowClick
    end
    object btnAdmin: TButton
      Left = 210
      Top = 21
      Width = 57
      Height = 25
      Caption = '&Admin'
      TabOrder = 2
      OnClick = btnAdminClick
    end
    object EditDispatchKey: THotKey
      Left = 85
      Top = 54
      Width = 121
      Height = 24
      Cursor = crIBeam
      Hint = #38544#34255#21518#20351#29992#36825#20010#24555#25463#38190#21484#21796#25105#12290
      HotKey = 8314
      InvalidKeys = [hcNone, hcShift, hcAlt]
      Modifiers = [hkShift]
      TabOrder = 3
      OnChange = EditDispatchKeyChange
    end
    object btnHideCtrl: TTntButton
      Left = 210
      Top = 53
      Width = 57
      Height = 21
      Caption = #38544#34255'(&D)'
      TabOrder = 4
      OnClick = btnHideCtrlClick
    end
  end
  object grpGuestCommentSet: TTntGroupBox
    Left = 8
    Top = 88
    Width = 281
    Height = 49
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
    object cobNetCFontName: TTntComboBox
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
      ItemHeight = 16
      ParentFont = False
      TabOrder = 0
      OnChange = cobNetCFontNameChange
    end
    object cobNetCFontSize: TTntComboBox
      Left = 168
      Top = 17
      Width = 42
      Height = 25
      ItemHeight = 17
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
    object cobNetCFontBold: TTntCheckBox
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
  end
  object grpOfficialComment: TTntGroupBox
    Left = 8
    Top = 144
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
    object editOfficialComment: TTntEdit
      Left = 8
      Top = 80
      Width = 257
      Height = 25
      TabOrder = 5
    end
    object cobOfficialCFontName: TTntComboBox
      Left = 8
      Top = 21
      Width = 201
      Height = 25
      Style = csDropDownList
      ItemHeight = 17
      TabOrder = 0
      OnChange = cobOfficialCFontNameChange
    end
    object btnOfficialSend: TTntButton
      Left = 168
      Top = 144
      Width = 97
      Height = 25
      Caption = #21457#23556'(&K)'
      Default = True
      TabOrder = 9
      OnClick = btnOfficialSendClick
    end
    object grpSpecialEffects: TTntRadioGroup
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
      TabOrder = 3
      Text = '1'
    end
    object cobOfficialCFontSize: TTntComboBox
      Left = 216
      Top = 21
      Width = 49
      Height = 25
      ItemHeight = 17
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
    object cobOfficialCFontBold: TTntCheckBox
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
    object editOfficialCommentParaUpDown: TTntUpDown
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
      EditLabel.Width = 48
      EditLabel.Height = 17
      EditLabel.Caption = #26174#31034#26102#38388
      ImeMode = imDisable
      LabelPosition = lpLeft
      TabOrder = 2
      Text = '3000'
    end
    object editOfficialCommentDurationUpDown: TTntUpDown
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
      Left = 168
      Top = 112
      Width = 97
      Height = 25
      Caption = #35774#23450#26631#39064'(&L)'
      TabOrder = 7
      OnClick = btnSetFixedLabelClick
    end
  end
  object grpTiming: TTntRadioGroup
    Left = 856
    Top = 8
    Width = 169
    Height = 81
    Caption = #26102#38388#36724#27169#24335
    ItemIndex = 0
    Items.Strings = (
      #23454#26102#65288#20351#29992#31995#32479#26102#38388#65289
      #23454#26102#65288#20351#29992#26381#21153#22120#26102#38388#65289
      #22238#25918#65288#20351#29992#33258#23450#20041#26102#38388#65289)
    TabOrder = 3
    OnClick = grpTimingClick
  end
  object Statusbar: TTntStatusBar
    Left = 0
    Top = 473
    Width = 1164
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
        Width = 110
      end
      item
        Width = 110
      end
      item
        Width = 110
      end>
  end
  object ListComments: TTntListView
    Left = 296
    Top = 8
    Width = 553
    Height = 425
    Columns = <
      item
        Caption = '?'
        Width = 25
      end
      item
        Caption = #26412#22320#26102#38388
        Width = 60
      end
      item
        Caption = #36828#31243#26102#38388
        Width = 90
      end
      item
        Caption = #20869#23481
        Width = 100
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
      end
      item
        AutoSize = True
        Caption = #25968#25454
      end>
    FlatScrollBars = True
    GridLines = True
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 5
    ViewStyle = vsReport
    OnChange = ListCommentsChange
    OnChanging = ListCommentsChanging
    OnDblClick = ListCommentsDblClick
    OnKeyDown = ListCommentsKeyDown
  end
  object grpComm: TTntGroupBox
    Left = 8
    Top = 336
    Width = 281
    Height = 129
    Caption = #36890#20449#35774#23450
    TabOrder = 6
    object radioNetPasv: TTntRadioButton
      Left = 8
      Top = 20
      Width = 73
      Height = 17
      Caption = #34987#21160#27169#24335
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = radioNetPasvClick
    end
    object radioNetPort: TTntRadioButton
      Left = 8
      Top = 38
      Width = 73
      Height = 17
      Caption = #20027#21160#27169#24335
      TabOrder = 1
      OnClick = radioNetPortClick
    end
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
      TabOrder = 2
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
      TabOrder = 3
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
      Enabled = False
      ImeMode = imClose
      LabelPosition = lpLeft
      TabOrder = 4
    end
    object ChkAutoStartNet: TTntCheckBox
      Left = 145
      Top = 105
      Width = 129
      Height = 17
      Caption = #21551#21160#21518#24320#22987#36890#20449'(&C)'
      TabOrder = 5
    end
    object radioNetTransmit: TTntRadioButton
      Left = 8
      Top = 56
      Width = 73
      Height = 17
      Caption = #20013#32487#27169#24335
      TabOrder = 6
      OnClick = radioNetTransmitClick
    end
    object btnNetStart: TTntButton
      Left = 8
      Top = 97
      Width = 89
      Height = 24
      Caption = #24320#22987#36890#20449'(&M)'
      TabOrder = 7
      OnClick = btnNetStartClick
    end
  end
  object btnOpenFilter: TButton
    Left = 456
    Top = 440
    Width = 89
    Height = 25
    Caption = #20851#38190#23383#36807#28388'(&X)'
    TabOrder = 7
    OnClick = btnOpenFilterClick
  end
  object btnSaveComment: TButton
    Left = 296
    Top = 440
    Width = 75
    Height = 25
    Caption = #20445#23384#24377#24149'(&Y)'
    TabOrder = 8
    OnClick = btnSaveCommentClick
  end
  object btnLoadComment: TButton
    Left = 376
    Top = 440
    Width = 75
    Height = 25
    Caption = #36733#20837#24377#24149'(&Z)'
    TabOrder = 9
    OnClick = btnLoadCommentClick
  end
  object grpDebug: TGroupBox
    Left = 856
    Top = 344
    Width = 297
    Height = 121
    Caption = 'Debug Tools (Be Careful)'
    TabOrder = 10
    object editStdShowTime: TLabeledEdit
      Left = 208
      Top = 88
      Width = 37
      Height = 25
      EditLabel.Width = 72
      EditLabel.Height = 17
      EditLabel.Caption = #32593#32476#24377#24149#29992#26102
      LabelPosition = lpLeft
      TabOrder = 0
      Text = '3000'
      OnChange = editStdShowTimeChange
    end
    object editTimingInv: TLabeledEdit
      Left = 88
      Top = 88
      Width = 25
      Height = 25
      EditLabel.Width = 72
      EditLabel.Height = 17
      EditLabel.Caption = #39134#34892#31227#21160#38388#38548
      LabelPosition = lpLeft
      TabOrder = 1
      Text = '50'
      OnChange = editTimingInvChange
    end
    object editTimingInvUpDown: TTntUpDown
      Left = 113
      Top = 88
      Width = 16
      Height = 25
      Associate = editTimingInv
      Increment = 5
      Position = 50
      TabOrder = 2
    end
    object EditStdShowTimeUpDown: TTntUpDown
      Left = 245
      Top = 88
      Width = 17
      Height = 25
      Associate = editStdShowTime
      Min = 1000
      Max = 8000
      Increment = 200
      Position = 3000
      TabOrder = 3
      Thousands = False
    end
    object btnClearList: TTntButton
      Left = 8
      Top = 56
      Width = 89
      Height = 25
      Caption = #28165#31354#21015#34920'(&J)'
      TabOrder = 4
      OnClick = btnClearListClick
    end
    object btnExControl: TButton
      Left = 8
      Top = 24
      Width = 89
      Height = 25
      Caption = #25511#20214#20493#22686'(&C)'
      TabOrder = 5
      OnClick = btnExControlClick
    end
    object Button1: TButton
      Left = 104
      Top = 24
      Width = 89
      Height = 25
      Caption = #27979#35797'HTTP'
      TabOrder = 6
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 208
      Top = 24
      Width = 81
      Height = 25
      Caption = #26029#24320'TCP'
      Enabled = False
      TabOrder = 7
      OnClick = Button2Click
    end
    object EditFetchInv: TLabeledEdit
      Left = 208
      Top = 56
      Width = 41
      Height = 25
      EditLabel.Width = 96
      EditLabel.Height = 17
      EditLabel.Caption = #20027#21160#27169#24335#26816#27979#38388#38548
      LabelPosition = lpLeft
      TabOrder = 8
      Text = '1000'
      OnChange = EditFetchInvChange
    end
    object EditFetchInvUpDown: TUpDown
      Left = 249
      Top = 56
      Width = 17
      Height = 25
      Associate = EditFetchInv
      Min = 300
      Max = 5000
      Increment = 100
      Position = 1000
      TabOrder = 9
      Thousands = False
    end
  end
  object Log: TTntMemo
    Left = 856
    Top = 96
    Width = 297
    Height = 241
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 11
  end
  object btnExit: TTntButton
    Left = 784
    Top = 440
    Width = 65
    Height = 25
    Caption = #36864#20986'(&E)'
    TabOrder = 12
    OnClick = btnExitClick
  end
  object btnEscAll: TTntButton
    Left = 552
    Top = 440
    Width = 97
    Height = 25
    Caption = #32039#24613#27827#34809#19968#20999'(&N)'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = #24494#36719#38597#40657
    Font.Style = []
    ParentFont = False
    TabOrder = 13
    OnClick = btnEscAllClick
  end
  object BtnFreezing: TTntButton
    Left = 1032
    Top = 64
    Width = 121
    Height = 25
    Hint = #24314#35758#20808#35774#23450#33258#23450#20041#26102#38388'0:0:0'#20877#24405#21046#12290
    Caption = #20923#32467#24320#20851'(&V)'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 14
    OnClick = BtnFreezingClick
  end
  object DelayProgBar: TTntProgressBar
    Left = 1032
    Top = 32
    Width = 121
    Height = 17
    BorderWidth = 1
    Smooth = True
    TabOrder = 15
  end
  object EdtNetDelay: TLabeledEdit
    Left = 728
    Top = 440
    Width = 41
    Height = 25
    EditLabel.Width = 73
    EditLabel.Height = 17
    EditLabel.Caption = #24378#21046#24310#26102'(ms)'
    LabelPosition = lpLeft
    TabOrder = 16
    Text = '5000'
  end
  object TimerGeneral: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerGeneralTimer
    Left = 312
    Top = 40
  end
  object ColorDialog: TColorDialog
    Left = 312
    Top = 72
  end
  object SaveDialog: TTntSaveDialog
    DefaultExt = 'xml'
    Filter = #24377#24149#25968#25454'(*.xml)|*.xml'
    Title = #35760#24405#40657#21382#21490
    Left = 344
    Top = 72
  end
  object HTTPClient: TIdHTTP
    Intercept = HTTPLog
    AllowCookies = False
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.ContentType = 'text/html'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 312
    Top = 104
  end
  object InSocket: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    Intercept = TCPLogFile
    ListenQueue = 200
    OnConnect = InSocketConnect
    OnExecute = InSocketExecute
    Left = 344
    Top = 104
  end
  object TCPLogFile: TIdServerInterceptLogFile
    Left = 344
    Top = 136
  end
  object TimerFetch: TTimer
    Enabled = False
    OnTimer = TimerFetchTimer
    Left = 344
    Top = 40
  end
  object TimerAddComment: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerAddCommentTimer
    Left = 376
    Top = 40
  end
  object HTTPLog: TIdLogFile
    Left = 312
    Top = 136
  end
  object TimerUpdate: TTimer
    Interval = 10
    OnTimer = TimerUpdateTimer
    Left = 408
    Top = 40
  end
end
