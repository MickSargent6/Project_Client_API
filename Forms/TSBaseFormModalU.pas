//
// Unit: formBaseModalU
// Author: M.A.Sargent  Date: 04/06/11  Version: V1.0
//
// Notes:
//
unit TSBaseFormModalU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TSBaseForm_ProjectU, MAS_TypesU, MASRecordStructuresU, jpeg,
  RzBckgnd;

type
  TFormTSBaseFormModal = class(TTSBaseForm_Project)
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  Protected
  public
    { Public declarations }
    Class Function ShowForm (aForm: TFormTSBaseFormModal; Const aCaption: String; Const aParams: tJSONString2): tOKStrRec;
  end;

var
  FormTSBaseFormModal: TFormTSBaseFormModal;

implementation

{$R *.dfm}

Uses FormatResultU, TSBaseFormU;

Class Function TformTSBaseFormModal.ShowForm (aForm: TFormTSBaseFormModal; Const aCaption: String; Const aParams: tJSONString2): tOKStrRec;
begin
  Result := fnResult (Assigned (aForm), 'Error: ShowForm. aForm Must be Assigned');
  if not Result.OK then begin
    Result.ExtendedInfoRec.aRecordResult := rrError;
    Exit;
  end;
  //
  Try
    Try
      aForm.Caption := aCaption;
      aForm.SetupParams (aParams);
      Result := h_fnShowModalForm (aForm);
      aForm.DoGetResult (Result);
    Except
      on e:Exception do begin
        Result := fnResultException ('TformTSBaseFormModal.ShowForm ', e);
      end;
    End;
  Finally
    FreeAndNil (aForm);
  End;
end;

Procedure TformTSBaseFormModal.FormCreate(Sender: TObject);
begin
  inherited;
  KeyPreview := True;
  Self.BorderStyle := bsDialog;
end;

Procedure TformTSBaseFormModal.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_ESCAPE) then
    ModalResult := mrCancel;
end;


end.

