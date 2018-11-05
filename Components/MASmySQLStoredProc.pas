//
// Unit: MASmySQLStoredProc
// Author: M.A.Sargent  Date: 04/09/13  Version: V1.0
//         M.A.Sargent        10/09/13           V2.0
//         M.A.Sargent        04/11/13           V3.0
//         M.A.Sargent        13/12/13           V4.0
//         M.A.Sargent        12/03/14           V5.0
//         M.A.Sargent        15/07/14           V6.0
//
// Notes:
//  V2.0: Updated to allow result or exception to be raised in h_fnGetStoredProc2
//  V3.0: Updated helpers FreeAndNil and not Free
//  V4.0: Still a problem use Free and then set to Nil
//  V5.0; Added helper version h_fnGetStoredProc_Result
//  V6.0: Add Function ParamExists
//
unit MASmySQLStoredProc;

interface

uses
  SysUtils, Classes, DB, mySQLDbTables, Variants, MASRecordStructuresU, FormatResultU;

type
  tMASmySQLStoredProc = class(TmySQLStoredProc)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
   { Public declarations }
    Procedure SetUp (aDatabase: TmySQLDatabase; Const aSPName: String); overload;
    Procedure SetUp (Const aSPName: String); overload;
    //
    Procedure ClearParameters;
    Function fnParamExists (Const aName: String): Boolean;
    procedure LoadParamByName (Const aParams: array of string; Const aValues: array of Variant; Const aMustExist: Boolean);
    Function ExecProc (aDatabase: TmySQLDatabase; Const aSPName: String;
                        Const aParams: array of string; Const aValues: array of Variant): Boolean; overload;
    Function ExecProc (Const aParams: array of string; Const aValues: array of Variant): Boolean; overload;

    Function fnSQLWrapper: String;
  published
    { Published declarations }
  end;

  // Helper Functions
  Function h_fnGetStoredProc (aDatabase: TmySQLDatabase; Const aName: String): tMASmySQLStoredProc; overload;
  Function h_fnGetStoredProc (aDatabase: TmySQLDatabase; Const aName: String;
                               Const aParams: array of string; Const aValues: array of Variant): tMASmySQLStoredProc; overload;
  Function h_fnGetStoredProc2 (aDatabase: TmySQLDatabase; Const aName: String;
                                Const aParams: array of string; Const aValues: array of Variant; Const RaiseException: Boolean = False): tOKStrRec; overload;
  Function h_fnGetStoredProc_Result (aDatabase: TmySQLDatabase; Const aName: String;
                                      Const aParams: array of string; Const aValues: array of Variant; Const RaiseException: Boolean): tOKStrRec;


implementation

Uses MASCommonU, MASDBUtilsCommonU;

// Routine: h_fnGetStoredProc
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//
// Notes:
//
Function h_fnGetStoredProc (aDatabase: TmySQLDatabase; Const aName: String): tMASmySQLStoredProc;
begin
  Result := tMASmySQLStoredProc.Create (Nil);
  Try
    Result.SetUp (aDatabase, aName);
  Except
    FreeAndNil(Result);
    Raise;
  end;
end;

Function h_fnGetStoredProc (aDatabase: TmySQLDatabase; Const aName: String;
                             Const aParams: array of string; Const aValues: array of Variant): tMASmySQLStoredProc;
begin
  Result := h_fnGetStoredProc (aDatabase, aName);
  Try
    if Assigned (Result) then
      Result.ExecProc (aParams, aValues);
  Except
    FreeAndNil(Result);
    Raise;
  end;
end;

// Routine: h_fnGetStoredProc2
// Author: M.A.Sargent  Date: 10/09/13  Version: V1.0
//
// Notes:
//
Function h_fnGetStoredProc2 (aDatabase: TmySQLDatabase; Const aName: String;
                              Const aParams: array of string; Const aValues: array of Variant; Const RaiseException: Boolean): tOKStrRec;
begin
  Result := h_fnGetStoredProc_Result (aDatabase, aName, aParams, aValues, RaiseException);
  if Result.OK then Result.Msg := '';
end;

// Routine: h_fnGetStoredProc_Result
// Author: M.A.Sargent  Date: 12/03/14  Version: V1.0
//
// Notes:
//
Function h_fnGetStoredProc_Result (aDatabase: TmySQLDatabase; Const aName: String;
                                    Const aParams: array of string; Const aValues: array of Variant; Const RaiseException: Boolean): tOKStrRec;
