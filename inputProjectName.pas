unit inputProjectName;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls;

type
  TDlgInputProjectName = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    edtProjectName: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DlgInputProjectName: TDlgInputProjectName;

implementation

{$R *.dfm}

end.
