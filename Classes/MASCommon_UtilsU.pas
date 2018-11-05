//
// Unit: MASCommon_UtilsU
// Author: M.A.Sargent  Date: 04/07/11  Version: V1.0
//         M.A.Sargent        13/10/11           V2.0
//         M.A.Sargent        13/01/12           V3.0
//         M.A.Sargent        25/02/12           V4.0
//         M.A.Sargent        10/10/12           V5.0
//         M.A.Sargent        05/06/14           V6.0
//         M.A.Sargent        10/02/15           V7.0
//         M.A.Sargent        14/03/18           V8.0
//         M.A.Sargent        31/07/18           V9.0
//         M.A.Sargent        02/08/18           V10.0
//         M.A.Sargent        04/08/18           V11.0
//         M.A.Sargent        05/08/18           V12.0
//         M.A.Sargent        06/08/18           V13.0
//         M.A.Sargent        14/08/18           V14.0
//
// Notes:
//  V2.0: LPad, and RPad
//  V3.0: Added fnAddValuePair
//  V4.0: Add Function AvgeCharWidth
//  V5.0: Add function GetEnvVarValue
//  V6.0: Add function fnAppendStrings
//  V7.0: Updated InitCaps
//  V8.0: Updated to add functions fnBetweenTwoDelimiters
//  V9.0: Added function fnAsPercentage
// V10.0: Fix bug in fnBetweenTwoDelimiters
// V11.0: Time Systems UK Update
// V12.0: Add function fnDeQuoteString
// V13.0: Add function fnOutputElapsedDays
// V14.0: Add another version of fnOutputElapsedDays
//
unit MASCommon_UtilsU;

interface

Uses Controls, MAS_DirectoryU, SysUtils, Types, Windows, MASCommonU, Forms, MASRecordStructuresU,
      Graphics, StdCtrls, Classes;

  Function fnTopLevelParent (aControl: tControl): tControl;
  //
  Function fnFound (Const aArray: Array of String; Const aMsg: String): Boolean;
  //
  Function fnGetFormFromControl (aControl: tControl): tForm;
  //
  Function LPad  (Const S: string; NewLength: Integer): string;
  Function LPad2 (Const S: string; NewLength: Integer; PadChar: Char = ' '): string;
  Function RPad  (Const S: string; NewLength: Integer): string;
  Function RPad2 (Const S: string; NewLength: Integer; PadChar: Char = ' '): string;
  //
  Function SplitAtDelimiter (Const aString: String; Const aChar: Char): tValuePair;

  Function fnAddValuePair    (Const aName, aValue: String): String;
  Function fnAddValuePairInt (Const aName: String; Const aValue: Integer): String;
  //
  //
  Function FreeRegardLess (var Obj): Boolean;
  //
   Function AvgeCharWidth (Const aFont: tFont): Integer; overload;
  Function AvgeCharWidth (Const aText: String; Const aFont: tFont): Integer; overload;

  {Function to uppercase the First Character of a string and to lowercase the remainder}
  Function InitCaps (Const aString: String): String;
  //
  Function GetEnvVarValue (Const VarName: string): string;
  //
  Function fnAppendStrings (Const aDelimiter: Char; aPath, aNew: String): String;
  //
  Function fnLogSystemStartUp (Const aIdentifier: String): tOKStrRec;
  Procedure fnLogSystemShutDown (Const aIdentifier: String);

  Function fnAsPercentage (Const aSoFar, aTotal: Integer): Integer;
  //
  Function fnCopyFromLocation (Const aIdent, aStr: String; Const aIncludeIdent: Boolean; Const aRaiseIfNotFound: Boolean = True): String;
  Function fnCopyUntilLocation (Const aIdent, aStr: String; Const aIncludeIdent: Boolean; Const aRaiseIfNotFound: Boolean = True): String;

  Function fnBetweenTwoDelimiters  (Const aStr: String; Const aDelimiter: Char): tOKStrRec; overload;
  Function fnBetweenTwoDelimiters2 (Const aStr: String; Const aDelimiter: Char): String; overload;
  Function fnBetweenTwoDelimiters  (Const aStr: String; Const aStartDelimit, aEndDelimit: Char): tOKStrRec; overload;
  Function fnBetweenTwoDelimiters2 (Const aStr: String; Const aStartDelimit, aEndDelimit: Char): String; overload;
  Function fnBetweenTwoDelimiters  (aStr: String; Const aOffSet: Integer; Const aStartDelimit, aEndDelimit: Char): tOKStrRec; overload;
  Function fnBetweenTwoDelimiters2 (aStr: String; Const aOffSet: Integer; Const aStartDelimit, aEndDelimit: String): tOKStrRec; overload;

  //
  Function fnDeQuoteString (Const aStr: string): String;
  //
  Function fnOutputElapsedDays (Const aStartDate: tDateTime; Const aAddSeconds: Boolean = False): String; overload;
  Function fnOutputElapsedDays (Const aSeconds: Integer): String; overload;
  //
