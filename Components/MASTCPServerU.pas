//
// Unit: MASTCPServerU
// Author: M.A.Sargent  Date: 24/07/2018  Version: V1.0
//
// Notes:
//
unit MASTCPServerU;

interface

uses SysUtils, Classes, IdBaseComponent, IdComponent, IdTCPServer, MASIndyHelpersU, MASRecordStructuresU, MAS_JSonU,
      TSUK_D7_ConstsU;

type
  tOnCmdEvent = Procedure (Const aCommand: tIdCommand; Const aValue: Integer; Const aStr: string) of object;

  tMASTCPServer = class(tidtcpserver)
  private
    { Private declarations }
    fOnCmdEvent: tOnCmdEvent;
    //
    Procedure Int_OnCmd (aSender: tIdCommand);
  Protected
    { Protected declarations }
    Procedure DoCmdEvent (Const aCommand: tIdCommand; Const aValue: Integer; Const aStr: string); virtual;
  Public
    { Public declarations }
    Constructor Create (aOwner: tComponent); override;
  Published
    { Published declarations }
    Property OnCmdEvent: tOnCmdEvent read fOnCmdEvent write fOnCmdEvent;
  end;

implementation

{ tMASTCPServer }

// Routine: Create
// Author: M.A.Sargent  Date: 24/07/18  Version: V1.0
//
// Notes:
//
Constructor tMASTCPServer.Create (aOwner: tComponent);
begin
  inherited;
  //
  fOnCmdEvent := Nil;
  if (Self.CommandHandlers.Count > 0) then
    Self.CommandHandlers.Clear;
  //
  if not (csDesigning in ComponentState) then
    fnAddIndyCommand (Self, cHWC_CMD_REPLY_OK, 'CMD', Int_OnCmd);
end;

// Routine: Int_OnCmd
// Author: M.A.Sargent  Date: 24/07/18  Version: V1.0
//
// Notes:
//
Procedure tMASTCPServer.DoCmdEvent (Const aCommand: tIdCommand; Const aValue: Integer; Const aStr: string);
begin
  if Assigned (fOnCmdEvent) then fOnCmdEvent (aCommand, aValue, aStr);
  //
  //ASender.Reply.SetReply (1000, 'Fred');
end;

// Routine: Int_OnCmd
// Author: M.A.Sargent  Date: 24/07/18  Version: V1.0
//
// Notes:
//
Procedure tMASTCPServer.Int_OnCmd (aSender: tIdCommand);
var
  lvRes: tIntStrRec;
  lvStr: String;
begin
  //
  lvStr := fnGetJSonParams (aSender.Params);
  lvRes := fnJSONToIntStrRec (lvStr);
  //
  DoCmdEvent (aSender, lvRes.Int, lvRes.Msg);
end;

end.
