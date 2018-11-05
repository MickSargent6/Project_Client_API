//
// Unit: MAS_MySql_PollingMachine_APIU
// Author: M.A.Sargent  Date: 24/05/18  Version: V1.0
//
// Notes:
//
unit MAS_MySql_PollingMachine_APIU;

interface

Uses Classes, MAS_MySql_BaseTableU, MASRecordStructuresU, TSUK_D7_ConstsU, TSUK_ConstsU, SysUtils, LogFileProcess_D7U;

Type
  tPollingMachine_API = Class (tBM_BaseTableAPI)
  Public
    //
    Function fnCheckRegistration (Const aFingerPrint: String): tOKStrRec;
    Function fnRegistration      (Const aFingerPrint, aDisplayName: String; Const aAllowRoaming: Boolean): tOKStrRec;
    //
    Function fnWriteLog_Critial  (Const aFingerPrint, aName, aMessage, aMyIP: String; Const aDate: TDateTime): tOKStrRec;
    Function fnWriteLog          (Const aTypeMsg: tTypeMsg; Const aFingerPrint, aName, aMessage, aMyIP: String; Const aDate: TDateTime): tOKStrRec;
    //
    Function fnUpd_FileNames     (Const aFingerPrint, aFileName: String; Const aLineNumber: Integer; Const aPollingFileType: tPollingFileType): tOKStrRec;
    Function fnDel_FileNames     (Const aFingerPrint: String; Const aPollingFileType: tPollingFileType): tOKStrRec;
    Function fnUpd_Settings      (Const aFingerPrint, aLevel1, aLevel2, aValue: String): tOKStrRec;
    //
    Function fnDel_JustOnceEntry (Const aFingerPrint: String; Const aFileName: String): tOKStrRec;
    //
    Function fnLog_HeartBeat     (Const aFingerPrint, aMyIP: String): tOKStrRec;
    //
    // Added to process files polling, Insert, Updated & Delete
    Function fnIns_PollingFile   (Const aFingerPrint, aOrigFileName, aFileName, aMD5: String; Const aLineCount: Integer): tOKStrRec;
    Function fnUpd_PollingFile   (Const aPK: Integer; Const aValue: tPollingFileStatus): tOKStrRec;

    Function fnDel_PollingFiles  (Const aFingerPrint: String): tOKStrRec;
  end;

implementation

Uses FormatResultU, MAS_ConstsU, MASDBUtilsCommonU;

{ tPollingMachine_API }

// Routine: fnCheckRegistration
// Author: M.A.Sargent  Date: 24/05/2018  Version: V1.0
//
// Notes:
//
Function tPollingMachine_API.fnCheckRegistration (Const aFingerPrint: String): tOKStrRec;
var
  lvRes: tOKIntegerRec;
begin
  Result := fnClear_OKStrRec;
  Try
    lvRes  := Self.fnProcAsInt ('fnCheckRegistration', cSP_CHK_POLLING_MACHINE, [cI_FINGER_PRINT], [aFingerPrint], True);
    Result := fnAPIResult_Not (lvRes.OK, cMC_ZERO_ROWS, lvRes.Int, 'Error: fnCheckRegistration. FingerPrint is Not Registered. (%s)', [aFingerPrint]);
  Except
    on e:Exception do
      Result := fnResultException ('fnCheckRegistration', e);
  end;
end;

// Routine: fnRegistration
// Author: M.A.Sargent  Date: 24/05/2018  Version: V1.0
//
// Notes:
//
Function tPollingMachine_API.fnRegistration (Const aFingerPrint, aDisplayName: String; Const aAllowRoaming: Boolean): tOKStrRec;
var
  lvRes: tOKIntegerRec;
begin
  Result := fnClear_OKStrRec;
  Try
    lvRes := Self.fnProcCount ('fnRegistration', cSP_UPD_POLLING_MACHINE,
                                [cI_FINGER_PRINT, cI_DISPLAY_NAME, cI_ALLOW_ROAMING],
                                 [aFingerPrint, aDisplayName, fnBooleanToDBLogical (aAllowRoaming)], True, rtOneRow);
    //  Should work
    fnRaiseOnFalse (lvRes.OK, 'Error: fnRegistration. Failed to Insert or Update record for FingerPrint. (%s)', [aFingerPrint]);
  Except
    on e:Exception do
      Result := fnResultException ('fnRegistration', e);
  end;
end;

// Routine: fnWriteLog_Critial & fnWriteLog
// Author: M.A.Sargent  Date: 24/05/2018  Version: V1.0
//
// Notes:
//
Function tPollingMachine_API.fnWriteLog_Critial (Const aFingerPrint, aName, aMessage, aMyIP: String; Const aDate: TDateTime): tOKStrRec;
begin
  Result := fnWriteLog (tmCritical, aFingerPrint, aName, aMessage, aMyIP, aDate);
