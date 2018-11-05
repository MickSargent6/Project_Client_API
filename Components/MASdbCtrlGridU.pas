//
// Unit: MASdbCtrlGridU
// Author: M.A.Sargent  Date: 29/10/2018  Version: V1.0
//
unit MASdbCtrlGridU;

interface

uses
  SysUtils, Classes, Controls, dbcgrids, Windows, Messages;

type
  tMASdbCtrlGrid = class(TDBCtrlGrid)
  private
    { Private declarations }
    fShowScrollBars: Boolean;
    //
    Procedure SetShowScrollBars (Const Value: Boolean);
    Procedure Int_ScrollBars;
    //
    Procedure WMNCCalcSize  (Var msg: TMessage); message WM_NCCALCSIZE;
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
    Property ShowScrollBars: Boolean read fShowScrollBars write SetShowScrollBars;
  end;

implementation

{ tMASdbCtrlGrid }

Procedure tMASdbCtrlGrid.Int_ScrollBars;
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

Procedure tMASdbCtrlGrid.SetShowScrollBars (Const Value: Boolean);
begin
  fShowScrollBars := Value;
end;

Procedure tMASdbCtrlGrid.WMNCCalcSize(var msg: TMessage);
begin
  Int_ScrollBars;
  inherited;
end;

end.
