unit InfoWindow;

interface

uses Winapi.Windows, System.Types, System.Classes, System.SysUtils, Vcl.Forms,
  ProgramTypes, IGDIPlusEmbedded, System.UIConsts, System.UITypes, System.Diagnostics;

procedure CreateInfoWindow;

type TInfoCmdType = (infoOnly, playInfo);

const FontName = 'Meiryo';
const FontSizeTitle = 28;
const FontSizeType = 18;
const FontSizeCreditTitle = 16;
const FontSizeCreditName = 20;

type
  TInfoRenderThread = class(TThread)
  WorkingGraphic: GpGraphics;

  MyProgram: TProgram;
  WorkMode: TInfoCmdType;
  MS: Cardinal;
  Duration: Integer;
  protected
    FMainHandle: HWND;
    FCycle: Cardinal;
    FHeightZoom: Single;
    FFFDict: TFontFamilyDict;
    FSBDict: TBrushDict;
    FFPDict: TFontDict;
    FPGraphic: GpGraphics;
    FPStringFormat: GPSTRINGFORMAT;
    FPPath: GPPATH;
    FPPen: GPPen;
    FSRC_HDC: HDC;
    FDEST_HDC: HDC;
    FBITMAP: HBITMAP;
    FMPCHC_TITLE: string;
    FOriginPoint: TIGPRectF;

    procedure CenterToLeftTop(FullWidth, FullHeight, RelWidth, RelHeight, PercentWidth, PercentHeight: Integer; var Point: TPoint);
    function PercentValue(Accurate, Percent: Integer): Integer;
    function GetFontFamily(AFontName: WideString): GpFontFamily;
    function GetFont(AFontName: WideString; AFontSize: Single; AFontStyle: Integer): GpFont;
    function GetSolidBrush(AColor: TAlphaColor): GpBrush;
    function GetCachedBitmap(AText: PWideChar; ALength: Integer; AFontFamily: GPFONTFAMILY;
       AFontStyle: Integer; emSize: Single; AFillColor: TAlphaColor; AWidth: Integer; AHeight: Integer): GpCachedBitmap;
    function CreateCachedBitmapFromHBITMAP(const hBitmap: HBITMAP; pGraphics: GPGraphics): GpCachedBitmap;
    procedure GetStringDim(AStr: string; AFont: WideString; ASize: Single; AStyle: Integer; var OWidth: Integer; var OHeight: Integer);
  public
    procedure AccurateCycle();
    procedure Execute; override;
    procedure TextOut(AStr: string; AFontFamily: Pointer; AFontStyle: Integer; 
      emSize: Single; AFillColor: TAlphaColor; AWidth: Integer; AHeight: Integer);
    procedure NewGraphic();
    procedure Update();
 public
    procedure ShowInfo();
    procedure StartPlay();
    procedure ClearAll();

    constructor Create(AProgram: TProgram; AWorkMode: TInfoCmdType; OffsetMS: Cardinal);
    destructor Destroy(); override;
  end;

implementation

uses UnitControl, Configuration;

var
  WindowInstance: THandle;
  CCWinClass: TWndClassEx;
  blend: BLENDFUNCTION;
  WindowRect: TRect;
  sizeWindow: SIZE;
  ptWinPos, ptSrc: TPoint;

procedure CreateInfoWindow;
var
  hdcTemp,hdcScreen,m_hdcMemory: HDC;
  hBitMap: Winapi.Windows.HBITMAP;
  DesiredMonitorID: Integer;
  MyMonitor: TMonitor;
