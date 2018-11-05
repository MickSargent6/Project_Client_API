//
// Unit: MAS_MySql_QueryCacheU
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
unit MAS_MySql_QueryCacheU;

interface

uses Classes, SysUtils, MASStringListU, MASRecordStructuresU, mySQLDbTables, MASmySQLQuery;

Type
  tLastCacheItem = record
    Name: String;
    Qry:  tMASmySQLQuery;
  end;
  tCacheItem = record
    SQLExists: Boolean;
    Qry:       tMASmySQLQuery;
  end;

  tSQLCache = Class (tObject)
  Private
    fCache:         tMASStringList;
    fDbConnection:  tMySQLDatabase;
    fLastCacheItem: tLastCacheItem;
  Protected
    Procedure SetCacheItem (Const aName: string; Const aQry: tMASmySQLQuery);
    Function  fnCacheItem  (Const aName: string; var aQry: tMASmySQLQuery): Boolean;
    //
    Property DbConnection: tMySQLDatabase read fDbConnection write fDbConnection;

  Public
    Constructor Create (aDbConnection: tMySQLDatabase); virtual;
    Destructor  Destroy; override;
    Procedure   Clear;
    //
    Function fnQryExists (Const aName: String): Boolean;
    //
    Function fnQry       (Const aName: String): tCacheItem; overload;
    Function fnQry       (Const aName: String; const aSQL: String): tMASmySQLQuery; overload;
    Function fnQry       (Const aName: String; const aSQL: tStrings): tMASmySQLQuery; overload;
    //
    Function fnRunQuery  (Const aName: String; Const aParams: array of string; Const aValues: array of Variant; Const DisableCtrls: Boolean = True): tMASmySQLQuery;
    Function fnExecQuery (Const aName: String; Const aParams: array of string; Const aValues: array of Variant): Integer;
  end;

//TmySQLDirectQuery
//tMASmySQLQuery

implementation

Uses MASCommonU, FormatResultU;

{ tSQLCache }

// Routine: Create
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
Constructor tSQLCache.Create (aDbConnection: tMySQLDatabase);
begin
  fDbConnection := aDbConnection;
  fCache        := tMASStringList.CreateSorted;
  fCache.FreeObjects := True;
  //
  fLastCacheItem.Name := '';
  fLastCacheItem.Qry  := Nil;
end;

// Routine: Destroy
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
Destructor tSQLCache.Destroy;
begin
  fCache.Clear;
  fCache.Free;
  inherited;
end;

Procedure tSQLCache.Clear;
begin
  fLastCacheItem.Name := '';
  fLastCacheItem.Qry  := Nil;
  fCache.Clear;
end;

// Routine: SetCacheItem & fnCacheItem
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
Procedure tSQLCache.SetCacheItem (Const aName: string; Const aQry: tMASmySQLQuery);
begin
  fLastCacheItem.Name := aName;
  fLastCacheItem.Qry  := aQry;
end;
Function tSQLCache.fnCacheItem (Const aName: string; var aQry: tMASmySQLQuery): Boolean;
begin
  aQry := Nil;
  Result := IsEqual (fLastCacheItem.Name, aName);
  if Result then aQry := fLastCacheItem.Qry;
end;

// Routine: fnQry
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
Function tSQLCache.fnQry (Const aName: String): tCacheItem;
var
  lvIdx: Integer;
begin
  if fnCacheItem (aName, Result.Qry) then begin
    Result.SQLExists := (Result.Qry.SQL.Count > 0);
    Exit;
  end;
  //
  Case fCache.Find (aName, lvIdx) of
    True: Result.Qry := tMASmySQLQuery (fCache.Objects [lvIdx]);
    else begin
          Result.Qry := h_fnGetQuery   (fDbConnection);
          fCache.AddObject (aName, Result.Qry);
    end;
  end;
  //
  Result.SQLExists := (Result.Qry.SQL.Count > 0);
  // Only add to Cache is SQL Exists
  if Result.SQLExists then SetCacheItem  (aName, Result.Qry);
end;
Function tSQLCache.fnQry (Const aName, aSQL: String): tMASmySQLQuery;
var
  lvIdx: Integer;
begin
  Result := fnQry (aName).Qry;
  Result.SQL.Text := aSQL;
  Result.Prepare;
  //
{  if fCache.Find (aName, lvIdx) then fCache.Objects [lvIdx] := Result
  else Raise Exception.Create ('Error: fnQry. Should Not Happen');  }
end;
Function tSQLCache.fnQry (Const aName: String; Const aSQL: tStrings): tMASmySQLQuery;
var
  lvIdx: Integer;
begin
  fnRaiseOnFalse (Assigned (aSQL), 'Error: fnQry. aSQL List must be Assigned');
  Result := fnQry (aName).Qry;
  Result.SQL.Assign (aSQL);
  Result.Prepare;
  //
 { if fCache.Find (aName, lvIdx) then fCache.Objects  [lvIdx] := Result
  else Raise Exception.Create ('Error: fnQry. Should Not Happen');}
end;

// Routine: fnRunQuery
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
Function tSQLCache.fnRunQuery (Const aName: String; Const aParams: array of string; Const aValues: array of Variant; Const DisableCtrls: Boolean): tMASmySQLQuery;
begin
  Result := fnQry (aName).Qry;
  if not Result.Prepared then Result.Prepare;
  Result.RunQuery (aParams, aValues, DisableCtrls);
end;

// Routine: fnExecQuery
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
Function tSQLCache.fnExecQuery (Const aName: String; Const aParams: array of string; Const aValues: array of Variant): Integer;
var
  lvQry: tMASmySQLQuery;
begin
  lvQry := fnQry (aName).Qry;
  if not lvQry.Prepared then lvQry.Prepare;
  lvQry.ClearParameters;
  lvQry.LoadParamByName (aParams, aValues, True);
  lvQry.ExecSQL;
  Result := lvQry.RowsAffected;
end;

// Routine: fnQryExists
// Author: M.A.Sargent  Date: 14/06/18  Version: V1.0
//
// Notes:
//
Function tSQLCache.fnQryExists (Const aName: String): Boolean;
begin
  Result := fCache.Exists (aName);
end;

end.
