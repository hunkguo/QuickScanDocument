unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DSUtil, StdCtrls, DSPack, DirectShow9, Menus, ExtCtrls,jpeg,
  ComCtrls, ImgList,IniFiles, ShellCtrls, CnButtons, WinSkinData;

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
    scbMain: TScrollBox;
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

    procedure TreeviewRightClick(Sender: TObject);
    
    procedure ShowImage();
    procedure ClearImage();
    procedure DeleteImage(i:Integer);
    procedure initDirectory();
    procedure initControl();
    procedure initConfig();
    procedure SetButtonPosition(Buttons:array of TCnButton);

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SnapClick(Sender: TObject);
    procedure SnapNextClick(Sender: TObject);

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
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure TreeView1CustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
 
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


  //动态生成控件部分
  DocumentsTypeName :array of string;     //读取配置文件中文档类型部分 名称
  DocumentsTypeNum :array of string;     //读取配置文件中文档类型部分 页数
  DocPanel :array of TPanel;              //一种文档类型一个Panel
  DocTitle :array of TLabel;              //文档的标题
  Docscb :array of TScrollBox;      //文档的扫描按钮容器，可以滚动
  DocBut :array of array of TCnButton;   //定义二维数组，存放button

  //读取配置文件
  NodeName :array[0..500] of string;
  Connector:string;   //文件命名连接符



implementation



{$R *.dfm}                       
procedure TVideoForm.initConfig();
var
  ini:TInifile;
  DirectoryLevel,docs:TStringList;
  i:Integer;
begin
      DirectoryLevel := TStringList.Create;
      try

        ini:=TInifile.Create('./Config/Default.ini');
        ini.ReadSection('Directory',DirectoryLevel);
        for i:=0 to DirectoryLevel.Count-1 do
        begin
          NodeName[i]:=ini.ReadString('Directory',DirectoryLevel[i],'');
        end;

        docs := TStringList.Create;
        ini.ReadSection('Documents',docs);
        SetLength(DocumentsTypeName,docs.Count);
        SetLength(DocumentsTypeNum,docs.Count);
        for i:=0 to docs.Count-1 do
        begin
          DocumentsTypeNum[i]:=ini.ReadString('Documents',docs[i],'');
          DocumentsTypeName[i]:=docs[i];
        end;

        Connector:=ini.ReadString('Connector','symbol','-');
      except
          ShowMessage('配置文件读取错误，程序将退出！');              
          ExitProcess(0);
          Application.Terminate;
      end;
end;

procedure TVideoForm.initControl();
var
  ini:TInifile;
  list:array of string;
  i:Integer;
  SnapButtonCount:string;
  j:Integer;
  row,col,butCount,PanelHeigh,ScbHeigh:Integer;
