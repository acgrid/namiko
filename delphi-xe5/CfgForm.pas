unit CfgForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ValEdit, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls, System.Generics.Collections, IniFiles, NamikoTypes, Math,
  Vcl.Buttons;

type
  TConfiguration = class(TObject)
    protected
      FGroup: string;
      FKey: string;
      FDescription: string;
    public
      function GetFullKey(): string;
      function GetString(): string; virtual; abstract;
      property Group: string read FGroup;
      property Key: string read FKey;
      property FullKey: string read GetFullKey;
      property PlainValue: string read GetString;
      property Description: string read FDescription;
      constructor Create(Group, Key, Description: string); virtual;
      procedure ReadFromINI(AIniFile: TIniFile); virtual; abstract;
      procedure WriteToINI(AIniFile: TIniFile); virtual; abstract;
  end;

type
  TConfigurationPool = TObjectList<TConfiguration>;

type
  TConfigurationDict = TDictionary<string, TConfiguration>;

type
  TStringConfiguration = class(TConfiguration)
    protected
      FDefault: string;
      FValue: string;
    public
      function GetString(): string; override;
      property DefaultValue: string read FDefault;
      property Value: string read FValue write FValue;
      constructor Create(Group, Key, Description: string); overload; override;
      constructor Create(Group, Key, Description, Default: string); reintroduce; overload;
      procedure ReadFromINI(AIniFile: TIniFile); override;
      procedure WriteToINI(AIniFile: TIniFile); override;
  end;

type
  TBooleanConfiguration = class(TConfiguration)
    protected
      FDefault: Boolean;
      FValue: Boolean;
    public
      function GetString(): string; override;
      property DefaultValue: Boolean read FDefault;
      property Value: Boolean read FValue write FValue;
      constructor Create(Group, Key, Description: string); overload; override;
      constructor Create(Group, Key, Description: string; Default: Boolean); reintroduce; overload;
      procedure ReadFromINI(AIniFile: TIniFile); override;
      procedure WriteToINI(AIniFile: TIniFile); override;
  end;

type
  PBooleanConfiguration = ^TBooleanConfiguration;

type
  TIntegerConfiguration = class(TConfiguration)
    protected
      FDefault: Integer;
      FMinValue: Integer;
      FMaxValue: Integer;
      FStepValue: Integer;
      FValue: Integer;
    public
      procedure SetValue(const AValue: Integer);
      function GetString(): string; override;
      property DefaultValue: Integer read FDefault;
      property MinValue: Integer read FMinValue write FMinValue;
      property MaxValue: Integer read FMaxValue write FMaxValue;
      property StepValue: Integer read FStepValue write FStepValue;
      property Value: Integer read FValue write SetValue;
      constructor Create(Group, Key, Description: string); overload; override;
      constructor Create(Group, Key, Description: string; Default, MinValue, MaxValue, StepValue: Integer); reintroduce; overload;
      procedure ReadFromINI(AIniFile: TIniFile); override;
      procedure WriteToINI(AIniFile: TIniFile); override;
  end;

type
  TfrmConfig = class(TForm)
    ValueListEditor: TValueListEditor;
    GroupEdit: TGroupBox;
    LabelDescription: TLabel;
    LabelNewValue: TLabel;
    EditString: TEdit;
    BtnSave: TButton;
    UpDownInteger: TUpDown;
    EditInteger: TEdit;
    RadioGroupBoolean: TRadioGroup;
    BtnReload: TButton;
    BtnConfirm: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ValueListEditorClick(Sender: TObject);
    procedure BtnConfirmClick(Sender: TObject);
    procedure BtnReloadClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
  private
    { Private declarations }
    MyConfig: TConfigurationPool;
    ConfigDict: TConfigurationDict;
    ShownIndex: Integer;
    CfgFile: TFileName;
  public
    { Public declarations }
    procedure Initialize();
    procedure Save();
    procedure ReportLog(Info: string; Level: TLogType = logInfo);
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

uses LogForm, CtrlForm;

