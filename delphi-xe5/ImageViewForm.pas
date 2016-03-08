unit ImageViewForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TfrmImage = class(TForm)
    ProgressBarRemaining: TProgressBar;
    ImagePresentation: TImage;
    LabelSignature: TLabel;
    TimerHide: TTimer;
    procedure FormResize(Sender: TObject);
    procedure TimerHideTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DelayTime, LeftTime: Cardinal;
    procedure Display;
    procedure Init;
  end;

var
  frmImage: TfrmImage;

procedure SetFormMonitor(Form:TCustomForm; MonitorIndex, Left, Top: Integer);

implementation

uses
  JPEGUtils, CfgForm;

{$R *.dfm}

procedure TfrmImage.FormCreate(Sender: TObject);
begin
  Init;
end;

procedure SetFormMonitor(Form: TCustomForm; MonitorIndex, Left, Top: Integer);
begin
  if (MonitorIndex > -1) and (MonitorIndex < Screen.MonitorCount) then begin
    Form.SetBounds(
      Screen.Monitors[MonitorIndex].Left + Left,
      Screen.Monitors[MonitorIndex].Top + Top,
      Form.Width, Form.Height);
  end;
end;

procedure TfrmImage.Init;
begin
  frmImage.Left := Screen.Monitors[Screen.MonitorCount - 1].Left;
  with frmConfig do begin
    DelayTime := IntegerItems['ImageView.DelayTime'];
    frmImage.Top := IntegerItems['ImageView.Top'];
    frmImage.Left := IntegerItems['ImageView.Left'];
    frmImage.Width := IntegerItems['ImageView.Width'];
    frmImage.Height := IntegerItems['ImageView.Height'];
    frmImage.Color := StringToColor(StringItems['ImageView.BackgroundColor']);
    ProgressBarRemaining.BackgroundColor := frmImage.Color;
    ProgressBarRemaining.BarColor := StringToColor(StringItems['ImageView.ForegroundColor']);
    LabelSignature.Font.Color := ProgressBarRemaining.BarColor;
    LabelSignature.Font.Size := IntegerItems['ImageView.SignatureFontSize'];
    LabelSignature.Font.Name := StringItems['ImageView.SignatureFontName'];
    LabelSignature.Color := frmImage.Color;
  end;
end;

procedure TfrmImage.FormResize(Sender: TObject);
begin
  ImagePresentation.Width := Self.Width;
  ImagePresentation.Height := Self.Height - ProgressBarRemaining.Height;
  ProgressBarRemaining.Top := ImagePresentation.Height;
  LabelSignature.Top := ImagePresentation.Height - LabelSignature.Height - 50;
end;

procedure TfrmImage.TimerHideTimer(Sender: TObject);
begin
  Dec(LeftTime, TimerHide.Interval);
  ProgressBarRemaining.Position := Round(LeftTime / DelayTime * 100);
  if LeftTime <= 0 then begin
    TimerHide.Enabled := False;
    Hide;
  end;
end;

procedure TfrmImage.Display;
begin
  ProgressBarRemaining.Position := 100;
  LeftTime := DelayTime;
  TimerHide.Enabled := True;
  Show;
  SetFormMonitor(Self, 1, frmConfig.IntegerItems['ImageView.Left'], frmConfig.IntegerItems['ImageView.Top']);
end;

end.
