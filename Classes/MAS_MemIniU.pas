//
// Unit: MAS_MemIniU
// Author: M.A.Sargent  Date: 04/09/12  Version: V1.0
//         M.A.Sargent        10/10/12           V2.0
//         M.A.Sargent        20/10/12           V3.0
//         M.A.Sargent        11/04/13           V4.0
//         M.A.Sargent        03/10/13           V5.0
//         M.A.Sargent        26/04/15           V6.0
//         M.A.Sargent        09/10/17           V7.0
//         M.A.Sargent        15/05/18           V8.0
//         M.A.Sargent        24/05/18           V9.0
//
// Notes:
//  V2.0: Updated to add property IniFileLoadedOK
//  V3.0: Added method SaveAndReload
//  V4.0: Add method function fnIncrementInteger
//  V5.0: Add CreateFromApp constructors
//  V6.0: Updated to use fnTS_ExeName and not Application.ExeName
//  V7.0: Add CreateFromModule constrcutor
//  V8.0: TSUK Ltd Update
//  V9.0: Updateds to add method LoadFromList
//
unit MAS_MemIniU;

interface

Uses Classes, IniFiles, SysUtils, BaseEncryptU, TS_SystemVariablesU, MASRecordStructuresU, Dialogs;

  { tMAS_MemIniFile - loads an entire INI file into memory and allows all
    operations to be performed on the memory image.  The image can then
    be written out to the disk file }

Type
  tMAS_CustomMemIniFile = Class;
  tOnLoadEvent = Procedure (Sender: tMAS_CustomMemIniFile; aList: tStringList) of object;

  tMASHashedStringList = class(tHashedStringList)
  end;

  tMAS_CustomMemIniFile = class(TCustomIniFile)
  private
    fOnAfterLoad: tOnLoadEvent;
    fOnBeforeSave: tOnLoadEvent;
    fSections: TStringList;
    fIniFileLoadedOK: Boolean;
    function AddSection(const Section: string): TStrings;
    function GetCaseSensitive: Boolean;
    procedure LoadValues;
    procedure SetCaseSensitive(Value: Boolean);
    procedure IntDoAfterLoad (aList: tStringList);
    procedure IntDoBeforeSave (aList: tStringList);
  Protected
    Procedure DoAfterLoad (aList: tStringList); virtual;
    Procedure DoBeforeSave (aList: tStringList); virtual;
    Procedure DoLoadValues; virtual;
    //
    Property Int_IniFileLoadedOK: Boolean read fIniFileLoadedOK write fIniFileLoadedOK;

  public
    Constructor Create (Const FileName: string); virtual;

    Destructor Destroy; override;
    Procedure Clear;
    //
    Procedure LoadFromList (Const aList: tStrings);
    Function  ReLoad: Integer;
    Function  SaveAndReload: Integer;

    Procedure DeleteKey          (Const Section, Ident: String); override;
    Procedure EraseSection       (Const Section: string); override;
    Procedure GetStrings         (List: TStrings);
    Procedure ReadSection        (Const Section: string; Strings: TStrings); override;
    Procedure ReadSections       (Strings: TStrings); override;
    //
    Procedure ReadSectionValues  (Const Section: string; Strings: TStrings); override;
    Procedure ReadSectionValues2 (Const Section: string; Strings: TStrings);
    //
    Function  ReadString         (Const Section, Ident, Default: string): string; override;
    Procedure SetStrings         (List: TStrings);
    Procedure UpdateFile; override;
    //
    Procedure WriteString         (Const Section, Ident, Value: String); override;
    Procedure WriteString_Reload  (Const Section, Ident, Value: String);
    Procedure WriteInteger_Reload (Const Section, Ident: string; Value: Longint);
    //
    Function fnIncrementInteger   (Const Section, Ident: String; Const InitialValue: Integer = 0): Integer;
    //
    Property CaseSensitive: Boolean read GetCaseSensitive write SetCaseSensitive;
    //
    Property IniFileLoadedOK: Boolean read fIniFileLoadedOK;
  end;

  // Base Clasa s from which both flavours or the MmIni file derive
  tMAS_BaseMemIniFile = Class (tMAS_CustomMemIniFile)
  Protected
    fLoadedFromDLL: tOKStrRec;
  End;

  tMAS_MemIniFile = Class (tMAS_BaseMemIniFile)
  Protected
    Procedure DoLoadValues; override;
  Public
    Constructor Create (Const FileName: string); override;
    Constructor CreateEvents (Const FileName: String; aLoadEvent, aSaveEvent: tOnLoadEvent);
    Constructor CreateFromApp (Const aFileName: String); overload; virtual;
    Constructor CreateFromApp; overload; virtual;
    Constructor CreateFromModule;
  End;

