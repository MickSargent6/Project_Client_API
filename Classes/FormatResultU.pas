//
// Unit: FormatResultU
// Author: M.A.Sargent  Date: 16/09/13  Version: V1.0
//         M.A.Sargent        10/11/13           V2.0
//         M.A.Sargent        16/04/14           V3.0
//         M.A.Sargent        13/06/18           V4.0
//
// Notes:
//  V4.0: Added another version of fnResultOK
//
unit FormatResultU;

interface

Uses SysUtils, MASRecordStructuresU, Dialogs, Controls,
     {$IFDEF VER150}
     MAS_TypesU;
     {$ELSE}
     MAS_TypesU, UITypes;
     {$ENDIF}

  Function fnResult (Const aCondition: Boolean; Const aMsg: String): tOKStrRec; overload;
  Function fnResult (Const aCondition: Boolean; Const aFormat: string; Const Args: array of const): tOKStrRec; overload;
  //
  Function fnResult (Const aMsg: String): tOKStrRec; overload;
  Function fnResult (Const aFormat: string; Const Args: array of const): tOKStrRec; overload;
  //
  Function fnResultOK (Const aFormat: string; Const Args: array of const): tOKStrRec; overload;
  Function fnResultOK (Const aMsg: String): tOKStrRec; overload;
  Function fnResultOK (Const aMsg: String; Const aRecordResult: tRecordResult): tOKStrRec; overload;

  Function fnResultIfTrue (Const aCondition: Boolean; Const aTrueMsg, aFalseMsg: String): tOKStrRec; overload;

  Procedure RaiseOnFalse (Const aOKStrRec: tOKStrRec); overload;
  Procedure RaiseOnFalse (Const aOKCodeStrRec: tOKCodeStrRec; Const aIncludeCode: Boolean = True); overload;
  //
  Procedure RaiseNow     (Const aMsg: String); overload;
  Procedure RaiseNow     (Const aFormat: string; Const Args: array of const); overload;
  //
  Function fnRaiseOnFalse (Const aOKStrRec: tOKStrRec): Boolean; overload
  Function fnRaiseOnFalse (Const aCondition: Boolean; Const aMsg: String): Boolean; overload;
  Function fnRaiseOnFalse (Const aCondition: Boolean; Const aFormat: string; Const Args: array of const): Boolean; overload;
  //
  Function fnRaiseOnFalse2 (Const aOKStrRec: tOKStrRec): String;
  Function fnRaiseOnFalse (Const aName: String; Const aOKStrRec: tOKStrRec): Boolean; overload;
  //
  Function fnChkOK  (aOKStrRec: tOKStrRec): Boolean;

  Function fnOKStrRecAsString (Const aOKStrRec: tOKStrRec): String;

  // NOT Thread Safe
  Function fnDialogOnFalse (Const aOKStrRec: tOKStrRec): Boolean;
  // NOT Thread Safe

  Function fnToOKCodeStrRec (Const aOKStrRec: tOKStrRec): tOKCodeStrRec;

  Function fnResultException (Const aName: String; Const aExcp: Exception): tOKStrRec; overload;
  Function fnResultException (Const aName, aMsg: String; Const aExcp: Exception): tOKStrRec; overload;
  Function fnResultException (Const aName: String; Const aFormat: string; Const Args: array of Const; Const aExcp: Exception): tOKStrRec; overload;

  // NOT Thread Safe
  Function fnRaiseOnFalse_ShowModal (Const aOKStrRec: tOKStrRec): Boolean;
  // NOT Thread Safe

implementation

Uses MAS_FormatU, MASCommonU;

Function fnResult (Const aFormat: string; Const Args: array of const): tOKStrRec;
begin
  Result := fnResult (fnTS_Format (aFormat, Args));
end;

Function fnResult (Const aMsg: String): tOKStrRec;
begin
  Result := fnResult (False, aMsg);
end;

Function fnResult (Const aCondition: Boolean; Const aFormat: string; Const Args: array of const): tOKStrRec; overload;
begin
  Result := fnResult (aCondition, fnTS_Format (aFormat, Args));
end;
Function fnResult (Const aCondition: Boolean; Const aMsg: String): tOKStrRec; overload;
begin
  Result.OK := aCondition;
  Case Result.OK of
    True: Result.Msg := '';
    else  Result.Msg := aMsg;
  end;
end;

Function fnResultOK (Const aFormat: string; Const Args: array of const): tOKStrRec;
begin
  Result := fnResultOK (fnTS_Format (aFormat, Args));
end;
Function fnResultOK (Const aMsg: String): tOKStrRec; overload;
begin
  Result.OK  := True;
  Result.Msg := aMsg;
end;
Function fnResultOK (Const aMsg: String; Const aRecordResult: tRecordResult): tOKStrRec; overload;
begin
  Result := fnResultOK (aMsg);
  Result.ExtendedInfoRec.aRecordResult := aRecordResult;
end;

// Routine: fnResultIfTrue
// Author: M.A.Sargent  Date: 24/10/18  Version: V1.0
//
// Notes:
//
Function fnResultIfTrue (Const aCondition: Boolean; Const aTrueMsg, aFalseMsg: String): tOKStrRec;
begin
  Result.OK  := aCondition;
  Result.Msg := IfTrue (Result.OK, aTrueMsg, aFalseMsg);
end;

// Routine: RaiseOnFalse
// Author: M.A.Sargent  Date: 15/10/13  Version: V1.0
//         M.A.Sargent        16/04/14           V2.0
//
// Notes:
//
Function fnRaiseOnFalse2 (Const aOKStrRec: tOKStrRec): String;
begin
  RaiseOnFalse (aOKStrRec);
  Result := aOKStrRec.Msg;
