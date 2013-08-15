unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DSUtil, StdCtrls, DSPack, DirectShow9, Menus, ExtCtrls,jpeg,
  ComCtrls, ImgList;

type
  TVideoForm = class(TForm)
    FilterGraph: TFilterGraph;
    MainMenu1: TMainMenu;
    Devices: TMenuItem;
    Filter: TFilter;
    SampleGrabber: TSampleGrabber;
    edt_project_name: TEdit;
    rg_documents: TRadioGroup;
    btn_save: TButton;
    VideoWindow: TVideoWindow;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btn_snapClick(Sender: TObject);
    procedure edt_project_nameExit(Sender: TObject);
    procedure btn_saveClick(Sender: TObject);
    
    procedure ShowImage(); 
    procedure ClearImage();
    procedure DeleteImage(i:Integer);
    procedure ScrollBox1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ScrollBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ScrollBox1Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
 
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
    procedure OnSelectDevice(sender: TObject);
  end;

var
  VideoForm: TVideoForm;
  SysDev: TSysDevEnum;
  
    Image:array[0..1000] of TImage;
      //�������ͼ
  ImgName : array[0..1000] of TLabel;
//  ���ͼƬ��
  BackGroud : array[0..1000] of TPanel;
  //��������ͼ��ͼƬ���ı���
  ImgNameBak :array[0..1000] of TPanel;
  //���imgname�ı���
  ImgPos,NamPos, imgcount:Integer;
  //����ͼ��λ�ú�ͼƬ����
  Path :string; //��ǰͼƬ��·��
  Filelist: TStringList; //��¼��ǰ·���µ�����ͼƬ��
implementation

uses preview;

{$R *.dfm}
procedure TVideoForm.ClearImage;
var
  i:Integer;
begin
  if Imgcount>=1 then
    for i:=1 to Imgcount do
    begin
      if Assigned(Image[i]) then
      begin
        Image[i].Free;
        Image[i]:=nil;
      end;
      if Assigned(ImgName[i]) then
      begin
        ImgName[i].Free;
        ImgName[i]:=nil;
      end;
      if Assigned(ImgNameBak[i]) then
      begin
        ImgNameBak[i].Free;
        ImgNameBak[i]:=nil;
      end;
      if Assigned(BackGroud[i]) then
      begin
        BackGroud[i].Free;
        BackGroud[i]:=nil;
      end;
      
    end;
end;

procedure TVideoForm.DeleteImage(i:Integer);
begin
  if i>=1 then
      if Assigned(Image[i]) then
      begin
        Image[i].Free;
        Image[i]:=nil;
      end;
      if Assigned(ImgName[i]) then
      begin
        ImgName[i].Free;
        ImgName[i]:=nil;
      end;
      if Assigned(ImgNameBak[i]) then
      begin
        ImgNameBak[i].Free;
        ImgNameBak[i]:=nil;
      end;
      if Assigned(BackGroud[i]) then
      begin
        BackGroud[i].Free;
        BackGroud[i]:=nil;
      end;
      Filelist.Delete(i-1);


end;

