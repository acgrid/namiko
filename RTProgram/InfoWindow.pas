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
  CCWinClass.cbClsExtra := 0; //������������������ṹ��Windows�ڲ�����Ĵ��ڽṹ
  CCWinClass.cbWndExtra := 0; //��Ԥ��һЩ����ռ�.
  CCWinClass.hIcon := 0; // wndcls.hIcon=NULL;
  CCWinClass.hIconsm := 0;
  CCWinClass.hCursor := LoadCursor(0, IDC_Arrow); // wndcls.hCursor=::LoadCursor(NULL,IDC_ARROW);
  //GetStockObject ��ȡһ��ͼ�ζ���,�������ǻ�ȡ���ƴ��ڱ�����ˢ��,����һ����ɫˢ  �ӵľ��.
  CCWinClass.hbrBackground := HBRUSH(COLOR_BTNFACE+1); // wndcls.hbrBackground=(HBRUSH)(COLOR_BTNFACE+1);
  CCWinClass.lpszMenuName := nil; //wndcls.lpszMenuName=NULL;

  //��Windows ע�ᴰ����.
  if RegisterClassEx(CCWinClass) = 0 then raise Exception.Create('��Ļ������ע��ʧ��');
  // MultiMonitor
  DesiredMonitorID := GetCfgInteger('Display.InfoWindowMonitor');
  MyMonitor := Screen.Monitors[DesiredMonitorID];
  if DesiredMonitorID >= Screen.MonitorCount then DesiredMonitorID := Screen.MonitorCount - 1;
  WindowRect := TRect.Create(TPoint.Create(MyMonitor.Left, MyMonitor.Top), MyMonitor.Width, MyMonitor.Height);

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
      SourceConstantAlpha := Trunc(100 * 2.55);  //ԴͼƬ��͸����
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

procedure TInfoRenderThread.Execute;
begin
  //
end;

end.
