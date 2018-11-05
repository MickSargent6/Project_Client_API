//
// Unit: TSUK_ActivationClient_HelpersU
// Author: M.A.Sargent  Date: 18/10/17  Version: V1.0
//         M.A.Sargent        28/08/18           V2.0
//
// Notes:
//  V2.0: Updated fnActivationClient_CloseDown 
//
unit TSUK_ActivationClient_HelpersU;

interface

Uses Classes, Windows, MASRecordStructuresU, SysUtils, Forms, TSUK_D7_ConstsU, DLLListU, AppDataU, CriticalSectionU, TSUK_D7_UtilsU,
      TSUK_ConstsU;

  // This version Creates a UserName based on the Sage Account Number
  Function fnActivationClient_Setup (Const aCommonDir: string;
                                      Const aUrl, aPwd, aSageAccount, aSaleNumber, aFingerPrint, aProduct, aVersion: String;
                                       Const aPort: Integer; var aActivationFileStatus: tActivationFileStatus): tOKStrRec; overload;
  // After testing do not expose this version used internally
  Function fnActivationClient_Setup      (Const aCommonDir: string;
                                           Const aUrl, aUserName, aPwd, aSageAccount, aSaleNumber, aFingerPrint, aProduct, aVersion: String;
                                            Const aPort: Integer; var aActivationFileStatus: tActivationFileStatus): tOKStrRec; overload;
  Function fnActivationClient_Setup      (Const aId: Integer; Const aParams: tStrings; var aActivationFileStatus: tActivationFileStatus): tOKStrRec; overload;
  //
  Function fnActivationClient_Check      (var aCheckLicense: tCheckLicense): tOKStrRec; overload;
  Function fnActivationClient_Activate   (var aActivationResult: tActivationResult): tOKStrRec; overload;
  Function fnActivationClient_GetLicense: tOKStrRec;
  //
  Function fnActivationClient_Active          (var aActive:     Boolean): tOKStrRec;
  Function fnActivationClient_Expiry          (var aEnabled:    Boolean; var aDate: tDateTime): tOKStrRec;
  Function fnActivationClient_Employees       (var aEmployees:  Integer): tOKStrRec;
  Function fnActivationClient_TotalUser       (var aTotalUsers: Integer): tOKStrRec;
  Function fnActivationClient_Region          (var aRegion:     tTimeSystemsRegions): tOKStrRec;
  Function fnActivationClient_Product         (var aProductName, aProductVersion: String): tOKStrRec;
  Function fnActivationClient_LicenseOptions  (var aLicensOptions:   tLicenseOptions): tOKStrRec;
  Function fnActivationClient_AllowActivation (var aAllowActivation: Boolean): tOKStrRec;
  //
  Function fnActivationClient_GetNamedValue   (Const aName: string; var aValue: tOKStrRec): tOKStrRec;

  //
  Function fnActivationClient_Ping: tOKStrRec;
  Function fnActivationClient_CloseDown: tOKStrRec;
  //

Type
  tDLL_D7_Setup           = Function (Const aId: Integer; Const aParams: pAnsiChar; var aActivationFileStatus: tActivationFileStatus): tOKIntegerRec; safecall;
  tDLL_D7_GetFeedBack     = Function (MessageOut: pAnsiChar): Boolean; safecall;
  //
  tDLL_D7_CheckActivation = Function (var aCheckLicense: tCheckLicense): tOKIntegerRec; safecall;
  tDLL_D7_Activate        = Function (var aActivationResult: tActivationResult): tOKIntegerRec; safecall;
  tDLL_D7_GetLicense      = Function: tOKIntegerRec; safecall;
  //
  tDLL_D7_GetValue        = Function (Const aActivationValue: tActivationValue): tOKIntegerRec; safecall;
  tDLL_D7_GetNamedValue   = Function (Const aName: pAnsiChar; var aFound: Boolean): tOKIntegerRec; safecall;

  tDLL_D7_Ping            = Function: tOKIntegerRec; safecall;
  tDLL_D7_CloseDown       = Function: tOKIntegerRec; safecall;

implementation

Uses FormatResultU, MAS_DS_ConstsU, MASCommon_UtilsU, MASStringListU;

