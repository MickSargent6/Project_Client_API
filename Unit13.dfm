object Form13: TForm13
  Left = 493
  Top = 216
  BorderStyle = bsDialog
  Caption = 'Form13'
  ClientHeight = 526
  ClientWidth = 927
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 337
    Width = 927
    Height = 189
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 0
    OnDblClick = Memo1DblClick
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 927
    Height = 337
    Align = alTop
    Caption = 'GroupBox1'
    TabOrder = 1
    object Label1: TLabel
      Left = 24
      Top = 16
      Width = 113
      Height = 13
      Caption = 'Sage Account Number :'
    end
    object Label2: TLabel
      Left = 24
      Top = 40
      Width = 72
      Height = 13
      Caption = 'Sales Number: '
    end
    object Label3: TLabel
      Left = 24
      Top = 64
      Width = 59
      Height = 13
      Caption = 'Finger Print:'
    end
    object Label4: TLabel
      Left = 24
      Top = 90
      Width = 41
      Height = 13
      Caption = 'Product:'
    end
    object Label5: TLabel
      Left = 297
      Top = 90
      Width = 39
      Height = 13
      Caption = 'Version:'
    end
    object Label6: TLabel
      Left = 24
      Top = 116
      Width = 77
      Height = 13
      Caption = 'Computer Name'
    end
    object Label7: TLabel
      Left = 25
      Top = 195
      Width = 23
      Height = 13
      Caption = 'URL:'
    end
    object Label8: TLabel
      Left = 25
      Top = 206
      Width = 24
      Height = 13
      Caption = 'Port:'
    end
    object Label9: TLabel
      Left = 24
      Top = 234
      Width = 53
      Height = 13
      Caption = 'UserName:'
    end
    object Label10: TLabel
      Left = 24
      Top = 257
      Width = 50
      Height = 13
      Caption = 'Password:'
    end
    object Label11: TLabel
      Left = 25
      Top = 179
      Width = 23
      Height = 13
      Caption = 'URL:'
    end
    object edSage: TEdit
      Left = 143
      Top = 10
      Width = 225
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 0
    end
    object edSalesNumber: TEdit
      Left = 144
      Top = 37
      Width = 129
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 1
    end
    object edFingerPrint: TEdit
      Left = 144
      Top = 62
      Width = 225
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 2
    end
    object cbProduct: TComboBox
      Left = 144
      Top = 88
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 3
      OnExit = cbProductExit
      Items.Strings = (
        'BCS_001')
    end
    object cbVersion: TComboBox
      Left = 344
      Top = 88
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 4
      OnExit = cbVersionExit
      Items.Strings = (
        '2018.04')
    end
    object edComputerName: TEdit
      Left = 144
      Top = 113
      Width = 161
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 5
    end
    object cbPort: TComboBox
      Left = 143
      Top = 203
      Width = 62
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 2
      TabOrder = 6
      Text = '7131'
      Items.Strings = (
        '1691'
        '1692'
        '7131')
    end
    object cbURL: TComboBox
      Left = 143
      Top = 176
      Width = 190
      Height = 21
      ItemHeight = 13
      TabOrder = 7
      Text = '127.0.0.1'
      Items.Strings = (
        '127.0.0.1'
        'LLC_HP236NQ_2'
        'TYPHON'
        '51.136.30.51'
        'activation.timesystemsuk.com')
    end
    object edPassword: TEdit
      Left = 143
      Top = 254
      Width = 162
      Height = 21
      TabOrder = 8
      Text = 'FRED'
    end
    object edUserName: TEdit
      Left = 143
      Top = 230
      Width = 162
      Height = 21
      TabOrder = 9
      Text = 'MICK'
    end
    object BtnRefresh: TButton
      Left = 380
      Top = 62
      Width = 75
      Height = 21
      Caption = 'Refresh'
      TabOrder = 10
      OnClick = BtnRefreshClick
    end
    object Button1: TButton
      Left = 404
      Top = 205
      Width = 75
      Height = 25
      Caption = 'DLL Ping'
      TabOrder = 11
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 323
      Top = 205
      Width = 75
      Height = 25
      Caption = 'DLL Setup'
      TabOrder = 12
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 485
      Top = 205
      Width = 75
      Height = 25
      Caption = 'Check'
      TabOrder = 13
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 648
      Top = 205
      Width = 75
      Height = 25
      Caption = 'Get License'
      TabOrder = 14
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 322
      Top = 237
      Width = 75
      Height = 25
      Caption = 'D7 Setup'
      TabOrder = 15
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 734
      Top = 237
      Width = 75
      Height = 25
      Caption = 'ShutDown'
      TabOrder = 16
      OnClick = Button6Click
    end
    object Button7: TButton
      Left = 405
      Top = 237
      Width = 75
      Height = 25
      Caption = 'D7 Ping'
      TabOrder = 17
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 486
      Top = 237
      Width = 75
      Height = 25
      Caption = 'Check'
      TabOrder = 18
      OnClick = Button8Click
    end
    object Button9: TButton
      Left = 568
      Top = 237
      Width = 75
      Height = 25
      Caption = 'Activate'
      TabOrder = 19
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 651
      Top = 237
      Width = 75
      Height = 25
      Caption = 'Download'
      TabOrder = 20
      OnClick = Button10Click
    end
    object Button11: TButton
      Left = 569
      Top = 205
      Width = 75
      Height = 25
      Caption = 'Activate'
      TabOrder = 21
      OnClick = Button11Click
    end
    object Button12: TButton
      Left = 320
      Top = 272
      Width = 41
      Height = 25
      Caption = 'Active'
      TabOrder = 22
      OnClick = Button12Click
    end
    object Button13: TButton
      Left = 368
      Top = 272
      Width = 41
      Height = 25
      Caption = 'Expire'
      TabOrder = 23
      OnClick = Button13Click
    end
    object Button14: TButton
      Left = 416
      Top = 272
      Width = 57
      Height = 25
      Caption = 'Exployees'
      TabOrder = 24
      OnClick = Button14Click
    end
    object Button15: TButton
      Left = 480
      Top = 272
      Width = 65
      Height = 25
      Caption = 'Total Users'
      TabOrder = 25
      OnClick = Button15Click
    end
    object Button16: TButton
      Left = 552
      Top = 272
      Width = 49
      Height = 25
      Caption = 'Region'
      TabOrder = 26
      OnClick = Button16Click
    end
    object Button17: TButton
      Left = 608
      Top = 272
      Width = 49
      Height = 25
      Caption = 'Product'
      TabOrder = 27
      OnClick = Button17Click
    end
    object Button18: TButton
      Left = 664
      Top = 272
      Width = 41
      Height = 25
      Caption = 'Options'
      TabOrder = 28
      OnClick = Button18Click
    end
    object Button19: TButton
      Left = 712
      Top = 272
      Width = 49
      Height = 25
      Caption = 'Allow AS'
      TabOrder = 29
      OnClick = Button19Click
    end
    object Button20: TButton
      Left = 320
      Top = 302
      Width = 49
      Height = 25
      Caption = 'Get Value'
      TabOrder = 30
      OnClick = Button20Click
    end
    object Edit1: TEdit
      Left = 384
      Top = 304
      Width = 121
      Height = 21
      TabOrder = 31
      Text = 'Edit1'
    end
    object Button21: TButton
      Left = 600
      Top = 136
      Width = 75
      Height = 25
      Caption = 'Button21'
      TabOrder = 32
    end
    object Button22: TButton
      Left = 464
      Top = 62
      Width = 113
      Height = 21
      Caption = 'Test Finger Print'
      TabOrder = 33
      OnClick = Button22Click
    end
    object cbFirstTimeOnly: TCheckBox
      Left = 584
      Top = 62
      Width = 97
      Height = 17
      Caption = 'First Time Only'
      TabOrder = 34
    end
  end
end
