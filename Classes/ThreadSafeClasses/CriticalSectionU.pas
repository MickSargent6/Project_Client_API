//
// Unit: CriticalSectionU
// Author: M.A.Sargent  Date: 23/07/2003  Version: V1.0
//         M.A.Sargent        23/06/11             V2.0
//         M.A.Sargent        24/09/11             V3.0
//         M.A.Sargent        08/10/11             V4.0
//         M.A.Sargent        12/11/11             V5.0
//         M.A.Sargent        31/07/13             V6.0
//         M.A.Sargent        03/08/13             V7.0
//         M.A.Sargent        ??/??/??             V8.0
//         M.A.Sargent        07/12/16             V9.0
//         M.A.Sargent        20/01/17             V10.0
//         M.A.Sargent        25/11/17             V11.0
//         M.A.Sargent        15/06/18             V12.0
//         M.A.Sargent        09/07/18             V13.0
//         M.A.Sargent        22/07/18             V14.0
//         M.A.Sargent        14/08/18             V15.0
//         M.A.Sargent        17/08/18             V16.0
//
// Notes: About screen
// V2.0: Add aLock and Unlock Event
// V3.0:
// V4.0:
// V5.0:
// V6.0:
// V7.0:
// V8.0:  Add tMASRORWSynch
// V9.0:  Add a Count function to tMASThreadSafeString
// V10.0: Add a count for the number for times tMASRORWSynch is locked
// V11.0:
// V12.0: Add a Simple class tSimpleThreadSafeStringQueue
// V13.0: Updated for Delphi 7
// V14.0: Updated to add another ThreadSafe class tMASThreadSafeIni
// V15.0: Updated AddValue, bug fix
// V16:0: Updated tMASThreadSafeIni add function fnFileName
//
unit CriticalSectionU;

interface

Uses Classes, Windows, SysUtils, IdThreadSafe, MASRecordStructuresU, MAS_MemIniU, MAS_ConstsU, MAS_Collections2U,
      Contnrs, MAS_IniU;

Type
  tLockType   = (ltEnter, ltLeave);
  tAddAction  = (aaUpdateIfExists, aaFailIfExists, aaExceptionIfExists);
  tCSType     = (csDefault, csTryAndWait);
  tWaitResult = (wrSignalled, wrTimeOut);
  //
  tOnEvent = Procedure(Const aType: tLockType; Const aName: String; Const Value: Integer) of object;
  tSignalEvent = Procedure of object;

  tMASThreadSafeString = Class(TIdThreadSafeString)
  Public
    Constructor Create; override;
    Constructor Create2 (Const aValue: String);
    Procedure Clear;
    Function Count: Integer;
    Property NonThreadSafeValue: String read fValue write fValue;
  end;

  tMASThreadSafeInteger = Class (tIdThreadSafeInteger)
  Private
    fInitValue: Integer;
  Public
    Constructor Create2 (Const aInitValue: Integer); virtual;
    Procedure Clear;
  end;

  // Note:
  // Note: DELPHI 7 does not release or clear objects assigned using AddObject, Higher versionS have a Property OwnsObjects, which if True
  //       will Free the object on Clear, Delete etc
  //       In Mick Sargent's tMASStringList I have copied this behaviour but in TIdThreadSafeStringList it uses a tStringList
  //       can be updated is needed but D7 is moving on unless I need Thread Safe tStringList that I can add Objects to I will not update it
  //
  // Update: 10/08/2018
  // Class has now been updated, if Delhi 7 and the Constructor Create_D7 or CreateSorted are called the original list is Freed
  // and a tMASStringList is createrd in its place, therefore calls to Delete and Clear will Free associated objects (default)
  //
  //
  tMASThreadSafeStringList = class (TIdThreadSafeStringList)
  private
    fOnChange: tSignalEvent;
    Procedure IntOnChange    (Sender: TObject);
    Procedure SetOnChange    (Const Value: tSignalEvent);
    Function  GetReadStrings (Index: Integer): String;
    Function  GetOwnsObjects: Boolean;
    Procedure SetOwnsObjects (Const Value: Boolean);
  Public
    {$IFDEF VER150}
    Constructor Create_D7    (Const ASorted: Boolean = False);
    {$ELSE}
    {$ENDIF}
    Constructor CreateSorted (Const Duplicate: tDuplicates = dupError);
    //
    Function  Count: Integer;
    Procedure Delete         (Index: Integer);
    Procedure LoadFromFile   (Const FileName: String);
    Procedure SaveToFile     (Const FileName: String);
    Function  ObjectByIndex  (Const aIndex: Integer): tObject;
    //
    Procedure AddValues      (Const aName, aValue: String);
    Function AddValuePair    (Const aName, aValue: String; Const aAddAction: tAddAction = aaUpdateIfExists): Boolean;
    Function GetValue        (Const aName: String): tOKStrRec; overload;
    Function GetValue        (Const aName, aDefault: String): tOKStrRec; overload;
    Function GetValue2       (Const aName, aDefault: String): String; overload;
    //
    Function fnAdd           (Const AItem: string): Integer;
    Function AddMsg          (Const aFormat: string; const Args: array of const): Integer; overload;
    //
    Function Exists          (Const aIdentifier: String): Boolean;
    Function DeleteByName    (Const aName: String): Boolean;
    Function Find            (Const S: String; var Index: Integer): Boolean;
    Function fnObject        (Const aIdx: Integer): tObject; overload;
    Function fnObject        (Const aIdentifier: String): tObject; overload;
    Function fnString        (Const aIdx: Integer): String;
    //
    Function DeleteByIndexOfName (Const Name: string): Boolean;
    //
    Function fnInt_IncrementValue (Const aName: String; Const aRaiseNotFound: Boolean = False): Integer;
    // in D7 only works if the Constructor Create_D7 has been called
    Property OwnsObjects: Boolean                        read GetOwnsObjects write SetOwnsObjects;
    Property ReadStrings [Index: Integer]: String        read GetReadStrings;
    Property OnChange:                     tSignalEvent  read fOnChange      write SetOnChange;
  end;

