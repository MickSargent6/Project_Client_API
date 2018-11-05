//
// Unit: MAS_MySql_BaseTableU
// Author: M.A.Sargent  Date: 29/11/17  Version: V1.0
//         M.A.Sargent        ??/??/??           V2.0
//         M.A.Sargent        22/05/18           V3.0
//
// Notes:
//  V2.0: Updated to use the FireBird version, updated to use FireDac
//  V3.0: Updated to a Devart MySql version
//
unit MAS_MySql_BaseTableU;

interface

Uses Classes, SysUtils, MASRecordStructuresU, MasStringListU, MASMessagesU, MASmySQLStoredProc, mySQLDbTables;

Type
  eDbAccess = Class;
  tBM_BaseTableAPI = Class;
  tEventType = (etBeforeExec, etAfterExec);
  tResultDataType = (rdtNone, rdtEvent, rdtString, rdtInteger, rdtResult {So Far, more can be added as needed});
  tResultType = (rtZeroRows, rtOneRow, rtOneOrMore, rtNotBothered);
  tOnExecEvent = Procedure (Sender: tBM_BaseTableAPI; Const aEventType: tEventType) of object;

  eDbAccess = Class (Exception)
  Private
    fMsg:       String;
    fDbError:   String;
    fListError: tStrings;
    //
    Procedure SetListError (Const Value: tStrings);
  Public
    Constructor Create    (Const aMsg, aDbError: String); overload;
    Constructor CreateFmt (Const aMsg: string; const Args: array of const; Const aDbError: String); overload;
    Constructor Create    (Const aMsg, aDbError: String; aErrList: tStrings); overload;
    Constructor CreateFmt (Const aMsg: string; const Args: array of const; Const aDbError: String; aErrList: tStrings); overload;
    Destructor Destroy; override;

    Property DbError:   String   read fDbError   write fDbError;
    Property Msg:       String   read fMsg       write fMsg;
    Property ListError: tStrings read fListError write SetListError;
  end;

  tBM_BaseTableAPI = Class (tObject)
  Private
    fRaiseIfNotFound: Boolean;
    fFeedBackHandle:  tHandle;
    fInTrans:         Integer;
    fRelease:         Boolean;
    fOnExecEvent:     tOnExecEvent;
    fLastError:       String;
    fDataSetList:     tMASStringList;
    fDbConnection:    tMySQLDatabase;
    //
    Procedure SetDbConnection (Const Value: tMySQLDatabase);
    Function GetDbConnection: tMySQLDatabase;
  Protected
    Procedure SetLastError      (Const aFormat: string; Const Args: array of const); overload;
    Procedure SetLastError      (Const aMsg: String); overload;
    Function  fnSetLastError    (Const aCondition: Boolean; Const aFormat: string; Const Args: array of const): Boolean; overload;
    Function  fnSetLastError    (Const aCondition: Boolean;Const aMsg: String): Boolean; overload;

    Procedure DoExecEvent       (Const aEventType: tEventType); virtual;
    Procedure DoAfterExecEvent  (Const aName: String; aProc: tMASmySQLStoredProc; var aOKVariant: tOKVariant); virtual;

    Procedure DoSetDbConnection (Const aConnection: tMySQLDatabase); virtual;
    Procedure IntClearLastError;
    //
    Function  fnIsInTransaction: Boolean;
    Function  StartTransactionIfNeeded: Boolean;
    Procedure CommitTransactionIfNeeded;
    Procedure RollbackTransactionIfNeeded;
    //
    Function  SendMessage       (Const Msg: Cardinal; WParam, LParam: Longint): LongInt;
    //
    Function  fnAPIResult       (Const aCondition: Boolean; Const aOKDbResult,  aDbResult: Integer; Const aFormat: String; Const Args: array of Const): tOKStrRec; overload;
    Function  fnAPIResult       (Const aCondition: Boolean; Const aOKDbResult,  aDbResult: Integer; Const aMsg: String): tOKStrRec; overload;
    Function  fnAPIResult_Not   (Const aCondition: Boolean; Const aNotDbResult, aDbResult: Integer; Const aFormat: String; Const Args: array of Const): tOKStrRec; overload;
    Function  fnAPIResult_Not   (Const aCondition: Boolean; Const aNotDbResult, aDbResult: Integer; Const aMsg: String): tOKStrRec; overload;
    //
    Function SetUpProc (Const aSPName: String): tMASmySQLStoredProc;
    //Function SetUpQuery (Const aSPName: String): tMAS_fdQuery;

    Function IntExec_Commit            (Const aRoutine: String; aProc: tMASmySQLStoredProc): Boolean;
    Function IntExec_ConditionalCommit (Const aRoutine: String; aProc: tMASmySQLStoredProc; Const aResultDataType: tResultDataType;
                                         Const aValues: Array of Variant; Const aRaiseOnFalse: Boolean = False): tOKVariant;
    // These routines are enclosed in Commit/Rollback routines
    Function fnProc      (Const aName: String): tMASmySQLStoredProc; overload;
    Function fnProc      (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant; Const aMustExist: Boolean): tMASmySQLStoredProc; overload;
    Function fnProcAsInt (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant; Const aMustExist: Boolean): tOKIntegerRec;
    Function fnProcAsVar (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant; Const aMustExist: Boolean): tOKVariant;
    //
    Function fnProcCheckInt (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant;
                              Const aMustExist: Boolean; Const aResults: Array of Variant): tOKIntegerRec;
    Function fnProcCheckStr (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant;
                              Const aMustExist: Boolean; Const aResults: Array of Variant): tOKStrRec;
    Function fnProcCheck (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant;
                           Const aMustExist: Boolean; Const aResultDataType: tResultDataType; Const aResults: Array of Variant): tOKVariant;
    //

    Function fnProcCount (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant;
                           Const aMustExist: Boolean; Const aResultType: tResultType): tOKIntegerRec;

    //Function fnQuery (Const aName: String): tMAS_fdQuery;
    //
    Property Release:        Boolean read fRelease        write fRelease default True;
    Property FeedBackHandle: tHandle read fFeedBackHandle write fFeedBackHandle;
    //
    Property DbConnection: tMySQLDatabase read GetDbConnection write SetDbConnection;
  Public
    Constructor Create (aDbConnection: tMySQLDatabase); overload; virtual;
    Constructor Create (aDbConnection: tMySQLDatabase; Const RaiseIfNotFound: Boolean); overload; virtual;
    Destructor  Destroy; override;
    Procedure   Clear; virtual;

    //
    Function  StartTransaction: Boolean;
    Procedure CommitTransaction;
    Procedure RollbackTransaction;

    Property LastError:       String       read fLastError       write fLastError;
    Property RaiseIfNotFound: Boolean      read fRaiseIfNotFound write fRaiseIfNotFound default True;
    Property OnExecEvent:     tOnExecEvent read fOnExecEvent     write fOnExecEvent;
  end;

