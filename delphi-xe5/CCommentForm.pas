//{$DEFINE DEV}
unit CCommentForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, CtrlForm, TntExtCtrls, TntStdCtrls,
  CoolCtrls, Math, IniFiles, StrUtils, MMTimer, CoolTools, ComCtrls, ThreadTimer;
type
  TWorkingState = (Stop, Idle, Working, Testing);
type
  TCommentList = Array of Integer;
type
  TfrmComment = class(TForm)
    TimerMonitor: TTimer;
    Monitor: TMemo;
    NetCDemo: TTntLabel;
    OfficialCDemo: TTntLabel;
    TestLabel: TCoolLabel;
    TimerMoving: TTimer;
    TimerDispatch: TTimer;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure TimerMovingTimer(Sender: TObject);
    procedure TimerDispatchTimer(Sender: TObject);
    procedure TimerMonitorTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TestLabelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TestLabelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TestLabelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    OriLeft, OriTop, OriLabelLeft, OriLabelTop, MinFS : Integer;
    MovingWindow, MovingLabel : Boolean;
    // DATA STRUCTURES
    Curtains : Array of TCoolLabel; // Label Containers for TComment with status STARTING/SCROOL/REMOVING
    Pool : Array of TComment; // Entities of TComment with status PENDING
    //Buffer : TQueue; // QueueManager for TComment with status PENDING
    //Field : TList; // ListManager for TAssign (Relationship Table)
    ControlFree: Array of Boolean; // Control(TCoolLabel) Using Map

    procedure LogEvent(Info: WideString);
    
    function AnyControlFree(): Boolean;
    procedure InitControl(Index: Integer);
    procedure ResetControl(Index: Integer);
    procedure SetControlVar(Index: Integer);
    procedure SetFont(Index: Integer; Src: String);
    procedure AssignFreeControl(CommentIndex: Integer);
    function CommentAddPool(Comment: TComment): Integer;
    procedure RequestChannel(var Comment: TComment);
    function GetMinChannel(): Integer;
    function GetMaxChannel(): Integer;
    function IsChannelUsed(FromPos, ToPos: Integer; Layer: Integer=0): Boolean;
    function ConflictTest(Comment: TComment; FromPos: Integer; ToPos: Integer; Layer: Integer=0): Boolean;
    function GetPossibleConflicts(FromPos, ToPos: Integer; Layer: Integer=0): TCommentList;
  public
    { Public declarations }
    State : TWorkingState;
    DisplayedCommentCount : Int64;
    //TimerDispatch : TThreadTimer;

    DEF_COMMENTS_DISPLAY : SmallInt;
    STD_COMMENT_SHOWTIME : Integer;
    MAX_COMMENT_SPEED : SmallInt;

    procedure AddComment(Comment: TComment);
    procedure PurgeComment();
    procedure ExpandControl(Quantity: SmallInt=1);
    function PendingCommentCount(): Integer;
    function DisplayingCommentCount(): Integer;
    function DisplayCapacity(): Integer;

    procedure SetTopMost();
  end;

var
  frmComment: TfrmComment;

const
  STD_COMMENT_SHOWTIME_DEFAULT = 3000;
  MAX_COMMENT_SPEED_DEFAULT = 100;
  DEF_COMMENT_CONTROL = 40;
  //MAX_COMMENTS_DISPLAY = 80;

procedure DynArrayDelete(var A; elSize: Longint; index, Count: Integer);

implementation

{$R *.dfm}

procedure TfrmComment.LogEvent(Info: WideString);
begin
  frmControl.LogEvent(Info);
end;

procedure TfrmComment.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  OriLeft := X;
  OriTop := Y;
  MovingWindow := true;
end;

procedure TfrmComment.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MovingWindow := false;
end;

procedure TfrmComment.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if MovingWindow then begin
    Left := Left + (X - OriLeft);
    Top := Top + (Y - OriTop);
  end;
end;

procedure TfrmComment.FormCreate(Sender: TObject);
var
  i : SmallInt;
  ini : TCustomIniFile;
