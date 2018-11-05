//
// Unit: TSUK_D7_UtilsU
// Author: M.A.Sargent  Date: 15/05/18  Version: V1.0
//
// Notes:
//
unit TSUK_D7_UtilsU;

interface

Uses SysUtils, MASRecordStructuresU;

  Function fnSageUserName (Const aSageAccountNumber: String): String;
  //
  Function fnMachineFingerPrint (Const DoOnlyOnce: Boolean; Const aDir: string): tOKStrRec;

implementation

Uses MASCommonU, FormatResultU, WindowsAPIU, MASWindowsSystemInfoU, MASRegistry, RegHelperU, MAS_HashsU;

// Routine: fnRandomKey
// Author: M.A.Sargent  Date: 15/05/18  Version: V1.0
//
// Notes: Used to create a password key based on the Computer name
//
Function fnSageUserName (Const aSageAccountNumber: String): String;
begin
  fnRaiseOnFalse (not IsEmpty (aSageAccountNumber), 'Error: fnUserName. aSageAccountNumber Cannot be Blank');
  //
  Result := (aSageAccountNumber + '_USERNAME');
end;

// Routine: fnMachineFingerPrint
// Author: M.A.Sargent  Date: 18/07/18  Version: V1.0
//
// Notes:
//
Function fnMachineFingerPrint (Const DoOnlyOnce: Boolean; Const aDir: string): tOKStrRec;
var
  lvMachine:        String;
  lvFingerPrint:    tOKStrRec;
  lvRegMachine:     String;
  lvRegFingerPrint: String;
  lvRegData:        String;
begin
  Result := fnClear_OKStrRec;
  Try
    // get the Registry entry
    lvRegData  := fn_h_GetRegString ('Config', 'Machine', 'Data', '');
    // get MAchien and Hash it
    lvMachine     := fnComputerName;
    lvMachine     := MD5_AsStr (lvMachine);
    // output data on the first running of the process
    lvFingerPrint := fnGenerateSystemID (IsEmpty (lvRegMachine), aDir);
    fnRaiseOnFalse (lvFingerPrint);
    // if not found then assume first item, write details and exit
    Case IsEmpty (lvRegData) of
      True: begin
        h_SetRegString ('Config', 'Machine', 'Data', (lvMachine+lvFingerPrint.Msg));
        Result := fnResultOK (lvFingerPrint.Msg);
        Exit;
      end;
      else begin
        // Now do the Tests, if Machine Name and Finger Print = The Registry Data everything OK
        Result.OK := IsEqual ((lvMachine+lvFingerPrint.Msg), lvRegData);
        if Result.OK then begin
          Result := lvFingerPrint;
        end
        else begin
          //
          // extract machine and Finger Print
          lvRegMachine     := Copy (lvRegData, 1, (Length (lvMachine)));
          lvRegFingerPrint := Copy (lvRegData, (Length (lvMachine)+1), MaxInt);
          // Do Once just check the Machine Names is equal then return the Registry Finger Print
          Case DoOnlyOnce of
            True: begin
              //
              Result := fnResult (IsEqual (lvMachine, lvRegMachine), 'Error: fnMachineFingerPrint. Machine Names Do not Match');
              if Result.OK then Result.Msg := lvRegFingerPrint;
            end;
            else begin
              //
              lvFingerPrint := fnGenerateSystemID (True, aDir);
              Result := fnResult ('Error: fnMachineFingerPrint. Machine Finger Print Data is Incorrect. %s', [lvFingerPrint.Msg]);
            end;
          end;
        end;
      end;
    end;
  except
    on e:Exception do begin
      Result := fnResultException ('fnMachineFingerPrint', 'Failed to Process Machine Data', e);
    end;
  end;
end;

end.