implementation

Uses MASDbUtilsU, MASCommon_UtilsU, MASDBUtilsCommonU, FormatResultU, MAS_FormatU, MAS_ConstsU;

{ tTableAPIException }

Constructor eDbAccess.Create (Const aMsg, aDbError: String);
begin
  Message := aMsg;
  DbError := aDbError;
end;

Constructor eDbAccess.Create (Const aMsg, aDbError: String; aErrList: tStrings);
begin
  Message := aMsg;
  DbError := aDbError;
  ListError := aErrList;
end;

Constructor eDbAccess.CreateFmt (Const aMsg: string; Const Args: array of const; const aDbError: String);
begin
  Message := Format (aMsg, Args);
  DbError := aDbError;
end;

Constructor eDbAccess.CreateFmt (Const aMsg: string; Const Args: array of const; const aDbError: String; aErrList: tStrings);
begin
  Message := Format (aMsg, Args);
  DbError := aDbError;
  ListError := aErrList;
end;

Destructor eDbAccess.Destroy;
begin
  if Assigned (fListError) then FreeRegardless (fListError);
  inherited;
end;

Procedure eDbAccess.SetListError (Const Value: tStrings);
begin
  FreeRegardLess (fListError);
  fListError := Value;
end;

{ tBM_BaseTableAPI }

// Routine:
// Author: M.A.Sargent  Date: 25/02/12  Version: V1.0
//
// Notes:
//
Constructor tBM_BaseTableAPI.Create (aDbConnection: tMySQLDatabase);
begin
  fOnExecEvent     := Nil;
  DbConnection     := aDbConnection;
  fRelease         := True;
  fInTrans         := 0;
  fRaiseIfNotFound := True;
  fDataSetList := tMasStringList.CreateSorted;
end;

Constructor tBM_BaseTableAPI.Create (aDbConnection: tMySQLDatabase; Const RaiseIfNotFound: Boolean);
begin
  Create (aDbConnection);
  Self.RaiseIfNotFound := RaiseIfNotFound;
end;


