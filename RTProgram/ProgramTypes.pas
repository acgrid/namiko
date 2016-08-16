unit ProgramTypes;

interface

uses System.Types, System.UITypes, System.Generics.Collections, IGDIPlusEmbedded;

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
end;

type TLogo = class(TObject)
  Enabled: Boolean;
  FullPath: string;
end;

type TProgram = class(TObject)
  Session: string;
  Sequence: Double;
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
end;

type TImageElement = class(TFrameElement)
  Image: TIGPImage;
end;

type TFrame = record
  TTL: Cardinal; // Cycles to remain, not millisecond
  Template: TIGPImage;
  Elements: TObjectList<TFrameElement>;
end;

implementation

constructor TProgram.Create;
begin
  Self.Status := Check;
end;

end.
