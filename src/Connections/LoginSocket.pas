unit LoginSocket;
interface
uses
  Winsock2, PlayerData, Windows, Classes,
  SysUtils, DateUtils, Player, System.SyncObjs, ShellAPI,SQL;


{$OLDTYPELAYOUT ON}
type
  TServerRecvThread = class(TThread)
  public
    fCritSect: TCriticalSection;
    constructor Create(); virtual;
  protected
    procedure Execute; override;
  end;
  TServerLoopThread = class(TThread)
  public
    fCritSect: TCriticalSection;
    constructor Create(); virtual;
  protected
    procedure Execute; override;
    procedure RestartApplication;  // Declaração do método RestartApplication
  end;
type
  TConnection = packed record
    Index: Integer;
    Socket: TSocket;
    Ip: string;
    IsActive: Boolean;
    ActiveTime: TTime;
    Checked: Boolean;
    PlayerInstance: TPlayer;
    FDset: TFDSet;
  public
    procedure Destroy;
    function ReceiveData: Boolean;
    function CheckSocket: Boolean;
    function SendPacket(const Packet; Size: WORD): Boolean;
  end;
type
  PLoginSocket = ^TLoginSocket;
  TLoginSocket = class(TObject)
    Sock: TSocket;
    ServerAddr: TSockAddrIn;
    Ip: AnsiString;
    ServerName: string;
    IsActive: Boolean;
    ChannelId: BYTE;
    Connections: ARRAY [1 .. 200] OF TConnection;
    // se demorar acontecer o crash dnv, é aqui
    ServerLoopThread: TServerLoopThread;
    RecvThread: TServerRecvThread;
  public
    { Client }
    function FreeClientId: BYTE;
    procedure AddConnection(const Socket: TSocket; const Info: PSockAddr);
    { Start }
    function StartSocket: Boolean;
    function StartServer: Boolean;
    { Disconnect }
    procedure Disconnect(Index: BYTE); overload;
    procedure Disconnect(var Connection: TConnection); overload;
    { Packet Control }
    procedure PacketControl(var Connection: TConnection;
      var Buffer: ARRAY OF BYTE; Size: WORD; initialOffset: WORD);
       end;
{$OLDTYPELAYOUT OFF}

var
  Query: TQuery;



implementation
uses
  GlobalDefs, Log, Packets, EncDec, AuthHandlers;
{$REGION 'TLoginSocket'}
//Altere a função para usar a classe TQuery existente para evitar duplicação de conexão
{function ContarConexoesPorIPNoBanco(const IPExterno: string): Integer;
begin
  Result := 0;  // Inicializa o resultado como 0
 Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
 // Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'server');//china
 // Query := TQuery.Create('localhost', 3306, 'root', 'odisseia190912!@#', 'odisseia');
  try
    // Contar quantas conexões ativas existem para este IP externo
    Query.SetQuery('SELECT COUNT(*) as ConexoesAtivas FROM accounts WHERE ip_created = :IP AND isactive = 1');
    Query.AddParameter('IP', IPExterno);  // Define o IP externo como parâmetro
    Query.Run(True);

    // Se a consulta retornar algum valor, atualize o resultado
    if not Query.Query.Eof then
    begin
      Result := Query.Query.FieldByName('ConexoesAtivas').AsInteger;  // Obtém a contagem de registros com isactive = 1

      // Log simples usando WriteLn para exibir a quantidade de conexões ativas para o IP
      WriteLn('IP ' + IPExterno + ' possui ' + IntToStr(Result) + ' conexões ativas (isactive = 1).');
    end
    else
    begin
      WriteLn('Nenhuma conexão ativa foi encontrada para o IP ' + IPExterno);
    end;
  finally
    Query.Free;
  end;
end; }

