//
// Unit: D7_ServiceControlMgr_HelpersU
// Author: M.A.Sargent  Date: 30/08/18  Version: V1.0
//
// Notes:
//
unit D7_ServiceControlMgr_HelpersU;

interface

Uses Classes, Windows, MASRecordStructuresU, SysUtils, Forms, DLLListU, AppDataU, CriticalSectionU, IdThreadSafe, MAS_ConstsU,
    {$IFDEF VER150}
    TSUK_D7_ConstsU,
    WinSvc,
    {$ELSE}
    Winapi.WinSvc,
    {$ENDIF}
    TSUK_ConstsU;
  //
  Function fnSetupService   (Const aId: Integer; Const aParams: tStrings): tOKStrRec;
  //
  Function fnStartService   (Const aServiceName: String): tOKStrRec;
  Function fnStopService    (Const aServiceName: String): tOKStrRec;
  Function fnQueryService   (Const aServiceName: String; var aValue: Integer): tOKStrRec;
  //
  Function fnServiceStatus  (Const aValue: Integer): String;
  //
  Function DLL_SCM_Setup_D7        (Const aId: Integer; Const aParams: pAnsiChar): tOKIntegerRec; safecall; external 'D7_ServiceControlMgr.dll';
  Function DLL_SCM_Setup           (Const aId: Integer; Const aParams: pChar): tOKIntegerRec; safecall; external 'D7_ServiceControlMgr.dll';
  //
  Function DLL_SCM_GetFeedBack     (MessageOut: pAnsiChar): Boolean; safecall; external 'D7_ServiceControlMgr.dll';
  //
  Function DLL_SCM_StartService_D7 (Const aServiceName: pAnsiChar): tOKIntegerRec; safecall; external 'D7_ServiceControlMgr.dll';
  Function DLL_SCM_StartService    (Const aServiceName: pChar): tOKIntegerRec; safecall; external 'D7_ServiceControlMgr.dll';
  //
  Function DLL_SCM_StopService_D7  (Const aServiceName: pAnsiChar): tOKIntegerRec; safecall; external 'D7_ServiceControlMgr.dll';
  Function DLL_SCM_StopService     (Const aServiceName: pChar): tOKIntegerRec; safecall; external 'D7_ServiceControlMgr.dll';
  //
  Function DLL_SCM_QueryService_D7 (Const aServiceName: pAnsiChar; var aValue: Integer): tOKIntegerRec; safecall; external 'D7_ServiceControlMgr.dll';
  Function DLL_SCM_QueryService    (Const aServiceName: pChar; var aValue: Integer): tOKIntegerRec; safecall; external 'D7_ServiceControlMgr.dll';

implementation

Uses FormatResultU, MAS_DS_ConstsU, MASCommon_UtilsU, MASStringListU, MASCommonU;

// Routine: IntGetFeedBack
// Author: M.A.Sargent  Date: 05/10/16  Version: V1.0
//
// Notes:
//
Function IntGetFeedBack (Const aResult: tOKIntegerRec): tOKStrRec;
var
  lvRes: pAnsiChar;
  lvResult: tOKStrRec;
begin
  Result.OK := aResult.OK;
  if (aResult.Int > 0) then begin
    //
    //lvRes := StrAlloc (aResult.Int+1);
    GetMem (lvRes, (aResult.Int+1));
    Try
      Try
        //
        lvResult := fnResult (DLL_SCM_GetFeedBack (lvRes), 'Internal Error In IntGetFeedBack.');
        RaiseOnFalse (lvResult);
        if lvResult.OK then Result.Msg := Trim (StrPas (lvRes));
      Except
        on e:Exception do
          Result := fnResult ('Error: IntGetFeedBack. (%s)', [e.Message]);
      end;
    Finally
      //StrDispose (lvRes);
      FreeMem (lvRes);
    end;
  end;
end;

// Routine: fnServiceStatus
// Author: M.A.Sargent  Date: 26/06/18  Version: V1.0
//
// Notes:
//
Function fnServiceStatus (Const aValue: Integer): String;
begin
  Case aValue of
    SERVICE_STOPPED:          Result := 'Stopped';
    SERVICE_START_PENDING:    Result := 'Start Pending';
    SERVICE_STOP_PENDING:     Result := 'Stop Pending';
    SERVICE_RUNNING:          Result := 'Running';
    SERVICE_CONTINUE_PENDING: Result := 'Continue Pending';
    SERVICE_PAUSE_PENDING:    Result := 'Pause Pending';
    SERVICE_PAUSED:           Result := 'Paused';
    else                      Result := ('Unknown Value: '+IntToStr(aValue));
  End;
end;

// Routine: fnSetupService
// Author: M.A.Sargent  Date: 29/08/18  Version: V1.0
//
// Notes:
//
Function fnSetupService (Const aId: Integer; Const aParams: tStrings): tOKStrRec;
var
  lvRec:    tOKIntegerRec;
  lvParams: String;
begin
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;  
  {$ELSE}
    Result.Clear;
  {$ENDIF}
  Try
    lvParams := IfTrue ((Assigned (aParams)), aParams.Text, '');

    {$IFDEF VER150}
    lvRec := DLL_SCM_Setup_D7 (aId, pAnsiChar (lvParams));
    {$ELSE}
    lvRec := DLL_SCM_Setup    (aId, pChar (lvParams));
    {$ENDIF}
    //
    Result.OK := lvRec.OK;
    Case Result.OK of
      True:;//hCopyFromList (lvList, aList);
      else Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResultException ('fnSetupService', 'Error', e);
  end;
end;

// Routine: fnStartService
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnStartService (Const aServiceName: String): tOKStrRec;
var
  lvRec: tOKIntegerRec;
begin
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  Try
    //
    {$IFDEF VER150}
    lvRec := DLL_SCM_StartService_D7 (pAnsiChar (aServiceName));
    {$ELSE}
    lvRec := DLL_SCM_StartService (pChar (aServiceName));
    {$ENDIF}
    Result.OK := lvRec.OK;
    Case Result.OK of
      True: Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResultException ('fnStartService', 'Error', e);
  end;
end;

// Routine: fnStopService
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnStopService (Const aServiceName: String): tOKStrRec;
var
  lvRec: tOKIntegerRec;
begin
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  Try
    //
    {$IFDEF VER150}
    lvRec := DLL_SCM_StopService_D7 (pAnsiChar (aServiceName));
    {$ELSE}
    lvRec := DLL_SCM_StopService (pChar (aServiceName));
    {$ENDIF}
    Result.OK := lvRec.OK;
    Case Result.OK of
      True: Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResultException ('fnStopService', 'Error', e);
  end;
end;

// Routine: fnQueryService
// Author: M.A.Sargent  Date: 30/08/18  Version: V1.0
//
// Notes:
//
Function fnQueryService (Const aServiceName: String; var aValue: Integer): tOKStrRec;
var
  lvRec: tOKIntegerRec;
begin
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  Try
    //
    {$IFDEF VER150}
    lvRec := DLL_SCM_QueryService_D7 (pAnsiChar (aServiceName), aValue);
    {$ELSE}
    lvRec := DLL_SCM_QueryService (pChar (aServiceName), aValue);
    {$ENDIF}
    Result.OK := lvRec.OK;
    Case Result.OK of
      True: Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResultException ('fnQueryService', 'Error', e);
  end;
end;

end.
