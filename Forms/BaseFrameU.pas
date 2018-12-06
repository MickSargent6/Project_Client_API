//
// Unit: BaseFrameU
// Author: M.A.Sargent  Date: 03/02/2004  Version: V1.0
//         M.A.Sargent        04/06/2008           V2.0
//         M.A.Sargent        04/06/2008           V3.0
//         M.A.Sargent        02/06/2009           V4.0
//         M.A.Sargent        15/04/2009           V5.0
//         M.A.Sargent        18/01/2011           V6.0
//         M.A.Sargent        08/03/2011           V7.0
//         M.A.Sargent        08/02/2012           V8.0
//         M.A.Sargent        31/07/2012           V9.0
//         M.A.Sargent        29/08/2012           V10.0
//         M.A.Sargent        03/09/2012           V11.0
//         M.A.Sargent        03/09/2012           V12.0
//
// Notes: Removed the constructor that had the prarent as a parameter, this has
//        now to be set in code, see MAS for more details
//        Add IntShowFrame to BaseFrame
//  V2.0: Add code to SendMessage to the TreeView that was used to call the Frame
//  V3.0: Add JustSendMessageToTreeView to Just Send Message to TreeView
//  V4.0: Add Public Methods DoneInitShow, DoShowEvent and DoHideEvent
//  V6.0: Update to add
//         1. atFormClosing
//         2. DoFormClosing protected virtual method
//         3. Message Handler Msg_ParentFormClosing
//  V7.0: Updated GetRegistry, can not pass null to Create routine
//  V8.0: Updated AfterConstruction to set Align to be alNone AfterConstrution,
//        then it is set by AutoAlign
//  V9.0: Updated DoFrameMessage
// V10.0: Added property fRunOpenOnInitialShow
// V11.0: Updated DoFrameMessage to be a function
// V12.0: Updated ReFresh
//
unit BaseFrameU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   StdCtrls, MASRegistry, ExtCtrls, Db, ComCtrls, MASCommon_UtilsU, TSUK_D7_ConstsU,
    MASMessagesU;

    {MASMessagesU, ApplicationMessagesU,
     MASCommon_UtilsU, MASHelpersU, MASJustMessagesU;}

Type
  tAutoAlign = (aaNone, aaClient, aaTop, aaLeft, aaBottom, aaRight);
  tActionType = (atCreate, atDestroy, atInitShow, atShow, atHide, atClear, atRefresh,
                  atInitilise, atPaint, atOpen, atClose, atFrameClosing);
  tShowNotifyEvent = Procedure (aOwner: tComponent; Const FirstTime: Boolean) of Object;
  tFrameAction = Procedure (aOwner: tComponent; Const aActionType: tActionType) of Object;
  tUpdateAction = (uaOnApply, uaOnCancel, uaAfterApply, uaAfterCancel, uaAfterClear);

  eFrameException = Class (Exception);

