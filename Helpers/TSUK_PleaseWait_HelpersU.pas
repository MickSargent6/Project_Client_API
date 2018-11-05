//
// Unit: TSUK_PleaseWait_HelpersU
// Author: M.A.Sargent  Date: 05/11/2018  Version: V1.0
//
unit TSUK_PleaseWait_HelpersU;

interface

Uses MASMessagesU, TSUK_D7_ConstsU, Forms;

  //
  Function fnPleaseWait_Start     (Const aInt: Integer; Const aMsg: String): Boolean;
  Function fnPleaseWait_Progress  (Const aPercentage: Integer): Boolean;

  Function fnPleaseWait_Start2    (Const aInt, aTotalParts: Integer; Const aMsg: String): Boolean;
  Function fnPleaseWait_Progress2: Boolean;


  Function fnPleaseWait_Info      (Const aMsg: String): Boolean;
  Function fnPleaseWait_End: Boolean;

implementation

Uses MASCommonU;

// Routine: fnPleaseWait_Start & fnPleaseWait_Progress
// Author: M.A.Sargent  Date: 05/11/18  Version: V1.0
//
// Notes:
//
Function fnPleaseWait_Start (Const aInt: Integer; Const aMsg: String): Boolean;
var
  lvHandle: tHandle;
begin
  Result := True;
  lvHandle := fnMainFormHandle;
  AppPostMessage (lvHandle, um_PleaseWait_Msg, cPLEASEWAIT_CREATE, aInt);
  if not IsEmpty (aMsg) then Send_WM_COPYDATA (lvHandle, aMsg);
  Application.ProcessMessages;
end;
Function fnPleaseWait_Progress (Const aPercentage: Integer): Boolean;
begin
  Result := True;
  AppPostMessage (um_PleaseWait_Msg, cPLEASEWAIT_PROGRESS, aPercentage);
  Application.ProcessMessages;
end;

// Routine: fnPleaseWait_Start2 & fnPleaseWait_Progress2
// Author: M.A.Sargent  Date: 05/11/18  Version: V1.0
//
// Notes:
//
Function fnPleaseWait_Start2 (Const aInt, aTotalParts: Integer; Const aMsg: String): Boolean;
var
  lvHandle: tHandle;
begin
  Result := fnPleaseWait_Start (aInt, aMsg);
  if Result then begin
    lvHandle := fnMainFormHandle;
    AppPostMessage (lvHandle, um_PleaseWait_Msg, cPLEASEWAIT_CREATE_SETUP, aTotalParts);
    Application.ProcessMessages;
  end;
end;
Function fnPleaseWait_Progress2: Boolean;
begin
  Result := True;
  AppPostMessage (um_PleaseWait_Msg, cPLEASEWAIT_PROGRESS_COUNT, 0);
  Application.ProcessMessages;
end;

// Routine: fnPleaseWait_Info & fnPleaseWait_End
// Author: M.A.Sargent  Date: 05/11/18  Version: V1.0
//
// Notes:
//
Function fnPleaseWait_Info (Const aMsg: String): Boolean;
var
  lvHandle: tHandle;
begin
  Result := True;
  if not IsEmpty (aMsg) then begin
    lvHandle := fnMainFormHandle;
    Send_WM_COPYDATA (lvHandle, cPLEASEWAIT_PROGRESS, aMsg);
    Application.ProcessMessages;
  end;
end;
Function fnPleaseWait_End: Boolean;
begin
  Result := True;
  AppPostMessage (um_PleaseWait_Msg, cPLEASEWAIT_FREE, 0);
end;

end.
