//
// Unit: CommonDLL_IniU
// Author: M.A.Sargent  Date: 21/10/2017  Version: V1.0
//
// Notes:
//
unit CommonDLL_IniU;

interface

Uses SysUtils, MASRecordStructuresU;

  Function fnDLL_Common_ReadString  (Const aSection, aName, aDefault: String): String;
  Function fnDLL_Common_ReadInteger (Const aSection, aName: String; Const aDefault: Integer): Integer;
  Function fnDLL_Common_ReadBoolean (Const aSection, aName: String; Const aDefault: Boolean): Boolean;

implementation

Uses MASCommonU, DLL_HelpersU, CriticalSectionU;

var
  gblIni: tMASThreadSafeMemIni = Nil;

Procedure CheckSetup;
begin
  if Assigned (gblIni) then Exit;
  gblIni := tMASThreadSafeMemIni.Create (fnGetDLLIniFile);
end;

// Routine: fnDLL_Common_ReadString
// Author: M.A.Sargent  Date: 03/10/17  Version: V1.0
//
// Notes:
//
Function fnDLL_Common_ReadString (Const aSection, aName, aDefault: String): String;
begin
  CheckSetup;
  Result := gblIni.ReadString (aSection, aName, aDefault);
end;

// Routine: fnDLL_Common_ReadInteger
// Author: M.A.Sargent  Date: 03/10/17  Version: V1.0
//
// Notes:
//
Function fnDLL_Common_ReadInteger (Const aSection, aName: String; Const aDefault: Integer): Integer;
begin
  CheckSetup;
  Result := gblIni.ReadInteger (aSection, aName, aDefault);
end;

// Routine: fnDLL_Common_ReadBoolean
// Author: M.A.Sargent  Date: 03/10/17  Version: V1.0
//
// Notes:
//
Function fnDLL_Common_ReadBoolean (Const aSection, aName: String; Const aDefault: Boolean): Boolean;
begin
  CheckSetup;
  Result := gblIni.ReadBoolean (aSection, aName, aDefault);
end;

Initialization
Finalization
  if Assigned (gblIni) then gblIni.Free;
end.