type
  tMASCriticalSection = class(TObject)
  private
    fSpinCount: Integer;
    fCSType:    tCSType;
    fOnEvent:   tOnEvent;
    FSection:   TRTLCriticalSection;
    Entered:    Integer;
  public
    Constructor Create; overload; virtual;
    Constructor Create (Const aCSType: tCSType; Const aSpinCount: Integer = 4000); overload;
    Destructor Destroy; override;
    //
    Function Enter: Boolean; overload;
    Function Enter(Const aDoEvent: Boolean; Const aName: String; Const aRaise: Boolean = True): Boolean; overload;
    Procedure EnterRaise (Const aName: String = '');
    //
    Procedure Leave; overload;
    Procedure Leave(Const aDoEvent: Boolean; Const aName: String); overload;
    //
    Property OnEvent: tOnEvent read fOnEvent write fOnEvent;
  end;

  tMASRORWSynch = Class(TObject)
  Private
    fRORWSynch: TMultiReadExclusiveWriteSynchronizer;
    fCount: Cardinal;
  Public
    Constructor Create; overload; virtual;
    Destructor Destroy; override;
    Property Count: Cardinal read fCount;
    //
    Procedure EnterRO;
    Function EnterRW: Boolean;
    //
    Procedure LeaveRO;
    Procedure LeaveRW;
  end;
  
  //
  //
  //
  tMASThreadSafeMemIni = class(TIdThreadSafe)
  private
  protected
    fIniFile: tMAS_MemIniFile;
  public
    Constructor Create (Const aFileName: String); reintroduce;
    Destructor Destroy; override;
    //
    Function  Lock: tMAS_MemIniFile; reintroduce;
    Procedure Unlock; reintroduce;
    Function IniFileLoadedOK: Boolean;
    // Currently the only methods available are listed below, but others can be added simply as and when needed
    // better to add a method so that the Lock/UnLock is called correctly and finally
    //
    Function ReadString  (Const Section, Ident, Default: string): string;
    Function ReadInteger (Const Section, Ident: String; Const aDefault: Integer): Integer;
    Function ReadBoolean (Const Section, Ident: String; Const aDefault: Boolean): Boolean;
    //
    Function fnExists    (Const Section, Ident: String): Boolean;
  end;

  //
  //
  //
  tMASThreadSafeIni = class(TIdThreadSafe)
  private
  protected
    fIniFile: tMASIni;
  public
    Constructor Create (Const aFileName: String); reintroduce;
    Destructor Destroy; override;
    //
    Function  Lock: tMASIni; reintroduce;
    Procedure Unlock; reintroduce;
    Function  IniFileLoadedOK: Boolean;
    Function  fnFileName: String;
    //
    Procedure Flush;
    Function fnExists      (Const Section, Ident: String): Boolean;

    //
    // Currently the only methods available are listed below, but others can be added simply as and when needed
    // better to add a method so that the Lock/UnLock is called correctly and finally
    //
    Function ReadString    (Const Section, Ident, Default: string): string;
    Function ReadInteger   (Const Section, Ident: String; Const aDefault: Integer): Integer;
    Function ReadBoolean   (Const Section, Ident: String; Const aDefault: Boolean): Boolean;
    //
    Procedure WriteString  (Const Section, Ident, aValue: String);
    Procedure WriteInteger (Const Section, Ident: String; Const aValue: Integer);
  end;

  tThreadSafeIndexList = Class (tIdThreadSafe)
  Private
    fList: tStringListList2;
  Public
    Constructor Create; override;
    Destructor Destroy; override;
    Procedure Clear;
    //
    Function  AddEntry                   (Const aId: Integer; Const aValue: String): Integer;
    Function  fnGetEntry                 (Const aId: Integer): tOKStrRec; overload;
    Function  fnGetEntryDeleteAfterRead  (Const aId: Integer): tOKStrRec; overload;
  end;

  {$IFDEF VER150}
  //
  // Only present for Delphi 7, exists in IdThreadSafe in Indy10 (XE + etc)
  //
  tIdThreadSafeBoolean = class (tIdThreadSafe)
  protected
    FValue: Boolean;
    //
    Function GetValue: Boolean;
    Procedure SetValue(const AValue: Boolean);
  public
    Constructor Create2 (Const aInitValue: Boolean); virtual;
    Function Toggle: Boolean;
    //
    Property Value:              Boolean read GetValue write SetValue;
    // This NonThreadSafeValue property can be used inside a Lock/UnLock section instead of more Locks nd UnLocks
    Property NonThreadSafeValue: Boolean read fValue   write fValue;
  end;

  tIdThreadSafeDateTime = class(TIdThreadSafe)
  protected
    FValue : TDateTime;
    function GetValue: TDateTime;
    procedure SetValue (const AValue: TDateTime);
  public
    procedure Add      (const AValue : TDateTime);
    procedure Subtract (const AValue : TDateTime);
    property Value: TDateTime read GetValue write SetValue;
  end;
  {$ENDIF}

  {$IFDEF VER150}
  //
  // Only present for Delphi 7, in XE7 Generic Procedures do this sort of this very well
  // This is a sort of a copy of tThreadedQueue
  //
  tMASQueue = class (tQueue)
  private
    Function GetCapacity: Integer;
    Procedure SetCapacity (Const aValue: Integer);
  Public
    Function fnPopItem: Pointer;
    Property Capacity:  Integer read GetCapacity write SetCapacity;
  end;

  tMASQueueItem = Class (TObject)
  Private
    fStr: String;
    fCode: Integer;
  Public
    Constructor Create (Const aStr: String); overload;
    Constructor Create (Const aCode: Integer; Const aStr: String); overload;
    Property Str:  String  read fStr;
    property Code: Integer read fCode;
  end;

  tSimpleThreadSafeStringQueue = class (tObject)
  Private
    fQueue:    tMASQueue;
    fLock:     tMASCriticalSection;
    fShutDown: Boolean;
    //
    Function  LockList: tWaitResult; overload;
    Function  LockList (var aQueue: tMASQueue): tWaitResult; overload;
    Procedure UnLockList;
  Public
    Constructor Create (Const aQueueSize: Integer = 100; Const aAccessTimeOut: Cardinal = Infinite);
    Destructor  Destroy; override;
    //
    Function  fnClear: tOKIntegerRec;
    Procedure DoShutDown;
    //
    Function  fnCount: Integer;
    Function  fnCount2: tOKIntegerRec;
    Function  fnPercentage: tOKIntegerRec;

    Function  fnPush (Const aStr: String): tWaitResult;                      overload;
    Function  fnPush (Const aCode: Integer;Const aStr: String): tWaitResult; overload;
    Function  fnPop  (var   aStr: String): tWaitResult;                      overload;
    Function  fnPop  (var aCode: Integer; var   aStr: String): tWaitResult;  overload;
  end;
  {$ENDIF}

  tMASThreadOKStrRec = class (tIdThreadSafe)
  private
    Function  GetCode: Integer;
    Function  GetMsg: String;
    function  GetOK: Boolean;
    Procedure SetCode (Const Value: Integer);
    Procedure SetMsg  (Const Value: String);
    Procedure SetOK   (Const Value: Boolean);
    procedure SetValue(const Value: tOKStrRec);
  protected
    fValue: tOKStrRec;
    //
    Function GetValue: tOKStrRec;
  public
    Constructor Create; override;
    Procedure Clear;
    //
    Procedure ValueSet (Const aValue: Boolean); overload;
    Procedure ValueSet (Const aValue: Boolean; Const aMsg: String); overload;
    Procedure ValueSet (Const aValue: Boolean; Const aCode: Integer); overload;
    Procedure ValueSet (Const aValue: Boolean; Const aMsg: String; Const aCode: Integer); overload;
    //
    Property Value: tOKStrRec read GetValue write SetValue;
    Property OK:    Boolean   read GetOK   write SetOK;
    Property Msg:   String    read GetMsg  write SetMsg;
    Property Code:  Integer   read GetCode write SetCode;
  end;


