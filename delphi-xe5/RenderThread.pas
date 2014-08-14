unit RenderThread;

interface

uses
  System.Classes, System.Types, System.SysUtils, System.UITypes,
  IGDIPlusEmbedded, Winapi.Windows, SyncObjs, System.Generics.Collections,
  Math, CtrlForm;

type
  TCommentUnit = record // Use to render
    PString: PWideChar;
    Length: Integer;
    Left: Integer; // X-Position
    Top: Integer; // Y-Position
    PFontFamily: GPFONTFAMILY;
    FillColor: TAlphaColor;
    //BorderColor: TAlphaColor;
    FontSize: Single;
    FontStyle: Integer;
    // FONT
  end;
type
  PCommentUnit = ^TCommentUnit;
type
  TCommentUnits = TDictionary<Integer,TCommentUnit>; // ID,TCommentUnit
type
  TFontFamilyDict = TDictionary<string,GPFONTFAMILY>;
type
  TRenderThread = class(TThread)
    constructor Create(Handle: HWND; Width: Integer; Height: Integer; var RenderList: TLiveCommentCollection; var UpdateQueue: TRenderUnitQueue);
    destructor Destroy(); override;
  protected
    // Cycle Counter
    FCounter: Int64;
    // GUI Variables
    FMainHandle: HWND;
    FWidth: Integer;
    FHeight: Integer;
    MinFS: Integer;
    // Collections
    FUpdateQueue: PRenderUnitQueue;
    FRenderList: PLiveCommentCollection;
    FRenderBuffer: TCommentUnits;
    // Reuseable GDI+ Resource
    FFFDict: TFontFamilyDict;
    FPGraphic: GpGraphics;
    FPStringFormat: GPSTRINGFORMAT;
    FPPath: GPPATH;
    FPPen: GPPen;
    procedure Calculate(ALiveComment: TLiveComment);
    function ConflictTest(AComment: TLiveComment; FromPos: Integer; ToPos: Integer; Layer: Integer=0): Boolean;
    procedure DoDrawHDC(var ARenderUnit: TRenderUnit);
    procedure DoUpdatePool();
    procedure Execute; override;
    function IsChannelUsed(FromPos, ToPos: Integer; Layer: Integer = 0): Boolean;
    function GetFontFamily(AFontName: WideString): GpFontFamily;
    procedure GetStringDim(AStr: string; AFormat: TCommentFormat; var OWidth: Integer; OHeight: Integer);
    procedure Remove(ALiveComment: TLiveComment);
    procedure ReportLog(Info: string);
    procedure RequestChannel(var AComment: TLiveComment);
    procedure Update(ALiveComment: TLiveComment);
    procedure NotifyStatusChanged(CommentID: Integer);
  end;

implementation

{ 
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);  

  and UpdateCaption could look like,

    procedure TRenderThread.UpdateCaption;
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

{ TRenderThread }

constructor TRenderThread.Create(Handle: HWND; Width: Integer; Height: Integer; var RenderList: TLiveCommentCollection; var UpdateQueue: TRenderUnitQueue);
begin
  FMainHandle := Handle;
  FWidth := Width;
  FHeight := Height;
  FFFDict := TFontFamilyDict.Create();

  GdipCreateFromHWND(FMainHandle,FPGraphic);
  GdipCreateStringFormat(0,LANG_NEUTRAL,FPStringFormat);
  GdipCreatePath(FillModeAlternate,FPPath);
  GdipCreatePen1(DEFAULT_BORDER_COLOR, DEFAULT_BORDER_WIDTH, UnitWorld, FPPen);

  MinFS := 65535;
  if not Assigned(RenderList) then raise Exception.Create('TLiveComment render list is not initialized.');
  FRenderList := @RenderList;
  if not Assigned(UpdateQueue) then raise Exception.Create('TRenderUnit update queue is not initialized.');
  FUpdateQueue := @UpdateQueue;
  inherited Create(True);
end;

destructor TRenderThread.Destroy;
var
  P: GpFontFamily;
begin
  inherited Destroy();
  GdipDeleteGraphics(FPGraphic);
  GdipDeleteStringFormat(FPSTRINGFORMAT);
  GdipDeletePen(FPPen);
  GdipDeletePath(FPPath);
  for P in FFFDict.Values do begin
    GdipDeleteFontFamily(P);
  end;
  FFFDict.Free;
end;

procedure TRenderThread.Calculate(ALiveComment: TLiveComment);
var
  AWidth, AHeight, Speed: Integer;
  ACommentUnit: TCommentUnit;
