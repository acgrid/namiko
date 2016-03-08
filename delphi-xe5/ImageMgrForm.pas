unit ImageMgrForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.Menus,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Imaging.jpeg, LogForm, NamikoTypes;

const
  TI_RECV_TIME = 0;
  TI_REMOTE_ID = 1;
  TI_REMOTE_GRP = 2;
  TI_SIGNATURE = 3;
  TI_DIM = 4;
  TI_FLAG_DL = 5;
  TI_FLAG_DISP = 6;
  TI_FLAG_COMMIT = 7;

type
  TfrmImageManager = class(TForm)
    ImagesListView: TListView;
    ImagePreview: TImage;
    BtnCommitDisplayed: TButton;
    BtnDownloadAll: TButton;
    PopupMenuImg: TPopupMenu;
    D1: TMenuItem;
    P1: TMenuItem;
    U1: TMenuItem;
    X1: TMenuItem;
    R1: TMenuItem;
    ActionList: TActionList;
    BtnClearCommitted: TButton;
    GroupButtons: TGroupBox;
    Button1: TButton;
    ActionLoadListOK: TAction;
    ActionDownloadAll: TAction;
    ActionDownload: TAction;
    ActionDisplay: TAction;
    ActionCommit: TAction;
    ActionDiscard: TAction;
    ActionRemove: TAction;
    ActionCommitDisplayed: TAction;
    ActionRemoveCommitted: TAction;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ImagesListViewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure AddImageComment(ID: Int64; RecvTime, CommittedTime: TTime; Author: TCommentAuthor; ImageKey, Signature: string; ImageSize: Int64);
    procedure NotifyDownloaded(ID: Int64);
    procedure NotifyCommitted(ID: Int64);
    procedure NotifyDiscarded(ID: Int64);
    procedure ActionLoadListOKExecute(Sender: TObject);
    procedure ActionDownloadAllExecute(Sender: TObject);
    procedure ImagesListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ActionDownloadExecute(Sender: TObject);
    procedure ActionCommitExecute(Sender: TObject);
    procedure ActionDiscardExecute(Sender: TObject);
    procedure ActionDisplayExecute(Sender: TObject);
    procedure ActionRemoveExecute(Sender: TObject);
    procedure ActionCommitDisplayedExecute(Sender: TObject);
    procedure ActionRemoveCommittedExecute(Sender: TObject);
  private
    { Private declarations }
    CurrentImageID: Int64;
    ImagePool: TImageCommentCollection;
    function FindListItem(ID: Int64): TListItem;
    function FindComment(ListItem: TListItem): TImageComment;
    procedure ReportLog(Info: string; Level: TLogType = logInfo);
    procedure LoadImage(ImageFile: TFileName; Container: TImage);
    procedure InsertListView(Cmt: TImageComment);
  public
    { Public declarations }
  end;

var
  frmImageManager: TfrmImageManager;

implementation

uses
  JPEGUtils, ImageViewForm, HTTPImageWorker, System.Generics.Collections, CfgForm;

{$R *.dfm}

procedure TfrmImageManager.Button1Click(Sender: TObject);
{var
  FileName: string;
  TestAuthor: TCommentAuthor;}
begin
  {FileName := InputBox('图片测试', '要加载的图片文件名(JPEG)', 'test.jpg');
  LoadImage(FileName, ImagePreview);
  with frmImage do begin
    LoadImage(FileName, ImagePresentation);
    Display;
  end;
  TestAuthor.Source := Console;
  TestAuthor.Address := 'TEST';
  TestAuthor.Group := 'Local';
  FileName := InputBox('ID测试', 'KEY', 'a');
  AddImageComment(1, Now(), Now() - 1, TestAuthor, FileName, 'X', 24243); }
end;

procedure TfrmImageManager.FormCreate(Sender: TObject);
begin
  ImagePool := TImageCommentCollection.Create();
end;

