  unit   ThreadTimer;

  interface

  uses
  Classes,
  sysutils,
  syncobjs;

type
      TThreadTimer   =   class(TThread)
      private
          cs:tcriticalsection;
          Interval:integer;
          OnTimer:TNotifyEvent;

      protected
          procedure   Execute;   override;
      public
          function   GetInterval:integer;
          procedure   SetInterval(Interval:integer);
          procedure   SetOntimer(Ontimer:TNotifyEvent);
          function   GetOnTimer:TNotifyEvent;
          /////////
          procedure   SetEnabled(Enabled:boolean);
          function   GetEnabled:boolean;
          /////////
          constructor   Create(Interval:integer;Ontimer:TNotifyEvent);
          destructor   Destroy;override;
      end;

  implementation


  {   TThreadTimer   }

  constructor   TThreadTimer.Create(Interval:   integer;   Ontimer:   TNotifyEvent);
  begin
      inherited   create(true);
      self.Interval:=interval;
      self.OnTimer:=ontimer;
      freeonterminate:=true;
      cs:=tcriticalsection.Create;

  end;

  destructor   TThreadTimer.Destroy;
  begin
      cs.Free;
      inherited;
  end;

  procedure   TThreadTimer.Execute;
  var
  i:integer;
  begin
      while   not   terminated   do
      begin
          cs.Enter;
          i:=interval;
          cs.Leave;
          sleep(i);
          cs.Enter;
          try
          if   assigned(ontimer)then
              ontimer(self);
          finally
          cs.Leave;
          end;
      end;
  end;

  function   TThreadTimer.GetEnabled:   boolean;
  begin
      result:=self.Suspended;
  end;

  function   TThreadTimer.GetInterval:   integer;
  begin
      cs.Enter;
      result:=interval;
      cs.Leave;
  end;

  function   TThreadTimer.GetOnTimer:   TNotifyEvent;
  begin
      cs.Enter;
      result:=ontimer;
      cs.Leave;
  end;



  procedure   TThreadTimer.SetEnabled(Enabled:   boolean);
  begin
      if   enabled   then
          resume
      else
          suspend;
  end;

  procedure   TThreadTimer.SetInterval(Interval:   integer);
  begin
      cs.Enter;
      self.Interval:=interval;
      cs.Leave;
  end;

  procedure   TThreadTimer.SetOntimer(Ontimer:   TNotifyEvent);
  begin
      cs.Enter;
      self.OnTimer:=ontimer;
      cs.Leave;
  end;


  end.