begin
  LiveCommentPoolMutex.Acquire;
  try
    with ALiveComment do begin
      if Status <> TLiveCommentStatus.LCreated then Exit;
      AHeight := 0;
      GetStringDim(Body.Content,Body.Format,AWidth,AHeight);
      Width := AWidth;
      Height := AHeight;
      case Body.Effect.Display of
        Scroll: begin
          Left := FWidth{$IFDEF DEBUG} - AWidth{$ENDIF}; // For inspect
          Speed := (AWidth + FWidth) div (Body.Effect.StayTime div DEFAULT_UPDATE_INTERVAL);
          if Speed > DEFAULT_MAX_SCROLL_SPEED then begin
            Body.Effect.Speed := DEFAULT_MAX_SCROLL_SPEED;
            Body.Effect.StayTime := (AWidth + FWidth) * DEFAULT_MAX_SCROLL_SPEED div DEFAULT_UPDATE_INTERVAL;
          end
          else
            Body.Effect.Speed := Speed;
          {$IFDEF DEBUG}ReportLog(Format('[绘制] 计算速度 %u 路径总长 %u 时间 %u',[Speed,AWidth + FWidth,Body.Effect.StayTime]));{$ENDIF}
        end;
        UpperFixed, LowerFixed: begin
          Left := (FWidth - AWidth) div 2;
        end;
      end;
    end;
    RequestChannel(ALiveComment);
    with ACommentUnit do begin
      PString := PWideChar(ALiveComment.Body.Content);
      Length := System.Length(ALiveComment.Body.Content);
      Left := ALiveComment.Left;
      Top := ALiveComment.Top;
      PFontFamily := GetFontFamily(ALiveComment.Body.Format.FontName);
      FillColor := ALiveComment.Body.Format.FontColor;
      FontSize := ALiveComment.Body.Format.FontSize;
      FontStyle := ALiveComment.Body.Format.FontStyle;
    end;
    FRenderBuffer.Add(ALiveComment.Body.ID,ACommentUnit);
    ALiveComment.Status := LMoving;
  finally
    LiveCommentPoolMutex.Release;
  end;
end;

procedure TRenderThread.DoUpdatePool();
var
  TheComment: TLiveComment;
  I, PoolCount: Integer;
begin
  LiveCommentPoolMutex.Acquire;
  try
    PoolCount := FRenderList.Count;
  finally
    LiveCommentPoolMutex.Release;
  end;
  for I := 0 to PoolCount - 1 do begin
    LiveCommentPoolMutex.Acquire;
    try
      if I < FRenderList.Count then TheComment := FRenderList.Items[I] else Continue;
    finally
      LiveCommentPoolMutex.Release;
    end;    
    case TheComment.Status of
      LCreated: Calculate(TheComment); // SET: LWait or LMoving
      LWait: Calculate(TheComment); // SET: LMoving or none
      LMoving: Update(TheComment); // SET: LDelete
      LDelete: Remove(TheComment);
    end;
  end;
end;

procedure TRenderThread.RequestChannel(var AComment: TLiveComment);
var
  n,m,fs,Layer : Integer;
  Done : Boolean;
begin
  Done := false;
  Layer := 1;
  m := -1; //Uninit
  n := -1; //Uninit
  fs := AComment.Height; // TODO: Consider Use Comment.Control.Height
  if fs < MinFS then MinFS := fs div 2; // Escape too long spaces
  case AComment.Body.Effect.Display of
    Scroll, UpperFixed: begin // Flying and Upper
      repeat
        n := 0;
        m := n + fs - 1;
        repeat
          if IsChannelUsed(n,m,Layer) then begin  // Unused by any comments
            if not ConflictTest(AComment,n,m,Layer) then begin
              Done := true;
              break;
            end;
          end
          else begin
            Done := true;
            break;
          end;
          n := n + MinFS; //inc(n); // TODO: Consider Use n := n + fs;
          m := m + MinFS; //inc(m); // TODO: Consider Use m := m + fs;
        until m >= FHeight;
        if not Done then inc(Layer);
      until Done;
    end;
    LowerFixed: begin
      repeat
        m := FHeight;
        n := m - fs + 1;
        repeat
          if IsChannelUsed(n,m,Layer) then begin  // Unused by any comments
            if not ConflictTest(AComment,n,m,Layer) then begin
              Done := true;
              break;
            end;
          end
          else begin
            Done := true;
            break;
          end;
          n := n - MinFS; //inc(n); // TODO: Consider Use n := n + fs;
          m := m - MinFS; //inc(m); // TODO: Consider Use m := m + fs;
        until n <= 0;
        if not Done then inc(Layer);
      until Done;
    end;
  end;
  {$IFDEF DEV}LogEvent(Format('[绘制] 分配通道 %d %d-%d',[Layer,n,m]));{$ENDIF}
  AComment.ChannelLayer := Layer;
  AComment.ChannelFrom := n;
  AComment.Top := n;
  AComment.ChannelTo := m;
