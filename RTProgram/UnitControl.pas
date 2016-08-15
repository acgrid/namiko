unit UnitControl;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ValEdit, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdTCPServer, IdCmdTCPServer, System.Actions, Vcl.ActnList;

type
  TfrmControl = class(TForm)
    ListViewProgramList: TListView;
    BtnChooseJSON: TButton;
    ProgramValues: TValueListEditor;
    StatusValues: TValueListEditor;
    StatusBar: TStatusBar;
    TCPServer: TIdCmdTCPServer;
    BtnReloadJSON: TButton;
    GroupProgramData: TGroupBox;
    BtnShowInfo: TButton;
    GroupPlayControl: TGroupBox;
    BtnHideInfo: TButton;
    BtnPlay: TButton;
    BtnStop: TButton;
    BtnResetMPC: TButton;
    BtnResetFB2K: TButton;
    BtnConfig: TButton;
    BtnResetWindow: TButton;
    BtnExit: TButton;
    GroupControls: TGroupBox;
    ListSessions: TListBox;
    FileOpenJSON: TFileOpenDialog;
    ActionList: TActionList;
    ActionLoadJSON: TAction;
    ActionReloadJSON: TAction;
    ActionShowInfo: TAction;
    ActionHideInfo: TAction;
    ActionPlay: TAction;
    ActionStop: TAction;
    ActionResetMPC: TAction;
    ActionResetFB2K: TAction;
    ActionResetWindow: TAction;
    ActionShowConfig: TAction;
    ActionExit: TAction;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmControl: TfrmControl;

implementation

{$R *.dfm}

procedure TfrmControl.FormCreate(Sender: TObject);
begin
  ListSessions.ItemIndex := 0;
end;

procedure TfrmControl.FormResize(Sender: TObject);
begin
  ListViewProgramList.Width := Self.Width - 280;
  ListViewProgramList.Height := Self.Height - 240;
  ProgramValues.Left := Self.Width - 270;
  ProgramValues.Height := Self.Height - 70;
  ListSessions.Top := Self.Height - 225;
  GroupProgramData.Top := ListSessions.Top;
  GroupPlayControl.Top := Self.Height - 170;
  GroupControls.Top := ListSessions.Top;
  StatusValues.Top := ListSessions.Top;
  StatusValues.Width := Self.Width - 780;
end;

end.
