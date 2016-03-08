unit HTTPImageWorker;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.JSON,
  IdGlobal, IdExceptionCore, IdHTTP, IdLogFile, IdComponent,
  NamikoTypes;

type
  THTTPImageAction = (LIST, DOWNLOAD, COMMIT, DISCARD);

type
  THTTPImageWorker = class(TThread)
  constructor Create();
  destructor Destroy(); override;
  protected
    FAction: THTTPImageAction;
    FBaseURL, FKey, FImageKey, FSavePath: string;
    FTZOffset: Integer;
    FID: Int64;
    FThreadID: Cardinal;
    Worker: TIdHTTP;
    Logger: TIdLogFile;
    LastestProgress: Integer;
    function ConvertTS(StdUnixTS: Int64): TDateTime;
    procedure RequestForString(AURL: string; var Response: string);
    procedure DoList;
    procedure DoDownload;
    procedure DoCommit;
    procedure DoDiscard;
    procedure Execute; override;
    procedure ReportLog(Info: string; Level: TLogType = logInfo);
    procedure DownloadProgress(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    class var NextID: Cardinal;
  public
    property Action: THTTPImageAction read FAction;
    procedure List();
    procedure Download(ID: Int64; Key, SavePath: string);
    procedure Commit(ID: Int64);
    procedure Discard(ID: Int64);
  end;

implementation

uses
  CfgForm, CtrlForm, ImageMgrForm, LogForm;

{ 
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);  

  and UpdateCaption could look like,

    procedure THTTPImageWorker.UpdateCaption;
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

{ THTTPImageWorker }

constructor THTTPImageWorker.Create();
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
    Logger.Filename := APP_DIR + 'HTTP-IMG-' + IntToStr(FThreadID) + '.log';
    Logger.ReplaceCRLF := True;
    Logger.LogTime := True;
    Logger.Active := True;
    Worker.Intercept := Logger;
  {$ENDIF}
  inherited Create(True);
end;

destructor THTTPImageWorker.Destroy;
begin
  FreeAndNil(Worker);
  FreeAndNil(Logger);
  inherited Destroy();
end;

function THTTPImageWorker.ConvertTS(StdUnixTS: Int64): TDateTime;
begin
  if StdUnixTS = 0 then
    Result := 0
  else begin
    Result := UnixToDateTime(StdUnixTS - FTZOffset);
  end;
end;

procedure THTTPImageWorker.ReportLog(Info: string; Level: TLogType = logInfo);
begin
  if Assigned(frmLog) then frmLog.LogAdd(Info, 'IMT' + IntToStr(FThreadID), Level);
end;

procedure THTTPImageWorker.RequestForString(AURL: string; var Response: string);
begin
  Response := Worker.Get(AURL);
  if (Worker.ResponseCode <> 200) or (Length(Response) = 0) then
    raise Exception.Create(Format('HTTP返回值%u 返回长度 %u',[Worker.ResponseCode, Length(Response)]));
end;

procedure THTTPImageWorker.List();
begin
  FAction := THTTPImageAction.LIST;
  Start;
end;

procedure THTTPImageWorker.DoList;
var
  Response: string;
  JSONArray: TJSONArray;
  JSONValue: TJSONValue;
  JSONItem: TJSONObject;
  ID, ImageFileSize: Int64;
  RecvTime, CommitTime: TTime;
  Author: TCommentAuthor;
  ImageKey, ImageSignature: string;
begin
  try
    RequestForString(Format('%s?action=image-list&key=%s',[FBaseURL, FKey]), Response);
    JSONArray := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Response), 0) as TJSONArray;
    for JSONValue in JSONArray do begin
      JSONItem := JSONValue as TJSONObject;
      ID := TJSONNumber(JSONItem.GetValue('ID')).AsInt64;
      RecvTime := ConvertTS(TJSONNumber(JSONItem.GetValue('TS')).AsInt64);
      CommitTime := ConvertTS(TJSONNumber(JSONItem.GetValue('COMMIT')).AsInt64);
      Author.Source := TAuthorSource.Internet;
      Author.Address := JSONItem.GetValue('IP').Value;
      Author.Group := JSONItem.GetValue('UG').Value;
      ImageKey := TJSONObject(JSONItem.GetValue('IMG')).GetValue('KEY').Value;
      ImageSignature := TJSONObject(JSONItem.GetValue('IMG')).GetValue('SIGN').Value;
      ImageFileSize := TJSONNumber(TJSONObject(JSONItem.GetValue('IMG')).GetValue('SIZE')).AsInt64;
      Synchronize(procedure begin
        frmImageManager.AddImageComment(ID, RecvTime, CommitTime, Author, ImageKey, ImageSignature, ImageFileSize);
      end);
    end;
  finally
    Synchronize(procedure begin
      frmImageManager.ActionLoadListOKExecute(frmImageManager);
    end);
  end;
