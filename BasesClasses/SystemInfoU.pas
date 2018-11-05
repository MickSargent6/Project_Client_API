//
// Unit: SystemInfoU
// Author: M.A.Sargent  Date: 05/10/16  Version: V1.0
//         M.A.Sargent        25/10/16           V2.0
//         M.A.Sargent        04/08/17           V3.0
//         M.A.Sargent        26/10/17           V4.0
//
// Notes:
//  V2.0: Updated GenerateHardwareId
//  V3.0: fnOSInfo
//  V4.0: Updated to allow some attributes to be excluded, via in file and currently
//         hardcoded Win10 items
//
unit SystemInfoU;

Interface

uses
  Classes, SysUtils, ActiveX, ComObj, Variants, MASRecordStructuresU, MASStringListU, MAS_MemIniU, StrUtils;

type
   TMotherBoardInfo   = (Mb_SerialNumber,Mb_Manufacturer,Mb_Product,Mb_Model);
   TMotherBoardInfoSet= set of TMotherBoardInfo;
   TProcessorInfo     = (Pr_Description,Pr_Manufacturer,Pr_Name,Pr_ProcessorId,Pr_UniqueId);
   TProcessorInfoSet  = set of TProcessorInfo;
   TBIOSInfo          = (Bs_BIOSVersion,Bs_BuildNumber,Bs_Description,Bs_Manufacturer,Bs_Name,Bs_SerialNumber,Bs_Version);
   TBIOSInfoSet       = set of TBIOSInfo;
   TOSInfo            = (Os_BuildNumber,Os_BuildType,Os_Manufacturer,Os_Name,Os_SerialNumber,Os_Version);
   TOSInfoSet         = set of TOSInfo;
   TDiskInfo          = (diModel, diManufacturer, diSignature, diTotalHeads, diDeviceID, diMediaType);
   TDiskInfoSet       = set of TDiskInfo;
   tAdapterInfo       = (aiDescription, aiMACAddress, aiAdapterType);
   tAdapterInfoSet    = set of tAdapterInfo;
   //
   tElementType = (etUnknown, etMotherBoardInfo, etProcessorInfo, etBIOSInfo, etOSInfo, etDiskInfo, etAdapterInfo);
   tWindowsOS = (woUnknown, woWin7, woWin10);

const //properties names to get the data
   MotherBoardInfoArr: array[TMotherBoardInfo] of AnsiString =
                        ('SerialNumber','Manufacturer','Product','Model');

   OsInfoArr         : array[TOSInfo] of AnsiString =
                        ('BuildNumber','BuildType','Manufacturer','Name','SerialNumber','Version');

   BiosInfoArr       : array[TBIOSInfo] of AnsiString =
                        ('BIOSVersion','BuildNumber','Description','Manufacturer','Name','SerialNumber','Version');

   ProcessorInfoArr  : array[TProcessorInfo] of AnsiString =
                        ('Description','Manufacturer','Name','ProcessorId','UniqueId');

   DiskInfoArr: array[TDiskInfo] of AnsiString = ('Model', 'Manufacturer', 'Signature', 'TotalHeads', 'DeviceID', 'MediaType');

   AdapterInfoArr: array [tAdapterInfo] of AnsiString = ('Description', 'MACAddress', 'AdapterType');