begin
  MovingWindow := false;
  MovingLabel := false;
  State := Stop;
  frmComment.Width := GetSystemMetrics(SM_CXSCREEN);
  frmComment.DoubleBuffered := true;
  Monitor.DoubleBuffered := true;
  DisplayedCommentCount := 0;
  MinFS := 65535;

  ini := TINIFile.Create(APP_DIR+'Settings.ini');
    TestLabel.Caption := ini.ReadString('Display','TitleText',TestLabel.Caption);
    TestLabel.Top := ini.ReadInteger('Display','TitleTop',TestLabel.Top);
    TestLabel.Left := ini.ReadInteger('Display','TitleLeft',TestLabel.Left);
    TestLabel.Font.Name := ini.ReadString('Display','TitleFontName',TestLabel.Font.Name);
    TestLabel.Font.Size := ini.ReadInteger('Display','TitleFontSize',TestLabel.Font.Size);
    TestLabel.Font.Color := StringToColor(ini.ReadString('Display','TitleColor','clTeal'));
    
    DEF_COMMENTS_DISPLAY := ini.ReadInteger('Display','DefaultCommentsDisplay',DEF_COMMENT_CONTROL);
    STD_COMMENT_SHOWTIME := ini.ReadInteger('Timing','DefaultCommentShowTime',STD_COMMENT_SHOWTIME_DEFAULT);
    MAX_COMMENT_SPEED := ini.ReadInteger('Timing','MaxCommentSpeed',MAX_COMMENT_SPEED_DEFAULT);
  ini.Free;

  SetLength(Curtains,DEF_COMMENTS_DISPLAY);
  SetLength(ControlFree,DEF_COMMENTS_DISPLAY);
  for i := 0 to DEF_COMMENTS_DISPLAY - 1 do begin
    ControlFree[i] := true;
    InitControl(i);
  end;
  // Init TimerDispatch
  //TimerDispatch := TThreadTimer.Create(30,TimerDispatchTimer);
  //TimerDispatch.SetEnabled(true);
  
  // Init Codes Put above
  // Inform frmControl CComment is Ready
  with frmControl do begin
    NetCDemo.Font.Name := cobNetCFontName.Items.Strings[cobNetCFontName.ItemIndex];
    NetCDemo.Font.Size := StrToInt(cobNetCFontSize.Text);
    NetCDemo.Font.Color := cobNetCFontColor.Brush.Color;
    if cobNetCFontBold.Checked then NetCDemo.Font.Style := [fsBold];
    OfficialCDemo.Font.Name := cobOfficialCFontName.Items.Strings[cobOfficialCFontName.ItemIndex];
    OfficialCDemo.Font.Size := StrToInt(cobOfficialCFontSize.Text);
    OfficialCDemo.Font.Color := cobOfficialCFontColor.Brush.Color;
    if cobOfficialCFontBold.Checked then OfficialCDemo.Font.Style := [fsBold];

    StatusBar.Panels[0].Text := '弹幕窗口初始化完毕';
    TimerGeneral.Enabled := true; // Avoid Invaild Access when Comment Window is not Ready
    btnCCShow.Click;
  end;
end;

procedure TfrmComment.InitControl(Index: Integer);
begin
  Curtains[Index] := TCoolLabel.Create(frmComment);
  Curtains[Index].Parent := frmComment;
  Curtains[Index].ParentColor := false;
  Curtains[Index].ParentFont := false;
  Curtains[Index].Color := frmComment.Color;
  Curtains[Index].Transparent := true;
  Curtains[Index].AutoSize := true;
  Curtains[Index].Anchors := [];
  //Curtains[Index].Visible := false;
  Curtains[Index].Left := frmComment.Width;
end;

procedure TfrmComment.TimerMovingTimer(Sender: TObject);
var
  i,j : SmallInt;
begin
  case State of
    Working: begin
      Application.ProcessMessages;
      for i := 0 to Length(Pool) - 1 do begin
        if (Pool[i].Status = Displaying) and (Pool[i].Effect.Display = Scroll) then begin
          j := Pool[i].ControlIndex;
          try
            if Curtains[j].Left > 0 - Curtains[j].Width then begin
              Curtains[j].Left := Curtains[j].Left - Pool[i].Effect.Speed;
            end
            else begin
              dec(Pool[i].Effect.RepeatCount);
              if Pool[i].Effect.RepeatCount <= 0 then
                Pool[i].Status := Removing
              else
                ResetControl(j);
            end;
          except
            frmControl.LogEvent('TimerMoving Failed at '+IntToStr(i));
            TimerMoving.Enabled := false;
          end;
        end;
      end;
    end;
  end;
