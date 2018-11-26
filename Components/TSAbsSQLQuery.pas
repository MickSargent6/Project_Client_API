//
// Unit: TSAbsSQLQuery
// Author: M.A.Sargent  Date: 04/09/13  Version: V1.0
//
// Notes:
//
unit TSAbsSQLQuery;

interface

uses
  SysUtils, Classes, DB, Variants, MASDbUtilsCommonU, ExtCtrls, ABSBase, ABSMain, TSAbsCommonU, MASMessagesU,
   MASStringListU;

type
  tTSAbsQuery = Class;
  tOnDebugSQL      = Procedure (aQry: tTSAbsQuery; Const aSQL: TStrings; Const aParams: tParams) of object;

  tTSAbsQuery = class (TABSQuery)
  private
    { Private declarations }
    fTimer:                tTimer;
    fOnDelayedAfterScroll: tDatasetDelayScroll;
    fOnDataSetEvent:       tOnDataSetEvent;
    fOnDebugSQL:           tOnDebugSQL;
    fList:                 tStringList;
    fDebug:                Boolean;
    //
    Procedure DoTimerEvent (Sender: TObject);
    Procedure Int_DoDataSetEvent (Const aDataSetEvent: tDataSetEvent);
  protected
    { Protected declarations }
    Procedure DoAfterScroll; override;
    Procedure DoBeforeOpen;  override;
    Procedure DoAfterOpen;  override;
    Procedure DoAfterInsert; override;
    Procedure DoAfterRefresh; override;
    Procedure DoAfterPost; override;

    Procedure DoDataSetEvent (Const aDataSetEvent: tDataSetEvent); virtual;

  public
    { Public declarations }
    Constructor Create (aOwner: tComponent); override;
    Destructor Destroy; override;
    Procedure ClearParameters;
    Procedure LoadParamByName (Const aParams: array of string; Const aValues: array of Variant; Const aMustExist: Boolean);
    //
    Procedure UnRegisterDataSource (aHandle: tHandle);
    Procedure RegisterDataSource   (aHandle: tHandle);
    //
    Function fnClone: tTSAbsQuery;

    //
    Procedure ReRun (Const DisableCtrls: Boolean = True); overload; virtual;
    Procedure ReRun (Const DisableCtrls, KeepBookMark: Boolean); overload;
    Procedure ReRun (aDataSet: tDataSet; Const DisableCtrls: Boolean = True); overload;
    //
    Procedure RunQuery (Const aParam: String; Const aValue: Variant; Const DisableCtrls: Boolean); overload;
    Procedure RunQuery (Const aParams: array of string; Const aValues: array of Variant; Const DisableCtrls: Boolean = True); overload;
    //
    Property  Debug: Boolean read fDebug write fDebug default False;

  published
    { Published declarations }
    property MASAfterScrollDelay: tDatasetDelayScroll read fOnDelayedAfterScroll write fOnDelayedAfterScroll;
    Property OnDataSetEvent:      tOnDataSetEvent     read fOnDataSetEvent       write fOnDataSetEvent;
    Property OnDebugSQL:          tOnDebugSQL         read fOnDebugSQL           write fOnDebugSQL;
  end;

  //
  //
  Function h_fnGetQuery (aConnection: tABSDataBase): tTSAbsQuery; overload;
  Function h_fnGetQuery (aConnection: tABSDataBaseName): tTSAbsQuery; overload;
  Function h_fnGetQuery (aConnection: tABSDataBase; Const aSQL: string; Const aOpen: Boolean): tTSAbsQuery; overload;
  Function h_fnGetQuery (aConnection: tABSDataBaseName; Const aSQL: string; Const aOpen: Boolean): tTSAbsQuery; overload;
  Function h_fnGetQuery (aQry: tTSAbsQuery): tTSAbsQuery; overload;

implementation

Uses {TSDatasourceU,} TSUK_D7_ConstsU, Dialogs;

Const
  cDELAYINTERVAL = 333;

// Routine: h_fnGetQuery
// Author: M.A.Sargent  Date: 13/12/12  Version: V1.0
//
// Notes:
//
Function h_fnGetQuery (aConnection: tABSDataBase): tTSAbsQuery;
begin
  if not Assigned (aConnection) then Raise Exception.Create ('Error: h_fnGetQuery. tABSDatabase must be Assigned');
  Result := h_fnGetQuery (aConnection.DatabaseName);