// Routine:
// Author: M.A.Sargent  Date: 25/02/12  Version: V1.0
//
// Notes:
//
Destructor tBM_BaseTableAPI.Destroy;
begin
  fDataSetList.Clear;
  fDataSetList.Free;
  inherited;
end;

// Routine: fnProc
// Author: M.A.Sargent  Date: 12/05/12  Version: V1.0
//         M.A.Sargent        03/06/12           V2.0
//         M.A.Sargent        29/11/17           V3.0
//
// Notes:
//  V2.0: Clear Parameters on Find
//  V3.0: Updated to make it read better, do not fail but.
//
Function tBM_BaseTableAPI.fnProc (Const aName: String): tMASmySQLStoredProc;
var
  lvObj: tObject;
begin
  Result := Nil;
  lvObj := fDataSetList.fnObject (aName);
  if Assigned (lvObj) and not (lvObj is tMASmySQLStoredProc) then Raise Exception.Create ('Ooops');
  if Assigned (lvObj) then begin
    Result := tMASmySQLStoredProc (lvObj);
    Result.ClearParameters;
    // Problem, needs looking into
    if True then begin
      fDataSetList.DeleteByName (aName);
      Result := nil;
    end;
  end;
  //
  if not Assigned (Result) then begin
    Result := SetUpProc (aName);
    fDataSetList.AddObject (aName, Result);
  end;
end;
Function tBM_BaseTableAPI.fnProc (Const aIdentifier, aSPName: String;
                                   Const aParams: array of string; Const aValues: array of Variant; Const aMustExist: Boolean): tMASmySQLStoredProc;
begin
  Result := fnProc (aSPName);
  Result.LoadParamByName (aParams, aValues, aMustExist);
  Self.IntExec_Commit (aIdentifier, Result);
end;
Function tBM_BaseTableAPI.fnProcAsVar (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant; Const aMustExist: Boolean): tOKVariant;
var
  lvObj: tMASmySQLStoredProc;
begin
  lvObj := fnProc (aIdentifier, aSPName, aParams, aValues, aMustExist);
  Result := fnResultAsVariant (lvObj);
end;

Function tBM_BaseTableAPI.fnProcAsInt (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant; Const aMustExist: Boolean): tOKIntegerRec;
var
  lvObj: tMASmySQLStoredProc;
begin
  lvObj := fnProc (aIdentifier, aSPName, aParams, aValues, aMustExist);
  Result := fnResultAsInt (lvObj);
end;

// Routine: fnProcCount
// Author: M.A.Sargent  Date: 12/05/12  Version: V1.0
//
// Notes: Procedure will return True if return code is on the aResult Array, else False
//        True will Commit amd False will RollBack
//        Exceptions will be raised
//
Function tBM_BaseTableAPI.fnProcCheckInt (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant;
                                           Const aMustExist: Boolean; Const aResults: Array of Variant): tOKIntegerRec;
var
  lvRes: tOKVariant;
begin
  lvRes := fnProcCheck (aIdentifier, aSPName, aParams, aValues, aMustExist, rdtInteger, aResults);
  Result.OK  := lvRes.OK;
  Result.Int := Integer (lvRes.Msg);
end;
Function tBM_BaseTableAPI.fnProcCheckStr (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant;
                                           Const aMustExist: Boolean; Const aResults: Array of Variant): tOKStrRec;
var
  lvRes: tOKVariant;
begin
  lvRes := fnProcCheck (aIdentifier, aSPName, aParams, aValues, aMustExist, rdtString, aResults);
  Result.OK  := lvRes.OK;
  Result.Msg := String (lvRes.Msg);
end;
Function tBM_BaseTableAPI.fnProcCheck (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant;
                                        Const aMustExist: Boolean; Const aResultDataType: tResultDataType; Const aResults: Array of Variant): tOKVariant;
var
  lvObj: tMASmySQLStoredProc;
begin
  Result := fnClear_OKVariant;
  lvObj := fnProc (aSPName);
  lvObj.LoadParamByName (aParams, aValues, aMustExist);
  //
  Result := Self.IntExec_ConditionalCommit (aIdentifier, lvObj, aResultDataType, aResults, True);
end;

// Routine: fnProcCount
// Author: M.A.Sargent  Date: 12/05/12  Version: V1.0
//
// Notes:
//
Function tBM_BaseTableAPI.fnProcCount (Const aIdentifier, aSPName: String; Const aParams: array of string; Const aValues: array of Variant;
                                        Const aMustExist: Boolean; Const aResultType: tResultType): tOKIntegerRec;
