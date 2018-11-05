//
// Unit: MAS_DirectoryU
// Author: M.A.Sargent  Date: 16/05/2011  Version: V1.0
//         M.A.Sargent        25/02/2012           V2.0
//         M.A.Sargent        27/09/2012           V3.0
//         M.A.Sargent        15/10/2012           V4.0
//         M.A.Sargent        23/10/2012           V5.0
//         M.A.Sargent        07/01/2013           V6.0
//         M.A.Sargent        07/01/2013           V7.0
//         M.A.Sargent        10/02/2013           V8.0
//         M.A.Sargent        15/07/2013           V9.0
//         M.A.Sargent        03/09/2013           V10.0
//         M.A.Sargent        14/09/2013           V12.0
//         M.A.Sargent        19/09/2013           V13.0
//         M.A.Sargent        11/10/2013           V14.0
//         M.A.Sargent        27/10/2013           V15.0
//         M.A.Sargent        11/02/2014           V16.0
//         M.A.Sargent        14/02/2014           V17.0
//         M.A.Sargent        27/05/2015           V18.0
//         M.A.Sargent        17/04/2018           V19.0
//
// Notes:
//  V2.0: Add function fnCheckFileExists and fnCopyFile
//  V3.0: Add unit Increment level in SetIncrementLimit
//  V4.0: Add another version of fnGenTempFile
//  V5.0: Add function DeleteFolder
//  V6.0: Add function fnCheckDirectory2
//  V7.0: Add t2 function fnGenDirectoryName, same as File version but for Directories
//  V8.0: Add another overloaded version of fnGenFileName
//  V9.0: Add a call to the ThreadSafe version of FormatDateTime
// V10.0: Updated AppendToFileName
// V12.0:
// V13.0: Updated to call Thread Safe routines
// V14.0: Updated to fix bug in GetTemporaryPath
// V15.0: add another version fnCopyFile
// V16.0: Update fnGenTempFile
// V17.0: Add functions
//          1. fnRemoveDriveLetter (Const aPath: String): String;
//          2. fnMapRootPath (Const aPath, aNewPath: String): String;
//          3. SetFileReadOnly
//          4. GetTemporaryPath
//          5. PreFixToFileName
// V18.0:
// V19.0: Updated fnGenFileName to Localize, in more cases
//
unit MAS_DirectoryU;

interface

Uses SysUtils, Controls, ShlObj, windows, Forms, Dialogs, MASRecordStructuresU, MASDatesU, TS_SystemVariablesU,
      MAS_TypesU;

