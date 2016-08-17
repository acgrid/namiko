unit Configuration;

interface

uses Vcl.Forms, System.SysUtils, System.Generics.Collections, IniFiles;

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

procedure LoadSettings();
procedure SaveSettings();

function GetCfgString(const Key: string): string;
function GetCfgBoolean(const Key: string): Boolean;
function GetCfgInteger(const Key: string): Integer;
procedure SetCfgString(const Key: string; Value: string);
procedure SetCfgBoolean(const Key: string; Value: Boolean);
procedure SetCfgInteger(const Key: string; Value: Integer);

var
  MyConfig: TConfigurationPool;
  ConfigDict: TConfigurationDict;
  CfgFile: TFileName;

implementation
var
  SaveOnExit: Boolean;

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
    raise Exception.Create(Format('尝试为配置项 %s 设置数值 %d 失败，允许最小值为 %d',[FullKey, AValue, FMinValue]))
  else if AValue > FMaxValue then
    raise Exception.Create(Format('尝试为配置项 %s 设置数值 %d 失败，允许最大值为 %d',[FullKey, AValue, FMaxValue]))
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

function GetCfgString(const Key: string): string;
begin
  if ConfigDict.ContainsKey(Key) then
    Result := TStringConfiguration(ConfigDict.Items[Key]).Value
  else
    raise Exception.Create('获取不存在的配置项 '+ Key);
end;

function GetCfgBoolean(const Key: string): Boolean;
begin
  if ConfigDict.ContainsKey(Key) then
    Result := TBooleanConfiguration(ConfigDict.Items[Key]).Value
  else
    raise Exception.Create('获取不存在的配置项 '+ Key);
end;

function GetCfgInteger(const Key: string): Integer;
begin
  if ConfigDict.ContainsKey(Key) then
    Result := TIntegerConfiguration(ConfigDict.Items[Key]).Value
  else
    raise Exception.Create('获取不存在的配置项 '+ Key);
end;

procedure SetCfgString(const Key: string; Value: string);
begin
  TStringConfiguration(ConfigDict.Items[Key]).Value := Value;
end;

procedure SetCfgBoolean(const Key: string; Value: Boolean);
begin
  TBooleanConfiguration(ConfigDict.Items[Key]).Value := Value;
end;

procedure SetCfgInteger(const Key: string; Value: Integer);
begin
  TIntegerConfiguration(ConfigDict.Items[Key]).Value := Value;
end;

procedure LoadSettings();
var
  Ini: TIniFile;
  Cfg: TConfiguration;
begin
  Ini := TINIFile.Create(CfgFile);
  try
    for Cfg in MyConfig do begin
      Cfg.ReadFromINI(Ini);
      if not ConfigDict.ContainsKey(Cfg.FullKey) then ConfigDict.Add(Cfg.FullKey, Cfg);
    end;
    SaveOnExit := TBooleanConfiguration(ConfigDict.Items['Debug.SaveOnExit']).Value;
  finally
    Ini.Free;
  end;
end;

procedure SaveSettings();
var
  Ini: TIniFile;
  Cfg: TConfiguration;
begin
  Ini := TINIFile.Create(CfgFile);
  try
    for Cfg in MyConfig do Cfg.WriteToINI(Ini);
  finally
    Ini.Free;
  end;
end;

