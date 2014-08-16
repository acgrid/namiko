program NamikoDesktop;

uses
  Forms,
  Windows,
  CtrlForm in 'CtrlForm.pas' {frmControl},
  UDPHandleThread in 'UDPHandleThread.pas',
  RenderThread in 'RenderThread.pas',
  UpdateThread in 'UpdateThread.pas',
  DispatchThread in 'DispatchThread.pas',
  HTTPWorker in 'HTTPWorker.pas',
  SetupForm in 'SetupForm.pas' {FormDimSet},
  HexieForm in 'HexieForm.pas' {frmWordList};

{$R *.res}

begin
  SetWindowLong(Application.Handle,GWL_EXSTYLE,WS_EX_TOOLWINDOW);
  {$IFDEF DEBUG}ReportMemoryLeaksOnShutdown := DebugHook<>0;{$ENDIF}
  Application.Initialize;
  Application.Title := 'NamikoÊµÊ±µ¯Ä»';
  Application.CreateForm(TfrmControl, frmControl);
  Application.CreateForm(TFormDimSet, FormDimSet);
  Application.CreateForm(TfrmWordList, frmWordList);
  Application.Run;
end.
