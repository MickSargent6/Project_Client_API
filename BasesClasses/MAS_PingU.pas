//
// Unit: MAS_PingU
// Author: M.A.Sargent  Date: 03/08/18  Version: V1.0
//         M.A.Sargent        12/09/18           V2.0
//
// Notes:
//
unit MAS_PingU;

interface

Uses Classes, SysUtils, IdIcmpClient, IdException, MASRecordStructuresU, Forms, Dialogs, MAS_ConstsU,
      MatchUtilsU;

Type
  tOnMessage = Procedure (Const aMsg: String) of object;

  tMAS_Ping = Class (TObject)
  Private
    fTCPPing:         tIdIcmpClient;
    fOnMessage:       tOnMessage;
    fPingLoop:        Integer;
    //
    Procedure DoMessage (Const aMsg: String); overload; virtual;
    Procedure DoMessage (Const aFormat: String; Const Args: Array of Const); overload; virtual;
    //
    Property PingLoop: Integer read fPingLoop write fPingLoop default cMC_THREE;
  Public
    Constructor Create; virtual;
    Destructor Destroy; override;
    //
    Function fnPing (Const aHost: string): tOKStrRec;
    Function fnEcho (Const aHost: String; aTimeOut: Integer = cMC_10_SECONDS): tOKStrRec;
    //
    Property OnMessage: tOnMessage read fOnMessage write fOnMessage;
  end;

  // Helper fucntions
  Function h_PingEcho (Const aHost: String; aTimeOut: Integer = cMC_10_SECONDS): tOKStrRec;


implementation

Uses MAS_FormatU, MAS_HashsU, FormatResultU, MASCommonU, DateUtils;

Function h_PingEcho (Const aHost: String; aTimeOut: Integer = cMC_10_SECONDS): tOKStrRec;
var
  lvObj: tMAS_Ping;
begin
  lvObj := tMAS_Ping.Create;
  Try
    Result := lvObj.fnEcho (aHost, aTimeOut);
  finally
    lvObj.Free;
  end;
end;

{ tMAS_Ping }

// Routine:
// Author: M.A.Sargent  Date: 03/08/18  Version: V1.0
//
// Notes:
//
Constructor tMAS_Ping.Create;
begin
  fTCPPing   := tIdIcmpClient.Create (Nil);
  fOnMessage := Nil;
  fPingLoop  := cMC_THREE;
end;

Destructor tMAS_Ping.Destroy;
begin
  fTCPPing.Free;
  inherited;
end;

// Routine:
// Author: M.A.Sargent  Date: 03/08/18  Version: V1.0
//
// Notes:
//
Procedure tMAS_Ping.DoMessage (Const aMsg: String);
begin
  if Assigned (fOnMessage) then fOnMessage (aMsg);
end;
Procedure tMAS_Ping.DoMessage (Const aFormat: String; Const Args: array of Const);
begin
  DoMessage (fnTS_Format (aFormat, Args));
end;

// Routine: fnPing
// Author: M.A.Sargent  Date: 03/08/18  Version: V1.0
//
// Notes:
//
Function tMAS_Ping.fnPing (Const aHost: String): tOKStrRec;
var
  lvCount:    Integer;
  lvProblems: Boolean;
