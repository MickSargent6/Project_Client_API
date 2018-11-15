//
// Unit: MASDatesU
// Author: M.A.Sargent  Date: 25/10/06  Version: V1.0
//         M.A.Sargent        20/10/12           V2.0
//         M.A.Sargent        21/09/14           V3.0
//         M.A.Sargent        23/10/13           V4.0
//         M.A.Sargent        17/07/14           V5.0
//         M.A.Sargent        05/03/15           V6.0
//         M.A.Sargent        05/03/15           V7.0
//         M.A.Sargent        13/05/18           V8.0
//         M.A.Sargent        02/08/18           V9.0
//
// Notes: Functions fnStrToDate to convert a string date/datetime into a date tvariable
//  V2.0: Add sDDMMYYYY_HHMMSS
//  V3.0: Updated to (hopefully) ThreadSafe routines
//  V4.0: Add Function fnDateHasChange
//  V5.0: add a thread safe version of fnTS_TimeToStr
//  V6.0: Added a new format sYYYYMMDD_HHMMSS
//  V7.0: Add time format types
//  V8.0: Updated to remove FormatSettings in fnStrToDate
//  V9.0: Updated to fix bug and add another method
//
unit MASDatesU;

Interface

Uses SysUtils, MASRecordStructuresU, Controls, Windows, MAS_LocalityU, MAS_ConstsU;

Type
  //
  tStringDates = (sdNone, sdHHMMSS, sdHHMM,
                   sdDDMMYY, sdDDMMYYYY, sdDDMMMYY, sdDDMMMYYYY, sdMM, sdMMM,
                    sdDDMMYYYY_HHMMSS, sdDDMMYY_HHMMSS, sdDDMMYYYY_HHMM, sdDDMMYY_HHMM,
                     // The two below are NOT Localized
                      sdYYYYMMDD_HHMMSS, sdYYYYMMDD_HHMM);
  //
  Function fnLocalisedDate (Const aFormat: tStringDates; Const aRemoveSeparators: Boolean = True): String;


  //tDateFormat = (dfShortDate, dfLongDate, dfShortDateTime, dfLongDateTime);
  // just add other formats as needed

  // function to voncert a date in text to a tDateTime variable
//  Function fnStrToDate (Const aDateStr: String; Const aStringDates: tStringDates): tDateTime; overload;
  Function fnStrToDate (Const aDateStr: String; aFormatStr: String = 'DD-MM-YYYY'): tDateTime; overload;

//  Function fnStringDatestoString (Const aStringDates: tStringDates): String;
  //
  Function fnDecodeDate: tDateParts; overload;
  Function fnDecodeDate (aDateTime: tDateTime): tDateParts; overload;
  //
  Function fnTryStrToDateTime (aStr: String; var aDateTime: tDateTime): Boolean;
  Function fnTryStrToDate (aStr: String; var aDateTime: tDateTime): Boolean;
  //
  //
  //
  Function fnTS_StrToDate        (Const aString: String): tDate;
  Function fnTS_StrToDateTime    (Const aString: String): tDatetime;
  Function fnTS_StrToTime        (Const aString: String): tDatetime;
  //
  Function fnTS_StrToDateDef     (Const aString: String; Const Default: TDateTime): tDate;
  Function fnTS_StrToDateTimeDef (Const aString: String; Const Default: TDateTime): tDatetime;
  Function fnTS_StrToTimeDef     (Const aString: String; Const Default: TDateTime): tDateTime;
  //
  Function fnTS_DateTimeToStr    (Const aDateTime: tDateTime): String;
  Function fnTS_TimeToStr        (Const aTime: tTime): String;
  //
  Function fnTS_DateTimeToNoneLocalizedFormat  (Const aDateTime: tDateTime): String;
  Function fnTS_NoneLocalizedFormatToDateTime  (Const aDateTime: String): tDateTime;
  Function fnTS_NoneLocalizedFormatToDateTime2 (Const aDateTime: String): tOKDateRec;

  Function fnTS_TryStrToDateTime (aStr: String; var aDateTime: tDateTime): Boolean;

  //