var
  gblDLLList:     tDLLList             = Nil;
  gblFeedBack:    tDLL_D7_GetFeedBack  = Nil;
  gblD7DoneSetup: tIdThreadSafeBoolean = Nil;

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
          gblFeedBack := tDLL_D7_GetFeedBack (gblDLLList.GetDLLAddress (cDLL_D7_ACTIVATION, cDLL_D7_FEEDBACK));
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
// This version Used internally and for testing, called by the following version that has no UserName parameter
Function fnActivationClient_Setup (Const aCommonDir: string;
                                    Const aUrl, aUserName, aPwd, aSageAccount, aSaleNumber, aFingerPrint, aProduct, aVersion: String;
                                     Const aPort: Integer; var aActivationFileStatus: tActivationFileStatus): tOKStrRec; overload;
var
  lvList: tMASStringList;
begin
  lvList := tMASStringList.Create;
  Try
    lvList.AddValues (cCLIENT_HOST,             aUrl);
    lvList.AddValues (cCLIENT_PORT,             aPort);
    lvList.AddValues (cCLIENT_USERNAME,         aUserName);
    lvList.AddValues (cCLIENT_PASSWORD,         aPwd);
    lvList.AddValues (cLOCAL_SAGE_ACCOUNT_CODE, aSageAccount);
    lvList.AddValues (cLOCAL_SALES_NUMBER,      aSaleNumber);
    lvList.AddValues (cLOCAL_FINGER_PRINT,      aFingerPrint);
    lvList.AddValues (cLOCAL_PRODUCT_NAME,      aProduct);
    lvList.AddValues (cLOCAL_PRODUCT_VERSION,   aVersion);
    lvList.AddValues (cCOMMON_COMMON_DIR,       aCommonDir);
    Result := fnActivationClient_Setup (cAD_APPLICATION_ID, lvList, aActivationFileStatus);
  Finally
    lvList.Free;
  end;
end;

Function fnActivationClient_Setup (Const aCommonDir: string;
                                    Const aUrl, aPwd, aSageAccount, aSaleNumber, aFingerPrint, aProduct, aVersion: String;
                                     Const aPort: Integer; var aActivationFileStatus: tActivationFileStatus): tOKStrRec;
var
  lvUserName: String;
begin
  lvUserName := fnSageUserName (aSageAccount);
  Result := fnActivationClient_Setup (aCommonDir,
                                       aUrl, lvUserName, aPwd, aSageAccount, aSaleNumber, aFingerPrint, aProduct, aVersion,
                                        aPort, aActivationFileStatus);
end;

Function fnActivationClient_Setup (Const aId: Integer; Const aParams: tStrings; var aActivationFileStatus: tActivationFileStatus): tOKStrRec;
var
  lvRec:     tOKIntegerRec;
  lvHandle:  tHandle;
  lvSetup:   tDLL_D7_Setup;
  lvAnsiStr: AnsiString;
begin
  Result := fnClear_OKStrRec;
  Try
    if not gblD7DoneSetup.Value then begin
      //
      lvHandle := gblDLLList.OpenLibrary (cDLL_D7_ACTIVATION);
      Result := fnResult ((lvHandle > 0), 'Error: fnActivationClient_Setup. %s', [gblDLLList.LastError]);
      // if OK
      if fnChkOK (Result) then begin
        //
        lvSetup  := tDLL_D7_Setup (gblDLLList.GetDLLAddress (cDLL_D7_ACTIVATION, cDLL_D7_SETUP));
        Case Assigned (aParams) of
          True: begin
                lvAnsiStr := aParams.Text;
                lvRec := lvSetup (aId, pAnsiChar (lvAnsiStr), aActivationFileStatus);
          end
          else  lvRec := lvSetup (aId, pAnsiChar (''), aActivationFileStatus);
        End;
        //
        Result.OK := lvRec.OK;
        Case Result.OK of
          True:;//hCopyFromList (lvList, aList);
          else Result := IntGetFeedBack (lvRec);
        end;
      end;
      //
      gblD7DoneSetup.Value := True;
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnActivationClient_Setup. %s', [e.Message]);
  end;
end;

// Routine: fnActivationClient_Check
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_Check (var aCheckLicense: tCheckLicense): tOKStrRec; overload;
var
  lvRec:        tOKIntegerRec;
  lvActivation: tDLL_D7_CheckActivation;
begin
  Result := fnClear_OKStrRec;
  Try
    //
    //
    lvActivation := tDLL_D7_CheckActivation (gblDLLList.GetDLLAddress (cDLL_D7_ACTIVATION, cDLL_D7_CHECK));

    lvRec := lvActivation (aCheckLicense);
    Result.OK := lvRec.OK;
    Case Result.OK of
      True:;// Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnActivationClient_Check. %s', [e.Message]);
  end;
