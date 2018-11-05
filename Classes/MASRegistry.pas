//
// Unit: MASRegistry
// Author: M.A.Sargent  Date: 02/11/2003 Version: V1.0
//         M.A.Sargent        17/04/2003          V1.1
//         M.A.Sargent        13/10/2011          V2.0
//         M.A.Sargent        30/07/2012          V3.0
//         M.A.Sargent        02/11/2012          V4.0
//         M.A.Sargent        10/02/2013          V5.0
//         M.A.Sargent        08/03/2013          V6.0
//         M.A.Sargent        04/08/2013          V7.0
//         M.A.Sargent        27/09/2013          V8.0
//         M.A.Sargent        02/10/2013          V9.0
//         M.A.Sargent        02/11/2013          V10.0
//         M.A.Sargent        06/11/2017          V11.0
//         M.A.Sargent        18/04/2018          V12.0
//
// Notes:
// V1.1: Bug fix, in the Destructor DO NOT free the fRegIniFile, just free the
// list that contains the entries
// V2.0: Add Create method to create/open a key below a Forms Reg entry
// V3.0: Add method RegSetListMerge
// V4.0: Fix bug in SaveFormState
// V5.0: Add RegGetFloat and RegSetFloat methods
// V6.0: Fix bug in CreateApplicationKey
// V7.0: Add a Lock and Unlock CriticalSection
// V8.0:
// V9.0:
// V10.0:
// V11.0: Updated tMASThreadRegistry.Lock to be a Function that is successful returns the tMASRegistry as a result
//        So calling Lock programmer should remember to call UnLock
// V12.0: Add method RegSetAddToList
//
unit MASRegistry;

interface

Uses Classes, Registry, SysUtils, Controls, MASStringListU, Forms, MASCommonU,
  MAS_DirectoryU, IdThreadSafe;

Type
  eRegistryError = Class(Exception);

