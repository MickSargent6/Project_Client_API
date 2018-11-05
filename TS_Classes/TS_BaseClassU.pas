//
// Unit: TS_BaseClassU
// Author: M.A.Sargent  Date: 29/03/18  Version: V1.0
//
// Notes:
//
unit TS_BaseClassU;

interface

Uses Classes, IdThreadSafe, VerboseLevelTypeU,
     {$IFDEF VER150}
     TSUK_D7_ConstsU,
     {$ELSE}
     TSUK_ConstsU,
     {$ENDIF}
     TS_SystemVariablesU, TSUK_UtilsU, MAS_IniU, SysUtils, CriticalSectionU;

Type
  tTS_AbstractBaseClass = Class (tObject)
  Private
    fVerboseLevel:          tIdThreadSafeVerboseLevel;
    fCommonDir:             String;
    fEnabled:               tIdThreadSafeBoolean;
    fCommonIni:             tMASIni;
    //
    Function  GetEnabled:       Boolean;
    Procedure SetEnabled        (Const Value: Boolean);
    Function  GetVerboseLevel:  tTSVerboseLevel;
    Procedure SetVerboseLevel   (Const Value: tTSVerboseLevel);
    Procedure DoVerboseLevel    (Const aValue: tTSVerboseLevel);
    Procedure Int_DoLogMsg      (Const aVerboseLevel: tTSVerboseLevel; Const aMsg: String);
  Protected
    Procedure LogMsg       (Const aMsg: String); overload;
    Procedure LogMsg       (Const aName, aMsg: String); overload;
    Procedure LogMsg       (Const aVerboseLevel: tTSVerboseLevel; Const aMsg: String); overload;
    Procedure LogMsg       (Const aVerboseLevel: tTSVerboseLevel; Const aName, aMsg: String); overload;
    Procedure LogMsg       (Const aFormat: string; Const Args: array of Const); overload;
    Procedure LogMsg       (Const aName, aFormat: string; Const Args: array of Const); overload;
    Procedure LogMsg       (Const aVerboseLevel: tTSVerboseLevel; Const aFormat: string; Const Args: array of Const); overload;
    Procedure LogMsg       (Const aVerboseLevel: tTSVerboseLevel; Const aName, aFormat: string; Const Args: array of Const); overload;
    //
    Procedure LogException (Const aLocationName: String; Const aExcp: Exception); overload;
    Procedure LogException (Const aLocationName, aMsg: String; Const aExcp: Exception); overload;
    //
    Procedure DoLogMsg   (Const aVerboseLevel: tTSVerboseLevel; Const aMsg: String); virtual; abstract;
    Procedure DoClear;   virtual;
    Procedure DoEnabled  (Const aEnabled: Boolean); virtual;
    //
    Property CommonDir:     String          read fCommonDir;
    Property CommonIni:     tMASIni         read fCommonIni      write fCommonIni;
    // This VerboseLevel is used in the BaseClass it is just Set so it can be used by ither class as the default
    Property VerboseLevel:  tTSVerboseLevel read GetVerboseLevel write SetVerboseLevel;

  Public
    Constructor Create (Const aCommonDir: String); virtual;
    Destructor Destroy; override;
    Procedure Clear; virtual;
    //
    Property Enabled: Boolean read GetEnabled write SetEnabled;
  End;

  {}
  tTS_BaseClass = Class (tTS_AbstractBaseClass)
  Private
    fLogFileName:           String;
  Protected
    Property LogFileName:   String          read fLogFileName;
  Public
    Constructor Create (Const aCommonDir, aLogFileName: String); reintroduce; virtual;
  end;


implementation

Uses MAS_FormatU;

{ tTS_BaseClass }

// Routine: Create
// Author: M.A.Sargent  Date: 28/03/18  Version: V1.0
//
// Notes:
//
Constructor tTS_AbstractBaseClass.Create (Const aCommonDir: String);
begin
  fCommonDir          := aCommonDir;
  fVerboseLevel       := tIdThreadSafeVerboseLevel.Create;
  fVerboseLevel.Value := tsvlNormal;
  fEnabled            := tIdThreadSafeBoolean.Create;
  fEnabled.Value      := False;
  fCommonIni          := tMASIni.CreateFromDir (aCommonDir);
  //
end;

// Routine: FormDestroy
// Author: M.A.Sargent  Date: 28/03/18  Version: V1.0
//
// Notes:
//
Destructor tTS_AbstractBaseClass.Destroy;
begin
  fCommonIni.Free;
  inherited;
end;

Procedure tTS_AbstractBaseClass.Clear;
begin
  DoClear;
end;

Procedure tTS_AbstractBaseClass.DoClear;
begin
end;