end;

// Routine: fnActivationClient_Activate
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_Activate (var aActivationResult: tActivationResult): tOKStrRec;
var
  lvRec:    tOKIntegerRec;
  lvActive: tDLL_D7_Activate;
begin
  Result := fnClear_OKStrRec;
  Try
    //
    //
    lvActive := tDLL_D7_Activate (gblDLLList.GetDLLAddress (cDLL_D7_ACTIVATION, cDLL_D7_ACTIVATE));

    lvRec := lvActive (aActivationResult);
    Result.OK := lvRec.OK;
    Case Result.OK of
      True:;// Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnActivationClient_Activate. %s', [e.Message]);
  end;
end;

// Routine: fnActivationClient_GetLicense
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_GetLicense: tOKStrRec;
var
  lvRec:        tOKIntegerRec;
  lvGetLicense: tDLL_D7_GetLicense;
begin
  Result := fnClear_OKStrRec;
  Try
    //
    //
    lvGetLicense := tDLL_D7_GetLicense (gblDLLList.GetDLLAddress (cDLL_D7_ACTIVATION, cDLL_D7_GETLICENSE));

    lvRec := lvGetLicense;
    Result.OK := lvRec.OK;
    Case Result.OK of
      True: // Result := IntGetFeedBack (lvRec);begin
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnActivationClient_GetLicense. %s', [e.Message]);
  end;
end;

// Routine: fnActivationClient_GetValue
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
//  tActivationValue = (avActive, avExpiryEnabled, avExpiryDate, avEmployees, avTotalUsers, avRegion,
//                       avProductName, avProductVersion, avLicenseOptions, avAllowActivation);
//
Function fnActivationClient_GetValue (Const aActivationValue: tActivationValue; var aValue: String): tOKStrRec;
var
  lvRes:      tOKStrRec;
  lvRec:      tOKIntegerRec;
  lvGetValue: tDLL_D7_GetValue;
begin
  Result := fnClear_OKStrRec;
  Try
    //
    lvGetValue := tDLL_D7_GetValue (gblDLLList.GetDLLAddress (cDLL_D7_ACTIVATION, cDLL_D7_GETVALUE));

    lvRec := lvGetValue (aActivationValue);
    Result.OK := lvRec.OK;
    Case Result.OK of
      True: begin
              lvRes := IntGetFeedBack (lvRec);
              fnRaiseOnFalse (lvRes);
              aValue := Trim (lvRes.Msg);
      end
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnActivationClient_GetValue. %s', [e.Message]);
  end;
end;

// Routine: fnActivationClient_Active
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_Active (var aActive:Boolean): tOKStrRec;
var
  lvValue: String;
begin
  aActive := False;
  Result := fnActivationClient_GetValue (avActive, lvValue);
  if Result.OK then aActive := (lvValue = '1');
end;
// Routine: fnActivationClient_Expiry
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_Expiry (var aEnabled: Boolean; var aDate: tDateTime): tOKStrRec;
var
  lvValue: String;
begin
  aEnabled := True;
  aDate    := 0;
  Result := fnActivationClient_GetValue (avExpiryEnabled, lvValue);
  if Result.OK then begin
    aEnabled := (lvValue = '1');
    //
    Result := fnActivationClient_GetValue (avExpiryDate, lvValue);
    if Result.OK then begin
      aDate := StrToDateTime (lvValue);
    end;
  end;
end;
// Routine: fnActivationClient_Employees
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_Employees (var aEmployees: Integer): tOKStrRec;
var
  lvValue: String;
begin
  aEmployees := 0;;
  Result := fnActivationClient_GetValue (avEmployees, lvValue);
  if Result.OK then aEmployees := StrToIntDef (lvValue, 0);
end;
// Routine: fnActivationClient_TotalUser
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_TotalUser (var aTotalUsers: Integer): tOKStrRec;
var
  lvValue: String;
begin
  aTotalUsers := 0;
  Result := fnActivationClient_GetValue (avTotalUsers, lvValue);
  if Result.OK then aTotalUsers := StrToIntDef (lvValue, 0);
end;
// Routine: fnActivationClient_Region
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_Region (var aRegion: tTimeSystemsRegions): tOKStrRec;
var
  lvValue: String;
begin
  aRegion := tsrAll;
  Result := fnActivationClient_GetValue (avRegion, lvValue);
  if Result.OK then aRegion := fnStrToTimeSystemsRegions (lvValue);
