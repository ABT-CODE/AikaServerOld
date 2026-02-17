unit TeleportHandler;
interface
uses
  Generics.Collections, Player, SysUtils, ExtCtrls, BaseMob, MiscData, CommandHandlers,
  AuctionFunctions, SQL, playerdata, itemFunctions, functions, DateUtils;

type
  TPlayerOriginalData = record
    OriginalNation: Integer;
    OriginalGuildIndex: Integer;
    TemporaryGuildIndex: Integer; // Número de guilda temporário
    TemporaryNation: Integer;     // Nação temporária atribuída ao jogador
    OriginalStatus: record
      DNFis: Integer;
      DNMAG: Integer;
      DEFFis: Integer;
      DEFMAG: Integer;
      BonusDMG: Integer;
      Critical: Integer;
      Esquiva: Integer;
      Acerto: Integer;
      DuploAtk: Integer;
      SpeedMove: Integer;
      Resistence: Integer;
      HabAtk: Integer;
      DamageCritical: Integer;
      ResDamageCritical: Integer;
      MagPenetration: Integer;
      FisPenetration: Integer;
      CureTax: Integer;
      CritRes: Integer;
      DuploRes: Integer;
      ReduceCooldown: Integer;
      PvPDamage: Integer;
      PvPDefense: Integer;
      ChannelId: Integer;
    end;
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
  packethandlers, GlobalDefs;

var
  PlayersInEvent: Integer = 0; // Número de jogadores atualmente no evento
  LastPlayerRewardTimer: TTimer; // Temporizador para premiar o último jogador
  LastPlayerID: Integer = -1; // ID do último jogador na lista
  LastLoggedPlayersEntered: Integer = 0; // Último número registrado de jogadores que entraram
  LastLoggedPlayersExited: Integer = 0; // Último número registrado de jogadores que saíram

class procedure TTeleportHandler.RewardLastPlayer(Sender: TObject);
var
  I: Integer;
  Player: TBaseMob;
  Query: TQuery;
  OriginalNation: Integer;
  OriginalGuildIndex: Integer;
  CharacterID: Integer;
  AccountID: Integer;
  VictoryCount: Integer;
begin
  if Assigned(LastPlayerRewardTimer) then
  begin
    LastPlayerRewardTimer.Free;
    LastPlayerRewardTimer := nil;
  end;

  for I := 0 to TeleportedPlayers.Count - 1 do
  begin
    Player := TeleportedPlayers[I];
    if Player.Character.ClientID = LastPlayerID then
    begin
      // Notifica o jogador sobre a vitória
      //Player.SendClientMessage('Parabéns! Você venceu o evento e será recompensado!', 48);

      // Notifica todos os jogadores no servidor sobre a vitória
      Servers[Player.ChannelId].SendServerMsg(
      AnsiString(Player.Character.Name) + ' venceu o evento Battle Royale!'
    ,16,16,16);




      // Obtém o ID do personagem e da conta
      Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
      try
        Query.SetQuery('SELECT id, owner_accid FROM characters WHERE Name = :CharacterName');
        Query.AddParameter2('CharacterName', String(Player.Character.Name));
        Query.Run;
        if not Query.Query.EOF then
        begin
          CharacterID := Query.Query.Fields[0].AsInteger; // Obtém o ID do personagem (id)
          AccountID := Query.Query.Fields[1].AsInteger;   // Obtém o ID da conta (owner_accid)
        end
        else
        begin
          WriteLn('Erro: personagem "', Player.Character.Name, '" não encontrado.');
          Exit;
        end;
      finally
        Query.Free;
      end;

      // Verifica se o jogador já possui um registro na tabela event_players_victories
      Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
      try
        Query.SetQuery('SELECT COUNT(*), VictoryCount FROM event_players_victories WHERE CharacterID = :CharacterID');
        Query.AddParameter2('CharacterID', CharacterID);
        Query.Run;
        if Query.Query.Fields[0].AsInteger > 0 then
        begin
          // Jogador já possui um registro, incrementa o VictoryCount
          VictoryCount := Query.Query.Fields[1].AsInteger + 1;

          Query.SetQuery('UPDATE event_players_victories ' +
                         'SET VictoryCount = :VictoryCount, updated_at = NOW() ' +
                         'WHERE CharacterID = :CharacterID');
          Query.AddParameter2('VictoryCount', VictoryCount);
          Query.AddParameter2('CharacterID', CharacterID);
          Query.Run(False);
        end
        else
        begin
          // Jogador não possui um registro, insere um novo
          Query.SetQuery('INSERT INTO event_players_victories ' +
                         '(AccountID, CharacterID, Name, VictoryCount, created_at, updated_at) ' +
                         'VALUES (:AccountID, :CharacterID, :Name, 1, NOW(), NOW())');
          Query.AddParameter2('AccountID', AccountID);
          Query.AddParameter2('CharacterID', CharacterID);
          Query.AddParameter2('Name', String(Player.Character.Name));
          Query.Run(False);
        end;
      finally
        Query.Free;
      end;

      // Restaura a nação e guilda originais
      Player.Character.Nation := OriginalNation;
      Player.Character.GuildIndex := OriginalGuildIndex;

      // Remove o jogador das listas
      TeleportedPlayers.Delete(I);
      TeleportedPlayerIDs.Remove(Player.Character.ClientID);

      // Atualiza contadores
      Dec(TotalPlayersEntered);
      Dec(PlayersInEvent);
      if TotalPlayersEntered < 0 then TotalPlayersEntered := 0;
      if PlayersInEvent < 0 then PlayersInEvent := 0;
      Inc(TotalPlayersExited);

      // Limpa o registro do jogador na tabela event_teleported_players
      Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
      try
        Query.SetQuery('DELETE FROM event_teleported_players');
        Query.Run;
      finally
        Query.Free;
      end;

      player.RemoveBuff(48);
        player.RemoveBuff(304);
        player.RemoveBuff(320);
        player.RemoveBuff(352);
        player.RemoveBuff(368);
        player.RemoveBuff(400);
        player.RemoveBuff(448);
        player.RemoveBuff(480);
        player.RemoveBuff(1152);
        player.RemoveBuff(1184);
        player.RemoveBuff(1248);
        player.RemoveBuff(1280);
        player.RemoveBuff(1312);
        player.RemoveBuff(1328);
        player.RemoveBuff(1344);
        player.RemoveBuff(1360);
        player.RemoveBuff(1440);
        player.RemoveBuff(1488);
        player.RemoveBuff(1520);
        player.RemoveBuff(1536);
        player.RemoveBuff(2048);
        player.RemoveBuff(2080);
        player.RemoveBuff(2128);
        player.RemoveBuff(2144);
        player.RemoveBuff(2192);
        player.RemoveBuff(2256);
        player.RemoveBuff(2272);
        player.RemoveBuff(1368);
        player.RemoveBuff(2400);
        player.RemoveBuff(2464);
        player.RemoveBuff(2496);
        player.RemoveBuff(2992);
        player.RemoveBuff(3024);
        player.RemoveBuff(3044);
        player.RemoveBuff(3088);
        player.RemoveBuff(3152);
        player.RemoveBuff(3200);
        player.RemoveBuff(3264);
        player.RemoveBuff(3312);
        player.RemoveBuff(3440);
        player.RemoveBuff(3983);
        player.RemoveBuff(4163);
        player.RemoveBuff(4192);
        player.RemoveBuff(4335);
        player.RemoveBuff(4929);
        player.RemoveBuff(5009);
        player.RemoveBuff(5072);
        player.RemoveBuff(5120);
        player.RemoveBuff(5232);
        player.RemoveBuff(5296);
        player.RemoveBuff(5344);
        player.RemoveBuff(6059);
        player.RemoveBuff(6040);
        player.RemoveBuff(6126);
        player.RemoveBuff(6134);
        player.RemoveBuff(6172);
        player.RemoveBuff(6219);
        player.RemoveBuff(6384);
        player.RemoveBuff(6605);
        player.RemoveBuff(6606);
        player.RemoveBuff(6616);
        player.RemoveBuff(6624);
        player.RemoveBuff(6629);
        player.RemoveBuff(6633);
        player.RemoveBuff(6634);
        player.RemoveBuff(6638);
        player.RemoveBuff(6645);
        player.RemoveBuff(8696);
        player.RemoveBuff(9111);
        player.RemoveBuff(9151);
        player.RemoveBuff(9011);
        player.RemoveBuff(9010);
        player.RemoveBuff(9012);
        player.RemoveBuff(9007);
        player.RemoveBuff(8699);
        player.RemoveBuff(8694);
        player.RemoveBuff(8403);
        player.RemoveBuff(7248);
        player.RemoveBuff(7249);
        player.RemoveBuff(6976);
        player.RemoveBuff(6643);
        player.RemoveBuff(9093);
        player.RemoveBuff(9095);
        player.RemoveBuff(9206);









      // Desconecta o jogador
      Servers[Player.ChannelId].Players[Player.ClientID].Disconnect;

      Break;
    end;
  end;



  // Reseta o ID do último jogador
  LastPlayerID := -1;
