//
// Unit: MASStringListU
// Author: M.A.Sargent  Date:  22/07/2003 Version: V1.0
//         M.A.Sargent         31/08/2003          V1.1
//         M.A.Sargent         26/09/2003          V1.2
//         M.A.Sargent         01/03/2004          V1.3
//         M.A.Sargent         08/04/2004          V1.5
//         M.A.Sargent         13/04/2004          V1.6
//         M.A.Sargent         17/08/2004          V1.7
//         M.A.Sargent         22/10/2004          V9.0 VSS Numbering
//         M.A.Sargent         18/02/2005          V11.0
//         M.A.Sargent         19/05/2005          V12.0
//         M.A.Sargent         20/11/2005          V2.0 VSS Numbering (Again)
//         M.A.Sargent         06/01/2006          V3.0
//         CA                  02/03/2006          V4.0
//         M.A.Sargent         02/03/2006          V5.0
//         M.A.Sargent         23/03/2006          V6.0
//         M.A.Sargent         16/11/2006          V7.0
//         M.A.Sargent         22/05/2007          V8.0
//         M.A.Sargent         01/08/2007          V9.0
//         M.A.Sargent         09/07/2008          V10.0
//         M.A.Sargent         10/12/2008          V11.0
//         M.A.Sargent         28/01/2009          V12.0
//         M.A.Sargent         31/03/2009          V13.0
//         M.A.Sargent         22/05/2009          V14.0
//         M.A.Sargent         14/07/2011          V15.0
//         M.A.Sargent         30/07/2012          V16.0
//         M.A.Sargent         12/11/2012          V17.0
//         M.A.Sargent         19/02/2013          V18.0
//         M.A.Sargent         20/02/2013          V19.0
//         M.A.Sargent         20/02/2013          V20.0
//         M.A.Sargent         24/09/2013          V21.0
//         M.A.Sargent         12/10/2013          V22.0
//         M.A.Sargent         16/10/2013          V23.0
//         M.A.Sargent         11/12/2013          V24.0
//         M.A.Sargent         05/01/2015          V25.0
//         M.A.Sargent         23/11/2016          V26.0
//         M.A.Sargent         20/01/2017          V27.0
//         M.A.Sargent         09/08/2017          V28.0

//         M.A.Sargent         09/01/2015          V26.0
//         M.A.Sargent         21/04/2015          V27.0 PAL_DEV
//         M.A.Sargent         31/07/2015          V28.0 PAL_DEV
//         M.A.Sargent         25/11/2015          V27.0
//         M.A.Sargent         25/11/2015          V28.0
//         M.A.Sargent         13/01/2016          V29.0
//         M.A.Sargent         23/03/2016          V29.0 PSL_DEV
//         M.A.Sargent         23/11/2016          V30.0

//         M.A.Sargent         10/10/2017          V29.0
//
// Notes: tStringList base class
//  V1.1: Update to use tDataset and not tQuery, add override methods to
//        clear associated objects
//  V1.2: Add property to allow the LoadFromQuery methods to Insert all New
//        entries or to Append to the existing list, Remove Dead Code
//  V1.3: Override the Delete method to free associated objects
//  V1.4: Add a Desendant of tMagStringList that has a some simple Navigation
//        methods and properies
//  V1.5: Updated to pass a type of eEventType when calling DoAfterEvent event
//  V1.6: Add a method to Iterate thru all the strings in the list
//  V1.7: Add a new Constructor and Property that will stop the associated objects
//        from being cleared when then tStringList is Cleared, Freed or Items deleted
//  V9.0: Changed to make the Constructor Virtual
// V10.0: ?????????
// V11.0: Add a method AddInt
// V12.0: Add 2 new methods: Exists (has to be a sorted list)
//                           CopyFromList
// V2.0:  Add a CurrentLine property to the public section
// V3.0:  1. DeleteByName
//        2. CreateSorted Constructor
//
// V4.0:  Remove the Inherited Create from overloaded constructor.
// V5.0:  Add a  Function AddMsg (Const aFormat: string; const Args: array of const): Integer;
//        that takes the same parameters as the Foramt function
// V6.0:  Add a GetIndex function to return the position of the String Item in the list
// V7.0:  add method fnValueExist, used when process value pairs eg. nnn=nnn
// V8.0:  Add a method fnPosIndex, see method notes
// V9.0:  1. Add a new write method to the CurrentLine property
//        2. Add another version of the function fnPosIndex, you can now choose the
//           occurrence of the string you are looking for
// V10.:  Add method AddValues
// V11.0: Add a new method: Minus,
// V12.0: Added two new Object methods
//         1. fnObjectExists (Const aIdentifier: String): Boolean;
//         2. fnObject  (Const aIdentifier: String): Boolean;
// V13.0: Add a InsertMsg method that takes a Format String
// V14.0: Minus Function set the default return vlaue to be 0 and not -1
// V8.0:  Added function AddValues
// V9.0:  Add method CopyToList , the reverse of CopyFromList
// V15.0: Add methods: ExtractFromList
//                     fnOccurrence
// V16.0: Add a Merge method
// V17.0: Add new methods
//          1. LoadFromQueryEx
//          2. CreateAppend
// V18.0: Added functions fnPosIndex2 and fnPosLocate
// V19.0:
// V20.0: Added another version of fnValuePair
// V21.0: 1. Add a new helper function hCopyFromList
//        2. Add a Procedure ReverseOrder;
// V22.0: Add more Helpers routines
// V23.0: Add another version of AddValues
// V24.0: Bug fix. fnValuePair
// V25.0: renamed fnSwapNamedPairValues and created another overloaded version
// V26.0: Updated to add a Desc parameter to the SortInt routines
// V27.0:
// V28.0: Added tMASHashedStringList
// V29.0: Updated the CopyTo type methods, added aBeginUpdate and EndUpdate
//
unit MASStringListU;

Interface

Uses Classes, SysUtils, db, MASRecordStructuresU, Windows, Forms, Controls, ValuePairU, IniFiles;

