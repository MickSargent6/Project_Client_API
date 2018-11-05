//
// Unit: MAS_DialogsU
// Author: M.A.Sargent  Date: 22/03/12  Version: V1.0
//
// Notes:
//
unit MAS_DialogsU;

interface

Uses Dialogs, SysUtils, Controls, Forms, StdCtrls, Types, Delphi2007DialogsU;

function MASDlgEx (Const aFormat: String; const Args: array of Const; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; FocusBtn: TMsgDlgBtn): Integer; overload;

function MASDlgEx (Const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; FocusBtn: TMsgDlgBtn): Integer; overload;

function MASDlgEx (Const aFormat: String; const Args: array of Const; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons;
                    FocusBtn: TMsgDlgBtn; Const aCheckBoxCaption: String; var aCBValue: Boolean): Integer; overload;

function MASDlgEx (Const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; FocusBtn: TMsgDlgBtn;
                    Const aCheckBoxCaption: String; var aCBValue: Boolean): Integer; overload;

function MASDlgEx (Const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; FocusBtn, CloseBtn: TMsgDlgBtn;
                    Const aCheckBoxCaption: String; var aCBValue: Boolean): Integer; overload;

implementation

Uses MASCommon_UtilsU;

Function MASDlgEx (Const aFormat: String; const Args: array of Const; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; FocusBtn: TMsgDlgBtn): Integer;
begin
  Result := MASDlgEx (Format (aFormat, Args), DlgType, Buttons, FocusBtn);
end;

// Routine:
// Author: M.A.Sargent  Date: 25/02/12  Version: V1.0
//
// Notes:
//
function MASDlgEx (Const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; FocusBtn: TMsgDlgBtn): Integer;
var
  lvJunk: Boolean;
begin
  Result := MASDlgEx (Msg, DlgType, Buttons, FocusBtn, mbCancel, '', lvJunk);
end;

// Routine:
// Author: M.A.Sargent  Date: 25/02/12  Version: V1.0
//
// Notes:
//
Function MASDlgEx (Const aFormat: String; const Args: array of Const; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons;
                    FocusBtn: TMsgDlgBtn; Const aCheckBoxCaption: String; var aCBValue: Boolean): Integer;
begin
  Result := MASDlgEx (Format (aFormat, Args), DlgType, Buttons, FocusBtn, aCheckBoxCaption, aCBValue);
end;

// Routine:
// Author: M.A.Sargent  Date: 25/02/12  Version: V1.0
//
// Notes:
//
function MASDlgEx (const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; FocusBtn: TMsgDlgBtn;
                        Const aCheckBoxCaption: String; var aCBValue: Boolean): Integer;
begin
  Result := MASDlgEx (Msg, DlgType, Buttons, FocusBtn, mbCancel, aCheckBoxCaption, aCBValue);
end;

// Routine:
// Author: M.A.Sargent  Date: 25/02/12  Version: V1.0
//
// Notes:
//
function MASDlgEx (Const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; FocusBtn, CloseBtn: TMsgDlgBtn;
                        Const aCheckBoxCaption: String; var aCBValue: Boolean): Integer;
{Const
  ModalResults: array[TMsgDlgBtn] of Integer = (mbYes, mbNo, mbOK, mbCancel, mbAbort, mbRetry, mbIgnore, mbAll, mbNoToAll, mbYesToAll, mbHelp, mbClose);
//                                       (mbYes, mbNo, mbOK, mbCancel, mbAbort, mbRetry, mbIgnore, mbAll, mbNoToAll, mbYesToAll, mbHelp, mbClose);}
var
  lvForm: tForm;
  lvCheckBox: tCheckBox;
begin
  //
  lvCheckBox := Nil;
  lvForm := CreateMessageDialog (Msg, DlgType, Buttons, FocusBtn);
  try
    if (aCheckBoxCaption<>'') then begin
      lvCheckBox := tCheckBox.Create (lvForm);
      lvCheckBox.Hint     := aCheckBoxCaption;
      lvCheckBox.ShowHint := True;
      lvCheckBox.Checked  := aCBValue;
      Case (Length (aCheckBoxCaption) > 50) of
        True: lvCheckBox.Caption  := (Copy (aCheckBoxCaption, 1, 50) + '...');
        else  lvCheckBox.Caption  := aCheckBoxCaption;
      end;
      lvCheckBox.Width    := ((Length(aCheckBoxCaption) * AvgeCharWidth (aCheckBoxCaption, lvCheckBox.Font)) + 30);
      lvCheckBox.Top      :=  lvForm.Height-30;
      lvCheckBox.Left     :=  15;
      lvCheckBox.Parent   := lvForm;
      lvForm.Height       := lvForm.Height + 25;
      if (lvCheckBox.Width > lvForm.Width) then lvForm.Width := lvCheckBox.Width;
    end;

    lvForm.Position := poScreenCenter;
    Result := lvForm.ShowModal;
    //if there's a cancel button, ignore CloseBtn.
    if (result = mrCancel) AND (NOT (mbCancel in Buttons)) then
      result := Ord (CloseBtn);
      //result := Ord (ModalResults[CloseBtn]);
  finally
    if Assigned (lvCheckBox) then aCBValue := lvCheckBox.Checked;
    lvForm.Free;
  end;
end;


end.
