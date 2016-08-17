unit UnitControl;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ValEdit, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdGlobal, IdTCPServer, IdCmdTCPServer, System.Actions, Vcl.ActnList, ProgramTypes,
  System.Generics.Collections, System.JSON, System.IOUtils, Vcl.ExtDlgs, StrUtils, SyncObjs;

const STATUS_PANEL_JSON = 0;
const STATUS_PANEL_MODE = 1;
const STATUS_PANEL_TIME = 2;

type
  TListBox = class(Vcl.StdCtrls.TListBox)
  private
    FItemIndex: Integer;
    FOnChange: TNotifyEvent;
    procedure CNCommand(var AMessage: TWMCommand); message CN_COMMAND;
  protected
    procedure Change; virtual;
    procedure SetItemIndex(const Value: Integer); override;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;
  
type
  TfrmControl = class(TForm)
    ListViewProgramList: TListView;
    BtnChooseJSON: TButton;
    ProgramValues: TValueListEditor;
    StatusValues: TValueListEditor;
    StatusBar: TStatusBar;
    TCPServer: TIdCmdTCPServer;
    BtnReloadJSON: TButton;
    GroupProgramData: TGroupBox;
    BtnShowInfo: TButton;
    GroupPlayControl: TGroupBox;
    BtnHideInfo: TButton;
    BtnPlay: TButton;
    BtnStop: TButton;
    BtnResetMPC: TButton;
    BtnResetFB2K: TButton;
    BtnConfig: TButton;
    BtnResetWindow: TButton;
    BtnExit: TButton;
    GroupControls: TGroupBox;
    ListSessions: TListBox;
    ActionList: TActionList;
    ActionLoadJSON: TAction;
    ActionReloadJSON: TAction;
    ActionShowInfo: TAction;
    ActionHideInfo: TAction;
    ActionPlay: TAction;
    ActionStop: TAction;
    ActionResetMPC: TAction;
    ActionResetFB2K: TAction;
    ActionResetWindow: TAction;
    ActionShowConfig: TAction;
    ActionExit: TAction;
    MemoLog: TMemo;
    OpenFile: TOpenTextFileDialog;
    BtnTimeMinus: TButton;
    BtnTimePlus: TButton;
    ActionTimeMinus: TAction;
    ActionTimePlus: TAction;
    TimerSecond: TTimer;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ActionLoadJSONExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionShowConfigExecute(Sender: TObject);
    procedure AddProgramToSession(SessionIndex: Integer; Session: string; ProgramJSON: TJSONObject);
    procedure DisplayPrograms(SessionIndex: Integer; ReloadList: Boolean = False);
    procedure ListSessionsChange(Sender: TObject);
    function JSONStringDefault(AValue: TJSONValue; DefaultValue: string = ''): string;
    function JSONCardinalDefault(AValue: TJSONValue): Cardinal;
    function TCreditsFactory(AValue: TJSONValue): TCredits;
    function TLyricsFactory(AValue: TJSONValue): TLyrics;
    function TFB2KFactory(APLValue: TJSONValue; AIdxValue: TJSONValue): TFB2K;
    function TMpcHCFactory(AValue: TJSONValue): TMpcHC;
    function TLogoFactory(AValue: TJSONValue): TLogo;
    procedure ActionReloadJSONExecute(Sender: TObject);
    procedure TimerSecondTimer(Sender: TObject);
  private
    { Private declarations }
    procedure ReadJSONContent(AData: TArray<Byte>);
    procedure InitializeSystem();
    procedure InitializePrograms();
    procedure InitializeTCPServer();
  public
    { Public declarations }
    LiveHWND, InfoHWND: HWND;
    WorkMode: TWorkMode;
    LastJSON: TFileName;
    Programs: TPrograms;
    ProgramsBySession: TSessionProgramsDict;
    procedure Log(AText: string);
    procedure ReadJSONFile(AFileName: string);
    function TProgramStatusToString(AStatus: TProgramStatus): string;
  end;

var
  frmControl: TfrmControl;
  AppPath: string;
  PlayItemS: TSemaphore;
  ProgramsMutex: TMutex;
  DefaultSA: TSecurityAttributes; // Use to create thread objects

implementation

{$R *.dfm}

uses Configuration, CfgForm, InfoWindow, LiveWindow, UnitClient, UnitWebUI;

{ TListBox }

