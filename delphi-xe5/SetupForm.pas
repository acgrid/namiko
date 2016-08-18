unit SetupForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormDimSet = class(TForm)
    ButtonCommit: TButton;
    ButtonDiscard: TButton;
    EditWidth: TLabeledEdit;
    EditHeight: TLabeledEdit;
    EditLeft: TLabeledEdit;
    EditTop: TLabeledEdit;
    RadioTarget: TRadioGroup;
    LabelNotice: TLabel;
    procedure FormShow(Sender: TObject);
    procedure RadioTargetClick(Sender: TObject);
    procedure ButtonCommitClick(Sender: TObject);
    procedure ButtonDiscardClick(Sender: TObject);
  private
    { Private declarations }
    RWWidth, RWHeight, RWTop, RWLeft, RCTop, RCLeft: Integer;
  public
    { Public declarations }
  end;

var
  FormDimSet: TFormDimSet;

implementation

uses
  CfgForm, CtrlForm;

{$R *.dfm}

procedure TFormDimSet.ButtonCommitClick(Sender: TObject);
begin
  with frmControl do begin
    case RadioTarget.ItemIndex of
      0: begin
        CCWinPos.Width := StrToInt(EditWidth.Text);
        CCWinPos.Height := StrToInt(EditHeight.Text);
        CCWinPos.Left := StrToIntDef(EditLeft.Text,0);
        CCWinPos.Top := StrToIntDef(EditTop.Text,0);
        Self.Hide;
      end;
      1: begin
        MTitleLeft := StrToIntDef(EditLeft.Text,0);
        MTitleTop := StrToIntDef(EditTop.Text,0);
        UpdateCaption;
      end;
    end;
  end;
end;

procedure TFormDimSet.ButtonDiscardClick(Sender: TObject);
begin
  with frmControl do begin
    CCWinPos.Width := RWWidth;
    CCWinPos.Height := RWHeight;
    CCWinPos.Left := RWLeft;
    CCWinPos.Top := RWTop;
    MTitleLeft := RCLeft;
    MTitleTop := RCTop;
    UpdateCaption;
  end;
  Self.Hide;
end;

procedure TFormDimSet.FormShow(Sender: TObject);
begin
  with frmControl do begin
    RWWidth := CCWinPos.Width;
    RWHeight := CCWinPos.Height;
    RWLeft := CCWinPos.Left;
    RWTop := CCWinPos.Top;
    RCLeft := MTitleLeft;
    RCTop := MTitleTop;

    EditWidth.Text := IntToStr(RWWidth);
    EditHeight.Text := IntToStr(RWHeight);
    EditLeft.Text := IntToStr(RWLeft);
    EditTop.Text := IntToStr(RWTop);
  end;
end;

procedure TFormDimSet.RadioTargetClick(Sender: TObject);
begin
  case RadioTarget.ItemIndex of
    0: begin
      EditWidth.Text := IntToStr(RWWidth);
      EditHeight.Text := IntToStr(RWHeight);
      EditWidth.Enabled := True;
      EditHeight.Enabled := True;
      EditLeft.Text := IntToStr(RWLeft);
      EditTop.Text := IntToStr(RCTop);
    end;
    1: begin
      EditWidth.Text := '';
      EditHeight.Text := '';
      EditWidth.Enabled := False;
      EditHeight.Enabled := False;
      EditLeft.Text := IntToStr(RCLeft);
      EditTop.Text := IntToStr(RCTop);
    end;
  end;
end;

end.
