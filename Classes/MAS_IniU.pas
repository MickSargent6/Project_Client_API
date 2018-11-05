//
// Unit: MAS_IniU
// Author: M.A.Sargent  Date: ??/??/06  Version: V1.0
//         M.A.Sargent        27/01/07           V2.0
//         M.A.Sargent        16/01/08           V3.0
//         M.A.Sargent        27/01/09           V4.0
//         M.A.Sargent        17/05/11           V5.0
//         M.A.Sargent        16/06/12           V6.0
//         M.A.Sargent        05/02/13           V7.0
//         M.A.Sargent        22/04/13           V8.0
//         M.A.Sargent        03/09/13           V9.0
//         M.A.Sargent        05/06/14           V10.0
//         M.A.Sargent        17/11/14           V10.0 (O2-Shuttle)
//         M.A.Sargent        27/05/15           V11.0
//         M.A.Sargent        14/10/15           V11.0 (O2-Shuttle)
//         M.A.Sargent        05/01/17           V12.0
//         M.A.Sargent        05/01/17           V13.0
//         M.A.Sargent        01/09/17           V14.0
//
//         M.A.Sargent        05/09/17           V16.0
//
// Notes:
//  V2.0: Update the Setup Method
//  v3.0: Added method CountSectionItems
//  V4.0: ReadString & WriteString Added to Class, can create an entry if needed
//  V5.0: ReadInteger & WriteInteger Added to Class, can create an entry if needed
//  V6.0: Add method ReadSectionValues
//        Added helper routines fnGetIniValueAsBoolean
//                              fnGetIniValueAsString
//                              fnGetIniValueAsInteger
//  V7.0: Updated to add a Float method
//  V8.0: Added Function  ReadSection
//  V9.0: Added a new constructor CreateFromApp
// V10.0: Added 3 more helpers classes
// V10.0: Add date methods ReadDate and WriteDate
// V11.0: Updated to maker the calls to Application.ExeName thread safe
// V11.0: Updated to add ValueExists Function
// V12.0: Add helper function h_fnGetSectionName
// V13.0: Add functions h_fnIsJustFileName & h_fnJustFileName
// V14.0: Add helper function h_fnIniFileNameFromModuleName
// V15.0: Added another Constructor for Time System Ltd CreateFromDir (
// V16.0: Add method IniAddToList to tMASIni
//
unit MAS_IniU;

interface

Uses IniFiles, SysUtils, Classes, MASRecordStructuresU;