type
  tMASRegistry = Class(tObject)
  Private
    fAppKey: String;
    fList: tMASStringList;
    fRegIniFile: TRegistryIniFile;
    Function FormatKey   (Const aSection, aIdent: String): String;
    Procedure CheckKey   (Const aSection, aIdent: String);
    Function IntFindKey  (Const aKey: String; CreateIt: Boolean): TRegistryIniFile;
    function GetKey      (aKey: String): TRegistryIniFile;
  Public
    Constructor Create; overload; virtual;
    Constructor Create (Const aKey: String); overload;
    // Constructor Create (Const aKey: String); overload; virtual;
    Destructor Destroy; override;
    //
    procedure CreateKey             (Const aKey: String);
    procedure CreateApplicationKey; overload;
    procedure CreateApplicationKey  (Const aKey: String); overload;
    procedure CreateFormKey         (Const aFormName: String);
    procedure SetKey                (Const aKey: String);

    Function  RegGetString_CAK     (Const aKey, aSection, aIdent, aInitial: String; Const CreateKey: Boolean = True): String;
    Function  RegGetString         (Const aSection, aIdent, aInitial: String; Const CreateKey: Boolean = True): String;
    Procedure RegSetString_CAK     (Const aKey, aSection, aIdent, aValue: String);
    Procedure RegSetString         (Const aSection, aIdent, aValue: String);
    //
    Function  RegGetInteger_CAK    (Const aKey, aSection, aIdent: String; aInitial: Integer; Const CreateKey: Boolean = True): Integer;
    Function  RegGetInteger        (const aSection, aIdent: String; aInitial: Integer; Const CreateKey: Boolean = True): Integer;
    Procedure RegSetInteger_CAK    (Const aKey, aSection, aIdent: String; aValue: Integer);
    Procedure RegSetInteger        (const aSection, aIdent: String; aValue: String); overload;
    Procedure RegSetInteger        (const aSection, aIdent: String; aValue: Integer); overload;
    Function  IncrementInteger_CAK (const aKey, aSection, aIdent: String; aInitial: Integer): Integer;
    Function  IncrementInteger     (Const aSection, aIdent: String; aInitial: Integer): Integer;
    //
    Function  RegGetBoolean_CAK    (Const aKey, aSection, aIdent: String; aInitial: Boolean; Const CreateKey: Boolean = True): Boolean;
    Function  RegGetBoolean        (const aSection, aIdent: String; aInitial: Boolean; Const CreateKey: Boolean = True): Boolean;
    Procedure RegSetBoolean_CAK    (Const aKey, aSection, aIdent: String; aValue: Boolean);
    Procedure RegSetBoolean        (const aSection, aIdent: String; aValue: Boolean);
    //
    Function  RegGetFloat          (Const aSection, aIdent: String; aInitial: Double; Const CreateKey: Boolean = True): Double;
    Procedure RegSetFloat          (Const aSection, aIdent: String; aValue: Double);
    //
    Function  RegGetDateTime_CAK   (Const aKey, aSection, aIdent: String; aInitial: tDate; Const CreateKey: Boolean = True): tDate;
    Function  RegGetDateTime       (Const aSection, aIdent: String; aInitial: tDate): tDate;
    Procedure RegSetDateTime_CAK   (Const aKey, aSection, aIdent: String; aValue: tDate);
    Procedure RegSetDateTime       (Const aSection, aIdent: String; aValue: tDate);
    //
    Function  RegListExists        (Const aSection, aIdent: String): Boolean;
    Function  RegGetList           (Const aSection, aIdent: String; aStrings: tStrings): Integer;
    Procedure RegSetList           (Const aSection, aIdent: String; aStrings: tStrings);
    Procedure RegSetAddToList      (Const aSection, aIdent, aValue: String);

    Procedure RegSetListMerge      (Const aSection, aIdent: String; aStrings: tMASStringList);
    Procedure RegEraseSection      (Const aSection, aIdent: String);

    Function  ValueExists          (Const aSection, aIdent: string): Boolean;

    Procedure DeleteKey_CAK        (Const aKey, aSection, aIdent: String);
    Procedure DeleteKey            (Const aSection: String; aKey: String);
    Procedure EraseSection_CAK     (Const aKey, aSection: String);
    Procedure EraseSection         (Const aSection: String);
    procedure RegReadSection       (Const aSection: String; Strings: tStrings);
    procedure RegReadSectionValues (Const aSection: String; Strings: tStrings);
    //
    procedure RestoreFormState (aForm: tForm); overload;
    procedure SaveFormState    (aForm: tForm); overload;
    //
    Property AppKey:            String read fAppKey;
    Property Registry:          TRegistryIniFile read fRegIniFile write fRegIniFile;
    Property Key[aKey: String]: TRegistryIniFile read GetKey;

    Class Procedure RestoreFormState2 (aForm: tForm); overload;
    Class Procedure SaveFormState2 (aForm: tForm); overload;
  end;

  tMASThreadRegistry = Class(tObject)
  Protected
    fCriticalSection: tIdThreadSafe;
    fMASRegistry: tMASRegistry;
    //
    Property MASRegistry: tMASRegistry read fMASRegistry write fMASRegistry;
  public
    Constructor Create; overload; virtual;
    Constructor Create (Const aKey: String); overload;
    Destructor Destroy; override;
    //
    Function Lock: tMASRegistry;
    Procedure Unlock;
  end;

  //
Function h_KeyFormName(Const aName: String): String;
Function h_KeyFormNameCfg(Const aName: String): String;

implementation

{ tMASRegistry }

Const
  cMSGATLEASTONE = 'At Least One of the Section or Ident Must be Supplied';
  cDEFAULT = '\Software';
  // cAPPNAME        = '\Software\%s\%s';
  cKEY_FORMS = 'Forms';
  cKEY_FORMS_CONFIG = 'Config';
  cmsgNOTFOUND = 'Error: Registry Key Has Not Been Created (%s)';
  cmsgMUSTSUPPLY = 'Error: Registry Key Can Not be Blank';

Function h_KeyFormName(Const aName: String): String;
begin
  Result := AppendPath(cKEY_FORMS, aName);
end;

Function h_KeyFormNameCfg(Const aName: String): String;
begin
  Result := AppendPath([cKEY_FORMS, aName, cKEY_FORMS_CONFIG]);
end;

// Routine:
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//
// Notes:
//
Class Procedure tMASRegistry.SaveFormState2 (aForm: tForm);
var
  lvObj: tMASRegistry;
begin
  if not Assigned (aForm) then Exit;
  lvObj := tMASRegistry.Create;
  Try
    lvObj.SaveFormState (aForm);
  Finally
    lvObj.Free;
  End;
