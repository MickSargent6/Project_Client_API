unit MAS_ComponentsReg;

interface

Uses Classes, MAS_fdConnectionU, MAS_fdSQLQueryU, MAS_fdStoredProcU, MAS_TimerU,
      MASLabelU, BaseMASEdit, Pipes, MAS_PipesU, MAS_ClientDataSetU;


procedure Register;

implementation

procedure Register;
begin
  RegisterComponents ('MAS', [tMAS_fdConnection, tMAS_fdQuery, tMAS_fdStoredProc, tMASTimer]);
  RegisterComponents ('MAS', [tMASPipeClient, tMASPipeServer, tMASLabel, tIncrementalEdit, tMAS_ClientDataSet]);
  //
end;

end.