{ Removed for TSUK Ltd
  tMAS_DLLMemIniFile = Class (tMAS_BaseMemIniFile)
  Private
    fAppHandle: tHandle;
  Protected
    Procedure DoLoadValues; override;
  Public
    Constructor CreateFromApp (Const aAppHandle: tHandle; Const aDLLIni_FileName: String; Const aIdentifier: Integer); overload;
    Constructor CreateFromApp (Const aAppHandle: tHandle; Const aDLLIni_FileName: String; Const aIdentifier: String); overload;
  End;}

 tMAS_Encrypt_MemIniFile = Class (tMAS_MemIniFile)
  Private
    fKey:                           String;
    fBaseEncrypt:                   tBaseEncrypt;
    //fExternalEncryptMustBeAssigned: Boolean;
    //
    Procedure SetBaseEncrypt (Const Value: tBaseEncrypt);
  Protected
    Procedure DoAfterLoad  (aList: tStringList); override;
    Procedure DoBeforeSave (aList: tStringList); override;
    //
    Property BaseEncrypt: tBaseEncrypt read fBaseEncrypt write SetBaseEncrypt;

  Public
    Constructor CreateEvents            (Const aKey, FileName: String);
    Constructor CreateEventsBaseEncrypt (Const aBaseEncrypt: tBaseEncrypt; Const aKey, FileName: String);
    //
//    Property ExternalEncryptMustBeAssigned: Boolean      read fExternalEncryptMustBeAssigned write fExternalEncryptMustBeAssigned default True;
  end;

implementation

Uses {MAS_Encrypt3U~,} MAS_DirectoryU, FormatResultU{, LoadIniFromDLL_HelpersU}, MASCommonU;

{ tMAS_MemIniFile }

Constructor tMAS_CustomMemIniFile.Create (Const FileName: string);
begin
  inherited Create (FileName);
  FSections := tMasHashedStringList.Create;
  fOnAfterLoad  := Nil;
  fOnBeforeSave := Nil;
  LoadValues;
end;

Destructor tMAS_CustomMemIniFile.Destroy;
begin
  if FSections <> nil then Clear;
  FSections.Free;
  inherited Destroy;
end;

