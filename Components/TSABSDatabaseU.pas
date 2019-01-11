//
// Unit: TSABSDatabaseU
// Author: M.A.Sargent  Date: 30/10/18  Version: V1.0
//
// Notes:
//

unit TSABSDatabaseU;

interface

uses
  SysUtils, Classes, ABSMain;

type
  TTSABSDatabase = class(TABSDatabase)
  protected
    { Protected declarations }
    Procedure ReadState(Reader: TReader); override;
    Procedure WriteState(Writer: TWriter); override;
  end;

implementation


procedure TTSABSDatabase.ReadState (Reader: TReader);
begin
  inherited;
  Connected := False;
end;

procedure TTSABSDatabase.WriteState (Writer: TWriter);
begin
  inherited;
  Connected := False;
end;

end.
