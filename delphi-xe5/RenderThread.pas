unit RenderThread;

interface

uses
  System.Classes, System.Types, System.SysUtils, System.UITypes, System.UIConsts,
  IGDIPlusEmbedded, Winapi.Windows, SyncObjs, System.Generics.Collections, System.StrUtils,
  System.Diagnostics,
  Math, LogForm, NamikoTypes;

type
  TByteDynArray = array of Byte;

type
  TCommentUnit = record // Use to render
    PString: PWideChar;
    Length: Integer;
    Left: Integer; // X-Position
    Top: Integer; // Y-Position
    Bitmap: GpCachedBitmap;
    Buf: TByteDynArray;
    PFontFamily: GPFONTFAMILY;
    FillColor: TAlphaColor;
    //BorderColor: TAlphaColor;
    FontSize: Single;
    FontStyle: Integer;
  end;
type
  PCommentUnit = ^TCommentUnit;
type
  TCommentUnits = TDictionary<Integer,TCommentUnit>; // ID,TCommentUnit
type
  TFontFamilyDict = TDictionary<string,GPFONTFAMILY>;
type
  TBrushDict = TDictionary<TAlphaColor,GpBrush>;
type
  TFontDict = TDictionary<string, GPFont>;
type
  TCommentIndexList = TList<Integer>;
type
  TRenderThread = class(TThread)
    MTitleText: string;
    MTitleTop, MTitleLeft: Integer;
    MTitleFontName: WideString;
    MTitleFontSize: Single;
    MTitleFontColor: TAlphaColor;
    MDoUpdate: Boolean;
    MDoEsc: Boolean;
    constructor Create(Handle: HWND; Width: Integer; Height: Integer; var RenderList: TLiveCommentCollection; var UpdateQueue: TRenderUnitQueue);
    destructor Destroy(); override;
  protected
    // Cycle Counter
    FCounter, FRenderMS, FOverheadMS, {FQueueFull, }FScreenFull, FMaxBufferCount: Int64;
    FStopwatch: TStopwatch;
    FBufferLength: Cardinal; // max frames for the buffer
    // GUI Variables
    FMainHandle: HWND;
    FWidth: Integer;
    FHeight: Integer;
    FHeightZoom: Single;
    FOverlayLimit: Integer;
    FBorderWidth: Single;
    MinFS: Integer;
    FRefInterval, FMaxMovement: Integer;
    // Collections
    FUpdateQueue: PRenderUnitQueue;
    FRenderList: PLiveCommentCollection;
    FRenderBuffer: TCommentUnits;
    // Reuseable GDI+ Resource
    FHPALETTE: HPALETTE;
    FFFDict: TFontFamilyDict;
    FSBDict: TBrushDict;
    FFPDict: TFontDict;
    FPGraphic: GpGraphics;
    FPStringFormat: GPSTRINGFORMAT;
    FPPath: GPPATH;
    FPPen: GPPen;
    FOriginPoint: TIGPRectF;
    FTitleBitmap: GpCachedBitmap;
    procedure Calculate(ALiveComment: TLiveComment);
    function ConflictTest(AComment: TLiveComment; FromPos: Integer; ToPos: Integer; Layer: Integer=0): Boolean;
    procedure DoDrawHDC(var ARenderUnit: TRenderUnit);
    procedure DoUpdatePool();
    procedure Execute; override;
    function GetPossibleConflicts(FromPos, ToPos: Integer; Layer: Integer = 0): TCommentIndexList;
    function GetFontFamily(AFontName: WideString): GpFontFamily;
    function GetFont(AFontName: WideString; AFontSize: Single; AFontStyle: Integer): GpFont;
    function GetSolidBrush(AColor: TAlphaColor): GpBrush;
    function GetCachedBitmap(AText: PWCHAR; ALength: Integer; AFontFamily: GPFONTFAMILY;
       AFontStyle: Integer; emSize: Single; AFillColor: TAlphaColor; AWidth: Integer; AHeight: Integer; buf: TByteDynArray): GpCachedBitmap;
    function CreateGDIBitmapFromHBITMAP(const hBitmap: HBITMAP; bmpBits: TByteDynArray): GpBitmap;
    procedure GetStringDim(AStr: string; AFormat: TCommentFormat; var OWidth: Integer; var OHeight: Integer);
    procedure Remove(ALiveComment: TLiveComment);
    procedure ReportLog(Info: string; Level: TLogType = logInfo);
    procedure RequestChannel(var AComment: TLiveComment);
    procedure Update(ALiveComment: TLiveComment);
    procedure NotifyStatusChanged(CommentID: Integer);
  public
    property FramesCount: Int64 read FCounter;
    //property QueueFullCount: Int64 read FQueueFull;
    property RenderMS: Int64 read FRenderMS;
    property OverheadMS: Int64 read FOverheadMS;
    property ScreenFullCount: Int64 read FScreenFull;
    property MaxBufferCount: Int64 read FMaxBufferCount;
  end;

