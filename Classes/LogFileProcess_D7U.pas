//
// Unit: LogFileProcess2U
// Author: M.A.Sargent  Date: 25/05/2018  Version: V1.0
//         M.A.Sargent        31/05/2018           V2.0
//         M.A.Sargent        22/07/2018           V3.0
//         M.A.Sargent        22/08/2018           V4.0
//
// Notes: New Version, dated the old version, easy to create sub classes to impliment writing to anything
//        Contains Base classes and implimenttion if a Text File writter, very common
//  V2.0: Updated to add a TimeSTamp option, was present in the other versions
//  V3.0: Updated DoCompleted and added method ProcessOuterQueue;
//  V4.0: Use new version to D7 Mutex DLL
//
// TODO: 1. (DONE) Add a Mutex section when writing to Text file incase many object try and write to the same file
//       2. Exception logging
//       3. ProcessInnerQueue parameter setting to exception count 
//
unit LogFileProcess_D7U;

interface

Uses Classes, TextFileIO, BaseEventThreadU, SysUtils, CriticalSectionU, Controls, MASCommonU, MAS_DirectoryU, Windows,
      MASDatesU, MAS_JSon_D7U, MAS_TimerU, D7_FileLockMutex_HelpersU, MASRecordStructuresU, MAS_ConstsU;

