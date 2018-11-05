//
// Unit: DissectU
// Author: M.A.Sargent  Date: 08/04/04  Version: V1.0
//         M.A.Sargent        13/04/04           V1.1
//         M.A.Sargent        09/02/05           V3.0 VSS Renumbering
//         M.A.Sargent        09/06/08           V4.0
//         M.A.Sargent        11/02/09           V5.0
//         M.A.Sargent        19/05/12           V6.0
//         M.A.Sargent        27/10/17           V7.0
//
// Notes: a small object used to take a delimited string (eg.  comma, tab) and
//        extract each block of data a fire an event for each one found
//
//        Process ('123', 'AAA, BBB, CCCC, DDD, EEE');
//
//        would call the OnValue event as follows
//
//        (1, '123', 'AAA');
//        (2, '123', 'BBB');
//        (3, '123', 'CCC');
//        (4, '123', 'DDD');
//        (5, '123', 'EEE');
//
//        and then call the OnDoneLine event once the line has been processed
//
// Note: Cant present this routine WOULD NOT handle embedded commas, in a CSV
//       string. Not a problem, will do it when have a little more time or
//       I need to process CSV strings. see MAS
//
// V1.1: Add another event that is called once the routine has completed processing
//       a line
// V3.0: Add another end of line event, it will pass an array of strings containing
//       all the values dissected from the original line
// V4.0: Add a List Property so that desected items can be read from a tStringList
// V5.0: 1. Add a function to allow elements for the Array to get Accessed by Index Number
//       2. Add Property to DeQuote String
// V6.0: Add new method ProcessNew that uses a CSV delimiter text method to load a
//       delimited text string
// V7.0: Add a class function fnToArray
//
unit dissectU;

interface

Uses Classes, SysUtils, MASStringListU, MASRecordStructuresU;

Type
 tOnValue = Procedure (Const aIdx: Integer; Const aId, aValue: String) of object;
 tOnArrayLine = Procedure (Const aArray: Array of String) of object;

Type
  tDisect = Class (tObject)
  private
    fList: tStrings;
    fArray: tArrayString; //array of string;
    fLine: String;
    fDelimiter: Char;
    fOnValue: tOnValue;
    fOnDoneLine: tNotifyEvent;
    fOnArrayLine: tOnArrayLine;
    fNewVersion: Boolean;
    fDeQuoteStr: Boolean;
    fCSVList: tMASStringList;
    Function GetArray: tArrayString;
  Protected
    Procedure DoValue (Const aIdx: Integer; Const aId: String; aValue: String); virtual;
    procedure DoneLine; virtual;
  Public
    Constructor Create (Const aDelimiter: Char); overload;
    Constructor Create (Const aDelimiter: Char; Const aNewVersion: Boolean); overload;
    Constructor Create2(Const aDelimiter: Char; Const aDeQuoteStr: Boolean); overload;
    Destructor Destroy; override;
    Property Line: String read fLine write fLine;
    //
    Class Function fnToArray (Const aDelimiter: Char; Const aLine: String): tOKArrayRec;
    //
    Function Process (Const aID: String): Boolean; overload;
    Function Process (Const aID, aLine: String): Boolean; overload;
    Function ProcessNew (Const aID, aLine: String): Boolean;
    //
    Function fnCount: Integer;
    Property List: tStrings read fList write fList;
    Property NewVersion: Boolean read fNewVersion write fNewVersion default False;
    Property DataArray: tArrayString read GetArray;
    //
    Function fnGetValue (Const aIdx: Integer; Const RaiseNotFound: Boolean): String;
    Property DeQuoteStr: Boolean  read fDeQuoteStr write fDeQuoteStr Default False;
    // Remove the Published Property
    Property OnValue: tOnValue read fOnValue write fOnValue;
    Property OnDoneLine: tNotifyEvent read fOnDoneLine write fOnDoneLine;
    Property OnArrayLine: tOnArrayLine read fOnArrayLine write fOnArrayLine;
  end;

  function GetField (Const aLine: String; Const aDelimiter: Char; aIndex:integer):string; overload;
  function GetField(Const aLine: String; Const aDelimiter: Char; aIndex: integer; Var Value: String):Boolean; overload;
  //
  Function fnXXX (Const aLine, aDelimiter: String; aIndex:integer): string; overload;
  Function fnXXX (Const aLine, aDelimiter: String; Const aIndex: Integer; Var Value: String): Boolean; overload;