procedure TfrmImageManager.LoadImage(ImageFile: TFileName; Container: TImage);
var
  Src, Dst: TBitmap;
  MyRatio: Extended;
begin
  Src := TBitmap.Create;
  ReportLog('加载图片' + ImageFile + '开始');
  try
    if LoadJPEGPictureFile(Src, ImageFile) then begin
      ReportLog('加载图片' + ImageFile + '完成');
      if (Src.Width > Container.Width) or (Src.Height > Container.Height) then begin
        Dst := TBitmap.Create;
        try
          MyRatio := Src.Width / Src.Height;
          if MyRatio > Container.Width / Container.Height then begin
            Dst.Width := Container.Width;
            Dst.Height := Trunc(Dst.Width / MyRatio);
          end
          else begin
            Dst.Height := Container.Height;
            Dst.Width := Trunc(Container.Height * MyRatio);
          end;
          SmoothResize(Src, Dst);
          Container.Picture.Bitmap.Assign(Dst);
        finally
          Dst.FreeImage;
          Dst.Free;
        end;
      end
      else begin
        Container.Picture.Bitmap.Assign(Src);
      end;
    end;
    Container.Refresh;
  finally
    Src.FreeImage;
    Src.Free;
  end;
end;

procedure TfrmImageManager.ActionDownloadExecute(Sender: TObject);
var
  Comment: TImageComment;
  Thread: THTTPImageWorker;
begin
  if ImagesListView.ItemIndex <> -1 then begin
    Comment := FindComment(ImagesListView.Selected);
    if Assigned(Comment) and (not Comment.Downloaded) then begin
      Thread := THTTPImageWorker.Create;
      Thread.Download(Comment.DBID, Comment.ImageKey, Comment.GetImageFileName);
    end;
  end;
end;

procedure TfrmImageManager.ActionCommitDisplayedExecute(Sender: TObject);
var
  It: TEnumerator<TPair<Int64, TImageComment>>;
  Thread: THTTPImageWorker;
begin
  It := ImagePool.GetEnumerator;
  while It.MoveNext do begin
    if It.Current.Value.Displayed then begin
      Thread := THTTPImageWorker.Create;
      Thread.Commit(It.Current.Value.DBID);
    end;
  end;
end;

procedure TfrmImageManager.ActionCommitExecute(Sender: TObject);
var
  Comment: TImageComment;
  Thread: THTTPImageWorker;
begin
  if ImagesListView.ItemIndex <> -1 then begin
    Comment := FindComment(ImagesListView.Selected);
    if Assigned(Comment) and (not Comment.Committed) then begin
      Thread := THTTPImageWorker.Create;
      Thread.Commit(Comment.DBID);
    end;
  end;
end;

procedure TfrmImageManager.ActionDiscardExecute(Sender: TObject);
var
  Comment: TImageComment;
  Thread: THTTPImageWorker;
begin
  if ImagesListView.ItemIndex <> -1 then begin
    Comment := FindComment(ImagesListView.Selected);
    if Assigned(Comment) and (not Comment.Committed) then begin
      Thread := THTTPImageWorker.Create;
      Thread.Discard(Comment.DBID);
    end;
  end;
end;

procedure TfrmImageManager.ActionDisplayExecute(Sender: TObject);
var
  Comment: TImageComment;
begin
  if ImagesListView.ItemIndex <> -1 then begin
    Comment := FindComment(ImagesListView.Selected);
    if Assigned(Comment) and Comment.Downloaded then begin
      with frmImage do begin
        LoadImage(Comment.GetImageFileName, ImagePresentation);
        if Comment.IsSignatured then begin
          LabelSignature.Caption := Comment.Signature;
          LabelSignature.Visible := True;
        end
        else LabelSignature.Visible := False;
        Display;
        ImagesListView.Selected.SubItems.Strings[TI_FLAG_DISP] := TimeToStr(Now());
      end;
      Comment.Displayed := True;
    end;
  end;
