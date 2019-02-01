//
// Unit: MAS_JSon_D7U
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//         M.A.Sargent        20/07/18           V2.0
//         M.A.Sargent        26/07/18           V3.0
//         M.A.Sargent        30/08/18           V4.0
//
// Notes:
//  V2.0: Add new methods AddArraysValues & fnAddArraysValues
//  V3.0: Updated SetString
//  V4.0: 1. Added a function fnExists
//        2. Updated AddArraysValues
//
unit MAS_JSon_D7U;

interface

Uses Classes, SysUtils, MASStringListU, MASRecordStructuresU, MAS_TypesU, Dialogs, Db;

type
  TSimpleJSon = Class (tObject)
  Private
    fList:    tMASStringList;
    fIntList: tMASStringList;
    //
    Function  GetAsString: String;
    Procedure SetAsString (Value: String);
  Public
    Constructor Create; overload;
    Constructor Create (Const aJSonStr: String); overload;
    Destructor Destroy; override;
    Procedure Clear;
    Function  fnCount: Integer;
    //
    Function fnAdd (Const aName, aValue: String): Integer; overload;
    Function fnAdd (Const aName: String; Const aValue: Integer): Integer; overload;
    Function fnAdd (Const aName: String; Const aValue: Boolean): Integer; overload;
    Function fnAdd (Const aName: String; Const aValue: tDateTime): Integer; overload;
    //
    Function fnAddCurrency (Const aName: String; const aValue: Currency): Integer;
    //

    Procedure AddJSonString     (Const aJSonStr: tJSONString2);
    Procedure AddArraysValues   (Const aParams, aValues: array of string);
    Function  fnAddArrayValues  (Const aParams: array of string; Const aValues: array of string): String;
    Function  fnAddFromList     (Const aList: tStrings; Const aStrictPair, aIgnoreDuplicates: Boolean): String;
    //
    Function  fnGetAsBool  (Const aName: String): Boolean; overload;
    Function  fnGetAsBool  (Const aName: String; Const aDefault: Boolean): Boolean; overload;
    //
    Function  fnGetAsDate  (Const aName: String): tDateTime;
    Function  fnGetAsDate2 (Const aName: String): tOKDateRec;
    //
    Function  fnGetAsInt   (Const aName: String): Integer; overload;
    Function  fnGetAsInt   (Const aName: String; Const aDefault: Integer): Integer; overload;
    Function  fnGetAsInt2  (Const aName: String): tOKIntegerRec;
    //
    Function  fnGetAsStr   (Const aName: String): String;
    Function  fnGetAsStr2  (Const aName: String; Const aRaiseNotFound: Boolean): tOKStrRec; overload;
    Function  fnGetAsStr2  (Const aName, aDefault: String): String; overload;
    //
    Function  fnGetAsCurrency  (Const aName: String): Currency;
    Function  fnGetAsCurrency2 (Const aName: String): tOKCurrencyRec;
    //
    Function  fnGetPair   (Const aIdx: Integer): tValuePair;
    Function  fnGetAsList (Const aList: tStrings; Const aAppendToList: Boolean = True): Integer;
    //
    Function  fnExists    (Const aName: String): Boolean;
    //
    Function  fnLoadFromFields (Const aFields: tFields): Integer;
    //
    Property AsString: String read GetAsString write SetAsString;
  end;

  // Helper Classes
  Function fnChkJSon           (Const aJSonStr: tJSONString2; Const AllowEmptyString: Boolean): Boolean;
  Function fnChkJSonRaise      (Const aJSonStr: tJSONString2; Const AllowEmptyString: Boolean): Boolean;

  Function h_fnAddToArrayValue (Const aJSonStr: tJSONString2; Const aName: String; Const aValue: Boolean): String; overload;
  Function h_fnAddToArrayValue (Const aJSonStr: tJSONString2; Const aName: String; Const aValue: Integer): String; overload;
  Function h_fnAddToArrayValue (Const aJSonStr: tJSONString2; Const aName: String; Const aValue: String): String; overload;
  //
  Function h_fnAddArrayValue   (Const aParam, aValue: String): String; overload;
  Function h_fnAddArrayValue   (Const aParams: array of string; Const aValues: array of string): String; overload;
  Function h_fnAddArrayValue   (Const aJSonStr: tJSONString2; Const aParams: array of string; Const aValues: array of string): String; overload;

  Function h_fnJSonToJSon      (Const aJSonStr1, aJSonStr2: tJSONString2): String;
  Function h_fnJSonAddFromList (Const aList: tStrings; Const aStrictPair, aIgnoreDuplicates: Boolean): String;

  //
  Function h_fnGetAsString     (Const aJSonStr: tJSONString2; Const aName: String): tOKStrRec; overload;
  Function h_fnGetAsString     (Const aJSonStr: tJSONString2; Const aName, aDefault: String): String; overload;
  Function h_fnGetAsString2    (Const aJSonStr: tJSONString2; Const aName: String): String;

  //
  Function h_fnGetAddFromJSon  (Const aJSonStr: tJSONString2; Const aList: tStrings): Integer;
  Function h_fnLoadFromFields  (Const aFields: tFields): tJSONString2;