end;

function TRenderThread.IsChannelUsed(FromPos, ToPos: Integer; Layer: Integer = 0): Boolean;
var
  TestComment: TLiveComment;
begin
  Result := false;
  for TestComment in FRenderList.ToArray do begin
    if (Layer > 0) and (TestComment.ChannelLayer <> Layer) then Continue;
    if TestComment.Status = LCreated then Continue;
    if (TestComment.ChannelFrom >= FromPos) and (TestComment.ChannelFrom <= ToPos) then begin Result := True; Exit; end;
    if (TestComment.ChannelFrom <= FromPos) and (TestComment.ChannelTo >= ToPos) then begin Result := True; Exit; end;
    if (TestComment.ChannelTo >= FromPos) and (TestComment.ChannelTo <= ToPos) then begin Result := True; Exit; end;
  end;
end;

function TRenderThread.ConflictTest(AComment: TLiveComment; FromPos: Integer; ToPos: Integer; Layer: Integer=0): Boolean;
var
  TestComment: TLiveComment;
  h: Integer;
  CurrFlyTime, PervFlyTime, CheckTime : Double;
begin
  Result := False;
  if AComment.Body.Effect.Display = LowerFixed then begin
    Result := True; // From bottom to top.
    Exit;
  end;
  for h := FromPos to ToPos do begin
    TestComment := FRenderList.Items[h];
    if (Layer > 0) and (TestComment.ChannelLayer <> Layer) then Continue;
    if (TestComment.Status = LMoving) or (TestComment.Status = LCreated) then Continue;
    if(TestComment.ChannelFrom >= FromPos) and (TestComment.ChannelFrom <= ToPos) or
      (TestComment.ChannelFrom <= FromPos) and (TestComment.ChannelTo >= ToPos) or
      (TestComment.ChannelTo >= FromPos) then begin
      case AComment.Body.Effect.Display of
        UpperFixed: begin
          case TestComment.Body.Effect.Display of
            UpperFixed: begin // #4 Up-Up: Always Conflict
              Result := true;
              exit;
            end;
            else begin // #3 ReqUp-PervFly
              Result := Boolean(TestComment.Left + TestComment.Width > AComment.Left);
              if Result then exit;
            end;
          end;
        end;
        else begin
          CurrFlyTime := (AComment.Left + AComment.Width) / AComment.Body.Effect.Speed;
          PervFlyTime := (TestComment.Left + TestComment.Width) / TestComment.Body.Effect.Speed;
          case TestComment.Body.Effect.Display of
            UpperFixed: begin // #2 ReqFly-PervUp
              Result := Boolean(FWidth - (AComment.Left + AComment.Width) div AComment.Body.Effect.StayTime * TestComment.Body.Effect.StayTime >= TestComment.Left + TestComment.Width);
              if Result then Exit;
            end;
            else begin // #1 Fly-Fly
              //if LeftStr(AComment.Body.Content,1) = '@' then Exit;
              Result := true;
              if TestComment.Left + TestComment.Width < FWidth then begin
                CheckTime := Min(CurrFlyTime,PervFlyTime);
                if TestComment.Left + TestComment.Width - TestComment.Body.Effect.Speed * CheckTime <= AComment.Left - AComment.Body.Effect.Speed * CheckTime then Result := False;
              end;
              {if (CurrFlyTime > PervFlyTime) and (TestComment.Left + TestComment.Width < AComment.Left) then begin
                Result := False;
              end
              else begin
                Result := True;
                Exit;
              end;}
              {Result := False;
              if (TestComment.Left > FWidth div 3 * 2) and (TestComment.Width < FWidth div 2) then begin
                Result := True;
                Exit;
              end;}
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TRenderThread.Execute;
var
  MainDC, CurrentHDC: HDC;
  CurrentBitmap: HBITMAP;

  LivePoolCount, LastCycleUnitCount: Integer;
  SleepThisCycle: Boolean;
  ThisRenderUnit: TRenderUnit;