Type
  tMASIni = Class (tObject)
  private
    fCreateDir: Boolean;
    fIniFile:   tIniFile;
    fFileName:  String;
    Procedure SetFileName (Const Value: String);
    Procedure IntFreeIniFile;
  Public
    Constructor Create; reintroduce; overload; virtual;
    Constructor Create (Const aFileName: String; Const Create: Boolean = True); overload; virtual;
    Constructor Create (Const aDirectory, aFileName: String; Const Create: Boolean = True); overload; virtual;
    Constructor CreateFromApp (Const aFileName: String; Const Create: Boolean = True); overload; virtual;
    Constructor CreateFromApp (Const Create: Boolean = True); overload; virtual;
    Constructor CreateFromDir (Const aDirName: String; Const Create: Boolean = True);
    Constructor CreateFromModule (Const aModule: HMODULE);
    // Add a Create from Module Name Constructor
    Destructor Destroy; override;
    //
    Procedure SetUp (Const aFileName: String; Const Create: Boolean = True); overload;
    Procedure SetUp (Const aDirectory, aFileName: String; Const Create: Boolean = True); overload;
    Property IniFile: tIniFile read fIniFile;
    //
    Procedure Flush;
    //
    Procedure EraseFileContents;
    Function SectionExists (Const aSection: String): Boolean;
    Function CountSectionItems(const aSection: String): Integer;
    Function ValueExists (Const Section, Ident: string): Boolean;
    //
    Function  IniGetList   (Const aSection: String; Strings: tStrings): Integer;
    Procedure IniSetList   (Const aSection: String; Strings: tStrings);
    Function  IniAddToList (Const aSection: String; aValue: String; Const aAllowDuplicates: Boolean = False): Integer;
    //
    Procedure RegEraseSection (Const aSection: String);
    //
    Function ReadSection       (Const Section: string; var aList: TStrings): Integer;
    Function ReadSectionValues (Const Section: string; var aList: TStrings): Integer;
    Function ReadJustSectionValues (Const aSection: String; var aList: TStrings): tOKStrRec;
    //
    Function ReadString    (Const Section, Ident, Default: string; Const Create: Boolean = False): string;
    Procedure WriteString  (Const Section, Ident, Value: String);
    //
    Function ReadInteger   (Const Section, Ident: String; const Default: Integer; const Create: Boolean = False): Integer;
    Procedure WriteInteger (Const Section, Ident: String; const Value: Integer);
    //
    Function ReadBoolean   (Const Section, Ident: String; const Default: Boolean; const Create: Boolean = False): Boolean;
    Procedure WriteBoolean (Const Section, Ident: String; Const Value: Boolean);
    //
    Function ReadFloat     (Const Section, Ident: String; Const Default: Double; Const Create: Boolean = False): Double;
    Procedure WriteFloat   (Const Section, Ident: String; Const Value: Double);
    //
    Function ReadDate      (Const Section, Ident: String; Const Default: tDateTime; Const Create: Boolean): tDateTime;
    Procedure WriteDate    (Const Section, Ident: String; Const Value: tDateTime);
    //
    Property FileName:  String  read fFileName  write SetFileName;
    Property CreateDir: Boolean read fCreateDir write fCreateDir;
  end;

  Function fnGetIniValueAsBoolean (aList: tStrings; Const aIdent: String; Const aDefault: Boolean = True): Boolean;
  Function fnGetIniValueAsString (aList: tStrings; Const aIdent: String; Const aDefault: String = ''): String;
  Function fnGetIniValueAsInteger (aList: tStrings; Const aIdent: String; Const aDefault: Integer = -1): Integer;
  //
  //
  Function h_fnGetIniValueAsBoolean (Const aIniFile, aSection, aIdent: String; Const aDefault: Boolean = True): Boolean;
  Function h_fnGetIniValueAsString (Const aIniFile, aSection, aIdent: String; Const aDefault: String = ''): String;
  Function h_fnGetIniValueAsInteger (Const aIniFile, aSection, aIdent: String; Const aDefault: Integer = -1): Integer;
  //
  Function h_fnGetSectionName (Const aComponent: tComponent): String; overload;
  Function h_fnGetSectionName (Const aSectionName: String; Const aComponent: tComponent): String; overload;
  Function h_fnIsJustFileName (Const aFileName: String): Boolean;
  Function h_fnJustFileName   (Const aFileName: String): String;

  //
  Function h_fnReadSection    (Const aIniFile, aSection: String; aStrings: tStrings): Integer;
  Function h_fnIniGetList     (Const aIniFile, aSection: String; aStrings: tStrings): Integer;
  //
  //
  //
  Function h_fnIniFileNameFromAppName: String; overload;
  Function h_fnIniFileNameFromAppName (Const aDir: String): String; overload;
  Function h_fnIniFileNameFromAppName2: tMASIni;
  //
  Function h_fnIniFileNameFromAppPath (Const aFileName: String): String; overload;
  Function h_fnIniFileNameFromAppPath (Const aDir, aFileName: String): String; overload;
  Function h_fnIniFileNameFromAppPath2 (Const aFileName: String): tMASIni;
  //
  Function h_fnIniFileNameFromModuleName (Const aDir: String): String; overload;
  Function h_fnIniFileNameFromModuleName (Const aUseAppDir: Boolean = False): String; overload;
  Function h_fnIniFileNameFromModuleName2 (Const aDir: String): tMASIni; overload;
  Function h_fnIniFileNameFromModuleName2 (Const aUseAppDir: Boolean = False): tMASIni; overload;
  //

implementation

