unit CtrlForm;

interface

uses
  Winapi.Windows, Winapi.Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls,
  Menus, Math, SyncObjs, System.Generics.Collections,
  XMLDoc, XMLIntf,
  IdContext, IdIntercept, IdServerInterceptLogBase, IdServerInterceptLogFile,
  Dialogs, System.UITypes,
  IdSocketHandle, IdGlobal,
  StrUtils, DateUtils,
  ShellAPI, ActiveX, IdExceptionCore, IdUDPBase, IdUDPServer,
  System.UIConsts, System.Types, IdComponent, IdBaseComponent,
  Vcl.Grids, Vcl.ValEdit, NamikoTypes,
  UDPHandleThread, RenderThread, UpdateThread, DispatchThread, HTTPWorker,
  LogForm, CfgForm;

const
  NamikoTrayMessage = WM_USER + 233;

  KEY = 'saf32459090sua0fj23jnroiahfaj23-ir512nmrpaf314';

  L_Console = '控制台';
  L_XMLFile = '文件';
  DET = #9+#9;
  CRLF = #13+#10;

  T_ID = 0;
  T_LTIME = 1;
  //T_RTIME = 1;
  T_TEXT = 2;
  T_SRC = 3;
  T_FORMAT = 4;
  T_DISP = 5;
  T_CYCLE = 6;
  T_OCTIME = 7;
  //T_STATUS = 8;

  SW_BANNED = 128;
  SW_CONSOLE = 64;
  SW_EFFECT = 56;
  SW_E_UFIXED = 16;
  SW_E_DFIXED = 24;
  SW_E_FLYING = 32;
  SW_STATUS = 7;
  SW_S_INIT = 1;
  SW_S_PROC = 2;
  SW_S_WAIT = 3;
  SW_S_DISP = 4;
  SW_S_DONE = 7;

  //DEFAULT_BORDER_WIDTH = 2;
  //DEFAULT_BORDER_COLOR = $FF000000; // Pure Black

type
  TfrmControl = class(TForm)
    grpCCWindow: TGroupBox;
    btnCCWork: TButton;
    TimerGeneral: TTimer;
    grpGuestCommentSet: TGroupBox;
    grpOfficialComment: TGroupBox;
    editOfficialComment: TEdit;
    cobNetCFontName: TComboBox;
    cobOfficialCFontName: TComboBox;
    btnOfficialSend: TButton;
    grpSpecialEffects: TRadioGroup;
    editOfficialCommentPara: TLabeledEdit;
    grpTiming: TRadioGroup;
    Statusbar: TStatusBar;
    ListComments: TListView;
    grpComm: TGroupBox;
    editNetPassword: TLabeledEdit;
    editNetPort: TLabeledEdit;
    editNetHost: TLabeledEdit;
    btnOpenFilter: TButton;
    btnSaveComment: TButton;
    btnLoadComment: TButton;
    btnExit: TButton;
    cobNetCFontSize: TComboBox;
    cobNetCFontColor: TShape;
    ColorDialog: TColorDialog;
    cobNetCFontBold: TCheckBox;
    cobOfficialCFontSize: TComboBox;
    cobOfficialCFontBold: TCheckBox;
    cobOfficialCFontColor: TShape;
    btnNetStart: TButton;
    SaveDialog: TSaveDialog;
    btnEscAll: TButton;
    btnHideCtrl: TButton;
    EditDispatchKey: THotKey;
    lblCallConsole: TLabel;
    btnSetFixedLabel: TButton;
    editOfficialCommentParaUpDown: TUpDown;
    editStdShowTime: TLabeledEdit;
    editOfficialCommentDuration: TLabeledEdit;
    ChkAutoStartNet: TCheckBox;
    btnClearList: TButton;
    BtnFreezing: TButton;
    DelayProgBar: TProgressBar;
    EdtNetDelay: TLabeledEdit;
    IdUDPServerCCRecv: TIdUDPServer;
    ButtonTerminateThread: TButton;
    ButtonStartThreads: TButton;
    BtnLogShow: TButton;
    BtnConfig: TButton;
    RadioGroupModes: TRadioGroup;
    BtnReloadCfg: TButton;
    StatValueList: TValueListEditor;
    procedure btnCCShowClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCCWorkClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TimerGeneralTimer(Sender: TObject);
    procedure btnSetFixedLabelClick(Sender: TObject);
    procedure btnOpenFilterClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure cobNetCFontColorMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure cobOfficialCFontColorMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnOfficialSendClick(Sender: TObject);
    procedure btnLoadCommentClick(Sender: TObject);
    procedure btnSaveCommentClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnHideCtrlClick(Sender: TObject);
    procedure EditDispatchKeyChange(Sender: TObject);
    procedure editNetPortChange(Sender: TObject);
    procedure cobNetCFontSizeKeyPress(Sender: TObject; var Key: Char);
    procedure cobOfficialCFontSizeKeyPress(Sender: TObject; var Key: Char);
    procedure editTimingInvChange(Sender: TObject);
    procedure editStdShowTimeChange(Sender: TObject);
    procedure btnNetStartClick(Sender: TObject);
    procedure cobNetCFontNameChange(Sender: TObject);
    procedure cobNetCFontSizeChange(Sender: TObject);
    procedure cobNetCFontBoldClick(Sender: TObject);
    procedure cobOfficialCFontNameChange(Sender: TObject);
    procedure cobOfficialCFontSizeChange(Sender: TObject);
    procedure cobOfficialCFontBoldClick(Sender: TObject);
    procedure grpSpecialEffectsClick(Sender: TObject);
    procedure grpTimingClick(Sender: TObject);
    procedure btnClearListClick(Sender: TObject);
    procedure BtnFreezingClick(Sender: TObject);
    procedure ListCommentsDblClick(Sender: TObject);
    procedure ListCommentsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure editNetPasswordChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EdtNetDelayChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonTerminateThreadClick(Sender: TObject);
    procedure ButtonStartThreadsClick(Sender: TObject);
    procedure BtnLogShowClick(Sender: TObject);
    procedure BtnConfigClick(Sender: TObject);
    procedure RadioGroupModesClick(Sender: TObject);
    procedure BtnReloadCfgClick(Sender: TObject);
    procedure editOfficialCommentDurationChange(Sender: TObject);

  private
    { Private declarations }
    CCWindowShow, CCWindowWorking, Fetching, AddOCWorking : Boolean;
    DispatchKey : Integer;
    XMLDelay : Integer;
    FreezingTime : TTime;

    procedure WindowTrayMessage(var Message: TMessage);
    message NamikoTrayMessage;
    procedure WMHotKey(var Msg : TWMHotKey); message WM_HOTKEY;

    procedure CreateCommentWindow();
    procedure StartThreads();
    procedure TerminateThreads();
    procedure LoadSetting();
    procedure ReloadControls();
    procedure SaveSetting();
  public
    { Public declarations }
    TimeZoneBias: Integer;
    RemoteTime, InternalTime, RemoteTimeOffset, InternalTimeOffset : TTime;
    Networking, SysReady, AutoStart, Freezing: Boolean;
    CommMode, CommUDPPort: Cardinal;
    CurrListIndex: Cardinal;
    ClearedItemCount: Cardinal;
    // Environment Variables
    ScreenWidth, ScreenHeight: Integer;
    // Internet Runtime Variables
    NetPassword, NetDefaultFontName: string;
    NetDefaultFontSize: Real;
    NetDefaultFontColor: TAlphaColor;
    NetDefaultFontStyle: Cardinal;
    NetDefaultDuration: Integer;
    NetDefaultOpacity: Byte;
    NetDelayDuration: Integer;
    // Official Runtime Variables
    OfficialFontName: string;
    OfficialFontSize: Real;
    OfficialFontColor: TAlphaColor;
    OfficialFontStyle: Cardinal;
    OfficialDuration: Integer;
    OfficialRepeat: Integer;
    OfficialOpacity: Byte;
    // Title Variables
    MTitleText: string;
    MTitleTop, MTitleLeft: Integer;
    MTitleFontName: WideString;
    MTitleFontSize: Real;
    MTitleFontColor: TAlphaColor;
    // CONTAINERS <<SHOULD BE FREED MANUALLY>>
    CommentPool: TCommentCollection;
    LiveCommentPool: TLiveCommentCollection;
    UpdateQueue: TRenderUnitQueue;
    // TListView Wrapper
    ListViewOffset: Integer;
    // Threads
    RThread: TRenderThread;
    UThread: TUpdateThread;
    DThread: TDispatchThread;
    HThread: THTTPWorkerThread;
    // New Procedures
    procedure UpdateListView(const CommentID: Integer); // called by AppendListView
    procedure AppendListView(const AComment: TComment);
    procedure AppendComment(var AComment: TComment); // MUTEX, called by AppendXComment()
    procedure AppendNetComment(LTime: TTime; RTime: TTime; Author: TCommentAuthor; AContent: string; AFormat: TCommentFormat);
    procedure AppendConsoleComment(AContent: string; AEffect: TCommentEffect; AFormat: TCommentFormat);
    procedure AppendLocalComment(LTime: TTime; RTime: TTime; AContent: string; AEffect: TCommentEffect; AFormat: TCommentFormat);
    procedure UpdateCaption();
    // Old Procedures
    procedure LogEvent(Info: string; Level: TLogType = logInfo);
  end;

