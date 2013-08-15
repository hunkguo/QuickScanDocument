object VideoForm: TVideoForm
  Left = 246
  Top = 107
  Width = 922
  Height = 671
  Caption = #25991#26723#31649#29702
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 640
    Top = 0
    Width = 265
    Height = 481
    BevelOuter = bvNone
    TabOrder = 0
    object btn_save: TButton
      Left = 21
      Top = 369
      Width = 212
      Height = 64
      Caption = #20445#23384' &s'
      TabOrder = 0
      OnClick = btn_saveClick
    end
    object rg_documents: TRadioGroup
      Left = 24
      Top = 65
      Width = 209
      Height = 296
      Caption = #36873#25321#25991#26723' &d'
      TabOrder = 1
    end
    object edt_project_name: TEdit
      Left = 24
      Top = 44
      Width = 209
      Height = 21
      TabOrder = 2
      OnExit = edt_project_nameExit
    end
    object Panel3: TPanel
      Left = 8
      Top = 24
      Width = 233
      Height = 17
      BevelOuter = bvNone
      Caption = #39033#30446#21517#31216#65306'                                               '
      TabOrder = 3
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 480
    Width = 905
    Height = 129
    BevelOuter = bvNone
    TabOrder = 1
    object ScrollBox1: TScrollBox
      Left = 0
      Top = 0
      Width = 905
      Height = 129
      BevelInner = bvNone
      BorderStyle = bsNone
      TabOrder = 0
      OnClick = ScrollBox1Click
      OnDblClick = ScrollBox1DblClick
      OnMouseMove = ScrollBox1MouseMove
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 480
    Caption = 'Panel1'
    TabOrder = 2
    object VideoWindow: TVideoWindow
      Left = 0
      Top = 0
      Width = 640
      Height = 480
      FilterGraph = FilterGraph
      VMROptions.Mode = vmrWindowed
      Color = clBlack
    end
  end
  object FilterGraph: TFilterGraph
    Mode = gmCapture
    GraphEdit = True
    LinearVolume = True
    Left = 8
    Top = 24
  end
  object SampleGrabber: TSampleGrabber
    FilterGraph = FilterGraph
    MediaType.data = {
      7669647300001000800000AA00389B717DEB36E44F52CE119F530020AF0BA770
      FFFFFFFF0000000001000000809F580556C3CE11BF0100AA0055595A00000000
      0000000000000000}
    Top = 80
  end
  object Filter: TFilter
    BaseFilter.data = {00000000}
    FilterGraph = FilterGraph
    Top = 136
  end
  object MainMenu1: TMainMenu
    Top = 192
    object Devices: TMenuItem
      Caption = #36873#25321#35774#22791
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 24
    Top = 504
    object N1: TMenuItem
      Caption = #25171#24320
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = #21024#38500
      OnClick = N2Click
    end
  end
end