implementation

Uses MASDatesU, FormatResultU, MASCommonU, MASCommon_UtilsU, MAS_ConstsU, MAS_FloatU, TypInfo;

// Routine: fnChkJSon
// Author: M.A.Sargent  Date: 31/08/18  Version: V1.0
//
// Notes:
//
Function fnChkJSon (Const aJSonStr: tJSONString2; Const AllowEmptyString: Boolean): Boolean;
begin
  if AllowEmptyString then begin
    Result := IsEmpty (aJSonStr);
    if Result then Exit;
  end;
  //
  Result := (Copy (aJSonStr, 1, 1) = '{');
  if Result then Result := (Copy (aJSonStr, Length (aJSonStr), 1) = '}');
end;
Function fnChkJSonRaise (Const aJSonStr: tJSONString2; Const AllowEmptyString: Boolean): Boolean;
begin
  Result := fnChkJSon (aJSonStr, AllowEmptyString);
  fnRaiseOnFalse (Result, 'Error: fnChkJSonRaise. JSon String must Start with a ''{ and End with ''}. String (%s)', [aJSonStr]);
end;

// Routine: h_fbAddArrayValue
// Author: M.A.Sargent  Date: 22/06/18  Version: V1.0
//
// Notes:
//
Function h_fnAddToArrayValue (Const aJSonStr: tJSONString2; Const aName: String; Const aValue: Boolean): String;
begin
  Result := h_fnAddToArrayValue (aJSonStr, aName, BoolToStr((aValue)));
end;
Function h_fnAddToArrayValue (Const aJSonStr: tJSONString2; Const aName: String; Const aValue: Integer): String;
begin
  Result := h_fnAddToArrayValue (aJSonStr, aName, IntToStr((aValue)));
end;
Function h_fnAddToArrayValue (Const aJSonStr: tJSONString2; Const aName: String; Const aValue: String): String;
var
  lvObj: TSimpleJSon;
begin
  lvObj := TSimpleJSon.Create;
  Try
    lvObj.AsString := aJSonStr;
    lvObj.fnAdd (aName, aValue);
    Result := lvObj.AsString;
  Finally
    lvObj.Free;
  end;
end;

// Routine: h_fbAddArrayValue
// Author: M.A.Sargent  Date: 22/06/18  Version: V1.0
//
// Notes:
//
Function h_fnAddArrayValue (Const aParam, aValue: String): String;
begin
  Result := h_fnAddArrayValue ([aParam], [aValue]);
end;
Function h_fnAddArrayValue (Const aParams: array of string; Const aValues: array of string): String;
begin
  Result := h_fnAddArrayValue ('', aParams, aValues);
end;
Function h_fnAddArrayValue (Const aJSonStr: tJSONString2; Const aParams: array of string; Const aValues: array of string): String; overload;
var
  lvObj: TSimpleJSon;
begin
  lvObj := TSimpleJSon.Create;
  Try
    // only add if not empty
    if not IsEmpty (aJSonStr) then lvObj.AsString := aJSonStr;
    //
    lvObj.fnAddArrayValues (aParams, aValues);
    Result := lvObj.AsString;
  Finally
    lvObj.Free;
  end;
