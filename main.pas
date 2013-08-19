unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DSUtil, StdCtrls, DSPack, DirectShow9, Menus, ExtCtrls,jpeg,
  ComCtrls, ImgList,IniFiles, ShellCtrls;

type
  TVideoForm = class(TForm)
    FilterGraph: TFilterGraph;
    MainMenu1: TMainMenu;
    Devices: TMenuItem;
    Filter: TFilter;
    SampleGrabber: TSampleGrabber;
    VideoWindow: TVideoWindow;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ScrollBox1: TScrollBox;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    imgPreview: TImage;
    scrlbx_pic: TScrollBox;
    PopupMenu2: TPopupMenu;
    StatusBar1: TStatusBar;
    N3: TMenuItem;
    TreeView1: TTreeView;
    PopupMenu3: TPopupMenu;

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btn_snapClick(Sender: TObject);
    procedure btn_saveClick(Sender: TObject);

    procedure TreeviewRightClick(Sender: TObject);
    
    procedure ShowImage(); 
    procedure ClearImage();
    procedure refreshDir();
    procedure DeleteImage(i:Integer);
    procedure initDirectory();
    procedure initControl();
    procedure initConfig();

    procedure DeleteDir(sDirectory: String);
    procedure ScrollBox1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N1Click(Sender: TObject);
    procedure SnapClick(Sender: TObject);
    procedure ShellTreeView1AddFolder(Sender: TObject;
      AFolder: TShellFolder; var CanAdd: Boolean);
    procedure ShellTreeView1Click(Sender: TObject);
    procedure scrlbx_picMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure scrlbx_picClick(Sender: TObject);
    procedure imgPreviewDblClick(Sender: TObject);
    procedure imgPreviewClick(Sender: TObject);
    procedure N3Click(Sender: TObject);

    procedure DirToTreeView(Tree: TTreeView; Directory: string; Root: TTreeNode; IncludeFiles:
  Boolean);
    procedure TreeView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
 
  private
    { D閏larations priv閑s }
  public
    { D閏larations publiques }
    procedure OnSelectDevice(sender: TObject);
  end;

var
  VideoForm: TVideoForm;
  SysDev: TSysDevEnum;
  
  Image:array[0..1000] of TImage;
  //存放缩略图
  ImgName : array[0..1000] of TLabel;
  //  存放图片名
  BackGroud : array[0..1000] of TPanel;
  //放置缩略图和图片名的背景
  ImgNameBak :array[0..1000] of TPanel;
  //存放imgname的背景
  ImgPos,NamPos, imgcount:Integer;
  //缩略图的位置和图片数量
  Path :string; //当前图片的路径
  Filelist: TStringList; //记录当前路径下的所有图片名

  Document:string;

  DocPanel :array[0..100] of TPanel;  
  DocPanelTitle :array[0..100] of TLabel;
  SnapButton :array[0..500] of TButton;

  //读取配置文件
  NodeName :array[0..500] of string;


implementation

uses preview;

{$R *.dfm}                       
procedure TVideoForm.initConfig();
var
  ini:TInifile;
  DirectoryLevel:TStringList;
  i:Integer;
begin
      DirectoryLevel := TStringList.Create;
      ini:=TInifile.Create('./Config/Default.ini');
      ini.ReadSection('Directory',DirectoryLevel); 
      for i:=0 to DirectoryLevel.Count-1 do
      begin
        NodeName[i]:=ini.ReadString('Directory',DirectoryLevel[i],'');
      end;
end;

procedure TVideoForm.initControl();
var
  ini:TInifile;
  list:TStringList;
  i,SnapButtonCount:integer;
  j,k:Integer;

