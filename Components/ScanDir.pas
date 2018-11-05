//
// Unit: ScanDir
// Author: M.A.Sargent  Date: 12/12/2001  Version: V1.0
//         M.A.Sargent        06/07/2005           V2.0
//         M.A.Sargent        31/01/2006           V3.0
//         M.A.Sargent        05/09/2008           V4.0
//         M.A.Sargent        17/01/2009           V5.0
//         M.A.Sargent        ??/??/20??           V6.0
//         M.A.Sargent        06/06/2018           V7.0
//
// Notes
// V2.0: Updated to add an AfterProcess Event
// V3.0: 1. Add an Property IgnoreFullFilePath, to allow the Ignore file list to use
//         the full FileName and path and NOT just the name
//         (default to just the name, as was}
//       2. Add Try/Finally in the Execute method for the fBusy indicator
// V4.0:
// V5.0: Add a MagnetCollection event
// V6.0: Updated ScanThisDir to add new event OnFileAction
// V7.0:
//
unit ScanDir;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ScanDirConsts, Masks, MASRecordStructuresU;

type

  tScanDir = class(TComponent)
  private
    { Private declarations }
    //fOnCollectionEvent: tOnCollectionEvent;
    //fCollection: tMASStringCollections;
    fOnListEvent: tOnListEvent;
    fIgnoreFullFilePath: Boolean;
    fAfterProcess: tNotifyEvent;
    fBeforeProcess: tNotifyEvent;
    fDir : string;            { Start directory }
    fTryOpen   : integer;     { No Secs to re-try opening a file }
    fTryOpenFiles
               :   Boolean;     { Default to False, Check that files can be opened}
    fOnNewFile :   tOnFileContinue;
    fOnNewFile2:   tOnFileContinue2;
    fOnFileAction: tOnFileAction;
                                { Event when file found }
    fOnOpenFail:   tOnFile;     { Unable to open this file }
    fRecurse   :   boolean;     { Recurse sub-directories }
    fIgnore    :   tStrings;    { List of files to ignore if found }
    fFiles     :   tFileList;   { List of files found }
    fBusy      :   boolean;     { Flag to signal we're currently scanning }
    fError     :   boolean;     { Flag set when fTryOpen times out }
    fCount     :   integer;     { Internal count of files found }
    fOnDir     :   tOnDir;      { Event raised for each directory }
    fFileMaskList: tStrings;    { Include FileMask List}
    fList:         tStrings;    { }
    procedure ScanThisDir(aDir:string);          { Run through dir and build list }
    procedure SetIgnore(aVal:tStrings);          { Sets files to ignore }
    function  CanOpenFile(aName:string):boolean; { Checks if file is locked / being copied }
    procedure ProcessList;                       { Read through list and raise event }
    function  IsIgnoreFile(aName:string):boolean;  { Is this file in the ignore list }
    function  IsIgnoreDir(aName:string):boolean;   { Must we ignore this directory }
    procedure SetStartDir(aVal:string);          { Write method of StartDir property }
    procedure SetFileMaskList(const Value: tStrings);
    function GetFileMask: String;
    procedure SetFileMask(const Value: String);
    function IsMaskFile (Const aName: String): Boolean;
    //procedure IntAddFileCollection (Const aFileInfo: tFileInfo);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(aOwner:tComponent);override;    { Constructor }
    destructor Destroy;override;                       { Releases objects }
    procedure Execute; overload;                       { Main run method }
    property Busy:boolean read fBusy;                  { Scan state }
    procedure TryStop;                                 { Try stop process }
    Procedure Setup (const aDir:String; aRecurse: Boolean; aOnFile: tOnFileContinue);
  published
    { Published declarations }
    property StartDirectory:string read fDir write SetStartDir;
    Property BeforeProcess: tNotifyEvent read fBeforeProcess write fBeforeProcess;
    Property AfterProcess: tNotifyEvent read fAfterProcess write fAfterProcess;
    property OnNewFile:tOnFileContinue read fOnNewFile write fOnNewFile;
    property OnNewFile2:tOnFileContinue2 read fOnNewFile2 write fOnNewFile2;
    Property OnFileAction: tOnFileAction read fOnFileAction write fOnFileAction;
    property OnOpenFail:tOnFile read fOnOpenFail write fOnOpenFail;
    property OnDirectory:tOnDir read fOnDir write fOnDir;
    property Recurse:boolean read fRecurse write fRecurse;
    property IgnoreList:tStrings read fIgnore write SetIgnore;
    Property IgnoreFullFilePath: Boolean read fIgnoreFullFilePath write fIgnoreFullFilePath default True;
    property TryOpenDuration:integer read fTryOpen write fTryOpen;
    property Count:integer read fCount;
    Property TryOpenFiles: Boolean read fTryOpenFiles write fTryOpenFiles default False;
    // New Events/Properties added 05/02/2006
    property FileMaskList: tStrings read fFileMaskList write SetFileMaskList;
    Property FileMask: String read GetFileMask write SetFileMask;
    Property OnListEvent: tOnListEvent read fOnListEvent write fOnListEvent;
    //Property OnCollectionEvent: tOnCollectionEvent read fOnCollectionEvent write fOnCollectionEvent;
    property List: tStrings read fList write fList;
  end;

  // Helper Classes and
  Function h_fnCountFile (Const aStartDir: String; Const aRecurse: Boolean): tOKCodeStrRec; overload;
  Function h_fnCountFile (Const aStartDir, aFileMask: String; Const aRecurse: Boolean): tOKCodeStrRec; overload;
  Function h_fnCountFile (Const aStartDir, aFileMask: String; Const aRecurse: Boolean; var aList: tStrings): tOKCodeStrRec; overload;

implementation

USes MAS_FormatU;

Function h_fnCountFile (Const aStartDir: String; Const aRecurse: Boolean): tOKCodeStrRec;
begin
  Result := h_fnCountFile (aStartDir, '', aRecurse);
end;
Function h_fnCountFile (Const aStartDir, aFileMask: String; Const aRecurse: Boolean): tOKCodeStrRec;
var
  lvList: tStrings;
begin
  lvList := Nil;
  Result := h_fnCountFile (aStartDir, aFileMask, aRecurse, lvList);
end;

Function h_fnCountFile (Const aStartDir, aFileMask: String; Const aRecurse: Boolean; var aList: tStrings): tOKCodeStrRec;
var
  lvObj:  tScanDir;
begin
  Result.OK   := True;
  Result.Code := -1;
  Try
    lvObj := tScanDir.Create (Nil);
    Try
      lvObj.StartDirectory := aStartDir;
      lvObj.Recurse        := aRecurse;
      lvObj.FileMask       := aFileMask;
      lvObj.List           := aList;
      lvObj.Execute;
      Result.Code := lvObj.Count;
    Finally
      lvObj.Free;
    end;
  except
    on e:Exception do begin
      Result.OK  := False;
      Result.Msg := fnTS_Format ('Error: h_fnCountFile. (%s)', [e.Message]);
    end;
  end;
end;

// Routine: Create
// Author: M.A.Sargent  Date: 06/07/2018  Version: V1.0
//
// Notes:
//
Constructor tScanDir.Create(aOwner:tComponent);
begin
  inherited;
  fDir            := '';
  fOnNewFile      := nil;
  fOnNewFile2     := nil;
  fOnFileAction   := Nil;
  fOnDir          := nil;
  fOnOpenFail     := nil;
  fBeforeProcess  := Nil;
  fAfterProcess   := Nil;
  fOnListEvent    := Nil;
  //fOnCollectionEvent := Nil;
  //
  fIgnore       := tStringList.Create;
  fFileMaskList := tStringList.Create;
  fFiles        := tFileList.Create;
  fBusy         := False;
  fTryOpen      := 5;
  fTryOpenFiles := False;
  fIgnoreFullFilePath := True;  {Default, as was}
end;

destructor tScanDir.Destroy;
begin
  fFiles.Clear;
  fFiles.Free;
  fIgnore.Free;
  //fCollection.Free;
  inherited;
end;

procedure tScanDir.SetStartDir(aVal:string);
begin
  fDir := aVal;
  if Copy(fDir,Length(fDir),1)='\' then
      fDir := Copy(fDir,1,Length(fDir)-1);
end;

// Routine:
// Author: M.A.Sargent  Date: 12/12/01  Version: V1.0
//         M.A.Sargent        02/01/06           V2.0
//         M.A.Sargent        08/02/06           V3.0
//
// Notes:
//  V2.0: Add a Try/Finally around the fBusy boolean
//  V3.0: Set the FileMask if = ''
//
procedure tScanDir.Execute;
var n : integer;
begin
  if not fBusy then
  begin
    fBusy := True;                             { We're scanning at the moment }
    Try
      //if Assigned (fOnCollectionEvent) and not Assigned (fCollection) then
      //  fCollection := tMASStringCollections.CreateSorted;

      for n := 0 to fIgnore.Count-1 do         { Set filenames to uppercase }
        fIgnore[n] := Uppercase(fIgnore[n]);   { Indexof to search for uppercase }
      fFiles.Clear;                            { Clear file list }
      fError := False;                         { No error so far }
      fCount := 0;                             { Zero counter }
      ScanThisDir( fDir );                     { Start with this dir }
      if not fError then begin
        ProcessList;                           { No errors, so process list }
        //if Assigned (fOnCollectionEvent) then fOnCollectionEvent (fCollection);
      end;
    Finally
      fBusy := False;                          { We're finished }
    end;
  end;
end;

//
procedure tScanDir.Setup(const aDir: String; aRecurse: Boolean;
  aOnFile: tOnFileContinue);
begin
  StartDirectory := aDir;
  Recurse        := aRecurse;
  OnNewFile      := aOnFile;
end;

// MAS 18/05/03 Update the fOnNewFile event to add a continue boolean variable
//              if set true then processing stops
// MAS 30/05/03 Add a BeforeProcess Event
// MAS 06/07/05 Add a AfterProcess Event
// MAS 08/02/06 Add OnListEvent, enables all the items to be assigned to an external
//              list in one hit, can also stop the per file event being firded
// MAS 04/08/07 Add an Extended Attributes parameter to the fOnNewFile event
procedure tScanDir.ProcessList;
var
  n : integer;
  o : tFileInfo;
  Continue: Boolean;
  lvList: tStrings;
begin
  Continue := True;
  fFiles.SortFiles;
  fCount := fFiles.Count;
  //
  if Assigned (fBeforeProcess) then fBeforeProcess (Self);
  // if List is ssigned then Copy Itmes to the List
  if Assigned (fList) then fFiles.CopyToList (fList);
  //
  if Assigned (fOnListEvent) then begin
    fOnListEvent (lvList, Continue);
    if Assigned (lvList) then fFiles.CopyToList (lvList);
  end;
  //
  if Continue then begin
    for n := 0 to fFiles.Count-1 do
    begin
      o := tFileInfo( fFiles.Items[n] );
      if Assigned(o) then
      begin
        if Assigned(fOnNewFile) then fOnNewFile( Self,o.FileName,(n+1),o.FileSize,o.FileTime, Continue);
        if Continue then begin
          //
          //IntAddFileCollection (o);
          if Assigned(fOnNewFile2) then fOnNewFile2 (Self,o.FileName,(n+1),o.FileSize,o.FileTime, o.Extended, Continue);
        end;
        if not Continue then Break;
      end;
    end;
    fCount := fFiles.Count;
  end;
  fFiles.Clear;
  if Assigned (fAfterProcess) then fAfterProcess (Self);
end;

// Routine: IntAddFileCollection
// Author: M.A.Sargent  Date: 17/01/09  Version: V1.0
//
// Notes:
//
{Procedure tScanDir.IntAddFileCollection (Const aFileInfo: tFileInfo);
begin
  if not Assigned (fCollection) then Exit;
  fCollection.AddValue (ExtractFileDir (aFileInfo.FileName), Format ('%s,%d,%d,', [ExtractFileName (aFileInfo.FileName),
                                                                                   aFileInfo.FileSize, aFileInfo.FileTime]));
end;}

procedure tScanDir.SetIgnore(aVal:tStrings);
begin
  { Copy strings }
  fIgnore.Assign(aVal);
  { Move all filenames to uppercase }
  // CAN WE REMOVE 20/05/03
  //for n := 0 to fIgnore.Count-1 do fIgnore[n] := Uppercase(fIgnore[n]);
end;

procedure tScanDir.SetFileMaskList (Const Value: tStrings);
begin
  fFileMaskList.Assign (Value);
end;

// MAS 20/10/02 Added fTryOpenFiles, it true all files are checked to see if
//              they can be opened
function  tScanDir.CanOpenFile(aName:string):boolean;
var
  lHandle : integer;
  lCount  : integer;
begin
  Result := True;
  {if True then try and open}
  if fTryOpenFiles then begin
    { Loop until opened }
    lCount := 0;
    lHandle:= FileOpen(aName,fmOpenRead or fmShareExclusive );
    while ( lCount < fTryOpen) and (lHandle<=0) do
    begin
      Sleep(1000);
      Inc(lCount);
      lHandle := FileOpen(aName,fmOpenRead or fmShareExclusive );
    end;
    Result := lHandle > 0;
    if lHandle > 0 then FileClose(lHandle);
  end;
end;

// MAS 27/10/02 Bug Fix: Also check for the start directory 
function tScanDir.IsIgnoreDir(aName:string):boolean;
var
  lvDir: String;
begin
  lvDir := StartDirectory + '\' + aName + '\*.*';
  Result := (fIgnore.IndexOf( Uppercase(lvDir)) <> -1) or
             (fIgnore.IndexOf( Uppercase(aName+'\*.*')) <> -1);
end;

// Routine: IsIgnoreFile
// Author: M.A.Sargent  Date: ??/??/??  Version: V1.0
//         M.A.Sargent        01/02/06           V2.0
//
// Notes:
//  V2.0: Add an option to allow the Ignore file list to use the full FileName and path
//        and NOT just the name
//
function tScanDir.IsIgnoreFile(aName:string):boolean;
var
  lName{,lExt} : string;
  x: Integer;
begin
  Case fIgnoreFullFilePath of
    True:  lName := Uppercase(ExtractFileName(aName));  {Ignore Location of File}
    False: lName := Uppercase(aName);                   {Ignore for a given location}
  end;
  Result := fIgnore.IndexOf(lName) <> -1;

  if (not Result) and (Pos('.',lName) > 0) then
  begin
    { Check wildcards }
    for x := 0 to fIgnore.Count-1 do begin
      Result := MatchesMask (lName, fIgnore.Strings[x]);
      if Result then Break;
    end;
    // CAN WE REMOVE 20/05/03
    {lExt  := '*' + ExtractFileExt(lName);
    lName := Copy( lName,1,Length(lName)-Length(lExt)+1) + '.*';
    Result :=  (fIgnore.IndexOf( lExt ) <> -1) or (fIgnore.IndexOf( lName ) <>-1);}
  end;
end;

// Routine: IsMaskFile
// Author: M.A.Sargent  Date: 05/09/08  Version: V1.0
//
// Notes:
//
Function tScanDir.IsMaskFile (Const aName: String): Boolean;
var
  x: Integer;
begin
  { Check wildcards }
  Result := (fFileMaskList.Count=0);
  if not Result then
    for x := 0 to fFileMaskList.Count-1 do begin
      Result := MatchesMask (aName, fFileMaskList.Strings[x]);
      if Result then Break;
    end;
end;

// Routine: ScanThisDir
// Author: M.A.Sargent  Date: 23/10/12  Version: V1.0
//
// Notes:
//
Procedure tScanDir.ScanThisDir (aDir:string);
var
  r : tSearchRec;
  //TWin32FindData
  x : integer;
  lName : string;
  lAllowed : boolean;
  lvAdd: Boolean;
begin
  lAllowed := True;
  if Assigned(fOnDir) then
    fOnDir(Self,aDir,lAllowed);

  if lAllowed then
  begin
    x := FindFirst( aDir + '\*.*', faAnyFile,r);
    Try
      while (x=0) and (not fError) do
      begin
        if copy(r.Name,1,1) <> '.' then
        begin
          { Check if its a directory }
          if (r.Attr and faDirectory) > 0 then
          begin
            if (fRecurse) and (not IsIgnoreDir(r.Name))  then begin
              //if Assigned (fCollection) then fCollection.AddEntryIfNotPresent (aDir + '\' + r.Name);
              ScanThisDir( aDir + '\' + r.Name );
            end;
          end else begin
            {Check to see if the FileMask if set Matches}
            if IsMaskFile (r.Name) then begin
            //if (fFileMask = '') or MatchesMask (r.Name, fFileMask) then begin
              { Check if this file is in the ignore file list }
              lName := aDir + '\' +  r.Name;
              if not IsIgnoreFile(lName) then
              begin
                { Nope its not, so we see if its opened }
                if CanOpenFile(lname) then begin
                  lvAdd := True;
                  if Assigned (fOnFileAction) then fOnFileAction (lName, lvAdd);
                  if lvAdd then fFiles.Add( lName , r.Size , r.Time, r.FindData);
                end else begin
                  fError := True;
                  if Assigned(fOnOpenFail) then fOnOpenFail(Self,lName,r.Size,r.Time);
                end;
              end;
            end;
          end;
        end;
        x := FindNext(r);
      end;
    Finally
      FindClose(r);
    end;
  end;
end;

procedure tScanDir.TryStop;
begin
  fError := True;
end;

function tScanDir.GetFileMask: String;
begin
  Result := fFileMaskList.Text;
end;

// Routine: SetFileMask
// Author: M.A.Sargent  Date: 10/01/08  Version: V1.0
//
// Notes: Old Property, as before, but you can pass CommaText to load tStrings
//
procedure tScanDir.SetFileMask (Const Value: String);
begin
  if (Pos (',', Value)>0) then
       fFileMaskList.CommaText := Value
  else fFileMaskList.Text      := Value;
end;

end.