Type
  tMASStringList = Class;
  tOnLineEvent = Procedure (Sender: tMASStringList; Const aIdx:Integer; Const aValue: String) of object;
  tLengthType = (ltAll, ltName, ltValue);

  tMASBaseStringList = Class (tStringList)
  Private
    fStrictDelimiter: Boolean;
    fFormat: tFormatSettings;
    Procedure SetNewDelimitedText(const Value: String);
    Function GetNewDelimitedText: string;
  Protected
    Property TS_LocaleSettings: tFormatSettings read fFormat;
  Public
    Constructor Create; overload; virtual;
    Property NewDelimitedText: String read GetNewDelimitedText write SetNewDelimitedText;
    Property StrictDelimiter: Boolean read fStrictDelimiter write fStrictDelimiter default False;
    //
    Function fnMaxLength (Const aLengthType: tLengthType): Integer;
  end;

  tMASStringList = Class (tMASBaseStringList)
  private
    fOnLineEvent: tOnLineEvent;
    fFreeObjects: Boolean;
    fAppendToList: Boolean;
    //
    Function fnQuoteStr (Const aValue: String): String;
  Public
    Constructor Create; overload; override;
    Constructor Create (Const FreeObjects: Boolean); overload;
    Constructor CreateSorted (Const Duplicate: tDuplicates = dupError); overload;
    Constructor CreateAppend (Const Duplicate: tDuplicates = dupError; Const AppendToList: Boolean = True); overload;

    Destructor Destroy; override;
    Function AddMsg (Const aFormat: string; const Args: array of const): Integer;
    Function AddInt (Const aInt: Integer): Integer;
    //
    Function AddValues (Const aName: String; Const aValue: Integer): Integer; overload;
    Function AddValues (Const aName, aValue: String): Integer; overload;
    //
    Function fnInt_InitValue (Const aName: String): Integer; overload;
    Function fnInt_InitValue (Const aFormat: string; const Args: array of const): Integer; overload;
    Function fnInt_IncrementValue (Const aName: String; Const aRaiseNotFound: Boolean = False): Integer; overload;
    Function fnInt_IncrementValue (Const aFormat: string; const Args: array of const; Const aRaiseNotFound: Boolean = False): Integer; overload;
    Function fnInt_GetValue (Const aName: String; Const aRaiseNotFound: Boolean = False): Integer; overload;
    Function fnInt_GetValue (Const aFormat: string; const Args: array of const; Const aRaiseNotFound: Boolean = False): Integer; overload;

    Procedure InsertMsg (Const aIdx: Integer; Const aFormat: string; const Args: array of const);

    Procedure Clear; override;
    Procedure Delete (Index: Integer); override;
    Function DeleteByName (Const aName: String): Boolean;
    Function DeleteByIndexOf (Const aName: String; Const DeleteAll: Boolean): Boolean;
    Function DeleteByIndexOfName (Const aName: String; Const DeleteAll: Boolean): Boolean;

    Function Exists (Const aIdentifier: String): Boolean;
    Function fnValueExist (Const aIdentifier: String): Boolean;
    Function fnValue (Const aIdentifier: String): tOKStrRec;
    Function fnValuePair (Const aIdentifier: String): tValuePair; overload;
    Function fnValuePair (Const aIndex: Integer): tValuePair; overload;
    //
    // 3 main types other can be added as an when
    Function fnValueAsString  (Const aName: String): String; overload;
    Function fnValueAsString  (Const aName: String; Const aDefault: String): String; overload;
    Function fnValueAsBoolean (Const aName: String): Boolean; overload;
    Function fnValueAsBoolean (Const aName: String; Const aDefault: Boolean): Boolean; overload;
    Function fnValueAsInteger (Const aName: String): Integer; overload;
    Function fnValueAsInteger (Const aName: String; Const aDefault: Integer): Integer; overload;
    //
    Function fnNameFromValue (Const aValue: String; Const IgnoreCase: Boolean = True): tOKStrRec;
    //
    // Methods that work on Object;
    Function fnObjectExists (Const aIdentifier: String): Boolean;
    Function fnObject (Const aIdentifier: String): tObject;
    //
    Function GetIndex (Const aIdentifier: String): Integer;
    //
    Procedure SortInt (Const aDesc: Boolean = False);
    Procedure SortFloat (Const aDesc: Boolean = False);
    //
    Function fnPosIndex (Const aIdentifier: String): tIntegerPair; overload;
    Function fnPosIndex (Const aIdentifier: String; Occurrence: Integer): tIntegerPair; overload;
    Function fnPosIndex (Const aIdentifier: String; Occurrence: Integer; Const IgnoreCase: Boolean): tIntegerPair; overload;
    Function fnPosIndex2 (Const aIdentifier: String): Integer;
    // fnPosLocate loops thru data and stops at the first line startinf with aIdentifier
    Function fnPosLocate (Const aIdentifier: String; Const aTrim: Boolean): Integer; overload;
    Function fnPosLocate (Const aIdentifier: String; Const aTrim, IgnoreCase: Boolean): Integer; overload;
    //
    Function fnOccurrence (Const aIdentifier: String; Const CaseSensitive: Boolean = False): Integer;
    //
    Function Minus (aList: tStringList): Integer; overload;
    Function Minus (aList: tStringList; var aOutputList: tMASStringList): Integer; overload;
    //
    Function Merge (aList: tStringList): Integer;
    //
    Procedure ReverseOrder;
    //
    Function fnSwapNamedPaidValues: Integer; overload;
    Function fnSwapNamedPaidValues (var aList: tStrings): Integer; overload;

    Function ExtractFromList (Const aStartLine, aLastLine: Integer; aList: tStrings): Integer;
    //
    Function CopyFromList (aList: tStrings; AppendToList: Boolean = True): Integer;
    Function CopyToList (aList: tStrings; AppendToList: Boolean = True): Integer;
    Function CopyToList_VP_Format (aList: tStrings; Const aFormat: String; AppendToList: Boolean = True): Integer;
    //
    Function  LoadFromQuery (aDataSet: tDataSet; Const ColumnName: String): Integer; overload;
    Function  LoadFromQueryEx (aDataSet: tDataSet; Const ColumnName: String; Const HourGlass: Boolean = True): Integer;
    Function  LoadFromQueryValuePair (aDataSet: tDataSet; Const aNameColumnName, aValueColumnName: String): Integer;
    Function  LoadFromArray (Const aArray: Array of String; Const AppendToList: Boolean = False): Integer;
    //
    Procedure LoadFromQuery (aDataSet: tDataSet; Const TrimFields: Boolean); overload;
    Procedure LoadFromQuery (aDataSet: tDataSet; Const Delimiter: Char = ','; Const QuoteStrings: Boolean = True; Const TrimFields: Boolean = False); overload;
    Procedure LoadFromQuery2 (aDataSet: tDataSet; Const Delimiter: Char = ','; Const QuoteStrings: Boolean = True; Const TrimFields: Boolean = False; Const aDoHeader: Boolean = True);
    Procedure LoadCurrentRowAsValues (aDataSet: tDataSet);
    //
    Function fnLoadFromFile (Const aFileName: String): Boolean;
    //
    Property AppendToList: Boolean  read fAppendToList write fAppendToList default False;
    Property FreeObjects: Boolean read fFreeObjects write fFreeObjects;
    //
    Property OnLineEvent: tOnLineEvent read fOnLineEvent write fOnLineEvent;
  end;

  //
  tVP_MASStringList = Class (tMASStringList)
  Private
    fValuePair: tValuePairEX;
  Public
    Constructor Create; overload; override;
    Constructor Create (Const aDelimiter: Char); overload;
    Constructor Create (Const aDelimiter: Char; Const aQuoteString: tQuoteStr); overload;
    //
    Destructor Destroy; override;
    //
    Function AssignValueByName (Const aName: String): Boolean;
    Procedure AssignValueByIndex (Const aIdx: Integer);
    //
    Property ValuePair: tValuePairEX read fValuePair write fValuePair;
    //
  end;

  { THashedStringList - A TStringList that uses TStringHash to improve the
    speed of Find }
  tMASHashedStringList = class(TMASStringList)
  private
    FValueHash:      TStringHash;
    FNameHash:       TStringHash;
    FValueHashValid: Boolean;
    FNameHashValid:  Boolean;
    fFound:          Boolean;
    Procedure        UpdateValueHash;
    Procedure        UpdateNameHash;
  protected
    procedure Changed; override;
  public
    destructor Destroy; override;
    Function IndexOf     (Const S: string): Integer; override;
    Function IndexOfName (Const Name: string): Integer; override;
    Procedure Clear; override;
    //
    Property Found: Boolean read fFound;
  end;

  // Helper functions
  Function hCopyFromList (aSource, aDest: tStrings; AppendToList: Boolean = True): Integer;
  Function hCopyFromList2 (aSource, aDest: tStrings; Const aForward: Boolean; Const AppendToList: Boolean = True): Integer;
  //
  Function hCreateStringList (Const aNames: array of string; Const aValues: array of String): tMASStringList; overload;
  Function hCreateStringList (Const aText: String): tMASStringList; overload;
  Function hCreateStringList (Const aSource: tStrings): tMASStringList; overload;
  //
  Function hAppendToFile (Const aFileName: String; Const aList: tStrings): Integer; overload;
  Function hAppendToFile (Const aFileName, aFormat: string; const Args: array of const): Integer; overload;
  Function hAppendToFile (Const aFileName, aMsg: String): Integer; overload;
  //
  Function hLoadFromFile (Const aFileName: String; Const aList: tStrings): Integer;
  Function hCountFromFile (Const aFileName: String): Integer;
  //
  Function h_fnAddFieldsToList (Const aFields: tFields; Const aList: tStrings; Const aAddNulls: Boolean): Integer;
  //
