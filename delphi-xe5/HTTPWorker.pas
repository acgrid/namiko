unit HTTPWorker;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, System.DateUtils, System.Diagnostics,
  IdGlobal, IdExceptionCore, IdHTTP, IdLogFile, System.JSON, PerlRegEx,
  NamikoTypes, LogForm, CfgForm;

type
  THTTPWorkerThread = class(TThread)
  constructor Create(AURL: string; Key: string; TimeZoneOffset: Integer; WithLog: string);
  destructor Destroy(); override;
  protected
    Worker: TIdHTTP;
    Logger: TIdLogFile;
    FURL: string;
    FTimeOffset: Integer;
    FRemoteTimeOffset: Integer;
    FKey: string;
    FInterval: Integer;
    FRetryDelay: Integer;
    FPoolCount: Cardinal;
    Hexie: TStringList;
    FHexie: TPerlRegEx;
    FStopwatch: TStopwatch;

    FReqCount, FReqConnTCCount, FReqReadTCCount, FReqClosedCount, FReqErrCount, FReqTotalMS, FReqLastMS: Int64;
    procedure Execute; override;
    procedure ReportLog(Info: string; Level: TLogType = logInfo);
    procedure ReadLines(var AResponse: string; var NextID: Int64);
    procedure ReadSharedConfiguration();
  public
    property HexieList: TStringList read Hexie;
    property ReqCount: Int64 read FReqCount;
    property ReqConnTCCount: Int64 read FReqConnTCCount;
    property ReqReadTCCount: Int64 read FReqReadTCCount;
    property ReqClosedCount: Int64 read FReqClosedCount;
    property ReqErrCount: Int64 read FReqErrCount;
    property ReqTotalMS: Int64 read FReqTotalMS;
    property ReqLastMS: Int64 read FReqLastMS;
    property ServerTimeOffset: Integer read FTimeOffset;
  end;

implementation

uses
  CtrlForm, HexieForm;

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure THTTPWorkerThreads.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end;
    
    or 
    
    Synchronize( 
      procedure 
      begin
        Form1.Caption := 'Updated in thread via an anonymous method' 
      end
      )
    );
    
  where an anonymous method is passed.
  
  Similarly, the developer can call the Queue method with similar parameters as 
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.
    
}

{ THTTPWorkerThreads }

constructor THTTPWorkerThread.Create(AURL: string; Key: string; TimeZoneOffset: Integer; WithLog: string);
begin
  FURL := AURL;
  FKey := Key;
  FTimeOffset := TimeZoneOffset;
  Worker := TIdHTTP.Create(nil);
  if Length(WithLog) > 0 then begin
    Logger := TIdLogFile.Create(nil);
    Logger.Filename := WithLog;
    Logger.ReplaceCRLF := True;
    Logger.LogTime := True;
    Logger.Active := True;
    Worker.Intercept := Logger;
  end;
  Hexie := TStringList.Create();
  HexieMutex.Acquire;
  try
    Hexie.Text := frmWordList.HexieList.Lines.Text;
  finally
    HexieMutex.Release;
  end;
  FHexie := TPerlRegEx.Create();
  FStopwatch := TStopwatch.Create();
  FReqCount := 0;
  FReqConnTCCount := 0;
  FReqReadTCCount := 0;
  FReqClosedCount := 0;
  FReqErrCount := 0;
  FReqTotalMS := 0;
  FReqLastMS := 0;
  inherited Create(False); // Start upon created;
  Priority := tpHigher;
end;

destructor THTTPWorkerThread.Destroy;
begin
  FreeAndNil(Worker);
  FreeAndNil(Logger);
  FreeAndNil(Hexie);
  FreeAndNil(FHexie);
  FreeAndNil(FStopwatch);
  inherited Destroy();
end;

procedure THTTPWorkerThread.Execute;
var
  RequestID, ElaspedMS: Int64;
  Response: string;
  LJSONObject: TJSONObject;
  JResult, JTimestamp, JLastID: TJSONPair;
