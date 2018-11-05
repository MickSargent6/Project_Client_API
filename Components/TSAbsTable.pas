//
// Unit: TSAbsSQLQuery
// Author: M.A.Sargent  Date: 04/09/13  Version: V1.0
//
// Notes:
//

unit TSAbsTable;

interface

uses
  SysUtils, Classes, DB, ABSMain, ExtCtrls, TSAbsCommonU, MASMessagesU, TSUK_D7_ConstsU;

type
  tTSAbsTable = class(TABSTable)
  private
    { Private declarations }
    fTimer: tTimer;
    fOnDelayedAfterScroll: tDatasetDelayScroll;
    fOnDataSetEvent:       tOnDataSetEvent;
    fList:                 tStringList;
    //
    Procedure DoTimerEvent (Sender: TObject);
    Procedure Int_DoDataSetEvent (Const aDataSetEvent: tDataSetEvent);
  protected
    { Protected declarations }
    Procedure DoAfterScroll; override;
    Procedure DoAfterOpen;  override;
    Procedure DoAfterRefresh; override;
    Procedure DoAfterInsert;  override;
    Procedure DoAfterPost;  override;
    Procedure DoDataSetEvent (Const aDataSetEvent: tDataSetEvent); virtual;

  public
    { Public declarations }
    Constructor Create (aOwner: tComponent); override;
    Destructor Destroy; override;
    //
    Procedure UnRegisterDataSource (aHandle: tHandle);
    Procedure RegisterDataSource   (aHandle: tHandle);
    //
    Function  fnClone: tTSAbsTable;
    //
    Procedure ReOpen;
    Procedure ColumnsVisible (Const aTrue: Boolean);
    Procedure ColumnVisible  (Const aName: String; Const aTrue: Boolean); overload;
    Procedure ColumnVisible  (Const aName, aDisplayName: String; Const aWidth: Integer); overload;
  published
    { Published declarations }
    Property MASAfterScrollDelay: tDatasetDelayScroll read fOnDelayedAfterScroll write fOnDelayedAfterScroll;
    Property OnDataSetEvent:      tOnDataSetEvent     read fOnDataSetEvent       write fOnDataSetEvent;
  end;

  //
  Function h_fnGetTable (aConnection: tABSDataBaseName): tTSAbsTable; overload;
  Function h_fnGetTable (aConnection: tABSDataBase): tTSAbsTable; overload;
  Function h_fnGetTable (aConnection: tABSDataBaseName; Const aTableName: String; Const aOpen: Boolean): tTSAbsTable; overload;
  Function h_fnGetTable (aConnection: tABSDataBase; Const aTableName: String; Const aOpen: Boolean): tTSAbsTable; overload;
  Function h_fnGetTable (aConnection: tABSDataBaseName; Const aTableName, aIndexFieldName: String; Const aOpen: Boolean): tTSAbsTable; overload;
  Function h_fnGetTable (aConnection: tABSDataBase; Const aTableName, aIndexFieldName: String; Const aOpen: Boolean): tTSAbsTable; overload;
  Function h_fnGetTable (aTable: tTSAbsTable): tTSAbsTable; overload;

implementation

Uses TSDatasourceU;

Const
  cDELAYINTERVAL = 333;

// Routine: h_fnGetTable
// Author: M.A.Sargent  Date: 15/10/18  Version: V1.0
//
// Notes:
//
Function h_fnGetTable (aConnection: tABSDataBase): tTSAbsTable;
begin
  if not Assigned (aConnection) then Raise Exception.Create ('Error: h_fnGetTable. tABSDatabase must be Assigned');
  Result := h_fnGetTable (aConnection.DatabaseName);
end;
Function h_fnGetTable (aConnection: tABSDataBaseName): tTSAbsTable;
begin
  Result := tTSAbsTable.Create (Nil);
  Try
    Result.DatabaseName := aConnection;
  Except
    FreeAndNil (Result);
    Raise;
  end;
end;
Function h_fnGetTable (aConnection: tABSDataBase; Const aTableName: String; Const aOpen: Boolean): tTSAbsTable;
begin
  if not Assigned (aConnection) then Raise Exception.Create ('Error: h_fnGetTable. tABSDatabase must be Assigned');
  Result := h_fnGetTable (aConnection.DatabaseName, aTableName, '', aOpen);
end;
Function h_fnGetTable (aConnection: tABSDataBaseName; Const aTableName: String; Const aOpen: Boolean): tTSAbsTable;
begin
  Result := h_fnGetTable (aConnection, aTableName, '', aOpen);
end;
Function h_fnGetTable (aConnection: tABSDataBase; Const aTableName, aIndexFieldName: String; Const aOpen: Boolean): tTSAbsTable;
begin
  if not Assigned (aConnection) then Raise Exception.Create ('Error: h_fnGetTable. tABSDatabase must be Assigned');
  Result := h_fnGetTable (aConnection.DatabaseName, aTableName, aIndexFieldName, aOpen);
