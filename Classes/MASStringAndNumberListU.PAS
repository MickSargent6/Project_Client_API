//
// Unit: MASStringAndNumberListU;
// Author: M.A.Sargent  Date: 28/05/2011  Version: V1.0
//         M.A.Sargent        19/05/2012           V2.0
//
// Notes:
//  V2.0: Add new method 
//
unit MASStringAndNumberListU;

interface

Uses Classes, MASStringListU, db, SysUtils;

type
  tProcessLine = Procedure (Const aLine: String; var aOK: Boolean) of Object;
  tKeepValue = (kvFirst, kvLast, kvLowest, kvHighest);

Type
  tMASStringAndNumberList = Class (tMASStringList)
  Private
    fOnBeforeProcess, fOnAfterProcess: tNotifyEvent;
    fOnEachLine: tProcessLine;
    fKeepValue: tKeepValue;
  Protected
    Procedure IntAdd (Const aName: String; Const aValue: Integer);
  Public
    Constructor Create; override;
    Procedure LoadFromDataSet (aDataSet: tDataSet; aField1 : string; aField2 : string);
    Procedure LoadFromFile2 (Const aFileName: String; Const aDuplicate: tDuplicates = dupError);
    Procedure LoadFromFile3 (Const aFileName: String; Const aDuplicate: tDuplicates = dupError; Const aUpdateKeepValue: tKeepValue = kvLast);
    Function fnGetInteger (Const aName: String): Integer; overload;
    Function fnGetInteger (Const aIndex: Integer): Integer; overload;
    Procedure AddEntry (Const aName: String; Const aValue: Integer);
    Procedure UpdateValue (Const aName: String; Const aValue: Integer);
    Procedure IncrementValue (Const aName: String);
    procedure SaveToFile2 (Const FileName: string);
  Published
    Property UpdateKeepValue: tKeepValue read fKeepValue write fKeepValue default kvLast;
    Property OnBeforeProcess: tNotifyEvent read fOnBeforeProcess write fOnBeforeProcess;
    Property OnAfterProcess: tNotifyEvent read fOnAfterProcess write fOnAfterProcess;
    Property OnEachLine: tProcessLine read fOnEachLine write fOnEachLine;
  end;

implementation

Uses DissectU;

{ tExistList }

constructor tMASStringAndNumberList.Create;
begin
  inherited;
  fOnBeforeProcess := Nil;
  fOnAfterProcess  := Nil;
  fOnEachLine      := Nil;
  //
  Sorted := True;
  Duplicates  := dupError;
  FreeObjects := False;
  fKeepValue  := kvLast;
end;

// Routine: fnGetInteger
// Author: M.A.Sargent  Date: 11/05/12  Version: V1.0
//
// Notes:
//
Function tMASStringAndNumberList.fnGetInteger (Const aName: String): Integer;
begin
  if Find (aName, Result) then
    Result := fnGetInteger (Result)
  else Result := -1;
end;
Function tMASStringAndNumberList.fnGetInteger (Const aIndex: Integer): Integer;
begin
  Result := Integer (Objects [aIndex])
end;

procedure tMASStringAndNumberList.AddEntry(const aName: String; const aValue: Integer);
begin
  IntAdd (aName, aValue);
end;

procedure tMASStringAndNumberList.UpdateValue (Const aName: String; Const aValue: Integer);
var
  x: Integer;
begin
  Case Find (aName, x) of
    True:  Self.Objects [x] := tObject (aValue);
    False: IntAdd (aName, aValue); {Add if not Found}
  End;
end;

procedure tMASStringAndNumberList.IntAdd(const aName: String; const aValue: Integer);
begin
  AddObject (aName, tObject(aValue));
end;

procedure tMASStringAndNumberList.LoadFromDataSet(aDataSet: tDataSet; aField1 : string; aField2 : string);
begin
  if not aDataSet.Active then Exit;
  Clear;
  with aDataSet do begin
    First;
    while not EOF do begin
      IntAdd (aDataSet.FieldByName(aField1).AsString, aDataSet.FieldByName(aField2).AsInteger);
      Next;
    end;
  end;
end;