begin
  NameThreadForDebugging('HTTP');
  { Place thread code here }
  try
  // Test HTTP Connection
    ReadSharedConfiguration();
    try
      Response := Worker.Get(Format('%s?action=init&key=%s',[FURL,FKey]));
      if Assigned(Worker) and (Worker.ResponseCode = 200) and (Length(Response) > 0) then begin
        LJSONObject := TJsonObject.Create;
        try
          try
            LJSONObject.Parse(TEncoding.ASCII.GetBytes(Response),0);
            JResult := LJSONObject.Get('Result');
            JTimestamp := LJSONObject.Get('Timestamp');
            JLastID := LJSONObject.Get('FrontID');
            if Assigned(JTimestamp) and Assigned(JLastID) then begin
              RequestID := StrToInt64(JLastID.JsonValue.Value);
              FRemoteTimeOffset := DateTimeToUnix(Now()) - (StrToInt64(JTimestamp.JsonValue.Value()) - FTimeOffset); // DateTimeToUnix is local timestamp - (PHP's UTC timestamp - offset of local to UTC)
              ReportLog(Format('测试成功，本地-远程时间差%d秒 开始接收网络弹幕',[FRemoteTimeOffset]));
              Synchronize(procedure begin
                with frmControl do begin
                  Networking := True;
                  RadioGroupModes.Enabled := False;
                  editNetPassword.Enabled := False;
                  editNetHost.Enabled := False;
                  btnNetStart.Caption := '停止通信(&M)';
                end;
              end);
            end
            else if Assigned(JResult) then begin
              ReportLog(Format('测试错误：服务器状态 %s',[JResult.JsonValue.Value()]));
              Exit;
            end
            else begin
              ReportLog('测试错误：服务器未返回状态');
              Exit;
            end;
          except
            ReportLog('测试错误：不合法的JSON格式');
            {$IFDEF DEBUG}ReportLog(Response);{$ENDIF}
            Exit;
          end;
        finally
          LJSONObject.Free;
        end;
      end
      else begin
        ReportLog(Format('测试错误：HTTP返回值%u 返回长度 %u',[Worker.ResponseCode,Length(Response)]));
        Exit;
      end;
    except
      on EIdConnectTimeout do begin
        ReportLog('测试错误：连接超时');
        Exit;
      end;
      on EIdReadTimeout do begin
        ReportLog('测试错误：接收超时');
        Exit;
      end;
      on E: Exception do begin
        ReportLog(Format('测试错误：[%s] %s',[E.ClassName,E.Message]));
        Exit;
      end;
    end;
    // Main Loop
    {$IFDEF DEBUG}ReportLog('进入主循环');{$ENDIF}
    while True do begin
      if Terminated then begin
        {$IFDEF DEBUG}ReportLog('退出 #1');{$ENDIF}
        Exit;
      end
      else
        Sleep(FInterval);
      if Terminated then begin
        {$IFDEF DEBUG}ReportLog('退出 #2');{$ENDIF}
        Exit;
      end;
      // Reload Configuration
      ReadSharedConfiguration();
      Inc(FReqCount);
      FStopwatch.Start;
      try
        try
          Response := Worker.Get(Format('%s?action=fetch&key=%s&fromID=%u&totalc=%u',[FURL,FKey,RequestID,FPoolCount]));
          FStopwatch.Stop;
          ElaspedMS := FStopwatch.ElapsedMilliseconds;
          FReqLastMS := ElaspedMS;
          FReqTotalMS := FReqTotalMS + ElaspedMS;
          if Assigned(Worker) and (Worker.ResponseCode = 200) and (Length(Response) > 0) then begin
            try
              ReadLines(Response, RequestID);
            except
              on E: Exception do ReportLog(Format('循环JSON异常：[%s] %s',[E.ClassName,E.Message]));
            end;
          end
          else begin
            ReportLog(Format('循环错误：HTTP返回值%u 返回长度 %u',[Worker.ResponseCode,Length(Response)]));
            Sleep(FRetryDelay);
            Continue;
          end;
        except
          on EIdConnectTimeout do begin
            Inc(FReqConnTCCount);
            Sleep(FRetryDelay);
            Continue;
          end;
          on EIdReadTimeout do begin
            Inc(FReqReadTCCount);
            Sleep(FRetryDelay);
            Continue;
          end;
          on EIdClosedSocket do begin
            Inc(FReqClosedCount);
            Sleep(FRetryDelay);
            Continue;
          end;
          on E: Exception do begin
            ReportLog(Format('其他异常：[%s] %s',[E.ClassName,E.Message]));
            Inc(FReqErrCount);
            Sleep(FRetryDelay);
            Continue;
          end;
        end;
      finally
        FStopwatch.Stop;
        FStopwatch.Reset;
      end;
    end;
  except
    on E: Exception do begin
      {$IFDEF DEBUG}ReportLog(Format('异常%s "%s"',[E.ClassName,E.Message]));{$ENDIF}
      Sleep(FInterval);
    end;
  end;
