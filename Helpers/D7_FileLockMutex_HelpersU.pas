//
// Unit: D7_FileLockMutex_HelpersU
// Author: M.A.Sargent  Date: 18/06/18  Version: V1.0
//
// Notes:
//
unit D7_FileLockMutex_HelpersU;

interface

Uses Classes, Windows, MASRecordStructuresU, SysUtils, Forms, DLLListU, AppDataU, CriticalSectionU, IdThreadSafe, MAS_ConstsU,
    {$IFDEF VER150}
    TSUK_D7_ConstsU,
    {$ELSE}
    {$ENDIF}
    TSUK_ConstsU;
  //

  Function fnCreateMutex   (Const aName, aMutexName: String): tOKStrRec;
  Function fnReAssignMutex (Const aName, aMutexName: String): tOKStrRec;
  Function fnMutexExists   (Const aName, aMutexName: String; var aResult: tMutexEntry): tOKStrRec;
  Function fnAquireMutex   (Const aName: String; Const aTimeOut: Integer = cMC_500ms; Const aReTryCount: Integer = 0): tOKStrRec;
  Function fnReleaseMutex  (Const aName: String): tOKStrRec;
  Function fnFreeMutex     (Const aName: String): tOKStrRec;
  //
  //
  //
  Function DLL_FLM_GetFeedBack     (MessageOut: pAnsiChar): Boolean; safecall; external 'D7_FileLockMutex.dll';
  //
  Function DLL_FLM_CreateMutex_D7  (Const aName, aMutexName: pAnsiChar): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';
  Function DLL_FLM_ReAssign_D7     (Const aName, aMutexName: pAnsiChar): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';
  Function DLL_FLM_MutexExists_D7  (Const aName, aMutexName: pAnsiChar; var aResult: tMutexEntry): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';
  //
  Function DLL_FLM_AquireMutex_D7  (Const aName: pAnsiChar; Const aTimeOut: Integer = cMC_500ms; Const aReTryCount: Integer = 0): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';
  Function DLL_FLM_ReleaseMutex_D7 (Const aName: pAnsiChar): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';
  Function DLL_FLM_FreeMutex_D7    (Const aName: pAnsiChar): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';
  //
  //
  //
  Function DLL_FLM_CreateMutex     (Const aName, aMutexName: pChar): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';
  Function DLL_FLM_ReAssign        (Const aName, aMutexName: pChar): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';
  Function DLL_FLM_MutexExists     (Const aName, aMutexName: pChar; var aResult: tMutexEntry): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';
  //
  Function DLL_FLM_AquireMutex     (Const aName: pChar; Const aTimeOut: Integer = cMC_500ms; Const aReTryCount: Integer = 0): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';
  Function DLL_FLM_ReleaseMutex    (Const aName: pChar): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';
  Function DLL_FLM_FreeMutex       (Const aName: pChar): tOKIntegerRec; safecall; external 'D7_FileLockMutex.dll';

implementation

Uses FormatResultU, MAS_DS_ConstsU, MASCommon_UtilsU, MASStringListU;

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
        lvResult := fnResult (DLL_FLM_GetFeedBack (lvRes), 'Internal Error In IntGetFeedBack.');
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

// Routine: fnCreateMutex
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnCreateMutex (Const aName, aMutexName: String): tOKStrRec;
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
    lvRec := DLL_FLM_CreateMutex_D7 (pAnsiChar (aName), pAnsiChar (aMutexName));
    {$ELSE}
    lvRec := DLL_FLM_CreateMutex (pChar (aName), pChar (aMutexName));
    {$ENDIF}
    Result.OK := lvRec.OK;
    Case Result.OK of
      True: Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnCreateMutex. %s', [e.Message]);
  end;
end;

// Routine: fnReAssignMutex
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnReAssignMutex (Const aName, aMutexName: String): tOKStrRec;
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
    lvRec := DLL_FLM_ReAssign_D7 (pAnsiChar (aName), pAnsiChar (aMutexName));
    {$ELSE}
    lvRec := DLL_FLM_ReAssign (pChar (aName), pChar (aMutexName));
    {$ENDIF}
    Result.OK := lvRec.OK;
    Case Result.OK of
      True: Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnReAssignMutex. %s', [e.Message]);
  end;
end;

// Routine: fnMutexExists
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnMutexExists (Const aName, aMutexName: String; var aResult: tMutexEntry): tOKStrRec;
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
    lvRec := DLL_FLM_MutexExists_D7 (pAnsiChar (aName), pAnsiChar (aMutexName), aResult);
    {$ELSE}
    lvRec := DLL_FLM_MutexExists (pChar (aName), pChar (aMutexName), aResult);
    {$ENDIF}
    Result.OK := lvRec.OK;
    Case Result.OK of
      True:; {Result := IntGetFeedBack (lvRec);}
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnMutexExists. %s', [e.Message]);
  end;
end;

// Routine: fnAquireMutex
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnAquireMutex (Const aName: String; Const aTimeOut: Integer = cMC_500ms; Const aReTryCount: Integer = 0): tOKStrRec;
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
    lvRec := DLL_FLM_AquireMutex_D7 (pAnsiChar (aName), aTimeOut, aReTryCount);
    {$ELSE}
    lvRec := DLL_FLM_AquireMutex (pChar (aName), aTimeOut, aReTryCount);
    {$ENDIF}
    Result.OK := lvRec.OK;
    Case Result.OK of
      True:;// Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnAquireMutex. %s', [e.Message]);
  end;
end;

// Routine: fnReleaseMutex
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnReleaseMutex (Const aName: String): tOKStrRec;
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
    lvRec := DLL_FLM_ReleaseMutex_D7 (pAnsiChar (aName));
    {$ELSE}
    lvRec := DLL_FLM_ReleaseMutex (pChar (aName));
    {$ENDIF}
    Result.OK := lvRec.OK;
    Case Result.OK of
      True:;// Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnReleaseMutex. %s', [e.Message]);
  end;
end;

// Routine: fnFreeMutex
// Author: M.A.Sargent  Date: 12/05/18  Version: V1.0
//
// Notes:
//
Function fnFreeMutex (Const aName: String): tOKStrRec;
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
    lvRec := DLL_FLM_FreeMutex_D7 (pAnsiChar (aName));
    {$ELSE}
    lvRec := DLL_FLM_FreeMutex (pChar (aName));
    {$ENDIF}
    Result.OK := lvRec.OK;
    Case Result.OK of
      True: Result := IntGetFeedBack (lvRec);
      else  Result := IntGetFeedBack (lvRec);
    end;
  except
    on e:Exception do
      Result := fnResult ('Error: fnFreeMutex. %s', [e.Message]);
  end;
end;

end.
