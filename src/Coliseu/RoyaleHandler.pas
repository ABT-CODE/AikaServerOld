unit RoyaleHandler;

interface

uses
  Generics.Collections, Player, SysUtils, ExtCtrls, BaseMob, MiscData, CommandHandlers, SQL;

type
  TRoyaleHandler = class
  private
    // Métodos internos
    class procedure LogEventStatus; // Log do status do evento
    class procedure CheckPlayersHealth(Sender: TObject); // Verifica HP dos jogadores
    class procedure RemoveEliminatedPlayer(Player: TBaseMob); // Remove jogador eliminado
    class procedure CheckWinner; // Verifica se há vencedor

    // Métodos de banco de dados
    class function CreateQuery: TQuery; // Cria conexão ao banco
    class procedure SavePlayerToDB(Player: TBaseMob); // Salva jogador no banco
    class procedure RemovePlayerFromDB(PlayerID: Integer); // Remove jogador do banco
    class procedure SaveEventStatus(Status: string); // Salva status do evento
    class procedure SaveElimination(Killer, Victim: TBaseMob); // Registra eliminação no banco
   // class procedure LoadPlayersFromDB; // Carrega jogadores do banco
  public
    // Métodos principais
    class procedure StartRoyaleEvent; // Inicia o evento
    class procedure RegisterPlayer(Player: TBaseMob); // Registra jogador no evento
    class procedure PlayerEliminated(Killer, Victim: TBaseMob); // Processa eliminação
    class procedure EndRoyaleEvent; // Finaliza o evento
    class function IsPlayerInEvent(Player: TBaseMob): Boolean; // Verifica se o jogador está no evento


  end;

var
  ActivePlayers: TList<TBaseMob>; // Lista de jogadores ativos
  SafeZoneRadius: Integer; // Raio da zona segura
  EventTimer: TTimer; // Temporizador do evento
  PlayerCheckTimer: TTimer; // Temporizador para verificar HP
  EventID: Integer; // ID do evento no banco

implementation

const
  MYSQL_SERVER = '127.0.0.1';
  MYSQL_PORT = 3306;

{ TRoyaleHandler - Métodos privados }

class function TRoyaleHandler.IsPlayerInEvent(Player: TBaseMob): Boolean;
begin
  Result := ActivePlayers.Contains(Player);
end;


class procedure TRoyaleHandler.SaveElimination(Killer, Victim: TBaseMob);
var
  Query: TQuery;
begin
  Query := CreateQuery;
  try
    Query.SetQuery(
      'INSERT INTO RoyaleEliminations (EventID, KillerID, VictimID, EliminationTime) ' +
      'VALUES (:EventID, :KillerID, :VictimID, NOW())'
    );
    Query.Query.Params[0].AsInteger := EventID;                      // ID do evento
    Query.Query.Params[1].AsInteger := Killer.Character.ClientID;    // ID do assassino
    Query.Query.Params[2].AsInteger := Victim.Character.ClientID;    // ID da vítima
    Query.Query.ExecSQL;

    WriteLn('Eliminação registrada: KillerID=', Killer.Character.ClientID,
      ', VictimID=', Victim.Character.ClientID);
  finally
    Query.Free;
  end;
end;


class function TRoyaleHandler.CreateQuery: TQuery;
begin
  Result := TQuery.Create(MYSQL_SERVER, MYSQL_PORT, 'root', 'Pt190912!@#', 'wars');
  if not Result.Query.Connection.Connected then
    raise Exception.Create('Erro ao conectar ao banco de dados.');
end;

class procedure TRoyaleHandler.SavePlayerToDB(Player: TBaseMob);
var
  Query: TQuery;
  CharacterID: Integer;
begin
  if (Player.Character = nil) or (Player.Character.Name = '') then
  begin
    WriteLn('Erro: Personagem inválido ou nome não definido.');
    Exit;
  end;

  // Busca o ID do personagem na tabela 'characters'
  Query := CreateQuery;
  try
    Query.SetQuery(
      'SELECT id FROM characters WHERE Name = :CharacterName'
    );
    Query.Query.Params[0].AsString := Player.Character.Name; // Usa o nome do personagem como filtro
    Query.Query.Open;

    if not Query.Query.EOF then
      CharacterID := Query.Query.Fields[0].AsInteger // ID do personagem encontrado
    else
    begin
      WriteLn('Erro: Personagem com nome "', Player.Character.Name, '" não encontrado na tabela characters.');
      Exit;
    end;
  finally
    Query.Free;
  end;

  // Insere ou atualiza os dados do jogador na tabela RoyalePlayers
  Query := CreateQuery;
  try
    Query.SetQuery(
      'INSERT INTO RoyalePlayers (PlayerID, PlayerName, CurrentHP, CurrentMP, EventID) ' +
      'VALUES (:PlayerID, :PlayerName, :CurrentHP, :CurrentMP, :EventID) ' +
      'ON DUPLICATE KEY UPDATE CurrentHP = :CurrentHP, CurrentMP = :CurrentMP'
    );
    Query.Query.Params[0].AsInteger := CharacterID;
    Query.Query.Params[1].AsString := Player.Character.Name;
    Query.Query.Params[2].AsInteger := Player.Character.CurrentScore.CurHP;
    Query.Query.Params[3].AsInteger := Player.Character.CurrentScore.CurMP;
    Query.Query.Params[4].AsInteger := EventID;
    Query.Query.ExecSQL;

    WriteLn('Dados do jogador com ID ', CharacterID, ' salvos com sucesso na tabela RoyalePlayers.');
  finally
    Query.Free;
  end;
