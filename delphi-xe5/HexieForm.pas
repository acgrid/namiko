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
    procedure FormCreate(Sender: TObject);
    procedure btnDoneClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnPCRETestClick(Sender: TObject);
  private
    { Private declarations }
    Hexier: TPerlRegEx;
  public
    { Public declarations }
    function Hexied(Content: WideString): Boolean;
  end;

var
  frmWordList: TfrmWordList;
  HexieBuffer: string;

implementation

{$R *.dfm}
uses
  CtrlForm;

procedure TfrmWordList.FormCreate(Sender: TObject);
begin
  try
    HexieList.Lines.LoadFromFile(APP_DIR+'HexieList.txt');
    HexieBuffer := HexieList.Lines.Text;
  except
    frmControl.LogEvent('[PCRE] 和谐列表为空');
  end;
  HexieMutex.Release;
  //Nofify frmControl that all forms is loaded and can startup Networking
end;

procedure TfrmWordList.btnDoneClick(Sender: TObject);
begin
  try
    HexieList.Lines.SaveToFile(APP_DIR+'HexieList.txt');
    HexieMutex.Acquire;
    try
      HexieBuffer := HexieList.Lines.Text;
    finally
      HexieMutex.Release;
    end;
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
  Result := False;
  Hexier := TPerlRegEx.Create();
  try
    try
      Hexier.Subject := Content;
      for i := 0 to HexieList.Lines.Count - 1 do begin
        Hexier.RegEx := HexieList.Lines.Strings[i];
        if Hexier.Match then begin
          Result := True;
          Exit;
        end;
      end;
    except
      on E:Exception do begin
        frmControl.LogEvent('[PCRE] 正则表达式错误：'+E.Message);
      end;
    end;
  finally
    Hexier.Free;
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
