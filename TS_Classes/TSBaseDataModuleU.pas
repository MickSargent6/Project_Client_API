//
// Unit: TS_BaseClassU
// Author: M.A.Sargent  Date: 29/03/18  Version: V1.0
//
// Notes:
//
unit TSBaseDataModuleU;

interface

uses
  SysUtils, Classes, MASRegistry, TSUK_ConstsU, VerboseLevelTypeU;

type
  TTSBaseDataModule = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  Private
    { Private declarations }
    fCommonReg: tMASRegistry;
  Protected
    Procedure AddMsg       (Const aLevel: tTSVerboseLevel; Const aFormatStr: String; Const Args: array of const); overload;
    Procedure AddMsg       (Const aMsg: String); overload;
    Procedure AddMsg       (Const aLevel: tTSVerboseLevel; Const aMsg: String); overload;
    //
    Procedure AddException (Const aLocationName: String; Const aExcp: Exception);
    //
    Property CommonReg:    tMASRegistry read fCommonReg write fCommonReg;

  public
    { Public declarations }
  end;

var
  TSBaseDataModule: TTSBaseDataModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

Procedure TTSBaseDataModule.DataModuleCreate(Sender: TObject);
begin
  fCommonReg := tMASRegistry.Create;
end;

Procedure TTSBaseDataModule.DataModuleDestroy(Sender: TObject);
begin
  fCommonReg.Free;
end;

Procedure TTSBaseDataModule.AddException (Const aLocationName: String; Const aExcp: Exception);
begin
//  AM_AddException (aLocationName, aExcp);
end;

Procedure TTSBaseDataModule.AddMsg (Const aLevel: tTSVerboseLevel; Const aFormatStr: String; const Args: array of const);
begin
  AddMsg (aLevel, Format (aFormatStr, Args));
end;

Procedure TTSBaseDataModule.AddMsg (Const aLevel: tTSVerboseLevel; Const aMsg: String);
begin
//  AM_LogMsg (aLevel, aMsg);
end;

Procedure TTSBaseDataModule.AddMsg (Const aMsg: String);
begin
  AddMsg (tsvlNormal, aMsg);
end;

end.