implementation

uses
  CtrlForm, CfgForm;

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
  FCounter := 0;
  FRenderMS := 0;
  //FQueueFull := 0;
  FMaxBufferCount := 0;
  FStopwatch := TStopwatch.Create;
  FMainHandle := Handle;
  FWidth := Width;
  FHeight := Height;
  FRefInterval := 1000 div frmConfig.IntegerItems['Display.ReferenceFPS'];
  FMaxMovement := frmConfig.IntegerItems['Display.MaxMovement'];
  FHeightZoom := frmConfig.IntegerItems['Display.HeightZoom'] / 100;
  FOverlayLimit := frmConfig.IntegerItems['Display.OverlayLimit'];
  FFFDict := TFontFamilyDict.Create();
  FSBDict := TBrushDict.Create();
  FFPDict := TFontDict.Create();
  FOriginPoint.X := 0;
  FOriginPoint.Y := 0;
  FOriginPoint.Width := 0;
  FOriginPoint.Height := 0;

  GdipCreateFromHWND(FMainHandle,FPGraphic);
  GdipStringFormatGetGenericTypographic(FPStringFormat);
  GdipCreatePath(FillModeAlternate,FPPath);
  FHPALETTE := GdipCreateHalftonePalette();
  if frmConfig.IntegerItems['Display.BorderWidth'] > 0 then GdipCreatePen1(StringToAlphaColor(frmConfig.StringItems['Display.BorderColor']), frmConfig.IntegerItems['Display.BorderWidth'].ToSingle, UnitWorld, FPPen);

  MinFS := 65535;
  if not Assigned(RenderList) then raise Exception.Create('TLiveComment render list is not initialized.');
  FRenderList := @RenderList;
  if not Assigned(UpdateQueue) then raise Exception.Create('TRenderUnit update queue is not initialized.');
  FUpdateQueue := @UpdateQueue;
  FBufferLength := (frmConfig.IntegerItems['Display.BufferLength'] * frmConfig.IntegerItems['Display.ReferenceFPS']) div 1000;
  ReportLog(Format('帧缓冲区长度 %u', [FBufferLength]));
  FUpdateQueue.Capacity := Max(1024, 2 * FBufferLength); // 2 time tolerance
  // In main thread no mutex needed
  MTitleText := frmControl.MTitleText;
  MTitleTop := frmControl.MTitleTop;
  MTitleLeft := frmControl.MTitleLeft;
  MTitleFontName := frmControl.MTitleFontName;
  MTitleFontSize := frmControl.MTitleFontSize;
  MTitleFontColor := frmControl.MTitleFontColor;
  MDoUpdate := True;
  MDoEsc := False;
  inherited Create(True);
end;

destructor TRenderThread.Destroy;
var
  P: GpFontFamily;
  FP: GpFont;
  SP: GpBrush;
