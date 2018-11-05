unit MAS_D7_ComponentsReg;

interface

Uses Classes, MASmySQLQuery, MASmySQLDatabase, MASmySQLStoredProc, MAS_PipesU, MAS_TimerU, MASTCPClientU, MASTCPServerU,
      cmpTrayIcon, TSAbsSQLQuery, TSDatasourceU, TSAbsTable, MASSaveDialogU, MASOpenDialogU, TSAdvEditU, MASdbCtrlGridU,
       TSABSDatabaseU;

Procedure Register;

implementation

procedure Register;
begin
  RegisterComponents ('TSUK', [tMASmySQLQuery, tMASmySQLStoredProc, tMASMySQLDatabase]);
  RegisterComponents ('TSUK', [tMASPipeClient, tMASPipeServer, tMASTimer, tMASTCPClient, tMASTCPServer]);
  RegisterComponents ('TSUK', [TTrayIcon, tTSAbsQuery, tTSAbsTable, tTSDataSource, tMASSaveDialog, tMASOpenDialog]);
  RegisterComponents ('TSUK', [tTSAdvEdit, tMASdbCtrlGrid, tTSABSDatabase]);
  //
end;

end.

