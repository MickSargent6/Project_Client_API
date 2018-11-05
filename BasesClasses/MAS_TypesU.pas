//
// Unit: MAS_TypesU
// Author: M.A.Sargent  Date: 06/01/16  Version: V1.0
//         M.A.Sargent        13/06/18           V2.0
//
// Notes:
//  V2.0: Add Type rrShutDown
//
unit MAS_TypesU;

interface

Uses SysUtils, Classes;

Type
  tVerboseLevel = (vlNone, vlInfo, vlFull, vlDump, vlWarning, vlError);
  //
  tMASBoolean = (mbUnknown, mbTrue, mbFalse);
  tTimeEvent  = (teMinute, teHour, teDay);

  tJSONString2  = String;
  //
  tRecordResult = (rrUnAssigned, rrOK, rrNotOK, rrCancel, rrError, rrException, rrOption1, rrOption2, rrShutDown);

  //Events
  tOnTimeEvent = Procedure (Sender: tObject; Const aTimeEvent: tTimeEvent) of object;

  tVariableClass = Class (tObject)
  public
    Constructor Create; virtual;
  end;
  tVariableClass_String = Class (tVariableClass)
  Private
    fValue: String;
  Public
    Constructor Create (Const aValue: String); reintroduce; virtual;
    Property Value: String read fValue write fValue;
  end;

  //
  Function fnVerboseAsText (Const aLevel: tVerboseLevel): String;
  Function fnVerboseToInt (Const aLevel: tVerboseLevel): Integer;
  //
  Function fnIntToVerbose (Const aValue: String): tVerboseLevel; overload;
  Function fnIntToVerbose (Const aValue: Integer): tVerboseLevel; overload;
  //
  Function fnIntToDbAlignment (Const aValue: Integer): tAlignment;
  //
  Function fnBoolean (Const aValue: tMASBoolean; Const aDefault: Boolean): Boolean;

  Function fnRecordResultToInt (Const aRecordResult: tRecordResult): Integer;
  Function fnRecordResultToStr (Const aRecordResult: tRecordResult): String;
  Function fnIntToRecordResult (Const aRecordResult: Integer): tRecordResult;
  Function fnStrToRecordResult (Const aRecordResult: String): tRecordResult;

implementation

Uses MAS_ConstsU, TypInfo;

Function fnVerboseAsText (Const aLevel: tVerboseLevel): String;
begin
  Case aLevel of
    vlNone:    Result := 'None';
    vlFull:    Result := 'Full';
    vlInfo:    Result := 'Info';
    vlDump:    Result := 'Dump';
    vlWarning: Result := 'Warning';
    vlError:   Result := 'Error';
    else       Result := 'UnKnown';
  end;
end;

Function fnVerboseToInt (Const aLevel: tVerboseLevel): Integer;
begin
  Result := Ord (aLevel);
end;

Function fnIntToVerbose (Const aValue: String): tVerboseLevel;
begin
  Result := fnIntToVerbose (StrToInt (aValue));

end;
Function fnIntToVerbose (Const aValue: Integer): tVerboseLevel;
begin
  Case aValue of
    0: Result := vlNone;
    1: Result := vlInfo;
    2: Result := vlFull;
    3: Result := vlDump;
    4: Result := vlWarning;
    5: Result := vlError;
    else Raise Exception.CreateFmt ('Error: fnIntToVerbose. Unknown value passed to routine (%d)', [aValue]);
  end;
end;

// Routine: fnIntToDbAlignment
// Author: M.A.Sargent  Date: 28/03/17  Version: V1.0
//
// Notes:
//
// tAlignment = (taLeftJustify, taRightJustify, taCenter);
//
Function fnIntToDbAlignment (Const aValue: Integer): tAlignment;
begin
  Case aValue of
    cMC_ZERO: Result := taLeftJustify;
    cMC_1:    Result := taRightJustify;
    cMC_2:    Result := taCenter;
    else Raise Exception.CreateFmt ('Error: fnIntToDbAlignment. Unknown value passed to routine. (%d)', [aValue]);
  end;
end;

// Routine: fnBoolean
// Author: M.A.Sargent  Date: 30/03/18  Version: V1.0
//
// Notes:
//
Function fnBoolean (Const aValue: tMASBoolean; Const aDefault: Boolean): Boolean;
begin
  Case aValue of
    mbUnknown: Result := (aDefault);
    mbTrue:    Result := (True);
    mbFalse:   Result := (False);
    else       Result := (False);
  end;
end;

// Routine: fnBoolean
// Author: M.A.Sargent  Date: 30/03/18  Version: V1.0
//
// Notes:
//
Function fnRecordResultToInt (Const aRecordResult: tRecordResult): Integer;
begin
  Result := Ord (aRecordResult);
end;
Function fnRecordResultToStr (Const aRecordResult: tRecordResult): String;
begin
  Result := IntToStr (fnRecordResultToInt (aRecordResult));
end;
Function fnStrToRecordResult (Const aRecordResult: String): tRecordResult;
begin
  Result := fnIntToRecordResult (StrToInt (aRecordResult));
end;
Function fnIntToRecordResult (Const aRecordResult: Integer): tRecordResult;
begin
  Case aRecordResult of
    0: Result := rrUnAssigned;
    1: Result := rrOK;
    2: Result := rrNotOK;
    3: Result := rrCancel;
    4: Result := rrError;
    5: Result := rrException;
    6: Result := rrOption1;
    7: Result := rrOption2;
    8: Result := rrShutDown;
    else Raise Exception.CreateFmt ('Error: fnIntToRecordResult. Unknown Value (%s)', [GetEnumName (TypeInfo (tRecordResult), aRecordResult)]);
  end;
end;

{ tVariableClass }
Constructor tVariableClass.Create;
begin
end;

{ tVariableClass }

Constructor tVariableClass_String.Create (Const aValue: String);
begin
  inherited Create;
  fValue := aValue;
end;

end.
