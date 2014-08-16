unit HTTPWorker;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, System.DateUtils,
  IdGlobal, IdExceptionCore, IdHTTP, IdLogFile, Data.DBXJSON;

type
  THTTPWorkerThread = class(TThread)
  constructor Create(AURL: string; Key: string; TimeZoneOffset: Integer; WithLog: string);
  destructor Destroy(); override;
  protected
    Worker: TIdHTTP;
    Logger: TIdLogFile;
    FURL: string;
    FTimeOffset: Integer;
    FKey: string;
    FTimeout: Integer;
    FInterval: Integer;
    FPoolCount: Cardinal;
    procedure Execute; override;
    procedure ReportLog(Info: string);
    procedure ReadLines(var AResponse: string);
    procedure ReadSharedConfiguration();
  end;

implementation

uses
  CtrlForm;

const
  HTTP_RETRY_DELAY = 1000;
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
  inherited Create(False); // Start upon created;
end;

destructor THTTPWorkerThread.Destroy;
begin
  Worker.Free;
  Logger.Free;
  inherited Destroy();
end;

procedure THTTPWorkerThread.Execute;
var
  RequestTimestamp: Int64;
  RemoteTimeOffset: Integer;
  Response: string;
  LJSONObject: TJSONObject;
  JResult, JTimestamp: TJSONPair;
  JIndex: Integer;
begin
  NameThreadForDebugging('HTTP');
  { Place thread code here }
  try
  // Test HTTP Connection
    ReadSharedConfiguration();
    Worker.ConnectTimeout := FTimeout;
    Worker.ReadTimeout := FTimeout;
    try
      Response := Worker.Get(Format('%s?action=init&key=%s',[FURL,FKey]));
      if (Worker.ResponseCode = 200) and (Length(Response) > 0) then begin
        LJSONObject := TJsonObject.Create;
        try
          try
            LJSONObject.Parse(TEncoding.ASCII.GetBytes(Response),0);
            JResult := LJSONObject.Get('Result');
            JTimestamp := LJSONObject.Get('Timestamp');
            if Assigned(JTimestamp) then begin
              RequestTimestamp := StrToInt64(JTimestamp.JsonValue.Value());
              RemoteTimeOffset := DateTimeToUnix(Now()) - (RequestTimestamp - FTimeOffset); // DateTimeToUnix is local timestamp - (PHP's UTC timestamp - offset of local to UTC)
              ReportLog(Format('[HTTP] 测试成功，本地-远程时间差%d秒 开始接收网络弹幕',[RemoteTimeOffset]));
              Synchronize(procedure begin
                with frmControl do begin
                  CheckboxHTTPLog.Enabled := False;
                  Networking := True;
                  radioNetPasv.Enabled := False;
                  radioNetTransmit.Enabled := False;
                  radioNetPasv.Enabled := False;
                  editNetPassword.Enabled := False;
                  editNetHost.Enabled := False;
                  btnNetStart.Caption := '停止通信(&M)';
                end;
              end);
            end
            else if Assigned(JResult) then begin
              ReportLog(Format('[HTTP] 测试错误：服务器状态 %s',[JResult.JsonValue.Value()]));
              Exit;
            end
            else begin
              ReportLog('[HTTP] 测试错误：服务器未返回状态');
              Exit;
            end;
          except
            ReportLog('[HTTP] 测试错误：不合法的JSON格式');
            {$IFDEF DEBUG}ReportLog(Response);{$ENDIF}
            Exit;
          end;
        finally
          LJSONObject.Free;
        end;
      end
      else begin
        ReportLog(Format('[HTTP] 测试错误：HTTP返回值%u 返回长度 %u',[Worker.ResponseCode,Length(Response)]));
        Exit;
      end;
    except
      on EIdConnectTimeout do begin
        ReportLog('[HTTP] 测试错误：连接超时');
        Exit;
      end;
      on EIdReadTimeout do begin
        ReportLog('[HTTP] 测试错误：接收超时');
        Exit;
      end;
      on E: Exception do begin
        ReportLog(Format('[HTTP] 测试错误：[%s] %s',[E.ClassName,E.Message]));
        Exit;
      end;
    end;
    // Main Loop
    {$IFDEF DEBUG}ReportLog('[HTTP] 进入主循环');{$ENDIF}
    while True do begin
      if Terminated then begin
        {$IFDEF DEBUG}ReportLog('[HTTP] 退出 #1');{$ENDIF}
        Exit;
      end;
      // Reload Configuration
      ReadSharedConfiguration();
      Worker.ConnectTimeout := FTimeout;
      Worker.ReadTimeout := FTimeout;
      try
        Response := Worker.Get(Format('%s?action=fetch&key=%s&from=%u&totalc=%u',[FURL,FKey,RequestTimestamp,FPoolCount]));
        if (Worker.ResponseCode = 200) and (Length(Response) > 0) then begin
          try
            ReadLines(Response);
            RequestTimestamp := DateTimeToUnix(Now()) + FTimeOffset;
          except
            on E: Exception do ReportLog(Format('[HTTP] 循环JSON异常：[%s] %s',[E.ClassName,E.Message]));
          end;
        end
        else begin
          ReportLog(Format('[HTTP] 循环错误：HTTP返回值%u 返回长度 %u',[Worker.ResponseCode,Length(Response)]));
          Sleep(HTTP_RETRY_DELAY);
          Continue;
        end;
      except
        on EIdConnectTimeout do begin
          ReportLog('[HTTP] 连接超时');
          Sleep(HTTP_RETRY_DELAY);
          Continue;
        end;
        on EIdReadTimeout do begin
          ReportLog('[HTTP] 接收超时');
          Sleep(HTTP_RETRY_DELAY);
          Continue;
        end;
        on E: Exception do begin
          ReportLog(Format('[HTTP] 循环异常：[%s] %s',[E.ClassName,E.Message]));
          Sleep(HTTP_RETRY_DELAY);
          Continue;
        end;
      end;
      if Terminated then begin
        {$IFDEF DEBUG}ReportLog('[HTTP] 退出 #2');{$ENDIF}
        Exit;
      end;
      Sleep(FInterval);
    end;
  except
    on E: Exception do begin
      {$IFDEF DEBUG}ReportLog(Format('[HTTP] 异常%s "%s"',[E.ClassName,E.Message]));{$ENDIF}
      Sleep(FInterval);
    end;
  end;