function ContarConexoesPorIdentificador(const Identificador: string): Integer;
begin
  Result := 0;  // Inicializa o resultado como 0
  Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
  try
    // Consulta genérica para verificar conexões ativas com base no identificador (IP ou MAC)
    Query.SetQuery('SELECT COUNT(*) as ConexoesAtivas FROM accounts WHERE ip_created = :Identificador AND isactive = 1');
    Query.AddParameter('Identificador', Identificador);  // Define o identificador (IP ou MAC)
    Query.Run(True);

    // Se a consulta retornar algum valor, atualize o resultado
    if not Query.Query.Eof then
    begin
      Result := Query.Query.FieldByName('ConexoesAtivas').AsInteger;
      WriteLn('Identificador ' + Identificador + ' possui ' + IntToStr(Result) + ' conexões ativas (isactive = 1).');
    end
    else
    begin
      WriteLn('Nenhuma conexão ativa foi encontrada para o identificador ' + Identificador);
    end;
  finally
    Query.Free;
  end;
end;











{$REGION 'Client Id'}
function TLoginSocket.FreeClientId: BYTE;
var
  i: BYTE;
begin
  Result := 0;
  for i := Low(Connections) to High(Connections) do
  begin
    if (Connections[i].Index = 0) then
    begin
      Result := i;
      Break;
    end;
  end;
end;
procedure TLoginSocket.AddConnection(const Socket: TSocket;
  const Info: PSockAddr);
var
  Index: BYTE;
  address: TSockAddrIn;
  addressLength: Integer;
begin
  Index := Self.FreeClientId;
  if (Index = 0) then
    Exit;
  Self.Connections[Index].Socket := Socket;
  getpeername(Socket, TSockAddr(address), addressLength);
  Self.Connections[Index].Ip := string(inet_ntoa(address.sin_addr));
  Self.Connections[Index].IsActive := True;
  Self.Connections[Index].ActiveTime := Now;
  Self.Connections[Index].Checked := False;
  Self.Connections[Index].Index := Index;
end;
{$ENDREGION}
{$REGION 'Start'}
function TLoginSocket.StartSocket: Boolean;
var
  wsa: TWsaData;
begin
  Result := False;
  if (WSAStartup(MAKEWORD(2, 2), wsa) <> 0) then
  begin
    Logger.Write('Ocorreu um erro ao inicializar o Winsock 2.',
      TLogType.ServerStatus);
    Exit;
  end;
  Self.Sock := Socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  Self.ServerAddr.sin_family := AF_INET;
  Self.ServerAddr.sin_port := htons(8831);
  Self.ServerAddr.sin_addr.S_addr := inet_addr(PAnsiChar(Self.Ip));
  if (bind(Sock, TSockAddr(ServerAddr), sizeof(ServerAddr)) = -1) then
  begin
    Logger.Write('Ocorreu um erro ao configurar o socket.',
      TLogType.ServerStatus);
    closesocket(Sock);
    Sock := INVALID_SOCKET;
    Exit;
  end;
  if (listen(Sock, 100) = -1) then
  begin
    Logger.Write('Ocorreu um erro ao colocar o socket em modo de escuta.',
      TLogType.ServerStatus);
    closesocket(Sock);
    Sock := INVALID_SOCKET;
    Exit;
  end;
  Result := True;
end;
function TLoginSocket.StartServer: Boolean;
begin
  Result := False;
  if not(Self.StartSocket) then
    Exit;
  IsActive := True;
  ZeroMemory(@Self.Connections, sizeof(Connections));
  Logger.Write('LoginServer iniciado com sucesso [Porta: 8831].',
    TLogType.ServerStatus);
  ServerLoopThread := TServerLoopThread.Create;
  RecvThread := TServerRecvThread.Create;
  Result := True;
end;
{$ENDREGION}
{$REGION 'Disconnect'}
procedure TLoginSocket.Disconnect(Index: BYTE);
begin
  if (Self.Connections[Index].IsActive) then
    Self.Connections[Index].Destroy;
end;
procedure TLoginSocket.Disconnect(var Connection: TConnection);
begin
  if (Connection.IsActive) then
    Connection.Destroy;
end;
{$ENDREGION}
{$REGION 'Packet Control'}
procedure TLoginSocket.PacketControl(var Connection: TConnection;
  var Buffer: ARRAY OF BYTE; Size: WORD; initialOffset: WORD);
var
  Header: TPacketHeader;
