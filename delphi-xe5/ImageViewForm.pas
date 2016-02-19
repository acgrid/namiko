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

implementation

uses
  JPEGUtils, CfgForm;

{$R *.dfm}

procedure TfrmImage.FormCreate(Sender: TObject);
begin
  Init;
end;

procedure TfrmImage.Init;
begin
  with frmConfig do begin
    DelayTime := IntegerItems['ImageView.DelayTime'];
    frmImage.Left := IntegerItems['ImageView.Left'];
    frmImage.Top := IntegerItems['ImageView.Top'];
    frmImage.Width := IntegerItems['ImageView.Width'];
    frmImage.Height := IntegerItems['ImageView.Height'];
    frmImage.Color := StringToColor(StringItems['ImageView.BackgroundColor']);
    ProgressBarRemaining.BackgroundColor := Color;
    ProgressBarRemaining.BarColor := StringToColor(StringItems['ImageView.ForegroundColor']);
    LabelSignature.Color := ProgressBarRemaining.BarColor;
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
end;

end.
