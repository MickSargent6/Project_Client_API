//
// Unit: MatchUtilsU
// Author: M.A.Sargent  Date:  05/12/2017 Version: V1.0
//         M.A.Sargent         13/03/2018          V2.0
//
// V2.0: Add Caridnal versions fnInc and fnInc2
//
unit MatchUtilsU;

interface

Uses MAS_ConstsU, MASRecordStructuresU;

  // String versions of can be found in StrUtils ie. MatchStr
  //

  // See if Integer exists in an array of Integer
  Function fnMatchInt (Const aInt: Integer; Const aValues: Array of Integer): Boolean;
  // Return the index of an Intreger in an Array of Integer (Zero Based)
  Function fnIndexInt (Const aInt: Integer; Const aValues: Array of Integer): Integer;
  // Check that the
  Function fnRangeInt (Const aInt, aMin, aMax: Integer): Boolean; overload;
  Function fnRangeInt (Const aInt, aMin, aMax, aDefault: Integer): Integer; overload;
  Function fnRangeInt2 (Const aInt, aMin, aMax, aDefault: Integer): tOKIntegerRec;

  Function fnInc  (var aValue: Integer; Const aMaxValue: Integer = MaxInt): Integer; overload;
  Function fnInc  (var aValue: Cardinal; Const aMaxValue: Cardinal = cMAX_CARDINAL): Cardinal; overload;

  Function fnInc2 (var aValue: Integer; Const aMaxValue: Integer; Const aFloor: Integer): Integer; overload;
  Function fnInc2 (var aValue: Cardinal; Const aMaxValue: Cardinal; Const aFloor: Integer): Cardinal; overload;

  Function fnMod     (Const aValue, aModValue, aRemainder: Integer): Boolean;
  Function fnModZero (Const aValue, aModValue: Integer): Boolean;


implementation

//
Function fnMatchInt (Const aInt: Integer; Const aValues: Array of Integer): Boolean;
begin
  Result := (fnIndexInt (aInt, aValues) <> cMC_NOT_FOUND);
end;

//
Function fnIndexInt (Const aInt: Integer; Const aValues: Array of Integer): Integer;
var
  x: Integer;
begin
  Result := -1;
  for x := Low (aValues) to High (aValues) do
    if (aInt = aValues [x]) then begin
      Result := x;
      Break;
    end;
end;

// Routine: fnRangeInt & fnRangeInt2
// Author: M.A.Sargent  Date: 05/12/17  Version: V1.0
//
// Notes:
//
Function fnRangeInt (Const aInt, aMin, aMax: Integer): Boolean;
begin
  Result := ((aInt >= aMin) and (aInt <= aMax));
end;
Function fnRangeInt (Const aInt, aMin, aMax, aDefault: Integer): Integer;
begin
  Result := fnRangeInt2 (aInt, aMin, aMax, aDefault).Int;
end;
Function fnRangeInt2 (Const aInt, aMin, aMax, aDefault: Integer): tOKIntegerRec;
begin
  Result.Int := aInt;
  Result.OK := fnRangeInt (aInt, aMin, aMax);
  if not Result.OK then Result.Int := aDefault;
end;

// Routine: fnInc
// Author: M.A.Sargent  Date: 14/12/17  Version: V1.0
//
// Notes:
//
Function fnInc (var aValue: Integer; Const aMaxValue: Integer): Integer;
begin
  Result := fnInc2 (aValue, aMaxValue, 1);
end;
Function fnInc (var aValue: Cardinal; Const aMaxValue: Cardinal): Cardinal;
begin
  Result := fnInc2 (aValue, aMaxValue, 1);
end;

Function fnInc2 (var aValue: Integer; Const aMaxValue: Integer; Const aFloor: Integer): Integer;
begin
  Case (aValue >= aMaxValue) of
    True: aValue := aFloor;
    else Inc (aValue);
  End;
  Result := aValue;
end;
Function fnInc2 (var aValue: Cardinal; Const aMaxValue: Cardinal; Const aFloor: Integer): Cardinal;
begin
  Case (aValue >= aMaxValue) of
    True: aValue := aFloor;
    else Inc (aValue);
  End;
  Result := aValue;
end;

// Routine: fnMod
// Author: M.A.Sargent  Date: 14/12/17  Version: V1.0
//
// Notes:
//
Function fnMod (Const aValue, aModValue, aRemainder: Integer): Boolean;
begin
  Result := ((aValue mod aModValue) = aRemainder);
end;
Function fnModZero (Const aValue, aModValue: Integer): Boolean;
begin
  Result := ((aValue mod aModValue) = 0);
end;

end.
