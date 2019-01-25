unit MASdbCtrlGridU;

interface

uses
  SysUtils, Classes, Controls, dbcgrids, Windows, Messages;

type
  TMASdbCtrlGrid = class(TDBCtrlGrid)
  private
    fShowScrollBars: Boolean;
    procedure SetShowScrollBars (Const Value: Boolean);
    procedure Int_ScrollBars;
    procedure WMNCCalcSize  (Var msg: TMessage); message WM_NCCALCSIZE;
  published
    property ShowScrollBars: Boolean read fShowScrollBars write SetShowScrollBars;
  end;

implementation

{ TMASdbCtrlGrid }

Procedure TMASdbCtrlGrid.Int_ScrollBars;
const
  scrollstyles = WS_VSCROLL or WS_HSCROLL;
var
  style: Integer;
begin
  style := getWindowLong( handle, GWL_STYLE );
  Self.ShowScrollBars := (Self.DataSource.DataSet.RecordCount > Self.PanelCount);
  Case fShowScrollBars of
    True:;
    else  If (style and scrollstyles) <> 0 Then SetWindowLong( handle, GWL_STYLE, style and not scrollstyles );
  end;
end;

Procedure TMASdbCtrlGrid.SetShowScrollBars (Const Value: Boolean);
begin
  fShowScrollBars := Value;
end;

Procedure TMASdbCtrlGrid.WMNCCalcSize(var msg: TMessage);
begin
  Int_ScrollBars;
  inherited;
end;

end.
