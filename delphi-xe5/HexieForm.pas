unit HexieForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, PerlRegEx, NamikoTypes;

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
    procedure ReportLog(Info: string; Level: TLogType = logInfo);
  public
    { Public declarations }
    function Hexied(Content: string): Boolean;
  end;

var
  frmWordList: TfrmWordList;

implementation

{$R *.dfm}
uses
  HTTPWorker, LogForm, CtrlForm;

procedure TfrmWordList.FormCreate(Sender: TObject);
begin
  try
    HexieList.Lines.LoadFromFile(APP_DIR + 'HexieList.txt');
    ReportLog('读取和谐列表');
  except
    ReportLog('和谐列表为空');
  end;
  HexieMutex.Release;
end;

procedure TfrmWordList.btnDoneClick(Sender: TObject);
begin
  try
    HexieList.Lines.SaveToFile(APP_DIR+'HexieList.txt');
    if Assigned(frmControl.HThread) then begin
      HexieMutex.Acquire;
      try
        frmControl.HThread.HexieList.Text := HexieList.Lines.Text;
      finally
        HexieMutex.Release;
      end;
    end;
  except
    on E: Exception do begin
      ReportLog('和谐列表保存异常: ' + E.Message, logException);
      Application.MessageBox('数据保存失败。','杯具了',MB_ICONERROR);
    end;
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

function TfrmWordList.Hexied(Content: string): Boolean;
var
  i : Integer;
begin
  Result := False;
  Hexier := TPerlRegEx.Create();
  try
    try
      Hexier.Subject := UTF8Encode(Content);
      for i := 0 to HexieList.Lines.Count - 1 do begin
        Hexier.RegEx := UTF8Encode(HexieList.Lines.Strings[i]);
        if Hexier.Match then begin
          Result := True;
          Exit;
        end;
      end;
    except
      on E: Exception do begin
        ReportLog('正则表达式错误：' + E.Message, logException);
      end;
    end;
  finally
    Hexier.Free;
  end;
end;

procedure TfrmWordList.btnPCRETestClick(Sender: TObject);
begin
  if Hexied(EditTestSubject.Text) then begin
    LblTestResult.Caption := '不和谐';
    LblTestResult.Font.Color := clRed;
  end
  else begin
    LblTestResult.Caption := '很和谐';
    LblTestResult.Font.Color := clGreen;
  end;
end;


procedure TfrmWordList.ReportLog(Info: string; Level: TLogType = logInfo);
begin
  frmLog.LogAdd(Info, '和谐', Level);
end;


end.
