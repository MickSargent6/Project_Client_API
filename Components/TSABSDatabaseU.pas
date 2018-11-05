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
  tTSABSDatabase = class(TABSDatabase)
  protected
    { Protected declarations }
    Procedure ReadState(Reader: TReader); override;
    Procedure WriteState(Writer: TWriter); override;
  end;

implementation


Procedure tTSABSDatabase.ReadState (Reader: TReader);
begin
  inherited;
  Connected := False;
end;

Procedure tTSABSDatabase.WriteState (Writer: TWriter);
begin
  inherited;
  Connected := False;
end;

end.