begin
  ZeroMemory(@Header, sizeof(Header));
  try
    if (initialOffset > 0) then
    begin
      try
        Move(Buffer[initialOffset], Buffer, sizeof(Buffer));
      except
        on E: Exception do
        begin
          Logger.Write(E.Message, TlogType.Error);
        end;
      end;
    end;
    TEncDec.Decrypt(Buffer, sizeof(Buffer));
    Move(Buffer, Header, sizeof(Header));
  finally
    case Header.Code of
      $81:
        TAuthHandlers.CheckToken(Connection, Buffer);
    end;
  end;
end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'TConnection'}
procedure TConnection.Destroy;
begin
  closesocket(Self.Socket);
  shutdown(Self.Socket, SD_BOTH);
  Self.IsActive := False;
  ZeroMemory(@Self, sizeof(Self));
end;
function TConnection.ReceiveData: Boolean;
var
  RecvBuffer: ARRAY [0 .. 4095] OF BYTE;
  initialOffset: WORD;
  RecvBytes: WORD;
begin
  Result := True;
  try
    ZeroMemory(@RecvBuffer, sizeof(RecvBuffer));
    RecvBytes := Recv(Self.Socket, RecvBuffer, 4096, 0);
    if RecvBytes <= 0 then
    begin
      if (WSAGetLastError = WSAEWOULDBLOCK) then
      begin
        Exit;
      end;
      LoginServer.Disconnect(Self);
      Result := False;
      Exit;
    end;
    if (RecvBytes < sizeof(TPacketHeader)) then
    begin
      Exit;
    end;
    initialOffset := 0;
    if (RecvBytes > 1116) then
    begin
      initialOffset := 4;
      dec(RecvBytes, 4);
    end;

    LoginServer.PacketControl(Self, RecvBuffer, RecvBytes, initialOffset);

    Result := True;
  except
    on E: Exception do
    begin
      Logger.Write('Erro no ReceiveData do LoginSocket - ' + E.Message,
        TLogType.Error);
    end;
  end;
end;
function TConnection.CheckSocket: Boolean;
begin
  Result := True;
  FD_ZERO(FDset);
  _FD_SET(Self.Socket, FDset);
  _FD_SET(LoginServer.Sock, FDset);
  if not(FD_ISSET(Self.Socket, FDset)) then
  begin
    LoginServer.Disconnect(Self);
    Result := False;
    Exit;
  end;
end;
function TConnection.SendPacket(const Packet; Size: WORD): Boolean;
var
  RetVal: Integer;
  Buffer: ARRAY [0 .. 3000] OF BYTE;
begin
  Result := False;
  ZeroMemory(@Buffer, Size);
  Move(Packet, Buffer, Size);
  TEncDec.Encrypt(@Buffer, Size);
  if not Self.IsActive then
    Exit;
  RetVal := Send(Socket, Buffer, Size, 0);
  if (RetVal = SOCKET_ERROR) then
  begin
    Logger.Write('Send failed with error: ' + IntToStr(WSAGetLastError),
      TLogType.Warnings);
    Self.Destroy;
    Exit;
  end;
  Result := True;
end;
{$ENDREGION}
{$REGION 'TServerLoopThread'}
constructor TServerLoopThread.Create();
begin
  fCritSect := TCriticalSection.Create;
  inherited Create(False);
  Self.FreeOnTerminate := True;
end;
procedure TServerLoopThread.RestartApplication;
var
  BatFilePath: string;
begin
  BatFilePath := ExtractFilePath(ParamStr(0)) + 'reiniciar.bat';  // Caminho do reiniciar.bat
  ShellExecute(0, 'open', PChar(BatFilePath), nil, nil, SW_SHOWNORMAL);  // Executa o reiniciar.bat
  Halt;  // Encerra a instância atual
end;

procedure TServerLoopThread.Execute;
var
  newSocket: TSocket;
  ClientInfo: TSockAddrIn;
  ClientInfoLen: Integer;
  Clid: Integer;
  Margv: Cardinal;
  LastError: Integer;
   ClientIP, Username: string;
  ConexoesAtivas: Integer;
