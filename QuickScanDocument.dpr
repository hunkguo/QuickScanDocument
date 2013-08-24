program QuickScanDocument;

uses
  Forms,
  main in 'main.pas' {VideoForm},
  wdRunOnce in 'wdRunOnce.pas';

{$R *.res}

begin
  Application.Initialize;
  if not AppHasRun(Application.Handle) then
    Application.CreateForm(TVideoForm, VideoForm);

  //Application.CreateForm(TPreviewForm, PreviewForm);
  //Application.CreateForm(TDlgInputProjectName, DlgInputProjectName);
  Application.Run;
end.