end;

class procedure TRoyaleHandler.RemovePlayerFromDB(PlayerID: Integer);
var
  Query: TQuery;
begin
  Query := CreateQuery;
  try
    Query.SetQuery('DELETE FROM RoyalePlayers WHERE PlayerID = :PlayerID');
    Query.Query.Params[0].AsInteger := PlayerID;
    Query.Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

class procedure TRoyaleHandler.SaveEventStatus(Status: string);
var
  Query: TQuery;
begin
  Query := CreateQuery;
  try
    if EventID = 0 then
    begin
      Query.SetQuery('INSERT INTO RoyaleEvents (Status, StartTime) VALUES (:Status, NOW())');
      Query.Query.Params[0].AsString := Status;
      Query.Query.ExecSQL;

      Query.SetQuery('SELECT LAST_INSERT_ID() AS EventID');
      Query.Query.Open;
      EventID := Query.Query.Fields[0].AsInteger;
    end
    else
    begin
      Query.SetQuery('UPDATE RoyaleEvents SET Status = :Status, EndTime = NOW() WHERE EventID = :EventID');
      Query.Query.Params[0].AsString := Status;
      Query.Query.Params[1].AsInteger := EventID;
      Query.Query.ExecSQL;
    end;
  finally
    Query.Free;
  end;
end;

class procedure TRoyaleHandler.CheckPlayersHealth(Sender: TObject);
var
  Player: TBaseMob;
begin
  for Player in ActivePlayers do
    if Player.Character.CurrentScore.CurHP <= 0 then
      RemoveEliminatedPlayer(Player);
end;

class procedure TRoyaleHandler.RemoveEliminatedPlayer(Player: TBaseMob);
begin
  if Player.Character.CurrentScore.CurHP <= 0 then
  begin
    Player.Character.CurrentScore.CurHP := 0;
    SavePlayerToDB(Player);
    ActivePlayers.Remove(Player);
    RemovePlayerFromDB(Player.Character.ClientID);
    WriteLn('Jogador ', Player.Character.ClientID, ' foi eliminado e removido do evento.');
  end;
end;

class procedure TRoyaleHandler.LogEventStatus;
begin
  WriteLn('Jogadores restantes: ', ActivePlayers.Count);
  WriteLn('Raio atual da zona segura: ', SafeZoneRadius);
end;

class procedure TRoyaleHandler.CheckWinner;
begin
  if ActivePlayers.Count = 1 then
  begin
    WriteLn('Vencedor: Jogador ', ActivePlayers[0].Character.ClientID);
    EndRoyaleEvent;
  end
  else if ActivePlayers.Count = 0 then
  begin
    WriteLn('Evento terminou sem vencedor.');
    EndRoyaleEvent;
  end;
end;

{ TRoyaleHandler - Métodos públicos }

class procedure TRoyaleHandler.StartRoyaleEvent;
begin
  ActivePlayers := TList<TBaseMob>.Create;
  SafeZoneRadius := 100;
  SaveEventStatus('started');

  // Temporizador para verificar jogadores
  PlayerCheckTimer := TTimer.Create(nil);
  PlayerCheckTimer.Interval := 1000; // Verifica a cada 1 segundo
  PlayerCheckTimer.OnTimer := CheckPlayersHealth;
  PlayerCheckTimer.Enabled := True;

  WriteLn('Evento Battle Royale iniciado!');
end;

class procedure TRoyaleHandler.RegisterPlayer(Player: TBaseMob);
begin
  if not ActivePlayers.Contains(Player) then
  begin
    ActivePlayers.Add(Player);

      // Ativa o modo PvP automaticamente
      Player.ActivatePvP;


    SavePlayerToDB(Player);
    WriteLn('Jogador ', Player.Character.ClientID, ' registrado.');
  end;
end;

class procedure TRoyaleHandler.PlayerEliminated(Killer, Victim: TBaseMob);
begin
  if ActivePlayers.Contains(Victim) then
  begin
    ActivePlayers.Remove(Victim);
    SaveElimination(Killer, Victim);
    WriteLn('Jogador ', Victim.Character.ClientID, ' eliminado por ', Killer.Character.ClientID);
  end;
  CheckWinner;
end;

class procedure TRoyaleHandler.EndRoyaleEvent;
begin
  SaveEventStatus('ended');
  if Assigned(PlayerCheckTimer) then
  begin
    PlayerCheckTimer.Enabled := False;
    FreeAndNil(PlayerCheckTimer);
  end;
  ActivePlayers.Clear;
  WriteLn('Evento Battle Royale finalizado.');
end;

initialization
  ActivePlayers := TList<TBaseMob>.Create;
  EventID := 0;

finalization
  ActivePlayers.Free;
  if Assigned(PlayerCheckTimer) then
    FreeAndNil(PlayerCheckTimer);
end.

