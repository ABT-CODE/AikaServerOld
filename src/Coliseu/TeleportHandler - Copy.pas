unit TeleportHandler;

interface

uses
  Generics.Collections, Player, SysUtils, ExtCtrls, BaseMob, MiscData, CommandHandlers,
  AuctionFunctions, SQL, playerdata;

type
  TPlayerOriginalData = record
    OriginalNation: Integer;
    OriginalGuildIndex: Integer;
    TemporaryGuildIndex: Integer; // Número de guilda temporário
    TemporaryNation: Integer;     // Nação temporária atribuída ao jogador
  end;

  TTeleportHandler = class
  private
    class procedure LogPlayerCount;
    class procedure UpdatePlayerList(Sender: TObject);
    class procedure RemovePlayerIfDead(Player: TBaseMob);
    class procedure TeleportAllPlayers;
    class procedure TimerOnTick(Sender: TObject);
    class procedure TeleportTimerOnTick(Sender: TObject);
    class procedure SaveEventLogToDatabase;
  public
    class procedure ProcessTeleport(Player: TBaseMob);
    class procedure PlayerDisconnectedOrDied(CharacterID: Integer);
    class procedure StartTeleportCountdown;
    class procedure SendLogToPlayers(const Message: string);
    class procedure RewardLastPlayer(Sender: TObject);


  end;

var
  TeleportedPlayerIDs: TList<Integer>; // Lista para armazenar IDs de personagens (CharacterID)
  TeleportedPlayers: TList<TBaseMob>; // Lista para armazenar objetos TBaseMob
  TotalPlayersEntered: Integer;
  TotalPlayersExited: Integer;
  LogUpdateTimer: TTimer;
  TeleportTimer: TTimer; // Temporizador para teleporte após 20 minutos
  TeleportLogUpdateTimer: TTimer; // Temporizador para atualizar logs
  PlayerOriginalData: TDictionary<Integer, TPlayerOriginalData>; // Armazena os dados originais dos jogadores
  NextTemporaryGuildIndex: Integer = 1000; // Contador para guildas temporárias
  NextNationNumber: Integer = 5; // Contador para números de nação

implementation

uses
  packethandlers;

var
  PlayersInEvent: Integer = 0; // Número de jogadores atualmente no evento
  LastPlayerRewardTimer: TTimer; // Temporizador para premiar o último jogador
  LastPlayerID: Integer = -1; // ID do último jogador na lista
  LastLoggedPlayersEntered: Integer = 0; // Último número registrado de jogadores que entraram
  LastLoggedPlayersExited: Integer = 0; // Último número registrado de jogadores que saíram

class procedure TTeleportHandler.RewardLastPlayer(Sender: TObject);
var
  Player: TBaseMob;
begin
  if Assigned(LastPlayerRewardTimer) then
  begin
    LastPlayerRewardTimer.Free;
    LastPlayerRewardTimer := nil;
  end;
  for Player in TeleportedPlayers do
  begin
    if Player.Character.ClientID = LastPlayerID then
    begin
      // Notifica o PacketHandler para entregar o prêmio
      Player.SendClientMessage('Parabéns! Você venceu o evento e será recompensado!', 48);
      Break;
    end;
  end;
  LastPlayerID := -1; // Reseta o ID do último jogador
end;

class procedure TTeleportHandler.SendLogToPlayers(const Message: string);
var
  Player: TBaseMob;
begin
  for Player in TeleportedPlayers do
  begin
    Player.SendClientMessage(Message);
  end;
end;

class procedure TTeleportHandler.LogPlayerCount;
var
  LogMessage: string;
begin
  LogMessage := Format('Evento Battle Royale:' + sLineBreak +
                       'Jogadores Teleportados: %d' + sLineBreak +
                       'Total de Entradas: %d' + sLineBreak +
                       'Total de Saídas: %d' + sLineBreak +
                       'Jogadores Ativos no Evento: %d',
                       [TeleportedPlayers.Count, TotalPlayersEntered, TotalPlayersExited, PlayersInEvent]);
  WriteLn(LogMessage);
  SendLogToPlayers(LogMessage);
  SaveEventLogToDatabase;
end;

class procedure TTeleportHandler.SaveEventLogToDatabase;
var
  Query: TQuery;
begin
  try
    Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
    Query.SetQuery('INSERT INTO event_battle_royale_logs (teleported_players, total_entries, total_exits, active_players) ' +
                   'VALUES (:teleported_players, :total_entries, :total_exits, :active_players)');
    Query.AddParameter2('teleported_players', TeleportedPlayers.Count);
    Query.AddParameter2('total_entries', TotalPlayersEntered);
    Query.AddParameter2('total_exits', TotalPlayersExited);
    Query.AddParameter2('active_players', PlayersInEvent);
    Query.Run(False); // False se não for uma consulta que retorna dados
  finally
    Query.Free;
  end;