begin
  if frmControl.InfoHWND > 0 then Exit;
  WindowInstance := GetModuleHandle(nil); // HINSTANCE hInstance=AfxGetInstanceHandle();
  CCWinClass.cbSize := SizeOf(TWndClassEx); // wndcls.cbSize=sizeof(WNDCLASSEX);
  CCWinClass.lpszClassName := 'InfoWindow'; // wndcls.lpszClassName=lpszClassName;
  CCWinClass.style := CS_DBLCLKS or CS_HREDRAW or CS_VREDRAW; //wndcls.style=CS_DBLCLKS|CS_HREDRAW|CS_VREDRAW;
  CCWinClass.hInstance := WindowInstance; //wndcls.hInstance=hInstance;
  CCWinClass.lpfnWndProc := @DefWindowProc; //wndcls.lpfnWndProc=::DefWindowProc;
  CCWinClass.cbClsExtra := 0; //������������������ṹ��Windows�ڲ�����Ĵ��ڽṹ
  CCWinClass.cbWndExtra := 0; //��Ԥ��һЩ����ռ�.
  CCWinClass.hIcon := 0; // wndcls.hIcon=NULL;
  CCWinClass.hIconsm := 0;
  CCWinClass.hCursor := LoadCursor(0, IDC_Arrow); // wndcls.hCursor=::LoadCursor(NULL,IDC_ARROW);
  //GetStockObject ��ȡһ��ͼ�ζ���,�������ǻ�ȡ���ƴ��ڱ�����ˢ��,����һ����ɫˢ  �ӵľ��.
  CCWinClass.hbrBackground := HBRUSH(COLOR_BTNFACE+1); // wndcls.hbrBackground=(HBRUSH)(COLOR_BTNFACE+1);
  CCWinClass.lpszMenuName := nil; //wndcls.lpszMenuName=NULL;

  //��Windows ע�ᴰ����.
  if RegisterClassEx(CCWinClass) = 0 then raise Exception.Create('��Ϣ������ע��ʧ��');
  // MultiMonitor
  DesiredMonitorID := GetCfgInteger('Display.InfoWindowMonitor');
  if DesiredMonitorID >= Screen.MonitorCount then DesiredMonitorID := Screen.MonitorCount - 1;
  MyMonitor := Screen.Monitors[DesiredMonitorID];
  frmControl.Log(Format('��������ʾ��%u(%d,%d)[%ux%u]', [DesiredMonitorID, MyMonitor.Left, MyMonitor.Top, MyMonitor.Width, MyMonitor.Height]));
  WindowRect := TRect.Create(TPoint.Create(MyMonitor.Left, MyMonitor.Top), MyMonitor.Width, MyMonitor.Height);
  frmControl.Log(Format('��Ϣ����λ��(%d,%d)[%ux%u]', [WindowRect.Left, WindowRect.Top, WindowRect.Width, WindowRect.Height]));

  frmControl.InfoHWND := CreateWindowEx(
    WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_LAYERED, //��չ�Ĵ��ڷ��.
    CCWinClass.lpszClassName, //����.
    'Hello Window', //���ڱ���.
    WS_POPUP or WS_VISIBLE, //���ڷ��.
    WindowRect.Left, //�������Ͻ��������Ļ���Ͻǵĳ�ʼλ��x.
    WindowRect.Top, //....��y.
    WindowRect.Width, //���ڿ��x.
    WindowRect.Height, //���ڸ߶�y.
    0, //�����ھ��.
    0, //���ڲ˵����.
    WindowInstance, //����ʵ�����.
    nil); //��������ָ��.
  if frmControl.InfoHWND = 0 then
    raise Exception.Create('��Ļ���崴��ʧ��')
  else
  begin
    hdcTemp := GetDC(frmControl.InfoHWND);
    m_hdcMemory := CreateCompatibleDC(hdcTemp);
    hBitMap := CreateCompatibleBitmap(hdcTemp,WindowRect.Width,WindowRect.Height);
    SelectObject(m_hdcMemory,hBitMap);
    with blend do begin
      BlendOp := AC_SRC_OVER;     //��ԴͼƬ���ǵ�Ŀ��֮��
      BlendFlags := 0;
      AlphaFormat := AC_SRC_ALPHA;//ÿ�������и��Ե�alphaͨ��
      SourceConstantAlpha := 255;  //ԴͼƬ��͸����
    end;
    ptWinPos := Point(0,0);
    sizeWindow.cx := WindowRect.Width;
    sizeWindow.cy := WindowRect.Height;
    ptSrc := Point(0,0);
    hdcScreen := GetDC(frmControl.InfoHWND);
    UpdateLayeredWindow(frmControl.InfoHWND,   //�ֲ㴰�ڵľ��
                        hdcScreen,     //��Ļ��DC���
                        @ptWinPos,     //�ֲ㴰���µ���Ļ����
                        @sizeWindow,   //�ֲ㴰���µĴ�С
                        m_hdcMemory,   //��������ֲ㴰�ڵı���DC���
                        @ptSrc,        //�ֲ㴰�����豸�����ĵ�λ��
                        0,             //�ϳɷֲ㴰��ʱʹ��ָ����ɫ��ֵ
                        @blend,        //�ڷֲ㴰�ڽ������ʱ��͸����ֵ
                        ULW_ALPHA);    //ʹ��pblendΪ��Ϲ���
    //---------------------��ʼ���ͷź�ɾ��--------------------------------------
    ReleaseDC(frmControl.InfoHWND, hdcScreen);
    ReleaseDC(frmControl.InfoHWND, hdcTemp);
    DeleteObject(hBitMap);
    DeleteDC(m_hdcMemory);
  end;