type
   THardwareId  = class
   private
    fElementType: tElementType;
    fIniFile: tMAS_MemIniFile;
    fWindowsOS: tWindowsOS;
    fOSList: tMASStringList;
    FOSInfo         : TOSInfoSet;
    FBIOSInfo       : TBIOSInfoSet;
    FProcessorInfo  : TProcessorInfoSet;
    FMotherBoardInfo: TMotherBoardInfoSet;
    fDiskInfoSet: TDiskInfoSet;
    fAdapterInfo: tAdapterInfoSet;
    fList: tStringList;
    function GetHardwareIdHex: AnsiString;
    function GetBuffer: AnsiString;
    Procedure AddToList (Const aName, aValue: String);
    Procedure AddToListAsValuePair (Const aName, aValue: String);
    Procedure AddToTempList (Const aName, aValue: String);
    //
    Function fnOS: tWindowsOS;
    Procedure IntCopyOSInfoToOutputList;

    property  Buffer : AnsiString read GetBuffer; //return the content of the data collected in the system
    property  HardwareIdHex : AnsiString read GetHardwareIdHex; //get a hexadecimal represntation of the data collected
    Property  ElementType: tElementType read fElementType write fElementType;
    //

   public
     //Set the properties to  be used in the generation of the hardware id
    property  MotherBoardInfo : TMotherBoardInfoSet read FMotherBoardInfo write FMotherBoardInfo;
    property  ProcessorInfo : TProcessorInfoSet read FProcessorInfo write FProcessorInfo;
    property  BIOSInfo: TBIOSInfoSet read FBIOSInfo write FBIOSInfo;
    property  OSInfo  : TOSInfoSet read FOSInfo write FOSInfo;
    Property  DiskInfoSet: TDiskInfoSet read fDiskInfoSet write fDiskInfoSet;
    Property  AdapterInfo: tAdapterInfoSet read fAdapterInfo write fAdapterInfo;
    //
    Constructor Create (Generate:Boolean=True); overload;
    Constructor Create (Const aIniDir: String; Generate:Boolean=True); overload;
    Destructor Destroy; override;
    //
    Function GenerateHardwareId: tOKStrRec; //calculate the hardware id
    Function AsMD5: String;
    //
    Function fnOSInfo: tOKStrRec;
    //
    Property List: tStringList read fList;
   end;

implementation

Uses MAS_HashsU, MASCommonU, FormatResultU, MAS_FormatU, WindowsAPIU, MAS_DirectoryU, MAS_ConstsU, MASCommon_UtilsU;

Const
  //
  cBUILDNUMBER = 'BuildNumber';
  cVERSION     = 'Version';
  cINIFILE     = 'SystemInfo.Ini';

Function VarArrayToStr(const vArray: variant): AnsiString;

  function _VarToStr(const V: variant): AnsiString;
  var
  Vt: integer;
  begin
   Vt := VarType(V);
      case Vt of
        varSmallint,
        varInteger  : Result := AnsiString(IntToStr(integer(V)));
        varSingle,
        varDouble,
        varCurrency : Result := AnsiString(FloatToStr(Double(V)));
        varDate     : Result := AnsiString(VarToStr(V));
        varOleStr   : Result := AnsiString(WideString(V));
        varBoolean  : Result := AnsiString(VarToStr(V));
        varVariant  : Result := AnsiString(VarToStr(Variant(V)));
        varByte     : Result := AnsiChar(byte(V));
        varString   : Result := AnsiString(V);
        varArray    : Result := VarArrayToStr(Variant(V));
      end;
  end;

var
i : integer;
begin
    Result := '[';
    if (VarType(vArray) and VarArray)=0 then
       Result := _VarToStr(vArray)
    else
    for i := VarArrayLowBound(vArray, 1) to VarArrayHighBound(vArray, 1) do
     if i=VarArrayLowBound(vArray, 1)  then
      Result := Result+_VarToStr(vArray[i])
     else
      Result := Result+'|'+_VarToStr(vArray[i]);

    Result:=Result+']';
end;

function VarStrNull(const V:OleVariant):AnsiString; //avoid problems with null strings
begin
  Result:='';
  if not VarIsNull(V) then
  begin
    if VarIsArray(V) then
       Result:=VarArrayToStr(V)
    else
    Result:=AnsiString(VarToStr(V));
  end;
end;

{ THardwareId }

Constructor THardwareId.Create (Const aIniDir: String; Generate: Boolean);
var
  lvIniFileName: String;
begin
  fIniFile := Nil;
  if ((aIniDir <> '') and DirectoryExists (aIniDir)) then begin
    //
    lvIniFileName := AppendPath (aIniDir, cINIFILE);
    if FileExists (lvIniFileName) then
      fIniFile := tMAS_MemIniFile.Create (lvIniFileName);
  end;
  //
  Create (Generate);
end;

