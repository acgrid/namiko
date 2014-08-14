{$DEFINE DEV}
unit CCommentForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  Math, IniFiles, StrUtils, ComCtrls, System.UITypes,
  CtrlForm;
type
  TWorkingState = (Stop, Idle, Working, Testing);
type
  TfrmComment = class(TForm)
    NetCDemo: TLabel;
    OfficialCDemo: TLabel;
    TestLabel: TLabel;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
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
    Curtains : Array of TLabel; // Label Containers for TComment with status STARTING/SCROOL/REMOVING
    Pool : Array of TComment; // Entities of TComment with status PENDING
    //Buffer : TQueue; // QueueManager for TComment with status PENDING
    //Field : TList; // ListManager for TAssign (Relationship Table)

    procedure LogEvent(Info: WideString);
    
    function GetMinChannel(): Integer;
    function GetMaxChannel(): Integer;
  public
    { Public declarations }
    State : TWorkingState;
    DisplayedCommentCount : Int64;
    //TimerDispatch : TThreadTimer;

    MAX_COMMENT_SPEED : SmallInt;

    procedure PurgeComment();
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
  ini : TCustomIniFile;
begin
  MovingWindow := false;
  MovingLabel := false;
  State := Stop;
  frmComment.Width := GetSystemMetrics(SM_CXSCREEN);
  frmComment.DoubleBuffered := true;
  DisplayedCommentCount := 0;
  MinFS := 65535;

  ini := TINIFile.Create(APP_DIR+'Settings.ini');
    TestLabel.Caption := ini.ReadString('Display','TitleText',TestLabel.Caption);
    TestLabel.Top := ini.ReadInteger('Display','TitleTop',TestLabel.Top);
    TestLabel.Left := ini.ReadInteger('Display','TitleLeft',TestLabel.Left);
    TestLabel.Font.Name := ini.ReadString('Display','TitleFontName',TestLabel.Font.Name);
    TestLabel.Font.Size := ini.ReadInteger('Display','TitleFontSize',TestLabel.Font.Size);
    TestLabel.Font.Color := StringToColor(ini.ReadString('Display','TitleColor','clTeal'));
    
    MAX_COMMENT_SPEED := ini.ReadInteger('Timing','MaxCommentSpeed',MAX_COMMENT_SPEED_DEFAULT);
  ini.Free;
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

procedure TfrmComment.SetTopMost();
begin
  SetWindowPos(Self.Handle,HWND_TOPMOST,Self.Left,Self.Top,Self.Width,Self.Height,SWP_NOACTIVATE or SWP_SHOWWINDOW);
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

{procedure TfrmComment.TimerMonitorTimer(Sender: TObject);
begin
  Monitor.Lines.Clear;
  Monitor.Lines.Add(Format('Current ID: %d',[frmControl.CurrListIndex]));
  Monitor.Lines.Add('Pending: '+IntToStr(PendingCommentCount()));
  Monitor.Lines.Add(Format('Channel: %d - %d',[GetMinChannel(),GetMaxChannel()]));
  Monitor.Lines.Add('Field: '+IntToStr(DisplayingCommentCount()));
  Monitor.Lines.Add('Pool: '+IntToStr(Length(Pool)));
  Monitor.Lines.Add('Control: '+IntToStr(Length(Curtains)));
end;}

function TfrmComment.GetMinChannel(): Integer;
var
  i : Integer;
begin
  Result := 0;
  {if Length(Pool) = 0 then exit;
  Result := frmComment.Height;
  for i := 0 to Length(Pool) - 1 do begin
    if Pool[i].ChannelFrom = -1 then continue;
    if Pool[i].ChannelFrom < Result then Result := Pool[i].ChannelFrom;
  end;}
end;

function TfrmComment.GetMaxChannel(): Integer;
var
  i : Integer;
begin
  Result := 0;
 { for i := 0 to Length(Pool) - 1 do begin
    if Pool[i].ChannelFrom = -1 then continue;
    if Pool[i].ChannelTo > Result then Result := Pool[i].ChannelTo;
  end;}
end;

procedure TfrmComment.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := False;
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