implementation

Uses MatchUtilsU, MAS_FormatU, MASCommon_UtilsU, FormatResultU, MASCommonU, MAS_MathsU, MASStringListU;

{ tMASThreadSafeString }

Constructor tMASThreadSafeString.Create2 (Const aValue: String);
begin
  inherited Create;
  Self.Value := aValue;
end;
Constructor tMASThreadSafeString.Create;
begin
  inherited;
  Clear;
end;

Procedure tMASThreadSafeString.Clear;
begin
  Value := '';
end;

Function tMASThreadSafeString.Count: Integer;
begin
  Result := Length(Value);
end;

{ tMASThreadSafeIntegerClass }

Constructor tMASThreadSafeInteger.Create2 (Const aInitValue: Integer);
begin
  Create;
  fInitValue := aInitValue;
  Self.Value := fInitValue;
end;

Procedure tMASThreadSafeInteger.Clear;
begin
  Lock;
  Try
    Self.FValue := fInitValue;
  Finally
    UnLock;
  End;
end;

{ tMASThreadSafeStringList }

// Routine:  Exists
// Author: M.A.Sargent  Date: 18/11/17  Version: V1.0
//
// Notes:
//
{$IFDEF VER150}
Constructor tMASThreadSafeStringList.Create_D7 (Const aSorted: Boolean);
begin
  Create (aSorted);
  Self.fValue.Free;
  Self.fValue := tMASStringList.Create;
  Self.fValue.Sorted := aSorted;
end;
{$ELSE}
{$ENDIF}

// Routine:  Exists
// Author: M.A.Sargent  Date: 18/11/17  Version: V1.0
//
// Notes:
//
Constructor tMASThreadSafeStringList.CreateSorted (Const Duplicate: tDuplicates);
begin
  Create;
  {$IFDEF VER150}
  Self.fValue.Free;
  Self.fValue := tMASStringList.Create;
  {$ELSE}
  {$ENDIF}
  //
  with Lock do
    try
      Sorted     := True;
      Duplicates := Duplicate;
    finally
      Unlock;
    end;
end;

Function tMASThreadSafeStringList.Count: Integer;
begin
  with Lock do
    try
      Result := Count;
    finally
      Unlock;
    end;
end;

procedure tMASThreadSafeStringList.SetOnChange (Const Value: tSignalEvent);
begin
  fOnChange := Value;
  Case Assigned (fOnChange) of
    True: fValue.OnChange := IntOnChange;
    else  fValue.OnChange := Nil;
  end;
end;

Function tMASThreadSafeStringList.GetOwnsObjects: Boolean;
var
  lvObj: tStringList;
begin
  Result := False;
  lvObj  := Lock;
  Try
    {$IFDEF VER150}
    if (lvObj is tMASStringList) then Result := tMASStringList (lvObj).FreeObjects
    else Raise Exception.Create ('Error: In Delphi 7 GetOwnsObjects can not be called unless Constructor_D7 has been called');
    {$ELSE}
    Result := lvObj.OwnsObjects;
    {$ENDIF}
  Finally
    Unlock;
  end;
end;

Procedure tMASThreadSafeStringList.SetOwnsObjects (Const Value: Boolean);
var
  lvObj: tStringList;
