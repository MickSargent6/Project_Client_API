//
// Unit: TSBaseForm_AltoU
// Author: M.A.Sargent  Date: 01/10/2018  Version: V1.0
//
unit TSBaseForm_ProjectU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TSBaseFormU, jpeg, RzBckgnd;

type
  TTSBaseForm_Project = class(TTSBaseForm)
    MainBG: TRzBackground;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TSBaseForm_Project: TTSBaseForm_Project;

implementation

{$R *.dfm}

end.
