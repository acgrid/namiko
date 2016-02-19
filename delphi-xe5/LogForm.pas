unit LogForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtDlgs,
  Vcl.ExtCtrls, System.Generics.Collections, SyncObjs, Math, Clipbrd, NamikoTypes;

type
  TLog = class(TObject)
    private
      FTime: TDateTime;
      FSource: string;
      FLevel: TLogType;
      FInfo: string;
    public
      function ShowLevel(): string;
      property Time: TDateTime read FTime;
      property Source: string read FSource;
      property Level: string read ShowLevel;
      property Info: string read FInfo;
      constructor Create(Info: string; Src: string = '未知'; Level: TLogType = logInfo);
  end;

type
  TLogCollection = TObjectList<TLog>;

type
  TfrmLog = class(TForm)
    LogList: TListView;
    BtnHide: TButton;
    ComboFilter: TComboBox;
    BtnSaveLog: TButton;
    TimerLogUpdate: TTimer;
    SaveLogFileDialog: TSaveTextFileDialog;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnHideClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerLogUpdateTimer(Sender: TObject);
    procedure ComboFilterChange(Sender: TObject);
    procedure BtnSaveLogClick(Sender: TObject);
    procedure LogListDblClick(Sender: TObject);
  private
    { Private declarations }
    Logs: TLogCollection;
    LatestLogIndex: Integer;
  public
    { Public declarations }
    procedure LogUpdate(Reload: Boolean = False);
    procedure LogAdd(Info: string; Src: string = '未知'; Level: TLogType = logInfo);
  end;
var
  frmLog: TfrmLog;
  APP_DIR: string;
  SecurityAttribute: TSecurityAttributes;
  LogMutex: TMutex;

implementation

uses
  CtrlForm;

{$R *.dfm}

procedure TfrmLog.BtnHideClick(Sender: TObject);
begin
  Self.Hide;
end;

procedure TfrmLog.BtnSaveLogClick(Sender: TObject);
var
  Buffer: TStringList;
  Log: TLog;
  i: Integer;
  Encoding: TEncoding;
begin
  if SaveLogFileDialog.Execute then begin
    TimerLogUpdate.Enabled := False;
    Buffer := TStringList.Create();
    try
      for i := 0 to Logs.Count - 1 do begin
        Log := Logs.Items[i];
        Buffer.Add(DateTimeToStr(Log.Time) + ' - ' + Log.Source + ' [' + Log.Level + '] ' + Log.Info);
      end;
      case SaveLogFileDialog.EncodingIndex of
        0: Encoding := TEncoding.UTF8;
        1: Encoding := TEncoding.Unicode;
        2: Encoding := TEncoding.BigEndianUnicode;
      else
        Encoding := TEncoding.UTF8;
      end;
      Buffer.SaveToFile(SaveLogFileDialog.FileName, Encoding);
    finally
      Buffer.Free();
    end;
    TimerLogUpdate.Enabled := True;
  end;

end;

procedure TfrmLog.ComboFilterChange(Sender: TObject);
begin
  TimerLogUpdate.Enabled := False;
  LogUpdate(True);
  TimerLogUpdate.Enabled := True;
end;

procedure TfrmLog.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not frmControl.SysReady;
end;

procedure TfrmLog.FormCreate(Sender: TObject);
var
  TaskbarWnd: HWnd;
  TaskbarRect: TRect;
begin
  // Position
  TaskbarWnd := FindWindow('Shell_TrayWnd',nil);
  GetWindowRect(TaskbarWnd, TaskbarRect);
  Self.Top := Screen.Height - TaskbarRect.Height - Self.Height;
  Self.Left := Screen.Width - Self.Width;
  // Initilize logger
  LatestLogIndex := 0;
  Logs := TLogCollection.Create(True);
  LogMutex.Release;
  LogAdd('创建日志池完成','日志',logInfo);
  // Start log updating
  TimerLogUpdate.Enabled := True;
end;

procedure TfrmLog.FormDestroy(Sender: TObject);
begin
  Logs.Free;
end;

procedure TfrmLog.FormResize(Sender: TObject);
begin
  with LogList do begin
    Width := Self.Width - 40;
    Height := Self.Height - 100;
  end;
  ComboFilter.Top := Self.Height - 75;
  BtnHide.Top := Self.Height - 77;
  BtnSaveLog.Top := Self.Height - 77;
  BtnHide.Left := Self.Width - 105;
  BtnSaveLog.Left := Self.Width - 215;
end;

procedure TfrmLog.LogAdd(Info: string; Src: string = '未知'; Level: TLogType = logInfo);
begin
  LogMutex.Acquire;
  try
    Logs.Add(TLog.Create(Info, Src, Level));
  finally
    LogMutex.Release;
  end;
end;

procedure TfrmLog.LogListDblClick(Sender: TObject);
begin
  Clipboard.AsText := LogList.Items.Item[LogList.ItemIndex].SubItems.Strings[2];
end;

procedure TfrmLog.LogUpdate(Reload: Boolean = False);
var
  i, StartIndex, FrontierIndex: Integer;
  ThisLog: TLog;
begin
  if Reload or (Logs.Count > LatestLogIndex) then begin
    StartIndex := IfThen(Reload, 0, LatestLogIndex);
    FrontierIndex := Logs.Count - 1;
    if Reload then LogList.Items.Clear;
    for i := StartIndex to FrontierIndex do begin
      ThisLog := Logs.Items[i];
      // Filter
      if (ComboFilter.ItemIndex > 0) and (ComboFilter.ItemIndex <> Ord(ThisLog.FLevel) + 1) then Continue;
      // Add
      with LogList.Items.Insert(0) do begin
        Caption := TimeToStr(ThisLog.Time);
        SubItems.Add(ThisLog.Source);
        SubItems.Add(ThisLog.Level);
        SubItems.Add(ThisLog.Info);
      end;
    end;
    LatestLogIndex := FrontierIndex + 1;
  end;
end;

procedure TfrmLog.TimerLogUpdateTimer(Sender: TObject);
begin
  if Self.Visible then LogUpdate;  
end;

function TLog.ShowLevel(): string;
begin
  case Self.FLevel of
    logDebug: Result := '调试';
    logInfo: Result := '信息';
    logWarning: Result := '警告';
    logError: Result := '错误';
    logException: Result := '异常';
  end;
end;

constructor TLog.Create(Info: string; Src: string = '未知'; Level: TLogType = logInfo);
begin
  Self.FTime := Now();
  Self.FSource := Src;
  Self.FLevel := Level;
  Self.FInfo := Info;
end;

initialization
  APP_DIR := ExtractFilePath(ParamStr(0));
  SecurityAttribute.nLength := SizeOf(TSecurityAttributes);
  SecurityAttribute.lpSecurityDescriptor := nil;
  SecurityAttribute.bInheritHandle := False;
  LogMutex := TMutex.Create(@SecurityAttribute,True,'main_log_m');

finalization
  LogMutex.Free;

end.