begin
      try
      for i:=Low(DocumentsTypeName) to High(DocumentsTypeName) do
      begin
          //初始化文档的容器Panel
          SetLength(DocPanel,Length(DocumentsTypeName));
          DocPanel[i]:=TPanel.Create(self);
          DocPanel[i].Parent:=scbMain;
          DocPanel[i].Visible:=True;
          DocPanel[i].Width:=275;
          DocPanel[i].Height:=60;       //默认高度，后期需根据按钮数量调整
          DocPanel[i].BevelInner:=bvNone;
          DocPanel[i].BevelOuter:=bvNone;

          //初始化文档标题
          SetLength(DocTitle,Length(DocumentsTypeName));
          DocTitle[i]:=TLabel.Create(self);
          DocTitle[i].Parent:=DocPanel[i];
          DocTitle[i].Visible:=True;
          DocTitle[i].Width:=200;
          DocTitle[i].Height:=20;
          DocTitle[i].Caption:=DocumentsTypeName[i];
          DocTitle[i].Top:=DocPanel[i].Top+5;
          DocTitle[i].left:=DocPanel[i].Left+5;

           //初始化按钮滚动框
          SetLength(Docscb,Length(DocumentsTypeName));
          Docscb[i]:=TScrollBox.Create(self);
          Docscb[i].Parent:=DocPanel[i];
          Docscb[i].Visible:=True;
          Docscb[i].Width:=275;
          Docscb[i].Height:=120;
          Docscb[i].Top:=DocTitle[i].Top+25;
          Docscb[i].left:=DocTitle[i].Left+3;
          Docscb[i].BorderStyle:=bsNone;



          //添加按钮          
          SetLength(DocBut,Length(DocumentsTypeNum));
          //ShowMessage(IntToStr(Low(DocBut)));
          //ShowMessage(IntToStr(High(DocBut)));
          if(DocumentsTypeNum[i]='n')then
          begin
            SetLength(DocBut[i],1);
            DocBut[i][0]:=TCnButton.Create(self);
            DocBut[i][0].Parent:=Docscb[i];
            DocBut[i][0].Visible:=True;
            DocBut[i][0].Width:=50;
            DocBut[i][0].Height:=50;
            DocBut[i][0].Caption:='扫描新页';
            DocBut[i][0].Tag:=i;
            DocBut[i][0].Hint:='new';
            DocBut[i][0].OnClick:=SnapNextClick;
            //设置按钮位置
            SetButtonPosition(DocBut[i]);
            end
            else
            for  j:=0 to  StrToInt(DocumentsTypeNum[i])-1 do
            begin
              SetLength(DocBut[i],j+1);
              DocBut[i][j]:=TCnButton.Create(self);
              DocBut[i][j].Parent:=Docscb[i];
              DocBut[i][j].Visible:=True;
              DocBut[i][j].Width:=50;
              DocBut[i][j].Height:=50;
              DocBut[i][j].Caption:=IntToStr(j+1);
              DocBut[i][j].Tag:=i;
              DocBut[i][j].OnClick:=SnapClick;

                  
              //设置按钮位置
              SetButtonPosition(DocBut[i]);
            end;
            

          if(i=0) then
          begin
              DocPanel[i].Top:=scbMain.Top+15;
              DocPanel[i].left:=scbMain.left;
          end
          else
          begin
              DocPanel[i].Top:=DocPanel[i-1].Top+DocPanel[i-1].Height;
              DocPanel[i].left:=DocPanel[i-1].left;
          end;

          
          butCount:=High(DocBut[i]);
          row:=(butCount div 5)+1;
          if(row=0) then
          begin
             ScbHeigh:=55;
             PanelHeigh:=90;
          end
          else
          begin
            ScbHeigh:=50+row*55;
            PanelHeigh:=90+row*55;
          end;
          DocPanel[i].Height:=PanelHeigh;
          Docscb[i].Height:=ScbHeigh;

      end;
      except
          ShowMessage('控件初始化错误');
      end;



      end;
procedure TVideoForm.SetButtonPosition(Buttons:array of TCnButton);
var
  i,row,col,butCount,PanelHeigh,ScbHeigh:Integer;
begin
      for  i:=Low(Buttons) to  High(Buttons) do
      begin
      //显示图片名，保证图片名 居中
      //showmessage(inttostr(High(Buttons)));
      //mod取余 得到 属于哪列，主要区别第一列
      //div 整除，得到第几行
      row:=i div 5;
      col:=i mod 5;
      
        if(row=0) then
        begin
          if(col=0) then
          begin
            Buttons[i].Left:=0;
            //ShowMessage(IntToStr(Buttons[i].Parent.top));
            Buttons[i].top:=0;
          end
          else
          begin
            Buttons[i].Left:=Buttons[i-1].Left+53;
            Buttons[i].top:=Buttons[i-1].top;
          end;
        end
        else
        begin
          if(col=0) then
          begin
            Buttons[i].Left:=0;
            Buttons[i].top:=(row)*55;
          end
          else
          begin
            Buttons[i].Left:=Buttons[i-1].Left+53;
            Buttons[i].top:=Buttons[i-1].top;
          end;

        end;
          //Buttons[i].Caption:='第'+inttostr(row)+'行,第'+inttostr(col)+'列';
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
  except    
    list.free;
    ini.Free;
    ShowMessage('目录初始化错误');
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
  try
  if not DirectoryExists(Document) then
  begin
     CreateDir(Document);
  end;
  except
    ShowMessage('Document目录初始化错误');
  end;
                      
  //初始化配置
  initConfig();   
  //初始化控件，从default.ini文件读取配置
  initControl();
  
  //初始化目录，从default.ini文件读取配置
  initDirectory();


  try
  DirToTreeView(TreeView1,Document,nil,false);
  TreeView1.FullExpand;
  except
    ShowMessage('读取目录结构错误');
  end;





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