end;

constructor TInfoRenderThread.Create(AProgram: TProgram; AWorkMode: TInfoCmdType; OffsetMS: Cardinal);
begin
  FOriginPoint.X := 0;
  FOriginPoint.Y := 0;
  FOriginPoint.Width := 0;
  FOriginPoint.Height := 0;
  FHeightZoom := GetCfgInteger('Render.HeightZoom') / 100;
  FFFDict := TFontFamilyDict.Create();
  FSBDict := TBrushDict.Create();
  FFPDict := TFontDict.Create();
  FCycle := Trunc(1000 / GetCfgInteger('Display.ReferenceFPS'));
  Self.FMainHandle := frmControl.InfoHWND;
  Self.Duration := Trunc((GetCfgInteger('InfoWindow.Duration') * 1000) / FCycle);
  Self.MyProgram := AProgram;
  Self.WorkMode := AWorkMode;
  Self.MS := OffsetMS;
  Self.FMPCHC_TITLE := GetCfgString('MPCHC.WindowTitle');
  GdipCreateFromHWND(FMainHandle, FPGraphic);
  GdipStringFormatGetGenericTypographic(FPStringFormat);
  GdipCreatePath(FillModeAlternate, FPPath);
  if GetCfgInteger('Render.BorderWidth') > 0 then GdipCreatePen1(StringToAlphaColor(GetCfgString('Render.BorderColor')), GetCfgInteger('Render.BorderWidth').ToSingle, UnitWorld, FPPen);
  Self.FreeOnTerminate := True;
  inherited Create();
end;

destructor TInfoRenderThread.Destroy();
var
  P: GpFontFamily;
  FP: GpFont;
  SP: GpBrush;
begin
  inherited Destroy();

  GdipDeleteGraphics(FPGraphic);
  GdipDeleteStringFormat(FPStringFormat);
  if Assigned(FPPen) then GdipDeletePen(FPPen);
  GdipDeletePath(FPPath);
  for P in FFFDict.Values do begin
    GdipDeleteFontFamily(P);
  end;
  FFFDict.Free;
  for FP in FFPDict.Values do GdipDeleteFont(FP);
  FFPDict.Free;
  for SP in FSBDict.Values do GdipDeleteBrush(SP);
  FSBDict.Free;
end;

procedure TInfoRenderThread.ShowInfo;
var
  ProgramType, ProgramName, CreditName, CreditTitle: string;
  W, H: Integer;
begin
  NewGraphic;
  try
    ProgramName := MyProgram.MainTitle;
    ProgramType := MyProgram.TypeName;
    GetStringDim(ProgramName, FontName, FontSizeTitle, 0, W, H);
    Synchronize(procedure begin
      frmControl.Log(ProgramName);
    end);
    TextOut(ProgramName, GetFontFamily(FontName), 0, FontSizeTitle, claWhite, PercentValue(sizeWindow.cx, 15), sizeWindow.cy - H - 50);
    TextOut(ProgramType, GetFontFamily(ProgramType), 0, FontSizeType, claWhite, PercentValue(sizeWindow.cx, 15), PercentValue(sizeWindow.cy - H, 90));
  finally
    Update;
  end;
