//
// Unit: MASOpenDialogU
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//
// Notes:
//
unit MASOpenDialogU;

interface

Uses Dialogs, Classes, MASRegistry, SysUtils, Forms, MAS_DirectoryU;

type
  tMASOpenDialog = class(TOpenDialog)
  private
    fRegId: String;
    fRegistry: tMASRegistry;
    procedure SetInitDir(const Value: String);
    function GetInitDir: String;
    procedure IntSetRegistry;
  Protected
    Property InitDir: String  read GetInitDir write SetInitDir;
  public
    Constructor Create (aOwner: tComponent); override;
    Destructor Destroy; override;
    Function Execute (Const aRegId: String; FileType: String = '*'): Boolean; reintroduce; overload;
    Function fnGetInitDir: String;
  end;

implementation

{ tMASOpenDialog }

constructor tMASOpenDialog.Create (aOwner: tcomponent);
begin
  inherited;
  fRegistry := tMASRegistry.Create;
end;

destructor tMASOpenDialog.Destroy;
begin
  fRegistry.Free;
  inherited;
end;

// Routine: Execute
// Author: M.A.Sargent  Date: 13/01/09  Version: V1.0
//
// Notes: Updated to set the DefaultExt property
//
function tMASOpenDialog.Execute (Const aRegId: String; FileType: String = '*'): Boolean;
begin
  fRegId := aRegId;
  IntSetRegistry;
  InitialDir := InitDir;
  DefaultExt := FileType;
  Result := Inherited Execute;
  if Result then InitDir := ExtractFileDir (FileName);;
end;

Procedure tMASOpenDialog.IntSetRegistry;
begin
  if (Self.Owner is tForm) then
       fRegistry.CreateApplicationKey (h_KeyFormName( tForm (Self.Owner).Name))
  else if (Self.Owner is tFrame) then
       fRegistry.CreateApplicationKey (h_KeyFormName( tFrame (Self.Owner).Name))
  else fRegistry.CreateApplicationKey ('OpenDialog');
end;

function tMASOpenDialog.GetInitDir: String;
begin
  Result := fRegistry.RegGetString ('', fRegId, GetTemporaryPath (fRegistry.AppKey));
end;

procedure tMASOpenDialog.SetInitDir(const Value: String);
begin
  fRegistry.RegSetString ('', fRegId,  Value);
end;

function tMASOpenDialog.fnGetInitDir: String;
begin
  IntSetRegistry;
  Result := InitDir;
end;

end.
