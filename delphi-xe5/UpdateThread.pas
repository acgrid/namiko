unit UpdateThread;

interface

uses
  System.Classes, Winapi.Windows, System.SysUtils, System.Types,
  CtrlForm;

type
  TUpdateThread = class(TThread)
    constructor Create(Handle: HWND; CCRect: TRect; var Queue: TRenderUnitQueue);
  protected
    FHandle: HWND;
    FRect: TRect;
    FBlend: BLENDFUNCTION;
    FQueue: PRenderUnitQueue;
    procedure Execute; override;
    procedure ReportLog(Info: string);
  end;

implementation

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
  inherited Create(True);
end;

procedure TUpdateThread.Execute;
var
  FormDCPoint: TPoint;
  CurrentRenderUnit: TRenderUnit;
  WindowSize: SIZE;
  ScreenHDC: HDC;
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
  WindowSize.cx := FRect.Width;
  WindowSize.cy := FRect.Height;
  ReportLog('[显示] 进入主循环');
  // Main Loop
  while True do begin
    if Self.Terminated then begin // Signalled to be terminated
      // Possible clean up
      // Clear Update Queue is done before starting threads
      {$IFDEF DEBUG}ReportLog('[显示] 退出 #1');{$ENDIF}
      Exit;
    end;
    UpdateS.Acquire; // Queue is MAYBE not empty
    CurrentRenderUnit.hDC := 0; // Default value to marked as unsuccessful
    UpdateQueueMutex.Acquire;
    if FQueue.Count > 0 then CurrentRenderUnit := FQueue.Dequeue; // Confirm REALLY there is anything
    UpdateQueueMutex.Release;
    if CurrentRenderUnit.hDC = 0 then Continue; // MAYBE queue is really empty OR parent thread is call me to exit
    ScreenHDC := GetDC(FHandle);
    try
      UpdateLayeredWindow(FHandle,ScreenHDC,nil,@WindowSize,CurrentRenderUnit.hDC,@FormDCPoint,0,@FBlend,ULW_ALPHA);
    finally
      ReleaseDC(FHandle,ScreenHDC);
      ReleaseDC(FHandle,CurrentRenderUnit.hSrcDC);
      DeleteObject(CurrentRenderUnit.hBitmap);
      DeleteDC(CurrentRenderUnit.hDC);
    end;
    Sleep(DEFAULT_UPDATE_INTERVAL);
  end;
end;

procedure TUpdateThread.ReportLog(Info: string);
begin
  Synchronize(procedure begin
    frmControl.LogEvent(Info);
  end);
end;

end.
