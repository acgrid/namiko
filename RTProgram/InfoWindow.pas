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
  CCWinClass.cbClsExtra := 0; //以下两个域用于在类结构和Windows内部保存的窗口结构
  CCWinClass.cbWndExtra := 0; //中预留一些额外空间.
  CCWinClass.hIcon := 0; // wndcls.hIcon=NULL;
  CCWinClass.hIconsm := 0;
  CCWinClass.hCursor := LoadCursor(0, IDC_Arrow); // wndcls.hCursor=::LoadCursor(NULL,IDC_ARROW);
  //GetStockObject 获取一个图形对象,在这里是获取绘制窗口背景的刷子,返回一个白色刷  子的句柄.
  CCWinClass.hbrBackground := HBRUSH(COLOR_BTNFACE+1); // wndcls.hbrBackground=(HBRUSH)(COLOR_BTNFACE+1);
  CCWinClass.lpszMenuName := nil; //wndcls.lpszMenuName=NULL;

  //向Windows 注册窗口类.
  if RegisterClassEx(CCWinClass) = 0 then raise Exception.Create('信息窗体类注册失败');
  // MultiMonitor
  DesiredMonitorID := GetCfgInteger('Display.InfoWindowMonitor');
  if DesiredMonitorID >= Screen.MonitorCount then DesiredMonitorID := Screen.MonitorCount - 1;
  MyMonitor := Screen.Monitors[DesiredMonitorID];
  frmControl.Log(Format('运行于显示器%u(%d,%d)[%ux%u]', [DesiredMonitorID, MyMonitor.Left, MyMonitor.Top, MyMonitor.Width, MyMonitor.Height]));
  WindowRect := TRect.Create(TPoint.Create(MyMonitor.Left, MyMonitor.Top), MyMonitor.Width, MyMonitor.Height);
  frmControl.Log(Format('信息窗口位置(%d,%d)[%ux%u]', [WindowRect.Left, WindowRect.Top, WindowRect.Width, WindowRect.Height]));

  frmControl.InfoHWND := CreateWindowEx(
    WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_LAYERED, //扩展的窗口风格.
    CCWinClass.lpszClassName, //类名.
    'Hello Window', //窗口标题.
    WS_POPUP or WS_VISIBLE, //窗口风格.
    WindowRect.Left, //窗口左上角相对于屏幕左上角的初始位置x.
    WindowRect.Top, //....右y.
    WindowRect.Width, //窗口宽度x.
    WindowRect.Height, //窗口高度y.
    0, //父窗口句柄.
    0, //窗口菜单句柄.
    WindowInstance, //程序实例句柄.
    nil); //创建参数指针.
  if frmControl.InfoHWND = 0 then
    raise Exception.Create('弹幕窗体创建失败')
  else
  begin
    hdcTemp := GetDC(frmControl.InfoHWND);
    m_hdcMemory := CreateCompatibleDC(hdcTemp);
    hBitMap := CreateCompatibleBitmap(hdcTemp,WindowRect.Width,WindowRect.Height);
    SelectObject(m_hdcMemory,hBitMap);
    with blend do begin
      BlendOp := AC_SRC_OVER;     //把源图片覆盖到目标之上
      BlendFlags := 0;
      AlphaFormat := AC_SRC_ALPHA;//每个像素有各自的alpha通道
      SourceConstantAlpha := 255;  //源图片的透明度
    end;
    ptWinPos := Point(0,0);
    sizeWindow.cx := WindowRect.Width;
    sizeWindow.cy := WindowRect.Height;
    ptSrc := Point(0,0);
    hdcScreen := GetDC(frmControl.InfoHWND);
    UpdateLayeredWindow(frmControl.InfoHWND,   //分层窗口的句柄
                        hdcScreen,     //屏幕的DC句柄
                        @ptWinPos,     //分层窗口新的屏幕坐标
                        @sizeWindow,   //分层窗口新的大小
                        m_hdcMemory,   //用来定义分层窗口的表面DC句柄
                        @ptSrc,        //分层窗口在设备上下文的位置
                        0,             //合成分层窗口时使用指定颜色键值
                        @blend,        //在分层窗口进行组合时的透明度值
                        ULW_ALPHA);    //使用pblend为混合功能
    //---------------------开始：释放和删除--------------------------------------
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
  {$IFDEF DEBUG_HEIGHT}Log(Format('测量大小 %s %u * %u',[AStr, OWidth, OHeight]), logDebug);{$ENDIF}
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