implementation

Uses MASCommonU;

function GetField (Const aLine: String; Const aDelimiter: Char; aIndex:integer):string;
begin
  GetField (aLine, aDelimiter, aIndex, Result);
end;

function GetField (Const aLine: String; Const aDelimiter: Char; aIndex: integer; Var Value: String):Boolean;

  function GetSubStr (aIndex:integer; var aValue: String):Boolean;
  var
    p1,p2,
    c,n : integer;
  begin
    { Get Start position }
    aValue := '';
    c := 0;
    n := 1;
    while (n <= Length(aLine)) and (c < aIndex) do
    begin
      if Copy(aLine,n,1) = aDelimiter then
        Inc(c);
      Inc(n);
    end;
    { Read until next delim }
    Result := (n <= Length(aLine));
    if Result then begin
      p1 := n;
      while (n <= Length(aLine)) and (Copy(aLine,n,1)<>aDelimiter) do Inc(n);
      p2 := n;
      aValue := Trim (Copy(aLine,p1,p2-p1));
    end;
  end;
begin
  Result := GetSubStr(aIndex, Value);
end;

Function fnXXX (Const aLine, aDelimiter: String; aIndex:integer): string;
var
  lvResult: String;
begin
  fnXXX (aLine, aDelimiter, aIndex, lvResult);
  Result := lvResult;
end;

Function fnXXX (Const aLine, aDelimiter: String; Const aIndex: Integer; Var Value: String): Boolean;
var
  lvOccur: Integer;
  lvP1: Integer;
  lvP2: Integer;
begin
  Value   := '';
  Result  := False;
  lvOccur := fnOccurrences (aDelimiter, aLine);
  if (lvOccur = 0) then Exit;
  //
  if (aIndex = 0) then begin
    lvP1 := NPos  (aDelimiter, aLine, (aIndex+1), False);
    Value := Copy (aLine, 1, (lvP1-1))
  end else if (aIndex = lvOccur) then begin
    lvP1 := NPos  (aDelimiter, aLine, aIndex, False);
    Value := Copy (aLine, (lvP1 + Length (aDelimiter)), MaxInt);
  end else begin
    lvP1 := NPos  (aDelimiter, aLine, aIndex, False);
    lvP2 := NPos  (aDelimiter, aLine, (aIndex+1), False);
    Value := Copy (aLine, (lvP1 + Length (aDelimiter)), ((lvP2-lvP1)-Length (aDelimiter)));
  end;
end;

{ tDisect }

Class Function tDisect.fnToArray (Const aDelimiter: Char; Const aLine: String): tOKArrayRec;
var
  lvObj: tDisect;
begin
  lvObj := tDisect.Create (aDelimiter, True);
  Try
    lvObj.Process ('', aLine);
    Result.OK     := (High (lvObj.fArray) > 0);
    Result.aArray := lvObj.fArray;
  Finally
    lvObj.Free;
  End;
end;


Constructor tDisect.Create2 (Const aDelimiter: Char; Const aDeQuoteStr: Boolean);
begin
  Create (aDelimiter);
  DeQuoteStr := aDeQuoteStr;
end;

Constructor tDisect.Create (Const aDelimiter: Char; Const aNewVersion: Boolean);
begin
  Create (aDelimiter);
  NewVersion := aNewVersion;
end;

Constructor tDisect.Create (Const aDelimiter: Char);
begin
  fOnValue     := Nil;
  fOnDoneLine  := Nil;
  fOnArrayLine := Nil;
  fDelimiter   := aDelimiter;
  fList        := tMASStringList.Create;
  NewVersion   := False;
  DeQuoteStr   := False;