var
  lvObj: tMASmySQLStoredProc;
  lvRes: tOKVariant;
begin
  Result := fnClear_OKIntegerRec;
  lvObj := fnProc (aSPName);
  lvObj.LoadParamByName (aParams, aValues, aMustExist);
  //
  Case aResultType of
    rtZeroRows:    lvRes := Self.IntExec_ConditionalCommit (aIdentifier, lvObj, rdtInteger, [cMC_ZERO_ROWS], True);
    rtOneRow:      lvRes := Self.IntExec_ConditionalCommit (aIdentifier, lvObj, rdtInteger, [cMC_ONE_ROW], True);
    rtOneOrMore:   Raise Exception.Create ('Error: fnProcCount. Not Implimented Yet');
                   //lvRes := Self.IntExec2 (aIdentifier, lvObj, rdtInteger, [0], True); //???
    rtNotBothered: lvRes := Self.IntExec_ConditionalCommit (aIdentifier, lvObj, rdtResult, [], True);

  end;
  //
  Result.OK  := lvRes.OK;
  Result.Int := lvRes.Msg;
end;

// Routine: fnQuery
// Author: M.A.Sargent  Date: 12/05/12  Version: V1.0
//         M.A.Sargent        03/06/12           V2.0
//
// Notes:
//  V2.0: Clear Parameters on Find
//
{Function tBM_BaseTableAPI.fnQuery (Const aName: String): tMAS_fdQuery;
var
  lvObj: tObject;
begin
  lvObj := fDataSetList.fnObject (aName);
  if Assigned (lvObj) and not (lvObj is tMAS_fdQuery) then Raise Exception.Create ('Ooops');
  Result := tMAS_fdQuery (lvObj);
  if Assigned (Result) then
    Result.ClearParameters
  else begin
    Result := SetUpQuery (aName);
    fDataSetList.AddObject (aName, Result);
  end;
end;}

Procedure tBM_BaseTableAPI.DoSetDbConnection (Const aConnection: tMySQLDatabase);
begin
end;

// Routine: IntClearLastError
// Author: M.A.Sargent  Date: 13/03/12  Version: V1.0
//
// Notes:
//
Procedure tBM_BaseTableAPI.IntClearLastError;
begin
  fLastError := '';
end;

// Routine: SetUpProc
// Author: M.A.Sargent  Date: 13/03/12  Version: V1.0
//
// Notes:
//
Function tBM_BaseTableAPI.SetUpProc (Const aSPName: String): tMASmySQLStoredProc;
begin
  if not Assigned (fDbConnection) then
    Raise Exception.CreateFmt ('Error: %s', ['oops']);
  //
  Result := h_fnGetStoredProc (fDbConnection, aSPName);
end;

// Routine: SetUpQuery
// Author: M.A.Sargent  Date: 28/11/12  Version: V1.0
//
// Notes: Removed the Transaction assignment, not sure this is needed for a query
//
{Function tBM_BaseTableAPI.SetUpQuery (Const aSPName: String): tMAS_fdQuery;
begin
  if not Assigned (fFDConnection) then
    Raise Exception.CreateFmt ('Error: %s', ['oops']);
  //
  Result := h_fnGetQuery (fFDConnection, aSPName);
end;}

// Routine: IntExec
// Author: M.A.Sargent  Date: 25/02/12  Version: V1.0
//
// Notes: IntExec, should return True, all other problems should raise an Exception
//
Function tBM_BaseTableAPI.IntExec_Commit (Const aRoutine: String; aProc: tMASmySQLStoredProc): Boolean;
begin
  Result := IntExec_ConditionalCommit (aRoutine, aProc, rdtNone, [], True).OK;
end;

// Routine: IntExec
// Author: M.A.Sargent  Date: 25/02/12  Version: V1.0
//
// Notes: If this Return False and not (aResultDataType = rdtNone) then has failed the Values Variant checks
//        and will have rolledback the Transaction
//
Function tBM_BaseTableAPI.IntExec_ConditionalCommit (Const aRoutine: String; aProc: tMASmySQLStoredProc; Const aResultDataType: tResultDataType;
                                                      Const aValues: Array of Variant; Const aRaiseOnFalse: Boolean): tOKVariant;
var
  lvInTrans: Boolean;
  lvList:    tStrings;
  //lvBool:    Boolean;
  lvResult:  Boolean;
 // lvRes: tOKVariant;
