unit BaseChat;
{
    Copyright 2002, Peter Millard

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

interface

uses
    Dockable, 
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, OLERichEdit, ExRichEdit;

type
  TfrmBaseChat = class(TfrmDockable)
    Panel3: TPanel;
    MsgList: TExRichEdit;
    Splitter1: TSplitter;
    pnlInput: TPanel;
    MsgOut: TMemo;
    Panel1: TPanel;
    popOut: TPopupMenu;
    Copy1: TMenuItem;
    CopyAll1: TMenuItem;
    Clear1: TMenuItem;
    Emoticons1: TMenuItem;

    procedure Emoticons1Click(Sender: TObject);
    procedure MsgListURLClick(Sender: TObject; url: String);
    procedure FormActivate(Sender: TObject);
    procedure MsgOutKeyPress(Sender: TObject; var Key: Char);
    procedure MsgOutKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MsgListKeyPress(Sender: TObject; var Key: Char);
    procedure Splitter1Moved(Sender: TObject);
  private
    { Private declarations }
    _msgHistory : TStringList;
    _lastMsg : integer;
  public
    { Public declarations }
    procedure SetEmoticon(msn: boolean; imgIndex: integer);
    procedure SendMsg(); virtual;
  end;

var
  frmBaseChat: TfrmBaseChat;

implementation

{$R *.dfm}
uses
    Session, MsgDisplay, ShellAPI, Emoticons, Jabber1;

{---------------------------------------}
procedure TfrmBaseChat.Emoticons1Click(Sender: TObject);
var
    l, t: integer;
    cp: TPoint;
begin
  inherited;
    // Show the emoticons form
    GetCaretPos(cp);
    l := MsgOut.ClientOrigin.x + cp.X;

    if (Self.Docked) then begin
        t := frmExodus.Top + frmExodus.ClientHeight - 10;
        frmEmoticons.Left := l + 10;
        end
    else begin
        t := Self.Top + Self.ClientHeight - 10;
        frmEmoticons.Left := l + 10;
        end;

    if ((t + frmEmoticons.Height) > Screen.Height) then
        t := Screen.Height - frmEmoticons.Height;

    frmEmoticons.Top := t;
    frmEmoticons.ChatWindow := Self;
    frmEmoticons.Show;
end;

{---------------------------------------}
procedure TfrmBaseChat.SetEmoticon(msn: boolean; imgIndex: integer);
var
    l, i, m: integer;
    eo: TEmoticon;
begin
    // Setup some Emoticon
    m := -1;

    if (emoticon_list.Count = 0) then
        ConfigEmoticons();

    for i := 0 to emoticon_list.Count - 1 do begin
        eo := TEmoticon(emoticon_list.Objects[i]);
        if (((msn) and (eo.il = frmExodus.imgMSNEmoticons)) or
        ((not msn) and (eo.il = frmExodus.imgYahooEmoticons))) then begin
            // the image lists match
            if (eo.idx = imgIndex) then begin
                m := i;
                break;
                end;
            end;
        end;

    if (m >= 0) then begin
        l := length(MsgOut.Text);
        if ((l > 0) and ((MsgOut.Text[l]) <> ' ')) then
            MsgOut.SelText := ' ';
        MsgOut.SelText := emoticon_list[m];
        end;
end;

{---------------------------------------}
procedure TfrmBaseChat.MsgListURLClick(Sender: TObject; url: String);
begin
    ShellExecute(0, 'open', PChar(url), nil, nil, SW_SHOWNORMAL);
end;

{---------------------------------------}
procedure TfrmBaseChat.FormActivate(Sender: TObject);
begin
    inherited;
    if (frmEmoticons.Visible) then
        frmEmoticons.Hide;
    if Self.Visible then
        MsgOut.SetFocus;
end;

{---------------------------------------}
procedure TfrmBaseChat.MsgOutKeyPress(Sender: TObject; var Key: Char);
var
    cur_buff: string;
    e, i: integer;
    start: boolean;
begin
    if ( Key = #27 ) then
        Close()
    else if ( (Key = #127) and (HiWord(GetKeyState(VK_CONTROL)) <> 0)) then begin
        Key := #0;
        // delete the last word.
        // JJH: yes, this is at least slight overkill, but it was bothering me.
        cur_buff := MsgOut.Lines.Text;
        e := MsgOut.SelStart;
        i := e;
        start := true;
        while (i > 0) do begin
            if (start) then begin
                if (cur_buff[i] <> ' ') then begin
                    start := false;
                    dec(i);
                    end;
                end
            else if (cur_buff[i] = ' ') then
                break;

            dec(i);
            end;

        if (i >= 0) then with MsgOut do begin
            SelStart := i;
            SelLength := (e - i);
            SelText := '';
            end;
        end;

    if (key <> #0) then
        inherited;
end;

{---------------------------------------}
procedure TfrmBaseChat.MsgOutKeyUp(Sender: TObject;
                                   var Key: Word;
                                   Shift: TShiftState);
var
    m : string;
begin
// for now.
// TODO: use the message history that's in MsgList
    if ((Key = VK_UP) and (Shift = [ssCtrl])) then begin
        dec(_lastMsg);
        if (_lastMsg < 0) then begin
            _lastMsg := 0;
            exit;
            end;
        m := _msgHistory[_lastMsg];
        MsgOut.Text := m;
        MsgOut.SelStart := length(m);
        MsgOut.SetFocus();
        end
    else if ((Key = VK_DOWN) and (Shift = [ssCtrl])) then begin
        if (_lastMsg = _msgHistory.Count) then exit;
        inc(_lastMsg);
        if (_lastMsg >= _msgHistory.Count) then begin
            _lastMsg := _msgHistory.Count - 1;
            exit;
            end;
        m := _msgHistory[_lastMsg];
        MsgOut.Text := m;
        MsgOut.SelStart := length(m);
        MsgOut.SetFocus();
        end
    else
        inherited;
end;

{---------------------------------------}
procedure TfrmBaseChat.SendMsg();
begin
    _msgHistory.Add(MsgOut.Text);
    _lastMsg := _msgHistory.Count;

    MsgOut.Text := '';
    MsgOut.SetFocus;
end;

{---------------------------------------}
procedure TfrmBaseChat.FormCreate(Sender: TObject);
var
    ht: integer;
begin
    _msgHistory := TStringList.Create();
    _lastMsg := -1;

    if (MainSession <> nil) then begin
        ht := MainSession.Prefs.getInt('chat_textbox');
        if (ht <> 0) then
            pnlInput.Height := ht
        else
            MainSession.prefs.setInt('chat_textbox', pnlInput.Height);
        end;

    inherited;
end;

{---------------------------------------}
procedure TfrmBaseChat.FormDestroy(Sender: TObject);
begin
    _msgHistory.Free();
    inherited;
end;

{---------------------------------------}
procedure TfrmBaseChat.MsgListKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
    // If typing starts on the MsgList, then bump it to the outgoing
    // text box.
    if (not Self.Visible) then exit;
    if (Ord(key) < 32) then exit;

    MsgOut.SetFocus();
    MsgOut.SelText := Key;
end;

{---------------------------------------}
procedure TfrmBaseChat.Splitter1Moved(Sender: TObject);
begin
  inherited;
    // save the new position to use on all new windows
    MainSession.prefs.setInt('chat_textbox', pnlInput.Height);
end;

end.
