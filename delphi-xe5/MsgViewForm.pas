unit MsgViewForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, NamikoTypes,
  System.Actions, Vcl.ActnList, Vcl.Menus, Math;

const
  TM_RECV_TIME = 0;
  TM_REMOTE_ID = 1;
  TM_REMOTE_GRP = 2;
  TM_TYPE = 3;
  TM_CONTENT = 4;

type
  TfrmMessages = class(TForm)
    MsgListView: TListView;
    MsgDetail: TMemo;
    BtnDownload: TButton;
    PopupMenu: TPopupMenu;
    ActionList: TActionList;
    ActionMarkDone: TAction;
    ActionCopyTo: TAction;
    ActionDownload: TAction;
    C1: TMenuItem;
    M1: TMenuItem;
    procedure AddSrvMessage(ID: Int64; RecvTime: TTime; Author: TCommentAuthor; MsgType, MsgContent: string);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure NotifyMarkedDone(ID: Int64);
    procedure NotifyListCompleted;
    procedure MsgListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure MsgListViewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ActionMarkDoneExecute(Sender: TObject);
    procedure ActionDownloadExecute(Sender: TObject);
    procedure ActionCopyToExecute(Sender: TObject);
  private
    { Private declarations }
    MsgPool: TSrvMessageCollection;
    function FindListItem(ID: Int64): TListItem;
    function FindComment(ListItem: TListItem): TSrvMessage;
    procedure ReportLog(Info: string; Level: TLogType = logInfo);
    procedure InsertListView(Msg: TSrvMessage);
  public
    { Public declarations }
  end;

var
  frmMessages: TfrmMessages;

implementation

uses
  LogForm, HTTPMsgWorker, CtrlForm;

{$R *.dfm}

procedure TfrmMessages.NotifyListCompleted;
begin
  BtnDownload.Enabled := True;
end;

procedure TfrmMessages.NotifyMarkedDone(ID: Int64);
var
  Row: TListItem;
begin
  if MsgPool.ContainsKey(ID) then begin
    Row := FindListItem(ID);
    if Assigned(Row) then begin
      Row.Delete();
    end;
    MsgPool.Remove(ID);
  end;
end;

procedure TfrmMessages.ReportLog(Info: string; Level: TLogType = logInfo);
begin
  frmLog.LogAdd(Info, '会场', Level);
end;

procedure TfrmMessages.InsertListView(Msg: TSrvMessage);
begin
  with MsgListView.Items.Add do begin
    Caption := IntToStr(Msg.DBID);
    SubItems.Add(TimeToStr(Msg.Time));
    SubItems.Add(Msg.Author.Address);
    SubItems.Add(Msg.Author.Group);
    SubItems.Add(Msg.MsgType);
    if Length(Msg.Content) > 10 then begin
      SubItems.Add(Copy(Msg.Content, 0, Min(20, Length(Msg.Content))) + '...');
    end
    else begin
      SubItems.Add(Msg.Content);
    end;
  end;
end;

procedure TfrmMessages.MsgListViewContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  if MsgListView.Selected = nil then Handled := True;
end;

procedure TfrmMessages.MsgListViewSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  Msg: TSrvMessage;
begin
  MsgDetail.Lines.Clear;
  if Selected then begin
    Msg := FindComment(Item);
    if Assigned(Msg) then begin
      MsgDetail.Text := Msg.Content;
    end;
  end;
end;

function TfrmMessages.FindListItem(ID: Int64): TListItem;
var
  It: TListItemsEnumerator;
  Find: string;
begin
  Find := IntToStr(ID);
  It := MsgListView.Items.GetEnumerator;
  while It.MoveNext do begin
    Result := It.GetCurrent;
    if Result.Caption = Find then Exit;
  end;
  Result := nil;
end;

function TfrmMessages.FindComment(ListItem: TListItem): TSrvMessage;
var
  ID: Int64;
begin
  Result := nil;
  if Assigned(ListItem) then begin
    ID := StrToInt64(ListItem.Caption);
    if MsgPool.ContainsKey(ID) then Result := MsgPool.Items[ID];
  end;
end;

procedure TfrmMessages.ActionCopyToExecute(Sender: TObject);
var
  Msg: TSrvMessage;
begin
  if MsgListView.ItemIndex <> -1 then begin
    Msg := FindComment(MsgListView.Selected);
    if Assigned(Msg) then begin
      frmControl.editOfficialComment.Text := Msg.Content;
    end;
  end;
end;

procedure TfrmMessages.ActionDownloadExecute(Sender: TObject);
var
  Thread: THTTPMsgWorker;
begin
  BtnDownload.Enabled := False;
  Thread := THTTPMsgWorker.Create;
  Thread.List;
end;

procedure TfrmMessages.ActionMarkDoneExecute(Sender: TObject);
var
  Msg: TSrvMessage;
  Thread: THTTPMsgWorker;
begin
  if MsgListView.ItemIndex <> -1 then begin
    Msg := FindComment(MsgListView.Selected);
    if Assigned(Msg) then begin
      Thread := THTTPMsgWorker.Create;
      Thread.MarkDone(Msg.DBID);
    end;
  end;
end;

procedure TfrmMessages.AddSrvMessage(ID: Int64; RecvTime: TTime; Author: TCommentAuthor; MsgType: string; MsgContent: string);
var
  Msg: TSrvMessage;
begin
  if MsgPool.ContainsKey(ID) then begin
    ReportLog(Format('ID冲突发现: %u', [ID]));
    Exit;
  end;
  Msg := TSrvMessage.Create;
  Msg.DBID := ID;
  Msg.Time := RecvTime;
  Msg.Author := Author;
  Msg.MsgType := MsgType;
  Msg.Content := MsgContent;
  MsgPool.Add(ID, Msg);
  InsertListView(Msg);
end;

procedure TfrmMessages.FormCreate(Sender: TObject);
begin
  MsgPool := TSrvMessageCollection.Create();
end;

procedure TfrmMessages.FormDestroy(Sender: TObject);
begin
  MsgPool.Free;
end;

end.
