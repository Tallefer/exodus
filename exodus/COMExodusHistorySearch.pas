unit COMExodusHistorySearch;

{$WARN SYMBOL_PLATFORM OFF}
{
    Copyright 2008, Estate of Peter Millard

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
    ComObj, ActiveX, Exodus_TLB,
    StdVcl, Unicode;

type
  TExodusHistorySearch = class(TAutoObject, IExodusHistorySearch)
  private
    // Variables
    _AllowedSearchType: TWidestringList;
    _JIDList: TWidestringList;
    _KeywordList: TWidestringList;
    _minDate: TDateTime;
    _maxDate: TDateTime;
    _SearchID: Widestring;
    _ExactMatch: boolean;

    // Methods

  protected
    // Variables

    // Methods

    // IExodusHistorySearch Interface
    function Get_AllowedSearchTypeCount: Integer; safecall;
    function Get_ExactKeywordMatch: WordBool; safecall;
    function Get_JIDCount: Integer; safecall;
    function Get_KeywordCount: Integer; safecall;
    function Get_maxDate: TDateTime; safecall;
    function Get_minDate: TDateTime; safecall;
    function Get_SearchID: WideString; safecall;
    function GetAllowedSearchType(index: Integer): WideString; safecall;
    function GetJID(index: Integer): WideString; safecall;
    function GetKeyword(index: Integer): WideString; safecall;
    procedure AddAllowedSearchType(const ID: WideString); safecall;
    procedure AddJid(const JID: WideString); safecall;
    procedure AddKeyword(const Keyword: WideString); safecall;
    procedure Set_ExactKeywordMatch(value: WordBool); safecall;
    procedure Set_maxDate(value: TDateTime); safecall;
    procedure Set_minDate(value: TDateTime); safecall;
  public
    // Variables

    // Methods
    procedure Initialize(); override;
    destructor Destroy(); override;

    // Properties
  end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

uses
    ComServ,
    sysUtils,
    DateUtils;


{---------------------------------------}
procedure TExodusHistorySearch.Initialize();
begin
    inherited;

    _AllowedSearchType := TWidestringList.Create();
    _JIDList := TWidestringList.Create();
    _KeywordList := TWidestringList.Create();

    _minDate := StrToDateTime('01/01/1970 00:00:00'); 
    _maxDate := Tomorrow(); // Makes sure we capture all of today by default
    _SearchID := Format('%8.6f', [Now()]);
    _ExactMatch := false;
end;

{---------------------------------------}
destructor TExodusHistorySearch.Destroy();
begin
    _AllowedSearchType.Clear();
    _JIDList.Clear();
    _KeywordList.Clear();

    _AllowedSearchType.Free();
    _JIDList.Free();
    _KeywordList.Free();
 
    inherited;
end;

{---------------------------------------}
function TExodusHistorySearch.Get_AllowedSearchTypeCount: Integer;
begin
    Result := _AllowedSearchType.Count;
end;

{---------------------------------------}
function TExodusHistorySearch.Get_ExactKeywordMatch: WordBool;
begin
    Result := _ExactMatch;
end;

{---------------------------------------}
function TExodusHistorySearch.Get_JIDCount: Integer;
begin
    Result := _JIDList.Count;
end;

{---------------------------------------}
function TExodusHistorySearch.Get_KeywordCount: Integer;
begin
    Result := _KeywordList.Count;
end;

{---------------------------------------}
function TExodusHistorySearch.Get_maxDate: TDateTime;
begin
    Result := _maxDate;
end;

{---------------------------------------}
function TExodusHistorySearch.Get_minDate: TDateTime;
begin
    Result := _minDate;
end;

{---------------------------------------}
function TExodusHistorySearch.Get_SearchID: WideString;
begin
    Result := _SearchID;
end;

{---------------------------------------}
function TExodusHistorySearch.GetAllowedSearchType(index: Integer): WideString;
begin
    Result := '';
    if (index < 0) then exit;
    if (index >= _AllowedSearchType.Count) then exit;

    Result := _AllowedSearchType[index];    
end;

{---------------------------------------}
function TExodusHistorySearch.GetJID(index: Integer): WideString;
begin
    Result := '';
    if (index < 0) then exit;
    if (index >= _JIDList.Count) then exit;

    Result := _JIDList[index];
end;

{---------------------------------------}
function TExodusHistorySearch.GetKeyword(index: Integer): WideString;
begin
    Result := '';
    if (index < 0) then exit;
    if (index >= _KeywordList.Count) then exit;

    Result := _KeywordList[index];
end;

{---------------------------------------}
procedure TExodusHistorySearch.AddAllowedSearchType(const ID: WideString);
var
    index: integer;
    tmp: Widestring;
begin
    if (ID = '') then exit;

    tmp := LowerCase(ID);
    index := -1;

    if (not _AllowedSearchType.Find(tmp, index)) then begin
        _AllowedSearchType.Add(tmp);
    end;
end;

{---------------------------------------}
procedure TExodusHistorySearch.AddJid(const JID: WideString);
var
    index: integer;
    tmp: Widestring;
begin
    if (JID = '') then exit;

    tmp := LowerCase(JID);
    index := -1;

    if (not _JIDList.Find(tmp, index)) then begin
        _JIDList.Add(tmp);
    end;
end;

{---------------------------------------}
procedure TExodusHistorySearch.AddKeyword(const Keyword: WideString);
var
    index: integer;
    tmp: Widestring;
begin
    if (Keyword = '') then exit;

    tmp := LowerCase(Keyword);
    index := -1;

    if (not _KeywordList.Find(tmp, index)) then begin
        _KeywordList.Add(tmp);
    end;
end;

{---------------------------------------}
procedure TExodusHistorySearch.Set_ExactKeywordMatch(value: WordBool);
begin
    _ExactMatch := value;
end;

{---------------------------------------}
procedure TExodusHistorySearch.Set_maxDate(value: TDateTime);
begin
    _maxDate := value;
end;

{---------------------------------------}
procedure TExodusHistorySearch.Set_minDate(value: TDateTime);
begin
    _minDate := value;
end;




initialization
  TAutoObjectFactory.Create(ComServer, TExodusHistorySearch, Class_ExodusHistorySearch,
    ciMultiInstance, tmApartment);

end.