Type
  tFileNameType = (fntDate, fntDateTime, fntDateYMD, fntDateTimeYMD, fntIncremental, fntMonth,
                  {$IFDEF VER150}
                  {$ELSE}
                  fntTicks,
                  {$ENDIF}
                  fntNone);

  Function AppendPath (aPath, aNew: String): String; overload;
  Function AppendPath (Const aPaths: array of String): String; overload;
  //
  Function fnCheckDirectory (Const aFileName: String; Const Create: Boolean = True): Boolean;
  Function fnCheckDirectory2 (Const aDirectory: String; Const Create: Boolean): Boolean;
  //
  procedure ResetGenFileName;

  Function fnGenFileName (aPath, aNew: String; Const aFileNameType: tFileNameType): String; overload;
  Function fnGenFileName (Const aPaths: array of String; Const aFileNameType: tFileNameType): String; overload;
  //
  Function fnGenFileName (aFileName: String; Const aFileNameType: tFileNameType = fntDateTime): String; overload;
  Function fnGenFileName (aFileName: String; Const FixedDate: Boolean; Const aFileNameType: tFileNameType = fntDateTime): String; overload;
  Function fnGenFileName (Const aFileName, aPart: String): String; overload;
  //
  Function fnGenDirectoryName (Const aDirPath: String; Const aFileNameType: tFileNameType = fntDateTime): String; overload;
  Function fnGenDirectoryName (Const aDirPath: String; Const FixedDate: Boolean; Const aFileNameType: tFileNameType = fntDateTime): String; overload;
  //
  Function fnGenTempFile (aDir: String; aStartFileName: String): String; overload;
  Function fnGenTempFile (aDir, aDirName, aStartFileName: String; Const CreatePath: Boolean;
                           Const aFileNameType: tFileNameType): String; overload;
  // Used to Create a fully quified path, based on Application Dir, + Dir + Filename + tFileNAmeType
  // Directory created if it does not exist
  Function fnGenAppPathFile  (Const aFileName: String): String; overload;
  Function fnGenAppPathFile2 (Const aPath, aFileName: String): String;
  Function fnGenAppPathFile  (Const aPath, aFileName: String; Const aFileNameType: tFileNameType = fntDateTime): String; overload;
  //
  Function fnGenTempFile2 (aDir: String; aFileName: String): String;

  // These 3 routine are Thread Safe but you have have called TS_SystemVariablesU.TS_SetExeName
  Function fnGetIniFileName: String; overload;
  Function fnGetIniFileName (Const aFileName: String): String; overload;
  Function fnGetIniFileName (Const aDir, aFileName: String): String; overload;
  //
  Function fnAppName         (Const RemoveType: Boolean = True): String; overload;
  Function fnAppName         (Const aExeName: String; Const RemoveType: Boolean = True): String; overload;
  //
  Function AppendToFileName  (aFileName, aAppend: String; Const AddUnderScore: Boolean = False): String;
  Function PreFixToFileName  (aFileName, aAppend: String; Const AddUnderScore: Boolean = False): String;
  Function fnReplaceFileName (Const aExistingFileName, aNewFileName: String): String;
  //
  Function fnAppPath         (Const aSubDir: String): String;
  function GetSystemPath     (Const Folder: Integer): string;
  function GetTemporaryPath  (Const aOptionDir: String): string; overload;
  Function GetTemporaryPath  (Const aOptionDir: String; Const Create: Boolean): string; overload;

  //
  Function fnCheckFileExists (Const aDestFile: String): Boolean;
  Function fnCopyFile        (Const aSourceFile, aDestFile: String): tOKStrRec; overload;
  Function fnCopyFile        (Const aSourceFile, aDestFile: String; Const aFailIfExists: Boolean): tOKStrRec; overload;
  //
  Function fnMoveFile        (Const aSourceFile, aDestFile: String; Const aDeleteIfExists: Boolean = True): tOKStrRec;
  Function fnDeleteFile      (Const aFileName: String; Const SetReadWrite: Boolean = True): tOKStrRec;
  //
  Function fnChangeFileName (Const aFileName, aPartName: String): String;
  Function fnChangeFilePath (Const aFileName, aNewPath: String; Const CreateDir: Boolean = True): String;
  // aExt must contain a period '.'
  Function fnChangeExt (Const aExt: String): String; overload;
  Function fnChangeExt (Const aFileName, aExt: String): String; overload;
  //
  Procedure SetIncrementLimit (Const aLimit: Integer);
  //
  Function DeleteFiles (aDirName: TFileName): tOKStrRec;
  Function DeleteFolder (aDirName: TFileName): tOKStrRec;
  //
  Function fnFileSize (aFile: String): Integer;
  //
  //
  //
  Function SetFileReadWrite (Const aFileName: String): Integer;
  Function SetFileReadOnly (Const aFileName: String): Integer;
  Function IsReadOnly (Const aFileName: String): Boolean;

  //
  Function fnRemoveDriveLetter (Const aPath: String): String;
  Function fnMapRootPath (Const aPath, aNewPath: String): String;
  //
  Function ExcludeLeadingPathDelimiter (Const aPath: String): String;
  Function fnIsFirstCharDelimiter (Const aPath: String): Boolean;
  Function fnFirstChar (Const aPath: String): String;
  //
  Function fnReplaceBaseDir (Const aFileName, aOldBase, aNewBase: String) : String;
  Function fnRemoveBaseDir (Const aBaseDir, aFullFileName: String): String;

  Function fnGetParentFileDir (Const aFileName: String): String;

  Function fnIsDLL (Const aFileName: String): Boolean;

  //
  Function fnFileNameTypeToInt (Const aValue: tFileNameType): Integer;
  Function fnIntToFileNameType (Const aValue: Integer): tFileNameType;


implementation

Uses MASCommonU, FormatResultU, IdGlobal, MAS_FormatU;

var
  gblDate: tDate = 0;
  gblMaxIncrement: Integer = 1000;



Procedure SetIncrementLimit (Const aLimit: Integer);
begin
  gblMaxIncrement := aLimit;
end;