begin
  lvObj := Lock;
  Try
    {$IFDEF VER150}
    if (lvObj is tMASStringList) then tMASStringList (lvObj).FreeObjects := Value
    else Raise Exception.Create ('Error: In Delphi 7 SetOwnsObjects can not be called unless Constructor_D7 has been called');
    {$ELSE}
    lvObj.OwnsObjects := Value;
    {$ENDIF}
  Finally
    Unlock;
  end;
end;

Procedure tMASThreadSafeStringList.IntOnChange (Sender: TObject);
begin
  if Assigned (fOnChange) then fOnChange;
end;

Function tMASThreadSafeStringList.GetReadStrings (Index: Integer): String;
begin
  with Lock do
    try
      Result := Strings[Index];
    finally
      Unlock;
    end;
end;

function tMASThreadSafeStringList.ObjectByIndex (Const aIndex: Integer): tObject;
begin
  with Lock do
    try
      Result := Objects [aIndex];
    finally
      Unlock;
    end;
end;

procedure tMASThreadSafeStringList.Delete(Index: Integer);
begin
  with Lock do
    try
      Delete (Index);
    finally
      Unlock;
    end;
end;

Procedure tMASThreadSafeStringList.LoadFromFile (Const FileName: String);
begin
  with Lock do
    try
      LoadFromFile (FileName);
    finally
      Unlock;
    end;
end;
Procedure tMASThreadSafeStringList.SaveToFile (Const FileName: String);
begin
  with Lock do
    try
      SaveToFile (FileName);
    finally
      Unlock;
    end;
end;

Function tMASThreadSafeStringList.fnAdd (Const AItem: string): Integer;
begin
  with Lock do try
    Result := Add(AItem);
  finally Unlock; end;
end;

// Routine:  fnObject
// Author: M.A.Sargent  Date: 18/11/17  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeStringList.fnObject (Const aIdx: Integer): tObject;
var
  lvObj: tStringList;
begin
  lvObj := Lock;
  Try
    Result := lvObj.Objects [aIdx];
  Finally
    Unlock;
  end;
end;
Function tMASThreadSafeStringList.fnObject (Const aIdentifier: String): tObject;
var
  lvObj: tStringList;
  x:     Integer;
begin
  Result := Nil;
  lvObj  := Lock;
  Try
    if lvObj.Find (aIdentifier, x) then Result := lvObj.Objects [x];
  Finally
    Unlock;
  end;
end;


// Routine:  fnString
// Author: M.A.Sargent  Date: 18/11/17  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeStringList.fnString (Const aIdx: Integer): String;
var
  lvObj: tStringList;
begin
  lvObj := Lock;
  Try
    //
    Result := lvObj.Strings [aIdx];
  Finally
    Unlock;
  end;
end;

Function tMASThreadSafeStringList.AddMsg (Const aFormat: string; Const Args: array of const): Integer;
begin
  Result := fnAdd (fnTS_Format (aFormat, Args));
end;

// Routine:  AddValue & GetValue
// Author: M.A.Sargent  Date: 14/11/16  Version: V1.0
//         M.A.Sargent        14/08/18           V2.0
//
// Notes:
//  V2.0: Bug Fix, if aaUpdateIfExists only asdsign value
//
Procedure tMASThreadSafeStringList.AddValues (Const aName, aValue: String);
begin
  Self.Add (MASCommon_UtilsU.fnAddValuePair (aName, aValue));
end;
Function tMASThreadSafeStringList.AddValuePair (Const aName, aValue: String; Const aAddAction: tAddAction): Boolean;
var
  lvObj: tStringList;
  lvStr: String;
  lvIdx: Integer;
begin
  lvObj := Lock;
  Try
    lvStr := MASCommon_UtilsU.fnAddValuePair (aName, aValue);
    //
    lvIdx := lvObj.IndexOfName (aName);
    Result := (lvIdx = -1);
    if Result then lvObj.Add (lvStr)
    else Case aAddAction of
           aaUpdateIfExists:   lvObj.ValueFromIndex [lvIdx] := aValue;
           aaFailIfExists:;    {Do Nothing, Result is Already False}
           aaExceptionIfExists: Raise Exception.CreateFmt ('Error: AddValuePair. Entry (%s) Already Exists', [aName]);
         end;
  Finally
    Unlock;
  end;
end;

Function tMASThreadSafeStringList.GetValue (Const aName: String): tOKStrRec;
var
  lvObj: tStringList;
  lvIdx: Integer;
begin
  lvObj := Lock;
  Try
    //
    Result.Msg := '';
    lvIdx := lvObj.IndexOfName (aName);
    Result.OK := (lvIdx <> -1);
    if Result.OK then Result.Msg := lvObj.ValueFromIndex [lvIdx];
  Finally
    Unlock;
  end;
end;

Function tMASThreadSafeStringList.GetValue (Const aName, aDefault: String): tOKStrRec;
begin
  Result := GetValue (aName);
  // if not True then set Msg to the aDefault, Result.OK will remain False, indicatin that the aDefault was used
  if not Result.OK then Result.Msg := aDefault;
end;

Function tMASThreadSafeStringList.GetValue2 (Const aName, aDefault: String): String;
begin
  Result := GetValue (aName, aDefault).Msg;
end;

// Routine:  Exists
// Author: M.A.Sargent  Date: 18/11/17  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeStringList.Exists (Const aIdentifier: String): Boolean;
var
  lvJunk: Integer;
  lvObj: tStringList;
begin
  Result := False;
  lvObj := Lock;
  Try
    if not lvObj.Sorted then Raise Exception.Create ('Error: StringList Must be Sorted to use Exists');
    Result := lvObj.Find (aIdentifier, lvJunk);
  Finally
    UnLock;
  End;
