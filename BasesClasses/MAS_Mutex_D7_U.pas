//
// Unit: MAS_Mutex_D7_U
// Author: M.A.Sargent  Date: 09/10/14  Version: V1.0
//
// Notes: This Mutex class is a cut down version from Delphi XE7, it does not provide the COM interface option
//
unit MAS_Mutex_D7_U;

interface

Uses SysUtils, Types, Windows, Math, RTLConsts, SyncObjs, MASRecordStructuresU;

Type
  TSynchroObject = class(TObject)
  public
    procedure Acquire; virtual;
    procedure Release; virtual;
    function WaitFor(Timeout: LongWord = INFINITE): TWaitResult; overload; virtual;
  end;

  THandleObject = class(TSynchroObject)
  protected
    FHandle: THandle;
    FLastError: Integer;
    FUseCOMWait: Boolean;
  public
    { Specify UseCOMWait to ensure that when blocked waiting for the object
      any STA COM calls back into this thread can be made. }
    constructor Create (UseCOMWait: Boolean = False);
    destructor Destroy; override;
  public
    function WaitFor(Timeout: LongWord): TWaitResult; overload; override;

    property LastError: Integer read FLastError;
    property Handle: THandle read FHandle;
  end;

  TD7_Mutex = class(THandleObject)
  Private
    fName: String;
  public
    constructor Create(UseCOMWait: Boolean = False); overload;
    constructor Create(MutexAttributes: PSecurityAttributes; InitialOwner: Boolean; const Name: string; UseCOMWait: Boolean = False); overload;
    constructor Create(DesiredAccess: LongWord; InheritHandle: Boolean; const Name: string; UseCOMWait: Boolean = False); overload;
    //
    Procedure Acquire; override;
    Procedure Release; override;
    //
    Function fnAcquire (Const aTimeout: LongWord = 1000): tWaitResult;
    //
    Property MutexName: string read fName write fName;
  end;

  // Helper wrappers for tD7_Mutex
  Function h_CreateMutex (Const aName: String; var aMutex: tD7_Mutex): tOKStrRec; overload;
  Function h_CreateMutex (MutexAttributes: PSecurityAttributes; Const aName: String; var aMutex: tD7_Mutex): tOKStrRec; overload;
  Function h_FreeMutex   (var aMutex: tD7_Mutex): tOKStrRec;
  Function h_AquireMutex (Const aMutex: tD7_Mutex; Const aTimeOut: LongWord = INFINITE): tOKStrRec;
  Function h_ReleaseMutex (Const aMutex: tD7_Mutex): tOKStrRec;

  Procedure h_GlobalMutex (const aGlobal: Boolean);

implementation

Uses FormatResultU, MASCommonU, MAS_FormatU, TypInfo, MAS_HashsU;

var
  gblMutexScope: Boolean = True;

// Routine: h_CreateMutex
// Author: M.A.Sargent  Date: 12/09/18  Version: V1.0
//
// Notes:
//
Function h_CreateMutex (Const aName: String; var aMutex: tD7_Mutex): tOKStrRec;
var
  lvSecurityDesc: TSecurityDescriptor;
  lvSecurityAttr: TSecurityAttributes;