// Routine: GetEnabled, SetEnabled & DoEnabled
// Author: M.A.Sargent  Date: 28/03/18  Version: V1.0
//
// Notes:
//
Function tTS_AbstractBaseClass.GetEnabled: Boolean;
begin
  Result := fEnabled.Value;
end;
Procedure tTS_AbstractBaseClass.SetEnabled (Const Value: Boolean);
begin
  fEnabled.Value := Value;
  DoEnabled (Value);
end;
Procedure tTS_AbstractBaseClass.DoEnabled (Const aEnabled: Boolean);
begin
end;

// Routine: GetVerboseLevel, SetVerboseLevel & DoVerboseLevel
// Author: M.A.Sargent  Date: 28/03/18  Version: V1.0
//
// Notes:
//
Function tTS_AbstractBaseClass.GetVerboseLevel: tTSVerboseLevel;
begin
  Result := fVerboseLevel.Value;
end;
Procedure tTS_AbstractBaseClass.SetVerboseLevel (Const Value: tTSVerboseLevel);
begin
  fVerboseLevel.Value := Value;
  DoVerboseLevel (Value);
end;
Procedure tTS_AbstractBaseClass.DoVerboseLevel (Const aValue: tTSVerboseLevel);
begin
end;

// Routine: LogMsg & LogException
// Author: M.A.Sargent  Date: 24/04/18  Version: V1.0
//
// Notes:
//
Procedure tTS_AbstractBaseClass.LogMsg (Const aMsg: String);
begin
  LogMsg (tsvlNormal, aMsg);
end;
Procedure tTS_AbstractBaseClass.LogMsg (Const aName, aMsg: String);
begin
  LogMsg (aName+': '+aMsg);
end;
Procedure tTS_AbstractBaseClass.LogMsg (Const aVerboseLevel: tTSVerboseLevel; Const aMsg: String);
begin
  Int_DoLogMsg (aVerboseLevel, aMsg);
end;
procedure tTS_AbstractBaseClass.LogMsg (Const aVerboseLevel: tTSVerboseLevel; Const aName, aMsg: String);
begin
  LogMsg (aVerboseLevel, (aName+': '+aMsg));
end;
Procedure tTS_AbstractBaseClass.LogMsg (Const aFormat: String; Const Args: array of Const);
begin
  LogMsg (tsvlNormal, aFormat, Args);
end;
procedure tTS_AbstractBaseClass.LogMsg (Const aName, aFormat: string; Const  Args: array of Const);
begin
   LogMsg (tsvlNormal, (aName+': '+fnTS_Format (aFormat, Args)));
end;
Procedure tTS_AbstractBaseClass.LogMsg (Const aVerboseLevel: tTSVerboseLevel; Const aFormat: String; Const Args: array of Const);
var
  lvStr: String;
begin
  lvStr := fnTS_Format (aFormat, Args);
  LogMsg (aVerboseLevel, lvStr);
end;
procedure tTS_AbstractBaseClass.LogMsg (Const aVerboseLevel: tTSVerboseLevel; Const aName, aFormat: string; Const Args: array of Const);
begin
  LogMsg (aVerboseLevel, (aName+': '+fnTS_Format (aFormat, Args)));
end;

// Routine: LogMsg & LogException
// Author: M.A.Sargent  Date: 09/04/18  Version: V1.0
//
// Notes:
//
procedure tTS_AbstractBaseClass.LogException (Const aLocationName: String; Const aExcp: Exception);
begin
  LogMsg (tsvlException, 'Error: (%s). LogException. (%s). (%s)', [Self.ClassName, aLocationName, aExcp.Message]);
end;
Procedure tTS_AbstractBaseClass.LogException (Const aLocationName, aMsg: String; Const aExcp: Exception);
begin
  LogMsg (tsvlException, 'Error: (%s). LogException. (%s). %s (%s)', [Self.ClassName, aLocationName, aMsg, aExcp.Message]);
end;

// Routine: Int_DoLogMsg
// Author: M.A.Sargent  Date: 13/03/18  Version: V1.0
//
// Notes: The Method
//                   DoLogMsg is abstract so it must be overriden
Procedure tTS_AbstractBaseClass.Int_DoLogMsg (Const aVerboseLevel: tTSVerboseLevel; Const aMsg: String);

  Function fnOK (Const aVerboseLevel: tTSVerboseLevel): Boolean;
  begin
    Result := (aVerboseLevel in [tsvlError, tsvlException]);
    if not Result then Result := (Ord (aVerboseLevel) <=  Ord (Self.VerboseLevel));
  end;
begin
  if fnOK (aVerboseLevel) then DoLogMsg (aVerboseLevel, aMsg);
  //OutputDebugString (aMsg);
end;

{ tTS_BaseClass }

Constructor tTS_BaseClass.Create (Const aCommonDir, aLogFileName: String);
begin
  inherited Create (aCommonDir);
  //
  fLogFileName := aLogFileName;
end;

end.
