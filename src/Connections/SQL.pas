unit SQL;
interface
uses Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, Log, System.SysUtils;
type
  TQuery = class(TObject)
    //MySQL: TFDConnection;
    Query: TFDQuery;
    constructor Create(Server: AnsiString; Port: Integer;
      Login, Senha, DB: AnsiString; OnlyTransaction: Boolean = False);
    destructor Destroy; override;
    procedure SetQuery(Query: String);
    procedure AddParameter(Param, Value: AnsiString);
    procedure AddParameter2(Param: AnsiString; Value: Variant);
    procedure Run(Consult: Boolean = True);
   end;
implementation
uses GlobalDefs;
constructor TQuery.Create(Server: AnsiString; Port: Integer; Login: AnsiString;
  Senha: AnsiString; DB: AnsiString; OnlyTransaction: Boolean = False);
var
  Connected: Boolean;
begin
{  MySQL := TFDConnection.Create(nil);
  MySQL.Params.Add('DriverID=MySQL');
  MySQL.Params.Add('Server=' + String(Server));
  MySQL.Params.Add('Port=' + IntToStr(Port));
  MySQL.Params.Add('Database=' + String(DB));
  MySQL.Params.Add('User_Name=' + String(Login));
  MySQL.Params.Add('Password=' + String(Senha));
  MySQL.ResourceOptions.AutoReconnect := True;    }
  //
  //MySQL.ResourceOptions.CmdExecMode := amBlocking;
  //MySQL.TxOptions.AutoCommit := False; // BLOQUENADO AUTO COMMIT AQUI //parece que tem que ser true pra arrumar os erro de transaction
  //
  Query := TFDQuery.Create(nil);
  Query.Connection := TFDConnection.Create(nil);
  Query.Connection.Params.Add('DriverID=MySQL');
  Query.Connection.Params.Add('Server=' + String(Server));
  Query.Connection.Params.Add('Port=' + IntToStr(Port));
  Query.Connection.Params.Add('Database=' + String(DB));
  Query.Connection.Params.Add('User_Name=' + String(Login));
  Query.Connection.Params.Add('Password=' + String(Senha));
  Query.Connection.Params.Add('Charset=utf8mb4');
  Query.Connection.ResourceOptions.AutoReconnect := True;
  Query.Connection.TxOptions.AutoCommit := not OnlyTransaction;
  Query.FetchOptions.Mode := fmAll;

  //Query.Connection.ExecSQL(
  //Query.Connection := MySQL;
  Connected := False;
  while not(Connected) do
  begin
    try
      Query.Connection.Open();
      Connected := Query.Connection.Connected;
    except
      on E: Exception do
      begin
        if(Query.Connection.Connected) then
        begin
          Query.Connection.Close();
        end;
        //Query.Connection.Free;
        FreeAndNil(Query.Connection);
        Query.Connection := TFDConnection.Create(nil);
        Query.Connection.Params.Add('DriverID=MySQL');
        Query.Connection.Params.Add('Server=' + String(Server));
        Query.Connection.Params.Add('Port=' + IntToStr(Port));
        Query.Connection.Params.Add('Database=' + String(DB));
        Query.Connection.Params.Add('User_Name=' + String(Login));
        Query.Connection.Params.Add('Password=' + String(Senha));
        Query.Connection.Params.Add('Charset=utf8mb4');
        Query.Connection.Params.Add('Collate=utf8mb4_unicode_ci');
        Query.Connection.ResourceOptions.AutoReconnect := True;
        Query.Connection.TxOptions.AutoCommit := not OnlyTransaction;
        Query.FetchOptions.Mode := fmAll;


        Logger.Write(E.ClassName + ': ' + E.Message, TLogType.Error);
        Connected := False;
        Continue;
      end;
    end;
  end;
  //inherited Create;
end;
destructor TQuery.Destroy;
begin
  try
    Query.Close;
    Query.Connection.Close;
    FreeAndNil(Query.Connection);
    FreeAndNil(Query);
    //Query.Connection.Free;
    //Query.Free;
    //inherited Destroy;
  except
    on E: Exception do
    begin
      Logger.Write(E.ClassName + ': ' + E.Message, TLogType.Warnings);
    end;
  end;
end;
procedure TQuery.SetQuery(Query: String);
var
  Setted: Boolean;
begin
  Self.Query.Close;
  Self.Query.SQL.Clear;
  Self.Query.SQL.Add(Query);

  {Setted := False;
  while not(Setted) do
  begin
    try
      Self.Query.SQL.Clear;

      Setted := True;
    except
      on E: Exception do
      begin
        Logger.Write(E.ClassName + ' SET QUERY: ' + E.Message, TLogType.Error);
        Setted := False;
        Continue;
      end;
    end;
  end; }
end;
procedure TQuery.AddParameter(Param: AnsiString; Value: AnsiString);
begin
  Self.Query.ParamByName(String(Param)).Value := Value;
end;
procedure TQuery.AddParameter2(Param: AnsiString; Value: Variant);
begin
  Self.Query.ParamByName(String(Param)).Value := Value;
end;
procedure TQuery.Run(Consult: Boolean = True);
var
  Confirmed, xBoolAux: Boolean;
  xSQL: String;
  triedtimes: Integer;
const
  MaxRetries = 1; // Número máximo de tentativas
