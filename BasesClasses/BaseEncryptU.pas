//
// Unit: BaseEncryptU
// Author: M.A.Sargent  Date: 25/04/15  Version: V1.0
//
// Notes:
//
unit BaseEncryptU;
                                                       
interface

Uses Classes, SysUtils;

Type
  tBaseEncrypt = Class;
  tOnKey = Procedure (Sender: tBaseEncrypt; var aKey: String) of object;

  tBaseEncrypt = Class (tObject)
  Private
    fKey: String;
    fOnKey: tOnKey;
  Protected
    Procedure DoOnKey (var aKey: String); virtual;
  Public
    Constructor Create; overload; virtual;
    Constructor Create (Const aKey: String); overload; virtual;
    //
    Procedure EncryptString (var aString: String); virtual;
    Procedure EncryptList (Const aStrings: tStrings); virtual;
    Procedure EncryptFile (Const aFileName: String); virtual;
    //
    Procedure DecryptString (var aString: String); virtual;
    Procedure DecryptList (Const aStrings: tStrings); virtual;
    Procedure DecryptFile (Const aFileName: String); virtual;
    //
    Property Key: String read fKey write fKey;
    Property OnKey: tOnKey read fOnKey write fOnKey;
  end;

implementation

{ tBaseEncrypt }

Constructor tBaseEncrypt.Create;
begin
  fOnKey := Nil;
end;

Constructor tBaseEncrypt.Create (Const aKey: String);
begin
  Create;
  Key := aKey;
end;

procedure tBaseEncrypt.DecryptFile (Const aFileName: String);
begin
end;

procedure tBaseEncrypt.DecryptList (Const aStrings: tStrings);
begin
end;

procedure tBaseEncrypt.DecryptString (var aString: String);
begin
end;

Procedure tBaseEncrypt.DoOnKey (var aKey: String);
begin
  if Assigned (fOnKey) then fOnKey (Self, aKey);
end;

procedure tBaseEncrypt.EncryptFile (Const aFileName: String);
begin
end;

procedure tBaseEncrypt.EncryptList (Const aStrings: tStrings);
begin
end;

procedure tBaseEncrypt.EncryptString (var aString: String);
begin
end;

end.
