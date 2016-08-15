program RTProgram;

uses
  Vcl.Forms,
  UnitControl in 'UnitControl.pas' {frmControl},
  ProgramTypes in 'ProgramTypes.pas',
  LiveWindow in 'LiveWindow.pas',
  InfoWindow in 'InfoWindow.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmControl, frmControl);
  Application.Run;
end.
