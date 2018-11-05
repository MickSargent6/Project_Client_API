//
// Unit: MAS_Collections2U
// Author: M.A.Sargent  Date: 03/09/2015  Version: V1.0
//
// Notes: Basically Three different version of tStringLists with tStringLists as objects
//        sort of tStringList MAster Details setup
//
unit MAS_Collections2U;

interface

Uses Classes, MASStringListU, SysUtils, MASRecordStructuresU, MAS_ConstsU;

Type
  tStringListList = Class (tObject)
  Private
    fList: tMASStringList;
  Public
    Constructor Create; virtual;
    Destructor Destroy; override;
    //
    Procedure Clear;
    Function AddEntry   (Const aName: String): Integer; overload;
    Function AddEntry   (Const aName: String; Const aList: tStrings): Integer; overload;

    Function UpdEntry   (Const aName: String; Const aList: tStrings; Const MustExist: Boolean = True): Integer;
    Function fnGetEntry (Const aName: String; var aList: tStrings; Const aAssignList: Boolean = True): Boolean;
    //
    Function fnExists   (Const aName: String): Integer; overload;
    Function fnExists2  (Const aName: String): Boolean; overload;
  end;

  tStringListList2 = Class (tObject)
  Private
    fList: tMASStringList;
  Public
    Constructor Create; virtual;
    Destructor Destroy; override;
    //
    Procedure Clear;
    Function  AddEntry    (Const aName, aValue: String): Integer; overload;
    Function  AddEntry    (Const aId: Integer; Const aValue: String): Integer; overload;
    //

    Function  fnGetEntry  (Const aName: String; var aList: tStrings; Const aAssignList: Boolean = True): Boolean; overload;
    Function  fnGetEntry  (Const aId: Integer;  var aList: tStrings; Const aAssignList: Boolean = True): Boolean; overload;
    Function  fnGetEntry2 (Const aName: String): tOKStrRec; overload;
    Function  fnGetEntry2 (Const aId: Integer): tOKStrRec; overload;
    //
    Function  fnCount: Integer;
    Function  fnGetIdByIdx     (Const aIdx: Integer): String;
    Function  fnGetEntryByIdx  (Const aIdx: Integer;  var aList: tStrings; Const aAssignList: Boolean = True): Boolean;

    //
    Function  fnDelete    (Const aName: String): Boolean; overload;
    Function  fnDelete    (Const aId: Integer): Boolean; overload;
    //
    Function  fnExists    (Const aName: String): Integer; overload;
    Function  fnExists2   (Const aName: String): Boolean; overload;
  end;

  tStringListList3 = Class (tObject)
  Private
    fList: tStringListList2;
  Public
    Constructor Create; virtual;
    Destructor Destroy; override;
    //
    Procedure Clear;
    Function  AddEntry    (Const aId, aName, aValue: String): Integer;
    Function  UpdEntry    (Const aId, aName, aValue: String): Boolean;
    Function  UpdEntry2   (Const aId, aName, aValue: String): Boolean;
    //
    Function  fnGetEntry2     (Const aId, aName: String): tOKStrRec; overload;
    Function  fnGetEntryByIdx (Const aIdx: Integer; Const aName: String): tOKStrRec;
    //
    Function  fnDelete    (Const aId: String): Boolean; overload;
    //
    Function  fnExists    (Const aId: String): Integer; overload;
    Function  fnExists2   (Const aId: String): Boolean; overload;
    Function  fnExists2   (Const aId, aName: String): Boolean; overload;
  end;

implementation

Uses MASCommonU;

{ tStringListList }

Constructor tStringListList.Create;
begin
  fList := tMASStringList.CreateSorted;
end;

Destructor tStringListList.Destroy;
begin
  Clear;
  fList.Free;
  inherited;
end;

// Routine: AddEntry
// Author: M.A.Sargent  Date: 25/04/15  Version: V1.0
//
// Notes:
//
Function tStringListList.AddEntry (Const aName: String): Integer;
begin
  //
  Result := fnExists (aName);
  Case (Result <> -1 ) of
    True:; {Do Nothing at Present}
    else   Result := AddEntry (aName, Nil);
  end;
end;

// Routine: AddEntry
// Author: M.A.Sargent  Date: 25/04/15  Version: V1.0
//
// Notes:
//
Function tStringListList.AddEntry (Const aName: String; Const aList: tStrings): Integer;
var
  lvList: tMASStringList;
begin
  //
  Case fnExists2 (aName) of
    True: Result := UpdEntry (aName, aList);
    else begin
      lvList := tMASStringList.Create;
      Try
        if Assigned (aList) then lvList.Assign (aList);
        Result := fList.AddObject (aName, lvList);
      Except
        lvList.Free;
        Raise;
      End;
    end;
  end;