Constructor THardwareId.Create (Generate:Boolean=True);
begin
   inherited Create;
   CoInitialize(nil);
   fList := tStringList.Create;
   fElementType := etUnknown;

   //Set the propeties to be used in the hardware id generation
   FMotherBoardInfo :=[Mb_SerialNumber,Mb_Manufacturer,Mb_Product,Mb_Model];
   FOSInfo          :=[Os_BuildNumber,Os_BuildType,Os_Manufacturer,Os_Name,Os_SerialNumber,Os_Version];
   FBIOSInfo        :=[Bs_BIOSVersion,Bs_BuildNumber,Bs_Description,Bs_Manufacturer,Bs_Name,Bs_SerialNumber,Bs_Version];
   FProcessorInfo   :=[Pr_Description,Pr_Manufacturer,Pr_Name,Pr_ProcessorId,Pr_UniqueId];
   //FProcessorInfo   :=[];//including the processor info is expensive [Pr_Description,Pr_Manufacturer,Pr_Name,Pr_ProcessorId,Pr_UniqueId];
   fDiskInfoSet     := [diModel, diManufacturer, diSignature, diTotalHeads{, diDeviceID, diMediaType}];
   fAdapterInfo     := [aiDescription, aiMACAddress, aiAdapterType];
   //
   fWindowsOS := woUnknown;
   fOSList    := tMASStringList.Create;
   //
   if Generate then
    GenerateHardwareId;
end;

destructor THardwareId.Destroy;
begin
  if Assigned (fIniFile) then fIniFile.Free;
  fOSList.Free;
  fList.Free;
  CoUninitialize;
  inherited;
end;

function THardwareId.GetBuffer: AnsiString;
begin
  Result := fList.Text;
end;

// Routine: DLL_AddOn_Security
// Author: M.A.Sargent  Date: 19/10/16  Version: V1.0
//         M.A.Sargent        25/10/16           V2.0
//
// Notes: Main function which collect the system data.
//  V2.0: Updated to only include 'Fixed hard disk media'
//
Function THardwareId.GenerateHardwareId: tOKStrRec;
var
  objSWbemLocator : OLEVariant;
  objWMIService   : OLEVariant;
  objWbemObjectSet: OLEVariant;
  oWmiObject      : OLEVariant;
  oEnum           : IEnumvariant;
  iValue          : LongWord;
  SDummy          : AnsiString;
  Mb              : TMotherBoardInfo;
  Os              : TOSInfo;
  Bs              : TBIOSInfo;
  Pr              : TProcessorInfo;
  Di: TDiskInfo;
  Ni: tAdapterInfo;