end;

procedure THTTPWorkerThread.ReadLines(var AResponse: string);
var
  LJsonArr: TJSONArray;
  LJsonValue: TJSONValue;
  LItem: TJSONValue;
  RTime, LTime: TDateTime;
  ThisAuthor: TCommentAuthor;
  ThisFormat: TCommentFormat;
  Content: string;
  TimeFound, IPFound, ContentFound: Boolean;
begin
  LTime := Now();
  ThisFormat.DefaultName := True;
  ThisFormat.DefaultSize := True;
  ThisFormat.DefaultColor := True;
  ThisFormat.DefaultStyle := True;
  try
  LJsonArr := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(AResponse),0) as TJSONArray;
  for LJsonValue in LJsonArr do begin
    TimeFound := False;
    IPFound := False;
    ContentFound := False;
    for LItem in TJSONArray(LJsonValue) do begin
      if TJSONPair(LItem).JsonString.Value = 'Timestamp' then begin
        RTime := UnixToDateTime(StrToInt64(TJSONPair(LItem).JsonValue.Value()) - FTimeOffset);
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
    if TimeFound and IPFound and ContentFound then begin
      Synchronize(procedure begin
        frmControl.AppendNetComment(LTime,RTime,ThisAuthor,Content,ThisFormat);
      end);
    end;
  end;
  finally
    LJsonArr.Free;
  end;
end;

procedure THTTPWorkerThread.ReportLog(Info: string);
begin
  Synchronize(procedure begin
    if Assigned(frmControl) then frmControl.LogEvent(Info);
  end);
end;

procedure THTTPWorkerThread.ReadSharedConfiguration;
begin
  HTTPSharedMutex.Acquire;
  try
    FTimeout := frmControl.HTTPTimeout;
    FInterval := frmControl.HTTPInterval;
    FPoolCount := frmControl.CommentPool.Count;
  finally
    HTTPSharedMutex.Release;
  end;
end;

end.
