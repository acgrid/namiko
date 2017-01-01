unit ProgramTypes;

interface

uses System.Types, System.UITypes, System.Generics.Collections, IGDIPlusEmbedded,
 System.SysUtils, System.StrUtils, System.Classes;

type TWorkMode = (SERVER_ONLY, SERVER_INFO, SERVER_LIVE, INFO_LIVE, CLIENT_INFO, CLIENT_LIVE);

type TCredit = class(TObject)
  Title: string;
  Name: string;
end;

type TCredits = TObjectList<TCredit>;

type TLyricPart = class(TObject)
  Main: string;
  MainOffset: Cardinal;
  Furi: string;
  FuriOffset: Cardinal;
end;

type TLyricParts = TObjectList<TLyricPart>;

type TLyric = class(TObject)
  Offset: Integer; // Milliseconds
  Text: string;
  Parts: TLyricParts;
end;

type TLyrics = class(TObject)
  Enabled: Boolean;
  Lyrics: TQueue<TLyric>;
end;

type TProgramStatus = (Check, Ready, Missing, InfoShown, Playing, Played);

type TFB2K = class(TObject)
  Enabled: Boolean;
  Playlist: Cardinal;
  Index: Cardinal;
end;

type TMpcHC = class(TObject)
  Enabled: Boolean;
  FullPath: string;
  function IsAvaliable(): Boolean;
  function HasError(): Boolean;
  function ToString(): string; override;
end;

type TLogo = class(TObject)
  Enabled: Boolean;
  FullPath: string;
  function IsAvaliable(): Boolean;
  function HasError(): Boolean;
  function ToString(): string; override;
end;

type TProgram = class(TObject)
  Session: string;
  Sequence: Double;
  ID: string;
  Team: string;
  TypeName: string;
  MobilePhone: string;
  MainTitle: string;
  TranslatedTitle: string;
  Credits: TCredits;
  Source: string;
  TranslatedSource: string;
  Status: TProgramStatus;
  Lyric: TLyrics;
  ShowInfo: Boolean;
  FB2K: TFB2K;
  MPCHC: TMpcHC;
  Logo: TLogo;
  constructor Create();
end;

type PProgram = ^TProgram;

type TPrograms = TObjectList<TProgram>;

type TSessionProgramsDict = TDictionary<Integer, TPrograms>;

{ Render Units }

type TFrameUnit = class(TObject)

end;

type TFrameElement = class(TObject)
  Position: TPoint;
end;

type TTextElement = class(TFrameElement)
  Text: string;
  Font: GPFONTFAMILY;
  Size: Single;
  Color: TAlphaColor;
  Style: Integer;
end;

type TImageElement = class(TFrameElement)
  Image: TIGPImage;
end;

type TFrame = record
  TTL: Cardinal; // Cycles to remain, not millisecond
  Template: TIGPImage;
  Elements: TObjectList<TFrameElement>;
end;

type
  TFontFamilyDict = TDictionary<string,GPFONTFAMILY>;
type
  TBrushDict = TDictionary<TAlphaColor,GpBrush>;
type
  TFontDict = TDictionary<string, GPFont>;

implementation

uses Configuration, UnitControl;

constructor TProgram.Create;
begin
  Self.Status := Check;
end;

function TMpcHC.IsAvaliable: Boolean;
begin
  Result := FileExists(Self.FullPath);
end;

function TLogo.IsAvaliable: Boolean;
begin
  Result := FileExists(Self.FullPath);
end;

function TMpcHC.HasError: Boolean;
begin
  Result := Self.Enabled and (not FileExists(Self.FullPath));
end;

function TLogo.HasError: Boolean;
begin
  Result := Self.Enabled and (not FileExists(Self.FullPath));
end;

function TMpcHC.ToString: string;
begin
  Result := IfThen(Self.Enabled, IfThen(Self.HasError, '¡Á', '¡Ì'), 'ÎÞ');
end;

function TLogo.ToString: string;
begin
  Result := IfThen(Self.Enabled, IfThen(Self.HasError, '¡Á', '¡Ì'), 'ÎÞ');
end;

end.
