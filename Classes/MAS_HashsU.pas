//
// Unit: MAS_HashsU
// Author: M.A.Sargent  Date: 19/10/12  Version: V1.0
//         ??
//         M.A.Sargent        23/03/15           V3.0
//
// Notes:
//  V2.0: Updated to use with Delphi XE2
//  V3.0
//
unit MAS_HashsU;

interface

Uses Classes, SysUtils, IdHashMessageDigest, idHash;

  Function MD5_AsFile       (Const aFileName: String): String;
  //
  Function MD5_AsStr        (Const aStr: String): String;
  Function fnMD5_CompareStr (Const aStr1, aStr2: String): Boolean;

implementation

Function MD5_AsFile (Const aFileName: String): String;
var
  idmd5 : TIdHashMessageDigest5;
  fs : TFileStream;
begin
  idmd5 := TIdHashMessageDigest5.Create;
  fs := TFileStream.Create (aFileName, fmOpenRead OR fmShareDenyWrite) ;
  try
    {$IFDEF VER150}
    result := idmd5.AsHex (idmd5.HashValue (fs));
    {$ELSE}
    result := idmd5.HashStreamAsHex (fs);
    {$ENDIF}
  finally
    fs.Free;
    idmd5.Free;
  end;
end;

Function MD5_AsStr (Const aStr: String): String;
var
  idmd5 : TIdHashMessageDigest5;
  fs : TStringStream;
begin
  idmd5 := TIdHashMessageDigest5.Create;
  fs := TStringStream.Create (aStr);
  try
    {$IFDEF VER150}
    result := idmd5.AsHex (idmd5.HashValue (fs));
    {$ELSE}
    result := idmd5.HashStreamAsHex (fs);
    {$ENDIF}
  finally
    fs.Free;
    idmd5.Free;
  end;
end;

// Routine: fnMD5_CompareStr
// Author:  M.A.Sargent  Date: 19/10/18 Version: V1.0
//
// Notes:
//
Function fnMD5_CompareStr (Const aStr1, aStr2: String): Boolean;
begin
  Result := (MD5_AsStr (aStr1) = MD5_AsStr (aStr2));
end;

end.