Uses MAS_DirectoryU, Forms, FormatResultU, MASCommonU, TS_SystemVariablesU, MAS_ConstsU, MAS_FormatU;

// Routine:
// Author: M.A.Sargent  Date: 02/06/12  Version: V1.0
//
// Notes:
//
Function fnGetIniValueAsBoolean (aList: tStrings; Const aIdent: String; Const aDefault: Boolean): Boolean;
begin
  Result := StrToBoolDef (fnGetIniValueAsString (aList, aIdent), aDefault);
end;
Function fnGetIniValueAsInteger (aList: tStrings; Const aIdent: String; Const aDefault: Integer): Integer;
begin
  Result := StrToIntDef (fnGetIniValueAsString (aList, aIdent), aDefault);
end;
Function fnGetIniValueAsString (aList: tStrings; Const aIdent: String; Const aDefault: String): String;
var
  x: Integer;
begin
  Result := aDefault;
  if not Assigned (aList) then Exit;
  x := aList.IndexOfName (aIdent);
  if (x<>-1) then Result := aList.ValueFromIndex [x];
end;

// Routine: h_fnGetIniValueAsBoolean,  h_fnGetIniValueAsString & h_fnGetIniValueAsInteger
// Author: M.A.Sargent  Date: 02/06/12  Version: V1.0
//
// Notes:
//
Function Int_Create_ (Const aIniFile: String): tMASIni;
begin
  Case h_fnIsJustFileName (aIniFile) of
    True: Result := tMASIni.CreateFromApp (aIniFile);
    else  Result := tMASIni.Create (aIniFile, False);
  end;
end;

Function h_fnGetIniValueAsBoolean (Const aIniFile, aSection, aIdent: String; Const aDefault: Boolean = True): Boolean;
var
  lvIni: tMASIni;
begin
  lvIni := Int_Create_ (aIniFile);
  Try
    Result := lvIni.ReadBoolean (aSection, aIdent, aDefault);
  Finally
    lvIni.Free;
  end;
end;
Function h_fnGetIniValueAsString (Const aIniFile, aSection, aIdent: String; Const aDefault: String = ''): String;
var
  lvIni: tMASIni;
begin
  lvIni := Int_Create_ (aIniFile);
  Try
    Result := lvIni.ReadString (aSection, aIdent, aDefault);
  Finally
    lvIni.Free;
  end;
end;
Function h_fnGetIniValueAsInteger (Const aIniFile, aSection, aIdent: String; Const aDefault: Integer = -1): Integer;
var
  lvIni: tMASIni;
begin
  lvIni := Int_Create_ (aIniFile);
  Try
    Result := lvIni.ReadInteger (aSection, aIdent, aDefault);
  Finally
    lvIni.Free;
  end;
end;

// Routine: h_fnGetSectionName
// Author: M.A.Sargent  Date: 05/01/17  Version: V1.0
//
// Notes:
//
Function h_fnGetSectionName (Const aComponent: tComponent): String;
begin
  Result := h_fnGetSectionName ('', aComponent);
end;
Function h_fnGetSectionName (Const aSectionName: String; Const aComponent: tComponent): String;
begin
  Result := '';
  if (aSectionName <> '') then Result := aSectionName
  else if Assigned (aComponent) then begin
    if  (aComponent.Name <> '') then
         Result := aComponent.Name
    else Result := aComponent.ClassName;
  end;
  //
  if (Result = '') then Raise Exception.Create ('Error: h_fnGetSectionName. Section Name is Blank');
end;

// Routine: h_fnIsJustFileName & h_fnJustFileName
// Author: M.A.Sargent  Date: 05/01/17  Version: V1.0
//
// Notes: Should be OK, extractfilepath on just afilename return an empty string
//
Function h_fnIsJustFileName (Const aFileName: String): Boolean;
begin
  Result := (ExtractFilePath (aFileName) = '');
end;

Function h_fnJustFileName (Const aFileName: String): String;
begin
  Result := ExtractFileName (aFileName);
end;