end;
Function h_fnGetQuery (aConnection: tABSDataBaseName): tTSAbsQuery;
begin
  Result := tTSAbsQuery.Create (Nil);
  Try
    Result.DatabaseName := aConnection;
  Except
    FreeAndNil (Result);
    Raise;
  end;
end;
Function h_fnGetQuery (aConnection: tABSDataBase; Const aSQL: string; Const aOpen: Boolean): tTSAbsQuery;
begin
  if not Assigned (aConnection) then Raise Exception.Create ('Error: h_fnGetQuery. tABSDatabase must be Assigned');
  Result := h_fnGetQuery (aConnection.DatabaseName, aSQL, aOpen);
end;
Function h_fnGetQuery (aConnection: tABSDataBaseName; Const aSQL: string; Const aOpen: Boolean): tTSAbsQuery;
begin
  Result  := h_fnGetQuery (aConnection);
  Try
    Result.SQL.Text := aSQL;
    if aOpen then Result.Open;
  Except
    FreeAndNil (Result);
    Raise;
  end;
end;

Function h_fnGetQuery (aQry: tTSAbsQuery): tTSAbsQuery;
begin
  if not Assigned (aQry) then Raise Exception.Create ('Error: h_fnGetQuery. A aQry Must be Assigned');
  Result := aQry.fnClone;
end;

{ tTSAbsQuery }

procedure tTSAbsQuery.ClearParameters;
var
  x : Integer;
begin
  for x := 0 to ParamCount-1 do
    if Params[x].Datatype <> ftCursor then
      Params[x].Clear;
end;

constructor tTSAbsQuery.Create(aOwner: tComponent);
begin
  inherited;
  fDebug                := False;
  fOnDelayedAfterScroll := Nil;
  fOnDataSetEvent       := Nil;
  fOnDebugSQL           := Nil;
  {Create the delay timer}
  fTimer := TTimer.Create (Nil);
  fTimer.Enabled     := False;
  fTimer.Interval    := cDELAYINTERVAL;
  fTimer.OnTimer     := DoTimerEvent;  // Assign the ScrollDelay Event
  //
  fList := tStringList.Create;
end;

destructor tTSAbsQuery.Destroy;
begin
  fList.Free;
  if Assigned (fTimer) then fTimer.Free;
  inherited;
end;

procedure tTSAbsQuery.LoadParamByName (Const aParams: array of string; Const aValues: array of Variant; Const aMustExist: Boolean);
var
  x: Integer;
  lvParam: tParam;
begin
  lvParam := Nil;
  if High(aParams) <> High (aValues) then
    //Raise eMagDOAException.Create ('The Number of Params and Values Should be the Same');
  // If not Prepared then Prepare so that values assigned in this routine are
  // not overwritten/cleared by a prepare
  if not Prepared then Prepare;
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

procedure tTSAbsQuery.ReRun (Const DisableCtrls: Boolean);
begin
  ReRun (Nil, DisableCtrls);
end;

// Routine: ReRun
// Author: M.A.Sargent  Date: 23/11/18  Version: V1.0
//
// Notes: Updated to keep the compter happy
//
Procedure tTSAbsQuery.ReRun (Const DisableCtrls, KeepBookMark: Boolean);
var
  lvBookMark: tBookMark;
begin
  lvBookMark := Nil;
  if KeepBookMark then lvBookMark := Self.GetBookmark;
  Try
    ReRun (Nil, DisableCtrls);
  Finally
    if KeepBookMark then begin
      Self.GotoBookMark (lvBookMark);
      Self.FreeBookMark (lvBookMark);
    end;
  end;
end;

procedure tTSAbsQuery.ReRun (aDataSet: tDataSet; Const DisableCtrls: Boolean);
begin
  if DisableCtrls then DisableControls;
  Try
    if Active then Active := False;
    if not Prepared then Prepare;
    //if Assigned (aDataSet) then
    //  LoadVariables (aDataSet);
    Try
      Active := True;
      First; {Should Not be Need but these are Crap Controls, MicroOLAP}
    except
      //if True then MessageDlg (Self.FinalSQL, mtError, [mbOK], 0);
      Raise;
    end;
  Finally
    if DisableCtrls then EnableControls;
  End;
