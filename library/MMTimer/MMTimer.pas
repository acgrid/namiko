  {  
          作者：NeutronBoy  
          EMail：NeutronBoy@soh.com   xsxdelphi 软件@sohu.com  
          说明：  
          多媒体定时器，精度可以达到1ms，定时相当准确。  
          大伙们可以任意使用，非过请保留作者地原著权。  
          俺相信此就为最好地多媒体定时器呢，编程代码(Code)规范简洁，优美。  
          非仅方便大伙们使用，更多地就为能够给大伙们地编码带来帮助。  
  }  
  unit   MMTimer;  
   
  interface  
   
  uses  
      Windows,   SysUtils,   Classes,   MMSystem;  
   
  type  
      EMMTimer   =   class(Exception);  
      TMMTimer   =   class(TComponent)  
      private  
          uTimerID:   MMRESULT;  
          FInterval:   Cardinal;  
          FResolution:   Cardinal;  
          FOnTimer:   TNotifyEvent;  
          FEnabled:   Boolean;  
          procedure   UpdateTimer;  
          procedure   SetEnabled(Value:   Boolean);  
          procedure   SetInterval(Value:   Cardinal);  
          procedure   SetOnTimer(Value:   TNotifyEvent);  
          procedure   SetResolution(Value:   Cardinal);   //设置分辨率  
      protected  
          procedure   Timer;   dynamic;  
      public  
          constructor   Create(AOwner:   TComponent);   override;  
          destructor   Destroy;   override;  
      published  
          property   Enabled:   Boolean   read   FEnabled   write   SetEnabled   default   True;  
          property   Interval:   Cardinal   read   FInterval   write   SetInterval   default   1000;  
          property   Resolution:   Cardinal   read   FResolution   write   SetResolution   default   10;  
          property   OnTimer:   TNotifyEvent   read   FOnTimer   write   SetOnTimer;  
      end;  
   
  procedure   Register;  
   
  implementation  
   
  procedure   Register;  
  begin  
      RegisterComponents('System',   [TMMTimer]);  
  end;  
   
  procedure   TimerCallback(uTimerID,   uMessage:   Cardinal;   dwUser,   dw1,   dw2:   Cardinal);   stdcall;  
  var  
      MMTimer:   TMMTimer;  
  begin  
      MMTimer   :=   TMMTimer(dwUser);  
      if   Assigned(MMTimer)   then  
          MMTimer.Timer;  
  end;  
   
  {   TMMTimer   }  
   
  constructor   TMMTimer.Create(AOwner:   TComponent);  
  begin  
      inherited   Create(AOwner);  
      FEnabled   :=   True;  
      FInterval   :=   1000;  
      FResolution   :=   10;  
      uTimerID   :=   0;  
  end;  
   
  destructor   TMMTimer.Destroy;  
  begin  
      FEnabled   :=   False;  
      UpdateTimer;  
      inherited   Destroy;  
  end;  
   
  procedure   TMMTimer.SetEnabled(Value:   Boolean);  
  begin  
      if   Value   <>   FEnabled   then  
      begin  
          FEnabled   :=   Value;  
          UpdateTimer;  
      end;  
  end;  
   
  procedure   TMMTimer.SetInterval(Value:   Cardinal);  
  begin  
      if   Value   <>   FInterval   then  
      begin  
          FInterval   :=   Value;  
          UpdateTimer;  
      end;  
  end;  
   
  procedure   TMMTimer.SetOnTimer(Value:   TNotifyEvent);  
  begin  
      FOnTimer   :=   Value;  
      UpdateTimer;  
  end;  
   
  procedure   TMMTimer.SetResolution(Value:   Cardinal);  
  var  
      Caps:   TTimeCaps;  
  begin  
      if   (Value   <>   FResolution)   and   (timeGetDevCaps(@Caps,   Sizeof(TTimeCaps))   <>   0)   then  
      begin  
          if   Value   <   Caps.wPeriodMin   then   //小于最小分辨率  
              Value   :=   0  
          else   if   Value   >   Caps.wPeriodMax   then   //大于最小分辨率  
              Value   :=   Caps.wPeriodMax;  
          FInterval   :=   Value;  
          UpdateTimer;  
      end;  
  end;  
   
  procedure   TMMTimer.Timer;  
  begin  
  //     if   Assigned(MMTimer.OnTimer)   then  
  //         FOnTimer(MMTimer);  
      if   Assigned(OnTimer)   then  
          FOnTimer(Self);  
   
  end;  
   
  procedure   TMMTimer.UpdateTimer;  
  var  
      lpTimerProc:   TFNTimeCallBack;  
  begin  
      if   uTimerID   <>   0   then  
          timeKillEvent(uTimerID);   //销毁  
      if   (FInterval   >   0)   and   FEnabled   and   Assigned(FOnTimer)   then  
      begin  
          lpTimerProc   :=   @TimerCallback;  
          uTimerID   :=   TimeSetEvent(FInterval,   FResolution,   lpTimerProc,   DWORD(Self),   TIME_PERIODIC);  
          if   uTimerID   =   0   then  
          begin  
              FEnabled   :=   FALSE;  
              raise   EMMTimer.Create('定时器创建失败！');  
          end;  
      end;  
  end;  
  end.   