end;

Destructor tDisect.Destroy;
begin
  if Assigned (fCSVList) then fCSVList.Free;
  fList.Free;
  inherited;
end;

// Routine: Process
// Author: M.A.Sargent  Date: 19/05/12  Version: V1.0
//
// Notes:
//
Function tDisect.Process (Const aID, aLine: String): Boolean;
begin
  Line := aLine;
  Result := Process (aId);
end;
Function tDisect.Process (Const aID: String): Boolean;
var
  x, lvPos: Integer;
  lvElement, lvStr: String;
begin
  Result := True;
  fList.Clear;
  x := 0;
  lvStr := Line;
  SetLength(fArray, 0);

  lvPos := Pos (fDelimiter, lvStr);
  // Old Version would not have process a line without a delimiter
  // if property NewVersion is True then it will
  if (lvPos=0) and (lvStr <> '') then begin
    if NewVersion then DoValue (x, aID, lvStr)
  end else
    while (lvPos <> 0) do begin
      lvElement := Copy (lvStr, 1, (lvPos-1));
      DoValue (x, aID, lvElement);
      //
      Inc (x);
      lvStr := Copy (lvStr, (lvPos+1), Length (lvStr));
      lvPos := Pos (fDelimiter, lvStr);
      if (lvPos=0) {and (lvStr <> '')} then
        DoValue (x, aID, lvStr);
    end;
  DoneLine;
end;

// Routine: ProcessNew
// Author: M.A.Sargent  Date: 19/05/12  Version: V1.0
//
// Notes:
//
Function tDisect.ProcessNew (Const aID, aLine: String): Boolean;
var
  x: Integer;
begin
  Result := True;
  fList.Clear;
  // Create Object of not already created
  if not Assigned (fCSVList) then begin
    fCSVList := tMASStringList.Create;
    fCSVList.Delimiter := fDelimiter;
    fCSVList.StrictDelimiter := True;
  end;
  //
  fCSVList.NewDelimitedText := aLine;
  for x := 0 to fCSVList.Count-1 do
    DoValue (x, aID, fCSVList.Strings[x]);
  //
  DoneLine;
end;

Procedure tDisect.DoValue (Const aIdx: Integer; Const aId: String; aValue: String);
begin
  if fDeQuoteStr then begin
    aValue :=  AnsiDequotedStr (aValue, '"');
    aValue :=  AnsiDequotedStr (aValue, '''');
  end;
  if Assigned (fOnValue) then fOnValue (aIdx, aID, aValue);
  SetLength (fArray, aIdx+1);
  fArray[aIdx] := aValue;
  fList.Add (aValue);
end;

// Routine: fnCount
// Author: M.A.Sargent  Date: 21/04/15  Version: V1.0
//
// Notes:
//
Function tDisect.fnCount: Integer;
begin
  Result := High (fArray);
end;

// Routine: fnGetValue
// Author: M.A.Sargent  Date: 11/02/08  Version: V1.0
//
// Notes: Add a Function to allow access to the Array after Processing a Line
//
function tDisect.fnGetValue (const aIdx: Integer; const RaiseNotFound: Boolean): String;
begin
  if (aIdx>High(fArray)) then begin
    if RaiseNotFound then Raise Exception.CreateFmt ('Error: Index (%d) Not Found', [aIdx])
    else Result := '';
  end else Result := fArray [aIdx];
end;

// Routine: GetArray
// Author: M.A.Sargent  Date: 21/04/15  Version: V1.0
//
// Notes:
//
Function tDisect.GetArray: tArrayString;
begin
  Result := fArray;
end;

procedure tDisect.DoneLine;
begin
  if Assigned (fOnDoneLine) then fOnDoneLine (Self);
  if Assigned (fOnArrayLine) then fOnArrayLine (fArray);
end;

end.



