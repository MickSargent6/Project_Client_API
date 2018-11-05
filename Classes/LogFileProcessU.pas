//
// Unit: LogFileProcessU
// Author: M.A.Sargent  Date: 28/06/08  Version: V1.0
//         M.A.Sargent        12/11/11           V2.0
//         M.A.Sargent        25/02/12           V3.0
//         M.A.Sargent        23/07/13           V4.0
//         M.A.Sargent        20/12/16           V5.0
//
// Notes:
//  V2.0: Updated assign the new ThreadName property
//  V3.0: Updated IntOpen
//  V4.0: Updated to add CreateDateLogFile method
//  V5.0: Updated to add:
//          1. New constructir
//          2. new AddLine method
//
unit LogFileProcessU;

interface

Uses Classes, TextFileIO, BaseEventThreadU, SysUtils, CriticalSectionU,
      Controls, MASCommonU, MAS_DirectoryU, Windows;

Type
  tWriterThread = Class (tBaseThread)
  private
    fLastWrite: tDate;
    fTextFile: tTextFile;
    fThreadSafeFormat: tFormatSettings;
    fLastTime: String;
    procedure IntOpen (Const aFileName: String);
    procedure IntAddLine (Const aLine: String);
    procedure CloseFileIfOpen;
  Protected
    Procedure DoAfterExecute; override;
    Procedure DoCompleted; override;
  Public
    Constructor Create (CreateSuspended: Boolean);
    Destructor Destroy; override;
    Procedure AddList (Const aFileName: String; Const aList: tStrings);
    Procedure AddLine (Const aFileName: String; Const aLine: String);
  end;

  tBaseLogFileWriter = Class (tObject)
  private
    fInitialFileName: String;
    fFileName: String;
    fThread: tWriterThread;
    procedure SetFileName(const Value: String);
  Public
    Constructor Create; overload;
    Constructor Create (Const aFileName: String; Const CreateIt: Boolean); overload;
    Constructor CreateDateStamp (Const aFileName: String; Const CreateIt: Boolean); overload;
    Destructor Destroy; override;
    Procedure AddLine (Const aLine: String); overload;
    Procedure AddLine (Const Format: string; const Args: array of const); overload;
    Procedure AddList (Const aList: tStrings);
    //
    Function CreateDateLogFile: Boolean;
    //
    Property FileName: String read fFileName write SetFileName;
  end;

var
  gblWriteLog: tMASCriticalSection = Nil;

implementation

Uses DateUtils, MAS_FormatU;

{ tWriterThread }

Constructor tWriterThread.Create (CreateSuspended: Boolean);
begin
  Inherited Create (CreateSuspended);
  fTextFile := tTextFile.Create;
  SleepInterval := 500;
  //
  GetLocaleFormatSettings (LOCALE_SYSTEM_DEFAULT, fThreadSafeFormat);
end;

Destructor tWriterThread.Destroy;
begin
  if Assigned (fTextFile) then fTextFile.Free;
  inherited;
end;

Procedure tWriterThread.AddList (Const aFileName: String; Const aList: tStrings);
var
  x: Integer;
begin
  gblWriteLog.Enter;
  Try
    IntOpen (aFileName);
    for x := 0 to aList.Count-1 do
      IntAddLine (aList.Strings[x]);
  Finally
    gblWriteLog.Leave;
  End;
end;

Procedure tWriterThread.AddLine (Const aFileName: String; Const aLine: String);
begin
  gblWriteLog.Enter;
  Try
    IntOpen (aFileName);
    IntAddLine (aLine);
  Finally
    gblWriteLog.Leave;
  End;
end;

Procedure tWriterThread.IntAddLine (Const aLine: String);
begin
  fTextFile.Append (aLine);
  fLastWrite := Now;
end;

// Routine: IntOpen
// Author: M.A.Sargent  Date: 25/02/12  Version: V1.0
//
// Notes: Only output the Time Stamp if it has changed
//
Procedure tWriterThread.IntOpen (Const aFileName: String);
var
  lvLastTime: String;
