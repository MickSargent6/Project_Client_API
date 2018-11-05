//
// Unit: VerboseLevelTypeU
// Author: M.A.Sargent  Date: 15/08/18  Version: V1.0
//
// Notes: This Class is Thread Safe,
//        Create one instance in each object that requires it.
//        If this object was passed to other Thread the set ThreadSafe True, all to do with the tFormatSettings
//        The internal list is not thread safe but is only used to hold messages that are written in the Create method
//        when a OnMessager event is assigned later
//           f := tTCP.Create             // any message output in the Creare method will be saveed until the OnMessge os Assigned
//           f.OnMessage := Int_OnMessage
//
unit VerboseLevelTypeU;

interface

Uses Classes, MAS_LocalityU, SysUtils, MASStringListU, MAS_FormatU, CriticalSectionU, MASRecordStructuresU, MAtchUtilsU;

Type
  tTSVerboseLevel   = (tsvlNormal, tsvlFull, tsvlError, tsvlException);
  tOnVerboseMessage = Procedure (Const aLevel: tTSVerboseLevel; Const aMsg: String) of object;

  tVerboseClass = Class (tObject)
  Private
    fErrorCount:       tIntegerPair;
    fCS:               tMASCriticalSection;
    fFormatSettings:   tFormatSettings;
    fOnVerboseMessage: tOnVerboseMessage;
    fVerboseLevel:     tTSVerboseLevel;
    fList:             tMASStringList;
    fThreadSafe:       Boolean;
    fName: String;
    //
    Function  GetVerboseLevel: tTSVerboseLevel;
    Procedure SetOnVerboseMessage (Const aEvent: tOnVerboseMessage);
    Procedure SetVerboseLevel     (Const Value: tTSVerboseLevel);
    Function  GetErrorCount: Integer;
    Function  GetExceptionCount: Integer;

  public
    Constructor Create; virtual;
    Constructor Create_UseHelperConstructors;
    Destructor  Destroy; override;
    Destructor  Destroy_UseHelperDestructor;

    Procedure AddMsg  (Const aMsg: String); overload;
    Procedure AddMsg  (Const aFormat: String; Const Args: Array of Const); overload;
    //
    Procedure AddMsg  (Const aVerboseLevel: tTSVerboseLevel; Const aMsg: String); overload;
    Procedure AddMsg  (Const aVerboseLevel: tTSVerboseLevel; Const aFormat: String; Const Args: Array of Const); overload;
    //
    Procedure AddMsgN (Const aRoutineName, aMsg: String); overload;
    Procedure AddMsgN (Const aRoutineName: String; Const aFormat: String; Const Args: Array of Const); overload;
    //
    Procedure AddMsgN (Const aRoutineName: String; Const aVerboseLevel: tTSVerboseLevel; Const aMsg: String); overload;
    Procedure AddMsgN (Const aRoutineName: String; Const aVerboseLevel: tTSVerboseLevel; Const aFormat: String; Const Args: Array of Const); overload;
    //
    Procedure AddException (Const aRoutineName: String; Const aExcp: Exception); overload;
    Procedure AddException (Const aRoutineName, aMsg: String; Const aExcp: Exception); overload;
    Procedure AddException (Const aRoutineName: String; Const aFormat: String; Const Args: Array of Const; Const aExcp: Exception); overload;

    property Name:             String            read fName             write fName;
    Property VerboseLevel:     tTSVerboseLevel   read GetVerboseLevel   write SetVerboseLevel;
    Property OnVerboseMessage: tOnVerboseMessage read fOnVerboseMessage write SetOnVerboseMessage;
    Property ThreadSafe:       Boolean           read fThreadSafe       write fThreadSafe default False;
    //
    Property ErrorCount:       Integer read GetErrorCount;
    Property ExceptionCount:   Integer read GetExceptionCount;
  end;

  // Helper procedures
  Function  h_fnGetGlobalVerboseLevel: tTSVerboseLevel;
  Procedure h_SetGlobalVerboseLevel (Const aLevel: tTSVerboseLevel);

  Function h_fnVerboseClassCreate   (Const aName: String): tVerboseClass; overload;
  Function h_fnVerboseClassCreate   (Const aName: String; Const aEvent: tOnVerboseMessage): tVerboseClass; overload;
  Function h_fnVerboseClassCreate   (Const aName: String; Const aVerboseLevel: tTSVerboseLevel; Const aEvent: tOnVerboseMessage): tVerboseClass; overload;
  //
  Procedure h_VerboseClassDestroy  (aObj: tVerboseClass);
  Function  h_fnVerboseClassReName (aObj: tVerboseClass; Const aNewName: String): Boolean;

