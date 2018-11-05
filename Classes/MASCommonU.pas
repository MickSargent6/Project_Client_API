//
// Unit: MASCommonU
// Author: M.A.Sargent  Date: 19/05/2011  Version: V1.0
//         M.A.Sargent        19/11/2011           V2.0
//         M.A.Sargent        15/01/2012           V3.0
//         M.A.Sargent        29/04/2012           V4.0
//         M.A.Sargent        21/08/2012           V5.0
//         M.A.Sargent        24/09/2012           V6.0
//         M.A.Sargent        12/05/2013           V7.0
//         M.A.Sargent        17/02/2014           V8.0
//         M.A.Sargent        13/05/2015           V9.0
//         M.A.Sargent        13/06/2015           V10.0
//         M.A.Sargent        10/09/2015           V11.0
//         M.A.Sargent        21/10/2017           V12.0
//         M.A.Sargent        17/04/2018           V13.0
//         M.A.Sargent        11/06/2018           V14.0
//
// Notes:
//  V2.0: Add RestoreWindow
//  V3.0: Updated GetValuePair
//  V4.0: Add next functions UContainsText
//  V5.0: Add function LastPos
//  V6.0: Added function fnOccurrences
//  V7.0: Added function NPos
//  V8.0: Added Helper function fnFormatValuePair
//  V9:0: Add function fnIsIDE
// V10.0: Update NPos
// V11.0:
// V12.0: Add 2 versions of function IsEmpty
// V13.0: Added another version of fnAddValuePair
// V14.0: Added a new function IfEmpty
//
unit MASCommonU;

interface

