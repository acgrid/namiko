unit UDPHandleThread;

interface

uses
  System.SysUtils, System.DateUtils, System.UIConsts,
  IdUDPServer, IdGlobal, Data.DBXJSON;

type
  TUDPHandleThread = class(TIdUDPListenerThread)
  protected
    procedure Run; override; // REMIND: UDPRead & UDPException is not marked override-able so you have to override the upper procedure
  public
    procedure UDPRead;
    procedure UDPException;
    procedure UDPResponse(AResponse: TJSONObject);
end;

implementation

uses
  CtrlForm;

{ TUDPHandleThread }

function ParseFormatData(const JFormat: TJSONObject): TCommentFormat;
var
  JFontName, JFontSize, JFontColor, JFontStyle: TJSONPair;
  AFontName, AFontSize, AFontColor, AFontStyle: string;
const
  DEFAULT_FONTNAME = 'DEF_FN';
  DEFAULT_FONTSIZE = 'DEF_FS';
  DEFAULT_FONTCOLOR = 'DEF_FC';
  DEFAULT_FONTSTYLE = 'DEF_FP';
begin
  JFontName := JFormat.Get('N');
  JFontSize := JFormat.Get('S');
  JFontColor := JFormat.Get('C');
  JFontStyle := JFormat.Get('D');
  if Assigned(JFontName) then begin
    AFontName := JFontName.JsonValue.Value();
    if AFontName = DEFAULT_FONTNAME then
      Result.DefaultName := True
    else begin
      Result.DefaultName := False;
      Result.FontName := AFontName;
    end;
  end
    else Result.DefaultName := True;
  if Assigned(JFontSize) then begin
    AFontSize := JFontSize.JsonValue.Value();
    if AFontSize = DEFAULT_FONTSIZE then
      Result.DefaultSize := True
    else begin
      Result.DefaultSize := False;
      Result.FontSize := StrToFloat(AFontSize);
    end;
  end
  else
    Result.DefaultSize := True;
  if Assigned(JFontColor) then begin
    AFontColor := JFontColor.JsonValue.Value();
    if AFontColor = DEFAULT_FONTCOLOR then
      Result.DefaultColor := True
    else begin
      Result.DefaultColor := False;
      Result.FontColor := StringToAlphaColor(AFontColor);
    end;
  end
  else
    Result.DefaultColor := True;
  if Assigned(JFontStyle) then begin
    AFontStyle := JFontStyle.JsonValue.Value();
    if AFontStyle = DEFAULT_FONTSTYLE then
      Result.DefaultStyle := True
    else begin
      Result.DefaultStyle := False;
      Result.FontStyle := 0; // Manually set to NORMAL
    end;
  end
  else
    Result.DefaultStyle := True;
end;

procedure TUDPHandleThread.Run;
var
  PeerIP: string;
  PeerPort : TIdPort;
  PeerIPVersion: TIdIPVersion;
  ByteCount: Integer;
begin
  if FBinding.Select(AcceptWait) then try
    // Doublecheck to see if we've been stopped
    // Depending on timing - may not reach here if it is in ancestor run when thread is stopped
    if not Stopped then begin
      SetLength(FBuffer, FServer.BufferSize);
      ByteCount := FBinding.RecvFrom(FBuffer, PeerIP, PeerPort, PeerIPVersion);
      FBinding.SetPeer(PeerIP, PeerPort, PeerIPVersion);
      if ByteCount > 0 then
      begin
        SetLength(FBuffer, ByteCount);
        if FServer.ThreadedEvent then begin
          UDPRead;
        end else begin
          Synchronize(UDPRead);
        end;
      end;
    end;
  except
    // exceptions should be ignored so that other clients can be served in case of a DOS attack
    on E : Exception do
    begin
      FCurrentException := E.Message;
      FCurrentExceptionClass := E.ClassType;
      if FServer.ThreadedEvent then begin
        UDPException;
      end else begin
        Synchronize(UDPException);
      end;
    end;
  end;
end;

procedure TUDPHandleThread.UDPRead;
var
  Request, Content: string;
  Len: Cardinal;
  LTime, RTime: TDateTime;
  LJSONObject, RJSONObject: TJSONObject;
  JRequest, JAuth, JContent, JSource, JTime: TJSONPair; // Confirm: Memory Leak?
  ThisAuthor: TCommentAuthor;
  ThisFormat: TCommentFormat;