end;

// Routine: fnExists & fnExists2
// Author: M.A.Sargent  Date: 03/09/15  Version: V1.0
//
// Notes:
//
Function tStringListList.fnExists (Const aName: String): Integer;
begin
  Result := fList.GetIndex (aName);
end;
Function tStringListList.fnExists2 (Const aName: String): Boolean;
begin
  Result := fList.Exists (aName);
end;

// Routine: fnGetEntry
// Author: M.A.Sargent  Date: 03/09/15  Version: V1.0
//
// Notes:
//
Function tStringListList.fnGetEntry (Const aName: String; var aList: tStrings; Const aAssignList: Boolean): Boolean;
var
  lvIdx: Integer;
begin
  lvIdx := fnExists (aName);
  Result := (lvIdx <> cMC_NOT_FOUND);
  Case Result of
    True: Case aAssignList of
            True: begin
                  if not Assigned (aList) then Raise Exception.Create ('Error. fnGetEntry. aList Must be Assigned');
                  aList.Assign (tMASStringList (fList.Objects [lvIdx]));
            end
            else  aList := tMASStringList (fList.Objects [lvIdx]);
          end;
    else  aList := Nil;
  end;
end;

// Routine: UpdEntry
// Author: M.A.Sargent  Date: 03/09/15  Version: V1.0
//
// Notes:
//
Function tStringListList.UpdEntry (Const aName: String; Const aList: tStrings; Const MustExist: Boolean): Integer;
var
  lvIdx: Integer;
begin
  Result := -1;
  lvIdx := fnExists (aName);
  Case (lvIdx <> cMC_NOT_FOUND) of
    True: tMASStringList (fList.Objects [lvIdx]).Assign (aList);
    else begin
      if MustExist then Raise Exception.Create ('Error. UpdEntry. aList Must be Assigned');
      Result := AddEntry (aName, aList);
    end;
  end;
end;

// Routine: Clear
// Author: M.A.Sargent  Date: 03/09/15  Version: V1.0
//
// Notes:
//
Procedure tStringListList.Clear;
begin
  fList.Clear;
end;

{ tStringListList2 }

Constructor tStringListList2.Create;
begin
  fList := tMASStringList.CreateSorted;
  fList.FreeObjects := True; {Default but just to make readable}
end;

Destructor tStringListList2.Destroy;
begin
  fList.Clear;
  fList.Free;
  inherited;
end;

// Routine: AddEntry
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes:
//
Function tStringListList2.AddEntry (Const aId: Integer; Const aValue: String): Integer;
begin
  Result := AddEntry (IntToStr (aId), aValue);
end;
Function tStringListList2.AddEntry (Const aName, aValue: String): Integer;
var
  lvList: tMASStringList;
begin
  //
  Result := fnExists (aName);
  Case (Result <> cMC_NOT_FOUND) of
    True: begin
      //
      lvList := tMASStringList (fList.Objects [Result]);
      lvList.Add (aValue);
      Result := Length (lvList.Text);
    end;
    else begin
      lvList := tMASStringList.Create;
      Try
        lvList.Add (aValue);
        fList.AddObject (aName, lvList);
        Result := Length (lvList.Text);
      Except
        lvList.Free;
        Raise;
      End;
    end;
  end;
end;

Procedure tStringListList2.Clear;
begin
  fList.Clear;
end;

// Routine: fnDelete
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes:
//
Function tStringListList2.fnDelete (Const aName: String): Boolean;
begin
  Result := fList.DeleteByName (aName);
end;
Function tStringListList2.fnDelete (Const aId: Integer): Boolean;
begin
  Result := fnDelete (IntToStr (aId));
end;

// Routine: fnExists
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes:
//
Function tStringListList2.fnExists (Const aName: String): Integer;
begin
  Result := fList.GetIndex (aName);
end;
Function tStringListList2.fnExists2 (Const aName: String): Boolean;
begin
  Result := fList.Exists (aName);
end;

// Routine: fnGetEntry
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes:
//
Function tStringListList2.fnGetEntry (Const aId: Integer; var aList: tStrings; Const aAssignList: Boolean): Boolean;
begin
  Result := fnGetEntry (IntToStr (aId), aList, aAssignList);
end;
Function tStringListList2.fnGetEntry (Const aName: String; var aList: tStrings; Const aAssignList: Boolean): Boolean;
var
  lvIdx: Integer;
