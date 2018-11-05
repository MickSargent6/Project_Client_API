//
// Unit: MAS_PipesU
// Author: M.A.Sargent  Date: 21/03/18  Version: V1.0
//
// Notes:
//
unit MAS_PipesU;

interface

Uses MASRecordStructuresU, MAS_JSonU, Controls, IdThreadSafe, Classes, SysUtils, Pipes, Math;

Type
  tPipeMessage = Record
    OK: Boolean;
    LineNo, LineTotal: Integer;
    Msg: String[255];
  End;

  tOnReceiveString = Procedure (Sender: TObject; Pipe: HPIPE; Const aString: String) of object;

  tMASPipeClient = Class (TPipeClient)
  Private
    // TODO Add a Queue  TThreadedQueue<tQMessage>;
    fPipeWriteCriticalSection: tIdThreadSafe;
    fThreadSafe:               Boolean;
    fOnReceiveString:          tOnReceiveString;
    fInputString:              String;
    Procedure IntSendPipeMessage (Const aMessageCode: Integer; Const aMsg: String);
    procedure IntSendMsg         (Const aString: String);
  Protected
    Procedure DoMessage (Sender: TObject; Pipe: HPIPE; Stream: TStream); override;
  Public
    Constructor Create (aOwner: tComponent); override;
    Destructor Destroy; override;
    //
    Procedure SendMsg (Const aMsg: String); overload;
    Procedure SendMsg (Const aMessageCode: Integer); overload;
    Procedure SendMsg (Const aMessageCode: Integer; Const aString: String); overload;
    Procedure SendMsg (Const aMessageCode: Integer; Const aOKStrRec: tOKStrRec); overload;
    Procedure SendMsg (Const aMessageCode: Integer; Const aOKCodeStrRec: tOKCodeStrRec); overload;
    Procedure SendMsg (Const aMessageCode: Integer; Const aIntStrRec: tIntStrRec); overload;
  Published
    // Default to Thread Safe SendMsg routines
    Property ThreadSafe: Boolean read fThreadSafe write fThreadSafe default True;
    Property OnReceiveString: tOnReceiveString read fOnReceiveString write fOnReceiveString;
  End;


  tMASPipeServer = Class (TPipeServer)
  private
    fPipeWriteCriticalSection: tIdThreadSafe;
    fThreadSafe:               Boolean;
    fOnReceiveString:          tOnReceiveString;
    Procedure IntSendPipeMessage (Const aMessageCode: Integer; Const aMsg: String);
    Procedure IntSendFileInBits  (Const aString: String);
  Protected
    Procedure DoMessage (Sender: TObject; Pipe: HPIPE; Stream: TStream); override;
  Public
    Constructor Create (aOwner: tComponent); override;
    Destructor Destroy; override;
    //
    Procedure SendMsg (Const aMsg: String); overload;
    Procedure SendMsg (Const aMessageCode: Integer); overload;
    Procedure SendMsg (Const aMessageCode: Integer; Const aString: String); overload;
  Published
    // Default to Thread Safe SendMsg routines
    Property ThreadSafe: Boolean read fThreadSafe write fThreadSafe default True;
    Property OnReceiveString: tOnReceiveString read fOnReceiveString write fOnReceiveString;
  End;

implementation

Const
  cMAXSSHORTSTRING = 255;

{ tMASPipeClient }

// Routine:
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Constructor tMASPipeClient.Create (aOwner: tComponent);
begin
  inherited;
  fOnReceiveString          := Nil;
  fPipeWriteCriticalSection := tIdThreadSafe.Create;
  ThreadSafe                := True;
  fInputString              := '';
end;

Destructor tMASPipeClient.Destroy;
begin
  fPipeWriteCriticalSection.Free;
  inherited;
end;

procedure tMASPipeClient.DoMessage(Sender: TObject; Pipe: HPIPE; Stream: TStream);
var
  lvRes: tPipeMessage;
begin
  inherited;
  if not Assigned (fOnReceiveString) then Exit;

  Stream.Read (lvRes, SizeOf (lvRes));
  //
  //
  if (lvRes.LineNo = 1) and (lvRes.LineTotal = 1) then begin
    fOnReceiveString (Sender, Pipe, lvRes.Msg);
  end
  else begin
    if (lvRes.LineNo = lvRes.LineTotal) then begin
      fInputString := fInputString + lvRes.Msg;
      fOnReceiveString (Sender, Pipe, fInputString);
    end
    else if (lvRes.LineNo = 1) then begin
      fInputString := lvRes.Msg;
    end else begin
      fInputString := (fInputString + lvRes.Msg);
    end;
  end;
end;

// Routine: SendMsg
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Procedure tMASPipeClient.SendMsg (Const aMsg: String);
begin
  SendMsg (0, aMsg);
end;

procedure tMASPipeClient.SendMsg (Const aMessageCode: Integer; Const aOKCodeStrRec: tOKCodeStrRec);
var
  lvStr: String;
begin
  lvStr := fnOKCodeStrRecToJSON (aOKCodeStrRec);
  SendMsg (aMessageCode, lvStr);
end;

procedure tMASPipeClient.SendMsg (Const aMessageCode: Integer; Const aOKStrRec: tOKStrRec);
var
  lvStr: String;