initialization
  CfgFile := ExtractFilePath(Application.ExeName) + 'RTPROG.ini';
  ConfigDict := TConfigurationDict.Create();
  MyConfig := TConfigurationPool.Create();
  MyConfig.Add(TStringConfiguration.Create('InfoWindow','FontName','信息窗口字体','SimHei'));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','FontSize','信息窗口字号',22,8,100,2));
  MyConfig.Add(TStringConfiguration.Create('InfoWindow','FontColor','信息窗口颜色','clGreen'));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','FontStyle','信息窗口字形，目前支持0=常规，1=加粗',0,0,1,1));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','Duration','信息窗口节目介绍显示时长(ms)',3000,1000,10000,100));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','Opacity','信息窗口文字透明度',255,0,255,1));
  MyConfig.Add(TStringConfiguration.Create('InfoWindow','LogoFile','信息窗口LOGO路径',''));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','LogoLeft','信息窗口LOGO 百分比X坐标',85,0,100,1));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','LogoTop','信息窗口LOGO 百分比Y坐标',15,0,100,1));

  MyConfig.Add(TStringConfiguration.Create('LiveWindow','FontName','直播窗口字体','SimHei'));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','FontSize','直播窗口字号',48,8,100,2));
  MyConfig.Add(TStringConfiguration.Create('LiveWindow','FontColor','直播窗口颜色','clBlue'));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','FontStyle','直播窗口字形，目前支持0=常规，1=加粗',0,0,1,1));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','Duration','直播窗口节目介绍显示时长',5000,1000,10000,100));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','Opacity','直播窗口不透明度',255,0,255,1));
  MyConfig.Add(TStringConfiguration.Create('LiveWindow','LogoFile','直播窗口LOGO路径',''));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','LogoLeft','直播窗口LOGO 百分比X坐标',85,0,100,1));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','LogoTop','直播窗口LOGO 百分比Y坐标',15,0,100,1));

  MyConfig.Add(TIntegerConfiguration.Create('Connection','Mode','通讯模式。0 = 主控 1 = 主控+信息窗口 2 = 主控+直播窗口 3 = 本地运行 4 = 信息窗口远程 5 => 直播窗口远程',1,0,5,1));
  MyConfig.Add(TStringConfiguration.Create('Connection','Host','TCP监听绑定/远程连接主机','0.0.0.0'));
  MyConfig.Add(TIntegerConfiguration.Create('Connection','Port','TCP监听/远程连接端口',20000,1,65535,1));

  MyConfig.Add(TStringConfiguration.Create('Startup','LastJSON','最近使用的JSON节目单',''));
  MyConfig.Add(TIntegerConfiguration.Create('Startup','LastSession','最近打开的场次', 0, 0, 65535, 1));

  MyConfig.Add(TStringConfiguration.Create('FB2K','URL','foobar2000 WebUI地址','http://127.0.0.1:8888/default/'));
  MyConfig.Add(TStringConfiguration.Create('FB2K','ExePath','foobar2000 启动路径',''));

  MyConfig.Add(TStringConfiguration.Create('MPCHC','URL','MPC-HC WebUI地址','http://127.0.0.1:8700/'));
  MyConfig.Add(TStringConfiguration.Create('MPCHC','ExePath','MPC-HC 启动路径',''));
  MyConfig.Add(TStringConfiguration.Create('MPCHC','WindowTitle','MPC-HC 窗口标题','Media Player Classic Home Cinema'));
  MyConfig.Add(TStringConfiguration.Create('MPCHC','Wallpaper','默认壁纸路径',''));

  MyConfig.Add(TIntegerConfiguration.Create('HTTP','ConnTimeout','HTTP连接超时(ms)',500,100,1000,100));
  MyConfig.Add(TIntegerConfiguration.Create('HTTP','RecvTimeout','HTTP接收超时(ms)',500,100,2000,100));
  MyConfig.Add(TIntegerConfiguration.Create('HTTP','RetryDelay','HTTP超时重试间隔(ms)',5000,500,60000,100));

  MyConfig.Add(TIntegerConfiguration.Create('Display','InfoWindowMonitor','信息窗口显示器索引',1,0,10,1));
  MyConfig.Add(TIntegerConfiguration.Create('Display','LiveWindowWidth','直播窗口宽度',1920,50,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('Display','LiveWindowHeight','直播窗口高度',1080,50,99999,10));

  MyConfig.Add(TIntegerConfiguration.Create('Display','BufferLength','渲染缓冲区大小(ms)',2000,200,6000,100));
  MyConfig.Add(TIntegerConfiguration.Create('Display','ReferenceFPS','参考帧率(fps)',24,5,60,1));
  MyConfig.Add(TIntegerConfiguration.Create('Display','MinInterval','最小刷新间隔(ms)',5,1,1000,5));
  MyConfig.Add(TIntegerConfiguration.Create('Display','MaxInterval','最大刷新间隔(ms)',100,1,1000,5));

  MyConfig.Add(TIntegerConfiguration.Create('Render','BorderWidth','文本描边大小',2,0,5,1));
  MyConfig.Add(TStringConfiguration.Create('Render','BorderColor','文本描边颜色','#FF000000'));
  MyConfig.Add(TIntegerConfiguration.Create('Render','HeightZoom','文本高度/字号比例(%)，0为自动测量',0,0,150,10));

  MyConfig.Add(TStringConfiguration.Create('ImageView','BackgroundColor','图片显示背景颜色','clBlack'));
  MyConfig.Add(TStringConfiguration.Create('ImageView','ForegroundColor','图片显示前景颜色','clWhite'));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','DelayTime','图片显示时间(ms)',5000,100,30000,100));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Left','图片显示顶点X坐标',0,-99999,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Top','图片显示顶点Y坐标',0,-99999,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Width','图片显示宽度',640,1,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Height','图片显示高度',480,1,99999,10));

  MyConfig.Add(TBooleanConfiguration.Create('Debug','GeneralLogFile','自动输出日志到文件',{$IFDEF DEBUG}True{$ELSE}False{$ENDIF}));
  MyConfig.Add(TBooleanConfiguration.Create('Debug','HTTPLogFile','转储HTTP请求到文件',{$IFDEF DEBUG}True{$ELSE}False{$ENDIF}));
  MyConfig.Add(TBooleanConfiguration.Create('Debug','SaveOnExit','退出时保存设置',{$IFDEF DEBUG}False{$ELSE}True{$ENDIF}));
  LoadSettings();

finalization
  if SaveOnExit then SaveSettings;
  ConfigDict.Free;
  MyConfig.Free;

end.
