object frmActivityWindow: TfrmActivityWindow
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'frmActivityWindow'
  ClientHeight = 422
  ClientWidth = 195
  Color = 13681583
  DockSite = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlListBase: TExGradientPanel
    Left = 0
    Top = 10
    Width = 195
    Height = 402
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    GradientProperites.startColor = 13681583
    GradientProperites.endColor = 13681583
    GradientProperites.orientation = gdHorizontal
    ExplicitWidth = 187
    ExplicitHeight = 374
    object pnlListScrollUp: TExGradientPanel
      Left = 0
      Top = 30
      Width = 195
      Height = 22
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      Visible = False
      OnClick = pnlListScrollUpClick
      OnMouseDown = pnlListScrollUpMouseDown
      OnMouseUp = pnlListScrollUpMouseUp
      GradientProperites.startColor = 13746091
      GradientProperites.endColor = 12429970
      GradientProperites.orientation = gdHorizontal
      ExplicitWidth = 187
      object imgScrollUp: TImage
        Left = 76
        Top = 1
        Width = 16
        Height = 16
        Align = alCustom
        Anchors = [akTop]
        Transparent = True
        OnClick = pnlListScrollUpClick
        OnMouseDown = pnlListScrollUpMouseDown
        OnMouseUp = pnlListScrollUpMouseUp
        ExplicitLeft = 73
      end
      object ScrollUpBevel: TColorBevel
        Left = 0
        Top = 17
        Width = 195
        Height = 5
        Align = alBottom
        Shape = bsBottomLine
        HighLight = clBtnHighlight
        Shadow = clBtnShadow
        FrameColor = frUser
        ExplicitTop = -28
        ExplicitWidth = 187
      end
    end
    object pnlListScrollDown: TExGradientPanel
      Left = 0
      Top = 380
      Width = 195
      Height = 22
      Align = alBottom
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      Visible = False
      OnClick = pnlListScrollDownClick
      OnMouseDown = pnlListScrollDownMouseDown
      OnMouseUp = pnlListScrollDownMouseUp
      GradientProperites.startColor = 13746091
      GradientProperites.endColor = 12429970
      GradientProperites.orientation = gdHorizontal
      ExplicitTop = 352
      ExplicitWidth = 187
      object imgScrollDown: TImage
        Left = 76
        Top = 4
        Width = 16
        Height = 16
        Align = alCustom
        Anchors = [akBottom]
        Transparent = True
        OnClick = pnlListScrollDownClick
        OnMouseDown = pnlListScrollDownMouseDown
        OnMouseUp = pnlListScrollDownMouseUp
        ExplicitLeft = 75
        ExplicitTop = 2
      end
      object ScrollDownBevel: TColorBevel
        Left = 0
        Top = 0
        Width = 195
        Height = 5
        Align = alTop
        Shape = bsTopLine
        HighLight = clBtnHighlight
        Shadow = clBtnShadow
        FrameColor = frUser
        ExplicitWidth = 187
      end
    end
    object pnlList: TExGradientPanel
      Left = 0
      Top = 52
      Width = 195
      Height = 328
      Align = alClient
      BevelOuter = bvNone
      ParentColor = True
      PopupMenu = popAWList
      TabOrder = 2
      OnResize = pnlListResize
      GradientProperites.startColor = 13746091
      GradientProperites.endColor = 12429970
      GradientProperites.orientation = gdHorizontal
      ExplicitWidth = 187
      ExplicitHeight = 300
      object ListLeftSpacer: TBevel
        Left = 0
        Top = 0
        Width = 10
        Height = 328
        Align = alLeft
        Shape = bsSpacer
        ExplicitHeight = 305
      end
      object ListRightSpacer: TBevel
        Left = 195
        Top = 0
        Width = 0
        Height = 328
        Align = alRight
        Shape = bsSpacer
        ExplicitLeft = 184
        ExplicitHeight = 327
      end
    end
    object pnlListSort: TExGradientPanel
      Left = 0
      Top = 0
      Width = 195
      Height = 30
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 3
      OnClick = pnlListSortClick
      GradientProperites.startColor = 13746091
      GradientProperites.endColor = 12429970
      GradientProperites.orientation = gdHorizontal
      ExplicitWidth = 187
      object lblSort: TTntLabel
        Left = 26
        Top = 5
        Width = 148
        Height = 20
        Align = alClient
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Sort By:  Alpha'
        EllipsisPosition = epEndEllipsis
        Transparent = True
        OnClick = pnlListSortClick
        ExplicitLeft = 94
        ExplicitWidth = 72
        ExplicitHeight = 13
      end
      object SortTopSpacer: TBevel
        Left = 0
        Top = 0
        Width = 195
        Height = 5
        Align = alTop
        Shape = bsSpacer
        ExplicitLeft = 1
        ExplicitTop = 30
        ExplicitWidth = 183
      end
      object imgSortArrow: TImage
        Left = 174
        Top = 5
        Width = 16
        Height = 20
        Align = alRight
        Transparent = True
        OnClick = pnlListSortClick
        ExplicitLeft = 75
        ExplicitTop = 2
        ExplicitHeight = 16
      end
      object imgShowRoster: TImage
        Left = 10
        Top = 5
        Width = 16
        Height = 20
        Hint = 'Back to Contact List'
        Align = alLeft
        ParentShowHint = False
        ShowHint = True
        Transparent = True
        OnClick = imgShowRosterClick
        ExplicitLeft = 149
        ExplicitTop = 4
      end
      object SortLeftSpacer: TBevel
        Left = 0
        Top = 5
        Width = 10
        Height = 20
        Align = alLeft
        Shape = bsSpacer
      end
      object SortRightSpacer: TBevel
        Left = 190
        Top = 5
        Width = 5
        Height = 20
        Align = alRight
        Shape = bsSpacer
        ExplicitLeft = 177
      end
      object SortBevel: TColorBevel
        Left = 0
        Top = 25
        Width = 195
        Height = 5
        Align = alBottom
        Shape = bsBottomLine
        HighLight = clBtnHighlight
        Shadow = clBtnShadow
        FrameColor = frUser
        ExplicitLeft = 104
        ExplicitTop = 32
        ExplicitWidth = 50
      end
    end
  end
  object pnlBorderTop: TExGradientPanel
    Left = 0
    Top = 0
    Width = 195
    Height = 10
    Align = alTop
    BevelOuter = bvNone
    Color = 13681583
    TabOrder = 1
    GradientProperites.startColor = 13681583
    GradientProperites.endColor = 13681583
    GradientProperites.orientation = gdVertical
    ExplicitWidth = 187
  end
  object pnlBorderBottom: TExGradientPanel
    Left = 0
    Top = 412
    Width = 195
    Height = 10
    Align = alBottom
    BevelOuter = bvNone
    Color = 13681583
    TabOrder = 2
    GradientProperites.startColor = 13681583
    GradientProperites.endColor = 13681583
    GradientProperites.orientation = gdVertical
    ExplicitTop = 384
    ExplicitWidth = 187
  end
  object popAWSort: TTntPopupMenu
    Left = 104
    Top = 144
    object mnuRecentSort: TTntMenuItem
      Caption = 'Activity'
      OnClick = mnuRecentSortClick
    end
    object mnuAlphaSort: TTntMenuItem
      Caption = 'Alphabetical'
      OnClick = mnuAlphaSortClick
    end
    object mnuTypeSort: TTntMenuItem
      Caption = 'Type'
      OnClick = mnuTypeSortClick
    end
    object mnuUnreadSort: TTntMenuItem
      Caption = 'Unread'
      OnClick = mnuUnreadSortClick
    end
  end
  object timShowActiveDocked: TTimer
    Interval = 100
    OnTimer = timShowActiveDockedTimer
    Left = 72
    Top = 144
  end
  object popAWList: TTntPopupMenu
    Left = 72
    Top = 176
    object mnuAW_CloseAll: TTntMenuItem
      Caption = 'Close All Windows'
      OnClick = mnuAW_CloseAllClick
    end
    object mnuAW_DockAll: TTntMenuItem
      Caption = 'Dock All Windows'
      OnClick = mnuAW_DockAllClick
    end
    object mnuAW_FloatAll: TTntMenuItem
      Caption = 'Undock All Windows'
      OnClick = mnuAW_FloatAllClick
    end
  end
  object timScrollTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = timScrollTimerTimer
    Left = 104
    Top = 176
  end
end