begin
  inherited Destroy();
  FreeAndNil(FStopwatch);
  GdipDeleteGraphics(FPGraphic);
  GdipDeleteStringFormat(FPStringFormat);
  if Assigned(FPPen) then GdipDeletePen(FPPen);
  GdipDeletePath(FPPath);
  for P in FFFDict.Values do begin
    GdipDeleteFontFamily(P);
  end;
  FFFDict.Free;
  for FP in FFPDict.Values do GdipDeleteFont(FP);
  FFPDict.Free;
  for SP in FSBDict.Values do GdipDeleteBrush(SP);
  FSBDict.Free;
end;

// Tested: 6/1079 cost
procedure TRenderThread.Calculate(ALiveComment: TLiveComment);
var
  AWidth, AHeight, Speed: Integer;
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
          Left := FWidth - 1; // For inspect
          Speed := (AWidth + FWidth) div (Body.Effect.StayTime div FRefInterval);
          if Speed > FMaxMovement then begin
            Body.Effect.Speed := FMaxMovement;
            Body.Effect.StayTime := (AWidth + FWidth) * FMaxMovement div FRefInterval;
          end
          else
            Body.Effect.Speed := Speed;
          {$IFDEF DEBUG}ReportLog(Format('计算速度 %u 路径总长 %u 时间 %u',[Speed,AWidth + FWidth,Body.Effect.StayTime]));{$ENDIF}
        end;
        UpperFixed, LowerFixed: begin
          Left := (FWidth - AWidth) div 2;
        end;
      end;
    end;
  finally
    LiveCommentPoolMutex.Release;
  end;
  RequestChannel(ALiveComment);
end;

procedure TRenderThread.DoUpdatePool();
var
  TheComment: TLiveComment;
  I, PoolCount: Integer;
begin
  TheComment := nil;
  LiveCommentPoolMutex.Acquire;
  try
    PoolCount := FRenderList.Count;
  finally
    LiveCommentPoolMutex.Release;
  end;
  if PoolCount > FMaxBufferCount then FMaxBufferCount := PoolCount;

  for I := 0 to PoolCount - 1 do begin
    LiveCommentPoolMutex.Acquire;
    try
      if I < FRenderList.Count then TheComment := FRenderList.Items[I] else Continue;
    finally
      LiveCommentPoolMutex.Release;
    end;
    if Assigned(TheComment) then begin
      case TheComment.Status of
        LCreated: Calculate(TheComment); // SET: LWait or LMoving
        LWait: RequestChannel(TheComment); // SET: LMoving or none
        LMoving: Update(TheComment); // SET: LDelete
        LDelete: Remove(TheComment);
      end;
    end;
  end;
end;

procedure TRenderThread.RequestChannel(var AComment: TLiveComment);
var
  FromCh, TillCh, Height, Layer: Integer;
  Done : Boolean;
  ACommentUnit: TCommentUnit;
