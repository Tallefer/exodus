unit Notify;
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

interface

uses
    XMLTag,
    JabberID,
    Presence,
    Dockable,
    Windows, Forms, Contnrs, SysUtils, classes;

type
    TNotifyController = class
    private
        _session: TObject;
        _presCallback: longint;
    published
        procedure Callback (event: string; tag: TXMLTag);
        procedure PresCallback(event: string; tag: TXMLTag; p: TJabberPres);
    public
        constructor Create;
        destructor Destroy; override;
        procedure SetSession(js: TObject);
end;

const
    // image index for tab notification.
    tab_notify = 42;

procedure DoNotify(win: TForm; notify: integer; msg: Widestring; icon: integer;
    sound_name: string); overload;
procedure DoNotify(win: TForm; pref_name: string; msg: Widestring; icon: integer); overload;

implementation
uses
    RosterImages,
    RosterForm,
    StateForm,
    DisplayName,
    BaseChat, JabberUtils, ExUtils,  GnuGetText,
    Jabber1, PrefController, RiserWindow,
    Room, ContactController, MMSystem, Debug, Session;

const
    sNotifyOnline = ' is now online.';
    sNotifyOffline = ' is now offline.';
    
{---------------------------------------}
constructor TNotifyController.Create;
begin
    //
    inherited;
end;

{---------------------------------------}
destructor TNotifyController.Destroy;
begin
    inherited Destroy;
end;

{---------------------------------------}
procedure TNotifyController.SetSession(js: TObject);
begin
    // Store a reference to the session object
    _session := js;
    with TJabberSession(_session) do begin
        _presCallback := RegisterCallback(PresCallback);
    end;
end;

{---------------------------------------}
procedure TNotifyController.PresCallback(event: string; tag: TXMLTag; p: TJabberPres);
begin
    // getting a pres event
    Callback(event, tag);
end;

{---------------------------------------}
procedure TNotifyController.Callback(event: string; tag: TXMLTag);
var
    idx: integer;
    sess: TJabberSession;
    nick, j, from, notifyMessage: Widestring;
    //ritem: TJabberRosterItem;
    tmp_jid: TJabberID;
    f: TForm;
begin
    notifyMessage := '';
    // we are getting some event to do notification on

    // DebugMsg('Notify Callback: ' + BoolToStr(MainSession.IsPaused, true));
{** JJF msgqueue refactor
    if MainSession.IsPaused then begin
        MainSession.QueueEvent(event, tag, Self.Callback);
        exit;
    end;
**}
    sess := TJabberSession(_session);
    from := tag.GetAttribute('from');
    tmp_jid := TJabberID.Create(from);
//    f := nil;
    idx := -1;
    try
        j := tmp_jid.jid;
        if (sess.IsBlocked(j)) then exit;
        // don't display notifications for rooms, here.
        if (IsRoom(j)) then exit;
        // someone is coming online for the first time..
            { TODO : Roster refactor }
//       if (event = '/presence/online') then begin
//            ritem := MainSession.roster.Find(tmp_jid.getDisplayJID());
//           if (ritem <> nil) then begin
//                idx := ritem.getPresenceImage('available');
//                if ((ritem = MainSession.roster.ActiveItem) and
//                    (MainSession.Roster.ActiveItem.IsContact) and
//                    (MainSession.Roster.ActiveItem.IsNative) and
//                    (frmrosterWindow.treeRoster.SelectionCount < 2)) then begin
//                    frmExodus.btnSendFile.Enabled := true;
//                    frmExodus.mnuPeople_Contacts_SendFile.Enabled := true;
//                end;
//            end
//            else
//                idx := RosterTreeImages.Find('available');
            //Presence notifications should be routed to the parent form of the
            //roster. may be mainform or roster is embedded in a tab
            f := GetRosterWindow();
            if (f <> nil) then
                 f := TRosterForm(f).GetDockParent();
            if (f <> nil) and (not f.inheritsFrom(TfrmDockable)) then
                f := nil; //route to mainform
            notifyMessage := sNotifyOnline;
//        end

        // someone is going offline
//        else if (event = '/presence/offline') then begin
        if (event = '/presence/offline') then begin
 { TODO : Roster refactor }       
