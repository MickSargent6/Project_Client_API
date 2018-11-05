//
// Unit: MASmySQLQuery
// Author: M.A.Sargent  Date: 04/09/13  Version: V1.0
//
// Notes:
//
unit MASmySQLQuery;

interface

uses
  SysUtils, Classes, DB, mySQLDbTables, Variants, MASDbUtilsCommonU, ExtCtrls;

Type
  tDatasetDelayScroll = Procedure (DataSet: tDataSet) of object;
  //tDatasetDelayScroll = Procedure (DataSet: tDataSet; var aChildDataSet: tDataSet) of object;

type
  tMASmySQLQuery = class(TmySQLQuery)
  private
    { Private declarations }
    fTimer: tTimer;
    fOnDelayedAfterScroll: tDatasetDelayScroll;
    procedure DoTimerEvent(Sender: TObject);
  protected
    { Protected declarations }
    procedure DoAfterScroll ; override;
  public
    { Public declarations }
    Constructor Create (aOwner: tComponent); override;
    Destructor Destroy; override;
    procedure ClearParameters;
    procedure LoadParamByName (Const aParams: array of string; Const aValues: array of Variant; Const aMustExist: Boolean);
    //
    Procedure ReRun (Const DisableCtrls: Boolean = True); overload; virtual;
    Procedure ReRun (Const DisableCtrls, KeepBookMark: Boolean); overload;
    Procedure ReRun (aDataSet: tDataSet; Const DisableCtrls: Boolean = True); overload;
    Procedure RunQuery (Const aParams: array of string; Const aValues: array of Variant; Const DisableCtrls: Boolean = True);

  published
    { Published declarations }
    property MASAfterScrollDelay: tDatasetDelayScroll
                                    read fOnDelayedAfterScroll
                                      write fOnDelayedAfterScroll;

  end;

  //
  //
  Function h_fnGetQuery (aConnection: TmySQLDatabase): tMASmySQLQuery; overload;

implementation

Const
  cDELAYINTERVAL = 333;

// Routine: h_fnGetQuery
// Author: M.A.Sargent  Date: 13/12/12  Version: V1.0
//
// Notes:
//
Function h_fnGetQuery (aConnection: TmySQLDatabase): tMASmySQLQuery; overload;
begin
  Result := tMASmySQLQuery.Create (Nil);
  Try
    Result.Database := aConnection;
  Except
    FreeAndNil (Result);
    Raise;
  end;
end;

{ tMASmySQLQuery }

procedure tMASmySQLQuery.ClearParameters;
var
  x : Integer;
begin
  for x := 0 to ParamCount-1 do
    if Params[x].Datatype <> ftCursor then
      Params[x].Clear;
end;

constructor tMASmySQLQuery.Create(aOwner: tComponent);
begin
  inherited;
  fOnDelayedAfterScroll := Nil;
  {Create the delay timer}
  fTimer := TTimer.Create (Nil);
  fTimer.Enabled     := False;
  fTimer.Interval    := cDELAYINTERVAL;
  fTimer.OnTimer     := DoTimerEvent;  // Assign the ScrollDelay Event
end;

destructor tMASmySQLQuery.Destroy;
begin
  if Assigned (fTimer) then fTimer.Free;
  inherited;
end;

procedure tMASmySQLQuery.LoadParamByName (Const aParams: array of string; Const aValues: array of Variant; Const aMustExist: Boolean);
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

procedure tMASmySQLQuery.ReRun (Const DisableCtrls: Boolean);
begin
  ReRun (Nil, DisableCtrls);
end;

procedure tMASmySQLQuery.ReRun (Const DisableCtrls, KeepBookMark: Boolean);
var
  lvBookMark: tBookMark;
begin
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

procedure tMASmySQLQuery.ReRun (aDataSet: tDataSet; Const DisableCtrls: Boolean);
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

procedure tMASmySQLQuery.RunQuery (Const aParams: array of string; Const aValues: array of Variant; Const DisableCtrls: Boolean);
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
procedure tMASmySQLQuery.DoTimerEvent (Sender: TObject);
begin
  fTimer.Enabled:= False;
  if Assigned (fOnDelayedAfterScroll) then begin
    fOnDelayedAfterScroll (Self);
  end;
end;

procedure tMASmySQLQuery.DoAfterScroll;
begin
  inherited;
  if Assigned (fOnDelayedAfterScroll) then begin
    fTimer.Enabled:= False;
    fTimer.Enabled := True;
  end;
end;

end.