end;

// Desconecta o jogador
     // Servers[Player.ChannelId].Players[Player.ClientID].Disconnect;

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
  PlayerCountMessage: string;
  I: Integer;
begin
  // Mantém a lógica original para criar a mensagem detalhada
  LogMessage := Format('Evento Battle Royale:' + sLineBreak +
                       'Jogadores Teleportados: %d' + sLineBreak +
                       'Total de Entradas: %d' + sLineBreak +
                       'Total de Saídas: %d' + sLineBreak +
                       'Jogadores Ativos no Evento: %d',
                       [TeleportedPlayers.Count, TotalPlayersEntered, TotalPlayersExited, PlayersInEvent]);

  // Exibe a mensagem detalhada no console do servidor
  WriteLn(LogMessage);

  // Envia a mensagem detalhada para os jogadores teleportados
  SendLogToPlayers(LogMessage);

  // Salva o log no banco de dados
  SaveEventLogToDatabase;

  // Nova funcionalidade: Cria e envia uma mensagem apenas com o número de jogadores teleportados
  PlayerCountMessage := Format('Jogadores dentro do Royale: %d', [TeleportedPlayers.Count]);

  // Envia a mensagem global para todos os jogadores no servidor
  for I := 0 to High(Servers) do // Itera por todos os índices do array Servers
  begin
    if Assigned(Servers[I]) then // Verifica se o servidor no índice I está atribuído (não é nulo)
    begin
      Servers[I].SendServerMsg(AnsiString(PlayerCountMessage), 16, 16, 16);
    end;
  end;
end;



// Função auxiliar para limitar valores entre mínimo e máximo
function Clamp(Value, MinValue, MaxValue: Integer): Integer;
begin
  if Value < MinValue then
    Result := MinValue
  else if Value > MaxValue then
    Result := MaxValue
  else
    Result := Value;
end;

class procedure TTeleportHandler.SaveEventLogToDatabase;
var
  Query: TQuery;
