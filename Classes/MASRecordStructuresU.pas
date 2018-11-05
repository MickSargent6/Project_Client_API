//
// Unit: MASRecordStructuresU
// Author: M.A.Sargent  Date: 30/10/06  Version: V1.0
//         M.A.Sargent        13/03/07           V2.0
//         M.A.Sargent        13/03/07           V3.0
//         M.A.Sargent        01/09/08           V4.0
//         M.A.Sargent        05/05/12           V5.0
//
// Notes:
//  V2.0: Moved record structure
//  V3.0: Add an Integer Pair Record type. tIntegerPair
//  V4.0: Added New record tOKVariant
//  V5.0: Added tXYPair
//
unit MASRecordStructuresU;

interface

Uses Classes, Variants, MAS_TypesU;

Type
  //
  tArrayInteger = Array of Integer;
  tArrayString  = Array of String;
  tArrayVariant = Array of Variant;

  tExtendedInfoRec = Record
    aRecordResult: tRecordResult;
    aHandled:      Boolean;
    aCode:         Integer;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    {$ENDIF}
  End;

  //Decode of the default line from the DFM file (OnBeforeInsert = mtOnBeforeInsertEvent)
  tParamData = record
    Name, Value: String;
  end;

  //Decode of the default line from the DFM file (OnBeforeInsert = mtOnBeforeInsertEvent)
  tParamData2 = record
    Name, Value: String;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    {$ENDIF}
  end;

  //Decode of the valued pair from a stringlist values property (OnBeforeInsert=mtOnBeforeInsertEvent)
  tValuePair = tParamData2;

  tIntegerPair = Record
    Int1, Int2: Integer;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    Procedure Inc_Int1;
    Procedure Inc_Int2;
    Procedure LapCount;
    {$ENDIF}
  end;
  tMinMaxRec = Record
    Min, Max: Integer;
  end;

  tFloatPair = Record
    Num1, Num2: Double;
  end;

  tXYPair = Record
    X, Y: Integer;
  end;

  tOKStrRec = Record
    OK:      Boolean;
    Msg:     String;
    //
    ExtendedInfoRec: tExtendedInfoRec;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear    (Const aDefValue: Boolean = True);
    Procedure SetValue (Const aValue: String); overload;
    Procedure SetValue (Const aOK: Boolean; Const aValue: String); overload;
    Procedure SetValue (Const aOK: Boolean; Const aCode: Integer; Const aValue: String); overload;
    Procedure SetValue (Const aOK: Boolean; Const aCode: Integer); overload;
    //
    Function fnOK: Boolean;
    {$ENDIF}
  end;

  tOKCodeStrRec = Record
    OK: Boolean;
    Code: Integer;
    Msg: String;
    //
    ExtendedInfoRec: tExtendedInfoRec;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    Procedure SetValue (Const aCode: Integer; Const aMsg: String); overload;
    Procedure SetValue (Const aOK: Boolean; Const aCode: Integer; Const aMsg: String); overload;
    {$ENDIF}
  end;

  tIntStrRec = Record
    Int: Integer;
    Msg: String;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    Procedure SetValue (Const aValue: Integer; Const aMsg: String);
    {$ENDIF}
  end;

  tOKIntegerRec = Record
    OK: Boolean;
    Int: Integer;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear (Const aDefValue: Boolean = True);
    Procedure SetValue (Const aOK: Boolean; Const aInt: Integer);
    {$ENDIF}
  end;

  tOKFloatRec = Record
    OK: Boolean;
    Value: Double;
  end;

  tOKCurrencyRec = Record
    OK: Boolean;
    Value: Currency;
  end;

  tOKDateRec = Record
    OK: Boolean;
    Date: tDateTime;
  end;

  tOKStrPairRec = Record
    OK: Boolean;
    Msg: tValuePair;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear (Const aDefValue: Boolean = True);
    Procedure SetValue (Const aName, aValue: String); overload;
    Procedure SetValue (Const aOK: Boolean; Const aName, aValue: String); overload;
    {$ENDIF}
  end;


  tOKIntegerPairRec = Record
    OK: Boolean;
    Ints: tIntegerPair
  end;

  tOKVariant = Record
    OK: Boolean;
    Msg: Variant;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear (Const aDefValue: Boolean = True);
    {$ENDIF}
  end;

  tOKStrRecP = Record
    OK: Boolean;
    Msg: pChar;
  end;

  tOKtStringListRec = Record
    OK: Boolean;
    aList: tStrings;
  end;

  tOKArrayRec = Record
    OK: Boolean;
    aArray: tArrayString;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    {$ENDIF}
  End;

  tLoginRec = Record
    DbName,
     Username,
      Password: String;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    Procedure SetVaue (Const DbName, Username, Password: String);
    {$ENDIF}
  end;
  tLoginRec2 = Record
    aHost:   String;
    aLogRec: tLoginRec;
    {$IFDEF VER150}
    {$ELSE}
    Procedure Clear;
    Procedure SetVaue (Const aHost, DbName, Username, Password: String);
    {$ENDIF}
  end;

  tDateParts = Record
    HR, Min, Sec, Ms, Day, Mth, Year: Word;
  end;

  tCreateObjectRec = Record
    OK: Boolean;
    Msg: String;
    Obj: tObject;
  end;

  tQuoteStr = (qsNo, qsYes, qsIfNeeded);

  {$IFDEF VER150}
  //
  //
  //
  Function fnClear_OKStrRec (Const aDefault: Boolean = True): tOKStrRec;
  Function fnSet_OKStrRec (Const aValue: String): tOKStrRec;
  //
  Function fnClear_OKCodeStrRec: tOKCodeStrRec;

  Function fnClear_IntStrRec: tIntStrRec;

  Function fnClear_OKIntegerRec (Const aDefault: Boolean = True): tOKIntegerRec;

  Function fnClear_OKVariant (Const aDefault: Boolean = True): tOKVariant;
  //
  Function fnClear_OKCurrencyRec (Const aDefault: Boolean = True): tOKCurrencyRec;

  //
  Function fnClear_IntegerPair: tIntegerPair;
  Function fnInc1_IntegerPair     (Const aIntegerPair: tIntegerPair): tIntegerPair;
  Function fnLapCount_IntegerPair (Const aIntegerPair: tIntegerPair): tIntegerPair;
  //
  {$ELSE}
  {$ENDIF}



