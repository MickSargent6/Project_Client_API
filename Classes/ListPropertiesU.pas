//
// Unit: ListPropertiesU
// Author: M.A.Sargent  Date: 10/03/13  Version: V1.0
//         M.A.Sargent        22/04/17           V2.0
//         M.A.Sargent        20/10/17           V3.0
//
// Notes: At present this class only works with
//          1. Properties Values (Float, Integer, String etc)
//          2. Embedded tObjects
// V2.0:
// V3.0: Add new method fnListProperties
//
unit ListPropertiesU;

interface

Uses Classes, TypInfo, MASStringListU, MASStringAndNumberListU, SysUtils, MASRecordStructuresU,
      Dialogs, Variants;

Type
  tResultType = (rtPath, rtProperty);
  tPropertyItem = Class;
  tOnListProperties = Procedure (Const aLevel: Integer; aObject: tObject; Const aPropertyItem: tPropertyItem; aPPropInfo: PPropInfo) of object;

  tPropertyRec = Record
    aObject: tObject;
    PropertyPath: String;
    PropertyName: String;
    PPropInfo: PPropInfo;
  end;

  tPropertyItem = Class (tObject)
  Private
    fPPropInfo: PPropInfo;
    fObject: tObject;
    fPropertyName: String;
    fTypeKind: tTypeKind;
    fPropertyPath: String;
  Public
    Constructor Create (Const aPropertyPath: String; Const aTypeKind: tTypeKind; aObject: tObject; Const aPPropInfo: PPropInfo);
    Property aObject: tObject read fObject;
    Property PropertyPath: String read fPropertyPath;
    Property PropertyName: String read fPropertyName;
    Property TypeKind: tTypeKind read fTypeKind;
    Property PPropInfo: PPropInfo read fPPropInfo;
  end;

  tPropertyList = Class (tObject)
  private
    fObject: tObject;
    fList: tMASStringList;
    fOnListProperties: tOnListProperties;
    //
    Procedure SetObject (Const Value: tObject);
    function GetObject: tObject;

    Function ToPropertyType (Const aPropertyName: String): tTypeKind; overload;
    Function ToPropertyType (Const aOrdValue: Integer): tTypeKind; overload;
    //
    Property fnObject: tObject read GetObject write SetObject;
    //
    Function Int_fnLoadProperties (Const aParent: String; Const aObject: tObject): Integer;
    //
    Function fnGetPropertyObject (Const aName: String): tPropertyRec;
    Function fnGetPropertyItem (Const aName: String; Const aRaiseOnNotFound: Boolean = True): tPropertyItem;

  Public
    Constructor Create;
    Destructor Destroy; override;
    //
    Procedure Clear;
    //
    Function fnLoadProperties (Const aObject: tObject): Integer;
    Function Count: Integer;
    //
    Function fnPropertyExists (Const aName: String): Boolean;
    Function GetPropertyByName (Const aName: String; Const aRaiseOnNotFound: Boolean = True): tPropertyItem;
    Function GetValueById   (Const aId: Integer): tPropertyItem;
    Function GetValueByName (Const aName: String): tOKVariant;
    Function SetValueByName (Const aName: String; Const aValue: Variant): Boolean;
    //
    Procedure ListProperties;
    Function fnListProperties (Const aList: tStrings): Integer; 
    //
    Class Function fnListProperties2 (Const aObject: tObject; Const aFileName: String): Integer; overload;
    Class Function fnListProperties2 (Const aObject: tObject; Const aList: tStrings): Integer; overload;
    //
    Property OnListProperties: tOnListProperties read fOnListProperties write fOnListProperties;
  end;

  //
  Function fnGetFromPropertyPath (Const aPropertyPath: String; Const aResultType: tResultType): String;
  //
  Function fnToPropertyDesc (Const aTypeKind: tTypeKind): String; overload;
  Function fnToPropertyDesc (Const aOrdValue: Integer): String; overload;

implementation

Uses FormatResultU;

// Routine: fnGetPropertyNameFromPath
// Author: M.A.Sargent  Date: 21/04/15  Version: V1.0
//
// Notes:
//
Function fnGetFromPropertyPath (Const aPropertyPath: String; Const aResultType: tResultType): String;
var
  lvPos: Integer;
begin
  Result := aPropertyPath;
  lvPos := LastDelimiter ('.', Result);
  if (lvPos > 0) then
    Case aResultType of
      rtPath: Result := Copy (Result, 1, (lvPos-1));
      {rtProperty}
      else    Result := Copy (Result, (lvPos+1), MaxInt);
    end;