//  Function fnTS_FormatTime (Const aDateTime: tDateTime; Const aStringDates: tStringDates = sdHHMMSS): String; overload;

//  Function fnTS_FormatDateTime (Const aDateTime: tDateTime; Const aStringDates: tStringDates = sDDMMYYYY_HHMMSS): String; overload;

  Function fnTS_FormatDateTime (Const aFormat: tStringDates; Const aDateTime: tDateTime): String; overload;
  Function fnTS_FormatDateTime (Const aFormat: string; Const aDateTime: tDateTime): String; overload;
  //
  Function fnDateHasChange: Boolean;

  // Function to add st, nd, td or th to the day
  Function fnDayStr (Const aDay: Word): String; overload;
  Function fnDayStr (Const aDate: TDate): String; overload;
  //
  Function fnIsAM    (Const aDate: TDateTime): Boolean;

implementation

Uses MASCommonU, DateUtils, TypInfo;

var
  gblDateToday: tDate = 0;

Function fnLocalisedDate (Const aFormat: tStringDates; Const aRemoveSeparators: Boolean): String;
var
 lvFormat: tFormatSettings;
begin
  Try
    lvFormat := fnTS_LocaleSettings;
    Case aFormat of
      sdNone:;
      sdHHMMSS:          Result := lvFormat.LongTimeFormat;
      sdHHMM:            Result := lvFormat.ShortTimeFormat;
      sdDDMMYY:          Result := lvFormat.ShortDateFormat;
      sdDDMMYYYY:        Result := lvFormat.ShortDateFormat;
      sdDDMMMYY:         Result := lvFormat.LongDateFormat;
      sdDDMMMYYYY:       Result := lvFormat.LongDateFormat;
      sdDDMMYYYY_HHMMSS: Result := lvFormat.ShortDateFormat + '_' + lvFormat.LongTimeFormat;
      sdDDMMYY_HHMMSS:   Result := lvFormat.ShortDateFormat + '_' + lvFormat.LongTimeFormat;
      sdDDMMYYYY_HHMM:   Result := lvFormat.ShortDateFormat + '_' + lvFormat.ShortTimeFormat;
      sdDDMMYY_HHMM:     Result := lvFormat.ShortDateFormat + '_' + lvFormat.ShortTimeFormat;
      // Month Only
      sdMM:              Result := 'MM';
      sdMMM:             Result := 'MMM';
      // Do Not Localize
      sdYYYYMMDD_HHMM:   Result := cDATETIME_NON_NOT_LOCALISED;
      sdYYYYMMDD_HHMMSS: Result := cDATETIME_NON_NOT_LOCALISED_SS;
      else Raise Exception.CreateFmt ('Error: fnLocalisedDate. Unknown Type passed to Routine. (%s)', [GetEnumName (TypeInfo (tStringDates), Integer (aFormat))]);
    end;
    //
    if aRemoveSeparators then begin
      Result := StringReplace (Result, lvFormat.TimeSeparator, '', [rfReplaceAll]);
      Result := StringReplace (Result, lvFormat.DateSeparator, '', [rfReplaceAll]);
    end;
    //
    Case aFormat of
      sdDDMMYY, sdDDMMMYY, sdDDMMYY_HHMMSS, sdDDMMYY_HHMM: Result := StringReplace (Result, 'YYYY', 'YY', [rfIgnoreCase]);
    End;
  Except
    Raise;
  End;
end;

Function fnLocalisedTime: String;
begin
end;

// Routine: fnStrToDate
// Author: M.A.Sargent  Date: 25/10/06  Version: V1.0
//
// Notes:
//
{Function fnStrToDate (Const aDateStr: String; Const aStringDates: tStringDates): tDateTime;
begin
  Result := fnStrToDate (aDateStr, fnStringDatestoString (aStringDates));
end;}

