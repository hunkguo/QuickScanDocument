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
    VideoWindow: TVideoWindow;
    scrlbx1: TScrollBox;
    lbl1: TLabel;
    edt_project_name: TEdit;
    rg_documents: TRadioGroup;
    btn_save: TButton;
    ImageList1: TImageList;
    Image1: TImage;
    ListView1: TListView;

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btn_snapClick(Sender: TObject);
    procedure edt_project_nameExit(Sender: TObject);
    procedure btn_saveClick(Sender: TObject);
 
  private
    { D閏larations priv閑s }
  public
    { D閏larations publiques }
    procedure OnSelectDevice(sender: TObject);
  end;

var
  VideoForm: TVideoForm;
  SysDev: TSysDevEnum;
implementation

{$R *.dfm}

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

  

  rg_documents.Items.CommaText:='用地申请,技术报告书,分幅图';
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
  SampleGrabber.GetBitmap(Image1.Picture.Bitmap);
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



procedure TVideoForm.btn_saveClick(Sender: TObject);
var
  jp: TJPEGImage;
  i : integer;
  Bitmap : TBitmap;
  savejpgname :string;
begin

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

      //加载保存的jpeg图片，生成缩略图，添加到imagelist
        TRY
            jp.LoadFromFile(savejpgname);
//            if (ImageList.Count = 0) then
//              ImageList1.SetSize(JpgIn.Width, JpgIn.Height);
            Bitmap := TBitmap.Create;
            try
              Bitmap.Assign(jp);
              ImageList1.Add(Bitmap, nil);
              ListView1.Items.Add();
              Image1.Picture.Assign(Bitmap);
            finally
              Bitmap.Free;
            end;
          finally
            jp.Free;
          end;


end;

end.
