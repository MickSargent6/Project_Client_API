//
// Unit: DLL_HelpersU
// Author: M.A.Sargent  Date: 26/10/17  Version: V1.0
//
// Notes:
//
unit DLL_HelpersU;

interface

Uses SysUtils;

  Function fnGetDLLName:       String;
  Function fnGetDLLDir:        String;
  Function fnGetDLLNameNoExtn: String;
  Function fnGetDLLIniFile (Const aWithPath: Boolean = True): String;
  //
  Function fnGetDLLTxtFile (Const aWithPath: Boolean): String; overload;
  Function fnGetDLLTxtFile (Const aPath: String): String; overload;

implementation

Uses MAS_DirectoryU, MAS_ConstsU;

// Routine: fnGetDLLName
// Author: M.A.Sargent  Date: 16/11/17  Version: V1.0
//
// Notes:
//
Function fnGetDLLName: String;
begin
  Result := GetModuleName (hInstance);
end;
Function fnGetDLLDir: String;
begin
  Result := ExtractFileDir (fnGetDLLName);
end;
Function fnGetDLLNameNoExtn: String;
begin
  Result := ChangeFileExt (fnGetDLLIniFile (False), '');
end;
Function fnGetDLLIniFile (Const aWithPath: Boolean): String;
begin
  Result := ChangeFileExt (GetModuleName (hInstance), cFILE_EXTN_INI);
  if not aWithPath then Result := ExtractFileName (Result);
end;

// Routine: fnGetDLLName
// Author: M.A.Sargent  Date: 16/11/17  Version: V1.0
//
// Notes:
//
Function fnGetDLLTxtFile (Const aWithPath: Boolean): String;
begin
  Result := fnGetDLLTxtFile ('');
  if not aWithPath then Result := ExtractFileName (Result);
end;
Function fnGetDLLTxtFile (Const aPath: String): String;
begin
  Result := ChangeFileExt (GetModuleName (hInstance), cFILE_EXTN_TXT);
  Case (aPath='') of
    True:;
    else  Result := AppendPath (aPath,  ExtractFileName (Result));
  end;
end;

end.
