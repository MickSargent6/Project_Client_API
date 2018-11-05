//
// Unit: DateEventU
// Author: M.A.Sargent  Date: 03/01/15  Version: V1.0
//
// Notes:
//
unit DateEventU;

interface

Uses SysUtils, DateUtils;

Type
  tDateDifference = (ddMinute, ddHours, ddDay);

Type
  tDateEvent = Class (tObject)
  Private
    fStartDate: tDateTime;
    fCurrentDate: tDateTime;
    fDiffSeconds: tDateTime;
    fDiffMinutes: tDateTime;
    fDiffHours: tDateTime;
    fDiffDays: tDateTime;
  Public
    Constructor Create;
    //Destructor Destroy; override;
    //
    Function Reset: tDateTime;
    Function fnSet: tDateTime;
    //
    Function fnHasDayChanged: Boolean; overload;
    Function fnHasDayChanged (Const aValue: Integer): Boolean; overload;
    //
    Function fnHasHourChanged: Boolean; overload;
    Function fnHasHourChanged (Const aValue: Integer): Boolean; overload;
    //
    Function fnHasMinuteChanged: Boolean; overload;
    Function fnHasMinuteChanged (Const aValue: Integer): Boolean; overload;
    //
    Function fnHasSecondChanged: Boolean; overload;
    Function fnHasSecondChanged (Const aValue: Integer): Boolean; overload;
  end;

implementation

{ tDateEvent }

Constructor tDateEvent.Create;
begin
  fStartDate := Reset;
end;

{Destructor tDateEvent.Destroy;
begin
  inherited;
end;}

Function tDateEvent.Reset: tDateTime;
begin
  Result        := Now;
  fCurrentDate  := Result;
  //
  fDiffMinutes  := Result;
  fDiffHours    := Result;
  fDiffDays     := Result;
  fDiffSeconds  := Result;
end;

Function tDateEvent.fnSet: tDateTime;
begin
  fCurrentDate := Now;
end;

Function tDateEvent.fnHasMinuteChanged: Boolean;
begin
  Result := fnHasMinuteChanged (1);
end;

Function tDateEvent.fnHasHourChanged: Boolean;
begin
  Result := fnHasHourChanged (1);
end;

Function tDateEvent.fnHasDayChanged: Boolean;
begin
  Result := fnHasDayChanged (1);
end;

Function tDateEvent.fnHasSecondChanged: Boolean;
begin
  Result := fnHasSecondChanged (1);
end;

Function tDateEvent.fnHasDayChanged (Const aValue: Integer): Boolean;
var
  lvDays: Integer;
begin
  lvDays := DaysBetween (fCurrentDate, fDiffDays);
  //
  Result := (lvDays >= aValue);
  if Result then
    fDiffDays := fCurrentDate;
end;

Function tDateEvent.fnHasHourChanged (Const aValue: Integer): Boolean;
var
  lvHours: Integer;
begin
  lvHours := HoursBetween (fCurrentDate, fDiffHours);
  //
  Result := (lvHours >= aValue);
  if Result then
    fDiffHours := fCurrentDate;
end;

Function tDateEvent.fnHasMinuteChanged (Const aValue: Integer): Boolean;
var
  lvMinutes: Integer;
begin
  lvMinutes := MinutesBetween (fCurrentDate, fDiffMinutes);
  //
  Result := (lvMinutes >= aValue);
  if Result then
    fDiffMinutes := fCurrentDate;
end;

Function tDateEvent.fnHasSecondChanged (Const aValue: Integer): Boolean;
var
  lvSeconds: Integer;
begin
  lvSeconds := SecondsBetween (fCurrentDate, fDiffSeconds);
  //
  Result := (lvSeconds >= aValue);
  if Result then
    fDiffSeconds := fCurrentDate;
end;

end.

