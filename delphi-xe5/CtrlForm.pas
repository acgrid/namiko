{$DEFINE DEV}
unit CtrlForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, TntStdCtrls, ExtCtrls, TntExtCtrls, ComCtrls,
  TntComCtrls, IniFiles, TntDialogs, TntWideStrings, Menus,
  Math, IdTCPServer, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, CoolCtrls, XMLDoc, XMLIntf,
  IdContext, IdIntercept, IdServerInterceptLogBase, IdServerInterceptLogFile,
  IdCustomTCPServer, Dialogs,
  IdSocketHandle, IdGlobal,
  IdCmdTCPServer, StrUtils, DateUtils, IdLogBase, IdLogFile,
  TntClasses, ShellAPI, ActiveX, TntSysUtils, IdExceptionCore, ThreadTimer,
  MMTimer;
  
const
  NamikoTrayMessage = WM_USER + 233;

  KEY = 'saf32459090sua0fj23jnroiahfaj23-ir512nmrpaf314';

  L_Console = '控制台';
  L_XMLFile = '文件';
  DET = #9+#9;
  CRLF = #13+#10;
  L_KEY = 'KEY=';
  L_TIME = 'TIME=';
  L_LEN = 'LEN=';
  L_FORMAT = 'FORMAT=';
  L_CONTENT = 'TEXT=';
  L_IP = 'IP=';

  T_LTIME = 0;
  T_RTIME = 1;
  T_TEXT = 2;
  T_SRC = 3;
  T_FORMAT = 4;
  T_DISP = 5;
  T_CYCLE = 6;
  T_OCTIME = 7;
  T_STATUS = 8;

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

{type
  TAuthorSource = (Internet, Console);}
type
  TNetResult = (OK, BadFormat, BadKey, BadTime, BadData, BadLen, Hexied, IntErr);
{type
  TAuthor = record
    Source: TAuthorSource;
    IPAddress: String;
  end;}
type
  TCommentEffectType = (Scroll, UpperFixed, LowerFixed);
type
  TCommentEffect = record
    Display: TCommentEffectType;
    StayTime: SmallInt;
    RepeatCount: SmallInt;
    Speed: SmallInt;
  end;
type
  TCommentStatus = (Created, Pending, Starting, Waiting, Displaying, Removing, Removed);
type
  TComment = record
    ID: Integer;
    //Time: TTime;
    Content: WideString;
    //Length: Cardinal;
    //Author: TAuthor;
    Font: WideString;
    Effect: TCommentEffect;
    Status: TCommentStatus;
    ControlIndex: SmallInt;
    ChannelLayer: Integer;
    ChannelFrom: Integer;
    ChannelTo: Integer;
  end;
type
  PComment = ^TComment;
type
  TfrmControl = class(TForm)
    grpCCWindow: TTntGroupBox;
    btnCCWork: TTntButton;
    btnCCShow: TButton;
    TimerGeneral: TTimer;
    grpGuestCommentSet: TTntGroupBox;
    grpOfficialComment: TTntGroupBox;
    editOfficialComment: TTntEdit;
    cobNetCFontName: TTntComboBox;
    cobOfficialCFontName: TTntComboBox;
    btnOfficialSend: TTntButton;
    grpSpecialEffects: TTntRadioGroup;
    editOfficialCommentPara: TLabeledEdit;
    grpTiming: TTntRadioGroup;
    Statusbar: TTntStatusBar;
    ListComments: TTntListView;
    grpComm: TTntGroupBox;
    radioNetPasv: TTntRadioButton;
    radioNetPort: TTntRadioButton;
    editNetPassword: TLabeledEdit;
    editNetPort: TLabeledEdit;
    editNetHost: TLabeledEdit;
    btnOpenFilter: TButton;
    btnSaveComment: TButton;
    btnLoadComment: TButton;
    grpDebug: TGroupBox;
    btnAdmin: TButton;
    Log: TTntMemo;
    btnExit: TTntButton;
    cobNetCFontSize: TTntComboBox;
    cobNetCFontColor: TShape;
    ColorDialog: TColorDialog;
    cobNetCFontBold: TTntCheckBox;
    cobOfficialCFontSize: TTntComboBox;
    cobOfficialCFontBold: TTntCheckBox;
    cobOfficialCFontColor: TShape;
    btnNetStart: TTntButton;
    SaveDialog: TTntSaveDialog;
    HTTPClient: TIdHTTP;
    btnEscAll: TTntButton;
    btnHideCtrl: TTntButton;
    EditDispatchKey: THotKey;
    lblCallConsole: TLabel;
    btnSetFixedLabel: TButton;
    editTimingInv: TLabeledEdit;
    editTimingInvUpDown: TTntUpDown;
    editOfficialCommentParaUpDown: TTntUpDown;
    editStdShowTime: TLabeledEdit;
    EditStdShowTimeUpDown: TTntUpDown;
    editOfficialCommentDuration: TLabeledEdit;
    InSocket: TIdTCPServer;
    ChkAutoStartNet: TTntCheckBox;
    btnClearList: TTntButton;
    btnExControl: TButton;
    TCPLogFile: TIdServerInterceptLogFile;
    Button1: TButton;
    TimerFetch: TTimer;
    TimerAddComment: TTimer;
    Button2: TButton;
    radioNetTransmit: TTntRadioButton;
    editOfficialCommentDurationUpDown: TTntUpDown;
    EditFetchInv: TLabeledEdit;
    HTTPLog: TIdLogFile;
    EditFetchInvUpDown: TUpDown;
    BtnFreezing: TTntButton;
    DelayProgBar: TTntProgressBar;
    DelayLabel: TTntLabel;
    TimerUpdate: TTimer;
    EdtNetDelay: TLabeledEdit;
    procedure btnCCShowClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCCWorkClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TimerGeneralTimer(Sender: TObject);
    procedure btnSetFixedLabelClick(Sender: TObject);
    procedure btnOpenFilterClick(Sender: TObject);
    procedure btnAdminClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure cobNetCFontColorMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure cobOfficialCFontColorMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure radioNetPortClick(Sender: TObject);
    procedure radioNetPasvClick(Sender: TObject);
    procedure btnOfficialSendClick(Sender: TObject);
    procedure btnLoadCommentClick(Sender: TObject);
    procedure btnSaveCommentClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnHideCtrlClick(Sender: TObject);
    procedure EditDispatchKeyChange(Sender: TObject);
    procedure editNetPortChange(Sender: TObject);
    procedure cobNetCFontSizeKeyPress(Sender: TObject; var Key: Char);
    procedure cobOfficialCFontSizeKeyPress(Sender: TObject; var Key: Char);
    procedure editTimingInvChange(Sender: TObject);
    procedure editStdShowTimeChange(Sender: TObject);
    procedure btnNetStartClick(Sender: TObject);
    procedure InSocketExecute(AContext: TIdContext);
    procedure InSocketConnect(AContext: TIdContext);
    procedure cobNetCFontNameChange(Sender: TObject);
    procedure cobNetCFontSizeChange(Sender: TObject);
    procedure cobNetCFontBoldClick(Sender: TObject);
    procedure cobOfficialCFontNameChange(Sender: TObject);
    procedure cobOfficialCFontSizeChange(Sender: TObject);
    procedure cobOfficialCFontBoldClick(Sender: TObject);
    procedure btnEscAllClick(Sender: TObject);
    procedure btnExControlClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TimerFetchTimer(Sender: TObject);
    procedure TimerAddCommentTimer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure grpSpecialEffectsClick(Sender: TObject);
    procedure ListCommentsChanging(Sender: TObject; Item: TListItem;
      Change: TItemChange; var AllowChange: Boolean);
    procedure ListCommentsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure grpTimingClick(Sender: TObject);
    procedure btnClearListClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure EditFetchInvChange(Sender: TObject);
    procedure radioNetTransmitClick(Sender: TObject);
    procedure BtnFreezingClick(Sender: TObject);
    procedure TimerAddOCTimer(Sender: TObject);
    procedure TimerUpdateTimer(Sender: TObject);
    procedure ListCommentsDblClick(Sender: TObject);
    procedure ListCommentsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    { Private declarations }
    CCWindowShow, CCWindowWorking, Fetching, AddOCWorking : Boolean;
    DispatchKey : Integer;
    HTTPURL : String;
    LastHTTPRequest : Int64;
    XMLDelay : Integer;
    FreezingTime : TTime;

    CommentIndex : Array of TTime;

    procedure WindowTrayMessage(var Message: TMessage);
    message NamikoTrayMessage;
    procedure WMHotKey(var Msg : TWMHotKey); message WM_HOTKEY;

    procedure DisconnectAll();
    function GetCommentCount(): Integer;
    procedure LoadSetting();
    procedure SaveSetting();
    procedure TestHTTPClient();
    function ParseLineData(Request: WideString): TNetResult;
    procedure ParseFontData(var Format: String);
    procedure SetSW(Index: Integer; Status: Word; Mask: Word=0);
    function QuerySW(Index: Integer; Status: Word; Mask: Word=65535): Boolean;
    function GetCommentEffect(Index: Integer): TCommentEffect;
    function FindLastIndex(FarestTime: TTime): Integer;
  public
    { Public declarations }
    TimeZoneBias: Integer;
    RemoteTime, InternalTime, RemoteTimeOffset, InternalTimeOffset : TTime;
    Networking, SysReady, Transmit, Freezing: Boolean;
    CurrListIndex: Integer;
    ClearedItemCount: Integer;
    TimerAddOC: TThreadTimer;
    procedure LogEvent(Info: WideString);
    procedure SubmitComment(RecvTime: TTime; Content: WideString; Source: String; Font: WideString; Effect: TCommentEffect; Bad: Boolean=false);    
    procedure NotifyCommentStatus(ID: Integer; Status: TCommentStatus);
    procedure NotifyDelay(Second: Word);
  end;