end;
Class Procedure tMASRegistry.RestoreFormState2 (aForm: tForm);
var
  lvObj: tMASRegistry;
begin
  if not Assigned (aForm) then Exit;
  lvObj := tMASRegistry.Create;
  Try
    lvObj.RestoreFormState (aForm);
  Finally
    lvObj.Free;
  End;
end;



// Routine:
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//
// Notes:
//
Constructor tMASRegistry.Create;
begin
  fAppKey := '';
  fList := tMASStringList.Create;
  fList.Sorted := True;
  fList.Duplicates := dupError;
end;

Constructor tMASRegistry.Create(Const aKey: String);
begin
  Create;
  CreateApplicationKey(aKey);
end;

{ Constructor tMASRegistry.Create (Const aKey: String);
  begin
  Create;
  fRegIniFile := IntFindKey (aKey, True);
  end; }

// On Destroy, Free the list that contains the Registry Key Entries
destructor tMASRegistry.Destroy;
begin
  fList.Free;
  inherited;
end;

Function tMASRegistry.IntFindKey(Const aKey: String; CreateIt: Boolean): TRegistryIniFile;
var
  Idx: Integer;
begin
  Result := Nil;
  if (aKey <> '') then
  begin
    if fList.Find(aKey, Idx) then
      Result := TRegistryIniFile(fList.Objects[Idx])
    else if CreateIt then
    begin
      Result := TRegistryIniFile.Create(AppendPath(cDEFAULT, aKey));
      fList.AddObject(aKey, Result);
    end;
  end
  else
    Raise eRegistryError.Create(cmsgMUSTSUPPLY);
end;

// Notes: Property will return TRegistryIniFile object, if not found the
// an exception will be raised
function tMASRegistry.GetKey(aKey: String): TRegistryIniFile;
begin
  Result := IntFindKey(aKey, False);
  if Result = nil then
    Raise eRegistryError.CreateFmt(cmsgNOTFOUND, [aKey]);
end;

// Notes: Property Set the tMASRegistry internal TRegistryIniFile ref to be one
// that exists in the list, if not found the an exception will be raised
procedure tMASRegistry.SetKey(Const aKey: String);
begin
  fRegIniFile := IntFindKey(aKey, False);
end;

procedure tMASRegistry.CreateApplicationKey;
begin
  CreateApplicationKey('');
end;

// Updated to Assign the Exe Name to a Property
procedure tMASRegistry.CreateApplicationKey(Const aKey: String);
begin
  fAppKey := fnGetExeName;
  if (aKey = '') then
    CreateKey(fAppKey) { Just AppName }
  else
    CreateKey(AppendPath(fAppKey, aKey)); { And AppName and Identifier }
end;

// Notes:
//
procedure tMASRegistry.CreateFormKey(Const aFormName: String);
var
  lvReg: String;
begin
  lvReg := h_KeyFormNameCfg(aFormName);
  CreateApplicationKey(lvReg);
end;

procedure tMASRegistry.CreateKey(Const aKey: String);
begin
  fRegIniFile := IntFindKey(aKey, True);
end;

// Routine:
// Author: M.A.Sargent  Date: 30/07/13  Version: V1.0
//
// Notes:
//
Function tMASRegistry.RegGetBoolean_CAK(Const aKey, aSection, aIdent: String; aInitial: Boolean; Const CreateKey: Boolean = True): Boolean;
begin
  Self.CreateApplicationKey(aKey);
  Result := RegGetBoolean(aSection, aIdent, aInitial, CreateKey);
end;

Procedure tMASRegistry.RegSetBoolean_CAK(Const aKey, aSection, aIdent: String; aValue: Boolean);
begin
  Self.CreateApplicationKey(aKey);
  RegSetBoolean(aSection, aIdent, aValue);
end;

function tMASRegistry.RegGetBoolean(const aSection, aIdent: String; aInitial: Boolean; Const CreateKey: Boolean): Boolean;
begin
  if CreateKey and not fRegIniFile.ValueExists(aSection, aIdent) then
    RegSetBoolean(aSection, aIdent, aInitial);
  Result := fRegIniFile.ReadBool(aSection, aIdent, aInitial)
end;

