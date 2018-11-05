//
// Unit: MASIndyHelpersU
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes:
//
unit MASIndyHelpersU;

interface

Uses Classes,
     {$IFDEF VER150}
     IdTCPServer;
     {$ELSE}
     IdCommandHandlers, IdCmdTCPServer;
     {$ENDIF}


  Function fnAddIndyCommand (aIdCmdTCPServer: {$IFDEF VER150}TIdTCPServer{$ELSE}TIdCmdTCPServer{$ENDIF}; Const aNumericCode: Integer;
                              Const aCommand: String; Const aOnCommand: tIdCommandEvent): tIdCommandHandler; overload;

  Function fnAddIndyCommand (aIdCmdTCPServer: {$IFDEF VER150}TIdTCPServer{$ELSE}TIdCmdTCPServer{$ENDIF}; Const aNumericCode: Integer;
                              Const aCmdDelimiter, aParamDelimiter: Char;
                               Const aCommand, aName: String;
                                Const aDisconnect, aEnabled, aParseParams: Boolean;
                                 Const aOnCommand: tIdCommandEvent): tIdCommandHandler; overload;
  //
  Function fnGetJSonParams (Const aParams: tStrings): String;

implementation

Function fnAddIndyCommand (aIdCmdTCPServer: {$IFDEF VER150}TIdTCPServer{$ELSE}TIdCmdTCPServer{$ENDIF}; Const aNumericCode: Integer;
                            Const aCommand: String; Const aOnCommand: tIdCommandEvent): tIdCommandHandler;
begin
  //
  Result := fnAddIndyCommand (aIdCmdTCPServer, aNumericCode, #32, #32, aCommand, (aCommand+'1'), False, True, True, aOnCommand);
end;

Function fnAddIndyCommand (aIdCmdTCPServer: {$IFDEF VER150}TIdTCPServer{$ELSE}TIdCmdTCPServer{$ENDIF}; Const aNumericCode: Integer;
                            Const aCmdDelimiter, aParamDelimiter: Char;
                             Const aCommand, aName: String;
                              Const aDisconnect, aEnabled, aParseParams: Boolean;
                               Const aOnCommand: tIdCommandEvent): tIdCommandHandler;

// property ExceptionReply: TIdReply read FExceptionReply write SetExceptionReply;
// property NormalReply: TIdReply read FNormalReply write SetNormalReply;
// property Response: TStrings read FResponse write SetResponse;

begin
  Result := Nil;
  if not Assigned (aIdCmdTCPServer) then Exit;
  if not Assigned (aIdCmdTCPServer.CommandHandlers) then Exit;
  //
  Result := aIdCmdTCPServer.CommandHandlers.Add;
  Result.CmdDelimiter            := aCmdDelimiter;
  Result.Command                 := aCommand;
  Result.Disconnect              := aDisconnect;
  Result.Name                    := aName;
  {$IFDEF VER150}
  Result.ReplyNormal.NumericCode := aNumericCode;
  {$ELSE}
  Result.NormalReply.NumericCode := aNumericCode;
  {$ENDIF}
  Result.ParamDelimiter          := aParamDelimiter;
  Result.ParseParams             := aParseParams;
  Result.OnCommand               := aOnCommand;
end;

// Routine: fnGetJSonParams
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes: Stitch back together the Params into one long string, passed as JSON it contains spaces
//
Function fnGetJSonParams (Const aParams: tStrings): String;
var
  x: Integer;
begin
  Result := '';
  if not Assigned (aParams) then Exit;
  //
  for x := 0 to aParams.Count-1 do begin
    //
    Result := (Result + aParams [(x)]) + ' ';
  end;
end;

end.
