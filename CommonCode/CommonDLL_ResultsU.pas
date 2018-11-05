//
// Unit: CommonDLL_ResultsU
// Author: M.A.Sargent  Date: 17/11/2017  Version: V1.0
//
// Notes:
//
unit CommonDLL_ResultsU;

interface

Uses SysUtils, MASRecordStructuresU, MAS_Collections2U, Windows, MAS_FormatU;

  Function Result_SaveError     (Const aName, aMsg: String): tOKIntegerRec; overload;
  Function Result_SaveError     (Const aCondition: Boolean; Const aName, aMsg: String): tOKIntegerRec; overload;
  Function Result_SaveError     (Const aCondition: Boolean; Const aName, aFormat: String; Const Args: Array of Const): tOKIntegerRec; overload;
  Function Result_SaveError     (Const aMsg: String): tOKIntegerRec; overload;
  Function Result_SaveException (Const aName: String; Const eExcept: Exception): tOKIntegerRec;
  Function Result_SaveMsg       (Const aMsg: String): tOKIntegerRec;
  //
  Function Result_fnGetFeedBackAnsi (MessageOut: PAnsiChar): Boolean;
  Function Result_fnGetFeedBack     (MessageOut: PChar): Boolean;

implementation

Uses MASCommonU, DLL_HelpersU, CriticalSectionU;

var
  gblString: tThreadSafeIndexList = Nil;

// Routine: Result_SaveError
// Author: M.A.Sargent  Date: 02/10/17  Version: V1.0
//
// Notes:
//
Function Result_SaveError (Const aMsg: String): tOKIntegerRec;
begin
  Result.OK := False;
  Result.Int := gblString.AddEntry (GetCurrentThreadId, aMsg);
end;
Function Result_SaveError (Const aName: String; Const aMsg: String): tOKIntegerRec;
begin
  Result.OK  := False;
  Result.Int := gblString.AddEntry (GetCurrentThreadId, (aName + ': ' + aMsg));
end;
Function Result_SaveError (Const aCondition: Boolean; Const aName, aFormat: String; Const Args: Array of Const): tOKIntegerRec;
begin
    Result := Result_SaveError (aCondition, aName, fnTS_Format (aFormat, Args));
end;
Function Result_SaveError (Const aCondition: Boolean; Const aName, aMsg: String): tOKIntegerRec;
begin
  Result.OK  := aCondition;
  Result.Int := 0;
  if not Result.OK then Result.Int := gblString.AddEntry (GetCurrentThreadId, (aName + ': ' + aMsg));
end;

Function Result_SaveException (Const aName: String; Const eExcept: Exception): tOKIntegerRec;
begin
  Result.OK := False;
  Result.Int := gblString.AddEntry (GetCurrentThreadId, (aName + ': ' + eExcept.Message));
end;

// Routine: Result_SaveMsg
// Author: M.A.Sargent  Date: 10/10/17  Version: V1.0
//
// Notes:
//
Function Result_SaveMsg (Const aMsg: String): tOKIntegerRec;
begin
  Result.OK := True;
  Result.Int := gblString.AddEntry (GetCurrentThreadId, aMsg);
end;

// Routine: Result_fnGetFeedBack
// Author: M.A.Sargent  Date: 17/11/17  Version: V1.0
//
// Notes:
//
Function Result_fnGetFeedBackAnsi (MessageOut: PAnsiChar): Boolean;
var
  lvTextLength: Cardinal;
  lvRec:        tOKStrRec;
begin
  Result := True;
  Try
    lvRec := gblString.fnGetEntryDeleteAfterRead (GetCurrentThreadId);
    if lvRec.OK then begin
      //
      lvTextLength := Length (lvRec.Msg)+1;
      Result := (StrBufSize (MessageOut) >= lvTextLength);
      if Result then begin
        StrPCopy (MessageOut, lvRec.Msg);
      end;
    end;
  Except
    on e:Exception do begin
      Result := False;
    end;
  end;
end;

// Routine: Result_fnGetFeedBack
// Author: M.A.Sargent  Date: 17/11/17  Version: V1.0
//
// Notes:
//
Function Result_fnGetFeedBack (MessageOut: PChar): Boolean;
var
  lvTextLength: Cardinal;
  lvRec:        tOKStrRec;
begin
  Result := True;
  Try
    lvRec := gblString.fnGetEntryDeleteAfterRead (GetCurrentThreadId);
    if lvRec.OK then begin
      //
      lvTextLength := Length (lvRec.Msg)+1;
      Result := (StrBufSize (MessageOut) = lvTextLength);
      if Result then begin
        StrPCopy (MessageOut, lvRec.Msg);
      end;
    end;
  Except
    on e:Exception do
      Result := False;
  end;
end;

Initialization
  gblString := tThreadSafeIndexList.Create;
Finalization
  gblString.Free;
end.