end;

// Routine:  Find
// Author: M.A.Sargent  Date: 18/11/17  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeStringList.Find (Const S: String; var Index: Integer): Boolean;
var
  lvObj: tStringList;
begin
  lvObj := Lock;
  Try
    Result := lvObj.Find (S, Index);
  Finally
    UnLock;
  End;
end;

// Routine: DeleteByIndexOfName
// Author: M.A.Sargent  Date: 18/11/17  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeStringList.DeleteByIndexOfName (Const Name: string): Boolean;
var
  lvObj: tStringList;
  x: Integer;
begin
  lvObj := Lock;
  Try
    x := lvObj.IndexOfName (Name);
    Result := (x = cMC_NOT_FOUND);
    if Result then Exit;
    lvObj.Delete (x);
  Finally
    UnLock;
  End;
end;

// Routine: DeleteByName
// Author: M.A.Sargent  Date: 18/11/17  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeStringList.DeleteByName (Const aName: String): Boolean;
var
  Idx: Integer;
  lvObj: tStringList;
begin
  Result := False;
  lvObj := Lock;
  Try
    if not lvObj.Sorted then Raise Exception.Create ('tStringList Must be Sorted to use the DeleteByName Method');
    Result := lvObj.Find (aName, Idx);
    if Result then Delete (Idx);
  Finally
    UnLock;
  End;
end;

// Routine:  Find
// Author: M.A.Sargent  Date: 18/11/17  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeStringList.fnInt_IncrementValue (Const aName: String; Const aRaiseNotFound: Boolean): Integer;
var
  x: Integer;
  lvObj: tStringList;
begin
  lvObj := Lock;
  Try
    Result := 1;
    x := lvObj.IndexOfName (aName);
    Case (x = cMC_NOT_FOUND) of
      True: begin
              if aRaiseNotFOund then Raise Exception.CreateFmt ('Error: fnInt_IncrementValue. Entry Not Found (%s)', [aName])
              else lvObj.Values [aName] := IntToStr (Result);
      end else begin
        Result := StrToInt (lvObj.ValueFromIndex [x]);
        Inc (Result);
        lvObj.ValueFromIndex [x] := IntToStr (Result);
      end;
    end;
  Finally
    UnLock;
  End;
end;

{ tMASThreadSafeStringList }

// Routine: Create
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes:
//
Constructor tMASCriticalSection.Create;
begin
  //fCSType := csDefault;
  //fSpinCount := 4000;
  inherited Create;
  fOnEvent := Nil;
  Entered := 0;
  Case fCSType of
    csTryAndWait: InitializeCriticalSectionAndSpinCount (FSection, fSpinCount);
    else          InitializeCriticalSection(FSection);
  end;
end;

constructor tMASCriticalSection.Create (Const aCSType: tCSType; Const aSpinCount: Integer);
begin
  fCSType    := aCSType;
  fSpinCount := aSpinCount;
  Create;
end;

destructor tMASCriticalSection.Destroy;
begin
  DeleteCriticalSection(FSection);
  inherited Destroy;
end;

Function tMASCriticalSection.Enter: Boolean;
begin
  Result := Enter(False, '', False);
end;

Procedure tMASCriticalSection.EnterRaise (Const aName: String);
begin
  Enter (False, aName, True);
end;

// Routine: Enter
// Author: M.A.Sargent  Date: 12/11/11  Version: V1.0
// M.A.Sargent        03/08/13           V2.0
//
// Notes:
// V2.0: Updated to allow exception tro be raise or not
//
Function tMASCriticalSection.Enter (Const aDoEvent: Boolean; Const aName: String; Const aRaise: Boolean): Boolean;
begin
  Result := True;
  Case fCSType of
    csTryAndWait: Result := TryEnterCriticalSection(FSection);
    else EnterCriticalSection(FSection);
  end;
  if Result then begin
    Inc(Entered);
    if aDoEvent and Assigned(fOnEvent) then fOnEvent(ltEnter, aName, Entered);
  end
  else begin
    if aRaise then
      Raise Exception.CreateFmt ('Thread Lock by (%d) Section %s', [fSection.OwningThread, aName]);
  end;
end;

procedure tMASCriticalSection.Leave;
begin
  Leave(False, '');
end;

procedure tMASCriticalSection.Leave(Const aDoEvent: Boolean; Const aName: String);
begin
  if Entered > 0 then begin
    Dec(Entered);
    LeaveCriticalSection(FSection);
  end;
  if aDoEvent and Assigned(fOnEvent) then
    fOnEvent(ltLeave, aName, Entered);
end;

{ tMASRORWSynch }

Constructor tMASRORWSynch.Create;
begin
  fRORWSynch := TMultiReadExclusiveWriteSynchronizer.Create;
  fCount := 0;
end;

Destructor tMASRORWSynch.Destroy;
begin
  fRORWSynch.Free;
  inherited;
end;

procedure tMASRORWSynch.EnterRO;
begin
  fRORWSynch.BeginRead;
  Inc(fCount);
end;

Function tMASRORWSynch.EnterRW: Boolean;
begin
  Result := fRORWSynch.BeginWrite;
  fnInc (fCount);
end;

procedure tMASRORWSynch.LeaveRO;
begin
  fRORWSynch.EndRead;
end;

Procedure tMASRORWSynch.LeaveRW;
begin
  fRORWSynch.EndWrite;
end;

{ tMASThreadSafeMemIni }

Constructor tMASThreadSafeMemIni.Create (Const aFileName: String);
begin
  inherited Create;
  fnRaiseOnFalse ((aFileName <> ''), 'Error: tMASThreadSafeMemIni. aFilename cannot be left blank');
  //
  fIniFile := tMAS_MemIniFile.Create (aFileName);
end;