implementation

Uses MASCommonU, TSUK_D7_ConstsU, TSUK_UtilsU;

var
  gblVerboseLevel: tIdThreadSafeVerboseLevel = Nil;
  gblVerboseList:  tMASThreadSafeStringList  = Nil;

// Routine: AddMsg
// Author: M.A.Sargent  Date: 15/08/18  Version: V1.0
//
// Notes:
//
Function h_fnGetGlobalVerboseLevel: tTSVerboseLevel;
begin
  Result := gblVerboseLevel.Value;
end;
Procedure h_SetGlobalVerboseLevel (Const aLevel: tTSVerboseLevel);
begin
  gblVerboseLevel.Value := aLevel;
end;

// Routine: AddMsg
// Author: M.A.Sargent  Date: 15/08/18  Version: V1.0
//
// Notes:
//
Function h_fnVerboseClassCreate (Const aName: String): tVerboseClass;
var
  lvJunk: tOnVerboseMessage;
begin
  lvJunk := Nil;
  Result := h_fnVerboseClassCreate (aName, gblVerboseLevel.Value, lvJunk);
end;
Function h_fnVerboseClassCreate (Const aName: String; Const aEvent: tOnVerboseMessage): tVerboseClass;
begin
  Result := h_fnVerboseClassCreate (aName, gblVerboseLevel.Value, aEvent);
end;
Function h_fnVerboseClassCreate (Const aName: String; Const aVerboseLevel: tTSVerboseLevel; Const aEvent: tOnVerboseMessage): tVerboseClass;
begin
  Result := tVerboseClass.Create_UseHelperConstructors;
  try
    Result.Name             := aName;
    Result.VerboseLevel     := aVerboseLevel;
    Result.OnVerboseMessage := aEvent;
    gblVerboseList.AddObject (aName, Result);
  Except
    FreeAndNil (Result);
    Raise;
  end;
end;

// Routine: h_fnVerboseClassDestroy
// Author: M.A.Sargent  Date: 15/08/18  Version: V1.0
//
// Notes:
//
Procedure h_VerboseClassDestroy (aObj: tVerboseClass);
var
  lvList: tStringList;
  x:      Integer;
begin
  lvList := gblVerboseList.Lock;
  Try
    for x := 0 to lvList.Count-1 do
      if (lvList.Objects [x] = aObj) then begin
         lvList.Delete (x);
         Break;
      end;
  Finally
    gblVerboseList.UnLock;
  end;
  FreeAndNil (aObj);
end;

// Routine: h_fnVerboseClassReName
// Author: M.A.Sargent  Date: 17/08/18  Version: V1.0
//
// Notes:
//
Function h_fnVerboseClassReName (aObj: tVerboseClass; Const aNewName: String): Boolean;
var
  lvList: tStringList;
  x:      Integer;
begin
  Result := False;
  lvList := gblVerboseList.Lock;
  Try
    for x := 0 to lvList.Count-1 do
      if (lvList.Objects [x] = aObj) then begin
         lvList.Strings [x] := aNewName;
         Result             := True;
         Break;
      end;
  Finally
    gblVerboseList.UnLock;
  end;
end;

{ tVerboseClass }