procedure TVideoForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Filelist.Free;
  ClearImage;
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
    EndUpdate;
  except    
      EndUpdate;
     ShowMessage('读取目录结构,初始化treeview错误');

  end;
end;




function GetTreeviewNodeDir(const t:TTreeview):string;
var
  dir:string;
  Node : TTreeNode;
begin
  dir:='';
  Node:=t.Selected;
  while Node.Level>0 do
  begin

    if(dir='')then
    begin
      dir:=Node.Text+'\';
    end
    else
    begin
      dir:=Node.Text+'\'+dir;
    end;

    //dir:='\'+Node.Text+'\'+dir;
   Node:=Node.Parent;
  end;
  if(Node.Level=0) then
  begin
     dir:=ExtractFilePath(Paramstr(0))+'Document\'+Node.Text+'\'+dir;
   //dir:=ExtractFilePath(Paramstr(0))+'Document\'+Node.Text+dir;
   Node:=Node.Parent;
  end;
  Result:=dir;

end;

 
procedure TVideoForm.TreeView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    Node : TTreeNode;
    cursorPos:TPoint;
    vlItem: TMenuItem;
    i:Integer;
begin
  if Button = mbLeft then
  begin           
      GetCursorPos(cursorPos);
      if  treeView1.GetNodeAt(x,y)<>nil then
      begin          
        ShowImage();
      end;
  end;


  if Button = mbRight then
  begin
      GetCursorPos(cursorPos);
      vlItem := TMenuItem.Create(Self);
      vlItem.OnClick:=TreeviewRightClick;

      if  treeView1.GetNodeAt(x,y)<>nil then
      begin

             Node:=TreeView1.GetNodeAt(x,y);
             Node.Selected:=true;
               if( Node.Level>=0) then
               begin
                 if(NodeName[Node.Level+1]<>'' )then
                 begin
                   vlItem.Caption := '新建'+NodeName[Node.Level+1];
                   vlItem.Hint:=IntToStr(Node.Level+1);
                   {
                 end
                 else
                 begin
                   vlItem.Caption := '新建';
                   vlItem.Hint:=IntToStr(Node.Level+1);
                   }
                 end;
               end;
               //ShowMessage(IntToStr(Node.Level));
               //ShowMessage(  NodeName[Node.Level+1]);
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
     try
      if(menuItem.Hint='0')then
      begin
         if not DirectoryExists(Document+'\'+projectName) then
          begin
             CreateDir(Document+'\'+projectName);
          end;
      end
      else
      begin
         if not DirectoryExists(GetTreeviewNodeDir(TreeView1)+'\'+projectName) then
          begin
             CreateDir(GetTreeviewNodeDir(TreeView1)+'\'+projectName);
          end;
      end;
      except
        ShowMessage('创建项目目录错误');
      end;
      TreeView1.Items.Clear();
      DirToTreeView(TreeView1,Document,nil,false);
      TreeView1.FullExpand;
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

    try
    path1:=GetTreeviewNodeDir(TreeView1)+'\'+ Filelist.Strings[NamPos-1];
    imgPreview.Stretch :=True;
    imgPreview.Picture.LoadFromFile(path1);
    if(imgPreview.Picture.Width<imgPreview.Width) and (imgPreview.Picture.Height<imgPreview.Height) then
    imgPreview.Stretch:=False;
    except
      ShowMessage('读取图片错误');
    end;
    //如果图片小于image1 的大小则以图片的实际大小显示
  end;
end;



procedure TVideoForm.SnapClick(Sender: TObject);
var
  i:Integer;
  btn:TCnButton;
  labTitle:TLabel;
  jp: TJPEGImage;
  Bitmap : TBitmap;
  savejpgname :string;
  node:TTreeNode;
  dlgResult:Integer;
begin
  if(Sender is TCnButton) then
  begin
    btn:=TCnButton(Sender);
    labTitle:=TLabel(btn.Parent.Parent.Controls[0]);
    if(btn.Font.Style= [fsbold]) then
    begin
      //ShowMessage('文件已存在，确认扫描？');
      dlgResult:=MessageBox(Handle,'文件已存在，确认重新扫描？','确认',MB_OKCANCEL);
      if dlgResult = 2 then
      begin
          exit;
      end;
    end;

      try
      savejpgname:=GetTreeviewNodeDir(TreeView1)+'\'+labTitle.Caption+Connector+btn.Caption+'.jpg';
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
      except
        ShowMessage('图像捕捉成功，保存失败');
      end;
      ShowImage;
      
  end;

end;

function SplitString(const source, ch: string): TStringList;
var
  temp, t2: string;
  i: integer;
begin
  result := TStringList.Create;
  temp := source;
  i := pos(ch, source);
  while i <> 0 do
  begin
    t2 := copy(temp, 0, i - 1);
    if (t2 <> '') then
      result.Add(t2);
    delete(temp, 1, i - 1 + Length(ch));
    i := pos(ch, temp);
  end;
  result.Add(temp);
end;

procedure TVideoForm.ShowImage;
var
  i,j,k,docButPos,btnCount:Integer;  
 SearchRec:TSearchRec;
 found:integer;
 docPanName,docButName:string;
 strs:TStringList;
  begin
    //获取当前选择节点，显示其中图片文件
    try
      StatusBar1.SimpleText:=GetTreeviewNodeDir(TreeView1);
    if not Assigned(Filelist) then
    begin
      Filelist := TStringList.Create;
    end;
    Filelist.Clear();
    found:=FindFirst(GetTreeviewNodeDir(TreeView1)+'*.jpg',faAnyFile,SearchRec);
     while    found=0    do
       begin
           if (SearchRec.Name<>'.')  and (SearchRec.Name<>'..')
                 and    (SearchRec.Attr<>faDirectory)    then
               Filelist.Add(SearchRec.Name);
           found:=FindNext(SearchRec);
       end;
     FindClose(SearchRec);
    except
      ShowMessage('读取当前项目下的图片失败');
    end;

    ClearImage();
    imgcount:=Filelist.count;
    try
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
      Path :=GetTreeviewNodeDir(TreeView1)+'\'+Filelist.Strings[i-1];
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
    except
      ShowMessage('调整图片位置发生错误');
    end;

    //读取图片列表，判断所属的panel，如果是动态按钮，添加之
    for i:=0 to Imgcount-1 do
    begin
      strs := SplitString(Filelist[i], connector);
      docPanName:=Strs[0];
      docButName:=Strs[1];
      docButPos:=StrToInt(docButName);
      //ShowMessage(docPanName+'###########'+docButName);
      for j:=Low(DocumentsTypeName) to High(DocumentsTypeName) do
      begin
         //如果文件名相同，且控件数目为n,遍历buts
         if(DocumentsTypeName[j]=docPanName) and (DocumentsTypeNum[j]='n')then
         begin
            btnCount:=Length(DocBut[j]);
            if(btnCount<=docButPos) then
            begin
              try
                SetLength(DocBut[j],btnCount+1);
                DocBut[j][btnCount]:=TCnButton.Create(self);
                DocBut[j][btnCount].Parent:=Docscb[j];
                DocBut[j][btnCount].Visible:=True;
                DocBut[j][btnCount].Width:=50;
                DocBut[j][btnCount].Height:=50;
                DocBut[j][btnCount].Caption:=IntToStr(btnCount);
                DocBut[j][btnCount].Tag:=i;
                DocBut[j][btnCount].OnClick:=SnapClick;
                DocBut[j][btnCount].Color:=clBlue;
                DocBut[j][btnCount].Font.Color:=clWhite;
                DocBut[j][btnCount].Font.Style:= [fsbold];
                SetButtonPosition(DocBut[j]);
              except
                ShowMessage('动态添加按钮发生错误');
              end;
            end;
        end
        else
        begin
          //ShowMessage(DocBut[j][docButPos].Caption);
          //DocBut[j][docButPos].Font.Color:=clRed;
          try
          if(DocumentsTypeName[j]=docPanName) then
            DocBut[j][docButPos-1].Font.Style:= [fsbold];
          except
            ShowMessage('按钮与图片匹配错误');
          end;
        end;
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




procedure TVideoForm.scrlbx_picMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);   
var
  path1:string;
begin 
  ImgPos:=0;
  try
  if not Assigned(Filelist) then
  begin
    Filelist := TStringList.Create;
  end;
  for ImgPos:=1 to Filelist.Count do
    if((Sender =Image[ImgPos]) or (Sender = imgName[ImgPos])) then
    begin
      NamPos:= ImgPos;
      path1:= GetTreeviewNodeDir(TreeView1)+'\'+FileList.strings[NamPos-1];
      scbMain.Hint:='文件名:'+Filelist.strings[nampos-1]+#13+'图像大小:'+ IntToStr(Image[ImgPos].Picture.Width)+'          X'+ IntToStr(Image[ImgPos].Picture.Height)+'像素';
    end;
  except
    ShowMessage('读取图片信息失败');
  end;

end;


procedure TVideoForm.N3Click(Sender: TObject); 
var
  path1:string;
begin
  
  if((TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent.ClassName='TImage') or (TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent.ClassName='TLabel')) then
  begin
    try
    path1:=Filelist.Strings[NamPos-1];
    DeleteFile(GetTreeviewNodeDir(TreeView1)+'\'+path1);
    DeleteImage(NamPos);
    ShowImage;
    except
      ShowMessage('删除图片发生错误');
    end;
  end;
end;


procedure TVideoForm.SnapNextClick(Sender: TObject);
var
  i,btnCount:Integer;
  btn:TCnButton;
  labTitle:TLabel;
  jp: TJPEGImage;
  Bitmap : TBitmap;
  savejpgname :string;
  node:TTreeNode;     
  row,col,butCount,PanelHeigh,ScbHeigh:Integer;
begin

  if(Sender is TCnButton) then
  begin
    btn:=TCnButton(Sender);
    //ShowMessage(IntToStr(btn.Tag));
    i:=btn.Tag;
    btnCount:=length(DocBut[btn.Tag]);
    try
    SetLength(DocBut[i],btnCount+1);
    DocBut[i][btnCount]:=TCnButton.Create(self);
    DocBut[i][btnCount].Parent:=Docscb[i];
    DocBut[i][btnCount].Visible:=True;
    DocBut[i][btnCount].Width:=50;
    DocBut[i][btnCount].Height:=50;
    DocBut[i][btnCount].Caption:=IntToStr(btnCount);
    DocBut[i][btnCount].Tag:=i;
    DocBut[i][btnCount].OnClick:=SnapClick;
    DocBut[i][btnCount].Font.Style:= [fsbold];
    DocBut[i][btnCount].Font.Color:=clWhite;
    DocBut[i][btnCount].Color:=clBlue;

    SetButtonPosition(DocBut[i]);
    except
      ShowMessage('动态添加按钮发生错误');
    end;
    try
    for i:=Low(DocumentsTypeName) to High(DocumentsTypeName) do
      begin
          if(i=0) then
          begin
              DocPanel[i].Top:=scbMain.Top+15;
              DocPanel[i].left:=scbMain.left;
          end
          else
          begin
              DocPanel[i].Top:=DocPanel[i-1].Top+DocPanel[i-1].Height;
              DocPanel[i].left:=DocPanel[i-1].left;


          end;
    
          
          butCount:=High(DocBut[i]);
          row:=(butCount div 5)+1;
          if(row=0) then
          begin
             ScbHeigh:=55;
             PanelHeigh:=90;
          end
          else
          begin
            ScbHeigh:=50+row*55;
            PanelHeigh:=90+row*55;
          end;
          DocPanel[i].Height:=PanelHeigh;
          Docscb[i].Height:=ScbHeigh;
      end;
      except
        ShowMessage('调整按钮位置发生错误');
      end;

      //保存图片
      
      labTitle:=TLabel(btn.Parent.Parent.Controls[0]);
      try
      savejpgname:=GetTreeviewNodeDir(TreeView1)+'\'+labTitle.Caption+Connector+inttostr(btnCount)+'.jpg';
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
      ShowImage;
      except
        ShowMessage('文件保存错误,请选择保存位置');
      end;

  end;
  end;





procedure TVideoForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  posi:integer;
begin
     posi := scbmain.vertScrollBar.Position - 25 ;
     if scbmain.vertScrollBar.Position < 0 then posi := 0;
      scbmain.vertScrollBar.Position := posi;
end;

procedure TVideoForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin     
       scbmain.vertScrollBar.Position := scbmain.vertScrollBar.Position + 25 ;
end;

//在失去焦点时依然保持选中状态显示
procedure TVideoForm.TreeView1CustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
    if node.Selected then
    begin
      TreeView1.Canvas.Brush.Style := bsSolid;
      TreeView1.Canvas.Brush.Color := clBlue;
    end;
end;

end.
