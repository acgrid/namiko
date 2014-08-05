  {  
          ���ߣ�NeutronBoy  
          EMail��NeutronBoy@soh.com   xsxdelphi ���@sohu.com  
          ˵����  
          ��ý�嶨ʱ�������ȿ��Դﵽ1ms����ʱ�൱׼ȷ��  
          ����ǿ�������ʹ�ã��ǹ��뱣�����ߵ�ԭ��Ȩ��  
          �����Ŵ˾�Ϊ��õض�ý�嶨ʱ���أ���̴���(Code)�淶��࣬������  
          �ǽ���������ʹ�ã�����ؾ�Ϊ�ܹ�������ǵر������������  
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
          procedure   SetResolution(Value:   Cardinal);   //���÷ֱ���  
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
          if   Value   <   Caps.wPeriodMin   then   //С����С�ֱ���  
              Value   :=   0  
          else   if   Value   >   Caps.wPeriodMax   then   //������С�ֱ���  
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
          timeKillEvent(uTimerID);   //����  
      if   (FInterval   >   0)   and   FEnabled   and   Assigned(FOnTimer)   then  
      begin  
          lpTimerProc   :=   @TimerCallback;  
          uTimerID   :=   TimeSetEvent(FInterval,   FResolution,   lpTimerProc,   DWORD(Self),   TIME_PERIODIC);  
          if   uTimerID   =   0   then  
          begin  
              FEnabled   :=   FALSE;  
              raise   EMMTimer.Create('��ʱ������ʧ�ܣ�');  
          end;  
      end;  
  end;  
  end.   