end;

procedure TInfoRenderThread.ClearAll;
begin
  NewGraphic;
  try 
    GdipGraphicsClear(WorkingGraphic, $FFFFFFFF);
    {$IFDEF DEBUG}GdipDrawLine(WorkingGraphic, FPPen, 0, 0, sizeWindow.cx, sizeWindow.cy);{$ENDIF}
  finally
    Update;
  end;
end;

procedure TInfoRenderThread.StartPlay;
begin
  // LYRIC PARSER
end;

procedure TInfoRenderThread.NewGraphic;
begin
  Self.FSRC_HDC := GetDC(frmControl.InfoHWND);
  if(FSRC_HDC = 0) then raise Exception.Create('Cannot obtain HDC from HWND.');
  Self.FDEST_HDC := CreateCompatibleDC(Self.FSRC_HDC);
  if FDEST_HDC = 0 then raise Exception.Create('Cannot create HDC compatible to parent HDC.');
  Self.FBITMAP := CreateCompatibleBitmap(FDEST_HDC, sizeWindow.cx, sizeWindow.cy);
  if Self.FBITMAP = 0 then raise Exception.Create('Cannot create bitmap for specific HDC.');
  SelectObject(FDEST_HDC, FBITMAP);
  GdipCreateFromHDC(FDEST_HDC, WorkingGraphic);
  Assert(Assigned(WorkingGraphic), 'GDI+ graphic is not created.');
  GdipSetSmoothingMode(WorkingGraphic, SmoothingModeAntiAlias);
  GdipSetInterpolationMode(WorkingGraphic, InterpolationModeHighQualityBicubic);
end;

procedure TInfoRenderThread.Update();
var
  ScreenHDC: HDC;
  MPC_HWND: HWND;
begin
  ScreenHDC := GetDC(frmControl.InfoHWND);
  MPC_HWND := FindWindow(nil, @FMPCHC_TITLE);
  if MPC_HWND <> 0 then
    SetWindowPos(MPC_HWND, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW or SWP_NOACTIVATE);
  try
    UpdateLayeredWindow(frmControl.InfoHWND, ScreenHDC, @ptWinPos, @sizeWindow, Self.FDEST_HDC, @ptSrc, 0, @blend, ULW_ALPHA);
  finally
    ReleaseDC(frmControl.InfoHWND, ScreenHDC);
    ReleaseDC(frmControl.InfoHWND, Self.FSRC_HDC);
    DeleteObject(Self.FBITMAP);
    DeleteDC(Self.FDEST_HDC);
  end;
end;

procedure TInfoRenderThread.TextOut(AStr: string; AFontFamily: Pointer; AFontStyle: Integer; emSize: Single; AFillColor: TAlphaColor; AWidth: Integer; AHeight: Integer);
begin
  GdipResetPath(FPPath);
  GdipAddPathStringI(FPPath, PWideChar(AStr), Length(AStr), AFontFamily, AFontStyle, emSize, @FOriginPoint, FPStringFormat);
  if Assigned(FPPen) then GdipDrawPath(WorkingGraphic, FPPen, FPPath);
  GdipFillPath(WorkingGraphic, GetSolidBrush(AFillColor), FPPath);  
end;

procedure TInfoRenderThread.AccurateCycle;
var
  FSleepwatch: TStopWatch;
begin
  FSleepwatch := TStopWatch.Create;
  try
    repeat
      FSleepwatch.Start;
      Sleep(1);
      FSleepwatch.Stop;
    until (Assigned(Self) and (FSleepwatch.ElapsedMilliseconds >= FCycle));
  finally
    FSleepwatch.Stop;
    FSleepwatch.Reset;
  end;
end;

procedure TInfoRenderThread.CenterToLeftTop(FullWidth, FullHeight, RelWidth, RelHeight, PercentWidth, PercentHeight: Integer; var Point: TPoint);
var
  CenteredX, CenteredY: Integer;