end;

// Routine: h_fnJSonToJSon
// Author: M.A.Sargent  Date: 22/06/18  Version: V1.0
//
// Notes:
//
Function h_fnJSonToJSon (Const aJSonStr1, aJSonStr2: tJSONString2): String;
var
  lvObj: TSimpleJSon;
begin
  lvObj := TSimpleJSon.Create;
  Try
    // only add if not empty
    if not IsEmpty (aJSonStr1) then lvObj.AsString := aJSonStr1;
    //
    lvObj.AddJSonString (aJSonStr2);
    Result := lvObj.AsString;
  Finally
    lvObj.Free;
  end;
end;

// Routine: h_fnJSonAddFromList
// Author: M.A.Sargent  Date: 22/06/18  Version: V1.0
//
// Notes:
//
Function h_fnJSonAddFromList (Const aList: tStrings; Const aStrictPair, aIgnoreDuplicates: Boolean): String;
var
  lvObj: TSimpleJSon;
begin
  lvObj := TSimpleJSon.Create;
  Try
    lvObj.fnAddFromList (aList, aStrictPair, aIgnoreDuplicates);
    Result := lvObj.AsString;
  Finally
    lvObj.Free;
  end;
end;

// Routine: h_fnGetAsString
// Author: M.A.Sargent  Date: 22/06/18  Version: V1.0
//
// Notes:
//
Function h_fnGetAsString  (Const aJSonStr: tJSONString2; Const aName: String): tOKStrRec;
var
  lvObj: TSimpleJSon;
begin
  lvObj := TSimpleJSon.Create;
  Try
    //
    lvObj.AsString := aJSonStr;
    Result := lvObj.fnGetAsStr2 (aName, False);
  Finally
    lvObj.Free;
  end;
end;
Function h_fnGetAsString (Const aJSonStr: tJSONString2; Const aName, aDefault: String): String;
var
  lvRes: tOKStrRec;
begin
  lvRes := h_fnGetAsString (aJSonStr, aName);
  Result := IfTrue (lvRes.OK, lvRes.Msg, aDefault);
end;
Function h_fnGetAsString2 (Const aJSonStr: tJSONString2; Const aName: String): String;
var
  lvRes: tOKStrRec;
begin
  lvRes := h_fnGetAsString (aJSonStr, aName);
  fnRaiseOnFalse (lvRes.OK, 'Error. h_fnGetAsString2. Entry not found for Identifier. (%s)', [aName]);
  Result := lvRes.Msg;
end;

// Routine: h_fnGetAsString
// Author: M.A.Sargent  Date: 22/06/18  Version: V1.0
//
// Notes:
//
Function h_fnGetAddFromJSon (Const aJSonStr: tJSONString2; Const aList: tStrings): Integer;
var
  lvObj: TSimpleJSon;
begin
  lvObj := TSimpleJSon.Create;
  Try
    lvObj.AsString := aJSonStr;
    lvObj.fnGetAsList (aList);
    Result := lvObj.fnCount;
  Finally
    lvObj.Free;
  end;
end;

// Routine: h_fnLoadFromFields
// Author: M.A.Sargent  Date: 22/06/18  Version: V1.0
//
// Notes:
//
Function h_fnLoadFromFields (Const aFields: tFields): tJSONString2;
var
  lvObj: TSimpleJSon;
begin
  lvObj := TSimpleJSon.Create;
  Try
    lvObj.fnLoadFromFields (aFields);
    Result := lvObj.AsString;
  Finally
    lvObj.Free;
  end;
end;

{ TSimpleJSon }

Constructor TSimpleJSon.Create;
begin
  fList    := tMASStringList.Create;
  fIntList := tMASStringList.CreateSorted (dupIgnore);
end;
Constructor TSimpleJSon.Create (Const aJSonStr: String);
begin
  Create;
  Self.AsString := aJSonStr;
end;

Destructor TSimpleJSon.Destroy;
begin
  fList.Free;
  fIntList.Free;
  inherited;
end;

Procedure TSimpleJSon.Clear;
begin
  fIntList.Clear;
  fList.Clear;
