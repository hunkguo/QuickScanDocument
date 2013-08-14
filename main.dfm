object VideoForm: TVideoForm
  Left = 337
  Top = 80
  Width = 1011
  Height = 751
  Caption = 'VideoForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 776
    Top = 13
    Width = 60
    Height = 13
    Caption = #39033#30446#21517#31216#65306
  end
  object scrlbx1: TScrollBox
    Left = 0
    Top = 0
    Width = 585
    Height = 425
    VertScrollBar.Position = 1101
    TabOrder = 0
    object VideoWindow: TVideoWindow
      Left = 0
      Top = -1101
      Width = 1944
      Height = 2592
      FilterGraph = FilterGraph
      VMROptions.Mode = vmrWindowed
      Color = clBlack
    end
  end
  object edt_project_name: TEdit
    Left = 776
    Top = 37
    Width = 209
    Height = 21
    TabOrder = 1
    OnExit = edt_project_nameExit
  end
  object rg_documents: TRadioGroup
    Left = 776
    Top = 65
    Width = 225
    Height = 120
    Caption = #36873#25321#25991#26723' &d'
    Columns = 5
    TabOrder = 2
  end
  object btn_save: TButton
    Left = 885
    Top = 201
    Width = 92
    Height = 64
    Caption = #20445#23384' &s'
    TabOrder = 3
    OnClick = btn_saveClick
  end
  object lv1: TListView
    Left = 760
    Top = 296
    Width = 217
    Height = 265
    Columns = <>
    LargeImages = ImageList
    TabOrder = 4
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
  object ImageList: TImageList
    Left = 696
    Top = 304
  end
end