function tMAS_CustomMemIniFile.AddSection (Const Section: string): TStrings;
begin
  Result := tMasHashedStringList.Create;
  try
    tMasHashedStringList(Result).CaseSensitive := CaseSensitive;
    FSections.AddObject(Section, Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure tMAS_CustomMemIniFile.Clear;
var
  I: Integer;
begin
  for I := 0 to FSections.Count - 1 do
    TObject(FSections.Objects[I]).Free;
  FSections.Clear;
end;

procedure tMAS_CustomMemIniFile.DeleteKey(const Section, Ident: String);
var
  I, J: Integer;
  Strings: TStrings;
begin
  I := FSections.IndexOf(Section);
  if I >= 0 then
  begin
    Strings := TStrings(FSections.Objects[I]);
    J := Strings.IndexOfName(Ident);
    if J >= 0 then
      Strings.Delete(J);
  end;
end;

procedure tMAS_CustomMemIniFile.EraseSection(const Section: string);
var
  I: Integer;
begin
  I := FSections.IndexOf(Section);
  if I >= 0 then
  begin
    TStrings(FSections.Objects[I]).Free;
    FSections.Delete(I);
  end;
end;

function tMAS_CustomMemIniFile.GetCaseSensitive: Boolean;
begin
  Result := FSections.CaseSensitive;
end;

procedure tMAS_CustomMemIniFile.GetStrings(List: TStrings);
var
  I, J: Integer;
  Strings: TStrings;
begin
  List.BeginUpdate;
  try
    for I := 0 to FSections.Count - 1 do
    begin
      List.Add('[' + FSections[I] + ']');
      Strings := TStrings(FSections.Objects[I]);
      for J := 0 to Strings.Count - 1 do List.Add(Strings[J]);
      List.Add('');
    end;
  finally
    List.EndUpdate;
  end;
end;

// Routine: LoadValues
// Author: M.A.Sargent  Date: 10/10/12  Version: V1.0
//
// Notes: Add propertry to indicate if a file ini has been loaded correctly
//
procedure tMAS_CustomMemIniFile.LoadValues;
begin
  DoLoadValues;
end;

procedure tMAS_CustomMemIniFile.ReadSection (Const Section: string; Strings: TStrings);
var
  I, J: Integer;
  SectionStrings: TStrings;
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    I := FSections.IndexOf(Section);
    if I >= 0 then
    begin
      SectionStrings := TStrings(FSections.Objects[I]);
      for J := 0 to SectionStrings.Count - 1 do
        Strings.Add(SectionStrings.Names[J]);
    end;
  finally
    Strings.EndUpdate;
  end;
end;

procedure tMAS_CustomMemIniFile.ReadSections(Strings: TStrings);
begin
  Strings.Assign(FSections);
end;

// Routine: ReadSectionValues2 &
// Author: M.A.Sargent  Date: 10/10/12  Version: V1.0
//
// Notes:
//
Procedure tMAS_CustomMemIniFile.ReadSectionValues2 (Const Section: String; Strings: TStrings);
begin
  ReadSectionValues (Section, Strings);
  Strings.Insert (0, ('['+Section+']'));
end;
procedure tMAS_CustomMemIniFile.ReadSectionValues (Const Section: String; Strings: TStrings);
var
  I: Integer;
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    I := FSections.IndexOf(Section);
    if I >= 0 then
      Strings.Assign(TStrings(FSections.Objects[I]));
  finally
    Strings.EndUpdate;
  end;
end;

function tMAS_CustomMemIniFile.ReadString(const Section, Ident, Default: string): string;
var
  I: Integer;
  Strings: TStrings;
begin
  I := FSections.IndexOf(Section);
  if I >= 0 then
  begin
    Strings := TStrings(FSections.Objects[I]);
    I := Strings.IndexOfName(Ident);
    if I >= 0 then
    begin
      Result := Copy(Strings[I], Length(Ident) + 2, Maxint);
      Exit;
    end;
  end;
  Result := Default;
end;

procedure tMAS_CustomMemIniFile.SetCaseSensitive(Value: Boolean);
var
  I: Integer;
begin
  if Value <> FSections.CaseSensitive then
  begin
    FSections.CaseSensitive := Value;
    for I := 0 to FSections.Count - 1 do
      with tMasHashedStringList(FSections.Objects[I]) do
      begin
        CaseSensitive := Value;
        Changed;
      end;
      tMasHashedStringList(FSections).Changed;
  end;
end;

procedure tMAS_CustomMemIniFile.SetStrings(List: TStrings);
var
  I, J: Integer;
  S: string;
  Strings: TStrings;
begin
  Clear;
  Strings := nil;
  for I := 0 to List.Count - 1 do
  begin
    S := Trim(List[I]);
    if (S <> '') and (S[1] <> ';') then
      if (S[1] = '[') and (S[Length(S)] = ']') then
      begin
        Delete(S, 1, 1);
        SetLength(S, Length(S)-1);
        Strings := AddSection(Trim(S));
      end
      else
        if Strings <> nil then
        begin
          J := Pos('=', S);
          if J > 0 then // remove spaces before and after '='
            Strings.Add(Trim(Copy(S, 1, J-1)) + '=' + Trim(Copy(S, J+1, MaxInt)) )
          else
            Strings.Add(S);
        end;
  end;
end;

procedure tMAS_CustomMemIniFile.UpdateFile;
var
  List: TStringList;
begin
  List := TStringList.Create;
  try
    GetStrings(List);
    IntDoBeforeSave (List);
    List.SaveToFile (FileName);
  finally
    List.Free;
  end;
end;

procedure tMAS_CustomMemIniFile.WriteString(const Section, Ident, Value: String);
var
  I: Integer;
  S: string;
  Strings: TStrings;
begin
  I := FSections.IndexOf(Section);
  if I >= 0 then
    Strings := TStrings(FSections.Objects[I])
  else
    Strings := AddSection(Section);
  S := Ident + '=' + Value;
  I := Strings.IndexOfName(Ident);
  if I >= 0 then
    Strings[I] := S
  else
    Strings.Add(S);
end;

// Routine: WriteString_Reload
// Author: M.A.Sargent  Date: 20/10/12  Version: V1.0
//
// Notes:
//
procedure tMAS_CustomMemIniFile.WriteString_Reload (Const Section, Ident, Value: String);
begin
  WriteString (Section, Ident, Value);
  SaveAndReload;
end;

// Routine: WriteString_Reload
// Author: M.A.Sargent  Date: 20/10/12  Version: V1.0
//
// Notes:
//
procedure tMAS_CustomMemIniFile.WriteInteger_Reload (Const Section, Ident: string; Value: Integer);
begin
  WriteInteger (Section, Ident, Value);
  SaveAndReload;
end;

// Routine: fnIncrementInteger
// Author: M.A.Sargent  Date: 11/04/13  Version: V1.0
//
// Notes:
//
Function tMAS_CustomMemIniFile.fnIncrementInteger (Const Section, Ident: String; Const InitialValue: Integer): Integer;
begin
  Result := (Self.ReadInteger (Section, Ident, InitialValue) + 1);
  WriteInteger_Reload (Section, Ident, Result);
end;

// Routine: ReLoad
// Author: M.A.Sargent  Date: 24/09/12  Version: V1.0
//
// Notes:
//
Function tMAS_CustomMemIniFile.ReLoad: Integer;
begin
  LoadValues;
  Result := fSections.Count;
end;

// Routine: SaveAndReload
// Author: M.A.Sargent  Date: 20/10/12  Version: V1.0
//
// Notes:
//
Function tMAS_CustomMemIniFile.SaveAndReload: Integer;
begin
  UpdateFile;
  Result := ReLoad;
end;

// Routine: DoAfterLoad
// Author: M.A.Sargent  Date: 20/10/12  Version: V1.0
//
// Notes:
//
Procedure tMAS_CustomMemIniFile.IntDoAfterLoad (aList: tStringList);
begin
  if Assigned (fOnAfterLoad) then fOnAfterLoad (Self, aList)
  else DoAfterLoad (aList);
end;
procedure tMAS_CustomMemIniFile.DoAfterLoad (aList: tStringList);
begin
end;

// Routine: DoBeforeSave
// Author: M.A.Sargent  Date: 20/10/12  Version: V1.0
//
// Notes:
//
Procedure tMAS_CustomMemIniFile.IntDoBeforeSave (aList: tStringList);
begin
  if Assigned (fOnBeforeSave) then fOnBeforeSave (Self, aList)
  else DoBeforeSave (aList);
end;
procedure tMAS_CustomMemIniFile.DoBeforeSave (aList: tStringList);
begin
end;

Procedure tMAS_CustomMemIniFile.DoLoadValues;
begin
  if IsEqual (Self.ClassName, 'tMAS_CustomMemIniFile') and not IsEmpty (Self.FileName) then
    Raise Exception.CreateFmt ('Error: tMAS_CustomMemIniFile. This Object Will not Load FileName. %s', [Self.FileName]);
end;

// Routine: LoadFromList
// Author: M.A.Sargent  Date: 24/05/18  Version: V1.0
//
// Notes:
//
Procedure tMAS_CustomMemIniFile.LoadFromList (Const aList: tStrings);
var
  lvList: tStringList;
begin
  fnRaiseOnFalse (Assigned (aList), 'Error: LoadFromList. aList must be Assigned');
  lvList := tStringList.Create;
  Try
    lvList.Assign(aList);
    fIniFileLoadedOK := True;
    IntDoAfterLoad (lvList);
    SetStrings (lvList);
  Finally
    lvList.Free;
  end;
end;

{ tMAS_BaseMemIniFile }

{ tMAS_MemIniFile }

Constructor tMAS_MemIniFile.Create (Const FileName: string);
begin
  {$IFDEF VER150}
  fLoadedFromDLL := fnClear_OKStrRec;
  {$ELSE}
  fLoadedFromDLL.Clear;
  {$ENDIF}
  inherited;
end;

Constructor tMAS_MemIniFile.CreateEvents (Const FileName: String; aLoadEvent, aSaveEvent: tOnLoadEvent);
begin
  inherited Create (FileName);
  FSections := tMasHashedStringList.Create;
  fOnAfterLoad  := aLoadEvent;
  fOnBeforeSave := aSaveEvent;
  LoadValues;
end;

Constructor tMAS_MemIniFile.CreateFromApp (Const aFileName: String);
var
  lvFileName: String;
begin
  lvFileName := AppendPath (fnTS_AppPath, aFilename);
  Create (lvFileName);
end;

constructor tMAS_MemIniFile.CreateFromApp;
var
  lvFileName: String;
begin
  lvFileName := fnTS_ExeName;
  lvFileName := ChangeFileExt (lvFileName, '.Ini');
  Create (lvFileName);
end;

Constructor tMAS_MemIniFile.CreateFromModule;
var
  lvFileName: String;
begin
  lvFileName := ExtractFileName (GetModuleName (hInstance));
  lvFileName := ChangeFileExt (lvFileName, '.Ini');
  Create (lvFileName);
end;

procedure tMAS_MemIniFile.DoLoadValues;
var
  List: TStringList;
begin
  inherited;
  fIniFileLoadedOK := False;
  if (FileName <> '') and FileExists(FileName) then begin
    List := TStringList.Create;
    try
      List.LoadFromFile(FileName);
      fIniFileLoadedOK := True;
      IntDoAfterLoad (List);
      SetStrings(List);
    finally
      List.Free;
    end;
  end
  else Clear;
end;

{ tMAS_DLLMemIniFile }

{Constructor tMAS_DLLMemIniFile.CreateFromApp (Const aAppHandle: tHandle; Const aDLLIni_FileName: String; Const aIdentifier: Integer);
begin
  CreateFromApp (aAppHandle, aDLLIni_FileName, IntToStr (aIdentifier));
end;

Constructor tMAS_DLLMemIniFile.CreateFromApp (Const aAppHandle: tHandle; Const aDLLIni_FileName: String; Const aIdentifier: String);
var
  lvFileName: String;
begin
  fLoadedFromDLL.OK  := True;
  fLoadedFromDLL.Msg := aIdentifier;
  fAppHandle := aAppHandle;
  //
  Case (aDLLIni_FileName <> '') of
    True: lvFileName := AppendPath (fnTS_AppPath, aDLLIni_FileName);
    else  lvFileName := '';
  end;

  Create (lvFileName);
end;

Procedure tMAS_DLLMemIniFile.DoLoadValues;
var
  lvList: TStringList;
  lvRes: tOKStrRec;
begin
  inherited;
  fIniFileLoadedOK := False;
  if ((FileName <> '') and FileExists(FileName) or
      (FileName = '')) then
  begin
    lvList := TStringList.Create;
    try
      // load details from DLL
      lvRes := fnLoadIniFromDLL_Load (fAppHandle, FileName, fLoadedFromDLL.Msg);
      fnRaiseOnFalse (lvRes.OK, 'Error: DoLoadValues. %s', [lvRes.Msg]);
      lvList.Text := lvRes.Msg;
      //
      fIniFileLoadedOK := True;
      IntDoAfterLoad (lvList);
      SetStrings (lvList);
    finally
      lvList.Free;
    end;
  end
  else
    Clear;
end;
}

{ tMAS_MemEncryptIniFile }

Constructor tMAS_Encrypt_MemIniFile.CreateEvents (Const aKey, FileName: String);
begin
  fKey := aKey;
  Inherited CreateEvents (FileName, Nil, Nil);
end;

Constructor tMAS_Encrypt_MemIniFile.CreateEventsBaseEncrypt (Const aBaseEncrypt: tBaseEncrypt; Const aKey, FileName: String);
begin
  Self.BaseEncrypt := aBaseEncrypt;
  CreateEvents (aKey, FileName);
end;

Procedure tMAS_Encrypt_MemIniFile.DoAfterLoad (aList: tStringList);
begin
  inherited;
  Case Assigned (fBaseEncrypt) of
    True: fBaseEncrypt.DecryptList (aList);
    else begin
      Raise Exception.Create ('Error: TS Not Currently Implimented');
      //qqq DecryptListByLine (fKey, aList);
    end;
  end;
end;

Procedure tMAS_Encrypt_MemIniFile.DoBeforeSave(aList: tStringList);
begin
  inherited;
  Case Assigned (fBaseEncrypt) of
    True: fBaseEncrypt.EncryptList (aList);
    else begin
      Raise Exception.Create ('Error: TS Not Currently Implimented');
      //qqq EncryptListByLine (fKey, aList);
    end;
  end;
end;

Procedure tMAS_Encrypt_MemIniFile.SetBaseEncrypt (Const Value: tBaseEncrypt);
begin
  fBaseEncrypt := Value;
  fBaseEncrypt.Key := Self.fKey;
end;

end.

