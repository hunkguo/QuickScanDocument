unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DSUtil, StdCtrls, DSPack, DirectShow9, Menus, ExtCtrls,jpeg,
  ComCtrls, ImgList,IniFiles, ShellCtrls,  auHTTP, auAutoUpgrader,Filectrl,ShlObj,
 cxButtons, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters,StrUtils;

type
  TVideoForm = class(TForm)
    FilterGraph: TFilterGraph;
    MainMenu1: TMainMenu;
    Devices: TMenuItem;
    Filter: TFilter;
    SampleGrabber: TSampleGrabber;
    VideoWindow: TVideoWindow;
    scbMain: TScrollBox;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    imgPreview: TImage;
    scrlbx_pic: TScrollBox;
    PopupMenu2: TPopupMenu;
    StatusBar1: TStatusBar;
    N3: TMenuItem;
    PopupMenu3: TPopupMenu;
    N2: TMenuItem;
    NewProject: TMenuItem;
    OpenProject: TMenuItem;
    auAutoUpgrader1: TauAutoUpgrader;
    tvDir: TTreeView;
    Version: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure DirToTreeView(Tree: TTreeView; Directory: string; Root: TTreeNode; IncludeFiles:
  Boolean);                                                              
    procedure InitConfig();
    procedure InitTreeView;
    procedure InitDocName;
    procedure tvDirMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TreeviewRightClick(Sender: TObject);
    procedure ClearImage;
    procedure ShowImage;  
    //procedure ClearBut;
    procedure ShowBut;
    procedure ImageButCompare;      //��ͼƬ�밴ť�Ƚϣ���ͼƬ�ļӴ�
    procedure ClearBut();  //�����ť

    procedure SetButtonPosition(Buttons:array of TcxButton); 
    procedure SnapClick(Sender: TObject);
    procedure SnapNextClick(Sender: TObject); 
    procedure NewProjectClick(Sender: TObject);
    procedure OpenProjectClick(Sender: TObject); 
    procedure NewAndOpenInit();
    procedure VersionClick(Sender: TObject);
    procedure DeleteImage(i:Integer);
    procedure N3Click(Sender: TObject);
    procedure imgPreviewClick(Sender: TObject);
    procedure imgPreviewDblClick(Sender: TObject);
    procedure scrlbx_picClick(Sender: TObject);
    procedure scrlbx_picMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure tvDirCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
 
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

  //��ȡ�����ļ�
  Connector:string;   //�ļ��������ӷ�

  ProjectDir,ProjectName:string;      //������ĿĿ¼
  DirectoryLevel:array[0..100] of string;        //�����ĵ��ڵ㼶��


  //��̬���ɿؼ�����
  DocumentsTypeName :array of string;     //��ȡ�����ļ����ĵ����Ͳ��� ����
  DocumentsTypeNum :array of string;     //��ȡ�����ļ����ĵ����Ͳ��� ҳ��
  DocPanel :array of TPanel;              //һ���ĵ�����һ��Panel
  DocTitle :array of TLabel;              //�ĵ��ı���
  Docscb :array of TScrollBox;      //�ĵ���ɨ�谴ť���������Թ���
  DocBut :array of array of TcxButton;   //�����ά���飬���button





implementation



{$R *.dfm}
function ReversePos(SubStr, S: String): Integer;
var
  i : Integer;
  begin
  i := Pos(ReverseString(SubStr), ReverseString(S));
  if i>0 then
    i := Length(S)- i- Length(SubStr)+2;
  Result := i;
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



//��ȡĿ¼����ʼ��treeview
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
          if (SearchRec.Attr and faDirectory > 0) and (SearchRec.Name<>'Config') then
          begin
            Root := AddChild(Root, SearchRec.Name);
          ItemTemp := Root.Parent;
          DirToTreeView(Tree, Directory + SearchRec.Name, Root, IncludeFiles);
          Root := ItemTemp;
          end;
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
     ShowMessage('��ȡĿ¼�ṹ,��ʼ��treeview����');

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
  dir:=ProjectDir+'\'+dir;
  Result:=dir;

end;