// Routine: h_fnReadSection & h_fnIniGetList
// Author: M.A.Sargent  Date: 26/09/18  Version: V1.0
//
// Notes:
//
Function h_fnReadSection (Const aIniFile, aSection: String; aStrings: tStrings): Integer;
var
  lvIni: tMASIni;
begin
  Result := -1;
  if not Assigned (aStrings) then Exit;
  //
  lvIni := Int_Create_ (aIniFile);
  Try
    Result := lvIni.ReadSection (aSection, aStrings);
  Finally
    lvIni.Free;
  end;
end;
Function h_fnIniGetList (Const aIniFile, aSection: String; aStrings: tStrings): Integer;
var
  lvIni: tMASIni;
begin
  Result := -1;
  if not Assigned (aStrings) then Exit;
  //
  lvIni := Int_Create_ (aIniFile);
  Try
    Result := lvIni.IniGetList (aSection, aStrings);
  Finally
    lvIni.Free;
  end;
end;

{ tMagInit }

Constructor tMASIni.Create;
begin
  Inherited;
end;

Constructor tMASIni.Create (Const aDirectory, aFileName: String; Const Create: Boolean);
begin
  Inherited Create;
  SetUp (aDirectory, aFilename, Create);
end;

constructor tMASIni.Create (Const aFileName: String; Const Create: Boolean);
begin
  Inherited Create;
  Setup (aFileName, Create);
end;

// Routine: CreateFromApp
// Author: M.A.Sargent  Date: 10/03/13  Version: V1.0
//
// Notes:
//
Constructor tMASIni.CreateFromApp (Const Create: Boolean);
var
  lvFileName: String;
begin
  lvFileName := fnTS_ExeName;
  lvFileName := ChangeFileExt (lvFileName, cFILE_EXTN_INI);
  CreateFromApp (lvFileName, Create);
end;

Constructor tMASIni.CreateFromApp (Const aFileName: String; Const Create: Boolean);
begin
  Self.Create;
  SetUp (fnTS_AppPath, aFilename, Create);
end;

// Routine: CreateFromDir
// Author: M.A.Sargent  Date: 13/03/18  Version: V1.0
//
// Notes:
//
Constructor tMASIni.CreateFromDir (Const aDirName: String; Const Create: Boolean = True);
var
  lvFileName: String;
  lvPath: String;
begin
  Case DirectoryExists (aDirName) of
    True: lvPath := aDirName;
    else  lvPath := fnTS_AppPath;
  end;
  //
  lvFileName := ChangeFileExt (fnTS_ExeName, cFILE_EXTN_INI);

  Self.Create;
  SetUp (lvPath, lvFileName, Create);
end;

Constructor tMASIni.CreateFromModule (Const aModule: HMODULE);
begin
  Create (ChangeFileExt (GetModuleName (aModule), cFILE_EXTN_INI));
end;

Procedure tMASIni.SetUp (Const aDirectory, aFileName: String; Const Create: Boolean);
var
  lvFullPath: String;
begin
  lvFullPath := AppendPath (aDirectory, aFileName);
  SetUp (lvFullPath , Create);
end;

procedure tMASIni.SetUp (Const aFileName: String; const Create: Boolean);
begin
  CreateDir := Create;
  FileName := aFileName;
end;

destructor tMASIni.Destroy;
begin
  IntFreeIniFile;
  inherited;
end;

Procedure tMASIni.IntFreeIniFile;
begin
  if not Assigned (fIniFile) then Exit;
  fIniFile.UpdateFile;
  FreeAndNil (fIniFile);
end;

Procedure tMASIni.Flush;
begin
  if not Assigned (fIniFile) then Exit;
  fIniFile.UpdateFile;
end;

procedure tMASIni.SetFileName (Const Value: String);
begin
  if (fFileName = Value) then Exit;
  IntFreeIniFile;
  fFileName := Value;
  if not fnCheckDirectory (fFileName) then
    Raise Exception.CreateFmt ('Error: Directory could not be Created (%s)', [fFileName]);
  fIniFile := tIniFile.Create (fFileName);
end;