end;
Function tPollingMachine_API.fnWriteLog (Const aTypeMsg: tTypeMsg; Const aFingerPrint, aName, aMessage, aMyIP: String; Const aDate: TDateTime): tOKStrRec;
begin
  Result := fnClear_OKStrRec;
  Try
    Self.fnProc ('fnWriteLog', cSP_INS_POLLING_MACHINE_LOG,
                  [cI_MSG_TYPE,                   cI_FINGER_PRINT, cI_NAME, cI_DATA,  cI_MY_IP, cI_DATE],
                   [fnTypeMsgToDbValue (aTypeMsg), aFingerPrint,    aName,   aMessage, aMyIP,    aDate], True);
  Except
    on e:Exception do
      Result := fnResultException ('fnWriteLog', e);
  end;
end;

// Routine: fnUpd_FileNames
// Author: M.A.Sargent  Date: 29/05/2018  Version: V1.0
//
// Notes:
//
Function tPollingMachine_API.fnUpd_FileNames (Const aFingerPrint, aFileName: String; Const aLineNumber: Integer;
                                               Const aPollingFileType: tPollingFileType): tOKStrRec;
var
  lvRes:      tOKIntegerRec;
  lvFileName: String;
begin
  Result := fnClear_OKStrRec;
  Try
    lvFileName := StringReplace (aFileName, '\', '/', [rfReplaceAll]);
    lvRes := Self.fnProcCount ('fnUpd_FileNames', cSP_UPD_POLLING_MACHINE_FILENAMES,
                               [cI_FINGER_PRINT, cI_LINE_NUMBER, cI_FILENAME, cI_FREQUENCY],
                                [aFingerPrint,    aLineNumber,    lvFileName, fnPollingFileTypeToDbValue (aPollingFileType)], True, rtOneRow);
    //  Should work
    fnRaiseOnFalse (lvRes.OK, 'Error: fnUpd_FileNames. Failed to Insert record for FingerPrint. (%s) Line No: %d', [aFingerPrint, aLineNumber]);
  Except
    on e:Exception do
      Result := fnResultException ('fnUpd_FileNames', e);
  end;
end;

// Routine: fnDel_FileNames
// Author: M.A.Sargent  Date: 29/05/2018  Version: V1.0
//
// Notes:
//
Function tPollingMachine_API.fnDel_FileNames (Const aFingerPrint: String; Const aPollingFileType: tPollingFileType): tOKStrRec;
var
  lvRes: tOKIntegerRec;
begin
  Result := fnClear_OKStrRec;
  Try
    lvRes := Self.fnProcCount ('fnDel_FileNames', cSP_DEL_POLLING_MACHINE_FILENAMES,
                               [cI_FINGER_PRINT, cI_FREQUENCY],
                                [aFingerPrint, fnPollingFileTypeToDbValue (aPollingFileType)], True, rtNotBothered);
    //  Should work
    fnRaiseOnFalse (lvRes.OK, 'Error: fnDel_FileNames. Failed to Insert record for FingerPrint. (%s)', [aFingerPrint]);
  Except
    on e:Exception do
      Result := fnResultException ('fnDel_FileNames', e);
  end;
end;

// Routine: fnUpd_Settings
// Author: M.A.Sargent  Date: 29/05/2018  Version: V1.0
//
// Notes:
//
Function tPollingMachine_API.fnUpd_Settings (Const aFingerPrint, aLevel1, aLevel2, aValue: String): tOKStrRec;
var
  lvRes: tOKIntegerRec;
begin
  Result := fnClear_OKStrRec;
  Try
    lvRes := Self.fnProcCount ('fnUpd_Settings', cSP_UPD_POLLING_MACHINE_SETTINGS,
                                [cI_FINGER_PRINT, cI_LEVEL1 , cI_LEVEL2 , cI_VALUE],
                                 [aFingerPrint,    aLevel1,    aLevel2,    aValue], True, rtOneRow);
    //  Should work
    fnRaiseOnFalse (lvRes.OK, 'Error: fnUpd_Settings. Failed to Insert record for FingerPrint. (%s) %s/%s %s', [aFingerPrint, aLevel1, aLevel2, aValue]);
  Except
    on e:Exception do
      Result := fnResultException ('fnUpd_Settings', e);
  end;
end;

// Routine: fnLog_HeartBeat
// Author: M.A.Sargent  Date: 08/06/2018  Version: V1.0
//
// Notes:
//
Function tPollingMachine_API.fnLog_HeartBeat (Const aFingerPrint, aMyIP: String): tOKStrRec;
var
  lvRes: tOKIntegerRec;
begin
  Result := fnClear_OKStrRec;
  Try
    lvRes := Self.fnProcCount ('fnLog_HeartBeat', cSP_LOG_POLLING_MACHINE_HEARTBEAT,
                                [cI_FINGER_PRINT, cI_MY_IP, cI_DATE], [aFingerPrint, aMyIP, Now], True, rtOneRow);
    //  Should work
    fnRaiseOnFalse (lvRes.OK, 'Error: fnLog_HeartBeat. Failed to Log HeartBeat record for FingerPrint. (%s)', [aFingerPrint]);
  Except
    on e:Exception do
      Result := fnResultException ('fnUpd_Settings', e);
  end;
end;

// Routine: fnIns_PollingFile
// Author: M.A.Sargent  Date: 11/06/2018  Version: V1.0
//
// Notes:
//
Function tPollingMachine_API.fnIns_PollingFile (Const aFingerPrint, aOrigFileName, aFileName, aMD5: String; Const aLineCount: Integer): tOKStrRec;
var
  lvRes:          tOKIntegerRec;
  lvOrigFileName: String;
  lvFileName:     String;
begin
  Result := fnClear_OKStrRec;
  Try
    lvOrigFileName := StringReplace (aOrigFileName, '\', '/', [rfReplaceAll]);
    lvFileName     := StringReplace (aFileName, '\', '/', [rfReplaceAll]);
    //
    lvRes := Self.fnProcCount ('fnIns_PollingFile', cSP_INS_POLLING_FILES,
                                [cI_FINGER_PRINT, cI_ORIG_FILENAME, cI_FILENAME, cI_LINES, cI_MD5],
                                 [aFingerPrint, lvOrigFileName, lvFileName, aLineCount, aMD5], True, rtOneRow);
    //  Should work
    fnRaiseOnFalse (lvRes.OK, 'Error: fnIns_PollingFile. Failed to Insert New Polling File Record. (%s) %s', [aOrigFileName, aFileName]);
  Except
    on e:Exception do
      Result := fnResultException ('fnIns_PollingFile', e);
  end;
end;

// Routine: fnUpd_PollingFile
// Author: M.A.Sargent  Date: 11/06/2018  Version: V1.0
//
// Notes:
//
Function tPollingMachine_API.fnUpd_PollingFile (Const aPK: Integer; Const aValue: tPollingFileStatus): tOKStrRec;
var
  lvRes: tOKIntegerRec;
begin
  Result := fnClear_OKStrRec;
  Try
    lvRes := Self.fnProcCount ('fnUpd_PollingFile', cSP_UPD_POLLING_FILES, [cI_PK, cI_STATUS],
                                                                            [aPK, fnPollingFileStatusToDbValue (aValue)], True, rtOneRow);
    //  Should work
    fnRaiseOnFalse (lvRes.OK, 'Error: fnUpd_PollingFile. Failed to Update Polling File Record. (%d)', [aPK]);
  Except
    on e:Exception do
      Result := fnResultException ('fnUpd_PollingFile', e);
  end;
end;

// Routine: fnDeletePollingFile
// Author: M.A.Sargent  Date: 11/06/2018  Version: V1.0
//
// Notes:
//
Function tPollingMachine_API.fnDel_PollingFiles (Const aFingerPrint: String): tOKStrRec;
var
  lvRes: tOKIntegerRec;
begin
  Result := fnClear_OKStrRec;
  Try
    lvRes := Self.fnProcCount ('fnDel_PollingFiles', cSP_DEL_POLLING_FILES, [cI_FINGER_PRINT], [aFingerPrint], True, rtNotBothered);
    //  Should work
    fnRaiseOnFalse (lvRes.OK, 'Error: fnDel_PollingFiles. Failed to Delete Old Polling File Records');
  Except
    on e:Exception do
      Result := fnResultException ('fnDel_PollingFiles', e);
  end;
end;

// Routine: fnDel_JustOnceEntry
// Author: M.A.Sargent  Date: 13/06/2018  Version: V1.0
//
// Notes:
//
Function tPollingMachine_API.fnDel_JustOnceEntry (Const aFingerPrint, aFileName: String): tOKStrRec;
var
  lvRes:      tOKIntegerRec;
  lvFileName: String;
begin
  Result := fnClear_OKStrRec;
  Try
    lvFileName := StringReplace (aFileName, '\', '/', [rfReplaceAll]);
    lvRes := Self.fnProcCount ('fnDel_JustOnceEntry', cSP_DEL_POLLINg_MACHINE_SINGLEFILENAME,
                               [cI_FINGER_PRINT, cI_FILENAME, cI_FREQUENCY],
                                [aFingerPrint,   lvFileName,  fnPollingFileTypeToDbValue (pftJustOnce)], True, rtOneRow);
    //  Should work
    fnRaiseOnFalse (lvRes.OK, 'Error: fnDel_JustOnceEntry. Failed to Delete JustOnce Entry for FingerPrint. (%s) Filename: %s', [aFingerPrint, aFileName]);
  Except
    on e:Exception do
      Result := fnResultException ('fnDel_JustOnceEntry', e);
  end;
end;

end.