// Routine: AppendPath
// Author: M.A.Sargent  Date: 18/10/04  Version: V1.0
//         M.A.Sargent        21/02/07           V2.0
//         M.A.Sargent        08/02/11           V3.0
//
// Notes: Copied from DOACommonU.pas, does not call that version as it calls
//        CommonU.pas, and all the Magnet apps would end up with lots of IPD stuff
//        in them
//  V2.0: 1. Updated to work correctly if aPath if null
//        2. Trim aNew path
//  V3.0: Do Not Append if the String is Blank
//
Function AppendPath (aPath, aNew: String): String;
begin
  aPath := Trim (aPath);
  aNew  := Trim (aNew);
  if (aNew = '') then begin
    Result := aPath;
  end else begin
    // if the last character is a '\' then
    // append aNew
    if (Copy (aPath, Length(aPath), 1) = '\') then begin
      if (Copy(aNew, 1, 1) = '\') then
           Result := aPath + Copy(aNew, 2, Length(aNew)-1)
      else Result := aPath + aNew;
    end
    else begin
      if (Copy(aNew, 1, 1) = '\') then
           Result := aPath + aNew
      else begin
        if (aPath<>'') then                 // if Path is not Null then As Before
             Result := aPath + '\' + aNew   // Do as Before
        else Result := aNew;                // Just Append the aNew value
      end;
    end;
  end;
end;
// Array version pass many iterms that construct the Path ['c:\mick', 'Fred', '3_Medway', ''Life.Ini']
Function AppendPath (Const aPaths: array of String): String;
var
  x: Integer;
begin
  Result := '';
  for x := 0 to High (aPaths) do
    Result := AppendPath (Result, aPaths[x]);
end;

// Routine: fnCheckDirectory
// Author: M.A.Sargent  Date: 20/02/06  Version: V1.0
//
// Notes: Updated to detect a period '.', if found the
//
Function fnCheckDirectory (Const aFileName: String; Const Create: Boolean): Boolean;
var
  lvDir: String;
begin
  //
  Case (Pos ('.', aFileName) > 0) of
    True:  lvDir := ExtractFileDir (aFileName);     {Filename has . eg: file.exe}
    False: lvDir := aFileName;                      {Just use as is}
  end;
  Result := DirectoryExists (lvDir);
  if Create and not Result then
    Result := ForceDirectories (lvDir);
end;
Function fnCheckDirectory2 (Const aDirectory: String; Const Create: Boolean): Boolean;
begin
  Result := DirectoryExists (aDirectory);
  if Create and not Result then
    Result := ForceDirectories (aDirectory);
end;

// Routine: fnGenFileName
// Author: M.A.Sargent  Date: 28/03/06  Version: V1.0
//         M.A.Sargent        27/09/12           V2.0
//         M.A.Sargent        24/02/14           V3.0
//
// Notes:
//  V2.0: Use Unit variable to limit Max Increment Filenames
//  V3.0: Updated to use the Thread Safe version of FormatDateTime
//  V4.0: Updated fnGenFileName to use LastDelimiter
//
procedure ResetGenFileName;
begin
  gblDate := 0.0;
end;

Function fnGenFileName (aPath, aNew: String; Const aFileNameType: tFileNameType): String;
var
  lvStr: String;
begin
  lvStr  := AppendPath (aPath, aNew);
  Result := fnGenFileName (lvStr, False, aFileNameType);
end;

Function fnGenFileName (Const aPaths: array of String; Const aFileNameType: tFileNameType): String;
var
  lvStr: String;
begin
  lvStr  := AppendPath (aPaths);
  Result := fnGenFileName (lvStr, False, aFileNameType);
end;

Function fnGenFileName (aFileName: String; Const aFileNameType: tFileNameType): String;
begin
  Result := fnGenFileName (aFileName, False, aFileNameType);
end;
Function fnGenFileName (aFileName: String; Const FixedDate: Boolean; Const aFileNameType: tFileNameType = fntDateTime): String;
var
  lvName: String;
  lvFileName: String;

  Function fnVersionFile: String;
  var
    x: Integer;
    lvPath: String;
  begin
    lvPath := ExtractFilePath (aFileName);
    if not DirectoryExists (lvPath) then Raise Exception.CreateFmt ('Error: To Create Incremental Filename, Directory Path (%s) Must Exist', [lvPath]);
    for x := 1 to (gblMaxIncrement+1) do begin
      Result := AppendToFileName (aFileName, Format ('_%d', [x]));
      if not FileExists (Result) then begin
        Result := Format ('_%d', [x]);
        Exit;
      end;
      if (x=gblMaxIncrement) then Raise Exception.CreateFmt ('Error: Maximum File Version of %d Reached for File (%s)', [gblMaxIncrement, Result]);
    end;
  end;
begin
  Case FixedDate of
    True:  if (gblDate=0.0) then gblDate := Now;
    False: gblDate := Now
  end;

  lvFileName := aFileName;

  Case aFileNameType of
    fntNone:        lvName := '';
    fntDate:        lvName := fnTS_FormatDateTime (fnLocalisedDate (sdDDMMYY),        gblDate);
    fntDateTime:    lvName := fnTS_FormatDateTime (fnLocalisedDate (sdDDMMYY_HHMMSS), gblDate);
    fntDateYMD:     lvName := fnTS_FormatDateTime ('_YYYYMMDD',                       gblDate); // Do Not Localize
    fntDateTimeYMD: lvName := fnTS_FormatDateTime ('_YYYYMMDD_HHNNSS',                gblDate); // Do Not Localize
    fntMonth:       lvName := fnTS_FormatDateTime (fnLocalisedDate (sdMM),            gblDate);
    //
    fntIncremental: lvName := fnVersionFile;
    {$IFDEF VER150} {$ELSE}
    fntTicks:       lvName := fnTS_Format ('_%d', [Ticks]);
    {$ENDIF}
  end;
  // Call Other Function
  Case (aFileNameType = fntNone) of
    True: Result := lvFileName;
    else  Result := fnGenFileName (lvFileName, lvName);
  end;
end;

// Routine: fnGenFileName
// Author: M.A.Sargent  Date: 24/03/14  Version: V1.0
//
// Notes:
//
Function fnGenFileName (Const aFileName, aPart: String): String;
var
  lvPos: Integer;
  lvFileName: String;
begin
  Result := '';
  // Extract Directory info if it Exists
  lvPos := LastDelimiter ('\', aFileName);
  if (lvPos > 0) then begin
    Result := Copy (aFileName, 1, (lvPos-1));
    lvFileName := Copy (aFileName, (lvPos+1), 9999);
  end
  else lvFileName := aFileName;
  //
  // Use FileName After this Point
  //
  lvPos := LastDelimiter ('.', lvFileName);
  if (lvPos > 0) then
       Result := AppendPath (Result, (Copy (lvFileName, 1, (lvPos-1)) + aPart + Copy (lvFileName, lvPos, 9999)))
  else Result := AppendPath (Result, (lvFileName + aPart));
end;

{Function fnGenFileName (Const aFileName, aPart: String): String;
var
  lvPos: Integer;
begin
  // Use FileName After this Point
  //lvPos := Pos ('.', aFileName);
  lvPos := LastDelimiter ('.', aFileName);
  if (lvPos > 0) then
       Result := Copy (aFileName, 1, (lvPos-1)) + aPart + Copy (aFileName, lvPos, 9999)
  else Result := aFileName + aPart;
end;}

// Routine: fnGenDirectoryName
// Author: M.A.Sargent  Date: 07/01/13  Version: V1.0
//
// Notes:
//
Function fnGenDirectoryName (Const aDirPath: String; Const aFileNameType: tFileNameType = fntDateTime): String;
begin
  Result := fnGenDirectoryName (aDirPath, False, aFileNameType);
end;
Function fnGenDirectoryName (Const aDirPath: String; Const FixedDate: Boolean; Const aFileNameType: tFileNameType = fntDateTime): String;
var
  lvName: String;

  Function fnIncrementalDirFile: String;
  var
    x: Integer;
    lvPath: String;
  begin
    lvPath := aDirPath;
    if not DirectoryExists (lvPath) then Raise Exception.CreateFmt ('Error: To Create Incremental Filename, Directory Path (%s) Must Exist', [lvPath]);
    for x := 1 to (gblMaxIncrement+1) do begin
      Result := Format ('%s_%d',[aDirPath, x]);
      if not DirectoryExists (Result) then begin
        Result := Format ('_%d', [x]);
        Exit;
      end;
      if (x=gblMaxIncrement) then Raise Exception.CreateFmt ('Error: Maximum File Version of %d Reached for File (%s)', [gblMaxIncrement, Result]);
    end;
  end;
begin
  Case FixedDate of
    True:  if (gblDate=0.0) then gblDate := Now;
    False: gblDate := Now
  end;

  Case aFileNameType of
    fntDate:        lvName := fnTS_FormatDateTime ('_DDMMYY', gblDate);
    fntDateTime:    lvName := fnTS_FormatDateTime ('_DDMMYY_HHNNSS', gblDate);
    fntDateTimeYMD: lvName := fnTS_FormatDateTime ('_YYYYMMDD_HHNNSS', gblDate);
    fntIncremental: lvName := fnIncrementalDirFile;
    {$IFDEF VER150} {$ELSE}
    fntTicks:       Raise Exception.Create ('Error: fnGenDirectoryName. Type fntTicks is Not Valid for this Routine');
    {$ENDIF}
  end;
  // Use FileName After this Point
  Result := aDirPath + lvName;
end;

// Routine: fnAppName
// Author: M.A.Sargent  Date: 28/03/06  Version: V1.0
//
// Notes:
//
Function fnAppName (Const RemoveType: Boolean = True): String;
begin
  Result := fnAppName (fnTS_AppName, RemoveType);
end;
Function fnAppName (Const aExeName: String; Const RemoveType: Boolean = True): String;
begin
  Result := ExtractFileName (aExeName);     {Get the Filesname}
  if RemoveType then Result := ChangeFileExt (Result, '');
end;

// Routine: AppendToFileName and PreFixToFileName
// Author: M.A.Sargent  Date: 03/12/08  Version: V1.0
//         M.A.Sargent        11/10/09           V2.0
//         M.A.Sargent        03/09/11           V3.0
//         M.A.Sargent        20/02/14           V4.0
//         M.A.Sargent        22/02/14           V5.0
//
// Notes: Function to Add strinfg data at the end of the filename
//        eg.  c:\mick\filename.txt --> c:\mick\filename_12.txt
//  V2.0: Fix Problem, if file name had multiple '.' problem , updated
//        to find the last '.'
//  V3.0: Add parameter AddUnderScore
//  V4.0: Allow Postfix and Prefix
//  V5.0: Bug Fix
//
Function IntPreFixToFileName (aFileName, aAppend: String; Const aPreFix: Boolean; Const AddUnderScore: Boolean = False): String;
var
  lvNewName: String;
begin
  // replace the persio with a format string char and persion '.' --> '%s.'
  lvNewName := ExtractFileName (aFileName);
  Case aPreFix of
    True: Case AddUnderScore of
            True: Insert ('%s_',  lvNewName, 1);
            else  Insert ('%s',  lvNewName, 1);
          end;
    else  Case AddUnderScore of
            True: Insert ('_%s',  lvNewName, LastDelimiter ('.', lvNewName));
            else  Insert ('%s',  lvNewName, LastDelimiter ('.', lvNewName));
          end;
    end;
  // add the Append Details
  lvNewName := Format (lvNewName, [aAppend]);
  // replace FileName
  Result := fnReplaceFileName (aFileName, lvNewName);
end;
//
Function AppendToFileName (aFileName, aAppend: String; Const AddUnderScore: Boolean = False): String;
begin
  Result := IntPreFixToFileName (aFileName, aAppend, False, AddUnderScore);
end;
Function PreFixToFileName (aFileName, aAppend: String; Const AddUnderScore: Boolean = False): String;
begin
  Result := IntPreFixToFileName (aFileName, aAppend, True, AddUnderScore);
end;

// Routine: fnReplaceFileName
// Author: M.A.Sargent  Date: 20/02/07  Version: V1.0
//
// Notes: Routine used to replace the filename in a directory, filename string
//
Function fnReplaceFileName (Const aExistingFileName, aNewFileName: String): String;
begin
  // existsing filename MUST contain a period  eg. missingfile.ini
  if (Pos ('.', aExistingFileName) = 0) then
    Raise Exception.CreateFmt ('Error: FileName Must Contain a ''.'' (%s)', [aExistingFileName]);
  //
  Result := ExtractFilePath (aExistingFileName);
  Result := AppendPath (Result, aNewFileName);
end;

//
// Routine: GetSystemPath
// Author: M.A.Sargent  Date: 05/03/2006  Version: V1.0
//
// Notes: see parameter values in SHFolder.pas or ShlObj.pas for available options
// CSIDL_APPDATA for Application Data
// CSIDL_DESKTOP for WINDOWS\Desktop
// CSIDL_DESKTOPDIRECTORY for WINDOWS\Desktop
// CSIDL_FONTS for WINDOWS\FONTS
// CSIDL_NETHOOD for WINDOWS\NetHood
// CSIDL_PERSONAL for X:\My Documents
// CSIDL_PROGRAMS for WINDOWS\StartMenu\Programs
// CSIDL_RECENT for WINDOWS\Recent
// CSIDL_SENDTO for WINDOWS\SendTo
// CSIDL_STARTMENU for WINDOWS\Start Menu
// CSIDL_STARTUP for WINDOWS\Start Menu\Programs\StartUp
// CSIDL_TEMPLATES for WINDOWS\ShellNew
// CSIDL_WINDOWS for { GetWindowsDirectory() }
//
function GetSystemPath (Const Folder: Integer): string;
var
  PIDL: PItemIDList;
  Path: pChar;

begin
  Result := '';
  Path := StrAlloc(256);//MAX_PATH);
  Try
    SHGetSpecialFolderLocation (Application.Handle, Folder, PIDL);
    if SHGetPathFromIDList (PIDL, Path) then
      Result := Path;


  Finally
    StrDispose(Path);
  end;
end;

// Routine: GetTemporaryPath, add overloaded version
// Author: M.A.Sargent  Date: 20/02/06  Version: V1.0
//         M.A.Sargent        11/10/13           V2.0
//         M.A.Sargent        20/02/14           V3.0
//
// Notes: Decoupled version
//  V2.0: Bug fix
//  V3.0:
//
Function GetTemporaryPath (Const aOptionDir: String): string;
begin
  Result := GetTemporaryPath (aOptionDir, False);
end;
Function GetTemporaryPath (Const aOptionDir: String; Const Create: Boolean): string;
const
  MAX_PATH = 144;
var
  lpPathBuffer : PChar;
begin
  GetMem(lpPathBuffer, MAX_PATH);           {Get the temp path buffer}
  Try
    GetTempPath(MAX_PATH, lpPathBuffer);    {Get the temp path}
   {Create a pascal string containg}
   {the temp file name and return it}
   Result := StrPas(lpPathBuffer);
   if (aOptionDir<>'') then Result := AppendPath (Result, aOptionDir);
   // New Version, Create and it is the Default
   if Create then
     if not fnCheckDirectory (Result, True) then Raise Exception.CreateFmt ('Error: GetTemporaryPath. Could Not create Directrory (%s', [Result]);
  Finally
    FreeMem(lpPathBuffer, MAX_PATH);        {Free the temp path buffer}
  End;
end;

// Routine: fnCheckFileExists
// Author: M.A.Sargent  Date: 10/03/12  Version: V1.0
//
// Notes: Only Return False if File Exists and User DOES NOT want to overwrite it
//
Function fnCheckFileExists (Const aDestFile: String): Boolean;
begin
  Result := FileExists (aDestFile);
  if Result then
       Result := (MASDlg ('Destination File (%s) Already Exists, Do You Want to OverWrite It?', [aDestFile], mtConfirmation, [mbYes, mbNo]) = mrYes)
  else Result := True;
end;

// Routine: fnCopyFile
// Author: M.A.Sargent  Date: 10/03/12  Version: V1.0
//
// Notes:
//
function fnCopyFile (Const aSourceFile, aDestFile: String): tOKStrRec;
begin
  Result.OK := fnCheckFileExists (aDestFile);
  if Result.OK then begin
    Result := fnCopyFile (aSourceFile, aDestFile, False);
  end
  else Result.Msg := Format ('Error: File (%s) Not Overwritten', [aDestFile]);
end;
Function fnCopyFile (Const aSourceFile, aDestFile: String; Const aFailIfExists: Boolean): tOKStrRec;
begin
  Result.OK := CopyFile (PChar(aSourceFile), PChar(aDestFile), aFailIfExists);
  if not Result.OK then
    Result.Msg := Format ('Error: %s', [SysErrorMessage(GetLastError)]);
end;

// Routine: fnMoveFile
// Author: M.A.Sargent  Date: 27/10/13  Version: V1.0
//
// Notes:
//
Function fnMoveFile (Const aSourceFile, aDestFile: String; Const aDeleteIfExists: Boolean): tOKStrRec;
begin
  Result.OK := True;
  if FileExists (aDestFile) and aDeleteIfExists then
    Result := fnDeleteFile (aDestFile, aDeleteIfExists);
  //
  if Result.OK then begin
    Result.OK := MoveFile (PChar(aSourceFile), PChar(aDestFile));
    if not Result.OK then
      Result.Msg := Format ('Error: %s', [SysErrorMessage(GetLastError)]);
  end;
end;

// Routine: fnDeleteFile
// Author: M.A.Sargent  Date: 15/02/14  Version: V1.0
//         M.A.Sargent        15/02/14           V2.0
//
// Notes:
//  V2.0: See if
//
Function fnDeleteFile (Const aFileName: String; Const SetReadWrite: Boolean): tOKStrRec;
begin
  if SetReadWrite then SetFileReadWrite (aFileName);
  //
  Result.OK := SysUtils.DeleteFile (aFileName);
  if not Result.OK then Result := fnResult ('Error: Deleting File: (%s) (%s)', [aFileName, SysErrorMessage(GetLastError)]);
end;

// Routine:  fnChangeFileName
// Author: M.A.Sargent  Date: 27/10/13  Version: V1.0
//
// Notes:
//
Function fnChangeFileName (Const aFileName, aPartName: String): String;
begin
  Result := ExtractFilePath (aFileName);
  Result := AppendPath (Result, Format ('%s%s', [Trim (aPartName), ExtractFileExt (aFileName)]));
end;

// Routine:  fnChangeFilePath
// Author: M.A.Sargent  Date: 14/01/14  Version: V1.0
//
// Notes:
//
Function fnChangeFilePath (Const aFileName, aNewPath: String; Const CreateDir: Boolean): String;
begin
  if not fnCheckDirectory (aNewPath, CreateDir) then Raise Exception.CreateFmt ('Error: Creating Directory (%s)', [aNewPath]);
  //
  Result := aNewPath;
  Result := AppendPath (Result, ExtractFileName (aFileName));
end;

// Routine:  fnChangeExt
// Author: M.A.Sargent  Date: 07/12/17  Version: V1.0
//
// Notes:
//
Function fnChangeExt (Const aExt: String): String;
begin
  Result := fnChangeExt (fnTS_AppName, aExt);
end;
Function fnChangeExt (Const aFileName, aExt: String): String;
begin
  if (Pos ('.', aExt) <> 1) then raise Exception.Create ('Error: fnChangeExt. aExt Must contain a Period');
  Result := ChangeFileExt (aFileName, aExt);
end;

// Routine: fnGenTempFile
// Author: M.A.Sargent  Date: 06/05/12  Version: V1.0
//         M.A.Sargent        11/02/14           V2.0
//
// Notes:
//  V2.0: Wrapper commands
//
Function fnGenTempFile (aDir, aStartFileName: String): String;
begin
  Result := fnGenTempFile (aDir, '', aStartFileName, True, fntIncremental);
end;
Function fnGenTempFile (aDir, aDirName, aStartFileName: String; Const CreatePath: Boolean; Const aFileNameType: tFileNameType): String;
begin
  // Get Temp path if one is not supplied
  if (aDir = '') then
       Result := GetTemporaryPath ('')
  else Result := aDir;
  // Append Dir name if one is supplied
  if (aDirName <> '') then Result := AppendPath (Result, aDirName);
  // See if directory exists, if CreatePath then create else raise exception
  if not DirectoryExists (Result) then begin
    if CreatePath then begin
         if not ForceDirectories (Result) then
           Raise Exception.CreateFmt ('Error: Creating directory path (%s)', [Result])
    end
    else Raise Exception.CreateFmt ('Error: Directory path does not exist (%s)', [Result]);
  end;
  //
  if (aStartFileName = '') then aStartFileName := 'MAS';
  aStartFileName := AppendPath (Result, aStartFileName);
  Result := fnGenFileName (aStartFileName, False, aFileNameType);
  //
end;
Function fnGenTempFile2 (aDir: String; aFileName: String): String;
begin
  Result := GetTemporaryPath (aDir);
  if (aFileName='') then Raise Exception.CreateFmt ('Error: fnGenTempFile. Filename Can Not be Left Blank(%s)', [aFileName]);
  Result := AppendPath (Result, aFileName);
  if not fnCheckDirectory (Result, True) then Raise Exception.CreateFmt ('Error: Creating Directory (%s)', [Result]);
end;

// Routine: fnGenFilePath
// Author: M.A.Sargent  Date: 07/12/17  Version: V1.0
//
// Notes:
//

Function fnGenAppPathFile (Const aFileName: String): String;
begin
  Result := fnGenAppPathFile ('', aFileName, fntDateTime);
end;
Function fnGenAppPathFile2 (Const aPath, aFileName: String): String;
begin
  Result := fnGenAppPathFile (aPath, aFileName, fntNone);
end;

Function fnGenAppPathFile (Const aPath, aFileName: String; Const aFileNameType: tFileNameType = fntDateTime): String;
var
  lvPath: String;
begin
  if IsEmpty (aFileName) then Raise Exception.CreateFmt ('Error: fnGenFileAndPath. Filename Can Not be Left Blank(%s)', [aFileName]);
  //
  lvPath := aPath;
  if IsEmpty (lvPath) then lvPath := 'Common\Debug';
  //
  Result := fnGenTempFile (fnTS_AppPath, lvPath, aFileName, True, aFileNameType);
end;

// Routine: fnGetIniFileName
// Author: M.A.Sargent  Date: 27/05/15  Version: V1.0
//
// Notes: All 3 routines are thread safe, must call TS_SystemVariablesU.TS_SetExeName
//
Function fnGetIniFileName: String;
var
  lvFileName: String;
begin
  lvFileName := fnTS_ExeName;
  Result := fnGetIniFileName (ExtractFileDir (lvFileName), ExtractFileName (lvFileName));
end;
Function fnGetIniFileName (Const aFileName: String): String;
var
  lvFileName: String;
  lvFileNameOnly: String;
begin
  lvFileName := fnTS_ExeName;
  // extract filename is case a full file path has been passed to the routine
  lvFileNameOnly := ExtractFileName (aFileName);
  if (lvFileNameOnly = '') then lvFileNameOnly := ExtractFileName (lvFileName);
  //
  Result := fnGetIniFileName (ExtractFileDir (lvFileName), lvFileNameOnly);
end;
Function fnGetIniFileName (Const aDir, aFileName: String): String;
begin
  Result := AppendPath (aDir, aFileName);
  Result := ChangeFileExt (Result, '.Ini');
end;

// Routine: DeleteFolder
// Author: M.A.Sargent  Date: 23/10/12  Version: V1.0
//         M.A.Sargent        17/02/14           V2.0
//         M.A.Sargent        10/11/14           V3.0
//
// Notes:
//  V2.0: Check to see if the directory exists
//  V3.0: Stop a blank string being pasted to the routine
//
Function DeleteFiles (aDirName: TFileName): tOKStrRec;
var
  lvError: Integer;
  lvFileSearch: TSearchRec;
begin
  if (aDirName = '') then Raise Exception.Create ('Error: DeleteFiles. aDirName Parameter Can Not be Null');
  Result.OK := True;
  if DirectoryExists (aDirName) then begin
    //
    if aDirName [Length (aDirName)] <> '\' then aDirName := aDirName + '\';
    //
    lvError := SysUtils.FindFirst (aDirName + '*.*', faAnyFile, lvFileSearch);
    Try
      with lvFileSearch do begin
        while (lvError = 0) do begin
          if (aDirName + Name <> '.') and (aDirName + Name <> '..') then begin
            FileSetAttr (aDirName + Name, 0);
            SysUtils.DeleteFile (aDirName + Name);
          end;

          lvError := SysUtils.FindNext (lvFileSearch);
        end;
      end;
    Finally
      SysUtils.FindClose (lvFileSearch);
    end;
  end;
end;

Function DeleteFolder (aDirName: TFileName): tOKStrRec;
begin
  Result := DeleteFiles (aDirName);
  if Result.OK then begin
    Result.OK := RemoveDir (aDirName);
    if not Result.OK then Result.Msg := Format ('Error: Directory %s could not be removed' ,[aDirName]);
  end;
end;

// Routine: fnFileSize
// Author: M.A.Sargent  Date: 14/09/13  Version: V1.0
//
// Notes:
//
Function fnFileSize (aFile: String): Integer;
var
  lFile: file of Byte;
begin
  Result := -1;                              {Default to -1, -1 indicates error}
  if not FileExists (aFile) then Exit;
  //
  AssignFile(lFile, aFile);
  FileMode := 0;                             {Set file access to read only(0)}
  Reset(lFile);
  Try
    Result := System.FileSize(lFile);
  Finally
    System.CloseFile(lFile);
  end;
end;

// Routine: fnAppPath
// Author: M.A.Sargent  Date: 13/01/14 Version: V1.0
//
// Notes:
//
Function fnAppPath (Const aSubDir: String): String;
begin
  Result := ExtractFilePath (Application.ExeName);
  Result := AppendPath (Result, aSubDir);
  //
  if not fnCheckDirectory2 (Result, True) then Raise Exception.CreateFmt ('Error: Creating Directory (%s)', [Result]);
  //
end;

// Routine: SetFileReadWrite
// Author: M.A.Sargent  Date: 01/02/14 Version: V1.0
//
// Notes:
//
Function SetFileReadWrite (Const aFileName: String): Integer;
var
  lvFileAttr: Integer;
begin
  Case IsReadOnly (aFileName) of
    True: begin
            lvFileAttr := FileGetAttr (aFileName);
            Result := FileSetAttr (aFileName, (lvFileAttr - faReadOnly));
    end
    else  Result := 0;
  end;
end;

// Routine: SetFileReadOnly
// Author: M.A.Sargent  Date: 01/02/14 Version: V1.0
//
// Notes:
//
Function SetFileReadOnly (Const aFileName: String): Integer;
var
  lvFileAttr: Integer;
begin
  Case IsReadOnly (aFileName) of
    True: Result := 0;
    else begin
           lvFileAttr := FileGetAttr (aFileName);
           Result := FileSetAttr (aFileName, (lvFileAttr + faReadOnly));
    end
  end;
end;

// Routine: SetFileAttribute
// Author: M.A.Sargent  Date: 01/02/14 Version: V1.0
//
// Notes:
//
Function IsReadOnly (Const aFileName: String): Boolean;
var
  lvFileAttr: Integer;
begin
  lvFileAttr := FileGetAttr (aFileName);
  Result := ((lvFileAttr and faReadOnly) <> 0);
end;

// Routine: fnRemoveDriveLetter
// Author: M.A.Sargent  Date: 14/02/14 Version: V1.0
//
// Notes:
//
Function fnRemoveDriveLetter (Const aPath: String): String;
var
  lvDrive: String;
begin
  lvDrive := ExtractFileDrive (aPath);
  Result := ExtractRelativePath (lvDrive, aPath);
end;

// Routine: fnMapRootPath
// Author: M.A.Sargent  Date: 14/02/14 Version: V1.0
//
// Notes:
//
Function fnMapRootPath (Const aPath, aNewPath: String): String;
begin
  Result := fnRemoveDriveLetter (aPath);
  Result := AppendPath (aNewPath, Result);
end;

// Routine: ExcludeLeadingPathDelimiter, fnIsFirstCharDelimiter & fnFirstChar
// Author: M.A.Sargent  Date: 23/02/14 Version: V1.0
//
// Notes:
//
Function ExcludeLeadingPathDelimiter (Const aPath: String): String;
begin
  Result := aPath;
  if fnIsFirstCharDelimiter (aPath) then
    Result := Copy (aPath, 2, 99999);
end;
Function fnIsFirstCharDelimiter (Const aPath: String): Boolean;
begin
  Result := IsPathDelimiter (aPath, 1);
end;
Function fnFirstChar (Const aPath: String): String;
begin
  Result := Copy (aPath, 1, 1);
end;

// Routine: fnReplaceBaseDir
// Author: M.A.Sargent  Date: 23/02/14 Version: V1.0
//
// Notes:
//
Function fnReplaceBaseDir (Const aFileName, aOldBase, aNewBase: String): String;
begin
  Result := StringReplace (aFileName, aOldBase, aNewBase, [rfIgnoreCase]);
  Result := ExcludeLeadingPathDelimiter (Result);
end;

Function fnRemoveBaseDir (Const aBaseDir, aFullFileName: String): String;
var
  lvPos: Integer;
begin
  lvPos := UPos (aBaseDir, aFullFileName);
  Case (lvPos = 1) of
    True: Result := fnReplaceBaseDir (aFullFileName, aBaseDir, '');
    else  Result := aFullFileName;
  end;
end;

// Routine: fnGetFileDir
// Author: M.A.Sargent  Date: 16/04/14 Version: V1.0
//
// Notes:
//
Function fnGetParentFileDir (Const aFileName: String): String;
var
  lvStr: String;
  lvPos: Integer;
begin
  lvStr := ExtractFileName (aFileName);
  // if Filename Should contain  a '.' period
  Case (LastDelimiter ('.', lvStr) > 0) of
    True: Result := ExtractFileDir (aFileName);
    else  Result := aFileName;
  End;
  // remove a trailing '\' if it exists
  if (LastDelimiter ('\', Result) = Length (Result)) then
    Result := Copy (Result, 1, (Length (Result)-1));
  //
  lvPos := LastDelimiter ('\', Result);
  if (lvPos > 0) then
    Result := Copy (Result, (lvPos+1), MaxInt);
end;

// Routine: fnIsDLL
// Author: M.A.Sargent  Date: 02/07/14 Version: V1.0
//
// Notes:
//
Function fnIsDLL (Const aFileName: String): Boolean;
begin
  Result := UContainsText ('.DLL', ExtractFileExt (aFileName));
end;


// Routine: fnFileNameTypeToInt & fnIntToFileNameType
// Author: M.A.Sargent  Date: 30/03/18  Version: V1.0
//
// Notes:
//
Function fnFileNameTypeToInt (Const aValue: tFileNameType): Integer;
begin
  Result := Ord (aValue);
end;
Function fnIntToFileNameType (Const aValue: Integer): tFileNameType;
begin
  Result := tFileNameType (aValue);
end;



end.


