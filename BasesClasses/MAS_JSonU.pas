//
// Unit: MAS_JSonU
// Author: M.A.Sargent  Date: 15/03/18  Version: V1.0
//         M.A.Sargent        18/04/18           V2.0
//
// Notes:
//  V2.0: Added fnCreateJSon that processes varaints, that is how I load tDateset parameters
//
//      NOT Yet JSOn just text formatting but this is the only place to be updated once i have a little time
//
unit MAS_JSonU;

interface

Uses MASRecordStructuresU, SysUtils, MASCommonU, MASCommon_UtilsU,
    {$IFDEF VER150}
    {$ELSE}
    System.JSON,
    {$ENDIF}
    Variants, MAS_ConstsU, MAS_TypesU;

Type
  tJSONString2 = String;
  tJSONType    = (jtOKStrRec, jtOKCodeStrRec, jtIntStrRec, jtOther);

{$IFDEF VER150}
{$ELSE}

  tMASJSonObject = Class (tObject)
  Private
    fJSONObject: tJSONObject;
    fJSonString: tJSonString2;
    //
    Procedure SetJSonString (Const Value: tJSonString2);
  Public
    Constructor Create; overload; virtual;
    Constructor Create (Const aJSonString: tJSonString2); overload; virtual;
    Destructor Destroy; override;
    //
    Function fnCount: Integer;
    Function JSonPair (Const aIdx: Integer): tJSONPair;
    //
    Function fnValueExists (Const aName: String): Boolean;
    Function fnFindValue   (Const aName: String): tJSONValue;
    Function fnValueByName (Const aName: String; Const aRaiseOnNotFound: Boolean = True): String;
    //
    Function fnValueByName_AsString  (Const aName: String): String;
    Function fnValueByName_AsBoolean (Const aName: String): Boolean;
    Function fnValueByName_AsInteger (Const aName: String): Integer;
    //

    Function fnArrayExists (Const aName: String): Boolean;
    Function fnArrayCount  (Const aName: String): Integer;
    Function fnArrayGet    (Const aName: String): tJSONArray;
    //
    Function fnArrayEntry  (Const aName: String; Const aIdx: Integer): tJSONValue; overload;
    Function fnArrayEntry  (Const aJSONArray: tJSONArray; Const aIdx: Integer): tJSONValue; overload;

    //
    Class Function Class_fnValueByName_AsString  (Const aJSonString2: tJSonString2; Const aName: String): String;
    Class Function Class_fnValueByName_AsInteger (Const aJSonString2: tJSonString2; Const aName: String): Integer;
    //
    Property JSonString: tJSonString2 read fJSonString write SetJSonString;
    Property JSonObject: tJSONObject  read fJSONObject write fJSONObject;
  End;

{$ENDIF}

  Function fnJSONTypeToInt (Const aJSONType: tJSONType): Integer;
  Function fnJSONTypeToString (Const aJSONType: tJSONType): String;
  Function fnJSONStringToJSONType (Const aValue: tJSONString2): tJSONType;
  //
  Function fnOKStrRecToJSON     (Const aOK: Boolean; Const aMsg: String): tJSONString2; overload;
  Function fnOKStrRecToJSON     (Const aValue: tOKStrRec): tJSONString2; overload;
{$IFDEF VER150}
{$ELSE}
  Function fnJSONToOKStrRec     (Const aValue: tJSONString2): tOKStrRec;
{$ENDIF}
  //
  Function fnOKCodeStrRecToJSON (Const aOK: Boolean; Const aCode: Integer; Const aMsg: String): tJSONString2; overload;
  Function fnOKCodeStrRecToJSON (Const aValue: tOKCodeStrRec): tJSONString2; overload;
  Function fnJSONToOKCodeStrRec (Const aValue: tJSONString2): tOKCodeStrRec;
  //
  Function fnIntStrRecToJSON    (Const aCode: Integer; Const aMsg: String): tJSONString2; overload;
  Function fnIntStrRecToJSON    (Const aValue: tIntStrRec): tJSONString2; overload;
  Function fnJSONToIntStrRec    (Const aValue: tJSONString2): tIntStrRec;
  //

