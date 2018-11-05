//
// Unit: MAS_DS_TypesU
// Author: M.A.Sargent  Date: 21/10/2017  Version: V1.0
//
//
// Notes:
//
unit MAS_DS_TypesU;

interface

Uses MASRecordStructuresU;

Type
  tLogonType = (ltPlainTestAccess, ltEncryptedUsernamePassword, ltGuid, ltFull);

  tAccessInfoRec = Record
    aLogonType:           tLogonType;
    aPCName:              String;
    aGUID:                String;
    aMachineID:           String;
    aSchema:              String;
    aHash:                String;
    aValuePairListAsText: String;
    Procedure Clear;
  End;

  tConnectionInfoRec = Record
    aIsLoaded:  Boolean;
    aLogonType: tLogonType;
    aURL:       String;
    aGUID:      String;
    aPort:      Integer;
    aSchema:    String;
    aHash:      String;
    aUsername:  String;
    aPassword:  String;
    aMachineID: String;
    //aHash: String;
    Procedure Clear;
    Procedure SetValue (Const aLogonType: tLogonType; Const aPort: Integer; Const aURL, aGUID, aSchema, aHash, aUsername, aPassword, aMachineID: String);
  end;

  tOKAccessInfoRec = Record
    aOK:         tOKStrRec;
    aAccessInfo: tAccessInfoRec;
    Procedure Clear;
    {Will Set OK.OK True}
    Procedure SetValue (Const aLogonType: tLogonType; Const aPCName, aGUID, aMachineID, aSchema, aHash, aValuePairListAsText: String); overload;
    Procedure SetValue (Const aOKStrRec: tOKStrRec); overload;
    {Will Set OK.OK False}
    Procedure SetFalse (Const aMsg: String);
  End;

  tServerRecord = Record
    aGUID:      String;
    aSchema:    String;
    aUserName:  String;
    aPassword:  String;
    aMachineId: String;
    aPeerIP:    String;
    Procedure Clear;
    Procedure SetValue (Const aGUID, aSchema, aUserName, aPassword, aMachineId: String); overload;
    Procedure SetValue (Const aUserName, aPassword, aMachineId, aPeerIP: String); overload;
  End;


implementation

Uses MAS_DS_CommonU;

{ tAccessInfoRec }

Procedure tAccessInfoRec.Clear;
begin
  aLogonType           := ltPlainTestAccess;
  aPCName              := '';
  aGUID                := '';
  aMachineID           := '';
  aSchema              := '';
  aHash                := '';
  aValuePairListAsText := '';
end;

{ tOKAccessInfoRec }

procedure tOKAccessInfoRec.Clear;
begin
  aOK.Clear;
  aAccessInfo.Clear;
end;

Procedure tOKAccessInfoRec.SetFalse (Const aMsg: String);
begin
  Self.aOK.OK  := False;
  Self.aOK.Msg := aMsg;
end;

Procedure tOKAccessInfoRec.SetValue (Const aOKStrRec: tOKStrRec);
begin
  Clear;
  Self.aOK := aOKStrRec;
end;

Procedure tOKAccessInfoRec.SetValue (Const aLogonType: tLogonType; Const aPCName, aGUID, aMachineID, aSchema, aHash, aValuePairListAsText: String);
begin
  Self.Clear;
  Self.aAccessInfo.aLogonType           := aLogonType;
  Self.aAccessInfo.aPCName              := aPCName;
  Self.aAccessInfo.aGUID                := aGUID;
  Self.aAccessInfo.aMachineID           := aMachineID;
  Self.aAccessInfo.aSchema              := aSchema;
  Self.aAccessInfo.aHash                := aHash;
  Self.aAccessInfo.aValuePairListAsText := aValuePairListAsText;
end;

{ tConnectionInfoRec }

procedure tConnectionInfoRec.Clear;
begin
  aIsLoaded  := False;
  aLogonType := ltPlainTestAccess;
  aURL       := '';
  aGUID      := '';
  aPort      := 0;
  aSchema    := '';
  aHash      := '';
  aUsername  := '';
  aPassword  := '';
  aMachineID := '';
end;

Procedure tConnectionInfoRec.SetValue (Const aLogonType: tLogonType; Const aPort: Integer; Const aURL, aGUID, aSchema, aHash, aUsername, aPassword, aMachineID: String);
begin
  Self.aIsLoaded  := True;
  Self.aLogonType := aLogonType;
  Self.aURL       := aURL;
  Self.aGUID      := aGUID;
  Self.aPort      := aPort;
  Self.aSchema    := aSchema;
  Self.aHash      := aHash;
  Self.aUsername  := aUsername;
  Self.aPassword  := aPassword;
  Self.aMachineID := aMachineID;
end;

{ tServerRecord }

Procedure tServerRecord.Clear;
begin
  SetValue ('', '', '', '', '');
  Self.aPeerIP := '';
end;

Procedure tServerRecord.SetValue (Const aGUID, aSchema, aUserName, aPassword, aMachineId: String);
begin
  Self.aGUID      := aGUID;
  Self.aSchema    := aSchema;
  Self.aUserName  := aUserName;
  Self.aPassword  := aPassword;
  Self.aMachineId := aMachineId;
end;

Procedure tServerRecord.SetValue (Const aUserName, aPassword, aMachineId, aPeerIP: String);
begin
  SetValue ('', '', aUserName, aPassword, aMachineId);
  Self.aPeerIP := aPeerIP;
end;

end.