Type
  tFileNameChange = Procedure (Sender: tObject; Const aFileName: String) of object;

  tWriterThread = Class (tBaseThread)
  private
    fLastWrite:           tDateTime;
    fInnerList:           tStringList;
    fOuterListQueue:      tMASThreadSafeStringList;
    fThreadExceptionList: tMASThreadSafeStringList;
    fTimeStamp:           Boolean;
    fThreadSafeFormat:    tFormatSettings;
    fFailureCounter:      tIntegerPair;
    fWriteFailureCount:   Integer;
    //
    Procedure ProcessOuterQueue;
    Procedure ProcessInnerQueue;
    //
    Procedure Int_AddExceptionMessage (Const aMsg: String);
    //
    Property  InnerList: tStringList read fInnerList write fInnerList;
  Protected
    Procedure DoSetup; virtual;
    Procedure DoProcessInnerQueue (var aProcessedOK: Boolean); virtual;

    Procedure DoTimeEvent (Const aTimeEvent: tTimeEvent); override;
    Procedure DoExecute;      override;
    Procedure DoAfterExecute; override;
    Procedure DoCompleted;    override;
    Procedure ExceptionHandlerInner (Const aException: Exception; var aHandled: Boolean); override;

    // Used to get data in SubClassed versions
    Function  fnInnerList_Count: Integer;
    Function  fnInnerList_Data (Const aIdx: Integer): String;
    Procedure InnerList_Clear;
    Procedure InnerList_AddTo  (Const aMsg: String);
    //
    Property  LastWrite: tDateTime read fLastWrite write fLastWrite;
  Public
    Constructor Create (CreateSuspended: Boolean; Const aListQueue, aExceptionList: tMASThreadSafeStringList); virtual;
    Destructor Destroy; override;
    //
    Property TimeStamp:         Boolean read fTimeStamp         write fTimeStamp         default True;
    Property WriteFailureCount: Integer read fWriteFailureCount write fWriteFailureCount default cMC_TEN;
  end;

  // Text file write is a implimentation of tWriterThread,
  //
  //
  tWriterThread_Text = Class (tWriterThread)
  Private
    fInitialFileName:        String;
    fFileName:               tMASThreadSafeString;
    fTextFile:               tTextFile;
    fOnThreadFileNameChange: tNotifyEvent;
    //
    Function  GetFileName: String;
    Procedure SetFileName (Const Value: String);
    Procedure Int_GenFileName;
  Protected
    Procedure DoProcessInnerQueue (var aProcessedOK: Boolean); override;
    Procedure DoTimeEvent         (Const aTimeEvent: tTimeEvent); override;
    Procedure DoCompleted;    override;
    //
    Property FileName: String read GetFileName Write SetFileName;

  Public
    Constructor Create          (Const aFileName: String; Const aListQueue, aExceptionList: tMASThreadSafeStringList); reintroduce; virtual;
    Constructor CreateDateStamp (Const aFileName: String; Const aListQueue, aExceptionList: tMASThreadSafeStringList); virtual;
    Destructor Destroy; override;
    //
    Property OnThreadFileNameChange: tNotifyEvent read fOnThreadFileNameChange write fOnThreadFileNameChange;
  end;

  //
  //
  //
  tBaseLogFileWriter = Class (tObject)
  private
    fThread:        tWriterThread;
    fListQueue:     tMASThreadSafeStringList;
    fExceptionList: tMASThreadSafeStringList;
    fTimeStamp:     Boolean;
    fDisplayName:   String;
    //
    Procedure SetTimeStamp (Const Value: Boolean);
    Procedure SetThread    (Const Value: tWriterThread);
  Protected
    Procedure Int_DoException (Sender: tObject; Const ErrMsg: String);
    //
    Property Thread:        tWriterThread            read fThread        write SetThread;
    Property ListQueue:     tMASThreadSafeStringList read fListQueue     write fListQueue;
    property ExceptionList: tMASThreadSafeStringList read fExceptionList write fExceptionList;

  Public
    Constructor Create; overload;
    Destructor  Destroy; override;
    //
    Function fnZeroExceptions: Boolean;
    Function fnExceptions (var aList: tStrings; Const aClearList: Boolean = True): Integer;

    //
    Function fnAddLine         (Const aLine: String): Boolean; overload;
    Function fnAddLine         (Const Format: string; Const Args: array of const): Boolean; overload;
    Function fnAddList         (Const aList: tStrings): Boolean;
    // This is a simple array processing, it will create a JSON string of values that can be passed around
    Function fnAddArraysValues (Const aParams: array of string; Const aValues: array of string): Boolean;
    //
    Property TimeStamp:   Boolean read fTimeStamp   write SetTimeStamp default True;
    Property DisplayName: String  read fDisplayName write fDisplayName;
  end;

  //
  //
  //
  tTextLogFileWriter = Class (tBaseLogFileWriter)
  Private
    fOnTextLogFileNameChange: tFileNameChange;
    //
    Procedure Int_OnFileNameChange (Sender: TObject);
    Function  GetFileName: String;
  Public
    Constructor Create (Const aFileName: String; Const aDateTimeFile: Boolean); reintroduce; virtual;
    Destructor  Destroy; override;
    //
    Property FileName: String read GetFileName;
    Property OnTextLogFileNameChange: tFileNameChange read fOnTextLogFileNameChange write fOnTextLogFileNameChange;
  end;

  //
  Procedure SetTestFileNameDateFormat (Const aFileNameType: tFileNameType);

implementation

Uses DateUtils, MAS_FormatU, FormatResultU, MASStringListU;

Const
  cLOGWRITER_MUTEX = 'LOGWRITER_MUTEX';

var
  gblDateFormat: tFileNameType = fntDateYMD;   // Not Localised

Procedure SetTestFileNameDateFormat (Const aFileNameType: tFileNameType);
begin
  gblDateFormat := aFileNameType;
end;

{ tWriterThread }

// Routine: Create
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Constructor tWriterThread.Create (CreateSuspended: Boolean; Const aListQueue, aExceptionList: tMASThreadSafeStringList);
begin
  Inherited Create (CreateSuspended);
  fInnerList := tStringList.Create;
  //
  fWriteFailureCount   := cMC_TEN;
  fFailureCounter      := fnClear_IntegerPair;
  Self.NewLifeCycle    := True;
  Self.MustSynchronize := False;
  fTimeStamp           := True;
  fOuterListQueue      := aListQueue;
  fThreadExceptionList := aExceptionList;
  SleepInterval        := cMC_500Ms;
  //
  GetLocaleFormatSettings (LOCALE_SYSTEM_DEFAULT, fThreadSafeFormat);
