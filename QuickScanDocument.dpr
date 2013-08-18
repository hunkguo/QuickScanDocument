program QuickScanDocument;

uses
  Forms,
  main in 'main.pas' {VideoForm},
  preview in 'preview.pas' {PreviewForm},
  inputProjectName in 'inputProjectName.pas' {DlgInputProjectName};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TVideoForm, VideoForm);
  Application.CreateForm(TPreviewForm, PreviewForm);
  Application.CreateForm(TDlgInputProjectName, DlgInputProjectName);
  Application.Run;
end.
