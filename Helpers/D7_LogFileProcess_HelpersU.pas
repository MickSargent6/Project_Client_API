//
// Unit: D7_LogFileProcess_HelpersU
// Author: M.A.Sargent  Date: 04/09/18  Version: V1.0
//
// Notes:
//
unit D7_LogFileProcess_HelpersU;

interface

Uses LogFileProcess_D7U, SysUtils, MASStringListU, Classes;

  // Dump the Log File Exception List, if erros then raise an exception
  Procedure h_LogWrite_DumpExceptions (Const aFileName, aName: String; Const aLogWriter: tTextLogFileWriter);
  Procedure h_LogWrite_OnException    (Const aFileName, aName, aMsg: String; Const aExcp: Exception);

implementation

Uses FormatResultU, MAS_FormatU, MASDatesU, MAS_ConstsU, TextFileIO_HelpersU;

// Routine: h_LogWrite_DumpExceptions
// Author: M.A.Sargent  Date: 04/09/18  Version: V1.0
//
// Notes:
//
Procedure h_LogWrite_DumpExceptions (Const aFileName, aName: String; Const aLogWriter: tTextLogFileWriter);
var
  lvList: tStrings;
begin
  lvList := tMASStringList.Create;
  Try
    fnRaiseOnFalse (Assigned (aLogWriter), 'Error: h_LogWrite_DumpExceptions. aLogWrite Must be Assigned');
    aLogWriter.fnExceptions (lvList);
    lvList.Insert (0, fnTS_Format ('Error: (h_LogWrite_DumpExceptions) %s. (%d) Message(s) Written to DumpFile: %s', [aName, lvList.Count, fnTS_DateTimeToStr (Now)]));
    h_fnWriteToTextFile (aFileName, (lvList));
  Finally
    lvList.Free;
  end;
end;

// Routine: h_LogWrite_OnException
// Author: M.A.Sargent  Date: 04/09/18  Version: V1.0
//
// Notes:
//
Procedure h_LogWrite_OnException (Const aFileName, aName, aMsg: String; Const aExcp: Exception);
var
  lvMsg: String;
begin
  //
  lvMsg := (aExcp.Message + cMC_2CR + aMsg);
  h_fnWriteToTextFile (aFileName, 'Exception: (h_LogWrite_OnException). %s. Message Written to DumpFile: %s', [aName, fnTS_DateTimeToStr (Now)]);
  h_fnWriteToTextFile (aFileName, 'Exception: (h_LogWrite_OnException). %s. Int_OnMessage. %s', [lvMsg]);
end;

end.
