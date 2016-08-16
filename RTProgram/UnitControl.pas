unit UnitControl;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ValEdit, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdTCPServer, IdCmdTCPServer, System.Actions, Vcl.ActnList, ProgramTypes,
  System.Generics.Collections, System.JSON, System.IOUtils, Vcl.ExtDlgs;

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
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ActionLoadJSONExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionShowConfigExecute(Sender: TObject);
    procedure AddProgramToSession(SessionIndex: Integer; Session: string; ProgramJSON: TJSONObject);
    procedure DisplayPrograms(SessionIndex: Integer);
    function JSONStringDefault(AValue: TJSONValue; DefaultValue: string = ''): string;
    function JSONCardinalDefault(AValue: TJSONValue): Cardinal;
    function TCreditsFactory(AValue: TJSONValue): TCredits;
    function TLyricsFactory(AValue: TJSONValue): TLyrics;
    function TFB2KFactory(APLValue: TJSONValue; AIdxValue: TJSONValue): TFB2K;
    function TMpcHCFactory(AValue: TJSONValue): TMpcHC;
    function TLogoFactory(AValue: TJSONValue): TLogo;
  private
    { Private declarations }
    procedure ReadJSONContent(AData: TArray<Byte>);
  public
    { Public declarations }
    Programs: TPrograms;
    ProgramsBySession: TSessionProgramsDict;
    procedure Log(AText: string);
  end;

var
  frmControl: TfrmControl;
  AppPath: string;

implementation

{$R *.dfm}

uses Configuration, CfgForm;

procedure TfrmControl.ActionLoadJSONExecute(Sender: TObject);
begin
  if OpenFile.Execute then begin
    Log('读取JSON数据：' + OpenFile.FileName);
    try
      ReadJSONContent(TFile.ReadAllBytes(OpenFile.FileName));
    except
      on E: Exception do begin
        Log('JSON 读取失败：' + E.Message);
      end;
    end;
  end;
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
      for JSONSession in JSONSessions do begin
        if JSONSession.JsonValue is TJSONArray then begin
          JSONSessionArray := JSONSession.JsonValue as TJSONArray;
          ProgramsBySession.Add(Index, TPrograms.Create(False));
          for JSONProgram in JSONSessionArray do begin
            if JSONProgram is TJSONObject then AddProgramToSession(Index, JSONSession.JsonValue.Value, JSONProgram as TJSONObject);            
          end;
        end
        else raise Exception.Create('JSON场次不是数组');
        Inc(Index);
      end;
      DisplayPrograms(0);
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

procedure TfrmControl.DisplayPrograms(SessionIndex: Integer);
var
  ProgramsInSession: TPrograms;
  ProgramItem: TProgram;
  CurrentSession: string;
begin
  ListSessions.Items.Clear;
  ListSessions.Items.Add('全部场次');
  for ProgramsInSession in ProgramsBySession.Values do begin
    CurrentSession := ProgramsInSession.First.Session;
    ListSessions.Items.Add(CurrentSession);
    with ListViewProgramList do begin
      Items.Clear;
      for ProgramItem in ProgramsInSession do begin
        with Items.Add do begin  
          Caption := '';
          SubItems.Add(CurrentSession);
          SubItems.Add(Format('%.1f', [ProgramItem.Sequence]));
          SubItems.Add('');
          SubItems.Add(ProgramItem.TypeName);
          SubItems.Add(ProgramItem.MainTitle);
          SubItems.Add('');
          SubItems.Add('');
          SubItems.Add('');
          SubItems.Add('');
        end;
      end;  
    end;
  end;
end;

initialization
  AppPath := ExtractFilePath(Application.ExeName);

end.