Destructor tMASThreadSafeMemIni.Destroy;
begin
  inherited Lock;
  Try
    FreeAndNil (fIniFile);
  Finally
    inherited Unlock;
  end;
  inherited;
end;

Function tMASThreadSafeMemIni.Lock: tMAS_MemIniFile;
begin
  inherited Lock;
  Result := fIniFile;
end;

Procedure tMASThreadSafeMemIni.Unlock;
begin
  Inherited UnLock;
end;

// Routine:  ReadString, ReadInteger & ReadBoolean
// Author: M.A.Sargent  Date: 10/10/17  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeMemIni.ReadString (Const Section, Ident, Default: String): string;
begin
  with Lock do
    Try
      Result := fIniFile.ReadString (Section, Ident, Default);
    Finally
      UnLock;
    end;
end;
Function tMASThreadSafeMemIni.ReadInteger (Const Section, Ident: String; Const aDefault: Integer): Integer;
begin
  with Lock do
    Try
      Result := fIniFile.ReadInteger (Section, Ident, aDefault);
    Finally
      UnLock;
    end;
end;
Function tMASThreadSafeMemIni.ReadBoolean (Const Section, Ident: String; Const aDefault: Boolean): Boolean;
begin
  with Lock do
    Try
      Result := fIniFile.ReadBool (Section, Ident, aDefault);
    Finally
      UnLock;
    end;
end;

// Routine:  IniFileLoadedOK
// Author: M.A.Sargent  Date: 10/10/17  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeMemIni.IniFileLoadedOK: Boolean;
begin
  with Lock do
    Try
      Result := IniFileLoadedOK;
    Finally
      UnLock;
    end;
end;

// Routine: fnExists
// Author: M.A.Sargent  Date: 10/09/18  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeMemIni.fnExists (Const Section, Ident: String): Boolean;
begin
  with Lock do
    Try
      Result := fIniFile.ValueExists (Section, Ident);
    Finally
      UnLock;
    end;
end;


{ tThreadSafeIndexList }

// Routine: Create
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes:
//
Constructor tThreadSafeIndexList.Create;
begin
  inherited;
  fList := tStringListList2.Create;
end;

Destructor tThreadSafeIndexList.Destroy;
begin
  fList.Free;
  inherited;
end;

Procedure tThreadSafeIndexList.Clear;
begin
  Lock;
  Try
    fList.Clear;
  Finally
    UnLock;
  End;
end;

Function tThreadSafeIndexList.AddEntry (Const aId: Integer; Const aValue: String): Integer;
begin
  Lock;
  Try
    Result := fList.AddEntry (aId, aValue);
  Finally
    UnLock;
  End;
end;

Function tThreadSafeIndexList.fnGetEntry (Const aId: Integer): tOKStrRec;
begin
  Lock;
  Try
    Result := fList.fnGetEntry2 (aId);
  Finally
    UnLock;
  End;
end;

// Routine: Create
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes:
//
Function tThreadSafeIndexList.fnGetEntryDeleteAfterRead (Const aId: Integer): tOKStrRec;
begin
  Lock;
  Try
    Result := fList.fnGetEntry2 (aId);
    if Result.OK then
      fnRaiseOnFalse (fList.fnDelete (aId), 'Error: fnGetEntryDeleteAfterRead. Failed to Delete Entry for Id (%d)', [aId]);
  Finally
    UnLock;
  End;
end;

{$IFDEF VER150}
{ TIdThreadSafeBoolean }

// Routine: Create
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes:
//
Constructor tIdThreadSafeBoolean.Create2 (Const aInitValue: Boolean);
begin
  Create;
  Self.Value := aInitValue;
end;

Function TIdThreadSafeBoolean.GetValue: Boolean;
begin
  Lock;
  Try
    Result := FValue;
  Finally
    Unlock;
  end;
end;

Procedure TIdThreadSafeBoolean.SetValue(const AValue: Boolean);
begin
  Lock;
  Try
    FValue := AValue;
  Finally
    Unlock;
  end;
end;

Function TIdThreadSafeBoolean.Toggle: Boolean;
begin
  Lock;
  Try
    FValue := not FValue;
    Result := FValue;
  Finally
    Unlock;
  end;
end;

 { TIdThreadSafeDateTime }
// Routine: Create
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes:
//
Procedure TIdThreadSafeDateTime.Add (Const AValue: TDateTime);
begin
  Lock;
  try
    FValue := FValue + AValue;
  finally
    Unlock;
  end;
end;

Function TIdThreadSafeDateTime.GetValue: TDateTime;
begin
  Lock;
  try
    Result := FValue;
  finally
    Unlock;
  end;
end;

Procedure TIdThreadSafeDateTime.SetValue (Const AValue: TDateTime);
begin
  Lock;
  try
    FValue := AValue;
  finally
    Unlock;
  end;
end;

Procedure TIdThreadSafeDateTime.Subtract (Const AValue: TDateTime);
begin
  Lock;
  try
    FValue := FValue - AValue;
  finally
    Unlock;
  end;
end;

{$ENDIF}

{$IFDEF VER150}

{ tMASQueue }

Function tMASQueue.fnPopItem: Pointer;
begin
  Result := Nil;
  if (Self.Count > 0) then Result := Self.PopItem;
end;

Function tMASQueue.GetCapacity: Integer;
begin
  Result := Self.List.Capacity;
end;
Procedure tMASQueue.SetCapacity (Const aValue: Integer);
begin
  Self.List.Capacity := aValue;
end;

{ tMASQueueItem }

Constructor tMASQueueItem.Create (Const aStr: String);
begin
  fStr  := aStr;
  fCode := cMC_UNKNOWN;
end;
Constructor tMASQueueItem.Create (Const aCode: Integer; Const aStr: String);
begin
  fStr  := aStr;
  fCode := aCode;
