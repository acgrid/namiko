unit HTTPWorker;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs,
  IdGlobal, IdHTTP, IdLogFile;

type
  THTTPWorkerThread = class(TThread)
  constructor Create(AURL: string; WithLog: string);
  destructor Destroy(); override;
  protected
    Worker: TIdHTTP;
    Logger: TIdLogFile;
    TargetURL: string;
    procedure Execute; override;
    procedure ReportLog(Info: string);
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

constructor THTTPWorkerThread.Create(AURL: string; WithLog: string);
begin
  TargetURL := AURL;
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
end;

procedure THTTPWorkerThread.Execute;
var
    RequestTimestamp: Cardinal;
begin
  NameThreadForDebugging('HTTP');
  { Place thread code here }
  try
  // Test HTTP Connection
    // Main Loop
    {$IFDEF DEBUG}ReportLog('[HTTP] 进入主循环');{$ENDIF}
    while True do begin
      if Terminated then begin
        {$IFDEF DEBUG}ReportLog('[HTTP] 退出 #1');{$ENDIF}
        Exit;
      end;

    end;
  except
    on E: Exception do begin
      {$IFDEF DEBUG}ReportLog(Format('[HTTP] 异常%s "%s"',[E.ClassName,E.Message]));{$ENDIF}
      Sleep(1000);
    end;
  end;
end;

procedure THTTPWorkerThread.ReportLog(Info: string);
begin
  Synchronize(procedure begin
    if Assigned(frmControl) then frmControl.LogEvent(Info);
  end);
end;

end.
