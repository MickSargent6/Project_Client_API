//
// Unit: TSUK_D7_EncryptU
// Author: M.A.Sargent  Date: 17/05/18  Version: V1.0
//
// Notes:
//
unit TSUK_D7_EncryptU;

interface

uses Classes, BaseEncryptU, DECCipher, uTSCrypto, SysUtils, MAS_MemIniU;

type
  eTSException_NotEncryptedText = Class (Exception);

  tTS_BaseEncrypt  = class (tBaseEncrypt)
  private
   fCipher:   tTS3Encryptor;
  public
    Constructor Create; override;
    Destructor  Destroy; override;
    //
    Procedure EncryptList (Const aStrings: tStrings); override;
    Procedure DecryptList (Const aStrings: tStrings); override;
  end;

  tTSUK_Encrypt_MemIniFile = Class (tMAS_Encrypt_MemIniFile)
  Private
    fTSCipher:   tTS_BaseEncrypt;
    fFileName: String;
  Public
    Constructor Create_ActivationServer (Const aKey, aFileName: String); virtual;
    Destructor Destroy; override;

  end;

implementation

{ tTS_BaseEncrypt }

// Routine: Create
// Author: M.A.Sargent  Date: 17/05/18  Version: V1.0
//
// Notes:
//
Constructor tTS_BaseEncrypt.Create;
begin
  inherited;
  fCipher := tTS3Encryptor.Create (aecAcceptOnlyEncrypted, aecWriteEncrypted);
end;

Destructor tTS_BaseEncrypt.Destroy;
begin
  fCipher.Free;
  inherited;
end;

// Routine: Create
// Author: M.A.Sargent  Date: 17/05/18  Version: V1.0
//
// Notes:
//
Procedure tTS_BaseEncrypt.EncryptList (Const aStrings: tStrings);
var
  x:     Integer;
  lvStr: String;
begin
  inherited;
  if not Assigned (aStrings) then Exit;
  for x := 0 to aStrings.Count-1 do begin
    lvStr        := fCipher.Encrypt (aStrings [x]);
    aStrings [x] := lvStr;
  end;
end;

Procedure tTS_BaseEncrypt.DecryptList (Const aStrings: tStrings);
var
  x:     Integer;
  lvStr: String;
begin
  inherited;
  if not Assigned (aStrings) then Exit;
  for x := 0 to aStrings.Count-1 do begin

    if not fCipher.LineIsEncrypted (aStrings [x]) then Raise eTSException_NotEncryptedText.Create ('Line Not Encrypted');
    lvStr        := fCipher.Decrypt (aStrings [x]);
    aStrings [x] := lvStr;
  end;
end;

{TSUK_Encrypt_MemIniFile}


Constructor tTSUK_Encrypt_MemIniFile.Create_ActivationServer (Const aKey, aFileName: String);
begin
  Try
    fTSCipher   := tTS_BaseEncrypt.Create;
    fFileName := aFileName;
    CreateEventsBaseEncrypt (fTSCipher, aKey, aFileName);
  Except
    on e:eTSException_NotEncryptedText do begin
      DeleteFile (aFileName);
      Int_IniFileLoadedOK := False;
    end;
  end;
end;

Destructor tTSUK_Encrypt_MemIniFile.Destroy;
begin
  fTSCipher.Free;
  Inherited;
end;

end.