begin
  {try
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
  end;}
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
      // Mensagem global para todos os jogadores no servidor
    Servers[Player.ChannelId].SendServerMsg(
      'Iniciando contagem regressiva de 1 minuto para premiar o último jogador: ' +
      AnsiString(TeleportedPlayers[0].Character.Name),16,16,16
    );

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
    player.RemoveBuff(48);
        player.RemoveBuff(304);
        player.RemoveBuff(320);
        player.RemoveBuff(352);
        player.RemoveBuff(368);
        player.RemoveBuff(400);
        player.RemoveBuff(448);
        player.RemoveBuff(480);
        player.RemoveBuff(1152);
        player.RemoveBuff(1184);
        player.RemoveBuff(1248);
        player.RemoveBuff(1280);
        player.RemoveBuff(1312);
        player.RemoveBuff(1328);
        player.RemoveBuff(1344);
        player.RemoveBuff(1360);
        player.RemoveBuff(1440);
        player.RemoveBuff(1488);
        player.RemoveBuff(1520);
        player.RemoveBuff(1536);
        player.RemoveBuff(2048);
        player.RemoveBuff(2080);
        player.RemoveBuff(2128);
        player.RemoveBuff(2144);
        player.RemoveBuff(2192);
        player.RemoveBuff(2256);
        player.RemoveBuff(2272);
        player.RemoveBuff(1368);
        player.RemoveBuff(2400);
        player.RemoveBuff(2464);
        player.RemoveBuff(2496);
        player.RemoveBuff(2992);
        player.RemoveBuff(3024);
        player.RemoveBuff(3044);
        player.RemoveBuff(3088);
        player.RemoveBuff(3152);
        player.RemoveBuff(3200);
        player.RemoveBuff(3264);
        player.RemoveBuff(3312);
        player.RemoveBuff(3440);
        player.RemoveBuff(3983);
        player.RemoveBuff(4163);
        player.RemoveBuff(4192);
        player.RemoveBuff(4335);
        player.RemoveBuff(4929);
        player.RemoveBuff(5009);
        player.RemoveBuff(5072);
        player.RemoveBuff(5120);
        player.RemoveBuff(5232);
        player.RemoveBuff(5296);
        player.RemoveBuff(5344);
        player.RemoveBuff(6059);
        player.RemoveBuff(6040);
        player.RemoveBuff(6126);
        player.RemoveBuff(6134);
        player.RemoveBuff(6172);
        player.RemoveBuff(6219);
        player.RemoveBuff(6384);
        player.RemoveBuff(6605);
        player.RemoveBuff(6606);
        player.RemoveBuff(6616);
        player.RemoveBuff(6624);
        player.RemoveBuff(6629);
        player.RemoveBuff(6633);
        player.RemoveBuff(6634);
        player.RemoveBuff(6638);
        player.RemoveBuff(6645);
        player.RemoveBuff(8696);
        player.RemoveBuff(9111);
        player.RemoveBuff(9151);
        player.RemoveBuff(9011);
        player.RemoveBuff(9010);
        player.RemoveBuff(9012);
        player.RemoveBuff(9007);
        player.RemoveBuff(8699);
        player.RemoveBuff(8694);
        player.RemoveBuff(8403);
        player.RemoveBuff(7248);
        player.RemoveBuff(7249);
        player.RemoveBuff(6976);
        player.RemoveBuff(6643);
        player.RemoveBuff(9093);
        player.RemoveBuff(9095);
        player.RemoveBuff(9206);
         player.RemoveBuff(9185);

  end;

end;

class procedure TTeleportHandler.PlayerDisconnectedOrDied(CharacterID: Integer);
var
  Player: TBaseMob;
  I: Integer;
  Query: TQuery;
  OriginalNation: Integer;
  OriginalGuildIndex: Integer;
  ListIndex: Integer; // Índice do jogador na lista
  OriginalData: TPlayerOriginalData; // Registro original do jogador