procedure TListBox.Change;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TListBox.CNCommand(var AMessage: TWMCommand);
begin
  inherited;
  if (AMessage.NotifyCode = LBN_SELCHANGE) and (FItemIndex <> ItemIndex) then
  begin
    FItemIndex := ItemIndex;
    Change;
  end;
end;

procedure TListBox.SetItemIndex(const Value: Integer);
begin
  inherited;
  if FItemIndex <> ItemIndex then
  begin
    FItemIndex := ItemIndex;
    Change;
  end;
end;

{ TfrmControl }

procedure TfrmControl.InitializeSystem;
begin
  WorkMode := TWorkMode(GetCfgInteger('Connection.Mode'));
  with StatusBar.Panels.Items[STATUS_PANEL_MODE] do begin
    case WorkMode of
      SERVER_ONLY: Text := '主控';
      SERVER_INFO: Text := '主控+信息窗口';
      SERVER_LIVE: Text := '主控+直播窗口';
      INFO_LIVE: Text := '本地信息+直播';
      CLIENT_INFO: Text := '信息窗口远程';
      CLIENT_LIVE: Text := '直播窗口远程';
    end;  
  end;
  if WorkMode < INFO_LIVE then begin // Server Start
    InitializeTCPServer;
    Log(Format('启动TCP服务器于%s:%u', [GetCfgString('Connection.Host'), GetCfgInteger('Connection.Port')]));
  end
  else if WorkMode > INFO_LIVE then begin // Client Start
    // ???
  end;
  if (WorkMode = SERVER_INFO) or (WorkMode = INFO_LIVE) or (WorkMode = CLIENT_INFO) then begin
    CreateInfoWindow;
    Log('创建信息窗口');
  end;
  if (WorkMode = SERVER_LIVE) or (WorkMode = INFO_LIVE) or (WorkMode = CLIENT_LIVE) then begin
    Application.CreateForm(TfrmLiveWindow, frmLiveWindow);
    Log('创建直播窗口');
  end;
end;

procedure TfrmControl.InitializeTCPServer;
begin
  with TCPServer.Bindings.Add do begin
    IPVersion := Id_IPv4;
    IP := GetCfgString('Connection.Host');
    Port := GetCfgInteger('Connection.Port');
  end;
  TCPServer.Active := True;
end;

procedure TfrmControl.ListSessionsChange(Sender: TObject);
begin
  DisplayPrograms(ListSessions.ItemIndex, False);
end;

function TfrmControl.TProgramStatusToString(AStatus: TProgramStatus): string;
begin
  case AStatus of
    Check: Result := '检查';
    Ready: Result := '就绪';
    Missing: Result := '缺失';
    InfoShown: Result := '信息';
    Playing: Result := '播放';
    Played: Result := '完毕';
  end;
end;

procedure TfrmControl.ActionLoadJSONExecute(Sender: TObject);
begin
  if OpenFile.Execute then begin
    ReadJSONFile(OpenFile.FileName);
    (ConfigDict.Items['Startup.LastSession'] as TIntegerConfiguration).Value := 0;
  end;
end;

procedure TfrmControl.ActionReloadJSONExecute(Sender: TObject);
begin
  if FileExists(LastJSON) then ReadJSONContent(TFile.ReadAllBytes(LastJSON));
end;

procedure TfrmControl.ActionShowConfigExecute(Sender: TObject);
begin
  frmConfig.Show;
end;

procedure TfrmControl.FormCreate(Sender: TObject);
begin
  ListSessions.ItemIndex := 0;
  Programs := TPrograms.Create(True);
  ProgramsBySession := TSessionProgramsDict.Create();
  ProgramsMutex.Release;
  ListSessions.OnChange := ListSessionsChange;
  InitializeSystem;
  LastJSON := GetCfgString('Startup.LastJSON');
  if FileExists(LastJSON) then begin
    ReadJSONFile(LastJSON);
    DisplayPrograms(GetCfgInteger('Startup.LastSession'));
  end;
end;

procedure TfrmControl.FormDestroy(Sender: TObject);
var
  ProgramsInSession: TPrograms;
begin
  for ProgramsInSession in ProgramsBySession.Values do ProgramsInSession.Free;
  ProgramsBySession.Free;
  Programs.Free;
end;