end;

class procedure TTeleportHandler.UpdatePlayerList(Sender: TObject);
var
  Player: TBaseMob;
begin
  for Player in TeleportedPlayers do
  begin
    RemovePlayerIfDead(Player);
  end;
  if (TotalPlayersEntered <> LastLoggedPlayersEntered) or
     (TotalPlayersExited <> LastLoggedPlayersExited) then
  begin
    LastLoggedPlayersEntered := TotalPlayersEntered;
    LastLoggedPlayersExited := TotalPlayersExited;
    LogPlayerCount;
  end;
  if PlayersInEvent = 1 then
  begin
    if LastPlayerRewardTimer = nil then
    begin
      LastPlayerRewardTimer := TTimer.Create(nil);
      LastPlayerRewardTimer.Interval := 60000; // 60 segundos
      LastPlayerRewardTimer.OnTimer := TTeleportHandler.RewardLastPlayer;
      LastPlayerRewardTimer.Enabled := True;
      LastPlayerID := TeleportedPlayers[0].Character.ClientID;
      WriteLn('Iniciando contagem regressiva para premiar o último jogador: ', LastPlayerID);
    end;
  end
  else if PlayersInEvent > 1 then
  begin
    if Assigned(LastPlayerRewardTimer) then
    begin
      LastPlayerRewardTimer.Free;
      LastPlayerRewardTimer := nil;
      LastPlayerID := -1;
    end;
  end;
end;

class procedure TTeleportHandler.RemovePlayerIfDead(Player: TBaseMob);
begin
  if Player.Character.CurrentScore.CurHP <= 0 then
  begin
    WriteLn('O jogador com CharacterID ', Player.Character.ClientID, ' morreu e será removido da lista.');
    PlayerDisconnectedOrDied(Player.Character.ClientID);
  end;
end;

class procedure TTeleportHandler.PlayerDisconnectedOrDied(CharacterID: Integer);
var
  Player: TBaseMob;
  I: Integer;
  Query: TQuery;
  OriginalNation: Integer;
  OriginalGuildIndex: Integer;
begin
  for I := TeleportedPlayers.Count - 1 downto 0 do
  begin
    Player := TeleportedPlayers[I];
    if Player.Character.ClientID = CharacterID then
    begin
      // Busca a nação original no banco de dados
      Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
      try
        Query.SetQuery('SELECT OriginalNation, OriginalGuildIndex FROM PlayerOriginalData WHERE CharacterID = :CharacterID');
        Query.AddParameter2('CharacterID', CharacterID);
        Query.Run;
        if not Query.Query.EOF then
        begin
          OriginalNation := Query.Query.Fields[0].AsInteger;
          OriginalGuildIndex := Query.Query.Fields[1].AsInteger;

          // Restaura a nação e guilda originais
          Player.Character.Nation := OriginalNation;
          Player.Character.GuildIndex := OriginalGuildIndex;
        end
        else
        begin
          WriteLn('Erro: dados originais não encontrados para CharacterID: ', CharacterID);
        end;
      finally
        Query.Free;
      end;

      // Remove os dados do banco de dados
      Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
      try
        Query.SetQuery('DELETE FROM PlayerOriginalData WHERE CharacterID = :CharacterID');
        Query.AddParameter2('CharacterID', CharacterID);
        Query.Run(False);
      finally
        Query.Free;
      end;




      // Remove o jogador das listas
      TeleportedPlayers.Delete(I);
      TeleportedPlayerIDs.Remove(CharacterID);



      // Atualiza contadores
      Dec(TotalPlayersEntered);
      Dec(PlayersInEvent);
      if TotalPlayersEntered < 0 then TotalPlayersEntered := 0;
      if PlayersInEvent < 0 then PlayersInEvent := 0;
      Inc(TotalPlayersExited);

      // Envia mensagem ao jogador
      Player.SendClientMessage('Você foi removido do evento Battle Royale.');

      // Remove também da tabela event_teleported_players
      Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
      try
        Query.SetQuery('DELETE FROM event_teleported_players WHERE character_id = :character_id');
        Query.AddParameter2('character_id', CharacterID);
        Query.Run(False);
      finally
        Query.Free;
      end;

      // Registra o log
      LogPlayerCount;
      Break;
    end;
  end;
end;

class procedure TTeleportHandler.ProcessTeleport(Player: TBaseMob);
var
  Query: TQuery;
  OriginalData: TPlayerOriginalData;
  CharacterID: Integer;