begin;
  Result.OK := True;
  Try
    fList.Clear;

    objSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    objWMIService   := objSWbemLocator.ConnectServer('localhost','root\cimv2', '','');
    //
    AddToList ('ComputerName', fnComputerName);
    //
    // This section has been moved to before the MotherBoard info, it us still written in the same place
    // but here it can obtain and set the fWindowsOS property
    //
    if FOSInfo<>[] then//Windows info
    begin
      ElementType := etOSInfo;
      objWbemObjectSet:= objWMIService.ExecQuery('SELECT * FROM Win32_OperatingSystem','WQL',0);
      oEnum           := IUnknown(objWbemObjectSet._NewEnum) as IEnumVariant;
      //
      fOSList.Clear;
      while oEnum.Next(1, oWmiObject, iValue) = 0 do
      begin
        for Os := Low(TOSInfo) to High(TOSInfo) do
         if Os in FOSInfo then
         begin
            SDummy:=VarStrNull(oWmiObject.Properties_.Item(OsInfoArr[Os]).Value);
            AddToTempList (OsInfoArr[Os], SDummy);
            //
         end;
         oWmiObject:=Unassigned;
         //
      end;
      //
      fWindowsOS := fnOS;
    end;

    if FMotherBoardInfo<>[] then //MotherBoard info
    begin
      ElementType := etMotherBoardInfo;
      objWbemObjectSet:= objWMIService.ExecQuery('SELECT * FROM Win32_BaseBoard','WQL',0);
      oEnum           := IUnknown(objWbemObjectSet._NewEnum) as IEnumVariant;
      while oEnum.Next(1, oWmiObject, iValue) = 0 do
      begin
        for Mb := Low(TMotherBoardInfo) to High(TMotherBoardInfo) do
         if Mb in FMotherBoardInfo then
         begin
            SDummy:=VarStrNull(oWmiObject.Properties_.Item(MotherBoardInfoArr[Mb]).Value);
            AddToList (MotherBoardInfoArr[Mb], SDummy);
         end;
         oWmiObject:=Unassigned;
      end;
    end;

    //
    if FOSInfo<>[] then begin//Windows info
      //
      ElementType := etOSInfo;
      IntCopyOSInfoToOutputList;
    end;

    if FBIOSInfo<>[] then//BIOS info
    begin
      ElementType := etBIOSInfo;
      objWbemObjectSet:= objWMIService.ExecQuery('SELECT * FROM Win32_BIOS','WQL',0);
      oEnum           := IUnknown(objWbemObjectSet._NewEnum) as IEnumVariant;
      while oEnum.Next(1, oWmiObject, iValue) = 0 do
      begin
        for Bs := Low(TBIOSInfo) to High(TBIOSInfo) do
         if Bs in FBIOSInfo then
         begin
            SDummy:=VarStrNull(oWmiObject.Properties_.Item(BiosInfoArr[Bs]).Value);
            AddToList (BiosInfoArr[Bs], SDummy);
         end;
         oWmiObject:=Unassigned;
      end;
    end;

    if FProcessorInfo<>[] then//CPU info
    begin
      ElementType := etProcessorInfo;
      objWbemObjectSet:= objWMIService.ExecQuery('SELECT * FROM Win32_Processor','WQL',0);
      oEnum           := IUnknown(objWbemObjectSet._NewEnum) as IEnumVariant;
      while oEnum.Next(1, oWmiObject, iValue) = 0 do
      begin

        for Pr := Low(TProcessorInfo) to High(TProcessorInfo) do
         if Pr in FProcessorInfo then
         begin
            SDummy:=VarStrNull(oWmiObject.Properties_.Item(ProcessorInfoArr[Pr]).Value);
            AddToList (ProcessorInfoArr[Pr], SDummy);
         end;
         oWmiObject:=Unassigned;
      end;
    end;

    if fDiskInfoSet<>[] then begin
      // Disk Info
      ElementType := etDiskInfo;
      objWbemObjectSet:= objWMIService.ExecQuery('SELECT * FROM Win32_DiskDrive where MediaType = ''Fixed hard disk media''','WQL',0);
      oEnum           := IUnknown(objWbemObjectSet._NewEnum) as IEnumVariant;
      while oEnum.Next(1, oWmiObject, iValue) = 0 do begin

        for Di := Low(TDiskInfo) to High(TDiskInfo) do
          if Di in fDiskInfoSet then begin
            SDummy:=VarStrNull (oWmiObject.Properties_.Item (DiskInfoArr[Di]).Value);
            AddToList (DiskInfoArr[Di], SDummy);
          end;
        //
        oWmiObject:=Unassigned;
      end;
    end;


    if fAdapterInfo<>[] then begin
      // Network Adapter Info
      ElementType := etAdapterInfo;
      objWbemObjectSet:= objWMIService.ExecQuery('SELECT * FROM Win32_NetworkAdapter where AdapterType is not null and MACAddress is not Null','WQL',0);
      oEnum           := IUnknown(objWbemObjectSet._NewEnum) as IEnumVariant;
      while oEnum.Next(1, oWmiObject, iValue) = 0 do begin

        for Ni := Low(tAdapterInfo) to High(tAdapterInfo) do
          if Ni in fAdapterInfo then begin
            SDummy:=VarStrNull (oWmiObject.Properties_.Item (AdapterInfoArr[Ni]).Value);
            AddToList (AdapterInfoArr[Ni], SDummy);
          end;
        //
        oWmiObject:=Unassigned;
      end;
    end;
  Except
    on e:Exception do begin
      Result := fnResult (False, 'Error: GenerateHardwareId. (%s)', [e.Message]);
      fnRaiseOnFalse (Result);
    end;
  end;
end;

