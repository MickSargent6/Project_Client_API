//
// Unit: BaseEventThreadU
// Author: M.A.Sargent  Date:  17/01/2007 Version: V1.0
//         M.A.Sargent         06/11/2009          V2.0
//         M.A.Sargent         08/11/2009          V3.0
//         M.A.Sargent         29/09/2011          V4.0
//         M.A.Sargent         12/11/2011          V5.0
//         M.A.Sargent         20/12/2013          V6.0
//         M.A.Sargent         28/12/2013          V7.0
//         M.A.Sargent         27/04/2015          V8.0
//         M.A.Sargent         23/03/2016          V9.0
//         M.A.Sargent         22/12/2016          V10.0
//         M.A.Sargent         12/12/2017          V11.0
//         M.A.Sargent         14/04/2018          V12.0
//         M.A.Sargent         30/08/2018          V13.0
//
// Notes:
//  V2.0: Add New Constructor: Create (CreateSuspended, TerminateOnCompletion: Boolean)
//  V3.0: Add DoException virtual method
//  V4.0: Add IntDoStart method
//  V5.0: Add threadName property, default to classname
//  V6.0: Add property (default to True, as was) to stop Synchronizing with desktop
//  V7.0: Cut and Paste Error
//  V8.0: Add a method DoChangeOfDay
//  V9.0: Add a new flag tlcException
// V10.0: Updated ReleaseThread
// V11.0:
// V12.0: Updated the Timer Event and added simepl tTimerThread clas
// V13.0: Updated to add Exception Count to the Base Class
//
unit BaseEventThreadU;

interface

uses
  Windows, Classes, db, SysUtils, Dialogs, Controls, IdThreadSafe, MatchUtilsU, MAS_ConstsU;

type tEventChain = (ecNone, ecInit, ecAfterInit, ecBeforeExecute, ecExecute, ecAfterExecute,
                     ecSuspend, ecTeminateSet, ecTeminate, ecCompleted);
     //tEventChainSet = Set of tEventChain ;
     tThreadLifeCycle = (tlcCreated, tlcExecuting, tlcException, tlcCompleted);
     tTimeEvent       = (teMinute, teHour, teDay);
     tExceptionType   = (etInnerException, etFinalException);

     tMessageHandler    = Procedure (Sender: tObject; Const aMsg: String) of object;
     tErrorHandler      = Procedure (Sender: tObject; Const ErrMsg: String) of object;
     tThreadAction      = Procedure (Sender: tObject; aEventChain: tEventChain) of object;
     tOnThreadLifeCycle = Procedure (Sender: tObject; aThreadLifeCycle: tThreadLifeCycle) of object;
     tOnTimeEvent       = Procedure (Sender: tObject; Const aTimeEvent: tTimeEvent) of object;
     // On a ExceptionType of etFinalException then aHandled is Ignored
     tNewErrorHandler   = Procedure (Sender: tObject; Const aExceptionType: tExceptionType; Const ErrMsg: String; var aHandled: Boolean) of object;