begin
  NameThreadForDebugging('Render');
  { Place thread code here }

  FRenderBuffer := TCommentUnits.Create();
  {$IFDEF DEBUG}ReportLog('[绘制] 完成初始化');{$ENDIF}
  try
    // The thread loop
    ReportLog('[绘制] 进入主循环');
    while True do begin
      Inc(FCounter);
      SleepThisCycle := False;
      if Self.Terminated then begin // Signalled to be terminated
        {$IFDEF DEBUG}ReportLog('[绘制] 退出 #1');{$ENDIF}
        Exit;
      end;

      // Check for multi-threaded destinataion pool is full?
      UpdateQueueMutex.Acquire;
      try
        if Self.Terminated then begin // Signalled to be terminated
          {$IFDEF DEBUG}ReportLog('[绘制] 退出 #2');{$ENDIF}
          Exit;
        end;
        if FUpdateQueue.Count >= FUpdateQueue.Capacity then begin
          //{$IFDEF DEBUG}ReportLog('[绘制] 显示队列满');{$ENDIF}
          SleepThisCycle := True;
        end;
      finally
        UpdateQueueMutex.Release;
      end;
      if SleepThisCycle then begin
        Sleep(10);
        Continue;
      end;

      LastCycleUnitCount := FRenderBuffer.Count;
      LiveCommentPoolMutex.Acquire;
      try
        //{$IFDEF DEBUG}ReportLog(Format('[绘制] 已请求运行时弹幕池',[]));{$ENDIF}
        if Self.Terminated then begin // Signalled to be terminated
          {$IFDEF DEBUG}ReportLog('[绘制] 退出 #3');{$ENDIF}
          Exit;
        end;
        LivePoolCount := FRenderList.Count;
      finally
        LiveCommentPoolMutex.Release;
        //{$IFDEF DEBUG}ReportLog(Format('[绘制] 已释放运行时弹幕池',[]));{$ENDIF}
      end;
      if LivePoolCount > 0 then DoUpdatePool(); // Iteration to local data structure and do update/delete

      if Self.Terminated then begin // Signalled to be terminated
        {$IFDEF DEBUG}ReportLog('[绘制] 退出 #4');{$ENDIF}
        Exit;
      end;

      if (FRenderBuffer.Count > 0) or (LastCycleUnitCount > 0) then begin
        // New hDC Interface and associated handle
        MainDC := GetDC(FMainHandle);
        if MainDC = 0 then raise Exception.Create('Cannot obtain HDC from HWND.');
        CurrentHDC := CreateCompatibleDC(MainDC);
        if CurrentHDC = 0 then raise Exception.Create('Cannot create HDC compatible to parent HDC.');
        CurrentBitmap := CreateCompatibleBitmap(MainDC,FWidth,FHeight);
        if CurrentBitmap = 0 then raise Exception.Create('Cannot create bitmap for specific HDC.');
        SelectObject(CurrentHDC,CurrentBitmap);
        // Pack the handle
        ThisRenderUnit.hSrcDC := MainDC;
        ThisRenderUnit.hDC := CurrentHDC;
        ThisRenderUnit.hBitmap := CurrentBitmap;
        // Do Draw
        DoDrawHDC(ThisRenderUnit);
        // Enqueuing protected by mutex
        UpdateQueueMutex.Acquire;
        try
          FUpdateQueue.Enqueue(ThisRenderUnit);
          // Notify UpdateThread
          UpdateS.Release;
        finally
          UpdateQueueMutex.Release;
        end;
      end
      else begin
        // Nothing to do. Idle for a while
        Sleep(100);
        Continue;
      end;
    end;
  finally
    FRenderBuffer.Free;
  end;
end;

procedure TRenderThread.DoDrawHDC(var ARenderUnit: TRenderUnit);
var
  PGraphic: GpGraphics;
  PBrush: GpSolidFill;
  StrRect: TIGPRect;
  ACommentUnit: TCommentUnit;
begin
  GdipCreateFromHDC(ARenderUnit.hDC,PGraphic);
  GdipSetSmoothingMode(PGraphic,SmoothingModeAntiAlias);
  GdipSetInterpolationMode(PGraphic,InterpolationModeHighQualityBicubic);
  GdipResetPath(FPPath);
  for ACommentUnit in FRenderBuffer.Values do begin
    if ACommentUnit.Length = 0 then Continue;
    GdipCreateSolidFill(ACommentUnit.FillColor,PBrush);
    StrRect.X := ACommentUnit.Left;
    StrRect.Y := ACommentUnit.Top;
    StrRect.Width := 0;
    StrRect.Height := 0;
    GdipAddPathStringI(FPPath, ACommentUnit.PString, ACommentUnit.Length,
      ACommentUnit.PFontFamily, ACommentUnit.FontStyle, ACommentUnit.FontSize, @StrRect, FPStringFormat);
    GdipDrawPath(PGraphic, FPPen, FPPath);
    GdipFillPath(PGraphic, PBrush, FPPath);
    GdipDeleteBrush(PBrush);
  end;
  {$IFDEF DEBUG}GdipDrawLine(PGraphic, FPPen, 0,0,FWidth,FHeight);{$ENDIF}
  GdipDeleteGraphics(PGraphic);