// Routine: LoadFromFile
// Author: M.A.Sargent  Date: 15/12/08  Version: V1.0
//         M.A.Sargent        17/01/09           V2.0
//
// Notes: Add method to load data from a external text file, in the format
//        ssssss, nnn
//  V2.0: Add events to routine
//
Procedure tMASStringAndNumberList.LoadFromFile3 (Const aFileName: String; Const aDuplicate: tDuplicates; Const aUpdateKeepValue: tKeepValue);
begin
  UpdateKeepValue := aUpdateKeepValue;
  LoadFromFile2 (aFileName, aDuplicate);
end;

procedure tMASStringAndNumberList.LoadFromFile2 (Const aFileName: String; Const aDuplicate: tDuplicates);
var
  lvList: tStringList;
  x: Integer;
  lvOK: Boolean;
  lvStr: String;
  lvInt: Integer;
  lvStored: Integer;
begin
  Clear;
  lvList := tStringList.Create;
  Try
    if Assigned (fOnBeforeProcess) then fOnBeforeProcess (Self);
    lvList.LoadFromFile(aFileName);
    for x := 0 to lvList.Count-1 do begin
      lvOK := True;
      if Assigned (fOnEachLine) then fOnEachLine (lvList.Strings[x], lvOK);
      // Add if OK
      if lvOK then begin
        //
        lvStr := GetField (lvList.Strings[x], ',', 0);
        lvInt := StrToInt (GetField (lvList.Strings[x], ',', 1));
        //
        Case aDuplicate of
          dupError: AddEntry (lvStr, lvInt);
          else begin
            if Self.Exists (lvStr) then begin
              Case aDuplicate of
                dupIgnore:; {Do Nothing At Present}
                dupAccept: begin
                  lvStored := fnGetInteger (lvStr);
                  // If Duplicate Values are different, keep the correct value
                  if (lvStored<>lvInt) then
                    Case fKeepValue of
                      kvFirst:;                               {Do Nothing, Leave As Is}
                      kvLast:    UpdateValue (lvStr, lvInt);  {Load As Is}
                      kvLowest:  if (lvStored > lvInt) then UpdateValue (lvStr, lvInt);
                      kvHighest: if (lvStored < lvInt) then UpdateValue (lvStr, lvInt);
                    end;
                end;
              end;
            end else AddEntry (lvStr, lvInt);
          end;
        end;
      end;
    end;
    // After Event
    if Assigned (fOnAfterProcess) then fOnAfterProcess (Self);
  Finally
    lvList.Free;
  End;
end;

// Routine: SaveToFile2
// Author: M.A.Sargent  Date: 10/12/08  Version: V1.0
//         M.A.Sargent        17/01/09           V2.0
//
// Notes: Add SaveTofile1 method that will outout the data in CSV format = String, integer
//  V2.0: Add events to routine
//
procedure tMASStringAndNumberList.SaveToFile2 (Const FileName: string);
var
  x: Integer;
  lvObj: tStringList;
  lvOK: Boolean;
begin
  lvObj := tStringList.Create;
  Try
    if Assigned (fOnBeforeProcess) then fOnBeforeProcess (Self);
    for x := 0 to Self.Count-1 do begin
      lvOK := True;
      if Assigned (fOnEachLine) then fOnEachLine (Self.Strings[x], lvOK);
      // Save if OK
      if lvOK then lvObj.Add (Format ('%s,%d', [Self.Strings[x], Integer (Self.Objects[x])]));
    end;
    // After Event
    if Assigned (fOnAfterProcess) then fOnAfterProcess (Self);
    lvObj.SaveToFile (FileName);
  Finally
    lvObj.Free;
  End;
end;

// Routine: IncrementValue
// Author: M.A.Sargent  Date: 19/05/12  Version: V1.0
//
// Notes:
//
Procedure tMASStringAndNumberList.IncrementValue (Const aName: String);
var
  lvValue: Integer;
begin
  lvValue := fnGetInteger (aName);
  Case (lvValue<>-1) of
    True:  UpdateValue (aName, (lvValue + 1));
    False: AddEntry (aName, 1);
  end;
end;

end.
