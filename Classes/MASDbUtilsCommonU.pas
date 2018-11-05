//
// Unit: MASDBUtilsCommonU
// Author: M.A.Sargent  Date: 10/03/13  Version: V1.0
//         M.A.Sargent        05/05/15           V2.0
//         M.A.Sargent        24/04/18           V3.0
//         M.A.Sargent        30/04/18           V4.0
//
// Notes:
//  V2.0: fnAssignDataValue
//  V3.0: add a read method GetData to property Data
//  V4.0: Updated fnResultInArray_AsInteger & fnResultInArray_AsString
//
unit MASDBUtilsCommonU;

interface

Uses Db, Variants, SysUtils, MASDatesU, MAS_FloatU, MASRecordStructuresU, MASmySQLStoredProc;

  Function fnAssignDataValue (Const aDataType: tFieldType; Const aValue: String): Variant; overload;
  //
  // Used to Get my coding Standard of output param RESULT or O_RESULT
  Function fnResultAsInt     (Const aProc: tMASmySQLStoredProc): tOKIntegerRec;
  Function fnResultAsVariant (Const aProc: tMASmySQLStoredProc): tOKVariant;
  //
  Function fnResultInArray_AsInteger (Const aProc: tMASmySQLStoredProc; Const aArray: Array of Variant): tOKVariant; overload;
  Function fnResultInArray_AsString  (Const aProc: tMASmySQLStoredProc; Const aArray: Array of Variant): tOKVariant; overload;

  //
  //
  //
  Function fnDBLogicalToBoolean (Const aValue: String):  Boolean;
  Function fnBooleanToDBLogical (Const aValue: Boolean): String;
  //
  Function fnDBLogicalToIniFileValue (Const aValue: String): String;
  Function fnIniFileValueToDBLogical (Const aValue: Boolean): String; overload;
  Function fnIniFileValueToDBLogical (Const aValue: String): String; overload;

implementation

Uses MASCommonU, FormatResultU, TypInfo, MAS_ConstsU;

Const
  cRESULT_PARAM_NOTFOUND = -1;
  //
  cDBU_IDENTIFIER        = 'Identifier';
  cDBU_ACTION            = 'Action';
  cDBU_SPNAME            = 'SPName';
  cDBU_PARAMSARRAY       = 'ParamsArray';
  cDBU_NAME              = 'Name';
  cDBU_VALUE             = 'Value';
  cDBU_DATATYPE          = 'DataType';
  cDBU_NULL              = 'Null';

// Routine: fnGetExeName
// Author: M.A.Sargent  Date: 04/09/13  Version: V1.0
//         M.A.Sargent        20/05/15           V2.0
//
// Notes:
//  V2.0: Added ftFixedChar
//  V3.0: Added ftBoolean   (Absolute Database TSUK Ltd)
//
Function fnAssignDataValue (Const aDataType: tFieldType; Const aValue: String): Variant;
begin
  Result := Null;
  Case aDataType of
    ftWideString,
     ftString,
      ftFixedChar: Result := aValue;
    ftSmallint,
     ftInteger,
      ftWord,
       ftLargeInt: if (aValue<>'') then Result := StrToInt (aValue);
    ftFloat:       if (aValue<>'') then Result := fnTS_StrToFloat (aValue);
    ftDate,
     ftDateTime:    {if (GetTreeViewDates <> sdNone) then
                              lvParams[i].AsDateTime := fnStrToDate (lvValue, GetTreeViewDates)}
                   Result := fnTS_StrToDateTime (aValue);
    ftTime:        Result := fnTS_StrToTime (aValue);
    ftBoolean:     Result := StrToBool (aValue);
    //
    //ftFMTBCD,
    // FTbcd:        Result := StrToInt (aValue);
    else Raise Exception.CreateFmt ('fnAssignDataValue: Wrong Datatype.1 %d', [Ord (aDataType)]);
  end;
end;

// Routine: fnResultAsInt & fnResultAsVariant
// Author: M.A.Sargent  Date: 30/11/17  Version: V1.0
//
// Notes:
//
Function fnResultAsInt (Const aProc: tMASmySQLStoredProc): tOKIntegerRec;
var
  lvRes: tOKVariant;
begin
  lvRes := fnResultAsVariant (aProc);
  Result.OK := lvRes.OK;
  if Result.OK then
       Result.Int := Integer (lvRes.Msg)
  else Result.Int := cRESULT_PARAM_NOTFOUND;
end;

