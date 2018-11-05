//
// Unit: BaseM=MASEdit
// Author: M.A.Sargent  Date: 30/05/2003  Version: V1.0
//         M.A.Sargent        09/06/2003           V1.1
//         M.A.Sargent        09/06/2003           V1.2
//         M.A.Sargent        29/08/2003           V1.3
//         M.A.Sargent        13/06/2006           V1.4
//         M.A.Sargent        13/06/2006           V3.0
//         M.A.Sargent        25/01/2007           V4.0
//         M.A.Sargent        01/12/2008           V5.0
//         M.A.Sargent        15/05/2015           V6.0
//
// Notes:
//  V1.1: Add notification event to remove assignment of fButton
//  V1.2: Publish the OnChange property
//  V1.3: Publish the Text property
//  V1.4: Publish the OnKeyPress event
//  V3.0: Updated to add in timed event after n MilliSeconds so that incremental
//        searching can be performed
//  V4.0: Added OnDblClick
//  V5.0: Updated to add the PasswordChar to the Public section
//  V6.0: Updated KeyPress
//
unit BaseMASEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TBaseMASEdit = class(TCustomEdit)
  private
    { Private declarations }
    fIntervalEvent: tNotifyEvent;
    fButton: tButton;
    fTimer: tTimer;
    fEnableIntervalEvent: Boolean;
    procedure SetIntervalEvent(const Value: tNotifyEvent);
    procedure TimerEvent (Sender: TObject);
  protected
    { Protected declarations }
    procedure Loaded ; override;
    procedure KeyPress(var Key: Char); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    { Public declarations }
    Constructor Create (aOwner: tComponent); override;
    Destructor Destroy; override;
    //
    Property EnableIntervalEvent: Boolean read fEnableIntervalEvent write fEnableIntervalEvent default True;
    Property PasswordChar;
    Property MaxLength;
    {$IFDEF VER150}
    {$ELSE}
    Property NumbersOnly;
    {$ENDIF}
  published
    { Published declarations }
    Property MagReturnButton: tButton read fButton write fButton;
    Property MagIntervalEvent: tNotifyEvent read fIntervalEvent write SetIntervalEvent;
    //
    Property ReadOnly;
    Property Enabled;
    Property Color;
    Property CharCase;
    property TabOrder;
    Property Font;
    Property Text;
    Property OnChange;
    Property OnExit;
    Property OnKeyPress;
    Property OnDblClick;
  end;

  tIncrementalEdit = Class (tBaseMASEdit)
  end;

implementation

Const
  cDELAYTIME = 333;

{ TBaseIPDEdit }

constructor TBaseMASEdit.Create(aOwner: tComponent);
begin
  inherited;
  fIntervalEvent := Nil;
  fEnableIntervalEvent := True;
end;

destructor TBaseMASEdit.Destroy;
begin
  if Assigned (fTimer) then fTimer.Free;
  inherited;
end;

// Notes: Updated to set focus to the control to be clicked, this causes the
//        OnExit event to be fired
// Notes: MAS 19/01/07 Updated
// Notes: MAS 15/05/15 Updated to add acheck for Button Enabled
procedure TBaseMASEdit.KeyPress (var Key: Char);
begin
  inherited;
  if (Key = #13) and Assigned (fButton) and fButton.Enabled then begin
    fButton.SetFocus;
    fButton.Click;
  end
  else if Assigned (fTimer) and fEnableIntervalEvent then begin
    fTimer.Enabled := False;   // on Key press Disable it Timer Enabled
    fTimer.Enabled := True;    // and then Enable again
  end;
end;

procedure TBaseMASEdit.Loaded;
begin
  inherited;
end;

// Notes: Added to remove the internal assignment of fButton if removed
//        from the IDE
procedure TBaseMASEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (aComponent = fButton) and (Operation = opRemove) then
  begin
    fButton := nil;
  end;
end;

procedure TBaseMASEdit.SetIntervalEvent(const Value: tNotifyEvent);
begin
  fIntervalEvent := Value;
  if not (csDesigning in ComponentState) then
    if Assigned (fIntervalEvent) then begin
      fTimer := tTimer.Create (Nil);
      fTimer.Interval := cDELAYTIME;
      fTimer.Enabled  := False;
      fTimer.OnTimer  := TimerEvent;
    end;
end;

procedure TBaseMASEdit.TimerEvent (Sender: TObject);
begin
  if not Assigned (fTimer) then Exit;
  //
  fTimer.Enabled := False;
  if Assigned (fIntervalEvent) then fIntervalEvent (Self);
end;

end.

