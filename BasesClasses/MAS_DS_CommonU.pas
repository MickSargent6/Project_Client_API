//
// Unit: MAS_DS_CommonU
// Author: M.A.Sargent  Date: 07/11/2017  Version: V1.0
//
//
// Notes:
//
unit MAS_DS_CommonU;

interface

Uses MAS_DS_TypesU, SysUtils;

  Function fnStringToLogonType (Const aValue: String): tLogonType;
  Function fnIntegerToLogonType (Const aValue: Integer): tLogonType;
  //
  Function fnLogonTypeToInteger (Const aValue: tLogonType): Integer;
  Function fnLogonTypeToString (Const aValue: tLogonType): String;

implementation

Function fnStringToLogonType (Const aValue: String): tLogonType;
begin
  Result := fnIntegerToLogonType (StrToInt (aValue));
end;
Function fnIntegerToLogonType (Const aValue: Integer): tLogonType;
begin
  Result := tLogonType (aValue);
end;
//
Function fnLogonTypeToInteger (Const aValue: tLogonType): Integer;
begin
  Result := Ord (aValue);
end;
Function fnLogonTypeToString (Const aValue: tLogonType): String;
begin
  Result := IntToStr (fnLogonTypeToInteger (aValue));
end;


end.