function CheckProject():Boolean;
  begin
    if(DirectoryExists(ProjectDir)) and (FileExists(ProjectDir+'\Config\Default.ini')) then
    begin
       Result:= True;
    end
    else
    begin
      Result:=False;
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
  tvDir.Free;
  scbMain.Free;
  scrlbx_pic.Free;
end;


procedure TVideoForm.FormCreate(Sender: TObject);
var
  i: integer;
  Device: TMenuItem;
  ini:TInifile;
  str:string;
begin
  
  //ShowMessage(auAutoUpgrader1.VersionNumber);
  //�Զ�����
  auAutoUpgrader1.CheckUpdate(true);

   {
   str:='Office2010Silver.skinres'; //�˴����λ�����޸�,�������������Ƥ����Դ��,
                                                   //�������е�Ƥ����Դ�ļ�.
   dxSkinsUserSkinLoadFromFile(Trim(ExtractFilePath(Application.ExeName)) + '\skin\' + str);
   dxSkinController1.NativeStyle:=False;
   dxSkinController1.UseSkins:=True;
   }

 
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
    ShowMessage('δ�ҵ������豸�������˳���');
    ExitProcess(0);
    Application.Terminate;
  end;

  try
    ini:=TInifile.Create('./Config/OpenHistory.ini');
    ProjectDir:=ini.ReadString('LastProjectPath','path','');
    ProjectName:=ini.ReadString('LastProjectPath','ProjectName','');
  except
    ShowMessage('��ȡ�ϴδ򿪼�¼ʧ��');
  end;

  if(ProjectDir<>'') and (ProjectName<>'') and (CheckProject()) then
  begin
    InitConfig;
    InitTreeView;
    InitDocName;
  end;
end;


procedure TVideoForm.InitConfig();
var
  ini:TInifile;
  tmp:TStringList;
  i,p:Integer;
  begin
          tmp := TStringList.Create;
          ini:=TInifile.Create(ProjectDir+'/Config/Default.ini');
          ini.ReadSection('Directory',tmp);
          for i:=0 to tmp.Count-1 do
          begin
            DirectoryLevel[i]:=ini.ReadString('Directory',tmp[i],'');
          end;

          tmp.Clear;
          ini.ReadSection('Documents',tmp);
          SetLength(DocumentsTypeName,tmp.Count);
          SetLength(DocumentsTypeNum,tmp.Count);
          for i:=0 to tmp.Count-1 do
          begin
            DocumentsTypeNum[i]:=ini.ReadString('Documents',tmp[i],'');
            DocumentsTypeName[i]:=tmp[i];
          end;

          Connector:=ini.ReadString('Connector','symbol','');
          ProjectName:=ini.ReadString('Project','ProjectName','');

          
            if(ProjectName='') then
            begin
                p:=ReversePos('\',ProjectDir);
                ProjectName:=Copy(PChar(ProjectDir),p+1,Length(ProjectDir)-p);
                ini.writestring('Project','ProjectName',ProjectName);
            end;

          ini:=TInifile.Create('./Config/OpenHistory.ini');
          //д����Ŀ�������ļ�����Ŀ����
          ini.writestring('LastProjectPath','ProjectName',ProjectName);
          ini.writestring('LastProjectPath','path',ProjectDir);
  end;
procedure TVideoForm.InitTreeView();
  begin
      try
        if(DirectoryExists(ProjectDir)) and (ProjectDir<>ExtractFilePath(Paramstr(0))) then
        begin
              tvDir.items.Clear;
              tvDir.Items.AddFirst( nil,ProjectName );
              DirToTreeView(tvDir,ProjectDir,tvDir.Items.GetFirstNode,false);
              tvDir.FullExpand;
        end;

      except
        ShowMessage('��ȡĿ¼�ṹ����');
      end;
  end;
procedure TVideoForm.InitDocName();
var         
  i:Integer;
  btn:TcxButton;
  begin
      for i:=Low(DocumentsTypeName) to High(DocumentsTypeName) do
      begin           
          //��ʼ���ĵ�������Panel
          SetLength(DocPanel,Length(DocumentsTypeName));
          DocPanel[i]:=TPanel.Create(self);
          DocPanel[i].Parent:=scbMain;
          DocPanel[i].Width:=290;
          DocPanel[i].Height:=190;       //Ĭ�ϸ߶ȣ���������ݰ�ť��������
          DocPanel[i].BevelInner:=bvNone;
          DocPanel[i].BevelOuter:=bvNone;

          //��ʼ���ĵ�����
          SetLength(DocTitle,Length(DocumentsTypeName));
          DocTitle[i]:=TLabel.Create(self);
          DocTitle[i].Parent:=DocPanel[i];
          DocTitle[i].Width:=290;
          DocTitle[i].Height:=20;
          DocTitle[i].Caption:=DocumentsTypeName[i];
          DocTitle[i].Top:=DocPanel[i].Top+5;
          DocTitle[i].left:=DocPanel[i].Left+15;

           //��ʼ����ť������
          SetLength(Docscb,Length(DocumentsTypeName));
          Docscb[i]:=TScrollBox.Create(self);
          Docscb[i].Parent:=DocPanel[i];
          Docscb[i].Width:=290;
          Docscb[i].Height:=100;
          Docscb[i].Top:=DocTitle[i].Top+25;
          Docscb[i].left:=DocTitle[i].Left+3;
          Docscb[i].BorderStyle:=bsNone;

          //��ʼ����ť����
          SetLength(DocBut,i+1);
          if(DocumentsTypeNum[i]='n') then
          begin
              //SetLength(DocBut[i],1);
              btn:=TcxButton.Create(self);
              btn.Parent:=DocPanel[i];
              btn.Visible:=True;
              btn.Width:=100;
              btn.Height:=30;
              btn.Caption:='ɨ����ҳ';//+inttostr(i);
              btn.Tag:=i;
              btn.Hint:='new';
              btn.OnClick:=SnapNextClick;
              //���ð�ťλ��
              //SetButtonPosition(DocBut[i]);
              btn.Left:=DocTitle[i].left+100;
              btn.Top:=DocTitle[i].Top-6;
          end;




          if(i=0) then
          begin
              DocPanel[i].Top:=scbMain.Top+15;
              //DocPanel[i].left:=scbMain.Left;
          end
          else
          begin
              DocPanel[i].Top:=DocPanel[i-1].Top+DocPanel[i-1].Height;
              //DocPanel[i].left:=DocPanel[i-1].left;
          end;




      end;
  end;






procedure TVideoForm.tvDirMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    Node : TTreeNode;
    cursorPos:TPoint;
    vlItem: TMenuItem;
    i,j,k:Integer;
begin  
  GetCursorPos(cursorPos);
  Node:=tvDir.GetNodeAt(x,y);
  //�����ѡ��ڵ�
  if Button = mbLeft then
  begin
        ClearBut();
        ClearImage();
    if  (Node<>nil) and (DirectoryLevel[Node.Level]='') then
      begin
        //��ʾĿ¼��ͼƬ
        ShowImage();
        //��ʾ��ť
        ShowBut();
      end;
  end;

  //�Ҽ��˵����½���Ŀ
  if Button = mbRight then
  begin
      vlItem := TMenuItem.Create(Self);
      vlItem.OnClick:=TreeviewRightClick;
      if  Node<>nil then
      begin
             Node.Selected:=true;
               if( Node.Level>=0) and (DirectoryLevel[Node.Level]<>'' ) then
               begin
                   vlItem.Caption := '�½�'+DirectoryLevel[Node.Level];
                   vlItem.Hint:=IntToStr(Node.Level);
               end;
      end
      else
      begin
            vlItem.Caption := '�½�'+DirectoryLevel[0];
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
  Name:string;
    Node : TTreeNode;
    menuItem:TMenuItem;
begin
  Name:=InputBox( '��������','����','');
  if trim(Name)<>'' then
  begin
     menuItem:=TMenuItem(Sender);
     try
      if(menuItem.Hint='0')then
      begin
         if not DirectoryExists(ProjectDir+'\'+Name) then
          begin
             CreateDir(ProjectDir+'\'+Name);
          end;
      end
      else
      begin
         if not DirectoryExists(GetTreeviewNodeDir(tvDir)+'\'+Name) then
          begin
            //ShowMessage(GetTreeviewNodeDir(TreeView1)+'\'+projectName);
             CreateDir(GetTreeviewNodeDir(tvDir)+'\'+Name);
          end;
      end;
      except
        ShowMessage('������ĿĿ¼����');
      end;
      tvDir.Items.Clear();
      tvDir.Items.AddFirst( nil,ProjectName );
      DirToTreeView(tvDir,ProjectDir,tvDir.Items.GetFirstNode,false);
      tvDir.FullExpand;
  end;

end;

procedure TVideoForm.ShowImage;
var
  i,j,k,docButPos,btnCount,strpos:Integer;
 SearchRec:TSearchRec;
 found:integer;
 docPanName,docButName:string;
 strs:TStringList;
  begin
    //��ȡ��ǰѡ��ڵ㣬��ʾ����ͼƬ�ļ�
    try
      StatusBar1.SimpleText:=GetTreeviewNodeDir(tvDir);
    if not Assigned(Filelist) then
    begin
      Filelist := TStringList.Create;
    end;
    Filelist.Clear();
    found:=FindFirst(GetTreeviewNodeDir(tvDir)+'*.jpg',faAnyFile,SearchRec);
     while    found=0    do
       begin
           if (SearchRec.Name<>'.')  and (SearchRec.Name<>'..')
                 and    (SearchRec.Attr<>faDirectory)    then
               Filelist.Add(SearchRec.Name);
           found:=FindNext(SearchRec);
       end;
     FindClose(SearchRec);
    except
      ShowMessage('��ȡ��ǰ��Ŀ�µ�ͼƬʧ��');
    end;

    //ClearImage();
    imgcount:=Filelist.count;
    try
    for i:=1 to Imgcount do
    begin
      BackGroud[i]:=TPanel.Create(self);
      BackGroud[i].Parent:=scrlbx_pic;
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
      ImgNameBak[i].BevelOuter:=bvNone;
      ImgNameBak[i].Font.Size:=9;
      ImgNameBak[i].Font.Color:=clBlue;
      ImgNameBak[i].Width:=100;
      ImgNameBak[i].Height :=12;
      //��̬����ImgNameBak,������Ϊimgname�ı���
      ImgName[i]:=TLabel.Create(self);
      ImgName[i].Parent:=ImgNameBak[i];
      ImgName[i].Font.Color :=clBlack;
      ImgName[i].Width:=100;
      //��̬����ImgName,�������ͼƬ��
      Path :=GetTreeviewNodeDir(tvDir)+'\'+Filelist.Strings[i-1];
      //�����ļ�·��


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
      //���ͼƬС��image �Ĵ�С����ͼƬ��ʵ�ʴ�С��ʾ
      ImgName[i].Caption:= Filelist.Strings[i-1];
      ImgNameBak[i].Caption:=ImgName[i].Caption;
      ImgName[i].Visible:=False;
      //��ʾͼƬ������֤ͼƬ�� ����
      if(i>=1) and (i<=7) then
      begin
        if(i=1) then
        begin
          BackGroud[i].Top:=8;
          BackGroud[i].Left :=8;
          Image[i].Top:=3;
          Image[i].Left:=3;
          Image[i].Visible:=True;


        end;
        if(i>=2) and (i<=7) then
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
        k:=Trunc(i/7);
        if((i mod (k*7))=1) then
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
      ShowMessage('����ͼƬλ�÷�������');
    end;         
    end;

procedure TVideoForm.ClearImage;
var
  i,j,k:Integer;
begin

  if Imgcount>=1 then
  begin
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
end;

  procedure TVideoForm.ShowBut;
var
  i,j,butcount:Integer; 
  row,col,PanelHeigh,ScbHeigh:Integer;
  begin
      for i:=Low(DocumentsTypeName) to High(DocumentsTypeName) do
      begin

         if(DocumentsTypeNum[i]<>'n')then
         begin
            SetLength(DocBut,i+1);
            butcount:=StrToInt(DocumentsTypeNum[i]);
            SetLength(DocBut[i],butcount);
            for j:=Low(DocBut[i]) to High(DocBut[i]) do
            begin
              DocBut[i][j]:=TcxButton.Create(self);
              DocBut[i][j].Parent:=Docscb[i];
              DocBut[i][j].Visible:=True;
              DocBut[i][j].Width:=50;
              DocBut[i][j].Height:=50;
              DocBut[i][j].Caption:=IntToStr(j+1);
              DocBut[i][j].Tag:=i;
              DocBut[i][j].OnClick:=SnapClick;
            end;
            SetButtonPosition(DocBut[i]);
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
      ImageButCompare;


  end;

procedure TVideoForm.ImageButCompare;
var
  i,j,k:integer;
  imageName:array of string;  
  imageID:array of integer;
  strs:TStringList;
  maxImageID,strpos:integer;
  maxID:integer;
  begin
    //����ͼƬ��  ����������������ӷ���ֱ��ͨ�����ӷ��ָ��������ӷ�����Ҫ��doc name��ͼƬ�ļ����ȶԣ���λdoc name����󳤶ȣ�����λ.��չ����λ�ã��ٽ�ȡ�õ����֣��밴ť���ֶ�Ӧ
    for i:=0 to filelist.Count-1 do
    begin
      //���������ַ����ͼƬ���� imageName���ļ��� imageID��ID
      if(connector<>'')then
      begin
          strs := SplitString(Filelist[i], connector);
          setlength(imageName,i+1);
          setlength(imageID,i+1);
          imageName[i]:=Strs[0];
          imageID[i]:=StrToInt(Strs[1]);
      end
      else
          for j:=Low(DocTitle) to High(DocTitle) do
          begin
            strpos:=ReversePos(DocTitle[j].Caption,Filelist[i]);
            if strpos<>0 then   //�õ���j���ַ����г��ֵ�λ�ã�������
            begin
              setlength(imageName,i+1);
              setlength(imageID,i+1);
              imageName[i]:=copy(PChar(Filelist[i]),strpos,Length(DocTitle[j].Caption));
              imageID[i]:=StrToInt(copy(PChar(Filelist[i]),Length(DocTitle[j].Caption)+1,(Length(Filelist[i])-(Length(Filelist[i])-pos('.',Filelist[i]))-(Length(DocTitle[j].Caption)+1))));
            end;
          end;
      end;

      
      //�ҵ�ͼƬ���ID ,��̬���ɵİ�ť�������ֵ�������а�ť
      //maxImageID:=MultiMax(imageID);
      for i:=Low(DocumentsTypeName) to High(DocumentsTypeName) do
      begin           
          maxID:=0;
          for j:=low(imageName) to high(imageName) do
          begin
             if(imageName[j]=DocumentsTypeName[i]) and (imageID[j]>maxID) then
             begin
                 maxID:=imageID[j];
             end;
          end;
          if(DocumentsTypeNum[i]='n') and (maxID>0)then
          begin
              setlength(DocBut[i],maxID);
              for k:=0 to maxID-1 do
              begin
                  DocBut[i][k]:=TcxButton.Create(self);
                  DocBut[i][k].Parent:=Docscb[i];
                  DocBut[i][k].Width:=50;
                  DocBut[i][k].Height:=50;
                  DocBut[i][k].Caption:=IntToStr(k+1); 
                  DocBut[i][k].OnClick:=SnapClick;
                  DocBut[i][k].Tag:=i;
              end;
              SetButtonPosition(DocBut[i]);
          end;
      end;
      
      //�ȶ����а�ť���Ӵ�
      for i:=Low(DocumentsTypeName) to High(DocumentsTypeName) do
      begin
          for j:=low(imageName) to high(imageName) do
          begin
            if(imageName[j]=DocumentsTypeName[i]) and ((imageID[j])<=length(docbut[i])) then
                docbut[i][imageID[j]-1].Font.Size:=16;
          end;
      end;
  end;
procedure TVideoForm.ClearBut();
var
  i,j:integer;
begin
  if(length(DocBut)>0)then
  begin         
     for i:=Low(DocumentsTypeName) to High(DocumentsTypeName) do
      begin
        if(length(DocBut[i])>0)then
        begin
            for j:=low(DocBut[i]) to high(DocBut[i]) do
            begin
                DocBut[i][j].Free;
                DocBut[i][j]:=nil;
            end;
            setlength(DocBut[i],0);
        end;

      end;
  end;
end;

procedure TVideoForm.SetButtonPosition(Buttons:array of TcxButton);
var
  i,row,col,butCount,PanelHeigh,ScbHeigh:Integer;
begin
      for  i:=Low(Buttons) to  High(Buttons) do
      begin
      //��ʾͼƬ������֤ͼƬ�� ����
      //showmessage(inttostr(High(Buttons)));
      //modȡ�� �õ� �������У���Ҫ�����һ��
      //div �������õ��ڼ���
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
          //Buttons[i].Caption:='��'+inttostr(row)+'��,��'+inttostr(col)+'��';
      end;
end;


procedure TVideoForm.SnapClick(Sender: TObject);
var
  i:Integer;
  btn:TcxButton;
  labTitle:TLabel;
  jp: TJPEGImage;
  Bitmap : TBitmap;
  savejpgname :string;
  node:TTreeNode;
  dlgResult:Integer;
begin    
  if tvDir.Selected=nil then
    Exit;
  node:=tvDir.Selected;
  if(Sender is TcxButton) and ((High(DocumentsTypeName)+1)=node.Level) then
  begin
    btn:=TcxButton(Sender);
    labTitle:=TLabel(btn.Parent.Parent.Controls[0]);
    if(btn.Font.size= 16) then
    begin
      //ShowMessage('�ļ��Ѵ��ڣ�ȷ��ɨ�裿');
      dlgResult:=MessageBox(Handle,'�ļ��Ѵ��ڣ�ȷ������ɨ�裿','ȷ��',MB_OKCANCEL);
      if dlgResult = 2 then
      begin
          exit;
      end;
    end;

      try
      savejpgname:=GetTreeviewNodeDir(tvDir)+'\'+labTitle.Caption+Connector+btn.Caption+'.jpg';
      //ShowMessage(savejpgname);
      //���沶׽��ͼƬ
      jp := TJPEGImage.Create;
      Bitmap := TBitmap.Create;
      SampleGrabber.GetBitmap(Bitmap);
      jp.CompressionQuality := 40;
      jp.Compress ;
      jp.Assign(Bitmap);
      Bitmap.Free;
      jp.SaveToFile(savejpgname);
        ClearImage();
      ShowImage;
      ImageButCompare;
        //ClearBut();
      //showbut;
      except
        ShowMessage('ͼ��׽�ɹ�������ʧ��');
      end;
      
  end;

end;


procedure TVideoForm.SnapNextClick(Sender: TObject);
var
  i,curButCount:Integer;
  btn:TcxButton;
  labTitle:TLabel;
  jp: TJPEGImage;
  Bitmap : TBitmap;
  savejpgname :string;
  node:TTreeNode;     
  row,col,butCount,PanelHeigh,ScbHeigh:Integer;
begin
  if tvDir.Selected=nil then
    Exit;
  node:=tvDir.Selected;
  if(Sender is TcxButton) and ((High(DocumentsTypeName)+1)=node.Level) then
  begin
    btn:=TcxButton(Sender);
    //ShowMessage(IntToStr(btn.Tag));
    i:=btn.Tag;
    curButCount:=length(DocBut[i]);
    setlength(DocBut[i],curButCount+1);
    DocBut[i][curButCount]:=TcxButton.Create(self);
    DocBut[i][curButCount].Parent:=Docscb[i];
    DocBut[i][curButCount].Width:=50;
    DocBut[i][curButCount].Height:=50;
    DocBut[i][curButCount].Caption:=IntToStr(curButCount+1);
    DocBut[i][curButCount].Tag:=i;  
    DocBut[i][curButCount].OnClick:=SnapClick;
    SetButtonPosition(DocBut[i]);

      //����ͼƬ
      
      labTitle:=TLabel(btn.Parent.Controls[0]);
      try
      savejpgname:=GetTreeviewNodeDir(tvDir)+'\'+labTitle.Caption+Connector+inttostr(curButCount+1)+'.jpg';
      //ShowMessage(savejpgname);
      //���沶׽��ͼƬ
      jp := TJPEGImage.Create;
      Bitmap := TBitmap.Create;
      SampleGrabber.GetBitmap(Bitmap);
      jp.CompressionQuality := 40;
      jp.Compress ;
      jp.Assign(Bitmap);
      Bitmap.Free;
      jp.SaveToFile(savejpgname);
        ClearBut();
        ClearImage();
      ShowImage;
      showbut;
      //ImageButCompare;
      except
        ShowMessage('�ļ��������,��ѡ�񱣴�λ��');
      end;

  end;
  end;

  
procedure TVideoForm.NewProjectClick(Sender: TObject);
var
  ini:TInifile;
  p:Integer;
begin
    //SelectDirectory('ѡ���½���Ŀ����λ��', '', ProjectDir);
    SelectDirectory('ѡ���½���Ŀ����λ��','',ProjectDir);
    ProjectName:=InputBox( '������Ŀ����','��Ŀ����','');
    if not DirectoryExists(ProjectDir+'\'+ProjectName) then
        begin
           CreateDir(ProjectDir+'\'+ProjectName);
        end;   
    ProjectDir:=ProjectDir+'\'+ProjectName;
    
        if not DirectoryExists(ProjectDir+'/Config') then
        begin
           CreateDir(ProjectDir+'/Config');

        end;
        if not FileExists(ProjectDir+'/Config/Default.ini') then
          CopyFile(pChar('./Config/Default.ini'),pChar(ProjectDir+'/Config/Default.ini'),true);



    ini:=TInifile.Create('./Config/OpenHistory.ini');
    ini.writestring('LastProjectPath','ProjectName',ProjectName);

    NewAndOpenInit;

end;

procedure TVideoForm.OpenProjectClick(Sender: TObject);
var
  ini:TInifile;
begin
    SelectDirectory('ѡ�����Ŀ��λ��', '', ProjectDir);
    NewAndOpenInit;
end;


procedure TVideoForm.NewAndOpenInit();
var
  ini:TInifile;
begin
  
    if(ProjectDir<>'') and (CheckProject()) then
    begin
      InitConfig;
      InitTreeView;
      InitDocName;

      
        ClearBut();
        ClearImage();
    end;
end;
procedure TVideoForm.VersionClick(Sender: TObject);
begin
    showmessage('��ǰ�汾��'+auAutoUpgrader1.VersionNumber);
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
procedure TVideoForm.N3Click(Sender: TObject);
var
  path1:string;
begin
  
  if((TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent.ClassName='TImage') or (TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent.ClassName='TLabel')) then
  begin
    try
    path1:=Filelist.Strings[NamPos-1];
    DeleteFile(GetTreeviewNodeDir(tvDir)+'\'+path1);
    DeleteImage(NamPos);
    ShowImage;
    except
      ShowMessage('ɾ��ͼƬ��������');
    end;
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


procedure TVideoForm.scrlbx_picClick(Sender: TObject);
var
  path1:string;
begin        
  if((Sender is TImage)or (Sender is TLabel)) then
  begin
    imgPreview.Visible:=True;
    VideoWindow.Visible:=false;

    try
    path1:=GetTreeviewNodeDir(tvDir)+'\'+ Filelist.Strings[NamPos-1];
    imgPreview.Stretch :=True;
    imgPreview.Picture.LoadFromFile(path1);
    if(imgPreview.Picture.Width<imgPreview.Width) and (imgPreview.Picture.Height<imgPreview.Height) then
    imgPreview.Stretch:=False;
    except
      ShowMessage('��ȡͼƬ����');
    end;
    //���ͼƬС��image1 �Ĵ�С����ͼƬ��ʵ�ʴ�С��ʾ
  end;
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
      path1:= GetTreeviewNodeDir(tvDir)+'\'+FileList.strings[NamPos-1];
      scbMain.Hint:='�ļ���:'+Filelist.strings[nampos-1]+#13+'ͼ���С:'+ IntToStr(Image[ImgPos].Picture.Width)+'          X'+ IntToStr(Image[ImgPos].Picture.Height)+'����';
    end;
  except
    ShowMessage('��ȡͼƬ��Ϣʧ��');
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

procedure TVideoForm.tvDirCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
    if node.Selected then
    begin
      tvDir.Canvas.Brush.Style := bsSolid;
      tvDir.Canvas.Brush.Color := clBlue;
    end;
end;

end.
