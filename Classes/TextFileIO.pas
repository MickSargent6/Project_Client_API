{
  Filename (Unit) : TextFileIO.pas
  Creation Date   : 01/12/1998
  Release         :

  CHANGE HISTORY

  Date       Issue Ref   Engineer  Description
  01/12/1998  0.0  -----  DVD      Creation
  28/06/1999              DVD      Changes for logic
  07/09/2000  0.1  CR/41  MAS      Add Percentage Done Event, used on Read file
                                   but not write file
  30/07/2003  0.2         MAS      Add internal filesize function
  07/08/2003  0.3         MAS      Add SetFileName method
  23/01/2006  2.0         MAS      Add CreateRead and CreateWrite constructors

  DESCRIPTION

}
unit TextFileIO;

interface
uses
  Classes,Windows,SysUtils,Dialogs;

const
  FILE_COMMENT_STRING = '//';

type
  tOnPercentage = Procedure (aPercentage: Integer) of Object;

type
  eTextFile = Class (Exception);

type
  tTextFile = class(tObject)
  private
    fLastPercent: Integer;
    fRead: Integer;
    fSize: Integer;
    fFileName : string;
    fFile     : TextFile;
    fDelim,
    fCurrentRecord   : string;
    fOpen      : boolean;
    fRecordsRead,
    fWrite     : integer;
    fAcceptCom : boolean;
    fOnPercentage: tOnPercentage;

    function GetSubStr(aIndex:integer):string;
    Procedure DoPercentage;
    Procedure SetUpPercentage;
    function FileSize(aFile: String): Integer; overload;
    procedure SetFileName(const Value: string);

    { Read internal buffer }
  protected
    function  GetField(aIndex:integer):string;virtual;
    function  GetDelCount:integer;virtual;
    procedure IntReadNextRecord;
    function  IsCommentRecord:boolean;

  public
    { Inherited }
    Constructor Create;
    Constructor CreateRead  (Const aFileName: String);
    Constructor CreateWrite (Const aFileName: String);
    destructor Destroy;override;

    { Open existing, or create new }
    function OpenFile(aForRead:boolean):boolean;
    function CreateFile:boolean;
    function CloseFile:boolean;

    { Help Methods}
    procedure CreateWriteFile (Const aFileName: String);

    { IO Functions }
    procedure First;
    function  Eof:boolean;
    procedure Next;
    procedure Append(aStr:string);

    { General information }
    function  FileExists:boolean;
    function  IntEofFileSignalled:boolean;
    function FileSize: Integer; overload;

    { Properties }
    property FileName:string read fFileName write SetFileName;
    property CurrentRecord:string read fCurrentRecord write fCurrentRecord;
    property Delimiter:string read fDelim write fDelim ;
    property Field[aIndex:integer]:string read GetField;
    property DelimCount:integer read GetDelCount;
    property RecordsRead:integer read fRecordsRead;
    property IsOpen:boolean read fOpen;
    property AcceptComments:boolean read fAcceptCom write fAcceptCom;

    {Event}
    Property OnPercentage: tOnPercentage read fOnPercentage write fOnPercentage;
  end;

implementation

Const
  cmsgFILEALREADYOPEN = 'Can Not Assign Filename Existing File is Already Open (%s)';

// Routine: Create
// Author: M.A.Sargent  Date: 04/09/18  Version: V1.0
//
// Notes:
//
Constructor tTextFile.Create;
begin
  inherited;
  fOpen := False;
  fCurrentRecord := '';
  fRecordsRead  := 0;
  fOnPercentage := nil;
  fLastPercent  := 0;
  fSize         := 0;
  fAcceptCom := False;//Uppercase(GetRegistryString( LORS_KEY , cACCEPTFILECOMMENTS,'NO')) = 'YES';
end;

constructor tTextFile.CreateRead (Const aFileName: String);
begin
  Create;
  FileName := aFileName;
  if not OpenFile (True) then Raise Exception.CreateFmt ('Error: File (%s) Does Not Exist', [aFileName]);
end;

constructor tTextFile.CreateWrite (Const aFileName: String);
begin
  Create;
  CreateWriteFile (aFileName);
end;

destructor tTextFile.Destroy;
begin
  if fOpen then CloseFile;
  inherited;
end;

function tTextFile.OpenFile(aForRead:boolean):boolean;
begin
  if (not fOpen) and (fFileName<>'') and (FileExists) then
  begin
    {}
    if assigned (fOnPercentage) and aForRead then SetUpPercentage;

    Assign( fFile,fFileName );
    if aForRead then
    begin
      {$I-}
      Reset( fFile )
      {$I+}
    end else begin
      {$I-}
      System.Append( fFile )
      {$I+}
    end;
    fOpen := (IOResult=0);
    Result := fOpen;
    fRead  := 0;
    fCurrentRecord := '';
    fRecordsRead := 0;
    if (fOpen) and (aForRead) then First;
  end else
    Result := False;
end;