end;

// Routine: Destroy
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Destructor tWriterThread.Destroy;
begin
  fInnerList.Free;
  inherited;
end;

// Routine: Int_AddExceptionMessage
// Author: M.A.Sargent  Date: 28/08/18  Version: V1.0
//
// Notes:
//
Procedure tWriterThread.Int_AddExceptionMessage (Const aMsg: String);
begin
  fThreadExceptionList.Add (aMsg);
end;

// Routine: DoSetup
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Procedure tWriterThread.DoSetup;
begin
end;

// Routine: fnInnerList_Data, fnInnerList_Count, InnerList_Clear & InnerList_AddTo
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Function tWriterThread.fnInnerList_Data (Const aIdx: Integer): String;
begin
  Case Self.TimeStamp of
    True: Result := Format ('[%s] %s', [FormatDateTime (fnLocalisedDate (sdDDMMYY_HHMMSS, False), Now, fThreadSafeFormat), InnerList.Strings [aIdx]], fThreadSafeFormat);
    else  Result := InnerList.Strings [aIdx];
  end;
end;
Function tWriterThread.fnInnerList_Count: Integer;
begin
  Result := InnerList.Count;
end;
Procedure tWriterThread.InnerList_Clear;
begin
  InnerList.Clear;
end;
Procedure tWriterThread.InnerList_AddTo (Const aMsg: String);
begin
end;

// Routine: DoTimeEvent
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Procedure tWriterThread.DoTimeEvent (Const aTimeEvent: tTimeEvent);
begin
  inherited;
  Case aTimeEvent of
    teHour: fFailureCounter := fnLapCount_IntegerPair (fFailureCounter);
  end;
end;

// Routine: DoExecute
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Procedure tWriterThread.DoExecute;
begin
  Inherited;
  ProcessOuterQueue;
end;

Procedure tWriterThread.DoAfterExecute;
begin
  ProcessInnerQueue;
  Inherited;
  //  if ((Self.ExecutionCount mod 10) = 0) then RaiseNow  ('Hello: ' + IntToStr (Self.ExecutionCount));
end;

// Routine: DoCompleted
// Author: M.A.Sargent  Date: 31/05/18  Version: V1.0
//
// Notes: Updated to add a call to ProcessOuterQueue for any last minute changes
//
Procedure tWriterThread.DoCompleted;
begin
  inherited;
  ProcessOuterQueue;
  ProcessInnerQueue;
end;

// Routine: ProcessOuterQueue
// Author: M.A.Sargent  Date: 31/05/18  Version: V1.0
//
// Notes:
//
Procedure tWriterThread.ProcessOuterQueue;
var
  x:      Integer;
  lvList: tStringList;
begin
  if not Assigned (fOuterListQueue) then Exit;
  lvList := fOuterListQueue.Lock;
  Try
    if (lvList.Count > 0) then begin
      //
      for x := 0 to lvList.Count-1 do
        InnerList.Add (lvList[x]);
      //
      lvList.Clear;
    end;
  Finally
    fOuterListQueue.UnLock;
  end;
end;

// Routine: ProcessInnerQueue;
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Procedure tWriterThread.ProcessInnerQueue;
var
  lvOK: Boolean;
begin
  if (InnerList.Count > 0) then begin
    lvOK := True;
    DoProcessInnerQueue (lvOK);
    LastWrite := Now;
    // if Virtual method returns lvOK False, Increment Counter
    //
    if not lvOK then begin
      fFailureCounter := fnInc1_IntegerPair (fFailureCounter);
      // need to load trigger level from parameter/property
      if (fFailureCounter.Int1 > WriteFailureCount) then begin
        // DumpList as Hourly Exception Count exceeded

        // Log Exception has been dumped
        fnRaiseOnFalse (False, 'Error: ProcessInnerQueue.Hourly Failure Count Exceeded. %d Failures in the last Hour', [fFailureCounter.Int1]);
      end;
    end;
  end;
