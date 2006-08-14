unit LocalUtils;
{
    Copyright 2003, Peter Millard

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
    XMLTag, XMLParser, Unicode,
    Classes, SysUtils;

function getLocaleName(locale: string): string;

var
    langs: TXMLTag;
    codes: TXMLTag;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

var
    tmps: TWidestringlist;
    res: TResourceStream;
    p: TXMLTagParser;


{---------------------------------------}
function getLocaleName(locale: string): string;
var
    lcode, ccode: string;
    upos: integer;
    ltag: TXMLTag;
    ctag: TXMLTag;
begin
    // This needs to convert lang[_COUNTRY] to "language"
    Result := '';
    upos := Pos('_', locale);
    if (upos = 0) then begin
        ltag := langs.GetFirstTag(locale);
        if (ltag <> nil) then
            Result := ltag.Data;
    end
    else begin
        lcode := Copy(locale, 1, upos - 1);
        ccode := Copy(locale, upos + 1, length(locale) - upos);
        ltag := langs.GetFirstTag(lcode);
        if (ltag <> nil) then
            Result := ltag.Data;
        ctag := codes.GetFirstTag(ccode);
        if (ctag <> nil) then
            Result := Result + ' (' + ctag.Data + ')';
    end;
end;


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
initialization
    res := TResourceStream.Create(HInstance, 'langs', 'XML');
    tmps := TWidestringList.Create();
    tmps.LoadFromStream(res);
    res.Free();

    p := TXMLTagParser.Create();
    p.parseString(tmps.Text, '');
    if (p.Count > 0) then
        langs := p.popTag();

    res := TResourceStream.Create(HInstance, 'countries', 'XML');
    tmps.Clear();
    tmps.LoadFromStream(res);
    res.Free();

    p.parseString(tmps.Text, '');
    if (p.Count > 0) then
        codes := p.popTag();

    p.Free();

finalization
    langs.Free();
    codes.Free();

end.