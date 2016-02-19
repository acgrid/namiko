unit HTTPMsgWorker;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.JSON,
  IdGlobal, IdExceptionCore, IdHTTP, IdLogFile,
  NamikoTypes;

type
  TMsgAction = (LIST, MARKDONE);

type
  THTTPMsgWorker = class(TThread)
  constructor Create();
  destructor Destroy(); override;
  protected
    FAction: TMsgAction;
    FBaseURL, FKey: string;
    FTZOffset: Integer;
    FID: Int64;
    FThreadID: Cardinal;
    Worker: TIdHTTP;
    Logger: TIdLogFile;
    function ConvertTS(StdUnixTS: Int64): TDateTime;
    procedure RequestForString(AURL: string; var Response: string);
    procedure DoList;
    procedure DoMarkDone;
    procedure Execute; override;
    procedure ReportLog(Info: string; Level: TLogType = logInfo);
    class var NextID: Cardinal;
  public
    property Action: TMsgAction read FAction;
    procedure List();
    procedure MarkDone(ID: Int64);
  end;

implementation

uses
  CfgForm, CtrlForm, LogForm, MsgViewForm;
{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);  

  and UpdateCaption could look like,

    procedure THTTPMsgWorker.UpdateCaption;
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

{ THTTPMsgWorker }

constructor THTTPMsgWorker.Create;
begin
  FreeOnTerminate := True;
  Worker := TIdHTTP.Create(nil);
  with frmControl do begin
    FBaseURL := editNetHost.Text;
    FKey := NetPassword;
    FTZOffset := TimeZoneBias;
  end;
  with frmConfig do begin
    Worker.ConnectTimeout := IntegerItems['HTTP.ConnTimeout'];
    Worker.ReadTimeout := IntegerItems['HTTP.RecvTimeout'];
  end;
  Inc(NextID);
  FThreadID := NextID;
  {$IFDEF DEBUG}
    Logger := TIdLogFile.Create(nil);
    Logger.Filename := APP_DIR + 'HTTP-MSG-' + IntToStr(FThreadID) + '.log';
    Logger.ReplaceCRLF := True;
    Logger.LogTime := True;
    Logger.Active := True;
    Worker.Intercept := Logger;
  {$ENDIF}
  inherited Create(True);
end;

destructor THTTPMsgWorker.Destroy;
begin
  FreeAndNil(Worker);
  FreeAndNil(Logger);
  inherited Destroy();
end;

function THTTPMsgWorker.ConvertTS(StdUnixTS: Int64): TDateTime;
begin
  if StdUnixTS = 0 then
    Result := 0
  else begin
    Result := UnixToDateTime(StdUnixTS - FTZOffset);
  end;
end;

procedure THTTPMsgWorker.RequestForString(AURL: string; var Response: string);
begin
  Response := Worker.Get(AURL);
  if (Worker.ResponseCode <> 200) or (Length(Response) = 0) then
    raise Exception.Create(Format('HTTP����ֵ%u ���س��� %u',[Worker.ResponseCode, Length(Response)]));
end;

procedure THTTPMsgWorker.ReportLog(Info: string; Level: TLogType = logInfo);
begin
  if Assigned(frmLog) then frmLog.LogAdd(Info, 'MST' + IntToStr(FThreadID), Level);
end;

procedure THTTPMsgWorker.DoList;
var
  Response: string;
  JSONArray: TJSONArray;
  JSONValue: TJSONValue;
  JSONItem: TJSONObject;
  ID: Int64;
  RecvTime: TTime;
  Author: TCommentAuthor;
  MsgType, MsgContent: string;
begin
  RequestForString(Format('%s?action=srv-msg-list&key=%s',[FBaseURL, FKey]), Response);
  JSONArray := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Response), 0) as TJSONArray;
  for JSONValue in JSONArray do begin
    JSONItem := JSONValue as TJSONObject;
    ID := TJSONNumber(JSONItem.GetValue('ID')).AsInt64;
    RecvTime := ConvertTS(TJSONNumber(JSONItem.GetValue('TS')).AsInt64);
    Author.Source := TAuthorSource.Internet;
    Author.Address := JSONItem.GetValue('IP').Value;
    Author.Group := JSONItem.GetValue('UG').Value;
    MsgType := TJSONObject(JSONItem.GetValue('SRV')).GetValue('TYPE').Value;
    MsgContent := TJSONObject(JSONItem.GetValue('SRV')).GetValue('MSG').Value;
    Synchronize(procedure begin
      frmMessages.AddSrvMessage(ID, RecvTime, Author, MsgType, MsgContent);
    end);
  end;
  Synchronize(procedure begin
    frmMessages.NotifyListCompleted;
  end);
end;

procedure THTTPMsgWorker.List;
begin
  FAction := TMsgAction.LIST;
  Start;
end;

procedure THTTPMsgWorker.DoMarkDone;
var
  Response: string;
  JSONResult: TJSONObject;
begin
  RequestForString(Format('%s?action=srv-msg-markdone&key=%s&id=%u',[FBaseURL, FKey, FID]), Response);
  JSONResult := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Response), 0) as TJSONObject;
  if JSONResult.GetValue('Result').Value = 'OK' then Synchronize(procedure begin
    frmMessages.NotifyMarkedDone(FID);
  end);
end;

procedure THTTPMsgWorker.MarkDone(ID: Int64);
begin
  FAction := TMsgAction.MARKDONE;
  FID := ID;
  Start;
end;

procedure THTTPMsgWorker.Execute;
begin
  NameThreadForDebugging('HTTPMsg');
  try
    case FAction of
      TMsgAction.LIST: DoList;
      TMsgAction.MARKDONE: DoMarkDone;
    end;
  except
    on EIdConnectTimeout do begin
      ReportLog('���ӳ�ʱ');
    end;
    on EIdReadTimeout do begin
      ReportLog('���ճ�ʱ');
      Exit;
    end;
    on E: Exception do begin
      ReportLog(Format('HTTP����[%s] %s',[E.ClassName,E.Message]));
      Exit;
    end;
  end;
end;

end.