var
  frmControl: TfrmControl;
  APP_DIR: String;
  TrayIconData: TNotifyIconData;

function EncrypKey(Src:String; Key:String): String;
function UncrypKey(Src:String; Key:String): String;

procedure SetFontData(Src: String; var Dest: TFont);
function GetFontData(Src: TFont): WideString;

function ShiftStateToInt(Shift: TShiftState): Cardinal;
function StreamToWideString(AStream: TStream): WideString;

function SplitString(Source, Deli: WideString): TTntStringList; stdcall;
function SetKeyValue(SrcList: TTntStringList): TTntStringList;

procedure SetStatusWord(var SW: Word; Value: Word; Mask: Word=0);
function QueryStatusWord(SW: Word; Value: Word; Mask: Word=65535): Boolean;

implementation

{$R *.dfm}
uses
  CCommentForm, HexieForm, XMLLoadForm;

procedure TfrmControl.btnCCShowClick(Sender: TObject);
begin
  if CCWindowShow then begin
    CCWindowShow := false;
    btnCCShow.Caption := '显示(&S)';
    frmComment.Hide;
  end
  else begin
    CCWindowShow := true;
    btnCCShow.Caption := '隐藏(&H)';
    frmComment.Show;
  end;
end;

procedure TfrmControl.WindowTrayMessage(var Message: TMessage);
begin
  if Message.Msg = NamikoTrayMessage then begin
    case Message.LParam of
      WM_LBUTTONUP:
      begin
        ShowWindow(Application.Handle,SW_NORMAL);
        SetForegroundWindow(Application.Handle);
      end;
    end;
  end;
end;

procedure TfrmControl.FormCreate(Sender: TObject);
var
  Key : Word;
  Shift : TShiftState;
  m_timezone : TIME_ZONE_INFORMATION;
begin
  CoInitialize(nil);
  //Init Interface
  StatusBar.Panels[0].Width := Width - 610;
  StatusBar.Panels[2].Text := '显示/总共 0/0';
  {$IFNDEF DEV}
  Width := 870;
  Constraints.MaxWidth := 870;
  {$ENDIF}
  CCWindowShow := false;
  CCWindowWorking := false;
  Networking := false;
  Transmit := false;
  Fetching := false;
  Freezing := false;
  AddOCWorking := false;
  //Set Variable & UI
  CurrListIndex := 0;
  ClearedItemCount := 0;
  XMLDelay := 0;
  //Set Internal Time as System Time
  InternalTime := Time();
  InternalTimeOffset := 0;
  //Set Timezone
  GetTimeZoneInformation(m_timezone);
  TimeZoneBias := m_timezone.Bias * 60;
  LastHTTPRequest := DateTimeToUnix(Now())+TimeZoneBias;
  //Fetch Font List
  cobNetCFontName.Items.AddStrings(Screen.Fonts);
  cobOfficialCFontName.Items.AddStrings(Screen.Fonts);
  //Load Settings
  APP_DIR := ExtractFilePath(ParamStr(0));
  LoadSetting(); // Call After APP_DIR
  //Set Path
  SaveDialog.InitialDir := APP_DIR;
  TCPLogFile.Filename := APP_DIR+'TCPServer.log';
  HTTPLog.Filename := APP_DIR+'HTTPClient.log';
  //Register Hotkey
  try
    ShortCutToKey(EditDispatchKey.HotKey,Key,Shift);
    DispatchKey := GlobalAddAtom('RTCCDispatchHotkey');
    RegisterHotKey(handle,DispatchKey,ShiftStateToInt(Shift),Key);
  except
    LogEvent('[异常] 快捷键设置失败');
  end;
  //Init Timer
  TimerAddOC := TThreadTimer.Create(20,TimerAddOCTimer);
  //Register Tray Icon
  TrayIconData.cbSize := SizeOf(TrayIconData);
  TrayIconData.uFlags := NIF_ICON or NIF_TIP or NIF_MESSAGE;
  TrayIconData.uID := UINT(Self);
  TrayIconData.Wnd := Handle;
  TrayIconData.hIcon := Application.Icon.Handle;
  StrCopy(@TrayIconData.szTip,PChar(Application.Title));
  TrayIconData.uCallbackMessage := NamikoTrayMessage;
  Shell_NotifyIcon(NIM_ADD,@TrayIconData);
  //Set Digit-Only TEdits
  SetWindowLong(editOfficialCommentDuration.Handle, GWL_STYLE, GetWindowLong(editOfficialCommentDuration.Handle, GWL_STYLE) or ES_NUMBER);
  SetWindowLong(editOfficialCommentPara.Handle, GWL_STYLE, GetWindowLong(editOfficialCommentPara.Handle, GWL_STYLE) or ES_NUMBER);
  SetWindowLong(editNetPort.Handle, GWL_STYLE, GetWindowLong(editNetPort.Handle, GWL_STYLE) or ES_NUMBER);
  SetWindowLong(editTimingInv.Handle, GWL_STYLE, GetWindowLong(editTimingInv.Handle, GWL_STYLE) or ES_NUMBER);
  SetWindowLong(editFetchInv.Handle, GWL_STYLE, GetWindowLong(editFetchInv.Handle, GWL_STYLE) or ES_NUMBER);
  //Notify Complete
  LogEvent('初始化完毕');
  StatusBar.Panels[0].Text := '控制台初始化完毕';
 end;

