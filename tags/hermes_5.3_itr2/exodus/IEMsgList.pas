unit IEMsgList;

{
    Copyright 2004, Peter Millard

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

// To use IE (TWebBrowser) as the history window in chats/rooms
// set <msglist_type value="1"/> in the defaults
// or a branding file.  If msglist_type is left at a value of 0, then the
// history window will still be RTF and not HTML even though HTML support is
// compiled in.

interface


uses
    TntMenus, JabberMsg,
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, Regexpr, iniFiles,
    BaseMsgList, Session, gnugettext, unicode,
    XMLTag, XMLNode, XMLConstants, XMLCdata, LibXmlParser, XMLUtils,
    OleCtrls, SHDocVw, MSHTML, mshtmlevents, ActiveX;

  function HTMLColor(color_pref: integer) : widestring;

type
  TfIEMsgList = class(TfBaseMsgList)
    browser: TWebBrowser;
    procedure browserDocumentComplete(Sender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure browserBeforeNavigate2(Sender: TObject;
      const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    procedure browserDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure browserDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);

  private
    { Private declarations }
    _home: WideString;

    _doc: IHTMLDocument2;
    _win: IHTMLWindow2;
    _body: IHTMLElement;
    _style: IHTMLStyleSheet;
    _content: IHTMLElement;
    _content2: IHTMLElement2;
    _lastelement: IHTMLElement;
    _composingelement: IHTMLElement;

    _we: TMSHTMLHTMLElementEvents;
    _we2: TMSHTMLHTMLElementEvents2;
    _de: TMSHTMLHTMLDocumentEvents;

    _bottom: Boolean;
    _menu:  TTntPopupMenu;
    _queue: TWideStringList;
    _title: WideString;
    _ready: Boolean;
    _idCount: integer;
    _displayDateSeperator: boolean;
    _lastTimeStamp: TDateTime;
    _composing: integer;
    _msgCount: integer;
    _maxMsgCountHigh: integer;
    _maxMsgCountLow: integer;
    _doMessageLimiting: boolean;

    _dragDrop: TDragDropEvent;
    _dragOver: TDragOverEvent;

    procedure onScroll(Sender: TObject);
    procedure onResize(Sender: TObject);

    function onDrop(Sender: TObject): WordBool;
    function onDragOver(Sender: TObject): WordBool;
    function onContextMenu(Sender: TObject): WordBool;
    function onKeyPress(Sender: TObject; const pEvtObj: IHTMLEventObj): WordBool;
    function _genElementID(): WideString;
    procedure _ClearOldMessages();
    function _getHistory(includeCount: boolean = true): WideString;
    function _processUnicode(txt: widestring): WideString;

  protected
      procedure writeHTML(html: WideString);

  public
    { Public declarations }
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    procedure Invalidate(); override;
    procedure CopyAll(); override;
    procedure Copy(); override;
    procedure ScrollToBottom(); override;
    procedure Clear(); override;
    procedure setContextMenu(popup: TTntPopupMenu); override;
    procedure setDragOver(event: TDragOverEvent); override;
    procedure setDragDrop(event: TDragDropEvent); override;
    procedure DisplayMsg(Msg: TJabberMessage; AutoScroll: boolean = true); override;
    procedure DisplayPresence(txt: string; timestamp: string); override;
    function  getHandle(): THandle; override;
    function  getObject(): TObject; override;
    function  empty(): boolean; override;
    function  getHistory(): Widestring; override;
    procedure Save(fn: string); override;
    procedure populate(history: Widestring); override;
    procedure setupPrefs(); override;
    procedure setTitle(title: Widestring); override;
    procedure ready(); override;
    procedure refresh(); override;
    procedure DisplayComposing(msg: Widestring); override;
    procedure HideComposing(); override;
    function  isComposing(): boolean; override;

    procedure ChangeStylesheet(resname: WideString);
    procedure print(ShowDialog: boolean);
  end;

var
  fIEMsgList: TfIEMsgList;
  xp_xhtml: TXPLite;
  ok_tags: THashedStringList;
  style_tags: THashedStringList;
  style_props: THashedStringList;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation


uses
    JabberConst,
    Jabber1,
    BaseChat,
    JabberUtils,
    ExUtils,
    ShellAPI,
    Emote,
    StrUtils;

{$R *.dfm}

{---------------------------------------}
function HTMLColor(color_pref: integer) : widestring;
var
    color: TColor;
begin
    color := TColor(color_pref);
    Result := IntToHex(GetRValue(color), 2) +
              IntToHex(GetGValue(color), 2) +
              IntToHex(GetBValue(color), 2);
end;

{---------------------------------------}
constructor TfIEMsgList.Create(Owner: TComponent);
begin
    inherited;
    _queue := TWideStringList.Create();
    _ready := true;
    _idCount := 0;
    _composing := -1;
    _msgCount := 0;
    _maxMsgCountHigh := MainSession.Prefs.getInt('maximum_displayed_messages');
    _maxMsgCountLow := MainSession.Prefs.getInt('maximum_displayed_messages_drop_down_to');
    if ((_maxMsgCountHigh <> 0) and
        (_maxMsgCountLow <> 0) and
        (_maxMsgCountHigh >= _maxMsgCountLow))then
        _doMessageLimiting := true
    else
        _doMessageLimiting := false;
    _displayDateSeperator := MainSession.Prefs.getBool('display_date_seperator');
end;

{---------------------------------------}
destructor TfIEMsgList.Destroy;
begin
    if (_queue <> nil) then begin
        _queue.Free();
        _queue := nil;
    end;
    inherited;
end;

{---------------------------------------}
procedure TfIEMsgList.writeHTML(html: WideString);
begin
    if (_content = nil) then begin
        assert(_queue <> nil);
        _queue.Add(html);
        exit;
    end;

    // For some reason, the _content that is set
    // elsewhere is causing exceptions
    _content := _doc.all.item('content', 0) as IHTMLElement;
    _content.insertAdjacentHTML('beforeEnd', html);
end;

{---------------------------------------}
procedure TfIEMsgList.Invalidate();
begin
//    browser.Invalidate();
end;

{---------------------------------------}
procedure TfIEMsgList.CopyAll();
begin
    _doc.execCommand('SelectAll', false, varNull);
    _doc.execCommand('Copy', true, varNull);
    _doc.execCommand('Unselect', false, varNull);
end;

{---------------------------------------}
procedure TfIEMsgList.Copy();
begin
    _doc.execCommand('Copy', true, varNull);
end;

{---------------------------------------}
procedure TfIEMsgList.ScrollToBottom();
var
    tags: IHTMLElementCollection;
    last: IHTMLElement;
begin
    if (_win = nil) then exit;

    // this is a slowness for large histories, I think, but it is the only
    // thing that seems to work, since we are now scrolling the _content
    // element, rather than the window, as Bill intended.
    tags := _content.children as IHTMLElementCollection;
    if (tags.length > 0) then begin
        last := tags.Item(tags.length - 1, 0) as IHTMLElement;
        last.ScrollIntoView(false);
    end;
end;

{---------------------------------------}
procedure TfIEMsgList.Clear();
begin
    _ready := true;
    _home := 'res://' + URL_EscapeChars(Application.ExeName);
    browser.Navigate(_home + '/iemsglist');
end;

{---------------------------------------}
procedure TfIEMsgList.setContextMenu(popup: TTntPopupMenu);
begin
    _menu := popup;
end;

{---------------------------------------}
function TfIEMsgList.getHandle(): THandle;
begin
    Result := 0; //Browser.Handle;
end;

{---------------------------------------}
function TfIEMsgList.getObject(): TObject;
begin
    // Result := Browser;
    result := nil;
end;

{---------------------------------------}
function ProcessTag(parent: TXMLTag; n: TXMLNode): WideString;
var
    nodes: TXMLNodeList;
    i, j: integer;
    attrs: TAttrList;
    attr: TAttr;
    tag: TXMLTag;
    chunks: TWideStringList;
    nv : TWideStringList;
    started: boolean;
    str: WideString;
    tag_name: WideString;
    aname: WideString;
begin
    // See JEP-71 (http://www.jabber.org/jeps/jep-0071.html) for details.

    result := '';

    // any tag not in the good list should be deleted, but everything else
    // around it should stay.
    // opted to do own serialization for efficiency; didn't want to have to
    // make many passes over the same data.
    if (n.NodeType = xml_Tag) then begin
        tag := TXMLTag(n);
        tag_name := lowercase(tag.Name);

        if (ok_tags.IndexOf(tag_name) < 0) then
            exit;

        result := result + '<' + tag_name;

        nv := TWideStringList.Create();
        chunks := TWideStringList.Create();
        attrs := tag.Attributes;
        for i := 0 to attrs.Count - 1 do begin
            attr := TAttr(attrs[i]);
            aname := lowercase(attr.Name);
            if (aname = 'style') then begin
                // style attribute only allowed on style_tags.
                if (style_tags.IndexOf(tag_name) >= 0) then begin
                    //  remove any style properties that aren't in the allowed list
                    chunks.Clear();
                    split(attr.value, chunks, ';');
                    started := false;
                    for j := 0 to chunks.Count - 1 do begin
                        nv.Clear();
                        split(chunks[j], nv, ':');
                        if (nv.Count < 1) then
                            continue;
                        if (style_props.IndexOf(nv[0]) >= 0) then begin
                            if (not started) then begin
                                started := true;
                                result := result + ' style="';
                            end;
                            result := result + HTML_EscapeChars(chunks[j], false, true) + ';';
                        end;
                    end;
                    if (started) then
                        result := result + '"';
                end;
            end
            else if (tag_name = 'a') then begin
                if (aname = 'href') then
                    result := result + ' ' +
                        attr.Name + '="' + HTML_EscapeChars(attr.Value, false, true) + '"';
            end
            else if (tag_name = 'img') then begin
                if ((aname = 'alt') or
                    (aname = 'height') or
                    (aname = 'longdesc') or
                    (aname = 'src') or
                    (aname = 'width')) then begin
                    result := result + ' ' +
                        aname + '="' + HTML_EscapeChars(attr.Value, false, true) + '"';
                end;
            end
        end;
        nv.Free();
        chunks.Free();

        nodes := tag.Nodes;
        if (nodes.Count = 0) then
            result := result + '/>'
        else begin
            // iterate over all the children
            result := result + '>';
            for i := 0 to nodes.Count - 1 do
                result := result + ProcessTag(tag, TXMLNode(nodes[i]));
            result := result + '</' + tag.name + '>';
        end;
    end
    else if (n.NodeType = xml_CDATA) then begin
        // Check for URLs
        if ((parent = nil) or (parent.Name <> 'a')) then begin
            str := REGEX_URL.Replace(TXMLCData(n).Data,
                                     '<a href="$0">$0</a>', true);
            result := result + ProcessIEEmoticons(str);
        end
        else
            result := result + TXMLCData(n).Data;
    end;
end;

{---------------------------------------}
procedure TfIEMsgList.DisplayMsg(Msg: TJabberMessage; AutoScroll: boolean = true);
var
    txt: WideString;
    body: TXmlTag;
    i: integer;
    nodes: TXMLNodeList;
    cd: TXMLCData;
    dv: WideString;
    t: TDateTime;
    id: WideString;
begin
    try
        if (_displayDateSeperator) then begin
            t := msg.Time;
            if ((DateToStr(t) <> DateToStr(_lastTimeStamp)) and
                (msg.Subject = '') and
                (msg.Nick <> ''))then begin
                txt := '<div class="date"><span><br />';
                txt := txt +
                       ' -= ' +
                       DateToStr(t) +
                       ' =- ' +
                       '<br /></span></div>';

                writeHTML(txt);
                _lastTimeStamp := msg.Time;
                txt := '';
                if (_doMessageLimiting) then
                    Inc(_msgCount);
            end;
        end;
    except
    end;

    _clearOldMessages();

    if (not Msg.Action) then begin
        // ignore HTML for actions.  it's harder than you think.
        body := Msg.Tag.QueryXPTag(xp_xhtml);

        if (body <> nil) then begin
        // if first node is a p tag, make it a span...
            if ((body.Nodes.Count > 0) and
                (TXMLTag(body.Nodes[0]).NodeType = xml_tag) and
                (TXMLTag(body.Nodes[0]).Name = 'p')) then
                TXMLTag(body.Nodes[0]).Name := 'span';

            nodes := body.nodes;
            for i := 0 to nodes.Count - 1 do
                txt := txt + ProcessTag(body, TXMLNode(nodes[i]));
        end;
    end;

    if (txt = '') then begin
        txt := HTML_EscapeChars(Msg.Body, false, false);
        txt := _processUnicode(txt); //StringReplace() cannot handle
        txt := StringReplace(txt, ' ', '&ensp;', [rfReplaceAll]);
        cd := TXMLCData.Create(txt);
        txt := ProcessTag(nil, cd);
        txt := REGEX_CRLF.Replace(txt, '<br />', true);
        cd.Free();
    end;

    // build up a string, THEN call writeHTML, since IE is being "helpful" by
    // canonicalizing HTML as it gets inserted.
    id := _genElementID();
    dv := '<div id="' + id + '" class="line">';
    if (MainSession.Prefs.getBool('timestamp')) then begin
        try
            dv := dv + '<span class="ts">[' +
                FormatDateTime(MainSession.Prefs.getString('timestamp_format'), Msg.Time) +
                ']</span>';
        except
            on EConvertError do begin
                dv := dv + '<span class="ts">[' +
                    FormatDateTime(MainSession.Prefs.getString('timestamp_format'),
                    Now()) + ']</span>';
            end;
        end;
    end;

    if (Msg.Nick = '') then begin
        // Server generated msgs (mostly in TC Rooms)
        dv := dv + '<span class="svr">' + txt + '</span>';
    end
    else if not Msg.Action then begin
        // This is a normal message

        if (Msg.Priority = high) then
            dv := dv + '<span class="pri_high">[' + GetDisplayPriority(Msg.Priority) + ']</span>'
        else if (Msg.Priority = low) then
            dv := dv + '<span class="pri_low">[' + GetDisplayPriority(Msg.Priority) + ']</span>';

        if Msg.isMe then
            // our own msgs
            dv := dv + '<span class="me">&lt;' + Msg.Nick + '&gt;</span>'
        else
            dv := dv + '<span class="other">&lt;' + Msg.Nick + '&gt;</span>';

        if (Msg.Highlight) then
            dv := dv + '<span class="alert"> ' + txt + '</span>'
        else
            dv := dv + '<span class="msg">' + txt + '</span>';
    end
    else
        // This is an action
        dv := dv + '<span class="action">&nbsp;*&nbsp;' + Msg.Nick + '&nbsp;' + txt + '</span>';

    dv := dv + '</div>';
    writeHTML(dv);

    _lastelement := _doc.all.item(id, 0) as IHTMLElement;

    if (_doMessageLimiting) then
        Inc(_msgCount);

    if (_bottom) then
        ScrollToBottom();
end;

{---------------------------------------}
procedure TfIEMsgList.DisplayPresence(txt: string; timestamp: string);
var
    pt : integer;
    tags: IHTMLElementCollection;
    dv : IHTMLElement;
    sp : IHTMLElement;
    i : integer;
begin
    pt := MainSession.Prefs.getInt('pres_tracking');
    if (pt = 2) then exit;

    if ((pt = 1) and (_content <> nil)) then begin
        // if previous is a presence, replace with this one.
        tags := _content.children as IHTMLElementCollection;
        if (tags.length > 0) then begin
            dv := tags.Item(tags.length - 1, 0) as IHTMLElement;
            tags := dv.children as IHTMLElementCollection;
            for i := 0 to tags.length - 1 do begin
                sp := tags.Item(i, 0) as IHTMLElement;
                if sp.className = 'pres' then begin
                    dv.outerHTML := '';
                    if (_doMessageLimiting) then
                        Dec(_msgCount);
                    break;
                end;
            end;
        end;
    end;

    if timestamp <> '' then
        writeHTML('<div class="line"><span class="ts">[' + timestamp + ']</span><span class="pres">' + txt + '</span></div>')
    else
        writeHTML('<div class="line"><span class="pres">' + txt + '</span></div>');

    if (_bottom) then
        ScrollToBottom();

    if (_doMessageLimiting) then
        Inc(_msgCount);
end;

{---------------------------------------}
procedure TfIEMsgList.Save(fn: string);
var
    txt: widestring;
    elem: IHTMLElement;
    byteorder_marker: Word;
    fs: TFileStream;
begin
    fs := nil;

    // Save out the HTML to a file using widestring
    // This means that it is UTF-16
    if (browser = nil) then exit;

    elem := _doc.body.parentElement;
    if (elem = nil) then exit;

    try
        try
            fs := TFileStream.Create(fn, fmCreate);
            byteorder_marker := $FEFF; // Unicode marker for file.
            txt := elem.outerHTML;
            fs.WriteBuffer(byteorder_marker, sizeof(byteorder_marker));
            fs.WriteBuffer(txt[1], Length(txt)*sizeof(txt[1]));
        except

        end;
    finally
        fs.free;
    end;
end;

{---------------------------------------}
procedure TfIEMsgList.populate(history: Widestring);
var
    txt: widestring;
    p: integer;
begin
    p := pos('-->', history);

    if ((p > 0) and
        (LeftStr(history, 4) = '<!--')) then begin
        txt := LeftStr(history, p - 1);
        txt := MidStr(txt, 5, Length(txt));
        try
            if (_doMessageLimiting) then begin
                _msgCount := StrToInt(txt);
            end;
        except
        end;
        history := MidStr(history, p + 3, Length(history));
    end;

    writeHTML(history);

    if (_doMessageLimiting) then begin
        _clearOldMessages();
    end;
end;

{---------------------------------------}
procedure TfIEMsgList.setupPrefs();
begin
    // XXX: IE MsgList should pick up stylesheet prefs
end;

{---------------------------------------}
function TfIEMsgList.empty(): boolean;
begin
    if (_content = nil) then
        Result := true
    else
        Result := (_content.innerHTML = '');
end;

{---------------------------------------}
function TfIEMsgList.getHistory(): Widestring;
begin
    Result := _getHistory();
end;

{---------------------------------------}
function TfIEMsgList._getHistory(includeCount: boolean): WideString;
begin
    Result := '';
    if (_content = nil) then
        Result := ''
    else begin
        if (includeCount) then
            Result := '<!--' + IntToStr(_msgCount) + '-->';
        Result := Result + _content.innerHTML;
    end;
end;


{---------------------------------------}
procedure TfIEMsgList.setDragOver(event: TDragOverEvent);
begin
    _dragOver := event;
end;

{---------------------------------------}
procedure TfIEMsgList.setDragDrop(event: TDragDropEvent);
begin
    _dragDrop := event;
end;

{---------------------------------------}
procedure TfIEMsgList.ChangeStylesheet(resname: WideString);
    function replaceString(source, key, newtxt: Widestring): widestring;
    var
        offset: integer;
    begin
        if ((source = '') or
            (key = '')) then
            exit;

        Result := '';
        offset := Pos(key, source);
        while (offset > 0) do begin
            Result := Result + LeftStr(source, offset - 1);
            Result := Result + newtxt;
            source := MidStr(source, offset + Length(key), Length(source));
            offset := Pos(key, source);
        end;
        Result := Result + source;        
    end;
var
    stream: TResourceStream;
    tmp: TWideStringList;
    css: Widestring;
    i: integer;
begin
    try
        // Get CSS template from resouce
        stream := TResourceStream.Create(HInstance, resname, 'CSS');

        tmp := TWideStringList.Create;
        tmp.LoadFromStream(stream);
        css := '';
        for i := 0 to tmp.Count - 1 do
            css := css + tmp.Strings[i];

        tmp.Clear;
        tmp.Free;
        stream.Free(); 

        // Place colors in CSS
        if (css <> '') then begin
            css := replaceString(css, '/*font_name*/', MainSession.Prefs.getString('font_name'));
            css := replaceString(css, '/*font_size*/', MainSession.Prefs.getString('font_size') + 'pt');
            css := replaceString(css, '/*font_color*/', HTMLColor(MainSession.Prefs.getInt('font_color')));
            css := replaceString(css, '/*color_bg*/', HTMLColor(MainSession.Prefs.getInt('color_bg')));
            css := replaceString(css, '/*color_me*/', HTMLColor(MainSession.Prefs.getInt('color_me')));
            css := replaceString(css, '/*color_other*/', HTMLColor(MainSession.Prefs.getInt('color_other')));
            css := replaceString(css, '/*color_time*/', HTMLColor(MainSession.Prefs.getInt('color_time')));
            css := replaceString(css, '/*color_priority*/', HTMLColor(MainSession.Prefs.getInt('color_priority')));
            css := replaceString(css, '/*color_action*/', HTMLColor(MainSession.Prefs.getInt('color_action')));
            css := replaceString(css, '/*color_server*/', HTMLColor(MainSession.Prefs.getInt('color_server')));
        end;

        // put CSS into page
        if (css <> '') then begin
            _style := _doc.createStyleSheet('', 0);
            _style.cssText := css;
            _style.disabled := false;
        end;
    except
    end;
end;

{---------------------------------------}
procedure TfIEMsgList.onScroll(Sender: TObject);
begin
    if _content2 = nil then
        _bottom := true
    else
    _bottom :=
        ((_content2.scrollTop + _content2.clientHeight) >= _content2.scrollHeight);
end;

{---------------------------------------}
procedure TfIEMsgList.onResize(Sender: TObject);
begin
//    if (_bottom) then
//         ScrollToBottom();
end;

{---------------------------------------}
function TfIEMsgList.onContextMenu(Sender: TObject): WordBool;
begin
    _menu.Popup(_win.event.screenX, _win.event.screeny);
    result := false;
end;

{---------------------------------------}
function TfIEMsgList.onKeyPress(Sender: TObject; const pEvtObj: IHTMLEventObj): WordBool;
var
    bc: TfrmBaseChat;
    key: integer;
begin
    // If typing starts on the MsgList, then bump it to the outgoing
    // text box.
    bc := TfrmBaseChat(_base);
    if (not bc.MsgOut.Enabled) then exit;

    if (not bc.Visible) then exit;

    key := pEvtObj.keyCode;

    if (key = 22) then begin
        // paste, Ctrl-V
        if (bc.MsgOut.Visible and bc.MsgOut.Enabled) then begin
            bc.MsgOut.PasteFromClipboard();
            bc.MsgOut.SetFocus();
        end;
    end
    else if ((MainSession.Prefs.getBool('esc_close')) and (key = 27)) then begin
        if (Self.Parent <> nil) then begin
            if (Self.Parent.Parent <> nil) then begin
                SendMessage(Self.Parent.Parent.Handle, WM_CLOSE, 0, 0);
            end;
        end;
    end
    else if (key < 32) then begin
        // Not a "printable" key
        bc.MsgOut.SetFocus();
    end
    else if (bc.pnlInput.Visible) then begin
        if (bc.MsgOut.Visible and bc.MsgOut.Enabled) then begin
            bc.MsgOut.WideSelText := WideChar(Key);
            bc.MsgOut.SetFocus();
        end;
    end;
    pEvtObj.returnValue := false;
    // This shouldn't be needed, but the TWebbrowser control takes back focus.
    // You would think that the SetFocus() calls above wouldn't be necessary then
    // but for some reason the Post doesn't work if they aren't called?
    PostMessage(bc.Handle, WM_SETFOCUS, 0, 0);
    Result := false;
end;

{---------------------------------------}
function TfIEMsgList.onDrop(Sender: TObject): WordBool;
begin
    _dragDrop(sender, browser, _win.event.x, _win.event.y);
    result := false;
end;

{---------------------------------------}
function TfIEMsgList.onDragOver(Sender: TObject): WordBool;
var
    accept: boolean;
begin
    accept := true;
    _dragOver(sender, browser, _win.event.x, _win.event.y, dsDragMove, accept);
    result := accept;
end;

{---------------------------------------}
procedure TfIEMsgList.browserDocumentComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
    i: integer;
begin
    inherited;
    try
        if ((not _ready) or (browser.Document = nil)) then
            exit;

        _ready := false;
        _doc := browser.Document as IHTMLDocument2;
        ChangeStylesheet('iemsglist_style');

        _content := _doc.all.item('content', 0) as IHTMLElement;
        _content2 := _content as IHTMLElement2;
        _body := _doc.body;
        _bottom := true;

        _win := _doc.parentWindow;
        if (_we <> nil) then
            _we.Free();
        if (_we2 <> nil) then
            _we2.Free();

        _we := TMSHTMLHTMLElementEvents.Create(self);
        _we.Connect(_content);
        _we.onscroll   := onscroll;
        _we.onresize   := onresize;
        _we.ondrop     := ondrop;
        _we.ondragover := ondragover;

        _we2 := TMSHTMLHTMLElementEvents2.Create(self);
        _we2.Connect(_content);
        _we2.onkeypress := onkeypress;

        if (_de <> nil) then
            _de.Free();
        _de := TMSHTMLHTMLDocumentEvents.Create(self);
        _de.Connect(_doc);
        _de.oncontextmenu := onContextMenu;

        assert (_queue <> nil);
        for i := 0 to _queue.Count - 1 do begin
            writeHTML(_queue.Strings[i]);
        end;
        _queue.Clear();
        if (_title <> '') then begin
            setTitle(_title);
        end;
        ScrollToBottom();
    except
        // When Undocking, the browser.Document becomes bad and
        // throws an exception.  Call Clear() to force a re-navigation
        // to reset browser.Document.
        Clear();
    end;
end;

{---------------------------------------}
procedure TfIEMsgList.browserBeforeNavigate2(Sender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
    u: string;
begin
    u := URL;
    if (u <> _home + '/iemsglist') then begin
        ShellExecute(Application.Handle, 'open', pAnsiChar(u), '', '', SW_SHOW);
        cancel := true;
    end;
    inherited;
end;

{---------------------------------------}
procedure TfIEMsgList.setTitle(title: Widestring);
//var
//    splash : IHTMLElement;
begin
//    if (_doc = nil) then begin
//        _title := title;
//        exit;
//    end;
//
//    splash :=  _doc.all.item('splash', 0) as IHTMLElement;
//    if (splash = nil) then exit;
//
//    splash.innerText := _title;
end;

{---------------------------------------}
procedure TfIEMsgList.ready();
begin
//    _ready := true;
//    Clear();
end;

{---------------------------------------}
procedure TfIEMsgList.refresh();
begin
    _queue.Add(_getHistory(false));
    Clear();
end;

{---------------------------------------}
procedure TfIEMsgList.browserDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
    _dragDrop(sender, source, x, y);
//  inherited;
end;

{---------------------------------------}
procedure TfIEMsgList.browserDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
    _dragOver(sender, source, x, y, state, accept);
//   inherited;
end;

{---------------------------------------}
procedure TfIEMsgList.DisplayComposing(msg: Widestring);
var
    outstring: Widestring;
    id: widestring;
begin
    HideComposing();
    _composing := 1;
    id := _genElementID();
    outstring := '<div id="' +
                 id +
                 '"><br /><span class="composing">' +
                 HTML_EscapeChars(msg, false, false) +
                 '</span><br /></div>';
    writeHTML(outstring);
    _composingelement := _doc.all.item(id, 0) as IHTMLElement;

    ScrollToBottom();
end;

{---------------------------------------}
procedure TfIEMsgList.HideComposing();
begin
    if (_composing = -1) then exit;

    if (_composingelement <> nil) then begin
        _composingelement.outerHTML := '';
        _composingelement := nil;
    end;

    _composing := -1;
end;

{---------------------------------------}
function TfIEMsgList.isComposing(): boolean;
begin
    Result := (_composing >= 0);
end;

{---------------------------------------}
function TfIEMsgList._genElementID(): WideString;
begin
    Result := 'msg_id_' + IntToStr(_idCount);
    Inc(_idCount);
end;

{---------------------------------------}
procedure TfIEMsgList.print(ShowDialog: boolean);
var
   vIn, vOut: OleVariant;
begin
    if (browser = nil) then exit;

    if (ShowDialog) then begin
        browser.ControlInterface.ExecWB(OLECMDID_PRINT, OLECMDEXECOPT_PROMPTUSER, vIn, vOut);
    end
    else begin
        browser.ControlInterface.ExecWB(OLECMDID_PRINT, OLECMDEXECOPT_DONTPROMPTUSER, vIn, vOut);
    end;
end;


{---------------------------------------}
procedure TfIEMsgList._clearOldMessages();
var
    children: IHTMLElementCollection;
    elem: IHTMLElement;
begin
    if ((_doMessageLimiting) and
        (_msgCount >= _maxMsgCountHigh) and
        (_content <> nil)) then begin
        while (_msgCount >= _maxMsgCountLow) do begin
            children := _content.children as IHTMLElementCollection;
            if (children <> nil) then begin
                elem := children.item(0, 0) as IHTMLElement;
                if (elem <> nil) then begin
                    elem.outerHTML := '';
                    Dec(_msgCount);
                end;
            end;
        end;
    end;
end;

{---------------------------------------}
function TfIEMsgList._processUnicode(txt: widestring): WideString;
var
    i: integer;
begin
    Result := '';
    for i := 1 to Length(txt) do begin
        if (Ord(txt[i]) > 126) then begin
            // This looks to be a non-ascii char so represent in HTML escaped notation
            try
                Result := Result + '&#' + IntToStr(Ord(txt[i])) + ';';
            except
                exit;
            end;
        end
        else begin
            Result := Result + txt[i];
        end;
    end;
end;

initialization
    TP_GlobalIgnoreClassProperty(TWebBrowser, 'StatusText');

    xp_xhtml := TXPLite.Create('/message/html/body');

    ok_tags := THashedStringList.Create();
    ok_tags.Add('blockquote');
    ok_tags.Add('br');
    ok_tags.Add('cite');
    ok_tags.Add('code');
    ok_tags.Add('div');
    ok_tags.Add('em');
    ok_tags.Add('h1');
    ok_tags.Add('h2');
    ok_tags.Add('h3');
    ok_tags.Add('p');
    ok_tags.Add('pre');
    ok_tags.Add('q');
    ok_tags.Add('span');
    ok_tags.Add('strong');
    ok_tags.Add('a');
    ok_tags.Add('ol');
    ok_tags.Add('ul');
    ok_tags.Add('li');
    ok_tags.Add('img');

    style_tags := THashedStringList.Create();
    style_tags.Add('blockquote');
    style_tags.Add('body');
    style_tags.Add('div');
    style_tags.Add('h1');
    style_tags.Add('h2');
    style_tags.Add('h3');
    style_tags.Add('li');
    style_tags.Add('ol');
    style_tags.Add('p');
    style_tags.Add('pre');
    style_tags.Add('q');
    style_tags.Add('span');
    style_tags.Add('ul');

    style_props := THashedStringList.Create();
    style_props.Add('color');
    style_props.Add('font-family');
    style_props.Add('font-size');
    style_props.Add('font-style');
    style_props.Add('font-weight');
    style_props.Add('text-align');
    style_props.Add('text-decoration');

finalization
    xp_xhtml.Free();
    ok_tags.Free();
    style_tags.Free();
    style_props.Free();


end.

