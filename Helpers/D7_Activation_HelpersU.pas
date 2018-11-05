//
// Unit: D7_Activation_HelpersU
// Author: M.A.Sargent  Date: 18/10/17  Version: V1.0
//
// Notes:
//
unit D7_Activation_HelpersU;

interface

Uses Classes, Windows, MASRecordStructuresU, SysUtils, Forms, TSUK_ConstsU, DLLListU, AppDataU, CriticalSectionU,
      MAS_IniU, TSUK_D7_ConstsU;

  //
  Function fnActivation_Setup (Const aCommonDir: string;
                                Const aUrl, aUserName, aPwd, aSageAccount, aSaleNumber, aFingerPrint, aProduct, aVersion, aComputer: String;
                                 Const aPort: Integer): tOKStrRec; overload;
  Function fnActivation_Setup (Const aId: Integer; Const aParams: tStrings): tOKStrRec; overload;
  //
  Function fnCheckActivation  (var aCheckLicense: tCheckLicense): tOKStrRec; overload;
  Function fnActivate         (var aActivationResult: tActivationResult): tOKStrRec; overload;
  Function fnGetLicense       (var aList: tStrings): tOKStrRec;
  //
  Function fnPing: tOKStrRec;
  Function fnCloseDown: tOKStrRec;
  //

Type
  tDLL_AS_Setup           = Function (Const aId: Integer; Const aParams: pAnsiChar): tOKIntegerRec; safecall;
  tDLL_AS_GetFeedBack     = Function (MessageOut: pAnsiChar): Boolean; safecall;
  //
  tDLL_AS_CheckActivation = Function (var aCheckLicense: tCheckLicense): tOKIntegerRec; safecall;
  tDLL_AS_Activate        = Function (var aActivationResult: tActivationResult): tOKIntegerRec; safecall;
  tDLL_AS_GetLicense      = Function: tOKIntegerRec; safecall;

  tDLL_AS_Ping            = Function: tOKIntegerRec; safecall;
  tDLL_AS_CloseDown       = Function: tOKIntegerRec; safecall;

implementation

Uses FormatResultU, MAS_DS_ConstsU, MASCommon_UtilsU, MASStringListU, MASCommonU;

var
  gblDLLList:   tDLLList             = Nil;
  gblFeedBack:  tDLL_AS_GetFeedBack  = Nil;
  gblDoneSetup: tIdThreadSafeBoolean = Nil;

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
        if not Assigned (gblFeedBack) then begin
          gblFeedBack := tDLL_AS_GetFeedBack (gblDLLList.GetDLLAddress (cDLL_AS_ACTIVATION, cDLL_AS_FEEDBACK));
        end;

        lvResult := fnResult (gblFeedBack (lvRes), 'Internal Error In IntGetFeedBack.');
        RaiseOnFalse (lvResult);
        if lvResult.OK then Result.Msg := StrPas (lvRes);
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

// Routine: fnActivation_Setup
// Author: M.A.Sargent  Date: 01/12/17  Version: V1.0
//
// Notes:
//
Function fnActivation_Setup (Const aCommonDir: string;
                              Const aUrl, aUserName, aPwd, aSageAccount, aSaleNumber, aFingerPrint, aProduct, aVersion, aComputer: String;
                               Const aPort: Integer): tOKStrRec;
var
  lvList:          tMASStringList;
  lvEnableLogging: Boolean;
  lvIniFileName:   String;
begin
  lvList := tMASStringList.Create;
  Try
    lvIniFileName := h_fnIniFileNameFromModuleName (aCommonDir);
    lvEnableLogging := h_fnGetIniValueAsBoolean (lvIniFileName, cCLIENT_ACTIVATIONSERVER_SETTINGS, cCAS_ENABLELOGGING, False);
    //
    lvList.AddValues (cCAS_ENABLELOGGING, IfTrue (lvEnableLogging, '1', '0'));
    lvList.AddValues (cCLIENT_HOST,             aUrl);
    lvList.AddValues (cCLIENT_PORT,             aPort);
    lvList.AddValues (cCLIENT_USERNAME,         aUserName);
    lvList.AddValues (cCLIENT_PASSWORD,         aPwd);
    lvList.AddValues (cLOCAL_SAGE_ACCOUNT_CODE, aSageAccount);
    lvList.AddValues (cLOCAL_SALES_NUMBER,      aSaleNumber);
    lvList.AddValues (cLOCAL_FINGER_PRINT,      aFingerPrint);
    lvList.AddValues (cLOCAL_PRODUCT_NAME,      aProduct);
    lvList.AddValues (cLOCAL_PRODUCT_VERSION,   aVersion);
    lvList.AddValues (cLOCAL_COMPUTER_NAME,     aComputer);
    Result := fnActivation_Setup (cAD_APPLICATION_ID, lvList);
  Finally
    lvList.Free;
  end;
end;

Function fnActivation_Setup (Const aId: Integer; Const aParams: tStrings): tOKStrRec;
var
  lvRec:     tOKIntegerRec;
  lvHandle:  tHandle;
  lvSetup:   tDLL_AS_Setup;
  lvAnsiStr: AnsiString;
