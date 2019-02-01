//
// Unit: MAS_ABS_QueryCacheU
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes: Cache is used to in TS to create tQuery Components, they can then:
//          1. Recalled by name, using a Sorted tStringList, quick as a Find on Sorted StringList can be
//          2. The Last Named tQuery is keep so if calling the same tquery as quick as it can be, could not be quicker.
//          3. If calling more than 1 routine in a loop many times us fnQry and assign to a variable so you do not
//             have to keep loooking it up, if small loop dont bother but if 1000s for iterations may be worth doing
//          4. For tQuery it is best that they are parameterised and then call fnRunQuery or fnExecQuery
//
//
unit MAS_ABS_QueryCacheU;

interface

uses Classes, SysUtils, MASStringListU, MASRecordStructuresU, Db, MAS_QueryCacheU, TSAbsSQLQuery, AbsMain;

Type

  TAbsSQLCache = Class (TSQLCache)
  Private
    Function  fnCast          (Const aDataSet: tDataSet): TTSAbsQuery;
  Protected
    Function  fnDoContainsSQL (Const aDataSet: tDataSet): Boolean; override;
    Function  fnDoGetQuery    (Const DbConnection: tObject): tDataSet; override;
    //
    Procedure DoPrepare       (Const aDataSet: tDataSet); override;
    Procedure DoPrepare       (Const aDataSet: tDataSet; Const aSQL: String); override;
    Procedure AssignSQL       (Const aDataSet: tDataSet; Const aSQL: String); override;

  Public
    Constructor CreateWithDb  (Const aDb: tABSDatabase; Const aPrepareOnCreate: Boolean = False); virtual;
    //
    Function fnSetup          (Const aName: String; Const aSQL: String; Const aCacheOption: tCacheOption = coDefault): TTSAbsQuery; overload;
    Function fnSetup          (Const aName: String; Const aSQL: tStrings; Const aCacheOption: tCacheOption = coDefault): TTSAbsQuery; overload;
    //
    Function fnRunQuery       (Const aName: String; Const DisableCtrls: Boolean = True): TTSAbsQuery; overload;
    Function fnRunQuery       (Const aName: String; Const aParam: String; Const aValue: Variant; Const DisableCtrls: Boolean = True): TTSAbsQuery; overload;
    Function fnRunQuery       (Const aName: String; Const aParams: array of string; Const aValues: array of Variant; Const DisableCtrls: Boolean = True): TTSAbsQuery; overload;
    Function fnRunQuery2      (Const aName, aSQL: String; Const aParams: array of string; Const aValues: array of Variant; Const DisableCtrls: Boolean = True): TTSAbsQuery; overload;
    //
    Function fnExecQuery      (Const aName: String): Integer; overload;
    Function fnExecQuery      (Const aName: String; Const aParam: String; Const aValue: Variant): Integer; overload;
    Function fnExecQuery      (Const aName: String; Const aParams: array of string; Const aValues: array of Variant): Integer; overload;
    //
    Function fnIsDbAssigned: Boolean;
    Function fnDbConnection: tABSDatabase;

  End;

implementation

Uses MASCommonU, FormatResultU, MAS_HashsU;

{ TAbsSQLCache }

Constructor TAbsSQLCache.CreateWithDb (Const aDb: tABSDatabase; Const aPrepareOnCreate: Boolean);
begin
  inherited Create;
  Self.PrepareOnCreate := aPrepareOnCreate;
  Self.DbConnection    := aDb;
end;

Function TAbsSQLCache.fnDoContainsSQL (Const aDataSet: tDataSet): Boolean;
begin
  Inherited fnDoContainsSQL (aDataSet);
  fnRaiseOnFalse ((aDataSet is TTSAbsQuery), 'Error: fnContainsSQL. aDataSet must be of type TTSAbsQuery');
  Result := (TTSAbsQuery (aDataSet).SQL.Count > 0);
end;

Function TAbsSQLCache.fnDoGetQuery (Const DbConnection: tObject): tDataSet;
begin
  fnRaiseOnFalse ((DbConnection is tABSDataBase), 'Error: fnGetQuery. DbConnection must be of type TABSDataBase');
  Result := h_fnGetQuery (tABSDataBase (DbConnection));
end;

// Routine: fnCast
// Author: M.A.Sargent  Date: 22/10/18  Version: V1.0
//
// Notes:
//
Function TAbsSQLCache.fnCast (Const aDataSet: tDataSet): TTSAbsQuery;
begin
  fnRaiseOnFalse ((aDataSet is TTSAbsQuery), 'Error: fnCast. aDataSet must be of type TTSAbsQuery');
  Result := TTSAbsQuery (aDataSet);
end;

// Routine: DoPrepare
// Author: M.A.Sargent  Date: 19/10/18  Version: V1.0
//
// Notes:
//
Procedure TAbsSQLCache.DoPrepare (Const aDataSet: tDataSet);
begin
  inherited;
  fnRaiseOnFalse ((aDataSet is TTSAbsQuery), 'Error: Prepare. aDataSet must be of type TTSAbsQuery');
  if not IsEmpty (TTSAbsQuery (aDataSet).SQL.Text) then
    TTSAbsQuery (aDataSet).Prepare;
