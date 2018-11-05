//
// Unit: ListPropertyAndLoadU
// Author: M.A.Sargent  Date: 01/12/16  Version: V1.0
//         M.A.Sargent        03/01/17           V2.0
//         M.A.Sargent        21/04/17           V3.0
//         M.A.Sargent        13/03/18           V4.0
//         M.A.Sargent        26/07/18           V5.0
//
// Notes:
//  V2.0: Change so that by default the IniFiles existance is not returned as a False if it does not exist
//  V3.0:
//  V4.0: Updated to remove code in fnAssignPropertyFromIni, (Time Systems UK)
//  V5.0: Updated to add a new version of fnAssignPropertyFromIni that will output details of Inifile changes
//
unit ListPropertyAndLoadU;

interface

Uses ListPropertiesU, IniFiles, classes, MASRecordStructuresU, SysUtils, Dialogs, Variants;

  Function fnAssignPropertyFromIni (Const aInifile: String; Const aComponent: tComponent; Const aChkIniExists: Boolean = False): tOKStrRec; overload;
  Function fnAssignPropertyFromIni (Const aIni: tCustomIniFile; Const aComponent: tComponent): tOKStrRec; overload;
  Function fnAssignPropertyFromIni (Const aIni: tCustomIniFile; Const aComponent: tComponent; Const aList: tStrings): tOKStrRec; overload;

  Function fnAssignProperty (Const aIni: tCustomIniFile; Const aSection: String; Const aPropertyItem: tPropertyItem): tOKVariant;

implementation

Uses FormatResultU, MASCommonU, TypInfo;

// Routine: fnAssignProperty
// Author: M.A.Sargent  Date: 21/04/17  Version: V1.0
//
// Notes:
//
Function fnAssignProperty (Const aIni: tCustomIniFile; Const aSection: String; Const aPropertyItem: tPropertyItem): tOKVariant;
begin
  // see if a section exists for the ComponentName
  //
    {TTypeKind = (tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat,
                   tkString, tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString,
                    tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray, tkUString,
                     tkClassRef, tkPointer, tkProcedure {, tkMRecord}

  Result.OK := aIni.ValueExists (aSection, aPropertyItem.PropertyName);
  if Result.OK then begin
    Case aPropertyItem.TypeKind of
      tkInteger:  Result.Msg := aIni.ReadInteger (aSection, aPropertyItem.PropertyName, 0);
      {$IFDEF VER150}
      tkString:   Result.Msg := aIni.ReadString (aSection, aPropertyItem.PropertyName, '');
      tkLString:  Result.Msg := aIni.ReadString (aSection, aPropertyItem.PropertyName, '');
      {$ELSE}
      tkString,
       tkuString: Result.Msg := aIni.ReadString (aSection, aPropertyItem.PropertyName, '');
      {$ENDIF}
      // Currently onlyprocess Boolean values
      tkEnumeration: Case IsEqual (aPropertyItem.PPropInfo^.PropType^.Name, 'Boolean') of
                       True: Result.Msg := aIni.ReadBool (aSection, aPropertyItem.PropertyName, False);
                       else
                     end;
      else Result.OK := False;
    end;
  end;
end;

// Routine: fnAssignPropertyFromIni
// Author: M.A.Sargent  Date: 21/04/17  Version: V1.0
//         M.A.Sargent        13/03/18           V2.0
//         M.A.Sargent        26/07/18           V3.0
//
// Notes:
//  V2.0:
//  V3.0: Add a new version
//
Function fnAssignPropertyFromIni (Const aInifile: String; Const aComponent: tComponent; Const aChkIniExists: Boolean): tOKStrRec;
var
  lvIni: tIniFile;
begin
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}

  if FileExists (aIniFile) then begin
    lvIni := tIniFile.Create (aIniFile);
    Try
      Result := fnAssignPropertyFromIni (lvIni, aComponent);
    Finally
      lvIni.Free;
    End;
  end
  else if aChkIniExists then Result := fnResult ('Ini File not Found: (%s)', [aIniFile]);
end;
Function fnAssignPropertyFromIni (Const aIni: tCustomIniFile; Const aComponent: tComponent): tOKStrRec;
begin
  Result := fnAssignPropertyFromIni (aIni, aComponent, Nil);
end;
Function fnAssignPropertyFromIni (Const aIni: tCustomIniFile; Const aComponent: tComponent; Const aList: tStrings): tOKStrRec;
var
  lvProps:    tPropertyList;
  x:          Integer;
  lvTotal:    Integer;
  lvRec:      tPropertyItem;
  lvSection:  String;
  lvRes:      tOKVariant;
  lvOldVal:   tOKVariant;
  lvCompName: String;
begin
  //
  {$IFDEF VER150}
  Result := fnClear_OKStrRec;
  {$ELSE}
  Result.Clear;
  {$ENDIF}
  Try
    Result := fnResult (Assigned (aComponent), 'Error: fnAssignPropertyFromIni. A Component must be Assigned');
    if Result.OK then begin
      //
      Result := fnResult (Assigned (aIni), 'Error: fnAssignPropertyFromIni. A IniFile object must be Assigned');
      if Result.OK then begin
        //
        lvProps := tPropertyList.Create;
        Try
          // see if a section exists for either Component.Name and then ClassName (
          lvSection := '';
          lvCompName := IfTrue (IsEmpty (aComponent.Name), 'UNKNOWN', aComponent.Name);
          //
          if      aIni.SectionExists (lvCompName) then lvSection := lvCompName
          else if aIni.SectionExists (aComponent.ClassName) then lvSection := aComponent.ClassName;
          // if exists then list component properties
          if (lvSection <> '') then begin
            //
            lvTotal := lvProps.fnLoadProperties (aComponent);
            for x := 0 to lvTotal-1 do begin
              //
              lvRec := lvProps.GetValueById (x);
              lvRes := fnAssignProperty (aIni, lvSection, lvRec);
              if lvRes.OK then begin
                // Output details if a list is Assigned
                if Assigned (aList) then begin
                  lvOldVal := lvProps.GetValueByName (lvRec.PropertyName);
                  if lvOldVal.OK then aList.Add ('IniFile Update to Property ' + lvRec.PropertyName +
                                                  ': Old: ' + VarToStr (lvOldVal.Msg) + ' New: ' + VarToStr (lvRes.Msg));
                end;
                lvProps.SetValueByName (lvRec.PropertyName, lvRes.Msg);
              end
            end;
          end;
        Finally
          lvProps.Free;
        End;
      end;
    end;
  Except
    on e:Exception do
      Result := fnResult ('Error: fnAssignPropertyFromIni. (%s)', [e.Message]);
  End;
end;

end.
