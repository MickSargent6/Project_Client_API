//
// Unit: WindowsAPIU
// Author: M.A.Sargent  Date: 07/08/17  Version: V1.0
//
// Notes:
//
unit WindowsAPIU;

interface

Uses Windows;

  Function fnComputerName: String;

implementation

// Notes: Add a Function to get the Computer Name
Function fnComputerName: String;
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

end.