procedure TfrmControl.FormResize(Sender: TObject);
begin
  ListViewProgramList.Width := Self.Width - 280;
  ListViewProgramList.Height := Self.Height - 240;
  ProgramValues.Left := Self.Width - 270;
  ProgramValues.Height := Self.Height - 240;
  ListSessions.Top := Self.Height - 225;
  GroupProgramData.Top := ListSessions.Top;
  GroupPlayControl.Top := Self.Height - 170;
  GroupControls.Top := ListSessions.Top;
  StatusValues.Top := ListSessions.Top;
  StatusValues.Width := Self.Width - 780;
  MemoLog.Top := Self.Height - 225;
  MemoLog.Left := Self.Width - 270;
end;

procedure TfrmControl.Log(AText: string);
begin
  MemoLog.Lines.Add(TimeToStr(Time()) + ' ' + AText);
end;

procedure TfrmControl.InitializePrograms;
var
  I: Integer;
  MPCFail, LogoFail: Boolean;
begin
  ProgramsMutex.Acquire;
  try
    for I := 0 to Programs.Count - 1 do begin
      MPCFail := Programs.Items[I].MPCHC.HasError();
      LogoFail := Programs.Items[I].Logo.HasError();
      if MPCFail or LogoFail then
        Programs.Items[I].Status := Missing
      else
        Programs.Items[I].Status := Ready;
    end;
  finally
    ProgramsMutex.Release;
  end;
end;

procedure TfrmControl.ReadJSONContent(AData: TArray<Byte>);
var
  JSON, JSONProgram: TJSONValue;
  JSONSession: TJSONPair;
  JSONSessions: TJSONObject;
  JSONSessionArray: TJSONArray;
  Index: Integer;
begin
  JSON := TJSONObject.ParseJSONValue(AData, 0, True);
  if not Assigned(JSON) then Log('JSON读取失败');
  try
    if JSON is TJSONObject then begin
      JSONSessions := JSON as TJSONObject;
      Index := 1;
      ProgramsBySession.Clear;
      Programs.Clear;
      ProgramsMutex.Acquire;
      try
        for JSONSession in JSONSessions do begin
          if JSONSession.JsonValue is TJSONArray then begin
            JSONSessionArray := JSONSession.JsonValue as TJSONArray;
            ProgramsBySession.Add(Index, TPrograms.Create(False));
            for JSONProgram in JSONSessionArray do begin
              if JSONProgram is TJSONObject then AddProgramToSession(Index, JSONSession.JsonString.Value, JSONProgram as TJSONObject);
            end;
          end
          else raise Exception.Create('JSON场次不是数组');
          Inc(Index);
        end;
      finally
        ProgramsMutex.Release;
      end;
      InitializePrograms;
      DisplayPrograms(0, True);
      ListSessions.ItemIndex := 0;
    end
    else raise Exception.Create('JSON数据不是对象');
  finally
    JSON.Free;
  end;
end;

procedure TfrmControl.AddProgramToSession(SessionIndex: Integer; Session: string; ProgramJSON: TJSONObject);
var
  AProgram: TProgram;
  ProgramGrouped: TPrograms;
begin
  AProgram := TProgram.Create;
  AProgram.Session := Session;
  AProgram.Sequence := (ProgramJSON.GetValue('SEQUENCE') as TJSONNumber).AsDouble;
  AProgram.TypeName := JSONStringDefault(ProgramJSON.GetValue('TYPE'), '-');
  AProgram.ID := JSONStringDefault(ProgramJSON.GetValue('ID'), '-');
  AProgram.Team := JSONStringDefault(ProgramJSON.GetValue('TEAM'), '');
  AProgram.MobilePhone := JSONStringDefault(ProgramJSON.GetValue('MOBILE'), '');
  AProgram.MainTitle := JSONStringDefault(ProgramJSON.GetValue('TITLE_O'), '');
  AProgram.TranslatedTitle := JSONStringDefault(ProgramJSON.GetValue('TITLE_OT'), '');
  AProgram.Credits := TCreditsFactory(ProgramJSON.GetValue('CREDITS'));
  AProgram.Source := JSONStringDefault(ProgramJSON.GetValue('NETA_O'), '');
  AProgram.TranslatedSource := JSONStringDefault(ProgramJSON.GetValue('NETA_OT'), '');
  AProgram.Lyric := TLyricsFactory(ProgramJSON.GetValue('LRC'));
  if ProgramJSON.GetValue('ShowInfo') is TJSONTrue then begin
    AProgram.ShowInfo := True;  
  end
  else AProgram.ShowInfo := False;
  AProgram.FB2K := TFB2KFactory(ProgramJSON.GetValue('FB2K_PL'), ProgramJSON.GetValue('FB2K_IDX'));
  AProgram.MPCHC := TMpcHCFactory(ProgramJSON.GetValue('MPC'));
  AProgram.Logo := TLogoFactory(ProgramJSON.GetValue('LOGO'));

  if ProgramsBySession.ContainsKey(SessionIndex) then begin
    ProgramGrouped := ProgramsBySession.Items[SessionIndex];
    ProgramGrouped.Add(AProgram);  
  end;
  Programs.Add(AProgram);
