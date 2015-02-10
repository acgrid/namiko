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
  HexieForm in 'HexieForm.pas' {frmWordList},
  LogForm in 'LogForm.pas' {frmLog},
  CfgForm in 'CfgForm.pas' {frmConfig},
  DemoForm in 'DemoForm.pas' {frmDemo},
  NamikoTypes in 'NamikoTypes.pas';

{$R *.res}

begin
  SetWindowLong(Application.Handle,GWL_EXSTYLE,WS_EX_TOOLWINDOW);
  {$IFDEF DEBUG}ReportMemoryLeaksOnShutdown := DebugHook<>0;{$ENDIF}
  Application.Initialize;
  Application.Title := 'Namiko Danmaku Client';
  Application.CreateForm(TfrmLog, frmLog);
  Application.CreateForm(TfrmConfig, frmConfig);
  Application.CreateForm(TfrmWordList, frmWordList);
  Application.CreateForm(TfrmDemo, frmDemo);
  Application.CreateForm(TfrmControl, frmControl);
  Application.Run;
end.