begin
  Done := False;
  Layer := 1;
  TillCh := -1; //Initialize FOverlayLimit
  FromCh := -1; //Initialize
  Height := AComment.Height; // TODO: Consider Use Comment.Control.Height
  if Height < MinFS then MinFS := Height div 2; // Escape too long spaces
  case AComment.Body.Effect.Display of
    Scroll, UpperFixed: begin // Flying and Upper
      repeat
        FromCh := 0;
        TillCh := FromCh + Height - 1;
        repeat
          if not ConflictTest(AComment,FromCh,TillCh,Layer) then begin
            Done := True;
            Break;
          end;
          FromCh := FromCh + MinFS; //inc(n); // TODO: Consider Use n := n + fs;
          TillCh := TillCh + MinFS; //inc(m); // TODO: Consider Use m := m + fs;
        until TillCh >= FHeight;
        if not Done and (Layer < FOverlayLimit) then Inc(Layer);
      until Done or (Layer >= FOverlayLimit);
    end;
    LowerFixed: begin
      repeat
        TillCh := FHeight;
        FromCh := TillCh - Height + 1;
        repeat
          if not ConflictTest(AComment,FromCh,TillCh,Layer) then begin
            Done := True;
            Break;
          end;
          FromCh := FromCh - MinFS; //inc(n); // TODO: Consider Use n := n + fs;
          TillCh := TillCh - MinFS; //inc(m); // TODO: Consider Use m := m + fs;
        until FromCh <= 0;
        if not Done and (Layer < FOverlayLimit) then Inc(Layer);
      until Done or (Layer >= FOverlayLimit);
    end;
  end;
  if Done then begin
    {$IFDEF DEBUG}ReportLog(Format('分配通道 %d 层 %d到%d',[Layer,FromCh,TillCh]));{$ENDIF}
    LiveCommentPoolMutex.Acquire;
    try
      AComment.ChannelLayer := Layer;
      AComment.ChannelFrom := FromCh;
      AComment.Top := FromCh;
      AComment.ChannelTo := TillCh;
      AComment.Status := LMoving;
    finally
      LiveCommentPoolMutex.Release;
    end;

    with ACommentUnit do begin
      PString := PWideChar(AComment.Body.Content);
      Length := System.Length(AComment.Body.Content);
      Left := AComment.Left;
      Top := AComment.Top;
      PFontFamily := GetFontFamily(AComment.Body.Format.FontName);
      FillColor := AComment.Body.Format.FontColor;
      FontSize := AComment.Body.Format.FontSize;
      FontStyle := AComment.Body.Format.FontStyle;
      Bitmap := GetCachedBitmap(PString, Length, PFontFamily, FontStyle, FontSize, FillColor, AComment.Width, AComment.Height, buf);
    end;
    FRenderBuffer.Add(AComment.Body.ID,ACommentUnit);
  end
  else begin
    AComment.Status := LWait;
    Inc(FScreenFull);
  end;
end;

function TRenderThread.GetCachedBitmap(AText: PWideChar; ALength: Integer; AFontFamily: Pointer; AFontStyle: Integer; emSize: Single; AFillColor: TAlphaColor; AWidth: Integer; AHeight: Integer; buf: TByteDynArray): GpCachedBitmap;
var
  MainDC, CurrentHDC: HDC;
  CurrentBitmap: HBITMAP;
  PGraphic: GPGraphics;
  RenderedBitmap: GPBITMAP;
begin
  // initialization
  MainDC := GetDC(FMainHandle);
  if MainDC = 0 then raise Exception.Create('Cannot obtain HDC from HWND.');
  CurrentHDC := CreateCompatibleDC(MainDC);
  if CurrentHDC = 0 then raise Exception.Create('Cannot create HDC compatible to parent HDC.');
  CurrentBitmap := CreateCompatibleBitmap(MainDC, AWidth, AHeight);
  if CurrentBitmap = 0 then raise Exception.Create('Cannot create bitmap for specific HDC.');
  SelectObject(CurrentHDC, CurrentBitmap);
  GdipCreateFromHDC(CurrentHDC, PGraphic);
  GdipSetSmoothingMode(PGraphic, SmoothingModeAntiAlias);
  GdipSetInterpolationMode(PGraphic, InterpolationModeHighQualityBicubic);
  // do render
  GdipGraphicsClear(PGraphic, $FFFFFFFF);
  GdipResetPath(FPPath);
  GdipAddPathStringI(FPPath, AText, ALength, AFontFamily, AFontStyle, emSize, @FOriginPoint, FPStringFormat);
  if Assigned(FPPen) then GdipDrawPath(PGraphic, FPPen, FPPath);
  GdipFillPath(PGraphic, GetSolidBrush(AFillColor), FPPath);
  //GdipCreateBitmapFromHBITMAP(CurrentBitmap, FHPALETTE, RenderedBitmap); // Lost Alpha channels
  RenderedBitmap := CreateGDIBitmapFromHBITMAP(CurrentBitmap, buf);
  if Assigned(RenderedBitmap) then GdipCreateCachedBitmap(RenderedBitmap, PGraphic, Result);
  // finalization
  GdipDeleteGraphics(PGraphic);
  ReleaseDC(FMainHandle, MainDC);
  DeleteObject(CurrentBitmap);
  DeleteDC(CurrentHDC);