end;

procedure TfrmImageManager.ActionDownloadAllExecute(Sender: TObject);
var
  Thread: THTTPImageWorker;
begin
  BtnDownloadAll.Enabled := False;
  BtnDownloadAll.Caption := '获取中';
  Thread := THTTPImageWorker.Create;
  Thread.List();
end;

procedure TfrmImageManager.ActionLoadListOKExecute(Sender: TObject);
begin
  BtnDownloadAll.Caption := '下载历史图片(&D)';
  BtnDownloadAll.Enabled := True;
end;

procedure TfrmImageManager.ActionRemoveCommittedExecute(Sender: TObject);
var
  It: TEnumerator<TPair<Int64, TImageComment>>;
begin
  It := ImagePool.GetEnumerator;
  while It.MoveNext do begin
    if It.Current.Value.Committed then begin
      // modify myself within iteration, dangerous?
      NotifyDiscarded(It.Current.Value.DBID);
    end;
  end;
end;

procedure TfrmImageManager.ActionRemoveExecute(Sender: TObject);
var
  Comment: TImageComment;
begin
  if ImagesListView.ItemIndex <> -1 then begin
    Comment := FindComment(ImagesListView.Selected);
    if Assigned(Comment) and Comment.Committed then begin
      NotifyDiscarded(Comment.DBID);
    end;
  end;
end;

procedure TfrmImageManager.AddImageComment(ID: Int64; RecvTime: TTime; CommittedTime: TTime; Author: TCommentAuthor; ImageKey: string; Signature: string; ImageSize: Int64);
var
  Comment: TImageComment;
  Thread: THTTPImageWorker;
begin
  if ImagePool.ContainsKey(ID) then begin
    ReportLog(Format('ID冲突发现: %u', [ID]));
    Exit;
  end;
  Comment := TImageComment.Create(ImageKey);
  Comment.DBID := ID;
  Comment.Time := RecvTime;
  Comment.Author := Author;
  Comment.IsSignatured := Boolean(Signature <> '');
  Comment.Signature := Signature;
  Comment.Committed := Boolean(CommittedTime > 0);
  Comment.CommittedTime := CommittedTime;
  ImagePool.Add(ID, Comment);
  InsertListView(Comment);
  if not Comment.Downloaded and frmConfig.BooleanItems['ImageView.AutoDownload'] then begin
    Thread := THTTPImageWorker.Create;
    Thread.Download(Comment.DBID, Comment.ImageKey, Comment.GetImageFileName);
  end;
end;

procedure TfrmImageManager.InsertListView(Cmt: TImageComment);
begin
  with ImagesListView.Items.Add do begin
    Caption := IntToStr(Cmt.DBID);
    SubItems.Add(TimeToStr(Cmt.Time));
    SubItems.Add(Cmt.Author.Address);
    SubItems.Add(Cmt.Author.Group);
    if Cmt.IsSignatured then begin
      SubItems.Add('有:' + Cmt.Signature);
    end else begin
      SubItems.Add('无');
    end;
    if Cmt.Downloaded then begin
      SubItems.Add(Format('%u*%u px', [Cmt.Width, Cmt.Height]));
      SubItems.Add('已下载');
    end
    else begin
      SubItems.Add(Format('%.1f KB', [Cmt.FileSize / 1024]));
      SubItems.Add('未下载');
    end;
    SubItems.Add('未显示');
    if Cmt.Committed then begin
      SubItems.Add(TimeToStr(Cmt.CommittedTime));
    end
    else begin
      SubItems.Add('未上报');
    end;
  end;
end;

procedure TfrmImageManager.FormDestroy(Sender: TObject);
begin
  ImagePool.Free;
end;

procedure TfrmImageManager.FormResize(Sender: TObject);
begin
  ImagesListView.Width := Self.Width - 370;
  ImagesListView.Height := Self.Height - 90;
  ImagePreview.Left := Self.Width - 355;
  GroupButtons.Top := Self.Height - 80;