begin
  LJSONObject := TJsonObject.Create;
  try
    RJSONObject := TJsonObject.Create;
    try
      LJSONObject.Parse(BytesOf(FBuffer,Length(FBuffer)), 0);
      JRequest := LJSONObject.Get('Request');
      if Assigned(JRequest) then begin
        Request := JRequest.JsonValue.Value();
        LTime := Now();
        if Request = 'Query' then begin
          CommentPoolMutex.Acquire; // CS: Read the comment count
          try
            Len := frmControl.CommentPool.Count;
          finally
            CommentPoolMutex.Release;
          end;
          RJSONObject.AddPair('Result','QueryOK');
          RJSONObject.AddPair('CommentCount',IntToStr(Len));
          RJSONObject.AddPair('LocalTime',TimeToStr(LTime));
          UDPResponse(RJSONObject);
        end
        else if Request = 'Data' then begin
          JAuth := LJSONObject.Get('Auth');
          if Assigned(JAuth) then begin // Check Auth Key
            SharedConfigurationMutex.Acquire; // frmControl.NetPassword
            try
              if JAuth.JsonValue.Value() <> frmControl.NetPassword then begin
                RJSONObject.AddPair('Result','Rejected');
                RJSONObject.AddPair('Reason','Key dismatch');
                UDPResponse(RJSONObject);
                Exit;
              end;
            finally
              SharedConfigurationMutex.Release;
            end;
          end
          else begin
            RJSONObject.AddPair('Result','Bad Request');
            RJSONObject.AddPair('Debug','Missing Auth Field');
            UDPResponse(RJSONObject);
            Exit; // Finally block will be executed. Do not be afraid
          end;
          JContent := LJSONObject.Get('Content');
          if Assigned(JContent) then begin
            Content := JContent.JsonValue.Value();
            Len := Length(Content);
            if Len = 0 then begin
              RJSONObject.AddPair('Result','Rejected');
              RJSONObject.AddPair('Reason','Empty Content');
              UDPResponse(RJSONObject);
              Exit;
            end;
            if Len > 1000 then begin // TODO
              RJSONObject.AddPair('Result','Rejected');
              RJSONObject.AddPair('Reason','Large Content');
              UDPResponse(RJSONObject);
              Exit;
            end;
            // Hexie Test
          end
          else begin
            RJSONObject.AddPair('Result','Bad Request');
            RJSONObject.AddPair('Debug','Missing Content Field');
            UDPResponse(RJSONObject);
            Exit;
          end;
          JSource := LJSONObject.Get('Source');
          if Assigned(JSource) then begin
            ThisAuthor.Source := TAuthorSource.Internet;
            ThisAuthor.Address := JSource.JsonValue.Value();
          end
          else begin
            RJSONObject.AddPair('Result','Bad Request');
            RJSONObject.AddPair('Debug','Missing Source Field');
            UDPResponse(RJSONObject);
            Exit;
          end;
          JTime := LJSONObject.Get('Time');
          if Assigned(JTime) then begin
            RTime := UnixToDateTime(StrToInt64(JTime.JsonValue.Value()));
          end
          else begin
            RJSONObject.AddPair('Result','Bad Request');
            RJSONObject.AddPair('Debug','Missing Time Field');
            UDPResponse(RJSONObject);
            Exit;
          end;
          ThisFormat := ParseFormatData(LJSONObject);
          // Response
          RJSONObject.AddPair('Result','Recvived');
          RJSONObject.AddPair('Length',IntToStr(Len));
          UDPResponse(RJSONObject);
          // Construct the record and sync to Main thread
          Synchronize(procedure begin
            frmControl.AppendNetComment(LTime,RTime,ThisAuthor,Content,ThisFormat);
          end);
        end
        else begin
          RJSONObject.AddPair('Result','Bad Request');
          RJSONObject.AddPair('Debug','Unknown Request Type: '+Request);
          UDPResponse(RJSONObject);
          Exit;
        end
      end
      else begin
        RJSONObject.AddPair('Result','Bad Request');
        RJSONObject.AddPair('Debug','Missing Request Field');
        UDPResponse(RJSONObject);
        Exit;
      end;
    finally
      RJSONObject.Free;
    end;
  finally
    LJSONObject.Free;
  end;
end;

procedure TUDPHandleThread.UDPException;
begin
  Synchronize(procedure begin
    frmControl.LogEvent(Format('UDP “Ï≥£: %s',[FCurrentException]));
  end);
end;

procedure TUDPHandleThread.UDPResponse(AResponse: TJSONObject);
begin
  if Assigned(AResponse) then FBinding.SendTo(FBinding.PeerIP,FBinding.PeerPort,
    AResponse.ToString(),FBinding.IPVersion,IndyTextEncoding_UTF8());
end;

end.