begin
  for I := TeleportedPlayers.Count - 1 downto 0 do
  begin
    Player := TeleportedPlayers[I];
    if Player.Character.ClientID = CharacterID then
    begin
      // Busca os dados originais no banco de dados
      Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
      try
        Query.SetQuery('SELECT OriginalNation, OriginalGuildIndex FROM PlayerOriginalData WHERE CharacterID = :CharacterID');
        Query.AddParameter2('CharacterID', CharacterID);
        Query.Run;
        if not Query.Query.EOF then
        begin
          OriginalNation := Query.Query.Fields[0].AsInteger;
          OriginalGuildIndex := Query.Query.Fields[1].AsInteger;

          // Restaura a nação e guilda originais no banco de dados
          Query.SetQuery('UPDATE characters ' +
                         'SET nation = :OriginalNation, guild_index = :OriginalGuildIndex ' +
                         'WHERE owner_accid = :CharacterID');
          Query.AddParameter2('OriginalNation', OriginalNation);
          Query.AddParameter2('OriginalGuildIndex', OriginalGuildIndex);
          Query.AddParameter2('CharacterID', CharacterID);
          Query.Run(False);

          // Restaura os status originais na memória
          if PlayerOriginalData.ContainsKey(CharacterID) then
          begin
            OriginalData := PlayerOriginalData[CharacterID];
            Player.Character.Nation := OriginalData.OriginalNation;
            Player.Character.GuildIndex := OriginalData.OriginalGuildIndex;

            // Restaura os status do personagem
            Player.PlayerCharacter.Base.CurrentScore.DNFis := OriginalData.OriginalStatus.DNFis;
            Player.PlayerCharacter.Base.CurrentScore.DNMAG := OriginalData.OriginalStatus.DNMAG;
            Player.PlayerCharacter.Base.CurrentScore.DEFFis := OriginalData.OriginalStatus.DEFFis;
            Player.PlayerCharacter.Base.CurrentScore.DEFMAG := OriginalData.OriginalStatus.DEFMAG;
            Player.PlayerCharacter.Base.CurrentScore.BonusDMG := OriginalData.OriginalStatus.BonusDMG;
            Player.PlayerCharacter.Base.CurrentScore.Critical := OriginalData.OriginalStatus.Critical;
            Player.PlayerCharacter.Base.CurrentScore.Esquiva := OriginalData.OriginalStatus.Esquiva;
            Player.PlayerCharacter.Base.CurrentScore.Acerto := OriginalData.OriginalStatus.Acerto;
            Player.PlayerCharacter.DuploAtk := OriginalData.OriginalStatus.DuploAtk;
            Player.PlayerCharacter.SpeedMove := OriginalData.OriginalStatus.SpeedMove;
            Player.PlayerCharacter.Resistence := OriginalData.OriginalStatus.Resistence;
            Player.PlayerCharacter.HabAtk := OriginalData.OriginalStatus.HabAtk;
            Player.PlayerCharacter.DamageCritical := OriginalData.OriginalStatus.DamageCritical;
            Player.PlayerCharacter.ResDamageCritical := OriginalData.OriginalStatus.ResDamageCritical;
            Player.PlayerCharacter.MagPenetration := OriginalData.OriginalStatus.MagPenetration;
            Player.PlayerCharacter.FisPenetration := OriginalData.OriginalStatus.FisPenetration;
            Player.PlayerCharacter.CureTax := OriginalData.OriginalStatus.CureTax;
            Player.PlayerCharacter.CritRes := OriginalData.OriginalStatus.CritRes;
            Player.PlayerCharacter.DuploRes := OriginalData.OriginalStatus.DuploRes;
            Player.PlayerCharacter.ReduceCooldown := OriginalData.OriginalStatus.ReduceCooldown;
            Player.PlayerCharacter.PvPDamage := OriginalData.OriginalStatus.PvPDamage;
            Player.PlayerCharacter.PvPDefense := OriginalData.OriginalStatus.PvPDefense;

            Player.GetCurrentScore;  // Recalcula os pontos de status desconsiderando o buff removido
            Player.SendRefreshPoint; // Envia os pontos atualizados ao servidor

            // Notifica o jogador sobre a restauração
            Player.SendClientMessage(Format('Sua nação (%d), guilda (%d) e status originais foram restaurados.', [OriginalNation, OriginalGuildIndex]), 48);
          end
          else
          begin
            WriteLn('Erro: dados originais não encontrados na memória para CharacterID: ', CharacterID);
          end;
        end
        else
        begin
          WriteLn('Erro: dados originais não encontrados no banco de dados para CharacterID: ', CharacterID);
        end;
      finally
        Query.Free;
      end;

      // Determina o índice do jogador na lista
      ListIndex := I;

      // Remove o registro da tabela event_teleported_players usando o ListIndex
      Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
      try
        Query.SetQuery('DELETE FROM event_teleported_players WHERE ListIndex = :ListIndex');
        Query.AddParameter2('ListIndex', ListIndex);
        Query.Run(False);
      finally
        Query.Free;
      end;

      // Remove o registro da tabela PlayerOriginalData
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

      // Remove os dados da memória
      if PlayerOriginalData.ContainsKey(CharacterID) then
        PlayerOriginalData.Remove(CharacterID);

      // Atualiza contadores
      Dec(TotalPlayersEntered);
      Dec(PlayersInEvent);
      if TotalPlayersEntered < 0 then TotalPlayersEntered := 0;
      if PlayersInEvent < 0 then PlayersInEvent := 0;
      Inc(TotalPlayersExited);

      // Envia mensagem ao jogador
      Player.SendClientMessage('Você foi removido do evento Battle Royale.');

      // Registra o log
      LogPlayerCount;

     // Cria os baús no mapa para o jogador que matou (atacante)
      if Player.Character.GuildIndex > 900 then
      begin
        // Gera um número aleatório entre 0 e 100 para determinar a chance de 40%
        var Chance := Random(100); // Gera um número entre 0 e 99

        // Verifica se o número gerado é menor ou igual a 40 (40% de chance)
        if Chance <= 40 then
        begin
          // Declaração do array de IDs de itens possíveis para os baús
          var PossibleItems: array[0..97] of Integer;

          // Preenche o array com os IDs dos itens
          PossibleItems[0] := 3777;
                       PossibleItems[1] := 3610;

            PossibleItems[2] := 3778;
            PossibleItems[3] := 3611;

            PossibleItems[4] := 3779;
            PossibleItems[5] := 3612;

            PossibleItems[6] := 3780;
            PossibleItems[7] := 3613;

            PossibleItems[8] := 3781;
            PossibleItems[9] := 3615;

            PossibleItems[10] := 3782;
            PossibleItems[11] := 3616;

            PossibleItems[12] := 3783;
            PossibleItems[13] := 3617;

            PossibleItems[14] := 3784;
            PossibleItems[15] := 3618;

            PossibleItems[16] := 3785;
            PossibleItems[17] := 3620;

            PossibleItems[18] := 3580;
            PossibleItems[19] := 3621;

            PossibleItems[20] := 3581;
            PossibleItems[21] := 3622;

            PossibleItems[22] := 3582;
            PossibleItems[23] := 3623;

            PossibleItems[24] := 3583;
            PossibleItems[25] := 3624;

            PossibleItems[26] := 3585;
            PossibleItems[27] := 3625;

            PossibleItems[28] := 3586;
            PossibleItems[29] := 3626;

            PossibleItems[30] := 3587;
            PossibleItems[31] := 3627;

            PossibleItems[32] := 3588;
            PossibleItems[33] := 3628;

            PossibleItems[34] := 3590;
            PossibleItems[35] := 3630;

            PossibleItems[36] := 3591;
            PossibleItems[37] := 3631;

            PossibleItems[38] := 3592;
            PossibleItems[39] := 3632;

            PossibleItems[40] := 3593;
            PossibleItems[41] := 3633;

            PossibleItems[42] := 3595;
            PossibleItems[43] := 3635;

            PossibleItems[44] := 3596;
            PossibleItems[45] := 3636;

            PossibleItems[46] := 3597;
            PossibleItems[47] := 3637;

            PossibleItems[48] := 3598;
            PossibleItems[49] := 3638;

            PossibleItems[50] := 3599;
            PossibleItems[51] := 3639;

            PossibleItems[52] := 3600;
            PossibleItems[53] := 1674;

            PossibleItems[54] := 3601;
            PossibleItems[55] := 1734;

            PossibleItems[56] := 3602;
            PossibleItems[57] := 1764;

            PossibleItems[58] := 3603;
            PossibleItems[59] := 1794;

            PossibleItems[60] := 3605;
            PossibleItems[61] := 1824;

            PossibleItems[62] := 3606;
            PossibleItems[63] := 1854;

            PossibleItems[64] := 3607;
            PossibleItems[65] := 1884;

            PossibleItems[66] := 3608;
            PossibleItems[67] := 1914;

            PossibleItems[68] := 3609;
            PossibleItems[69] := 1944;

            PossibleItems[70] := 3610;
            PossibleItems[71] := 1974;

            PossibleItems[72] := 3611;
            PossibleItems[73] := 2004;

            PossibleItems[74] := 3612;
            PossibleItems[75] := 2034;

            PossibleItems[76] := 3613;
            PossibleItems[77] := 2064;

            PossibleItems[78] := 3615;
            PossibleItems[79] := 2094;

            PossibleItems[80] := 3616;
            PossibleItems[81] := 2124;

            PossibleItems[82] := 3617;
            PossibleItems[83] := 2154;

            PossibleItems[84] := 3618;
            PossibleItems[85] := 2184;

            PossibleItems[86] := 3620;
            PossibleItems[87] := 2214;

            PossibleItems[88] := 3621;
            PossibleItems[89] := 2244;

            PossibleItems[90] := 3622;
            PossibleItems[91] := 2274;

            PossibleItems[92] := 3623;
            PossibleItems[93] := 2304;

            PossibleItems[94] := 3624;
            PossibleItems[95] := 2334;

            PossibleItems[96] := 3625;
            PossibleItems[97] := 2364;

          // Gera um índice aleatório para escolher um item da lista
          var RandomIndex := Random(Length(PossibleItems));
          var RandomItemID := PossibleItems[RandomIndex];

          // Cria 1 baú com o item aleatório
          Servers[Player.ChannelId].CreateMapObject(@Servers[Player.ChannelId].Players[Player.ClientID], 320, RandomItemID);

          // Mensagem opcional para o servidor
          Servers[Player.ChannelId].SendServerMsg('O jogador ' +
            AnsiString(Servers[Player.ChannelId].Players[Player.ClientID].Base.Character.Name) +
            ' criou 1 baú contendo o item Raro ' + IntToStr(RandomItemID) + ' ao ser morto.');
        end
        else
        begin
          // Mensagem opcional caso o baú não seja gerado
          Servers[Player.ChannelId].SendServerMsg('O jogador ' +
            AnsiString(Servers[Player.ChannelId].Players[Player.ClientID].Base.Character.Name) +
            ' não gerou nenhum baú ao ser morto.');
        end;
      end;

      //remove todos os buffs
      // Remove cada buff individualmente (método direto)
        player.RemoveBuff(48);
        player.RemoveBuff(304);
        player.RemoveBuff(320);
        player.RemoveBuff(352);
        player.RemoveBuff(368);
        player.RemoveBuff(400);
        player.RemoveBuff(448);
        player.RemoveBuff(480);
        player.RemoveBuff(1152);
        player.RemoveBuff(1184);
        player.RemoveBuff(1248);
        player.RemoveBuff(1280);
        player.RemoveBuff(1312);
        player.RemoveBuff(1328);
        player.RemoveBuff(1344);
        player.RemoveBuff(1360);
        player.RemoveBuff(1440);
        player.RemoveBuff(1488);
        player.RemoveBuff(1520);
        player.RemoveBuff(1536);
        player.RemoveBuff(2048);
        player.RemoveBuff(2080);
        player.RemoveBuff(2128);
        player.RemoveBuff(2144);
        player.RemoveBuff(2192);
        player.RemoveBuff(2256);
        player.RemoveBuff(2272);
        player.RemoveBuff(1368);
        player.RemoveBuff(2400);
        player.RemoveBuff(2464);
        player.RemoveBuff(2496);
        player.RemoveBuff(2992);
        player.RemoveBuff(3024);
        player.RemoveBuff(3044);
        player.RemoveBuff(3088);
        player.RemoveBuff(3152);
        player.RemoveBuff(3200);
        player.RemoveBuff(3264);
        player.RemoveBuff(3312);
        player.RemoveBuff(3440);
        player.RemoveBuff(3983);
        player.RemoveBuff(4163);
        player.RemoveBuff(4192);
        player.RemoveBuff(4335);
        player.RemoveBuff(4929);
        player.RemoveBuff(5009);
        player.RemoveBuff(5072);
        player.RemoveBuff(5120);
        player.RemoveBuff(5232);
        player.RemoveBuff(5296);
        player.RemoveBuff(5344);
        player.RemoveBuff(6059);
        player.RemoveBuff(6040);
        player.RemoveBuff(6126);
        player.RemoveBuff(6134);
        player.RemoveBuff(6172);
        player.RemoveBuff(6219);
        player.RemoveBuff(6384);
        player.RemoveBuff(6605);
        player.RemoveBuff(6606);
        player.RemoveBuff(6616);
        player.RemoveBuff(6624);
        player.RemoveBuff(6629);
        player.RemoveBuff(6633);
        player.RemoveBuff(6634);
        player.RemoveBuff(6638);
        player.RemoveBuff(6645);
        player.RemoveBuff(8696);
        player.RemoveBuff(9111);
        player.RemoveBuff(9151);
        player.RemoveBuff(9011);
        player.RemoveBuff(9010);
        player.RemoveBuff(9012);
        player.RemoveBuff(9007);
        player.RemoveBuff(8699);
        player.RemoveBuff(8694);
        player.RemoveBuff(8403);
        player.RemoveBuff(7248);
        player.RemoveBuff(7249);
        player.RemoveBuff(6976);
        player.RemoveBuff(6643);
        player.RemoveBuff(9093);
        player.RemoveBuff(9095);
        player.RemoveBuff(9206);
         player.RemoveBuff(9185);

      Break;
    end;
  end;