end;

procedure THTTPImageWorker.DownloadProgress(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
var
  HTTP: TIdHTTP;
  ContentLength: Int64;
  CurrentPercent: Integer;
begin
  Http := TIdHTTP(ASender);
  ContentLength := Http.Response.ContentLength;

  if (Pos('chunked', LowerCase(Http.Response.TransferEncoding)) = 0) and
     (ContentLength > 0) then begin
    CurrentPercent := 100 * AWorkCount div ContentLength;
    if CurrentPercent <> LastestProgress then begin
      LastestProgress := CurrentPercent;
      Synchronize(procedure begin
        frmImageManager.FindListItem(FID).SubItems.Strings[TI_FLAG_DL] := Format('%d%%', [CurrentPercent]);
      end);
    end;
  end;
end;

procedure THTTPImageWorker.Download(ID: Int64; Key: string; SavePath: string);
begin
  FAction := THTTPImageAction.DOWNLOAD;
  FID := ID;
  FImageKey := Key;
  FSavePath := SavePath;
  ReportLog(Format('开始下载图片 %s', [Key]));
  Start;
end;

procedure THTTPImageWorker.DoDownload;
var
  OutStream: TFileStream;
begin
  OutStream := TFileStream.Create(FSavePath, fmCreate or fmShareDenyWrite);
  LastestProgress := 0;
  try
    Worker.OnWork := DownloadProgress;
    Worker.Get(Format('%s?action=image-download&key=%s&image=%s',[FBaseURL, FKey, FImageKey]), OutStream);
    if Worker.ResponseCode <> 200 then begin
      raise Exception.Create(Format('下载失败，返回值%u 长度%u',[Worker.ResponseCode, Worker.Response.ContentLength]));
    end;
  finally
    OutStream.Free;
  end;
  Synchronize(procedure begin
    frmImageManager.NotifyDownloaded(FID);
  end);
end;

procedure THTTPImageWorker.Commit(ID: Int64);
begin
  FAction := THTTPImageAction.COMMIT;
  FID := ID;
  Start;
end;

procedure THTTPImageWorker.DoCommit;
var
  Response: string;
  JSONResult: TJSONObject;
begin
  RequestForString(Format('%s?action=image-commit&key=%s&id=%u',[FBaseURL, FKey, FID]), Response);
  JSONResult := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Response), 0) as TJSONObject;
  if JSONResult.GetValue('Result').Value = 'OK' then Synchronize(procedure begin
    frmImageManager.NotifyCommitted(FID);
  end);
end;

procedure THTTPImageWorker.Discard(ID: Int64);
begin
  FAction := THTTPImageAction.DISCARD;
  FID := ID;
  Start;
end;

procedure THTTPImageWorker.DoDiscard;
var
  Response: string;
  JSONResult: TJSONObject;
begin
  RequestForString(Format('%s?action=image-discard&key=%s&id=%u',[FBaseURL, FKey, FID]), Response);
  JSONResult := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Response), 0) as TJSONObject;
  if JSONResult.GetValue('Result').Value = 'OK' then Synchronize(procedure begin
    frmImageManager.NotifyDiscarded(FID);
  end);
end;

procedure THTTPImageWorker.Execute;
begin
  NameThreadForDebugging('HTTPImage');
  try
    case FAction of
      THTTPImageAction.LIST: DoList;
      THTTPImageAction.DOWNLOAD: DoDownload;
      THTTPImageAction.COMMIT: DoCommit;
      THTTPImageAction.DISCARD: DoDiscard;
    end;
  except
    on EIdConnectTimeout do begin
      ReportLog('连接超时');
    end;
    on EIdReadTimeout do begin
      ReportLog('接收超时');
      Exit;
    end;
    on E: Exception do begin
      ReportLog(Format('HTTP错误：[%s] %s',[E.ClassName,E.Message]));
      Exit;
    end;
  end;
end;

end.