end;


procedure TfrmComment.SetTopMost();
begin
  SetWindowPos(Self.Handle,HWND_TOPMOST,Self.Left,Self.Top,Self.Width,Self.Height,SWP_NOACTIVATE or SWP_SHOWWINDOW);
end;

procedure TfrmComment.AddComment(Comment: TComment);
var
  i : Integer;
begin
  State := Working;
  i := CommentAddPool(Comment);
  if AnyControlFree() then begin
    AssignFreeControl(i);
    Pool[i].Status := Starting;
  end
  else begin
    Pool[i].Status := Pending;
    ExpandControl(DEF_COMMENT_CONTROL);
    frmControl.NotifyCommentStatus(Comment.ID, Waiting);
    frmControl.LogEvent('Pending Comment:'+IntToStr(i));
  end;
end;

procedure TfrmComment.SetControlVar(Index: Integer);
var
  j, Speed: Integer;
begin
  j := Pool[Index].ControlIndex;
  if j = -1 then exit; // No Controls Assigned.
  Curtains[j].Caption := Pool[Index].Content; // Don't move this line!
  SetFont(j,Pool[Index].Font);
  case Pool[Index].Effect.Display of
    Scroll: begin
      Speed := (Curtains[j].Width + frmComment.Width) div (Pool[Index].Effect.StayTime div Integer(TimerMoving.Interval));
      if Speed > MAX_COMMENT_SPEED then begin
        Pool[Index].Effect.Speed := MAX_COMMENT_SPEED;
        Pool[Index].Effect.StayTime := (Curtains[j].Width + frmComment.Width) * MAX_COMMENT_SPEED div Integer(TimerMoving.Interval);
      end
      else
        Pool[Index].Effect.Speed := Speed;
      {$IFDEF DEV}LogEvent(Format('速度 %d 路径总长 %d 时间 %d',[Speed,Curtains[j].Width + frmComment.Width,Pool[Index].Effect.StayTime]));{$ENDIF}
    end;
    UpperFixed, LowerFixed: begin
      Curtains[j].Left := (frmComment.Width - Curtains[j].Width) div 2;
    end;
  end;
  RequestChannel(Pool[Index]);
  if LeftStr(Pool[Index].Content,1) = '@' then Curtains[j].Caption := RightStr(Pool[Index].Content,Length(Pool[Index].Content)-1);
  {$IFDEF DEV}frmControl.LogEvent('Channel: '+IntToStr(Pool[Index].ChannelFrom)+'-'+IntToStr(Pool[Index].ChannelTo));{$ENDIF}
end;

procedure TfrmComment.SetFont(Index: Integer; Src: String);
var
  Font: TFont;
begin
  Font := Curtains[Index].Font;
  SetFontData(Src,Font);
  Curtains[Index].Font := Font;
end;

procedure TfrmComment.RequestChannel(var Comment: TComment);
var
  j,n,m,fs,Layer : Integer;
  Done : Boolean;
begin
  Done := false;
  Layer := 1;
  m := -1; //Uninit
  n := -1; //Uninit
  j := Comment.ControlIndex;
  fs := Curtains[j].Height; // TODO: Consider Use Comment.Control.Height
  if fs < MinFS then MinFS := fs div 2; // Escape too long spaces
  case Comment.Effect.Display of
    Scroll, UpperFixed: begin // Flying and Upper
      repeat
        n := 0;
        m := n + fs - 1;
        repeat
          if IsChannelUsed(n,m,Layer) then begin  // Unused by any comments
            if not ConflictTest(Comment,n,m,Layer) then begin
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
        until m >= frmComment.Height;
        if not Done then inc(Layer);
      until Done;
    end;
    LowerFixed: begin
      repeat
        m := frmComment.Height;
        n := m - fs + 1;
        repeat
          if IsChannelUsed(n,m,Layer) then begin  // Unused by any comments
            if not ConflictTest(Comment,n,m,Layer) then begin
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
  {$IFDEF DEV}LogEvent(Format('Channel Assignment: %d %d-%d',[Layer,n,m]));{$ENDIF}
  Comment.ChannelLayer := Layer;
  Comment.ChannelFrom := n;
  Curtains[j].Top := n;
  Comment.ChannelTo := m;
