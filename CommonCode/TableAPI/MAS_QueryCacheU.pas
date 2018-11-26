//
// Unit: MAS_QueryCacheU
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
unit MAS_QueryCacheU;

interface

uses Classes, SysUtils, MASStringListU, MASRecordStructuresU, Db;
Type
  tSQLEvent = Procedure (Const aName: String; var aSQL: String) of Object;
  //
  tCacheOption = (coDefault, coNoFree,   coFreeOnClose);   //, coUnique, coUniqueFreeClose);
  tCacheAction = (caIgnore,  caOverrite, caException);


  tLastCacheItem = record
    Name: String;
    Qry:  tDataSet;
  end;
  tCacheItem = record
    SQLExists: Boolean;
    Qry:       tDataSet;
  end;

  tSQLCache = Class (tObject)
  Private
    fSQLCache:        tMASStringList;     //
    fCache:           tMASStringList;     //
    fDbConnection:    tObject;            //
    fLastCacheItem:   tLastCacheItem;     //
    fMaxCacheSize:    Integer;            //
    fOnSQLEvent:      tSQLEvent;          //
    fPrepareOnCreate: Boolean;            //
    //
    Procedure SetCacheItem       (Const aName: string; Const aQry: tDataSet);
    Function  fnCacheItem        (Const aName: string; var aQry: tDataSet): Boolean;
    Procedure ClearCacheItem;
    //
    Procedure SetMaxCacheSize    (Const Value: Integer);
    // for future use Function  fnIntToCacheOption (Const aInt: Integer): tCacheOption;
  Protected
    Function  Int_fnSQLIsCached  (Const aName: String): Boolean;
    Function  Int_fnSQLToCache   (Const aName: String; aSQL: String; Const aCacheAction: tCacheAction = caIgnore): String;
    //
    Function  fnDoGetSQL         (Const aName: String;var aSQL: String): Boolean; virtual;
    //
    Function  fnDoGetQuery       (Const DbConnection: tObject): tDataSet; virtual;
    Function  fnDoContainsSQL    (Const aDataSet: tDataSet): Boolean; virtual;
    Procedure AssignSQL          (Const aDataSet: tDataSet; Const aSQL: String); virtual;
    Procedure DoPrepare          (Const aDataSet: tDataSet); overload; virtual;
    Procedure DoPrepare          (Const aDataSet: tDataSet; Const aSQL: String); overload; virtual;
    //
    Function fnDbConnection: tObject;

    //
    Function  Int_fnQry          (Const aName, aSQL: String; Const aCacheAction: tCacheAction; Const aCacheOption: tCacheOption): tCacheItem;

    //
    Property DbConnection: tObject    read fDbConnection    write fDbConnection;
    Property PrepareOnCreate: Boolean read fPrepareOnCreate write fPrepareOnCreate default False;

  Public
    Constructor Create; virtual;
    Destructor  Destroy; override;
    Procedure   Clear;
    //
    Function    fnRelease (Const aName: String; Const aRelaseSQLCache: Boolean = False): Boolean;
    //
    Function    fnQryExists (Const aName: String): Boolean;
    //
    Property MaxCacheSize: Integer    read fMaxCacheSize   write SetMaxCacheSize;
    Property OnSQLEvent:   tSQLEvent  read fOnSQLEvent     write fOnSQLEvent;
  end;

  // Helpers

implementation

Uses MASCommonU, FormatResultU, MAS_HashsU;

{ tSQLCache }

// Routine: Create
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
Constructor tSQLCache.Create;
begin
  fOnSQLEvent           := Nil;
  fPrepareOnCreate      := False;
  //
  fSQLCache             := tMASStringList.CreateSorted;
  fSQLCache.FreeObjects := True;
  fCache                := tMASStringList.CreateSorted;
  fCache.FreeObjects    := True;
  //
  Clear;
end;