begin
  lvProblems := False;
  Result     := fnClear_OKStrRec;
  Try
    lvCount    := 0;
    DoMessage ('Pinging %s with data', [fTCPPing.Host]);
    Repeat
      Application.ProcessMessages;
      fTCPPing.Host:= aHost;
      Try
        fTCPPing.Ping (MD5_AsStr (fTCPPing.Host));
        with fTCPPing do begin
          // Lock True is any answer other than rsEcho
          if (ReplyStatus.ReplyStatusType <> rsEcho) then lvProblems := True;
          //
          Case ReplyStatus.ReplyStatusType of
            rsEcho:             DoMessage  ('  Reply from: %s: Bytes:%d Time<%dms TTL=%d', [Host, ReplyStatus.BytesReceived, ReplyStatus.MsRoundTripTime, ReplyStatus.TimeToLive]);
            rsError:            DoMessage  ('  Error: ');
            rsTimeOut:          DoMessage  ('  Request Timed Out');
            rsErrorUnreachable: DoMessage  ('  Reply from: %s: Destination host unreachable', [ReplyStatus.FromIpAddress]);
            rsErrorTTLExceeded: DoMessage  ('  Time To Live Exceeded: %d', [ReplyStatus.TimeToLive]);
            else Raise Exception.CreateFmt ('Unknown Type: %d', [Ord (ReplyStatus.ReplyStatusType)]);
          end;
        end;
        Inc (lvCount);
        Sleep (1500);
      except
        on e:EIdSocketError do begin
          Case e.LastError of
            11001: begin
                     Result := fnResult ('  Ping request could not find host: %s', [fTCPPing.Host]);
                     DoMessage (Result.Msg);
            end;
            else Raise;
          end;
          Break;
        end;
      end;
    until (lvCount >= fPingLoop)
    //
  Except
    On E:Exception do
      Result := fnResultException ('fnPing', 'Failed to Ping Remote Host: %s', [aHost], e);
  end;
  Case Result.OK of
    True: ShowMessage (fnTS_Format ('Host: %s Pinged. %s', [aHost, IfTrue (lvProblems,  'With Problems', 'OK')]));
    else  ShowMessage (fnTS_Format ('Ping Failed: %s', [Result.Msg]));
  end;
end;

// Routine: fnEcho
// Author: M.A.Sargent  Date: 03/08/18  Version: V1.0
//
// Notes:
//
Function tMAS_Ping.fnEcho (Const aHost: String; aTimeOut: Integer): tOKStrRec;
var
  lvCount:     Integer;
  lvProblems:  Boolean;
  lvStartTime: tDateTime;
begin
  lvProblems := False;
  Result     := fnClear_OKStrRec (False);
  Try
    // Range check, must be betwen 1 & 30 seconds, default 10 seconds
    aTimeOut := fnRangeInt (aTimeOut, cMC_1000Ms, cMC_30_SECONDS_Ms, cMC_10_SECONDS_Ms);
    // Start
    lvStartTime   := Now;
    lvCount       := 0;
    Repeat
      fTCPPing.Host := aHost;
      Try
        fTCPPing.Ping (MD5_AsStr (fTCPPing.Host));
        with fTCPPing do begin
          // Lock True is any answer other than rsEcho
          if (ReplyStatus.ReplyStatusType <> rsEcho) then lvProblems := True;
          //
          Case ReplyStatus.ReplyStatusType of
            rsEcho:             Result     := fnResultOK ('Echo OK. %dms %s', [MilliSecondsBetween (Now, lvStartTime), IfTrue (lvProblems, 'With Problems', '')]);
            rsError:            Result.Msg := '  Error: ';
            rsTimeOut:          Result.Msg := '  Request Timed Out';
            rsErrorUnreachable: Result.Msg := fnTS_Format ('  Reply from: %s: Destination host unreachable', [ReplyStatus.FromIpAddress]);
            rsErrorTTLExceeded: Result.Msg := fnTS_Format ('  Time To Live Exceeded: %d', [ReplyStatus.TimeToLive]);
            else Raise Exception.CreateFmt ('Unknown Type: %d', [Ord (ReplyStatus.ReplyStatusType)]);
          end;
        end;
        Inc (lvCount);
        Sleep (cMC_250ms);
      except
        on e:EIdSocketError do begin
          Case e.LastError of
            11001: Result.Msg := fnTS_Format ('  Echo request could not find host: %s', [fTCPPing.Host]);
            else Raise;
          end;
          Break;
        end;
      end;
      //
      Case Result.OK of
        True: Break;
        else begin
          //
          if (MilliSecondsBetween (Now, lvStartTime) > aTimeOut) then begin
            Result.Msg := fnTS_Format ('Error:  Echo request to host: %s Timed Out After. %dms', [fTCPPing.Host, aTimeOut]);
            Break;
          end;
        end;
      end;
    // 120 - Max Time 30 seoncs / 250ms = 120
    until (lvCount >= 120);
    //
  Except
    On E:Exception do
      Result := fnResultException ('fnEcho', 'Failed to Ping Remote Host: %s', [aHost], e);
  end;
end;

end.