{$IFDEF VER150}
{$ELSE}

  Function fnCreateJSon         (Const aName, aValue: String): tJSONString2; overload;
  Function fnCreateJSon         (Const aNames: Array of String; Const aArray: Array of Integer): tJSONString2; overload;
  Function fnCreateJSon         (Const aNames: Array of String; Const aArray: Array of Variant): tJSONString2; overload;
  Function fnCreateJSon         (Const aNames: Array of String; Const aArray: Array of String): tJSONString2; overload;
  Function fnCreateJSon         (Const aNames: Array of String; Const aArray: Array of TJSONValue): tJSONString2; overload;
  //
  //
{$ENDIF}

implementation

Function fnDequotStr (Const aStr: String): String;
var
  lvLength: Integer;
begin
  // does it start with " and end with "
  lvLength := Length (aStr);
  if ((Copy (aStr, 1, 1) = '"') and (Copy (aStr, lvLength, 1) = '"')) then begin
    // remove the "
    Result := Copy (aStr, 2, (lvLength-2));
  end
  else Result := aStr;
end;

// Routine: fnJSONTypeToInt & fnIntToJSONType
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Function fnJSONTypeToInt (Const aJSONType: tJSONType): Integer;
begin
  Result := Ord (aJSONType);
end;
Function fnJSONTypeToString (Const aJSONType: tJSONType): String;
begin
  Result := IntToStr (fnJSONTypeToInt (aJSONType));
end;
Function fnJSONStringToJSONType (Const aValue: tJSONString2): tJSONType;
var
  lvValuePair: tValuePair;
  lvInt: Integer;
begin
  lvValuePair := SplitAtDelimiter (aValue, ',');                                {Get the first element}
  Case UContainsText ('{"Type"', lvValuePair.Name) of
    True: begin
      lvInt  := StrToInt (SplitAtDelimiter (lvValuePair.Name, ':').Value);     {Split at the ':'}
      Result := tJSONType (lvInt);
    end
    else Result := jtOther;
  end;
end;

Function fnIntToJSONType (Const aValue: Integer): tJSONType;
begin
  Result := tJSONType (aValue);
end;

// Routine: fnOKStrRecToJSON & fnJSONToOKStrRec
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Function fnOKStrRecToJSON (Const aOK: Boolean; Const aMsg: String): tJSONString2;
var
  lvRec: tOKStrRec;
begin
  lvRec.OK  := aOK;
  lvRec.Msg := aMsg;
  Result := fnOKStrRecToJSON (lvRec);
end;
Function fnOKStrRecToJSON (Const aValue: tOKStrRec): tJSONString2;
begin
  { "OK:":"Y", "Value":"New York" };
  Result := '{"Type":' + fnJSONTypeToString (jtOKStrRec);
  //Result := Result + ', "OK":"' + BoolToStr (aValue.OK) + '", "Value":"' + aValue.Msg + '"}';
  Result := Result + ', "OK":"' + BoolToStr (aValue.OK) + '", "Value":"' + aValue.Msg + '", ' +
            '"ExtType": '    + fnRecordResultToStr (aValue.ExtendedInfoRec.aRecordResult) + ', ' +
            '"ExtHandled":"' + BoolToStr (aValue.ExtendedInfoRec.aHandled) + '", '+
            '"ExtCode":'    + IntToStr (aValue.ExtendedInfoRec.aCode) + '}';
end;

{$IFDEF VER150}
{$ELSE}
Function fnJSONToOKStrRec (Const aValue: tJSONString2): tOKStrRec;
var
  lvObj: tMASJSonObject;
begin
  Result.Clear;
  lvObj := tMASJSonObject.Create (aValue);
  Try
    Result.OK                            := lvObj.fnValueByName_AsBoolean ('OK');
    Result.Msg                           := lvObj.fnValueByName_AsString  ('Value');
    Result.ExtendedInfoRec.aRecordResult := fnStrToRecordResult (lvObj.fnValueByName_AsString  ('ExtType'));
    Result.ExtendedInfoRec.aHandled      := lvObj.fnValueByName_AsBoolean ('ExtHandled');
    Result.ExtendedInfoRec.aCode         := lvObj.fnValueByName_AsInteger ('ExtCode');
  Finally
    lvObj.Free;
  End;