begin
  while (LoginServer.IsActive) do
  begin
    try
      if not(ServerHasClosed) then
      begin
        ClientInfoLen := SizeOf(ClientInfo);
        FillChar(ClientInfo, ClientInfoLen, 0);  // Inicializa a estrutura com zeros

        // Aceitar a conexão
        newSocket := accept(LoginServer.Sock, @ClientInfo, @ClientInfoLen);
        if (newSocket <> INVALID_SOCKET) then
        begin
          // Obter o IP do cliente
          ClientIP := inet_ntoa(ClientInfo.sin_addr);

          // Verificar quantas conexões ativas esse IP já tem
          ConexoesAtivas := ContarConexoesPorIdentificador(ClientIP);

          // Se o número de conexões ativas for maior que 1, rejeitar a nova conexão
          if ConexoesAtivas > 2 then  // Aqui verificamos se há mais de 1 conexão ativa
          begin
            Logger.Write('IP ' + ClientIP + ' já possui mais de 1 conexão ativa. Conexão recusada.', TLogType.Warnings);
            closesocket(newSocket);  // Fechar a nova conexão
            Continue;  // Ignorar o restante da iteração do loop
          end;
          // Se não exceder o limite, permitir a conexão
          Clid := LoginServer.FreeClientId;
          if Clid <> 0 then
          begin
            Margv := 1;

            // Configurar o socket como Non-Blocking
            if ioctlsocket(newSocket, FIONBIO, Margv) < 0 then
            begin
              LastError := WSAGetLastError;
              Logger.Write('Ocorreu um erro ao configurar o socket para Non-Blocking. Erro: ' + IntToStr(LastError), TLogType.Warnings);
              closesocket(newSocket);
              newSocket := INVALID_SOCKET;
              RestartApplication;  // Chama o reiniciar.bat para reiniciar a aplicação
              fCritSect.Leave;
              Exit;
            end;

            // Conexão bem-sucedida, configurando a conexão
            LoginServer.Connections[Clid].Socket := newSocket;
            LoginServer.Connections[Clid].ActiveTime := Now;
            LoginServer.Connections[Clid].Checked := False;
            LoginServer.Connections[Clid].Index := Clid;
            LoginServer.Connections[Clid].IsActive := True;
          end;
        end
        else
        begin
          LastError := WSAGetLastError;
          Logger.Write('Erro ao aceitar socket. Erro #' + IntToStr(LastError), TLogType.Warnings);
        end;
      end;
    except
      on E: Exception do
      begin
        Logger.Write('Erro no LoginSocket.pas:TServerLoopThread.Execute: ' + E.Message, TLogType.Error);
        RestartApplication;  // Chama o reiniciar.bat para reiniciar a aplicação em caso de exceção
        fCritSect.Leave;
      end;
    end;

    // Pequeno delay para evitar sobrecarga de CPU
    inherited Sleep(10);
  end;
end;






{$ENDREGION}
{$REGION 'TServerRecvThread'}
constructor TServerRecvThread.Create();
begin
  fCritSect := TCriticalSection.Create;
  inherited Create(False);
  Self.FreeOnTerminate := True;
end;
procedure TServerRecvThread.Execute;
var
  i: BYTE;
begin
  while (LoginServer.IsActive) do
  begin
    for i := Low(LoginServer.Connections) to High(LoginServer.Connections) do
    begin
      if not(LoginServer.Connections[i].IsActive) then
        continue;

      if not(ServerHasClosed) then
      begin
        try
          if
            (LoginServer.Connections[i].ReceiveData = False) { or
              ((MillisecondsBetween(Now, LoginServer.Connections[i].ActiveTime) >=
              60000) and LoginServer.Connections[i].Checked = False) }  then
          begin
            LoginServer.Connections[i].Destroy;
            fCritSect.Leave;
            break;
          end;
          fCritSect.Leave;
        except
          on E: Exception do
          begin
            Logger.Write('Error LoginSocket procedure TServerRecvThread.Execute ' +
              E.Message, TLogType.Error);
            fCritSect.Leave;
            Continue;
          end;
        end;
      end;
      // Sleep(100);
    end;
    fCritSect.Leave;
    Self.Sleep(1);
  end;
  Self.Terminate;
end;
{$ENDREGION}
end.