// Routine: Destroy
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
Destructor tSQLCache.Destroy;
begin
  fSQLCache.Clear;
  fSQLCache.Free;
  fCache.Clear;
  fCache.Free;
  inherited;
end;

Procedure tSQLCache.Clear;
begin
  ClearCacheItem;
  fCache.Clear;
  fSQLCache.Clear;
end;

// Routine: Int_fnSQLIsCached & Int_fnSQLToCache
// Author: M.A.Sargent  Date: 19/10/18  Version: V1.0
//
// Notes:
//
Function tSQLCache.Int_fnSQLIsCached (Const aName: String): Boolean;
begin
  Result := fSQLCache.Exists (aName);
end;
Function tSQLCache.Int_fnSQLToCache (Const aName: String; aSQL: String; Const aCacheAction: tCacheAction): String;
var
  lvObj:  tObject;
  lvList: tStringList;
begin
  //
  if IsEmpty (aSQL) then begin
    fnDoGetSQL (aName, aSQL);
  end;
  //fnRaiseOnFalse (not IsEmpty (aSQL), 'Error: Int_fnSQLToCache. SQL Text is Empty for Query (%s)', [aName]);
  //
  lvObj := fSQLCache.fnObject (aName);
  Case Assigned (lvObj) of
    True: begin
            Case aCacheAction of // tCacheAction = (caIgnore, caOverrite, caException);
              caIgnore:;  {Do Nothing}
              caOverrite: tStringList(lvObj).Text := aSQL;
              else begin
                if (tStringList(lvObj).Text <> '') then
                  if (aSQL <> '') then
                    if not fnMD5_CompareStr (tStringList(lvObj).Text, aSQL)  then
                      Raise Exception.CreateFmt ('Error: Int_SQLToCache. SQL Already Exists for Name (%s)', [aName]);
              end;
            end;
            //
            aSQL := tStringList(lvObj).Text;
    end;
    else begin
      lvList := tStringList.Create;
      Try
        lvList.Text := aSQL;
        fSQLCache.AddObject (aName, lvList);
      Except
        lvList.Free;
        Raise;
      End;
    end;
  End;
  Result := aSQL;
end;

// Routine: SetCacheItem & fnCacheItem &ClearCachItem
// Author: M.A.Sargent  Date: 13/06/18  Version: V10
//
// Notes:
//
Procedure tSQLCache.ClearCacheItem;
begin
  SetCacheItem ('', nil);
end;
Procedure tSQLCache.SetCacheItem (Const aName: string; Const aQry: tDataSet);
begin
  fLastCacheItem.Name := aName;
  fLastCacheItem.Qry  := aQry;
end;
Function tSQLCache.fnCacheItem (Const aName: string; var aQry: tDataSet): Boolean;
begin
  aQry := Nil;
  Result := Assigned (fLastCacheItem.Qry);
  if not Result then Exit;
  //
  Result := IsEqual (fLastCacheItem.Name, aName);
  if Result then aQry := fLastCacheItem.Qry;
end;

// Routine: Int_fnQry
// Author: M.A.Sargent  Date: 13/06/18  Version: V1.0
//
// Notes:
//
{Function tSQLCache.Int_fnQry (Const aName, aSQL: String; Const aCacheAction: tCacheAction): tCacheItem;
begin
  Result := Int_fnQry (aName, aSQL, aCacheAction, );
end;}

Function tSQLCache.Int_fnQry (Const aName, aSQL: String; Const aCacheAction: tCacheAction; Const aCacheOption: tCacheOption): tCacheItem;
var
  lvIdx: Integer;