// Routine: fnStrToDate
// Author: M.A.Sargent  Date: 10/10/06  Version: V1.0
//
// Notes:
//   Format Decoded so far  YY = 05, YYYY = 2005 year, default Epoch gblEPOCH (50)
//                          MM = 12, MMM  = Short Month
//                          DD = 01
//                          HH = 12 Hours
//                          NN = 24 Minutes
//                          SS = 12 Seconds
//                          Z = 1, ZZ = 2, ZZZ = 3 MiliiSeconds
//
Function fnStrToDate (Const aDateStr: String; aFormatStr: String = 'DD-MM-YYYY'): tDateTime;
Type
  tSomeInts = set of 1..4;
var
  YR, Mth, Day, HR, Min, Sec, Ms: Word;
  lvFormat: tFormatSettings;
  //
  Function fnExtract (Const aChar: Char; Const aValidLength: tSomeInts): Word;
  var
    lvPos: Integer;
    x: Integer;
    lvLength: Integer;
    lvMonth: String;

  begin
    Result   := 0;
    lvLength := 0;
    lvPos := UPos (aChar, aFormatStr);
    if (lvPos > 0) then begin
      for x := 1 to ((Length (aFormatStr)-lvPos)+1) do begin
        if not IsEqual (aFormatStr [lvPos + x], aChar) then
          Break;
        lvLength := x;
      end;
      Inc (lvLength);
      //
      if (lvLength > 0) and not (lvLength in aValidLength) then
        Raise Exception.CreateFmt ('Error: Invalid Format Processing (%s) in %s', [aChar, aFormatStr]);
      //
      Case aChar of
        'M': if (lvLength = 3 {ShortMonth Name}) then begin
               lvMonth := Copy (aDateStr, lvPos, lvLength);
               for x := Low (lvFormat.ShortMonthNames) to High (lvFormat.ShortMonthNames) do
                 if IsEqual (lvMonth, lvFormat.ShortMonthNames[x]) then begin
                   Result := x;
                   Break;
                 end;
             end
             else Result := StrToInt (Copy (aDateStr, lvPos, lvLength));
        else Result := StrToInt (Copy (aDateStr, lvPos, lvLength));
      end;
    end;
  end;
begin
  lvFormat := fnTS_LocaleSettings;
  // Process Year
  YR := fnExtract ('Y', [2, 4]);
  if (YR < 99) then
    if (YR < fnEPOCH) then
         YR := YR + 2000
    else YR := YR + 1900;
  // Process Month
  Mth := fnExtract ('M', [2, 3]);
  // Process Day
  Day := fnExtract ('D', [2]);
  // Hours
  Hr := fnExtract ('H', [2]);
  // Minutes
  Min := fnExtract ('N', [2]);
  // Seconds
  Sec := fnExtract ('S', [2]);
  // MilliSeconds
  Ms := fnExtract ('Z', [1, 2, 3]);
  //
  Result := EncodeDate (Yr, Mth, Day) + EncodeTime (Hr, Min, Sec, Ms);
end;

// Routine: fnStringDatestoString
// Author: M.A.Sargent  Date: 20/10/12  Version: V1.0
//         M.A.Sargent        05/03/15           V2.0
//
// Notes: Convert a tStringDate valus into is string representation
//  V2.0: Add sDDMMYYYY_HHMMSS
//  V3.0l Added sYYYYMMDD_HHMMSS
//
{Function fnStringDatestoString (Const aStringDates: tStringDates): String;
begin
  Case aStringDates of
    sdNone:; //Do Nothing
    sdHHMMSS:         Result := 'HH:NN:SS';
    sdHHMM:           Result := 'HH:NN';
    sdDDMMYY:         Result := 'DD-MM-YY';
    sdDDMMYYYY:       Result := 'DD-MM-YYYY';
    sDDMMYYYY_HHMMSS: Result := 'DD-MM-YYYY HH:NN:SS';
    sDDMMMYY:         Result := 'DD-MMM-YY';
    sDDMMMYYYY:       Result := 'DD-MMM-YYYY';
    sYYYYMMDD_HHMMSS: Result := 'YYYY-MM-DD HH:NN:SS';
    else Raise Exception.Create ('Error Unknown Format Passed to Function fnStringDatestoString');
  end;
end;}

// Routine: fnDecodeDate
// Author: M.A.Sargent  Date: 13/08/11  Version: V1.0
//
// Notes:
//
Function fnDecodeDate: tDateParts;
begin
  Result := fnDecodeDate (Now);