end;
{$ENDIF}

// Routine: fnOKCodeStrRecToJSON & fnJSONToOKCodeStrRec
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Function fnOKCodeStrRecToJSON (Const aOK: Boolean; Const aCode: Integer; Const aMsg: String): tJSONString2;
var
  lvRec: tOKCodeStrRec;
begin
  lvRec.OK   := aOK;
  lvRec.Code := aCode;
  lvRec.Msg  := aMsg;
  Result := fnOKCodeStrRecToJSON (lvRec);
end;
Function fnOKCodeStrRecToJSON (Const aValue: tOKCodeStrRec): tJSONString2;
begin
  { "OK":"Y", "Code":222, "Value":"New York" };
  Result := '{"Type":' + fnJSONTypeToString (jtOKCodeStrRec);
  Result := Result + ', "OK":"' + BoolToStr (aValue.OK) + '", "CODE": ' + IntToStr (aValue.Code) + ',' + '"Value":"' + aValue.Msg + '"}';
end;
Function fnJSONToOKCodeStrRec (Const aValue: tJSONString2): tOKCodeStrRec;
var
  lvValuePair: tValuePair;
  lvTmp: String;
begin
  {$IFDEF VER150}
  Result := fnClear_OKCodeStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  lvValuePair := SplitAtDelimiter (aValue, ',');                                {Junk the first element}
  lvValuePair.Value := Copy (lvValuePair.Value, 1, (Length (lvValuePair.Value)-1));
  lvValuePair := SplitAtDelimiter (lvValuePair.Value, ',');                      {}
  lvTmp := AnsiDequotedStr (SplitAtDelimiter (lvValuePair.Name, ':').Value, '"');
  Result.OK  := StrToBool (lvTmp);
  //
  lvValuePair := SplitAtDelimiter (lvValuePair.Value, ',');
  Result.Code := StrToInt (SplitAtDelimiter (lvValuePair.Name, ':').Value);
  lvTmp := SplitAtDelimiter (lvValuePair.Value, ':').Value;
  // Remove the last '}' if it exists
  if (Copy (lvTmp, Length (lvTmp), 1) = '}') then lvTmp := (Copy (lvTmp, 1, (Length (lvTmp) - 1)));
  //
  Result.Msg  := fnDequotStr (lvTmp);
end;

// Routine: fnOKCodeStrRecToJSON & fnJSONToOKCodeStrRec
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Function fnIntStrRecToJSON (Const aCode: Integer; Const aMsg: String): tJSONString2;
var
  lvRec: tIntStrRec;
begin
  lvRec.Int := aCode;
  lvRec.Msg := aMsg;
  Result := fnIntStrRecToJSON (lvRec);
end;
Function fnIntStrRecToJSON (Const aValue: tIntStrRec): tJSONString2; overload;
begin
  { "OK":"Y", "Code":222, "Value":"New York" };
  Result := '{"Type":' + fnJSONTypeToString (jtIntStrRec);
  Result := Result + ', "Integer": ' + IntToStr (aValue.Int) + ',' + '"Value":"' + aValue.Msg + '"}';
end;
Function fnJSONToIntStrRec (Const aValue: tJSONString2): tIntStrRec;
var
  lvValuePair: tValuePair;
  lvTmp: String;
begin
  {$IFDEF VER150}
  Result := fnClear_IntStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  lvValuePair := SplitAtDelimiter (aValue, ',');                             {Junk the first element}
  lvValuePair.Value := Copy (lvValuePair.Value, 1, (Length (lvValuePair.Value)-1));
  lvValuePair := SplitAtDelimiter (lvValuePair.Value, ',');                  {}
  Result.Int  := StrToInt (SplitAtDelimiter (lvValuePair.Name, ':').Value);  {}
  lvTmp := SplitAtDelimiter (lvValuePair.Value, ':').Value;
  // Remove the last '}' if it exists
  if (Copy (lvTmp, Length (lvTmp), 1) = '}') then lvTmp := (Copy (lvTmp, 1, (Length (lvTmp) - 1)));
  //
  Result.Msg  := fnDequotStr (lvTmp);