end;

function TfrmControl.JSONStringDefault(AValue: TJSONValue; DefaultValue: string = ''): string;
begin
  if Assigned(AValue) and (AValue is TJSONString) then
    Result := (AValue as TJSONString).Value
  else
    Result := DefaultValue;
end;

function TfrmControl.JSONCardinalDefault(AValue: TJSONValue): Cardinal;
begin
  if Assigned(AValue) and (AValue is TJSONNumber) then
    Result := Cardinal((AValue as TJSONNumber).AsInt)
  else
    Result := 0;
end;

function TfrmControl.TCreditsFactory(AValue: TJSONValue): TCredits;
var
  JSONCredit: TJSONObject;
  JSONCredits: TJSONArray;
  Credit: TCredit;
  I: Integer;
begin
  Result := TCredits.Create;
  if Assigned(AValue) and (AValue is TJSONArray) then begin
    JSONCredits := AValue as TJSONArray;
    for I := 0 to JSONCredits.Count - 1 do begin
      if JSONCredits.Items[I] is TJSONObject then begin
        JSONCredit := (JSONCredits.Items[I]) as TJSONObject;
        Credit := TCredit.Create;
        Credit.Title := JSONStringDefault(JSONCredit.GetValue('T'), '');
        Credit.Name := JSONStringDefault(JSONCredit.GetValue('N'), '');
        if (Credit.Title <> '') and (Credit.Name <> '') then Result.Add(Credit);
      end;       
    end;
  end;
end;

function TfrmControl.TLyricsFactory(AValue: TJSONValue): TLyrics;
var
  JSONLyricPartValue: TJSONValue;
  JSONLyric, JSONLyricPart: TJSONObject;
  JSONLyrics, JSONLyricParts: TJSONArray;
  Lyric: TLyric;
  LyricPart: TLyricPart;
  I: Integer;
begin
  Result := TLyrics.Create;
  if Assigned(AValue) and (AValue is TJSONArray) then begin
    JSONLyrics := AValue as TJSONArray;
    if JSONLyrics.Count > 0 then Result.Enabled := True;    
    for I := 0 to JSONLyrics.Count - 1 do begin
      if JSONLyrics.Items[I] is TJSONObject then begin
        Lyric := TLyric.Create;
        JSONLyric := (JSONLyrics.Items[I]) as TJSONObject;
        Lyric.Offset := (JSONLyric.GetValue('O') as TJSONNumber).AsInt;
        Lyric.Text := JSONStringDefault(JSONLyric.GetValue('T'), '');
        Lyric.Parts := TLyricParts.Create();
        if JSONLyric.GetValue('P') is TJSONArray then begin
          JSONLyricParts := (JSONLyric.GetValue('P') as TJSONArray);
          for JSONLyricPartValue in JSONLyricParts do begin 
            if JSONLyricPartValue is TJSONObject then begin
              JSONLyricPart := JSONLyricPartValue as TJSONObject;
              LyricPart := TLyricPart.Create;
              LyricPart.Main := JSONStringDefault(JSONLyricPart.GetValue('M'), '');
              LyricPart.Furi := JSONStringDefault(JSONLyricPart.GetValue('F'), '');
              Lyric.Parts.Add(LyricPart);
            end;
          end;
        end;
        Result.Lyrics.Enqueue(Lyric);
      end;
    end;
  end;
end;

function TfrmControl.TFB2KFactory(APLValue: TJSONValue; AIdxValue: TJSONValue): TFB2K;
begin   
  Result := TFB2K.Create;
  if Assigned(APLValue) and (APLValue is TJSONNumber) and Assigned(AIdxValue) and (AIdxValue is TJSONNumber) then begin
    Result.Enabled := True;
    Result.Playlist := JSONCardinalDefault(APLValue);
    Result.Index := JSONCardinalDefault(APLValue);
  end
  else Result.Enabled := False;