{$R *.dfm}

constructor TConfiguration.Create(Group: string; Key: string; Description: string);
begin
  FGroup := Group;
  FKey := Key;
  FDescription := Description;
end;

function TConfiguration.GetFullKey(): string;
begin
  Result := Self.FGroup + '.' + Self.FKey;
end;

constructor TStringConfiguration.Create(Group: string; Key: string; Description: string);
begin
  inherited Create(Group, Key, Description);
  FDefault := '';
end;

constructor TStringConfiguration.Create(Group, Key, Description, Default: string);
begin
  inherited Create(Group, Key, Description);
  FDefault := Default;
end;

function TStringConfiguration.GetString(): string;
begin
  Result := FValue;
end;

procedure TStringConfiguration.ReadFromINI(AIniFile: TIniFile);
begin
  FValue := AIniFile.ReadString(FGroup, FKey, FDefault);
end;

procedure TStringConfiguration.WriteToINI(AIniFile: TIniFile);
begin
  AIniFile.WriteString(FGroup, FKey, FValue);
end;

constructor TBooleanConfiguration.Create(Group: string; Key: string; Description: string);
begin
  inherited Create(Group, Key, Description);
  FDefault := False;
end;

constructor TBooleanConfiguration.Create(Group, Key, Description: string; Default: Boolean);
begin
  inherited Create(Group, Key, Description);
  FDefault := Default;
end;

function TBooleanConfiguration.GetString(): string;
begin
  Result := BoolToStr(FValue, True);
end;

procedure TBooleanConfiguration.ReadFromINI(AIniFile: TIniFile);
begin
  FValue := AIniFile.ReadBool(FGroup, FKey, FDefault);
end;

procedure TBooleanConfiguration.WriteToINI(AIniFile: TIniFile);
begin
  AIniFile.WriteBool(FGroup, FKey, FValue);
end;

constructor TIntegerConfiguration.Create(Group: string; Key: string; Description: string);
begin
  inherited Create(Group, Key, Description);
  FDefault := 0;
end;

constructor TIntegerConfiguration.Create(Group, Key, Description: string; Default, MinValue, MaxValue, StepValue: Integer);
begin
  inherited Create(Group, Key, Description);
  FDefault := Default;
  FMinValue := MinValue;
  FMaxValue := MaxValue;
  FStepValue := StepValue;
end;

procedure TIntegerConfiguration.SetValue(const AValue: Integer);
begin
  if AValue < FMinValue then
    frmConfig.ReportLog(Format('尝试为配置项 %s 设置数值 %d 失败，允许最小值为 %d',[FullKey, AValue, FMinValue]),logWarning)
  else if AValue > FMaxValue then
    frmConfig.ReportLog(Format('尝试为配置项 %s 设置数值 %d 失败，允许最大值为 %d',[FullKey, AValue, FMaxValue]),logWarning)
  else
    FValue := AValue;
end;

function TIntegerConfiguration.GetString(): string;
begin
  Result := IntToStr(FValue);
end;

procedure TIntegerConfiguration.ReadFromINI(AIniFile: TIniFile);
begin
  FValue := AIniFile.ReadInteger(FGroup, FKey, FDefault);
end;

procedure TIntegerConfiguration.WriteToINI(AIniFile: TIniFile);
begin
  AIniFile.WriteInteger(FGroup, FKey, FValue);
end;

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
  Initialize;
end;

procedure TfrmConfig.BtnSaveClick(Sender: TObject);
begin
  Save;
  frmControl.LoadSetting;
  frmControl.ReloadControls;
  Self.Hide;
end;

