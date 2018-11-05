//
// Unit: MAS_FloatU
// Author: M.A.Sargent  Date: 19/09/13  Version: V1.0
//
// Notes:
//
unit MAS_FloatU;

interface

Uses MAS_LocalityU, SysUtils;

  Function fnTS_FloatToStr (Value: Extended): String;
  //
  Function fnTS_StrToFloat (Const S: string): Extended;
  Function fnTS_StrToFloatDef (Const S: string; const Default: Extended): Extended;
  //
  Function fnTS_FloatToStrF (Value: Extended; Format: TFloatFormat; Precision, Digits: Integer): String;

  //
  Function fnTS_CurrToStr    (Const aValue: Currency): String;
  Function fnTS_CurrToStrF   (Const aValue: Currency): String;
  //
  Function fnTS_StrToCurr    (Const aValue: String): Currency;
  Function fnTS_TryStrToCurr (Const aValue: String; out aCurrency: Currency): Boolean;

implementation

Function fnTS_FloatToStr (Value: Extended): String;
begin
  Result := FloatToStr (Value, fnTS_LocaleSettings);
end;

Function fnTS_StrToFloat (Const S: string): Extended;
begin
  Result := StrToFloat (S, fnTS_LocaleSettings);
end;
Function fnTS_StrToFloatDef (Const S: string; const Default: Extended): Extended;
begin
  Result := StrToFloatDef (S, Default, fnTS_LocaleSettings);
end;

Function fnTS_FloatToStrF (Value: Extended; Format: TFloatFormat; Precision, Digits: Integer): String;
begin
  Result := FloatToStrF (Value, Format, Precision, Digits, fnTS_LocaleSettings);
end;

// Routine: fnTS_CurrToStrF
// Author: M.A.Sargent  Date: 02/10/18  Version: V1.0
//
// Notes:
//
Function fnTS_CurrToStr (Const aValue: Currency): String;
begin
  Result := CurrToStr (aValue, fnTS_LocaleSettings);
end;
Function fnTS_CurrToStrF (Const aValue: Currency): String;
begin
  Result := CurrToStrF (aValue, ffCurrency, 2, fnTS_LocaleSettings);
end;

// Routine: fnTS_StrToCurr & fnTS_TryStrToCurr
// Author: M.A.Sargent  Date: 02/10/18  Version: V1.0
//
// Notes:
//
Function fnTS_StrToCurr (Const aValue: String): Currency;
begin
  Result := StrToCurr (aValue, fnTS_LocaleSettings);
end;
Function fnTS_TryStrToCurr (Const aValue: string; out aCurrency: Currency): Boolean;
begin
  Result := TryStrToCurr (aValue, aCurrency, fnTS_LocaleSettings);
end;

end.
