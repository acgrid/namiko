unit DemoForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Math,
  System.UITypes, System.UIConsts,
  CfgForm, LogForm;

type
  TfrmDemo = class(TForm)
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
    procedure TestLabelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TestLabelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TestLabelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    OriLeft, OriTop, OriLabelLeft, OriLabelTop : Integer;
    MovingWindow, MovingLabel : Boolean;
    procedure SetTopMost();
    procedure LogEvent(Info: string; Level: TLogType = logInfo);
  public
    { Public declarations }
    procedure UpdateControls();
  end;

var
  frmDemo: TfrmDemo;

const
  STD_COMMENT_SHOWTIME_DEFAULT = 3000;
  MAX_COMMENT_SPEED_DEFAULT = 100;
  DEF_COMMENT_CONTROL = 40;
  //MAX_COMMENTS_DISPLAY = 80;

implementation

uses
  CtrlForm;

{$R *.dfm}

procedure TfrmDemo.LogEvent(Info: string; Level: TLogType = logInfo);
begin
  frmLog.LogAdd(Info, 'бнЪО', Level);
end;

procedure TfrmDemo.FormHide(Sender: TObject);
begin
  with frmControl do begin
    CCWinPos.Width := Self.Width;
    CCWinPos.Height := Self.Height;
    CCWinPos.Left := Self.Left;
    CCWinPos.Top := Self.Top;

    MTitleTop := TestLabel.Top;
    MTitleLeft := TestLabel.Left;
  end;
end;

procedure TfrmDemo.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  OriLeft := X;
  OriTop := Y;
  MovingWindow := true;
end;

procedure TfrmDemo.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MovingWindow := false;
end;

procedure TfrmDemo.FormShow(Sender: TObject);
begin
  UpdateControls;
end;

procedure TfrmDemo.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if MovingWindow then begin
    Left := Left + (X - OriLeft);
    Top := Top + (Y - OriTop);
  end;
end;

procedure TfrmDemo.FormCreate(Sender: TObject);
begin
  MovingWindow := False;
  MovingLabel := False;
end;

procedure TfrmDemo.SetTopMost();
begin
  SetWindowPos(Self.Handle,HWND_TOPMOST,Self.Left,Self.Top,Self.Width,Self.Height,SWP_NOACTIVATE or SWP_SHOWWINDOW);
end;

procedure TfrmDemo.TestLabelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MovingLabel := True;
  OriLabelLeft := X;
  OriLabelTop := Y;
end;

procedure TfrmDemo.TestLabelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if MovingLabel then begin
    TestLabel.Left := TestLabel.Left + (X - OriLabelLeft);
    TestLabel.Top := TestLabel.Top + (Y - OriLabelTop);
  end;
end;

procedure TfrmDemo.TestLabelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MovingLabel := False;
end;

procedure TfrmDemo.UpdateControls;
begin
  with frmControl do begin
    Self.Width := CCWinPos.Width;
    Self.Height := CCWinPos.Height;
    Self.Left := CCWinPos.Left;
    Self.Top := CCWinPos.Top;

    TestLabel.Caption := MTitleText;
    TestLabel.Top := MTitleTop;
    TestLabel.Left := MTitleLeft;
    TestLabel.Font.Name := MTitleFontName;
    TestLabel.Font.Size := Floor(MTitleFontSize);
    TestLabel.Font.Color := AlphaColorToColor(RGBToBGR(MTitleFontColor));

    NetCDemo.Font.Name := NetDefaultFontName;
    NetCDemo.Font.Size := Floor(NetDefaultFontSize);
    NetCDemo.Font.Color := AlphaColorToColor(NetDefaultFontColor);
    if NetDefaultFontStyle and 1 = 1 then NetCDemo.Font.Style := [fsBold] else NetCDemo.Font.Style := [];

    OfficialCDemo.Font.Name := OfficialFontName;
    OfficialCDemo.Font.Size := Floor(OfficialFontSize);
    OfficialCDemo.Font.Color := AlphaColorToColor(OfficialFontColor);
    if OfficialFontStyle and 1 = 1 then OfficialCDemo.Font.Style := [fsBold] else OfficialCDemo.Font.Style := [];
  end;
end;

end.
