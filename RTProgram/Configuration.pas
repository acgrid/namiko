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
    raise Exception.Create(Format('����Ϊ������ %s ������ֵ %d ʧ�ܣ�������СֵΪ %d',[FullKey, AValue, FMinValue]))
  else if AValue > FMaxValue then
    raise Exception.Create(Format('����Ϊ������ %s ������ֵ %d ʧ�ܣ��������ֵΪ %d',[FullKey, AValue, FMaxValue]))
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
    raise Exception.Create('��ȡ�����ڵ������� '+ Key);
end;

function GetCfgBoolean(const Key: string): Boolean;
begin
  if ConfigDict.ContainsKey(Key) then
    Result := TBooleanConfiguration(ConfigDict.Items[Key]).Value
  else
    raise Exception.Create('��ȡ�����ڵ������� '+ Key);
end;

function GetCfgInteger(const Key: string): Integer;
begin
  if ConfigDict.ContainsKey(Key) then
    Result := TIntegerConfiguration(ConfigDict.Items[Key]).Value
  else
    raise Exception.Create('��ȡ�����ڵ������� '+ Key);
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
  MyConfig.Add(TStringConfiguration.Create('InfoWindow','FontName','��Ϣ��������','SimHei'));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','FontSize','��Ϣ�����ֺ�',22,8,100,2));
  MyConfig.Add(TStringConfiguration.Create('InfoWindow','FontColor','��Ϣ������ɫ','clGreen'));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','FontStyle','��Ϣ�������Σ�Ŀǰ֧��0=���棬1=�Ӵ�',0,0,1,1));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','Duration','��Ϣ���ڽ�Ŀ������ʾʱ��(ms)',3000,1000,10000,100));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','Opacity','��Ϣ��������͸����',255,0,255,1));
  MyConfig.Add(TStringConfiguration.Create('InfoWindow','LogoFile','��Ϣ����LOGO·��',''));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','LogoLeft','��Ϣ����LOGO �ٷֱ�X����',85,0,100,1));
  MyConfig.Add(TIntegerConfiguration.Create('InfoWindow','LogoTop','��Ϣ����LOGO �ٷֱ�Y����',15,0,100,1));

  MyConfig.Add(TStringConfiguration.Create('LiveWindow','FontName','ֱ����������','SimHei'));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','FontSize','ֱ�������ֺ�',48,8,100,2));
  MyConfig.Add(TStringConfiguration.Create('LiveWindow','FontColor','ֱ��������ɫ','clBlue'));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','FontStyle','ֱ���������Σ�Ŀǰ֧��0=���棬1=�Ӵ�',0,0,1,1));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','Duration','ֱ�����ڽ�Ŀ������ʾʱ��',5000,1000,10000,100));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','Opacity','ֱ�����ڲ�͸����',255,0,255,1));
  MyConfig.Add(TStringConfiguration.Create('LiveWindow','LogoFile','ֱ������LOGO·��',''));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','LogoLeft','ֱ������LOGO �ٷֱ�X����',85,0,100,1));
  MyConfig.Add(TIntegerConfiguration.Create('LiveWindow','LogoTop','ֱ������LOGO �ٷֱ�Y����',15,0,100,1));

  MyConfig.Add(TIntegerConfiguration.Create('Connection','Mode','ͨѶģʽ��0 = ���� 1 = ����+��Ϣ���� 2 = ����+ֱ������ 3 = �������� 4 = ��Ϣ����Զ�� 5 => ֱ������Զ��',1,0,5,1));
  MyConfig.Add(TStringConfiguration.Create('Connection','Host','TCP������/Զ����������','0.0.0.0'));
  MyConfig.Add(TIntegerConfiguration.Create('Connection','Port','TCP����/Զ�����Ӷ˿�',20000,1,65535,1));

  MyConfig.Add(TStringConfiguration.Create('Startup','LastJSON','���ʹ�õ�JSON��Ŀ��',''));
  MyConfig.Add(TIntegerConfiguration.Create('Startup','LastSession','����򿪵ĳ���', 0, 0, 65535, 1));

  MyConfig.Add(TStringConfiguration.Create('FB2K','URL','foobar2000 WebUI��ַ','http://127.0.0.1:8888/default/'));
  MyConfig.Add(TStringConfiguration.Create('FB2K','ExePath','foobar2000 ����·��',''));

  MyConfig.Add(TStringConfiguration.Create('MPCHC','URL','MPC-HC WebUI��ַ','http://127.0.0.1:8700/'));
  MyConfig.Add(TStringConfiguration.Create('MPCHC','ExePath','MPC-HC ����·��',''));
  MyConfig.Add(TStringConfiguration.Create('MPCHC','WindowTitle','MPC-HC ���ڱ���','Media Player Classic Home Cinema'));
  MyConfig.Add(TStringConfiguration.Create('MPCHC','Wallpaper','Ĭ�ϱ�ֽ·��',''));

  MyConfig.Add(TIntegerConfiguration.Create('HTTP','ConnTimeout','HTTP���ӳ�ʱ(ms)',500,100,1000,100));
  MyConfig.Add(TIntegerConfiguration.Create('HTTP','RecvTimeout','HTTP���ճ�ʱ(ms)',500,100,2000,100));
  MyConfig.Add(TIntegerConfiguration.Create('HTTP','RetryDelay','HTTP��ʱ���Լ��(ms)',5000,500,60000,100));

  MyConfig.Add(TIntegerConfiguration.Create('Display','InfoWindowMonitor','��Ϣ������ʾ������',1,0,10,1));
  MyConfig.Add(TIntegerConfiguration.Create('Display','LiveWindowWidth','ֱ�����ڿ��',1920,50,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('Display','LiveWindowHeight','ֱ�����ڸ߶�',1080,50,99999,10));

  MyConfig.Add(TIntegerConfiguration.Create('Display','BufferLength','��Ⱦ��������С(ms)',2000,200,6000,100));
  MyConfig.Add(TIntegerConfiguration.Create('Display','ReferenceFPS','�ο�֡��(fps)',24,5,60,1));
  MyConfig.Add(TIntegerConfiguration.Create('Display','MinInterval','��Сˢ�¼��(ms)',5,1,1000,5));
  MyConfig.Add(TIntegerConfiguration.Create('Display','MaxInterval','���ˢ�¼��(ms)',100,1,1000,5));

  MyConfig.Add(TIntegerConfiguration.Create('Render','BorderWidth','�ı���ߴ�С',2,0,5,1));
  MyConfig.Add(TStringConfiguration.Create('Render','BorderColor','�ı������ɫ','#FF000000'));
  MyConfig.Add(TIntegerConfiguration.Create('Render','HeightZoom','�ı��߶�/�ֺű���(%)��0Ϊ�Զ�����',0,0,150,10));

  MyConfig.Add(TStringConfiguration.Create('ImageView','BackgroundColor','ͼƬ��ʾ������ɫ','clBlack'));
  MyConfig.Add(TStringConfiguration.Create('ImageView','ForegroundColor','ͼƬ��ʾǰ����ɫ','clWhite'));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','DelayTime','ͼƬ��ʾʱ��(ms)',5000,100,30000,100));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Left','ͼƬ��ʾ����X����',0,-99999,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Top','ͼƬ��ʾ����Y����',0,-99999,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Width','ͼƬ��ʾ���',640,1,99999,10));
  MyConfig.Add(TIntegerConfiguration.Create('ImageView','Height','ͼƬ��ʾ�߶�',480,1,99999,10));

  MyConfig.Add(TBooleanConfiguration.Create('Debug','GeneralLogFile','�Զ������־���ļ�',{$IFDEF DEBUG}True{$ELSE}False{$ENDIF}));
  MyConfig.Add(TBooleanConfiguration.Create('Debug','HTTPLogFile','ת��HTTP�����ļ�',{$IFDEF DEBUG}True{$ELSE}False{$ENDIF}));
  MyConfig.Add(TBooleanConfiguration.Create('Debug','SaveOnExit','�˳�ʱ��������',{$IFDEF DEBUG}False{$ELSE}True{$ENDIF}));
  LoadSettings();

finalization
  if SaveOnExit then SaveSettings;
  ConfigDict.Free;
  MyConfig.Free;

end.