begin
  lvStr := fnOKStrRecToJSON (aOKStrRec);
  SendMsg (aMessageCode, lvStr);
end;

Procedure tMASPipeClient.SendMsg (Const aMessageCode: Integer; Const aIntStrRec: tIntStrRec);
var
  lvStr: String;
begin
  lvStr := fnIntStrRecToJSON (aIntStrRec);
  SendMsg (aMessageCode, lvStr);
end;

Procedure tMASPipeClient.SendMsg (Const aMessageCode: Integer);
begin
  SendMsg (aMessageCode, '');
end;

Procedure tMASPipeClient.SendMsg (Const aMessageCode: Integer; Const aString: String);
begin
  IntSendPipeMessage (aMessageCode, aString);
end;

// Routine: IntSendPipeMessage
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Procedure tMASPipeClient.IntSendPipeMessage (Const aMessageCode: Integer; Const aMsg: String);
var
  lvStr: String;
begin
  if ThreadSafe then fPipeWriteCriticalSection.Lock;
  Try
    if Self.Connected then begin
      lvStr := fnIntStrRecToJSON (aMessageCode, aMsg);
      IntSendMsg (lvStr);
    end;
  Finally
    if ThreadSafe then fPipeWriteCriticalSection.UnLock;
  End;
end;

// Routine: IntSendMsg
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Procedure tMASPipeClient.IntSendMsg (Const aString: String);
var
  lvOrig: tPipeMessage;
begin
  Case (Length (aString) <= cMAXSSHORTSTRING) of
    True: begin
      lvOrig.OK        := True;
      lvOrig.LineNo    := 1;
      lvOrig.LineTotal := 1;
      lvOrig.Msg       := aString;
      Self.Write (lvOrig, SizeOf (lvOrig));
    end;
    else raise Exception.Create ('Error: IntSendMsg. Max String Size is 255 Characters');
  end;
end;

{ tMASPipeServer }

Constructor tMASPipeServer.Create (aOwner: tComponent);
begin
  inherited;
  fOnReceiveString := Nil;
  fPipeWriteCriticalSection := tIdThreadSafe.Create;
  ThreadSafe := True;
end;

Destructor tMASPipeServer.Destroy;
begin
  fPipeWriteCriticalSection.Free;
  inherited;
end;

Procedure tMASPipeServer.DoMessage(Sender: TObject; Pipe: HPIPE; Stream: TStream);
var
  lvRes: tPipeMessage;
  lvStr: String;
begin
  inherited;
  if not Assigned (fOnReceiveString) then Exit;

  Stream.Read (lvRes, SizeOf (lvRes));
  //
  if (lvRes.LineNo = 1) and (lvRes.LineTotal = 1) then begin
    lvStr := lvRes.Msg;
    fOnReceiveString (Sender, Pipe, lvStr);
  end;
end;

Procedure tMASPipeServer.SendMsg (Const aMsg: String);
begin
  SendMsg (0, aMsg);
end;
Procedure tMASPipeServer.SendMsg (Const aMessageCode: Integer);
begin
  SendMsg (aMessageCode, '');
end;
Procedure tMASPipeServer.SendMsg (Const aMessageCode: Integer; Const aString: String);
begin
  IntSendPipeMessage (aMessageCode, aString);
end;

// Routine: IntSendPipeMessage
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Procedure tMASPipeServer.IntSendPipeMessage (Const aMessageCode: Integer; Const aMsg: String);
var
  lvStr: String;
begin
  if ThreadSafe then fPipeWriteCriticalSection.Lock;
  Try
    if Self.Active then begin
      lvStr := fnIntStrRecToJSON (aMessageCode, aMsg);
      IntSendFileInBits (lvStr);
    end;
  Finally
    if ThreadSafe then fPipeWriteCriticalSection.UnLock;
  End;
end;

// Routine: IntSendFileInBits
// Author: M.A.Sargent  Date: 20/03/18  Version: V1.0
//
// Notes:
//
Procedure tMASPipeServer.IntSendFileInBits (Const aString: String);
var
  x: Integer;
  lvOrig: tPipeMessage;
  lvWorker: String;
begin
  Case (Length (aString) <= cMAXSSHORTSTRING) of
    True: begin
      lvOrig.OK        := True;
      lvOrig.LineNo    := 1;
      lvOrig.LineTotal := 1;
      lvOrig.Msg       := aString;
      //Self.Write (lvOrig, SizeOf (lvOrig));
      Self.Broadcast (lvOrig, SizeOf (lvOrig));

    end;
    else begin
      //
      lvWorker := aString;
      lvOrig.LineTotal := Ceil (Length (aString) / cMAXSSHORTSTRING);
      for x := 1 to lvOrig.LineTotal do begin
        lvOrig.OK        := True;
        lvOrig.LineNo    := x;
        lvOrig.Msg       := Copy (lvWorker, 1, cMAXSSHORTSTRING);
        lvWorker         := Copy (lvWorker, (cMAXSSHORTSTRING + 1), MaxInt);
        //Self.Write (lvOrig, SizeOf (lvOrig));
        Self.Broadcast (lvOrig, SizeOf (lvOrig));
      end;
    end;
  end;
end;

end.