implementation

{$IFDEF VER150}

// Routine: fnOKStrRec
// Author: M.A.Sargent  Date: 13/05/18  Version: V1.0
//
// Notes: Read the
//
Function fnClear_OKStrRec (Const aDefault: Boolean): tOKStrRec;
begin
  Result.OK  := aDefault;
  Result.Msg := '';
  //
  Result.ExtendedInfoRec.aRecordResult := rrUnAssigned;
  Result.ExtendedInfoRec.aHandled      := False;
  Result.ExtendedInfoRec.aCode         := 0;
end;

Function fnSet_OKStrRec (Const aValue: String): tOKStrRec;
begin
  Result := fnClear_OKStrRec;
  Result.Msg := aValue;
end;

//
Function fnClear_OKCodeStrRec: tOKCodeStrRec;
begin
  Result.OK   := True;
  Result.Code := 0;
  Result.Msg  := '';
  //
  Result.ExtendedInfoRec.aRecordResult := rrUnAssigned;
  Result.ExtendedInfoRec.aHandled      := False;
  Result.ExtendedInfoRec.aCode         := 0;
end;

Function fnClear_IntStrRec: tIntStrRec;
begin
  Result.Int := 0;
  Result.Msg := '';
end;

Function fnClear_OKIntegerRec (Const aDefault: Boolean): tOKIntegerRec;
begin
  Result.OK  := aDefault;
  Result.Int := 0;
end;

Function fnClear_OKCurrencyRec (Const aDefault: Boolean = True): tOKCurrencyRec;
begin
  Result.OK    := aDefault;
  Result.Value := 0;
end;

Function fnClear_OKVariant (Const aDefault: Boolean): tOKVariant;
begin
  Result.OK  := aDefault;
  Result.Msg := Null;
end;

Function fnClear_IntegerPair: tIntegerPair;
begin
  Result.Int1 := 0;
  Result.Int2 := 0;
end;
Function fnInc1_IntegerPair (Const aIntegerPair: tIntegerPair): tIntegerPair;
begin
  Result.Int1 := (aIntegerPair.Int1 + 1);
  Result.Int2 := aIntegerPair.Int2;
end;
Function fnLapCount_IntegerPair (Const aIntegerPair: tIntegerPair): tIntegerPair;
begin
  Result.Int2 := (aIntegerPair.Int1 + aIntegerPair.Int2);
  Result.Int1 := 0;
end;

{$ELSE}

{ tIntStrRec }

Procedure tIntStrRec.Clear;
begin
  Int := 0;
  Msg := '';
end;

Procedure tIntStrRec.SetValue (Const aValue: Integer; Const aMsg: String);
begin
  Int := aValue;
  Msg := aMsg;
end;

{ tOKCodeStrRec }

