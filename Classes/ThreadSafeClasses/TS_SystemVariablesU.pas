//
// Unit: TS_SystemVariablesU
// Author: M.A.Sargent  Date: 25/04/15  Version: V1.0
//         M.A.Sargent        09/12/16           V2.0
//         M.A.Sargent        04/08/17           V3.0
//         M.A.Sargent        13/03/18           V4.0
//         M.A.Sargent        09/08/18           V5.0
//
// Notes:
//  V2.0: Add functions fnTS_AppName & fnTS_AppIniFile
//  V3.0: Updated to make a new version of fnTS_ExeName2
//  V4.0: Updated to remove the DLL CommonMediatorHelperU unit
//  V5.0: Updated to add a function to returnthe AppDataPath, based on the either.
//        1. A Directory passed to the routine TS_SetAppDataPath or
//        2. A Directory creatred using the system CSIDL_APPDATA + the ExeName. eg. C:\ProgramData\Intel
//
unit TS_SystemVariablesU;

interface

Uses Classes, SysUtils, MASRecordStructuresU, ShlObj;

  //
  Function fnTS_Setup: Boolean;
  Function fnTS_AppName: String;
  Function fnTS_AppIniFile: String;
  Function fnTS_ExeName: String;
  Function fnTS_ExeName2: tOKStrRec;
  Function fnTS_AppPath: String;
  Function fnTS_AppDataPath: String;
  Function fnIsIDE: Boolean;
  //
  Function TS_SetApplicationExeName (Const aAppName: String): tOKStrRec;
  //
  Function TS_SetAppDataPath (Const aPathName: String): tOKStrRec; overload;
  Function TS_SetAppDataPath: tOKStrRec; overload;


implementation

Uses MAS_DirectoryU, FormatResultU, MAS_ConstsU, CriticalSectionU, MASCommonU;

var
  gblAppName:      String = '';
  gblMASRORWSynch: tMASRORWSynch = Nil;
  gblIsIDE:        Boolean;
  gblAppDataPath:  String = '';

Function Int_fnGetAppName: String;
begin
  Result := gblAppName;
end;

Function fnIsIDE: Boolean;
begin
  gblMASRORWSynch.EnterRO;
  Try
    Result := gblIsIDE;
  Finally
    gblMASRORWSynch.LeaveRO;
  End;
end;

// Routine: fnTS_Setup
// Author: M.A.Sargent  Date: 16/08/17  Version: V1.0
//
// Notes:
//
Function fnTS_Setup: Boolean;
begin
  Result := fnTS_ExeName2.OK
end;

// Routine: fnTS_ExeName & fnTS_ExeName2
// Author: M.A.Sargent  Date: 05/05/12  Version: V1.0
//
// Notes:
//
Function fnTS_ExeName: String;
begin
  gblMASRORWSynch.EnterRO;
  Try
    Result := ExtractFileName (Int_fnGetAppName);
    if (Result = '') then Raise Exception.Create ('Error: TS_SetExeName Must be Called from MainApplication');
  Finally
    gblMASRORWSynch.LeaveRO;
  End;
end;
Function fnTS_ExeName2: tOKStrRec;
begin
  gblMASRORWSynch.EnterRO;
  Try
    Result.Msg := ExtractFileName (Int_fnGetAppName);
    Result.OK := (Result.Msg <> '');
  Finally
    gblMASRORWSynch.LeaveRO;
  End;
end;
//
Function fnTS_AppPath: String;
begin
  gblMASRORWSynch.EnterRO;
  Try
    Result := ExtractFileDIR (Int_fnGetAppName);
    if (Result = '') then Raise Exception.Create ('Error: TS_SetExeName Must be Called from MainApplication');
  Finally
    gblMASRORWSynch.LeaveRO;
  End;
end;

Function TS_SetApplicationExeName (Const aAppName: String): tOKStrRec;
begin
  Result := fnClear_OKStrRec;
  gblMASRORWSynch.EnterRW;
  Try
    gblAppName     := aAppName;
    gblAppDataPath := ExtractFileDir (aAppName);
  Finally
    gblMASRORWSynch.LeaveRW;
  End;
end;

Function fnTS_AppName: String;
begin
  gblMASRORWSynch.EnterRO;
  Try
    Result := AppendPath (fnTS_AppPath, fnTS_ExeName);
    if (Result = '') then raise Exception.Create ('Error: TS_SetExeName Must be Called from MainApplication');
  Finally
    gblMASRORWSynch.LeaveRO;
  End;
end;
Function fnTS_AppIniFile: String;
begin
  Result := ChangeFileExt (fnTS_AppName, cFILE_EXTN_INI);
end;

// Routine: fnTS_AppDataPath
// Author: M.A.Sargent  Date: 09/08/18  Version: V1.0
//
// Notes:
//
Function fnTS_AppDataPath: String;
begin
  gblMASRORWSynch.EnterRO;
  Try
    Result := gblAppDataPath;
    if (Result = '') then Raise Exception.Create ('Error: TS_SetExeName Must be Called from MainApplication');
  Finally
    gblMASRORWSynch.LeaveRO;
  End;
end;

// Routine: TS_SetAppDataPath
// Author: M.A.Sargent  Date: 09/08/18  Version: V1.0
//
// Notes:
//
Function TS_SetAppDataPath (Const aPathName: String): tOKStrRec;
begin
  Result := fnClear_OKStrRec;
  gblMASRORWSynch.EnterRW;
  Try
    fnRaiseOnFalse (IsEmpty (gblAppDataPath), 'Error: TS_SetAppDataPath. A PathName can not be Blank');
    gblAppDataPath := aPathName
  Finally
    gblMASRORWSynch.LeaveRW;
  End;
end;
Function TS_SetAppDataPath: tOKStrRec; overload;
var
  lvDir: String;
begin
  lvDir := fnTS_ExeName;
  lvDir := ChangeFileExt (lvDir, '');
  lvDir := AppendPath (GetSystemPath (CSIDL_APPDATA), lvDir);
  //
  Result := TS_SetAppDataPath (lvDir);
end;

Initialization
  gblMASRORWSynch := tMASRORWSynch.Create;
  //
  gblIsIDE := (DebugHook > 0);
Finalization
  gblMASRORWSynch.Free;
end.