implementation

Uses MASRegistry, MAS_FormatU, MAS_ConstsU, FormatResultU;

// Routine: fnTopLevelParent
// Author: M.A.Sargent  Date: 17/01/11  Version: V1.0
//
// Notes:
//
Function fnTopLevelParent (aControl: tControl): tControl;
begin
  Result := Nil;
  if Assigned (aControl) then begin
    if Assigned (aControl.Parent) then
      Result := fnTopLevelParent (aControl.Parent)
    else Result := aControl;
  end;
end;

// Routine: fnFound
// Author: M.A.Sargent  Date: 04/07/11  Version: V1.0
//
// Notes:
//
Function fnFound (Const aArray: Array of String; Const aMsg: String): Boolean;
var x: Integer;
begin
  Result := False;
  for x := 0 to High (aArray) do begin
    Result := IsEqual (aMsg, aArray [x]);
    if Result then Exit;
  end;
end;

// Routine: fnGetFormFromControl
// Author: M.A.Sargent  Date: 12/07/11  Version: V1.0
//
// Notes:
//
Function fnGetFormFromControl (aControl: tControl): tForm;
begin
  Result := Nil;
  if Assigned (aControl) and Assigned (aControl.Parent) then
    if aControl.Parent is tForm then
         Result := tForm (aControl.Parent)
    else Result := fnGetFormFromControl (aControl.Parent);
end;

// Routine: LPad, and RPad
// Author: M.A.Sargent  Date: 13/10/11  Version: V1.0
//
// Notes:
//
Function LPad (Const S: string; NewLength: Integer): string;
begin
  Result := LPad2 (S, NewLength, ' ');
end;
Function LPad2 (Const S: string; NewLength: Integer; PadChar: Char): string;
begin
  Result := S;
  while Length(Result) < NewLength do
    Result := PadChar + Result;
end; // LPad()
Function RPad (Const S: string; NewLength: Integer): string;
begin
  Result := RPad2 (S, NewLength, ' ');
end;
Function RPad2 (Const S: string; NewLength: Integer; PadChar: Char): string;
begin
  Result := S;
  while Length(Result) < NewLength do
    Result := Result  + PadChar;
end; // RPad()


// Routine:
// Author: M.A.Sargent  Date: 28/06/12  Version: V1.0
//         M.A.Sargent        13/11/14           V2.0
//
// Notes:
//  V2.0: Bug proof, 999999999 and not 999
//
Function SplitAtDelimiter (Const aString: String; Const aChar: Char): tValuePair;
var
  lvPos: Integer;
begin
  Result.Value := '';
  //
  lvPos := Pos (aChar, aString);
  Case (lvPos=0) of
    True: Result.Name := aString;
    else begin
      Result.Name  := Copy (aString, 1, (lvPos-1));
      Result.Value := Copy (aString, (lvPos+1), 999999999);
    end;
  end;
end;

// Routine: fnAddValuePair
// Author: M.A.Sargent  Date: 13/01/12  Version: V1.0
//
// Notes:
//
Function fnAddValuePair (Const aName, aValue: String): String;
begin
  Result := fnTS_Format ('%s=%s', [Trim (aName), Trim(aValue)]);
end;
Function fnAddValuePairInt (Const aName: String; Const aValue: Integer): String;
begin
  Result := fnAddValuePair (aName, IntToStr (aValue));
end;