procedure TfrmControl.btnCCWorkClick(Sender: TObject);
begin
  if CCWindowWorking then begin
    CCWindowWorking := false;
    btnCCWork.Caption := '进入运作模式(&W)';
    with frmComment do begin
      BorderStyle := bsSizeable;
      TransparentColor := false;
      TimerMonitor.Enabled := true;
      Monitor.Visible := true;
      NetCDemo.Visible := true;
      OfficialCDemo.Visible := true;
    end;
    //SetWindowPos(frmComment.Handle,HWND_NOTOPMOST,frmComment.Left,frmComment.Top,frmComment.Width,frmComment.Height,SWP_NOACTIVATE or SWP_SHOWWINDOW);
    SetWindowPos(Self.Handle,HWND_NOTOPMOST,Self.Left,Self.Top,Self.Width,Self.Height,SWP_NOACTIVATE or SWP_SHOWWINDOW);
  end
  else begin
    CCWindowWorking := true;
    btnCCWork.Caption := '回到调试模式(&I)';
    with frmComment do begin
      BorderStyle := bsNone;
      TransparentColor := true;
      TimerMonitor.Enabled := false;
      Monitor.Visible := false;
      NetCDemo.Visible := false;
      OfficialCDemo.Visible := false;
    end;
    SetWindowPos(Self.Handle,HWND_TOPMOST,Self.Left,Self.Top,Self.Width,Self.Height,SWP_NOACTIVATE or SWP_SHOWWINDOW);
    //frmComment.SetWindowTop;
  end;
end;

procedure TfrmControl.FormResize(Sender: TObject);
begin
  StatusBar.Panels[0].Width := Width - 610;
end;

procedure TfrmControl.TimerGeneralTimer(Sender: TObject);
begin
  {case grpTiming.ItemIndex of
    0: InternalTime := Time();
    1,2: if not Freezing then InternalTime := InternalTime + TimerGeneral.Interval / 86400000;
  end;
  if RemoteTime <> 0 then RemoteTime := RemoteTime + TimerGeneral.Interval / 86400000;}
  StatusBar.Panels[1].Text := '显示中/容量 ' + IntToStr(frmComment.DisplayingCommentCount()) + '/' + IntToStr(frmComment.DisplayCapacity());
  StatusBar.Panels[2].Text := '已显示/总共 ' + IntToStr(frmComment.DisplayedCommentCount) + '/' + IntToStr(GetCommentCount());
  StatusBar.Panels[3].Text := '内部 '+TimeToStr(InternalTime);
  StatusBar.Panels[4].Text := '远程 '+Ifthen(Boolean(RemoteTime = 0),'未知',TimeToStr(RemoteTime));
  StatusBar.Panels[5].Text := '本地 '+TimeToStr(Time());
end;