//
// Notes: MAS 21/07/03 Append Number to Ident
Function tMASIni.IniGetList (Const aSection: String; Strings: tStrings): Integer;
begin
  Result := 0;
  with Strings do begin
    Clear;
    while fIniFile.ValueExists (aSection, fnTS_Format ('Item%d', [Result+1])) do begin
      Add (fIniFile.ReadString (aSection, fnTS_Format ('Item%d', [Result+1]), ''));
      Inc (Result);
    end;
  end;
end;

// Notes: MAS 21/07/03 Append Number to Ident
Procedure tMASIni.IniSetList (Const aSection: String; Strings: tStrings);
var
  x: Integer;
begin
  with Strings do begin
    fIniFile.EraseSection (aSection);
    for x := 0 to Count-1 do
      fIniFile.WriteString (aSection, fnTS_Format ('Item%d', [x+1]), Strings[x]);
  end;
end;

// Routine: IniAddToList
// Author: M.A.Sargent  Date: 05/09/18  Version: V1.0
//
// Notes:
//
Function tMASIni.IniAddToList (Const aSection: String; aValue: String; Const aAllowDuplicates: Boolean): Integer;
var
  lvList: tStrings;
begin
  lvList := tStringList.Create;
  Try
    Result := IniGetList (aSection, lvList);
    Case aAllowDuplicates of
      True: fIniFile.WriteString (aSection, fnTS_Format ('Item%d', [Result+1]), aValue);  // Add regardless
      else begin
        if (lvList.IndexOf (aValue) = cMC_NOT_FOUND) then                         // Only Add if not present
          fIniFile.WriteString (aSection, fnTS_Format ('Item%d', [Result+1]), aValue);
      end;
    end;
  Finally
    lvList.Free;
  end;
end;

// Notes: Added to allow a section to be completly removed
Procedure tMASIni.RegEraseSection (Const aSection: String);
begin
  fIniFile.EraseSection (aSection);
end;

procedure tMASIni.EraseFileContents;
var
  lvList: tStringList;
  x: Integer;
begin
  lvList := tStringList.Create;
  Try
    fIniFile.ReadSections (lvList);
    for x := 0 to lvList.Count-1 do
      RegEraseSection (lvList.Strings[x]);
  Finally
    lvList.Free;
  end;
end;

function tMASIni.SectionExists (Const aSection: String): Boolean;
begin
  Result := Assigned (fIniFile);
  if Result then
    Result := fIniFile.SectionExists (aSection);
end;

// Routine: ValueExists
// Author: M.A.Sargent  Date: 14/10/15  Version: V1.0
//
// Notes:
//
Function tMASIni.ValueExists (Const Section, Ident: string): Boolean;
begin
  Result := False;
  if not Assigned (fIniFile) then Exit;
  //
  Result := fIniFile.ValueExists (Section, Ident);
end;

// Routine: CountSectionItems
// Author: M.A.Sargent  Date: 16/01/08  Version: V1.0
//
// Notes:
//
function tMASIni.CountSectionItems (Const aSection: String): Integer;
var
  lvList: tStringList;
begin
  Result := 0;
  if not Assigned (fIniFile) then Exit;
  lvList := tStringList.Create;
  Try
    fIniFile.ReadSection (aSection, lvList);
    Result := lvList.Count;
  Finally
    lvList.Free;
  end;
end;

// Routine: ReadString
// Author: M.A.Sargent  Date: 27/01/09  Version: V1.0
//
// Notes: ReadString Added to Class, can create an entry if needed
//
function tMASIni.ReadString (Const Section, Ident, Default: string; Const Create: Boolean): string;
begin
  if not Assigned (fIniFile) then Exit;
  if Create and NOT fIniFile.ValueExists (Section, Ident) then
    WriteString (Section, Ident, Default);
  // Now Read as Normal
  Result := fIniFile.ReadString (Section, Ident, Default);
end;

// Routine: WriteString
// Author: M.A.Sargent  Date: 27/01/09  Version: V1.0
//
// Notes:
//
procedure tMASIni.WriteString (Const Section, Ident, Value: String);
begin
  if not Assigned (fIniFile) then Exit;
  fIniFile.WriteString (Section, Ident, Value);