Uses SysUtils, MASRecordStructuresU, StrUtils, Forms, Dialogs, DissectU, Controls,
      Graphics, DbCtrls, Windows, Messages, StdCtrls, TypInfo;

  Function IfTrue (aCondition: Boolean; aTrue, aFalse: String): String; overload;
  Function IfTrue (aCondition: Boolean; aTrue, aFalse: Integer): Integer; overload;
  Function IfTrue (aCondition: Boolean; aTrue, aFalse: Real): Real; overload;
  Function IfTrue (aCondition: Boolean; aTrue, aFalse: Variant): Variant; overload;
  //
  Procedure IfTrueDlg (Const aCondition: Boolean; aTrue, aFalse: String);
  //
  Function IfValue (Const aValue, aEqual1, Result1, aDefault: Variant): Variant; overload;
  Function IfValue (Const aValue, aEqual1, Result1, aEqual2, Result2, aDefault: Variant): Variant; overload;
  Function IfValue (Const aValue, aEqual1, Result1, aEqual2, Result2, aEqual3, Result3, aDefault: Variant): Variant; overload;
  Function IfValue (Const aValue, aEqual1, Result1, aEqual2, Result2, aEqual3, Result3, aEqual4, Result4, aDefault: Variant): Variant; overload;
  Function IfValue (Const aValue, aEqual1, Result1, aEqual2, Result2, aEqual3, Result3, aEqual4, Result4, aEqual5, Result5, aDefault: Variant): Variant; overload;
  //
  Function IfCase (Const aEqual1: Boolean; Const Result1: Variant; Const aEqual2: Boolean; Const Result2, aDefault: Variant): Variant;
  //
  Function fnFormatValuePair (Const aName, aValue: String): tValuePair;
  Function GetValuePair (Const aString: String): tValuePair;
  //
  Function fnAddValuePair (Const aName: String; Const aValue: Integer): String; overload;
  Function fnAddValuePair (Const aName, aValue: String): String; overload;
  //
  Function Pos2 (Const aSubStr, aString: String; Const aMustExist: Boolean = False): Integer;
  Function UPos (Const aSubStr, aString: String; Const aMustExist: Boolean = False): Integer;
  Function UPosEx (Const aSubStr, aString: String; Const OffSet: Integer; Const aMustExist: Boolean = False): Integer;
  // Function to Return the Position of the Last Sub String
  Function LastPos (Const aSubStr, aString: String; Const CaseInSensitive: Boolean = True): Integer;
  Function fnOccurrences (Const aSubtext: String; aText: String): Integer;
  Function NPos (Const aSubStr, aString: String; Const aIdx: Integer; Const CaseInSensitive: Boolean = True): Integer;
  //
  Function IsEqual (Const aName, aOther: String): Boolean;
  Function IsSame (Const aName, aOther: String): Boolean;
  //
  Function IsEmpty (Const aStr: String): Boolean; overload;
  Function IsEmpty (Const aStr: pChar): Boolean; overload;
  // if Empty then output Default
  Function IfEmpty (Const aStr, aDefault: String): String;

  Function fnStrPas (Const aStr: pChar): String;

  Function fnIntToBoolean (Const aInt: Integer): Boolean;
  Function fnBooleanToInt (Const aBool: Boolean): Integer;

  Function UContainsText (Const aSubStr, aString: String): Boolean;
  Function ContainsText (Const aSubStr, aString: String): Boolean;
  //
  function fnGetExeName (Const RemoveExt: Boolean = True): String;
  //
  Function MASDlg (Const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer; overload;
  Function MASDlg (Const aFormat: string; const Args: array of const; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer; overload;
  //
  Function StrArrayToStr (Const aArray: array of String): String;
  Function StrToArrayStr (Const aArray: String): tArrayString;

  //
  Procedure RestoreWindow (aWnd: tHandle);
  //
  Function fnIsIDE: Boolean;
  //
  //Function fnTypeInfoAsString (Const aTypeInfo: PTypeInfo; Const aValue: SmallInt): String;

  Function fnIfEnabled   (Const aValue: Boolean): String;
  Function fnIfTrue      (Const aValue: Boolean): String;
  Function fnIfLocked    (Const aValue: Boolean): String;
  Function fnIfOn        (Const aValue: Boolean): String;
  Function fnIfConnected (Const aValue: Boolean): String;
  Function fnIfStart     (Const aValue: Boolean): String;


implementation

Uses MASCommon_UtilsU;

// Routine:
// Author: M.A.Sargent  Date: //04  Version: V1.0
//
// Notes:
//
Function IfTrue (aCondition: Boolean; aTrue, aFalse: String): String;
begin
  if aCondition then
       Result := aTrue
  else Result := aFalse;
end;
Function IfTrue (aCondition: Boolean; aTrue, aFalse: Integer): Integer;
begin
  if aCondition then
       Result := aTrue
  else Result := aFalse;
end;
Function IfTrue (aCondition: Boolean; aTrue, aFalse: Real): Real;
begin
  if aCondition then
       Result := aTrue
  else Result := aFalse;
end;
Function IfTrue (aCondition: Boolean; aTrue, aFalse: Variant): Variant;
begin
  if aCondition then
       Result := aTrue
  else Result := aFalse;
end;

Procedure IfTrueDlg (Const aCondition: Boolean; aTrue, aFalse: String);
begin
  Case aCondition of
    True:  MASDlg (aTrue, mtInformation, [mbOK]);
    False: MASDlg (aFalse, mtInformation, [mbOK]);
  end;
end;

Function IfValue (Const aValue, aEqual1, Result1, aDefault: Variant): Variant; overload;
begin
  if IsEqual (aValue, aEqual1) then Result := Result1
  else Result := aDefault;
end;
Function IfValue (Const aValue, aEqual1, Result1, aEqual2, Result2, aDefault: Variant): Variant; overload;
begin
  if      IsEqual (aValue, aEqual1) then Result := Result1
  else if IsEqual (aValue, aEqual2) then Result := Result2
  else Result := aDefault;
end;
Function IfValue (Const aValue, aEqual1, Result1, aEqual2, Result2, aEqual3, Result3, aDefault: Variant): Variant; overload;
begin
  if      IsEqual (aValue, aEqual1) then Result := Result1
  else if IsEqual (aValue, aEqual2) then Result := Result2
  else if IsEqual (aValue, aEqual3) then Result := Result3
  else Result := aDefault;
end;
Function IfValue (Const aValue, aEqual1, Result1, aEqual2, Result2, aEqual3, Result3, aEqual4, Result4, aDefault: Variant): Variant; overload;
begin
  if      IsEqual (aValue, aEqual1) then Result := Result1
  else if IsEqual (aValue, aEqual2) then Result := Result2
  else if IsEqual (aValue, aEqual3) then Result := Result3
  else if IsEqual (aValue, aEqual4) then Result := Result4
  else Result := aDefault;
end;
Function IfValue (Const aValue, aEqual1, Result1, aEqual2, Result2, aEqual3, Result3, aEqual4, Result4, aEqual5, Result5, aDefault: Variant): Variant; overload;
begin
  if      IsEqual (aValue, aEqual1) then Result := Result1
  else if IsEqual (aValue, aEqual2) then Result := Result2
  else if IsEqual (aValue, aEqual3) then Result := Result3
  else if IsEqual (aValue, aEqual4) then Result := Result4
  else if IsEqual (aValue, aEqual5) then Result := Result5
  else Result := aDefault;
end;

// Routine: IfCase
// Author: M.A.Sargent  Date: 11/10/2018  Version: V1.0
//
// Notes:
//
Function IfCase (Const aEqual1: Boolean; Const Result1: Variant; Const aEqual2: Boolean; Const Result2, aDefault: Variant): Variant;
begin
  if      aEqual1 then Result := Result1
  else if aEqual2 then Result := Result2
  else Result := aDefault;
end;

// Routine: GetValuePair
// Author: M.A.Sargent  Date: ??/??/2004  Version: V1.0
//         M.A.Sargent        15/01/12             V2.0
//         M.A.Sargent        04/06/13             V3.0
//
// Notes:
//  V2.0:
//  V3.0: Updated to use new function
//
Function GetValuePair (Const aString: String): tValuePair;
begin
  Result := SplitAtDelimiter (aString, '=');
end;

// Routine: fnFormatValuePair
// Author: M.A.Sargent  Date: 17/02/14  Version: V1.0
//
// Notes:
//
Function fnFormatValuePair (Const aName, aValue: String): tValuePair;
begin
  Result.Name  := aName;
  Result.Value := aValue;
end;

// Routine: fnAddValuePair
// Author: M.A.Sargent  Date: 13/01/12  Version: V1.0
//
// Notes:
//
Function fnAddValuePair (Const aName: String; Const aValue: Integer): String;
begin
  Result := fnAddValuePair (aName, IntToStr (aValue));
end;
Function fnAddValuePair (Const aName, aValue: String): String;
begin
  Result := MASCommon_UtilsU.fnAddValuePair (aName, aValue);
end;

// Routine: Pos2, UPos, UPosEx
// Author: M.A.Sargent  Date: 02/11/05  Version: V1.0
//         M.A.Sargent        10/09/15           V2.0
//
// Notes:
//  V2.0: Updated to riase any exception if SubStr deoes not exist and aMustExist True (Default False)
//
Function Pos2 (Const aSubStr, aString: String; Const aMustExist: Boolean): Integer;
begin
  Result := Pos (aSubStr, aString);
  if aMustExist and (Result = 0) then Raise Exception.CreateFmt ('Error: Pos2. SubStr (%s) Not Found in aString', [aSubStr]);
end;
Function UPos (Const aSubStr, aString: String; Const aMustExist: Boolean): Integer;
begin
  Result := Pos2 (UpperCase (aSubStr), UpperCase (aString));
end;
Function UPosEx (Const aSubStr, aString: String; Const OffSet: Integer; Const aMustExist: Boolean): Integer;
begin
  Result := PosEx (UpperCase (aSubStr), UpperCase (aString), OffSet);
  if aMustExist and (Result = 0) then Raise Exception.CreateFmt ('Error: UPosEx. SubStr (%s) Not Found in aString', [aSubStr]);
end;

// Routine: NPos
// Author: M.A.Sargent  Date: 12/05/13  Version: V1.0
//         M.A.Sargent        13/06/15           V2.0
//
// Notes:
//
Function NPos (Const aSubStr, aString: String; Const aIdx: Integer; Const CaseInSensitive: Boolean = True): Integer;
var
  lvIdx: Integer;
  lvPos: Integer;
begin
  if (aIdx = 0) then raise Exception.Create ('Error: NPos. aIndex Must Greater Than 0');

  Result := 0;
  lvIdx  := 1;
  lvPos  := 0;
  Repeat
    Case CaseInSensitive of
      True: lvPos := UPosEx (aSubStr, aString, (lvPos+1));
      else  lvPos :=  PosEx (aSubStr, aString, (lvPos+1));
    end;
    if (lvPos <> 0) then begin
      if (aIdx = lvIdx) then begin
        Result := lvPos;
        Break;
      end;
    end
    else Break;
    lvIdx := (lvIdx+1);
  until False;
end;

// Routine: LastPos
// Author: M.A.Sargent  Date: 08/01/11  Version: V1.0
//         M.A.Sargent        21/08/12           V2.0
//
// Notes: Function to Return the Position of the Last Sub-String
//        0 if not Found
//  V2.0: Stop the copiler complaining
//
Function LastPos (Const aSubStr, aString: String; Const CaseInSensitive: Boolean = True): Integer;
var
  lvIdx: Integer;
  lvPos: Integer;
begin
  Result := 0;
  lvIdx  := 1;
  Repeat
    Case CaseInSensitive of
      True: lvPos := UPosEx (aSubStr, aString, lvIdx);
      else  lvPos :=  PosEx (aSubStr, aString, lvIdx);
    end;
    lvIdx := (lvIdx+1);
    if (lvPos<>0) then
         Result := lvPos
    else Break;
  until False;
end;

// Routine: fnOccurrences
// Author: M.A.Sargent  Date: 04/09/12  Version: V1.0
//
// Notes:
//
//Function fnOccurrences (Const aSubtext: string; aText: string; Const CaseInSensitive: Boolean = True): Integer;
Function fnOccurrences (Const aSubtext: String; aText: String): Integer;
var
  lvOffset: Integer;
begin
  if (Length (aSubtext) = 0) or (Length (aText) = 0) or (Pos (aSubtext, aText) = 0) then
    Result := 0
  else begin
    //Result := (Length (aText) - Length (StringReplace (aText, aSubtext, '', [rfReplaceAll]))) div Length (aSubtext);
    Result := 0;
    lvOffset := PosEx(aSubtext, aText, 1);
    while (lvOffset <> 0) do begin
      Inc (Result);
      lvOffset := PosEx(aSubtext, aText, lvOffset + length(aSubtext));
    end;
  end;
end;

// Routine: IsEqual
// Author: M.A.Sargent  Date: 11/06/18  Version: V1.0
//
// Notes:
//
Function IsEqual (Const aName, aOther: String): Boolean;
begin
  Result := (AnsiCompareText (aName, aOther) = 0);
end;
Function IsSame (Const aName, aOther: String): Boolean;
begin
  Result := (AnsiCompareStr (aName, aOther) = 0);
end;
Function IsEmpty (Const aStr: String): Boolean;
begin
  Result := (aStr = '');
end;
Function IsEmpty (Const aStr: pChar): Boolean;
begin
//  Result := (Length (aStr) <> 0);
  try
    Result := (aStr = nil) or (aStr^ = #0);
  except
   Result := True;
  end;
end;
Function IfEmpty (Const aStr, aDefault: String): String;
begin
  Result := IfTrue (not IsEmpty (aStr), aStr, aDefault);
end;

// Routine: fnStrPas
// Author: M.A.Sargent  Date: 11/06/18  Version: V1.0
//
// Notes:
//
Function fnStrPas (Const aStr: pChar): String;
begin
  Result := '';
  if not IsEmpty (aStr) then Result := StrPas (aStr);
end;

// Routine: UContainsText and ContainsText
// Author: M.A.Sargent  Date: 29/04/12  Version: V1.0
//
// Notes:
//
Function fnIntToBoolean (Const aInt: Integer): Boolean;
begin
  Result := StrToBool (IntToStr (aInt));
end;
Function fnBooleanToInt (Const aBool: Boolean): Integer;
begin
  Result := StrToInt (BoolToStr (aBool));
end;

// Routine: UContainsText and ContainsText
// Author: M.A.Sargent  Date: 29/04/12  Version: V1.0
//
// Notes:
//
Function UContainsText (Const aSubStr, aString: String): Boolean;
begin
  Result := AnsiContainsText (aString, aSubStr);
end;
Function ContainsText (Const aSubStr, aString: String): Boolean;
begin
  Result := AnsiContainsStr (aString, aSubStr);
end;

// Routine: fnGetExeName
// Author: M.A.Sargent  Date: 01/11/06  Version: V1.0
//
// Notes:
//
function fnGetExeName (Const RemoveExt: Boolean = True): String;
begin
  Result := ExtractFileName (Application.ExeName);        {Get Exe Name}
  if RemoveExt then
    Result := ChangeFileExt (Result, '');                 {Remove the Extention}
end;

// Routine: fnGetExeName
// Author: M.A.Sargent  Date: 01/11/06  Version: V1.0
//
// Notes:
//
Function MASDlg (Const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
begin
  Result := MessageDlg (Msg, DlgType, Buttons, 0);
end;
Function MASDlg (Const aFormat: string; const Args: array of const; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
begin
  Result := MASDlg (Format (aFormat, Args), DlgType, Buttons);
end;

// Routine: StrArrayToStr
// Author: M.A.Sargent  Date: 21/11/06  Version: V1.0
//
// Notes:
//
Function StrArrayToStr (Const aArray: array of String): String;
var
  x: Integer;
begin
  Result := '';
  for x := 0 to High (aArray) do
    Result := (Result + aArray [x]);
end;

// Routine: StrToArrayStr
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//
// Notes:
//
Function StrToArrayStr (Const aArray: String): tArrayString;
var
  x: Integer;
  lvStr: String;
begin
  for x := 0 to 999 do begin
    lvStr := '';
    if not GetField (aArray, ',', x, lvStr) then Break;
    SetLength (Result, (x+1));
    Result[x] := lvStr;
  end;
end;

// Routine:
// Author: M.A.Sargent  Date: 01/11/11  Version: V1.0
//
// Notes:
//
Procedure RestoreWindow (aWnd: tHandle);
begin
  if (aWnd <> 0) and IsWindow(aWnd) then begin
    SetForeGroundWindow(aWnd);
    if IsIconic(aWnd) then
         PostMessage (aWnd, WM_SYSCOMMAND, SC_RESTORE, 0)
    else ShowWindow (aWnd, SW_SHOW);
  end;
end;

// Routine: fnIsIDE
// Author: M.A.Sargent  Date: 15/05/15  Version: V1.0
//
// Notes:
//
Function fnIsIDE: Boolean;
begin
  Result := (DebugHook > 0);
end;

// Routine: fnTypeInfoAsString
// Author: M.A.Sargent  Date: 29/03/18  Version: V1.0
//
// Notes:
//
{Function fnTypeInfoAsString (Const aTypeInfo: PTypeInfo; Const aValue: SmallInt): String;
begin
  Result := GetEnumName (aTypeInfo, aValue);
end;}

// Routine: fnIfEnabled, fnIfTrue, fnIfLocked & fnIfOn
// Author: M.A.Sargent  Date: 11/07/18  Version: V1.0
//
// Notes:
//
Function fnIfEnabled (Const aValue: Boolean): String;
begin
  Result := IfTrue (aValue, 'Enabled', 'Disabled');
end;
Function fnIfTrue (Const aValue: Boolean): String;
begin
  Result := IfTrue (aValue, 'True', 'False');
end;
Function fnIfLocked (Const aValue: Boolean): String;
begin
  Result := IfTrue (aValue, 'Locked', 'UnLocked');
end;
Function fnIfOn (Const aValue: Boolean): String;
begin
  Result := IfTrue (aValue, 'On', 'Off');
end;
Function fnIfConnected (Const aValue: Boolean): String;
begin
  Result := IfTrue (aValue, 'Connected', 'DisConnected');
end;
Function fnIfStart (Const aValue: Boolean): String;
begin
  Result := IfTrue (aValue, 'Start', 'Stop');
end;

end.