begin
  CenteredX := PercentValue(FullWidth, PercentWidth);
  CenteredY := PercentValue(FullHeight, PercentHeight);
  Point.X := CenteredX - Trunc(RelWidth / 2);
  Point.Y := CenteredY - Trunc(RelHeight / 2);
end;

function TInfoRenderThread.PercentValue(Accurate, Percent: Integer): Integer;
begin
  Result := Round(Accurate * (Percent / 100));
end;

function TInfoRenderThread.GetFontFamily(AFontName: WideString): GpFontFamily;
var
  PFontFamily: GpFontFamily;
begin
  if FFFDict.ContainsKey(AFontName) then
    Result := FFFDict.Items[AFontName]
  else begin
    GdipCreateFontFamilyFromName(PWideChar(AFontName),nil,PFontFamily);
    FFFDict.Add(AFontName,PFontFamily);
    Result := PFontFamily;
  end;
end;

function TInfoRenderThread.GetFont(AFontName: WideString; AFontSize: Single; AFontStyle: Integer): GpFont;
var
  Key: string;
  PFont: GpFont;
begin
  Key := Format('%s:%.1f:%u', [AFontName, AFontSize, AFontStyle]);
  if FFPDict.ContainsKey(Key) then
    Result := FFPDict.Items[Key]
  else begin
    GdipCreateFont(GetFontFamily(AFontName),AFontSize,AFontStyle,0,PFont);
    FFPDict.Add(Key,PFont);
    Result := PFont;
  end;
end;

function TInfoRenderThread.GetSolidBrush(AColor: TAlphaColor): GpBrush;
var
  PBrush: GpBrush;
begin
  if FSBDict.ContainsKey(AColor) then
    Result := FSBDict.Items[AColor]
  else begin
    GdipCreateSolidFill(AColor,PBrush);
    FSBDict.Add(AColor,PBrush);
    Result := PBrush;
  end;
end;

procedure TInfoRenderThread.GetStringDim(AStr: string; AFont: WideString; ASize: Single; AStyle: Integer; var OWidth: Integer; var OHeight: Integer);
var
  Rect, ResultRect: TIGPRectF;
begin
  Rect.X := 0;
  Rect.Y := 0;
  Rect.Width := 0;
  Rect.Height := 0;
  GdipMeasureString(
      FPGraphic,
      PWideChar(AStr),
      Length(AStr),
      GetFont(AFont, ASize, AStyle),
      @Rect,
      FPStringFormat,
      @ResultRect,
      nil,
      nil
  );
  OWidth := Round(ResultRect.Width);
  if FHeightZoom > 0.1 then
    OHeight := Round(ResultRect.Height)
  else
    OHeight := Round(FHeightZoom * ASize);
  {$IFDEF DEBUG_HEIGHT}Log(Format('������С %s %u * %u',[AStr, OWidth, OHeight]), logDebug);{$ENDIF}
end;

function TInfoRenderThread.GetCachedBitmap(AText: PWideChar; ALength: Integer; AFontFamily: Pointer; AFontStyle: Integer; emSize: Single; AFillColor: TAlphaColor; AWidth: Integer; AHeight: Integer): GpCachedBitmap;
var
  MainDC, CurrentHDC: HDC;
  CurrentBitmap: HBITMAP;
  PGraphic: GPGraphics;