end;

function TRenderThread.CreateGDIBitmapFromHBITMAP(const hBitmap: HBITMAP; bmpBits: TByteDynArray): GpBitmap;
var
  bmp: BITMAP;
  bmpInfo: BITMAPINFO;
  bmpData: TIGPBitmapDataRecord;
  bmpRect: TRect;
  hdcScreen: HDC;
begin
  Result := nil;
  ZeroMemory(@bmp, SizeOf(BITMAP));
  if GetObject(hBitmap, SizeOf(BITMAP), @bmp) = 0 then raise Exception.Create('Error get BITMAP from HBITMAP.'); // HBITMAP -> Native BITMAP

  ZeroMemory(@bmpInfo, SizeOf(BITMAPINFO));
  bmpInfo.bmiHeader.biSize := SizeOf(BITMAPINFOHEADER);
  bmpInfo.bmiHeader.biWidth := bmp.bmWidth;
  bmpInfo.bmiHeader.biHeight := -bmp.bmHeight; // Upside-down!
  bmpInfo.bmiHeader.biPlanes := bmp.bmPlanes;
  bmpInfo.bmiHeader.biBitCount := bmp.bmBitsPixel;
  bmpInfo.bmiHeader.biCompression := BI_RGB;
  SetLength(bmpBits, bmp.bmWidthBytes * bmp.bmHeight);
  ReportLog(Format('Buf Length: %u', [bmp.bmWidthBytes * bmp.bmHeight]));
  hdcScreen := GetDC(0);
  if hdcScreen = 0 then raise Exception.Create('GetDC() Error');

  try
    if (GetDIBits(hdcScreen, hBitmap, 0, bmp.bmHeight, PByte(bmpBits), bmpInfo, DIB_RGB_COLORS) = 0) and (GetLastError() <> 0) then
      raise Exception.Create('Error copy HBITMAP to BITMAP.');
  finally
    DeleteDC(hdcScreen);
  end;
  GdipCreateBitmapFromScan0(bmp.bmWidth, bmp.bmHeight, bmp.bmWidthBytes, PixelFormat32bppARGB, PByte(bmpBits), Result);
  {GdipCreateBitmapFromScan0(bmp.bmWidth, bmp.bmHeight, bmp.bmWidthBytes, PixelFormat32bppARGB, PByte(bmpBits), Result);
  Exit;
  bmpRect := TRect.Create(0, 0, bmp.bmWidth, bmp.bmHeight);
  GdipBitmapLockBits(Result, @bmpRect, Ord(ImageLockModeRead), PixelFormat32bppARGB, @bmpData);
  // assure
  if bmp.bmHeight < 0 then begin // bottom -> top
    for currLine := 0 to Length(bmpBits) do begin
      CopyMemory(Pointer(Integer(bmpData.Scan0) + currLine), Pointer(Integer(bmpBits) + currLine), 1);
    end;
    ZeroMemory(bmpData.Scan0, Length(bmpBits));
    for currLine := 0 to bmp.bmHeight - 1 do begin
      CopyMemory(Pointer(Integer(bmpData.Scan0) + bmp.bmWidthBytes * (bmp.bmHeight - currLine - 1)), Pointer(Integer(bmpBits) + bmp.bmWidthBytes * currLine), bmp.bmWidthBytes);
    end;
  end
  else begin // top -> bottom
    CopyMemory(bmpData.scan0, bmpBits, Length(bmpBits));
  end;
  GdipBitmapUnlockBits(Result, @bmpData); }
