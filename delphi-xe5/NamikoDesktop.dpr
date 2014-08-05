program NamikoDesktop;

uses
  Forms,
  Windows,
  CtrlForm in 'CtrlForm.pas' {frmControl},
  CCommentForm in 'CCommentForm.pas' {frmComment},
  HexieForm in 'HexieForm.pas' {frmWordList},
  XMLLoadForm in 'XMLLoadForm.pas' {frmLoadXML};

{$R *.res}

begin
  SetWindowLong(Application.Handle,GWL_EXSTYLE,WS_EX_TOOLWINDOW);
  Application.Initialize;
  Application.Title := 'NamikoÊµÊ±µ¯Ä»';
  Application.CreateForm(TfrmControl, frmControl);
  Application.CreateForm(TfrmComment, frmComment);
  Application.CreateForm(TfrmWordList, frmWordList);
  Application.CreateForm(TfrmLoadXML, frmLoadXML);
  Application.Run;
end.
