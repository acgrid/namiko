program RTProgram;

uses
  Vcl.Forms,
  UnitControl in 'UnitControl.pas' {frmControl},
  ProgramTypes in 'ProgramTypes.pas',
  LiveWindow in 'LiveWindow.pas',
  InfoWindow in 'InfoWindow.pas',
  CfgForm in 'CfgForm.pas' {frmConfig},
  Configuration in 'Configuration.pas',
  UnitServer in 'UnitServer.pas',
  UnitWebUI in 'UnitWebUI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmControl, frmControl);
  Application.CreateForm(TfrmConfig, frmConfig);
  Application.Run;
end.