begin
  Result := fnClear_OKVariant (False);
  if not Assigned (aProc) then Exit;
  //
  lvInTrans := fnIsInTransaction;
  if not lvInTrans then DbConnection.StartTransaction;
  Try
    // Check details before routine is run,
    //
    Case aResultDataType of
      rdtString, rdtInteger:        fnRaiseOnFalse ((High (aValues) > -1), 'aValue Array cannot be Empty');
      rdtNone, rdtEvent, rdtResult: fnRaiseOnFalse ((High (aValues) = -1), 'aValue Array must be Empty');
      else Raise Exception.CreateFmt ('Error: IntExec. Unknown Datatype: %d', [Ord (aResultDataType)]);
    End;
    //
    DoExecEvent (etBeforeExec);
    lvResult := True;
    aProc.ExecProc;
    fnRaiseOnFalse  (lvResult, 'Function returned False: %s', [aRoutine]);
    DoExecEvent (etAfterExec);
    //
    //
    //
    Case aResultDataType of
      rdtNone: begin
             // default , as was
             if not lvInTrans then DbConnection.Commit;
             Result.OK := True;
      end;
      else begin
            //
            Case aResultDataType of
              rdtEvent:    DoAfterExecEvent (aRoutine, aProc, Result);
              rdtString:   Result := fnResultInArray_AsString  (aProc, aValues);
              rdtInteger:  Result := fnResultInArray_AsInteger (aProc, aValues);
              rdtResult:   Result := fnResultAsVariant (aProc);
              else Raise Exception.CreateFmt ('Unknown Datatype: %d', [Ord (aResultDataType)]);
            end;
            //
            Case lvInTrans of
              True: if not Result.OK then
                      if aRaiseOnFalse then Raise Exception.CreateFmt ('Exception Raised On Result(False). %s', [aRoutine]);
              else Case Result.OK of
                     True: DbConnection.Commit;
                     else  DbConnection.Rollback;
              end;
            end;
      end;
    end;
    //
  Except
    on e:Exception do begin
      if not lvInTrans then DbConnection.Rollback;
      lvList := ListParamsAsStrings (aProc);
      Raise eDbAccess.CreateFmt ('Error: IntExec_ConditionalCommit. %s-%s-%s %s', [ClassName, aRoutine, aProc.ProcedureName, E.Message], E.Message, lvList);
    end;
  end;
end;

// Routine: DoAfterExecEvent
// Author: M.A.Sargent  Date: 30/11/17  Version: V1.0
//
// Notes:
//
Procedure tBM_BaseTableAPI.DoAfterExecEvent (Const aName: String; aProc: tMASmySQLStoredProc; var aOKVariant: tOKVariant);
begin
  aOKVariant := fnClear_OKVariant;
end;

// Routine: DoExecEvent
// Author: M.A.Sargent  Date: 30/11/17  Version: V1.0
//
// Notes:
//
Procedure tBM_BaseTableAPI.DoExecEvent (Const aEventType: tEventType);
begin
  if Assigned (fOnExecEvent) then fOnExecEvent (Self, aEventType);
end;

// Routine: fnIsInTransaction
// Author: M.A.Sargent  Date: 18/12/12  Version: V1.0
//
// Notes:
//
Function tBM_BaseTableAPI.fnIsInTransaction: Boolean;
begin
  Result := DbConnection.InTransaction;
end;

// Routine: StartTransactionIfNeeded, CommitTransactionIfNeeded, RollbackTransactionIfNeeded
// Author: M.A.Sargent  Date: 11/05/12  Version: V1.0
//
// Notes:
//
Function tBM_BaseTableAPI.StartTransactionIfNeeded: Boolean;
begin
  Result := False;
  if (fInTrans > 0) then
    Case fnIsInTransaction of
      True: Inc (fInTrans);
      else Raise Exception.Create ('Error: StartTransactionIfNeeded');
    end
  else
    if not fnIsInTransaction then begin
      DbConnection.StartTransaction;
      Inc (fInTrans);
      Result := True;
    end;
end;
Procedure tBM_BaseTableAPI.CommitTransactionIfNeeded;
begin
  if (fInTrans > 1) then
       Dec (fInTrans)
  else if (fInTrans = 1) then begin
    DbConnection.Commit;
    Dec (fInTrans);
  end;
end;

Procedure tBM_BaseTableAPI.RollbackTransactionIfNeeded;
begin
  if (fInTrans > 1) then
       Dec (fInTrans)
  else if (fInTrans = 1) then begin
    DbConnection.Rollback;
    Dec (fInTrans);
  end;