begin
      ini:=TInifile.Create('./Config/Default.ini');
      list:=TStringlist.Create;
      ini.ReadSection('Documents',list);
      for i:=0 to list.Count-1 do
      begin
        //初始化按钮的容器panel
        DocPanel[i]:=TPanel.Create(self);
        DocPanel[i].Parent:=ScrollBox1;
        DocPanel[i].Visible:=True;
        DocPanel[i].Width:=280;

        DocPanelTitle[i]:=TLabel.Create(self);
        DocPanelTitle[i].Parent:=DocPanel[i];
        DocPanelTitle[i].Visible:=True;
        DocPanelTitle[i].Width:=280;
        DocPanelTitle[i].Height:=10;
        DocPanelTitle[i].Caption:=list[i];
        DocPanelTitle[i].Top:=DocPanel[i].Top+5;
        DocPanelTitle[i].left:=DocPanel[i].left+5;

        //初始化按钮
        SnapButtonCount:=StrToInt(ini.ReadString('Documents',list[i],'0'));
        if(SnapButtonCount>0) then
        begin

          for j:=1 to SnapButtonCount do
          begin                        
              SnapButton[j]:=TButton.Create(self);
              SnapButton[j].Parent:=DocPanel[i];
              SnapButton[j].Visible:=True;
              SnapButton[j].Width:=50;
              SnapButton[j].height:=50;
              SnapButton[j].Caption:=IntToStr(j);
              SnapButton[j].OnClick:=SnapClick;
              //判断按钮位置，5个换行
              if(j>=1) and (j<=5) then
              begin
                if(j=1) then
                begin
                  SnapButton[j].Top:=25;
                  SnapButton[j].Left :=5;
                end;
                if(j>=2) and (j<=5) then
                begin
                  SnapButton[j].Top:=SnapButton[j-1].Top;
                  SnapButton[j].Left :=SnapButton[j-1].left+55;
                end;
              end
              else
              begin
                k:=Trunc(j/5);           
                if((j mod (k*5))=1) then
                begin
                  if k=1 then
                  begin
                    SnapButton[j].Top:=25+50*k+5;
                    SnapButton[j].Left:=5;
                  end
                  else
                  begin
                    SnapButton[j].Top:=25+50*k+5*k;
                    SnapButton[j].Left:=5;
                    //SnapButton[j].Caption:= IntToStr(SnapButton[j].Top +SnapButton[j].Left);
                  end;
                end
                else
                begin
                  SnapButton[j].Top:=SnapButton[j-1].Top;
                  SnapButton[j].Left:=SnapButton[j-1].Left+55;
                end;
              end;

          end;
        end;
        //初始化panel高度，根据按钮数量 
        DocPanel[i].Height:=35+ ((Trunc(SnapButtonCount/5)+1)*50)+(Trunc(SnapButtonCount/5))*5; 
        if(i=0) then
        begin

            DocPanel[i].Top:=ScrollBox1.top;
            DocPanel[i].Left:=ScrollBox1.Left;
            //DocPanel[i].Height:=35+ ((Trunc(SnapButtonCount/5)+1)*50);
        end;
        if(i>0) then
        begin
            DocPanel[i].Top:=DocPanel[i-1].top+DocPanel[i-1].Height+15;
            DocPanel[i].Left:=DocPanel[i-1].Left;

        end;
      end;

end;
procedure TVideoForm.initDirectory;
var
  ini:TInifile;
  list:TStringList;
  i:integer;
  allName:string;
begin
  //载入配置文件中的目录
  try
      ini:=TInifile.Create('./Config/Default.ini');
      list:=TStringlist.Create;
      ini.ReadSection('Directory',list);
      allName:='';
      for i:=0 to list.Count-1 do
      begin
        allName:=allName+'\'+ini.ReadString('Directory',list[i],'');
        if not DirectoryExists(Document+allName) then
        begin
           CreateDir(Document+allName);
        end;
      end;

  
  finally
    list.free;
    ini.Free;
  end;