end;

{$IFDEF VER150}
{$ELSE}

// Routine:
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
{ "OK":"Y", "Code":222, "Value":"New York" }
Function fnAddToJSonStr (Const aName, aValue: String): tJSONString2;
var
  lvJSon: tJSONPair;
begin
  lvJSon := tJSONPair.Create (aName, aValue);
  Try
    Result := lvJSon.ToString;
  Finally
    lvJSon.Free;
  End;
end;

// Routine: fnCreateJSon
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Function fnCreateJSon (Const aName, aValue: String): tJSONString2;
var
  lvObj: tJSONObject;
begin
  lvObj := tJSONObject.Create;
  Try
    lvObj.AddPair (aName, aValue);
    Result := lvObj.ToString;
  Finally
    lvObj.Free;
  End;
end;

Function fnCreateJSon (Const aNames: Array of String; Const aArray: Array of Integer): tJSONString2;
var
  x: Integer;
  lvArray: Array of TJSONValue;
begin
  if (High (aNames) <> High (aArray)) then Raise Exception.Create ('Error: fnCreateJSon Arrays must be the same size');
  SetLength (lvArray, (High (aArray)+1));
  for x := 0 to High (aArray) do
    lvArray [x] := tJSONNumber.Create (aArray[x]);
  //
  Result := fnCreateJSon (aNames, lvArray);
end;

Function fnCreateJSon (Const aNames: Array of String; Const aArray: Array of Variant): tJSONString2;
var
  x: Integer;
  lvArray: Array of TJSONValue;
begin
  if (High (aNames) <> High (aArray)) then Raise Exception.Create ('Error: fnCreateJSon Arrays must be the same size');
  SetLength (lvArray, (High (aArray)+1));
  for x := 0 to High (aArray) do
    lvArray [x] := tJSONString.Create (VarToStr (aArray[x]));
  //
  Result := fnCreateJSon (aNames, lvArray);
end;

Function fnCreateJSon (Const aNames: Array of String; Const aArray: Array of String): tJSONString2;
var
  x: Integer;
  lvArray: Array of TJSONValue;
begin
  if (High (aNames) <> High (aArray)) then Raise Exception.Create ('Error: fnCreateJSon Arrays must be the same size');
  SetLength (lvArray, (High (aArray)+1));
  for x := 0 to High (aArray) do
    lvArray [x] := tJSONString.Create (aArray[x]);
  //
  Result := fnCreateJSon (aNames, lvArray);
end;
Function fnCreateJSon (Const aNames: Array of String; Const aArray: Array of TJSONValue): tJSONString2;
var
  lvObj: tJSONObject;
  x: Integer;
Begin
  if (High (aNames) <> High (aArray)) then Raise Exception.Create ('Error: fnCreateJSon Arrays must be the same size');

  lvObj := tJSONObject.Create;
  Try
    for x := 0 to High (aArray) do
      lvObj.AddPair (aNames[x], aArray[x]);
    Result := lvObj.ToString;
  Finally
    lvObj.Free;
  End;
End;


{ tMASJSonObject }

Constructor tMASJSonObject.Create;
begin
end;

Class Function tMASJSonObject.Class_fnValueByName_AsInteger (Const aJSonString2: tJSonString2; Const aName: String): Integer;
begin
  Result := StrToInt (Class_fnValueByName_AsString (aJSonString2, aName));
end;

Class Function tMASJSonObject.Class_fnValueByName_AsString (Const aJSonString2: tJSonString2; Const aName: String): String;
var
  lvObj: tMASJSonObject;
begin
  lvObj := tMASJSonObject.Create (aJSonString2);
  Try
    Result := lvObj.fnValueByName (aName);
  Finally
    lvObj.Free;
  End;