end;

function TRenderThread.GetPossibleConflicts(FromPos, ToPos: Integer; Layer: Integer = 0): TCommentIndexList;
var
  Index: Integer;
  TestComment: TLiveComment;
begin
  Result := TCommentIndexList.Create();
  for Index := 0 to FRenderList.Count - 1 do begin
    TestComment := FRenderList.Items[Index];
    if (Layer > 0) and (TestComment.ChannelLayer <> Layer) then Continue;
    if TestComment.Status <> LMoving then Continue;
    if (TestComment.ChannelFrom >= FromPos) and (TestComment.ChannelFrom <= ToPos) then begin Result.Add(Index); Continue; end;
    if (TestComment.ChannelFrom <= FromPos) and (TestComment.ChannelTo >= ToPos) then begin Result.Add(Index); Continue; end;
    if (TestComment.ChannelTo >= FromPos) and (TestComment.ChannelTo <= ToPos) then begin Result.Add(Index); Continue; end;
  end;
  {$IFDEF DEBUG}ReportLog(Format('冲突检测 %u 层 %u-%u 可疑数量%u',[Layer,FromPos,ToPos,Result.Count]));{$ENDIF}
end;

function TRenderThread.ConflictTest(AComment: TLiveComment; FromPos: Integer; ToPos: Integer; Layer: Integer = 0): Boolean;
var
  TestComment: TLiveComment;
  PossibleConflicts: TCommentIndexList;
  CurrFlyTime, PervFlyTime, CheckTime : Double;
  Index: Integer;