//            ritem := sess.roster.Find(j);
//            if (ritem <> nil) then begin
//                idx := ritem.getPresenceImage('offline');
//                if (ritem = MainSession.roster.ActiveItem) then begin
//                    frmExodus.btnSendFile.Enabled := false;
//                    frmExodus.mnuPeople_Contacts_SendFile.Enabled := false;
//                end;
//            end
//            else
//                idx := RosterTreeImages.Find('offline');

            f := GetRosterWindow();
            if (f <> nil) then
                f := TRosterForm(f).GetDockParent();
            if (f <> nil) and (not f.inheritsFrom(TfrmDockable)) then
                f := nil; //route to mainform
            notifyMessage := sNotifyOffline;
        end

        // don't display normal presence changes
        else if ((event = '/presence/available') or (event = '/presence/error')
            or (event = '/presence/unavailable') ) then
            // do nothing

        // unkown.
        else
            DebugMessage('Unknown notify event: ' + event);

        if (notifyMessage <> '') then begin
            nick := DisplayName.getDisplayNameCache().getDisplayName(tmp_jid);
            if (notifyMessage = sNotifyOnline) then
              DoNotify(f, 'notify_online', nick + _(notifyMessage), idx)
            else
              DoNotify(f, 'notify_offline', nick + _(notifyMessage), idx);            
        end;
    finally
        tmp_jid.Free();
    end;
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
procedure DoNotify(win: TForm; notify: integer; msg: Widestring; icon: integer;
    sound_name: string);
var
    tstr: string;
begin
    //bail if paused
{** JJF msgqueue refactor
    if (MainSession.IsPaused) then exit;
**}
    //If "bring to front" notification selected, skip the following section
    // and perform notification code following this section
    if ((notify and notify_front) = 0) then begin
        //check "notify if app active" and "notify if window active" prefs.
        if (Application.Active) then begin
            if (not MainSession.prefs.getBool('notify_active')) then begin
                // We Don't want to be notified when active (contact offline/online msgs)
                if (not MainSession.prefs.getBool('notify_active_win')) then begin
                    // We never want to get notified when app active
                    exit;
                end
                else begin
                    // We DO want to get notified when in active window  (chat activity, not contact offline/online)
                    // Make sure we have the active window
                    if (win = nil) then exit;
                    if (GetForegroundWindow() <> win.handle) then exit;
                    //if dock manager is active and win is top docked, it is active
                    if ((GetDockManager().GetTopDocked() = win) and GetDockManager().isActive) then exit;
                end;
            end
            else begin
                // We DO want to be notified when active (contact offline/online msgs)
                if (not MainSession.prefs.getBool('notify_active_win')) then begin
                    // We Don't want to be notified when in active window. (chat activity, not contact offline/online)
                    // Make sure we are in active window
                    if (win <> nil) then begin
                        if (GetForegroundWindow() = win.handle) then exit;
                        //if dock manager is active and win is top docked, it is active
                        if ((GetDockManager().GetTopDocked() = win) and GetDockManager().isActive) then exit;
                    end;
                end;
            end;
        end;
    end;

    if ((notify and notify_toast) > 0) then
        ShowRiserWindow(win, msg, icon); // Show toast

    if (win is TfrmState) then
        TfrmState(win).OnNotify(notify)
    else if (win <> nil) then begin  //handle flash and front ourselves
        if ((notify and notify_flash) > 0) then
            FlashWindow(win.Handle, true);
        if ((notify and notify_front) > 0) then begin
            if ((not win.Visible) or (win.WindowState = wsMinimized))then begin
            win.WindowState := wsNormal;
            win.Visible := true;
        end;
        ShowWindow(win.Handle, SW_SHOWNORMAL);
        ForceForegroundWindow(win.Handle);
        end;
    end;

    if ((sound_name <> 'notify_online') and
        (sound_name <> 'notify_offline')) then begin
        // We do NOT want the dock window to get notifications for online/offline
        // on the off chance that they were able to enable flash or bringtofront
        // via the branding or old prefs file.
        GetDockManager().OnNotify(win, notify);
    end;

    if (MainSession.prefs.getBool('notify_sounds')) then begin
        tstr := MainSession.Prefs.GetSoundFile(sound_name);
        if (tstr <> '') and ((notify and notify_sound) > 0) then
            PlaySound(pchar(tstr), 0,
                      SND_FILENAME or SND_ASYNC or SND_NOWAIT or SND_NODEFAULT);
    end;
end;


{---------------------------------------}
procedure DoNotify(win: TForm; pref_name: string; msg: Widestring; icon: integer);
begin
    DoNotify(win, MainSession.Prefs.getInt(pref_name), msg, icon, pref_name);
end;

end.