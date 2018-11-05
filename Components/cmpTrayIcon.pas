unit cmpTrayIcon;

//   Tray icon component.  Copyright (c) Colin Wilson 1997
//
// NB.  To prevent your main form displaying at startup, select
//      View / Project source from the menu and insert the lines
//
//   ShowWindow(Application.Handle, SW_HIDE);
//   Application.ShowMainForm := FALSE;
//
//      before the Application.Run line.


{$S-,W-,R-}
{$C PRELOAD}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ShellAPI, Menus;

type
  TTrayIcon = class(TComponent)
  private
    fWindowHandle : HWND;
    fIcon : TIcon;
    fEnabled : boolean;
    fIconThere : boolean;
    fHint : string;
    fPopupMenu : TPopupMenu;
    fAutoShow : boolean;

    fOnLeftBtnClick : TNotifyEvent;
    fOnLeftBtnDblClick : TNotifyEvent;
    fOnRightBtnClick : TNotifyEvent;
    fOnMouseMove : TNotifyEvent;

    procedure WProc(var Msg: TMessage);
    procedure UpdateIcon (Flags : integer);

    procedure SetIcon (value : TIcon);
    procedure SetEnabled (value : boolean);
    procedure SetHint (value : string);
  protected
    { Protected declarations }
  public
    constructor Create (AOwner : TComponent); override;
    destructor Destroy; override;
  published
    property Icon : TIcon read fIcon write SetIcon;
    property Enabled : boolean read fEnabled write SetEnabled;
    property Hint : string read fHint write SetHint;
    property PopupMenu : TPopupMenu read fPopupMenu write fPopupMenu;
    property AutoShow : boolean read fAutoShow write fAutoShow;

    property OnLeftBtnClick : TNotifyEvent read fOnLeftBtnClick write fOnLeftBtnClick;
    property OnLeftBtnDblClick : TNotifyEvent read fOnLeftBtnDblClick write fOnLeftBtnDblClick;
    property OnRightBtnClick : TNotifyEvent read fOnRightBtnClick write fOnRightBtnClick;
    property OnMouseMove : TNotifyEvent read fOnMouseMove write fOnMouseMove;

  end;

implementation

const WM_ICONMESSAGE = WM_USER + $200;

constructor TTrayIcon.Create (AOwner : TComponent);
begin
  inherited Create (AOwner);
  fWindowHandle := AllocateHWND (WProc);
  fIcon := TIcon.Create;
  fIcon.Assign (Application.Icon);
  fAutoShow := True;
end;

destructor TTrayIcon.Destroy;
begin
  if fIconThere then
  begin
    fIcon := Nil;
    UpdateIcon (0);
  end;

  fIcon.Free;
  DeallocateHWND (fWindowHandle);
  inherited
end;

procedure TTrayIcon.WProc(var Msg: TMessage);
var
  pt : TPoint;
begin
  with msg do
    if msg = WM_ICONMESSAGE then
      case lParam of
        WM_RBUTTONDOWN :
          begin
            if Assigned (fOnRightBtnClick) then
            	OnRightBtnClick (self);

            if Assigned (fPopupMenu) then
            begin
              GetCursorPos (pt);
              if AutoShow then fPopupMenu.Items [0].default := True;
              SetForegroundWindow (fWindowHandle);
              fPopupMenu.Popup (pt.x, pt.y);
            end
          end;

        WM_LBUTTONDOWN :
          if Assigned (fOnLeftBtnClick) then
            OnLeftBtnClick (self);

        WM_LBUTTONDBLCLK :
        begin
          if Assigned (fOnLeftBtnDblClick) then
            OnLeftBtnDblClick (self);

          if Assigned (fPopupMenu) and AutoShow then with fPopupMenu do
            if Assigned (items [0]) then
              items [0].click
        end;

        WM_MOUSEMOVE :
          if Assigned (fOnMouseMove) then
            OnMouseMove (self);
      end
    else
      Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam)
end;

procedure TTrayIcon.UpdateIcon (flags : Integer);
var
  iconData : TNotifyIconData;
begin
  if not (csDesigning in ComponentState) then
  begin
    iconData.cbSize := SizeOf (iconData);
    iconData.Wnd := fWindowHandle;
    iconData.uID := Tag;
    iconData.uFlags :=NIF_ICON or NIF_TIP or NIF_MESSAGE;
    iconData.uCallbackMessage := WM_ICONMESSAGE;
    if fHint = '' then
      iconData.szTip [0] := #0
    else
      StrPCopy (iconData.szTip, fHint);

    if Assigned (fIcon) and fEnabled then
    begin
      iconData.hIcon := fIcon.Handle;
      if fIconThere then
      begin
    	iconData.uFlags := flags;
	    Shell_NotifyIcon (NIM_MODIFY, @iconData)
      end
      else
      begin
	    Shell_NotifyIcon (NIM_ADD, @iconData);
        fIconThere := True
      end
    end
    else
    begin
      Shell_NotifyIcon (NIM_DELETE, @iconData);
      fIconThere := False
    end
  end
end;

procedure TTrayIcon.SetIcon (value : TIcon);
begin
  if fIcon <> value then
  begin
    fIcon.Assign (value);
    UpdateIcon (NIF_ICON);
  end
end;

procedure TTrayIcon.SetHint (value : String);
begin
  if fHint <> value then
  begin
    fHint := value;
    UpdateIcon (NIF_TIP);
  end
end;

procedure TTrayIcon.SetEnabled (value : boolean);
begin
  if value <> fEnabled then
  begin
    fEnabled := value;
    UpdateIcon (NIF_ICON or NIF_TIP or NIF_MESSAGE);
  end
end;

end.
