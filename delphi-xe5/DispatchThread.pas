unit DispatchThread;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, Math,
  CtrlForm;

type
  TDispatchThread = class(TThread)
    MDiscardBefore: Cardinal; // Discard comments older than N msec
    MAcceptAfter: Cardinal;   // Accept comments newer than N msec
  constructor Create(DiscardBefore: Cardinal; AcceptAfter: Cardinal;
    var RefMainPool: TCommentCollection; var RefLivePool: TLiveCommentCollection);
  protected
    FPoolFrontier: Integer;
    FPoolTail: Integer;
    FMainPool: TCommentCollection;
    FLivePool: TLiveCommentCollection;
    procedure CheckPool(From: Integer; Till: Integer);
    procedure DoDispatch(AComment: TComment);
    procedure Execute; override;
    procedure ReportLog(Info: string);
    procedure NotifyStatusChanged(CommentID: Integer);
  end;

implementation

{ 
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);  

  and UpdateCaption could look like,

    procedure TDispatchThread.UpdateCaption;
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

{ TDispatchThread }

constructor TDispatchThread.Create(DiscardBefore: Cardinal; AcceptAfter: Cardinal; var RefMainPool: TCommentCollection; var RefLivePool: TLiveCommentCollection);
begin
  MDiscardBefore := DiscardBefore;
  MAcceptAfter := AcceptAfter;
  FPoolFrontier := 0;
  FPoolTail := -1;
  if not Assigned(RefMainPool) then raise Exception.Create('RefMainPool is not initialized.');
  FMainPool := RefMainPool;
  if not Assigned(RefLivePool) then raise Exception.Create('RefLivePool is not initialized.');
  FLivePool := RefLivePool;
  inherited Create(True);
end;

procedure TDispatchThread.CheckPool(From: Integer; Till: Integer);
var
  i: Integer;
  AComment: TComment;
  TimeNow: TTime;
begin
  {$IFDEF DEBUG}ReportLog(Format('[调度] 调度 %u - %u 弹幕池共有%u',[From,Till,FMainPool.Count]));{$ENDIF}
  TimeNow := Now();
  with FMainPool do begin
    for i := From to Till do begin
      CommentPoolMutex.Acquire;
      try
        if i < Count then AComment := Items[i] else Continue; // Double Check
      finally
        CommentPoolMutex.Release;
      end;
      if (AComment.Status = Created) or (AComment.Status = Pending) then begin
        // Subject to be dispatched
        {$IFDEF DEBUG}ReportLog(Format('[调度] 调度 %u 创建或待定状态',[i]));{$ENDIF}
        if TimeNow > AComment.Time then begin
          // TOO OLD
          if TimeNow - AComment.Time > MDiscardBefore / 86400000 then begin
            {$IFDEF DEBUG}ReportLog(Format('[调度] 调度 %u 超时删除',[i]));{$ENDIF}
            CommentPoolMutex.Acquire;
            try
              AComment.Status := Removed;
              NotifyStatusChanged(AComment.ID);
            finally
              CommentPoolMutex.Release;
            end;
            Continue;
          end
          else begin
            {$IFDEF DEBUG}ReportLog(Format('[调度] 迟调度 %u ',[i]));{$ENDIF}
            DoDispatch(AComment);
            Continue;
          end;
        end
        else begin // FUTURE TIME
          if AComment.Time - TimeNow < MAcceptAfter / 86400000 then begin
            {$IFDEF DEBUG}ReportLog(Format('[调度] 早调度 %u ',[i]));{$ENDIF}
            DoDispatch(AComment);
            Continue;
          end;
        end;
        if AComment.Status = Created then begin
          {$IFDEF DEBUG}ReportLog(Format('[调度] 过早调度 %u ',[i]));{$ENDIF}
          CommentPoolMutex.Acquire;
          try
            AComment.Status := Pending;
            NotifyStatusChanged(AComment.ID);
          finally
            CommentPoolMutex.Release;
          end;
        end;
      end
      else if AComment.Status = Removed then begin
        // Offset my tail pointer
        if i = FPoolTail + 1 then FPoolTail := i;
      end;
    end;
  end;
end;

procedure TDispatchThread.DoDispatch(AComment: TComment);
var
  ALiveComment: TLiveComment;
begin
  CommentPoolMutex.Acquire;
  try
    AComment.Status := TCommentStatus.Starting;
    NotifyStatusChanged(AComment.ID);
  finally
    CommentPoolMutex.Release;
  end;
  ALiveComment := TLiveComment.Create();
  ALiveComment.Body := AComment;
  {$IFDEF DEBUG}ReportLog(Format('[调度] 初始化运行时弹幕 %u',[ALiveComment.Body.ID]));{$ENDIF}
  LiveCommentPoolMutex.Acquire;
  try
    {$IFDEF DEBUG}ReportLog(Format('[调度] 已请求运行时弹幕池',[]));{$ENDIF}
    FLivePool.Add(ALiveComment);
  finally
    LiveCommentPoolMutex.Release;
    {$IFDEF DEBUG}ReportLog(Format('[调度] 已释放运行时弹幕池',[]));{$ENDIF}
  end;
end;

procedure TDispatchThread.Execute;
var
  WaitResult: TWaitResult;
  PoolCount, NewFrontier: Integer;
begin
  {$IFDEF DEBUG}NameThreadForDebugging('Dispatch');{$ENDIF}
  { Place thread code here }

  while True do begin
    if Terminated then begin
      {$IFDEF DEBUG}ReportLog('[调度] 退出 #1');{$ENDIF}
      Exit;
    end;
    WaitResult := DispatchS.WaitFor(1000);
    if Terminated then begin
      {$IFDEF DEBUG}ReportLog('[调度] 退出 #2');{$ENDIF}
      Exit;
    end;
    CommentPoolMutex.Acquire;
    try
      PoolCount := FMainPool.Count;
      if PoolCount > 0 then NewFrontier := FMainPool.Last.ID; // ID is 1-started index
    finally
      CommentPoolMutex.Release;
    end;
    if PoolCount > 0 then begin // KEEP IN MIND Count is MAYBE Changed!
      if (WaitResult = wrSignaled) and (NewFrontier > FPoolFrontier) then begin // Check the CommentPool
        CheckPool(FPoolFrontier,NewFrontier - 1); // Fast dispatch
        FPoolFrontier := NewFrontier;
      end
      else if NewFrontier - 1 >= FPoolTail + 1 then begin
        CheckPool(FPoolTail + 1,NewFrontier - 1); // Normal dispatch, Prevent OUT OF RANGE
      end;
    end;
  end;
end;

procedure TDispatchThread.ReportLog(Info: string);
begin
  Synchronize(procedure begin
    frmControl.LogEvent(Info);
  end);
end;

procedure TDispatchThread.NotifyStatusChanged(CommentID: Integer);
begin
  Synchronize(procedure begin
    if Assigned(frmControl) then frmControl.UpdateListView(CommentID);
  end);
end;

end.
