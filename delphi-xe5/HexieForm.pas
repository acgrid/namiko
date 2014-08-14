unit HexieForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, PerlRegEx, ThreadTimer;

type
  TfrmWordList = class(TForm)
    HexieList: TMemo;
    btnDone: TButton;
    EditTestSubject: TEdit;
    btnPCRETest: TButton;
    LblDesc: TLabel;
    LblTestResult: TLabel;
    Hexie: TPerlRegEx;
    procedure FormCreate(Sender: TObject);
    procedure btnDoneClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnPCRETestClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Hexied(Content: WideString): Boolean;
  end;

var
  frmWordList: TfrmWordList;

implementation

{$R *.dfm}
uses
  CtrlForm;

procedure TfrmWordList.FormCreate(Sender: TObject);
begin
  try
    HexieList.Lines.LoadFromFile(APP_DIR+'HexieList.txt');
  except
    frmControl.LogEvent('河蟹列表读取不能，快喂东西。');
  end;
  //Nofify frmControl that all forms is loaded and can startup Networking
  with frmControl do begin
    SysReady := true;
    if chkAutoStartNet.Checked then btnNetStart.Click{$IFNDEF DEV} else Application.MessageBox('开始通信前，将收不到网络弹幕','提示',MB_ICONINFORMATION){$ENDIF};
  end;
end;

procedure TfrmWordList.btnDoneClick(Sender: TObject);
begin
  try
    HexieList.Lines.SaveToFile(APP_DIR+'HexieList.txt');
  except
    Application.MessageBox('数据保存失败。','杯具了',MB_ICONERROR);
  end;
  frmWordList.Hide;
end;

procedure TfrmWordList.FormResize(Sender: TObject);
begin
  HexieList.Width := Self.Width - 30;
  HexieList.Height := Self.Height - 140;
  EditTestSubject.Width := Self.Width - 170;
  btnPCRETest.Left := Self.Width - 155;
  LblTestResult.Left := Self.Width - 85;
  btnDone.Top := Self.Height - 70;
  btnDone.Left := (Self.Width - btnDone.Width) div 2;
end;

function TfrmWordList.Hexied(Content: WideString): Boolean;
var
  i : Integer;
begin
  Hexie.Subject := UTF8Encode(Content);
  Result := false;
  for i := 0 to HexieList.Lines.Count - 1 do begin
    Hexie.RegEx := UTF8Encode(HexieList.Lines.Strings[i]);
    if Hexie.Match then begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TfrmWordList.btnPCRETestClick(Sender: TObject);
begin
  if Hexied(EditTestSubject.Text) then begin
    LblTestResult.Caption := '被河蟹';
    LblTestResult.Font.Color := clRed;
  end
  else begin
    LblTestResult.Caption := '很好很和谐';
    LblTestResult.Font.Color := clGreen;
  end;
end;

end.