type
  tBaseThread = class(TThread)
  private
    { Private declarations }
    fOnTimeEvent:           tOnTimeEvent;
    fDebugFileName:         String;
    fTerminateOnCompletion: Boolean;
    fMessageHandler:        tMessageHandler;
    fThreadLifeCycle:       tThreadLifeCycle;
    fIsRunning:             Boolean;
    fLastEvent:             tEventChain;                {Synchorize event variables}
    fTmpMsg:                String;
    fOnException:           tErrorHandler;              {Events}
    fOnNewErrorHandler:     tNewErrorHandler;
    fOnThreadAction:        tThreadAction;
    fOnThreadLifeCycle:     tOnThreadLifeCycle;
    fOnTerminate:           tNotifyEvent;
    fSleep:                 Integer;
    fThreadName:            String;
    fMustSynchronize:       Boolean;                    {Sleep Period (milli seconds, between each execute loop}
    fCurrentMinute:         Integer;
    fCurrentDay:            Integer;
    fCurrentHour:           Integer;
    fExecutionCount:        tIdThreadSafeInteger;
    fExceptionCount:        tIdThreadSafeInteger;
    fConsecutiveExceptions: tIdThreadSafeInteger;

    fNewLifeCycle:          Boolean;
    fSignalTimeEvents:      Boolean;
    //
    Procedure SetSleep (Const Value: Integer);
    Function  GetIsRunning: Boolean;
    Procedure ThreadAction;
    Procedure SynchHandleMessage;
    Procedure SynchInfoMessage;
    //
    Procedure IntDoOnStart;
    Function  GetThreadName: String;
    Procedure Int_IsChangeOfDay;
    Procedure SetThreadLifeCycle   (Const Value: tThreadLifeCycle);
    Procedure prcThreadLifeCycle;
    Function  GetExecutionCount: Integer;
    Procedure SetOnThreadAction    (Const Value: tThreadAction);
    Procedure SetSignalTimeEvents  (Const Value: Boolean);
    Function  GetExceptionCount: Integer;
    Function  GetConsecutiveExceptions: Integer;

  Protected
    fSupendPending: Boolean;
    Procedure Execute; override;
    {}
    Function fnGenDebugFileName: String;
    Procedure IntThreadAction       (Const aEventChain: tEventChain);
    //
    Procedure ExceptionHandlerInner (Const aException: Exception; var aHandled: Boolean); virtual;
    Procedure ExceptionHandler      (Const aMsg: String); virtual;

    Procedure DoAfterConstruction; virtual;
    Procedure Sync_ThreadAction     (aThread: tBaseThread; Const aEventChain: tEventChain); virtual;
    Procedure Sync_ThreadLifeCylce  (aThread: tBaseThread; Const aThreadLifeCycle: tThreadLifeCycle); virtual;
    Procedure DoCreate; virtual;
    Procedure DoOnStart; virtual;
    Procedure DoBeforeExecute       (var aOKDoExecute: Boolean); virtual;
    Procedure DoExecute; virtual;
    Procedure DoAfterExecute; virtual;
    Procedure DoTimeEvent           (Const aTimeEvent: tTimeEvent); virtual;
    Procedure DoOnTerminate; virtual;
    Procedure DoCompleted; virtual;
    Procedure DoDestroy; virtual;
    Procedure DoException           (Const aMsg: String; var Handled: Boolean); virtual;
    //
    //Procedure TerminatedSet; override;

    //
    Procedure IntHandleMessage      (Const aName, aMsg: String); virtual;
    Procedure renamed_OutputMessage (const aMsg: String); virtual;
    //
    Property NewLifeCycle: Boolean read fNewLifeCycle   write fNewLifeCycle Default False;

  Public
    Constructor Create (CreateSuspended: Boolean; Const aThreadName: String = ''); overload; virtual;
    Constructor Create (CreateSuspended, TerminateOnCompletion: Boolean; Const aThreadName: String = ''); overload; virtual;
    Destructor  Destroy; override;
    Procedure   AfterConstruction; override;
    //
    Procedure ResetExceptionCount;
    //
    Procedure SuspendAfterExecute; virtual;
    //
    Property IsRunning:             Boolean          read GetIsRunning;
    Property SleepInterval:         Integer          read fSleep            write SetSleep default 0;
    Property ThreadLifeCycle:       tThreadLifeCycle read fThreadLifeCycle  write SetThreadLifeCycle;
    Property LastEvent:             tEventChain      read fLastEvent;
    Property ThreadName:            String           read GetThreadName     write fThreadName;
    Property MustSynchronize:       Boolean          read fMustSynchronize  write fMustSynchronize default True;
    Property SignalTimeEvents:      Boolean          read fSignalTimeEvents write SetSignalTimeEvents default False;
    //
    Property ExecutionCount:        Integer          read GetExecutionCount;
    Property ExceptionCount:        Integer          read GetExceptionCount;
    Property ConsecutiveExceptions: Integer          read GetConsecutiveExceptions;

  Published
    Property OnThreadAction:    tThreadAction        read fOnThreadAction    write SetOnThreadAction;
    Property OnException:       tErrorHandler        read fOnException       write fOnException;
    Property OnMessage:         tMessageHandler      read fMessageHandler    write fMessageHandler;
    Property OnThreadLifeCycle: tOnThreadLifeCycle   read fOnThreadLifeCycle write fOnThreadLifeCycle;
    Property OnTimeEvent:       tOnTimeEvent         read fOnTimeEvent       write fOnTimeEvent;
    //
    Property OnNewErrorHandler: tNewErrorHandler     read fOnNewErrorHandler write fOnNewErrorHandler;
    Property WhenTerminate:     tNotifyEvent         read fOnTerminate       write fOnTerminate;
  end;

  { tTimerThread }
  tTimerThread = Class (tBaseThread)
  Public
    Constructor CreateSetup (Const aEvent: tOnTimeEvent; Const aResume: Boolean; Const aSleepPeriod: Integer = cMC_250ms);
  End;

  //
  Function ReleaseThread (var aThread: tThread; Const aFreeObject: Boolean = True): Integer;
  Function ResumeThread  (Const aThread: tBaseThread; Const aWaitMs: Integer = 2000): Boolean;

implementation

Uses DateUtils, TS_SystemVariablesU, MAS_DirectoryU, MAS_FormatU, MASCommonU, MAS_TypesU;

// Helper Routines
Function ReleaseThread (var aThread: tThread; Const aFreeObject: Boolean = True): Integer;
begin
  Result := 0;
  if Assigned (aThread) then begin
    aThread.Terminate;
    aThread.Resume;
    Result := aThread.WaitFor;
    if aFreeObject then FreeAndNil (aThread);
  end;
end;

Function ResumeThread (Const aThread: tBaseThread; Const aWaitMs: Integer): Boolean;
var
  x: Integer;
  lvUnits: Integer;
begin
  // check Ms range, default to 2 seconds (2000Ms)
  lvUnits := fnRangeInt (aWaitMS, 500, 5000, 2000);
  //
  x := 0;
  Result := Assigned (aThread);
  if not Result then Exit;
  aThread.Resume;
  Repeat
    Sleep (100);
    Inc (x);
    if (x > (lvUnits / 100)) then
      Raise Exception.CreateFmt ('Error: ResumeThread. Thread not Executing with Timeout Period (%d Ms)', [lvUnits]);
  Until (aThread.ThreadLifeCycle <> tlcCreated);
end;

{ tBaseThread }

Constructor tBaseThread.Create (CreateSuspended: Boolean; Const aThreadName: String = '');
begin
  Create (CreateSuspended, False, aThreadName);
  Self.ThreadName := aThreadName;
  NewLifeCycle     := False;
  fMustSynchronize := True;
  //
end;

Procedure tBaseThread.AfterConstruction;
begin
  inherited;
  DoAfterConstruction;
end;

Constructor tBaseThread.Create (CreateSuspended, TerminateOnCompletion: Boolean; Const aThreadName: String = '');
begin
  Inherited Create (CreateSuspended);       {create suspended}
  Try
    Self.ThreadName    := aThreadName;
    ThreadLifeCycle    := tlcCreated;       {set when the Thread is Created}
    fOnThreadAction    := Nil;
    fOnException       := Nil;              {Ensure the event handlers are nil}
    fMessageHandler    := Nil;
    fOnThreadLifeCycle := Nil;
    fOnTimeEvent       := Nil;
    fOnNewErrorHandler := Nil;
    //
    fSignalTimeEvents     := False;
    fExecutionCount       := tIdThreadSafeInteger.Create;
    fExecutionCount.Value := 1;
    //
    fExceptionCount       := tIdThreadSafeInteger.Create;
    fExceptionCount.Value := 0;
    //
    fConsecutiveExceptions       := tIdThreadSafeInteger.Create;
    fConsecutiveExceptions.Value := 0;
    //
    fLastEvent := ecNone;                   {Set the Initial Value}
    Priority   := tpLower;                  {Set Lower that main thread}
    fIsRunning := False;                    {Default to False}
    DoCreate;                               {}
    fTerminateOnCompletion := TerminateOnCompletion;
  Except
    On e:Exception do begin
      IntHandleMessage ('Create', e.Message);
    end;
  end;
end;

Destructor tBaseThread.Destroy;
begin
  Try
    fExceptionCount.Free;
    fExecutionCount.Free;
    fConsecutiveExceptions.Free;
    DoDestroy;
  Except
    On e:Exception do begin
      IntHandleMessage ('Destroy', e.Message);
    end;
  end;
  inherited;
end;

Function tBaseThread.GetIsRunning: Boolean;
begin
  Result := fIsRunning;
end;

// Notes: Updated to add a tThreadLifeCycle to indicate if the Thread is:
//          tlcCreated:    Set in the Create method
//          tlcExecuting:  Set at the Start of the Execute method (Try/Finally)
//          tlcException:  Set on an Exception (if NewLifeCycle is set True)
//          tlcCompleted:  Set at the End of the Execute method
//
procedure tBaseThread.Execute;
var
  lvDoExecute: Boolean;
  lvHandled:   Boolean;
begin
  ThreadLifeCycle := tlcExecuting;         {set once it is running}
  fIsRunning := True;
  Try
    { Place thread code here }
    Try
      if Not Terminated then IntDoOnStart;
      While Not Terminated do begin
        fSupendPending := False;
        fIsRunning := True;
        Try
          Try
            lvDoExecute := True;
            DoBeforeExecute (lvDoExecute);
            if lvDoExecute then DoExecute;
          Finally
            DoAfterExecute;
          end;
          // if code reaches here then reset as no exceptions could have been raised
          fConsecutiveExceptions.Value := cMC_ZERO;
        Except
          On e:Exception do begin
            lvHandled := False;
            ExceptionHandlerInner (e, lvHandled);
            if not lvHandled then Raise;
          end;
        End;
      end;
      DoOnTerminate;
    Except
      On e:Exception do begin
        if NewLifeCycle then ThreadLifeCycle := tlcException;  {set On an Exception }
        ExceptionHandler (e.Message);
      end;
    end;
  Finally
    DoCompleted;
    ThreadLifeCycle := tlcCompleted;         {set once it has run}
  End;
end;

// Routine: fnGenDebugFileName
// Author: M.A.Sargent  Date: 07/12/17  Version: V1.0
//
// Notes:
//
Function tBaseThread.fnGenDebugFileName: String;
begin
  if IsEmpty (fDebugFileName) then
    fDebugFileName := fnGenTempFile (fnTS_AppPath, 'Common\Debug', fnChangeExt (Self.ThreadName, '.Txt'), True, fntDateTime);
  Result := fDebugFileName;
end;

procedure tBaseThread.SuspendAfterExecute;
begin
  fSupendPending := True;
end;

procedure tBaseThread.DoCreate;
begin
end;
Procedure tBaseThread.DoAfterConstruction;
begin
end;

procedure tBaseThread.DoDestroy;
begin
end;

// Routine: IntDoOnStart
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//
// Notes:
//
procedure tBaseThread.IntDoOnStart;
begin
  DoOnStart;
  if not Terminated then IntThreadAction (ecAfterInit);
end;

procedure tBaseThread.DoOnStart;
begin
  IntThreadAction (ecInit);
end;

procedure tBaseThread.DoBeforeExecute (var aOKDoExecute: Boolean);
begin
  IntThreadAction (ecBeforeExecute);
end;

procedure tBaseThread.DoExecute;
begin
  IntThreadAction (ecExecute);
end;

// Notes: Updated bug fix, DONT suspend if terminated
// Notes: If Boolean fTerminateOnCompletion True then Terminate, this is
//        set in the Constructor so that the Thread will only Execute Once
//
Procedure tBaseThread.DoAfterExecute;
var
  lvMaxInt: Integer;
begin
  //
  lvMaxInt := fExecutionCount.Increment;
  if (lvMaxInt = MaxInt) then fExecutionCount.Value := 1;
  //
  IntThreadAction (ecAfterExecute);
  fIsRunning := False;
  //
  if fTerminateOnCompletion then Terminate;
  if Terminated then Exit;    // DONT suspend if terminated
  //
  Int_IsChangeOfDay;          // As the Thread is not terminated check for the change of day
  //
  Case fSupendPending of
    True:  begin
      IntThreadAction (ecSuspend);
      Inherited Suspend;
    end;
    False: if (fSleep > 0) then
             Sleep (fSleep);
  end;
  fSupendPending := False;
end;

procedure tBaseThread.IntHandleMessage (Const aName, aMsg: String);
var
  lvHandled: Boolean;
  lvMsg: String;
begin
  lvHandled := False;
  lvMsg := (aName + ': ' + aMsg);
  DoException (lvMsg, lvHandled);
  if not lvHandled then begin
    fTmpMsg := lvMsg;
    Case fMustSynchronize of
      True: Synchronize (SynchHandleMessage);
      else  SynchHandleMessage;
    end;
  end;
end;

procedure tBaseThread.renamed_OutputMessage (Const aMsg: String);
begin
  fTmpMsg := aMsg;
  Case fMustSynchronize of
    True: Synchronize (SynchInfoMessage);
    else  SynchInfoMessage;
  end;
end;

procedure tBaseThread.SynchInfoMessage;
begin
  if Assigned (fMessageHandler) then fMessageHandler (Self, fTmpMsg);
end;

// Routine: ExceptionHandlerInner
// Author: M.A.Sargent  Date: 30/03/18  Version: V1.0
//
// Notes:
//
Procedure tBaseThread.ExceptionHandlerInner (Const aException: Exception; var aHandled: Boolean);
begin
  aHandled := False;
  fExceptionCount.Increment;
  // Increment on exception
  fConsecutiveExceptions.Increment;
  //
  if Assigned (fOnNewErrorHandler) then fOnNewErrorHandler (Self, etInnerException, fnTS_Format ('Error: ExceptionHandlerInner. %s', [aException.Message]), aHandled);
end;

procedure tBaseThread.ExceptionHandler (Const aMsg: String);
begin
  IntHandleMessage ('Execute, Exception', aMsg);
end;

Procedure tBaseThread.SynchHandleMessage;
var
  lvJunk: Boolean;
begin
  lvJunk := False;
  // if event assigned then do event
  if Assigned (fOnException) then fOnException (Self, fTmpMsg);
  if Assigned (fOnNewErrorHandler) then fOnNewErrorHandler (Self, etFinalException, fTmpMsg, lvJunk);

  if not (Assigned (fOnException) or Assigned (fOnNewErrorHandler)) then begin
    //
    Case fMustSynchronize of
      True: MessageDlg (Format('Error: (%s) - %s', [Self.ClassName, fTmpMsg]), mtError, [mbOK], 0);   // Default as was
      else Raise Exception.CreateFmt ('Error: UnHandled Exception - %s', [fTmpMsg]);
    end;
  end;
end;

// Notes: MAS 05/07/03 Hookup the fOnTerminate Event
procedure tBaseThread.DoOnTerminate;
begin
  IntThreadAction (ecTeminate);
  if Assigned (fOnTerminate) then fOnTerminate (Self);
end;

// Routine: GetExecutionCount
// Author: M.A.Sargent  Date: 08/12/17  Version: V1.0
//
// Notes:
//
Function tBaseThread.GetExecutionCount: Integer;
begin
  Result := fExecutionCount.Value;
end;

procedure tBaseThread.SetOnThreadAction (Const Value: tThreadAction);
begin
  fOnThreadAction := Value;
end;

Procedure tBaseThread.SetSignalTimeEvents (Const Value: Boolean);
var
  lvNow: TDateTime;
begin
  fSignalTimeEvents := Value;
  if fSignalTimeEvents then begin
    lvNow          := Now;
    fCurrentDay    := Trunc    (lvNow);  {}
    fCurrentHour   := HourOf   (lvNow);  {}
    fCurrentMinute := MinuteOf (lvNow);  {}
  end;
end;

// Notes: value is in Milli Seconds, between 0 and 2000
Procedure tBaseThread.SetSleep (Const Value: Integer);
begin
  if (Value >= 0) and (Value <= 2000) then
     fSleep := Value
  else Raise Exception.CreateFmt ('Error: SetSleep. Interval must be between 0 and 1000Ms, %d is Invalid', [Value]);
end;

procedure tBaseThread.SetThreadLifeCycle (Const Value: tThreadLifeCycle);
begin
  fThreadLifeCycle := Value;
  Case fMustSynchronize of
    True: Synchronize (prcThreadLifeCycle);
    else  prcThreadLifeCycle;
  end;
end;

// Routine: prcThreadLifeCycle
// Author: M.A.Sargent  Date: 28/12/13  Version: V1.0
//
// Notes:
//
Procedure tBaseThread.prcThreadLifeCycle;
begin
  Sync_ThreadAction (Self, fLastEvent);
  if Assigned (fOnThreadLifeCycle) then fOnThreadLifeCycle (Self, Self.ThreadLifeCycle);
end;

// Routine: IntThreadAction
// Author: M.A.Sargent  Date: 28/12/13  Version: V1.0
//
// Notes:
//
Procedure tBaseThread.IntThreadAction (Const aEventChain: tEventChain);
begin
 fLastEvent := aEventChain;
  Case fMustSynchronize of
    True: Synchronize (ThreadAction);
    else  ThreadAction;
  end;
end;

{Procedure tBaseThread.TerminatedSet;
begin
  inherited;
  IntThreadAction (ecTeminateSet);
end;}

Procedure tBaseThread.ThreadAction;
begin
  Sync_ThreadAction (Self, fLastEvent);
  if Assigned (fOnThreadAction) then fOnThreadAction (Self, fLastEvent);
end;

Procedure tBaseThread.Sync_ThreadAction (aThread: tBaseThread; Const aEventChain: tEventChain);
begin
end;

Procedure tBaseThread.Sync_ThreadLifeCylce (aThread: tBaseThread; Const aThreadLifeCycle: tThreadLifeCycle);
begin
end;

Procedure tBaseThread.DoException (const aMsg: String; var Handled: Boolean);
begin
end;

// Routine: Int_IsChangeOfDay & DoChangeOfDay
// Author: M.A.Sargent  Date: 27/04/15  Version: V1.0
//
// Notes: Only check every 100 Executions
//
Procedure tBaseThread.Int_IsChangeOfDay;
var
  lvNow: tDateTime;
begin
  if not fSignalTimeEvents then Exit;
  // Only check every 100 Executions
  if ((fExecutionCount.Value Mod 100) = cMC_ZERO) then begin
    lvNow := Now;

    // the first call after MidNight should return True
    if (Trunc (lvNow) > fCurrentDay) then begin
      fCurrentDay := Trunc (lvNow);
      DoTimeEvent (teDay);
    end;
    // Now Check to see if the Hour has changed
    // the first call after Hours change should return True
    // Use <> as hour range is 0-23
    if (HourOf (lvNow) <> fCurrentHour) then begin
      fCurrentHour := HourOf (lvNow);
      DoTimeEvent (teHour);
    end;
    //
    if (MinuteOf (lvNow) <> fCurrentMinute) then begin
      fCurrentMinute := MinuteOf (lvNow);
      DoTimeEvent (teMinute);
    end;
  end;
end;

// Routine: DoTimeEvent
// Author: M.A.Sargent  Date: 13/04/18  Version: V1.0
//
// Notes:
//
Procedure tBaseThread.DoTimeEvent (Const aTimeEvent: tTimeEvent);
begin
  if Assigned (fOnTimeEvent) then fOnTimeEvent (Self, aTimeEvent);
end;

procedure tBaseThread.DoCompleted;
begin
  IntThreadAction (ecCompleted);
end;

Function tBaseThread.GetThreadName: String;
begin
  if IsEmpty (fThreadName) then fThreadName := Self.ClassName;
  Result := fnTS_Format ('%s,[%d]', [fThreadName, ThreadId]);
end;

Function tBaseThread.GetExceptionCount: Integer;
begin
  Result := Self.fExceptionCount.Value;
end;

Procedure tBaseThread.ResetExceptionCount;
begin
  Self.fExceptionCount.Value := 0;
end;

Function tBaseThread.GetConsecutiveExceptions: Integer;
begin
  Result := Self.fConsecutiveExceptions.Value;
end;

{ tTimerThread }

Constructor tTimerThread.CreateSetup (Const aEvent: tOnTimeEvent; Const aResume: Boolean; Const aSleepPeriod: Integer);
begin
  Inherited Create (True);
  Self.SleepInterval    := aSleepPeriod;
  Self.SignalTimeEvents := True;
  Self.MustSynchronize  := False;
  Self.OnTimeEvent      := aEvent;
  if aResume then Self.Resume;
end;

end.
