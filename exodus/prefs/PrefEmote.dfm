inherited frmPrefEmote: TfrmPrefEmote
  Left = 263
  Top = 185
  Caption = 'frmPrefEmote'
  ClientHeight = 326
  ClientWidth = 312
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlHeader: TTntPanel
    Width = 312
    Caption = 'Emoticon Options'
  end
  object Panel1: TPanel
    Left = 0
    Top = 26
    Width = 312
    Height = 26
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object chkEmoticons: TTntCheckBox
      Left = 2
      Top = 5
      Width = 300
      Height = 17
      Caption = 'Auto detect Emoticons in messages'
      TabOrder = 0
    end
  end
  object pageEmotes: TTntPageControl
    Left = 0
    Top = 52
    Width = 312
    Height = 274
    ActivePage = TntTabSheet2
    Align = alClient
    TabOrder = 2
    object TntTabSheet1: TTntTabSheet
      Caption = 'Emoticon Packages'
      object pnlCustomPresButtons: TPanel
        Left = 0
        Top = 212
        Width = 304
        Height = 34
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 0
        object btnEmoteAdd: TTntButton
          Left = 4
          Top = 4
          Width = 60
          Height = 25
          Caption = 'Add'
          TabOrder = 0
          OnClick = btnEmoteAddClick
        end
        object btnEmoteRemove: TTntButton
          Left = 68
          Top = 4
          Width = 60
          Height = 25
          Caption = 'Remove'
          TabOrder = 1
          OnClick = btnEmoteRemoveClick
        end
        object btnEmoteClear: TTntButton
          Left = 132
          Top = 4
          Width = 60
          Height = 25
          Caption = 'Clear'
          TabOrder = 2
          OnClick = btnEmoteClearClick
        end
        object btnEmoteDefault: TTntButton
          Left = 196
          Top = 4
          Width = 60
          Height = 25
          Caption = 'Defaults'
          TabOrder = 3
          OnClick = btnEmoteDefaultClick
        end
      end
      object lstEmotes: TTntListBox
        Left = 0
        Top = 0
        Width = 304
        Height = 212
        Align = alClient
        ItemHeight = 13
        TabOrder = 1
      end
    end
    object TntTabSheet2: TTntTabSheet
      Caption = 'Custom Emoticons'
      object Panel2: TPanel
        Left = 0
        Top = 158
        Width = 304
        Height = 34
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 0
        object btnCustomEmoteAdd: TTntButton
          Left = 4
          Top = 4
          Width = 60
          Height = 25
          Caption = 'Add ...'
          TabOrder = 0
          OnClick = btnCustomEmoteAddClick
        end
        object btnCustomEmoteRemove: TTntButton
          Left = 132
          Top = 4
          Width = 60
          Height = 25
          Caption = 'Remove'
          TabOrder = 1
          OnClick = btnCustomEmoteRemoveClick
        end
        object btnCustomEmoteEdit: TTntButton
          Left = 68
          Top = 4
          Width = 60
          Height = 25
          Caption = 'Edit ...'
          TabOrder = 2
          OnClick = btnCustomEmoteEditClick
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 192
        Width = 304
        Height = 54
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object TntLabel3: TTntLabel
          Left = 2
          Top = 8
          Width = 190
          Height = 13
          Caption = 'Filename of custom emoticon definitions:'
        end
        object txtCustomEmoteFilename: TTntEdit
          Left = 16
          Top = 22
          Width = 249
          Height = 21
          TabOrder = 0
        end
        object btnCustomEmoteBrowse: TTntButton
          Left = 270
          Top = 20
          Width = 27
          Height = 25
          Caption = '...'
          TabOrder = 1
          OnClick = btnCustomEmoteBrowseClick
        end
      end
      object lstCustomEmotes: TTntListView
        Left = 0
        Top = 0
        Width = 304
        Height = 158
        Align = alClient
        Columns = <>
        IconOptions.AutoArrange = True
        LargeImages = imagesCustom
        MultiSelect = True
        OwnerDraw = True
        TabOrder = 2
        OnAdvancedCustomDrawItem = lstCustomEmotesAdvancedCustomDrawItem
        OnDblClick = btnCustomEmoteEditClick
      end
    end
  end
  object EmoteOpen: TOpenDialog
    Filter = 'Resource Files|*.dll|All Files|*.*'
    Left = 224
    Top = 34
  end
  object XMLDialog1: TOpenDialog
    Filter = 'XML Files|*.xml|All Files|*.*'
    Left = 256
    Top = 34
  end
  object imagesCustom: TImageList
    BlendColor = clWindow
    BkColor = 15857655
    Height = 32
    Width = 32
    Left = 288
    Top = 34
  end
end