Procedure tOKCodeStrRec.Clear;
begin
  OK      := True;
  Code    := 0;
  Msg     := '';
  //
  Self.ExtendedInfoRec.Clear;
end;

procedure tOKCodeStrRec.SetValue (Const aCode: Integer; Const aMsg: String);
begin
  SetValue (True, aCode, aMsg);
end;

procedure tOKCodeStrRec.SetValue (Const aOK: Boolean; Const aCode: Integer; Const aMsg: String);
begin
  Self.OK   := aOK;
  Self.Code := aCode;
  Self.Msg  := aMsg;
end;

{ tOKIntegerRec }

Procedure tOKIntegerRec.Clear (Const aDefValue: Boolean = True);
begin
  OK  := aDefValue;
  Int := 0;
end;

procedure tOKIntegerRec.SetValue (Const aOK: Boolean; const aInt: Integer);
begin
  OK  := aOK;
  Int := aInt;
end;

{ tParamData2 }

procedure tParamData2.Clear;
begin
  Name  := '';
  Value := '';
end;

{ tOKStrRec }

Procedure tOKStrRec.Clear (Const aDefValue: Boolean = True);
begin
  OK      := aDefValue;
  Msg     := '';
  //
  Self.ExtendedInfoRec.Clear;
end;

Procedure tOKStrRec.SetValue (Const aValue: String);
begin
  SetValue (True, aValue);
end;

Procedure tOKStrRec.SetValue (Const aOK: Boolean; Const aValue: String);
begin
  Self.Clear;
  OK  := aOK;
  Msg := aValue;
end;

Procedure tOKStrRec.SetValue (Const aOK: Boolean; Const aCode: Integer; Const aValue: String);
begin
  Self.Clear;
  OK  := aOK;
  Msg := aValue;
  Self.ExtendedInfoRec.aCode := aCode;
end;

Function tOKStrRec.fnOK: Boolean;
begin
  Result := (Self.OK and (Self.ExtendedInfoRec.aRecordResult in [rrUnAssigned, rrOK]));
end;

Procedure tOKStrRec.SetValue (Const aOK: Boolean; Const aCode: Integer);
begin
  SetValue (aOK, aCode, '');
end;

{ tOKArrayRec }

Procedure tOKArrayRec.Clear;
begin
  Self.OK := True;
  SetLength (Self.aArray, 0);
end;

{ tOKVariant }

Procedure tOKVariant.Clear (Const aDefValue: Boolean);
begin
  Self.OK := aDefValue;
  Self.Msg := Null;
end;

{ tIntegerPair }

Procedure tIntegerPair.Clear;
begin
  Self.Int1 := 0;
  Self.Int2 := 0;
end;

Procedure tIntegerPair.Inc_Int1;
begin
  Inc (Self.Int1);
end;
Procedure tIntegerPair.Inc_Int2;
begin
  Inc (Self.Int2);
end;

Procedure tIntegerPair.LapCount;
begin
  Self.Int2 := (Self.Int2 + Self.Int1);
  Self.Int1 := 0;
end;

{ tOKStrPairRec }

Procedure tOKStrPairRec.Clear (Const aDefValue: Boolean);
begin
  Self.OK        := aDefValue;
  Self.Msg.Name  := '';
  Self.Msg.Value := '';
end;

Procedure tOKStrPairRec.SetValue (Const aName, aValue: String);
begin
  Self.Msg.Name  := aName;
  Self.Msg.Value := aValue;
end;

Procedure tOKStrPairRec.SetValue (Const aOK: Boolean; Const aName, aValue: String);
begin
  Self.OK        := aOK;
  Self.Msg.Name  := aName;
  Self.Msg.Value := aValue;
end;

{ tExtendedInfoRec }

Procedure tExtendedInfoRec.Clear;
begin
  aRecordResult := rrUnAssigned;
  aHandled      := False;
  aCode         := 0;
end;

{ tLoginRec }

Procedure tLoginRec.Clear;
begin
  SetVaue ('', '', '');
end;

Procedure tLoginRec.SetVaue (Const DbName, Username, Password: String);
begin
  Self.DbName   := DbName;
  Self.UserName := UserName;
  Self.Password := PassWord;
end;

{ tLoginRec }

Procedure tLoginRec2.Clear;
begin
  SetVaue ('', '', '', '');
end;

Procedure tLoginRec2.SetVaue (Const aHost, DbName, Username, Password: String);
begin
  Self.aHost := DbName;
  Self.aLogRec.DbName   := DbName;
  Self.aLogRec.Username := Username;
  Self.aLogRec.Password := Password;
end;

{$ENDIF}

end.