end;

// Routine: ReadString
// Author: M.A.Sargent  Date: 27/01/09  Version: V1.0
//
// Notes: ReadString Added to Class, can create an entry if needed
//
function tMASIni.ReadInteger (Const Section, Ident: String; Const Default: Integer; Const Create: Boolean): Integer;
begin
  Result := 0;
  if not Assigned (fIniFile) then Exit;
  if Create and NOT fIniFile.ValueExists (Section, Ident) then
    WriteInteger (Section, Ident, Default);
  // Now Read as Normal
  Result := fIniFile.ReadInteger (Section, Ident, Default);
end;

// Routine: WriteInteger
// Author: M.A.Sargent  Date: 17/05/11  Version: V1.0
//
// Notes:
//
procedure tMASIni.WriteInteger (Const Section, Ident: String; Const Value: Integer);
begin
  if not Assigned (fIniFile) then Exit;
  fIniFile.WriteInteger (Section, Ident, Value);
end;

// Routine: ReadBoolean
// Author: M.A.Sargent  Date: 17/05/11  Version: V1.0
//
// Notes:
//
function tMASIni.ReadBoolean (Const Section, Ident: String; const Default: Boolean; const Create: Boolean): Boolean;
begin
  Result := False;
  if not Assigned (fIniFile) then Exit;
  if Create and NOT fIniFile.ValueExists (Section, Ident) then
    WriteBoolean (Section, Ident, Default);
  // Now Read as Normal
  Result := fIniFile.ReadBool (Section, Ident, Default);
end;

// Routine: WriteBoolean
// Author: M.A.Sargent  Date: 17/05/11  Version: V1.0
//
// Notes:
//
procedure tMASIni.WriteBoolean (Const Section, Ident: String; Const Value: Boolean);
begin
  if not Assigned (fIniFile) then Exit;
  fIniFile.WriteBool (Section, Ident, Value);
end;

// Routine: ReadSection and ReadSectionValues
// Author: M.A.Sargent  Date: 16/06/12  Version: V1.0
//
// Notes:
//
Function tMASIni.ReadSection (Const Section: string; var aList: TStrings): Integer;
begin
  Case Assigned (aList) of
    True: aList.Clear;
    else  aList := tStringList.Create;
  end;
  fIniFile.ReadSection (Section, aList);
  Result := aList.Count;
end;

Function tMASIni.ReadSectionValues (Const Section: string; var aList: TStrings): Integer;
begin
  Case Assigned (aList) of
    True: aList.Clear;
    else  aList := tStringList.Create;
  end;
  fIniFile.ReadSectionValues (Section, aList);
  Result := aList.Count;
end;

Function tMASIni.ReadJustSectionValues (Const aSection: String; var aList: TStrings): tOKStrRec;
var
  x: Integer;
begin
  Result := fnResult (Assigned (aList), 'Error: aList must be Assigned ');
  if not Result.OK then Exit;
  //
  Result := fnResult (SectionExists (aSection), 'Error: Section %s Does Not Exist', [aSection]);
  if Result.OK then begin
    ReadSectionValues (aSection, aList);
    for x := aList.Count-1 downto 0 do begin
      // Ignore Commented Lines
      Case (Copy (aList.Strings[x], 1, 1) = '#') of
        True: aList.Delete (x);
        else aList.Strings[x] := GetValuePair (aList.Strings[x]).Value
      end;
    end;
  end;
end;

// Routine: ReadFloat
// Author: M.A.Sargent  Date: 05/02/13  Version: V1.0
//
// Notes:
//
Function tMASIni.ReadFloat (Const Section, Ident: String; Const Default: Double; Const Create: Boolean): Double;
begin
  Result := 0;
  if not Assigned (fIniFile) then Exit;
  if Create and NOT fIniFile.ValueExists (Section, Ident) then
    WriteFloat (Section, Ident, Default);
  // Now Read as Normal
  Result := fIniFile.ReadFloat (Section, Ident, Default);
end;

