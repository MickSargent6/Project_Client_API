//
// Unit: RegHelperU
// Author: M.A.Sargent  Date: 19/12/13  Version: V1.0
//         M.A.Sargent        20/12/13           V2.0
//         M.A.Sargent        08/10/14           V3.0
//         M.A.Sargent        18/03/18           V4.0
//
// Notes:
//
unit RegHelperU;

interface

Uses MASRegistry;

  Function fnGetRegInteger (Const aKey, aIdent, aName: String; Const aValue: Integer; Const aCreate: Boolean = True): Integer;
  Procedure SetRegInteger (Const aKey, aIdent, aName: String; Const aValue: Integer);

  Function fn_h_GetRegString (Const aKey, aIdent, aName: String; Const aValue: String; Const aCreate: Boolean = True): String;
  Procedure h_SetRegString (Const aKey, aIdent, aName: String; Const aValue: String);

  Function fnGetRegBoolean (Const aKey, aIdent, aName: String; Const aValue: Boolean; Const aCreate: Boolean = True): Boolean;
  Procedure h_SetRegBoolean (Const aKey, aIdent, aName: String; Const aValue: Boolean);

implementation

Uses MASCommonU;

// Routine: fnGetRegInteger
// Author: M.A.Sargent  Date: 15/12/13  Version: V1.0
//
// Notes:
//
Function fnGetRegInteger (Const aKey, aIdent, aName: String; Const aValue: Integer; Const aCreate: Boolean = True): Integer;
var
  lvReg: tMASRegistry;
begin
  lvReg := tMASRegistry.Create (aKey);
  Try
    Result := lvReg.RegGetInteger (aIdent, aName, aValue, aCreate);
  Finally
    lvReg.Free;
  End;
end;

// Routine: fnGetRegInteger
// Author: M.A.Sargent  Date: 15/12/13  Version: V1.0
//
// Notes:
//
Procedure SetRegInteger (Const aKey, aIdent, aName: String; Const aValue: Integer);
var
  lvReg: tMASRegistry;
begin
  lvReg := tMASRegistry.Create (aKey);
  Try
    lvReg.RegSetInteger (aIdent, aName, aValue);
  Finally
    lvReg.Free;
  End;
end;

// Routine: fn_h_GetRegString
// Author: M.A.Sargent  Date: 12/03/14  Version: V1.0
//
// Notes:
//
Function fn_h_GetRegString (Const aKey, aIdent, aName: String; Const aValue: String; Const aCreate: Boolean = True): String;
var
  lvReg: tMASRegistry;
begin
  lvReg := tMASRegistry.Create (aKey);
  Try
    Result := lvReg.RegGetString (aIdent, aName, aValue, aCreate);
  Finally
    lvReg.Free;
  End;
end;

// Routine: h_SetRegString
// Author: M.A.Sargent  Date: 12/03/14  Version: V1.0
//
// Notes:
//
Procedure h_SetRegString (Const aKey, aIdent, aName: String; Const aValue: String);
var
  lvReg: tMASRegistry;
begin
  lvReg := tMASRegistry.Create (aKey);
  Try
    lvReg.RegSetString (aIdent, aName, aValue);
  Finally
    lvReg.Free;
  End;
end;

// Routine: fnGetRegInteger
// Author: M.A.Sargent  Date: 20/12/13  Version: V1.0
//
// Notes:
//
Function fnGetRegBoolean (Const aKey, aIdent, aName: String; Const aValue: Boolean; Const aCreate: Boolean = True): Boolean;
var
  lvReg: tMASRegistry;
begin
  lvReg := tMASRegistry.Create (aKey);
  Try
    Result := lvReg.RegGetBoolean (aIdent, aName, aValue, aCreate);
  Finally
    lvReg.Free;
  End;
end;

// Routine: h_SetRegBoolean
// Author: M.A.Sargent  Date: 18/03/18  Version: V1.0
//
// Notes:
//
Procedure h_SetRegBoolean (Const aKey, aIdent, aName: String; Const aValue: Boolean);
var
  lvReg: tMASRegistry;
begin
  lvReg := tMASRegistry.Create (aKey);
  Try
    lvReg.RegSetBoolean (aIdent, aName, aValue);
  Finally
    lvReg.Free;
  End;
end;

end.