var
  frmControl: TfrmControl;
  TrayIconData: TNotifyIconData;
  // Thread Sync Objects
  SharedConfigurationMutex, GraphicSharedMutex, {HTTPSharedMutex,} HexieMutex,
  CommentPoolMutex, LiveCommentPoolMutex, UpdateQueueMutex: TMutex;
  DispatchS, UpdateS: TSemaphore;
  DefaultSA: TSecurityAttributes; // Use to create thread objects
  // Comment Layered Window
  CCWnd,hInst: THandle;
  CCWinClass: TWndClassEx; // WNDCLASSEX wndcls;
  CCWinPos: TRect;

function EncrypKey(Src: string; Key: string): string;
function UncrypKey(Src: string; Key: string): string;

function AlphaColorToColor(Alpha: TAlphaColor): TColor;
function ColorToAlphaColor(Color: TColor; Opacity: Byte): TAlphaColor;
function BGRToRGB(AColor: TAlphaColor): TAlphaColor;

function ShiftStateToInt(Shift: TShiftState): Cardinal;

implementation

{$R *.dfm}
uses
  SetupForm, HexieForm, DemoForm;

procedure TfrmControl.AppendListView(const AComment: TComment);
begin
  with ListComments.Items.Add do begin
    Caption := 'C';
    SubItems.Add(IntToStr(AComment.ID));
    SubItems.Add(Format('%s.%u',[TimeToStr(AComment.Time),MilliSecondOf(AComment.Time)]));
    SubItems.Add(AComment.Content);
    case AComment.Author.Source of
      Internet: SubItems.Add(AComment.Author.Address);
      Console: SubItems.Add(L_Console);
      XML: SubItems.Add(L_XMLFile);
    end;
    SubItems.Add(Format('%s|%.1f|%s|%s',[AComment.Format.FontName,AComment.Format.FontSize,IntToHex(AComment.Format.FontColor,8),IfThen(AComment.Format.FontStyle = 1,'B','R')]));
    case AComment.Effect.Display of
      Scroll: SubItems.Add('飞行');
      UpperFixed: SubItems.Add('顶部');
      LowerFixed: SubItems.Add('底部');
    end;
    SubItems.Add(IntToStr(AComment.Effect.RepeatCount));
    SubItems.Add(IntToStr(AComment.Effect.StayTime));
  end;
end;

// WARNING: Call Me After CommentPoolMutex.Acquire!
procedure TfrmControl.UpdateListView(const CommentID: Integer);
var
  AComment: TComment;
  Index: Integer;
begin
  if CommentID > CommentPool.Count then Exit;
  Index := CommentID - ListViewOffset - 1;
  if Index > ListComments.Items.Count then Exit;
  AComment := CommentPool.Items[Index];
  //if StrToInt(ListComments.Items[Index].SubItems.Strings[T_ID]) = CommentID then begin // Out of range
  case AComment.Status of
    Created: ListComments.Items.Item[Index].Caption := 'C';
    Pending: ListComments.Items.Item[Index].Caption := 'P';
    Starting: ListComments.Items.Item[Index].Caption := 'S';
    Waiting: ListComments.Items.Item[Index].Caption := 'W';
    Displaying: ListComments.Items.Item[Index].Caption := '<';
    Removing: ListComments.Items.Item[Index].Caption := 'R';
    Removed: ListComments.Items.Item[Index].Caption := 'D';
  end;
  //end;
end;