end;
// Routine: fnActivationClient_Product
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_Product (var aProductName, aProductVersion: String): tOKStrRec;
var
  lvValue: String;
begin
  aProductName    := '';
  aProductVersion := '';
  Result := fnActivationClient_GetValue (avProductName, lvValue);
  if Result.OK then begin
    aProductName := lvValue;
    //
    Result := fnActivationClient_GetValue (avProductVersion, lvValue);
    if Result.OK then begin
      aProductVersion := lvValue;
    end;
  end;
end;

// Routine: fnActivationClient_LicenseOptions
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
// tLicenseOptions = (loUnKnown, loLicenseServer, loDeskTop, loSpare1, loSpare2);
//
Function fnActivationClient_LicenseOptions (var aLicensOptions: tLicenseOptions): tOKStrRec;
var
  lvValue: String;
begin
  aLicensOptions := loUnKnown;
  Result := fnActivationClient_GetValue (avLicenseOptions, lvValue);
  if Result.OK then aLicensOptions := fnStrToLicenseOptions (lvValue);
end;

// Routine: fnActivationClient_AllowActivation
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_AllowActivation (var aAllowActivation: Boolean): tOKStrRec;
var
  lvValue: String;
begin
  aAllowActivation := True;
  Result := fnActivationClient_GetValue (avAllowActivation, lvValue);
  if Result.OK then aAllowActivation := (lvValue = '1');
end;

// Routine: fnActivationClient_General
// Author: M.A.Sargent  Date: 14/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_GetNamedValue (Const aName: string; var aValue: tOKStrRec): tOKStrRec;
var
  lvRes:      tOKStrRec;
  lvRec:      tOKIntegerRec;
  lvGetValue: tDLL_D7_GetNamedValue;
  lvFound:    Boolean;
begin
  Result := fnClear_OKStrRec;
  Try
    aValue := fnClear_OKStrRec;
    //
    // Notes: This function will only return False if an Excetion is Raised
    lvGetValue := tDLL_D7_GetNamedValue (gblDLLList.GetDLLAddress (cDLL_D7_ACTIVATION, cDLL_D7_GETNAMEDVALUE));

    lvRec := lvGetValue (pAnsiChar (aName), lvFound);
    Result.OK := lvRec.OK;
    Case Result.OK of
      True: begin
              lvRes := IntGetFeedBack (lvRec);
              aValue.OK  := lvFound;
              aValue.Msg := Trim (lvRes.Msg);
      end
      else IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnActivationClient_GetNamedValue. %s', [e.Message]);
  end;
end;


// Routine: fnPing
// Author: M.A.Sargent  Date: 13/05/18  Version: V1.0
//
// Notes:
//
Function fnActivationClient_Ping: tOKStrRec;
var
  lvRec:  tOKIntegerRec;
  lvPing: tDLL_D7_Ping;
begin
  Result := fnClear_OKStrRec;
  Try
    lvPing := tDLL_D7_Ping (gblDLLList.GetDLLAddress (cDLL_D7_ACTIVATION, cDLL_D7_PING));

    lvRec := lvPing;
    Result.OK := lvRec.OK;
    Case Result.OK of
      True:;
      else Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnActivationClient_Ping. %s', [e.Message]);
  end;
end;

// Routine: fnActivationClient_CloseDown
// Author: M.A.Sargent  Date: 04/08/17  Version: V1.0
//
// Notes:
//
Function fnActivationClient_CloseDown: tOKStrRec;
var
  lvRec:   tOKIntegerRec;
  lvClose: tDLL_D7_CloseDown;
begin
  Result := fnClear_OKStrRec;
  Try
    if gblD7DoneSetup.Value then begin
      //
      lvClose := tDLL_D7_CloseDown (gblDLLList.GetDLLAddress (cDLL_D7_ACTIVATION, cDLL_D7_CLOSEDOWN));

      lvRec := lvClose;
      Result.OK := lvRec.OK;
      Case Result.OK of
        True:;
        else Result := IntGetFeedBack (lvRec);
      end;
      //
      gblD7DoneSetup.Value := False;
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnActivationClient_DSCloseDown. %s', [e.Message]);
  end;
end;

Initialization
  gblDLLList           := tDLLList.Create;
  gblD7DoneSetup       := tIdThreadSafeBoolean.Create;
  gblD7DoneSetup.Value := False;
Finalization
  gblDLLList.Free;
  gblD7DoneSetup.Free;
end.
