//
// Unit: TSUK_UtilsU
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//         M.A.Sargent        15/05/18           V2.0
//         M.A.Sargent        16/08/18           V3.0
//
// Notes:
//  V2.0: Added Functions fnRandomKey & fnComputerNameKey
//  V3.0: Upodate the Constrcutor in tIdThreadSafeVerboseLevel, ensure deails to tsvlNOrmal;
//
unit TSUK_UtilsU;

interface

Uses IdThreadSafe, Forms, MASWindowsSystemInfoU, SysUtils, MAS_ConstsU, VerboseLevelTypeU,
     {$IFDEF VER150}
     TSUK_D7_ConstsU,
     Controls,
     Math;
     {$ELSE}
     TSUK_ConstsU,
     UITypes,
     System.Math,
     {$ENDIF}

Type
  tIdThreadSafeVerboseLevel = class(TIdThreadSafe)
  Protected
    fValue: tTSVerboseLevel;
    //
    Function GetValue: tTSVerboseLevel;
    Procedure SetValue (Const aValue: tTSVerboseLevel);
  Public
    //
    Constructor Create; override;
    Property Value: tTSVerboseLevel read GetValue write SetValue;
  end;

  //
  //
  //
  Function  fnCursorWait: tCursor;
  Procedure CursorRestore; overload;
  Procedure CursorRestore (Const aCursor: tCursor); overload;
  //
  Function fnRandomKey       (aLength: Integer = 16): String;
  Function fnComputerNameKey: String;
  //
  Function fnRemoveLFCR (Const aStr: String): String;
  // Use to create a Hash for the unique identifiers
  Function fnLicenseToMD5 (Const aSageAccountCode, aFingerPrint, aSalesNumber, aProduct, aVersion: String): String;
  Function fnProductToMD5 (Const aProduct, aVersion: String): String;

implementation

Uses MASCommonU, MAS_HashsU;

{ tIdThreadSafeVerboseLevel }

Constructor tIdThreadSafeVerboseLevel.Create;
begin
  inherited;
  fValue := tsvlNormal;
end;

Function tIdThreadSafeVerboseLevel.GetValue: tTSVerboseLevel;
begin
  Lock;
  try
    Result := fValue;
  finally
    Unlock;
  end;
end;

Procedure tIdThreadSafeVerboseLevel.SetValue (Const aValue: tTSVerboseLevel);
begin
  Lock;
  try
    fValue := aValue;
  finally
    Unlock;
  end;
end;

// Routine: fnCursorWait & CursorRestore
// Author: M.A.Sargent  Date: 19/04/18  Version: V1.0
//         M.A.Sargent        03/08/18           V2.0
//
// Notes:
//  V2.0: Add Application.ProcessMessages
//
Function fnCursorWait: tCursor;
begin
  Result := crDefault;
  if not Assigned (Screen) then Exit;
  Result := Screen.Cursor;
  Screen.Cursor := crSQLWait;
  Application.ProcessMessages;
end;
Procedure CursorRestore;
begin
  CursorRestore (crDefault);
end;
Procedure CursorRestore (Const aCursor: tCursor);
begin
  if not Assigned (Screen) then Exit;
  Case (aCursor = crDefault) of
    True: Screen.Cursor := crDefault;
    else  Screen.Cursor := aCursor;
  end;
  //Application.ProcessMessages;
end;

// Routine: fnRandomKey
// Author: M.A.Sargent  Date: 15/05/18  Version: V1.0
//
// Notes:
//
Function fnRandomKey (aLength: Integer = 16): String;
begin
  Result := '';
  if (aLength <= 4) then aLength := 4;
  //
  repeat
    Result := Result + Chr(RandomRange (32, 127));
  until (Length(Result) = aLength)
end;

// Routine: fnRandomKey
// Author: M.A.Sargent  Date: 15/05/18  Version: V1.0
//
// Notes: Used to create a password key based on the Computer name
//
Function fnComputerNameKey: String;
var
  lvComputerName: String;
begin
  Result := '';
  lvComputerName := Trim (fnComputerName);
  // ComputerName should not be empty
  if IsEmpty (lvComputerName) then lvComputerName := 'SungGafg12';
  //
  Result := Copy (lvComputerName, 1, 3);
  Result := (Result + '_1@&~Joy' + Copy (lvComputerName, 3, MaxInt));
end;

// Routine: fnRemoveLFCR
// Author: M.A.Sargent  Date: 15/05/18  Version: V1.0
//
// Notes:
//
Function fnRemoveLFCR (Const aStr: String): String;
begin
  Result := StringReplace (aStr,   cMC_CR, '', [rfReplaceAll]);
  Result := StringReplace (Result, cMC_LF, '', [rfReplaceAll]);
end;

// Routine: fnLicenseToMD5
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//
// Notes:
//
Function fnLicenseToMD5 (Const aSageAccountCode, aFingerPrint, aSalesNumber, aProduct, aVersion: String): String;
var
  lvStr: String;
begin
  lvStr  := (Trim (aSageAccountCode) + ':' + Trim (aFingerPrint) + ':' + Trim (aSalesNumber) + ':' + Trim (aProduct) + ':' + Trim (aVersion));
  Result := MD5_AsStr (lvStr);
end;

// Routine: fnProductToMD5
// Author: M.A.Sargent  Date: 01/05/18  Version: V1.0
//
// Notes:
//
Function fnProductToMD5 (Const aProduct, aVersion: String): String;
var
  lvStr: String;
begin
  lvStr  := (Trim (aProduct) + ':' + Trim (aVersion));
  Result := MD5_AsStr (lvStr);
end;

Initialization
  Randomize;

end.
