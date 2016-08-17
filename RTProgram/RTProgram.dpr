program RTProgram;

uses
  Vcl.Forms,
  UnitControl in 'UnitControl.pas' {frmControl},
  ProgramTypes in 'ProgramTypes.pas',
  InfoWindow in 'InfoWindow.pas',
  CfgForm in 'CfgForm.pas' {frmConfig},
  Configuration in 'Configuration.pas',
  UnitWebUI in 'UnitWebUI.pas',
  UnitClient in 'UnitClient.pas',
  LiveWindow in 'LiveWindow.pas' {frmLiveWindow};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmControl, frmControl);
  Application.CreateForm(TfrmConfig, frmConfig);
  Application.Run;
end.