end;

class procedure TTeleportHandler.ProcessTeleport(Player: TBaseMob);
var
  Query: TQuery;
  OriginalData: TPlayerOriginalData;
  CharacterID: Integer;
  ListIndex: Integer; // Índice do jogador na lista

  // Função para verificar se OriginalGuildIndex deve ser incluído
  function ShouldIncludeOriginalGuildIndex(Value: Integer): Boolean;
  begin
    Result := Value <= 900;
  end;

  // Função para construir dinamicamente a query de INSERT
  function BuildInsertQuery: String;
  begin
    Result := 'INSERT INTO PlayerOriginalData (AccountID, CharacterID, OriginalNation, ' +
              'TemporaryGuildIndex, TemporaryNation, created_at, updated_at, ListIndex';

    if ShouldIncludeOriginalGuildIndex(OriginalData.OriginalGuildIndex) then
      Result := Result + ', OriginalGuildIndex';

    Result := Result + ') VALUES (:AccountID, :CharacterID, :OriginalNation, ' +
              ':TemporaryGuildIndex, :TemporaryNation, NOW(), NOW(), :ListIndex';

    if ShouldIncludeOriginalGuildIndex(OriginalData.OriginalGuildIndex) then
      Result := Result + ', :OriginalGuildIndex';

    Result := Result + ')';
  end;

  // Função para construir dinamicamente a query de UPDATE
  function BuildUpdateQuery: String;
  begin
    Result := 'UPDATE PlayerOriginalData ' +
              'SET TemporaryGuildIndex = :TemporaryGuildIndex, ' +
                  'TemporaryNation = :TemporaryNation, ' +
                  'updated_at = NOW(), ' +
                  'ListIndex = :ListIndex ';

    if ShouldIncludeOriginalGuildIndex(OriginalData.OriginalGuildIndex) then
      Result := Result + ', OriginalGuildIndex = :OriginalGuildIndex ';

    Result := Result + 'WHERE CharacterID = :CharacterID';
  end;