end;

// Routine: fnAdd
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Function TSimpleJSon.fnAdd (Const aName: String; Const aValue: Integer): Integer;
begin
  Result := fnAdd (aName, IntToStr (aValue));
  fIntList.Add (aName);
end;
Function TSimpleJSon.fnAdd (Const aName, aValue: String): Integer;
begin
  // see if the entry already exists, if so then update the entry else add
  Result := fList.IndexOfName (aName);
  Case Result of
    cMC_NOT_FOUND: Result := fList.AddValues (Trim (aName), aValue);
    else           fList.Values [aName] := aValue;
  end;
end;
Function TSimpleJSon.fnAdd (Const aName: String; Const aValue: tDateTime): Integer;
begin
  Result := fnAdd (aName, fnTS_DateTimeToNoneLocalizedFormat (aValue));
end;
Function TSimpleJSon.fnAdd (Const aName: String; Const aValue: Boolean): Integer;
begin
  Result := fnAdd (aName, BoolToStr (aValue));
end;
Function TSimpleJSon.fnAddCurrency (Const aName: String; Const aValue: Currency): Integer;
begin
  Result := fnAdd (aName, fnTS_CurrToStr (aValue));
end;

// Routine: fnGetAsBool
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Function TSimpleJSon.fnGetAsBool (Const aName: String): Boolean;
begin
  Result := StrToBool (fnGetAsStr2 (aName, True).Msg);
end;
Function TSimpleJSon.fnGetAsBool (Const aName: String; Const aDefault: Boolean): Boolean;
var
  lvRes: tOKStrRec;
begin
  lvRes := fnGetAsStr2 (aName, False);
  Case lvRes.OK of
    True: Result := StrToBool (lvRes.Msg);
    else  Result := aDefault;
  end;
end;

// Routine: fnGetAsDate
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Function TSimpleJSon.fnGetAsDate (Const aName: String): tDateTime;
begin
  Result := fnTS_NoneLocalizedFormatToDateTime (fnGetAsStr2 (aName, True).Msg);
end;
Function TSimpleJSon.fnGetAsDate2 (Const aName: String): tOKDateRec;
var
  lvRes: tOKStrRec;
begin
  lvRes  := fnGetAsStr2 (aName, False);
  Result := fnTS_NoneLocalizedFormatToDateTime2 (lvRes.Msg);
end;

// Routine:
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Function TSimpleJSon.fnGetAsInt (Const aName: String): Integer;
begin
  Result := StrToInt (fnGetAsStr2 (aName, True).Msg);
end;
Function TSimpleJSon.fnGetAsInt (Const aName: String; Const aDefault: Integer): Integer;
var
  lvRes: tOKStrRec;
begin
  lvRes := fnGetAsStr2 (aName, False);
  Case lvRes.OK of
    True: Result := StrToInt (lvRes.Msg);
    else  Result := aDefault;
  end;
end;
Function TSimpleJSon.fnGetAsInt2  (Const aName: String): tOKIntegerRec;
var
  lvRes: tOKStrRec;
begin
  Result := fnClear_OKIntegerRec;
  lvRes  := fnGetAsStr2 (aName, False);
  Result.OK := lvRes.OK;
  if Result.OK then
    Result.OK := TryStrToInt (lvRes.Msg, Result.Int);
end;

// Routine:
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Function TSimpleJSon.fnGetAsStr (Const aName: String): String;
begin
  Result := fnGetAsStr2 (aName, True).Msg;
end;
Function TSimpleJSon.fnGetAsStr2 (Const aName: String; Const aRaiseNotFound: Boolean): tOKStrRec;
begin
  Result := fList.fnValue (aName);
  if aRaiseNotFound then fnRaiseOnFalse (Result.OK, 'Error. fnGetAsStr2. Entry not found for Identifier. (%s)', [aName]);
end;
Function TSimpleJSon.fnGetAsStr2 (Const aName, aDefault: String): String;
var
  lvRes: tOKStrRec;
begin
  lvRes := fnGetAsStr2 (aName, False);
  Result := IfTrue (lvRes.OK, lvRes.Msg, aDefault);
end;