var
  lvProc: tMASmySQLStoredProc;
  lvParam: tParam;
begin
  lvProc := Nil;
  Result.OK := True;
  Try
    Try
      lvProc := h_fnGetStoredProc (aDatabase, aName, aParams, aValues);
      // see if a parameter called RESULT or O_RESULT exists i
      if Assigned (lvProc.Params) then begin
        lvParam := lvProc.Params.FindParam ('RESULT');
        if not Assigned (lvParam) then lvParam := lvProc.Params.FindParam ('O_RESULT');
        //
        if Assigned (lvParam) then Result.Msg := lvParam.AsString;
      end;
    Except
      on e:Exception do begin
        Case RaiseException of
          True: Raise;
          else  Result := fnResult ('Error: h_fnGetStoredProc2-%s, %s', [aName, e.Message]);
        end;
      end;
    end;
  Finally
    if Assigned (lvProc) then FreeAndNil (lvProc);
  end;
end;


{ tMASmySQLStoredProc }

Procedure tMASmySQLStoredProc.ClearParameters;
var
  x : Integer;
begin
  for x := 0 to ParamsCount-1 do
    if Params[x].Datatype <> ftCursor then
      Params[x].Clear;
end;

// Routine:
// Author: M.A.Sargent  Date: 10/03/13  Version: V1.0
//
// Notes:
//
Function tMASmySQLStoredProc.ExecProc (aDatabase: TmySQLDatabase; Const aSPName: String;
                                        Const aParams: array of string; Const aValues: array of Variant): Boolean;
begin
  SetUp (aDatabase, aSPName);
  Result := ExecProc (aParams, aValues);
end;
Function tMASmySQLStoredProc.ExecProc (Const aParams: array of string; Const aValues: array of Variant): Boolean;
begin
  Result := True;
  ClearParameters;
  LoadParamByName (aParams, aValues, True);
  ExecProc;
end;

// Routine:
// Author: M.A.Sargent  Date: 10/03/13  Version: V1.0
//
// Notes:
//
Procedure tMASmySQLStoredProc.LoadParamByName (Const aParams: array of string; const aValues: array of Variant;
                                                Const aMustExist: Boolean);
var
  x: Integer;
  lvParam: tParam;
begin
  lvParam := Nil;
  if High(aParams) <> High (aValues) then
    //Raise eMagDOAException.Create ('The Number of Params and Values Should be the Same');
  // If not Prepared then Prepare so that values assigned in this routine are
  // not overwritten/cleared by a prepare

//MAS if not Prepared then Prepare;

  ClearParameters;
  for x := 0 to High (aParams) do begin
    //
    Case aMustExist of
      True:  lvParam := Self.ParamByName (aParams[x]);
      False: lvParam := Self.Params.FindParam (aParams[x]);
    End;
    //
    if Assigned (lvParam) then begin
      // If Unknown then Assign the Parameter as ptInput
      if (lvParam.ParamType = ptUnknown) then lvParam.ParamType := ptInput;
      // Set Unknown DataType then Set DataType to Variant DataType
      if (lvParam.DataType = ftUnknown) then lvParam.DataType := VarTypeToDataType (VarType (aValues[x]));
      //
      if (VarIsNull (aValues[x]) or VarIsEmpty (aValues[x])) then lvParam.Clear
      else lvParam.Value := fnAssignDataValue (lvParam.DataType, aValues[x]);
    end;
  end;
end;

// Routine: fnParamExists
// Author: M.A.Sargent  Date: 15/07/14  Version: V1.0
//
// Notes:
//
Function tMASmySQLStoredProc.fnParamExists (Const aName: String): Boolean;
begin
  Result := Assigned (Self.Params.FindParam (aName));
end;

// Routine:
// Author: M.A.Sargent  Date: 10/03/13  Version: V1.0
//
// Notes:
//
procedure tMASmySQLStoredProc.SetUp (aDatabase: TmySQLDatabase; Const aSPName: String);
begin
  // Assign a Connection and then Assign the Stored Procdure Name
  if (Self.Database <> aDatabase) then Self.Database := aDatabase;
  SetUp (aSPName);
end;
Procedure tMASmySQLStoredProc.SetUp (Const aSPName: String);
begin
  if not IsEqual (aSPName, ProcedureName) then begin
    ProcedureName := aSPName;
    //Self.PrepareCursor;
  end;
end;

Function tMASmySQLStoredProc.fnSQLWrapper: String;
begin
  Result := GetCallStatement;
end;

end.