begin
  if not TeleportedPlayerIDs.Contains(Player.Character.ClientID) then
  begin
    // Define os valores originais e temporários
    OriginalData.OriginalNation := Player.Character.Nation;
    OriginalData.OriginalGuildIndex := Player.Character.GuildIndex;
    OriginalData.TemporaryGuildIndex := NextTemporaryGuildIndex;
    Inc(NextTemporaryGuildIndex);
    if NextNationNumber > 200 then NextNationNumber := 5;
    Player.Character.Nation := NextNationNumber;
    Inc(NextNationNumber);
    Player.Character.GuildIndex := OriginalData.TemporaryGuildIndex;
    OriginalData.TemporaryNation := Player.Character.Nation;

    // Salva os status originais antes de modificar
    OriginalData.OriginalStatus.DNFis := Player.PlayerCharacter.Base.CurrentScore.DNFis;
    OriginalData.OriginalStatus.DNMAG := Player.PlayerCharacter.Base.CurrentScore.DNMAG;
    OriginalData.OriginalStatus.DEFFis := Player.PlayerCharacter.Base.CurrentScore.DEFFis;
    OriginalData.OriginalStatus.DEFMAG := Player.PlayerCharacter.Base.CurrentScore.DEFMAG;
    OriginalData.OriginalStatus.BonusDMG := Player.PlayerCharacter.Base.CurrentScore.BonusDMG;
    OriginalData.OriginalStatus.Critical := Player.PlayerCharacter.Base.CurrentScore.Critical;
    OriginalData.OriginalStatus.Esquiva := Player.PlayerCharacter.Base.CurrentScore.Esquiva;
    OriginalData.OriginalStatus.Acerto := Player.PlayerCharacter.Base.CurrentScore.Acerto;
    OriginalData.OriginalStatus.DuploAtk := Player.PlayerCharacter.DuploAtk;
    OriginalData.OriginalStatus.SpeedMove := Player.PlayerCharacter.SpeedMove;
    OriginalData.OriginalStatus.Resistence := Player.PlayerCharacter.Resistence;
    OriginalData.OriginalStatus.HabAtk := Player.PlayerCharacter.HabAtk;
    OriginalData.OriginalStatus.DamageCritical := Player.PlayerCharacter.DamageCritical;
    OriginalData.OriginalStatus.ResDamageCritical := Player.PlayerCharacter.ResDamageCritical;
    OriginalData.OriginalStatus.MagPenetration := Player.PlayerCharacter.MagPenetration;
    OriginalData.OriginalStatus.FisPenetration := Player.PlayerCharacter.FisPenetration;
    OriginalData.OriginalStatus.CureTax := Player.PlayerCharacter.CureTax;
    OriginalData.OriginalStatus.CritRes := Player.PlayerCharacter.CritRes;
    OriginalData.OriginalStatus.DuploRes := Player.PlayerCharacter.DuploRes;
    OriginalData.OriginalStatus.ReduceCooldown := Player.PlayerCharacter.ReduceCooldown;
    OriginalData.OriginalStatus.PvPDamage := Player.PlayerCharacter.PvPDamage;
    OriginalData.OriginalStatus.PvPDefense := Player.PlayerCharacter.PvPDefense;

    // Aplica os status temporários com valor de 1500
    Player.PlayerCharacter.Base.CurrentScore.DNFis := 1500;
    Player.PlayerCharacter.Base.CurrentScore.DNMAG := 1500;
    Player.PlayerCharacter.Base.CurrentScore.DEFFis := 1500;
    Player.PlayerCharacter.Base.CurrentScore.DEFMAG := 1500;
    Player.PlayerCharacter.Base.CurrentScore.BonusDMG := 1500;
    Player.PlayerCharacter.Base.CurrentScore.Critical := 1500;
    Player.PlayerCharacter.Base.CurrentScore.Esquiva := 100;
    Player.PlayerCharacter.Base.CurrentScore.Acerto := 100;
    Player.PlayerCharacter.DuploAtk := 1500;
    Player.PlayerCharacter.SpeedMove := 1500;
    Player.PlayerCharacter.Resistence := 1500;
    Player.PlayerCharacter.HabAtk := 1500;
    Player.PlayerCharacter.DamageCritical := 1500;
    Player.PlayerCharacter.ResDamageCritical := 1500;
    Player.PlayerCharacter.MagPenetration := 1500;
    Player.PlayerCharacter.FisPenetration := 1500;
    Player.PlayerCharacter.CureTax := 1500;
    Player.PlayerCharacter.CritRes := 1500;
    Player.PlayerCharacter.DuploRes := 1500;
    Player.PlayerCharacter.ReduceCooldown := 1500;
    Player.PlayerCharacter.PvPDamage := 1500;
    Player.PlayerCharacter.PvPDefense := 1500;
    Player.GetCurrentScore;  // Recalcula os pontos de status desconsiderando o buff removido
    Player.SendRefreshPoint; // Envia os pontos atualizados ao servidor

    // Obtém o ID do personagem
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

    // Determina o índice do jogador na lista
    ListIndex := TeleportedPlayers.Count;
    ListIndex := ListIndex + 1;

    // Verifica se o jogador já tem um registro na tabela PlayerOriginalData
    Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
    try
      Query.SetQuery('SELECT COUNT(*) FROM PlayerOriginalData WHERE CharacterID = :CharacterID');
      Query.AddParameter2('CharacterID', CharacterID);
      Query.Run;
      if Query.Query.Fields[0].AsInteger > 0 then
      begin
        // Atualiza o registro existente
        Query.SetQuery(BuildUpdateQuery);

        // Adiciona parâmetros para todas as colunas, exceto OriginalGuildIndex
        Query.AddParameter2('TemporaryGuildIndex', OriginalData.TemporaryGuildIndex);
        Query.AddParameter2('TemporaryNation', OriginalData.TemporaryNation);
        Query.AddParameter2('ListIndex', ListIndex);
        Query.AddParameter2('CharacterID', CharacterID);

        // Adiciona OriginalGuildIndex apenas se for menor ou igual a 900
        if ShouldIncludeOriginalGuildIndex(OriginalData.OriginalGuildIndex) then
          Query.AddParameter2('OriginalGuildIndex', OriginalData.OriginalGuildIndex);

        Query.Run(False);
      end
      else
      begin
        // Insere um novo registro
        Query.SetQuery(BuildInsertQuery);

        // Adiciona parâmetros para todas as colunas, exceto OriginalGuildIndex
        Query.AddParameter2('AccountID', Player.PlayerCharacter.Index);
        Query.AddParameter2('CharacterID', CharacterID);
        Query.AddParameter2('OriginalNation', OriginalData.OriginalNation);
        Query.AddParameter2('TemporaryGuildIndex', OriginalData.TemporaryGuildIndex);
        Query.AddParameter2('TemporaryNation', OriginalData.TemporaryNation);
        Query.AddParameter2('ListIndex', ListIndex);

        // Adiciona OriginalGuildIndex apenas se for menor ou igual a 900
        if ShouldIncludeOriginalGuildIndex(OriginalData.OriginalGuildIndex) then
          Query.AddParameter2('OriginalGuildIndex', OriginalData.OriginalGuildIndex);

        Query.Run(False);
      end;
    finally
      Query.Free;
    end;

    // Adiciona os dados à memória
    PlayerOriginalData.AddOrSetValue(CharacterID, OriginalData);

    // Atualiza as listas e contadores
    TeleportedPlayerIDs.Add(CharacterID);
    TeleportedPlayers.Add(Player);
    Inc(TotalPlayersEntered);
    Inc(PlayersInEvent);

    // Notifica o jogador
    Player.SendClientMessage('Você foi registrado no evento Battle Royale!', 48);

    // Registra o log
    LogPlayerCount;

    // Insere ou atualiza os dados do jogador na tabela event_teleported_players
    Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
    try
      // Verifica se o jogador já tem um registro na tabela event_teleported_players
      Query.SetQuery('SELECT COUNT(*) FROM event_teleported_players WHERE character_id = :character_id');
      Query.AddParameter2('character_id', CharacterID);
      Query.Run;

      if Query.Query.Fields[0].AsInteger > 0 then
      begin
        // Atualiza o registro existente
        Query.SetQuery('UPDATE event_teleported_players ' +
                       'SET joined_at = NOW(), ListIndex = :ListIndex ' +
                       'WHERE character_id = :character_id');
        Query.AddParameter2('ListIndex', ListIndex);
        Query.AddParameter2('character_id', CharacterID);
        Query.Run(False);
      end
      else
      begin
        // Insere um novo registro
        Query.SetQuery('INSERT INTO event_teleported_players (account_id, character_id, name, joined_at, ListIndex) ' +
                       'VALUES (:account_id, :character_id, :name, NOW(), :ListIndex)');
        Query.AddParameter2('account_id', Player.PlayerCharacter.Index);
        Query.AddParameter2('character_id', CharacterID);
        Query.AddParameter2('name', String(Player.Character.Name));
        Query.AddParameter2('ListIndex', ListIndex);
        Query.Run(False);
      end;
    finally
      Query.Free;
    end;

    LogPlayerCount;
  end;
