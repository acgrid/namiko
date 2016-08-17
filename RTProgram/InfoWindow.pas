unit InfoWindow;

interface

uses Winapi.Windows, System.Types, System.Classes, System.SysUtils, Vcl.Forms;

procedure CreateInfoWindow;

type
  TInfoRenderThread = class(TThread)
  protected
    procedure Execute; override;
  end;

implementation

uses UnitControl, Configuration;

var
  WindowInstance: THandle;
  CCWinClass: TWndClassEx;

procedure CreateInfoWindow;
var
  hdcTemp,hdcScreen,m_hdcMemory: HDC;
  hBitMap: Winapi.Windows.HBITMAP;
  blend: BLENDFUNCTION;
  ptWinPos, ptSrc: TPoint;
  sizeWindow: SIZE;
  DesiredMonitorID: Integer;
  WindowRect: TRect;
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
  if RegisterClassEx(CCWinClass) = 0 then raise Exception.Create('弹幕窗体类注册失败');
  // MultiMonitor
  DesiredMonitorID := GetCfgInteger('Display.InfoWindowMonitor');
  MyMonitor := Screen.Monitors[DesiredMonitorID];
  if DesiredMonitorID >= Screen.MonitorCount then DesiredMonitorID := Screen.MonitorCount - 1;
  WindowRect := TRect.Create(TPoint.Create(MyMonitor.Left, MyMonitor.Top), MyMonitor.Width, MyMonitor.Height);

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
      SourceConstantAlpha := Trunc(100 * 2.55);  //源图片的透明度
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

procedure TInfoRenderThread.Execute;
begin
  //
end;

end.