Function fnResultAsVariant (Const aProc: tMASmySQLStoredProc): tOKVariant;
var
  lvParam: tParam;
begin
  Result := fnClear_OKVariant;

  if not Assigned (aProc) then Raise Exception.Create ('Error: fnResultAsVariant. aProc must be Assigned');
  // see if a parameter called RESULT or O_RESULT exists
  if Assigned (aProc.Params) then begin
    lvParam := aProc.Params.FindParam ('RESULT');
    if not Assigned (lvParam) then lvParam := aProc.Params.FindParam ('O_RESULT');
    //
    Result.OK := Assigned (lvParam);
    if Result.OK then Result.Msg := lvParam.Value;
  end;
end;

// Routine: fnResultInArray_AsInteger & fnResultInArray_AsString
// Author: M.A.Sargent  Date: 30/11/17  Version: V1.0
//         M.A.Sargent        30/04/18           V2.0
//
// Notes:
//  V2.0: Updated to only set the Result.Msg once and then True or False based on the aArray
//
Function fnResultInArray_AsInteger (Const aProc: tMASmySQLStoredProc; Const aArray: Array of Variant): tOKVariant; overload;
var
  x: Integer;
  lvRes: tOKIntegerRec;
begin
  Result := fnClear_OKVariant;
  Try
    lvRes := fnResultAsInt (aProc);
    fnRaiseOnFalse (lvRes.OK, 'Return Param RESULT or O_RESULT not found');
    // Set the Msg value and Loop and Set True/False if the value is in the valid results aArray
    Result.Msg := lvRes.Int;
    for x := 0 to High (aArray) do begin
      //
      Case VarType (aArray[x]) of
        varSmallInt, varShortInt, varInteger, varByte, varWord, varLongWord{, varInt64, varUInt64}:;
        else Raise Exception.CreateFmt ('Unknown Var Type: %d', [Ord (VarType (aArray[x]))]);
      End;
      //
      Result.OK := (lvRes.Int = aArray[x]);
      if Result.OK then Break;
    end;
  Except
    on e:Exception do
      Raise Exception.CreateFmt ('Error: fnResultInArray_AsInteger. %s', [e.Message]);
  End;
end;

Function fnResultInArray_AsString (Const aProc: tMASmySQLStoredProc; Const aArray: Array of Variant): tOKVariant; overload;
var
  x: Integer;
  lvRes: tOKVariant;
begin
  Result := fnClear_OKVariant;
  Try
    lvRes := fnResultAsVariant (aProc);
    fnRaiseOnFalse (lvRes.OK, 'Return Param RESULT or O_RESULT not found');
    //
    // Set the Msg value and Loop and Set True/False if the value is in the valid results aArray
    Result.Msg := lvRes.Msg;
    for x := 0 to High (aArray) do begin
      //
      Case VarType (aArray[x]) of
        varString:;
        else Raise Exception.CreateFmt ('Unknown Var Type: %d', [Ord (VarType (aArray[x]))]);
      End;
      //
      Result.OK := IsEqual (lvRes.Msg, aArray [x]);
      if Result.OK then Break;
    end;
  Except
    on e:Exception do
      Raise Exception.CreateFmt ('Error: fnResultInArray_AsString. %s', [e.Message]);
  End;
end;

// Routine: fnDBLogicalToBoolean & fnBooleanToDBLogical
// Author: M.A.Sargent  Date: 18/05/18  Version: V1.0
//
// Notes:
//
Function fnDBLogicalToBoolean (Const aValue: String): Boolean;
begin
  Result := IsEqual (cMC_Y, aValue);
end;
Function fnBooleanToDBLogical (Const aValue: Boolean): String;
begin
  Result := IfTrue (aValue, cMC_Y, cMC_N);
end;

// Routine: fnDBLogicalToIniFileValue & fnIniFileValueToDBLogical
// Author: M.A.Sargent  Date: 28/05/18  Version: V1.0
//
// Notes:
//
Function fnDBLogicalToIniFileValue (Const aValue: String): String;
begin
  Result := IfTrue (IsEqual (aValue, cMC_Y), '1', '0');
end;
Function fnIniFileValueToDBLogical (Const aValue: Boolean): String;
begin
  Result := IfTrue (aValue, 'Y', 'N');
end;
Function fnIniFileValueToDBLogical (Const aValue: String): String;
begin
  Result := IfTrue (IsEqual (aValue, '1'), 'Y', 'N');
end;

end.