end;

// Routine: RunQuery
// Author: M.A.Sargent  Date: 13/12/12  Version: V1.0
//
// Notes:
//
Procedure tTSAbsQuery.RunQuery (Const aParam: String; Const aValue: Variant; Const DisableCtrls: Boolean);
begin
  RunQuery ([aParam], [aValue], DisableCtrls);
end;

Procedure tTSAbsQuery.RunQuery (Const aParams: array of string; Const aValues: array of Variant; Const DisableCtrls: Boolean);
begin
  if DisableCtrls then DisableControls;
  Try
    Active := False;
    if not Prepared then Prepare;
    LoadParamByName (aParams, aValues, True);
    Active := True;
    First; {Should Not be Need but these are Crap Controls, MicroOLAP}
  Finally
    if DisableCtrls then EnableControls;
  End;
end;

// Notes: Event called on Timer Event, will call Event if assigned
procedure tTSAbsQuery.DoTimerEvent (Sender: TObject);
begin
  fTimer.Enabled:= False;
  if Assigned (fOnDelayedAfterScroll) then begin
    fOnDelayedAfterScroll (Self);
  end;
  Int_DoDataSetEvent (deDelayedAfterScroll);
end;

procedure tTSAbsQuery.DoAfterScroll;
begin
  inherited;
  if Assigned (fOnDelayedAfterScroll) then begin
    fTimer.Enabled:= False;
    fTimer.Enabled := True;
  end;
  Int_DoDataSetEvent (deAfterScroll);
end;

// Routine: fnClone
// Author: M.A.Sargent  Date: 02/10/18  Version: V1.0
//
// Notes:
//
Function tTSAbsQuery.fnClone: tTSAbsQuery;
begin
  Result := tTSAbsQuery.Create (Nil);
  Try
    Result.DatabaseName := DatabaseName;
    Result.SessionName  := SessionName;
    Result.InMemory     := InMemory;
    Result.SQL.Text     := SQL.Text;
    Result.Params.Assign (Self.Params);
  except
    FreeAndNil (Result);
    Raise;
  end;
end;

Procedure tTSAbsQuery.DoAfterOpen;
begin
  inherited;
  Int_DoDataSetEvent (deAfterOpen);
end;

Procedure tTSAbsQuery.Int_DoDataSetEvent (Const aDataSetEvent: tDataSetEvent);
begin
  DoDataSetEvent (aDataSetEvent);
end;


Procedure tTSAbsQuery.DoDataSetEvent (Const aDataSetEvent: tDataSetEvent);
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
    AppPostMessage (lvHandle, um_ABSDatesetEvent, Integer (Self), Ord (aDataSetEvent));
  end;
end;

Procedure tTSAbsQuery.RegisterDataSource (aHandle: tHandle);
begin
  fList.Add (IntToStr(aHandle));
end;
Procedure tTSAbsQuery.UnRegisterDataSource (aHandle: tHandle);
var
  x: Integer;
begin
  x := fList.IndexOf (IntToStr(aHandle));
  if (x <> -1) then fList.Delete (x);
end;

Procedure tTSAbsQuery.DoAfterRefresh;
begin
  inherited;
  Int_DoDataSetEvent (deAfterRefresh);
end;

Procedure tTSAbsQuery.DoBeforeOpen;
var
  lvList: tMASStringList;
  x:      Integer;
begin
  inherited;
  Int_DoDataSetEvent (deBeforeOpen);
  if Assigned (fOnDebugSQL) then fOnDebugSQL (Self, SQL, Params);
  //
  if fDebug then begin
    lvList := tMASStringList.Create;
    Try
      lvList.CopyFromList (SQL);
      lvList.Add ('Params:----------');
      for x := 0 to ParamCount-1 do
        lvList.AddMsg ('  P%d: %s - %s', [(x+1), Params[x].Name, Params[x].AsString]);
      ShowMessage (lvList.Text);
    Finally
      lvList.Free;
    end;
  end;
end;

procedure tTSAbsQuery.DoAfterInsert;
begin
  inherited;
  Int_DoDataSetEvent (deAfterInsert);
end;

Procedure tTSAbsQuery.DoAfterPost;
begin
  inherited;
  Int_DoDataSetEvent (deAfterPost);
end;

end.
