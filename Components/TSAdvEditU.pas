//
// Unit: TSAdvEdit
// Author: M.A.Sargent  Date: 29/10/2018  Version: V1.0
//         M.A.Sargent        05/12/2018           V2.0
//
// Notes: Currently a simple update, OnExit of the control if the content has changed an event will be fired
//        on OnChange where you get a event every time a character is typed
//  V2.0: Updated to Pass the Original Value with the OnExitIfContentChanged
//
unit TSAdvEditU;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, AdvEdit;

type
  tTSAdvEdit = Class;
  tOnExitIfContentChanged = Procedure (aSender: tTSAdvEdit; Const aOrigValue: String) of object;

  tTSAdvEdit = class(TAdvEdit)
  private
    fValueOnEnter:           String;
    fOnExitIfContentChanged: tOnExitIfContentChanged;
  protected
    { Protected declarations }
    Procedure DoEnter; override;
    Procedure DoExit; override;
  public
    { Public declarations }
    Constructor Create (aOwner: tComponent); override;
  published
    { Published declarations }
    Property OnExitIfContentChanged: tOnExitIfContentChanged read fOnExitIfContentChanged write fOnExitIfContentChanged;
  end;

implementation

{ tTSAdvEdit }

Constructor tTSAdvEdit.Create(aOwner: tComponent);
begin
  inherited;
  fOnExitIfContentChanged := Nil;
  fValueOnEnter           := '';
end;

Procedure tTSAdvEdit.DoEnter;
begin
  inherited;
  fValueOnEnter := Self.Text;
end;

Procedure tTSAdvEdit.DoExit;
begin
  inherited;
  if (fValueOnEnter <> Self.Text) then Self.OnExitIfContentChanged (Self, fValueOnEnter);
end;

end.