begin
  if not TeleportedPlayerIDs.Contains(Player.Character.ClientID) then
  begin
    OriginalData.OriginalNation := Player.Character.Nation;
    OriginalData.OriginalGuildIndex := Player.Character.GuildIndex;
    OriginalData.TemporaryGuildIndex := NextTemporaryGuildIndex;
    Inc(NextTemporaryGuildIndex);
    if NextNationNumber > 200 then NextNationNumber := 5;
    Player.Character.Nation := NextNationNumber;
    Inc(NextNationNumber);
    Player.Character.GuildIndex := OriginalData.TemporaryGuildIndex;
    OriginalData.TemporaryNation := Player.Character.Nation;

    Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
    try
      Query.SetQuery('SELECT owner_accid FROM characters WHERE Name = :CharacterName');
      Query.AddParameter2('CharacterName', String(Player.Character.Name));
      Query.Run;
      if not Query.Query.EOF then
        CharacterID := Query.Query.Fields[0].AsInteger
      else
      begin
        WriteLn('Erro: personagem "', Player.Character.Name, '" não encontrado.');
        Exit;
      end;
    finally
      Query.Free;
    end;

    Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
    try
      Query.SetQuery('INSERT INTO PlayerOriginalData (AccountID, CharacterID, OriginalNation, OriginalGuildIndex, TemporaryGuildIndex, TemporaryNation) ' +
                     'VALUES (:AccountID, :CharacterID, :OriginalNation, :OriginalGuildIndex, :TemporaryGuildIndex, :TemporaryNation)');
      Query.AddParameter2('AccountID', Player.PlayerCharacter.Index);
      Query.AddParameter2('CharacterID', CharacterID);
      Query.AddParameter2('OriginalNation', OriginalData.OriginalNation);
      Query.AddParameter2('OriginalGuildIndex', OriginalData.OriginalGuildIndex);
      Query.AddParameter2('TemporaryGuildIndex', OriginalData.TemporaryGuildIndex);
      Query.AddParameter2('TemporaryNation', OriginalData.TemporaryNation);
      Query.Run(False);
    finally
      Query.Free;
    end;

    PlayerOriginalData.AddOrSetValue(CharacterID, OriginalData);
    TeleportedPlayerIDs.Add(CharacterID);
    TeleportedPlayers.Add(Player);
    Inc(TotalPlayersEntered);
    Inc(PlayersInEvent);
    Player.SendClientMessage('Você foi registrado no evento Battle Royale!', 48);
    LogPlayerCount;

    // 🔽 Insere os dados do jogador na tabela event_teleported_players
    Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
    try
      Query.SetQuery('INSERT INTO event_teleported_players (account_id, character_id, name, joined_at) ' +
                     'VALUES (:account_id, :character_id, :name, NOW())');
      Query.AddParameter2('account_id', Player.PlayerCharacter.Index);
      Query.AddParameter2('character_id', CharacterID);
      Query.AddParameter2('name', String(Player.Character.Name));
      Query.Run(False);
    finally
      Query.Free;
    end;

    LogPlayerCount;
  end;
end;

class procedure TTeleportHandler.TeleportAllPlayers;
var
  Player: TBaseMob;
begin
  for Player in TeleportedPlayers do
  begin
    Player.Teleport(TPosition.Create(2953, 1661));
    WriteLn('Jogador com CharacterID ', Player.Character.ClientID, ' foi teleportado para (2953, 1661)');
  end;
end;

class procedure TTeleportHandler.StartTeleportCountdown;
begin
  TeleportLogUpdateTimer := TTimer.Create(nil);
  TeleportLogUpdateTimer.Interval := 1000; // 1 segundo
  TeleportLogUpdateTimer.OnTimer := TTeleportHandler.TeleportTimerOnTick;
  TeleportLogUpdateTimer.Enabled := True;
end;

class procedure TTeleportHandler.TimerOnTick(Sender: TObject);
begin
  // TeleportAllPlayers;
end;

class procedure TTeleportHandler.TeleportTimerOnTick(Sender: TObject);
begin
  if (TotalPlayersEntered <> LastLoggedPlayersEntered) or
     (TotalPlayersExited <> LastLoggedPlayersExited) then
  begin
    LastLoggedPlayersEntered := TotalPlayersEntered;
    LastLoggedPlayersExited := TotalPlayersExited;
    LogPlayerCount;
  end;
end;

initialization
  TeleportedPlayerIDs := TList<Integer>.Create;
  TeleportedPlayers := TList<TBaseMob>.Create;
  TotalPlayersEntered := 0;
  TotalPlayersExited := 0;
  PlayerOriginalData := TDictionary<Integer, TPlayerOriginalData>.Create;
  LogUpdateTimer := TTimer.Create(nil);
  LogUpdateTimer.Interval := 1000; // 30 segundos
  LogUpdateTimer.OnTimer := TTeleportHandler.UpdatePlayerList;
  LogUpdateTimer.Enabled := True;
  TTeleportHandler.StartTeleportCountdown;

finalization
  TeleportedPlayerIDs.Free;
  TeleportedPlayers.Free;
  LogUpdateTimer.Free;
  TeleportTimer.Free;
  TeleportLogUpdateTimer.Free;
  PlayerOriginalData.Free;

end.
