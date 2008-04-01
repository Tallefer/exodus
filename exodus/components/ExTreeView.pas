{
    Copyright 2001, Peter Millard

    This file is part of Exodus.

    Exodus is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Exodus is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Exodus; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

unit ExTreeView;

interface

uses
  SysUtils, Classes, Controls, TntComCtrls, XMLTag, Exodus_TLB,
  RegExpr, Types, ComCtrls, Contnrs, Messages, Unicode;

type

  TExTreeView = class(TTntTreeView)
  private
      { Private declarations }
      _JS: TObject;
      _SessionCB: Integer;
      _RosterCB: Integer;
      _DataCB: Integer;
      _NestedGroups : TRegExpr;
      _StatusColor: Integer;
      _TotalsColor: Integer;
      _InactiveColor: Integer;
      _ShowGroupTotals: Boolean;
      _ShowStatus: Boolean;
      _CurrentNode: TTntTreeNode;
      _GroupSeparator: WideChar;
      _TabIndex: Integer;

      //Methods
      procedure _RosterCallback(Event: string; Item: IExodusItem);
      procedure _SessionCallback(Event: string; Tag: TXMLTag);
      procedure _GroupCallback(Event: string; Tag: TXMLTag; Data: WideString);

      procedure _GetActionableItems(items: IExodusItemList; node: TTntTreeNode);

  protected
      { Protected declarations }
      function  AddItemNode(Item: IExodusItem): TTntTreeNode;virtual;
      function  GetNodeByName(Group: WideString): TTntTreeNode;virtual;
      function  AddNodeByName(Group: WideString): TTntTreeNode;virtual;
      function  GetChildNodeByName(Group: WideString; Parent: TTntTreeNode): TTntTreeNode;virtual;
      function  AddChildNodeByName(Group: WideString; Parent: TTntTreeNode): TTntTreeNode;virtual;
      function  GetItemNodes(Uid: WideString) : TObjectList; virtual;
      procedure UpdateItemNodes(Item: IExodusItem); virtual;
      procedure RemoveItemNodes(Item: IExodusItem); virtual;
      procedure UpdateItemNode(Node: TTntTreeNode); virtual;
      function  GetActiveCounts(Node: TTntTreeNode): Integer; virtual;
      function  GetLeavesCounts(Node: TTntTreeNode): Integer; virtual;
      procedure SaveGroupsState(); virtual;
      procedure RestoreGroupsState(); virtual;
      function  Collapsed(Node: TTntTreeNode): Boolean; virtual;
      function  TopNode(Node: TTntTreeNode): TTntTreeNode; virtual;
      procedure CustomDrawItem(Sender: TCustomTreeView;
                               Node: TTreeNode;
                               State: TCustomDrawState;
                               var DefaultDraw: Boolean); virtual;
      procedure DrawNodeText(Node: TTntTreeNode;
                             State: TCustomDrawState;
                             Text, ExtendedText: Widestring);  virtual;
      procedure Editing(Sender: TObject; Node: TTreeNode; var AllowEdit: Boolean);
      function  FilterItem(Item: IExodusItem): Boolean; virtual;
      procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;

  public
      { Public declarations }
      constructor Create(AOwner: TComponent; Session: TObject);
      procedure CreateParams(var Params: TCreateParams); override;
      destructor Destroy(); override;
      procedure MouseDown(Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer);  override;
      function  GetNodePath(Node: TTntTreeNode): WideString; virtual;
      procedure DblClick(); override;
      function  GetSubgroups(Group: WideString): TWideStringList; virtual;
      //Properties
      property Session: TObject read _JS write _JS;
      procedure SetFontsAndColors();

      procedure Refresh();
      //Properties
      property TabIndex: Integer read _TabIndex write _TabIndex;

  end;

//procedure Register;

implementation
uses Session, Graphics, Windows, ExUtils, CommCtrl, Jabber1,
     RosterImages, JabberID, ContactController, COMExodusItem, COMExodusItemList,
     ChatWin, GroupInfo, Room, Forms, ActionMenus, ExActionCtrl;

procedure TExTreeView.CreateParams(var Params: TCreateParams);
begin
    inherited CreateParams(Params);
    Params.Style := Params.Style or TVS_NOHSCROLL;
end;

{---------------------------------------}
constructor TExTreeView.Create(AOwner: TComponent; Session: TObject);
var
    popup: TExActionPopupMenu;

begin
    inherited Create(AOwner);

    Align := alClient;
    Anchors := [akLeft, akTop, akRight, akBottom];
    BorderStyle := bsNone;
    ShowButtons := true;    //buttons are owner-drawn (at least on XP)
    ShowLines := false;
    AutoExpand := false;
    HideSelection := false;
    MultiSelect := true;
    MultiSelectStyle := [msControlSelect, msShiftSelect, msVisibleOnly];
    RowSelect := false;
    SortType := stText;
    OnCustomDrawItem := CustomDrawItem;
    OnEditing := Editing;

    popup := TExActionPopupMenu.Create(Self);
    popup.ActionController := GetActionController();
    PopupMenu := popup;

    _JS :=  TJabberSession(Session);
    _RosterCB := TJabberSession(_JS).RegisterCallback(_RosterCallback, '/item');
    _SessionCB := TJabberSession(_JS).RegisterCallback(_SessionCallback, '/session');
    _DataCB := TJabberSession(_JS).RegisterCallback(_GroupCallback);
    _GroupSeparator := PWideChar(TJabberSession(_JS).Prefs.getString('group_seperator'))^;

    _NestedGroups := TRegExpr.Create();
    //Spaces are no longer word boundaries, but group separators are.
    _NestedGroups.SpaceChars :=  _GroupSeparator;
    _NestedGroups.WordChars := _NestedGroups.WordChars + chr(32);
    _NestedGroups.Expression := '\b\w+';
    _NestedGroups.Compile();
    _TotalsColor := TColor(RGB(130,143,154 ));
    _InactiveColor := TColor(RGB(130,143,154 ));
    Perform(TVM_SETITEMHEIGHT, -1, 0);
    _CurrentNode := nil;
    _TabIndex := -1;
end;

{---------------------------------------}
destructor TExTreeView.Destroy();
begin
    with TJabberSession(_js) do begin
        UnregisterCallback(_SessionCB);
        UnregisterCallback(_RosterCB);
        UnregisterCallback(_DataCB);
    end;
   _NestedGroups.Free;

   inherited;
end;

{---------------------------------------}
procedure TExTreeView.SetFontsAndColors();
begin
    //Initialize fonts and colors
    _StatusColor := TColor(TJabberSession(_JS).Prefs.getInt('inline_color'));
    Color := TColor(TJabberSession(_JS).prefs.getInt('roster_bg'));
    Font.Name := TJabberSession(_JS).prefs.getString('roster_font_name');
    Font.Size := TJabberSession(_JS).prefs.getInt('roster_font_size');
    Font.Color := TColor(TJabberSession(_JS).prefs.getInt('roster_font_color'));
    Font.Charset := TJabberSession(_JS).prefs.getInt('roster_font_charset');
    Font.Style := [];
    if (TJabberSession(_JS).prefs.getBool('font_bold')) then
        Font.Style := Font.Style + [fsBold];
    if (TJabberSession(_JS).prefs.getBool('font_italic')) then
        Font.Style := Font.Style + [fsItalic];
    if (TJabberSession(_JS).prefs.getBool('font_underline')) then
        Font.Style := Font.Style + [fsUnderline];
    _ShowGroupTotals := TJabberSession(_JS).prefs.getBool('roster_groupcounts');
    _ShowStatus := TJabberSession(_JS).prefs.getBool('inline_status');
end;

{---------------------------------------}
procedure TExTreeView._RosterCallback(Event: string; Item: IExodusItem);
begin
  if Event = '/item/begin' then begin
      Self.Items.BeginUpdate;
      exit;
  end;
  if event = '/item/end' then begin
     RestoreGroupsState();
     Self.Items.EndUpdate;
     exit;
  end;

  if (FilterItem(Item) = false) then
      exit;

  if Event = '/item/add' then begin
     AddItemNode(Item);
     exit;
  end;
  if Event = '/item/update' then begin
     UpdateItemNodes(Item);
     exit;
  end;
  if event = '/item/remove' then begin
     RemoveItemNodes(Item);
     exit;
  end;


end;

{---------------------------------------}
procedure TExTreeView._SessionCallback(Event: string; Tag: TXMLTag);
begin
     //Force repaing if prefs have changed.
     if Event = '/session/prefs' then
     begin
         SetFontsAndColors();
         Invalidate();
     end
     else if (Event = '/session/disconnecting') then
     begin
         SaveGroupsState();
     end;
          
end;

{---------------------------------------}
procedure TExTreeView._GroupCallback(Event: string; Tag: TXMLTag; Data: WideString);
begin
    if Event = '/data/item/group/add' then
       AddNodeByName(Data);
end;

{---------------------------------------}
function TExTreeView.AddItemNode(Item: IExodusItem): TTntTreeNode;
var
    Root, Group, Node: TTntTreeNode;
    i: Integer;
begin
    //Remove all nodes pointing to the item
    RemoveItemNodes(Item);

    //Iterate through list of groups and make sure group exists
    for i := 0 to Item.GroupCount - 1 do
    begin
        //Check if group node exists
        Group := GetNodeByName(Item.Group[i]);
        //If group does not exists, create node.
        if (Group = nil) then
            Group := AddNodeByName(Item.Group[i]);

        //Add item to the group
        Node := Items.AddChild(Group, Item.Text);
        Node.Data := Pointer(Item);
        //Check if group item is expanded
        Root := TopNode(Node);
        if (TJabberSession(_js).ItemController.GroupExpanded[Item.Group[i]]) then
            Root.Expand(true)
        else
            Root.Collapse(true);
        UpdateItemNode(Node);

    end;

end;

{---------------------------------------}
//This function will use regular expression to parse group strings in
//format a/b/c or /a/b/c or /a/b/c/  and will return node with the name
//matching the passed string in the above format.
function TExTreeView.GetNodeByName(Group: WideString): TTntTreeNode;
var
    Found: Boolean;
    Node, Parent: TTntTreeNode;
begin
   Result := nil;
   Node := nil;
   Parent := nil;
   Found := _NestedGroups.Exec(group);
   //Continue while finding tokens separated by /
   while (Found) do
   begin
       Node := GetChildNodeByName(_NestedGroups.Match[0], Parent);
       if (Node = nil) then
           exit;
       //Found node becomes a parent and continue working down the tree.
       Parent := Node;
       Found := _NestedGroups.ExecNext();
   end;
   Result := Node;
end;

{---------------------------------------}
// Returns child node with the given name for the give parent.
function TExTreeView.GetChildNodeByName(Group: WideString; Parent: TTntTreeNode): TTntTreeNode;
var
     Child: TTntTreeNode;
     i: Integer;
begin
     Result := nil;
     //If no parent, look in all root the nodes.
     if (Parent = nil) then
     begin
         for i := 0 to Items.Count - 1 do
         begin
            if (WideTrim(Items[i].Text) = WideTrim(Group)) then
            begin
                Result := Items[i];
                exit;
            end;
         end;
         exit;
     end;

     //Match text for all children.
     Child := Parent.GetFirstChild();
     while (Child <> nil) do
     begin
         if (WideTrim(Child.Text) = WideTrim(Group)) then
         begin
             Result := Child;
             exit;
         end;
         Child := Parent.GetNextChild(Child);
     end;

end;

{---------------------------------------}
//This function will use regular expression to parse group strings in
//format a/b/c or /a/b/c or /a/b/c/  and will add node with the name
//matching the passed string in the above format if the node does not
//exists.
function TExTreeView.AddNodeByName(Group: WideString): TTntTreeNode;
var
    Found: Boolean;
    Node, Parent: TTntTreeNode;
begin
   Node := nil;
   Parent := nil;
   Found := _NestedGroups.Exec(Group);
   while (Found) do
   begin
       Node := GetChildNodeByName(_NestedGroups.Match[0], Parent);
       if (node = nil) then
           node := AddChildNodeByName(_NestedGroups.Match[0], Parent);
       Parent := Node;
       Found := _NestedGroups.ExecNext();
   end;
   Result := Node;
end;

{---------------------------------------}
//Adds group node to the given parent. Node name for the group is parsed (it
//will not contain '/')
function TExTreeView.AddChildNodeByName(group: WideString; parent: TTntTreeNode): TTntTreeNode;
begin
   Result := Items.AddChild(Parent, Group);
end;

{---------------------------------------}
//Returns a list of nodes for the given uid.
function TExTreeView.GetItemNodes(Uid: WideString) : TObjectList;
var
    i:Integer;
    Item: IExodusItem;
begin
    Result := TObjectList.Create();
    try
        for i := 0 to Items.Count - 1 do
        begin
           //Find non-group nodes
           if (Items[i].Data <> nil) then
           begin
              Item := IExodusItem(Items[i].Data);
              if (Item.Uid = Uid) then
                  Result.Add(Items[i]);
           end;
        end;
    except

    end;

end;

{---------------------------------------}
//Perform repainting for all the nodes for the given item.
procedure TExTreeView.UpdateItemNodes(Item: IExodusItem);
var
    Nodes: TObjectList;
    i: Integer;
begin
    if (Item = nil) then exit;
    Nodes := GetItemNodes(Item.Uid);
    for i := 0 to Nodes.Count - 1 do
       UpdateItemNode(TTntTreeNode(Nodes[i]));
end;

{---------------------------------------}
//Removes all the nodes for the given item.
procedure TExTreeView.RemoveItemNodes(Item: IExodusItem);
var
    i:Integer;
    CurrentItem: IExodusItem;
begin
    try
        for i := Items.Count - 1 downto 0 do
        begin
           //Find non-group nodes
           if (Items[i].Data <> nil) then
           begin
              CurrentItem := IExodusItem(Items[i].Data);
              if (CurrentItem.Uid = Item.Uid) then
                  Items.Delete(Items[i]);
           end;
        end;
    except

    end;
end;

{---------------------------------------}
//Repaint given node and all it's ancestors.
procedure TExTreeView.UpdateItemNode(Node: TTntTreeNode);
var
    Rect: TRect;
begin
    //Update all ancestors for the node if showing totals
    Rect := Node.DisplayRect(false);
    InvalidateRect(Handle, @Rect, true);
    Node := Node.Parent;
    while (Node <> nil) do
    begin
        UpdateItemNode(Node);
        Node := Node.parent;
    end;
end;

{---------------------------------------}
//This recursive function counts totals
//for active items in the given group node.
function  TExTreeView.GetActiveCounts(Node: TTntTreeNode): Integer;
var
    Child: TTntTreeNode;
    Item: IExodusItem;
begin
    if (node.Data <> nil) then
    begin
        //If it is a leaf, end recursion.
        item := IExodusItem(node.Data);
        if (item.Active) then
            Result := 1
        else
            Result := 0;
        exit;
    end;

    //Iterate through children and accumulate
    //totals for active for each child.
    Result := 0;
    Child := Node.GetFirstChild();
    while (Child <> nil) do
    begin
        //The following statement takes care of nested group totals.
        Result := Result + GetActiveCounts(Child);
        Child := Node.GetNextChild(Child);
    end;
end;

{---------------------------------------}
//This recursive function counts totals
//for total number of items in the given group node.
function  TExTreeView.GetLeavesCounts(Node: TTntTreeNode): Integer;
var
    Child: TTntTreeNode;
begin
    if (Node.Data <> nil) then
    //If it is a leaf, end recursion.
    begin
        Result := 1;
        exit;
    end;

    //Iterate through children and accumulate
    //totals for each child.
    Result := 0;
    Child := node.GetFirstChild();
    while (child <> nil) do
    begin
        //The following statement takes care of nested group totals.
        Result := Result + GetLeavesCounts(Child);
        Child := Node.GetNextChild(child);
    end;
end;

{---------------------------------------}
//This recursive function returns true
//if any of the ancestors for the node are collapsed.
function TExTreeView.Collapsed(Node: TTntTreeNode): Boolean;
begin
    //If most inner group collapsed, don't need recursion.
    if (Node.Expanded = false) then
    begin
         Result := Node.Expanded;
         exit;
    end;

    if (Node.Parent = nil) then
        Result := Node.Expanded
    else
        //Stop recursion if we find collpased ansestor 
        if (Node.Parent.Expanded = false) then
            Result := Node.Parent.Expanded
        else
            Result := Collapsed(Node.Parent);

end;

{---------------------------------------}
//Returns top most node for the given node.
function  TExTreeView.TopNode(Node: TTntTreeNode): TTntTreeNode;
begin
     if (Node.Parent = nil) then
          Result := Node
     else
          Result := TopNode(Node.Parent);
end;

{---------------------------------------}
//This recursive function returns full group name path for the nested groups
function  TExTreeView.GetNodePath(Node: TTntTreeNode): WideString;
begin
    if (Node = nil) then exit;

    if (Node.Parent <> nil) then
        Result := GetNodePath(Node.Parent) + _GroupSeparator + Node.Text
    else
        Result := Node.Text;

end;

{---------------------------------------}
//Returns the list of immediate subgroups
function  TExTreeView.GetSubgroups(Group: WideString): TWideStringList;
var
   Subgroups: TWideStringList;
   GroupNode, ChildNode: TTntTreeNode;
begin
   Subgroups := TWideStringList.Create();
   Result := Subgroups;
   GroupNode := GetNodeByName(Group);
   if (GroupNode = nil) then
       exit;
   if (GroupNode.Data <> nil) then
       exit;
   ChildNode := GroupNode.GetFirstChild();
   while (ChildNode <> nil) do
   begin
      if (ChildNode.Data = nil) then
          Subgroups.Add(ChildNode.Text);

      ChildNode := GroupNode.GetNextChild(ChildNode);
   end;
end;

{---------------------------------------}
{
function  TExTreeView.SwitchExpandedState() : Boolean;
var
    NodeRect: TRect;
    prevSelect: Boolean;
begin
    OutputDebugMsg('switching expanded state...');

    Result := false;
    prevSelect := _CurrentNode.Selected;
    NodeRect := _CurrentNode.DisplayRect(true);
    _CurrentNode.Selected := prevSelect;
    if (_LastMouseEvent.Type_ = meDoubleClick) then
       if (_LastMouseEvent.X > NodeRect.Left + Indent) then
           Result := true;


    if (_LastMouseEvent.Type_ = meClick) then
       if ((_LastMouseEvent.X > NodeRect.Left) and (_LastMouseEvent.X < NodeRect.Left + Indent - 1)) then
           Result := true;

    if (Result) then
    begin
        //If tree control has already expanded it (double clicking withing
        //indent will cause that, we do not need to reverse.
        //if (_CurrentNode.Expanded <> _LastMouseEvent.Expanded) then
        //    exit;
        //Proceed with switching the state if has not been done yet
        //by the tree control
        if (_CurrentNode.Expanded) then
           _CurrentNode.Collapse(false)
        else
           _CurrentNode.Expand(false);

    end;

end;
}

{---------------------------------------}
//Iterates thorugh all the nodes and saves exapanded state for group nodes.
procedure  TExTreeView.SaveGroupsState();
var
    i: Integer;
    Name: WideString;
begin
    for i := 0 to Items.Count - 1 do
    begin

        if (Items[i].Data <> nil) then
            continue;
        //TJabberSession(_js).ItemController.GroupExpanded[Items[i].Text] := Items[i].Expanded;
        Name := GetNodePath(Items[i]);
        TJabberSession(_js).ItemController.GroupExpanded[Name] := Collapsed(Items[i]);
    end;

    TJabberSession(_js).ItemController.SaveGroups();

end;

{---------------------------------------}
//Iterates thorugh all the nodes and restores expanded/collapsed state for the group.
procedure  TExTreeView.RestoreGroupsState();
var
    Expanded: Boolean;
    Name: WideString;
    i: Integer;
    Root: TTntTreeNode;
begin
     for i := 0 to Items.Count - 1 do
     begin
       if (Items[i].Data <> nil) then continue;
       Name := GetNodePath(Items[i]);
       Expanded := TJabberSession(_js).ItemController.GroupExpanded[Name];
       Root := TopNode(Items[i]);
       if (Expanded) then
           Root.Expand(true)
       else
           Root.Collapse(true);
    end;
end;

{---------------------------------------}
//This function figures out all the pieces
//to perform custom drawing for the individual node.
procedure TExTreeView.CustomDrawItem(Sender: TCustomTreeView;
                                     Node: TTreeNode;
                                     State: TCustomDrawState;
                                     var DefaultDraw: Boolean);
var
    Text, ExtendedText: WideString;
    IsGroup: Boolean;
    Item: IExodusItem;
begin
    // Perform initialization
    if (Node = nil) then exit;

    if (not Node.IsVisible) then exit;
    Item := nil;
    DefaultDraw := false;
    Text := '';
    ExtendedText := '';

    //If there is no data attached to the node, it is a group.
    if (Node.Data = nil) then
        IsGroup := true
    else
    begin
        IsGroup := false;
        Item := IExodusItem(Node.Data);
    end;

   if (IsGroup) then
   begin
       //Set extended text for totals for the groups, if required.
       Text := Node.Text;
       if (_ShowGroupTotals) then
          ExtendedText := '(' + IntToStr(GetActiveCounts(TTntTreeNode(Node))) + ' of '+ IntToStr(GetLeavesCounts(TTntTreeNode(Node))) + ' online)';
   end
   else
   begin
       if (Item <> nil) then
       begin
           //Set extended text for status for the node, if required.
           Text := Item.Text;
           if (_ShowStatus) then
               if (WideTrim(Item.ExtendedText) <> '') then
                   ExtendedText := ' - ' + Item.ExtendedText;
       end;
    end;

    DrawNodeText(TTntTreeNode(Node), State, Text, ExtendedText);
end;

{---------------------------------------}
//Performs drawing of text and images for the given node.
procedure TExTreeView.DrawNodeText(Node: TTntTreeNode; State: TCustomDrawState;
    Text, ExtendedText: Widestring);
var
    RightEdge, MaxRight, Arrow, Folder, TextWidth: integer;
    ImgRect, TxtRect, NodeRect, NodeFullRow: TRect;
    MainColor, StatColor, TotalsColor, InactiveColor: TColor;
    IsGroup: boolean;
    Item: IExodusItem;

begin

    Item := nil;
    //Save string width and height for the node text
    TextWidth := CanvasTextWidthW(Canvas, Text);
    //Set group flag based on presence of data attached.
    if (Node.Data = nil) then
       IsGroup := true
    else
    begin
       IsGroup := false;
       Item := IExodusItem(Node.Data);
    end;

    //Get default rectangle for the node
    NodeRect := Node.DisplayRect(true);
    NodeFullRow := NodeRect;
    NodeFullRow.Left := 0;
    NodeFullRow.Right := ClientWidth - 2;
    Canvas.Font.Color := Font.Color;
    Canvas.Brush.Color := Color;
    Canvas.FillRect(NodeFullRow);
    //Shift to the right to support two group icons for all groups
    NodeRect.Left := NodeRect.Left + Indent;
    NodeRect.Right := NodeRect.Right + Indent;
    TxtRect := NodeRect;
    ImgRect := NodeRect;
    RightEdge := nodeRect.Left + TextWidth + 2 + CanvasTextWidthW(Canvas, (ExtendedText + ' '));
    MaxRight := ClientWidth - 2;

    // make sure our rect isn't bigger than the treeview
    if (RightEdge >= MaxRight) then
        TxtRect.Right := MaxRight
    else
        TxtRect.Right := RightEdge;

    ImgRect.Left := ImgRect.Left - (2*Indent);

    Canvas.Font.Style := Self.Font.Style;
    // if selected, draw a solid rect
    if (cdsSelected in State) then
    begin
        Canvas.Font.Color := clHighlightText;
        Canvas.Brush.Color := clHighlight;
        Canvas.FillRect(TxtRect);
    end;

    if (IsGroup) then
    begin
        // this is a group
        if (Node.Expanded) then
        begin
            Arrow := RosterTreeImages.Find(RI_OPENGROUP_KEY);
            Folder := RosterTreeImages.Find(RI_FOLDER_OPEN_KEY);
        end
        else
        begin
            Arrow := RosterTreeImages.Find(RI_CLOSEDGROUP_KEY);
            Folder := RosterTreeImages.Find(RI_FOLDER_CLOSED_KEY);
        end;
        //Groups have two images
        //Draw > image
        frmExodus.ImageList1.Draw(Canvas,
                                  ImgRect.Left,
                                  ImgRect.Top, Arrow);
        //Move to the second image drawing
        ImgRect.Left := ImgRect.Left + Indent;
        //Draw second image
        frmExodus.ImageList1.Draw(Canvas,
                                  ImgRect.Left,
                                  ImgRect.Top, Folder);
    end
    else
        //Draw image for the item
        frmExodus.ImageList1.Draw(Canvas,
                                  ImgRect.Left + Indent,
                                  ImgRect.Top, Item.ImageIndex);


    // draw the text
    if (cdsSelected in State) then
    begin
        // Draw the focus box.
        Canvas.DrawFocusRect(TxtRect);
        MainColor := clHighlightText;
        StatColor := MainColor;
        TotalsColor := MainColor;
        InactiveColor := MainColor;
    end
    else
    begin
        MainColor := Canvas.Font.Color;
        StatColor := _StatusColor;
        TotalsColor := _TotalsColor;
        InactiveColor := _InactiveColor;
    end;

    //Figure out color for the node.
    if (IsGroup) then
       SetTextColor(Canvas.Handle, ColorToRGB(MainColor))
    else
       if (Item.Active) then
           SetTextColor(Canvas.Handle, ColorToRGB(MainColor))
       else
           SetTextColor(Canvas.Handle, ColorToRGB(InactiveColor));

    //Draw basic node text
    CanvasTextOutW(Canvas, TxtRect.Left + 1,  TxtRect.Top, Text, MaxRight);

    //Draw additional node text, if required.
    if (ExtendedText <> '') then begin
        if (IsGroup) then
            SetTextColor(Canvas.Handle, ColorToRGB(TotalsColor))
        else
            SetTextColor(Canvas.Handle, ColorToRGB(StatColor));

        CanvasTextOutW(Canvas, txtRect.Left + TextWidth + 4, TxtRect.Top, ExtendedText, MaxRight);
    end;

end;

{---------------------------------------}
procedure TExTreeView.DblClick();
var
    Item: IExodusItem;
    Nick, RegNick: WideString;
    UseRegNick: Boolean;
begin
    OutputDebugMsg('tree double-click event!');
    //inherited;

    if (_CurrentNode = nil) then exit;
    if (_CurrentNode.Data <> nil) then

    //Non-group node
    begin
        Item := IExodusItem(_CurrentNode.Data);
        if (Item.Type_ = EI_TYPE_CONTACT) then
        begin
            StartChat(Item.UID, '', true);
        end
        else if (Item.Type_ = EI_TYPE_ROOM) then
        begin
            try
               Nick := Item.value['nick'];
            except
            end;
            try
               RegNick := Item.value['reg_nick'];
            except
            end;
            if (RegNick = 'true') then
                UseRegNick := true
            else
                UseRegNick := false;

            StartRoom(Item.UID, Nick, '', true, false, UseRegNick);
        end;
    end;
end;

procedure TExTreeView.MouseDown(Button: TMouseButton;
                                Shift: TShiftState; X, Y: Integer);
var
  NodeRect: TRect;
  node: TTntTreeNode;
begin
    // check to see if we're hitting a button
    node := GetNodeAt(X, Y);
    if (node = nil) then begin
        Selected := nil;
        exit;
    end;

    // if we have a legit node.... make sure it's selected..
    if not (ssShift in Shift) and not (ssCtrl in Shift) then begin
        if (Selected <> node) then
            Select(node, Shift);
    end;

    _CurrentNode := node;
{
    if (_CurrentNode <> nil) then begin
        //Obtain node coordinates
        //NodeRect := _CurrentNode.DisplayRect(true);
        //Save mouse down event information for the future handling
        _LastMouseEvent.X := X;
        _LastMouseEvent.Y := Y;
        _LastMouseEvent.Button := Button;
        //We need to save expanded state for the node on the
        //"Mouse Down" event since tree control it trying to
        //expand/collapse node if mouse down event is part of
        //double click chain of events.
        //_LastMouseEvent.Expanded := _CurrentNode.Expanded;
    end;
}
end;

{---------------------------------------}
procedure TExTreeView.Editing(Sender: TObject; Node: TTreeNode; var AllowEdit: Boolean);
begin
     AllowEdit := false;
end;

{---------------------------------------}
function  TExTreeView.FilterItem(Item: IExodusItem): Boolean;
begin
    Result := true;
end;

procedure TExTreeView._GetActionableItems(items: IExodusItemList; node: TTntTreeNode);
var
    idx: Integer;
    item: IExodusItem;
begin
    if (node.Data = nil) then begin
        for idx := 0 to node.Count - 1 do  begin
            _GetActionableItems(items, node.Item[idx]);
        end;
    end else begin
        item := IExodusItem(node.Data);

        if item.IsVisible then items.Add(item);
    end;

end;
procedure TExTreeView.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
var
    actPM: TExActionPopupMenu;
    items: IExodusItemList;
    idx: Integer;
    pt: TPoint;
begin
    if Assigned(PopupMenu) and PopupMenu.InheritsFrom(TExActionPopupMenu) then begin
        items := TExodusItemList.Create as IExodusItemList;
        for idx := 0 to SelectionCount - 1 do begin
            _GetActionableItems(items, Selections[idx]);
        end;

        actPM := TExActionPopupMenu(PopupMenu);
        actPM.Targets := items;

        if InvalidPoint(MousePos) then
            pt := Point(0,0)
        else
            pt := MousePos;

        pt := ClientToScreen(pt);
        actPM.Popup(pt.X, pt.Y);

        Handled := true;
    end;
end;

procedure TExTreeView.Refresh;
var
    itemCtrl: IExodusItemController;
    item: IExodusItem;
    idx: Integer;
begin
    Items.Clear();

    //TODO:  make this use a local variable??
    itemCtrl := TJabberSession(_JS).ItemController;
    for idx := 0 to itemCtrl.ItemsCount - 1 do begin
        item := itemCtrl.Item[idx];

        if not FilterItem(item) then continue;

        AddItemNode(item);
    end;
end;

end.