procedure tMASRegistry.RegSetBoolean(const aSection, aIdent: String; aValue: Boolean);
begin
  CheckKey(aSection, aIdent);
  fRegIniFile.WriteBool(aSection, aIdent, aValue);
end;

Function tMASRegistry.RegGetDateTime_CAK(Const aKey, aSection, aIdent: String; aInitial: tDate; const CreateKey: Boolean): tDate;
begin
  Self.CreateApplicationKey(aKey);
  Result := RegGetDateTime(aSection, aIdent, aInitial);
end;

function tMASRegistry.RegGetDateTime(Const aSection, aIdent: String; aInitial: tDate): tDate;
begin
  Result := fRegIniFile.ReadDate(aSection, aIdent, aInitial)
end;

procedure tMASRegistry.RegSetDateTime_CAK(Const aKey, aSection, aIdent: String; aValue: tDate);
begin
  Self.CreateApplicationKey(aKey);
  RegSetDateTime(aSection, aIdent, aValue);
end;

procedure tMASRegistry.RegSetDateTime(Const aSection, aIdent: String; aValue: tDate);
begin
  CheckKey(aSection, aIdent);
  fRegIniFile.WriteDate(aSection, aIdent, aValue)
end;

function tMASRegistry.RegGetString_CAK(Const aKey, aSection, aIdent, aInitial: String; const CreateKey: Boolean): String;
begin
  Self.CreateApplicationKey(aKey);
  Result := RegGetString(aSection, aIdent, aInitial, CreateKey);
end;

function tMASRegistry.RegGetString(Const aSection, aIdent, aInitial: String; Const CreateKey: Boolean): String;
begin
  if CreateKey and not fRegIniFile.ValueExists(aSection, aIdent) then
    RegSetString(aSection, aIdent, aInitial);
  Result := fRegIniFile.ReadString(aSection, aIdent, aInitial)
end;

procedure tMASRegistry.RegSetString_CAK(Const aKey, aSection, aIdent, aValue: String);
begin
  Self.CreateApplicationKey(aKey);
  RegSetString(aSection, aIdent, aValue);
end;

procedure tMASRegistry.RegSetString(Const aSection, aIdent, aValue: String);
begin
  CheckKey(aSection, aIdent);
  fRegIniFile.WriteString(aSection, aIdent, aValue)
end;

// Routine:
// Author: M.A.Sargent  Date: 30/07/13  Version: V1.0
//
// Notes:
//
Function tMASRegistry.RegGetInteger_CAK(Const aKey, aSection, aIdent: String; aInitial: Integer; const CreateKey: Boolean): Integer;
begin
  Self.CreateApplicationKey(aKey);
  Result := RegGetInteger(aSection, aIdent, aInitial, CreateKey);
end;

function tMASRegistry.RegGetInteger(const aSection, aIdent: String; aInitial: Integer; Const CreateKey: Boolean = True): Integer;
begin
  if CreateKey and not fRegIniFile.ValueExists(aSection, aIdent) then
    RegSetInteger(aSection, aIdent, aInitial);
  Result := fRegIniFile.ReadInteger(aSection, aIdent, aInitial)
end;

Procedure tMASRegistry.RegSetInteger_CAK(Const aKey, aSection, aIdent: String; aValue: Integer);
begin
  Self.CreateApplicationKey(aKey);
  RegSetInteger(aSection, aIdent, aValue);
end;

Procedure tMASRegistry.RegSetInteger(const aSection, aIdent: String; aValue: String);
begin
  RegSetInteger(aSection, aIdent, StrToInt(aValue));
end;

procedure tMASRegistry.RegSetInteger(const aSection, aIdent: String; aValue: Integer);
begin
  CheckKey(aSection, aIdent);
  fRegIniFile.WriteInteger(aSection, aIdent, aValue);
end;

Function tMASRegistry.IncrementInteger_CAK(Const aKey, aSection, aIdent: String; aInitial: Integer): Integer;
begin
  Self.CreateApplicationKey(aKey);
  Result := IncrementInteger(aSection, aIdent, aInitial);
end;

// Notes: Add a function to increment a registry value and then return and save it
function tMASRegistry.IncrementInteger(const aSection, aIdent: String; aInitial: Integer): Integer;
begin
  Result := (RegGetInteger(aSection, aIdent, aInitial) + 1);
  RegSetInteger(aSection, aIdent, Result);
end;