Type
  tCurrentString = record
    aString: String;
    aObject: tObject;
  end;

implementation

Uses Dialogs, MASCommonU, MASStringList_CustomSortRoutinesU, MAS_ConstsU, MAS_LocalityU, MASCommon_UtilsU,
      MAS_FormatU, FormatResultU;

Const
  csmgEMPTY       = 'Error: List is Empty';
  csmgNUMBERERROR = 'Error: Internal Position is Greater Than the Current Count Value';

Function hCopyFromList (aSource, aDest: tStrings; AppendToList: Boolean = True): Integer;
begin
  Result := hCopyFromList2 (aSource, aDest, False, AppendToList);
end;

Function hCopyFromList2 (aSource, aDest: tStrings; Const aForward: Boolean; Const AppendToList: Boolean = True): Integer;
var
  x: Integer;
begin
  Result := -1;
  if not Assigned (aSource) and not Assigned (aDest) then Exit;
  aDest.BeginUpdate;
  Try
    if not AppendToList then aDest.Clear;
    Case aForward of
      True: for x := 0 to aSource.Count-1 do
              aDest.Add (aSource.Strings[x]);

      else  for x := aSource.Count-1 downto 0 do
              aDest.Add (aSource.Strings[x]);
    end;
    Result := aDest.Count;
  Finally
    aDest.EndUpdate;
  end;
end;

// Routine: hCreateStringList
// Author: M.A.Sargent  Date: 22/09/2017 Version: V1.0
//
// Notes:
//
Function hCreateStringList (Const aNames: array of string; Const aValues: array of String): tMASStringList;
var
  x: Integer;
begin
  if High (aNames) <> High (aValues) then Raise Exception.Create ('Error: hCreateStringList. The number of aNames and aValues array parameters be the Same');
  //
  Result := tMASStringList.Create;
  Try
    for x := 0 to High (aNames) do
      Result.AddValues (aNames[x], aValues[x]);
  Except
    FreeAndNil (Result);
    Raise;
  end;
end;
Function hCreateStringList (Const aText: String): tMASStringList;
begin
  Result := tMASStringList.Create;
  Try
    Result.Text := aText;
  Except
    FreeAndNil (Result);
    Raise;
  end;
end;
Function hCreateStringList (Const aSource: tStrings): tMASStringList;
begin
  fnRaiseOnFalse (Assigned (aSource), 'Error: hCreateStringList. aSource List must be Assigned');
  Result := hCreateStringList (aSource.Text);
end;

// Routine: hAppendToFile
// Author: M.A.Sargent  Date: 15/12/2017 Version: V1.0
//
// Notes:
//
Function hAppendToFile (Const aFileName: string; Const aList: tStrings): Integer;
var
  x: Integer;
begin
  Result := -1;
  if not Assigned (aList) then Exit;
  with tStringList.Create do
    Try
      if FileExists (aFileName) then LoadFromFile (aFileName);
      //
      for x := 0 to aList.Count-1 do
        Add (aList.Strings[x]);
      SaveToFile (aFileName);
      Result := Count;
    Finally
      Free;
    End;
end;
Function hAppendToFile (Const aFileName, aFormat: string; const Args: array of const): Integer;
begin
  Result := hAppendToFile (aFileName, fnTS_Format (aFormat, Args));
end;
Function hAppendToFile (Const aFileName, aMsg: String): Integer;
begin
  with tStringList.Create do
    Try
      if FileExists (aFileName) then LoadFromFile (aFileName);
      Add (aMsg);
      SaveToFile (aFileName);
      Result := Count;
    Finally
      Free;
    End;
end;

// Routine: hLoadFromFile
// Author: M.A.Sargent  Date: 15/12/2017 Version: V1.0
//
// Notes:
//
Function hLoadFromFile (Const aFileName: String; Const aList: tStrings): Integer;
begin
  Result := 0;
  if Assigned (aList) then
    if FileExists(aFileName) then
    begin
      aList.LoadFromFile(aFileName);
      Result := aList.Count;
    end;
end;

// Routine: h_fnAddFieldsToList
// Author: M.A.Sargent  Date: 24/01/2018 Version: V1.0
//
// Notes:
//
Function hCountFromFile (Const aFileName: String): Integer;
var
  lvList: tStrings;
begin
  lvList := tStringList.Create;
  Try
    lvList.LoadFromFile (aFileName);
    Result := lvList.Count;
  Finally
    lvList.Free;
  end;
end;


// Routine: h_fnAddFieldsToList
// Author: M.A.Sargent  Date: 24/01/2018 Version: V1.0
//
// Notes:
//
Function h_fnAddFieldsToList (Const aFields: tFields; Const aList: tStrings; Const aAddNulls: Boolean): Integer;
var
 x: integer;
begin
  Result := 0;
  if not Assigned (aFields) then Exit;
  if not Assigned (aList) then Exit;
  //
  aList.Clear;
  for x := 0 to aFields.Count - 1 do begin
    //
    if not aFields[x].IsNull or aAddNulls then begin
      //
      Case aFields[x].DataType of
        //
        ftWideString,
         ftString,
          ftFixedChar,
        ftSmallint,
         ftInteger,
          ftWord,
           ftLargeInt,
        ftFloat,
        ftDate,
         ftDateTime,
        ftTime:        aList.Add (fnAddValuePair (aFields[x].FieldName, aFields[x].AsString));
        //
        //ftFMTBCD,
        // FTbcd:        Result := StrToInt (aValue);
        else Raise Exception.CreateFmt ('fnAssignDataValue: Wrong Datatype. %d', [Ord (aFields[x].DataType)]);
      end;
    end;
  end;
  Result := aList.Count;
end;

{ tMASBaseStringList }

constructor tMASBaseStringList.Create;
begin
  Inherited Create;
  fStrictDelimiter := False;
  fFormat          := fnTS_LocaleSettings;
end;

