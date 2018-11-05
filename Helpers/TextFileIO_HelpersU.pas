//
// Unit: MAS_FormatU
// Author: M.A.Sargent  Date: 04/01/13  Version: V1.0
//
// Notes:
//
unit TextFileIO_HelpersU;

interface

Uses TextFileIO, MASRecordStructuresU, Classes, SysUtils, IdThreadSafe;

  //
  Function h_fnWriteToTextFile (Const aFileName: String; Const aFormat: string; Const Args: array of const; Const aDateStamp: Boolean = True): tOKStrRec; overload;
  Function h_fnWriteToTextFile (Const aFileName, aMsg: String; Const aDateStamp: Boolean = True): tOKStrRec; overload;
  Function h_fnWriteToTextFile (Const aFileName: String; Const aList: tStrings; Const aDateStamp: Boolean = True): tOKStrRec; overload;

implementation

Uses MAS_FormatU, MASDatesU, FormatResultU;

var
  gblThreadLock: tIdThreadSafe = Nil;

// Routine: h_fnWriteToTextFile
// Author: M.A.Sargent  Date: 04/09/18  Version: V1.0
//
// Notes:
//
Function h_fnWriteToTextFile (Const aFileName: String; Const aFormat: string; Const Args: array of const; Const aDateStamp: Boolean): tOKStrRec;
begin
  Result := h_fnWriteToTextFile (aFileName, fnTS_Format (aFormat, Args), aDateStamp);
end;
Function h_fnWriteToTextFile (Const aFileName, aMsg: String; Const aDateStamp: Boolean): tOKStrRec;
var
  lvObj: tStringList;
begin
  lvObj := tStringList.Create;
  Try
    lvObj.Add (aMsg);
    Result := h_fnWriteToTextFile (aFileName, lvObj, aDateStamp);
  Finally
    lvObj.Free;
  end;
end;
Function h_fnWriteToTextFile (Const aFileName: String; Const aList: tStrings; Const aDateStamp: Boolean): tOKStrRec;
var
  lvNow:      String;
  lvTextFile: tTextFile;
  x:          Integer;
begin
  if not Assigned (aList) then Exit;
  Try
    gblThreadLock.Lock;
    Try
      lvTextFile := tTextFile.CreateWrite (aFileName);
      Try
        lvNow := fnTS_DateTimeToStr (Now);
        if not lvTextFile.IsOpen then Raise Exception.CreateFmt ('Error: File (%s) Could Not Be Opened', [aFileName]);
        for x := 0 to aList.Count-1 do
          Case aDateStamp of
            True: lvTextFile.Append ('['+lvNow+'] '+aList.Strings[x]);
            else  lvTextFile.Append (aList.Strings[x]);
          end;
      Finally
        lvTextFile.Free;
      end;
    Finally
      gblThreadLock.UnLock;
    end;
  except
    on e:Exception do
      Result := fnResultException ('h_fnWriteToTextFile', 'Failed to Write to File. (%s) %s', [aFileName, aList.Text], e);
  end;
end;

Initialization
  gblThreadLock := tIdThreadSafe.Create;
Finalization
  gblThreadLock.Free;

end.

