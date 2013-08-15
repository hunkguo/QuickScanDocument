program QuickScanDocument;

uses
  Forms,
  main in 'main.pas' {VideoForm},
  preview in 'preview.pas' {PreviewForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TVideoForm, VideoForm);
  Application.CreateForm(TPreviewForm, PreviewForm);
  Application.Run;
end.
