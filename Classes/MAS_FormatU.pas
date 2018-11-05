//
// Unit: MAS_FormatU
// Author: M.A.Sargent  Date: 04/01/13  Version: V1.0
//
// Notes:
//
unit MAS_FormatU;

interface

Uses MAS_LocalityU, SysUtils;

  Function fnTS_Format (Const aFormat: String; Const Args: Array of Const): String;

implementation

Function fnTS_Format (Const aFormat: String; Const Args: Array of Const): String;
begin
  Result := Format (aFormat, Args, fnTS_LocaleSettings);
end;

end.
