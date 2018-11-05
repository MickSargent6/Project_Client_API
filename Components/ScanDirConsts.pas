//
// Unit:
// Author: M.A.Sargent  Date: //06  Version: V1.0
//
// Notes:
//
//
unit ScanDirConsts;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs{,
   MASCollectionsU};

type
  tFileInfoRec = record
    Name : String;
    Size : Integer;
    Time : tDate;
  end;

  tFileInfo = class(tObject)
  private
    fName : string;
    fSize : integer;
    fTime : integer;
    fExtended: TWin32FindData;
  public
    property FileName : string read fName write fName;
    property FileSize : integer read fSize write fSize;
    property FileTime : integer read fTime write fTime;
    Property Extended: TWin32FindData read fExtended write fExtended;
  end;

  tFileList = class(tList)
  Private
    Function FileInfoByIndex (const aIndex: Integer): tFileInfo;
  public
    function  Add(aFileName:string;aSize,aTime:integer; Const aExtended: TWin32FindData):tFileInfo; overload;
    procedure Clear; override;
    procedure SortFiles;
    Procedure CopyToList (aList: tStrings);
  end;

  tOnFile = procedure(Sender:tObject;aName:string;aSize,aTime:integer) of object;
  tOnFileContinue = procedure(Sender:tObject;aName:string; aCount, aSize,aTime:integer; var Continue: Boolean) of object;
  tOnFileContinue2 = procedure(Sender:tObject;aName:string; aCount, aSize,aTime:integer; Const aExtended: TWin32FindData; var Continue: Boolean) of object;
  tOnFileAction = procedure (Const aName: String; var aAccept: Boolean) of object;
  //
  tOnDir  = procedure(Sender:tObject;aDirName:string;var aAllowScan:boolean) of object;
  tOnListEvent = Procedure (var aList: tStrings; var ProcessListEvent: Boolean) of object;
  //tOnCollectionEvent = Procedure (aCollections: tMASStringCollections) of object;

  Function fnDirScanToRec (aStr: String): tFileInfoRec;

implementation

Uses DissectU;

procedure tFileList.Clear;
begin
  while (Count > 0) do
  begin
    if Assigned( Items[0]) then tFileInfo(Items[0]).Free;
    Delete(0);
  end;
  inherited;
  Pack;
end;

function tFileList.Add(aFileName: string; aSize, aTime: integer; Const aExtended: TWin32FindData): tFileInfo;
var
  r : tFileInfo;
begin
  r := tFileInfo.Create;
  r.FileName := aFileName;
  r.FileSize := aSize;
  r.FileTime := aTime;
  r.Extended := aExtended;
  inherited Add(r);
  Result := r;
end;

function SortFunc( Val1,Val2 : tFileInfo ):integer;
begin
  Result := Val1.FileTime - Val2.FileTime;
end;

procedure tFileList.SortFiles;
begin
  Sort(@SortFunc);
end;

Function tFileList.FileInfoByIndex (const aIndex: Integer): tFileInfo;
begin
  Result := tFileInfo (Items[aIndex]);
end;

// Routine: CopyToList
// Author: M.A.Sargent  Date: 08/02/06  Version: V1.0
//
// Notes:
//
procedure tFileList.CopyToList (aList: tStrings);
var
  x: Integer;
  lvFile: tFileInfo;
begin
  for x := 0 to Count-1 do begin
    lvFile := FileInfoByIndex (x);
    if Assigned (lvFile) then aList.Add (lvFile.FileName);
  end;
end;

Function fnDirScanToRec (aStr: String): tFileInfoRec;
begin
  Result.Name := GetField (aStr, ',', 0);
  Result.Size := StrToInt (GetField (aStr, ',', 1));
  Result.Time := FileDateToDateTime (StrToInt (GetField (aStr, ',', 2)));
end;

end.
