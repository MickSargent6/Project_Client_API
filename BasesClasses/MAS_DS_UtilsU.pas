//
// Unit: MAS_DS_UtilsU
// Author: M.A.Sargent  Date: 24/11/2017  Version: V1.0
//
//
// Notes:
//
unit MAS_DS_UtilsU;

interface

Uses SysUtils, MASRecordStructuresU, MASCommonU;

  Function fnXXX (Const aHash, aHash2, aPassword, aMachineID: String): String;
  //
  Function fnMachineID (Const aCode, aHash: String; Const aFreeAfterUse: Boolean): String;
  Function fnPassword (Const aCode, aHash: String; Const aFreeAfterUse: Boolean): String;

implementation

Uses MAS_Encrypt3U;

// Routine: fnXXX
// Author: M.A.Sargent  Date: 24/11/17  Version: V1.0
//
// Notes: Create a string of the Password and Machine ID using 2 different Hashs
//        Format nn:sssssssssssssssssssssssssssssssssssssssssss
//
Function fnXXX (Const aHash, aHash2, aPassword, aMachineID: String): String;
var
  lvStr: String;
  lvLen: Integer;
begin
  //
  Result := fnEncryptString (aPassword, aHash, False);
  lvStr  := fnEncryptString (aMachineID, aHash2, True);
  lvLen := Length (Result);
  if (lvLen > 90) then Raise Exception.Create ('Error: Password Length Error');
  Result := (IntToStr (lvLen) + ':' + Result + lvStr);
end;

// Routine: fnMachineID
// Author: M.A.Sargent  Date: 24/11/17  Version: V1.0
//
// Notes: Decode the Machine Id form the encoded string
//
Function fnMachineID (Const aCode, aHash: String; Const aFreeAfterUse: Boolean): String;
var
  lvStr: String;
  lvLen: Integer;
  lvPos: Integer;
begin
  lvPos := Pos (':', aCode);
  lvLen := StrToInt (Copy (aCode, 1, (lvPos-1)));
  lvStr := (Copy (aCode, (lvPos+1), MaxInt));
  //
  Result := fnDecryptString (Copy (lvStr, (lvLen+1), MaxInt), aHash, aFreeAfterUse);
end;

// Routine: fnPassword
// Author: M.A.Sargent  Date: 24/11/17  Version: V1.0
//
// Notes: Decode the Password form the encoded string
//
Function fnPassword (Const aCode, aHash: String; Const aFreeAfterUse: Boolean): String;
var
  lvStr: String;
  lvLen: Integer;
  lvPos: Integer;
begin
  lvPos := Pos (':', aCode);
  lvLen := StrToInt (Copy (aCode, 1, (lvPos-1)));
  lvStr := (Copy (aCode, (lvPos+1), MaxInt));
  //
  Result := fnDecryptString (Copy (lvStr, 1, lvLen), aHash, aFreeAfterUse);
end;

end.