type
  TBaseFrame = class(TFrame)
    procedure FrameExit(Sender: TObject);
  private
    { Private declarations }
    fDoneSetUp:            Boolean;
    fIsCancelling:         Boolean;
    fRunOpenOnInitialShow: Boolean;
    fInitializing:         Boolean;
    fDoneOpen:             Boolean;
    fAutoAlign:            tAutoAlign;
    fOnShow:               tShowNotifyEvent;
    fOnFrameAction:        tFrameAction;
    fDoneInitShow:         Boolean;
    fRegistry:             tMASRegistry;
    fUpdateKind:           tUpdateKind;
    fReadOnly:             Boolean;
    fCaption:              String;
    //
    Procedure IntAlign;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure SetAutoAlign(const Value: tAutoAlign);
    procedure SetCaption(const Value: String); virtual;
    function GetRegistry: tMASRegistry;
    procedure SetUpdateKind(const Value: tUpdateKind);
    Procedure IntDoDelete;
    Procedure Msg_ParentFormClosing (var Msg: TMessage); Message um_TellFramesParentFormingClosing;
    Procedure Msg_FrameMsg          (var Msg: tMessage); Message um_FrameMsg;
    Procedure Msg_AfterConstructor  (var Msg: TMessage); Message um_AfterConstructor;
    Procedure SetReadOnly           (Const Value: Boolean);
    Procedure SetDoneSetUp          (Const Value: Boolean);
    //

  Protected
    procedure VisibleChanging; override;
    //
    Procedure DoUpdateAction (Const aUpdateAction: tUpdateAction); virtual;
    //
    Procedure DoInsert; virtual;
    Procedure DoUpdate; virtual;
    Procedure DoDelete (var aOK: Boolean); virtual;
    //
    Function  DoCancel: Boolean; virtual;
    Function  DoApply: Boolean; virtual;
    Procedure DoClear; virtual;

    Procedure virtualDoCancel (var aOKCancel: Boolean); virtual;
    Procedure virtualDoApply (var aOK: Boolean); overload; virtual;

    Procedure DoFormClosing; virtual;

    procedure DoDoneSetup; virtual;
    Procedure DoReadOnly; virtual;
    procedure DoInitialShow; virtual;
    Procedure DoShow; virtual;
    Procedure DoHide; virtual;
    Procedure DoFrameAction (Const aActionType: tActionType); virtual;
    procedure SetParent (aParent: TWinControl); override;
    //
    Procedure CanCloseFrame (var aMsg: String; var aClose: Boolean); virtual;
    //
    Procedure AddMsg (Const aMsg: String); overload;
    Procedure AddMsg (Const aFormat: string; Const Args: array of const); overload;
    //
    Function  DoFrameMessage (Const aAppMsg: tAppMsg; Const lParam: Integer): Integer; virtual;
    Procedure DoAddMsg       (Const aMsg: String); virtual;
    //
    Property Initializing: Boolean      read fInitializing;
    Property DoneSetUp:    Boolean      read fDoneSetUp write SetDoneSetUp;
    Property Registry:     tMASRegistry read GetRegistry;
    Property IsCancelling: Boolean      read fIsCancelling;

  public
    { Public declarations }
    Constructor Create (aOwner: tComponent); overload; override;
    Constructor Create (aOwner: tComponent; Const aAutoAlign: tAutoAlign); reintroduce; overload; virtual;

    Destructor Destroy; override;
    Procedure AfterConstruction; override;
    //
    Function CloseFrameQuery: Boolean;

    Procedure Initialise; virtual;
    Procedure FormClose; virtual;
    Procedure Close; virtual;
    Procedure Clear; virtual;
    Procedure Open; virtual;
    Procedure ReFresh; virtual;
    // Public Procedures to Trigger Show and Hide events
    Procedure DoShowEvent;
    Procedure DoHideEvent;

    Property AutoAlign: tAutoAlign read fAutoAlign write SetAutoAlign;
    Property UpdateKind: tUpdateKind read fUpdateKind write SetUpdateKind;
    //
    //
    Property RunOpenOnInitialShow: Boolean read fRunOpenOnInitialShow write fRunOpenOnInitialShow Default True;
    Property DoneInitShow:         Boolean read fDoneInitShow;
    //
    Property ReadOnly: Boolean read fReadOnly write SetReadOnly default False;

  Published
    Property Align;
    Property TabOrder;
    Property Caption: String read fCaption write SetCaption;
    Property OnShow: tShowNotifyEvent read fOnShow write fOnShow;
    Property OnFrameAction: tFrameAction read fOnFrameAction write fOnFrameAction;
  end;
  //
  Procedure IntShowFrame  (aFrame: TBaseFrame; aInfoContainer: tCustomControl); overload;
  Procedure IntShowFrame2 (aFrame: TBaseFrame; aInfoContainer: TWinControl); overload;
  Procedure IntShowFrame2 (aFrame: TBaseFrame; aInfoContainer: TWinControl; Const aDoOpen: Boolean); overload;

implementation

Uses MAS_FormatU;

{$R *.DFM}

Procedure IntShowFrame (aFrame: TBaseFrame; aInfoContainer: tCustomControl);
begin
  if (aFrame.Parent <> aInfoContainer) then
    aFrame.Parent := aInfoContainer;
  IntShowFrame2 (aFrame, Nil);
end;

Procedure IntShowFrame2 (aFrame: TBaseFrame; aInfoContainer: TWinControl);
begin
  IntShowFrame2 (aFrame, aInfoContainer, True);
end;

Procedure IntShowFrame2 (aFrame: TBaseFrame; aInfoContainer: TWinControl; Const aDoOpen: Boolean);
var
  lvDoOpen: Boolean;
begin
  lvDoOpen := True;
  if (aInfoContainer <> Nil) then
    if (aFrame.Parent <> aInfoContainer) and (aInfoContainer <> Nil) then begin
      aFrame.Parent := aInfoContainer;
      lvDoOpen := False;
    end;
  //
  if lvDoOpen then begin
    aFrame.BringtoFront;
    if aDoOpen then aFrame.Open;
  end;
end;

{ TFrame2 }

constructor TBaseFrame.Create (aOwner: tComponent);
begin
  inherited Create (aOwner);
  fCaption              := '';
  fAutoAlign            := aaNone;
  DoFrameAction (atCreate);
  fDoneOpen             := False;
  fInitializing         := True;
  fRunOpenOnInitialShow := True;
  fDoneSetUp            := True;