begin
  xSQL := Query.SQL.Text;

  if Consult then
  begin
    Confirmed := False;
    triedtimes := 0;
    while not Confirmed and (triedtimes <= MaxRetries) do
    begin
      try
        Inc(triedtimes);

        if triedtimes > MaxRetries then
        begin
         // Logger.Write('Número máximo de tentativas atingido em Query.Open. Abortando operação.', TLogType.Error);
         // Exit; // Saia do loop de maneira controlada
        end;

        Query.Open();
        Confirmed := True;
      except
        on E: EFDException do
        begin
          if Pos('Duplicate entry', E.Message) > 0 then
          begin
            //Logger.Write(Format('Erro ao executar Query.Open: Duplicated Entry - %s', [E.Message]), TLogType.Error);
            //Exit; // Evitar novas tentativas em caso de entrada duplicada
          end
          else if Pos('Deadlock', E.Message) > 0 then
          begin
            Logger.Write('Erro de Deadlock ao executar Query.Open: Reiniciando transação', TLogType.Error);
            //Query.Connection.Rollback;
            Continue; // Tentar novamente a transação
          end
          else
          begin  // ero de banco de dados.
            Logger.Write(Format('Erro ao executar Query.Open %s: %s', [E.ClassName, E.Message]), TLogType.Error);
            Confirmed := False;
            xBoolAux := Query.Connection.TxOptions.AutoCommit;
            Query.Close;
            Query.Connection.Close;
            FreeAndNil(Query.Connection);  // Libere os recursos de forma segura
            FreeAndNil(Query);  // Libere o recurso da query
            Query := TFDQuery.Create(nil);
            Query.Connection := TFDConnection.Create(nil);
            Query.Connection.Params.Add('DriverID=MySQL');
            Query.Connection.Params.Add('Server=' + MYSQL_SERVER);
            Query.Connection.Params.Add('Port=' + IntToStr(MYSQL_PORT));
            Query.Connection.Params.Add('Database=' + MYSQL_DATABASE);
            Query.Connection.Params.Add('User_Name=' + MYSQL_USERNAME);
            Query.Connection.Params.Add('Password=' + MYSQL_PASSWORD);
            Query.Connection.Params.Add('Charset=utf8mb4');
            Query.Connection.Params.Add('Collate=utf8mb4_unicode_ci');
            Query.Connection.ResourceOptions.AutoReconnect := True;
            Query.Connection.TxOptions.AutoCommit := xBoolAux;
            Query.FetchOptions.Mode := fmAll;
            Self.SetQuery(xSQL);
          end;
        end;
      end;
    end;
  end
  else
  begin
    Confirmed := False;
    triedtimes := 0;
    while not Confirmed and (triedtimes <= MaxRetries) do
    begin
      try
        Inc(triedtimes);

        if triedtimes > MaxRetries then
        begin
         // Logger.Write('Número máximo de tentativas atingido em Query.ExecSQL. Abortando operação.', TLogType.Error);
          Exit; // Saia do loop de maneira controlada
        end;

        if not Query.Connection.InTransaction then
        begin
          if not Query.Connection.TxOptions.AutoCommit then
          begin
            Query.Connection.StartTransaction;
          end;
        end;

        Query.ExecSQL();
        Confirmed := True;
      except
        on E: EFDException do
        begin
          if Pos('Duplicate entry', E.Message) > 0 then
          begin
           // Logger.Write(Format('Erro ao executar Query.ExecSQL: Duplicated Entry - %s', [E.Message]), TLogType.Error);
            //Exit; // Evitar novas tentativas em caso de entrada duplicada
          end
          else if Pos('Deadlock', E.Message) > 0 then
          begin
            Logger.Write('Erro de Deadlock ao executar Query.ExecSQL: Reiniciando transação', TLogType.Error);
           // Query.Connection.Rollback;
            Continue; // Tentar novamente a transação
          end
          else
          begin
           // Logger.Write(Format('Erro ao executar Query.ExecSQL %s: %s', [E.ClassName, E.Message]), TLogType.Error);
            Confirmed := False;
            xBoolAux := Query.Connection.TxOptions.AutoCommit;
            if Query.Connection.InTransaction then
            begin
              if not Query.Connection.TxOptions.AutoCommit then
              begin
                Query.Connection.Commit;
              end;
            end;
            Query.Close;
            Query.Connection.Close;
            FreeAndNil(Query.Connection);  // Libere os recursos de forma segura
            FreeAndNil(Query);  // Libere o recurso da query
            Query := TFDQuery.Create(nil);
            Query.Connection := TFDConnection.Create(nil);
            Query.Connection.Params.Add('DriverID=MySQL');
            Query.Connection.Params.Add('Server=' + MYSQL_SERVER);
            Query.Connection.Params.Add('Port=' + IntToStr(MYSQL_PORT));
            Query.Connection.Params.Add('Database=' + MYSQL_DATABASE);
            Query.Connection.Params.Add('User_Name=' + MYSQL_USERNAME);
            Query.Connection.Params.Add('Password=' + MYSQL_PASSWORD);
            Query.Connection.Params.Add('Charset=utf8mb4');
            Query.Connection.Params.Add('Collate=utf8mb4_unicode_ci');
            Query.Connection.ResourceOptions.AutoReconnect := True;
            Query.Connection.TxOptions.AutoCommit := xBoolAux;
            Query.FetchOptions.Mode := fmAll;
            Self.SetQuery(xSQL);
          end;
        end;
      end;
    end;
  end;
end;


end.