Function THardwareId.GetHardwareIdHex: AnsiString;
begin
  SetLength(Result,Length(Buffer)*2);
  BinToHex(PAnsiChar(Buffer),PAnsiChar(Result),Length(Buffer));
end;

// Routine: AddToList
// Author: M.A.Sargent  Date: 26/10/17  Version: V1.0
//
// Notes:
//
Procedure THardwareId.AddToList (Const aName, aValue: String);
var
  aOK: Boolean;
  lvValue: String;
begin
  lvValue := aValue;
  aOK := True;
  Case Assigned (fIniFile) of
    True: begin
      //
      Raise Exception.Create ('Not Yet Implimented, need to Read items to be excluded from the tIniFile');
    end;
    else Case Self.fWindowsOS of
           woWin10: Case Self.ElementType of
                      etOSInfo: begin
                                  if AnsiMatchText (aName, [cBUILDNUMBER, cVERSION]) then
                                    lvValue := 'Win10 Value Excluded';
                      end
                      else {Do Nothing aOK already True}
                    end;
           else {Do Nothing aOK already True}
         end;
  end;
  //
  if aOK then fList.Add (fnTS_Format ('%s: %s', [aName, lvValue]));
end;
Procedure THardwareId.AddToListAsValuePair (Const aName, aValue: String);
begin
  fList.Add (fnTS_Format ('%s=%s', [Trim (aName), Trim (aValue)]));
end;

Procedure THardwareId.AddToTempList (Const aName, aValue: String);
begin
  fOSList.Add (fnTS_Format ('%s=%s', [Trim (aName), Trim (aValue)]));
end;

Function THardwareId.AsMD5: String;
begin
  Result := MD5_AsStr (HardwareIdHex);
end;

// Routine: fnOS
// Author: M.A.Sargent  Date: 25/10/17  Version: V1.0
//
// Notes: Read the
//
Function THardwareId.fnOS: tWindowsOS;
begin
  if (fOSList.fnPosIndex2 (cMC_WV_WINDOWS7) <> cMC_NOT_FOUND) then Result := woWin7
  else if (fOSList.fnPosIndex2 (cMC_WV_WINDOWS10) <> cMC_NOT_FOUND) then Result := woWin10
  else Result := woUnknown;
end;

Procedure THardwareId.IntCopyOSInfoToOutputList;
var
  x: Integer;
  lvRes: tValuePair;
begin
  //
  for x := 0 to fOSList.Count-1 do begin
    // loop thru and process all OS entries
    lvRes := GetValuePair (fOSList.Strings[X]);
    AddToList (lvRes.Name, lvRes.Value);
  end;
end;

Function THardwareId.fnOSInfo: tOKStrRec;
var
  objSWbemLocator : OLEVariant;
  objWMIService   : OLEVariant;
  objWbemObjectSet: OLEVariant;
  oWmiObject      : OLEVariant;
  oEnum           : IEnumvariant;
  iValue          : LongWord;
  SDummy          : AnsiString;
  Os              : TOSInfo;
begin
  Result.OK := True;
  Try
    fList.Clear;

    objSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    objWMIService   := objSWbemLocator.ConnectServer('localhost','root\cimv2', '','');
    //
    AddToListAsValuePair ('ComputerName', fnComputerName);
    //
    if FOSInfo<>[] then//Windows info
    begin
      objWbemObjectSet:= objWMIService.ExecQuery('SELECT * FROM Win32_OperatingSystem','WQL',0);
      oEnum           := IUnknown(objWbemObjectSet._NewEnum) as IEnumVariant;
      while oEnum.Next(1, oWmiObject, iValue) = 0 do
      begin
        for Os := Low(TOSInfo) to High(TOSInfo) do
         if Os in FOSInfo then
         begin
            SDummy:=VarStrNull(oWmiObject.Properties_.Item(OsInfoArr[Os]).Value);
            AddToListAsValuePair (OsInfoArr[Os], SDummy);
         end;
         oWmiObject:=Unassigned;
      end;
    end;
  Except
    on e:Exception do begin
      Result := fnResult (False, 'Error: OSInfo. (%s)', [e.Message]);
      fnRaiseOnFalse (Result);
    end;
  end;
end;

end.