end;

destructor TBaseFrame.Destroy;
begin
  DoFrameAction (atDestroy);
  if Assigned (fRegistry) then fRegistry.Free;
  inherited;
end;

procedure TBaseFrame.Initialise;
begin
  fDoneInitShow := False;
  DoFrameAction (atInitilise);
end;

procedure TBaseFrame.Clear;
begin
  DoFrameAction (atClear);
  DoClear;
  DoUpdateAction (uaAfterClear);
end;

procedure TBaseFrame.DoShow;
begin
  DoInitialShow;
  DoFrameAction (atShow);
end;

procedure TBaseFrame.DoShowEvent;
begin
  DoShow;
end;

// Notes: On the intial show the Open routine is called
//  V2.0: Find the Parent Form and Send a Message to info the Form
//        that a Fram ehas been Added
//
procedure TBaseFrame.DoInitialShow;
var
  lvControl: tControl;
begin
  if Assigned (fOnShow) then fOnShow (Self, Not fDoneInitShow);
  if not fDoneInitShow then begin
    DoFrameAction (atInitShow);
    if fRunOpenOnInitialShow then Open;
  end;
  fDoneInitShow := True;
  //
  lvControl := fnTopLevelParent (Self);
  if (Assigned (lvControl) and (lvControl is tForm)) then
    AppPostMessage (tForm (lvControl).Handle, um_FrameCreatedTellParentForm, Self.Handle, 0);
  //
  DoneSetUp := True;
end;

// Open is used to contain queryies that need to be opened,
// it is called by the Initialshow method
procedure TBaseFrame.Open;
begin
  DoFrameAction (atOpen);
  fDoneOpen := True;
end;

procedure TBaseFrame.DoHide;
begin
  DoFrameAction (atHide);
end;

procedure TBaseFrame.DoHideEvent;
begin
  DoHide;
end;

procedure TBaseFrame.WMPaint (var Message: TWMPaint);
begin
  Inherited;
  DoFrameAction (atPaint);
end;

Procedure TBaseFrame.DoFrameAction (Const aActionType: tActionType);
begin
  if Assigned (fOnFrameAction) then fOnFrameAction (Self, aActionType);
end;


// Notes: Parent tForm is About to Close, enables things (ieSaving) to be
//        preformed before the Destructors start ge4tting called
//
procedure TBaseFrame.DoFormClosing;
begin
  DoFrameAction (atFrameClosing);
end;

procedure TBaseFrame.CMShowingChanged (var Message: TMessage);
begin
  Inherited;
  if not (csDesigning in ComponentState) then begin
    if Showing then
         DoShow
    else DoHide;
  end;
end;

procedure TBaseFrame.SetParent (aParent: TWinControl);
begin
  inherited;
  if (fAutoAlign = aaNone) then Exit;
  IntAlign;
end;

constructor TBaseFrame.Create (aOwner: tComponent; const aAutoAlign: tAutoAlign);
begin
  Create (aOwner);
  AutoAlign := aAutoAlign;
end;

// Notes: MAS Only Update if the Values has changed
procedure TBaseFrame.SetAutoAlign(const Value: tAutoAlign);
begin
  if (fAutoAlign <> Value) then begin
    fAutoAlign := Value;
    IntAlign;
  end;
end;

// Notes: MAS Only Update if the Values has changed
procedure TBaseFrame.IntAlign;
begin
  if not (csDestroying in ComponentState) then begin
    Case fAutoAlign of
      aaClient: if (Align <> alClient) then Align := alClient;
      aaTop:    if (Align <> altop) then Align := alTop;
      aaLeft:   if (Align <> alLeft) then Align := alLeft;
      aaBottom: if (Align <> alBottom) then Align := alBottom;
      aaRight:  if (Align <> alRight) then Align := alRight;
    end;
  end;
end;

Procedure TBaseFrame.SetCaption (Const Value: String);
begin
  fCaption := Value;
end;

procedure TBaseFrame.Close;
begin
  fDoneOpen := False;
  DoFrameAction (atClose);
end;

// MAS 08/03/2011 Can NOt Pass '' to Create Method
function TBaseFrame.GetRegistry: tMASRegistry;
begin
  if Not Assigned (fRegistry) then
    fRegistry := tMASRegistry.Create;
  Result := fRegistry
end;

procedure TBaseFrame.CanCloseFrame (var aMsg: String; var aClose: Boolean);
begin
end;

procedure TBaseFrame.IntDoDelete;
var
  lvOK: Boolean;
begin
  lvOK := True;
  DoDelete (lvOK);
end;

