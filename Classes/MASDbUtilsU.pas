//
// Unit: MASDbUtilsU
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//         M.A.Sargent        01/12/11           V2.0
//         M.A.Sargent        14/11/12           V3.0
//         M.A.Sargent        19/09/13           V4.0
//         M.A.Sargent        02/05/14           V5.0
//         M.A.Sargent        12/10/15           V6.0
//
// Notes:
//  V3.0: Added a Function fnDoesExist, not yet tested
//  V4.0:
//  V5.0: Added ListParamsAsStrings
//  V6.0: Add another version of ListParamsAsStrings2
//
unit MASDbUtilsU;

interface

Uses Db, {MASDBTreeViewConstsU,} Variants, SysUtils, MASStringListU, Controls, Classes, {MemDS,}
      Forms, MASDBUtilsCommonU, MASDatesU, MASmySQLQuery, MASmySQLStoredProc;

  //
  Function fnAssignDataValue (Const aDataType: tFieldType; Const aValue: String): Variant;
  //
  Function ListParamsAsStrings (aDataSet: tDataSet): tStrings;
  Procedure ListParamsAsStrings2 (aDataSet: tDataSet);

  Procedure h_SetDBFilter (Const aDataSet: tDataSet; Const aFilter: String);
  Procedure h_ClearDbFilter (Const aDataSet: tDataSet);

  Function h_ReRun (Const aDataSet: tDataSet; Const aDisableControl: Boolean = True): Boolean;

implementation

Uses MASCommonU, MAS_DirectoryU, FormatResultU;

// Routine: fnGetExeName
// Author: M.A.Sargent  Date: 01/11/06  Version: V1.0
//
// Notes:
//
function fnAssignDataValue (Const aDataType: tFieldType; Const aValue: String): Variant;
begin
  Result := MASDBUtilsCommonU.fnAssignDataValue (aDataType, aValue);
end;

// Routine: ListParamsAsStrings
// Author: M.A.Sargent  Date: 02/05/14  Version: V1.0
//         M.A.Sargent        12/10/14           V2.0
//
// Notes:
//  V2.0: Updated to output the names of calling routines
//
Function ListParamsAsStrings (aDataSet: tDataSet): tStrings;
var
  x: Integer;
  lvStr: String;
begin
  Result := tMASStringList.Create;
  Try
    if Assigned (aDataSet) then begin
      if aDataSet is tMASmySQLQuery then begin
        tMASStringList(Result).CopyToList (tMASmySQLQuery (aDataSet).SQL);
        for x := 0 to tMASmySQLQuery (aDataSet).ParamCount-1 do
          tMASStringList(Result).AddMsg ('  P%d: %s - %s', [(x+1), tMASmySQLQuery (aDataSet).Params[x].Name, tMASmySQLQuery (aDataSet).Params[x].AsString]);
      end
      else if aDataSet is tMASmySQLStoredProc then begin
        lvStr := tMASmySQLStoredProc (aDataSet).ProcedureName;
        tMASStringList(Result).AddMsg ('SP Name: %s', [lvStr]);
        for x := 0 to tMASmySQLStoredProc (aDataSet).ParamsCount-1 do
          tMASStringList(Result).AddMsg ('  P%d: %s - %s', [(x+1), tMASmySQLStoredProc (aDataSet).Params[x].Name, tMASmySQLStoredProc (aDataSet).Params[x].AsString]);
      end;
    end;
  except
    FreeAndNil (Result);
    Raise;
  end;
end;

Procedure ListParamsAsStrings2 (aDataSet: tDataSet);
var
  lvList: tStrings;
  lvFileName: String;
begin
  lvList := ListParamsAsStrings (aDataSet);
  Try
    lvFileName := fnGenFileName ('Output\LogFiles\DBErrors', 'Sp_Error.Txt', fntDateTime);
    fnRaiseOnFalse (fnCheckDirectory (lvFileName), 'Error: ListParamsAsStrings2. Unable to Create Dir (%s)', [ExtractFileDir (lvFileName)]);
    lvList.SaveToFile (lvFileName);
  Finally
    if Assigned (lvList) then lvList.Free;
  end;
end;

// Routine: h_SetDBFilter & h_ClearDbFilter
// Author: M.A.Sargent  Date: 23/02/16  Version: V1.0
//
// Notes:
//
Procedure h_SetDBFilter (Const aDataSet: tDataSet; Const aFilter: String);
begin
  if not Assigned (aDataSet) then Exit;
  aDataSet.Filter   := aFilter;
  aDataSet.Filtered := (aDataSet.Filter <> '');
end;

Procedure h_ClearDbFilter (Const aDataSet: tDataSet);
begin
  if not Assigned (aDataSet) then Exit;
  aDataSet.Filtered := False;
  aDataSet.Filter   := '';
end;

// Routine: h_ReRun
// Author: M.A.Sargent  Date: 23/02/16  Version: V1.0
//
// Notes:
//
Function h_ReRun (Const aDataSet: tDataSet; Const aDisableControl: Boolean = True): Boolean;
begin
  Result := Assigned (aDataSet);
  fnRaiseOnFalse (Result, 'Error: h_ReRun. A Dataset Must be Assigned');
  //
  if aDisableControl then aDataSet.DisableControls;
  Try
    if aDataSet.Active then aDataSet.Close;
    aDataSet.Open;
    Result := not aDataSet.IsEmpty;
  Finally
    if aDisableControl then aDataSet.EnableControls;
  end;
end;

end.
