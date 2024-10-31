object FSampleMain: TFSampleMain
  Left = 0
  Top = 0
  Caption = 'FSampleMain'
  ClientHeight = 576
  ClientWidth = 808
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object MemoHexStr: TMemo
    Left = 17
    Top = 134
    Width = 777
    Height = 81
    Lines.Strings = (
      
        '85054350563031616F4F07041000000140105713920077900000135202010601' +
        '7700000000000F5F3401029F60124E50C1100970F3D64E5EB08C49E9E03059'
      
        'C563369F260824453616964068189F2701809F10140509A00008000000000000' +
        '0020200910170428019F36022742820200009F37041030C2EC')
    TabOrder = 3
  end
  object BtBase64Decode: TButton
    Left = 17
    Top = 103
    Width = 88
    Height = 25
    Caption = 'Base64Decode'
    TabOrder = 1
    OnClick = BtBase64DecodeClick
  end
  object MemoBerTlv: TMemo
    Left = 17
    Top = 252
    Width = 777
    Height = 315
    TabOrder = 7
  end
  object MemoQR: TMemo
    Left = 17
    Top = 16
    Width = 777
    Height = 81
    Lines.Strings = (
      
        'hQVDUFYwMWFvTwcEEAAAAUAQVxOSAHeQAAATUgIBBgF3AAAAAAAPXzQBAp9gEk5Q' +
        'wRAJcPPWTl6wjEnp4DBZxWM2nyYIJEU2FpZAaBifJwGAnxAUBQmgAAg'
      'AAAAAAAAAICAJEBcEKAGfNgInQoICAACfNwQQMMLs')
    TabOrder = 0
  end
  object BtSplitBerTlv: TButton
    Left = 17
    Top = 221
    Width = 88
    Height = 25
    Caption = 'SplitBerTlv'
    TabOrder = 4
    OnClick = BtSplitBerTlvClick
  end
  object BtTagValue: TButton
    Left = 205
    Top = 221
    Width = 88
    Height = 25
    Caption = 'TagValue'
    TabOrder = 6
    OnClick = BtTagValueClick
  end
  object EtTagStr: TEdit
    Left = 111
    Top = 223
    Width = 88
    Height = 21
    MaxLength = 8
    TabOrder = 5
    Text = '9F60'
  end
  object BtBase64Encode: TButton
    Left = 111
    Top = 103
    Width = 88
    Height = 25
    Caption = 'Base64Encode'
    TabOrder = 2
    OnClick = BtBase64EncodeClick
  end
end