begin
  if not IsEqual (fTextFile.FileName, aFileName) then begin
    // Close File if Open
    if fTextFile.IsOpen then
      if not fTextFile.CloseFile then
        Raise Exception.CreateFmt ('Error: File (%s) Could Not Be Closed', [fTextFile.FileName]);
  end;
  // Assign and Create new Output File
  if not fTextFile.IsOpen then begin
    fTextFile.CreateWriteFile (aFileName);
    if not fTextFile.IsOpen then
      Raise Exception.CreateFmt ('Error: File (%s) Could Not Be Opened', [fTextFile.FileName]);
  end;
  // Only Output the Time when it has changed
  lvLastTime := FormatDateTime ('[DD/MM/YY HH:NN:SS]', Now, fThreadSafeFormat);
  if not IsEqual (fLastTime, lvLastTime) then IntAddLine (lvLastTime);
  fLastTime := lvLastTime;
end;

procedure tWriterThread.DoAfterExecute;
begin
  if (SecondsBetween (Now, fLastWrite) > 5) then
    CloseFileIfOpen;
  Inherited;
end;

// Routine: CloseFileIfOpen
// Author: M.A.Sargent  Date: 24/06/11  Version: V1.0
//
// Notes:
//
procedure tWriterThread.CloseFileIfOpen;
begin
  gblWriteLog.Enter;
  Try
    if fTextFile.IsOpen then begin
      if not fTextFile.CloseFile then
        Raise Exception.CreateFmt ('Error: File (%s) Could Not Be Closed', [fTextFile.FileName]);
    end;
  Finally
    gblWriteLog.Leave;
  End;
end;

procedure tWriterThread.DoCompleted;
begin
  inherited;
  CloseFileIfOpen;
end;

{ tBaseLogFileWriter }

// Routine: Create
// Author: M.A.Sargent  Date: 12/11/11  Version: V1.0
//
// Notes:
//
constructor tBaseLogFileWriter.Create;
begin
  fThread := tWriterThread.Create (True);
  fThread.ThreadName := 'BaseLogFileWriter';
  fThread.Resume;
end;

constructor tBaseLogFileWriter.Create (Const aFileName: String; Const CreateIt: Boolean);
begin
  if not fnCheckDirectory (aFileName, CreateIt) then Raise Exception.CreateFmt ('Error: Directory Path Not Found or Created (%s)', [aFileName]);
  Create;
  if (aFileName<> '') then FileName := aFileName;
end;

Constructor tBaseLogFileWriter.CreateDateStamp (Const aFileName: String; Const CreateIt: Boolean);
begin
  Create (aFileName, CreateIt);
  CreateDateLogFile;
end;

destructor tBaseLogFileWriter.Destroy;
begin
  ReleaseThread (tThread (fThread));
  inherited;
end;

procedure tBaseLogFileWriter.AddLine (Const Format: string; const Args: array of const);
begin
  AddLine (fnTS_Format (Format, Args));
end;

procedure tBaseLogFileWriter.AddLine (Const aLine: String);
begin
  Try
    if (fFileName='') then
      Raise Exception.Create ('Error: A FileName Has Not Been Set');
    fThread.AddLine (fFileName, aLine);
  Except
    on e:Exception do begin
      Raise Exception.CreateFmt ('Error: AddLine: %s', [e.Message]);
    end;
  end;
end;

procedure tBaseLogFileWriter.AddList (Const aList: tStrings);
begin
  Try
    if (fFileName='') then
      Raise Exception.Create ('Error: A FileName Has Not Been Set');
    fThread.AddList (fFileName, aList);
  Except
    on e:Exception do begin
      Raise Exception.CreateFmt ('Error: AddLine: %s', [e.Message]);
    end;
  end;
end;

// Routine: CreateDateLogFile
// Author: M.A.Sargent  Date: 15/07/13  Version: V1.0
//
// Notes:
//
Function tBaseLogFileWriter.CreateDateLogFile: Boolean;
begin
  Result := (fInitialFileName <> '');
  if not Result then Exit;
  //
  FileName := fnGenFileName (fInitialFileName, fntDate);
  //
end;

procedure tBaseLogFileWriter.SetFileName(const Value: String);
begin
  fFileName := Value;
  if (fInitialFileName = '') then fInitialFileName := fFileName;
end;

initialization
  gblWriteLog := tMASCriticalSection.Create;

finalization
  gblWriteLog.Free;

end.