end;

procedure THTTPWorkerThread.ReadLines(var AResponse: string; var NextID: Int64);
var
  LJsonArr: TJSONArray;
  LJsonValue: TJSONValue;
  LItem: TJSONValue;
  ThisID: Int64;
  RTime, LTime: TDateTime;
  ThisAuthor: TCommentAuthor;
  ThisFormat: TCommentFormat;
  Content: string;
  HexieIndex: Integer;
  TimeFound, IPFound, ContentFound: Boolean;
begin
  LTime := Now();
  ThisFormat.DefaultName := True;
  ThisFormat.DefaultSize := True;
  ThisFormat.DefaultColor := True;
  ThisFormat.DefaultStyle := True;
  try
    LJsonArr := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(AResponse),0) as TJSONArray;
    try
      for LJsonValue in LJsonArr do begin
        TimeFound := False;
        IPFound := False;
        ContentFound := False;
        for LItem in TJSONArray(LJsonValue) do begin
          if TJSONPair(LItem).JsonString.Value = 'ID' then begin
            ThisID := StrToInt64(TJSONPair(LItem).JsonValue.Value());
            if ThisID > NextID then NextID := ThisID;
          end;
          if TJSONPair(LItem).JsonString.Value = 'Timestamp' then begin
            RTime := UnixToDateTime(StrToInt64(TJSONPair(LItem).JsonValue.Value()) - FTimeOffset + FRemoteTimeOffset);
            TimeFound := True;
          end;
          if TJSONPair(LItem).JsonString.Value = 'IP' then begin
            ThisAuthor.Source := TAuthorSource.Internet;
            ThisAuthor.Address := TJSONPair(LItem).JsonValue.Value;
            IPFound := True;
          end;
          if TJSONPair(LItem).JsonString.Value = 'Content' then begin
            Content := TJSONPair(LItem).JsonValue.Value;
            ContentFound := True;
          end;
        end;
        HexieMutex.Acquire;
        try
          try
            FHexie.Subject := Content;
            for HexieIndex := 0 to Hexie.Count - 1 do begin
              FHexie.RegEx := Hexie.Strings[HexieIndex];
              if FHexie.Match then begin
                ReportLog(Format('[PCRE] 已和谐来自%s的弹幕"%s"',[ThisAuthor.Address,Content]));
                Exit;
              end;
            end;
          except
            on E:Exception do begin
              ReportLog('[PCRE] 正则表达式错误：'+E.Message);
            end;
          end;
        finally
          HexieMutex.Release;
        end;
        if TimeFound and IPFound and ContentFound then begin
          Synchronize(procedure begin
            frmControl.AppendNetComment(LTime,RTime,ThisAuthor,Content,ThisFormat);
          end);
        end;
      end;
      finally
        LJsonArr.Free;
      end;
    except
      on E: Exception do begin
      {$IFDEF DEBUG}ReportLog(Format('JSON 解析异常 %s "%s"',[E.ClassName,E.Message]));{$ENDIF}
      Sleep(FInterval);
      end;
    end;
end;

procedure THTTPWorkerThread.ReportLog(Info: string; Level: TLogType = logInfo);
begin
  frmLog.LogAdd(Info, 'HTTP', Level);
end;

procedure THTTPWorkerThread.ReadSharedConfiguration;
begin
  {HTTPSharedMutex.Acquire;
  try}
  with frmConfig do begin
    FInterval := IntegerItems['HTTP.Interval'];

    Worker.ConnectTimeout := IntegerItems['HTTP.ConnTimeout'];
    Worker.ReadTimeout := IntegerItems['HTTP.RecvTimeout'];

    FRetryDelay := IntegerItems['HTTP.RetryDelay'];
  end;
  FPoolCount := frmControl.CommentPool.Count;
  {finally
    HTTPSharedMutex.Release;
  end;}
end;

end.
