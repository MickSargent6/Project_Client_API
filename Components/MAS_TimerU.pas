//
// Unit: MAS_TimerU
// Author: M.A.Sargent  Date: 13/12/17  Version: V1.0
//         M.A.Sargent        15/06/18           V2.0
//         M.A.Sargent        20/06/18           V3.0
//         M.A.Sargent        06/07/18           V4.0
//         M.A.Sargent        16/08/18           V5.0
//
// Notes:
//  V2.0: 1. Updated to ad property MASTimerOnStartup, will cause a time event to be fired on Start default False
//        2. Updated all a time period to be passed to an updated Start method, range 1 - 3600 seconds
//  V3.0: Updated to add a Log Event Option, currently there are 3 event teMinute, teHour and teDay
//  V4.0: Update one of the Start methods use Integer and not SmallInt
//  V5.0: Updated the Timer method
//
unit MAS_TimerU;

interface

uses
  MatchUtilsU, MAS_ConstsU, MASRecordStructuresU, MAS_TypesU, DateUtils,
  {$IFDEF VER150}
  SysUtils, Classes, ExtCtrls;
  {$ELSE}
  System.SysUtils, System.Classes, Vcl.ExtCtrls;
  {$ENDIF}

type
  tTimerInterval = (ti100Ms, ti250Ms, ti500Ms, ti750Ms, ti1000Ms);
  tTimerEvent = (teNone, te1Second, te5Seconds, te10Seconds, te15Seconds, te30Seconds, te60Seconds, te120Seconds, te300Seconds,
                  teValue);
  //
  tMASTimer = Class;
  tOnMASEvent = Procedure (aSender: tMASTimer; var aResumeTimer: Boolean) of object;

  tMASTimer = class(TTimer)
  private
    { Private declarations }
    fOnTimeEvent:       tOnTimeEvent;
    fOnMASEvent:        tOnMASEvent;
    fMASInterval:       tTimerInterval;
    fMASTimerEvent:     tTimerEvent;
    fTriggerLevel:      Integer;
    fValueRec:          tIntegerPair;
    fCount:             Integer;
    fMASTimerOnStartup: Boolean;
    //
    fCurrentMinute:         Integer;
    fCurrentDay:            Integer;
    fCurrentHour:           Integer;
     //
    Procedure SetMASInterval   (Const Value: tTimerInterval);
    Procedure SetMASTimerEvent (Const Value: tTimerEvent);
    Procedure DoTimer          (Sender: TObject);
    //
    Procedure Int_LogTimeEvents;
  protected
    { Protected declarations }
    Procedure DoTimeEvent (Const aTimeEvent: tTimeEvent);
    Procedure Reset       (Const aEnable: Boolean);
    Procedure Timer; override;

  public
    { Public declarations }
    Constructor Create (aOwner: tComponent); override;
    //
    Procedure Start; overload;
    Procedure Start (Const aTimerInterval: tTimerInterval; Const aTimerEvent: tTimerEvent; Const aEnable: Boolean); overload;
    Procedure Start (Const aInterval: Integer); overload;
    Procedure Start (Const aInterval: Integer; Const aEnable: Boolean); overload;
    //
    Procedure StartLongEvents;
    Procedure Stop;
    //
    Procedure CallEvent;

  published
    { Published declarations }
    Property MASInterval:       tTimerInterval read fMASInterval       write SetMASInterval default ti1000Ms;
    Property MASTimerEvent:     tTimerEvent    read fMASTimerEvent     write SetMASTimerEvent;
    Property MASTimerOnStartup: Boolean        read fMASTimerOnStartup write fMASTimerOnStartup default False;
    //
    Property OnMASEvent:        tOnMASEvent    read fOnMASEvent        write fOnMASEvent;
    Property OnTimeEvent:       tOnTimeEvent   read fOnTimeEvent       write fOnTimeEvent;
  end;

  Function fnTimerEventToInt (Const aValue: tTimerEvent): Integer;
  Function fnIntToTimerEvent (Const aValue: Integer): tTimerEvent;

implementation

Uses FormatResultU;

Function fnTimerEventToInt (Const aValue: tTimerEvent): Integer;
begin
  Result := Ord (aValue);
end;
Function fnIntToTimerEvent (Const aValue: Integer): tTimerEvent;
begin
  Result := tTimerEvent (aValue);
end;

{ TMASTimer }

Constructor tMASTimer.Create (aOwner: tComponent);
begin
  Inherited;
  Tag                := 0;
  fMASTimerOnStartup := False;
  Self.Enabled       := False;
  fOnMASEvent        := Nil;
  fOnTimeEvent       := nil;
  fMASInterval       := ti1000Ms;
  //
  Reset (False);
end;

procedure tMASTimer.DoTimer (Sender: TObject);
begin
 {}
end;

Procedure tMASTimer.Reset (Const aEnable: Boolean);
begin
  fCount          := 0;
  fTriggerLevel   := 0;
  //
  fValueRec := fnClear_IntegerPair;
  //
  Case fMASInterval of
    ti100Ms:  Self.Interval := 100;
    ti250Ms:  Self.Interval := 250;
    ti500Ms:  Self.Interval := 500;
    ti750Ms:  Self.Interval := 750;
    ti1000Ms: Self.Interval := 1000;
    else Raise Exception.Create ('Error: SetMASInterval. Oops');
  end;
  //
  Case fMASTimerEvent of
    teNone:       Self.Enabled  := False;
    te1Second:    fTriggerLevel := Round (1000   / Self.Interval);
    te5Seconds:   fTriggerLevel := Round (5000   / Self.Interval);
    te10Seconds:  fTriggerLevel := Round (10000  / Self.Interval);
    te15Seconds:  fTriggerLevel := Round (15000  / Self.Interval);
    te30Seconds:  fTriggerLevel := Round (30000  / Self.Interval);
    te60Seconds:  fTriggerLevel := Round (60000  / Self.Interval);
    te120Seconds: fTriggerLevel := Round (120000 / Self.Interval);
    te300Seconds: fTriggerLevel := Round (300000 / Self.Interval);
    teValue:      fTriggerLevel := Round (1000   / Self.Interval);
  End;
  //
  if (fMASTimerEvent <> teNone) then Self.Enabled  := aEnable;
