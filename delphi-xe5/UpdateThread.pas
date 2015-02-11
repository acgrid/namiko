unit UpdateThread;

interface

uses
  System.Classes, Winapi.Windows, System.SysUtils, System.Types, System.Diagnostics,
  NamikoTypes, LogForm, CfgForm;

type
  TUpdateThread = class(TThread)
    constructor Create(Handle: HWND; CCRect: TRect; var Queue: TRenderUnitQueue);
    destructor Destroy();
  protected
    FHandle: HWND;
    FRect: TRect;
    FBlend: BLENDFUNCTION;
    FQueue: PRenderUnitQueue;
    FRefFPS, FCriticalInterval, FMinInterval, FMaxInterval: Integer;
    FStopwatch, FSleepwatch: TStopwatch;
    FSCount, FSElaspedMS, FWOverFPS, FWOverMin, FWOverMax: Int64;
    procedure Execute; override;
    procedure AccurateSleep(Millisecond: Cardinal);
    procedure ReportLog(Info: string; Level: TLogType = logInfo);
  public
    property SCount: Int64 read FSCount;
    property SElaspedMS: Int64 read FSElaspedMS;
    property WOverFPS: Int64 read FWOverFPS;
    property WOverMin: Int64 read FWOverMin;
    property WOverMax: Int64 read FWOverMax;
  end;

implementation

uses
  CtrlForm;
{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TUpdateThread.UpdateCaption;
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

{ TUpdateThread }

constructor TUpdateThread.Create(Handle: HWND; CCRect: TRect; var Queue: TRenderUnitQueue);
begin
  FHandle := Handle;
  FRect := CCRect;
  if not Assigned(Queue) then raise Exception.Create('Render unit queue is not initialized.');
  FQueue := @Queue;
  with frmConfig do begin
    FRefFPS := IntegerItems['Display.ReferenceFPS'];
    FMinInterval := IntegerItems['Display.MinInterval'];
    FMaxInterval := IntegerItems['Display.MaxInterval'];
  end;
  FCriticalInterval := 1000 div FRefFPS;
  ReportLog(Format('帧间隔 %u ms',[FCriticalInterval]));
  FStopwatch := TStopwatch.Create;
  if FStopwatch.IsHighResolution then ReportLog(Format('支持高精度计时，精度：%u',[FStopwatch.Frequency]));
  FSleepwatch := TStopwatch.Create;
  FSCount := 0;
  FSElaspedMS := 0;
  FWOverFPS := 0;
  FWOverMin := 0;
  FWOverMax := 0;
  inherited Create(True);
  Priority := tpTimeCritical;
end;

destructor TUpdateThread.Destroy;
begin
  FStopwatch.Stop;
  FreeAndNil(FStopwatch);
  FSleepwatch.Stop;
  FreeAndNil(FSleepwatch);
end;

procedure TUpdateThread.Execute;
var
  FormOffsetPoint, FormDCPoint: TPoint;
  CurrentRenderUnit: TRenderUnit;
  WindowSize: SIZE;
  ScreenHDC: HDC;
  BeforeRender, RenderElasped, RenderDelay: Int64;
begin
  NameThreadForDebugging('Update');
  { Place thread code here }
  // Mutex
  {ReportLog('[Update] Acquire Initial Mutex');
  GraphicSharedMutex.Acquire;
  ReportLog('[Update] Acquired Initial Mutex');
  GraphicSharedMutex.Release;
  ReportLog('[Update] Released Initial Mutex'); }
  // Initial Structures
  with FBlend do begin
    BlendOp := AC_SRC_OVER;     //把源图片覆盖到目标之上
    BlendFlags := 0;
    AlphaFormat := AC_SRC_ALPHA; //每个像素有各自的alpha通道
    SourceConstantAlpha := 255;
  end;
  FormDCPoint := Point(0,0);
  FormOffsetPoint := Point(FRect.Left,FRect.Top);
  WindowSize.cx := FRect.Width;
  WindowSize.cy := FRect.Height;
  ReportLog('进入主循环');
  // Main Loop
  FStopwatch.Start;
  while True do begin
    if Self.Terminated then begin // Signalled to be terminated
      // Possible clean up
      // Clear Update Queue is done before starting threads
      {$IFDEF DEBUG}ReportLog('退出 #1');{$ENDIF}
      Exit;
    end;
    FStopwatch.Stop;
    BeforeRender := FStopwatch.ElapsedMilliseconds;
    UpdateS.Acquire; // Queue is MAYBE not empty
    FStopwatch.Start;
    Inc(FSCount);
    CurrentRenderUnit.hDC := 0; // Default value to marked as unsuccessful
    UpdateQueueMutex.Acquire;
    if FQueue.Count > 0 then CurrentRenderUnit := FQueue.Dequeue; // Confirm REALLY there is anything
    UpdateQueueMutex.Release;
    if CurrentRenderUnit.hDC = 0 then Continue; // MAYBE queue is really empty OR parent thread is call me to exit
    ScreenHDC := GetDC(FHandle);
    try
      UpdateLayeredWindow(FHandle,ScreenHDC,@FormOffsetPoint,@WindowSize,CurrentRenderUnit.hDC,@FormDCPoint,0,@FBlend,ULW_ALPHA);
    finally
      ReleaseDC(FHandle,ScreenHDC);
      ReleaseDC(FHandle,CurrentRenderUnit.hSrcDC);
      DeleteObject(CurrentRenderUnit.hBitmap);
      DeleteDC(CurrentRenderUnit.hDC);
    end;
    FStopwatch.Stop;
    RenderElasped := FStopwatch.ElapsedMilliseconds;
    FStopwatch.Reset;
    FStopwatch.Start;
    FSElaspedMS := FSElaspedMS + RenderElasped;
    RenderElasped := (RenderElasped - BeforeRender) + (SElaspedMS div FSCount - FCriticalInterval); // This time +- Average offset
    if RenderElasped > FCriticalInterval then begin
      // FPS too high to meet
      Inc(FWOverFPS);
    end
    else begin
      RenderDelay := FCriticalInterval - RenderElasped;
      if RenderDelay > FMaxInterval then begin
        RenderDelay := FMaxInterval;
        Inc(FWOverMax);
      end
      else
      if RenderDelay < FMinInterval then begin
        RenderDelay := FMinInterval;
        Inc(FWOverMin);
      end;
      AccurateSleep(RenderDelay);
    end;
  end;
end;

procedure TUpdateThread.AccurateSleep(Millisecond: Cardinal);
begin
  try
    repeat
      FSleepwatch.Start;
      Sleep(1);
      FSleepwatch.Stop;
    until (FSleepwatch.ElapsedMilliseconds >= Millisecond);
  finally
    FSleepwatch.Stop;
    FSleepwatch.Reset;
  end;
end;

procedure TUpdateThread.ReportLog(Info: string; Level: TLogType = logInfo);
begin
  frmLog.LogAdd(Info, '更新', Level);
end;

end.
