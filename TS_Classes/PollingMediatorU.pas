//
// Unit: PollingMediatorU
// Author: M.A.Sargent  Date: 31/05/18 Version: V1.0
//
// Notes:
//
unit PollingMediatorU;

interface

Uses CriticalSectionU, SysUtils, MAS_TypesU, MASRecordStructuresU;

  //
  Function  fnIsTerminated: Boolean; overload;
  Function  fnIsTerminated (Const aMsg: string): tOKStrRec; overload;
  //
  Procedure SetTerminated;

  Function fnIsShutDown (Const aResult: tOKStrRec): Boolean;

implementation

Uses FormatResultU;

var
  gblTerminated: tIdThreadSafeBoolean = nil;

// Routine: fnIsTerminated & SetTerminated
// Author: M.A.Sargent  Date: 27/03/18  Version: V1.0
//
// Notes:
//
Function fnIsTerminated: Boolean;
begin
  Result := gblTerminated.Value;
end;
Function fnIsTerminated (Const aMsg: string): tOKStrRec;
begin
  Result.OK := fnIsTerminated;
  if Result.OK then
    Result := fnResultOK (aMsg, rrShutDown);
end;
Procedure SetTerminated;
begin
  gblTerminated.Value := True;
end;

// Routine: fnIsShutDown
// Author: M.A.Sargent  Date: 27/03/18  Version: V1.0
//
// Notes:
//
Function fnIsShutDown (Const aResult: tOKStrRec): Boolean;
begin
  Result := aResult.OK;
  if Result then
    Result := (aResult.ExtendedInfoRec.aRecordResult = rrShutDown);
end;

initialization
  gblTerminated       := tIdThreadSafeBoolean.Create;
  gblTerminated.Value := False;

finalization
  FreeAndNil (gblTerminated);
end.

