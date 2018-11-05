//
// Unit: MASWindowsSystemInfoU
// Author: M.A.Sargent  Date: 24/11/11  Version: V1.0
//         M.A.Sargent        15/01/12           V2.0
//         M.A.Sargent        25/10/12           V3.0
//
// Notes:
//  V3.0: Updated fnExcelVersion
//
unit MASWindowsSystemInfoU;

interface

Uses Windows, SysUtils, Classes, ActiveX, Variants, MASRecordStructuresU, MAS_ConstsU;//,
      //WbemScripting_TLB;   { Typelib name: "Microsoft Windows WMI Scripting V1.2 Library" }


type
  _OSVERSIONINFOEX = record
         dwOSVersionInfoSize : DWORD;
         dwMajorVersion      : DWORD;
         dwMinorVersion      : DWORD;
         dwBuildNumber       : DWORD;
         dwPlatformId        : DWORD;
         szCSDVersion        : array[0..127] of AnsiChar;
         wServicePackMajor   : WORD;
         wServicePackMinor   : WORD;
         wSuiteMask          : WORD;
         wProductType        : BYTE;
         wReserved           : BYTE;
  end;
  tOSVERSIONINFOEX = _OSVERSIONINFOEX;

  Function fnGetVersion (Const aDirectory, aFileName: String; Const aBuild: Boolean = True): String; overload;
  Function fnGetVersion (Const aFileName: String; Const aBuild: Boolean = True): String; overload;
  //
  Function WindowsVersion: String; overload;
  Function WindowsVersion (var aInfo: tOSVERSIONINFOEX): Boolean; overload;
  //
  Function fnGetHardDiskSerial_AsString (Const DriveLetter: Char): string;
  Function fnGetHardDiskSerial (Const DriveLetter: Char): DWORD;

  Function fnGetUserName: String;
  Function fnComputerName: String;
  //
  Function fnGenerateSystemID (Const aDumpFile: Boolean; Const aDir: String): tOKStrRec;

implementation

Uses MAS_DirectoryU, SystemInfoU, FormatResultU, MAS_FormatU, MASCommonU;

Const
  VER_NT_WORKSTATION = 1;
  SM_SERVERR2 = 89;

  // Windows Version
  function GetVersionExA (var lpVersionInformation: TOSVersionInfoEX): BOOL; stdcall; external kernel32;

// Routine: GetVersion
// Author: M.A.Sargent  Date: 04/07/11  Version: V1.0
//         M.A.Sargent        06/07/18           V2.0
//
// Notes:
//  V2.0: Updated to test the return value of GetFileVersionInfo, returns False if Version INfo is not Included
//
Function fnGetVersion (Const aDirectory, aFileName: String; Const aBuild: Boolean): String;
begin
  Result := fnGetVersion (AppendPath (aDirectory, aFileName));
end;

Function fnGetVersion (Const aFileName: String; Const aBuild: Boolean): String;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  Try
    VerInfoSize := GetFileVersionInfoSize(PChar (aFileName), Dummy);
    GetMem(VerInfo, VerInfoSize);
    Try
      if GetFileVersionInfo(PChar (aFileName), 0, VerInfoSize, VerInfo) then begin
        VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
        with VerValue^ do begin
          Result := IntToStr (dwFileVersionMS shr 16);
          Result := Result + '.' + IntToStr(dwFileVersionMS and $FFFF);
          Result := Result + '.' + IntToStr(dwFileVersionLS shr 16);
          Case aBuild of
            True:  Result := fnTS_Format ('%s Build(%s)', [Result, IntToStr(dwFileVersionLS and $FFFF)]);
            False: Result := Result + '.' + IntToStr(dwFileVersionLS and $FFFF);
          end;
        end;
      end
      else Result := 'Error: Version Information Not Present';
    Finally
      FreeMem(VerInfo, VerInfoSize);
    end;
  Except
    Result := 'Error: Version Unknown';
  end;
end;

// Routine: WindowsVersion
// Author: M.A.Sargent  Date: 04/07/11  Version: V1.0
//
// Notes:
//
Function WindowsVersion (var aInfo: tOSVERSIONINFOEX): Boolean;
begin
  aInfo.dwOSVersionInfoSize := SizeOf(aInfo);
  Result := GetVersionExA (aInfo);
end;

Function WindowsVersion: String;
var
  OSINFO: TOSVERSIONINFOEX;
