unit TCPClientWorker;

interface

uses
  System.Classes, NamikoTypes, LogForm, IdTCPClient, IdSocketHandle, System.JSON;

type
  TCPClientThread = class(TThread)
  constructor Create(ConnectionString: string);
  destructor Destroy(); override;
  protected
    Client: TIdTCPClient;
    FHost, FActivity: string;
    FPort: Word;
    procedure Execute; override;
    procedure ReportLog(Info: string; Level: TLogType = logInfo);
  end;

implementation

uses
  CtrlForm, System.SysUtils;

{ 
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);  

  and UpdateCaption could look like,

    procedure TCPClientThread.UpdateCaption;
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

{ TCPClientThread }

constructor TCPClientThread.Create(ConnectionString: string);
var
  PortPosition, ActivityPosition: Integer;
begin
  PortPosition := Pos(':', ConnectionString);
  ActivityPosition := Pos('/', ConnectionString);
  FHost := Copy(ConnectionString, 0, PortPosition);
  FPort := StrToIntDef(Copy(ConnectionString, PortPosition + 1, ActivityPosition), 40000);
  FActivity := Copy(ConnectionString, ActivityPosition + 1, Length(ConnectionString) - ActivityPosition);
  inherited Create(False); // Start upon created;
  Priority := tpHigher;
end;

destructor TCPClientThread.Destroy;
begin
  inherited Destroy();
end;

procedure TCPClientThread.Execute;
begin
  NameThreadForDebugging('TCPClient');
  { Place thread code here }
  Client := TIdTCPClient.Create();
  Client.Host := FHost;
  Client.Port := FPort;
  Client.Connect;
  if Client.Connected then Client.Socket.Write(FActivity);
  while Client.Connected do begin
    if Terminated then begin
      Client.Disconnect;
      Exit;
    end;
    if Client.IOHandler.InputBufferIsEmpty then
      Sleep(100)
    else begin
      ReportLog(Client.IOHandler.ReadLn());
    end;
  end;

end;

procedure TCPClientThread.ReportLog(Info: string; Level: TLogType = logInfo);
begin
  if Assigned(frmLog) then frmLog.LogAdd(Info, 'TCP', Level);
end;

end.