begin
  Result := False; // Default Value;
  // GetPossibleConflicts
  LiveCommentPoolMutex.Acquire; // DO NOT ACQUIRE ANY LOCKS IN THIS BLOCK!!!!
  PossibleConflicts := GetPossibleConflicts(FromPos,ToPos,Layer);
  try
    if PossibleConflicts.Count = 0 then Exit; // No possible conflicts
    // Logic based on there is at least one possible conflict(s)
    if AComment.Body.Effect.Display = LowerFixed then begin
      Result := True; // From bottom to top.
      Exit;
    end;
    for Index in PossibleConflicts do begin
      TestComment := FRenderList.Items[Index];
      {$IFDEF DEBUG}ReportLog(Format('冲突检测 位置0',[]));{$ENDIF}
      case AComment.Body.Effect.Display of
        UpperFixed: begin
          {$IFDEF DEBUG}ReportLog(Format('冲突检测 位置3-A',[]));{$ENDIF}
          case TestComment.Body.Effect.Display of
            UpperFixed: begin // #4 Up-Up: Always Conflict
              {$IFDEF DEBUG}ReportLog(Format('冲突检测 位置4-A',[]));{$ENDIF}
              Result := True;
              Exit;
            end;
            else begin // #3 ReqUp-PervFly
              {$IFDEF DEBUG}ReportLog(Format('冲突检测 位置4-B',[]));{$ENDIF}
              Result := Boolean(TestComment.Left + TestComment.Width > AComment.Left);
              if Result then Exit;
            end;
          end;
        end;
        else begin
          {$IFDEF DEBUG}ReportLog(Format('冲突检测 位置3-B',[]));{$ENDIF}
          CurrFlyTime := (AComment.Left + AComment.Width) / AComment.Body.Effect.Speed;
          PervFlyTime := (TestComment.Left + TestComment.Width) / TestComment.Body.Effect.Speed;
          case TestComment.Body.Effect.Display of
            UpperFixed: begin // #2 ReqFly-PervUp
              Result := Boolean(FWidth - (AComment.Left + AComment.Width) div AComment.Body.Effect.StayTime * TestComment.Body.Effect.StayTime >= TestComment.Left + TestComment.Width);
              if Result then Exit;
            end;
            else begin // #1 Fly-Fly
              if LeftStr(AComment.Body.Content,1) = '@' then Exit;
              Result := True;
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
  finally
    PossibleConflicts.Free;
    LiveCommentPoolMutex.Release;
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
  {$IFDEF DEBUG}ReportLog('完成初始化');{$ENDIF}
  try
    // The thread loop
    ReportLog('进入主循环');
    while True do begin
      SleepThisCycle := False;
      if Self.Terminated then begin // Signalled to be terminated
        {$IFDEF DEBUG}ReportLog('退出 #1');{$ENDIF}
        Exit;
      end;
      // Check for multi-threaded destinataion pool is full?
      UpdateQueueMutex.Acquire;
      try
        if Self.Terminated then begin // Signalled to be terminated
          {$IFDEF DEBUG}ReportLog('退出 #2');{$ENDIF}
          Exit;
        end;
        if FUpdateQueue.Count >= FUpdateQueue.Capacity then begin
          SleepThisCycle := True;
        end;
      finally
        UpdateQueueMutex.Release;
      end;
      if Assigned(frmControl.UThread) and (FCounter - frmControl.UThread.SCount > FBufferLength) then SleepThisCycle := True;

      if SleepThisCycle then begin
        //Inc(FQueueFull);
        Continue;
      end;

      FStopwatch.Start;
      LastCycleUnitCount := FRenderBuffer.Count;
      LiveCommentPoolMutex.Acquire;
      try
        //{$IFDEF DEBUG}ReportLog(Format('已请求运行时弹幕池',[]));{$ENDIF}
        if Self.Terminated then begin // Signalled to be terminated
          {$IFDEF DEBUG}ReportLog('退出 #3');{$ENDIF}
          Exit;
        end;
        LivePoolCount := FRenderList.Count;
      finally
        LiveCommentPoolMutex.Release;
        //{$IFDEF DEBUG}ReportLog(Format('已释放运行时弹幕池',[]));{$ENDIF}
      end;
      if LivePoolCount > 0 then DoUpdatePool(); // Iteration to local data structure and do update/delete

      FStopwatch.Stop;
      FOverheadMS := FOverheadMS + FStopwatch.ElapsedMilliseconds;
      FStopwatch.Reset;

      if Self.Terminated then begin // Signalled to be terminated
        {$IFDEF DEBUG}ReportLog('退出 #4');{$ENDIF}
        Exit;
      end;

      if (FRenderBuffer.Count > 0) or (LastCycleUnitCount > 0) or MDoUpdate or MDoEsc then begin
        MDoUpdate := False;
        Inc(FCounter);
        FStopwatch.Start;
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
        FStopwatch.Stop;
        FRenderMS := FRenderMS + FStopwatch.ElapsedMilliseconds;
        FStopwatch.Reset;
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
        Sleep(1);
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
  StrRect: TIGPRect;
  ACommentUnit: TCommentUnit;
begin
  GdipCreateFromHDC(ARenderUnit.hDC,PGraphic);
  GdipSetSmoothingMode(PGraphic,SmoothingModeAntiAlias);
  GdipSetInterpolationMode(PGraphic,InterpolationModeHighQualityBicubic);
  GdipResetPath(FPPath);
  if MDoEsc then begin
    FRenderBuffer.Clear;
    MDoEsc := False;
    LiveCommentPoolMutex.Acquire;
    try
      FRenderList.Clear;
    finally
      LiveCommentPoolMutex.Release;
    end;
  end;
  for ACommentUnit in FRenderBuffer.Values do begin
    if ACommentUnit.Length = 0 then Continue;
    GdipDrawCachedBitmap(PGraphic, ACommentUnit.Bitmap, ACommentUnit.Left, ACommentUnit.Top);
  end;
  {GraphicSharedMutex.Acquire;
  try}
    if Length(MTitleText) > 0 then begin // Display the Title
      StrRect.X := MTitleLeft;
      StrRect.Y := MTitleTop;
      StrRect.Width := 0;
      StrRect.Height := 0;
      GdipResetPath(FPPath);
      GdipAddPathStringI(FPPath, PWideChar(MTitleText), Length(MTitleText),
        GetFontFamily(MTitleFontName), 1, MTitleFontSize, @StrRect, FPStringFormat);
      GdipDrawPath(PGraphic, FPPen, FPPath);
      GdipFillPath(PGraphic, GetSolidBrush(MTitleFontColor), FPPath);
    end;
  {finally
    GraphicSharedMutex.Release;
  end;}
  {$IFDEF DEBUG_DIM}GdipDrawLine(PGraphic, FPPen, 0,0,FWidth,FHeight);{$ENDIF}
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