end;

// Routine: SendMessage
// Author: M.A.Sargent  Date: 28/05/12  Version: V1.0
//
// Notes:
//
Function tBM_BaseTableAPI.SendMessage (Const Msg: Cardinal; WParam, LParam: Integer): LongInt;
begin
  Result := -1;
  if (fFeedBackHandle <> 0) then
    Result := AppSendMessage (fFeedBackHandle, Msg, WParam, LParam);
end;

// Routine: fnAPIResult
// Author: M.A.Sargent  Date: 24/05/18  Version: V1.0
//
// Notes:
//
Function tBM_BaseTableAPI.fnAPIResult (Const aCondition: Boolean; Const aOKDbResult, aDbResult: Integer; Const aFormat: String; Const Args: array of Const): tOKStrRec;
begin
  Result := fnAPIResult (aCondition, aOKDbResult, aDbResult, fnTS_Format (aFormat, Args));
end;
Function tBM_BaseTableAPI.fnAPIResult (Const aCondition: Boolean; Const aOKDbResult, aDbResult: Integer; Const aMsg: String): tOKStrRec;
begin
  Result.OK := aCondition;                       {}
  if Result.OK then begin                        {if OK then check the Db Result Code}
    //
    Result.ExtendedInfoRec.aCode := aDbResult;   {}
    if (aOKDbResult <> aDbResult) then           {}
      Result.Msg := aMsg;                        {}
  end
  else Result.Msg := aMsg;                       {else just return message}
end;

// Routine: fnAPIResult_Not
// Author: M.A.Sargent  Date: 24/05/18  Version: V1.0
//
// Notes:
//
Function tBM_BaseTableAPI.fnAPIResult_Not (Const aCondition: Boolean; Const aNotDbResult, aDbResult: Integer; Const aFormat: String; Const Args: array of Const): tOKStrRec;
begin
  Result := fnAPIResult_Not (aCondition, aNotDbResult, aDbResult, fnTS_Format (aFormat, Args));
end;
Function tBM_BaseTableAPI.fnAPIResult_Not (Const aCondition: Boolean; Const aNotDbResult, aDbResult: Integer; Const aMsg: String): tOKStrRec;
begin
  Result.OK := aCondition;                       {}
  if Result.OK then begin                        {if OK then check the Db Result Code}
    //
    Result.ExtendedInfoRec.aCode := aDbResult;   {}
    if (aNotDbResult = aDbResult) then           {}
      Result.Msg := aMsg;                        {}
  end
  else Result.Msg := aMsg;                       {else just return message}
end;

// Routine: Clear
// Author: M.A.Sargent  Date: 11/12/12  Version: V1.0
//
// Notes:
//
Procedure tBM_BaseTableAPI.Clear;
begin
end;

Function tBM_BaseTableAPI.fnSetLastError (Const aCondition: Boolean; Const aFormat: string; Const Args: array of const): Boolean;
begin
  Result := fnSetLastError (aCondition, Format (aFormat, Args));
end;

Function tBM_BaseTableAPI.fnSetLastError (Const aCondition: Boolean; Const aMsg: String): Boolean;
begin
  Result := aCondition;
  if not Result then SetLastError (aMsg);
end;

Function tBM_BaseTableAPI.GetDbConnection: tMySQLDatabase;
begin
  Result := fDbConnection;
end;

Procedure tBM_BaseTableAPI.SetLastError (Const aFormat: string; Const Args: array of const);
begin
  SetLAstError (Format (aFormat, Args));
end;

Procedure tBM_BaseTableAPI.SetDbConnection (Const Value: tMySQLDatabase);
begin
  fDbConnection := Value;
  DoSetDbConnection (Value);
end;

Procedure tBM_BaseTableAPI.SetLastError (Const aMsg: String);
begin
  fLastError := aMsg;
end;

// Routine: StartTransaction
// Author: M.A.Sargent  Date: 11/12/12  Version: V1.0
//
// Notes:
//
Function tBM_BaseTableAPI.StartTransaction: Boolean;
begin
  fnRaiseOnFalse (not fnIsInTransaction, 'Error: tBM_BaseTableAPI.StartTransaction. Already In Transaction');
  Result := StartTransactionIfNeeded;
end;
Procedure tBM_BaseTableAPI.CommitTransaction;
begin
  CommitTransactionIfNeeded;
end;
procedure tBM_BaseTableAPI.RollbackTransaction;
begin
  RollbackTransactionIfNeeded;
end;

end.
