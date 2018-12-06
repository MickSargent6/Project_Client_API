//
// Unit: TSBaseForm
// Author: M.A.Sargent  Date: 20/04/18  Version: V1.0
//
// Notes:
//  V2.0: Commrmt Added for Testing
//
unit TSBaseFormU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, {TS_ApplicationMediatorU, }
  Dialogs, MASMessagesU, MASStringListU, StdCtrls, ExtCtrls, TSUK_ConstsU, MASRegistry, MASRecordStructuresU,
  TSUK_D7_ConstsU, MAS_JSon_D7U, MAS_TypesU, MAS_ConstsU;

Type
  tFormDetails = record
    Assigned: Boolean;
    State, Top, Left, Width, Height: Integer;
  end;

type
  TTSBaseForm = class(TForm)
    procedure FormDestroy(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    fSystemShuttingDown:  Boolean;
    fDoneSetUp:           Boolean;
    fDoneInitialShow:     Boolean;
    fDFMDetails:          tFormDetails;
    fDesignMinimumSize:   Boolean;
    fSaveFormSize:        Boolean;
    fDestroying:          Boolean;
    fCommonReg:           tMASRegistry;
    //
    Function GetIsMainApp: Boolean;
  Protected
    procedure GetRegInfoForm;
    procedure SetRegInfoForm;
    Procedure DoOpen; virtual;
    //
    Procedure DoSetupParams (Const aParams: tJSonString2); virtual;
    Procedure DoGetResult   (var aResult: tOKStrRec); virtual;

    Procedure InitialShow; virtual;
    Procedure DoAfterShow; virtual;
    //
    //
    Property IsMainAppForm: Boolean read GetIsMainApp;
    //
//    Procedure AddMsg       (Const aLevel: tTSVerboseLevel; Const aFormatStr: String; Const Args: array of const); overload;
//    Procedure AddMsg       (Const aMsg: String); overload;
//    Procedure AddMsg       (Const aLevel: tTSVerboseLevel; Const aMsg: String); overload;
    //
//    Procedure AddException (Const aLocationName: String; Const aExcp: Exception);
    //
    Property DoneSetUp:          Boolean      read fDoneSetUp;
    Property SystemShuttingDown: Boolean      read fSystemShuttingDown;
    Property CommonReg:          tMASRegistry read fCommonReg write fCommonReg;
  public
    { Public declarations }
    Constructor Create (AOwner: TComponent); override;

    Procedure AfterConstruction; override;
    Procedure SetupParams (Const aParams: tJSonString2);
    //
    Property DesignMinimumSize: Boolean read fDesignMinimumSize write fDesignMinimumSize default False;
    Property SaveFormSize:      Boolean read fSaveFormSize write fSaveFormSize default True;
    Property IsDestroying:      Boolean Read fDestroying default False;
    //
    Property DoneInitialShow:   Boolean read fDoneInitialShow;
  end;

   // Helper Function
   Function h_fnShowModalForm (Const aForm: tForm): tOKStrRec; overload;

var
  TSBaseForm: TTSBaseForm;

implementation

Uses Math, MASCommonU, MAS_IniU, DynamicPropertiesU, ListPropertyAndLoadU, FormatResultU, TypInfo;

{$R *.dfm}

// Notes: Used when showinf a Modal form, there can be at least 4 results.
//        OK, Cancel, Error  Exception
//        1. Set externed attributes form Error and Exception and these will always result False
//        2. OK is OK but Cancel does not mean there is a error, so still return True but set extended attributes to rrCancel
//
Function h_fnShowModalForm (Const aForm: tForm): tOKStrRec;
var
  lvModalResult: tModalResult;
begin
  Result := fnResult (Assigned (aForm), 'Error: AForm Must be Assigned');
  if not Result.OK then begin
    Result.ExtendedInfoRec.aRecordResult := rrError;
    Exit;
  end;
  //
  lvModalResult := aForm.ShowModal;
  Case lvModalResult of
    mrOK:     begin
              Result.OK  := True;
              Result.ExtendedInfoRec.aRecordResult := rrOK;
    end;
    mrCancel: begin
              Result.OK := True;
              Result.ExtendedInfoRec.aRecordResult := rrCancel;
    end;
    else Raise Exception.CreateFmt ('Error: h_fnShowModalForm. Only ModalResults of mrOK and mrCancel are currently processed. %s', [GetEnumName (TypeInfo (tModalResult), Integer(lvModalResult))]);
  End;
end;

{ TBMBaseForm }

constructor TTSBaseForm.Create(AOwner: TComponent);
begin
  inherited;
  fDesignMinimumSize  := False;
  fSaveFormSize       := True;
  fDestroying         := False;
  fDoneInitialShow    := False;
  fDoneSetUp          := False;
  fSystemShuttingDown := False;
  //
  fCommonReg := tMASRegistry.Create;
end;

procedure TTSBaseForm.FormDestroy(Sender: TObject);
begin
  fDestroying := True;
  //
  SetRegInfoForm;
  fCommonReg.Free;
  Inherited;
end;

procedure TTSBaseForm.AfterConstruction;
begin
  inherited;
  GetRegInfoForm;
end;

procedure TTSBaseForm.FormClose (Sender: TObject; var Action: TCloseAction);
begin
end;

// Notes: Event assigned to enabled the user to resize the form/maximize it but
//        form can not be made smaller than the design time size
//
procedure TTSBaseForm.FormCanResize (Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
begin
  inherited;
  if not fDesignMinimumSize then Exit;
  if fDFMDetails.Assigned and (WindowState <> wsMinimized) then
    Resize := (NewWidth >= fDFMDetails.Width) and (NewHeight >= fDFMDetails.Height);
end;

Procedure TTSBaseForm.SetupParams (Const aParams: tJSonString2);
var
  lvList: tMASStringList;
begin
  lvList := tMASStringList.Create;
  Try
    // extrwact the JSon to a Valued Pair list
    if (h_fnGetAddFromJSon (aParams, lvList) = cMC_ZERO) then Exit;
    //Assign published properties at a class level
    // todo
    // Virutal Method to Assign Values in SubClass
    DoSetupParams (aParams);
  Finally
    lvList.Free;
  end;
end;

Procedure TTSBaseForm.DoGetResult (var aResult: tOKStrRec);
begin
end;

Procedure TTSBaseForm.GetRegInfoForm;
var
  lvObj: tMASIni;
  lvFileName: String;
begin
  // this should take care of the screen problem
  Self.Constraints.MaxWidth   := IfTrue (Assigned (Screen), Screen.Width, Width);
  Self.Constraints.MaxHeight  := IfTrue (Assigned (Screen), Screen.Height, Height);
  //
  fDFMDetails.Assigned := True;
  fDFMDetails.State    := Ord (WindowState);
  fDFMDetails.Top      := Top;
  fDFMDetails.Left     := Left;
  fDFMDetails.Width    := Width;
  fDFMDetails.Height   := Height;
  //
  CommonReg.RestoreFormState (Self);
  //
  lvFileName := h_fnIniFileNameFromAppPath ('Forms.Ini');
  if FileExists (lvFileName) then begin
    //
    lvObj := tMASIni.Create (lvFileName);
    Try
      Self.Width             := lvObj.ReadInteger (h_fnFormName (Self.Name), 'Width',             Width);
      Self.Height            := lvObj.ReadInteger (h_fnFormName (Self.Name), 'Height',            Height);
      Self.DesignMinimumSize := lvObj.ReadBoolean (h_fnFormName (Self.Name), 'DesignMinimumSize', DesignMinimumSize);
      //TFormBorderStyle = (bsNone, bsSingle, bsSizeable, bsDialog, bsToolWindow, bsSizeToolWin);
      Self.BorderStyle       := tFormBorderStyle (lvObj.ReadInteger (h_fnFormName (Self.Name), 'BorderStyle', Ord (Self.BorderStyle)));
    Finally
      lvObj.Free;
    end;
  end;
  //
  lvFileName := h_fnIniFileNameFromAppPath ('FormsProperties.Ini');
  fnAssignPropertyFromIni (lvFilename, Self, False);
end;

procedure TTSBaseForm.SetRegInfoForm;
begin
  CommonReg.SaveFormState (Self);
end;

procedure TTSBaseForm.FormShow(Sender: TObject);
begin
  if not fDoneInitialShow then begin
    InitialShow;
    fDoneInitialShow := True;
  end;
end;

procedure TTSBaseForm.InitialShow;
begin
  DoOpen;
  fDoneSetUp := True;
end;

Function TTSBaseForm.GetIsMainApp: Boolean;
begin
  Result := (Application.MainForm = Self);
end;

Procedure TTSBaseForm.DoOpen;
begin
end;

Procedure TTSBaseForm.DoAfterShow;
begin
end;

Procedure TTSBaseForm.DoSetupParams (Const aParams: tJSonString2);
begin
end;


end.