end;

function TfrmComment.ConflictTest(Comment: TComment; FromPos: Integer; ToPos: Integer; Layer: Integer=0): Boolean;
var
  PossibleConflicts : TCommentList;
  h,i,j,k : Integer;
  { i PervPoolIndex
    j CurrControlIndex
    k PervControlIndex  }
  CurrFlyTime, PervFlyTime, CheckTime : Double;
begin
  Result := false;
  if Comment.Effect.Display = LowerFixed then begin
    Result := true; // From bottom to top.
    exit;
  end;
  j := Comment.ControlIndex;
  PossibleConflicts := GetPossibleConflicts(FromPos,ToPos,Layer);
  for h := 0 to Length(PossibleConflicts) - 1 do begin
    i := PossibleConflicts[h];
    k := Pool[i].ControlIndex;
    if Pool[i].Status <> Displaying then continue;
    case Comment.Effect.Display of
      UpperFixed: begin
        case Pool[i].Effect.Display of
          UpperFixed: begin // #4 Up-Up: Always Conflict
            Result := true;
            exit;
          end;
          else begin // #3 ReqUp-PervFly
            Result := Boolean(Curtains[k].Left + Curtains[k].Width > Curtains[j].Left);
            if Result then exit;
          end;
        end;
      end;
      else begin
        CurrFlyTime := (Curtains[j].Left + Curtains[j].Width) / Comment.Effect.Speed;
        PervFlyTime := (Curtains[k].Left + Curtains[k].Width) / Pool[i].Effect.Speed;
        case Pool[i].Effect.Display of
          UpperFixed: begin // #2 ReqFly-PervUp
            Result := Boolean(frmComment.Width - (Curtains[j].Left + Curtains[j].Width) div Comment.Effect.StayTime * Pool[i].Effect.StayTime >= Curtains[k].Left + Curtains[k].Width);
            if Result then exit;
          end;
          else begin // #1 Fly-Fly
            if LeftStr(Comment.Content,1) = '@' then exit;
            Result := true;
            if Curtains[k].Left + Curtains[k].Width < frmComment.Width then begin
              CheckTime := Min(CurrFlyTime,PervFlyTime);
              if Curtains[k].Left + Curtains[k].Width - Pool[i].Effect.Speed * CheckTime <= Curtains[j].Left - Comment.Effect.Speed * CheckTime then Result := false;
            end;
            {if (CurrFlyTime > PervFlyTime) and (Curtains[k].Left + Curtains[k].Width < Curtains[j].Left) then begin
              Result := false;
            end
            else begin
              Result := true;
              exit;
            end;}
            {Result := false;
            if (Curtains[k].Left > frmComment.Width div 3 * 2) and (Curtains[k].Width < frmComment.Width div 2) then begin
              Result := true;
              exit;
            end;}
          end;
        end;
      end;
    end;
  end;
end;

function TfrmComment.GetPossibleConflicts(FromPos: Integer; ToPos: Integer; Layer: Integer=0): TCommentList;
var
  i,m : Integer;
  Conflicts : TCommentList;
begin
  SetLength(Conflicts,0);
  m := 1;
  for i := 0 to Length(Pool) - 1 do begin
    if (Layer > 0) and (Pool[i].ChannelLayer <> Layer) then continue;
    if Pool[i].ChannelFrom = -1 then continue;
    if (Pool[i].ChannelFrom >= FromPos) and (Pool[i].ChannelFrom <= ToPos) then begin SetLength(Conflicts,m); Conflicts[m-1] := i; inc(m); continue; end;
    if (Pool[i].ChannelFrom <= FromPos) and (Pool[i].ChannelTo >= ToPos) then begin SetLength(Conflicts,m); Conflicts[m-1] := i; inc(m); continue; end;
    if (Pool[i].ChannelTo >= FromPos) and (Pool[i].ChannelTo <= ToPos) then begin SetLength(Conflicts,m); Conflicts[m-1] := i; inc(m); end;
  end;
  Result := Conflicts;