end;

// Routine: DoProcessInnerQueue
// Author: M.A.Sargent  Date: 28/08/18  Version: V1.0
//
// Notes:
//
Procedure tWriterThread.DoProcessInnerQueue (var aProcessedOK: Boolean);
begin
end;

// Routine: ExceptionHandlerInner
// Author: M.A.Sargent  Date: 28/08/18  Version: V1.0
//
// Notes: Write any Exception to the Container Class Excepotion List, it is upto the Container Class to action, (Stop/ReStart)
//
Procedure tWriterThread.ExceptionHandlerInner (Const aException: Exception; var aHandled: Boolean);
var
  lvDate: String;
begin
  inherited;
  lvDate := FormatDateTime (fnLocalisedDate (sdDDMMYY_HHMMSS, False), Now, fThreadSafeFormat);
  Int_AddExceptionMessage (fnTS_Format ('Error: ExceptionHandlerInner. When: %s. Error Count Since Startup (%d). %s', [lvDate, Self.ExceptionCount, aException.Message]));
  // write to the Exception Log so Handled
  aHandled := True;
  Sleep (100);
end;

{ tWriterThread_Text }

// Routine: Create
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Constructor tWriterThread_Text.Create (Const aFileName: String; Const aListQueue, aExceptionList: tMASThreadSafeStringList);
begin
  inherited Create (True, aListQueue, aExceptionList);
  fOnThreadFileNameChange := Nil;
  //
  fFileName      := tMASThreadSafeString.Create;
  //
  fInitialFileName := aFileName;
  FileName         := aFileName;
  fTextFile        := tTextFile.Create;
  //
  fnRaiseOnFalse (fnCheckDirectory (aFileName, True), 'Error: tWriterThread_Text.Create. Failed to CreateOutput Dir (%s)', [ExtractFileDir (aFileName)]);
end;

// Routine: CreateDateStamp
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Constructor tWriterThread_Text.CreateDateStamp (Const aFileName: String; Const aListQueue, aExceptionList: tMASThreadSafeStringList);
begin
  Create (aFileName, aListQueue, aExceptionList);
  //
  Self.SignalTimeEvents := True;
  //
  Int_GenFileName;
end;

Destructor tWriterThread_Text.Destroy;
begin
  fFileName.Free;
  fTextFile.Free;
  inherited;
end;

// Routine: DoProcessInnerQueue
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Procedure tWriterThread_Text.DoProcessInnerQueue (var aProcessedOK: Boolean);
var
  x:          Integer;
  lvFileName: String;
  lvRes:      tOKStrRec;
begin
  inherited;
  lvFileName := FileName;
  Try
    fnRaiseOnFalse2 (fnReAssignMutex (cLOGWRITER_MUTEX, lvFileName));
    // Try for n loops to Aquire Mutex, if it fails then Increment Failure Counter and Try again next time
    lvRes := fnAquireMutex (cLOGWRITER_MUTEX, cMC_500ms, cMC_10);
    Case lvRes.OK of
      True: begin
        Try
          //
          fTextFile.CreateWriteFile (lvFileName);
          Try
            for x := 0 to fnInnerList_Count-1 do begin
              //
              fTextFile.Append (fnInnerList_Data (x));
            end;
            InnerList_Clear;
          Finally
            fTextFile.CloseFile;
          End;
        Finally
          fnRaiseOnFalse2 (fnReleaseMutex (cLOGWRITER_MUTEX));
        End;
      end;
      // Return False as Aquire Failed
      else begin
        aProcessedOK := False;
        InnerList_AddTo (Format ('Error: DoProcessInnerQueue. Failed to Aquire Mutex. %s', [lvRes.Msg], fThreadSafeFormat));
      end;
    end;

  except
    on e:Exception do
      fnRaiseOnFalse (fnResultException ('DoProcessInnerQueue', 'Processing Inner Thread Queue Failed', e))
  end;