end;
Function fnDecodeDate (aDateTime: tDateTime): tDateParts;
begin
  DecodeDate (Now, Result.Year, Result.Mth, Result.Day);
  DecodeTime (Now, Result.Hr, Result.Min, Result.Sec, Result.Ms);
end;

{TFormatSettings = record
    CurrencyFormat: Byte;
    NegCurrFormat: Byte;
    ThousandSeparator: Char;
    DecimalSeparator: Char;
    CurrencyDecimals: Byte;
    DateSeparator: Char;
    TimeSeparator: Char;
    ListSeparator: Char;
    CurrencyString: string;
    ShortDateFormat: string;
    LongDateFormat: string;
    TimeAMString: string;
    TimePMString: string;
    ShortTimeFormat: string;
    LongTimeFormat: string;

    ShortMonthNames: array[1..12] of string;
    LongMonthNames: array[1..12] of string;
    ShortDayNames: array[1..7] of string;
    LongDayNames: array[1..7] of string;
    TwoDigitYearCenturyWindow: Word;
  end;}

// Routine: fnTryStrToDateTime
// Author: M.A.Sargent  Date: 05/05/12  Version: V1.0
//
// Notes:
//
Function fnTryStrToDateTime (aStr: String; var aDateTime: tDateTime): Boolean;
var
 x:        Integer;
 lvFormat: tFormatSettings;
begin
  Result := TryStrToDateTime (aStr, aDateTime);
  if Result then Exit;
  //
  lvFormat := fnTS_LocaleSettings;
  // Replace Short Month name in date String 12/Jan/1999 or Jan/12/1999
  for x := 0 to High(lvFormat.ShortMonthNames) do
    if UContainsText (lvFormat.ShortMonthNames[x], aStr) then begin
      aStr := StringReplace (aStr, lvFormat.ShortMonthNames[x], IntToStr(x+1), [rfIgnoreCase]);
      Result := True;
      Break;
    end;
  //
  if not Result then begin
    // Replace Long Month name in date String 12/January/1999
    for x := 0 to High(lvFormat.LongMonthNames) do
      if UContainsText (lvFormat.LongMonthNames[x], aStr) then begin
        aStr := StringReplace (aStr, lvFormat.LongMonthNames[x], IntToStr(x+1), [rfIgnoreCase]);
        Break;
      end;
  end;
  //
  Result := TryStrToDateTime (aStr, aDateTime);
end;

Function fnTryStrToDate (aStr: String; var aDateTime: tDateTime): Boolean;
begin
  Result := TryStrToDate (aStr, aDateTime, fnTS_LocaleSettings);
  if Result then Exit;
end;

// Routine: fnLocalStrToDate and fnLocalStrToDateTime
// Author: M.A.Sargent  Date: 11/05/12  Version: V1.0
//
// Notes: Both use a local copy of FormatSettings
//
function fnTS_StrToDate (Const aString: String): tDate;
begin
  Result := StrToDate (aString, fnTS_LocaleSettings);
end;
function fnTS_StrToDateTime (Const aString: String): tDatetime;
begin
  Result := StrToDateTime (aString, fnTS_LocaleSettings);
end;
Function fnTS_StrToTime (Const aString: String): tDatetime;
begin
  Result := StrToTime (aString, fnTS_LocaleSettings);
end;
//
function fnTS_StrToDateDef (Const aString: String; Const Default: TDateTime): tDate;
begin
  Result := StrToDateDef (aString, Default, fnTS_LocaleSettings);
end;
function fnTS_StrToDateTimeDef (Const aString: String; Const Default: TDateTime): tDatetime;
begin
  Result := StrToDateTimeDef (aString, Default, fnTS_LocaleSettings);
end;
Function fnTS_StrToTimeDef (Const aString: String; Const Default: TDateTime): tDateTime;
begin
  Result := StrToTimeDef (aString, Default, fnTS_LocaleSettings);
end;
//
Function fnTS_DateTimeToStr (Const aDateTime: tDateTime): String;
begin
  Result := DateTimeToStr (aDateTime, fnTS_LocaleSettings);