end;

Function fnRaiseOnFalse (Const aCondition: Boolean; Const aFormat: string; Const Args: array of const): Boolean;
begin
  Result := fnRaiseOnFalse (fnResult (aCondition, aFormat, Args));
end;
Function fnRaiseOnFalse (Const aCondition: Boolean; Const aMsg: String): Boolean;
begin
  Result := fnRaiseOnFalse (fnResult (aCondition, aMsg));
end;
Function fnRaiseOnFalse (Const aOKStrRec: tOKStrRec): Boolean;
begin
  Result := aOKStrRec.OK;
  if not Result then
    Raise Exception.CreateFmt ('Error: %s', [aOKStrRec.Msg]);
end;
Function fnRaiseOnFalse (Const aName: String; Const aOKStrRec: tOKStrRec): Boolean;
begin
  Result := fnRaiseOnFalse (aOKStrRec.OK, 'Error: %s. %s', [aName, aOKStrRec.Msg]);
end;

// Routine: RaiseOnFalse
// Author: M.A.Sargent  Date: 27/10/13  Version: V1.0
//
// Notes:
//
Procedure RaiseOnFalse (Const aOKStrRec: tOKStrRec);
begin
  fnRaiseOnFalse (aOKStrRec);
end;

Procedure RaiseOnFalse (Const aOKCodeStrRec: tOKCodeStrRec; Const aIncludeCode: Boolean = True);
begin
  Case (aIncludeCode and (aOKCodeStrRec.Code <> 0)) of
    True: fnRaiseOnFalse (aOKCodeStrRec.OK, fnTS_Format ('(%d): %s', [aOKCodeStrRec.Code , aOKCodeStrRec.Msg]));
    else  fnRaiseOnFalse (aOKCodeStrRec.OK, aOKCodeStrRec.Msg);
  end;
end;

Procedure RaiseNow (Const aMsg: String);
begin
  fnRaiseOnFalse (fnResult (aMsg));
end;
Procedure RaiseNow (Const aFormat: String; Const Args: array of Const);
begin
  fnRaiseOnFalse (fnResult (aFormat, Args));
end;

// Routine: fnChkOK
// Author: M.A.Sargent  Date: 03/05/18  Version: V1.0
//
// Notes:
//
Function fnChkOK (aOKStrRec: tOKStrRec): Boolean;
begin
  Result := aOKStrRec.OK;
end;

// Routine: fnOKStrRecAsString
// Author: M.A.Sargent  Date: 22/03/18  Version: V1.0
//
// Notes:
//
Function fnOKStrRecAsString (Const aOKStrRec: tOKStrRec): String;
begin
  Case aOKStrRec.OK of
    True: Result := ('OK: '+aOKStrRec.Msg);
    else  Result := ('Failed: '+aOKStrRec.Msg);
  end;
end;

// Routine: DialogOnFalse
// Author: M.A.Sargent  Date: 27/10/13  Version: V1.0
//
// Notes:
//
Function fnDialogOnFalse (Const aOKStrRec: tOKStrRec): Boolean;
begin
  Result := aOKStrRec.OK;
  if not Result and (aOKStrRec.Msg <> '') then
    MessageDlg (fnTS_Format ('Error: (%s)', [aOKStrRec.Msg]), mtError, [mbOK], 0);
end;

Function fnToOKCodeStrRec (Const aOKStrRec: tOKStrRec): tOKCodeStrRec;
begin
  {$IFDEF VER150}
  Result.OK   := aOKStrRec.OK;
  Result.Code := -1;
  Result.Msg  := aOKStrRec.Msg;
  {$ELSE}
  Result.SetValue (aOKStrRec.OK, -1, aOKStrRec.Msg);
  {$ENDIF}
end;

// Routine: fnResultException
// Author: M.A.Sargent  Date: 21/04/18  Version: V1.0
//
// Notes:
//
Function fnResultException (Const aName: String; Const aExcp: Exception): tOKStrRec; overload;
begin
  Case IsEmpty (aName) of
    True: Result := fnResult ('Exception: %s', [aExcp.Message]);
    else  Result := fnResult ('Exception: %s. %s', [aName, aExcp.Message]);
  End;
  Result.ExtendedInfoRec.aRecordResult := rrException;
end;
Function fnResultException (Const aName, aMsg: String; Const aExcp: Exception): tOKStrRec; overload;
begin
  Case IsEmpty (aName) of
    True: Result := fnResultException (aMsg, aExcp);
    else  Result := fnResultException ((aName + '. ' + aMsg), aExcp);
  end;
end;
Function fnResultException (Const aName: String; Const aFormat: string; Const Args: array of Const; Const aExcp: Exception): tOKStrRec; overload;
begin
  Result := fnResultException (aName, fnTS_Format (aFormat, Args), aExcp);
end;

// Routine: fnRaiseOnFalse_ShowModal
// Author: M.A.Sargent  Date: 21/04/18  Version: V1.0
//
// Notes: See function h_fnShowModalForm in TSBaseFormU, return True on mrOK, Boolean result
//        so that for instance a Grid could be refreshed, but a mr Cancel means somebody just pressed the Cancel button
//        no Error or Exception)
//
Function fnRaiseOnFalse_ShowModal (Const aOKStrRec: tOKStrRec): Boolean;
begin
  fnRaiseOnFalse (aOKStrRec);
  Result := (aOKStrRec.ExtendedInfoRec.aRecordResult = rrOK);
end;

end.
