//
// Unit: DynamicPropertiesU
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//         M.A.Sargent        04/06/11           V2.0
//         M.A.Sargent        20/11/17           V3.0
//         M.A.Sargent        12/07/18           V4.0
//
// Notes:
//  V2.0: Moved fnFormName outside of class to be a helper function h_fnFormName
//  V3.0: Updated to allow the use of 3 different types of
//  V4.0: Updated fnCreateID
//
unit DynamicPropertiesU;

interface

Uses Classes, SysUtils, IniFiles, ListPropertyAndLoadU, ListPropertiesU, MASRecordStructuresU, Dialogs,
      MASStringListU, MASCommonU, Forms, StdCtrls, Controls, MAS_MemIniU;

Type
  tDynamicProperties = Class (tObject)
  private
    fIniFile: tCustomIniFile;
  Protected
    fProps: tPropertyList;
    fItemsList: tMASStringList;
    Function fnCreateID (aFormName, aCompName: String): String;
    //
    Function Int_AssignValues (Const aFormName: String; aComponent: tComponent): Integer;

  Public
    Constructor CreateIni (Const aIniFileName: String);
    Destructor Destroy; override;
    //
    Function AssignValues (Const aForm: tCustomForm): Integer; overload;
    Function AssignValues (Const aDataModule: tDataModule): Integer; overload;
    Function AssignValues (Const aForm: tCustomForm; aComponent: tComponent): Integer; overload;
    Function AssignValues (Const aDataModule: tDataModule; aComponent: tComponent): Integer; overload;
    //
    Property IniFile: tCustomIniFile read fIniFile;
    Function IniFileLoadedOK: Boolean;
  end;

  tDynamicControls = Class (tDynamicProperties)
  Private
    Function fnFindParent (Const aForm: tForm; Const aName: String): tWinControl;
  Public
    //
    Function DynamicControls (Const aForm: tForm): Integer;
  end;

  Function h_fnFormName (aFormName: String): String;

implementation

Uses MAS_FormatU;

// Routine: h_fnFormName
// Author: M.A.Sargent  Date: 21/04/17  Version: V1.0
//
// Notes:
//
Function h_fnFormName (aFormName: String): String;
var
  x: Integer;
begin
  if (aFormName = '') then Raise Exception.Create ('Error: fnFormName. aFormName can not be blank');
  // if a duplicate Frame or Form if created Delete append a number FormAddress1, FormAddress2 etc
  // remove numbers so that ini file is scanned for FormAddress only
  for x := Length (aFormName) downto 1 do begin
    if (aFormName [x] in ['0','1','2','3','4','5','6','7','8','9']) then
      Delete (aFormName, x, 1)
    else Break;
  end;
  //
  Result := aFormName;
end;

{ tDynamicProperties }
Constructor tDynamicProperties.CreateIni (Const aIniFileName: String);
begin
  fIniFile   := tMAS_MemIniFile.CreateFromApp (aIniFileName);
  fProps     := tPropertyList.Create;
  fItemsList := tMASStringList.Create;
end;

Function tDynamicProperties.IniFileLoadedOK: Boolean;
begin
  Result := True;  // Default to True, for tIniFile
  if (fIniFile is tMAS_CustomMemIniFile) then
    Result := tMAS_CustomMemIniFile (fIniFile).IniFileLoadedOK;
end;

Destructor tDynamicProperties.Destroy;
begin
  fItemsList.Free;
  fProps.Free;
  fIniFile.Free;
  inherited;
end;

// Routine: fnCreateID
// Author: M.A.Sargent  Date: 21/04/17  Version: V1.0
//
// Notes: Bug fix
//
Function tDynamicProperties.fnCreateID (aFormName, aCompName: String): String;
begin
  Case IsEmpty (aCompName) of
    True: Result := fnTS_Format ('%s',    [h_fnFormName (aFormName)]);
    else  Result := fnTS_Format ('%s_%s', [h_fnFormName (aFormName), aCompName]);
  end;
end;

// Routine: AssignValues
// Author: M.A.Sargent  Date: 21/04/17  Version: V1.0
//
// Notes:
//
Function tDynamicProperties.AssignValues (Const aForm: tCustomForm): Integer;
begin
  Result := AssignValues (aForm, Nil);
end;