end;
Function fnTS_TimeToStr (Const aTime: tTime): String;
begin
  Result := TimeToStr (aTime, fnTS_LocaleSettings);
end;

// Routine: fnTS_DateTimeToNoneLocalizedFormat & fnTS_NoneLocalizedFormatToDateTime
// Author: M.A.Sargent  Date: 11/04/18  Version: V1.0
//         M.A.Sargent        11/04/18           V2.0
//
// Notes:
//
Function fnTS_DateTimeToNoneLocalizedFormat (Const aDateTime: tDateTime): String;
begin
  // Do not Localize
  Result := fnTS_FormatDateTime (sdYYYYMMDD_HHMMSS, aDateTime);
end;
Function fnTS_NoneLocalizedFormatToDateTime (Const aDateTime: String): tDateTime;
begin
  // Do not Localize
  if not IsEmpty (aDateTime) then
       Result := fnStrToDate (aDateTime, fnLocalisedDate (sdYYYYMMDD_HHMMSS))
  else Result := 0;
end;
Function fnTS_NoneLocalizedFormatToDateTime2 (Const aDateTime: String): tOKDateRec;
begin
  // Do not Localize
  Result.Date := fnTS_NoneLocalizedFormatToDateTime (aDateTime);
  Result.OK   := (Result.Date > 0);
end;


// Routine: fnTS_FormatTime and fnTS_FormatDateTime
// Author: M.A.Sargent  Date: 20/09/13  Version: V1.0
//
// Notes:
//
{Function fnTS_FormatTime (Const aDateTime: tDateTime; Const aStringDates: tStringDates): String;
begin
  Result := fnTS_FormatDateTime (fnStringDatestoString (aStringDates), aDateTime);
end;
Function fnTS_FormatDateTime (Const aDateTime: tDateTime; Const aStringDates: tStringDates): String;
begin
  Result := fnTS_FormatDateTime (fnStringDatestoString (aStringDates), aDateTime);
end;}
Function fnTS_FormatDateTime (Const aFormat: tStringDates; Const aDateTime: tDateTime): String; overload;
begin
  Result := fnTS_FormatDateTime (fnLocalisedDate (aFormat), aDateTime);
end;
Function fnTS_FormatDateTime (Const aFormat: string; Const aDateTime: tDateTime): String;
begin
  Result := FormatDateTime (aFormat, aDateTime, fnTS_LocaleSettings);
end;

// Routine: fnTS_TryStrToDateTime
// Author: M.A.Sargent  Date: 25/06/17  Version: V1.0
//
// Notes:
//
Function fnTS_TryStrToDateTime (aStr: String; var aDateTime: tDateTime): Boolean;
begin
  Result := TryStrToDateTime (aStr, aDateTime, fnTS_LocaleSettings);
end;

// Routine: fnDateHasChange
// Author: M.A.Sargent  Date: 23/10/13  Version: V1.0
//
// Notes:
//
Function fnDateHasChange: Boolean;
var
  lvDate: tDate;
begin
  lvDate := Trunc (Now);
  Result := (lvDate > gblDateToday);
  if Result then
    gblDateToday := lvDate;
end;

// Routine: fnDayStr
// Author: M.A.Sargent  Date: 23/10/13  Version: V1.0
//
// Notes:
//
Function fnDayStr (Const aDate: TDate): String;
begin
  Result := fnDayStr (DayOf (aDate));
end;
Function fnDayStr (Const aDay: Word): String;
begin
  Case aDay of
    1,21,31: Result := 'st';
    2,22:    Result := 'nd';
    3,23:    Result := 'rd';
    else     Result := 'th';
  end;
  Result := (IntToStr (aDay) + Result);
end;

// Routine: fnIsAM
// Author: M.A.Sargent  Date: 23/10/13  Version: V1.0
//
// Notes: HourOf return 0 to 23, so 0 to 11 (and could 11.58.59) is AM
//
Function fnIsAM (Const aDate: TDateTime): Boolean;
begin
  Case HourOf (aDate) of
    0..11: Result := True;
    else   Result := False;
  end;
end;

end.