begin
  Result := 'Error';
  if WindowsVersion (OSINFO) then begin
    if (OSINFO.dwMajorVersion = 5) and (OSINFO.dwMinorVersion = 0) then
      Result := 'Windows 2000'
    else if (OSINFO.dwMajorVersion = 5) and (OSINFO.dwMinorVersion = 1) then
      Result := 'Windows XP'
    else if (OSINFO.dwMajorVersion = 5) and (OSINFO.dwMinorVersion = 2) and (GetSystemMetrics(SM_SERVERR2) = 0) then
      Result := 'Windows Server 2003'
     else if (OSINFO.dwMajorVersion = 5) and (OSINFO.dwMinorVersion = 2) and (GetSystemMetrics(SM_SERVERR2) <> 0) then
      Result := 'Windows Server 2003 R2'
    else if (OSINFO.dwMajorVersion = 6) and (OSINFO.dwMinorVersion = 0) and (OSINFO.wProductType = VER_NT_WORKSTATION) then
      Result := 'Windows Vista'
    else if (OSINFO.dwMajorVersion = 6) and (OSINFO.dwMinorVersion = 0) and (OSINFO.wProductType <> VER_NT_WORKSTATION) then
      Result := 'Windows Server 2008'
    else if (OSINFO.dwMajorVersion = 6) and (OSINFO.dwMinorVersion = 1) and (OSINFO.wProductType <> VER_NT_WORKSTATION) then
      Result := 'Windows Server 2008 R2'
    else if (OSINFO.dwMajorVersion = 6) and (OSINFO.dwMinorVersion = 1) and (OSINFO.wProductType = VER_NT_WORKSTATION) then
      Result := 'Windows 7'
    else
      Result := 'Unknown';
  end;
end;

// Routine: fnGetHardDiskSerial
// Author: M.A.Sargent  Date: 04/07/11  Version: V1.0
//
// Notes:
//
function fnGetHardDiskSerial (Const DriveLetter: Char): DWORD;
var
  NotUsed:     DWORD;
  VolumeFlags: DWORD;
  VolumeInfo:  array[0..MAX_PATH] of Char;
begin
  GetVolumeInformation(PChar(DriveLetter + ':\'), nil, SizeOf(VolumeInfo), @Result, NotUsed, VolumeFlags, nil, 0);
end;
function fnGetHardDiskSerial_AsString (Const DriveLetter: Char): String;
var
  VolumeSerialNumber: DWORD;
begin
  VolumeSerialNumber := fnGetHardDiskSerial (DriveLetter);
  Result := Format('%.10X', [VolumeSerialNumber]);
end;

// Notes: function to get the current loggedin user
Function fnGetUserName: String;
var
  UserName: array[0..30] of Char;
  Size: DWord;
begin
  Size := High(UserName);
  GetUserName (UserName, Size);
  Result := UpperCase (StrPas(UserName));
end;

// Notes: Add a Function to get the Computer Name
function fnComputerName: String;
var
  buffer: array[0..255] of char;
  size: dword;
begin
  size := 256;
  if GetComputerName (buffer, size) then
    Result := buffer
  else
    Result := ''
end;

// Routine: fnGenerateSystemID
// Author: M.A.Sargent  Date: 06/05/13  Version: V1.0
//
// Notes:
//
Function fnGenerateSystemID (Const aDumpFile: Boolean; Const aDir: String): tOKStrRec;
var
  lvObj:      tHardwareId;
  lvFileName: String;
  lvList:     tStringList;
begin
  Try
    lvList := tStringList.Create;
    Try
      lvObj := tHardwareId.Create (False);
      try
        lvObj.AdapterInfo   := [];
        lvObj.ProcessorInfo := [];

        lvObj.GenerateHardwareId;
        if aDumpFile then begin
          lvFileName := fnGenTempFile (aDir, 'MachineID', fnTS_Format ('%s.Txt', [lvObj.AsMD5]), True, fntDateTime);
          lvObj.List.SaveToFile (lvFileName);
          lvList.Add (fnAddValuePair ('FileName', lvFileName));
        end;
        //
        {$IFDEF VER150}
        Result := fnSet_OKStrRec (lvObj.AsMD5);
        {$ELSE}
        Result.SetValue (lvObj.AsMD5);
        {$ENDIF}
        lvList.Add (fnAddValuePair ('MD5', lvObj.AsMD5));
      finally
       lvObj.Free;
      end;
    Finally
      lvList.Free;
    End;
  except
    on E:Exception do begin
      Result := fnResult ('Error: DLL_GenerateSystemID (%s)', [e.Message]);
    end;
  end;
end;

end.