procedure tMASBaseStringList.SetNewDelimitedText (Const Value: String);
var
  P, P1: PChar;
  S: string;
begin
  BeginUpdate;
  try
    Clear;
    P := PChar(Value);
    if not StrictDelimiter then
      while P^ in [#1..' '] do
      {$IFDEF MSWINDOWS}
        P := CharNext(P);
      {$ELSE}
        Inc(P);
      {$ENDIF}
    while P^ <> #0 do
    begin
      if P^ = QuoteChar then
        S := AnsiExtractQuotedStr(P, QuoteChar)
      else
      begin
        P1 := P;
        while ((not FStrictDelimiter and (P^ > ' ')) or
              (FStrictDelimiter and (P^ <> #0))) and (P^ <> Delimiter) do
        {$IFDEF MSWINDOWS}
          P := CharNext(P);
        {$ELSE}
          Inc(P);
        {$ENDIF}
        SetString(S, P1, P - P1);
      end;
      Add(S);
      if not FStrictDelimiter then
        while P^ in [#1..' '] do
        {$IFDEF MSWINDOWS}
          P := CharNext(P);
        {$ELSE}
          Inc(P);
        {$ENDIF}

      if P^ = Delimiter then
      begin
        P1 := P;
        {$IFDEF MSWINDOWS}
        if CharNext(P1)^ = #0 then
        {$ELSE}
        Inc(P1);
        if P1^ = #0 then
        {$ENDIF}
          Add('');
        repeat
          {$IFDEF MSWINDOWS}
          P := CharNext(P);
          {$ELSE}
          Inc(P);
          {$ENDIF}
        until not (not FStrictDelimiter and (P^ in [#1..' ']));
      end;
    end;
  finally
    EndUpdate;
  end;
end;

Function tMASBaseStringList.GetNewDelimitedText: string;
var
  S: string;
  P: PChar;
  I, Count: Integer;
  LDelimiters: set of Char;
begin
  Count := GetCount;
  if (Count = 1) and (Get(0) = '') then
    if QuoteChar = #0 then
      Result := ''
    else
      Result := QuoteChar + QuoteChar
  else
  begin
    Result := '';
    if QuoteChar <> #0 then
    begin
      LDelimiters := [Char(#0), Char(QuoteChar), Char(Delimiter)];
      if not StrictDelimiter then
        LDelimiters := LDelimiters + [Char(#1)..Char(' ')];
    end;

      for I := 0 to Count - 1 do
      begin
        S := Get(I);
        if QuoteChar <> #0 then begin
          P := PChar(S);
          while not (P^ in LDelimiters) do
            P := CharNext(P);

          if (P^ <> #0) then S := AnsiQuotedStr(S, QuoteChar);
        end;

        Result := Result + S + Delimiter;
      end;

      System.Delete(Result, Length(Result), 1);
  end;
end;

// Routine: fnMaxLength
// Author: M.A.Sargent  Date: 20/01/17  Version: V1.0
//
// Notes:
//
Function tMASBaseStringList.fnMaxLength (Const aLengthType: tLengthType): Integer;
var
  x: Integer;
  lvRec: tValuePair;
  lvLength: Integer;
begin
  Result := cMC_NOT_FOUND;
  for x := 0 to Count-1 do begin
      lvRec := GetValuePair (Strings [x]);
      Case aLengthType of
        ltAll:  lvLength := Length (Strings [x]);
        ltName: lvLength := Length (lvRec.Name);
        {ltValue:}
        else    lvLength := Length (lvRec.Value);
      end;
      //
      if (lvLength > Result) then Result := lvLength;
  end;
end;

{ tMASStringList }

// Routine: Constructors 3
// Author: M.A.Sargent  Date: ??/??/???? Version: V1.0
//         M.A.Sargent        05/01/2006          V2.0
//
// Notes:
//  V2.0: Add a CreateSorted constructor
//
constructor tMASStringList.Create;
begin
  Inherited Create;
  fAppendToList := False;
  fFreeObjects  := True;   {Default to True, Free all objects}
  fOnLineEvent  := Nil;
end;

constructor tMASStringList.Create (Const FreeObjects: Boolean);
begin
  Create;
  fFreeObjects := FreeObjects;
end;

constructor tMASStringList.CreateSorted (Const Duplicate: tDuplicates);
begin
  Create;
  Sorted := True;
  Duplicates := Duplicate;
end;

Constructor tMASStringList.CreateAppend (Const Duplicate: tDuplicates; Const AppendToList: Boolean);
begin
  CreateSorted (Duplicate);
  Self.AppendToList := AppendToList;
end;

// Routine: Delete
// Author: M.A.Sargent  Date: //04  Version: V1.0
//
// Notes: Override the Delete method to remove Object entries
//
procedure tMASStringList.Delete(Index: Integer);
begin
  if fFreeObjects and Assigned (Objects[Index]) then
    Objects[Index].Free;
  inherited;
end;

procedure tMASStringList.Clear;
var
  x: Integer;
begin
  if fFreeObjects then
    for x := 0 to Count-1 do
     if Assigned (Objects[x]) then
       Objects[x].Free;
  inherited;
end;

destructor tMASStringList.Destroy;
begin
  Clear;
  inherited;
end;

// Routine: LoadFromQuery and LoadFromQueryEx
// Author: M.A.Sargent  Date: 10/10/12  Version: V1.0
//
// Notes: MAS 26/09/03 Allow list to be appended to
//
Function tMASStringList.LoadFromQuery (aDataSet: tDataSet; Const ColumnName: String): Integer;
begin
  Result := LoadFromQueryEx (aDataSet, ColumnName, False);
end;
Function tMASStringList.LoadFromQueryEx (aDataSet: tDataSet; Const ColumnName: String; Const HourGlass: Boolean): Integer;
var
  lvCursor: tCursor;
  lvBookMark: tBookMark;
begin
  Result := -1;
  lvCursor := Screen.Cursor;
  if not Assigned (aDataSet) then Exit;
  if not fAppendToList then Clear;

  with aDataSet do begin
    Inc (Result);                                     // Make it 0
    if aDataSet.IsEmpty then Exit;

    if HourGlass then begin
      lvCursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
    end;
    DisableControls;
    lvBookMark := GetBookMark;                        // Save Bookmark
    Try
      First;
      While not Eof do begin
        Add (FieldByName (ColumnName).AsString);
        Inc (Result);                                 // Increment
        Next;
      end;
      aDataSet.GotoBookMark (lvBookMark);             // Return to the Bookmark
    Finally
      FreeBookMark (lvBookMark);                      // Release Bookmark
      EnableControls;
      if HourGlass then Screen.Cursor := lvCursor;
    end;
  end;
end;

// Routine: LoadFromQuery
// Author: M.A.Sargent  Date: 26/09/03  Version: V1.0
//         M.A.Sargent        17/11/08           V2.0
//
//  V2.0: Bug fix
//
// Notes: MAS 26/09/03 Allow list to be appended to
procedure tMASStringList.LoadFromQuery (aDataSet: tDataSet; const TrimFields: Boolean);
var
  lvStr: String;
  x: Integer;
begin
  if not fAppendToList then Clear;
  with aDataSet do begin
    First;
    While not Eof do begin
      lvStr := '';
      for x := 0 to FieldCount-1 do begin
        if TrimFields then
             lvStr := lvStr + Trim(Fields[x].AsString)
        else lvStr := lvStr + Fields[x].AsString;

      end;
      Add (lvStr);
      Next;
    end;
  end;
end;

// Routine: LoadFromQueryValuePair
// Author: M.A.Sargent  Date: 30/06/15  Version: V1.0
//
// Notes:
//
Function tMASStringList.LoadFromQueryValuePair (aDataSet: tDataSet; Const aNameColumnName, aValueColumnName: String): Integer;
begin
  Result := -1;
  if not Assigned (aDataSet) then Exit;
  if not AppendToList then Clear;

  with aDataSet do begin
    Inc (Result);                                     // Make it 0
    if aDataSet.IsEmpty then Exit;

    DisableControls;
    Try
      First;
      While not Eof do begin
        Self.AddValues (FieldByName (aNameColumnName).AsString, FieldByName (aValueColumnName).AsString);
        Inc (Result);                                 // Increment
        Next;
      end;
    Finally
      EnableControls;
    end;
  end;
end;


// Routine:
// Author: M.A.Sargent  Date: //04  Version: V1.0
//
// Notes:
//
procedure tMASStringList.LoadFromQuery (aDataSet: tDataSet; Const Delimiter: Char; Const QuoteStrings, TrimFields: Boolean);
begin
  LoadFromQuery2 (aDataSet, Delimiter, QuoteStrings, TrimFields, False);
end;
procedure tMASStringList.LoadFromQuery2 (aDataSet: tDataSet; Const Delimiter: Char; Const QuoteStrings, TrimFields, aDoHeader: Boolean);
var
  lvStr: String;
  x: Integer;
  Function fnFormat (Const aValue: String; Const aTrimFields, LastField: Boolean): String;
  var
    lvValue: String;
  begin
    lvValue := IfTrue (aTrimFields, Trim (aValue), aValue);
    Case LastField of
      True:  Result := IfTrue (QuoteStrings, fnQuoteStr (lvValue), lvValue);
      False: Result := IfTrue (QuoteStrings, fnQuoteStr (lvValue), lvValue) + Delimiter;
    end;
  end;
begin
  if not fAppendToList then Clear;
  with aDataSet do begin
    First;
    if aDoHeader then begin
      lvStr := '';
      for x := 0 to FieldCount-1 do
        lvStr := lvStr + fnFormat (Fields[x].FieldName, TrimFields, (x=(FieldCount-1)));
      Add (lvStr);
    end;
    While not Eof do begin
      lvStr := '';
      for x := 0 to FieldCount-1 do
        lvStr := lvStr + fnFormat (Fields[x].AsString, TrimFields, (x=(FieldCount-1)));
      Add (lvStr);
      Next;
    end;
  end;
end;

// Routine: Minus
// Author: M.A.Sargent  Date: 09/12/08  Version: V1.0
//
// Notes:
//
Function tMASStringList.Minus (aList: tStringList): Integer;
var
  lvNotAssignedList: tMASStringList;
begin
  Result := Minus (aList, lvNotAssignedList);
end;

// MAS 22/05/2009 Bug Fix. REsult Init to 0 and not -1
Function tMASStringList.Minus (aList: tStringList; var aOutputList: tMASStringList): Integer;
var
  x: Integer;
  lvIdx: Integer;
begin
  Result := 0;
  if not Assigned (aList) then Exit;
  if Assigned (aOutputList) then aOutputList.Clear;

  if not (Self.Sorted and aList.Sorted) then Raise Exception.Create ('Error: Both Lists Must be Sorted');
  if (Self.Duplicates=dupAccept) or (aList.Duplicates=dupAccept) then Raise Exception.Create ('Error: Either List Can Not Have Duplicates');
  //
  for x := 0 to Count-1 do begin
    Case aList.Find (Self.Strings[x], lvIdx) of
      True:; {Do Nothing As Yet}
      False: begin
        Inc (Result);      // Return the number of Output Items
        if Assigned (fOnLineEvent) then fOnLineEvent (Self, (x+1), Self.Strings[x]);
        if Assigned (aOutputList) then begin
          if Assigned (Self.Objects [x]) then
                aOutputList.AddObject (Self.Strings[x], Self.Objects [x])
          else  aOutputList.Add (Self.Strings[x]);
        end;
      end;
    End;
  end;
end;

// Routine: Merge
// Author: M.A.Sargent  Date: 30/07/12  Version: V1.0
//
// Notes:
//
Function tMASStringList.Merge (aList: tStringList): Integer;
var
  x: Integer;
begin
  Result := 0;
  if not Assigned (aList) then Exit;
  if not (Self.Sorted and aList.Sorted) then Raise Exception.Create ('Error: Both Lists Must be Sorted');
  if (Self.Duplicates=dupAccept) or (aList.Duplicates=dupAccept) then Raise Exception.Create ('Error: Either List Can Not Have Duplicates');
  //
  for x := 0 to aList.Count-1 do begin
    if not Self.Exists (aList.Strings [x]) then
      Self.Add (aList.Strings [x]);
  end;
end;

// Routine:
// Author: M.A.Sargent  Date: //04  Version: V1.0
//
// Notes:
//
procedure tMASStringList.LoadCurrentRowAsValues (aDataSet: tDataSet);
var
  x: Integer;
begin
  if not fAppendToList then Clear;
  with aDataSet do begin
    if not Eof then
      // loop thru fields add add each one to the tStringList as a Values
      // property (eg. COLUMN_NAME=FRED
      //               COLUMN_SIZE=424). See Help for tStringList.values
      for x := 0 to FieldCount-1 do begin
        Values [Fields[x].FieldName] := Fields[x].AsString;
      end;
  end;
end;

function tMASStringList.AddInt (Const aInt: Integer): Integer;
begin
  Result := Add (IntToStr(aInt));
end;

// Routine: AddMsg
// Author: M.A.Sargent  Date: 21/02/06  Version: V1.0
//
// Notes: New version, allow the data to be passed in the format that can be
//        used by the Format function
//
function tMASStringList.AddMsg (Const aFormat: string; Const Args: array of Const): Integer;
begin
  Result := Add (Format (aFormat, Args, TS_LocaleSettings));
end;

Function tMASStringList.AddValues (Const aName: String; Const aValue: Integer): Integer;
begin
  Result := AddValues (aName, IntToStr (aValue));
end;
Function tMASStringList.AddValues (Const aName, aValue: String): Integer;
begin
  Result := Add (Format ('%s=%s', [Trim(aName), Trim (aValue)], TS_LocaleSettings));
end;

// Routine: Exists
// Author: M.A.Sargent  Date: 18/10/05  Version: V1.0
//
// Notes: List must be sorted to us this function
//
function tMASStringList.Exists (Const aIdentifier: String): Boolean;
var
  lvJunk: Integer;
begin
  if not Sorted then Raise Exception.Create ('Error: StringList Must be Sorted to use Exists');
  Result := Find (aIdentifier, lvJunk);
end;

// Routine: fnValueExist
// Author: M.A.Sargent  Date: 30/10/06  Version: V1.0
//
// Notes:
//
function tMASStringList.fnValueExist (Const aIdentifier: String): Boolean;
begin
  Result := (IndexOfName (aIdentifier) >= 0);
end;

// Routine: fnValuePair
// Author: M.A.Sargent  Date: 10/03/13  Version: V1.0
//         M.A.Sargent        11/12/13           V2.0
//
// Notes:
//  V2.0: Bug fix
//
Function tMASStringList.fnValuePair (Const aIndex: Integer): tValuePair;
begin
  Result := GetValuePair (Self.Strings[aIndex]);
  //Result := fnValuePair (Self.Names [aIndex]);
end;

function tMASStringList.fnValuePair (Const aIdentifier: String): tValuePair;
var
  x: Integer;
begin
  Result.Name  := '';
  Result.Value := '';
  x := IndexOfName (aIdentifier);
  if (x <> -1) then
    Result := GetValuePair (Strings[x]);
end;

function tMASStringList.fnValue (Const aIdentifier: String): tOKStrRec;
var
  x: Integer;
begin
  Result.Msg := '';
  x := IndexOfName (aIdentifier);
  Result.OK := (x <> -1);
  if Result.OK then Result.Msg := Self.ValueFromIndex [x];
end;

// Routine: fnValueAsString, fnValueAsBoolean & fnValueAsInteger
// Author: M.A.Sargent  Date: 05/04/18  Version: V1.0
//
// Notes:
//
Function tMASStringList.fnValueAsString (Const aName: String): String;
begin
  Result := fnValueAsString (aName, '');
end;
Function tMASStringList.fnValueAsString (Const aName: String; Const aDefault: String): String;
var
  lvRes : tOKStrRec;
begin
  lvRes := fnValue (aName);
  Result := IfTrue (lvRes.OK, lvRes.Msg, aDefault);
end;
Function tMASStringList.fnValueAsBoolean (Const aName: String): Boolean;
begin
    Result := fnValueAsBoolean (aName, True);
end;
Function tMASStringList.fnValueAsBoolean (Const aName: String; Const aDefault: Boolean): Boolean;
var
  lvRes : tOKStrRec;
begin
  lvRes := fnValue (aName);
  Result := IfTrue (lvRes.OK, (lvRes.Msg = '1'), aDefault);
end;
Function tMASStringList.fnValueAsInteger (Const aName: String): Integer;
begin
    Result := fnValueAsInteger (aName, -1);
end;
Function tMASStringList.fnValueAsInteger (Const aName: String; Const aDefault: Integer): Integer;
var
  lvRes : tOKStrRec;
begin
  lvRes := fnValue (aName);
  Case lvRes.OK of
    True: Result := StrToInt (lvRes.Msg);
    else  Result := aDefault;
  end;
end;

// Routine: ExtractFromList
// Author: M.A.Sargent  Date: 14/07/11  Version: V1.0
//
// Notes: Add items from a list supplied
//
function tMASStringList.ExtractFromList (Const aStartLine, aLastLine: Integer; aList: tStrings): Integer;
var
  x: Integer;
  lvStr: String;
  lvLastLine: Integer;
begin
  Result := 0;
  if not Assigned (aList) then Exit;
  aList.Clear;
  if (aLastLine = -1) then
       lvLastLine := (Count-1)
  else lvLastLine := aLastLine-1;
  for x := (aStartLine-1) to lvLastLine do begin
    lvStr := Self.Strings[x];
    aList.Add (lvStr);
  end;
  Result := aList.Count;
end;

// Routine: CopyFromList
// Author: M.A.Sargent  Date: 19/05/05  Version: V1.0
//
// Notes: Add items from a list supplied
//
function tMASStringList.CopyFromList (aList: tStrings; AppendToList: Boolean): Integer;
var
  x: Integer;
begin
  Result := 0;
  if not Assigned (aList) then Exit;
  if not AppendToList then Clear;
  for x := 0 to aList.Count-1 do
    Add (aList.Strings[x]);
  Result := aList.Count;
end;

Function tMASStringList.CopyToList (aList: tStrings; AppendToList: Boolean): Integer;
var
  x: Integer;
begin
  Result := 0;
  if not Assigned (aList) then Exit;
  aList.BeginUpdate;
  Try
    if not AppendToList then aList.Clear;
    for x := 0 to Count-1 do
      aList.Add (Strings[x]);
    Result := Count;
  Finally
    aList.EndUpdate;
  end;
end;

// Routine: DeleteByName
// Author: M.A.Sargent  Date: 22/12/05  Version: V1.0
//
// Notes:
//
Function tMASStringList.DeleteByName (Const aName: String): Boolean;
var
  Idx: Integer;
begin
  if not Sorted then Raise Exception.Create ('tStringList Must be Sorted to use the DeleteByName Method');
  Result := Find (aName, Idx);
  if Result then Delete (Idx);
end;

// Routine: DeleteByIndexOf
// Author: M.A.Sargent  Date: 22/12/05  Version: V1.0
//
// Notes: Loop thru a list (backwards) and delete based on the Name
//
Function tMASStringList.DeleteByIndexOf (Const aName: String; Const DeleteAll: Boolean): Boolean;
var
  x: Integer;
begin
  Result := False;
  for x := Self.Count-1 downto 0 do begin
    if IsEqual (Self.Strings[x], aName) then begin
      //
      Self.Delete (x);
      Result := True;
      if not DeleteAll then Break;
    end;
  end;
end;

// Routine: DeleteByIndexOfName
// Author: M.A.Sargent  Date: 22/12/05  Version: V1.0
//
// Notes: Loop thru a list (backwards) and delete based on the value pair Name
//
Function tMASStringList.DeleteByIndexOfName (Const aName: String; Const DeleteAll: Boolean): Boolean;
var
  x: Integer;
  lvRec: tValuePair;
begin
  Result := False;
  for x := Self.Count-1 downto 0 do begin
    lvRec := GetValuePair (Self.Strings[x]);
    if IsEqual (lvRec.Name, aName) then begin
      //
      Self.Delete (x);
      Result := True;
      if not DeleteAll then Break;
    end;
  end;
end;

// Routine: CopyToList_VP_Format
// Author: M.A.Sargent  Date: 20/01/17  Version: V1.0
//
// Notes:
//
Function tMASStringList.CopyToList_VP_Format (aList: tStrings; Const aFormat: String; AppendToList: Boolean): Integer;
var
  x: Integer;
  lvRec: tValuePair;
  lvLength: Integer;
begin
  Result := 0;
  if not Assigned (aList) then Exit;
  if (aFormat = '') then Result := CopyToList (aList, AppendToList)
  else
    begin
      //
      aList.BeginUpdate;
      Try
        if not AppendToList then aList.Clear;
        //
        lvLength := fnMaxLength (ltName);
        //
        for x := 0 to Count-1 do begin
          lvRec := fnValuePair (x);
          aList.Add (Format (aFormat, [RPad2 (lvRec.Name, lvLength), lvRec.Value], TS_LocaleSettings));
        end;
      Finally
        aList.EndUpdate;
      end;
      Result := Count;  // Was in wrong place...  IanB
    end;
end;

// Routine: GetIdx
// Author: M.A.Sargent  Date: 22/03/06  Version: V1.0
//         M.A.Sargent        21/04/15           V2.0
//
// Notes:
//  V2.0: Add a Sorted Check
//
function tMASStringList.GetIndex (Const aIdentifier: String): Integer;
begin
  if not Sorted then Raise Exception.Create ('Error: tStringList Must be Sorted to use GetIndex');
  if not Find (aIdentifier, Result) then
    Result := -1;
end;

Procedure tMASStringList.InsertMsg (Const aIdx: Integer; const aFormat: string; const Args: array of const);
begin
  Insert (aIdx, Format (aFormat, Args, TS_LocaleSettings));
end;

// Routine: fnPosIndex2
// Author: M.A.Sargent  Date: 10/02/13  Version: V1.0
//
// Notes:
//
Function tMASStringList.fnPosIndex2 (Const aIdentifier: String): Integer;
var
  lvRes: tIntegerPair;
begin
  lvRes := fnPosIndex (aIdentifier);
  Result := lvRes.Int1;
end;

// Routine: fnPosIndex
// Author: M.A.Sargent  Date: 22/05/07  Version: V1.0
//
// Notes: Find the First instance of a SubStr in the list, -1 returned if not Found
//
function tMASStringList.fnPosIndex (Const aIdentifier: String): tIntegerPair;
begin
  Result := fnPosIndex (aIdentifier, 1);
end;

function tMASStringList.fnObject (const aIdentifier: String): tObject;
var
  x: Integer;
begin
  Result := Nil;
  if not Sorted then Raise Exception.Create ('tStringList Must be Sorted to use the fnObject Method');
  if Find (aIdentifier,  x) then
    Result := self.Objects [x];
end;

function tMASStringList.fnObjectExists (const aIdentifier: String): Boolean;
begin
  Result := (fnObject (aIdentifier) <> Nil);
end;

function tMASStringList.fnPosIndex (Const aIdentifier: String; Occurrence: Integer): tIntegerPair;
begin
  Result := fnPosIndex (aIdentifier, Occurrence, True);
end;

function tMASStringList.fnPosIndex (Const aIdentifier: String; Occurrence: Integer; Const IgnoreCase: Boolean): tIntegerPair;
var
  x: Integer;
  lvHitCount: Integer;
begin
  lvHitCount := 0;
  Result.Int1 := -1;
  for x := 0 to Count-1 do begin
    Case IgnoreCase of
      True:  Result.Int2 := UPos (aIdentifier, Strings[x]);
      False: Result.Int2 := Pos (aIdentifier, Strings[x]);
    end;
    if (Result.Int2 > 0) then begin
      Inc (lvHitCount);
      if (lvHitCount = Occurrence) then begin
        Result.Int1 := x;
        Break;
      end;
    end;
  end;
  if (Result.Int1 = -1) then Result.Int2 := -1;
end;

// Routine: fnOccurrence
// Author: M.A.Sargent  Date: 14/07/11  Version: V1.0
//
// Notes:
//
function tMASStringList.fnOccurrence (Const aIdentifier: String; Const CaseSensitive: Boolean): Integer;
var
  x: Integer;
begin
  Result := 0;
  for x := 0 to Count-1 do begin
    Case CaseSensitive of
      True:  if IsSame  (aIdentifier, Strings[x]) then Inc (Result);
      False: if IsEqual (aIdentifier, Strings[x]) then Inc (Result);
    end;
  end;
end;

// Routine: fnPosLocate
// Author: M.A.Sargent  Date: 20/02/13  Version: V1.0
//
// Notes: Needs to be update to StartsWith and Contains
//
Function tMASStringList.fnPosLocate (Const aIdentifier: String; Const aTrim: Boolean): Integer;
begin
  Result := fnPosLocate (aIdentifier, aTrim, True);
end;
Function tMASStringList.fnPosLocate (Const aIdentifier: String; Const aTrim, IgnoreCase: Boolean): Integer;
var
  x: Integer;
  lvStr: String;
  lvIdx: Integer;
begin
  Result := -1;
  for x := 0 to Count-1 do begin
    Case aTrim of
      True: lvStr := Trim (Strings[x]);
      else  lvStr := Strings[x];
    end;
    //
    Case IgnoreCase of
      True: lvIdx := UPos (aIdentifier, lvStr);
      else  lvIdx := Pos  (aIdentifier, lvStr);
    end;
    if (lvIdx = 1) then begin
      Result := x;
      Break;
    end;
  end;
end;

// Routine: fnQuoteStr
// Author: M.A.Sargent  Date: 26/06/15  Version: V1.0
//
// Notes:
//
Function tMASStringList.fnQuoteStr (Const aValue: String): String;
begin
  Result := aValue;
  if (aValue = '') then Exit;

  // May need to set this later
  Case True of
    True: Result := AnsiQuotedStr (aValue, QuoteChar);
    else  Result := QuotedStr (aValue);
  end;
end;

// Routine: ReverseOrder
// Author: M.A.Sargent  Date: 24/09/13  Version: V1.0
//
// Notes:
//
procedure tMASStringList.ReverseOrder;
var
  x: Integer;
begin
  if Self.Sorted then Raise Exception.Create ('Error: ReverseOrder can not be used on Sorted Lists');
  for x := 0 to Count-1 do begin
    Self.Exchange (x, ((Count-1) - x));
    if ((x+1) = Trunc ((Count/2))) then Break;
  end;
end;

// Routine: fnSwapNamedPaidValues
// Author: M.A.Sargent  Date: 05/01/14 Version: V1.0
//
// Notes:
//
Function tMASStringList.fnSwapNamedPaidValues (var aList: tStrings): Integer;
var
  x: Integer;
  lvRec: tValuePair;
begin
  Result := 0;
  if not Assigned (aList) then Exit;
  aList.Clear;
  for x := 0 to Count-1 do begin
    lvRec := fnValuePair (x);
    aList.Add (fnAddValuePair (lvRec.Value, lvRec.Name));
  end;
  Result := aList.Count;
end;
Function tMASStringList.fnSwapNamedPaidValues: Integer;
var
  x: Integer;
  lvRec: tValuePair;
begin
  for x := 0 to Count-1 do begin
    lvRec := fnValuePair (x);
    Self.Strings [x] := fnAddValuePair (lvRec.Value, lvRec.Name);
  end;
  Result := Self.Count;
end;

// Routine: SortIntm, SortFloat;
// Author: M.A.Sargent  Date: 09/01/14  Version: V1.0
//
// Notes:
//
Procedure tMASStringList.SortInt (Const aDesc: Boolean);
begin
  if Self.Sorted then Raise Exception.Create ('Error: SortInt ca not work on a Already sorted Object. Sort = True');
  Case aDesc of
    True: Self.CustomSort (CompareIntDesc);
    else  Self.CustomSort (CompareInt);
  end;

end;
Procedure tMASStringList.SortFloat (Const aDesc: Boolean);
begin
  if Self.Sorted then Raise Exception.Create ('Error: SortInt ca not work on a Already sorted Object. Sort = True');
  Case aDesc of
    True: Self.CustomSort (CompareFloatDesc);
    else  Self.CustomSort (CompareFloat);
  end;
end;

// Routine: fnInt_InitValue, fnInt_IncrementValue & fnInt_GetValue
// Author: M.A.Sargent  Date: 20/01/17  Version: V1.0
//
// Notes: fnInt_IncrementValue is not found
//
Function tMASStringList.fnInt_InitValue (Const aFormat: string; Const Args: array of const): Integer;
begin
  Result := fnInt_InitValue (Format (aFormat, Args, TS_LocaleSettings));
end;
Function tMASStringList.fnInt_InitValue (Const aName: String): Integer;
begin
  Result := AddValues (aName, 0);
end;
Function tMASStringList.fnInt_IncrementValue (Const aFormat: string; Const Args: array of const; Const aRaiseNotFound: Boolean): Integer;
begin
  Result := fnInt_IncrementValue (Format (aFormat, Args, TS_LocaleSettings), aRaiseNotFound);
end;
Function tMASStringList.fnInt_IncrementValue (Const aName: String; Const aRaiseNotFound: Boolean): Integer;
begin
  // if aRaiseNotFound and not found then fnInt_GetValue will raise an exception, else if Not Found then Add/Init at 0
  Result := fnInt_GetValue (aName, aRaiseNotFound);
  if (Result = cMC_NOT_FOUND) then begin
    fnInt_InitValue (aName);
    Result := 0;
  end;
  // Increment regardless
  Inc (Result);
  Self.Values [aName] := IntToStr (Result);
end;
Function tMASStringList.fnInt_GetValue (Const aFormat: string; Const Args: array of const; Const aRaiseNotFound: Boolean): Integer;
begin
  Result := fnInt_GetValue (Format (aFormat, Args, TS_LocaleSettings), aRaiseNotFound);
end;
Function tMASStringList.fnInt_GetValue (Const aName: String; Const aRaiseNotFound: Boolean): Integer;
var
  lvRes: tOKStrRec;
begin
  Result := cMC_NOT_FOUND;
  lvRes := fnValue (aName);
  if lvRes.OK then begin
    Result := StrToInt (lvRes.Msg);
  end
  else if aRaiseNotFound then Raise Exception.Create (Format ('Error: fnInt_GetValue. Entrry (%s) Not Found', [aName], TS_LocaleSettings));
end;

{ tVP_MASStringList }

Constructor tVP_MASStringList.Create;
begin
  Inherited;
  fValuePair := tValuePairEX.Create (Self.Delimiter, qsIfNeeded);
end;

Constructor tVP_MASStringList.Create (Const aDelimiter: Char);
begin
  Create (aDelimiter, qsIfNeeded);
end;

Constructor tVP_MASStringList.Create (Const aDelimiter: Char; Const aQuoteString: tQuoteStr);
begin
  Create;
  fValuePair.Delimiter   := aDelimiter;
  fValuePair.QuoteString := aQuoteString;
end;

Destructor tVP_MASStringList.Destroy;
begin
  fValuePair.Free;
  inherited;
end;

Function tVP_MASStringList.AssignValueByName (Const aName: String): Boolean;
var
  x: Integer;
begin
  x := Self.IndexOfName (aName);
  Result := (x <> -1);
  if Result then AssignValueByIndex (x);
end;

Procedure tVP_MASStringList.AssignValueByIndex (Const aIdx: Integer);
begin
  fValuePair.AssignValue (Self.ValueFromIndex [aIdx]);
end;

// Routine: fnLoadFromFile
// Author: M.A.Sargent  Date: 09/01/15  Version: V1.0
//
// Notes:
//
Function tMASStringList.fnLoadFromFile (Const aFileName: String): Boolean;
begin
  Result := FileExists (aFileName);
  if Result then Self.LoadFromFile (aFileName);
end;

// Routine: fnNameFromValue
// Author: M.A.Sargent  Date: 25/11/15  Version: V1.0
//
// Notes:
//
Function tMASStringList.fnNameFromValue (Const aValue: String; Const IgnoreCase: Boolean): tOKStrRec;
var
  x: Integer;
  lvRec: tValuePair;
begin
  Result.OK  := False;
  Result.Msg := '';
  for x := 0 to Self.Count-1 do begin
    //
    lvRec := fnValuePair (x);
    Case IgnoreCase of
      True: if IsEqual (lvRec.Value, aValue) then begin
              Result.Msg := lvRec.Name;
              Result.OK  := True;
            end;
      else if (lvRec.Value = aValue) then begin
              Result.Msg := lvRec.Name;
              Result.OK  := True;
            end;
    end;
    if Result.OK then Break;
  end;
end;

// Routine: LoadFromArray
// Author: M.A.Sargent  Date: 26/11/15  Version: V1.0
//
// Notes:
//
Function tMASStringList.LoadFromArray (Const aArray: array of String; Const AppendToList: Boolean): Integer;
var
  x: Integer;
begin
  if not AppendToList then Self.Clear;
  //
  // IanB - function never returned a value - assuming the intention was to
  // return the count of the array...
  Result := High(aArray);
  for x := 0 to Result do
    Self.Add (aArray[x]);
end;

// Routine: IndexOfName
// Author: M.A.Sargent  Date: 09/08/17  Version: V1.0
//
// Notes:
//


{ tMASHashedStringList }

procedure tMASHashedStringList.Changed;
begin
  inherited Changed;
  FValueHashValid := False;
  FNameHashValid := False;
  fFound := False;
end;

procedure tMASHashedStringList.Clear;
begin
  inherited;
  fFound := False;
end;

destructor tMASHashedStringList.Destroy;
begin
  FValueHash.Free;
  FNameHash.Free;
  inherited Destroy;
end;

function tMASHashedStringList.IndexOf(const S: string): Integer;
begin
  UpdateValueHash;
  if not CaseSensitive then
    Result :=  FValueHash.ValueOf(AnsiUpperCase(S))
  else
    Result :=  FValueHash.ValueOf(S);
  //
  fFound := (Result <> -1);
end;

Function tMASHashedStringList.IndexOfName (Const Name: string): Integer;
begin
  UpdateNameHash;
  if not CaseSensitive then
    Result := FNameHash.ValueOf(AnsiUpperCase(Name))
  else
    Result := FNameHash.ValueOf(Name);
  //
  fFound := (Result <> -1);
end;

procedure tMASHashedStringList.UpdateNameHash;
var
  I: Integer;
  P: Integer;
  Key: string;
begin
  if FNameHashValid then Exit;

  if FNameHash = nil then
    FNameHash := TStringHash.Create
  else
    FNameHash.Clear;
  for I := 0 to Count - 1 do
  begin
    Key := Get(I);
    P := AnsiPos(NameValueSeparator, Key);
    if P <> 0 then
    begin
      if not CaseSensitive then
        Key := AnsiUpperCase(Copy(Key, 1, P - 1))
      else
        Key := Copy(Key, 1, P - 1);
      FNameHash.Add(Key, I);
    end;
  end;
  FNameHashValid := True;
end;

procedure tMASHashedStringList.UpdateValueHash;
var
  I: Integer;
begin
  if FValueHashValid then Exit;

  if FValueHash = nil then
    FValueHash := TStringHash.Create
  else
    FValueHash.Clear;
  for I := 0 to Count - 1 do
    if not CaseSensitive then
      FValueHash.Add(AnsiUpperCase(Self[I]), I)
    else
      FValueHash.Add(Self[I], I);
  FValueHashValid := True;
end;

end.