Function tDynamicProperties.AssignValues (Const aDataModule: tDataModule): Integer;
begin
  Result := AssignValues (aDataModule, Nil);
end;

Function tDynamicProperties.AssignValues (Const aDataModule: tDataModule; aComponent: tComponent): Integer;
begin
  Result := -1;
  if not Assigned (aDataModule) then Exit;
  Result := Int_AssignValues (aDataModule.Name, aComponent);
end;
Function tDynamicProperties.AssignValues (Const aForm: tCustomForm; aComponent: tComponent): Integer;
begin
  Result := -1;
  if not Assigned (aForm) then Exit;
  Result := Int_AssignValues (aForm.Name, aComponent);
end;

Function tDynamicProperties.Int_AssignValues (Const aFormName: String; aComponent: tComponent): Integer;
var
  lvSection: String;
  x: Integer;
  lvTotal: Integer;
  lvRec: tPropertyItem;
  lvRes: tOKVariant;
  lvPair: tValuePair;
  //
begin
  Result := -1;
  //
  if not IniFileLoadedOK then Exit;
  //
  Case Assigned (aComponent) of
    True: lvSection := fnCreateID (aFormName, aComponent.Name);
    else  lvSection := fnCreateID (aFormName, '');
  End;
 //
  if fIniFile.SectionExists (lvSection) then begin
    // As is assume there will always be more properties than ini file entries
    // loop around the ini file entries and tehn find each property
    fIniFile.ReadSectionValues (lvSection, tStrings (fItemsList));
    if (fItemsList.Count > 0) then begin
      // load the Component properties
      lvTotal := fProps.fnLoadProperties (aComponent);

      for x := 0 to fItemsList.Count-1 do begin
        lvPair := GetValuePair (fItemsList[x]);
        //
        lvRec := fProps.GetPropertyByName (lvPair.Name);
        lvRes := fnAssignProperty (fIniFile, lvSection, lvRec);
        if lvRes.OK then
          fProps.SetValueByName (lvRec.PropertyName, lvRes.Msg);
      end;
    end;
  end;
end;

// Routine: DynamicControls
// Author: M.A.Sargent  Date: 21/04/17  Version: V1.0
//
// Notes:
//
Function tDynamicControls.DynamicControls (Const aForm: tForm): Integer;
var
  x: Integer;
  lvComponent: tComponent;
  lvSection: String;
  lvFormName: String;
  Function IntCreateControl (Const aSection: String): tControl;
  var
    lvStr: String;
  begin
    //
    Result := Nil;
    lvStr := fIniFile.ReadString (aSection, 'ControlType', '');
    if IsEqual (lvStr, 'tButton') then
      Result := tButton.Create (aForm);

    //
    if not Assigned (Result) then Exit;

    lvStr := fIniFile.ReadString (aSection, 'ControlName', '');
    Result.Name := lvStr;
    //
    lvStr := fIniFile.ReadString (aSection, 'ControlParent', '');
    Case (lvStr='') of
      True: Result.Parent := aForm;
      else  Result.Parent := fnFindParent (aForm, lvStr);
    end;
  end;
begin
  Result := -1;
  if not Assigned (aForm) then Exit;
  lvFormName := h_fnFormName (aForm.Name);

  Result := fIniFile.ReadInteger ('Controls', lvFormName, 0);
  if (Result = 0) then Exit;
  //
    // section [Control]
    //          FormName=3
    for x := 1 to Result do begin
      //
      lvSection := fnTS_Format ('Create_%s_%d', [lvFormName, x]);
      //
      lvComponent := IntCreateControl (lvSection);
      if Assigned (lvComponent) then begin

        AssignValues (aForm, lvComponent);
      end;
    end;
end;

// Routine: fnFindParent
// Author: M.A.Sargent  Date: 21/04/17  Version: V1.0
//
// Notes:
//
Function tDynamicControls.fnFindParent (Const aForm: tForm; Const aName: String): tWinControl;
var
  x: Integer;
begin
  Result := aForm;
  if not Assigned (Result) then Exit;
  for x := 0 to aForm.ComponentCount-1 do begin
    if (aForm.Components [x] is tWinControl) then begin
      if IsEqual (aForm.Components [x].Name, aName) then begin
        Result := tWinControl (aForm.Components [x]);
        Break;
      end;
    end;
  end;
end;

end.