end;

// Routine: fnToPropertyDesc
// Author: M.A.Sargent  Date: 21/04/15  Version: V1.0
//
// Notes:
//
Function fnToPropertyDesc (const aTypeKind: tTypeKind): String;
begin
  Result := fnToPropertyDesc (Ord (aTypeKind));
end;

Function fnToPropertyDesc (Const aOrdValue: Integer): String;
begin
  Case aOrdValue of
    0:  Result := 'tkUnknown';
    1:  Result := 'tkInteger';
    2:  Result := 'tkChar';
    3:  Result := 'tkEnumeration';
    4:  Result := 'tkFloat';
    5:  Result := 'tkString';
    6:  Result := 'tkSet';
    7:  Result := 'tkClass';
    8:  Result := 'tkMethod';
    9:  Result := 'tkWChar';
    10: Result := 'tkLString';
    11: Result := 'tkWString';
    12: Result := 'tkVariant';
    13: Result := 'tkArray';
    14: Result := 'tkRecord';
    15: Result := 'tkInterface';
    16: Result := 'tkInt64';
    17: Result := 'tkDynArray';
    18: Result := 'tkUString';
    19: Result := 'tkClassRef';
    20: Result := 'tkPointer';
    21: Result := 'tkProcedure';
    else Raise Exception.CreateFmt ('Error: UnKnown Value Passed to fnToPropertyDesc (%d)', [aOrdValue]);
  end;
end;

{ tPropertyItem }

Constructor tPropertyItem.Create (Const aPropertyPath: String; Const aTypeKind: tTypeKind; aObject: tObject; Const aPPropInfo: PPropInfo);
begin
  fPropertyPath := fnGetFromPropertyPath (aPropertyPath, rtPath);
  fPropertyName := fnGetFromPropertyPath (aPropertyPath, rtProperty);
  fTypeKind     := aTypeKind;
  fObject       := aObject;
  fPPropInfo    := aPPropInfo;
end;

{ tPropertyList }

// Routine: fnListProperties2
// Author: M.A.Sargent  Date: 21/04/17  Version: V1.0
//
// Notes:
//
Class Function tPropertyList.fnListProperties2 (Const aObject: tObject; Const aFileName: String): Integer;
var
  lvList: tStringList;
begin
  fnRaiseOnFalse ((aFileName <> ''), 'Error: fnListProperties2. aFilename can not be Blank');
  //
  lvList := tStringList.Create;;
  Try
    Result := fnListProperties2 (aObject, lvList);
    lvList.SaveToFile (aFileName);
  Finally
    lvList.Free;
  end;
end;


Class Function tPropertyList.fnListProperties2 (Const aObject: tObject; Const aList: tStrings): Integer;
var
  lvObj: tPropertyList;
begin
  lvObj := tPropertyList.Create;
  Try
    lvObj.fnLoadProperties (aObject);
    Result := lvObj.fnListProperties (aList);
  Finally
    lvObj.Free;
  end;
end;

Constructor tPropertyList.Create;
begin
  fList := tMASStringList.Create;
  fOnListProperties := Nil;
end;

Destructor tPropertyList.Destroy;
begin
  fList.Free;
  inherited;
end;

Procedure tPropertyList.Clear;
begin
  fList.Clear;
  fObject := Nil;
end;

Function tPropertyList.Count: Integer;
begin
  Result := fList.Count;
end;

// Routine: fnGetPropertyItem
// Author: M.A.Sargent  Date: 21/04/15  Version: V1.0
//
// Notes:
//
Function tPropertyList.fnGetPropertyObject (Const aName: String): tPropertyRec;
var
  lvPropertyItem: tPropertyItem;
begin
  lvPropertyItem := fnGetPropertyItem (aName);

  Result.aObject      := lvPropertyItem.aObject;
  Result.PropertyPath := lvPropertyItem.PropertyPath;
  Result.PropertyName := lvPropertyItem.PropertyName;
  Result.PPropInfo    := lvPropertyItem.PPropInfo;

  if not Assigned (Result.aObject) then begin
    //
    Result.PropertyPath := fnGetFromPropertyPath (Result.PropertyPath, rtPath);
    lvPropertyItem      := fnGetPropertyItem (Result.PropertyPath);
    Result.aObject      := lvPropertyItem.aObject;
  end;
end;

Function tPropertyList.fnGetPropertyItem (Const aName: String; Const aRaiseOnNotFound: Boolean): tPropertyItem;
var
  x: Integer;
