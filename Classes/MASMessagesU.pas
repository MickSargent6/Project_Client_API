//
// Unit: MagnetMessagesU
// Author: M.A.Sargent  Date: 16/04/04  Version: V1.0
//         M.A.Sargent        03/08/05           V2.0
//         M.A.Sargent        03/06/08           V3.0
//         M.A.Sargent        09/11/10           V4.0
//         M.A.Sargent        17/12/11           V5.0
//         M.A.Sargent        31/08/12           V6.0
//         M.A.Sargent        03/09/12           V7.0
//         M.A.Sargent        12/10/12           V8.0
//         M.A.Sargent        23/04/18           V9.0
//         M.A.Sargent        17/07/18           V10.0
//
// Notes:
//  V3.0: Add a function to Send a WM_COPYDATA message to a Component Handle
//  V4.0: Add a New Message um_TreeViewAfterChange
//  V5.0: Updated to add Send_HintMessage
//  V6.0: Add another version of WM_COPYDATA
//  V7.0: Updated to add message return values
//  V8.0: Added AppSendMessage2
//  V8.0: Updated AppSendMessage2
//
// NOTE: Add the following method to porocess WM_COPYDATA messages
//        Procedure Form_WMCopyData (var msg: TWMCopyData); message WM_COPYDATA;
//
unit MASMessagesU;

interface

Uses Messages, SysUtils, Windows, Controls, Forms, Classes, MASRecordStructuresU;

  Function Send_WM_COPYDATA (aHandle: tHandle; Const aFormat: string; const Args: array of const): Integer; overload;
  Function Send_WM_COPYDATA (aHandle: tHandle; Const aMsg: String): Integer; overload;
  Function Send_WM_COPYDATA (aHandle: tHandle; Const aParam: Integer; Const aFormat: string; Const Args: array of const): Integer; overload;
  Function Send_WM_COPYDATA (aHandle: tHandle; Const aParam: Integer; Const aMsg: String): Integer; overload;
  Function Send_WM_COPYDATA (aHandle: tHandle; Const WParam, aParam: Integer; Const aMsg: String): Integer; overload;
  //
  Function Extract_WM_CopyData (var msg: TWMCopyData): tIntStrRec;
  //
  Function fnGetActiveFormHandle: tHandle;
  Function fnGetActiveControlHandle: tHandle;
  //
  Procedure AppPostMessage (Const Msg: Cardinal); overload;
  Procedure AppPostMessage (Const Msg: Cardinal; WParam: Longint); overload;
  Procedure AppPostMessage (Const Msg: Cardinal; WParam, LParam: Longint); overload;
  Procedure AppPostMessage (aHandle: tHandle; Const Msg: Cardinal; WParam, LParam: Longint); overload;
  //
  Function AppSendMessage  (aHandle: tHandle; Const Msg: Cardinal; WParam, LParam: Longint): LongInt; overload;
  Function AppSendMessage  (Const Msg: Cardinal; WParam, LParam: Longint): LongInt; overload;
  Function AppSendMessage2 (aHandle: tHandle; Const Msg: Cardinal; WParam, LParam: Longint): Longint;
  //

  Function fnMainFormHandle: tHandle;

implementation

// Routine: Send_WM_COPYDATA
// Author: M.A.Sargent  Date: 03/06/08  Version: V1.0
//
// Notes:
//
Function Send_WM_COPYDATA (aHandle: tHandle; Const aFormat: string; const Args: array of const): Integer;
begin
  Result := Send_WM_COPYDATA (aHandle, Format (aFormat, Args));
end;
Function Send_WM_COPYDATA (aHandle: tHandle; Const aMsg: String): Integer;
begin
  Result := Send_WM_COPYDATA (aHandle, 0, aMsg);
end;
Function Send_WM_COPYDATA (aHandle: tHandle; Const aParam: Integer; Const aFormat: string; Const Args: array of const): Integer;
begin
  Result := Send_WM_COPYDATA (aHandle, aParam, Format (aFormat, Args));