procedure TfrmControl.AppendComment(var AComment: TComment);
begin
  AComment.Format.FontColor := BGRToRGB(AComment.Format.FontColor);
  AppendListView(AComment);
  // Do not change these two lines
  AComment.Content := StringReplace(AComment.Content,'\n',#13,[rfReplaceAll]);
  AComment.Content := StringReplace(AComment.Content,'/n',#13,[rfReplaceAll]);
  {$IFDEF DEBUG_VERBOSE1}LogEvent('Before CommentPoolMutex.Acquire()', logDebug);{$ENDIF}
  CommentPoolMutex.Acquire; // CS: Read the comment pool
  {$IFDEF DEBUG_VERBOSE1}LogEvent('After CommentPoolMutex.Acquire()', logDebug);{$ENDIF}
  try
    // Main Proc to complete this operation
    CommentPool.Add(AComment);
    DispatchS.Release;
  finally
    CommentPoolMutex.Release;
  end;
end;

procedure TfrmControl.AppendNetComment(LTime: TTime; RTime: TTime; Author: TCommentAuthor; AContent: string; AFormat: TCommentFormat);
var
  ThisComment: TComment;
begin
  ThisComment := TComment.Create;
  ThisComment.Time := LTime + (NetDelayDuration + Random(3000)) / 86400000; // TODO
  ThisComment.Content := AContent;
  ThisComment.Author := Author;
  ThisComment.Format := AFormat;
  with ThisComment.Format do begin
    if DefaultName then FontName := NetDefaultFontName;
    if DefaultSize then FontSize := NetDefaultFontSize;
    if DefaultColor then FontColor := NetDefaultFontColor;
    if DefaultStyle then FontStyle := NetDefaultFontStyle;
  end;
  with ThisComment.Effect do begin
    Display := Scroll;
    StayTime := NetDefaultDuration;
    RepeatCount := 1;
    Speed := 0;
  end;
  ThisComment.Status := Created;
  AppendComment(ThisComment);
end;

procedure TfrmControl.AppendConsoleComment(AContent: string; AEffect: TCommentEffect; AFormat: TCommentFormat);
var
  ThisComment: TComment;
begin
  ThisComment := TComment.Create;
  ThisComment.Time := Now(); // TODO
  ThisComment.Content := AContent;
  ThisComment.Author.Source := Console;
  ThisComment.Format := AFormat;
  ThisComment.Effect := AEffect;
  ThisComment.Status := Created;
  AppendComment(ThisComment);
end;

procedure TfrmControl.AppendLocalComment(LTime: TTime; RTime: TTime; AContent: string; AEffect: TCommentEffect; AFormat: TCommentFormat);
var
  ThisComment: TComment;
begin
  // TODO
  AppendComment(ThisComment);
end;

procedure TfrmControl.btnCCShowClick(Sender: TObject);
begin
  FormDimSet.Show;
end;

procedure TfrmControl.WindowTrayMessage(var Message: TMessage);
begin
  if Message.Msg = NamikoTrayMessage then begin
    case Message.LParam of
      WM_LBUTTONUP:
      begin
        ShowWindow(Self.Handle,SW_NORMAL);
        SetForegroundWindow(Self.Handle);
      end;
    end;
  end;
end;

procedure TfrmControl.CreateCommentWindow;
var
  hdcTemp,hdcScreen,m_hdcMemory: HDC;
  hBitMap: Winapi.Windows.HBITMAP;
  blend: BLENDFUNCTION;      //这种结构的混合控制通过指定源和目标位图的混合功能
  ptWinPos,ptSrc: TPoint;
  sizeWindow: SIZE;
begin
  if CCWnd > 0 then Exit; // Already Created
  hInst := GetModuleHandle(nil); // HINSTANCE hInstance=AfxGetInstanceHandle();
  CCWinClass.cbSize := SizeOf(TWndClassEx); // wndcls.cbSize=sizeof(WNDCLASSEX);
  CCWinClass.lpszClassName := 'MyLayeredWindow'; // wndcls.lpszClassName=lpszClassName;
  CCWinClass.style := CS_DBLCLKS or CS_HREDRAW or CS_VREDRAW; //wndcls.style=CS_DBLCLKS|CS_HREDRAW|CS_VREDRAW;
  CCWinClass.hInstance := hInst; //wndcls.hInstance=hInstance;
  CCWinClass.lpfnWndProc := @DefWindowProc; //wndcls.lpfnWndProc=::DefWindowProc;
  CCWinClass.cbClsExtra := 0; //以下两个域用于在类结构和Windows内部保存的窗口结构
  CCWinClass.cbWndExtra := 0; //中预留一些额外空间.
  CCWinClass.hIcon := 0; // wndcls.hIcon=NULL;
  CCWinClass.hIconsm := 0;
  CCWinClass.hCursor := LoadCursor(0,IDC_Arrow); // wndcls.hCursor=::LoadCursor(NULL,IDC_ARROW);
  //GetStockObject 获取一个图形对象,在这里是获取绘制窗口背景的刷子,返回一个白色刷  子的句柄.
  CCWinClass.hbrBackground := HBRUSH(COLOR_BTNFACE+1); // wndcls.hbrBackground=(HBRUSH)(COLOR_BTNFACE+1);
  CCWinClass.lpszMenuName := nil; //wndcls.lpszMenuName=NULL;

  //向Windows 注册窗口类.
  if RegisterClassEx(CCWinClass) = 0 then begin
    LogEvent('弹幕窗体类注册失败', logError);
    Exit;
  end;

  CCWnd := CreateWindowEx(
    WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_LAYERED, //扩展的窗口风格.
    CCWinClass.lpszClassName, //类名.
    'Hello Window', //窗口标题.
    WS_POPUP or WS_VISIBLE, //窗口风格.
    CCWinPos.Left, //窗口左上角相对于屏幕左上角的初始位置x.
    CCWinPos.Top, //....右y.
    CCWinPos.Width, //窗口宽度x.
    CCWinPos.Height, //窗口高度y.
    0, //父窗口句柄.
    0, //窗口菜单句柄.
    hInst, //程序实例句柄.
    nil); //创建参数指针.
  if CCWnd = 0 then
    LogEvent('弹幕窗体创建失败', logError)
  else
  begin
    hdcTemp := GetDC(CCWnd);
    m_hdcMemory := CreateCompatibleDC(hdcTemp);
    hBitMap := CreateCompatibleBitmap(hdcTemp,CCWinPos.Width,CCWinPos.Height);
    SelectObject(m_hdcMemory,hBitMap);
    with blend do begin
      BlendOp := AC_SRC_OVER;     //把源图片覆盖到目标之上
      BlendFlags := 0;
      AlphaFormat := AC_SRC_ALPHA;//每个像素有各自的alpha通道
      SourceConstantAlpha := Trunc(100 * 2.55);  //源图片的透明度
    end;
    ptWinPos := Point(0,0);
    sizeWindow.cx := CCWinPos.Width;
    sizeWindow.cy := CCWinPos.Height;
    ptSrc := Point(0,0);
    hdcScreen := GetDC(CCWnd);
    UpdateLayeredWindow(CCWnd,   //分层窗口的句柄
                        hdcScreen,     //屏幕的DC句柄
                        @ptWinPos,     //分层窗口新的屏幕坐标
                        @sizeWindow,   //分层窗口新的大小
                        m_hdcMemory,   //用来定义分层窗口的表面DC句柄
                        @ptSrc,        //分层窗口在设备上下文的位置
                        0,             //合成分层窗口时使用指定颜色键值
                        @blend,        //在分层窗口进行组合时的透明度值
                        ULW_ALPHA);    //使用pblend为混合功能
    //---------------------开始：释放和删除--------------------------------------
    ReleaseDC(CCWnd,hdcScreen);
    ReleaseDC(CCWnd,hdcTemp);
    DeleteObject(hBitMap);
    DeleteDC(m_hdcMemory);
  end;
end;

procedure TfrmControl.StartThreads;
var
  CreateD, CreateR, CreateU: Boolean;
begin
  if not SysReady then begin
    LogEvent('未就绪状态，无法启动线程', logError);
    Exit;
  end;
  CreateD := True;
  CreateR := True;
  CreateU := True;
  if Assigned(DThread) then begin
    if DThread.Finished then
      DThread.Free()
    else
      CreateD := False;
  end;
  if CreateD then begin
    DThread := TDispatchThread.Create(20000,300,CommentPool,LiveCommentPool);
    LogEvent('创建调度线程');
    DThread.Start;
  end;
  if Assigned(RThread) then begin
    if RThread.Finished then
      RThread.Free()
    else
      CreateR := False;
  end;
  if CreateR then begin
    RThread := TRenderThread.Create(CCWnd,CCWinPos.Width,CCWinPos.Height,LiveCommentPool,UpdateQueue);
    LogEvent('创建绘制线程');
    RThread.Start;
  end;
  if Assigned(UThread) then begin
    if UThread.Finished then
      UThread.Free()
    else
      CreateU := False;
  end;
  if CreateU then begin
    UThread := TUpdateThread.Create(CCWnd,CCWinPos,UpdateQueue);
    LogEvent('创建显示线程');
    UThread.Start;
  end;
end;

procedure TfrmControl.TerminateThreads;
begin
  if Assigned(DThread) and DThread.Started then DThread.Terminate;
  if Assigned(RThread) and RThread.Started then RThread.Terminate;
  if Assigned(UThread) and UThread.Started then begin
    UpdateS.Release; // Empty Operation
    UThread.Terminate;
  end;
  if Assigned(HThread) and HThread.Started then HThread.Terminate;
end;

procedure TfrmControl.FormCreate(Sender: TObject);
var
  Key : Word;
  Shift : TShiftState;
  m_timezone : TIME_ZONE_INFORMATION;
begin
  LogEvent('主窗体开始加载');
  ScreenWidth := GetSystemMetrics(SM_CXSCREEN);
  ScreenHeight := GetSystemMetrics(SM_CYSCREEN);
  LogEvent(Format('获取屏幕大小 %u*%u',[ScreenWidth,ScreenHeight]));
  //Init Interface
  StatusBar.Panels[0].Width := Width - 610;
  StatusBar.Panels[2].Text := '显示/总共 0/0';
  //Set Variable & UI
  CCWindowShow := False;
  CCWindowWorking := False;
  Networking := False;
  Fetching := False;
  Freezing := False;
  AddOCWorking := False;
  CurrListIndex := 0;
  ClearedItemCount := 0;
  XMLDelay := 0;
  ListViewOffset := 0;
  //Set Internal Time as System Time
  InternalTime := Time();
  InternalTimeOffset := 0;
  //Set Timezone
  GetTimeZoneInformation(m_timezone);
  TimeZoneBias := m_timezone.Bias * 60;
  LogEvent(Format('获取时区偏移 %d',[TimeZoneBias]));
  //Fetch Font List
  cobNetCFontName.Items.AddStrings(Screen.Fonts);
  cobOfficialCFontName.Items.AddStrings(Screen.Fonts);
  //Load Settings
  LoadSetting(); // Call After APP_DIR
  LogEvent('初始化配置');
  ReloadControls();
  //HTTPSharedMutex.Release;
  //Set Path
  SaveDialog.InitialDir := APP_DIR;
  //Register Hotkey
  try
    ShortCutToKey(EditDispatchKey.HotKey,Key,Shift);
    DispatchKey := GlobalAddAtom('RTCCDispatchHotkey');
    RegisterHotKey(handle,DispatchKey,ShiftStateToInt(Shift),Key);
    LogEvent('注册快捷键');
  except
    LogEvent('快捷键设置失败', logException);
  end;
  //Register Tray Icon
  TrayIconData.cbSize := SizeOf(TrayIconData);
  TrayIconData.uFlags := NIF_ICON or NIF_TIP or NIF_MESSAGE;
  TrayIconData.uID := UINT(Self);
  TrayIconData.Wnd := Handle;
  TrayIconData.hIcon := Application.Icon.Handle;
  StrCopy(@TrayIconData.szTip,PChar(Application.Title));
  TrayIconData.uCallbackMessage := NamikoTrayMessage;
  Shell_NotifyIcon(NIM_ADD,@TrayIconData);
  LogEvent('创建托盘图标');
  //Pools
  CommentPool := TCommentCollection.Create(True);
  CommentPoolMutex.Release;
  LiveCommentPool := TLiveCommentCollection.Create(True);
  LiveCommentPoolMutex.Release;
  UpdateQueue := TRenderUnitQueue.Create();
  UpdateQueue.Capacity := 1024;
  UpdateQueueMutex.Release;
  LogEvent('创建弹幕池和临时空间');
  CreateCommentWindow;
  if CCWnd = 0 then begin
    LogEvent('弹幕窗口创建失败', logError);
    Application.MessageBox('弹幕窗体创建失败，将无法正常工作。','启动异常',MB_ICONERROR);
  end
  else begin
    LogEvent('创建弹幕窗体完成');
    SysReady := True;
    // Thread
    StartThreads;
    // IMPORTANT!
    SharedConfigurationMutex.Release;
    GraphicSharedMutex.Release;
    //Notify Complete
    LogEvent('初始化完毕');
    StatusBar.Panels[0].Text := '控制台初始化完毕';
  end;
  //StatValueList.InsertRow('','0',True);
  Self.Show;
  if AutoStart then begin
    LogEvent('自动启动通信');
    btnNetStart.Click;
  end;
 end;

procedure TfrmControl.FormDestroy(Sender: TObject);
begin
  SysReady := False;
  Shell_NotifyIcon(NIM_DELETE,@TrayIconData);
  UnRegisterHotKey(handle,DispatchKey);
  GlobalDeleteAtom(DispatchKey);
  FreeAndNil(DThread);
  FreeAndNil(RThread);
  FreeAndNil(UThread);
  FreeAndNil(HThread);
  CommentPoolMutex.Acquire;
  FreeAndNil(CommentPool);
  CommentPoolMutex.Release;
  LiveCommentPoolMutex.Acquire;
  FreeAndNil(LiveCommentPool);
  LiveCommentPoolMutex.Release;
  UpdateQueueMutex.Acquire;
  FreeAndNil(UpdateQueue);
  UpdateQueueMutex.Release;
  if CCWnd > 0 then DestroyWindow(CCWnd);
end;

procedure TfrmControl.btnCCWorkClick(Sender: TObject);
begin
  if frmDemo.Visible then begin
    frmDemo.Hide;
    btnCCWork.Caption := '测试窗口(&W)';
  end
  else begin
    frmDemo.Show;
    btnCCWork.Caption := '确认位置(&I)';
  end;
end;

procedure TfrmControl.FormResize(Sender: TObject);
begin
  StatusBar.Panels[0].Width := Width - 610;
end;

procedure TfrmControl.TimerGeneralTimer(Sender: TObject);
var
  TimeNow: TTime;
begin
  {case grpTiming.ItemIndex of
    0: InternalTime := Time();
    1,2: if not Freezing then InternalTime := InternalTime + TimerGeneral.Interval / 86400000;
  end;
  if RemoteTime <> 0 then RemoteTime := RemoteTime + TimerGeneral.Interval / 86400000;}
  TimeNow := Time();
  if CommentPool.Count > 0 then begin
    StatusBar.Panels[1].Text := Format('弹幕数 %u',[CommentPool.Last.ID]);
    StatusBar.Panels[2].Text := Format('最近弹幕 %s',[TimeToStr(CommentPool.Last.Time)]);
  end
  else begin
    StatusBar.Panels[1].Text := '无弹幕';
    StatusBar.Panels[2].Text := '-';
  end;

  StatusBar.Panels[3].Text := '调度 '+TimeToStr(TimeNow);
  StatusBar.Panels[5].Text := '本地 '+TimeToStr(TimeNow);
  // STAT
  if Assigned(HThread) and HThread.Started and (HThread.ReqCount > 0) then begin
    with HThread do begin
      StatusBar.Panels[4].Text := '远程 ' + TimeToStr(TimeNow - ServerTimeOffset / 86400000);
      StatValueList.Values['HTTP已请求'] := IntToStr(ReqCount);
      StatValueList.Values['HTTP连超时'] := IntToStr(ReqConnTCCount);
      StatValueList.Values['HTTP读超时'] := IntToStr(ReqReadTCCount);
      StatValueList.Values['HTTP被关闭'] := IntToStr(ReqClosedCount);
      StatValueList.Values['HTTP错误'] := IntToStr(ReqErrCount);
      StatValueList.Values['HTTP平均耗时'] := Format('%.2f s',[ReqTotalMS / 1000 / ReqCount]);
      StatValueList.Values['HTTP上次耗时'] := Format('%.2f s',[ReqLastMS / 1000]);
    end;
  end;
  if Assigned(RThread) and RThread.Started then begin
    with RThread do begin
      StatValueList.Values['已绘制帧'] := IntToStr(FramesCount);
      StatValueList.Values['已绘制秒'] := Format('%.2f',[RenderMS / 1000]);
      StatValueList.Values['绘制帧率'] := Format('%.3ffps',[FramesCount / (RenderMS / 1000)]);
      StatValueList.Values['绘制开销'] := IntToStr(OverheadMS);
      StatValueList.Values['绘制队列满'] := IntToStr(QueueFullCount);
    end;
  end;
  if Assigned(UThread) and UThread.Started then begin
    with UThread do begin
      StatValueList.Values['已显示帧'] := IntToStr(SCount);
      StatValueList.Values['已显示秒'] := Format('%.2f',[SElaspedMS / 1000]);
      StatValueList.Values['显示帧率'] := Format('%.3ffps',[SCount / (SElaspedMS / 1000)]);
      StatValueList.Values['帧率过高'] := IntToStr(WOverFPS);
      StatValueList.Values['更新下限'] := IntToStr(WOverMin);
      StatValueList.Values['更新上限'] := IntToStr(WOverMax);
    end;
  end;
end;

procedure TfrmControl.UpdateCaption;
begin
  if Assigned(RThread) then begin
    GraphicSharedMutex.Acquire;
    try
      RThread.MTitleText := MTitleText;
      RThread.MTitleTop := MTitleTop;
      RThread.MTitleLeft := MTitleLeft;
      RThread.MTitleFontName := MTitleFontName;
      RThread.MTitleFontSize := MTitleFontSize;
      RThread.MTitleFontColor := MTitleFontColor;
      RThread.MDoUpdate := True;
    finally
      GraphicSharedMutex.Release;
    end;
  end;
end;

procedure TfrmControl.btnSetFixedLabelClick(Sender: TObject);
begin
  MTitleText := StringReplace(editOfficialComment.Text,'/n',#13,[rfReplaceAll]);
  MTitleFontName := OfficialFontName;
  MTitleFontSize := OfficialFontSize;
  MTitleFontColor := BGRToRGB(OfficialFontColor);
  if frmDemo.Visible then begin
    with frmDemo.TestLabel do begin
      Caption := MTitleText;
      Font.Name := OfficialFontName;
      Font.Size := Floor(OfficialFontSize);
      Font.Color := cobOfficialCFontColor.Brush.Color;
    end;
  end;
  UpdateCaption;
end;

procedure TfrmControl.ButtonStartThreadsClick(Sender: TObject);
begin
  StartThreads;
end;

procedure TfrmControl.ButtonTerminateThreadClick(Sender: TObject);
begin
  TerminateThreads;
end;

procedure TfrmControl.btnOpenFilterClick(Sender: TObject);
begin
  frmWordList.Show;
end;

procedure TfrmControl.BtnReloadCfgClick(Sender: TObject);
begin
  LoadSetting;
  ReloadControls;
end;

procedure TfrmControl.btnExitClick(Sender: TObject);
begin
  // Unloading
  frmControl.Close;
end;

procedure TfrmControl.cobNetCFontColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := cobNetCFontColor.Brush.Color;
  if ColorDialog.Execute then begin
    cobNetCFontColor.Brush.Color := ColorDialog.Color;
    if frmDemo.Visible then frmDemo.NetCDemo.Font.Color := ColorDialog.Color;    
    NetDefaultFontColor := ColorToAlphaColor(ColorDialog.Color, NetDefaultOpacity);
  end;
end;

procedure TfrmControl.cobOfficialCFontColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := cobOfficialCFontColor.Brush.Color;
  if ColorDialog.Execute then begin
    cobOfficialCFontColor.Brush.Color := ColorDialog.Color;
    if frmDemo.Visible then frmDemo.OfficialCDemo.Font.Color := ColorDialog.Color;
    OfficialFontColor := ColorToAlphaColor(ColorDialog.Color, OfficialOpacity);
  end;
end;

procedure TfrmControl.btnOfficialSendClick(Sender: TObject);
var
  Content: string;
  Effect: TCommentEffect;
  Format: TCommentFormat;
begin
  Content := TrimRight(editOfficialComment.Text);
  if Length(Content) = 0 then Exit;
  {if frmWordList.Hexied(Content) then begin
    if Application.MessageBox('检测到敏感词，继续吗？','河蟹已经阻止不了你了么',MB_ICONQUESTION + MB_YESNO) = IDNO then begin
      editOfficialComment.Clear;
      editOfficialComment.SetFocus;
      exit;
    end;
  end;}

  case grpSpecialEffects.ItemIndex of
    0: Effect.Display := Scroll;
    1: Effect.Display := UpperFixed;
    2: Effect.Display := LowerFixed;
  end;
  Effect.StayTime := OfficialDuration;
  Effect.RepeatCount := IfThen(Boolean(Effect.Display = Scroll),StrToInt(editOfficialCommentPara.Text),1);

  Format.DefaultName := False;
  Format.DefaultSize := False;
  Format.DefaultColor := False;
  Format.DefaultStyle := False;
  Format.FontName := OfficialFontName;
  Format.FontSize := OfficialFontSize;
  Format.FontColor := OfficialFontColor; // TColor To TAlphaColor
  Format.FontStyle := OfficialFontStyle;
  {Format.FontColor := Color or $FF000000; // TColor To TAlphaColor
  Format.FontStyle := IfThen(fsBold in Style,1,0);}

  AppendConsoleComment(Content,Effect,Format);

  editOfficialComment.Clear;
  editOfficialComment.SetFocus;
end;

procedure TfrmControl.btnLoadCommentClick(Sender: TObject);
begin
  //frmLoadXML.Show();
  //frmLoadXML.Test;
end;

procedure TfrmControl.BtnLogShowClick(Sender: TObject);
begin
  if not frmLog.Visible then frmLog.Show;
end;

procedure TfrmControl.btnSaveCommentClick(Sender: TObject);
{var
  XMLDoc : TXMLDocument;
  DocIntf : IXMLDocument;
  RootNode, CNode : IXMLNode;
  i : Integer;}
begin
  {if SaveDialog.Execute then begin
    XMLDoc := TXMLDocument.Create(nil);
    try
      DocIntf := XMLDoc;
      try
        XMLDoc.Active := true;
        XMLDoc.Encoding := 'utf-8';
        XMLDoc.Options := XMLDoc.Options + [doNodeAutoIndent];
        RootNode := XMLDoc.AddChild('Namiko');
        for i := 0 to CommentPool.Count - 1 do begin
          CNode := RootNode.AddChild('comment');
          // Read CommentPool instead
          with ListComments.Items.Item[i].SubItems do begin
            CNode.AddChild('time').Text := Strings[T_LTIME];
            CNode.AddChild('content').Text := Strings[T_TEXT];
            CNode.AddChild('format').Text := Strings[T_FORMAT];
            CNode.AddChild('repeat').Text := Strings[T_CYCLE];
            CNode.AddChild('duration').Text := Strings[T_OCTIME];
            CNode.AddChild('data').Text := Strings[T_STATUS];
          end;
        end;
        XMLDoc.SaveToFile(SaveDialog.FileName);
      except
        LogEvent('XML弹幕保存异常：%s' + );
        DocIntf := nil;
      end;
    finally
      XMLDoc.Free;
    end;
  end;}
end;

procedure TfrmControl.LogEvent(Info: string; Level: TLogType = logInfo);
begin
  frmLog.LogAdd(Info, '控制', Level);
end;

procedure TfrmControl.RadioGroupModesClick(Sender: TObject);
begin
  case RadioGroupModes.ItemIndex of
    0, 2: begin
      editNetPort.Enabled := True;
      editNetHost.Enabled := False;
    end;
    1: begin
      editNetPort.Enabled := False;
      editNetHost.Enabled := True;
    end;
  end;
  CommMode := RadioGroupModes.ItemIndex;
end;

procedure TfrmControl.LoadSetting();
begin
  with frmConfig do begin
    NetDefaultFontName := StringItems['NetComment.FontName'];
    NetDefaultFontSize := IntegerItems['NetComment.FontSize'].ToDouble;
    NetDefaultFontColor := StringToAlphaColor(StringItems['NetComment.FontColor']);
    NetDefaultFontStyle := IntegerItems['NetComment.FontStyle'];
    NetDefaultDuration := IntegerItems['NetComment.Duration'];
    NetDefaultOpacity := IntegerItems['NetComment.Opacity'];
    NetDelayDuration := IntegerItems['Pool.NetDelay'];

    OfficialFontName := StringItems['OfficialComment.FontName'];
    OfficialFontSize := IntegerItems['OfficialComment.FontSize'].ToDouble;
    OfficialFontColor := StringToAlphaColor(StringItems['OfficialComment.FontColor']);
    OfficialFontStyle := IntegerItems['OfficialComment.FontStyle'];
    OfficialDuration := IntegerItems['OfficialComment.Duration'];
    OfficialOpacity := IntegerItems['OfficialComment.Opacity'];

    CommMode := IntegerItems['Connection.Mode'];
    CommUDPPort := IntegerItems['Connection.Port'];
    try
      NetPassword := UncrypKey(StringItems['Connection.Key'],KEY);
    except
      NetPassword := '233-614-789-998';
      LogEvent('通信密码无效，请重新设定', logWarning);
    end;
    editNetHost.Text := StringItems['Connection.Host'];
    AutoStart := BooleanItems['Connection.AutoStart'];

    CCWinPos := TRect.Create(
      IntegerItems['Display.WorkWindowLeft'],
      IntegerItems['Display.WorkWindowTop'],
      IntegerItems['Display.WorkWindowWidth'],
      IntegerItems['Display.WorkWindowHeight']
    );
    CCWinPos.Right := CCWinPos.Left + IntegerItems['Display.WorkWindowWidth'];

    MTitleText := StringItems['Title.Text'];
    MTitleLeft := IntegerItems['Title.Left'];
    MTitleTop := IntegerItems['Title.Top'];
    MTitleFontName := StringItems['Title.FontName'];
    MTitleFontSize := IntegerItems['Title.FontSize'].ToDouble;
    MTitleFontColor := StringToAlphaColor(StringItems['Title.FontColor']);
  end;
end;

procedure TfrmControl.ReloadControls;
begin
  cobNetCFontName.ItemIndex := cobNetCFontName.Items.IndexOf(NetDefaultFontName);
  cobNetCFontSize.Text := FloatToStr(NetDefaultFontSize);
  cobNetCFontColor.Brush.Color := AlphaColorToColor(NetDefaultFontColor);
  if NetDefaultFontStyle and 1 = 1 then
    cobNetCFontBold.Checked := True
  else
    cobNetCFontBold.Checked := False;
  editStdShowTime.Text := IntToStr(NetDefaultDuration);
  edtNetDelay.Text := IntToStr(NetDelayDuration);

  cobOfficialCFontName.ItemIndex := cobOfficialCFontName.Items.IndexOf(OfficialFontName);
  cobOfficialCFontSize.Text := FloatToStr(OfficialFontSize);
  cobOfficialCFontColor.Brush.Color := AlphaColorToColor(OfficialFontColor);
  if OfficialFontStyle and 1 = 1 then
    cobOfficialCFontBold.Checked := True
  else
    cobOfficialCFontBold.Checked := False;
  editOfficialCommentDuration.Text := IntToStr(OfficialDuration);

  RadioGroupModes.ItemIndex := CommMode;
  editNetPort.Text := IntToStr(CommUDPPort);
  //editNetHost.Text already assigned
  editNetPassword.Text := NetPassword;
  chkAutoStartNet.Checked := AutoStart;
end;

procedure TfrmControl.SaveSetting();
begin
  with frmConfig do begin
    StringItems['NetComment.FontName'] := NetDefaultFontName;
    IntegerItems['NetComment.FontSize'] := Floor(NetDefaultFontSize);
    StringItems['NetComment.FontColor'] := AlphaColorToString(NetDefaultFontColor);
    IntegerItems['NetComment.FontStyle'] := NetDefaultFontStyle;
    IntegerItems['NetComment.Duration'] := NetDefaultDuration;
    IntegerItems['Pool.NetDelay'] := NetDelayDuration;

    StringItems['OfficialComment.FontName'] := OfficialFontName;
    IntegerItems['OfficialComment.FontSize'] := Floor(OfficialFontSize);
    StringItems['OfficialComment.FontColor'] := AlphaColorToString(OfficialFontColor);
    IntegerItems['OfficialComment.FontStyle'] := OfficialFontStyle;
    IntegerItems['OfficialComment.Duration'] := OfficialDuration;

    IntegerItems['Connection.Mode'] := CommMode;
    IntegerItems['Connection.Port'] := CommUDPPort;
    StringItems['Connection.Key'] := EncrypKey(NetPassword,KEY);
    StringItems['Connection.Host'] := editNetHost.Text;
    BooleanItems['Connection.AutoStart'] := AutoStart;

    IntegerItems['Display.WorkWindowLeft'] := CCWinPos.Left;
    IntegerItems['Display.WorkWindowTop'] := CCWinPos.Top;
    IntegerItems['Display.WorkWindowWidth'] := CCWinPos.Width;
    IntegerItems['Display.WorkWindowHeight'] := CCWinPos.Height;

    StringItems['Title.Text'] := MTitleText;
    IntegerItems['Title.Left'] := MTitleLeft;
    IntegerItems['Title.Top'] := MTitleTop;
    StringItems['Title.FontName'] := MTitleFontName;
    IntegerItems['Title.FontSize'] := Floor(MTitleFontSize);
    StringItems['Title.FontColor'] := AlphaColorToString(MTitleFontColor);
  end;
end;

function EncrypKey(Src:string; Key:string): string;
var
  KeyLen,KeyPos: Integer;
  offset: Integer;
  dest: string;
  SrcPos,SrcAsc,Range: Integer;
begin
  KeyLen := Length(Key);
  if KeyLen = 0 then Key := '233acgrid998';
  KeyPos := 0;
  Range := 256;

  Randomize;
  offset := Random(Range);
  dest := format('%1.2x',[offset]);
  for SrcPos := 1 to Length(Src) do begin
    SrcAsc := (Ord(Src[SrcPos]) + offset) mod 255;
    if KeyPos < KeyLen then KeyPos := KeyPos + 1 else KeyPos:=1;
    SrcAsc := SrcAsc xor Ord(Key[KeyPos]);
    dest := dest + format('%1.2x',[SrcAsc]);
    offset := SrcAsc;
  end;
  Result := dest;
end;

function UncrypKey(Src:string; Key:string): string;
var
  KeyLen,KeyPos: Integer;
  offset: Integer;
  dest: string;
  SrcPos,SrcAsc,TmpSrcAsc: Integer;
begin
  KeyLen := Length(Key);
  if KeyLen = 0 then key := '233acgrid998';
  KeyPos := 0;
  offset := StrToInt('$'+ Copy(src,1,2));
  SrcPos := 3;
  repeat
    SrcAsc := StrToInt('$'+ Copy(src,SrcPos,2));
    if KeyPos < KeyLen then KeyPos := KeyPos + 1 else KeyPos := 1;
    TmpSrcAsc := SrcAsc xor Ord(Key[KeyPos]);
    if TmpSrcAsc <= offset then
      TmpSrcAsc := 255 + TmpSrcAsc - offset
    else
      TmpSrcAsc := TmpSrcAsc - offset;
    dest := dest + chr(TmpSrcAsc);
    offset := srcAsc;
    SrcPos := SrcPos + 2;
  until SrcPos >= Length(Src);
  Result := Dest;
end;

procedure TfrmControl.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TerminateThreads;
  SaveSetting;
  SysReady := False;
  frmConfig.Close;
  frmLog.Close;
end;

procedure TfrmControl.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  {$IFNDEF DEBUG}
  {$IFDEF PASSWORD_CLOSE}
  if btnAdmin.Visible then begin
    CanClose := false;
    StatusBar.Panels[0].Text := '关你妹';
    exit;
  end;
  {$ENDIF}
  CanClose := Boolean(Application.MessageBox('确认?','退出',MB_ICONQUESTION + MB_YESNO) = IDYES);
  {$ENDIF}
end;

procedure TfrmControl.btnHideCtrlClick(Sender: TObject);
begin
  SetWindowPos(Self.Handle,HWND_NOTOPMOST,Self.Left,Self.Top,Self.Width,Self.Height,SWP_NOACTIVATE);
  Self.Hide;
end;

procedure TfrmControl.EditDispatchKeyChange(Sender: TObject);
var
  Key : Word;
  Shift : TShiftState;
begin
  try
    UnRegisterHotKey(handle,DispatchKey);
    GlobalDeleteAtom(DispatchKey);
    ShortCutToKey(EditDispatchKey.HotKey,Key,Shift);
    DispatchKey := GlobalAddAtom('RTCCDispatchHotkey');
    RegisterHotKey(handle,DispatchKey,ShiftStateToInt(Shift),Key);
  except on E: Exception do
    LogEvent('快捷键设置失败: '+E.Message, logException);
  end;
end;

procedure TfrmControl.WMHotKey(var Msg : TWMHotKey);  //HOTKEY DISPATCHER
begin
  if Msg.HotKey = DispatchKey then begin
    frmControl.Left := 0;
    frmControl.Show;
  end;
end;

function ShiftStateToInt(Shift: TShiftState): Cardinal;
begin
  Result := 0;
  if ssShift in Shift then Result := Result + MOD_SHIFT;
  if ssAlt in Shift then Result := Result + MOD_ALT;
  if ssCtrl	in Shift then Result := Result + MOD_CONTROL;
end;

procedure TfrmControl.editNetPasswordChange(Sender: TObject);
begin
  SharedConfigurationMutex.Acquire;
  try
    NetPassword := editNetPassword.Text;
  finally
    SharedConfigurationMutex.Release;
  end;
end;

procedure TfrmControl.editNetPortChange(Sender: TObject);
var
  Port : Integer;
begin
  Port := StrToIntDef(editNetPort.Text,65536);
  if (Port <= 0) or (Port > 65535) then begin
    editNetPort.Text := '9233';
    Application.MessageBox('端口号范围：1-65535。','错误',MB_ICONEXCLAMATION);
  end
  else
    CommUDPPort := Port;
end;

procedure TfrmControl.editOfficialCommentDurationChange(Sender: TObject);
begin
  OfficialDuration := StrToIntDef(editOfficialCommentDuration.Text, 5000);
end;

procedure TfrmControl.cobNetCFontSizeKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not CharInSet(Key,['0'..'9', #8, #13, #27]) then Key := #0;
end;

procedure TfrmControl.cobOfficialCFontSizeKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not CharInSet(Key,['0'..'9', #8, #13, #27]) then Key := #0;
end;

procedure TfrmControl.editTimingInvChange(Sender: TObject);
begin
  //frmComment.TimerMoving.Interval := StrToIntDef(editTimingInv.Text,50);
end;

procedure TfrmControl.EdtNetDelayChange(Sender: TObject);
begin
  NetDelayDuration := StrToIntDef(EdtNetDelay.Text, 3000);
end;

procedure TfrmControl.editStdShowTimeChange(Sender: TObject);
begin
  NetDefaultDuration := StrToIntDef(EditStdShowTime.Text, 3000);
end;

procedure TfrmControl.btnNetStartClick(Sender: TObject);
begin
  if Networking then begin
    {if Transmit then begin
      editNetPort.Enabled := True;
      radioNetPasv.Enabled := True;
      radioNetPort.Enabled := True;
      Transmit := False;
      LogEvent('TCP转发服务已关闭');
    end
    else }if IdUDPServerCCRecv.Active then begin
      IdUDPServerCCRecv.Active := False;
      RadioGroupModes.Enabled := True;
      editNetPort.Enabled := True;
      editNetHost.Enabled := True;
      editNetPassword.Enabled := True;
      LogEvent('UDP监听关闭，停止接收网络弹幕');
    end
    else begin
      if Assigned(HThread) then HThread.Terminate;
      RadioGroupModes.Enabled := True;
      editNetPassword.Enabled := True;
      editNetHost.Enabled := True;
      LogEvent('正在关闭HTTP抓取，停止接收网络弹幕');
      RemoteTime := 0;
    end;
    Networking := False;
    btnNetStart.Caption := '开始通信(&M)';
  end
  else begin
    case RadioGroupModes.ItemIndex of
      0: begin
        try
          IdUDPServerCCRecv.Active := False;
          IdUDPServerCCRecv.Bindings.Clear;

          with IdUDPServerCCRecv.Bindings.Add do begin
            IPVersion := Id_IPv4;
            IP := '0.0.0.0';
            Port := CommUDPPort;
          end;

          with IdUDPServerCCRecv.Bindings.Add do begin
            IPVersion := Id_IPv6;
            IP := '::';
            Port := CommUDPPort;
          end;

          IdUDPServerCCRecv.ThreadClass := TUDPHandleThread;
          IdUDPServerCCRecv.ThreadedEvent := True;
          IdUDPServerCCRecv.Active := True;
          Networking := True;
          btnNetStart.Caption := '停止通信(&M)';
          RadioGroupModes.Enabled := False;
          editNetPort.Enabled := False;
          editNetPassword.Enabled := False;
          LogEvent('UDP监听启动于端口 ' + editNetPort.Text);
        except on E: Exception do
          LogEvent('UDP启动异常：' + E.Message, logException);
        end;
      end;
      1: begin
        if Assigned(HThread) then begin
          if HThread.Finished then
            HThread.Free
          else begin
            LogEvent('HTTP线程尚未退出，无法启动。', logWarning);
            Exit;
          end;
        end;
        LogEvent('创建并启动HTTP线程');
        HThread := THTTPWorkerThread.Create(editNetHost.Text,
          NetPassword,TimeZoneBias,
          {$IFDEF DEBUG}APP_DIR+'HTTP.log'{$ELSE}''{$ENDIF}); // Auto Start!
      end;
      2: begin
        LogEvent('暂未实现TCP转发',logError);
      end;
      else begin
        LogEvent('未知模式。',logError);
      end;
    end;
  end;
end;

procedure TfrmControl.cobNetCFontNameChange(Sender: TObject);
begin
  NetDefaultFontName := cobNetCFontName.Items.Strings[cobNetCFontName.ItemIndex];
  if frmDemo.Visible then frmDemo.NetCDemo.Font.Name := NetDefaultFontName;
end;

procedure TfrmControl.cobNetCFontSizeChange(Sender: TObject);
var
  FontSize: Integer;
begin
  FontSize := StrToIntDef(cobNetCFontSize.Text,20);
  NetDefaultFontSize := FontSize.ToDouble;
  if frmDemo.Visible then frmDemo.NetCDemo.Font.Size := FontSize;
end;

procedure TfrmControl.cobNetCFontBoldClick(Sender: TObject);
begin
  if cobNetCFontBold.Checked then begin
    NetDefaultFontStyle := 1;
    if frmDemo.Visible then frmDemo.NetCDemo.Font.Style := [fsBold];
  end
  else begin
    NetDefaultFontStyle := 0;
    if frmDemo.Visible then frmDemo.NetCDemo.Font.Style := [];
  end;
end;

procedure TfrmControl.cobOfficialCFontNameChange(Sender: TObject);
begin
  OfficialFontName := cobOfficialCFontName.Items.Strings[cobOfficialCFontName.ItemIndex];
  if frmDemo.Visible then frmDemo.OfficialCDemo.Font.Name := OfficialFontName;
end;

procedure TfrmControl.cobOfficialCFontSizeChange(Sender: TObject);
var
  FontSize: Integer;
begin
  FontSize := StrToIntDef(cobOfficialCFontSize.Text,20);
  OfficialFontSize := FontSize.ToDouble;
  if frmDemo.Visible then frmDemo.OfficialCDemo.Font.Size := FontSize;
end;

procedure TfrmControl.cobOfficialCFontBoldClick(Sender: TObject);
begin
  if cobOfficialCFontBold.Checked then begin
    OfficialFontStyle := 1;
    if frmDemo.Visible then frmDemo.OfficialCDemo.Font.Style := [fsBold];
  end
  else begin
    OfficialFontStyle := 0;
    if frmDemo.Visible then frmDemo.OfficialCDemo.Font.Style := [];
  end;
end;

procedure TfrmControl.grpSpecialEffectsClick(Sender: TObject);
begin
  case grpSpecialEffects.ItemIndex of
    0 : editOfficialCommentPara.Enabled := True;
    1,2 : editOfficialCommentPara.Enabled := False;
  end;
  if editOfficialCommentPara.Enabled = False then editOfficialCommentPara.Text := '1';
end;

procedure TfrmControl.grpTimingClick(Sender: TObject);
begin
  case grpTiming.ItemIndex of
    0 : begin
      InternalTImeOffset := 0;
    end;
    1 : begin
      if RemoteTime <> 0 then InternalTimeOffset := RemoteTimeOffset else Application.MessageBox('远程时间未知','ERROR',MB_ICONEXCLAMATION);
    end;
    2 : begin
      InternalTimeOffset := StrToTimeDef(InputBox('更改时间轴','将内部时间修改为：   ',TimeToStr(Time())),Time())-Time();
    end;
  end;
end;

procedure TfrmControl.btnClearListClick(Sender: TObject);
begin
  SysReady := False;
  ListViewOffset := ListComments.Items.Count;
  ListComments.Items.Clear;
  SysReady := True;
end;

procedure TfrmControl.BtnConfigClick(Sender: TObject);
begin
  frmConfig.Show;
end;

procedure TfrmControl.BtnFreezingClick(Sender: TObject);
begin
  if Freezing then begin
    InternalTimeOffset := InternalTimeOffset - (Time() - FreezingTime);
  end
  else begin
    FreezingTime := Time();
  end;
  Freezing := not Freezing;
end;

procedure TfrmControl.ListCommentsDblClick(Sender: TObject);
begin
  if ListComments.SelCount > 0 then begin
    try
      editOfficialComment.Text := ListComments.Selected.SubItems.Strings[T_TEXT];
    except
      Exit;
    end;
  end;
end;

procedure TfrmControl.ListCommentsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  CommentID: Integer;
begin
  if (Key = VK_Delete) and (ListComments.SelCount > 0) then begin
    ListComments.Selected.SubItems.Strings[T_TEXT] := '(已删除)';
    ListComments.Selected.Caption := 'R';
    CommentID := StrToInt(ListComments.Selected.SubItems.Strings[T_ID]);
    CommentPoolMutex.Acquire;
    try
      with CommentPool.Items[CommentID] do begin
        Content := '';
        Status := TCommentStatus.Removed;
      end;
    finally
      CommentPoolMutex.Release;
    end;
  end;
end;

function AlphaColorToColor(Alpha: TAlphaColor): TColor;
begin
  Result := Alpha and $00FFFFFF; // 00BBGGRR
end;

function ColorToAlphaColor(Color: TColor; Opacity: Byte): TAlphaColor;
begin
  Result := (Color and $00FFFFFF) or (Opacity shl 24); // AABBGGRR
end;

function BGRToRGB(AColor: TAlphaColor): TAlphaColor;
var
  ChRed, ChBlue: Cardinal;
begin
  // TAlphaColor in GDI+ seems AARRGGBB while Delphi defines as AABBGGRR
  ChRed := (AColor and $000000FF) shl 16;
  ChBlue := (AColor and $00FF0000) shr 16;
  Result := (AColor and $FF00FF00) or ChRed or ChBlue;
end;

initialization
  CoInitialize(nil);
  DefaultSA.nLength := SizeOf(TSecurityAttributes);
  DefaultSA.lpSecurityDescriptor := nil;
  DefaultSA.bInheritHandle := False;
  CommentPoolMutex := TMutex.Create(@DefaultSA,True,'main_pool_m');
  SharedConfigurationMutex := TMutex.Create(@DefaultSA,True,'shared_cfg_m');
  GraphicSharedMutex := TMutex.Create(@DefaultSA,True,'shared_gui_m');
  HexieMutex := TMutex.Create(@DefaultSA,True,'shared_hx_m');
  //HTTPSharedMutex := TMutex.Create(@DefaultSA,True,'shared_http_m');
  LiveCommentPoolMutex := TMutex.Create(@DefaultSA,True,'live_pool_m');
  UpdateQueueMutex := TMutex.Create(@DefaultSA,True,'render_queue_m');
  DispatchS := TSemaphore.Create(@DefaultSA,0,1024,'dispatch_s',False);
  UpdateS := TSemaphore.Create(@DefaultSA,0,1024,'update_s',False);

finalization
  CommentPoolMutex.Free();
  SharedConfigurationMutex.Free();
  GraphicSharedMutex.Free();
  HexieMutex.Free;
  //HTTPSharedMutex.Free();
  LiveCommentPoolMutex.Free();
  UpdateQueueMutex.Free();
  DispatchS.Free();
  UpdateS.Free();
  CoUninitialize();

end.