Constructor tVerboseClass.Create;
begin
  fCS                    := tMASCriticalSection.Create;
  fThreadSafe            := False;
  fErrorCount            := fnClear_IntegerPair;
  //
  fList                  := tMASStringList.Create;
  fFormatSettings        := fnTS_LocaleSettings;
  Self.VerboseLevel      := gblVerboseLevel.Value;
  Self.OnVerboseMessage  := Nil;
end;
Constructor tVerboseClass.Create_UseHelperConstructors;
begin
  Create;
end;

Destructor tVerboseClass.Destroy;
begin
  if Assigned (fList) then fList.Free;
  fCS.Free;
  inherited;
end;
Destructor tVerboseClass.Destroy_UseHelperDestructor;
begin
  Destroy;
end;

// Routine: AddMsg
// Author: M.A.Sargent  Date: 15/08/18  Version: V1.0
//
// Notes:
//
Procedure tVerboseClass.AddMsg (Const aMsg: String);
begin
  AddMsgN ('', tsvlNormal, aMsg);
end;
Procedure tVerboseClass.AddMsgN (Const aRoutineName, aMsg: String);
begin
  AddMsgN (aRoutineName, tsvlNormal, aMsg);
end;

Procedure tVerboseClass.AddMsg (Const aVerboseLevel: tTSVerboseLevel; Const aFormat: String; Const Args: array of Const);
begin
  Case fThreadSafe of
    True: AddMsgN ('', aVerboseLevel, fnTS_Format (aFormat, Args));
    else  AddMsgN ('', aVerboseLevel, Format (aFormat, Args, fFormatSettings));
  end;
end;
Procedure tVerboseClass.AddMsgN (Const aRoutineName: String; Const aVerboseLevel: tTSVerboseLevel; Const aFormat: String; Const Args: array of Const);
begin
  Case fThreadSafe of
    True: AddMsgN (aRoutineName, aVerboseLevel, fnTS_Format (aFormat, Args));
    else  AddMsgN (aRoutineName, aVerboseLevel, Format (aFormat, Args, fFormatSettings));
  end;
end;

Procedure tVerboseClass.AddMsg (Const aFormat: String; Const Args: array of Const);
begin
  Case fThreadSafe of
    True: AddMsgN ('', tsvlNormal, fnTS_Format (aFormat, Args));
    else  AddMsgN ('', tsvlNormal, Format (aFormat, Args, fFormatSettings));
  end;
end;
Procedure tVerboseClass.AddMsgN (Const aRoutineName, aFormat: String;const  Args: array of Const);
begin
  Case fThreadSafe of
    True: AddMsgN (aRoutineName, tsvlNormal, fnTS_Format (aFormat, Args));
    else  AddMsgN (aRoutineName, tsvlNormal, Format (aFormat, Args, fFormatSettings));
  end;
end;

Procedure tVerboseClass.AddMsg (Const aVerboseLevel: tTSVerboseLevel; Const aMsg: String);
begin
  AddMsgN ('', aVerboseLevel, aMsg);
end;

Procedure tVerboseClass.AddMsgN (Const aRoutineName: String; Const aVerboseLevel: tTSVerboseLevel; Const aMsg: String);

  // Check the Verbose Level
  Function fnOK (Const aVerboseLevel: tTSVerboseLevel): Boolean;
  begin
    Result := (aVerboseLevel in [tsvlError, tsvlException]);
    if not Result then Result := (Ord (aVerboseLevel) <=  Ord (VerboseLevel));//
    Case aVerboseLevel of
      tsvlError:     fErrorCount.Int1 := fnInc (fErrorCount.Int1);
      tsvlException: fErrorCount.Int2 := fnInc (fErrorCount.Int2);
    end;
  end;

  Function Int_FormatName (Const aName, aMsg: String): String;
  begin
    if IsEmpty (aName) then Result := aMsg
    else                    Result := ('('+aName+') ' + aMsg);
  end;