// Routine: fnGetAsCurrency & fnGetAsCurrency2
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Function TSimpleJSon.fnGetAsCurrency  (Const aName: String): Currency;
var
  lvRes: tOKCurrencyRec;
begin
  lvRes := fnGetAsCurrency2 (aName);
  Case lvRes.OK of
    True: Result := lvRes.Value;
    else  Raise Exception.Createfmt ('Error: fnGetAsCurrency. Failed to get Currency for (%s)', [aName]);
  end;
end;
Function TSimpleJSon.fnGetAsCurrency2 (Const aName: String): tOKCurrencyRec;
var
  lvRes: tOKStrRec;
begin
  Result := fnClear_OKCurrencyRec;
  lvRes  := fnGetAsStr2 (aName, False);
  Result.OK := lvRes.OK;
  if Result.OK then
    Result.OK := fnTS_TryStrToCurr (lvRes.Msg, Result.Value);
end;

// Routine: GetAsString
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Function TSimpleJSon.GetAsString: String;
var
  X:      Integer;
  lvPair: tValuePair;
  lvStr:  String;
begin
  Result := '';
  for x := 0 to fList.Count-1 do begin
    lvPair := GetValuePair (fList.Strings [x]);
    //
    if (x > 0) then Result := (Result + ', ');

    Case fIntList.Exists (lvPair.Name) of
      True: lvStr := ('"' + lvPair.Name + '":'  + lvPair.Value);
      else  lvStr := ('"' + lvPair.Name + '":"' + lvPair.Value+'"');
    end;
    //
    Result := (Result + lvStr);
  end;
  //
  if not IsEmpty (Result) then Result := ('{' + Result + '}');
end;

// Routine: SetAsString
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//         M.A.Sargent        26/07/18           V2.0
//
// Notes:
//  V2.0: Updated to check that the String start and ends with a { & }
//
Procedure TSimpleJSon.SetAsString (Value: String);
var
  lvIsInt: Boolean;
  lvPair:  tValuePair;
  x:       Integer;
  lvPos:   Integer;
  lvStr:   String;
begin
  Clear;
  x := 0;
  //
  fnChkJSonRaise (Value, True);
//  if IsEmpty (Value) then Exit;
//  fnRaiseOnFalse ((Copy (Value, 1, 1) = '{'), 'Error: SetAsString. String must Start with a ''{');
//  fnRaiseOnFalse ((Copy (Value, Length (Value), 1) = '}'), 'Error: SetAsString. String must End with a ''{');}
  //
  Value := Copy (Value, 2, MaxInt);
  Value := Copy (Value, 1, (Length (Value)-1));
  //
  Repeat
    lvPos := Pos (', "', Value);
    if (lvPos <> 0) then begin
      lvStr := Copy (Value, 1, (lvPos-1));
      Value := Copy (Value, (lvPos+2), MaxInt);
    end
    else lvStr := Value;

    lvPair := SplitAtDelimiter (lvStr, ':');

    lvIsInt      := (Copy (lvPair.Value, 1, 1) <> '"');
    lvPair.Name  := fnDeQuoteString (lvPair.Name);
    lvPair.Value := fnDeQuoteString (lvPair.Value);
    //fList.AddValues (lvPair.Name, lvPair.Value);
    fnAdd (lvPair.Name, lvPair.Value);
    if lvIsInt then fIntList.Add (lvPair.Name);
    //
    Inc (x);
    if (x >= 1000) then Raise Exception.Create ('Error: SetAsString. Loop Count Hit 1000');
  Until ((lvPos = 0));
end;

// Routine: AddJSonString
// Author: M.A.Sargent  Date: 01/08/18  Version: V1.0
//
// Notes:
//
Procedure TSimpleJSon.AddJSonString (Const aJSonStr: String);
var
  lvJSon: TSimpleJSon;
  x:      Integer;
  lvPair: tValuePair;
begin
  lvJSon := TSimpleJSon.Create;
  Try
    lvJSon.AsString := aJSonStr;
    for x := 0 to lvJSon.fnCount-1 do begin
      lvPair := lvJSon.fnGetPair (x);
      Self.fnAdd (lvPair.Name, lvPair.Value);
    end;
  Finally
    lvJSon.Free;
  end;