end;

{ tSimpleThreadSafeStringQueue }

// Routine: Create
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes: Need to come back to this, currentlky hard coded 4000 spin locks, need a timeout in milli seconds
//        as per parameter, but currently this will do 
//
Constructor tSimpleThreadSafeStringQueue.Create (Const aQueueSize: Integer = 100; Const aAccessTimeOut: Cardinal = Infinite);
begin
  fShutDown := False;
  fLock     := tMASCriticalSection.Create (csTryAndWait, 4000);
  fQueue    := tMASQueue.Create;
  fQueue.SetCapacity (aQueueSize);
end;

// Routine: Destroy
// Author: M.A.Sargent  Date: 14/03/18  Version: V1.0
//
// Notes:
//
Destructor tSimpleThreadSafeStringQueue.Destroy;
begin
  LockList;
  Try
    fnClear;
    fQueue.Free;
  Finally
    UnLockList;
    fLock.Free;
  end;
end;

// Routine: fnClear
// Author: M.A.Sargent  Date: 08/03/18  Version: V1.0
//
// Notes:
//
Function tSimpleThreadSafeStringQueue.fnClear: tOKIntegerRec;
var
  lvItem: tObject;
begin
  Result := fnClear_OKIntegerRec;
  Result.OK := (LockList <> wrTimeOut);
  if (not Result.OK) then Exit;
  Try
    Repeat
      lvItem := fQueue.fnPopItem;
      if Assigned (lvItem) then lvItem.Free;
    until not Assigned (lvItem);

  Finally
    UnLockList;
  end;
end;

// Routine: DoShutDown
// Author: M.A.Sargent  Date: 08/06/18  Version: V1.0
//
// Notes:
//
Procedure tSimpleThreadSafeStringQueue.DoShutDown;
begin
  LockList;
  Try
    fShutDown := True;
  Finally
    UnLockList;
  end;
end;

// Routine: fnCount
// Author: M.A.Sargent  Date: 08/06/18  Version: V1.0
//
// Notes:
//
Function tSimpleThreadSafeStringQueue.fnCount: Integer;
var
  lvRes: tOKIntegerRec;
begin
  lvRes := fnCount2;
  fnRaiseOnFalse (lvRes.OK, 'Error: fnCount. Failed to Obtain Lock');
  Result := lvRes.Int;
end;
Function tSimpleThreadSafeStringQueue.fnCount2: tOKIntegerRec;
begin
  Result := fnClear_OKIntegerRec;
  Result.OK := (LockList <> wrTimeOut);
  if (not Result.OK) then Exit;
  Try
    Result.Int := fQueue.Count;
  Finally
    UnLockList;
  end;
end;

// Routine: fnPercentage
// Author: M.A.Sargent  Date: 08/03/18  Version: V1.0
//
// Notes:
//
Function tSimpleThreadSafeStringQueue.fnPercentage: tOKIntegerRec;
var
  lvQueue: tMASQueue;
begin
  Result := fnClear_OKIntegerRec;
  Result.OK := (LockList (lvQueue) <> wrTimeOut);
  if (not Result.OK) then Exit;
  Try
    Result.Int := fnPercent (lvQueue.Count, lvQueue.Capacity);
  Finally
    UnLockList;
  end;
end;

// Routine: fnPop
// Author: M.A.Sargent  Date: 08/03/18  Version: V1.0
//
// Notes:
//
Function tSimpleThreadSafeStringQueue.fnPop (var aStr: String): tWaitResult;
var
  lvJunk: Integer;
begin
  Result := fnPop (lvJunk, aStr);
end;
function tSimpleThreadSafeStringQueue.fnPop (var aCode: Integer; var aStr: String): tWaitResult;
var
  lvItem: tObject;
begin
  Result := LockList;
  if (Result = wrTimeOut) then Exit;
  Try
    //
    lvItem := fQueue.fnPopItem;
    Case Assigned (lvItem) of
      True: begin
        aStr  := tMASQueueItem (lvItem).Str;
        aCode := tMASQueueItem (lvItem).Code;
        lvItem.Free;
      end;
      else Result := wrTimeOut;
    end;
  Finally
    UnLockList;
  end;
end;

// Routine: fnPush
// Author: M.A.Sargent  Date: 08/06/18  Version: V1.0
//
// Notes:
//
Function tSimpleThreadSafeStringQueue.fnPush (Const aStr: String): tWaitResult;
begin
  Result := fnPush(0, aStr);
end;
Function tSimpleThreadSafeStringQueue.fnPush (Const aCode: Integer; Const aStr: String): tWaitResult;
begin
  if fShutDown then begin
    Result := wrTimeOut;
    Exit;
  end;
  //
  Result := LockList;
  if (Result = wrTimeOut) then Exit;
  Try
    fQueue.PushItem (tMASQueueItem.Create (aCode, aStr));
  Finally
    UnLockList;
  end;
end;


Function tSimpleThreadSafeStringQueue.LockList: tWaitResult;
var
  lvJunk: tMASQueue;
begin
  Result := LockList (lvJunk);
end;
Function tSimpleThreadSafeStringQueue.LockList (var aQueue: tMASQueue): tWaitResult;
begin
  aQueue := Nil;
  Case fLock.Enter of
    True: Result := wrSignalled;
    else  Result := wrTimeOut;
  end;
  if (Result = wrSignalled) then aQueue := fQueue;
end;

Procedure tSimpleThreadSafeStringQueue.UnLockList;
begin
  fLock.Leave;
end;
{$ENDIF}


{ tMASThreadSafeIni }

Constructor tMASThreadSafeIni.Create (Const aFileName: String);
begin
  inherited Create;
  fnRaiseOnFalse ((aFileName <> ''), 'Error: tMASThreadSafeIni. aFilename cannot be left blank');
  //
  fIniFile := tMASIni.Create (aFileName);