begin
  if fnOK (aVerboseLevel) then begin
    fCS.Enter;
    Try
      if Assigned (OnVerboseMessage) then begin
        OnVerboseMessage (aVerboseLevel, Int_FormatName (aRoutineName, aMsg));
      end
      else fList.AddValues (fnVerboseLevelToStr (aVerboseLevel), Int_FormatName (aRoutineName, aMsg));
    Finally
      fCS.Leave;
    end;
  end;
end;

// Routine: AddException
// Author: M.A.Sargent  Date: 15/08/18  Version: V1.0
//
// Notes:
//
Procedure tVerboseClass.AddException (Const aRoutineName, aFormat: String; Const Args: array of Const; Const aExcp: Exception);
begin
  Case fThreadSafe of
    True: AddException (aRoutineName, fnTS_Format (aFormat, Args), aExcp);
    else  AddException (aRoutineName, Format (aFormat, Args, fFormatSettings), aExcp);
  end;
end;

Procedure tVerboseClass.AddException (Const aRoutineName, aMsg: String; Const aExcp: Exception);
var
  lvMsg: string;
begin
  lvMsg := 'Exception: ';
  if not IsEmpty (aRoutineName) then lvMsg := (lvMsg + aRoutineName + '. ');
  if not IsEmpty (aMsg) then          lvMsg := (lvMsg + aMsg + '. ');
  if Assigned (aExcp) then begin
    if not IsEqual (aExcp.ClassName, 'Exception') then lvMsg := (lvMsg + '(' + aExcp.ClassName) +'). ';
    lvMsg := (lvMsg + aExcp.Message);
  end;
  AddMsg (tsvlException, lvMsg);
end;

Procedure tVerboseClass.AddException (Const aRoutineName: String; Const aExcp: Exception);
begin
  AddException (aRoutineName, '', aExcp);
end;

// Routine: SetOnVerboseMessage
// Author: M.A.Sargent  Date: 15/08/18  Version: V1.0
//
// Notes:
//
Procedure tVerboseClass.SetOnVerboseMessage (Const aEvent: tOnVerboseMessage);

  // Add any records that are contained in the fList to the Output Queue/Event
  Procedure Int_SendToQueue;
  var
    x:      Integer;
    lvPair: tValuePair;
  begin
    if Assigned (fList) then begin
      Try
        //
        for x := 0 to fList.Count-1 do begin
          lvPair := fList.fnValuePair (x);
          aEvent (fnStrToVerboseLevel (lvPair.Name), lvPair.Value);
        end;
      Finally
        FreeAndNil (fList);
      end;
    end;
  end;

begin
  fCS.Enter;
  Try
    // If being set to Nil
    if not Assigned (aEvent) then begin
      fOnVerboseMessage := aEvent;
      Exit;
    end;
    // Process any records in the fList
    Int_SendToQueue;
    fOnVerboseMessage := aEvent;
  Finally
    fCS.Leave;
  end;
end;

// Routine:
// Author: M.A.Sargent  Date: 15/08/18  Version: V1.0
//
// Notes:
//
Function tVerboseClass.GetVerboseLevel: tTSVerboseLevel;
begin
  Result := fVerboseLevel;
end;
Procedure tVerboseClass.SetVerboseLevel (Const Value: tTSVerboseLevel);
begin
  fVerboseLevel := Value;
end;

// Routine: GetErrorCount & GetExceptionCount
// Author: M.A.Sargent  Date: 15/08/18  Version: V1.0
//
// Notes:
//
Function tVerboseClass.GetErrorCount: Integer;
begin
  Result := fErrorCount.Int1;
end;
Function tVerboseClass.GetExceptionCount: Integer;
begin
  Result := fErrorCount.Int2;
end;

Initialization
  gblVerboseLevel := tIdThreadSafeVerboseLevel.Create;
  gblVerboseList  := tMASThreadSafeStringList.Create_D7 (False);
  gblVerboseList.OwnsObjects := False;
finalization
  gblVerboseLevel.Free;
  gblVerboseList.Free;
end.
