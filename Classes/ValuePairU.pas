//
// Unit: ValuePairU
// Author: M.A.Sargent  Date: 02/02/2015  Version: V1.0
//
// Notes:
//
unit ValuePairU;

interface

Uses Classes, SysUtils, DB, MASRecordStructuresU;

Type
  tFormatDelimitedString = Class;

  tValuePairEX = Class (tObject)
  Private
    fObj: tFormatDelimitedString;
    fDelimiter: Char;
    fQuoteString: tQuoteStr;
    procedure SetDelimiter(const Value: Char);
    procedure SetQuoteString(const Value: tQuoteStr);
  Public
    Constructor Create; overload;
    Constructor Create (Const aDelimiter: Char; Const aQuoteString: tQuoteStr); overload;
    Destructor Destroy; override;
    //
    Procedure Clear;
    Function fnFormat (Const aName, aValue: String): String; overload;
    Function fnFormat (Const aName: String; Const aValue: Integer): String; overload;
    Function fnFormat (Const aName: String; Const aValue: Double): String; overload;
    //
    Function fnFormatStr (Const aName: String; Const aValues: array of String): String; overload;
    Function fnFormatInt (Const aName: String; Const aValues: array of Integer): String; overload;
    Function fnFormatFloat (Const aName: String; Const aValues: array of Double): String; overload;
    //
    Function fnFormatDataSet (Const aName: String; aDataSet: tDataSet; Const aFieldNames: array of String): String;
    //
    Function AssignValue (Const aString: String): Integer;
    //
    Function fnValue (Const aIdx: Integer): String;
    Function fnValueInt (Const aIdx: Integer): Integer;
    Function fnValueFloat (Const aIdx: Integer): Double;
    //
    Property Delimiter: Char read fDelimiter write SetDelimiter default ',';
    Property QuoteString: tQuoteStr read fQuoteString write SetQuoteString default qsIfNeeded;
  end;


  tFormatDelimitedString = Class (tObject)
  Private
    fQuoteString: tQuoteStr;
    fDelimiter: Char;
    fList: String;
    fOccurrences: Integer;
    fDeQuoteStr: Boolean;
    Function fnContainsDelimiter (Const aString: String): Boolean;
    function fnDeQuoteStr (Const aStr: String): String;
    function fnQuoteStr (Const aStr: String): String;
    function fnIsQuoted (Const aString: String): Boolean;
  Public
    Constructor Create; overload;
    Constructor Create (Const aDelimiter: Char; Const aQuoteString: tQuoteStr; Const aDeQuoteStr: Boolean = True); overload;
    //
    Procedure Clear;
    Function fnFormat (Const aValue: String): String; overload;
    Function fnFormat (Const aValue: Integer): String; overload;
    Function fnFormat (Const aValue: Double): String; overload;
    //
    Function fnFormatStr (Const aValues: array of String): String; overload;
    Function fnFormatInt (Const aValues: array of Integer): String; overload;
    Function fnFormatFloat (Const aValues: array of Double): String; overload;
    //
    Function fnFormatDataSet (aDataSet: tDataSet; Const aFieldNames: array of String): String;
    //
    Function AssignValue (Const aString: String): Integer;
    //
    Function fnValue (Const aIdx: Integer): String;
    Function fnValueInt (Const aIdx: Integer): Integer;
    Function fnValueFloat (Const aIdx: Integer): Double;

    Property DeQuoteStr: Boolean read fDeQuoteStr write fDeQuoteStr default True;
    Property Delimiter: Char read fDelimiter write fDelimiter default ',';
    Property QuoteString: tQuoteStr read fQuoteString write fQuoteString default qsIfNeeded;
  end;

implementation

Uses MASCommonU, MAS_FormatU, DissectU;

{ tValuePairEX }

Constructor tValuePairEX.Create (Const aDelimiter: Char; Const aQuoteString: tQuoteStr);
begin
  Create;
  fObj.Delimiter   := aDelimiter;
  fObj.QuoteString := aQuoteString;
end;

constructor tValuePairEX.Create;
begin
  fObj := tFormatDelimitedString.Create;
end;

Destructor tValuePairEX.Destroy;
begin
  fObj.Free;
  inherited;
end;

Function tValuePairEX.AssignValue (Const aString: String): Integer;
begin
  Result := fObj.AssignValue (aString);
end;