procedure TVideoForm.ShowImage;
var
  i,j,k:Integer;
  begin
    ClearImage();
    imgcount:=Filelist.count;
    for i:=1 to Imgcount do
    begin
      BackGroud[i]:=TPanel.Create(self);
      BackGroud[i].Parent:=ScrollBox1;
      BackGroud[i].Visible:=True;
      BackGroud[i].Width:=104;
      BackGroud[i].Height:=118;
      //��̬����BackGroud����Ϊ��������ͼ��ͼƬ���ı���
      image[i]:=TImage.Create(self);
      image[i].Parent:=BackGroud[i];
      image[i].Visible:=True;
      image[i].Stretch:=True;
      image[i].Center:=True;
      image[i].Width:=98;
      image[i].Height:=98;
      //��̬����Timage,�����������ͼ
      ImgNameBak[i]:=TPanel.Create(self);
      ImgNameBak[i].Parent:=BackGroud[i];
      ImgNameBak[i].BevelOuter:=bvLowered;
      ImgNameBak[i].Font.Size:=9;
      ImgNameBak[i].Font.Color:=clBlue;
      ImgNameBak[i].Width:=100;
      ImgNameBak[i].Height :=12;
      //��̬����ImgNameBak,������Ϊimgname�ı���
      ImgName[i]:=TLabel.Create(self);
      ImgName[i].Parent:=ImgNameBak[i];
      ImgName[i].Font.Color :=clBlue;
      ImgName[i].Width:=100;
      //��̬����ImgName,�������ͼƬ��
      Path :=Filelist.Strings[i-1];
      //�����ļ�·��

      Image[i].Picture.LoadFromFile(Path);
      ImgNameBak[i].OnClick:=ScrollBox1.OnClick;
      ImgNameBak[i].OnDblClick:=ScrollBox1.OnDblClick;
      ImgNameBak[i].PopupMenu:=PopupMenu1;
      Image[i].OnMouseMove:=ScrollBox1.OnMouseMove;
      Image[i].OnClick:=ScrollBox1.OnClick;
      Image[i].OnDblClick:=ScrollBox1.OnDblClick;
      Image[i].PopupMenu:=PopupMenu1;
      if (Image[i].Picture.Width<98) and (Image[i].Picture.Height<98) then
         Image[i].Stretch:=False;
      //���ͼƬС��image �Ĵ�С����ͼƬ��ʵ�ʴ�С��ʾ
      ImgName[i].Caption:= Filelist.Strings[i-1];
      ImgNameBak[i].Caption:=ImgName[i].Caption;
      ImgName[i].Visible:=False;
      //��ʾͼƬ������֤ͼƬ�� ����
      if(i>=1) and (i<=8) then
      begin
        if(i=1) then
        begin
          BackGroud[i].Top:=8;
          BackGroud[i].Left :=8;
          Image[i].Top:=3;
          Image[i].Left:=3;
          Image[i].Visible:=True;
          
        end;
        if(i>=2) and (i<=8) then
        begin
          BackGroud[i].Top:=BackGroud[i-1].Top;
          BackGroud[i].Left:=BackGroud[i-1].Left+108;
          Image[i].Top:=3;
          Image[i].Left:=3;
          Image[i].Visible:=True;
          
        end;
      end
      else
      begin
        k:=Trunc(i/8);
        if((i mod (k*8))=1) then
        begin
          if k=1 then
            BackGroud[i].Top:=130
          else
            BackGroud[i].Top:=120*k+12;
          BackGroud[i].Left:=8;
          Image[i].Top:=3;
          Image[i].Left:=3;
          Image[i].Visible:=True;
        end
        else
        begin
          BackGroud[i].Top:=BackGroud[i-1].Top;
          BackGroud[i].Left:=BackGroud[i-1].Left+108;
          Image[i].Top:=3;
          Image[i].Left:=3;
          Image[i].Visible:=True;
        end;
      end;
      ImgNameBak[i].Top:=Image[i].Top+101;
      ImgNameBak[i].Left:=1;
    end;
  end;

procedure TVideoForm.FormCreate(Sender: TObject);
var
  i: integer;
  Device: TMenuItem;
begin
  SysDev:= TSysDevEnum.Create(CLSID_VideoInputDeviceCategory);
  if SysDev.CountFilters > 0 then
    for i := 0 to SysDev.CountFilters - 1 do
    begin
      Device := TMenuItem.Create(Devices);
      Device.Caption := SysDev.Filters[i].FriendlyName;
      Device.Tag := i;
      Device.OnClick := OnSelectDevice;
      Devices.Add(Device);
    end;

    
  FilterGraph.ClearGraph;
  FilterGraph.Active := false;
  Filter.BaseFilter.Moniker := SysDev.GetMoniker(SysDev.CountFilters - 1);
  FilterGraph.Active := true;
  with FilterGraph as ICaptureGraphBuilder2 do
    RenderStream(@PIN_CATEGORY_PREVIEW, nil, Filter as IBaseFilter, SampleGrabber as IBaseFilter, VideoWindow as IbaseFilter);
  FilterGraph.Play;

  

  rg_documents.Items.CommaText:='�õ�����,����������,�ַ�ͼ';
  if rg_documents.ItemIndex = -1 then
      rg_documents.ItemIndex := 0;

  self.edt_project_name.SetFocus;
  

end;

procedure TVideoForm.OnSelectDevice(sender: TObject);
begin
  FilterGraph.ClearGraph;
  FilterGraph.Active := false;
  Filter.BaseFilter.Moniker := SysDev.GetMoniker(TMenuItem(Sender).tag);
  FilterGraph.Active := true;
  with FilterGraph as ICaptureGraphBuilder2 do
    RenderStream(@PIN_CATEGORY_PREVIEW, nil, Filter as IBaseFilter, SampleGrabber as IBaseFilter, VideoWindow as IbaseFilter);
  FilterGraph.Play;
end;

procedure TVideoForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  SysDev.Free;
  FilterGraph.ClearGraph;
  FilterGraph.Active := false;
end;





procedure TVideoForm.btn_snapClick(Sender: TObject);
begin
  //SampleGrabber.GetBitmap(Image1.Picture.Bitmap);
end;

procedure TVideoForm.edt_project_nameExit(Sender: TObject);
begin
      if trim(self.edt_project_name.Text) = '' then
      begin
         self.edt_project_name.SetFocus;
      end;
end;




function MakeFileNameUnique(const FileName:string;const iUnique:integer):string;
begin
    Result:=ChangeFileExt(FileName,'')+'-'+IntToStr(iUnique)+ExtractFileExt(FileName);
end;
function GetUniqueFileName(const FileName:string):string;
var
   N:integer;