begin
  //  By default (lpMutexAttributes =nil) created mutexes are accessible only by
  //  the user running the process. We need our mutexes to be accessible to all
  //  users, so that the mutex detection can work across user sessions.
  //  I.e. both the current user account and the System (Service) account.
  //  To do this we use a security descriptor with a null DACL.
  InitializeSecurityDescriptor (@lvSecurityDesc, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl    (@lvSecurityDesc, True, nil, False);
  lvSecurityAttr.nLength              := SizeOf (lvSecurityAttr);
  lvSecurityAttr.lpSecurityDescriptor := @lvSecurityDesc;
  lvSecurityAttr.bInheritHandle       := False;
  //
  Result := h_CreateMutex (@lvSecurityAttr, aName, aMutex);
end;
Function h_CreateMutex (MutexAttributes: PSecurityAttributes; Const aName: String; var aMutex: tD7_Mutex): tOKStrRec;
var
  lvName: string;
begin
  Result := fnClear_OKStrRec;
  Try
    lvName := MD5_AsStr (aName);
    lvName := IfTrue (gblMutexScope, ('Global\'+lvName), aName);
    //
    aMutex := tD7_Mutex.Create (MutexAttributes, False, lvName, False);
    aMutex.MutexName := lvName;
  except
    on e:Exception do
      Result := fnResultException ('h_CreateMutex', 'Failed to Create Mutex. %s', [aName], e);
  end;
end;

// Routine: h_FreeMutex
// Author: M.A.Sargent  Date: 12/09/18  Version: V1.0
//
// Notes:
//
Function h_FreeMutex (var aMutex: tD7_Mutex): tOKStrRec;
var
  lvName: String;
begin
  Result := fnClear_OKStrRec;
  Try
    lvName := 'Unknown';
    fnRaiseOnFalse (Assigned (aMutex), 'Mutex is Not Assigned Cannot be Freed');
    lvName := aMutex.MutexName;
    FreeAndNil (aMutex);
  except
    on e:Exception do
      Result := fnResultException ('h_FreeMutex', 'Failed to Free Mutex. %s', [lvName], e);
  end;
end;

// Routine: h_AquireMutex
// Author: M.A.Sargent  Date: 12/09/18  Version: V1.0
//
// Notes:
//
Function h_AquireMutex (Const aMutex: tD7_Mutex; Const aTimeOut: LongWord): tOKStrRec;
var
  lvWaitResult: tWaitResult;
  lvName: String;
begin
  Result := fnClear_OKStrRec (False);
  Try
    lvName := 'Unknown';
    fnRaiseOnFalse (Assigned (aMutex), 'Mutex is Not Assigned Cannot be Freed');
    lvName := aMutex.MutexName;
    //
    lvWaitResult := aMutex.fnAcquire (aTimeOut);
    Case lvWaitResult of
      wrTimeout: Raise Exception.Create (fnTS_Format ('TimeOut Exceeded (%d) Milli Seconds', [aTimeOut]));
      // wrSignalled, we got the lock, yippie, only place the result is set True
      wrSignaled: Result := fnClear_OKStrRec (True);
      // else
      wrAbandoned,
       wrError:    Raise Exception.Create (fnTS_Format ('Mutex Lock Failed. %s', [GetEnumName (TypeInfo (tWaitResult), Integer (lvWaitResult))]));
    End;
    //
  except
    on e:Exception do
      Result := fnResultException ('h_AquireMutex', 'Failed to Aquire Mutex. %s', [lvName], e);
  end;
end;

// Routine: h_ReleaseMutex
// Author: M.A.Sargent  Date: 12/09/18  Version: V1.0
//
// Notes:
//
Function h_ReleaseMutex (Const aMutex: tD7_Mutex): tOKStrRec;
var
  lvName: String;
begin
  Result := fnClear_OKStrRec;
  Try
    lvName := 'Unknown';
    fnRaiseOnFalse (Assigned (aMutex), 'Mutex is Not Assigned Cannot be Freed');
    lvName := aMutex.MutexName;
    //
    aMutex.Release;
    //
  except
    on e:Exception do
      Result := fnResultException ('h_ReleaseMutex', 'Failed to Release Mutex. %s', [lvName], e);
  end;
end;

// Routine: h_GlobalMutex
// Author: M.A.Sargent  Date: 12/09/18  Version: V1.0
//
// Notes:
//
Procedure h_GlobalMutex (Const aGlobal: Boolean);
begin
  gblMutexScope := aGlobal;
end;

{tSynchroObject}

// Routine:
// Author: M.A.Sargent  Date: 12/09/18  Version: V1.0
//
// Notes:
//
Procedure TSynchroObject.Acquire;
begin
  WaitFor(INFINITE);
end;

Procedure TSynchroObject.Release;
begin
end;

function TSynchroObject.WaitFor(Timeout: LongWord): TWaitResult;
begin
  Result := wrError;
end;

{ THandleObject }

// Routine:
// Author: M.A.Sargent  Date: 12/09/18  Version: V1.0
//
// Notes:
//
constructor THandleObject.Create(UseComWait: Boolean);
begin
  inherited Create;
  FUseCOMWait := UseCOMWait;
end;

destructor THandleObject.Destroy;
begin
  CloseHandle(FHandle);
  inherited Destroy;
end;

// Routine:
// Author: M.A.Sargent  Date: 12/09/18  Version: V1.0
//
// Notes:
//
Function THandleObject.WaitFor(Timeout: LongWord): TWaitResult;
//var
//  Index: DWORD;
begin
  if FUseCOMWait then
  begin
    Raise Exception.Create ('Error: WaitFor. Com Not Implimented');

  end else
  begin
    case WaitForMultipleObjectsEx(1, @FHandle, True, Timeout, False) of
      WAIT_ABANDONED: Result := wrAbandoned;
      WAIT_OBJECT_0: Result := wrSignaled;
      WAIT_TIMEOUT: Result := wrTimeout;
      WAIT_FAILED:
        begin
          Result := wrError;
          FLastError := Integer(GetLastError);
        end;
    else
      Result := wrError;
    end;
  end;
end;

// Routine:
// Author: M.A.Sargent  Date: 12/09/18  Version: V1.0
//
// Notes:
//

Constructor TD7_Mutex.Create (UseCOMWait: Boolean);
begin
  Create(nil, False, '', False {UseCOMWait});
end;

Constructor TD7_Mutex.Create(MutexAttributes: PSecurityAttributes; InitialOwner: Boolean; const Name: string; UseCOMWait: Boolean);
var
  lpName: PChar;
begin
  inherited Create(UseCOMWait);
  if Name <> '' then
    lpName := PChar(Name)
  else
    lpName := nil;
  FHandle := CreateMutex(MutexAttributes, InitialOwner, lpName);
  if FHandle = 0 then
    RaiseLastOSError;
end;

Constructor TD7_Mutex.Create(DesiredAccess: LongWord; InheritHandle: Boolean; Const Name: string; UseCOMWait: Boolean);
var
  lpName: PChar;
begin
  inherited Create(UseCOMWait);
  if Name <> '' then
    lpName := PChar(Name)
  else
    lpName := nil;
  FHandle := OpenMutex (DesiredAccess, InheritHandle, lpName);
  if FHandle = 0 then
    RaiseLastOSError;
end;

Procedure TD7_Mutex.Acquire;
begin
  if WaitFor(INFINITE) = wrError then
    RaiseLastOSError;
end;

Procedure TD7_Mutex.Release;
begin
  if not ReleaseMutex(FHandle) then
    RaiseLastOSError;
end;

Function TD7_Mutex.fnAcquire (Const aTimeout: LongWord): tWaitResult;
begin
  Result := Self.WaitFor (aTimeout);
end;

end.