begin
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  Try
    if not gblDoneSetup.Value then begin
      //
      lvHandle := gblDLLList.OpenLibrary (cDLL_AS_ACTIVATION);
      Result := fnResult ((lvHandle > 0), 'Error: fnActivation_Setup. %s', [gblDLLList.LastError]);
      // if OK
      if fnChkOK (Result) then begin
        //
        lvSetup  := tDLL_AS_Setup (gblDLLList.GetDLLAddress (cDLL_AS_ACTIVATION, cDLL_AS_SETUP));
        Case Assigned (aParams) of
          True: begin
                lvAnsiStr := aParams.Text;
                lvRec := lvSetup (aId, pAnsiChar (lvAnsiStr));
          end
          else  lvRec := lvSetup (aId, pAnsiChar (''));
        End;
        //
        Result.OK := lvRec.OK;
        Case Result.OK of
          True:;//hCopyFromList (lvList, aList);
          else Result := IntGetFeedBack (lvRec);
        end;
      end;
      //
      gblDoneSetup.Value := True;
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnActivation_Setup. %s', [e.Message]);
  end;
end;

// Routine: fnCheckActivation
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnCheckActivation (var aCheckLicense: tCheckLicense): tOKStrRec; overload;
var
  lvRec:        tOKIntegerRec;
  lvActivation: tDLL_AS_CheckActivation;
begin
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  Try
    //
    //
    lvActivation := tDLL_AS_CheckActivation (gblDLLList.GetDLLAddress (cDLL_AS_ACTIVATION, cDLL_AS_CHECK));

    lvRec := lvActivation (aCheckLicense);
    Result.OK := lvRec.OK;
    Case Result.OK of
      True:;// Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnCheckActivation. %s', [e.Message]);
  end;
end;

// Routine: fnActivate
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnActivate (var aActivationResult: tActivationResult): tOKStrRec;
var
  lvRec:    tOKIntegerRec;
  lvActive: tDLL_AS_Activate;
begin
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  Try
    //
    //
    lvActive := tDLL_AS_Activate (gblDLLList.GetDLLAddress (cDLL_AS_ACTIVATION, cDLL_AS_ACTIVATE));

    lvRec := lvActive (aActivationResult);
    Result.OK := lvRec.OK;
    Case Result.OK of
      True:;// Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnCheckSecurity. %s', [e.Message]);
  end;
end;

// Routine: fnGetLicense
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
//
Function fnGetLicense (var aList: tStrings): tOKStrRec;
var
  lvRes:        tOKStrRec;
  lvRec:        tOKIntegerRec;
  lvGetLicense: tDLL_AS_GetLicense;
begin
  Result := fnResult (Assigned (aList), 'Error: fmGetLicense. aList Must be Assigned');
  if not fnChkOK (Result) then Exit;
  Try
    //
    //
    lvGetLicense := tDLL_AS_GetLicense (gblDLLList.GetDLLAddress (cDLL_AS_ACTIVATION, cDLL_AS_GETLICENSE));

    lvRec := lvGetLicense;
    Result.OK := lvRec.OK;
    Case Result.OK of
      True: begin
            lvRes := IntGetFeedBack (lvRec);
            fnRaiseOnFalse (lvRes);
            aList.Text := lvRes.Msg;
      end
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnCheckSecurity. %s', [e.Message]);
  end;
end;

// Routine: fnPing
// Author: M.A.Sargent  Date: 13/05/18  Version: V1.0
//
// Notes:
//
Function fnPing: tOKStrRec;
var
  lvRec:   tOKIntegerRec;
  lvPing: tDLL_AS_Ping;
begin
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  Try
    lvPing := tDLL_AS_Ping (gblDLLList.GetDLLAddress (cDLL_AS_ACTIVATION, cDLL_AS_PING));

    lvRec := lvPing;
    Result.OK := lvRec.OK;
    Case Result.OK of
      True:;
      else Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnPing. %s', [e.Message]);
  end;
end;

// Routine: fnCloseDown
// Author: M.A.Sargent  Date: 04/08/17  Version: V1.0
//
// Notes:
//
Function fnCloseDown: tOKStrRec;
var
  lvRec:   tOKIntegerRec;
  lvClose: tDLL_AS_CloseDown;
begin
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  Try
    if gblDoneSetup.Value then begin
      //
      lvClose := tDLL_AS_CloseDown (gblDLLList.GetDLLAddress (cDLL_AS_ACTIVATION, cDLL_AS_CLOSEDOWN));

      lvRec := lvClose;
      Result.OK := lvRec.OK;
      Case Result.OK of
        True:;
        else Result := IntGetFeedBack (lvRec);
      end;
      //
      gblDoneSetup.Value := False;
    end;
    //
  except
    on e:Exception do
      Result := fnResult ('Error: fnDSCloseDown. %s', [e.Message]);
  end;
end;

Initialization
  gblDLLList         := tDLLList.Create;
  gblDoneSetup       := tIdThreadSafeBoolean.Create;
  gblDoneSetup.Value := False;
Finalization
  gblDLLList.Free;
  gblDoneSetup.Free;
end.