end;
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
      BackGroud[i].Parent:=scrlbx_pic;
      BackGroud[i].Visible:=True;
      BackGroud[i].Width:=104;
      BackGroud[i].Height:=118;
      //动态创建BackGroud，作为放置缩略图和图片名的背景
      image[i]:=TImage.Create(self);
      image[i].Parent:=BackGroud[i];
      image[i].Visible:=True;
      image[i].Stretch:=True;
      image[i].Center:=True;
      image[i].Width:=98;
      image[i].Height:=98;
      //动态创建Timage,用来存放缩略图
      ImgNameBak[i]:=TPanel.Create(self);
      ImgNameBak[i].Parent:=BackGroud[i];
      ImgNameBak[i].BevelOuter:=bvNone;
      ImgNameBak[i].Font.Size:=9;
      ImgNameBak[i].Font.Color:=clBlue;
      ImgNameBak[i].Width:=100;
      ImgNameBak[i].Height :=12;
      //动态创建ImgNameBak,用来作为imgname的背景
      ImgName[i]:=TLabel.Create(self);
      ImgName[i].Parent:=ImgNameBak[i];
      ImgName[i].Font.Color :=clBlack;
      ImgName[i].Width:=100;
      //动态创建ImgName,用来存放图片名
      Path :=ShellTreeView1.Path+'\'+Filelist.Strings[i-1];
      //设置文件路径

      Image[i].Picture.LoadFromFile(Path);
      ImgNameBak[i].OnClick:=scrlbx_pic.OnClick;
      ImgNameBak[i].OnDblClick:=scrlbx_pic.OnDblClick;
      ImgNameBak[i].PopupMenu:=PopupMenu2;
      Image[i].OnMouseMove:=scrlbx_pic.OnMouseMove;
      Image[i].OnClick:=scrlbx_pic.OnClick;
      Image[i].OnDblClick:=scrlbx_pic.OnDblClick;
      Image[i].PopupMenu:=PopupMenu2;
      if (Image[i].Picture.Width<98) and (Image[i].Picture.Height<98) then
         Image[i].Stretch:=False;
      //如果图片小于image 的大小则以图片的实际大小显示
      ImgName[i].Caption:= Filelist.Strings[i-1];
      ImgNameBak[i].Caption:=ImgName[i].Caption;
      ImgName[i].Visible:=False;
      //显示图片名，保证图片名 居中
      if(i>=1) and (i<=10) then
      begin
        if(i=1) then
        begin
          BackGroud[i].Top:=8;
          BackGroud[i].Left :=8;
          Image[i].Top:=3;
          Image[i].Left:=3;
          Image[i].Visible:=True;

        end;
        if(i>=2) and (i<=10) then
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
        k:=Trunc(i/10);
        if((i mod (k*10))=1) then
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
  begin   
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
  end
  else
  begin
    ShowMessage('未找到可用设备，程序将退出！');
    ExitProcess(0);
    Application.Terminate;
  end;

    


  



  Document:=ExtractFilePath(Paramstr(0)) +'Document';

  //创建Document目录
  if not DirectoryExists(Document) then
  begin
     CreateDir(Document);
  end;

  //初始化目录，从default.ini文件读取配置
  initDirectory();

  
  //初始化控件，从default.ini文件读取配置
  initControl();

  DirToTreeView(TreeView1,Document,nil,false);
  TreeView1.FullExpand;
  //初始化配置
  initConfig();






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

   //给定的文件不存在，则表示该文件名可以使用
   //   exit;

   N:=1;
   //如果FileName.Ext存在，则编码为FileName(Index).Ext
   //如 TestFile.txt.bak存在，就测试 TestFile.txt(1).bak
   //直到TestFile.txt(N).bak不存在为止

   Result:=MakeFileNameUnique(FileName,N);
   while FileExists(Result) do
   begin
      inc(N);
      Result:=MakeFileNameUnique(FileName,N);
   end;
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

procedure TVideoForm.N1Click(Sender: TObject);
var
  projectName:string;