// Routine: fnGenerateCRC
// Author: M.A.Sargent  Date: 21/03/06  Version: V1.0
//
// Notes:
//
{function fnGenerateCRC (Const aString: String): LongWord;
var
  s: String;
  CRC32Text: LongWord;
begin
  s := aString;                   // Move to a string
  CRC32Text := $FFFFFFFF;         // To match PKZIP
  if (Length (s) > 0) then        // Avoid access violation in D4
    CalcCRC32 (Addr(s[1]), Length(s), CRC32Text);
  CRC32Text := not CRC32Text;     // To match PKZIP
  Result := CRC32Text;            // Return the Result
end;

// Routine: fnGenerateCRCFromFile
// Author: M.A.Sargent  Date: 06/05/12  Version: V1.0
//
// Notes:
//
Function fnGenerateCRCFromFile (Const aFileName: String): LongWord;
var
  lvCRCFile: tStringList;
begin
  lvCRCFile := tStringList.Create;
  Try
    lvCRCFile.LoadFromFile (aFileName);
    Result := fnGenerateCRC (lvCRCFile.Text);
  Finally
    lvCRCFile.Free;
  end;
end;}

// Routine: FreeRegardLess
// Author: M.A.Sargent  Date: 14/03/12  Version: V1.0
//
// Notes:
//
Function FreeRegardLess (var Obj): Boolean;
begin
  Result := True;   // Just Squash Exception
  Try
    FreeAndNil (Obj);
  Except
    Result := False;   // Just Squash Exception
  end;
end;

