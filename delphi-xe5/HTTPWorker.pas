unit HTTPWorker;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs,
  IdGlobal, IdExceptionCore, IdHTTP, IdLogFile, Data.DBXJSON;

type
  THTTPWorkerThread = class(TThread)
  constructor Create(AURL: string; Key: string; WithLog: string);
  destructor Destroy(); override;
  protected
    Worker: TIdHTTP;
    Logger: TIdLogFile;
    FURL: string;
    FKey: string;
    FTimeout: Integer;
    FInterval: Integer;
    procedure Execute; override;
    procedure ReportLog(Info: string);
    procedure ReadSharedConfiguration();
  end;

implementation

uses
  CtrlForm;
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

constructor THTTPWorkerThread.Create(AURL: string; Key: string; WithLog: string);
begin
  FURL := AURL;
  FKey := Key;
  Worker := TIdHTTP.Create(nil);
  if Length(WithLog) > 0 then begin
    Logger := TIdLogFile.Create(nil);
    Logger.Filename := WithLog;
    Logger.ReplaceCRLF := True;
    Logger.LogTime := True;
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
    RequestTimestamp: Cardinal;
    Response: string;
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
        {$IFDEF DEBUG}ReportLog(Response);{$ENDIF}
        ReportLog('[HTTP] 测试成功，开始接收网络弹幕');
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
      else begin
        ReportLog(Format('[HTTP] 测试结果错误 HTTP返回值%u 返回长度 %u',[Worker.ResponseCode,Length(Response)]));
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

      Sleep(FInterval);
    end;
  except
    on E: Exception do begin
      {$IFDEF DEBUG}ReportLog(Format('[HTTP] 异常%s "%s"',[E.ClassName,E.Message]));{$ENDIF}
      Sleep(FInterval);
    end;
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
  finally
    HTTPSharedMutex.Release;
  end;
end;

end.
