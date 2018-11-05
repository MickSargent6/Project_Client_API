//
// Unit: MAS_LocalityU
// Author: M.A.Sargent  Date: 10/10/12  Version: V1.0
//         M.A.Sargent        18/09/13           V2.0
//         M.A.Sargent        23/05/18           V3.0
//
// Notes:
//  V2.0: Updated to make Thread Safe, local variable not a global one
//  V3.0: Updated to add another version of SetLocalSettings
//
unit MAS_LocalityU;

interface

Uses Windows, SysUtils, CriticalSectionU;
  //
  //
  Procedure SetLocalSettings (Const aShortDateFormat: String); overload;
  Procedure SetLocalSettings (Const aFormatSettings: tFormatSettings); overload;
  //
  Procedure ResetAllLocalSettings;

  Function fnTS_LocaleSettings: tFormatSettings;
  Function fnEPOCH: Integer;


implementation

var
  gblEPOCH: Integer = 50;
  gblLocalSettings: tFormatSettings;
  gblMAS_LocalityMASRORWSynch: tMASRORWSynch = Nil;

Function fnEPOCH: Integer;
begin
  Result := gblEPOCH;
end;

// Routine: SetLocalSettings
// Author: M.A.Sargent  Date: 12/05/12  Version: V1.0
//
// Notes:
//
Procedure SetLocalSettings (Const aShortDateFormat:String);
begin
  gblMAS_LocalityMASRORWSynch.EnterRW;
  try
    gblLocalSettings.ShortDateFormat := aShortDateFormat;
  finally
    gblMAS_LocalityMASRORWSynch.LeaveRW;
  end;
end;
Procedure SetLocalSettings (Const aFormatSettings: tFormatSettings);
begin
  gblMAS_LocalityMASRORWSynch.EnterRW;
  try
    gblLocalSettings := aFormatSettings;
  finally
    gblMAS_LocalityMASRORWSynch.LeaveRW;
  end;
end;

// Routine: ResetAllLocalSettings
// Author: M.A.Sargent  Date: 23/05/18  Version: V1.0
//
// Notes:
//
Procedure ResetAllLocalSettings;
begin
  gblMAS_LocalityMASRORWSynch.EnterRW;
  try
    GetLocaleFormatSettings (LOCALE_SYSTEM_DEFAULT, gblLocalSettings);
  finally
    gblMAS_LocalityMASRORWSynch.LeaveRW;
  end;
end;
//
Function fnTS_LocaleSettings: tFormatSettings;
begin
  gblMAS_LocalityMASRORWSynch.EnterRO;
  try
    Result := gblLocalSettings;
  finally
    gblMAS_LocalityMASRORWSynch.LeaveRO;
  end;
end;

Initialization
  gblMAS_LocalityMASRORWSynch := tMASRORWSynch.Create;
  gblMAS_LocalityMASRORWSynch.EnterRW;
  try
    GetLocaleFormatSettings (LOCALE_SYSTEM_DEFAULT, gblLocalSettings);
  finally
    gblMAS_LocalityMASRORWSynch.LeaveRW;
  end;
Finalization
  gblMAS_LocalityMASRORWSynch.Free;

end.