end;

class procedure TTeleportHandler.TeleportAllPlayers;
var
  I: Integer;
  Player: TBaseMob;
  Query : TQuery;
begin
  // Itera sobre todos os jogadores teleportados usando índices reversos
  for I := TeleportedPlayers.Count - 1 downto 0 do
  begin
    Player := TeleportedPlayers[I];

    try
      // Verifica se o jogador ainda está conectado antes de desconectá-lo
      if Assigned(Servers[Player.ChannelId]) then
      begin
        // Desconecta o jogador usando a função fornecida
        Servers[Player.ChannelId].Players[Player.Character.ClientID].Disconnect;
        WriteLn('Jogador com CharacterID ', Player.Character.ClientID, ' foi desconectado do servidor.');
      end
      else
      begin
        WriteLn('Jogador com CharacterID ', Player.Character.ClientID, ' já estava desconectado ou não encontrado no servidor.');
      end;

      player.RemoveBuff(48);
        player.RemoveBuff(304);
        player.RemoveBuff(320);
        player.RemoveBuff(352);
        player.RemoveBuff(368);
        player.RemoveBuff(400);
        player.RemoveBuff(448);
        player.RemoveBuff(480);
        player.RemoveBuff(1152);
        player.RemoveBuff(1184);
        player.RemoveBuff(1248);
        player.RemoveBuff(1280);
        player.RemoveBuff(1312);
        player.RemoveBuff(1328);
        player.RemoveBuff(1344);
        player.RemoveBuff(1360);
        player.RemoveBuff(1440);
        player.RemoveBuff(1488);
        player.RemoveBuff(1520);
        player.RemoveBuff(1536);
        player.RemoveBuff(2048);
        player.RemoveBuff(2080);
        player.RemoveBuff(2128);
        player.RemoveBuff(2144);
        player.RemoveBuff(2192);
        player.RemoveBuff(2256);
        player.RemoveBuff(2272);
        player.RemoveBuff(1368);
        player.RemoveBuff(2400);
        player.RemoveBuff(2464);
        player.RemoveBuff(2496);
        player.RemoveBuff(2992);
        player.RemoveBuff(3024);
        player.RemoveBuff(3044);
        player.RemoveBuff(3088);
        player.RemoveBuff(3152);
        player.RemoveBuff(3200);
        player.RemoveBuff(3264);
        player.RemoveBuff(3312);
        player.RemoveBuff(3440);
        player.RemoveBuff(3983);
        player.RemoveBuff(4163);
        player.RemoveBuff(4192);
        player.RemoveBuff(4335);
        player.RemoveBuff(4929);
        player.RemoveBuff(5009);
        player.RemoveBuff(5072);
        player.RemoveBuff(5120);
        player.RemoveBuff(5232);
        player.RemoveBuff(5296);
        player.RemoveBuff(5344);
        player.RemoveBuff(6059);
        player.RemoveBuff(6040);
        player.RemoveBuff(6126);
        player.RemoveBuff(6134);
        player.RemoveBuff(6172);
        player.RemoveBuff(6219);
        player.RemoveBuff(6384);
        player.RemoveBuff(6605);
        player.RemoveBuff(6606);
        player.RemoveBuff(6616);
        player.RemoveBuff(6624);
        player.RemoveBuff(6629);
        player.RemoveBuff(6633);
        player.RemoveBuff(6634);
        player.RemoveBuff(6638);
        player.RemoveBuff(6645);
        player.RemoveBuff(8696);
        player.RemoveBuff(9111);
        player.RemoveBuff(9151);
        player.RemoveBuff(9011);
        player.RemoveBuff(9010);
        player.RemoveBuff(9012);
        player.RemoveBuff(9007);
        player.RemoveBuff(8699);
        player.RemoveBuff(8694);
        player.RemoveBuff(8403);
        player.RemoveBuff(7248);
        player.RemoveBuff(7249);
        player.RemoveBuff(6976);
        player.RemoveBuff(6643);
        player.RemoveBuff(9093);
        player.RemoveBuff(9095);
        player.RemoveBuff(9206);
        player.RemoveBuff(9185);

      // Remove o jogador das listas
      TeleportedPlayerIDs.Remove(Player.Character.ClientID);
      TeleportedPlayers.Delete(I); // Remove diretamente do TeleportedPlayers

      // Atualiza contadores
      Dec(TotalPlayersEntered);
      Dec(PlayersInEvent);
      Inc(TotalPlayersExited);



      // Registra o log
      LogPlayerCount;
    except
      on E: Exception do
      begin
        WriteLn('Erro ao processar jogador com CharacterID ', Player.Character.ClientID, ': ', E.Message);
      end;
    end;
  end;

  // Limpa as listas após desconectar todos os jogadores
  TeleportedPlayers.Clear;
  TeleportedPlayerIDs.Clear;

  // Limpa o registro do jogador na tabela event_teleported_players
      Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');
      try
        Query.SetQuery('DELETE FROM event_teleported_players');
        Query.Run;
      finally
        Query.Free;
      end;