begin
  // initialization
  MainDC := GetDC(FMainHandle);
  if MainDC = 0 then raise Exception.Create('Cannot obtain HDC from HWND.');
  CurrentHDC := CreateCompatibleDC(MainDC);
  if CurrentHDC = 0 then raise Exception.Create('Cannot create HDC compatible to parent HDC.');
  CurrentBitmap := CreateCompatibleBitmap(MainDC, AWidth, AHeight);
  if CurrentBitmap = 0 then raise Exception.Create('Cannot create bitmap for specific HDC.');
  SelectObject(CurrentHDC, CurrentBitmap);
  GdipCreateFromHDC(CurrentHDC, PGraphic);
  Assert(Assigned(PGraphic), 'GDI+ graphic is not created.');
  GdipSetSmoothingMode(PGraphic, SmoothingModeAntiAlias);
  GdipSetInterpolationMode(PGraphic, InterpolationModeHighQualityBicubic);
  // do render
  GdipGraphicsClear(PGraphic, $FFFFFFFF);
  GdipResetPath(FPPath);
  GdipAddPathStringI(FPPath, AText, ALength, AFontFamily, AFontStyle, emSize, @FOriginPoint, FPStringFormat);
  if Assigned(FPPen) then GdipDrawPath(PGraphic, FPPen, FPPath);
  GdipFillPath(PGraphic, GetSolidBrush(AFillColor), FPPath);
  //GdipCreateBitmapFromHBITMAP(CurrentBitmap, FHPALETTE, RenderedBitmap); // Lost Alpha channels
  Result := CreateCachedBitmapFromHBITMAP(CurrentBitmap, PGraphic);
  // finalization
  GdipDeleteGraphics(PGraphic);
  ReleaseDC(FMainHandle, MainDC);
  DeleteObject(CurrentBitmap);
  DeleteDC(CurrentHDC);
end;

function TInfoRenderThread.CreateCachedBitmapFromHBITMAP(const hBitmap: HBITMAP; pGraphics: GPGraphics): GpCachedBitmap;
var
  bmp: BITMAP;
  bmpInfo: BITMAPINFO;
  bmpBits: Pointer;
  bmpSize: NativeUInt;
  pGDIbmp: GpBitmap;
  hdcScreen: HDC;
begin
  Result := nil;
  ZeroMemory(@bmp, SizeOf(BITMAP));
  if GetObject(hBitmap, SizeOf(BITMAP), @bmp) = 0 then raise Exception.Create('Error get BITMAP from HBITMAP.'); // HBITMAP -> Native BITMAP

  ZeroMemory(@bmpInfo, SizeOf(BITMAPINFO));
  bmpInfo.bmiHeader.biSize := SizeOf(BITMAPINFOHEADER);
  bmpInfo.bmiHeader.biWidth := bmp.bmWidth;
  bmpInfo.bmiHeader.biHeight := -bmp.bmHeight; // Upside-down!
  bmpInfo.bmiHeader.biPlanes := bmp.bmPlanes;
  bmpInfo.bmiHeader.biBitCount := bmp.bmBitsPixel;
  bmpInfo.bmiHeader.biCompression := BI_RGB;
  bmpSize := bmp.bmWidthBytes * bmp.bmHeight;
  bmpBits := VirtualAlloc(nil, bmpSize, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE);
  Assert(Assigned(bmpBits), 'VirtualAlloc failed');
  try
    hdcScreen := GetDC(0);
    if hdcScreen = 0 then raise Exception.Create('GetDC() Error');
    try
      if GetDIBits(hdcScreen, hBitmap, 0, bmp.bmHeight, PByte(bmpBits), bmpInfo, DIB_RGB_COLORS) = 0 then raise Exception.Create('Error copy HBITMAP to BITMAP.');
    finally
      DeleteDC(hdcScreen);
    end;
    GdipCreateBitmapFromScan0(bmp.bmWidth, bmp.bmHeight, bmp.bmWidthBytes, PixelFormat32bppARGB, PByte(bmpBits), pGDIbmp);
    Assert(Assigned(pGDIbmp), 'GdipCreateBitmapFromScan0 failed');
    try
      GdipCreateCachedBitmap(pGDIbmp, pGraphics, Result); // AV in RDP
    finally
      GdipFree(pGDIbmp);
    end;
  finally
    VirtualFree(bmpBits, 0, MEM_RELEASE);
  end;
end;

procedure TInfoRenderThread.Execute;
begin
  NameThreadForDebugging('INFO_WINDOW');
  ShowInfo;
  if WorkMode = infoOnly then begin
    while not Self.Terminated do begin
      Dec(Duration);
      if Duration = 0 then Break;
      AccurateCycle;
    end;
  end
  else StartPlay;
  ClearAll;
  Terminate;
end;

end.