procedure TfrmControl.btnSetFixedLabelClick(Sender: TObject);
begin
  with frmComment do begin
    TestLabel.Font := OfficialCDemo.Font;
    TestLabel.Caption := Tnt_WideStringReplace(editOfficialComment.Text,'/n',#13,[rfReplaceAll]);
  end;
end;

procedure TfrmControl.btnOpenFilterClick(Sender: TObject);
begin
  frmWordList.Show;
end;

procedure TfrmControl.btnAdminClick(Sender: TObject);
begin
  if InputBox('管理模式','请输入密码　　','') = 'CT356' then begin
    Constraints.MaxWidth := 1180;
    Width := 1180;
    btnAdmin.Visible := false;
  end;
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
    frmComment.NetCDemo.Font.Color := ColorDialog.Color;
  end;
end;

procedure TfrmControl.cobOfficialCFontColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := cobOfficialCFontColor.Brush.Color;
  if ColorDialog.Execute then begin
    cobOfficialCFontColor.Brush.Color := ColorDialog.Color;
    frmComment.OfficialCDemo.Font.Color := ColorDialog.Color;
  end;
end;

procedure TfrmControl.radioNetPortClick(Sender: TObject);
begin
  radioNetPort.Checked := true;
  editNetHost.Enabled := true;
  editNetPort.Enabled := false;
end;

procedure TfrmControl.radioNetPasvClick(Sender: TObject);
begin
  radioNetPasv.Checked := true;
  editNetHost.Enabled := false;
  editNetPort.Enabled := true;
end;

procedure TfrmControl.btnOfficialSendClick(Sender: TObject);
var
  Content, Format: WideString;
  Effect: TCommentEffect;
  RTime: TTime;

  Line : String;
  CList : TList;
  i : Integer;
begin
  Content := TrimRight(editOfficialComment.Text);
  if Length(Content) = 0 then exit;
  If frmWordList.Hexied(Content) then begin
    if Application.MessageBox('检测到敏感词，继续吗？','河蟹已经阻止不了你了么',MB_ICONQUESTION + MB_YESNO) = IDNO then begin
      editOfficialComment.Clear;
      editOfficialComment.SetFocus;
      exit;
    end;
  end;

  case grpSpecialEffects.ItemIndex of
  0: Effect.Display := Scroll;
  1: Effect.Display := UpperFixed;
  2: Effect.Display := LowerFixed;
  end;
  Effect.StayTime := StrToInt(editOfficialCommentDuration.Text);
  Effect.RepeatCount := ifthen(Boolean(Effect.Display = Scroll),StrToInt(editOfficialCommentPara.Text),1);

  {case GrpTiming.ItemIndex of
    0,2: RTime := InternalTime+EncodeTime(0,0,0,100);
    1: RTime := Time();
  end;}

  RTime := InternalTime + EncodeTime(0,0,0,300);

  Format := GetFontData(frmComment.OfficialCDemo.Font);

  SubmitComment(RTime,Content,L_Console,Format,Effect);

  editOfficialComment.Clear;
  editOfficialComment.SetFocus;
  // Broadcast
  if Transmit then begin
    Line := UTF8Encode('DATA VER=1'+DET+'KEY='+editNetPassword.Text+DET+'TIME='+IntToStr(DateTimeToUnix(Now())+TimeZoneBias)+DET+'IP='+L_CONSOLE+DET+'FORMAT='+Format+DET+'LEN='+IntToStr(Length(Content))+DET+'TEXT='+Content+DET+CRLF);
    try
      cList := InSocket.Contexts.LockList;
      for i := 0 to cList.Count - 1 do begin
        TIdContext(cList[i]).Connection.IOHandler.WriteLn(Line,TIdTextEncoding.Default);
      end;
    finally
      InSocket.Contexts.UnlockList;
    end;
  end;
end;

procedure TfrmControl.btnLoadCommentClick(Sender: TObject);
begin
  frmLoadXML.Show();
  frmLoadXML.Test;
end;

procedure TfrmControl.btnSaveCommentClick(Sender: TObject);
var
  XMLDoc : TXMLDocument;
  DocIntf : IXMLDocument;
  RootNode, CNode : IXMLNode;
  i : Integer;
begin
  if SaveDialog.Execute then begin
    XMLDoc := TXMLDocument.Create(nil);
    DocIntf := XMLDoc;
    try
      XMLDoc.Active := true;
      XMLDoc.Encoding := 'utf-8';
      XMLDoc.Options := XMLDoc.Options + [doNodeAutoIndent];
      RootNode := XMLDoc.AddChild('Namiko');
      for i := 0 to ListComments.Items.Count - 1 do begin
        CNode := RootNode.AddChild('comment');
        with ListComments.Items.Item[i].SubItems do begin
          CNode.AddChild('time').Text := Strings[T_RTIME];
          CNode.AddChild('content').Text := Strings[T_TEXT];
          CNode.AddChild('format').Text := Strings[T_FORMAT];
          CNode.AddChild('repeat').Text := Strings[T_CYCLE];
          CNode.AddChild('duration').Text := Strings[T_OCTIME];
          CNode.AddChild('data').Text := Strings[T_STATUS];
        end;
      end;
      XMLDoc.SaveToFile(SaveDialog.FileName);
    except
      LogEvent('有异常发生 自行检查是否保存成功（拖');
      DocIntf := nil;
    end;
  end;
end;

procedure TfrmControl.LogEvent(Info: WideString);
begin
  StatusBar.Panels[0].Text := Info;
  Log.Lines.Add(TimeToStr(Now())+' '+Info);
  Log.Lines.SaveToFile(APP_DIR+'Namiko.log');
end;

procedure TfrmControl.LoadSetting();
var
  ini : TCustomIniFile;
begin
  ini := TINIFile.Create(APP_DIR+'Settings.ini');
  // Internet Comment Format
  cobNetCFontName.ItemIndex := cobNetCFontName.Items.IndexOf(ini.ReadString('NetComment','FontName','微软雅黑'));
  cobNetCFontSize.Text := ini.ReadString('NetComment','FontSize','18');
  cobNetCFontColor.Brush.Color := StringToColor(ini.ReadString('NetComment','FontColor','clWhite'));
  cobNetCFontBold.Checked := ini.ReadBool('NetComment','FontBold',false);
  // Official Comment Format
  cobOfficialCFontName.ItemIndex := cobOfficialCFontName.Items.IndexOf(ini.ReadString('OfficialComment','FontName','微软雅黑'));
  cobOfficialCFontSize.Text := ini.ReadString('OfficialComment','FontSize','26');
  cobOfficialCFontColor.Brush.Color := StringToColor(ini.ReadString('OfficialComment','FontColor','clBlue'));
  cobOfficialCFontBold.Checked := ini.ReadBool('OfficialComment','FontBold',true);
  // Network Config
  {if ini.ReadBool('Connection','Transmit',false) then begin
    radioNetTransmit.OnClick(self);
  else begin}
  if ini.ReadBool('Connection','Passive',true) then radioNetPasv.OnClick(self) else radioNetPort.OnClick(self);
  editNetPort.Text := ini.ReadString('Connection','Port','7233');
  editNetHost.Text := ini.ReadString('Connection','Host','http://127.0.0.1/fetchcomment.php');
  chkAutoStartNet.Checked := ini.ReadBool('Connection','AutoStart',false);
  TimerFetch.Interval := ini.ReadInteger('Connection','Interval',1000);
  EditFetchInv.Text := ini.ReadString('Connection','Interval','1000');
  try
    editNetPassword.Text := UncrypKey(ini.ReadString('Connection','Key','UNDEF'),KEY);
  except
    editNetPassword.Text := '233-614-789-998';
    LogEvent('通信密码未设置！');
  end;
  // Other Parameters
  
  ini.Free;
end;

procedure TfrmControl.SaveSetting();
var
  ini : TCustomIniFile;
begin
  ini := TINIFile.Create(APP_DIR+'Settings.ini');

  ini.WriteString('NetComment','FontName',cobNetCFontName.Items.Strings[cobNetCFontName.ItemIndex]);
  ini.WriteString('NetComment','FontSize',cobNetCFontSize.Text);
  ini.WriteString('NetComment','FontColor',ColorToString(cobNetCFontColor.Brush.Color));
  ini.WriteBool('NetComment','FontBold',cobNetCFontBold.Checked);

  ini.WriteString('OfficialComment','FontName',cobOfficialCFontName.Items.Strings[cobOfficialCFontName.ItemIndex]);
  ini.WriteString('OfficialComment','FontSize',cobOfficialCFontSize.Text);
  ini.WriteString('OfficialComment','FontColor',ColorToString(cobOfficialCFontColor.Brush.Color));
  ini.WriteBool('OfficialComment','FontBold',cobOfficialCFontBold.Checked);

  ini.WriteBool('Connection','Transmit',radioNetTransmit.Checked);
  ini.WriteBool('Connection','Passive',radioNetPasv.Checked);
  ini.WriteString('Connection','Port',editNetPort.Text);
  ini.WriteString('Connection','Host',editNetHost.Text);
  ini.WriteString('Connection','Key',EncrypKey(editNetPassword.Text,KEY));
  ini.WriteBool('Connection','AutoStart',ChkAutoStartNet.Checked);
  ini.WriteInteger('Connection','Interval',TimerFetch.Interval);

  with frmComment do begin
    ini.WriteString('Display','TitleText',TestLabel.Caption);
    ini.WriteInteger('Display','TitleTop',TestLabel.Top);
    ini.WriteInteger('Display','TitleLeft',TestLabel.Left);
    ini.WriteString('Display','TitleFontName',TestLabel.Font.Name);
    ini.WriteInteger('Display','TitleFontSize',TestLabel.Font.Size);
    ini.WriteString('Display','TitleColor',ColorToString(TestLabel.Font.Color));
  end;

  ini.Free;
end;

Function EncrypKey(Src:String; Key:String): String;
var
  KeyLen :Integer;
  KeyPos :Integer;
  offset :Integer;
  dest :string;
  SrcPos :Integer;
  SrcAsc :Integer;
  Range :Integer;
begin
  KeyLen:=Length(Key);
  if KeyLen = 0 then key:='233acgrid998';
  KeyPos:=0;
  Range:=256;

  Randomize;
  offset := Random(Range);
  dest := format('%1.2x',[offset]);
  for SrcPos := 1 to Length(Src) do begin
    SrcAsc :=(Ord(Src[SrcPos]) + offset) MOD 255;
    if KeyPos < KeyLen then KeyPos:= KeyPos + 1 else KeyPos:=1;
    SrcAsc := SrcAsc xor Ord(Key[KeyPos]);
    dest := dest + format('%1.2x',[SrcAsc]);
    offset := SrcAsc;
  end;
  Result := Dest;
end;

Function UncrypKey(Src:String; Key:String): String;
var
  KeyLen :Integer;
  KeyPos :Integer;
  offset :Integer;
  dest :string;
  SrcPos :Integer;
  SrcAsc :Integer;
  TmpSrcAsc :Integer;
begin
  KeyLen:=Length(Key);
  if KeyLen = 0 then key:='233acgrid998';
  KeyPos:=0;
  offset:=StrToInt('$'+ copy(src,1,2));
  SrcPos:=3;
  repeat
    SrcAsc:=StrToInt('$'+ copy(src,SrcPos,2));
    if KeyPos < KeyLen then KeyPos := KeyPos + 1 else KeyPos := 1;
    TmpSrcAsc := SrcAsc xor Ord(Key[KeyPos]);
    if TmpSrcAsc <= offset then
      TmpSrcAsc := 255 + TmpSrcAsc - offset
    else
      TmpSrcAsc := TmpSrcAsc - offset;
    dest := dest + chr(TmpSrcAsc);
    offset:=srcAsc;
    SrcPos:=SrcPos + 2;
  until SrcPos >= Length(Src);
  Result := Dest;
end;

procedure TfrmControl.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  {$IFNDEF DEV}
  if btnAdmin.Visible then begin
    CanClose := false;
    StatusBar.Panels[0].Text := '关你妹';
    exit;
  end;
  CanClose := Boolean(Application.MessageBox('确认?','退出',MB_ICONQUESTION+MB_YESNO) = IDYES);
  {$ENDIF}
end;

procedure TfrmControl.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SysReady := false;
  DisconnectAll;
  InSocket.Active := false;
  TimerAddOC.SetEnabled(true);
  Shell_NotifyIcon(NIM_DELETE,@TrayIconData);
  UnRegisterHotKey(handle,DispatchKey);
  GlobalDeleteAtom(DispatchKey);
  SaveSetting();
  CoUninitialize;
end;

procedure TfrmControl.btnHideCtrlClick(Sender: TObject);
begin
  frmControl.btnCCWork.Click;
  frmComment.SetTopMost;
  frmControl.btnCCWork.Click;
  frmControl.Hide;
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
  except
    LogEvent('[异常] 快捷键设置失败');
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

procedure TfrmControl.editNetPortChange(Sender: TObject);
var
  Port : Integer;
begin
  Port := StrToIntDef(editNetPort.Text,65536);
  if Port > 65535 then begin
    editNetPort.Text := '9233';
    Application.MessageBox('端口号范围：1-65535。','错误数据',MB_ICONEXCLAMATION);
  end;
end;

procedure TfrmControl.cobNetCFontSizeKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not(Key in['0'..'9', #8, #13, #27]) then Key := #0;
end;

procedure TfrmControl.cobOfficialCFontSizeKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not(Key in['0'..'9', #8, #13, #27]) then Key := #0;
end;

procedure TfrmControl.editTimingInvChange(Sender: TObject);
begin
  frmComment.TimerMoving.Interval := StrToIntDef(editTimingInv.Text,50);
end;

procedure TfrmControl.SubmitComment(RecvTime: TTime; Content: WideString; Source: String; Font: WideString; Effect: TCommentEffect; Bad: Boolean=false);
var
  SW : Word;
  ID : Integer;
begin
  SW := 0;
  Content := Tnt_WideStringReplace(Content,'\n',#13,[rfReplaceAll]);
  Content := Tnt_WideStringReplace(Content,'/n',#13,[rfReplaceAll]);
  try
    with ListComments.Items.Add do begin
      if Bad then begin
        Caption := '╳';
        SetStatusWord(SW,SW_BANNED);
      end
      else begin
        Caption := '◆';
        SetStatusWord(SW,SW_S_INIT,SW_STATUS);
      end;
      SubItems.Add(TimeToStr(Time()));
      SubItems.Add(TimeToStr(RecvTime)+'.'+IntToStr(MilliSecondOf(RecvTime)));
      SubItems.Add(Content);
      SubItems.Add(Source);
      if (Source = L_Console) or (Source = L_XMLFile) then SetStatusWord(SW,SW_CONSOLE);
      SubItems.Add(Font);
      case Effect.Display of
        Scroll: begin SubItems.Add('飞行'); SetStatusWord(SW,SW_E_FLYING,SW_EFFECT); end;
        UpperFixed: begin SubItems.Add('上固'); SetStatusWord(SW,SW_E_UFIXED,SW_EFFECT) end;
        LowerFixed: begin SubItems.Add('下固'); SetStatusWord(SW,SW_E_DFIXED,SW_EFFECT) end;
      end;
      SubItems.Add(IntToStr(Effect.RepeatCount));
      SubItems.Add(IntToStr(Effect.StayTime));
      SubItems.Add(IntToStr(SW));
    end;
    ID := Length(CommentIndex);
    SetLength(CommentIndex,ID+1);
    CommentIndex[ID] := RecvTime;
  except
    LogEvent('SubmitComment() Expection!');
  end;
end;

procedure TfrmControl.editStdShowTimeChange(Sender: TObject);
begin
  frmComment.STD_COMMENT_SHOWTIME := StrToIntDef(EditStdShowTime.Text,STD_COMMENT_SHOWTIME_DEFAULT);
end;

procedure TfrmControl.btnNetStartClick(Sender: TObject);
var
  bind : TIdSocketHandle;
  port : Integer;
begin
  if Networking then begin
    if Transmit then begin
      DisconnectAll;
      InSocket.Active := false;
      editNetPort.Enabled := true;
      radioNetPasv.Enabled := true;
      radioNetPort.Enabled := true;
      Transmit := false;
      LogEvent('TCP转发服务已关闭');
    end
    else if InSocket.Active then begin
      InSocket.Active := false;
      editNetPort.Enabled := true;
      radioNetPort.Enabled := true;
      radioNetTransmit.Enabled := true;
      LogEvent('TCP服务器已关闭，停止接收网络弹幕');
    end
    else begin
      editNetHost.Enabled := true;
      radioNetPasv.Enabled := true;
      radioNetTransmit.Enabled := true;
      TimerFetch.Enabled := false;
      LogEvent('已关闭HTTP抓取，停止接收网络弹幕');
      RemoteTime := 0;
    end;
    Networking := false;
    btnNetStart.Caption := '开始通信(&M)';
  end
  else begin
    if radioNetPasv.Checked then begin
      port := StrToInt(editNetPort.Text);
      if (port < 1) or (port > 65535) then exit;
      try
        InSocket.Active := false;
        InSocket.Bindings.Clear;

        bind := InSocket.Bindings.Add;
        bind.IPVersion := Id_IPv4;
        bind.IP := '0.0.0.0';
        bind.Port := port;

        bind := InSocket.Bindings.Add;
        bind.IPVersion := Id_IPv6;
        bind.IP := '::';
        bind.Port := port;

        InSocket.Active := true;
        Networking := true;
        btnNetStart.Caption := '停止通信(&M)';
        radioNetPort.Enabled := false;
        radioNetTransmit.Enabled := false;
        editNetPort.Enabled := false;
        LogEvent('TCP监听启动于端口 ' + editNetPort.Text);
      except
        LogEvent('TCP服务器初始化失败，检查防火墙或端口冲突。');
      end;
    end
    else if radioNetPort.Checked then begin
      HTTPURL := editNetHost.Text;
      LogEvent('测试Web服务器连接：' + editNetHost.Text);
      TestHTTPClient();
    end
    else begin
      port := StrToInt(editNetPort.Text);
      if (port < 1) or (port > 65535) then exit;
      try
        InSocket.Active := false;
        InSocket.Bindings.Clear;

        bind := InSocket.Bindings.Add;
        bind.IPVersion := Id_IPv4;
        bind.IP := '0.0.0.0';
        bind.Port := port;

        bind := InSocket.Bindings.Add;
        bind.IPVersion := Id_IPv6;
        bind.IP := '::';
        bind.Port := port;

        InSocket.Active := true;
        Networking := true;
        Transmit := true;
        btnNetStart.Caption := '停止通信(&M)';
        radioNetPort.Enabled := false;
        radioNetPasv.Enabled := false;
        editNetPort.Enabled := false;
        LogEvent('TCP转发服务启动于端口 ' + editNetPort.Text);
      except
        LogEvent('TCP服务器初始化失败，检查防火墙或端口冲突。');
      end;
    end;
  end;
end;

procedure TfrmControl.TestHTTPClient();
var
  BadResponses : Array [0..2] of SmallInt;
  Response: WideString;
  i : Integer;
begin
  BadResponses[0] := 404;
  BadResponses[1] := 403;
  BadResponses[2] := 302;
  try
    HTTPClient.ConnectTimeout := 2000;
    HTTPClient.ReadTimeout := 2000;
    Response := HTTPClient.Get(HTTPURL+'?action=init&key='+editNetPassword.Text,TIdTextEncoding.Default);
    HTTPClient.Disconnect;
    //LogEvent(Response);
    if AnsiStartsText('INT Namiko',Response) then begin
      i := Pos('=',Response);
      RemoteTime := Frac(UnixToDateTime(StrToInt64(Copy(Response,i+1,Length(Response) - i)) - TimeZoneBias));
      RemoteTimeOffset := RemoteTime - Time();
      LogEvent('测试完成 服务器时间 '+TimeToStr(RemoteTime));
      TimerFetch.Enabled := true;
      Networking := true;
      btnNetStart.Caption := '停止通信(&M)';
      editNetHost.Enabled := false;
      radioNetPasv.Enabled := false;
      radioNetTransmit.Enabled := false;
    end
    else begin
      {$IFDEF DEV}LogEvent(Response);{$ENDIF}
      LogEvent('未识别的服务器数据，测试失败。');
    end;
  except
    HTTPClient.IOHandler.Close;
    if HTTPClient.Connected then HTTPClient.Disconnect;
    LogEvent('连接或读取超时，测试失败。');
  end;
end;

procedure TfrmControl.InSocketExecute(AContext: TIdContext);
var
  Line : WideString;
  CList : TList;
  i : Integer;
begin
  try
    with AContext.Connection.IOHandler do begin
      CheckForDisconnect(true,true);
      Line := UTF8Decode(ReadLn(TIdTextEncoding.Default));
      if AnsiStartsText('DATA VER=1',Line) then begin
        WriteLn('998 Comment Accepted');
        //case AddRawComment(Line) of
        case ParseLineData(Line) of
          OK: begin
            WriteLn('201 Success');
            if Transmit then begin
              try
                cList := InSocket.Contexts.LockList;
                for i := 0 to cList.Count - 1 do begin
                  TIdContext(cList[i]).Connection.IOHandler.WriteLn(Line,TIdTextEncoding.Default);
                end;
              finally
                InSocket.Contexts.UnlockList;
              end;
            end;
          end;
          BadKey: WriteLn('401 Not Authorized');
          BadLen: WriteLn('402 Broken Message');
          Hexied: WriteLn('4KW Hexie Your Family');
        end;
      end
      else if SameText(Line,'QUIT') then begin
        WriteLn('233 Goodbye');
        AContext.Connection.Disconnect();
      end
      else if SameText(Line,'QUERY') then begin
        WriteLn('300 Namiko Version: 1.0');
        WriteLn('301 Time: '+TimeToStr(Time()));
        WriteLn('302 Comment Count: '+IntToStr(GetCommentCount()));
      end
      else begin
        WriteLn('789 あなたの変態コマンドを理解できなかった。(Command Not Understood)',TIdTextEncoding.Default);
      end;
    end;
  except
    AContext.Connection.Disconnect();
    LogEvent('[异常] InSocket Execute()');
  end;
end;

procedure TfrmControl.DisconnectAll();
var
  CList : TList;
  i : Integer;
begin
  try
    cList := InSocket.Contexts.LockList;
    for i := 0 to cList.Count - 1 do begin
      TIdContext(cList[i]).Connection.Disconnect;
    end;
  finally
    InSocket.Contexts.UnlockList;
  end;
end;

function TfrmControl.ParseLineData(Request: WideString): TNetResult;
var
  Effect: TCommentEffect;
  Content: WideString;
  Key, IP, Font: String;
  RTime: TTime;
  H: Boolean;
  Paras : TTntStringList;
begin
  Result := OK;
  Paras := SplitString(Request,DET);

  Key := Copy(Paras.Strings[1],Length(L_KEY)+1,Length(Paras.Strings[1])-Length(L_KEY));
  if Key <> editNetPassword.Text then begin
    Result := BadKey;
    exit;
  end;

  RTime := Frac(UnixToDateTime(StrToInt64(Copy(Paras.Strings[2],Length(L_TIME)+1,Length(Paras.Strings[2])-Length(L_TIME))) - TimeZoneBias)) + StrToIntDef(EdtNetDelay.Text,5000)/1000/86400;
  RemoteTime := RTime;
  RemoteTimeOffset := RemoteTime - Time();
  {i := Pos(L_LEN,Request);
  j := PosEx(DET,Request,i);
  Len := StrToInt(Copy(Request,i+Length(L_LEN),j-i-Length(L_LEN)));}
  // TCP Incoming Data Don't need length check

  IP := Copy(Paras.Strings[3],Length(L_IP)+1,Length(Paras.Strings[3])-Length(L_IP));

  Font := Copy(Paras.Strings[4],Length(L_FORMAT)+1,Length(Paras.Strings[4])-Length(L_FORMAT));
  ParseFontData(Font);

  // TODO: Security Checks

  Content := Copy(Paras.Strings[6],Length(L_CONTENT)+1,Length(Paras.Strings[6])-Length(L_CONTENT));
  TCPLogFile.LogWriteString('弹幕内容: '+Content+#13+#10);

  Effect.Display := Scroll;
  Effect.StayTime := StrToIntDef(editStdShowTime.Text,frmComment.STD_COMMENT_SHOWTIME);
  Effect.RepeatCount := 1;
  H := frmWordList.Hexied(Content);
  if H then result := Hexied;

  SubmitComment(RTime,Content,IP,Font,Effect,H);
end;

procedure TfrmControl.ParseFontData(var Format: String);
begin
  Format := StringReplace(Format,'DEF_FN',cobNetCFontName.Text,[]);
  Format := StringReplace(Format,'DEF_FS',cobNetCFontSize.Text,[]);
  Format := StringReplace(Format,'DEF_FC',ColorToString(cobNetCFontColor.Brush.Color),[]);
  Format := StringReplace(Format,'DEF_FP',ifthen(cobNetCFontBold.Checked,'B','R'),[]);
end;

procedure TfrmControl.InSocketConnect(AContext: TIdContext);
begin
  AContext.Connection.IOHandler.WriteLn('200 Namiko Server VER=1');
end;

procedure TfrmControl.NotifyCommentStatus(ID: Integer; Status: TCommentStatus);
begin
  if ID >= ListComments.Items.Count then exit;
  try
    case Status of
      Waiting: begin
        ListComments.Items.Item[ID].Caption := '==';
        SetSW(ID,SW_S_WAIT,SW_STATUS);
      end;
      Displaying: begin
        ListComments.Items.Item[ID].Caption := '<<';
        SetSW(ID,SW_S_DISP,SW_STATUS);
      end;
      Removing: begin
        ListComments.Items.Item[ID].Caption := '√';
        SetSW(ID,SW_S_DONE,SW_STATUS);
      end;
    end;
  except
    LogEvent('[异常] 速すぎる！');
  end;
end;

procedure TfrmControl.cobNetCFontNameChange(Sender: TObject);
begin
  frmComment.NetCDemo.Font.Name := cobNetCFontName.Items.Strings[cobNetCFontName.ItemIndex];
end;

procedure TfrmControl.cobNetCFontSizeChange(Sender: TObject);
begin
  frmComment.NetCDemo.Font.Size := StrToInt(cobNetCFontSize.Text);
end;

procedure TfrmControl.cobNetCFontBoldClick(Sender: TObject);
begin
  if SysReady then
    if cobNetCFontBold.Checked then frmComment.NetCDemo.Font.Style := [fsBold] else frmComment.NetCDemo.Font.Style := [];
end;

procedure TfrmControl.cobOfficialCFontNameChange(Sender: TObject);
begin
  frmComment.OfficialCDemo.Font.Name := cobOfficialCFontName.Items.Strings[cobOfficialCFontName.ItemIndex];
end;

procedure TfrmControl.cobOfficialCFontSizeChange(Sender: TObject);
begin
  frmComment.OfficialCDemo.Font.Size := StrToInt(cobOfficialCFontSize.Text);
end;

procedure TfrmControl.cobOfficialCFontBoldClick(Sender: TObject);
begin
  if SysReady then
    if cobOfficialCFontBold.Checked then frmComment.OfficialCDemo.Font.Style := [fsBold] else frmComment.OfficialCDemo.Font.Style := [];
end;

procedure TfrmControl.btnEscAllClick(Sender: TObject);
begin
  frmComment.PurgeComment;
  LogEvent('和谐号出击完毕！');
end;

procedure TfrmControl.btnExControlClick(Sender: TObject);
var
  i : Integer;
begin
  i := StrToIntDef(InputBox('扩充显示容量','233','1'),1);
  frmComment.ExpandControl(i);
end;

procedure TfrmControl.Button1Click(Sender: TObject);
begin
  HTTPURL := editNetHost.Text;
  TestHTTPClient();
end;

procedure TfrmControl.TimerFetchTimer(Sender: TObject);
var
  Lines: TTntStringList;
  BadResponses : Array [0..2] of SmallInt;
  Buffer : TMemoryStream;
  i : Integer;
begin
  if Fetching then begin
    LogEvent('等待数据返回，本次HTTP请求取消');
    Fetching := false;
    exit;
  end;
  Fetching := true;
  BadResponses[0] := 404;
  BadResponses[1] := 403;
  BadResponses[2] := 302;
  try
    Buffer := TMemoryStream.Create;
    {$IFDEF DEV}HTTPLog.Active := true;{$ENDIF}
    HTTPClient.ConnectTimeout := TimerFetch.Interval;
    HTTPClient.ReadTimeout := TimerFetch.Interval;
    HTTPClient.Request.Connection := 'keep-alive';
    HTTPClient.Get(HTTPURL+'?action=fetch&key='+editNetPassword.Text+'&from='+IntToStr(LastHTTPRequest-30)+'&totalc='+IntToStr(GetCommentCount()),Buffer,BadResponses);

    Lines := SplitString(StreamToWideString(Buffer),CRLF);
    // Line 1 does not contain comment and last line is an empty line
    for i := 1 to Lines.Count - 2 do begin
      //{$IFDEF DEV}LogEvent(Lines.Strings[i]);{$ENDIF}
      ParseLineData(Lines.Strings[i]);
    end;
    LastHTTPRequest := DateTimeToUnix(Now())+TimeZoneBias;
    Buffer.Free;
    Fetching := false;
    {$IFDEF DEV}HTTPLog.Active := false;{$ENDIF}
    //if HTTPClient.Connected then HTTPClient.Disconnect;
  except
    on EIdConnectTimeout do begin
      LogEvent('连接超时，将重新建立连接。');
      if HTTPClient.Connected then HTTPClient.Disconnect;
      Fetching := false;
      if Assigned(Buffer) then Buffer.Free;
      {$IFDEF DEV}HTTPLog.Active := false;{$ENDIF}
    end;
    on EIdReadTimeout do begin
      LogEvent('读取超时，将重新建立连接。');
      if HTTPClient.Connected then HTTPClient.Disconnect;
      Fetching := false;
      if Assigned(Buffer) then Buffer.Free;
      {$IFDEF DEV}HTTPLog.Active := false;{$ENDIF}
    end;
    else begin
      LogEvent('获取数据时出现异常，通信停止。');
      HTTPClient.IOHandler.Close;
      btnNetStart.Click;
      {$IFDEF DEV}HTTPLog.Active := false;{$ENDIF}
    end;
  end;
end;

{function TfrmControl.AddRawComment(RawString: WideString): TNetResult;
var
  i,j,m,Len: Integer;
  Content: WideString;
  Key, IP: String;
  Time: TTime;
  Comment: TRawComment;
begin
  i := Pos(L_KEY,RawString);
  j := PosEx(DET,RawString,i);
  Key := Copy(RawString,i+Length(L_KEY),j-i-Length(L_KEY));
  if Key <> editNetPassword.Text then begin
    Result := BadKey;
    exit;
  end;
  i := Pos(L_TIME,RawString);
  j := PosEx(DET,RawString,i);
  Time := UnixToDateTime(StrToInt64(Copy(RawString,i+Length(L_TIME),j-i-Length(L_TIME))) - TimeZoneBias);
  // TODO: TimeSync
  i := Pos(L_LEN,RawString);
  j := PosEx(DET,RawString,i);
  Len := StrToInt(Copy(RawString,i+Length(L_LEN),j-i-Length(L_LEN)));

  i := Pos(L_IP,RawString);
  j := PosEx(DET,RawString,i);
  IP := Copy(RawString,i+Length(L_IP),j-i-Length(L_IP));

  i := Pos(L_CONTENT,RawString);
  j := PosEx(DET,RawString,i);
  Content := Copy(RawString,i+Length(L_CONTENT),j-i-Length(L_CONTENT));

  Comment.Time := Time;
  Comment.Length := Len;
  Comment.IP := IP;
  Comment.Content := Content;
  if frmWordList.Hexied(Content) then begin
    Comment.Status := RCBanned;
    Result := Hexied;
  end
  else begin
    Comment.Status := RCLoaded;
    Result := OK;
  end;
  m := Length(RawPool);
  SetLength(RawPool,m+1);
  RawPool[m] := Comment;
end; }

procedure TfrmControl.TimerAddCommentTimer(Sender: TObject);
var
  i,ProcCount: Integer;
  Comment: TComment;
  Pass : Boolean;
const
  MAX_PROC_ONCE = 10;
begin
  ProcCount := 0;
  Pass := true;
  try
    //with frmComment do if DisplayingCommentCount() / DisplayCapacity() > 0.8 then ExpandControl(DEF_COMMENT_CONTROL);
    for i := CurrListIndex to ListComments.Items.Count - 1 do begin
      if ProcCount = MAX_PROC_ONCE then break;
      with ListComments.Items.Item[i].SubItems do begin
        if QuerySW(i,SW_S_INIT,SW_STATUS) then begin
          if QuerySW(i,SW_CONSOLE,SW_CONSOLE) or (StrToTime(Strings[T_RTIME]) - InternalTime > EncodeTime(0,0,1,0)) then begin
          //if QuerySW(i,SW_CONSOLE,SW_CONSOLE) then begin
          //if QuerySW(i,SW_CONSOLE,SW_CONSOLE) and ((RTime - InternalTime > EncodeTime(0,0,0,500)) or (InternalTime - RTime > EncodeTime(0,0,3,0))) then begin
            Pass := false;
            continue;
          end;
          if Pass then CurrListIndex := i + 1; // Don't simplify me.
          inc(ProcCount);
          Comment.ID := i;
          Comment.Content := Strings[T_TEXT];
          Comment.Font := Strings[T_FORMAT];
          Comment.Effect := GetCommentEffect(i);
          Comment.ControlIndex := -1;
          Comment.ChannelLayer := -1;
          Comment.ChannelFrom := -1;
          Comment.ChannelTo := -1;
          Comment.Status := Created;
          frmComment.AddComment(Comment);
          SetSW(i,SW_S_PROC,SW_STATUS);
        end;
      end;
    end;
  except
    if CurrListIndex > 0 then dec(CurrListIndex);
    LogEvent('[异常] 网络弹幕队列，回滚到: '+IntToStr(CurrListIndex));
    exit;
  end;
end;

function StreamToWideString(AStream: TStream): WideString;
var
  s: UTF8String;
  l: integer;
begin
  AStream.Position:= 0;
  setlength(s, AStream.size);
  l:= AStream.Size * 2;
  SetLength(Result, l);
  AStream.Read(s[1], AStream.Size);
   Result := UTF8Decode(s);
end;

function SplitString(Source, Deli: WideString ): TTntStringList; stdcall;
var
  EndOfCurrentString: Byte;
  StringList: TTntStringList;
begin
  StringList := TTntStringList.Create;
  while Pos(Deli, Source) > 0 do begin
    EndOfCurrentString := Pos(Deli, Source);
    StringList.Add(Copy(Source, 1, EndOfCurrentString - 1));
    Source := Copy(Source, EndOfCurrentString + length(Deli), length(Source) - EndOfCurrentString);
  end;
  Result := StringList;
  StringList.Add(source);
end;

function SetKeyValue(SrcList: TTntStringList): TTntStringList;
var
  StringList: TTntStringList;
begin
  StringList := TTntStringList.Create;
  StringList.Free;
end;

procedure TfrmControl.Button2Click(Sender: TObject);
begin
  DisconnectAll;
end;

function TfrmControl.GetCommentCount(): Integer;
begin
  result := ListComments.Items.Count + ClearedItemCount;
end;

procedure SetFontData(Src: String; var Dest: TFont);
var
  Para: TTntStringList;
const
  L_FONTNAME = 0;
  L_FONTSIZE = 1;
  L_FONTCOLOR = 2;
  L_FONTOPTION = 3;
begin
  Para := SplitString(Src,'|');
  Dest.Name := Para.Strings[L_FONTNAME];
  Dest.Size := StrToInt(Para.Strings[L_FONTSIZE]);
  Dest.Color := StringToColor(Para.Strings[L_FONTCOLOR]);
  if Pos('B',Para.Strings[L_FONTOPTION]) > 0 then Dest.Style := Dest.Style + [fsBold];
end;

function GetFontData(Src: TFont): WideString;
begin
  Result := Src.Name + '|' + IntToStr(Src.Size) + '|' + ColorToString(Src.Color) + '|' + ifthen(Boolean(fsBold in Src.Style),'B','R');
end;

procedure SetStatusWord(var SW: Word; Value: Word; Mask: Word=0);
begin
  if Mask <> 0 then SW := SW and (not Mask);
  SW := SW or Value;
end;

function QueryStatusWord(SW: Word; Value: Word; Mask: Word=65535): Boolean;
begin
  result := Boolean((SW and Mask) = Value);
end;

procedure TfrmControl.SetSW(Index: Integer; Status: Word; Mask: Word=0);
var
  SW : Word;
begin
  try
    SW := Word(StrToInt(ListComments.Items.Item[Index].SubItems.Strings[T_STATUS]));
    SetStatusWord(SW,Status,Mask);
    ListComments.Items.Item[Index].SubItems.Strings[T_STATUS] := IntToStr(SW);
  except
    LogEvent('[异常] SetSW()');
  end;
end;

function TfrmControl.QuerySW(Index: Integer; Status: Word; Mask: Word=65535): Boolean;
begin
  try
    result := QueryStatusWord(Word(StrToInt(ListComments.Items.Item[Index].SubItems.Strings[T_STATUS])),Status,Mask);
  except
    LogEvent('[异常] QuerySW()');
    result := false;
  end;
end;

procedure TfrmControl.grpSpecialEffectsClick(Sender: TObject);
begin
  case grpSpecialEffects.ItemIndex of
    0 : editOfficialCommentPara.Enabled := true;
    1,2 : editOfficialCommentPara.Enabled := false;
  end;
  if editOfficialCommentPara.Enabled = false then editOfficialCommentPara.Text := '1';
end;

procedure TfrmControl.ListCommentsChanging(Sender: TObject;
  Item: TListItem; Change: TItemChange; var AllowChange: Boolean);
begin
  TimerAddComment.Enabled := false;
end;

procedure TfrmControl.ListCommentsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  TimerAddComment.Enabled := true;
end;

function TfrmControl.GetCommentEffect(Index: Integer): TCommentEffect;
begin
  if Index = ListComments.Items.Count then exit;
  with ListComments.Items.Item[Index].SubItems do begin
    if QuerySW(Index, SW_E_FLYING, SW_EFFECT) then begin
      Result.Display := Scroll;
      Result.RepeatCount := StrToInt(Strings[T_CYCLE]);
    end
    else if QuerySW(Index, SW_E_DFIXED, SW_EFFECT) then
      Result.Display := LowerFixed
    else if QuerySW(Index, SW_E_UFIXED, SW_EFFECT) then
      Result.Display := UpperFixed;
    Result.StayTime := StrToInt(Strings[T_OCTIME]);
  end;
end;

procedure TfrmControl.grpTimingClick(Sender: TObject);
begin
  case grpTiming.ItemIndex of
    0 : begin
      InternalTImeOffset := 0;
    end;
    1 : begin
      if RemoteTime <> 0 then InternalTimeOffset := RemoteTimeOffset else Application.MessageBox('远程时间未知','大丈夫ではない、問題だ。',MB_ICONEXCLAMATION);
    end;
    2 : begin
      InternalTimeOffset := StrToTimeDef(InputBox('更改时间轴','将内部时间修改为：   ',TimeToStr(Time())),Time())-Time();
    end;
  end;
end;

procedure TfrmControl.btnClearListClick(Sender: TObject);
begin
  TimerAddComment.Enabled := false;
  SysReady := false;
  TimerAddOC.SetEnabled(false);
  CurrListIndex := 0;
  inc(ClearedItemCount,ListComments.Items.Count);
  ListComments.Items.Clear;
  SetLength(CommentIndex,0);
  SysReady := true;
  TimerAddOC.SetEnabled(true);
  TimerAddComment.Enabled := true;
end;

procedure TfrmControl.Button3Click(Sender: TObject);
begin
  ParseLineData(InputBox('test','test',''));
end;

procedure TfrmControl.EditFetchInvChange(Sender: TObject);
begin
  TimerFetch.Interval := StrToIntDef(editFetchInv.Text,1000);
end;

procedure TfrmControl.radioNetTransmitClick(Sender: TObject);
begin
  editNetHost.Enabled := false;
  editNetPort.Enabled := true;
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

procedure TfrmControl.TimerAddOCTimer(Sender: TObject);
var
  i: Integer;
  RTime : TTime; // Comment Display Time!
  Comment: TComment;
  Pass : Boolean;
begin
  if not SysReady then exit;
  Pass := true;
  try
    with frmComment do if DisplayingCommentCount() / DisplayCapacity() > 0.8 then ExpandControl(DEF_COMMENT_CONTROL);
    //StatusBar.Panels[0].Text := IntToStr(FindLastIndex(InternalTime + EncodeTime(0,0,1,0)));
    for i := CurrListIndex to FindLastIndex(InternalTime + EncodeTime(0,0,0,10)) do begin
      with ListComments.Items.Item[i].SubItems do begin
        if QuerySW(i,SW_S_INIT,SW_STATUS) and QuerySW(i,SW_CONSOLE,SW_CONSOLE) then begin
          RTime := StrToTime(Strings[T_RTIME]);
          if (not QuerySW(i,SW_CONSOLE,SW_CONSOLE)) or (RTime - InternalTime > EncodeTime(0,0,0,10)) or (InternalTime - RTime > EncodeTime(0,1,0,0)) then begin
            Pass := false;
            continue;
          end;
          if Pass then CurrListIndex := i + 1; // Don't simplify me.
          Comment.ID := i;
          Comment.Content := Strings[T_TEXT];
          Comment.Font := Strings[T_FORMAT];
          Comment.Effect := GetCommentEffect(i);
          Comment.ControlIndex := -1;
          Comment.ChannelLayer := -1;
          Comment.ChannelFrom := -1;
          Comment.ChannelTo := -1;
          Comment.Status := Created;
          frmComment.AddComment(Comment);
          SetSW(i,SW_S_PROC,SW_STATUS);
        end;
      end;
    end;
  except
    if CurrListIndex > 0 then dec(CurrListIndex);
    LogEvent('[异常] 本地弹幕队列，回滚到: '+IntToStr(CurrListIndex));
  end;
end;

function TfrmControl.FindLastIndex(FarestTime: TTime): Integer;
var
  i : Integer;
begin
  for i := Length(CommentIndex) - 1 downto CurrListIndex do begin
    if CommentIndex[i] < FarestTime then begin
      Result := i;
      exit;
    end;
  end;
  Result := CurrListIndex - 1;
end;

procedure TfrmControl.NotifyDelay(Second: Word);
begin
  XMLDelay := Second * 1000;  
end;

procedure TfrmControl.TimerUpdateTimer(Sender: TObject);
begin
  if not SysReady then exit;
  if not Freezing then InternalTime := Time() + InternalTimeOffset;
  if RemoteTime <> 0 then RemoteTime := Time() + RemoteTImeOffset;
  if XMLDelay <> 0 then begin
    DelayLabel.Visible := True;
    DelayLabel.Caption := Format('延迟结束 %d ms',[XMLDelay]);
    DelayProgBar.Position := Min(Trunc((XMLDelay / 5000) * 100),100);
    Dec(XMLDelay, TimerAddOC.GetInterval);
    if XMLDelay <= 0 then begin
      XMLDelay := 0;
      DelayLabel.Visible := False;
    end;
  end;
end;

procedure TfrmControl.ListCommentsDblClick(Sender: TObject);
begin
  try
    editOfficialComment.Text := ListComments.Selected.SubItems.Strings[T_TEXT];
  except
    exit;
  end;
end;

procedure TfrmControl.ListCommentsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_Delete) and (ListComments.SelCount > 0) then begin
    ListComments.Selected.SubItems.Strings[T_TEXT] := '';
  end;
end;

end.
