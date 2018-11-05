//
// Unit: TSBaseFrameU
// Author: M.A.Sargent  Date: 01/10/2018  Version: V1.0
//
unit TSBaseFrameU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BaseFrameU;

type
  TTSBaseFrame = class(TBaseFrame)
  private
    { Private declarations }
    fChanged:              Boolean;
    //
    Procedure SetChanged (Const Value: Boolean);
  Protected
    //
    Procedure DoChanged (Const Value: Boolean); virtual;
    Procedure IsChanged;
    //
    Property  fnChanged: Boolean read fChanged write SetChanged;
  public
    { Public declarations }
    Constructor Create (aOwner: tComponent); override;    
  end;

var
  TSBaseFrame: TTSBaseFrame;

implementation

{$R *.dfm}

{ TTSBaseFrame }

Constructor TTSBaseFrame.Create(aOwner: tComponent);
begin
  inherited;
  fChanged := False;
end;

Procedure TTSBaseFrame.IsChanged;
begin
  fnChanged := True;
end;

Procedure TTSBaseFrame.SetChanged (Const Value: Boolean);
begin
  if DoneSetUp then begin
    fChanged := Value;
    DoChanged (fChanged);
  end;
end;

// Routine: DoChanged
// Author: M.A.Sargent  Date: 16/07/11  Version: V1.0
//
// Notes:
//
Procedure TTSBaseFrame.DoChanged  (Const Value: Boolean);
begin
end;


end.