Procedure tMASRegistry.CheckKey(Const aSection, aIdent: String);
begin
  if (aSection = '') and (aIdent = '') then
    Raise eRegistryError.Create(cMSGATLEASTONE);
end;

Function tMASRegistry.FormatKey (Const aSection, aIdent: String): String;
begin
  if (aSection <> '') and (aIdent <> '') then
    Result := Format('%s\%s', [aSection, aIdent])
  else if (aSection = '') then
    Result := aIdent
  else if (aIdent = '') then
    Result := aSection;
  if (Result = '') then
    Raise eRegistryError.Create(cMSGATLEASTONE);
end;

// Routine: RegSetListMerge
// Author: M.A.Sargent  Date: 30/07/12  Version: V1.0
//
// Notes: Updated to be a function, can be used to count items
//
Function tMASRegistry.RegListExists (Const aSection, aIdent: String): Boolean;
begin
  Result := (RegGetList (aSection, aIdent, Nil) > 0);
end;

Function tMASRegistry.RegGetList (Const aSection, aIdent: String; aStrings: tStrings): Integer;
var
  lvSection: String;
begin
  lvSection := FormatKey (aSection, aIdent);
  Result := 0;
  if Assigned (aStrings) then aStrings.Clear;
  //
  while fRegIniFile.ValueExists(lvSection, Format('ID_%d', [Result + 1])) do begin
    //
    if Assigned (aStrings) then aStrings.Add(fRegIniFile.ReadString(lvSection, Format('ID_%d', [Result + 1]), ''));
    Inc(Result);
  end;
end;

Procedure tMASRegistry.RegSetList (Const aSection, aIdent: String; aStrings: tStrings);
var
  x: Integer;
  lvSection: String;
begin
  lvSection := FormatKey (aSection, aIdent);
  with aStrings do begin
    fRegIniFile.EraseSection(lvSection);
    for x := 0 to Count - 1 do
      fRegIniFile.WriteString(lvSection, Format('ID_%d', [x + 1]), aStrings[x]);
  end;
end;

Procedure tMASRegistry.RegSetAddToList (Const aSection, aIdent, aValue: String);
var
  x: Integer;
  lvSection: String;
begin
  lvSection := FormatKey (aSection, aIdent);
  x := RegGetList (aSection, aIdent, Nil);
  //
  fRegIniFile.WriteString (lvSection, Format('ID_%d', [x + 1]), aValue);
end;

// Routine: RegSetListMerge
// Author: M.A.Sargent  Date: 30/07/12  Version: V1.0
//
// Notes:
//
Procedure tMASRegistry.RegSetListMerge(Const aSection, aIdent: String; aStrings: tMASStringList);
var
  x: Integer;
  lvSection: String;
  lvList: tMASStringList;
begin
  lvList := tMASStringList.CreateSorted;
  Try
    RegGetList(aSection, aIdent, lvList);
    aStrings.Merge(lvList);

    lvSection := FormatKey (aSection, aIdent);
    with aStrings do begin
      fRegIniFile.EraseSection (lvSection);
      for x := 0 to Count - 1 do
        fRegIniFile.WriteString (lvSection, Format('ID_%d', [x + 1]),
          Strings[x]);
    end;
  Finally
    lvList.Free;
  end;
end;

procedure tMASRegistry.RegEraseSection(const aSection, aIdent: String);
var
  lvSection: String;
begin
  lvSection := FormatKey (aSection, aIdent);
  fRegIniFile.EraseSection (lvSection);
end;

procedure tMASRegistry.RegReadSection(const aSection: String; Strings: tStrings);
begin
  CheckKey (aSection, '');
  fRegIniFile.ReadSection (aSection, Strings);
end;

procedure tMASRegistry.RegReadSectionValues(const aSection: String; Strings: tStrings);
begin
  CheckKey (aSection, '');
  fRegIniFile.ReadSectionValues (aSection, Strings);
end;

// Routine: RestoreFormState
// Author: M.A.Sargent  Date: 04/03/06  Version: V1.0
//
// Notes:
//
Procedure tMASRegistry.RestoreFormState(aForm: tForm);
var
  lvSize: Boolean;
