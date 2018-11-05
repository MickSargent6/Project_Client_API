//
// Unit: TSDatasourceU
// Author: M.A.Sargent  Date: 01/10/2018  Version: V1.0
//
unit TSDatasourceU;

interface

uses
  SysUtils, Classes, DB, ABSMain, TSAbsSQLQuery, TSAbsCommonU, TSAbsTable, StdCtrls, Messages, TSUK_D7_ConstsU,
  Windows, Dialogs, MASRecordStructuresU;

type
  tTSDatasource = class(TDataSource)
  private
    { Private declarations }
    fDataSet:        tABSDataset;
    fOnDataSetEvent: tOnDataSetEvent;
    fHandle:         HWND;
    //
    Function  GetSetTSDataSet: tABSDataset;
    Procedure SetTSDataSet (Const Value: TABSDataset);
    Procedure Int_UnRegisterDataSource;
  Protected
    { Protected declarations }
    Procedure WndMethod (var Message: TMessage);
    Procedure DoDataSetEvent (DataSet: tDataSet; Const aDataSetEvent: tDataSetEvent);

  public
    { Public declarations }
    Constructor Create (aOwner: TComponent); override;
    Destructor Destroy; override;
    //
    Function FieldAsString  (Const aName: String; Const aRaiseNotFound: Boolean = True): String;
    Function FieldAsString2 (Const aName: String): tOKStrRec;

  published
    { Published declarations }
    Property TSDataSet:      tABSDataset     read GetSetTSDataSet write SetTSDataSet;
    Property OnDataSetEvent: tOnDataSetEvent read fOnDataSetEvent write fOnDataSetEvent;
  end;

implementation

USes FormatResultU;

{ tTSDatasource }

Constructor tTSDatasource.Create(aOwner: TComponent);
begin
  inherited;
  fOnDataSetEvent := Nil;
  //
  fHandle := AllocateHWnd(WndMethod);
end;

Destructor tTSDatasource.Destroy;
begin
  Int_UnRegisterDataSource;
  DeAllocateHWnd (fHandle);
  inherited;
end;

Function tTSDatasource.GetSetTSDataSet: TABSDataset;
begin
  Result := fDataSet;
end;

Procedure tTSDatasource.SetTSDataSet (Const Value: TABSDataset);
begin
  Int_UnRegisterDataSource;
  //
  fDataSet     := Value;
  Self.DataSet := Value;
  //
  if (Value <> Nil) then begin
    if      Value is tTSAbsQuery then tTSAbsQuery (fDataSet).RegisterDataSource (fHandle)
    else if Value is tTSAbsTable then tTSAbsTable (fDataSet).RegisterDataSource (fHandle);
    // a bit of a fudge, but as the DataSet would have been created and probably opened before
    // assigning it to a DataSource the Open and SCroll events would already have been fired
    // so here just call AfterAssignment if the data is opened
    DoDataSetEvent (fDataSet, deAfterAssignment);
  end;
end;

Procedure tTSDatasource.DoDataSetEvent (DataSet: tDataSet; Const aDataSetEvent: tDataSetEvent);
begin
  if Assigned (fOnDataSetEvent) then fOnDataSetEvent (DataSet, aDataSetEvent);
end;

// Routine:
// Author: M.A.Sargent  Date: 05/10/18  Version: V1.0
//
// Notes:
//
Procedure tTSDatasource.WndMethod (var Message: TMessage);
var
  lvObj:   tObject;
  lvEvent: tDataSetEvent;
begin
  // Handle the pipe messages
  Case Message.Msg of
    um_ABSDatesetEvent: begin
      lvObj   := tObject (Message.wParam);
      lvEvent := tDataSetEvent (Message.lParam);
      if (lvObj is TABSDataset) then DoDataSetEvent (tABSDataset (lvObj), lvEvent);
    end;
    // Call default window procedure
    else DefWindowProc (fHandle, Message.Msg, Message.wParam, Message.lParam);
  end;
end;

// Routine:
// Author: M.A.Sargent  Date: 05/10/18  Version: V1.0
//
// Notes:
//
Function tTSDatasource.FieldAsString (Const aName: String; Const aRaiseNotFound: Boolean): String;
var
  lvRes: tOKStrRec;
begin
  Result := '';
  lvRes := FieldAsString2 (aName);
  Case lvRes.OK of
    True: Result := lvRes.Msg;
    else if aRaiseNotFound then RaiseNow ('Error: FieldAsString. Field (%s) NOt Found', [aName]);
  end;
end;
Function tTSDatasource.FieldAsString2 (Const aName: String): tOKStrRec;
var
  lvField: TField;
begin
  Result := fnClear_OKStrRec (False);
  if Assigned (Self.DataSet) then begin
    lvField := Self.DataSet.FindField (aName);
    if Assigned (lvField) then Result := fnResultOK (lvField.AsString);
  end;
end;

// Routine: Int_UnRegisterDataSource
// Author: M.A.Sargent  Date: 07/10/18  Version: V1.0
//
// Notes:
//
Procedure tTSDatasource.Int_UnRegisterDataSource;
begin
  if (fDataSet <> Nil) then begin
    if      fDataSet is tTSAbsQuery then tTSAbsQuery (fDataSet).UnRegisterDataSource (fHandle)
    else if fDataSet is tTSAbsTable then tTSAbsTable (fDataSet).UnRegisterDataSource (fHandle);
  end;
end;


end.