procedure TfrmConfig.FormCreate(Sender: TObject);
begin
  CfgFile := APP_DIR + 'Settings.ini';
  ConfigDict := TConfigurationDict.Create();
  MyConfig := TConfigurationPool.Create();
  MyConfig.Add(TStringConfiguration.Create('NetComment','FontName','网络弹幕默认字体','SimHei'));
  MyConfig.Add(TIntegerConfiguration.Create('NetComment','FontSize','网络弹幕默认字号',22,8,100,2));
  MyConfig.Add(TStringConfiguration.Create('NetComment','FontColor','网络弹幕默认颜色','clGreen'));
  MyConfig.Add(TIntegerConfiguration.Create('NetComment','FontStyle','网络弹幕默认字形，目前支持0=常规，1=加粗',0,0,1,1));
  MyConfig.Add(TIntegerConfiguration.Create('NetComment','Duration','网络弹幕默认时长(ms)',3000,1000,10000,100));
  MyConfig.Add(TIntegerConfiguration.Create('NetComment','Opacity','网络弹幕默认不透明度',255,0,255,1));
  MyConfig.Add(TStringConfiguration.Create('OfficialComment','FontName','官方弹幕字体','SimHei'));
  MyConfig.Add(TIntegerConfiguration.Create('OfficialComment','FontSize','官方弹幕字号',48,8,100,2));
  MyConfig.Add(TStringConfiguration.Create('OfficialComment','FontColor','官方弹幕颜色','clBlue'));
  MyConfig.Add(TIntegerConfiguration.Create('OfficialComment','FontStyle','官方弹幕字形，目前支持0=常规，1=加粗',0,0,1,1));
  MyConfig.Add(TIntegerConfiguration.Create('OfficialComment','Duration','官方弹幕时长(ms)',5000,1000,10000,100));
  MyConfig.Add(TIntegerConfiguration.Create('OfficialComment','Opacity','官方弹幕默认不透明度',255,0,255,1));
  MyConfig.Add(TIntegerConfiguration.Create('Connection','Mode','通讯模式。0 = UDP Passive 1 = HTTP Poll',1,0,1,1));
  MyConfig.Add(TIntegerConfiguration.Create('Connection','Port','UDP模式监听端口',20000,1,65535,1));
  MyConfig.Add(TStringConfiguration.Create('Connection','Key','已加密通讯密钥，请勿在此修改','61E075CEC8CCC9C8CC3455BE98A4BCC4'));
  MyConfig.Add(TStringConfiguration.Create('Connection','Host','HTTP模式请求页面，要求使用版本4格式(JSON)','http://localhost/fetchcomment.php'));
  MyConfig.Add(TBooleanConfiguration.Create('Connection','AutoStart','启动后自动开始通信',False));
  MyConfig.Add(TIntegerConfiguration.Create('HTTP','Interval','HTTP轮询间隔(ms)',1000,1000,10000,100));
  MyConfig.Add(TIntegerConfiguration.Create('HTTP','ConnTimeout','HTTP连接超时(ms)',3000,500,10000,100));
  MyConfig.Add(TIntegerConfiguration.Create('HTTP','RecvTimeout','HTTP接收超时(ms)',3000,500,10000,100));
  MyConfig.Add(TIntegerConfiguration.Create('HTTP','RetryDelay','HTTP超时重试间隔(ms)',5000,500,60000,100));
  MyConfig.Add(TIntegerConfiguration.Create('Pool','DispatchCycle','调度最大周期(ms)',5,0,1000,5));
  MyConfig.Add(TIntegerConfiguration.Create('Pool','DispatchSince','允许调度已过期弹幕秒数(s)',5,0,600,1));
  MyConfig.Add(TIntegerConfiguration.Create('Pool','NetDelay','网络弹幕延迟显示时间(ms)',4000,0,10000,1000));
  MyConfig.Add(TIntegerConfiguration.Create('Display','BufferLength','渲染缓冲区大小(ms)',2000,200,6000,100));
  MyConfig.Add(TIntegerConfiguration.Create('Display','WorkWindowLeft','弹幕窗口顶点X坐标',0,-99999,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('Display','WorkWindowTop','弹幕窗口顶点Y坐标',0,-99999,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('Display','WorkWindowWidth','弹幕窗口宽度',1024,50,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('Display','WorkWindowHeight','弹幕窗口高度',768,50,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('Display','ReferenceFPS','参考帧率(fps)',24,5,60,1));
  MyConfig.Add(TIntegerConfiguration.Create('Display','MinInterval','最小刷新间隔(ms)',5,1,1000,5));
  MyConfig.Add(TIntegerConfiguration.Create('Display','MaxInterval','最大刷新间隔(ms)',100,1,1000,5));
  MyConfig.Add(TIntegerConfiguration.Create('Display','MaxMovement','最大移动长度(px)',100,1,1000,5));
  MyConfig.Add(TIntegerConfiguration.Create('Display','HeightZoom','弹幕高度/字号比例(%)，0为自动测量',0,0,150,10));
  MyConfig.Add(TIntegerConfiguration.Create('Display','OverlayLimit','弹幕最大层数，1则禁止出现冲突',1,1,5,1));
  MyConfig.Add(TIntegerConfiguration.Create('Display','BorderWidth','弹幕描边大小',2,0,5,1));
  MyConfig.Add(TStringConfiguration.Create('Display','BorderColor','弹幕描边颜色','#FF000000'));
  MyConfig.Add(TStringConfiguration.Create('Title','Text','官方标题内容',''));
  MyConfig.Add(TIntegerConfiguration.Create('Title','Left','官方标题顶点X坐标',0,0,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('Title','Top','官方标题顶点Y坐标',0,0,99999,10));
  MyConfig.Add(TStringConfiguration.Create('Title','FontName','官方标题字体','SimHei'));
  MyConfig.Add(TIntegerConfiguration.Create('Title','FontSize','官方标题字号',22,8,100,2));
  MyConfig.Add(TStringConfiguration.Create('Title','FontColor','官方标题颜色','clRed'));
  MyConfig.Add(TStringConfiguration.Create('ImageView','BackgroundColor','图片显示背景颜色','clBlack'));
  MyConfig.Add(TStringConfiguration.Create('ImageView','ForegroundColor','图片显示前景颜色','clWhite'));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','DelayTime','图片显示时间(ms)',5000,100,30000,100));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Left','图片显示顶点X坐标',0,-99999,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Top','图片显示顶点Y坐标',0,-99999,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Width','图片显示宽度',640,1,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Height','图片显示高度',480,1,99999,10));
  MyConfig.Add(TStringConfiguration.Create('ImageView','SignatureFontName','图片签名字体','SimHei'));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','SignatureFontSize','图片签名字号',16,8,100,2));
  MyConfig.Add(TBooleanConfiguration.Create('Debug','GeneralLogFile','自动输出日志到文件',{$IFDEF DEBUG}True{$ELSE}False{$ENDIF}));
  MyConfig.Add(TBooleanConfiguration.Create('Debug','HTTPLogFile','转储HTTP请求到文件',{$IFDEF DEBUG}True{$ELSE}False{$ENDIF}));
  Initialize;
  ReportLog('读取配置完成');
end;

procedure TfrmConfig.FormDestroy(Sender: TObject);
begin
  Save;
  MyConfig.Free;
  ConfigDict.Free;
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

procedure TfrmConfig.Initialize;
var
  Cfg: TConfiguration;
  Ini: TIniFile;
begin
  // Collect
  Ini := TINIFile.Create(CfgFile);
  try
    ValueListEditor.Strings.Clear;
    // Read & Display
    for Cfg in MyConfig do begin
      Cfg.ReadFromINI(Ini);
      ValueListEditor.InsertRow(Cfg.FullKey, Cfg.PlainValue, True);
      if not ConfigDict.ContainsKey(Cfg.FullKey) then ConfigDict.Add(Cfg.FullKey, Cfg);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TfrmConfig.Save;
var
  Cfg: TConfiguration;
  Ini: TIniFile;
begin
  Ini := TINIFile.Create(CfgFile);
  try
    for Cfg in MyConfig do Cfg.WriteToINI(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TfrmConfig.ReportLog(Info: string; Level: TLogType = logInfo);
begin
  frmLog.LogAdd(Info, '配置', Level);
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