begin
  CreateApplicationKey;
  with aForm do
  begin
    lvSize := (aForm.BorderStyle = bsSizeable);
    Case RegGetInteger(h_KeyFormName(Name), 'State', 2) of
      0: WindowState := wsMaximized;
    else begin
        Top  := RegGetInteger (h_KeyFormName(Name), 'Top', Top);
        Left := RegGetInteger (h_KeyFormName(Name), 'Left', Left);
        if lvSize then begin
          Width  := RegGetInteger (h_KeyFormName(Name), 'Width', Width);
          Height := RegGetInteger (h_KeyFormName(Name), 'Height', Height);
        end;
        WindowState := wsNormal;
      end;
    end;
  end;
end;

// Routine: SaveFormState
// Author: M.A.Sargent  Date: 02/11/12  Version: V1.0
//
// Notes: Bug fix in the wsMaximized case section
//
Procedure tMASRegistry.SaveFormState(aForm: tForm);
begin
  CreateApplicationKey;
  with aForm do begin
    Case WindowState of
      wsMaximized: RegSetInteger (h_KeyFormName (Name), 'State', 0);
      wsNormal: begin
          { Don't save positions / size of minimized windows! Leave as previous }
          RegSetInteger (h_KeyFormName (Name), 'State', 2);
          RegSetInteger (h_KeyFormName (Name), 'Top', Top);
          RegSetInteger (h_KeyFormName (Name), 'Left', Left);
          RegSetInteger (h_KeyFormName (Name), 'Width', Width);
          RegSetInteger (h_KeyFormName (Name), 'Height', Height);
        end;
    end;
  end;
end;

// Routine: DeleteKey_CAK & DeleteKey
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//
// Notes:
//
Procedure tMASRegistry.DeleteKey_CAK (Const aKey, aSection, aIdent: String);
begin
  CreateApplicationKey (aKey);
  DeleteKey (aSection, aIdent);
end;
Procedure tMASRegistry.DeleteKey (Const aSection: String; aKey: String);
begin
  CheckKey(aSection, aKey);
  fRegIniFile.DeleteKey(aSection, aKey);
end;

// Routine: ValueExists
// Author: M.A.Sargent  Date: 24/06/11  Version: V1.0
//
// Notes:
//
function tMASRegistry.ValueExists(Const aSection, aIdent: string): Boolean;
begin
  CheckKey(aSection, aIdent);
  Result := fRegIniFile.ValueExists(aSection, aIdent);
end;

// Routine: RegGetFloat and RegSetFloat
// Author: M.A.Sargent  Date: 10/02/13  Version: V1.0
//
// Notes:
//
Function tMASRegistry.RegGetFloat(Const aSection, aIdent: String; aInitial: Double; Const CreateKey: Boolean): Double;
begin
  if CreateKey and not fRegIniFile.ValueExists(aSection, aIdent) then
    RegSetFloat(aSection, aIdent, aInitial);
  Result := fRegIniFile.ReadFloat(aSection, aIdent, aInitial)
end;

Procedure tMASRegistry.RegSetFloat(Const aSection, aIdent: String; aValue: Double);
begin
  CheckKey(aSection, aIdent);
  fRegIniFile.WriteFloat(aSection, aIdent, aValue);
end;

procedure tMASRegistry.EraseSection_CAK(Const aKey, aSection: String);
begin
  CreateApplicationKey(aKey);
  EraseSection(aSection);
end;

procedure tMASRegistry.EraseSection(Const aSection: String);
begin
  CheckKey(aSection, '');
  fRegIniFile.EraseSection(aSection);
end;

{ tMASThreadRegistry }

Constructor tMASThreadRegistry.Create;
begin
  Inherited;
  fCriticalSection := tIdThreadSafe.Create;
  fMASRegistry := tMASRegistry.Create;
end;

constructor tMASThreadRegistry.Create(Const aKey: String);
begin
  Create;
  MASRegistry.CreateApplicationKey(aKey);
end;

destructor tMASThreadRegistry.Destroy;
begin
  Lock;
  Try
    fMASRegistry.Free;
    inherited Destroy;
  Finally
    Unlock;
    fCriticalSection.Free;
  end;
end;

Function tMASThreadRegistry.Lock: tMASRegistry;
begin
  fCriticalSection.Lock;
  Result := fMASRegistry;
end;

procedure tMASThreadRegistry.Unlock;
begin
  fCriticalSection.Unlock;
end;

end.