procedure TBaseFrame.DoDelete (var aOK: Boolean);
begin
  if not fDoneOpen then Open;
end;

procedure TBaseFrame.DoInsert;
begin
  if not fDoneOpen then Open;
end;

procedure TBaseFrame.DoUpdate;
begin
end;

procedure TBaseFrame.Msg_ParentFormClosing (var Msg: TMessage);
begin
  DoFormClosing;
end;

procedure TBaseFrame.SetUpdateKind (Const Value: tUpdateKind);
begin
  fUpdateKind := Value;
  Case fUpdateKind of
    ukInsert: DoInsert;
    ukModify: DoUpdate;
    ukDelete: IntDoDelete;
  end;
end;

Function TBaseFrame.DoApply: Boolean;
begin
  Result := True;
  virtualDoApply (Result);
  if Result then begin
    DoUpdateAction (uaOnApply);
    DoUpdateAction (uaAfterApply);
  end;
end;

procedure TBaseFrame.virtualDoApply (Var aOK: Boolean);
begin
  aOK := True;
end;

Function TBaseFrame.DoCancel: Boolean;
begin
  fIsCancelling := True;
  Try
    Result := False;
    virtualDoCancel (Result);
    if Result then begin
      DoUpdateAction (uaOnCancel);
      DoUpdateAction (uaAfterCancel);
    end;
  Finally
    fIsCancelling := False;
  end;
end;

Procedure TBaseFrame.virtualDoCancel (var aOKCancel: Boolean);
begin
  aOKCancel := True;
end;

procedure TBaseFrame.FormClose;
begin
  if CloseFrameQuery then
    Release;
end;

procedure TBaseFrame.VisibleChanging;
begin
  Case Visible of
    True: if not CloseFrameQuery then Abort;
    False:; {Do Nothing}
  end;
  inherited;
end;

Function TBaseFrame.CloseFrameQuery: Boolean;
var
  lvMsg: String;
begin
  Result := True;
  CanCloseFrame (lvMsg, Result);
  if not Result then
    if (lvMsg<>'') then MessageDlg (lvMsg, mtInformation, [mbOK], 0);
end;

procedure TBaseFrame.Msg_FrameMsg (var Msg: tMessage);
begin
  Msg.Result := DoFrameMessage (tAppMsg (Msg.WParam), Msg.lParam);
end;

// Routine:
// Author: M.A.Sargent  Date: 08/08/12  Version: V1.0
//
// Notes: Updated to be a function and return cCLOSEQRY_CHANGESPENDING is changes pending
//
Function TBaseFrame.DoFrameMessage (Const aAppMsg: tAppMsg; Const lParam: Integer): Integer;
begin
  Result := cMSGOK;
  Case aAppMsg of
    amFrameCloseQry:  if not CloseFrameQuery then begin
                        Result := cCLOSEQRY_CHANGESPENDING;
                        //Abort;
    end;
  end;
end;

procedure TBaseFrame.SetReadOnly (Const Value: Boolean);
begin
  fReadOnly := Value;
  DoReadOnly;
end;

procedure TBaseFrame.DoReadOnly;
begin
end;

// Notes:
//  V1.0: Updated to set Align to alNone is AutoAlign is Assigned
//
procedure TBaseFrame.AfterConstruction;
begin
  inherited;
  AppPostMessage (Self.Handle, um_AfterConstructor, 0, 0);
  if (fAutoAlign <> aaNone) then Align := alNone;
end;

procedure TBaseFrame.Msg_AfterConstructor(var Msg: TMessage);
begin
  Initialise;
  fInitializing := False;
end;

procedure TBaseFrame.DoUpdateAction(const aUpdateAction: tUpdateAction);
begin
end;

procedure TBaseFrame.DoClear;
begin
end;

procedure TBaseFrame.ReFresh;
begin
  Open;
end;

Procedure TBaseFrame.SetDoneSetUp (Const Value: Boolean);
var
  lvOK: Boolean;
begin
  lvOK := not fDoneSetUp and Value;
  fDoneSetUp := Value;
  if lvOK then DoDoneSetup;
end;

Procedure TBaseFrame.DoDoneSetup;
begin
end;

Procedure TBaseFrame.FrameExit(Sender: TObject);
begin
  //
  DoHideEvent;
end;

Procedure TBaseFrame.AddMsg (Const aMsg: String);
begin
  DoAddMsg (aMsg);
end;
procedure TBaseFrame.AddMsg (Const aFormat: String; Const Args: array of const);
begin
  AddMsg (fnTS_Format (aFormat, Args));
end;

Procedure TBaseFrame.DoAddMsg (Const aMsg: String);
begin

end;

end.