end;
Function Send_WM_COPYDATA (aHandle: tHandle; Const aParam: Integer; Const aMsg: String): Integer;
begin
  Result := Send_WM_COPYDATA (aHandle, 0, aParam, aMsg);
end;
Function Send_WM_COPYDATA (aHandle: tHandle; Const WParam, aParam: Integer; Const aMsg: String): Integer;
var
  lvCopydata: TCopyDataStruct;
begin
  Result := 0;
  if (aHandle <> 0) then begin
    lvCopydata.dwData := aParam;
    lvCopydata.cbData := Length (aMsg) * SizeOf(Char);
    lvCopydata.lpData := PChar  (aMsg);

    Result := SendMessage (aHandle, WM_COPYDATA, WParam, LPARAM( @lvCopydata));
    If (Result<>0) then
      Raise Exception.CreateFmt ('Error: Send_WM_COPYDATA Error Code (%d)', [Result]);
  end;
end;

// Routine: Extract_WM_CopyData
// Author: M.A.Sargent  Date: 03/06/08  Version: V1.0
//
// Notes:
//

Function Extract_WM_CopyData (var msg: TWMCopyData): tIntStrRec;
begin
  Result.Int := Msg.CopyDataStruct^.dwData;
  SetString (Result.Msg, PChar(Msg.CopyDataStruct.lpData),  Msg.CopyDataStruct.cbData div SizeOf(Char));
end;

// Routine: Send_WM_COPYDATA
// Author: M.A.Sargent  Date: 03/06/08  Version: V1.0
//
// Notes:
//
Function fnGetActiveFormHandle: tHandle;
var
  lvForm: tForm;
begin
  Result := 0;
  if Assigned (Screen) then begin
    lvForm := Screen.ActiveForm;
    if Assigned (lvForm) then Result := lvForm.Handle;
  end;
end;

// Routine: Send_WM_COPYDATA
// Author: M.A.Sargent  Date: 03/06/08  Version: V1.0
//
// Notes:
//
Function fnGetActiveControlHandle: tHandle;
var
  lvControl: tControl;
begin
  Result := 0;
  if Assigned (Screen) then begin
    lvControl := Screen.ActiveControl;
    if Assigned (lvControl) and (lvControl is tWinControl) then
      Result := tWinControl (lvControl).Handle;
  end;
end;

// Routine: AppPostMessage
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//
// Notes:
//
Procedure AppPostMessage (Const Msg: Cardinal);
begin
  AppPostMessage (Msg, 0, 0);
end;
Procedure AppPostMessage (Const Msg: Cardinal; WParam: Longint);
begin
  AppPostMessage (Msg, WParam, 0);
end;
Procedure AppPostMessage (Const Msg: Cardinal; WParam, LParam: Longint);
begin
  AppPostMessage (fnMainFormHandle, Msg, WParam, LParam);
end;
Procedure AppPostMessage (aHandle: tHandle; Const Msg: Cardinal; WParam, LParam: Longint);
begin
  PostMessage (aHandle, Msg, WParam, LParam);
end;

// Routine: AppSendMessage
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//
// Notes:
//  V2.0: AppSendMessage2, remove second SendMessage
//
Function AppSendMessage (Const Msg: Cardinal; WParam, LParam: Longint): Longint;
begin
  Result := AppSendMessage (fnMainFormHandle, Msg, WParam, LParam);
end;
Function AppSendMessage (aHandle: tHandle; Const Msg: Cardinal; WParam, LParam: Longint): Longint;
begin
  Result := SendMessage (aHandle, Msg, WParam, LParam);
end;
Function AppSendMessage2 (aHandle: tHandle; Const Msg: Cardinal; WParam, LParam: Longint): Longint;
begin
  Result := -1;
  if (aHandle <> 0) then
    Result := SendMessage (aHandle, Msg, WParam, LParam);
end;

Function fnMainFormHandle: tHandle;
begin
  Result := 0;
  if Assigned (Application) and Assigned (Application.MainForm) then begin
    Result := Application.MainForm.Handle;
  end;
end;

end.