end;

// Routine: AddArraysValues & fnAddArraysValues
// Author: M.A.Sargent  Date: 20/06/18  Version: V1.0
//         M.A.Sargent        31/07/18           V2.0
//
// Notes:
//  V2.0: Updated to stop a empty Parameter name being added
//
Procedure TSimpleJSon.AddArraysValues (Const aParams, aValues: array of string);
var
  x: Integer;
begin
  fnRaiseOnFalse ((High(aParams) = High (aValues)), 'Error: AddArraysValues. The Number of Params and Values Should be the Same');
  //
  for x := 0 to High (aParams) do begin
    if not IsEmpty (aParams[x]) then
      Self.fnAdd (aParams[x], aValues[x]);
  end;
end;
Function TSimpleJSon.fnAddArrayValues (Const aParams, aValues: array of string): String;
begin
  //
  AddArraysValues (aParams, aValues);
  Result := Self.AsString;
end;

Function TSimpleJSon.fnAddFromList (Const aList: tStrings; Const aStrictPair, aIgnoreDuplicates: Boolean): String;
var
  x:      Integer;
  lvPair: tValuePair;
begin
  fnRaiseOnFalse (Assigned (aList), 'Error: fnAddFromList. aList Must be Assigned');
  for x := 0 to aList.Count-1 do begin
    //
    lvPair := GetValuePair (aList.Strings[x]);
    Case aIgnoreDuplicates of
      True: if not Self.fnExists(lvPair.Name) then Self.fnAdd (lvPair.Name, lvPair.Value);
      else  Self.fnAdd (lvPair.Name, lvPair.Value);
    end;
  end;
end;

// Routine: fnExists
// Author: M.A.Sargent  Date: 30/07/18  Version: V1.0
//
// Notes:
//
Function TSimpleJSon.fnExists (Const aName: String): Boolean;
begin
  Result := fnGetAsStr2 (aName, False).OK;
end;

// Routine: fnCount & fnGetPair
// Author: M.A.Sargent  Date: 30/07/18  Version: V1.0
//
// Notes:
//
Function TSimpleJSon.fnCount: Integer;
begin
  Result := fList.Count;
end;
Function TSimpleJSon.fnGetPair (Const aIdx: Integer): tValuePair;
begin
  Result := GetValuePair (fList.Strings [aIdx]);
end;

// Routine: fnGetAsList
// Author: M.A.Sargent  Date: 30/07/18  Version: V1.0
//
// Notes:
//
Function TSimpleJSon.fnGetAsList (Const aList: tStrings; Const aAppendToList: Boolean = True): Integer;
begin
  Result := -1;
  if not Assigned (aList) then Exit;
  //
  fList.CopyToList (aList, aAppendToList);
  Result := fList.Count;
end;

// Routine: fnLoadFromFields
// Author: M.A.Sargent  Date: 30/07/18  Version: V1.0
//
// Notes:
//
Function TSimpleJSon.fnLoadFromFields (Const aFields: tFields): Integer;
var
  x:       Integer;
  lvField: tField;
begin
  fnRaiseOnFalse (Assigned (aFields), 'Error: fnLoadFromFields. aFields Must be Assigned');
  Result := 0;
  for x := 0 to aFields.Count-1 do begin
    //
    lvField := aFields[x];
    Case lvField.DataType of
      //
      ftWideString,
       ftString,
        ftFixedChar: Self.fnAdd (lvField.FieldName, lvField.AsString);
      //
      ftSmallint,
       ftInteger,
        ftWord,
         ftLargeInt: Self.fnAdd (lvField.FieldName, lvField.AsInteger);
      //ftFloat:;
      ftDateTime:    Self.fnAdd (lvField.FieldName, lvField.AsDateTime);
      //
      ftCurrency:    Self.fnAddCurrency (lvField.FieldName, lvField.AsCurrency);
      //
      else Raise Exception.CreateFmt ('fnLoadFromFields: Wrong Datatype. %d', [GetEnumName (TypeInfo (TFieldType), Integer (lvField.DataType))]);
    end;
  end;
end;

end.