end;

procedure TfrmComment.TimerDispatchTimer(Sender: TObject);
var
  i,n : Integer;
begin
  for i := 0 to Length(Pool) - 1 do begin
    case Pool[i].Status of
      Pending: begin
        if AnyControlFree() then begin
          AssignFreeControl(i);
          SetControlVar(i);
          Pool[i].Status := Starting;
        end;
      end;
      Starting: begin
        SetControlVar(i);
        inc(DisplayedCommentCount);
        Pool[i].Status := Displaying;
        frmControl.NotifyCommentStatus(Pool[i].ID,Displaying);
        exit;
      end;
      Displaying: begin
        if (Pool[i].Effect.Display = UpperFixed) or (Pool[i].Effect.Display = LowerFixed) then begin
          if Pool[i].Effect.StayTime <= 0 then
            Pool[i].Status := Removing
          else
            Pool[i].Effect.StayTime := Pool[i].Effect.StayTime - Integer(TimerDispatch.Interval);
        end;
      end;
      Removing: begin
        frmControl.NotifyCommentStatus(Pool[i].ID,Removing);
        n := Pool[i].ControlIndex;
        ResetControl(n);
        if n >= 0 then ControlFree[n] := true;
        Pool[i].Status := Removed;
      end;
      Removed: begin
        DynArrayDelete(Pool,SizeOf(TComment),i,1);
      end;
    end;
  end;
end;

function TfrmComment.AnyControlFree(): Boolean;
var
  i : Integer;
begin
  //if (Length(Curtains) - Length(Pool) < 3) and (Length(Curtains) < MAX_COMMENTS_DISPLAY) then ExpandControl(3-Length(Curtains)+Length(Pool));
  if Length(Pool) < Length(Curtains) then begin
    try
      i := Length(Curtains) - 1;
      Curtains[i].Top := 0; // TEST Control is ready.
      Result := true;
    except
      LogEvent('AnyCF detected');
      Result := false;
    end;
  end
  else begin
    Result := false;
    for i := 0 to Length(ControlFree) - 1 do begin
      if ControlFree[i] then begin
        try
          Curtains[i].AutoSize := true; // Test it usable
          Result := true;
        except
          Result := false;
        end;
      end;
    end;
  end;
end;

procedure TfrmComment.AssignFreeControl(CommentIndex: Integer);
var
  i,m : Integer;
begin
  m := Length(ControlFree);
  for i := 0 to m - 1 do begin
    if ControlFree[i] then begin
      {$IFDEF DEV}frmControl.LogEvent('Assign Control '+IntToStr(i)+' for Comment Index '+IntToStr(CommentIndex));{$ENDIF}
      ControlFree[i] := false;
      Pool[CommentIndex].ControlIndex := i;
      exit; // If not exit (No free controls available) create one
    end;
  end;
  SetLength(ControlFree,m+1);
  SetLength(Curtains,m+1);
  InitControl(m);
  ControlFree[m] := false;
  Pool[CommentIndex].ControlIndex := m;
end;

procedure TfrmComment.ExpandControl(Quantity: SmallInt=1);
var
  m, i : Integer;
begin
  LogEvent('Expand Start');
  TimerDispatch.Enabled := false;
  for i := 1 to Quantity do begin
    m := Length(Curtains);
    SetLength(ControlFree,m+1);
    SetLength(Curtains,m+1);
    InitControl(m);
    ControlFree[m] := true;
  end;
  TimerDispatch.Enabled := true;
  LogEvent('Expand End');
end;

function TfrmComment.CommentAddPool(Comment: TComment): Integer;
var
  i,m : Integer;
begin
  m := Length(Pool);
  for i := 0 to m-1 do begin
    if Pool[i].Status = Removed then begin
      Pool[i] := Comment;
      Result := i;
      exit;
    end;
  end;
  SetLength(Pool,m+1);
  Pool[m] := Comment;
  Result := m;
end;

function TfrmComment.DisplayingCommentCount(): Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to Length(Pool) - 1 do begin
    if Pool[i].Status = Displaying then inc(Result);
  end;