begin

  Result.SQLExists := False;
  Result.Qry       := Nil;

  if fnCacheItem (aName, Result.Qry) then begin
    Result.SQLExists := fnDoContainsSQL (Result.Qry);
    fnRaiseOnFalse (Result.SQLExists, 'Error: %s', [aName]);
    Exit;
  end;
  //
  Case fCache.Find (aName, lvIdx) of
    True: begin
          //if (lvIdx > 0) then fCache.Move (lvIdx, 0);
          //Result.Qry := tDataSet (fCache.Objects [0]);
          Result.Qry := tDataSet (fCache.Objects [lvIdx]);
    end;
    else begin
          Result.Qry := fnDoGetQuery (fDbConnection);
          Try
            Result.Qry.Tag := Ord (aCacheOption);
            AssignSQL (Result.Qry, Int_fnSQLToCache (aName, aSQL, aCacheAction));
            if fPrepareOnCreate then DoPrepare (Result.Qry);
            fCache.AddObject (aName, Result.Qry);
          Except
            Result.Qry.Free;
            Raise;
          End;
    end;
  end;
  //
  Result.SQLExists := fnDoContainsSQL (Result.Qry);
  // Only add to Cache is SQL Exists
  if Result.SQLExists then SetCacheItem (aName, Result.Qry);
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

// Routine: fnDoGetSQL
// Author: M.A.Sargent  Date: 19/10/18  Version: V1.0
//
// Notes:
//
Function tSQLCache.fnDoGetSQL (Const aName: String; var aSQL: String): Boolean;
begin
  Result := False;
  if Assigned (fOnSQLEvent) then fOnSQLEvent (aName, aSQL);
end;

Function tSQLCache.fnDoContainsSQL (Const aDataSet: tDataSet): Boolean;
begin
  fnRaiseOnFalse (Assigned (aDataSet), 'Error: fnContainsSQL. A DataSet must be Assigned');
  Result := False;
end;

Function tSQLCache.fnDoGetQuery (Const DbConnection: tObject): tDataSet;
begin
  fnRaiseOnFalse (Assigned (DbConnection), 'Error: fnGetQuery. A DbConnection must be Assigned');
  Result := Nil;
end;

// Routine: fnDoGetSQL
// Author: M.A.Sargent  Date: 19/10/18  Version: V1.0
//
// Notes:
//
Procedure tSQLCache.DoPrepare (Const aDataSet: tDataSet);
begin
  fnRaiseOnFalse (Assigned (aDataSet), 'Error: fnContainsSQL. A DataSet must be Assigned');
end;
Procedure tSQLCache.DoPrepare (Const aDataSet: tDataSet; const aSQL: String);
begin
  fnRaiseOnFalse (Assigned (aDataSet), 'Error: fnContainsSQL. A DataSet must be Assigned');
end;

Procedure tSQLCache.SetMaxCacheSize (Const Value: Integer);
begin
  fMaxCacheSize := Value;
end;

// Routine: fnRelease
// Author: M.A.Sargent  Date: 21/10/18  Version: V1.0
//
// Notes:
//
Function tSQLCache.fnRelease (Const aName: String; Const aRelaseSQLCache: Boolean): Boolean;
begin
  Result := fCache.DeleteByName (aName);
  if IsEqual (fLastCacheItem.Name, aName) then ClearCacheItem;
  // Remove the Cached SQL if True
  if aRelaseSQLCache then fSQLCache.DeleteByName (aName);
end;

// Routine: fnIntToCacheOption
// Author: M.A.Sargent  Date: 21/10/18  Version: V1.0
//
// Notes: Future use
//
{Function tSQLCache.fnIntToCacheOption (Const aInt: Integer): tCacheOption;
begin
  Case aInt of
    0:   Result := coDefault;
    1:   Result := coNoFree;
    else Result := coFreeOnClose;
    //3:   Result := coUnique;
    //else Result := coUniqueFreeClose;
  end;
end;}

Function tSQLCache.fnDbConnection: tObject;
begin
  Result := Self.fDbConnection;
end;

Procedure tSQLCache.AssignSQL (Const aDataSet: tDataSet; Const aSQL: String);
begin
  fnRaiseOnFalse (Assigned (aDataSet), 'Error: fnContainsSQL. A DataSet must be Assigned');
end;

end.