end;

Destructor tMASThreadSafeIni.Destroy;
begin
  inherited Lock;
  Try
    FreeAndNil (fIniFile);
  Finally
    inherited Unlock;
  end;
  inherited;
end;

Function tMASThreadSafeIni.Lock: tMASIni;
begin
  inherited Lock;
  Result := fIniFile;
end;

Procedure tMASThreadSafeIni.Unlock;
begin
  Inherited UnLock;
end;

// Routine:  ReadString, ReadInteger & ReadBoolean
// Author: M.A.Sargent  Date: 10/10/17  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeIni.ReadString (Const Section, Ident, Default: String): string;
begin
  with Lock do
    Try
      Result := fIniFile.ReadString (Section, Ident, Default);
    Finally
      UnLock;
    end;
end;
Function tMASThreadSafeIni.ReadInteger (Const Section, Ident: String; Const aDefault: Integer): Integer;
begin
  with Lock do
    Try
      Result := fIniFile.ReadInteger (Section, Ident, aDefault);
    Finally
      UnLock;
    end;
end;
Function tMASThreadSafeIni.ReadBoolean (Const Section, Ident: String; Const aDefault: Boolean): Boolean;
begin
  with Lock do
    Try
      Result := fIniFile.ReadBoolean (Section, Ident, aDefault);
    Finally
      UnLock;
    end;
end;

// Routine:  IniFileLoadedOK
// Author: M.A.Sargent  Date: 10/10/17  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeIni.IniFileLoadedOK: Boolean;
begin
  with Lock do
    Try
      Result := IniFileLoadedOK;
    Finally
      UnLock;
    end;
end;

// Routine:  fnFileName
// Author: M.A.Sargent  Date: 17/08/18  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeIni.fnFileName: String;
begin
  with Lock do
    Try
      Result := fIniFile.FileName;
    Finally
      UnLock;
    end;
end;

// Routine: fnFileName
// Author: M.A.Sargent  Date: 29/08/18  Version: V1.0
//
// Notes:
//
Procedure tMASThreadSafeIni.WriteString (Const Section, Ident, aValue: String);
begin
  with Lock do
    Try
      fIniFile.WriteString (Section, Ident, aValue);
    Finally
      UnLock;
    end;
end;
Procedure tMASThreadSafeIni.WriteInteger (Const Section, Ident: String; Const aValue: Integer);
begin
  with Lock do
    Try
      fIniFile.WriteInteger (Section, Ident, aValue);
    Finally
      UnLock;
    end;
end;

// Routine: Flush
// Author: M.A.Sargent  Date: 29/08/18  Version: V1.0
//
// Notes:
//
Procedure tMASThreadSafeIni.Flush;
begin
  with Lock do
    Try
      fIniFile.Flush;
    Finally
      UnLock;
    end;
end;

// Routine: fnExists
// Author: M.A.Sargent  Date: 29/08/18  Version: V1.0
//
// Notes:
//
Function tMASThreadSafeIni.fnExists (Const Section, Ident: String): Boolean;
begin
  with Lock do
  Try
    Result := fIniFile.ValueExists (Section, Ident);
  Finally
    UnLock;
  end;
end;

{ tMASThreadOKStrRec }

Constructor tMASThreadOKStrRec.Create;
begin
  inherited;
  Clear;
end;

Procedure tMASThreadOKStrRec.Clear;
begin
  Lock;
  Try
    fValue := fnClear_OKStrRec;
  Finally
    UnLock;
  end;
end;

Function tMASThreadOKStrRec.GetValue: tOKStrRec;
begin
  Lock;
  Try
    Result := fValue;
  Finally
    UnLock;
  end;
end;

Procedure tMASThreadOKStrRec.ValueSet (Const aValue: Boolean);
begin
  ValueSet (aValue, '');
end;

Procedure tMASThreadOKStrRec.ValueSet (Const aValue: Boolean; Const aMsg: String);
begin
  ValueSet (aValue, aMsg, 0);
end;

Procedure tMASThreadOKStrRec.ValueSet (Const aValue: Boolean; Const aCode: Integer);
begin
  ValueSet (aValue, '', aCode);
end;

Procedure tMASThreadOKStrRec.ValueSet (Const aValue: Boolean; Const aMsg: String; Const aCode: Integer);
begin
  Lock;
  Try
    fValue.OK  := aValue;
    fValue.Msg := aMsg;
    fValue.ExtendedInfoRec.aCode := aCode;
  Finally
    UnLock;
  end;
end;

Function tMASThreadOKStrRec.GetCode: Integer;
begin
  Result := GetValue.ExtendedInfoRec.aCode;
end;

Function tMASThreadOKStrRec.GetMsg: String;
begin
  Result := GetValue.Msg;
end;

Function tMASThreadOKStrRec.GetOK: Boolean;
begin
  Result := GetValue.OK;
end;

Procedure tMASThreadOKStrRec.SetCode (Const Value: Integer);
begin
  Lock;
  Try
    fValue.ExtendedInfoRec.aCode := Value;
  Finally
    UnLock;
  end;
end;

Procedure tMASThreadOKStrRec.SetMsg (Const Value: String);
begin
  Lock;
  Try
    fValue.Msg := Value;
  Finally
    UnLock;
  end;
end;

Procedure tMASThreadOKStrRec.SetOK (Const Value: Boolean);
begin
  Lock;
  Try
    fValue.OK  := Value;
  Finally
    UnLock;
  end;
end;

Procedure tMASThreadOKStrRec.SetValue (Const Value: tOKStrRec);
begin
  Lock;
  Try
    fValue := Value;
  Finally
    UnLock;
  end;
end;

end.
