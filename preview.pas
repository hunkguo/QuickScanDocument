unit preview;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TPreviewForm = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PreviewForm: TPreviewForm;

implementation

uses main;

{$R *.dfm}

procedure TPreviewForm.FormCreate(Sender: TObject);
begin
  Image1.Stretch:=True;
  if(Image1.Picture.Width<Image1.Width) and
    (Image1.Picture.Height<Image1.Height) then
    Image1.Stretch:=False;
end;

procedure TPreviewForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  videoForm.show
end;


end.
