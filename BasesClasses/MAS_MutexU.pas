//
// Unit: MAS_MutexU
// Author: M.A.Sargent  Date: 28/03/18  Version: V1.0
//
// Notes:
//
unit MAS_MutexU;

interface

Uses system.SyncObjs;

Type
  tMASMutex = Class (tMutex)
  Public
    Function fnAcquire (Const aTimeout: LongWord = 1000): TWaitResult;
  End;

  tMASSemaphore = Class (tSemaphore)
  Public
    Function fnAcquire (Const aTimeout: LongWord = 1000): TWaitResult;
  End;

implementation

{ tMASMutex }

Function tMASMutex.fnAcquire (Const aTimeout: LongWord): TWaitResult;
begin
  Result := Self.WaitFor (aTimeout);
end;

{ tMASSemaphore }

Function tMASSemaphore.fnAcquire (Const aTimeout: LongWord): TWaitResult;
begin
  Result := Self.WaitFor (aTimeout);
end;

end.
