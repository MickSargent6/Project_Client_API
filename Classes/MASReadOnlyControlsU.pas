//
// Unit: MASReadOnlyControlsU
// Author: M.A.Sargent  Date: 26/01/12  Version: V1.0
//         M.A.Sargent        19/11/12           V2.0
//         M.A.Sargent        15/11/13           V3.0
//
// Notes:
//  V2.0:
//  V3.0:
//
unit MASReadOnlyControlsU;

interface

Uses Controls, Graphics, Spin;

  Procedure ControlReadOnly (aControl: tControl; Const ReadOnly: Boolean);

implementation

Uses BaseMASEdit, DbCtrls, StdCtrls;

// Routine: ControlReadOnly
// Author: M.A.Sargent  Date: 26/01/12  Version: V1.0
//
// Notes:
//  V1.0: Add tEdit class
//
Procedure ControlReadOnly (aControl: tControl; Const ReadOnly: Boolean);
var
  lvColor: tColor;
begin
  aControl.Enabled := not ReadOnly;
  Case ReadOnly of
    True:  lvColor := clBtnFace;
    False: lvColor := clWindow;
  end;
  if aControl is tDbEdit then      tDbEdit(aControl).Color := lvColor;
  if aControl is TBaseMASEdit then tBaseMASEdit(aControl).Color := lvColor;
  if aControl is tSpinEdit then    tSpinEdit(aControl).Color := lvColor;
  if aControl is tEdit then        tEdit(aControl).Color := lvColor;
  if aControl is tComboBox then    tComboBox (aControl).Color := lvColor;
end;

end.
