//
// Unit: MASmySQLDatabase
// Author: M.A.Sargent  Date: 09/11/13  Version: V1.0
//
// Notes:
//
unit MASmySQLDatabase;

interface

uses
  SysUtils, Classes, DB, mySQLDbTables;

type
  tMASMySQLDatabase = class (tMySQLDatabase)
  private
    function GetVersion: String;
  protected
    { Protected declarations }
    procedure ReadState(Reader: TReader); override;
    procedure WriteState(Writer: TWriter); override;
  Public
    Property Version: String read GetVersion;
  end;

implementation

{ tMASMySQLDatabase }

function tMASMySQLDatabase.GetVersion: String;
var
  lvStr: String;
begin
  lvStr := IntToStr (ServerVersion);
  Result := Format ('%s.%s.%s', [Copy (lvStr, 1, 1), Copy (lvStr, 2, 2), Copy (lvStr, 4, 2)])
end;

procedure tMASMySQLDatabase.ReadState(Reader: TReader);
begin
  inherited;
  Connected := False;
end;

procedure tMASMySQLDatabase.WriteState(Writer: TWriter);
begin
  inherited;
  Connected := False;
end;

end.
