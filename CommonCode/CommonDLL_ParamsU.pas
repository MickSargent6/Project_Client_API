//
// Unit: CommonDLL_ParamsU
// Author: M.A.Sargent  Date: 21/10/2017  Version: V1.0
//
// Notes:
//
unit CommonDLL_ParamsU;

interface

Uses SysUtils, MASRecordStructuresU, Classes;

  Function fnDLL_List_AddParamsAsText  (Const aStrListAsText: String): Integer;
  Function fnDLL_List_AddParamString   (Const aName, aValue: String): Integer;
  Function fnDLL_List_AddParamInteger  (Const aName: String; Const aValue: Integer): Integer;
  Function fnDLL_List_AddParamBoolean  (Const aName: String; Const aValue: Boolean): Integer;

  Function fnDLL_List_ReadList         (var aList: tStrings): Boolean;
  Function fnDLL_List_ReadString       (Const aName, aDefault: String): String;
  Function fnDLL_List_ReadInteger      (Const aName: String; Const aDefault: Integer): Integer;
  Function fnDLL_List_ReadBoolean      (Const aName: String; Const aDefault: Boolean): Boolean;

implementation

Uses MASCommonU, DLL_HelpersU, CriticalSectionU;

var
  gblList: tMASThreadSafeStringList = Nil;

// Routine: fnDLL_List_AddParamsAsText, fnDLL_List_AddParamString, fnDLL_AddParamInteger & fnDLL_List_AddParamBoolean
// Author: M.A.Sargent  Date: 07/11/17  Version: V1.0
//
// Notes:
//
Function fnDLL_List_AddParamsAsText (Const aStrListAsText: String): Integer;
begin
  with gblList.Lock do
    Try
      Text := aStrListAsText;
      Result := Count;
    Finally
      gblList.UnLock;
    End;
end;
Function fnDLL_List_AddParamString (Const aName, aValue: String): Integer;
begin
  Result := gblList.fnAdd (fnAddValuePair (aName, aValue));
end;
Function fnDLL_List_AddParamInteger (Const aName: String; Const aValue: Integer): Integer;
begin
  Result := fnDLL_List_AddParamString (aName, IntToStr (aValue));
end;
Function fnDLL_List_AddParamBoolean (Const aName: String; Const aValue: Boolean): Integer;
begin
  Result := fnDLL_List_AddParamString (aName, BoolToStr (aValue));
end;

// Routine: fnDLL_List_ReadList
// Author: M.A.Sargent  Date: 05/04/18  Version: V1.0
//
// Notes:
//
Function fnDLL_List_ReadList (var aList: tStrings): Boolean;
var
  lvList: tStringList;
begin
  Result := Assigned (aList);
  if not Result then Exit;
  lvList := gblList.Lock;
  Try
    aList.Assign (lvList);
  Finally
    gblList.UnLock;
  End;
end;

// Routine: fnDLL_List_ReadString
// Author: M.A.Sargent  Date: 03/10/17  Version: V1.0
//
// Notes:
//
Function fnDLL_List_ReadString (Const aName, aDefault: String): String;
begin
  Result := gblList.GetValue2 (aName, aDefault);
end;

// Routine: fnDLL_List_ReadInteger
// Author: M.A.Sargent  Date: 03/10/17  Version: V1.0
//
// Notes:
//
Function fnDLL_List_ReadInteger (Const aName: String; Const aDefault: Integer): Integer;
var
  lvResult: String;
begin
  lvResult := gblList.GetValue2 (aName, IntToStr (aDefault));
  Result := StrToInt (lvResult);
end;

// Routine: fnDLL_List_ReadBoolean
// Author: M.A.Sargent  Date: 03/10/17  Version: V1.0
//
// Notes:
//
Function fnDLL_List_ReadBoolean (Const aName: String; Const aDefault: Boolean): Boolean;
var
  lvResult: String;
begin
  lvResult := gblList.GetValue2 (aName, BoolToStr (aDefault));
  Result := StrToBool (lvResult);
end;

Initialization
  gblList := tMASThreadSafeStringList.Create;
Finalization
  gblList.Free;
end.

