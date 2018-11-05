//
// Unit: TSAbsSQLQuery
// Author: M.A.Sargent  Date: 04/09/13  Version: V1.0
//
// Notes:
//
unit TSAbsCommonU;

interface

Uses Db;

Type
  tDataSetEvent = (deNone, deAfterAssignment,
                    deAfterRefresh, deBeforeOpen, deAfterOpen, deAfterScroll, deDelayedAfterScroll, deAfterInsert,
                     deAfterPost);
  //
  tOnDataSetEvent     = Procedure (DataSet: tDataSet; Const aDataSetEvent: tDataSetEvent) of object;
  tDatasetDelayScroll = Procedure (DataSet: tDataSet) of object;

  tABSDataBaseName = String;

  //
  Procedure h_ColumnsVisible (Const aDataSet: TDataSet; Const aTrue: Boolean);
  Procedure h_ColumnVisible  (Const aDataSet: TDataSet; Const aName: String; Const aTrue: Boolean); overload;
  Procedure h_ColumnVisible  (Const aDataSet: TDataSet; Const aName, aDisplayName: String; Const aWidth: Integer); overload;

implementation

Procedure h_ColumnsVisible (Const aDataSet: TDataSet; Const aTrue: Boolean);
var
  x: Integer;
begin
  if not Assigned (aDataSet) then Exit;
  for x := 0 to aDataSet.Fields.Count-1 do
    aDataSet.Fields[x].Visible := aTrue;
end;
Procedure h_ColumnVisible (Const aDataSet: TDataSet; Const aName: String; Const aTrue: Boolean);
begin
  if not Assigned (aDataSet) then Exit;
  aDataSet.FieldByName (aName).Visible := aTrue;
end;

Procedure h_ColumnVisible (Const aDataSet: TDataSet; Const aName, aDisplayName: String; Const aWidth: Integer); overload;
var
  lvField: tField;
begin
  if not Assigned (aDataSet) then Exit;
  lvField := aDataSet.FieldByName (aName);
  lvField.Visible       := True;
  lvField.DisplayLabel  := aDisplayName;
  lvField.DisplayWidth  := aWidth;
end;

end.
