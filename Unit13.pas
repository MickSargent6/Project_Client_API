unit Unit13;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, IdBaseComponent, MASStringListU,
  IdComponent, IdTCPConnection, IdTCPClient, Buttons,
  MASRecordStructuresU, MAS_IniU, TS_SystemVariablesU, MASWindowsSystemInfoU,
  Spin, IdServerIOHandler, IdServerIOHandlerSocket, TSUK_UtilsU,
  DB, Grids, DBGrids, ComCtrls, DBClient, TSUK_ConstsU, TSUK_ActivationClient_HelpersU,
  SystemInfoU, D7_Activation_HelpersU, TSUK_D7_ConstsU, TSUK_D7_UtilsU;


type
  TForm13 = class(TForm)
    Memo1: TMemo;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edSage: TEdit;
    Label2: TLabel;
    edSalesNumber: TEdit;
    Label3: TLabel;
    edFingerPrint: TEdit;
    Label4: TLabel;
    cbProduct: TComboBox;
    cbVersion: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    edComputerName: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    cbPort: TComboBox;
    cbURL: TComboBox;
    Label9: TLabel;
    Label10: TLabel;
    edPassword: TEdit;
    Label11: TLabel;
    edUserName: TEdit;
    BtnRefresh: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button20: TButton;
    Edit1: TEdit;
    Button21: TButton;
    Button22: TButton;
    cbFirstTimeOnly: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Memo1DblClick(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
//    procedure BtnGetClick(Sender: TObject);
    procedure cbProductExit(Sender: TObject);
    procedure cbVersionExit(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
  private
    fIni:     tMASIni;
    procedure CheckClient;
    procedure AddMsg(const aMsg: String);
    Procedure IntAddMsg (Const aName: string; Const aResult: tOKStrRec; Const aValue: Variant);
    Procedure IntAddMsg2 (Const aName: string; Const aResult: tOKStrRec; Const aValue, aValue2: Variant);
    function Int_fnFingerPrint: String;

{   procedure DoPeriodicHeartBeat(Sender: tObject; const aTotalHeatBeat: Integer);
    procedure Int_Duplicate(Sender: tObject; const aIsConnect: Boolean);
    procedure Int_OpenEvent(aTCPClient: tIdTCPClient; const aOpenEvent: tOpenEvent);
    Procedure Int_OnException (aTCPClient: tIdTCPClient; Const aName: String; Const aExcp: Exception);}
  end;

var
  Form13: TForm13;

implementation

Uses TypInfo, MAS_DirectoryU, FormatResultU;

{$R *.dfm}

procedure TForm13.FormClose(Sender: TObject; var Action: TCloseAction);
var
  lvRes: tOKStrRec;
begin
  lvRes := fnCloseDown;
  Case lvRes.OK of
    True:;
    else  if not (csDestroying in ComponentState) then
      AddMsg (Format ('CloseDown Failed: %s', [lvRes.Msg]));
  end;
  //
  lvRes := fnActivationClient_CloseDown;
  if not (csDestroying in ComponentState) then begin
    //
    Case lvRes.OK of
      True: AddMsg ('D7 Shutdown OK:');
      else  AddMsg (Format ('D7 Shutdown Failed: %s', [lvRes.Msg]));
    end;
  end;
end;

Procedure TForm13.FormCreate(Sender: TObject);
var
  lvList: tStrings;
begin
  TS_SetApplicationExeName (Application.ExeName);

  lvList := tStringList.Create;
  Try
    fIni := tMASIni.CreateFromApp;
    //
    if fIni.SectionExists ('URL') then
      fIni.IniGetList ('URL', cbURL.Items);
    //
    fIni.IniGetList ('Product', cbProduct.Items);
    //
    fIni.IniGetList ('Version', cbVersion.Items);
    //
    cbURL.Text     := fIni.ReadString ('SetUp', 'URL', cbURL.Text);
    cbProduct.Text := fIni.ReadString ('SetUp', 'Product', cbProduct.Text);
    cbVersion.Text := fIni.ReadString ('SetUp', 'Version', cbVersion.Text);
    //
    edComputerName.Text := fnComputerName;
    BtnRefresh.Click;
    //
    edSage.Text         := fIni.ReadString ('SetUp', 'Sage', edSage.Text);
    edSalesNumber.Text  := fIni.ReadString ('SetUp', 'SalesNumber', edSalesNumber.Text);
    edUserName.Text     := fIni.ReadString ('SetUp', 'UserName', edUserName.Text);
    edPassword.Text     := fIni.ReadString ('SetUp', 'Password', edPassword.Text);
  Finally
    lvList.Free;
  End;
end;

procedure TForm13.FormDestroy(Sender: TObject);
begin
  fIni.WriteString ('SetUp', 'URL',         cbURL.Text);
  fIni.WriteString ('SetUp', 'Product',     cbProduct.Text);
  fIni.WriteString ('SetUp', 'Version',     cbVersion.Text);
  fIni.WriteString ('SetUp', 'Sage',        edSage.Text);
  fIni.WriteString ('SetUp', 'SalesNumber', edSalesNumber.Text);
  fIni.WriteString ('SetUp', 'UserName',    edUserName.Text);
  fIni.WriteString ('SetUp', 'Password',    edPassword.Text);
  //
  fIni.IniSetList ('URL',     cbURL.Items);
  fIni.IniSetList ('Product', cbProduct.Items);
  fIni.IniSetList ('Version', cbVersion.Items);
  //
  fIni.Free;
end;

Procedure TForm13.CheckClient;
begin
  memo1.Clear;
{  if Assigned (fClient) then Exit;
  fClient := tClientActivationServer.Create (ExtractFileDir (Application.ExeName), Self.Name);
  fClient.OnPeriodicHeartBeat      := DoPeriodicHeartBeat;
  fClient.ConnectionEvent          := Int_OpenEvent;
  fClient.OnDulicateConnectCommand := Int_Duplicate;
  fClient.OnTCPClientException     := Int_OnException;}
end;

{procedure TForm13.BtnGetClick(Sender: TObject);
var
  lvRes:              tOKStrRec;
  lvActivationResult: tActivationResult;
  lvList:             tStrings;
  lvFileName:         String;
begin
  //
  CheckClient;
  fClient.Port := StrToInt (cbPort.Text);
  fClient.Host := cbURL.Text;
  lvList := tStringList.Create;
  Try
    lvRes := fClient.fnConnect (edUserName.Text, edPassWord.Text);
    if fnChkOK (lvRes) then begin
      Try
        lvRes := fClient.fnGetLicenseData (edSage.Text, edFingerPrint.Text, edSalesNumber.Text, cbProduct.Text, cbVersion.Text, lvList);
        Case lvRes.OK of
          True: begin
            //
            lvFileName := AppendPath (fnAppPath (''), 'Download.Txt');
            lvList.SaveToFile (lvFileName);
            AddMsg ('Output to Filer: ' + lvFileName);
            AddMsg ('Result: ' + GetEnumName (TypeInfo (tActivationResult), Integer (lvActivationResult)));
          end
          else AddMsg ('Failed: Get Activation File: ' + lvRes.Msg);
        end;
      Finally
        fClient.DisConnect;
      End;
    end
    else AddMsg ('Failed: Login Failed: ' + lvRes.Msg);

  Finally
    lvList.Free;
  End;
end;}

procedure TForm13.BtnRefreshClick (Sender: TObject);
begin
  edFingerPrint.Text  := Int_fnFingerPrint;
end;

procedure TForm13.Button1Click(Sender: TObject);
var
  lvRes: tOKStrRec;
begin
  lvRes := fnPing;
  Case lvRes.OK of
    True: AddMsg ('Ping OK:');
    else  AddMsg (Format ('Ping Failed: %s', [lvRes.Msg]));
  end;
end;

procedure TForm13.Button2Click(Sender: TObject);
var
  lvRes: tOKStrRec;
begin
  lvRes := fnActivation_Setup (ExtractFileName (Application.ExeName),
                               cbURL.Text, edUserName.Text, edPassWord.Text,
                                edSage.Text, edSalesNumber.Text, edFingerPrint.Text, cbProduct.Text, cbVersion.Text,
                                 edComputerName.Text, StrToInt (cbPort.Text));
  Case lvRes.OK of
    True: AddMsg ('Setup OK: ');
    else  AddMsg (Format ('Setup Failed: %s', [lvRes.Msg]));
  end;
end;

procedure TForm13.Button3Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvCheckLicense: tCheckLicense;
begin
  lvRes := fnCheckActivation (lvCheckLicense);
  Case lvRes.OK of
    True: AddMsg ('Check OK: ' + GetEnumName (TypeInfo (tCheckLicense), Integer (lvCheckLicense)));
    else  AddMsg (Format ('Check Failed: %s', [lvRes.Msg]));
  end;
end;

procedure TForm13.cbProductExit(Sender: TObject);
begin
  if (cbProduct.Items.IndexOf (cbProduct.Text) = -1) then
    cbProduct.Items.Add (cbProduct.Text);
end;

procedure TForm13.cbVersionExit(Sender: TObject);
begin
  if (cbVersion.Items.IndexOf (cbVersion.Text) = -1) then
    cbVersion.Items.Add (cbVersion.Text);
end;

procedure TForm13.Memo1DblClick(Sender: TObject);
begin
  memo1.Clear;
end;


procedure TForm13.AddMsg (Const aMsg: String);
begin
  memo1.Lines.Add (aMsg);
  if (memo1.Lines.Count > 100) then memo1.Lines.Clear;
end;

procedure TForm13.Button4Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvList: TStrings;
begin
  lvList := TStringList.Create;
  Try
    lvRes := fnGetLicense (lvList);
    Case lvRes.OK of
      True: begin
              AddMsg ('fnGetLicense OK: ');
              hCopyFromList (lvList, Memo1.Lines, True);

      end
      else  AddMsg (Format ('fnGetLicense Failed: %s', [lvRes.Msg]));
    end;
  Finally
    lvList.Free;
  end;
end;

procedure TForm13.Button5Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvActivationFileStatus: tActivationFileStatus;
begin
   lvRes := fnActivationClient_Setup (ExtractFileDir (Application.ExeName),
                                       cbURL.Text, edPassWord.Text,
                                        edSage.Text, edSalesNumber.Text, edFingerPrint.Text, cbProduct.Text, cbVersion.Text,
                                         StrToInt (cbPort.Text), lvActivationFileStatus);

  Case lvRes.OK of
    True: AddMsg ('D7 Setup OK: ' + GetEnumName (TypeInfo (tActivationFileStatus), Integer (lvActivationFileStatus)));
    else  AddMsg (Format ('D7 Setup Failed: %s', [lvRes.Msg]));
  end;
end;

procedure TForm13.Button6Click(Sender: TObject);
var
  lvRes: tOKStrRec;
begin
  lvRes := fnActivationClient_CloseDown;

  Case lvRes.OK of
    True: AddMsg ('D7 Shutdown OK:');
    else  AddMsg (Format ('D7 Shutdown Failed: %s', [lvRes.Msg]));
  end;

end;

procedure TForm13.Button7Click(Sender: TObject);
var
  lvRes: tOKStrRec;
begin
  lvRes := fnActivationClient_Ping;
  Case lvRes.OK of
    True: AddMsg ('D7 Ping OK:');
    else  AddMsg (Format ('D7 Ping Failed: %s', [lvRes.Msg]));
  end;
end;

procedure TForm13.Button8Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvCheckLicense: tCheckLicense;
begin
  lvRes := fnActivationClient_Check (lvCheckLicense);
  Case lvRes.OK of
    True: AddMsg ('D7 Check OK: ' + GetEnumName (TypeInfo (tCheckLicense), Integer (lvCheckLicense)));
    else  AddMsg (Format ('D7 Check Failed: %s', [lvRes.Msg]));
  end;
end;

procedure TForm13.Button9Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvActivationResult: tActivationResult;
begin
  lvRes := fnActivationClient_Activate (lvActivationResult);
  Case lvRes.OK of
    True: AddMsg ('D7 Activate OK: ' + GetEnumName (TypeInfo (tActivationResult), Integer (lvActivationResult)));
    else  AddMsg (Format ('D7 Activate Failed: %s', [lvRes.Msg]));
  end;
end;

procedure TForm13.Button10Click(Sender: TObject);
var
  lvRes: tOKStrRec;
begin
  lvRes := fnActivationClient_GetLicense;
  Case lvRes.OK of
    True: AddMsg ('D7 Get License OK: ');
    else  AddMsg (Format ('D7 Get License Failed: %s', [lvRes.Msg]));
  end;
end;

procedure TForm13.Button11Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvActivationResult: tActivationResult;
begin
  lvRes := fnActivate (lvActivationResult);
  Case lvRes.OK of
    True: AddMsg ('Activate: OK ' + GetEnumName (TypeInfo (tActivationResult), Integer (lvActivationResult)));
    else  AddMsg (Format ('Activate Failed: %s', [lvRes.Msg]));
  end;

end;

Procedure TForm13.IntAddMsg (Const aName: string; Const aResult: tOKStrRec; Const aValue: Variant);
begin
  Case aResult.OK of
    True: AddMsg (aName + ' OK: ' + VarToStr((aValue)));
    else  AddMsg (Format ('%s Failed: %s', [aName, aResult.Msg]));
  end;
end;
Procedure TForm13.IntAddMsg2 (Const aName: string; Const aResult: tOKStrRec; Const aValue, aValue2: Variant);
begin
  Case aResult.OK of
    True: AddMsg (aName + ' OK: ' + VarToStr(aValue) + ' ' + VarToStr(aValue2));
    else  AddMsg (Format ('%s Failed: %s', [aName, aResult.Msg]));
  end;
end;


procedure TForm13.Button12Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvValue: Boolean;
begin
  lvRes := fnActivationClient_Active (lvValue);
  IntAddMsg ('fnActivationClient_Active', lvRes, lvValue);
end;

{
  Function fnActivationClient_LicenseOptions (var aLicenseOption: tLicenseOptions): tOKStrRec;
}

procedure TForm13.Button13Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvValue: Boolean;
  lvDate:  TDateTime;
begin
  lvRes := fnActivationClient_Expiry (lvValue, lvDate);
  IntAddMsg2 ('fnActivationClient_Expiry', lvRes, lvValue, lvDate);
end;

procedure TForm13.Button14Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvValue: Integer;
begin
  lvRes := fnActivationClient_Employees (lvValue);
  IntAddMsg ('fnActivationClient_Employees', lvRes, lvValue);
end;

procedure TForm13.Button15Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvValue: Integer;
begin
  lvRes := fnActivationClient_TotalUser (lvValue);
  IntAddMsg ('fnActivationClient_TotalUser', lvRes, lvValue);
end;

procedure TForm13.Button16Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvValue: tTimeSystemsRegions;
begin
  lvRes := fnActivationClient_Region (lvValue);
  IntAddMsg ('fnActivationClient_Region', lvRes, GetEnumName (TypeInfo (tTimeSystemsRegions), Integer (lvValue)));
end;

procedure TForm13.Button17Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvValue: String;
  lvValue2: String;
begin
  lvRes := fnActivationClient_Product (lvValue, lvValue2);
  IntAddMsg2 ('fnActivationClient_Product', lvRes, lvValue, lvValue2);
end;

procedure TForm13.Button18Click(Sender: TObject);
var
  lvRes: tOKStrRec;
  lvValue: tLicenseOptions;
begin
  lvRes := fnActivationClient_LicenseOptions (lvValue);
  IntAddMsg ('fnActivationClient_LicenseOptions', lvRes, GetEnumName (TypeInfo (tLicenseOptions), Integer (lvValue)));
end;

procedure TForm13.Button19Click(Sender: TObject);
var
  lvRes:   tOKStrRec;
  lvValue: Boolean;
begin
  lvRes := fnActivationClient_AllowActivation (lvValue);
  IntAddMsg ('fnActivationClient_AllowActivation', lvRes, lvValue);
end;

procedure TForm13.Button20Click(Sender: TObject);
var
  lvRes:      tOKStrRec;
  lvNamedRes: tOKStrRec;
begin
  lvRes := fnActivationClient_GetNamedValue (Edit1.Text, lvNamedRes);
  IntAddMsg ('fnActivationClient_GetNamedValue', lvRes, '');
  IntAddMsg (('   Result: '+Edit1.Text), lvNamedRes, lvNamedRes.Msg);
end;


procedure TForm13.Button22Click(Sender: TObject);
var
  lvRes: tOKStrRec;
begin
  lvRes := fnMachineFingerPrint (cbFirstTimeOnly.Checked, '');
  Case lvRes.OK of
    True: AddMsg ('OK: ' + lvRes.Msg);
    else  AddMsg ('Failed: ' + lvRes.Msg);
  end;
end;

Function TForm13.Int_fnFingerPrint: String;
var
  lvRes: tOKStrRec;
begin
  lvRes := fnMachineFingerPrint (cbFirstTimeOnly.Checked, '');
  fnRaiseOnFalse (lvRes);
  Result := lvRes.Msg;
end;

end.