end;

Procedure tMASTimer.SetMASInterval (Const Value: tTimerInterval);
begin
  fMASInterval := Value;
  Reset (False);
end;

Procedure tMASTimer.SetMASTimerEvent (Const Value: tTimerEvent);
begin
  fMASTimerEvent := Value;
  Reset (False);
end;

// Routine: Start
// Author: M.A.Sargent  Date: 06/06/18  Version: V1.0
//
// Notes:
//
Procedure tMASTimer.Start;
begin
  Self.OnTimer := DoTimer;
  // If True then Trigger Event on Start and then wait for the Timer period
  if fMASTimerOnStartup then begin
    fCount := (MaxInt-1);
    if (MASTimerEvent = teValue) then fValueRec.Int1 := (MaxInt-1);
  end;

  Self.Enabled := False;
  Self.Enabled := True;
end;

procedure tMASTimer.Start (Const aTimerInterval: tTimerInterval; Const aTimerEvent: tTimerEvent; Const aEnable: Boolean);
begin
  MASInterval   := aTimerInterval;
  MASTimerEvent := aTimerEvent;
  if aEnable then Start;
end;

Procedure tMASTimer.Start (Const aInterval: Integer);
begin
  Start (aInterval, True);
end;
Procedure tMASTimer.Start (Const aInterval: Integer; Const aEnable: Boolean);
begin
  fnRaiseOnFalse (fnRangeInt (aInterval, cMC_ONE_SECOND, cMC_DAY_IN_SECONDS), 'Error Start. Interval must be between 1 Second and %d Seconds', [cMC_DAY_IN_SECONDS]);
  MASInterval     := ti500Ms;
  MASTimerEvent   := teValue;
  fValueRec.Int2  := aInterval;
  if aEnable then Start;
end;

Procedure tMASTimer.StartLongEvents;
var
  lvNow: TDateTime;
begin
  MASInterval   := ti500Ms;
  MASTimerEvent := te10Seconds;
  //
  lvNow          := Now;
  fCurrentDay    := Trunc    (lvNow);  {}
  fCurrentHour   := HourOf   (lvNow);  {}
  fCurrentMinute := MinuteOf (lvNow);  {}
  //
  Start;
end;

Procedure tMASTimer.Stop;
begin
  Self.Enabled := False;
end;

// Routine: Timer
// Author: M.A.Sargent  Date: 27/03/18  Version: V1.0
//         M.A.Sargent        16/08/18           V2.0
//
// Notes:
//  V2.0: Updated to increment the TAG value everytime the event is called
//
Procedure tMASTimer.Timer;
var
  lvReStart:    Boolean;

  Procedure IntDoEvent;
  var
    x: Integer;
  begin
    lvReStart := True;
    if Assigned (fOnMASEvent) then begin
      //
      Self.Enabled := False;
      Try
        x := Tag;
        Tag := fnInc (x, MaxInt);
        fOnMASEvent (Self, lvReStart);
      Finally
        Self.Enabled := lvReStart;
      End;
    end;
  end;
begin
  Inherited;
  Inc (fCount);
  Case MASTimerEvent of
    teValue: begin
      //
      if (fCount >= fTriggerLevel) then begin
        //
        fCount := 0;
        fValueRec := fnInc1_IntegerPair (fValueRec);
        //
        if (fValueRec.Int1 >= fValueRec.Int2) then begin
          fValueRec.Int1 := 0;
          IntDoEvent;
        end;
      end;
    end;
    else begin
      // As Was
      if (fCount >= fTriggerLevel) then begin
        fCount := 0;
        IntDoEvent;
        Int_LogTimeEvents;
      end;
    end;
  end;
end;

// Routine: CallEvent
// Author: M.A.Sargent  Date: 20/06/18  Version: V1.0
//
// Notes: Set the Enabled False and then setting all the values to thier Trigger points calls Timer
//        will cause the process to Run, Timer will be Enabled after the Event.
//        This should not affect calls to Int_LogTimeEvents as this is fired based on Dates and Times
//
Procedure tMASTimer.CallEvent;
begin
  Self.Enabled := False;
  fCount         := fTriggerLevel;
  fValueRec.Int1 := fValueRec.Int2;
  Timer;
end;

// Routine: Int_LogTimeEvents
// Author: M.A.Sargent  Date: 20/06/18  Version: V1.0
//
// Notes:
//
Procedure tMASTimer.Int_LogTimeEvents;
var
  lvNow: tDateTime;
begin
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

// Routine: DoTimeEvent
// Author: M.A.Sargent  Date: 20/05/2018  Version: V1.0
//
// Notes:
//
Procedure tMASTimer.DoTimeEvent (Const aTimeEvent: tTimeEvent);
begin
  if Assigned (fOnTimeEvent) then fOnTimeEvent (Self, aTimeEvent);
end;

end.