begin
  lvIdx := fnExists (aName);
  Result := (lvIdx <> cMC_NOT_FOUND);
  Case Result of
    True: Case aAssignList of
            True: begin
                  if not Assigned (aList) then Raise Exception.Create ('Error. fnGetEntry. aList Must be Assigned');
                  aList.Assign (tMASStringList (fList.Objects [lvIdx]));
            end
            else  aList := tMASStringList (fList.Objects [lvIdx]);
          end;
    else  aList := Nil;
  end;
end;

Function tStringListList2.fnGetEntry2 (Const aId: Integer): tOKStrRec;
begin
  Result := fnGetEntry2 (IntToStr (aId));
end;
Function tStringListList2.fnGetEntry2 (Const aName: String): tOKStrRec;
var
  lvList: tStrings;
begin
  Result.OK := fnGetEntry (aName, lvList, False);
  if Result.OK then
    Result.Msg := lvList.Text;
end;

Function tStringListList2.fnCount: Integer;
begin
  Result := fList.Count;
end;

Function tStringListList2.fnGetIdByIdx (Const aIdx: Integer): String;
begin
  Result := fList.Strings [aIdx];
end;
Function tStringListList2.fnGetEntryByIdx (Const aIdx: Integer; var aList: tStrings; Const aAssignList: Boolean): Boolean;
var
  lvName: String;
begin
  lvName := fList.Strings[aIdx];
  Result := fnGetEntry (lvName, aList, aAssignList);
end;

{ tStringListList3 }

Constructor tStringListList3.Create;
begin
  fList := tStringListList2.Create;
end;

Destructor tStringListList3.Destroy;
begin
  fList.Clear;
  fList.Free;
  inherited;
end;

Procedure tStringListList3.Clear;
begin
  fList.Clear;
end;

// Routine:
// Author: M.A.Sargent  Date: 13/05/18  Version: V1.0
//
// Notes:
//
Function tStringListList3.AddEntry (Const aId, aName, aValue: String): Integer;
begin
  Result := fList.AddEntry (aId, fnAddValuePair (aName, aValue));
end;

// Routine: UpdEntry
// Author: M.A.Sargent  Date: 13/05/18  Version: V1.0
//
// Notes:
//
Function tStringListList3.UpdEntry (Const aId, aName, aValue: String): Boolean;
var
  lvList: tStrings;
begin
  Result := fList.fnGetEntry (aId, lvList, False);
  if Result then
    tMASStringList (lvList).Values [aName] := aValue;
end;
Function tStringListList3.UpdEntry2 (Const aId, aName, aValue: String): Boolean;
begin
  Result := UpdEntry (aId, aName, aValue);
  if not Result then AddEntry (aId, aName, aValue);
end;

// Routine: fnDelete
// Author: M.A.Sargent  Date: 13/05/18  Version: V1.0
//
// Notes:
//
Function tStringListList3.fnDelete (Const aId: String): Boolean;
begin
  Result := fList.fnDelete (aId);
end;
{Function tStringListList3.fnDelete (Const aId, aName: String): Boolean;
var
  lvList: tStrings;
begin
  Result := fList.fnGetEntry (aId, lvList, False);
  if Result then begin
    Result := tMASStringList (lvList).DeleteByName (aName);
end;}

// Routine: fnExists
// Author: M.A.Sargent  Date: 13/05/18  Version: V1.0
//
// Notes:
//
Function tStringListList3.fnExists (Const aId: String): Integer;
begin
  Result := fList.fnExists (aId);
end;
Function tStringListList3.fnExists2 (Const aId: String): Boolean;
begin
  Result := fList.fnExists2 (aId);
end;
Function tStringListList3.fnExists2 (Const aId, aName: String): Boolean;
var
  lvList: tStrings;
begin
  Result := fList.fnGetEntry (aId, lvList, False);
  if Result then Result := tMASStringList (lvList).fnValueExist (aName);
end;

// Routine: fnGetEntry2
// Author: M.A.Sargent  Date: 13/05/18  Version: V1.0
//
// Notes:
//
Function tStringListList3.fnGetEntryByIdx (Const aIdx: Integer; Const aName: String): tOKStrRec;
var
  lvId: String;
begin
  lvId   := fList.fnGetIdByIdx (aIdx);
  Result := Self. fnGetEntry2 (lvId, aName)
end;

Function tStringListList3.fnGetEntry2 (Const aId, aName: String): tOKStrRec;
var
  lvList: tStrings;
begin
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  Result.OK := fList.fnGetEntry (aId, lvList, False);
  if Result.OK then Result.Msg := tMASStringList (lvList).Values [aName];
end;

end.