end;

// Routine: DoCompleted
// Author: M.A.Sargent  Date: 18/06/18  Version: V1.0
//
// Notes:
//
Procedure tWriterThread_Text.DoCompleted;
begin
  inherited;
  fnRaiseOnFalse2 (fnFreeMutex (cLOGWRITER_MUTEX));
end;

// Routine: DoTimeEvent
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Procedure tWriterThread_Text.DoTimeEvent (Const aTimeEvent: tTimeEvent);
begin
  inherited;
  Case aTimeEvent of
    teDay: Int_GenFileName;
  end;
end;

// Routine: Int_GenFileName
// Author: M.A.Sargent  Date: 05/06/18  Version: V1.0
//
// Notes:
//
Procedure tWriterThread_Text.Int_GenFileName;
begin
  FileName := fnGenFileName (fInitialFileName, gblDateFormat);
  if Assigned (fOnThreadFileNameChange) then fOnThreadFileNameChange (Self);
end;

// Routine: GetFileName
// Author: M.A.Sargent  Date: 05/06/18  Version: V1.0
//
// Notes:
//
Function tWriterThread_Text.GetFileName: String;
begin
  Result := Self.fFileName.Value;
end;
Procedure tWriterThread_Text.SetFileName (Const Value: String);
begin
  Self.fFileName.Value := Value;
end;

{ tBaseLogFileWriter }

// Routine: Create
// Author: M.A.Sargent  Date: 12/11/11  Version: V1.0
//
// Notes:
//
Constructor tBaseLogFileWriter.Create;
begin
  fListQueue     := tMASThreadSafeStringList.Create;
  fExceptionList := tMASThreadSafeStringList.Create;
  fTimeStamp     := True;
  fDisplayName   := ('Name_' + Trim (Self.ClassName));
  //
end;

Destructor tBaseLogFileWriter.Destroy;
begin
  ReleaseThread (tThread (fThread));
  fListQueue.Free;
  fExceptionList.Free;
  inherited;
end;

// Routine: fnZeroExceptions & fnExceptions
// Author: M.A.Sargent  Date: 06/06/18  Version: V1.0
//
// Notes:
//
Function tBaseLogFileWriter.fnZeroExceptions: Boolean;
begin
  Result := (fExceptionList.Count = 0);
end;
Function tBaseLogFileWriter.fnExceptions (var aList: tStrings; Const aClearList: Boolean = True): Integer;
var
  lvList: tStringList;
begin
  Result := -1;
  if not Assigned (aList) then Exit;
  //
  lvList := fExceptionList.Lock;
  Try
    Result := hCopyFromList2 (lvList, aList, True, True);
    if aClearList then lvList.Clear;
  finally
    fExceptionList.UnLock;
  end;
end;

// Routine: SetThread
// Author: M.A.Sargent  Date: 15/05/18  Version: V1.0
//
// Notes:
//
Procedure tBaseLogFileWriter.SetThread (Const Value: tWriterThread);
begin
  fThread := Value;
  if Assigned (fThread) then begin
    fThread.TimeStamp   := Self.TimeStamp;
    fThread.OnException := Int_DoException;
  end;
end;

// Routine: Int_DoException
// Author: M.A.Sargent  Date: 06/06/18  Version: V1.0
//
// Notes:
//
Procedure tBaseLogFileWriter.Int_DoException (Sender: tObject; Const ErrMsg: String);
begin
  // Format Message
  fExceptionList.Add ('[' + (fnTS_DateTimeToStr (Now) + '] Error: ' + Self.DisplayName + '. ' + ErrMsg));
end;

// Routine: SetTimeStamp
// Author: M.A.Sargent  Date: 15/05/18  Version: V1.0
//
// Notes:
//
Procedure tBaseLogFileWriter.SetTimeStamp (Const Value: Boolean);
begin
  fTimeStamp := Value;
  if Assigned (fThread) then fThread.TimeStamp := fTimeStamp;
end;