end;

function TRenderThread.GetFontFamily(AFontName: WideString): GpFontFamily;
var
  PFontFamily: GpFontFamily;
begin
  if FFFDict.ContainsKey(AFontName) then
    Result := FFFDict.Items[AFontName]
  else begin
    GdipCreateFontFamilyFromName(PWideChar(AFontName),nil,PFontFamily);
    FFFDict.Add(AFontName,PFontFamily);
    Result := PFontFamily;
  end;
end;

procedure TRenderThread.GetStringDim(AStr: string; AFormat: TCommentFormat; var OWidth: Integer; OHeight: Integer);
var
  Rect, ResultRect: TIGPRectF;
  PFont: GPFONT;
begin
  GdipCreateFont(GetFontFamily(AFormat.FontName),AFormat.FontSize,AFormat.FontStyle,0,PFont);
  Rect.X := 0;
  Rect.Y := 0;
  Rect.Width := 0;
  Rect.Height := 0;
  try
    GdipMeasureString(
        FPGraphic,
        PWideChar(AStr),
        Length(AStr),
        PFont,
        @Rect,
        NIL,
        @ResultRect,
        NIL,
        NIL
    );
  finally
    GdipDeleteFont(PFont);
  end;
  OWidth := Round(ResultRect.Width);
  OHeight := Round(ResultRect.Height);
end;

procedure TRenderThread.Remove(ALiveComment: TLiveComment);
var
  ID: Integer;
begin
  ID := ALiveComment.Body.ID;
  CommentPoolMutex.Acquire;
  try
    ALiveComment.Body.Status := Removed;
    NotifyStatusChanged(ID); // add mutex
  finally
    CommentPoolMutex.Release;
  end;
  LiveCommentPoolMutex.Acquire;
  try
    FRenderList.Remove(ALiveComment);
  finally
    LiveCommentPoolMutex.Release;
  end;
  FRenderBuffer.Remove(ID); // Internal CommentUnits Buffer
end;

procedure TRenderThread.ReportLog(Info: string);
begin
  Synchronize(procedure begin
    frmControl.LogEvent(Info);
  end);
end;

procedure TRenderThread.Update(ALiveComment: TLiveComment);
var
  ACommentUnit: TCommentUnit;
begin
  LiveCommentPoolMutex.Acquire;
  try
    // Update TCommentUnit -> Modify -> Determine Removal
    if ALiveComment.Body.Effect.Display = Scroll then begin
      // Only Scroll comment need update its CommentUnit
      FRenderBuffer.TryGetValue(ALiveComment.Body.ID,ACommentUnit);
      // Modify ALiveComment
      if ALiveComment.Left > 0 - ALiveComment.Width then begin
        ALiveComment.Left := ALiveComment.Left - ALiveComment.Body.Effect.Speed;
      end
      else begin
        Dec(ALiveComment.Body.Effect.RepeatCount);
        if ALiveComment.Body.Effect.RepeatCount <= 0 then begin
          ALiveComment.Status := LDelete; // EXIT 1
          ALiveComment.Body.Status := Removing;
        end
        else
          ALiveComment.Left := FWidth;
      end;
      ACommentUnit.Left := ALiveComment.Left;
      FRenderBuffer.AddOrSetValue(ALiveComment.Body.ID,ACommentUnit);
      //{$IFDEF DEBUG}ReportLog(Format('[绘制] 飞行弹幕 %u更新到%d',[ALiveComment.Body.ID,ACommentUnit.Left]));{$ENDIF}
    end
    else begin // Static
      if ALiveComment.Body.Effect.StayTime <= 0 then begin
        ALiveComment.Status := LDelete; // EXIT 1
        ALiveComment.Body.Status := Removing;
      end
      else
        ALiveComment.Body.Effect.StayTime := ALiveComment.Body.Effect.StayTime - DEFAULT_UPDATE_INTERVAL;
    end;
  finally
    LiveCommentPoolMutex.Release;
  end;
end;

procedure TRenderThread.NotifyStatusChanged(CommentID: Integer);
begin
  Synchronize(procedure begin
    if Assigned(frmControl) then frmControl.UpdateListView(CommentID);
  end);
end;

end.
