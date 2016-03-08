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
  NamikoTypes in 'NamikoTypes.pas',
  ImageMgrForm in 'ImageMgrForm.pas' {frmImageManager},
  ImageViewForm in 'ImageViewForm.pas' {frmImage},
  MsgViewForm in 'MsgViewForm.pas' {frmMessages},
  HTTPImageWorker in 'HTTPImageWorker.pas',
  HTTPMsgWorker in 'HTTPMsgWorker.pas',
  JPEGUtils in 'JPEGUtils.pas';

{$R *.res}
var
  Mutex: THandle;

begin
  Mutex := CreateMutex(nil, true, 'namiko');
  try
    if GetLastError <> ERROR_ALREADY_EXISTS then begin
      SetWindowLong(Application.Handle,GWL_EXSTYLE,WS_EX_TOOLWINDOW);
      {$IFDEF DEBUG}ReportMemoryLeaksOnShutdown := DebugHook<>0;{$ENDIF}
      Application.Initialize;
      Application.Title := 'Namiko Danmaku Client';
      Application.CreateForm(TfrmLog, frmLog);
      Application.CreateForm(TfrmConfig, frmConfig);
      Application.CreateForm(TfrmImage, frmImage);
      Application.CreateForm(TfrmImageManager, frmImageManager);
      Application.CreateForm(TfrmMessages, frmMessages);
      Application.CreateForm(TfrmWordList, frmWordList);
      Application.CreateForm(TfrmDemo, frmDemo);
      Application.CreateForm(TfrmControl, frmControl);
      Application.Run;
    end
    else begin
      Application.MessageBox('另一个程序已经在运行。', '独占', MB_OK);
    end;
  finally
    ReleaseMutex(Mutex);
  end;
end.