function TRenderThread.GetFont(AFontName: WideString; AFontSize: Single; AFontStyle: Integer): GpFont;
var
  Key: string;
  PFont: GpFont;
begin
  Key := Format('%s:%.1f:%u', [AFontName, AFontSize, AFontStyle]);
  if FFPDict.ContainsKey(Key) then
    Result := FFPDict.Items[Key]
  else begin
    GdipCreateFont(GetFontFamily(AFontName),AFontSize,AFontStyle,0,PFont);
    FFPDict.Add(Key,PFont);
    Result := PFont;
  end;
end;

function TRenderThread.GetSolidBrush(AColor: TAlphaColor): GpBrush;
var
  PBrush: GpBrush;
begin
  if FSBDict.ContainsKey(AColor) then
    Result := FSBDict.Items[AColor]
  else begin
    GdipCreateSolidFill(AColor,PBrush);
    FSBDict.Add(AColor,PBrush);
    Result := PBrush;
  end;
end;

procedure TRenderThread.GetStringDim(AStr: string; AFormat: TCommentFormat; var OWidth: Integer; var OHeight: Integer);
var
  Rect, ResultRect: TIGPRectF;
begin
  Rect.X := 0;
  Rect.Y := 0;
  Rect.Width := 0;
  Rect.Height := 0;
  GdipMeasureString(
      FPGraphic,
      PWideChar(AStr),
      Length(AStr),
      GetFont(AFormat.FontName, AFormat.FontSize, AFormat.FontStyle),
      @Rect,
      FPStringFormat,
      @ResultRect,
      nil,
      nil
  );
  OWidth := Round(ResultRect.Width);
  if FHeightZoom > 0.1 then
    OHeight := Round(ResultRect.Height)
  else
    OHeight := Round(FHeightZoom * AFormat.FontSize);
  {$IFDEF DEBUG_HEIGHT}ReportLog(Format('测量大小 %s %u * %u',[AStr, OWidth, OHeight]), logDebug);{$ENDIF}
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
  GdipDeleteCachedBitmap(FRenderBuffer.Items[ID].Bitmap);
  FRenderBuffer.Remove(ID); // Internal CommentUnits Buffer
end;

procedure TRenderThread.ReportLog(Info: string; Level: TLogType = logInfo);
begin
  frmLog.LogAdd(Info, '绘制', Level);
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
      //{$IFDEF DEBUG}ReportLog(Format('飞行弹幕 %u更新到%d',[ALiveComment.Body.ID,ACommentUnit.Left]));{$ENDIF}
    end
    else begin // Static
      if ALiveComment.Body.Effect.StayTime <= 0 then begin
        ALiveComment.Status := LDelete; // EXIT 1
        ALiveComment.Body.Status := Removing;
      end
      else
        ALiveComment.Body.Effect.StayTime := ALiveComment.Body.Effect.StayTime - FRefInterval;
    end;
  finally
    LiveCommentPoolMutex.Release;
  end;
end;

procedure TRenderThread.NotifyStatusChanged(CommentID: Integer);
begin
  {Synchronize(procedure begin
    if Assigned(frmControl) then frmControl.UpdateListView(CommentID);
  end);}
end;

end.
