unit XMLLoadForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  xmldom, XMLIntf, msxmldom, XMLDoc, CtrlForm, Math;

type
  TfrmLoadXML = class(TForm)
    GrpOptions: TRadioGroup;
    EditDelay: TLabeledEdit;
    btnOK: TButton;
    LblSample: TLabel;
    OpenDialog: TOpenDialog;
    Label1: TLabel;
    ComboTiming: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure GrpOptionsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Test();
  end;

var
  frmLoadXML: TfrmLoadXML;

implementation

{$R *.dfm}

procedure TfrmLoadXML.FormCreate(Sender: TObject);
begin
  OpenDialog.InitialDir := APP_DIR;
  SetWindowLong(EditDelay.Handle, GWL_STYLE, GetWindowLong(EditDelay.Handle, GWL_STYLE) or ES_NUMBER);
end;

procedure TfrmLoadXML.Test();
var
  XMLDoc : TXMLDocument;
  DocIntf : IXMLDocument;
  RootNode, CNode : IXMLNode;
begin
  if OpenDialog.Execute then begin
    XMLDoc := TXMLDocument.Create(nil);
    DocIntf := XMLDoc;
    try
      XMLDoc.LoadFromFile(OpenDialog.FileName);
      XMLDoc.Active := true;
      XMLDoc.Encoding := 'utf-8';
      XMLDoc.Options := XMLDoc.Options + [doNodeAutoIndent];
      if XMLDoc.IsEmptyDoc then exit;
      RootNode := XMLDoc.ChildNodes.FindNode('Namiko');
      if RootNode <> nil then begin
        CNode := RootNode.ChildNodes.FindNode('comment');
        if CNode <> nil then LblSample.Caption := CNode.ChildNodes.FindNode('time').Text;
      end;
      if LblSample.Caption = '233' then Application.MessageBox('格式不正确','XML读取失败',MB_ICONERROR);
      if StrToDateTime(LblSample.Caption) > 30/86400 then GrpOptions.ItemIndex := 0 else GrpOptions.ItemIndex := 2;
    except
      frmControl.LogEvent('[异常] XML数据处理出错。');
    end;
  end
  else
    frmLoadXML.Hide;
end;

procedure TfrmLoadXML.btnOKClick(Sender: TObject);
var
  XMLDoc : TXMLDocument;
  DocIntf : IXMLDocument;
  RootNode, CNode : IXMLNode;
  i : Integer;
  RTime, Offset : TTime;
  SW : Word;
  Effect : TCommentEffect;
begin
  RTime := 0;
  Offset := Ifthen(Boolean(ComboTiming.ItemIndex = 0), StrToInt(EditDelay.Text), 0 - StrToInt(EditDelay.Text)) / 86400;
  if Offset > 0 then frmControl.NotifyDelay(StrToInt(EditDelay.Text));
  try
    XMLDoc := TXMLDocument.Create(nil);
    DocIntf := XMLDoc;
    XMLDoc.LoadFromFile(OpenDialog.FileName);
    XMLDoc.Active := true;
    XMLDoc.Encoding := 'utf-8';
    XMLDoc.Options := XMLDoc.Options + [doNodeAutoIndent];
    if XMLDoc.IsEmptyDoc then exit;
    RootNode := XMLDoc.ChildNodes.FindNode('Namiko');
    for i := 0 to RootNode.ChildNodes.Count - 1 do begin
      CNode := RootNode.ChildNodes.Nodes[i];
      with CNode do begin
        if CNode.NodeName <> 'comment' then continue;
        case GrpOptions.ItemIndex of
          0 : RTime := StrToTime(CNode.ChildNodes.FindNode('time').Text);
          1 : RTime := frmControl.InternalTime + StrToTime(CNode.ChildNodes.FindNode('time').Text) - StrToTime(RootNode.ChildNodes.FindNode('comment').ChildNodes.FindNode('time').Text) + Offset;
          2 : RTime := frmControl.InternalTime + StrToTime(CNode.ChildNodes.FindNode('time').Text) + Offset;
        end;
        SW := Word(StrToInt(CNode.ChildNodes.FindNode('data').Text));
        Effect.RepeatCount := 1;
        if QueryStatusWord(SW, SW_E_FLYING) then begin
          Effect.Display := Scroll;
          Effect.RepeatCount := StrToInt(CNode.ChildNodes.FindNode('repeat').Text);
        end
        else if QueryStatusWord(SW, SW_E_DFIXED) then
          Effect.Display := LowerFixed
        else if QueryStatusWord(SW, SW_E_UFIXED) then
          Effect.Display := UpperFixed;
        Effect.StayTime := StrToInt(CNode.ChildNodes.FindNode('duration').Text);
        frmControl.SubmitComment(RTime,CNode.ChildNodes.FindNode('content').Text,L_XMLFile,CNode.ChildNodes.FindNode('format').Text,Effect);
      end;
    end;
    frmControl.LogEvent('外部XML弹幕数据已导入。');
    frmLoadXML.Hide;
  except
    frmControl.LogEvent('[异常] XML数据处理出错。');
  end;
end;

procedure TfrmLoadXML.GrpOptionsClick(Sender: TObject);
begin
  case GrpOptions.ItemIndex of
    0 : EditDelay.Enabled := false;
    1 : EditDelay.Enabled := true;
    2 : EditDelay.Enabled := true;
  end;
end;

end.