Procedure tTextFile.CreateWriteFile (Const aFileName: String);
begin
  FileName := aFileName;
  if not OpenFile (False) then
    if not CreateFile then Raise Exception.CreateFmt ('Error: File (%s) Could Not be Created', [aFileName]);
end;

Procedure tTextFile.SetUpPercentage;
begin
  fLastPercent := 0;
  fSize := FileSize (fFileName);
  if Assigned (fOnPercentage) then fOnPercentage (0);
end;

function tTextFile.CloseFile:boolean;
begin
  if fOpen then
  begin
    {$I-}
    System.CloseFile( fFile );
    {$I+}
    fOpen := False;
  end;
  Result := not fOpen;
end;

function tTextFile.GetDelCount:integer;
var
  n,c : integer;
begin
  c := 0;
  if fOpen then
  begin
    for n := 1 to Length(fCurrentRecord) do
      if Copy(fCurrentRecord,n,1)=fDelim then Inc(c);
  end;
  Result := c;
end;

function tTextFile.GetSubStr(aIndex:integer):string;
var
  p1,p2,
  c,n : integer;
begin
  { Get Start position }
  c := 0;
  n := 1;
  while (n <= Length(fCurrentRecord)) and (c < aIndex) do
  begin
    if Copy(fCurrentRecord,n,1)=fDelim then
      Inc(c);
    Inc(n);
  end;
  { Read until next delim }
  p1 := n;
  while (n <= Length(fCurrentRecord)) and (Copy(fCurrentRecord,n,1)<>fDelim) do Inc(n);
  p2 := n;
  Result := Copy(fCurrentRecord,p1,p2-p1);
end;

function tTextFile.GetField(aIndex:integer):string;
begin
  Result := Trim(GetSubStr(aIndex));
end;

function tTextFile.CreateFile:boolean;
begin
  if (not fOpen) and (fFileName<>'') then
  begin
    Assign( fFile,fFileName );
    {$I-}
    Rewrite( fFile );
    {$I+}
    if IOResult=0 then
      fOpen := True
    else
      fOpen := False;
    fCurrentRecord := '';
    FWrite := 0;
    Result := fOpen;
  end else
    Result := False;
end;

procedure tTextFile.Append(aStr:string);
begin
  if fOpen then
  begin
    WriteLn( fFile,aStr );
    Inc(fWrite);
  end;
end;

function tTextFile.FileExists:boolean;
begin
  Result := SysUtils.FileExists( fFileName );
end;

procedure tTextFile.IntReadNextRecord;
begin
  fCurrentRecord := '';
  if (fOpen) and not (eof) then
  begin
    {$I-}
    ReadLn( fFile , fCurrentRecord );
    {$I+}
    DoPercentage;
  end;
end;

Procedure tTextFile.DoPercentage;
var
  lCurrent: Integer;
begin
  if assigned (fOnPercentage) then begin       {if assigned}
    if (fSize < 250000) then Exit;

    fRead := fRead + length(fCurrentRecord);   {total bytes read}

    lCurrent := Trunc((fRead*100)/fSize)+1;    {}
    if (lCurrent > fLastPercent) then begin
      fOnPercentage (lCurrent);
      fLastPercent := lCurrent;
    end;
  end;
end;

function tTextFile.IsCommentRecord:boolean;
begin
  Result := Copy( Trim(fCurrentRecord),1,Length(FILE_COMMENT_STRING))=FILE_COMMENT_STRING;
end;

procedure tTextFile.Next;
begin
  repeat
    IntReadNextRecord;
  until not ((fAcceptCom) and   (IsCommentRecord));
  if not Eof then Inc(fRecordsRead);
end;

procedure tTextFile.First;
begin
  fCurrentRecord := '';
  if fOpen then
  Begin
    fRecordsRead := 0;
    Reset(fFile);
    Next;
  end;
end;

function tTextFile.IntEofFileSignalled:boolean;
begin
  if fOpen then
    Result := System.Eof(fFile)
  else
    Result := True;
end;

function tTextFile.Eof:boolean;
begin
  if fOpen then
    Result := (System.Eof(fFile)) and (fCurrentRecord='')
  else
    Result := True;
end;

function tTextFile.FileSize: Integer;
begin
  if (fFileName<>'') then
       Result := FileSize (fFileName)
  else Result := 0;
end;

Function tTextFile.FileSize (aFile: String): Integer;
var
  lFile: file of Byte;
begin
  Result := -1;                              {Default to -1, -1 indicates error}
  AssignFile(lFile, aFile);
  FileMode := 0;                             {Set file access to read only(0)}
  Reset(lFile);
  Try
    Result := System.FileSize(lFile);
  Finally
    System.CloseFile(lFile);
  end;
end;

// Notes: MAS 07/08/03 Added check on setting of filename
procedure tTextFile.SetFileName(const Value: string);
begin
  if (fFileName <> Value) then begin
    // close file is on is open
    if IsOpen then Raise eTextFile.CreateFmt (cmsgFILEALREADYOPEN, [fFileName]);
    fFileName := Value;
  end;
end;


end.


