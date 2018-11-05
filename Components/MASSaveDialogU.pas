//
// Unit: MASSaveDialogU
// Author: M.A.Sargent  Date: 01/04/05  Version: V1.0
//         M.A.Sargent        03/03/12           V2.0
//
// Notes:
//  V2.0: Remove the register procedure call
//  V3.0: Pass the systen ID to the RegSetupForms procedure
//  V4.0: Updated Execute
//
unit MASSaveDialogU;

interface

uses
  SysUtils, Classes, Dialogs, Forms, MASCommonU, MASRegistry, MASStringListU,
   Types, Controls, windows, ExtCtrls, Buttons, StdCtrls, ExtDlgs, Messages,
    Consts, Graphics;

type
  tMASSaveDialog = Class (TSaveDialog)
  private
    { Private declarations }
    fRegistry: tMASRegistry;
    //
    Function GetCurrentFilterExtn: String;
  protected
    { Protected declarations }
  public
    { Public declarations }
    Constructor Create (aOwner: tComponent); override;
    Destructor Destroy; override;
    //
    function Execute: Boolean; overload; override; 
    function Execute (Const aRegId: String): Boolean; reintroduce; overload;
    Function Execute (Const aRegId: String; Lines: tStrings): Boolean; reintroduce; overload;
    Function fnGetInitDir: String;
    //
    Property CurrentFilterExtn: String read GetCurrentFilterExtn;
  published
    { Published declarations }
  end;

implementation

Uses MAS_DirectoryU;

{ tBaseMagnetSaveDialog }

// Routine: Execute
// Author: M.A.Sargent  Date: 03/08/06  Version: V1.0
//
// Notes:
//
constructor tMASSaveDialog.Create (aOwner: tComponent);
begin
  inherited;
  fRegistry := tMASRegistry.Create;
end;

destructor tMASSaveDialog.Destroy;
begin
  fRegistry.Free;
  inherited;
end;

// Routine: Execute
// Author: M.A.Sargent  Date: 05/12/11  Version: V1.0
//         M.A.Sargent        03/03/12           V2.0
//
// Notes:
//  V2.0: Change the If then Else statement around the InitialDir assignment
//
function tMASSaveDialog.Execute (Const aRegId: String): Boolean;
begin
  Result := Execute (aRegId, Nil);
end;
function tMASSaveDialog.Execute (Const aRegId: String; Lines: tStrings): Boolean;
var
  lvInitDir:  String;
  lvFileExtn: String;
begin
  if (Self.Owner is tForm) then
       fRegistry.CreateApplicationKey (h_KeyFormName( tForm (Self.Owner).Name))
  else if (Self.Owner is tFrame) then
       fRegistry.CreateApplicationKey (h_KeyFormName( tFrame (Self.Owner).Name))
  else fRegistry.CreateApplicationKey ('SaveDialog');

  if (aRegId = '') then Raise Exception.Create ('Error tSaveDialog: A Registry Identifier Must be Passed');
  // If A AppKey assign then pass and append to the Temp Directory
  lvInitDir := fRegistry.RegGetString ('Config', aRegId, '');
  if (lvInitDir = '') then begin
    if (InitialDir = '') then
      InitialDir := GetTemporaryPath (fRegistry.AppKey)
  end else InitialDir := lvInitDir;

  Result := Inherited Execute;
  if Result then begin
    //
    if (ExtractFileExt (FileName) = '') then begin
      lvFileExtn := ExtractFileExt (GetCurrentFilterExtn);
      FileName   := ChangeFileExt (FileName, lvFileExtn);
    end;
    //
    if Assigned (Lines) then Lines.SaveToFile (FileName);
    fRegistry.RegSetString ('Config', aRegId,  fnGetInitDir);
  end;
end;

function tMASSaveDialog.fnGetInitDir: String;
begin
  Result := ExtractFileDir (FileName);
end;

// Routine: GetCurrentFilterExtn
// Author: M.A.Sargent  Date: 08/12/11  Version: V1.0
//
// Notes:
//
function tMASSaveDialog.GetCurrentFilterExtn: String;
var
  lvList: tMASStringList;
begin
  lvList := tMASStringList.Create;
  Try
    lvList.Delimiter        := '|';
    lvList.StrictDelimiter  := True;
    lvList.NewDelimitedText := Self.Filter;
    Result := lvList.Strings [((Self.FilterIndex*2)-1)];
  Finally
    lvList.Free;
  end;
end;

Function tMASSaveDialog.Execute: Boolean;
begin
  if NewStyleControls and not (ofOldStyleDialog in Options) then
    Template := 'DLGTEMPLATE' else
    Template := nil; 
  Result := inherited Execute;
end;

end.