// Routine: AddLine
// Author: M.A.Sargent  Date: 31/05/18  Version: V1.0
//
// Notes:
//
Function tBaseLogFileWriter.fnAddLine (Const Format: string; Const Args: array of Const): Boolean;
begin
  Result := fnAddLine (fnTS_Format (Format, Args));
end;
Function tBaseLogFileWriter.fnAddLine (Const aLine: String): Boolean;
begin
  Try
    fListQueue.Add (aLine);
    Result := fnZeroExceptions;
  Except
    on e:Exception do begin
      Raise Exception.CreateFmt ('Error: AddLine: %s', [e.Message]);
    end;
  end;
end;

// Routine: AddList
// Author: M.A.Sargent  Date: 15/07/13  Version: V1.0
//
// Notes:
//
Function tBaseLogFileWriter.fnAddList (Const aList: tStrings): Boolean;
var
  x:      Integer;
  lvList: tStringList;
begin
  Result := True;
  if not Assigned (aList) then Exit;
  Try
    lvList := fListQueue.Lock;
    Try
      for x := 0 to aList.Count-1 do
        lvList.Add (aList[x]);
    Finally
      fListQueue.Unlock;
    end;
    Result := fnZeroExceptions;
  Except
    on e:Exception do begin
      Raise Exception.CreateFmt ('Error: AddList: %s', [e.Message]);
    end;
  end;
end;

// Routine: AddArraysValues
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//
Function tBaseLogFileWriter.fnAddArraysValues (Const aParams: array of string; Const aValues: array of string): Boolean;
var
  lvToJSon: tSimpleJSon;
  x:        Integer;
begin
  fnRaiseOnFalse ((High(aParams) <> High (aValues)), 'Error: fnAddArraysValues. The Number of Params and Values Should be the Same');
  //
  lvToJSon := tSimpleJSon.Create;
  Try
    for x := 0 to High (aParams) do begin
      lvToJSon.fnAdd (aParams[x], aValues[x]);
    end;
    //
    Result := fnAddLine (lvToJSon.AsString);
  Finally
    lvToJSon.Free;
  end;
end;

{ tTextLogFileWriter }

// Routine: Create
// Author: M.A.Sargent  Date: 25/05/18  Version: V1.0
//
// Notes:
//  V2.0: Updated to Assign a Event to the OnThreadFileNameChange event
//
Constructor tTextLogFileWriter.Create (Const aFileName: String; Const aDateTimeFile: Boolean);
begin
  inherited Create;
  fOnTextLogFileNameChange := Nil;
  // Check to see if the Output directory exists and if not Create it
  fnRaiseOnFalse (fnCheckDirectory (aFileName, True), 'Error: tTextLogFileWriter.Create. Failed to CreateOutput Dir (%s)', [ExtractFileDir (aFileName)]);
  //
  Case aDateTimeFile of
    True: begin
          Thread := tWriterThread_Text.CreateDateStamp (aFileName, Self.ListQueue, Self.ExceptionList);
          tWriterThread_Text (Thread).OnThreadFileNameChange := Int_OnFileNameChange;
    end;
    else  Thread := tWriterThread_Text.Create          (aFileName, Self.ListQueue, Self.ExceptionList);
  end;
  //
  Thread.Resume;
end;

Destructor tTextLogFileWriter.Destroy;
begin
  inherited;
end;

// Routine: GetFileName
// Author: M.A.Sargent  Date: 05/06/18  Version: V1.0
//
// Notes:
//
Function tTextLogFileWriter.GetFileName: String;
begin
  Result := tWriterThread_Text (Thread).FileName;
end;

// Routine: Int_OnFileNameChange
// Author: M.A.Sargent  Date: 24/09/18  Version: V1.0
//
// Notes:
//
Procedure tTextLogFileWriter.Int_OnFileNameChange(Sender: TObject);
begin
  if Assigned (fOnTextLogFileNameChange) then fOnTextLogFileNameChange (Sender, FileName);
end;

end.