// Routine: AvgeCharWidth
// Author: M.A.Sargent  Date: 15/09/04  Version: V1.0
//
// Notes: Routine to calulate the average character width using text supplied to
//        the function. The long the text the more accurate the returned value
//
Function AvgeCharWidth (Const aFont: tFont): Integer;
begin
  Result := AvgeCharWidth ('The Quick Brown Fox Jumped of the Lazy Dog, 1234567890 !"£$%^&*(){}#[]@~></?\', aFont);
end;
Function AvgeCharWidth (Const aText: String; Const aFont: tFont): Integer;
var
  lvLabel: tLabel;
begin
  lvLabel := tLabel.Create (Nil);
  Try
    lvLabel.Font := aFont;
    lvLabel.Caption := aText;
    Result := Round (lvLabel.Width / Length (aText)) + 1;
  Finally
    lvLabel.Free;
  End;
end;

// Routine: InitCaps
// Author: M.A.Sargent  Date: 14/03/12  Version: V1.0
//         M.A.Sargent        10/02/15           V2.0
//
// Notes: Function to uppercase the First Character of a string and to
//        lowercase the remainder
//  V2.0: Updated to tet for an empty string
//
Function InitCaps (Const aString: String): String;
Begin
  Result:= AnsiLowerCase (aString);
  if (Result <> '') then
    CharUpperBuff( @Result[1], 1 );
end;

// Routine: GetEnvVarValue
// Author: M.A.Sargent  Date: 10/10/12  Version: V1.0
//
// Notes:
//
Function GetEnvVarValue (Const VarName: string): string;
var
  BufSize: Integer;  // buffer size required for value
begin
  // Get required buffer size (inc. terminal #0)
  BufSize := GetEnvironmentVariable (PChar(VarName), nil, 0);
  if BufSize > 0 then begin
    // Read env var value into result string
    SetLength(Result, BufSize - 1);
    GetEnvironmentVariable(PChar(VarName), PChar(Result), BufSize);
  end
  // No such environment variable
  else Result := '';
end;

// Routine: fnAppendStrings
// Author: M.A.Sargent  Date: 10/03/13  Version: V1.0
//
// Notes:
//
Function fnAppendStrings (Const aDelimiter: Char; aPath, aNew: String): String;
begin
  aPath := Trim (aPath);
  aNew  := Trim (aNew);
  if (aNew = '') then begin
    Result := aPath;
  end else begin
    // if the last character is a '\' then
    // append aNew
    if (Copy (aPath, Length(aPath), 1) = aDelimiter) then begin
      if (Copy(aNew, 1, 1) = aDelimiter) then
           Result := aPath + Copy(aNew, 2, Length(aNew)-1)
      else Result := aPath + aNew;
    end
    else begin
      if (Copy(aNew, 1, 1) = aDelimiter) then
           Result := aPath + aNew
      else begin
        if (aPath<>'') then                 // if Path is not Null then As Before
             Result := aPath + aDelimiter + aNew   // Do as Before
        else Result := aNew;                // Just Append the aNew value
      end;
    end;
  end;
end;

// Routine: GetEnvVarValue
// Author: M.A.Sargent  Date: 10/10/12  Version: V1.0
//
// Notes:
//
Function fnLogSystemStartUp (Const aIdentifier: String): tOKStrRec;
var
  lvReg: tMASRegistry;
begin
  lvReg := tMASRegistry.Create;
  Try
    Result.OK := not lvReg.RegGetBoolean_CAK (aIdentifier, 'InitApp', 'SystemRunning', False);
    // Only Set if OK else it will already be True
    Case Result.OK of
      True: lvReg.RegSetBoolean_CAK (aIdentifier, 'InitApp', 'SystemRunning', True);
      else  Result.Msg := 'System Was NOT Shutdown Correctly Last Time';
    end;
  Finally
    lvReg.Free;
  End;
end;

Procedure fnLogSystemShutDown (Const aIdentifier: String);
var
  lvReg: tMASRegistry;
begin
  lvReg := tMASRegistry.Create;
  Try
    lvReg.RegSetBoolean_CAK (aIdentifier, 'InitApp', 'SystemRunning', False);
  Finally
    lvReg.Free;
  End;
end;


// Routine: fnAsPercentage
// Author: M.A.Sargent  Date: 28/07/15  Version: V1.0
//
// Notes:
//
Function fnAsPercentage (Const aSoFar, aTotal: Integer): Integer;
begin
  Result := Round (((aSoFar * 100) / aTotal));
end;

// Routine: fnCopyFromLocation & fnCopyUntilLocation
// Author: M.A.Sargent  Date: 07/10/15  Version: V1.0
//
// Notes:
//
Function fnCopyFromLocation (Const aIdent, aStr: String; Const aIncludeIdent: Boolean; Const aRaiseIfNotFound: Boolean): String;
var
  lvPos: Integer;
begin
  //
  Result := '';
  lvPos := UPos (aIdent, aStr);
  if (lvPos > 0) then begin
    Case aIncludeIdent of
      True: Result := Copy (aStr, lvPos, MaxInt);
      else  Result := Copy (aStr, (lvPos + (Length (aIdent))), MaxInt);
    end;
  end else if aRaiseIfNotFound then Raise Exception.CreateFmt ('Error: fnCopyFromLocation. SubStr Not Found (%s)', [aIdent]);
end;

Function fnCopyUntilLocation (Const aIdent, aStr: String; Const aIncludeIdent: Boolean; Const aRaiseIfNotFound: Boolean): String;
var
  lvPos: Integer;
begin
  //
  Result := '';
  lvPos := UPos (aIdent, aStr);
  if (lvPos > 0) then begin
    Case aIncludeIdent of
      True: Result := Copy (aStr, 1, ((lvPos-1) + Length (aIdent)));
      else  Result := Copy (aStr, 1, (lvPos-1));
    end;
  end else if aRaiseIfNotFound then Raise Exception.CreateFmt ('Error: fnCopyUntilLocation. SubStr Not Found (%s)', [aIdent]);
end;

// Routine: fnBetweenTwoDelimiters
// Author: M.A.Sargent  Date: 30/03/17  Version: V1.0
//
// Notes:
//  V2.0: Updated to fix bug, if delimiter the same did not work
//
Function fnBetweenTwoDelimiters (Const aStr: String; Const aDelimiter: Char): tOKStrRec;
begin
  Result := fnBetweenTwoDelimiters (aStr, aDelimiter, aDelimiter);
end;
Function fnBetweenTwoDelimiters2 (Const aStr: String; Const aStartDelimit, aEndDelimit: Char): String;
begin
  Result := fnBetweenTwoDelimiters (aStr, aStartDelimit, aEndDelimit).Msg;
end;
Function fnBetweenTwoDelimiters2 (Const aStr: String; Const aDelimiter: Char): String;
begin
  Result := fnBetweenTwoDelimiters (aStr, aDelimiter, aDelimiter).Msg;
end;
Function fnBetweenTwoDelimiters (Const aStr: String; Const aStartDelimit, aEndDelimit: Char): tOKStrRec;
begin
  Result := fnBetweenTwoDelimiters (aStr, 1, aStartDelimit, aEndDelimit);
end;
Function fnBetweenTwoDelimiters (aStr: String; Const aOffSet: Integer; Const aStartDelimit, aEndDelimit: Char): tOKStrRec;
begin
  Result := fnBetweenTwoDelimiters (aStr, aOffSet, aStartDelimit, aEndDelimit);
end;
Function fnBetweenTwoDelimiters2 (aStr: String; Const aOffSet: Integer; Const aStartDelimit, aEndDelimit: String): tOKStrRec;
var
  lvPos: Integer;
  lvPosEnd: Integer;
  lvPosNext: Integer;
  lvSameDelimiter: Boolean;
begin
  lvPosNext := 0;
  Result    := fnClear_OKStrRec;
  // if same use updates code, else as before                    //
  lvSameDelimiter := IsEqual (aStartDelimit, aEndDelimit);       //
  //                                                             //
  Result.OK := (aOffSet > 0);                                    //
  if Result.OK then begin                                        //
    aStr := Copy (aStr, aOffSet, MaxInt);                        //
                                                                 //
    lvPos := UPos (aStartDelimit, aStr);                         // get start pos
    lvPos := (lvPos + Length (aStartDelimit) - 1);               //
                                                                 //
    Case lvSameDelimiter of                                      //
      True: lvPosEnd  := UPosEx (aEndDelimit, aStr, (lvPos+1));   // get end pos
      else begin                                                 //
            lvPosEnd  := UPos   (aEndDelimit, aStr);             // get end pos
            lvPosNext := UPosEx (aStartDelimit, aStr, (lvPos+1));// get next start pos
      end;                                                       //
    end;                                                         //

    // both should > 0 and end must be great than start
    Result.OK := ((lvPos > 0) and (lvPosEnd > 0) and ((lvPosEnd - lvPos) >= 1));
    if Result.OK then begin
      //
      Case lvSameDelimiter of
        True: Result.OK := (lvPos < lvPosEnd);
        else  Result.OK := ((lvPosNext = 0) or (lvPosNext > lvPosEnd));
      end;
      //
      if Result.OK then begin
        Result.Msg := Copy (aStr, (lvPos+1), (lvPosEnd - (lvPos+1)));
      end;
    end;
  end;
  if not Result.OK then Result.Msg := '';
end;

// Routine: fnDeQuoteString
// Author: M.A.Sargent  Date: 10/10/12  Version: V1.0
//
// Notes: Added wrapper function, D7 (not sure about other) but "" returned "" so not dequoted
//
Function fnDeQuoteString (Const aStr: string): String;
begin
  Case (aStr = '""') of
    True: Result := '';
    else  Result := AnsiDequotedStr (aStr, '"');
  end;
end;

// Routine: fnOutputElapsedDays
// Author: M.A.Sargent  Date: 02/08/18  Version: V1.0
//
// Notes:
//
Function fnOutputElapsedDays (Const aStartDate: tDateTime; Const aAddSeconds: Boolean): String;
var
  lvDelta: TDateTime;
  Days, Hour, Min, Sec, MSec: Word;
begin
  lvDelta := (Now - aStartDate);
  Days := Trunc (lvDelta);
  DecodeTime (lvDelta, Hour, Min, Sec, MSec);
  Result := (IntToStr(Days) + ' day(s), ' + IntToStr(Hour) + ' hour(s), ' + IntToStr(Min) + ' minute(s)');
  if aAddSeconds then
    Result := (', ' + IntToStr (Sec) + 'seconds(s)');
end;

Function fnOutputElapsedDays (Const aSeconds: Integer): String;
var
  lvDelta: TDateTime;
  Days, Hour, Min, Sec, MSec: Word;
  lvResult: String;
  //
  Function Int_Add (Const aStr: String): String;
  begin
    //
    Case IsEmpty (lvResult) of
      True: Result := aStr;
      else  Result := (lvResult + ', ' + aStr);
    end;
  end;
begin
  //
  lvDelta := (aSeconds / cMC_DAY_IN_SECONDS);
  Days := Trunc (lvDelta);
  DecodeTime (lvDelta, Hour, Min, Sec, MSec);
  // Format output
  lvResult := '';
  if (Days <> 0) then lvResult := Int_Add ((IntToStr (Days) + ' day(s)'));
  if (Hour <> 0) then lvResult := Int_Add ((IntToStr (Hour) + ' hour(s)'));
  if (Min  <> 0) then lvResult := Int_Add ((IntToStr (Min)  + ' minute(s)'));
  if (Sec  <> 0) then lvResult := Int_Add ((IntToStr (Sec)  + ' seconds(s)'));
  Result := lvResult;
end;

end.