Procedure tValuePairEX.Clear;
begin
  fObj.Clear;
end;

Function tValuePairEX.fnFormat (Const aName, aValue: String): String;
begin
  Result := fnAddValuePair (aName, fObj.fnFormat (aValue));
end;

Function tValuePairEX.fnFormatStr (Const aName: String; Const aValues: array of String): String;
begin
  Result := fnAddValuePair (aName, fObj.fnFormatStr (aValues));
end;

Function tValuePairEX.fnFormat (Const aName: String; Const aValue: Double): String;
begin
  Result := fnAddValuePair (aName, fObj.fnFormat (aValue));
end;

Function tValuePairEX.fnFormat (Const aName: String; Const aValue: Integer): String;
begin
  Result := fnFormat (aName, fObj.fnFormat (aValue));
end;

Function tValuePairEX.fnFormatDataSet (Const aName: String; aDataSet: tDataSet; Const aFieldNames: array of String): String;
begin
  Result := fnAddValuePair (aName, fObj.fnFormatDataSet (aDataSet, aFieldNames));
end;

Function tValuePairEX.fnFormatFloat (Const aName: String; Const aValues: array of Double): String;
begin
  Result := fnAddValuePair (aName, fObj.fnFormatFloat (aValues));
end;

Function tValuePairEX.fnFormatInt (Const aName: String; Const aValues: array of Integer): String;
begin
  Result := fnAddValuePair (aName, fObj.fnFormatInt (aValues));
end;

Function tValuePairEX.fnValue (Const aIdx: Integer): String;
begin
  Result := fObj.fnValue (aIdx);
end;

Function tValuePairEX.fnValueFloat (Const aIdx: Integer): Double;
begin
  Result := fObj.fnValueFloat (aIdx);
end;

Function tValuePairEX.fnValueInt (Const aIdx: Integer): Integer;
begin
  Result := fObj.fnValueInt (aIdx);
end;

procedure tValuePairEX.SetDelimiter (Const Value: Char);
begin
  fDelimiter := Value;
  if Assigned (fObj) then fObj.Delimiter := Value;
end;

procedure tValuePairEX.SetQuoteString (Const Value: tQuoteStr);
begin
  fQuoteString := Value;
  if Assigned (fObj) then fObj.QuoteString := Value;
end;


// Routine: fnContainsDelimiter
// Author: M.A.Sargent  Date: 05/02/15 Version: V1.0
//
// Notes:
//
Constructor tFormatDelimitedString.Create;
begin
  fDelimiter   := ',';
  fQuoteString := qsIfNeeded;
  fDeQuoteStr  := True;
end;

Constructor tFormatDelimitedString.Create (Const aDelimiter: Char; Const aQuoteString: tQuoteStr; Const aDeQuoteStr: Boolean);
begin
  Create;
  Delimiter   := aDelimiter;
  QuoteString := aQuoteString;
  fDeQuoteStr := aDeQuoteStr;
end;

Function tFormatDelimitedString.fnFormat (Const aValue: String): String;
begin
  Case QuoteString of
    qsIfNeeded: if fnContainsDelimiter (aValue) then
                     Result := fnQuoteStr(aValue)
                else Result := aValue;
    qsYes:      Result := fnQuoteStr(aValue);
    else        Result := aValue;
  end;
end;

Function tFormatDelimitedString.fnQuoteStr (Const aStr: String): String;
begin
  Result := aStr;
  if not fnIsQuoted (Result) then
    Result := SysUtils.AnsiQuotedStr (aStr, '"');
end;

Function tFormatDelimitedString.fnDeQuoteStr (Const aStr: String): String;
begin
  Result := aStr;
  if fnIsQuoted (Result) then
    Result := SysUtils .AnsiDequotedStr (aStr, '"');
end;

Function tFormatDelimitedString.fnFormatStr (Const aValues: array of String): String;
var
  lvStr: String;
  x: Integer;
  lvDelimiter: String;
