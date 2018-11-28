//
// Unit: formSimpleEntryFormU
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//         M.A.Sargent        26/01/12           V2.0
//         M.A.Sargent        08/08/16           V3.0
//
// Notes:
//  V1.0: Add DoValidate method
//  V2.0: Updated FormCloseQuery
//
unit TSBaseSimpleEntryFormU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TSBaseFormModalU, StdCtrls, ExtCtrls, MASCommonU, AdvGlowButton,
  AdvPanel, jpeg, RzBckgnd, Db, MAS_ConstsU;

type
  TFormTSBaseSimpleEntryForm = class(TformTSBaseFormModal)
    AdvPanel1: TAdvPanel;
    BtnOK: TAdvGlowButton;
    CancelBtn: TAdvGlowButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnOKClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
    fIsClearing: Boolean;
    fChanged:    Boolean;
    fUpdateKind: tUpdateKind;
    procedure SetChanged(const Value: Boolean);
    Procedure IntDoOK;
    Procedure IntDoCancel;
  Protected
    //Function  fnHasChanged: Boolean;
    Procedure InitialShow; override;
    Function  fnDoCloseQuery: Boolean; virtual;
    //
    Procedure DoValidate (var aOK: Boolean; var aMsg: String); virtual;
    Procedure DoOK       (var aOK: Boolean); virtual;
    Procedure DoChanged  (Const Value: Boolean); virtual;
    Procedure DoCancel   (var aCancel: Boolean); virtual;
    Procedure DoClear; virtual;
    //
    Procedure IsChanged; virtual;
    Function fnIsInsert: Boolean;

    //
    Property  fnChanged:  Boolean read fChanged write SetChanged;
    Property  IsClearing: Boolean read fIsClearing;
    //
    Property UpdateKind: tUpdateKind read fUpdateKind write fUpdateKind default ukInsert;
  public
    { Public declarations }
    Constructor CreateTitle (aOwner: tComponent; Const aTitle: String); virtual;
    Procedure Clear;
  end;

var
  FormTSBaseSimpleEntryForm: TFormTSBaseSimpleEntryForm;

implementation

Uses prettymessages;

{$R *.dfm}

constructor TformTSBaseSimpleEntryForm.CreateTitle (aOwner: tComponent; const aTitle: String);
begin
  Create (aOwner);
  Caption := aTitle;
end;

procedure TformTSBaseSimpleEntryForm.FormCreate(Sender: TObject);
begin
  inherited;
  fUpdateKind   := ukInsert;
  fIsClearing   := False;
  fChanged      := False;
  BtnOK.Enabled := False;
end;

Procedure TformTSBaseSimpleEntryForm.IntDoCancel;
var
  lvCancel: Boolean;
begin
  inherited;
  lvCancel := True;
  DoCancel (lvCancel);
  if lvCancel then ModalResult := mrCancel;
end;

procedure TformTSBaseSimpleEntryForm.Clear;
begin
  fIsClearing := True;
  Try
    DoClear;
    fnChanged := False;
  Finally
    fIsClearing := False;
  end;
end;

procedure TformTSBaseSimpleEntryForm.DoCancel (var aCancel: Boolean);
begin
end;

// Routine: FormCloseQuery
// Author: M.A.Sargent  Date: 20/12/11  Version: V1.0
//         M.A.Sargent        08/08/16           V2.0
//
// Notes: Add Virtual function, default to True, allows SubClass to not Prompt
//        for CanClose assignment
//  V2.0: Updated to add a No as the default
//
procedure TformTSBaseSimpleEntryForm.FormCloseQuery (Sender: TObject; var CanClose: Boolean);
begin
  inherited;
  if fnDoCloseQuery then
    if fChanged then
      CanClose := (fnSimpleMessage (cmsg_CONFIRM_LOSS_CHANGES, mtConfirmation, [mbYes, mbNo], mbNo) = mrYes);
end;

// Routine: fnDoCloseQuery
// Author: M.A.Sargent  Date: 20/12/11  Version: V1.0
//
// Notes: Defaults to True
//
Function TformTSBaseSimpleEntryForm.fnDoCloseQuery: Boolean;
begin
  Result := True;
end;

{Function TformTSBaseSimpleEntryForm.fnHasChanged: Boolean;
begin
  Result := fChanged;
end;}

procedure TformTSBaseSimpleEntryForm.InitialShow;
begin
  inherited;
  Clear;
end;

procedure TformTSBaseSimpleEntryForm.SetChanged (Const Value: Boolean);
begin
  if DoneSetUp then begin
    fChanged := Value;
    DoChanged (fChanged);
  end;
end;

procedure TformTSBaseSimpleEntryForm.IntDoOK;
var
  lvOK: Boolean;
  lvMsg: String;
begin
  lvOK  := True;
  lvMsg := '';
  DoValidate (lvOK, lvMsg);
  Case lvOK of
    True: begin
      DoOK (lvOK);
      if lvOK then begin
        fnChanged   := False;
        ModalResult := mrOK;
      end;
    end;
    False: begin
      if (lvMsg<>'') then fnSimpleMessage ('Error: %s', [lvMsg], mtError, [mbOK]);
    end;
  end;
end;

procedure TformTSBaseSimpleEntryForm.DoOK (var aOK: Boolean);
begin
end;

procedure TformTSBaseSimpleEntryForm.BtnOKClick(Sender: TObject);
begin
  inherited;
  IntDoOK;
end;

Procedure TformTSBaseSimpleEntryForm.IsChanged;
begin
  fnChanged := True;
end;

// Routine: DoChanged
// Author: M.A.Sargent  Date: 16/07/11  Version: V1.0
//
// Notes:
//
procedure TformTSBaseSimpleEntryForm.DoChanged (const Value: Boolean);
begin
end;

// Routine: DoValidate
// Author: M.A.Sargent  Date: 26/01/12  Version: V1.0
//
// Notes:
//
procedure TformTSBaseSimpleEntryForm.DoValidate (var aOK: Boolean; var aMsg: String);
begin
end;

// Routine: DoClear
// Author: M.A.Sargent  Date: 05/12/12  Version: V1.0
//
// Notes:
//
procedure TformTSBaseSimpleEntryForm.DoClear;
begin
end;

procedure TformTSBaseSimpleEntryForm.OKBtnClick(Sender: TObject);
begin
  inherited;
  IntDoOK;
end;

Procedure TformTSBaseSimpleEntryForm.CancelBtnClick(Sender: TObject);
begin
  inherited;
  IntDoCancel;
end;

// Routine: fnIsInsert
// Author: M.A.Sargent  Date: 05/12/12  Version: V1.0
//
// Notes:
//
Function TFormTSBaseSimpleEntryForm.fnIsInsert: Boolean;
begin
  Result := (fUpdateKind = ukInsert);
end;

end.