end;
Function h_fnGetTable (aConnection: tABSDataBaseName; Const aTableName, aIndexFieldName: String; Const aOpen: Boolean): tTSAbsTable;
begin
  Result  := h_fnGetTable (aConnection);
  Try
    Result.TableName       := aTableName;
    Result.IndexFieldNames := aIndexFieldName;
    if aOpen then Result.Open;
  Except
    FreeAndNil (Result);
    Raise;
  end;
end;

Function h_fnGetTable (aTable: tTSAbsTable): tTSAbsTable;
begin
  if not Assigned (aTable) then Raise Exception.Create ('Error: h_fnGetTable. A aTable Must be Assigned');
  Result := aTable.fnClone;
end;

// Routine: Create
// Author: M.A.Sargent  Date: 15/10/18  Version: V1.0
//
// Notes:
//
Constructor tTSAbsTable.Create (aOwner: tComponent);
begin
  inherited;
  fOnDelayedAfterScroll := Nil;
  fOnDataSetEvent       := Nil;
  {Create the delay timer}
  fTimer := TTimer.Create (Nil);
  fTimer.Enabled     := False;
  fTimer.Interval    := cDELAYINTERVAL;
  fTimer.OnTimer     := DoTimerEvent;  // Assign the ScrollDelay Event
  //
  fList := tStringList.Create;
end;

Destructor tTSAbsTable.Destroy;
begin
  fList.Free;
  if Assigned (fTimer) then fTimer.Free;
  inherited;
end;

// Notes: Event called on Timer Event, will call Event if assigned
procedure tTSAbsTable.DoTimerEvent (Sender: TObject);
begin
  fTimer.Enabled:= False;
  if Assigned (fOnDelayedAfterScroll) then begin
    fOnDelayedAfterScroll (Self);
  end;
  Int_DoDataSetEvent (deDelayedAfterScroll);
end;

procedure tTSAbsTable.DoAfterScroll;
begin
  inherited;
  if Assigned (fOnDelayedAfterScroll) then begin
    fTimer.Enabled:= False;
    fTimer.Enabled := True;
  end;
  Int_DoDataSetEvent (deAfterScroll);
end;

Procedure tTSAbsTable.DoAfterOpen;
begin
  inherited;
  Int_DoDataSetEvent (deAfterOpen);
end;
Procedure tTSAbsTable.Int_DoDataSetEvent (Const aDataSetEvent: tDataSetEvent);
begin
  DoDataSetEvent (aDataSetEvent);
end;

// Routine:
// Author: M.A.Sargent  Date: 02/10/18  Version: V1.0
//
// Notes:
//
Procedure tTSAbsTable.DoDataSetEvent (Const aDataSetEvent: tDataSetEvent);
var
  x:        Integer;
  lvHandle: tHandle;
begin
  if (csDestroying in ComponentState) then Exit;

  if Assigned (fOnDataSetEvent) then fOnDataSetEvent (Self, aDataSetEvent);
  //
  for x := 0 to fList.Count-1 do begin
    //
    lvHandle := StrToInt (fList[x]);
    AppPostMessage (lvHandle, um_ABSDatesetEvent, Integer (Self), Ord (aDataSetEvent));  end;
end;

Procedure tTSAbsTable.RegisterDataSource (aHandle: tHandle);
begin
  fList.Add (IntToStr (aHandle));
end;
Procedure tTSAbsTable.UnRegisterDataSource (aHandle: tHandle);
var
  x: Integer;
begin
  x := fList.IndexOf (IntToStr(aHandle));
  if (x <> -1) then fList.Delete (x);
end;

procedure tTSAbsTable.DoAfterRefresh;
begin
  inherited;
  Int_DoDataSetEvent (deAfterRefresh);
end;

Procedure tTSAbsTable.DoAfterInsert;
begin
  inherited;
  Int_DoDataSetEvent (deAfterInsert);
end;

Procedure tTSAbsTable.DoAfterPost;
begin
  inherited;
  Int_DoDataSetEvent (deAfterPost);
end;

Procedure tTSAbsTable.ColumnsVisible (Const aTrue: Boolean);
begin
  h_ColumnsVisible (Self, aTrue);
end;

Procedure tTSAbsTable.ColumnVisible (Const aName: String; Const aTrue: Boolean);
begin
  h_ColumnVisible (Self, aName, aTrue);
end;
Procedure tTSAbsTable.ColumnVisible (Const aName, aDisplayName: String; Const aWidth: Integer);
begin
  h_ColumnVisible (Self, aName, aDisplayName, aWidth);
end;

Procedure tTSAbsTable.ReOpen;
begin
  if Self.Active then Close;
  Self.Open;
end;

// Routine: fnClone
// Author: M.A.Sargent  Date: 02/10/18  Version: V1.0
//
// Notes:
//
Function tTSAbsTable.fnClone: tTSAbsTable;
begin
  Result := tTSAbsTable.Create (Nil);
  Try
    Result.DatabaseName    := DatabaseName;
    Result.SessionName     := SessionName;
    Result.InMemory        := InMemory;
    Result.TableName       := TableName;
    Result.ReadOnly        := ReadOnly;
    Result.IndexFieldNames := IndexFieldNames;
    Result.IndexName       := IndexName;
  except
    FreeAndNil (Result);
    Raise;
  end;
end;

end.