begin
  lvStr := '';
  for x := 0 to High (aValues) do begin
    // Blank delimiter on the first row
    Case (x=0) of
      True: lvDelimiter := '';
      else  lvDelimiter := Delimiter;
    end;
    //
    Case QuoteString of
      qsIfNeeded: if fnContainsDelimiter (aValues[x]) then
                       lvStr := fnTS_Format ('%s%s%s', [lvStr, lvDelimiter, fnQuoteStr (aValues[x])])
                  else lvStr := fnTS_Format ('%s%s%s', [lvStr, lvDelimiter, aValues[x]]);
      qsYes: lvStr := fnTS_Format ('%s%s%s', [lvStr, lvDelimiter, fnQuoteStr (aValues[x])]);
      else   lvStr := fnTS_Format ('%s%s%s', [lvStr, lvDelimiter, aValues[x]]);
    end;
  end;
  //
  Result := lvStr;
end;

// Routine: AssignValue
// Author: M.A.Sargent  Date: 02/02/15 Version: V1.0
//
// Notes:
//
Function tFormatDelimitedString.AssignValue (Const aString: String): Integer;
begin
  fList        := aString;
  fOccurrences := fnOccurrences (Delimiter, fList);
  Result := fOccurrences;
end;

// Routine: fnValue
// Author: M.A.Sargent  Date: 02/02/15 Version: V1.0
//
// Notes:
//
Function tFormatDelimitedString.fnValueInt (Const aIdx: Integer): Integer;
begin
  Result := StrToInt (fnValue (aIdx));
end;

Function tFormatDelimitedString.fnValueFloat (Const aIdx: Integer): Double;
begin
  Result := StrToFloat (fnValue (aIdx));
end;

Function tFormatDelimitedString.fnValue (Const aIdx: Integer): String;
begin
  if ((aIdx > (fOccurrences)) or (aIdx < 0)) then Raise Exception.CreateFmt ('Error: tValuePair. Index Out of Range (%d)', [aIdx]);
  Result := GetField (fList, Delimiter, aIdx);
  //
  Case DeQuoteStr of
    True: Result := fnDeQuoteStr (Result);
    else  {Do Nothing}
  end;
end;

procedure tFormatDelimitedString.Clear;
begin
  fList        := '';
  fOccurrences := 0;
end;

Function tFormatDelimitedString.fnFormat (Const aValue: Double): String;
begin
  Result := FloatToStr (aValue);
end;

Function tFormatDelimitedString.fnFormat (Const aValue: Integer): String;
begin
  Result := IntToStr (aValue);
end;

Function tFormatDelimitedString.fnFormatFloat (Const aValues: array of Double): String;
var
  x: Integer;
  lvArray: Array of String;
begin
  SetLength (lvArray, (High (aValues)+1));
  for x := 0 to High (aValues) do
    lvArray[x] := FloatToStr (aValues[x]);
  //
  Result := fnFormatStr (lvArray);
end;

Function tFormatDelimitedString.fnFormatInt (Const aValues: array of Integer): String;
var
  x: Integer;
  lvArray: Array of String;
begin
  SetLength (lvArray, (High (aValues)+1));
  for x := 0 to High (aValues) do
    lvArray[x] := IntToStr (aValues[x]);
  //
  Result := fnFormatStr (lvArray);
end;

// Routine: fnFormatDataSet
// Author: M.A.Sargent  Date: 02/02/15 Version: V1.0
//
// Notes:
//
Function tFormatDelimitedString.fnFormatDataSet (aDataSet: tDataSet; Const aFieldNames: array of String): String;
var
  x: Integer;
  lvTmp: Array of String;
begin
  Result := '';
  if not Assigned (aDataSet) then Raise Exception.Create ('Error: fnFormatDataSet. Dataset Must be Assigned');
  if not aDataSet.Active then Raise Exception.Create ('Error: fnFormatDataSet. Dataset Must be Active');
  //
  SetLength (lvTmp, (High (aFieldNames)+1));
  //
  for x := 0 to High (aFieldNames) do
    lvTmp [x] := aDataSet.FieldByName (aFieldNames[x]).AsString;
  //
  Result := fnFormatStr (lvTmp);
end;

// Routine: fnContainsDelimiter
// Author: M.A.Sargent  Date: 05/02/15 Version: V1.0
//
// Notes:
//
Function tFormatDelimitedString.fnContainsDelimiter (Const aString: String): Boolean;
begin
  Result := (UPos (Delimiter, aString) <> 0);
end;
Function tFormatDelimitedString.fnIsQuoted (Const aString: String): Boolean;
begin
  Result := ((Copy (aString, 1, 1) = '"') and (Copy (aString, Length (aString), 1) = '"'));
end;

end.

