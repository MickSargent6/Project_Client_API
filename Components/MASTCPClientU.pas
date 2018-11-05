//
// Unit: MASTCPClientU
// Author: M.A.Sargent  Date: 24/07/2018  Version: V1.0
//
// Notes:
//
unit MASTCPClientU;

interface

uses
  SysUtils, Classes, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, MASRecordStructuresU, MAS_JSonU;

type
  tMASTCPClient = class (TIdTCPClient)
  private
    { Private declarations }
    fMustBeJSon: Boolean;
  protected
    { Protected declarations }
  public
    { Public declarations }
    Constructor Create (aowner: TComponent); override;
    //
    Function fnSendCmd (Const aCmdCode: Integer; Const aParams: String; Const aResultCode: Integer): tOKStrRec; overload;
    Function fnSendCmd (Const aCmdCode: Integer; Const aParams: String; Const aResponse: Array of SmallInt): tOKStrRec; overload;
    //
    Function fnSendCmd (Const aCmd: string; Const aCmdCode: Integer; Const aParams: String; Const aResultCode: Integer): tOKStrRec; overload;
    Function fnSendCmd (Const aCmd: string; aCmdCode: Integer; Const aParams: String; Const aResponse: Array of SmallInt): tOKStrRec; overload;
    //
    Property MustBeJSon: Boolean read fMustBeJSon write fMustBeJSon default True;
  published
    { Published declarations }
  end;

implementation

Uses FormatResultU, MAS_JSon_D7U;

{ tMASTCPClient }

// Routine: fnSendCmd
// Author: M.A.Sargent  Date: 24/07/18  Version: V1.0
//
// Notes: Updated to detect a period '.', if found the
//
Function tMASTCPClient.fnSendCmd (Const aCmdCode: Integer; Const aParams: String; Const aResultCode: Integer): tOKStrRec;
begin
  Result := fnSendCmd (aCmdCode, aParams, [aResultCode]);
end;
Function tMASTCPClient.fnSendCmd (Const aCmdCode: Integer; Const aParams: String; Const aResponse: Array of SmallInt): tOKStrRec;
begin
  Result := fnSendCmd ('CMD', aCmdCode, aParams, aResponse);
end;
Function tMASTCPClient.fnSendCmd (Const aCmd: string; Const aCmdCode: Integer; Const aParams: String; Const aResultCode: Integer): tOKStrRec;
begin
  Result := fnSendCmd ('CMD', aCmdCode, aParams, [aResultCode]);
end;
Constructor tMASTCPClient.Create(aowner: TComponent);
begin
  inherited;
   fMustBeJSon := True;
end;

Function tMASTCPClient.fnSendCmd (Const aCmd: string; aCmdCode: Integer; Const aParams: String; Const aResponse: Array of SmallInt): tOKStrRec;
var
  lvJSonString: tJSONString2;
begin
  Result := fnClear_OKStrRec;
  Try
    if fMustBeJSon then
      if not fnChkJSon (aParams, False) then Raise Exception.Create ('Error: fnSendCmd. aParams Must be a in JSon Format');
      //if (Copy x (aParams, 1, 1) <> '{') then Raise Exception.Create ('Error: fnSendCmd. aParams Must be a in JSon Format');
    //
    lvJSonString := fnIntStrRecToJSON (aCmdCode, aParams);
    Result.ExtendedInfoRec.aCode := Self.SendCmd ((aCmd + ' ' + lvJSonString), aResponse);
    //
    Result.Msg := Trim (Self.LastCmdResult.Text.Text);
  Except
    on e:Exception do
      Result := fnResultException ('fnSendCmd', 'Failed to Process Commands: %d, (%s)', [aCmdCode, aParams], e);
  end;
end;

end.