end;

procedure TfrmControl.TimerSecondTimer(Sender: TObject);
begin
  StatusBar.Panels.Items[STATUS_PANEL_TIME].Text := TimeToStr(Time());
end;

function TfrmControl.TMpcHCFactory(AValue: TJSONValue): TMpcHC;
var
  FullPath: string;
begin
  Result := TMpcHC.Create;
  FullPath := JSONStringDefault(AValue);
  if FullPath = '' then Result.Enabled := False else begin
    Result.Enabled := True;
    Result.FullPath := FullPath;
  end;    
end;

function TfrmControl.TLogoFactory(AValue: TJSONValue): TLogo;
var
  FullPath: string;
begin
  Result := TLogo.Create;  
  FullPath := JSONStringDefault(AValue);
  if FullPath = '' then Result.Enabled := False else begin
    Result.Enabled := True;
    Result.FullPath := FullPath;
  end;    
end;

procedure TfrmControl.DisplayPrograms(SessionIndex: Integer; ReloadList: Boolean = False);
var
  ProgramsInSession: TPrograms;
  ProgramItem: TProgram;
  CurrentSession: string;
  I, IStart, IEnd: Integer;
begin
  if SessionIndex > ProgramsBySession.Count then Exit;
  if ReloadList then begin
    ListSessions.Items.Clear;
    ListSessions.Items.Add('全部场次');
  end;
  ListViewProgramList.Items.Clear;
  if SessionIndex > 0 then begin
    IStart := SessionIndex;
    IEnd := SessionIndex;
    ListSessions.ItemIndex := SessionIndex;
    (ConfigDict.Items['Startup.LastSession'] as TIntegerConfiguration).Value := SessionIndex;  
  end
  else begin
    IStart := 1;
    IEnd := ProgramsBySession.Count;
  end;
  for I := IStart to IEnd do begin
    ProgramsInSession := ProgramsBySession.Items[I];
    CurrentSession := ProgramsInSession.First.Session;
    if ReloadList then ListSessions.Items.Add(CurrentSession);
    with ListViewProgramList do begin
      for ProgramItem in ProgramsInSession do begin
        with Items.Add do begin  
          Caption := TProgramStatusToString(ProgramItem.Status);
          SubItems.Add(ProgramItem.Session);
          SubItems.Add(Format('%.1f', [ProgramItem.Sequence]));
          if ProgramItem.Team = '' then begin
            SubItems.Add(ProgramItem.ID);          
          end
          else 
            SubItems.Add(ProgramItem.ID + '(' + ProgramItem.Team + ')');
          SubItems.Add(ProgramItem.TypeName);
          SubItems.Add(ProgramItem.MainTitle);
          SubItems.Add(IfThen(ProgramItem.FB2K.Enabled, Format('%u:%u', [ProgramItem.FB2K.Playlist, ProgramItem.FB2K.Index]), '无'));
          SubItems.Add(ProgramItem.MPCHC.ToString());
          SubItems.Add(IfThen(ProgramItem.Lyric.Enabled, '有', '无'));
          SubItems.Add(ProgramItem.MPCHC.ToString());
        end;
      end;  
    end;
  end;
end;

procedure TfrmControl.ReadJSONFile(AFileName: string);
begin
  Log('读取JSON数据：' + AFileName);
  try
    ReadJSONContent(TFile.ReadAllBytes(AFileName));
    LastJSON := AFileName;
    (ConfigDict.Items['Startup.LastJSON'] as TStringConfiguration).Value := LastJSON;
    StatusBar.Panels[STATUS_PANEL_JSON].Text := LastJSON;
  except
    on E: Exception do begin
      Log('JSON 读取失败：' + E.Message);
    end;
  end;
end;


initialization
  AppPath := ExtractFilePath(Application.ExeName);
  DefaultSA.nLength := SizeOf(TSecurityAttributes);
  DefaultSA.lpSecurityDescriptor := nil;
  DefaultSA.bInheritHandle := False;
  ProgramsMutex := TMutex.Create(@DefaultSA, True, 'program_mutex');
  PlayItemS := TSemaphore.Create(@DefaultSA, 0, 1, 'play_item', False);

finalization
  PlayItemS.Free;
  ProgramsMutex.Free;

end.