end;

procedure TfrmImageManager.ImagesListViewContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  SelectedItem: TListItem;
  ID: Int64;
  Comment: TImageComment;
begin
  SelectedItem := ImagesListView.Selected;
  if SelectedItem = nil then Handled := True;
  ID := StrToInt64(SelectedItem.Caption);
  if ImagePool.ContainsKey(ID) then begin
    Comment := ImagePool.Items[ID];
    R1.Enabled := False;
    if Comment.Downloaded then begin
      D1.Enabled := False;
      P1.Enabled := True;
    end else begin
      D1.Enabled := True;
      P1.Enabled := False;
    end;
    if Comment.Committed then begin
      U1.Enabled := False;
      X1.Enabled := False;
      R1.Enabled := True;
    end else begin
      U1.Enabled := True;
      X1.Enabled := True;
    end;
  end else Handled := True;
end;

procedure TfrmImageManager.ImagesListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  ClearImage: Boolean;
  Comment: TImageComment;
begin
  ClearImage := True;
  if Selected then begin
    Comment := FindComment(Item);
    if Assigned(Comment) then begin
      if (CurrentImageID <> Comment.DBID) and Comment.Downloaded then begin
        CurrentImageID := Comment.DBID;
        LoadImage(Comment.GetImageFileName, ImagePreview);
        ClearImage := False;
      end;
    end;
  end;
  if ClearImage then begin
    CurrentImageID := 0;
    ImagePreview.Picture.Assign(nil);
  end;
end;

function TfrmImageManager.FindComment(ListItem: TListItem): TImageComment;
var
  ID: Int64;
begin
  Result := nil;
  if Assigned(ListItem) then begin
    ID := StrToInt64(ListItem.Caption);
    if ImagePool.ContainsKey(ID) then Result := ImagePool.Items[ID];
  end;
end;

function TfrmImageManager.FindListItem(ID: Int64): TListItem;
var
  It: TListItemsEnumerator;
  Find: string;
begin
  Find := IntToStr(ID);
  It := ImagesListView.Items.GetEnumerator;
  while It.MoveNext do begin
    Result := It.GetCurrent;
    if Result.Caption = Find then Exit;
  end;
  Result := nil;
end;

procedure TfrmImageManager.NotifyDownloaded(ID: Int64);
var
  Comment: TImageComment;
  Row: TListItem;
begin
  if ImagePool.ContainsKey(ID) then begin
    Comment := ImagePool.Items[ID];
    Comment.Reload;
    Row := FindListItem(ID);
    if Comment.Downloaded and Assigned(Row) then begin
      Row.SubItems.Strings[TI_DIM] := Format('%u*%u px', [Comment.Width, Comment.Height]);
      Row.SubItems.Strings[TI_FLAG_DL] := '已下载';
      Row.Selected := True;
    end;
  end;
end;

procedure TfrmImageManager.NotifyCommitted(ID: Int64);
var
  Comment: TImageComment;
  Row: TListItem;
begin
  if ImagePool.ContainsKey(ID) then begin
    Comment := ImagePool.Items[ID];
    Comment.Committed := True;
    Comment.CommittedTime := Now();
    Row := FindListItem(ID);
    if Assigned(Row) then begin
      Row.SubItems.Strings[TI_FLAG_COMMIT] := TimeToStr(Comment.CommittedTime);
    end;
  end;
end;

procedure TfrmImageManager.NotifyDiscarded(ID: Int64);
var
  Row: TListItem;
begin
  if ImagePool.ContainsKey(ID) then begin
    Row := FindListItem(ID);
    if Assigned(Row) then begin
      Row.Delete();
    end;
    ImagePool.Remove(ID);
  end;
end;

procedure TfrmImageManager.ReportLog(Info: string; Level: TLogType = logInfo);
begin
  frmLog.LogAdd(Info, '图片', Level);
end;

end.