end;

function TfrmComment.PendingCommentCount(): Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to Length(Pool) - 1 do begin
    if Pool[i].Status = Pending then inc(Result);
  end;
end;

procedure TfrmComment.ResetControl(Index: Integer);
begin
  Curtains[Index].Left := frmComment.Width;
end;

procedure TfrmComment.TimerMonitorTimer(Sender: TObject);
begin
  Monitor.Lines.Clear;
  Monitor.Lines.Add(Format('Current ID: %d',[frmControl.CurrListIndex]));
  Monitor.Lines.Add('Pending: '+IntToStr(PendingCommentCount()));
  Monitor.Lines.Add(Format('Channel: %d - %d',[GetMinChannel(),GetMaxChannel()]));
  Monitor.Lines.Add('Field: '+IntToStr(DisplayingCommentCount()));
  Monitor.Lines.Add('Pool: '+IntToStr(Length(Pool)));
  Monitor.Lines.Add('Control: '+IntToStr(Length(Curtains)));
end;

function TfrmComment.GetMinChannel(): Integer;
var
  i : Integer;
begin
  Result := 0;
  if Length(Pool) = 0 then exit;
  Result := frmComment.Height;
  for i := 0 to Length(Pool) - 1 do begin
    if Pool[i].ChannelFrom = -1 then continue;
    if Pool[i].ChannelFrom < Result then Result := Pool[i].ChannelFrom;
  end;
end;

function TfrmComment.GetMaxChannel(): Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to Length(Pool) - 1 do begin
    if Pool[i].ChannelFrom = -1 then continue;
    if Pool[i].ChannelTo > Result then Result := Pool[i].ChannelTo;
  end;
end;

function TfrmComment.IsChannelUsed(FromPos, ToPos: Integer; Layer: Integer=0): Boolean;
var
  i : Integer;
begin
  result := false;
  for i := 0 to Length(Pool) - 1 do begin
    if (Layer > 0) and (Pool[i].ChannelLayer <> Layer) then continue;
    if Pool[i].ChannelFrom = -1 then continue;
    if (Pool[i].ChannelFrom >= FromPos) and (Pool[i].ChannelFrom <= ToPos) then begin Result := true; exit; end;
    if (Pool[i].ChannelFrom <= FromPos) and (Pool[i].ChannelTo >= ToPos) then begin Result := true; exit; end;
    if (Pool[i].ChannelTo >= FromPos) and (Pool[i].ChannelTo <= ToPos) then begin Result := true; exit; end;
  end;
end;

procedure DynArrayDelete(var A; elSize: Longint; index, Count: Integer);
var
	len, MaxDelete: Integer;
	P : PLongint;
begin
	P := PLongint(A);
	if P = nil then Exit;
	len := PLongint(PChar(P) - 4)^;
	if index >= len then Exit;
	MaxDelete := len - index;
	Count := Min(Count, MaxDelete);
	if Count = 0 then Exit;  
	Dec(len, Count);
	MoveMemory(PChar(P)+index*elSize , PChar(P)+(index + Count)*elSize , (len-index)*elSize); //移动内存
	Dec(P);
	Dec(P);
	ReallocMem(P, len * elSize + Sizeof(Longint) * 2);
	Inc(P);
	P^ := len;
	Inc(P);
	PLongint(A) := P;
end;

procedure TfrmComment.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := false;
end;

procedure TfrmComment.TestLabelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MovingLabel := true;
  OriLabelLeft := X;
  OriLabelTop := Y;
end;

procedure TfrmComment.TestLabelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if MovingLabel then begin
    TestLabel.Left := TestLabel.Left + (X - OriLabelLeft);
    TestLabel.Top := TestLabel.Top + (Y - OriLabelTop);
  end;
end;

procedure TfrmComment.TestLabelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MovingLabel := false;
end;

procedure TfrmComment.PurgeComment();
var
  i: Integer;
begin
  for i := 0 to Length(Pool) - 1 do begin
    Pool[i].Status := Removing;
  end;
end;

function TfrmComment.DisplayCapacity(): Integer;
begin
  Result := Length(frmComment.Curtains);
end;

end.
