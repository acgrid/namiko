unit CfgForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ValEdit, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls, Math, Vcl.Buttons;

type
  TfrmConfig = class(TForm)
    ValueListEditor: TValueListEditor;
    GroupEdit: TGroupBox;
    LabelDescription: TLabel;
    LabelNewValue: TLabel;
    EditString: TEdit;
    UpDownInteger: TUpDown;
    EditInteger: TEdit;
    RadioGroupBoolean: TRadioGroup;
    BtnReload: TButton;
    BtnConfirm: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure ValueListEditorClick(Sender: TObject);
    procedure BtnConfirmClick(Sender: TObject);
    procedure BtnReloadClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    ShownIndex: Integer;
  public
    { Public declarations }
    procedure RenderEditor();
    function GetCfgString(const Key: string): string;
    function GetCfgBoolean(const Key: string): Boolean;
    function GetCfgInteger(const Key: string): Integer;
    procedure SetCfgString(const Key: string; Value: string);
    procedure SetCfgBoolean(const Key: string; Value: Boolean);
    procedure SetCfgInteger(const Key: string; Value: Integer);
    property StringItems[const Key: string]: string read GetCfgString write SetCfgString;
    property BooleanItems[const Key: string]: Boolean read GetCfgBoolean write SetCfgBoolean;
    property IntegerItems[const Key: string]: Integer read GetCfgInteger write SetCfgInteger;
  end;

var
  frmConfig: TfrmConfig;

implementation

uses UnitControl, Configuration;

{$R *.dfm}

procedure TfrmConfig.BtnConfirmClick(Sender: TObject);
var
  Cfg: TConfiguration;
  IntCfg: TIntegerConfiguration;
begin
  if (ShownIndex >= 0) and (ShownIndex < MyConfig.Count) then begin
    Cfg := MyConfig.Items[ShownIndex];
    if Cfg.ClassType = TStringConfiguration then begin
      TStringConfiguration(Cfg).Value := EditString.Text;
    end
    else if Cfg.ClassType = TBooleanConfiguration then begin
      TBooleanConfiguration(Cfg).Value := Boolean(RadioGroupBoolean.ItemIndex = 0);
    end
    else if Cfg.ClassType = TIntegerConfiguration then begin
      IntCfg := TIntegerConfiguration(Cfg);
      TIntegerConfiguration(Cfg).Value := StrToIntDef(EditInteger.Text, IntCfg.DefaultValue);
    end;
    ValueListEditor.Values[Cfg.FullKey] := Cfg.PlainValue;
  end;
end;

procedure TfrmConfig.BtnReloadClick(Sender: TObject);
begin
  LoadSettings();
  RenderEditor();
end;

procedure TfrmConfig.FormCreate(Sender: TObject);
begin
  RenderEditor;
  frmControl.Log('读取配置完成');
end;

procedure TfrmConfig.FormHide(Sender: TObject);
begin
  SaveSettings;
end;

function TfrmConfig.GetCfgString(const Key: string): string;
begin
  if ConfigDict.ContainsKey(Key) then
    Result := TStringConfiguration(ConfigDict.Items[Key]).Value
  else
    raise Exception.Create('获取不存在的配置项 '+ Key);
end;

function TfrmConfig.GetCfgBoolean(const Key: string): Boolean;
begin
  if ConfigDict.ContainsKey(Key) then
    Result := TBooleanConfiguration(ConfigDict.Items[Key]).Value
  else
    raise Exception.Create('获取不存在的配置项 '+ Key);
end;

function TfrmConfig.GetCfgInteger(const Key: string): Integer;
begin
  if ConfigDict.ContainsKey(Key) then
    Result := TIntegerConfiguration(ConfigDict.Items[Key]).Value
  else
    raise Exception.Create('获取不存在的配置项 '+ Key);
end;

procedure TfrmConfig.SetCfgString(const Key: string; Value: string);
begin
  TStringConfiguration(ConfigDict.Items[Key]).Value := Value;
end;

procedure TfrmConfig.SetCfgBoolean(const Key: string; Value: Boolean);
begin
  TBooleanConfiguration(ConfigDict.Items[Key]).Value := Value;
end;

procedure TfrmConfig.SetCfgInteger(const Key: string; Value: Integer);
begin
  TIntegerConfiguration(ConfigDict.Items[Key]).Value := Value;
end;

procedure TfrmConfig.RenderEditor;
var
  Cfg: TConfiguration;
begin
  for Cfg in MyConfig do begin
    ValueListEditor.InsertRow(Cfg.FullKey, Cfg.PlainValue, True);
  end;
end;

procedure TfrmConfig.ValueListEditorClick(Sender: TObject);
var
  Cfg: TConfiguration;
begin
  ShownIndex := ValueListEditor.Row - 1;
  if (ShownIndex >= 0) and (ShownIndex < MyConfig.Count) then begin
    Cfg := MyConfig.Items[ShownIndex];
    LabelDescription.Caption := Cfg.Description;
    if Cfg.ClassType = TStringConfiguration then begin
      EditInteger.Visible := False;
      UpDownInteger.Visible := False;
      RadioGroupBoolean.Visible := False;
      EditString.Visible := True;
      EditString.Text := TStringConfiguration(Cfg).Value;
    end
    else if Cfg.ClassType = TBooleanConfiguration then begin
      EditInteger.Visible := False;
      UpDownInteger.Visible := False;
      EditString.Visible := False;
      RadioGroupBoolean.Visible := True;
      RadioGroupBoolean.ItemIndex := IfThen(TBooleanConfiguration(Cfg).Value, 0, 1);
    end
    else if Cfg.ClassType = TIntegerConfiguration then begin
      EditString.Visible := False;
      RadioGroupBoolean.Visible := False;
      EditInteger.Visible := True;
      UpDownInteger.Visible := True;
      EditInteger.Text := Cfg.PlainValue;
      UpDownInteger.Min := TIntegerConfiguration(Cfg).MinValue;
      UpDownInteger.Max := TIntegerConfiguration(Cfg).MaxValue;
      UpDownInteger.Increment := TIntegerConfiguration(Cfg).StepValue;
      LabelDescription.Caption := LabelDescription.Caption + #13 +
        Format('最小值=%d 最大值=%d 常用增量=%d', [UpDownInteger.Min, UpDownInteger.Max, UpDownInteger.Increment]);
    end;
  end
  else ShownIndex := -1;
end;

end.