end;

class procedure TTeleportHandler.StartTeleportCountdown;
var
  CurrentTime, NextScheduledTime: TDateTime;
  SecondsUntilNextEvent: Integer;
  MillisecondsUntilNextEvent: Integer;
  ScheduledTimes: array[0..2] of TDateTime; // Lista de horários programados
  i: Integer;
  NextEventTime: TDateTime;
begin

    // Obtém o horário atual
  CurrentTime := Now;

   // Cria o temporizador para teleportar todos após 30 segundos
  TeleportTimer := TTimer.Create(nil);
  TeleportTimer.Interval := 3600000; // 60 minutos segundos em milissegundos

  // Atribui o método TimerOnTick ao evento OnTimer
  TeleportTimer.OnTimer := TimerOnTick;

  // Calcula o horário do próximo evento
  CurrentTime := Now;
  NextEventTime := IncMilliSecond(CurrentTime, TeleportTimer.Interval);

  // Exibe o próximo horário de evento no log
  WriteLn(Format('Próximo evento será às %s.', [FormatDateTime('hh:nn:ss', NextEventTime)]));

  // Ativa o temporizador
  TeleportTimer.Enabled := True;
end;




class procedure TTeleportHandler.TimerOnTick(Sender: TObject);
begin
  TeleportAllPlayers;
  WriteLn('Todos os jogadores foram teleportados para a localização (2953, 1661).');

  // Desativa o temporizador antes de reconfigurá-lo
  if Assigned(TeleportTimer) then
  begin
    TeleportTimer.Enabled := False;
    TeleportTimer.Free;
  end;

  // Reconfigura o temporizador para o próximo horário programado
  StartTeleportCountdown;
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

