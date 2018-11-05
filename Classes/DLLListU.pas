//
// Unit: DLLListU
// Author: M.A.Sargent  Date: 29/10/11  Version: V1.0
//         M.A.Sargent        21/09/12           V2.0
//         M.A.Sargent        21/09/12           V3.0
//         M.A.Sargent        19/12/12           V4.0
//         M.A.Sargent        03/01/13           V5.0
//         M.A.Sargent        28/08/18           V6.0
//
// Notes:
//  V2.0: FR/1034 Bug Fix in Clear;
//  V3.0: Updated to just store the DLL Filename
//  V4.0:
//  V5.0: Add helper function h_GetDLLAddress
//  V6.0: Updated Constructor tDLLList.Create;
//
unit DLLListU;

interface

Uses Classes, MASStringListU, Windows, SysUtils, CriticalSectionU;

Type
  tDLLList = Class (tObject)
  Private
    fList:      tMASThreadSafeStringList;
    fLastError: String;
    //
    Procedure AddDLL (Const aLibrary: String; Const aHandle: tHandle);
    Function  fnExtractFileName (Const aName: String): String;
  Public
    Constructor Create;
    Destructor Destroy; override;
    Procedure Clear;
    //
    Function OpenLibrary   (Const aLibrary: String; Const RaiseOnError: Boolean = True): tHandle;
    Function CloseLibrary  (Const aLibrary: String): Boolean;
    Function fnGetHandle   (Const aLibrary: String): tHandle;
    Function GetDLLAddress (Const aLibrary, aName: String; Const RaiseOnError: Boolean = True): tFarProc;
    //
    Property LastError: String read fLastError;
  end;

  Function h_GetDLLAddress (Const aHandle: tHandle; Const aName: String; Const RaiseOnError: Boolean): tFarProc;

implementation

Function h_GetDLLAddress (Const aHandle: tHandle; Const aName: String; Const RaiseOnError: Boolean): tFarProc;
begin
  Result := Nil;
  if (aHandle <> 0) then begin
    Result := GetProcAddress (aHandle, pChar(aName));
    if (Result = nil) then begin
      if RaiseOnError then Raise Exception.CreateFmt ('Error: DLL Address (%s) Not Found', [aName]);
    end;
  end;
end;

{ tDLLList }

// Routine:
// Author: M.A.Sargent  Date: 04/10/11  Version: V1.0
//         M.A.Sargent        28/08/18           V2.0
//
// Notes:
//  V2.0: Updated to Set OwnObjects False, tMASThreadSafeStringList noiw updated to have this Property
//
Constructor tDLLList.Create;
begin
  Inherited;
  fList := tMASThreadSafeStringList.CreateSorted (dupError);
  fList.OwnsObjects := False;
  fLastError  := '';
end;

destructor tDLLList.Destroy;
begin
  Clear;
  fList.Free;
  inherited;
end;

// Routine: OpenLibrary
// Author: M.A.Sargent  Date: 19/12/12  Version: V1.0
//
// Notes:
//
Function tDLLList.OpenLibrary (Const aLibrary: String; Const RaiseOnError: Boolean): tHandle;
var
  lvDLLName: String;
begin
  lvDLLName := fnExtractFileName (aLibrary);
  fLastError := '';
  Case fList.Exists (lvDLLName) of
    True: Result := fnGetHandle (aLibrary);
    else begin
      Result := LoadLibrary (pChar (aLibrary));
      if (Result > 0) then begin
        AddDLL (aLibrary, Result);
      end
      else begin
        fLastError := Format ('Error: Loading DLL (%s) %s', [aLibrary, SysErrorMessage(GetLastError)]);
        if RaiseOnError then Raise Exception.Create  (fLastError);
      end;
    end;
  end;
end;

// Routine:
// Author: M.A.Sargent  Date: 04/10/11  Version: V1.0
//
// Notes:
//
function tDLLList.CloseLibrary (Const aLibrary: String): Boolean;
var
  lvHandle: tHandle;
begin
  fLastError := '';
  Result := False;
  lvHandle := fnGetHandle (aLibrary);
  if (lvHandle > 0) then begin
    fList.DeleteByName (aLibrary);
    Result := FreeLibrary (lvHandle);
    if not Result then begin
      fLastError := Format ('Error: Unloading DLL (%s) %s', [aLibrary, SysErrorMessage(GetLastError)]);
    end;
  end
  else fLastError := Format ('Error: DLL (%s) Has Not Been Previously Loaded', [aLibrary]);
end;

// Routine:
// Author: M.A.Sargent  Date: 04/10/11  Version: V1.0
//
// Notes:
//
Procedure tDLLList.AddDLL (Const aLibrary: String; Const aHandle: tHandle);
var
  lvDLLName: String;
begin
  lvDLLName := fnExtractFileName (aLibrary);
  fList.AddObject (lvDLLName, tObject(aHandle));
end;

// Routine:
// Author: M.A.Sargent  Date: 04/10/11  Version: V1.0
//
// Notes:
//
function tDLLList.fnGetHandle (Const aLibrary: String): tHandle;
var
  x: Integer;
  lvDLLName: String;
begin
  lvDLLName := fnExtractFileName (aLibrary);
  fLastError := '';
  if fList.Find (lvDLLName, x) then
       Result := tHandle (fList.fnObject (x))
  else begin
    Result := 0;
    fLastError := Format ('Error: DLL (%s) Not Loaded', [aLibrary]);
  end;
end;

// Routine: GetDLLAddress
// Author: M.A.Sargent  Date: 04/10/11  Version: V1.0
//         M.A.Sargent        19/12/12           V2.0
//
// Notes:
//  V2.0: Bug fix,
//
Function tDLLList.GetDLLAddress (Const aLibrary, aName: String; Const RaiseOnError: Boolean): tFarProc;
var
  lvHandle: tHandle;
begin
  fLastError := '';
  Result := Nil;
  lvHandle := OpenLibrary (aLibrary, RaiseOnError);
  if (lvHandle <> 0) then begin
    Result := GetProcAddress (lvHandle, pChar(aName));
    if (Result = nil) then begin
      fLastError := Format ('Error: DLL (%s) Address (%s) Not Found', [aLibrary, aName]);
      if RaiseOnError then Raise Exception.Create  (fLastError);
    end;
  end;
end;

// Routine:
// Author: M.A.Sargent  Date: 04/10/11  Version: V1.0
//         M.A.Sargent        21/09/12           V2.0
//
// Notes:
//  V2.0: Bug Fix, Close the Library before calling the Inherited Clear
//
procedure tDLLList.Clear;
var
  x: Integer;
begin
  for x := fList.Count-1 downto 0 do begin
    if not CloseLibrary (fList.fnString (x)) then Raise Exception.Create ('Error: Clearing DLL List');
  end;
  inherited;
end;

// Routine: fnExtractFileName
// Author: M.A.Sargent  Date: 21/09/12  Version: V1.0
//
// Notes:
//
Function tDLLList.fnExtractFileName (Const aName: String): String;
begin
  Result := ExtractFileName (aName);
  if (Result='') then Result := aName;
end;

end.