begin
   Result:=FileName;
   //if not FileExists(Result) then

   //�������ļ������ڣ����ʾ���ļ�������ʹ��
   //   exit;

   N:=1;
   //���FileName.Ext���ڣ������ΪFileName(Index).Ext
   //�� TestFile.txt.bak���ڣ��Ͳ��� TestFile.txt(1).bak
   //ֱ��TestFile.txt(N).bak������Ϊֹ

   Result:=MakeFileNameUnique(FileName,N);
   while FileExists(Result) do
   begin
      inc(N);
      Result:=MakeFileNameUnique(FileName,N);
   end;
end;






procedure TVideoForm.btn_saveClick(Sender: TObject);
var
  jp: TJPEGImage;
  i : integer;
  Bitmap : TBitmap;
  savejpgname :string;
begin
      //���沶׽��ͼƬ
      jp := TJPEGImage.Create;
      Bitmap := TBitmap.Create;
      SampleGrabber.GetBitmap(Bitmap);
      jp.CompressionQuality := 40;
      jp.Compress ;
      jp.Assign(Bitmap);
      Bitmap.Free;
      if not DirectoryExists(ExtractFilePath(Paramstr(0)) +edt_project_name.Text) then
      begin
         CreateDir(ExtractFilePath(Paramstr(0)) +'Document\'+edt_project_name.Text);
         ChDir(ExtractFilePath(Paramstr(0)) +'Document\'+edt_project_name.Text);
          //Ϊÿһ���ĵ����ʹ���Ŀ¼
         //for i:=0 to  rg_documents.ControlCount-1 do
         //begin
         //   CreateDir(rg_documents.Items[i]);
         //end;

      end;

      //ChDir(rg_documents.Items[rg_documents.ItemIndex]);
      savejpgname:=GetUniqueFileName(rg_documents.Items[rg_documents.ItemIndex]+'.jpg');
      jp.SaveToFile(savejpgname);
      //Image.Picture.SaveToFile(ExtractFilePath(Paramstr(0)) +rg_documents.Items[rg_documents.ItemIndex]+'.jpg');
      //showmessage(GetUniqueFileName(rg_documents.Items[rg_documents.ItemIndex]+'.jpg'));

      //�������ͼƬ��ӵ�Ԥ������         
      if not Assigned(Filelist) then
      begin
        Filelist := TStringList.Create;
      end;
      //Filelist.Clear;
      Filelist.Add(savejpgname);
      ShowImage;


end;

procedure TVideoForm.ScrollBox1DblClick(Sender: TObject);
var
  path1:string;
begin
  if((Sender is TImage) or (Sender is TLabel)) then
  begin
    path1:=Filelist.Strings[NamPos-1];
    PreviewForm.Image1.Picture.LoadFromFile(path1);
    VideoForm.Hide;
    PreviewForm.Caption :=path1;
    PreviewForm.ShowModal;
  end;

end;

procedure TVideoForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Filelist.Free;
  ClearImage;
end;

procedure TVideoForm.ScrollBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  path1:string;
begin
  ImgPos:=0;
  
  if not Assigned(Filelist) then
  begin
    Filelist := TStringList.Create;
  end;
  for ImgPos:=1 to Filelist.Count do
    if((Sender =Image[ImgPos]) or (Sender = imgName[ImgPos])) then
    begin
      NamPos:= ImgPos;
      path1:=FileList.strings[NamPos-1];
      //ScrollBox1.Hint:='�ļ���:'+Filelist.strings[nampos-1]+#13+'ͼ���С:'+ IntToStr(Image[ImgPos].Picture.Width)+'          X'+ IntToStr(Image[ImgPos].Picture.Height)+'����';
    end;

end;

procedure TVideoForm.ScrollBox1Click(Sender: TObject);
var
  path1:string;
begin
  if((Sender is TImage) or (Sender is TLabel)) then
  begin
    path1:=Filelist.Strings[NamPos-1];
    PreviewForm.Image1.Picture.LoadFromFile(path1);
    VideoForm.Hide;
    PreviewForm.Caption :=path1;
    PreviewForm.ShowModal;
  end;
end;

procedure TVideoForm.N1Click(Sender: TObject);
var
  path1:string;
begin
  if((TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent.ClassName='TImage') or (TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent.ClassName='TLabel')) then
  begin
    path1:=Filelist.Strings[NamPos-1];
    PreviewForm.Image1.Picture.LoadFromFile(path1);
    VideoForm.Hide;
    PreviewForm.Caption :=path1;
    PreviewForm.ShowModal;
  end;
end;

procedure TVideoForm.N2Click(Sender: TObject); 
var
  path1:string;
begin  
  if((TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent.ClassName='TImage') or (TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent.ClassName='TLabel')) then
  begin
    path1:=Filelist.Strings[NamPos-1];
    DeleteFile(path1);
    DeleteImage(NamPos);
    ShowImage;


  
  end;
end;

end.