end;
Procedure TAbsSQLCache.DoPrepare (Const aDataSet: tDataSet; Const aSQL: String);
begin
  inherited;
  fnRaiseOnFalse ((aDataSet is TTSAbsQuery), 'Error: Prepare. aDataSet must be of type TTSAbsQuery');
  AssignSQL (aDataSet, aSQL);
  DoPrepare (aDataSet);
end;

// Routine: AssignSQL
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
Procedure TAbsSQLCache.AssignSQL (Const aDataSet: tDataSet; Const aSQL: String);
begin
  inherited;
  fnRaiseOnFalse ((aDataSet is TTSAbsQuery), 'Error: Prepare. aDataSet must be of type TTSAbsQuery');
  if not IsEmpty (aSQL) then TTSAbsQuery (aDataSet).SQL.Text := aSQL;
end;

// Routine: fnSetup
// Author: M.A.Sargent  Date: 19/10/18  Version: V1.0
//
// Notes:
//
Function TAbsSQLCache.fnSetup (Const aName: String; Const aSQL: String; Const aCacheOption: tCacheOption): TTSAbsQuery;
var
  lvCacheItem: tCacheItem;
begin
  lvCacheItem := Int_fnQry (aName, aSQL, caException, aCacheOption);
  Result := fnCast (lvCacheItem.Qry);
end;
Function TAbsSQLCache.fnSetup (Const aName: String; Const aSQL: tStrings; Const aCacheOption: tCacheOption = coDefault): TTSAbsQuery;
begin
  fnRaiseOnFalse (Assigned (aSQL), 'Error: fnSetup. aSQL String list must be assigned');
  Result := fnSetup (aName, aSQL.Text, aCacheOption);
end;

// Routine: fnRunQuery
// Author: M.A.Sargent  Date: 19/10/18  Version: V1.0
//
// Notes:
//
Function TAbsSQLCache.fnRunQuery (Const aName: String; Const DisableCtrls: Boolean): TTSAbsQuery;
begin
  Result := fnRunQuery (aName, [], [], DisableCtrls);
end;
Function TAbsSQLCache.fnRunQuery (Const aName: String; Const aParam: String; Const aValue: Variant; Const DisableCtrls: Boolean): TTSAbsQuery;
begin
  Result := fnRunQuery (aName, [aParam], [aValue], DisableCtrls);
end;
Function TAbsSQLCache.fnRunQuery (Const aName: String; Const aParams: array of string; Const aValues: array of Variant; Const DisableCtrls: Boolean): TTSAbsQuery;
begin
  Result := fnRunQuery2 (aName, '', aParams, aValues, DisableCtrls);
end;
Function TAbsSQLCache.fnRunQuery2 (Const aName, aSQL: String; Const aParams: array of string; Const aValues: array of Variant; Const DisableCtrls: Boolean): TTSAbsQuery;
begin
  Result := fnSetup (aName, aSQL);
  if not Result.Prepared then DoPrepare (Result); //Result.Prepare;
  Result.RunQuery (aParams, aValues, DisableCtrls);
end;

// Routine: fnExecQuery
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
Function TAbsSQLCache.fnExecQuery (Const aName: String): Integer;
begin
  Result := fnExecQuery (aName, [], []);
end;
Function TAbsSQLCache.fnExecQuery (Const aName: String; Const aParam: String; Const aValue: Variant): Integer;
begin
  Result := fnExecQuery (aName, [aParam], [aValue]);
end;
Function TAbsSQLCache.fnExecQuery (Const aName: String; Const aParams: array of string; Const aValues: array of Variant): Integer;
var
  lvQry: TTSAbsQuery;
begin
  lvQry := fnSetup (aName, '');
  lvQry.ClearParameters;
  lvQry.LoadParamByName (aParams, aValues, True);
  lvQry.ExecSQL;
  Result := lvQry.RowsAffected;
end;

// Routine: fnDbConnection
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
Function TAbsSQLCache.fnIsDbAssigned: Boolean;
var
  lvObj: tObject;
begin
  lvObj := DbConnection;
  if Assigned (lvObj) then
    fnRaiseOnFalse ((lvObj is tABSDatabase), 'Error: GetDbConnection. DbConnection must be of type TABSDatabase');
  Result := Assigned (lvObj);
end;

Function TAbsSQLCache.fnDbConnection: tABSDatabase;
var
  lvObj: tObject;
begin
  lvObj := DbConnection;
  fnRaiseOnFalse (Assigned (lvObj), 'Error: GetDbConnection. DbConnection must be assigned');
  fnRaiseOnFalse ((lvObj is tABSDatabase), 'Error: GetDbConnection. DbConnection must be of type TABSDatabase');
  Result := tABSDatabase (lvObj);
end;

end.