// Routine: WriteFloat
// Author: M.A.Sargent  Date: 05/02/13  Version: V1.0
//
// Notes:
//
Procedure tMASIni.WriteFloat (Const Section, Ident: String; Const Value: Double);
begin
  if not Assigned (fIniFile) then Exit;
  fIniFile.WriteFloat (Section, Ident, Value);
end;

// Routine: ReadDate and WriteDate
// Author: M.A.Sargent  Date: 17/11/14  Version: V1.0
//
// Notes:
//
Function tMASIni.ReadDate (Const Section, Ident: String; Const Default: tDateTime; Const Create: Boolean): tDateTime;
begin
  Result := 0;
  if not Assigned (fIniFile) then Exit;
  if Create and NOT fIniFile.ValueExists (Section, Ident) then
    WriteDate (Section, Ident, Default);
  // Now Read as Normal
  Result := fIniFile.ReadDate (Section, Ident, Default);
end;
Procedure tMASIni.WriteDate (Const Section, Ident: String; Const Value: tDateTime);
begin
  if not Assigned (fIniFile) then Exit;
  fIniFile.WriteDate (Section, Ident, Value);
end;

// Routine: h_fnIniFileNameFromAppName & h_fnIniFileNameFromModuleName
// Author: M.A.Sargent  Date: 25/05/17  Version: V1.0
//
// Notes:
//
Function h_fnIniFileNameFromAppName: String;
begin
  Result := h_fnIniFileNameFromAppPath (fnTS_ExeName);
end;
Function h_fnIniFileNameFromAppName (Const aDir: String): String;
begin
  Result := h_fnIniFileNameFromAppPath (aDir, ExtractFileName (fnTS_ExeName));
end;

Function h_fnIniFileNameFromAppName2: tMASIni;
begin
  Try
    Result := tMASIni.CreateFromApp;
  Except
    FreeAndNil (Result);
    Raise;
  End;
end;

Function h_fnIniFileNameFromAppPath (Const aFileName: String): String;
begin
  Result := h_fnIniFileNameFromAppPath (fnTS_AppPath, ExtractFileName (aFileName));
end;
Function h_fnIniFileNameFromAppPath (Const aDir, aFileName: String): String;
var
  lvFileName: String;
begin
  lvFileName := ChangeFileExt (aFileName, cFILE_EXTN_INI);
  Result := AppendPath (aDir, lvFileName);
end;
Function h_fnIniFileNameFromAppPath2 (Const aFileName: String): tMASIni;
begin
  Try
    Result := tMASIni.Create (aFileName);
  Except
    FreeAndNil (Result);
    Raise;
  End;
end;

// Routine:
// Author: M.A.Sargent  Date: 25/05/17  Version: V1.0
//
// Notes:
//
Function h_fnIniFileNameFromModuleName (Const aDir: String): String;
var
  lvDir: String;
begin
  lvDir  := ExtractFileName (h_fnIniFileNameFromModuleName (False));
  Result := AppendPath (aDir, lvDir);
end;
Function h_fnIniFileNameFromModuleName (Const aUseAppDir: Boolean): String;
var
  lvModuleName: String;
begin
  lvModuleName := GetModuleName (hInstance);
  lvModuleName := ChangeFileExt (lvModuleName, cFILE_EXTN_INI);
  //
  Case aUseAppDir of
    True: Result := AppendPath (fnTS_AppName, ExtractFileName (lvModuleName));
    else  Result := lvModuleName;
  end;
end;
//
//
Function h_fnIniFileNameFromModuleName2 (Const aDir: String): tMASIni;
var
  lvName: String;
begin
  lvName := h_fnIniFileNameFromModuleName (aDir);
  Result := h_fnIniFileNameFromModuleName2 (lvName);
end;
Function h_fnIniFileNameFromModuleName2 (Const aUseAppDir: Boolean): tMASIni;
begin
  Try
    Result := tMASIni.Create (h_fnIniFileNameFromModuleName (aUseAppDir));
  Except
    FreeAndNil (Result);
    Raise;
  End;
end;


end.