begin
  projectName:=InputBox( '输入项目名称','项目名称','');
  if trim(projectName)<>'' then
  begin
     
    if not DirectoryExists(ShellTreeView1.Path+'\'+projectName) then
    begin
       CreateDir(ShellTreeView1.Path+'\'+projectName);
    end;
    ShellTreeView1.Refresh(ShellTreeView1.Selected);
    ShellTreeView1.Selected.Expand(true);

  end;
end;



procedure TVideoForm.SnapClick(Sender: TObject);
var
  i:Integer;
  btn:TButton;
  palTitle:TPanel;   
  jp: TJPEGImage;
  Bitmap : TBitmap;
  savejpgname :string;
  node:TTreeNode;
begin
  if(Sender is TButton) then
  begin
    btn:=TButton(Sender);
    palTitle:=TPanel(btn.Parent.Controls[0]);
    //ShowMessage(panel1.Caption);
    //判断选中的是文件夹还是文件
    {
    if ShellTreeView1.SelectedFolder.IsFolder then
    begin
        savejpgname:=ShellTreeView1.Path+'\'+palTitle.Caption+'-'+btn.Caption+'.jpg';
      end
      else
        shelltreeview1.Selected.Parent.Selected := true;
        savejpgname:=ShellTreeView1.Path+'\'+palTitle.Caption+'-'+btn.Caption+'.jpg';
      begin
    end;
    }

      savejpgname:=ShellTreeView1.Path+'\'+palTitle.Caption+'-'+btn.Caption+'.jpg';    
      //ShowMessage(savejpgname);
      //保存捕捉的图片
      jp := TJPEGImage.Create;
      Bitmap := TBitmap.Create;
      SampleGrabber.GetBitmap(Bitmap);
      jp.CompressionQuality := 40;
      jp.Compress ;
      jp.Assign(Bitmap);
      Bitmap.Free;
      jp.SaveToFile(savejpgname);

      //ShellTreeView1.ObjectTypes := [otNonFolders] + ShellTreeView1.ObjectTypes;
      //ShellTreeView1.Items.Item[nodeID].Selected:=true;
      //ShowMessage(IntToStr(nodeID));
      //ShowMessage(IntToStr(Shelltreeview1.Selected.Index));
      //ShellTreeView1.Refresh(ShellTreeView1.Selected);
      
      refreshDir;
      ShowImage;

      
  end;

end;

procedure TVideoForm.ShellTreeView1AddFolder(Sender: TObject;
  AFolder: TShellFolder; var CanAdd: Boolean);
  var
    maskExt : string;
    fileExt : string;
begin
 { maskExt := ExtractFileExt('*.jpg') ;
    fileExt := ExtractFileExt(AFolder.DisplayName) ;
    CanAdd := AFolder.IsFolder OR (CompareText(maskExt,fileExt) = 0) ;
    }
end;

procedure TVideoForm.ShellTreeView1Click(Sender: TObject);
begin
  //不再从treeview选取文件
  {
  if ShellTreeView1.SelectedFolder.IsFolder then
  begin
      imgPreview.Visible:=false;
      VideoWindow.Visible:=True;
  end
  else
  begin
      imgPreview.Visible:=True;
      VideoWindow.Visible:=false;

      
      imgPreview.Stretch :=True;
      imgPreview.Picture.LoadFromFile(ShellTreeView1.Path);
      if(imgPreview.Picture.Width<imgPreview.Width) and (imgPreview.Picture.Height<imgPreview.Height) then
      imgPreview.Stretch:=False;


  end;
    //ShowMessage(ShellTreeView1.Path);
    }
    StatusBar1.SimpleText:='当前选择项目：'+ShellTreeView1.Selected.Text;
    
  //刷新目录文件列表
  refreshDir;
  ShowImage;
end;

procedure TVideoForm.scrlbx_picMouseMove(Sender: TObject;
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
      path1:= ShellTreeView1.Path+'\'+FileList.strings[NamPos-1];
      ScrollBox1.Hint:='文件名:'+Filelist.strings[nampos-1]+#13+'图像大小:'+ IntToStr(Image[ImgPos].Picture.Width)+'          X'+ IntToStr(Image[ImgPos].Picture.Height)+'像素';
    end;

end;

procedure TVideoForm.scrlbx_picClick(Sender: TObject); 
var
  path1:string;
begin        
  if((Sender is TImage)or (Sender is TLabel)) then
  begin
    imgPreview.Visible:=True;
    VideoWindow.Visible:=false;

    path1:=ShellTreeView1.Path+'\'+ Filelist.Strings[NamPos-1];
    imgPreview.Stretch :=True;
    imgPreview.Picture.LoadFromFile(path1);
    if(imgPreview.Picture.Width<imgPreview.Width) and (imgPreview.Picture.Height<imgPreview.Height) then
    imgPreview.Stretch:=False;
    //如果图片小于image1 的大小则以图片的实际大小显示
  end;
end;

procedure TVideoForm.imgPreviewDblClick(Sender: TObject);
begin
  imgPreview.Visible:=False;
  VideoWindow.Visible:=True;
end;

procedure TVideoForm.imgPreviewClick(Sender: TObject);
begin

  imgPreview.Visible:=False;
  VideoWindow.Visible:=True;
end;

procedure TVideoForm.N3Click(Sender: TObject); 
var
  path1:string;
begin
  
  if((TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent.ClassName='TImage') or (TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent.ClassName='TLabel')) then
  begin
    path1:=Filelist.Strings[NamPos-1];
    DeleteFile(ShellTreeView1.path+'\'+path1);
    DeleteImage(NamPos);
    ShowImage;
  end;

end;

//读取目录，初始化treeview
procedure TVideoForm.DirToTreeView(Tree: TTreeView; Directory: string; Root: TTreeNode; IncludeFiles:
  Boolean);
var
  SearchRec         : TSearchRec;
  ItemTemp          : TTreeNode;
begin
  with Tree.Items do
  try
    BeginUpdate;
    if Directory[Length(Directory)] <> '\' then Directory := Directory + '\';
    if FindFirst(Directory + '*.*', faDirectory, SearchRec) = 0 then
    begin
      repeat
        if (SearchRec.Attr and faDirectory = faDirectory) and (SearchRec.Name[1] <> '.') then
        begin
          if (SearchRec.Attr and faDirectory > 0) then
            Root := AddChild(Root, SearchRec.Name);
          ItemTemp := Root.Parent;
          DirToTreeView(Tree, Directory + SearchRec.Name, Root, IncludeFiles);
          Root := ItemTemp;
        end
        else if IncludeFiles then
          if SearchRec.Name[1] <> '.' then
            AddChild(Root, SearchRec.Name);
      until FindNext(SearchRec) <> 0;
      FindClose(SearchRec);
    end;
  finally
    EndUpdate;
  end;
end;

procedure TVideoForm.TreeView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    Node : TTreeNode;
    cursorPos:TPoint;
    vlItem: TMenuItem;
    i:Integer;
begin

  if Button = mbRight then
  begin
      GetCursorPos(cursorPos);
      vlItem := TMenuItem.Create(Self);
      vlItem.OnClick:=TreeviewRightClick;

      if  treeView1.GetNodeAt(x,y)<>nil then
      begin

             Node:=TreeView1.GetNodeAt(x,y);
             Node.Selected:=true;
               if( Node.Level>=0) and (NodeName[Node.Level+1]<>'' )then
               begin
                 vlItem.Caption := '新建'+NodeName[Node.Level+1];
                 vlItem.Hint:=IntToStr(Node.Level+1);
               end;
      end
      else
      begin
          vlItem.Caption := '新建'+NodeName[0];
          vlItem.Hint:=IntToStr(0);
      end;
      PopupMenu3.Items.Clear;

      popupmenu3.Items.Add(vlItem);
      if(vlItem.Caption<>'') then
        popupmenu3.Popup(cursorPos.X, cursorPos.Y);
      end;
end;

procedure TVideoForm.TreeviewRightClick(Sender: TObject); 
var
  projectName:string; 
    Node : TTreeNode;
    menuItem:TMenuItem;
begin
  projectName:=InputBox( '输入项目名称','项目名称','');
  if trim(projectName)<>'' then
  begin
     menuItem:=TMenuItem(Sender);
      if(menuItem.Hint='0')then
      begin
         if not DirectoryExists(Document+'\'+projectName) then
          begin
             CreateDir(Document+projectName);
          end;
        end
        else
         Node:=TreeView1.Selected;
         while Node.Level>0 do
         begin
           projectName:=Node.Text+'\'+projectName;
           Node:=Node.Parent;
         end;
         if(Node.Level=0) then
         begin                        
           projectName:=Node.Text+'\'+projectName;
           Node:=Node.Parent;
         end;
         if not DirectoryExists(Document+'\'+projectName) then
          begin
             CreateDir(Document+'\'+projectName);
          end;
      TreeView1.Items.Clear();
      DirToTreeView(TreeView1,Document,nil,false);
      TreeView1.FullExpand;
  end;

end;

end.