begin
  Result := Nil;
  x := Self.fList.IndexOf (aName);
  if (x <> -1) then
    Result := tPropertyItem (Self.fList.Objects [x]);
  //
  if aRaiseOnNotFound and not Assigned (Result) then Raise Exception.CreateFmt ('Error: Property (%s) Not Found', [aName]);
end;

Function tPropertyList.fnLoadProperties (Const aObject: tObject): Integer;
begin
  Clear;
  fnObject := aObject;
  //
  Int_fnLoadProperties ('', fnObject);
  Result := fList.Count;
end;

Function tPropertyList.Int_fnLoadProperties (Const aParent: String; Const aObject: tObject): Integer;
var
  iprop : integer;
  ppi : PPropInfo;
  pprops : PPropList;
  lvObj: tObject;
  lvCount: Integer;
begin
  Result := -1;
  if Not Assigned (aObject) then Exit;
  //
  //
  Result := GetTypeData(aObject.classinfo).propcount;
  lvCount := Result;

  GetMem(pprops, sizeof(ppropInfo) * Result);
  GetPropInfos(aObject.classinfo, pprops);
  try
    for iprop := 0 to lvCount-1 do begin
      ppi := pprops[iprop];
      //
      lvObj := Nil;
      if (PpI^.PropType^.Kind = tkClass) then begin
        //
        lvObj := GetObjectProp (aObject, ppi.name);
      end;

      Case (aParent='') of
        True: fList.AddObject (ppi.name,               tPropertyItem.Create (ppi.name, PpI^.PropType^.Kind, lvObj, ppi));
        else  fList.AddObject ((aParent+'.'+ppi.name), tPropertyItem.Create ((aParent+'.'+ppi.name), PpI^.PropType^.Kind, lvObj, ppi));
      end;

      //
      if (PpI^.PropType^.Kind = tkClass) then begin
        //
        Case (aParent='') of
          True: Result := Int_fnLoadProperties (ppi.name, lvObj);
          else;  {not sure if correct but reove at present, problem when a property points to its self
                 ;//Result := Int_fnLoadProperties ((aParent+'.'+ppi.name), lvObj);}
        end;
      end;
    end;
  finally
   FreeMem(pprops, sizeof(ppropInfo) * Result);
  end;
end;

Function tPropertyList.GetObject: tObject;
begin
  Result := fObject;
end;

Procedure tPropertyList.SetObject (Const Value: tObject);
begin
  fObject := Value;
end;

Function tPropertyList.SetValueByName (Const aName: String; Const aValue: Variant): Boolean;
var
  lvObject: tObject;
  lvPropertyRec : tPropertyRec;
begin
  //
  lvObject := fnObject;
  lvPropertyRec := fnGetPropertyObject (aName);
  //
  if Assigned (lvPropertyRec.aObject) then
    lvObject := lvPropertyRec.aObject;

  //
  Result := True;
  Case ToPropertyType (aName) of
    {tkUnknown:;}
    tkClass:;
    {tkMethod:;}
    {tkArray:;}
    {tkRecord:;}
    {tkInterface:;}
    {tkClassRef:;}
    {tkPointer:;}
    {tkProcedure:;}
    tkInteger,
    tkChar,
    tkEnumeration,
    tkFloat,
    //
    tkLString,
     tkWString,
      tkString,
      {$IFDEF VER150}
      {$ELSE}
        tkUString,
      {$ENDIF}

    tkSet,
    tkWChar,
    tkVariant,
    tkInt64,
    tkDynArray:            SetPropValue (lvObject, lvPropertyRec.PropertyName, aValue);
    else Raise Exception.CreateFmt ('Error: UnKnown Value Passed to SetValueByName (%s)', [aName]);
  end;
end;

{
Function tPropertyList.fnGetPropertyItem (Const aName: String): tPropertyItem;
var
  x: Integer;
begin
  Result := Nil;
  x := Self.fList.IndexOf (aName);
  if (x <> -1) then
    Result := tPropertyItem (Self.fList.Objects [x]);
  if not Assigned (Result) then Raise Exception.CreateFmt ('Error: Property (%s) Not Found', [aName]);
end;
}

Function tPropertyList.GetValueById (Const aId: Integer): tPropertyItem;
begin
  Result := tPropertyItem (Self.fList.Objects [aId]);
  if not Assigned (Result) then Raise Exception.CreateFmt ('Error: Property Index (%d) Not Found', [aId]);
end;

Function tPropertyList.GetValueByName (Const aName: String): tOKVariant;
var
  lvObject: tObject;
  lvPropertyRec : tPropertyRec;
begin
  //
  lvObject := fnObject;
  lvPropertyRec := fnGetPropertyObject (aName);
  //
  if Assigned (lvPropertyRec.aObject) then
    lvObject := lvPropertyRec.aObject;

  Result.OK := True;
  Case ToPropertyType (aName) of
    {tkUnknown:;}
    tkClass:;
    {tkMethod:;}
    {tkArray:;}
    {tkRecord:;}
    {tkInterface:;}
    {tkClassRef:;}
    {tkPointer:;}
    {tkProcedure:;}
    tkInteger,
    tkChar,
    tkEnumeration,
    tkFloat,
    //
    tkLString,
     tkWString,
      tkString,
      {$IFDEF VER150}
      {$ELSE}
        tkUString,
      {$ENDIF}
    tkSet,
    tkWChar,
    tkVariant,
    tkInt64,
    tkDynArray:            Result.Msg := GetPropValue (lvObject, lvPropertyRec.PropertyName);
    else begin
      //
      Result.OK  := False;
      Result.Msg := Format ('Error: UnKnown Value Pased to GetValueByName (%s)', [aName]);
    end;
  end;
end;

Function tPropertyList.ToPropertyType (Const aPropertyName: String): tTypeKind;
var
  lvValue: Integer;
begin
  lvValue := Ord (fnGetPropertyItem (aPropertyName).TypeKind);
  Case lvValue of
    -1:  Raise Exception.CreateFmt ('Error: ToPropertyType: Property Not Found (%s)', [aPropertyName]);
    else Result := ToPropertyType (lvValue);
  end;
end;


Function tPropertyList.ToPropertyType (Const aOrdValue: Integer): tTypeKind;
begin
  Case aOrdValue of
    0:  Result := tkUnknown;
    1:  Result := tkInteger;
    2:  Result := tkChar;
    3:  Result := tkEnumeration;
    4:  Result := tkFloat;
    5:  Result := tkString;
    6:  Result := tkSet;
    7:  Result := tkClass;
    8:  Result := tkMethod;
    9:  Result := tkWChar;
    10: Result := tkLString;
    11: Result := tkWString;
    12: Result := tkVariant;
    13: Result := tkArray;
    14: Result := tkRecord;
    15: Result := tkInterface;
    16: Result := tkInt64;
    17: Result := tkDynArray;
      {$IFDEF VER150}
      {$ELSE}
    18: Result := tkUString;
    19: Result := tkClassRef;
    20: Result := tkPointer;
    21: Result := tkProcedure;
      {$ENDIF}
    else Raise Exception.CreateFmt ('Error: UnKnown Value Passed to ToPropertyType (%d)', [aOrdValue]);
  end;
end;

Procedure tPropertyList.ListProperties;
var
  x: Integer;
  lvProp: PPropInfo;
begin
  if not Assigned (fOnListProperties) then Exit;
  //
  for x := 0 to fList.Count-1 do begin
    //
    lvProp := GetPropInfo (fnObject, fList.Strings[x], []);
    fOnListProperties (0, fnObject, fnGetPropertyItem (fList.Strings[x]), lvProp);
  end;
end;

// Routine: fnListProperties
// Author: M.A.Sargent  Date: 20/10/17  Version: V1.0
//
// Notes:
//
Function tPropertyList.fnListProperties (Const aList: tStrings): Integer;
var
  x: Integer;
  lvOK: tOKVariant;
begin
  fnRaiseOnFalse (Assigned (aList), 'Error: fnListProperties. aList must be Assigned');
  //
  aList.Clear;
  for x := 0 to fList.Count-1 do begin
    //
    lvOK := GetValueByName (fList[x]);
    Case lvOK.OK of
      True: aList.Add (fList[x] + '=' + VarToStr (lvOK.Msg));
      else  aList.Add (fList[x] + '=Unknown');
    end;
  end;
  Result := aList.Count;
end;

// Routine: GetPropertyByName
// Author: M.A.Sargent  Date: 21/04/17  Version: V1.0
//
// Notes:
//
// Routine: GetPropertyByName
// Author: M.A.Sargent  Date: 21/04/17  Version: V1.0
//
// Notes:
//
Function tPropertyList.GetPropertyByName (Const aName: String; Const aRaiseOnNotFound: Boolean): tPropertyItem;
begin
  Result := fnGetPropertyItem (aName, aRaiseOnNotFound);
end;

Function tPropertyList.fnPropertyExists (Const aName: String): Boolean;
begin
  Result := Assigned (GetPropertyByName (aName, False));
end;

end.