end;

Constructor tMASJSonObject.Create (Const aJSonString: tJSonString2);
begin
  Create;
  JSonString := aJSonString;
end;

Destructor tMASJSonObject.Destroy;
begin
  if Assigned (fJSONObject) then fJSONObject.Free;
  inherited;
end;

// Routine: fnArrayExists
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Function tMASJSonObject.fnArrayExists (Const aName: String): Boolean;
begin
  Result := Assigned (fnArrayGet (aName));
end;
Function tMASJSonObject.fnArrayCount (Const aName: String): Integer;
var
  lvObj: tJSONArray;
begin
  Result := cMC_ZERO;
  lvObj := fnArrayGet (aName);
  if Assigned (lvObj) then Result := lvObj.Count;
end;
Function tMASJSonObject.fnArrayGet (Const aName: String): tJSONArray;
var
  lvObj: tJSONValue;
begin
  Result := Nil;
  if Assigned (fJSONObject) then begin
    lvObj := fJSONObject.GetValue (aName);
    if (lvObj is tJsonArray) then Result := tJsonArray (lvObj);
  end;
end;

Function tMASJSonObject.fnArrayEntry (Const aName: String; Const aIdx: Integer): tJSONValue;
var
  lvObj: tJSONArray;
begin
  Result := Nil;
  lvObj := fnArrayGet (aName);
  if Assigned (lvObj) then Result := fnArrayEntry (lvObj, aIdx);
end;

Function tMASJSonObject.fnArrayEntry (Const aJSONArray: tJSONArray; Const aIdx: Integer): tJSONValue;
begin
  Result := Nil;
  if not Assigned (aJSONArray) then Exit;
  if ((aIdx >= aJSONArray.Count) and (aIdx <= aJSONArray.Count)) then
    Result := aJSONArray.Items [aIdx];
end;

// Routine: fnCount
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Function tMASJSonObject.fnCount: Integer;
begin
   Result := 0;
  if Assigned (fJSONObject) then
    Result := fJSONObject.Count;
end;

Function tMASJSonObject.fnFindValue (Const aName: String): tJSONValue;
begin
  Result := Nil;
  if Assigned (fJSONObject) then
    Result := fJSONObject.GetValue (aName);
end;

Function tMASJSonObject.fnValueByName (Const aName: String; Const aRaiseOnNotFound: Boolean): String;
var
  lvObj: tJSONValue;
begin
  Result := '';
  lvObj := fnFindValue (aName) as TJSONString;
  Case Assigned (lvObj) of
    True: Result := lvObj.Value;
    else if aRaiseOnNotFound then Raise Exception.CreateFmt ('Error: fnValueByName. Entry NOT found for (%s)', [aName]);
  End;
end;

Function tMASJSonObject.fnValueByName_AsBoolean (Const aName: String): Boolean;
var
  lvTmp: String;
begin
  lvTmp := fnValueByName (aName, True);
  Result := StrToBool (lvTmp);
end;

Function tMASJSonObject.fnValueByName_AsInteger (Const aName: String): Integer;
var
  lvTmp: String;
begin
  lvTmp := fnValueByName (aName, True);
  Result := StrToInt (lvTmp);
end;

Function tMASJSonObject.fnValueByName_AsString (Const aName: String): String;
begin
  Result := fnValueByName (aName, True);
end;

Function tMASJSonObject.fnValueExists (Const aName: String): Boolean;
begin
  Result := Assigned (fnFindValue (aName));
end;

Function tMASJSonObject.JSonPair (Const aIdx: Integer): tJSONPair;
begin
  Result := Nil;
  if Assigned (fJSONObject) then begin
    Result := fJSONObject.Pairs [aIdx];
  end;
end;

Procedure tMASJSonObject.SetJSonString (Const Value: tJSonString2);
begin
  fJSonString := Value;
  if Assigned (fJSONObject) then fJSONObject.Free;
  //
  fJSONObject := tJSONObject.ParseJSONValue (fJSonString) as tJSONObject;
end;

{$ENDIF}

end.
