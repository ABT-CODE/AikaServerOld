unit BaseMob;
interface
{$O+}
uses
  Windows, PlayerData, Diagnostics, Generics.Collections, Packets, SysUtils,
  MiscData, AnsiStrings, FilesData, Math, SQL ;
{$OLDTYPELAYOUT ON}
type
  TPrediction = record
    ETA: Single;
    Timer: { TDateTime; } TStopwatch;
    Source: TPosition;
    Destination: TPosition;
    function CanPredict: Boolean;
    function Elapsed: Integer;
    function Delta: Single;
    function Interpolate(out d: Single): TPosition;
    procedure Create; overload;
    procedure CalcETA(speed: Byte);

  end;
type
  PBaseMob = ^TBaseMob;
  TBaseMob = record
  private
     FLastPosition: TPosition;
     FAttackCountWhileStatic: Integer;
    _prediction: TPrediction;
    _cooldown: TDictionary<WORD, TTime>;
    _buffs: TDictionary<WORD, TDateTime>;
     _currentPosition: TPosition;
    procedure AddToVisible(var mob: TBaseMob; SpawnType: Byte = 0);
    procedure RemoveFromVisible(mob: TBaseMob; SpawnType: Byte = 0);


  public
    IsDead: Boolean;
    ClientID: Dword;
    PranClientID: WORD;
    PetClientID: WORD;
    Character: PCharacter;
    PlayerCharacter: TPlayerCharacter;
    AttackSpeed: DWORD;
    IsActive: Boolean;
    IsDirty: Boolean;
    Mobbaby: WORD;
    PartyId: WORD;
    PartyRequestId: WORD;
    VisibleMobs: TList<WORD>;
    VisibleNPCS: TList<WORD>;
    VisiblePlayers: TList<WORD>;
    TimeForGoldTime: TDateTime;
    VisibleTargets: Array of TMobTarget;
    VisibleTargetsCnt: WORD; // aqui vai ser o controle da lista propia
    LastTimeGarbaged: TDateTime;
    target: PBaseMob;
    IsDungeonMob: Boolean;
    InClastleVerus: Boolean;
    LastReceivedSkillFromCastle: TDateTime;
    PositionSpawnedInCastle: TPosition;
    NationForCastle: Byte;
    NpcIdGen: WORD;
    NpcQuests: Array [0 .. 7] of TQuestMisc;
    PersonalShopIndex: DWORD;
    PersonalShop: TPersonalShopData;
    MOB_EF: ARRAY [0 .. 395] OF Integer;
    EQUIP_CONJUNT: ARRAY [0 .. 15] OF WORD;
    EFF_5: Array [0 .. 2] of WORD; // podemos ter at� 3 efeitos 5
    IsPlayerService: Boolean;
    ChannelId: Byte;
    Neighbors: Array [0 .. 8] of TNeighbor;
    EventListener: Boolean;
    EventAction: Byte;
    EventSkillID: WORD;
    EventSkillEtc1: WORD;
    HPRListener: Boolean; // HPR = HP Recovery
    HPRAction: Byte;
    HPRSkillID: WORD;
    HPRSkillEtc1: WORD;
    SKDListener: Boolean; // SKD = Skill Damage
    SKDAction: Byte;
    SKDSkillID: WORD;
    SKDTarget: WORD;
    SKDSkillEtc1: integer;
    SKDIsMob: Boolean;
    SDKMobID, SDKSecondIndex: WORD;
    Mobid: WORD;
    SecondIndex: WORD;
    IsBoss: Boolean;

    { Skill }
    Chocado: Boolean; //definir quando usa o choque hidra
    LastBasicAttack: TDateTime;
    LastSkillUse: TDateTime;
    LastAttackMsg: TDateTime;
    AttackMsgCount: Integer;
    UsingSkill: WORD;
    ResolutoPoints: Byte;
    ResolutoTime: TDateTime;
    DefesaPoints: Byte;
    DefesaPoints2: Byte;
    BolhaPoints: Byte;
    LaminaID: WORD;
    LaminaPoints: WORD;
    Polimorfed: Boolean;
    UsingLongSkill: Boolean;
    LongSkillTimes: WORD;
    UniaoDivina: String;
    SessionOnline: Boolean;
    SessionUsername: String;
    SessionMasterPriv: TMasterPrives;
    MissCount: WORD;
    NegarCuraCount: Integer;
    RevivedTime: TDateTime;
    CurrentAction: Integer;
    LastSplashTime: TDateTime;

    ActiveTitle: Integer;
    LastReceivedAttack: TDateTime;
    LastMovedTime: TDateTime;
    LastMovedMessageHack: TDateTime;
    AttacksAccumulated, AttacksReceivedAccumulated: Integer;
    DroppedCount: Integer;
    { TBaseMob }
    procedure ActivatePvP;


    procedure Create(characterPointer: PCharacter; Index: WORD;
      ChannelId: Byte); overload;
        procedure SendClientMessage(const Message: string; MsgType: Integer = 0);
    procedure Destroy(Aux: Boolean = False);
    function IsPlayer: Boolean;
    procedure UpdateVisibleList(SpawnType: Byte = 0);
    function CurrentPosition: TPosition;
    procedure SetDestination(const Destination: TPosition);
    procedure addvisible(m: TBaseMob);
    procedure removevisible(m: TBaseMob);
    procedure AddHP(Value: Integer; ShowUpdate: Boolean);
    procedure AddMP(Value: Integer; ShowUpdate: Boolean);
    procedure RemoveHP(Value: Integer; ShowUpdate: Boolean; StayOneHP: Boolean = true);
    procedure RemoveMP(Value: Integer; ShowUpdate: Boolean);
    procedure WalkinTo(Pos: TPosition);
    procedure SetEquipEffect(const Equip: TItem; SetType: Integer;
      ChangeConjunt: Boolean = True; VerifyExpired: Boolean = True);
    procedure SetConjuntEffect(Index: Integer; SetType: Integer);
    procedure ConfigEffect(Count, ConjuntId: Integer; SetType: Integer);
    procedure SetOnTitleActiveEffect();
    procedure SetOffTitleActiveEffect();
    function MatchClassInfo(ClassInfo: Byte): Boolean;
    function IsCompleteEffect5(out CountEffects: Byte): Boolean;
    function SearchEmptyEffect5Slot(): Byte;
    function GetSlotOfEffect5(CallID: WORD): Byte;
    procedure LureMobsInRange();
    { Send's }
    procedure SendCreateMob(SpawnType: WORD = 0; sendTo: WORD = 0;
      SendSelf: Boolean = True; Polimorf: WORD = 0);
    procedure SendRemoveMob(delType: Integer = 0; sendTo: WORD = 0;
      SendSelf: Boolean = True);
    procedure SendToVisible(var Packet; size: WORD; sendToSelf: Boolean = True);
    procedure SendPacket(var Packet; size: WORD);
    procedure SendRefreshLevel;
    procedure SendCurrentHPMP(Update: Boolean = False);
    procedure SendCurrentHPMPMob();
    procedure SendStatus;
    procedure SendRefreshPoint;
    procedure SendRefreshKills;
    procedure SendEquipItems(SendSelf: Boolean = True);
    procedure SendRefreshItemSlot(SlotType, SlotItem: WORD; Item: TItem;
      Notice: Boolean); overload;
    procedure SendRefreshItemSlot(SlotItem: WORD; Notice: Boolean); overload;
    procedure SendSpawnMobs;
    procedure GenerateBabyMob;
    procedure UngenerateBabyMob(ungenEffect: WORD);
    function AddTargetToList(target: PBaseMob): Boolean;
    function RemoveTargetFromList(target: PBaseMob): Boolean;
    function ContainsTargetInList(target: PBaseMob; out id: WORD)
      : Boolean; overload;
    function ContainsTargetInList(ClientID: WORD): Boolean; overload;
    function ContainsTargetInList(ClientID: WORD; out id: WORD): Boolean; overload;
    function GetEmptyTargetInList(out Index: WORD): Boolean;
    function GetTargetInList(ClientID: WORD): PBaseMob;
    function ClearTargetList(): Boolean;
    function TargetGarbageService(): Boolean;
    { Get's }
    procedure GetCreateMob(out Packet: TSendCreateMobPacket;
      P1: WORD = 0); overload;
    class function GetMob(Index: WORD; Channel: Byte; out mob: TBaseMob)
      : Boolean; overload; static;
    class function GetMob(Index: WORD; Channel: Byte; out mob: PBaseMob)
      : Boolean; overload; static;
    { class function GetMob(Pos: TPosition; Channel: Byte; out mob: TBaseMob)
      : Boolean; overload; static; }
    function GetMobAbility(eff: Integer): Integer;
    procedure IncreasseMobAbility(eff: Integer; Value: Integer);
    procedure DecreasseMobAbility(eff: Integer; Value: Integer);
    function GetCurrentHP(): DWORD;
    function GetCurrentMP(): DWORD;
    function GetRegenerationHP(): DWORD;
    function GetRegenerationMP(): DWORD;
    function GetEquipedItensHPMPInc: DWORD;
    function GetEquipedItensDamageReduce: DWORD;
    function GetMobClass(ClassInfo: Integer = 0): Integer;
    procedure GetCurrentScore;
    procedure GetEquipDamage(const Equip: TItem);
    procedure GetEquipDefense(const Equip: TItem);
    procedure GetEquipsDefense;

    { Buffs }
    function RefreshBuffs: Integer;
    procedure SendRefreshBuffs;
    procedure SendAddBuff(BuffIndex: WORD);
    procedure AddBuffEffect(Index: WORD);
    procedure RemoveBuffEffect(Index: WORD);
    function GetBuffToRemove(): DWORD;
    function GetDeBuffToRemove(): DWORD;
    function GetDebuffCount(): WORD;
    function GetBuffCount(): WORD;
    procedure RemoveBuffByIndex(Index: WORD);
    function GetBuffSameIndex(BuffIndex: DWORD): Boolean;
    function BuffExistsByIndex(BuffIndex: DWORD): Boolean;
    function BuffExistsByID(BuffID: DWORD): Boolean;
    function BuffExistsInArray(const BuffList: Array of DWORD): Boolean;
    function BuffExistsSopa(): Boolean;
    function GetBuffIDByIndex(Index: DWORD): WORD;
    procedure RemoveBuffs(Quant: Byte);
    procedure RemoveDebuffs(Quant: Byte);
    procedure ZerarBuffs();
    { Attack & Skills }
    procedure CheckCooldown(var Packet: TSendSkillUse);
    function CheckCooldown2(SkillID: DWORD): Boolean;
    procedure SendCurrentAllSkillCooldown();
    function AddBuff(BuffIndex: WORD; Refresh: Boolean = True;
      AddTime: Boolean = False; TimeAditional: Integer = 0): Boolean;
    function AddBuffWhenEntering(BuffIndex: Integer;
      BuffTime: TDateTime): Boolean;
    function GetBuffSlot(BuffIndex: WORD): Integer;
    function GetEmptyBuffSlot(): Integer;
    function RemoveBuff(BuffIndex: WORD): Boolean;
    procedure RemoveAllDebuffs();

    procedure SendDamage(Skill, Anim: DWORD; mob: PBaseMob;
      DataSkill: P_SkillData);
    function GetDamage(Skill: DWORD; mob: PBaseMob;
      out DnType: TDamageType): UInt64;
    function GetDamageType(Skill: DWORD; IsPhysical: Boolean; mob: PBaseMob)
      : TDamageType;
    function GetDamageType2(Skill: DWORD; IsPhysical: Boolean; mob: PBaseMob)
      : TDamageType;
    function GetDamageType3(Skill: DWORD; IsPhysical: Boolean; mob: PBaseMob)
      : TDamageType;
    procedure CalcAndCure(Skill: DWORD; mob: PBaseMob);
    function CalcCure(Skill: DWORD; mob: PBaseMob): Integer;
    function CalcCure2(BaseCure: DWORD; mob: PBaseMob; xSkill: Integer = 0): Integer;
    procedure HandleSkill(Skill, Anim: DWORD; mob: PBaseMob;
      SelectedPos: TPosition; DataSkill: P_SkillData);
    function ValidAttack(DmgType: TDamageType; DebuffType: Byte = 0;
      mob: PBaseMob = nil; AuxDano: Integer = 0; xisBoss: Boolean = False): Boolean;
    procedure MobKilledInDungeon(mob: PBaseMob);
    procedure MobKilled(mob: PBaseMob; out DroppedExp: Boolean;
      out DroppedItem: Boolean; InParty: Boolean = False);
    procedure DropItemFor(PlayerBase: PBaseMob; mob: PBaseMob);
    procedure PlayerKilled(mob: PBaseMob; xRlkSlot: Byte = 0);
    { Parses }
    procedure SelfBuffSkill(Skill, Anim: DWORD; mob: PBaseMob; Pos: TPosition);
    procedure TargetBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
      DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
    procedure TargetSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure AreaBuff(Skill, Anim: DWORD; mob: PBaseMob;
      Packet: TRecvDamagePacket);
    procedure AreaSkill(Skill, Anim: DWORD; mob: PBaseMob; SkillPos: TPosition;
      DataSkill: P_SkillData; DamagePerc: Single = 0; ElThymos: Integer = 0);
    procedure AttackParse(Skill, Anim: DWORD; mob: PBaseMob; var Dano: Integer;
      var DmgType: TDamageType; out AddBuff: Boolean; out MobAnimation: Byte;
      DataSkill: P_SkillData);
    procedure AttackParseForMobs(Skill, Anim: DWORD; mob: PBaseMob; var Dano: Integer;
      var DmgType: TDamageType; out AddBuff: Boolean; out MobAnimation: Byte);
    procedure Effect5Skill(mob: PBaseMob; EffCount: Byte; xPassive: Boolean = False);
    function IsSecureArea(): Boolean;
    { Skill classes handle }
    procedure WarriorSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure TemplarSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure RiflemanSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure DualGunnerSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure MagicianSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure ClericSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure WarriorAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; out MoveToTarget: Boolean);
    procedure TemplarAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure RiflemanAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure DualGunnerAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure MagicianAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure ClericAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    { Effect Functions }
    procedure SendEffect(EffectIndex: DWORD);
    { Move/Teleport }
    procedure Teleport(Pos: TPosition); overload;
    procedure Teleport(Posx, Posy: WORD); overload;
    procedure Teleport(Posx, Posy: string); overload;
    procedure WalkTo(Pos: TPosition; speed: WORD = 70; MoveType: Byte = 0);
    procedure WalkAvanced(Pos: TPosition; SkillID: Integer);
    procedure WalkBacked(Pos: TPosition; SkillID: Integer; Mob: PBaseMob);
    { Pets }
    procedure CreatePet(PetType: TPetType; Pos: TPosition; SkillID: DWORD = 0);
    procedure DestroyPet(PetID: WORD);
    { Class }
    // class procedure ForEachInRange(Pos: TPosition; range: Byte;
    // proc: TProc<TPosition, TBaseMob>; ChannelId: Byte); overload; static;
    // procedure ForEachInRange(range: Byte;
    // proc: TProc<TPosition, TBaseMob, TBaseMob>); overload;
    const
       RefinementDivisors: array[1..15]
        of Single = (15, 14.5, 14, 13.5, 13, 12.5, 12, 11.5, 11, 10.5, 10, 9.5, 9, 8.5, 8);


       end;
{$REGION 'HP / MP Increment por level'}
const
  HPIncrementPerLevel: array [0 .. 5] of Integer = (150, // War
    140, // Tp
    115, // Att
    120, // Dual
    110, // Fc
    130 // Santa
    );
const
  MPIncrementPerLevel: array [0 .. 5] of Integer = (110, // War
    130, // Tp
    145, // Att
    150, // Dual
    330, // Fc
    135 // Santa
    );
{$ENDREGION}
{$OLDTYPELAYOUT OFF}
implementation
uses
  Player, GlobalDefs, Util, Log, ItemFunctions, Functions, DateUtils, mob, PET,
  PartyData, Objects, PacketHandlers;

 procedure TBaseMob.ActivatePvP;
var
  Packet: TSignalData;

// ativar o pk
begin
  Packet.Header.Size := SizeOf(TSignalData);
  Packet.Data := 1; // Ativar PvP

  // Se TBaseMob já representa o próprio Player
  Self.PlayerCharacter.PlayerKill := True;

  Self.SendToVisible(Packet, Packet.Header.Size);
  Self.SendClientMessage('Modo PvP ativado automaticamente para o evento Royale.');
end;


  function HasItemInInventory(Player: TBaseMob; ItemID: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to High(Player.Character.Inventory) do
  begin
    if Player.Character.Inventory[i].Index = ItemID then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TBaseMob.SendClientMessage(const Message: string; MsgType: Integer);
begin
  // Exemplo de lógica para envio de mensagens
  WriteLn(Format('Mensagem para jogador [%d]: %s (Tipo: %d)', [Self.ClientID, Message, MsgType]));
end;

procedure SaveStatusToDatabase(CharacterID: Integer; CharacterName: String; var Mob: TBaseMob);
var
  Query: TQuery;
begin
  // Criar a conexão com o banco de dados usando a classe TQuery
  //Query := TQuery.Create('localhost', 3306, 'root', 'Pt190912!@#', 'wars');

 { try
    // Definir a consulta SQL para inserir ou atualizar os status do personagem
    Query.SetQuery(
      'INSERT INTO PlayerStatus (CharacterID, CharacterName, DNFis, DNMAG, DEFFis, DEFMAG, BonusDMG, Critical, Esquiva, Acerto, DuploAtk, SpeedMove, Resistence, HabAtk, DamageCritical, ResDamageCritical, MagPenetration, FisPenetration, CureTax, CritRes, DuploRes, ReduceCooldown, PvPDamage, PvPDefense) ' +
      'VALUES (:CharacterID, :CharacterName, :DNFis, :DNMAG, :DEFFis, :DEFMAG, :BonusDMG, :Critical, :Esquiva, :Acerto, :DuploAtk, :SpeedMove, :Resistence, :HabAtk, :DamageCritical, :ResDamageCritical, :MagPenetration, :FisPenetration, :CureTax, :CritRes, :DuploRes, :ReduceCooldown, :PvPDamage, :PvPDefense) ' +
      'ON DUPLICATE KEY UPDATE ' +
      'CharacterName = :CharacterName, DNFis = :DNFis, DNMAG = :DNMAG, DEFFis = :DEFFis, DEFMAG = :DEFMAG, BonusDMG = :BonusDMG, Critical = :Critical, Esquiva = :Esquiva, Acerto = :Acerto, DuploAtk = :DuploAtk, SpeedMove = :SpeedMove, Resistence = :Resistence, HabAtk = :HabAtk, DamageCritical = :DamageCritical, ResDamageCritical = :ResDamageCritical, MagPenetration = :MagPenetration, FisPenetration = :FisPenetration, CureTax = :CureTax, CritRes = :CritRes, DuploRes = :DuploRes, ReduceCooldown = :ReduceCooldown, PvPDamage = :PvPDamage, PvPDefense = :PvPDefense'
    );

    // Usar Mob.Character^ para acessar os valores de status corretamente
    Query.AddParameter2('CharacterID', CharacterID);
    Query.AddParameter2('CharacterName', CharacterName);
   Query.AddParameter2('DNFis', mob.PlayerCharacter.Base.CurrentScore.DNFis); // Ajuste conforme a estrutura
   Query.AddParameter2('DNMAG', Mob.PlayerCharacter.Base.CurrentScore.DNMAG); // Ajuste conforme a estrutura
   Query.AddParameter2('DEFFis', mob.PlayerCharacter.Base.CurrentScore.DEFFis); // Ajuste conforme a estrutura
   Query.AddParameter2('DEFMAG', mob.PlayerCharacter.Base.CurrentScore.DEFMAG); // Ajuste conforme a estrutura
    Query.AddParameter2('BonusDMG', mob.PlayerCharacter.base .CurrentScore.BonusDMG);
    Query.AddParameter2('Critical', Mob.PlayerCharacter. Base .CurrentScore.Critical);
    Query.AddParameter2('Esquiva', Mob.PlayerCharacter.base.CurrentScore.Esquiva);
    Query.AddParameter2('Acerto', Mob.PlayerCharacter.Base.CurrentScore.Acerto);
    Query.AddParameter2('DuploAtk', Mob.PlayerCharacter.DuploAtk);
    Query.AddParameter2('SpeedMove', Mob.PlayerCharacter.SpeedMove);
    Query.AddParameter2('Resistence', Mob.PlayerCharacter.Resistence);
    Query.AddParameter2('HabAtk', Mob.PlayerCharacter.HabAtk);
    Query.AddParameter2('DamageCritical', Mob.PlayerCharacter.DamageCritical);
    Query.AddParameter2('ResDamageCritical', Mob.PlayerCharacter.ResDamageCritical);
    Query.AddParameter2('MagPenetration', Mob.PlayerCharacter.MagPenetration);
    Query.AddParameter2('FisPenetration', Mob.PlayerCharacter.FisPenetration);
    Query.AddParameter2('CureTax', Mob.PlayerCharacter.CureTax);
    Query.AddParameter2('CritRes', Mob.PlayerCharacter.CritRes);
    Query.AddParameter2('DuploRes', Mob.PlayerCharacter.DuploRes);
    Query.AddParameter2('ReduceCooldown', Mob.PlayerCharacter.ReduceCooldown);
    Query.AddParameter2('PvPDamage', Mob.PlayerCharacter.PvPDamage);
    Query.AddParameter2('PvPDefense', Mob.PlayerCharacter.PvPDefense);

    // Executar a consulta
    Query.Run(False);
  finally
    Query.Free; // Liberar o objeto para evitar vazamento de memória
  end; }
end;






  procedure LogItem(CharacterName: String; StatusLog: String);
var
  NomeDoLog: string;
  Arquivo: TextFile;
begin
  // Atualize o caminho para incluir a pasta 'info'
  NomeDoLog := GetCurrentDir + '\Logs\info\' + CharacterName + '_Loginfo.txt';

  if not DirectoryExists(GetCurrentDir + '\Logs\info') then
    ForceDirectories(GetCurrentDir + '\Logs\info');

  AssignFile(Arquivo, NomeDoLog);
  if FileExists(NomeDoLog) then
    Append(Arquivo)  // Se existir, adiciona linhas
  else
    ReWrite(Arquivo);  // Cria um novo se não existir

  try
    WriteLn(Arquivo, StatusLog);
    WriteLn(Arquivo, '-------------------------------------------------------------------------------');
  finally
    CloseFile(Arquivo);
  end;
end;

procedure LogInfo(CharacterName: String; StatusLog: String);
var
  NomeDoLog: string;
  Arquivo: TextFile;
  LogEntry: string;
begin
  // Caminho fixo para um único arquivo de log
  NomeDoLog := GetCurrentDir + '\Logs\macro\MacroDetectionLog.txt';

  // Criar a pasta de logs se não existir
  if not DirectoryExists(GetCurrentDir + '\Logs\macro') then
    ForceDirectories(GetCurrentDir + '\Logs\macro');

  // Abre o arquivo para adicionar logs
  AssignFile(Arquivo, NomeDoLog);
  if FileExists(NomeDoLog) then
    Append(Arquivo)  // Se já existe, adiciona novas entradas
  else
    ReWrite(Arquivo);  // Se não existe, cria um novo

  try
    // Formata a entrada do log com data e nome do jogador
    LogEntry := Format('[%s] - Player: %s - %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), CharacterName, StatusLog]);

    WriteLn(Arquivo, LogEntry);
    WriteLn(Arquivo, '-------------------------------------------------------------------------------');
  finally
    CloseFile(Arquivo);
  end;
end;




function IsMobInGroup(Mobid: Integer; MobGroup: array of Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := Low(MobGroup) to High(MobGroup) do
  begin
    if MobGroup[i] = Mobid then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

{$REGION 'TBaseMob'}
procedure TBaseMob.Destroy(Aux: Boolean);
begin
  Self.IsActive := Aux;
  FreeAndNil(VisibleMobs);
  FreeAndNil(VisibleNPCS);
  FreeAndNil(VisiblePlayers);
  FreeAndNil(_cooldown);
  FreeAndNil(_buffs);
  Servers[Self.ChannelId].Prans[Self.PranClientID] := 0;
  Self.ClearTargetList();
  //Self.Character := nil; //talvez essa seja a solu��o do back char list
  Self.target := nil;
  Self.IsBoss := False;
  ZeroMemory(@Self, sizeof(TBaseMob));
end;
procedure TBaseMob.Create(characterPointer: PCharacter; Index: WORD;
  ChannelId: Byte);
begin
  ZeroMemory(@Self, sizeof(TBaseMob));
  VisibleMobs := TList<WORD>.Create;
  VisibleNPCS := TList<WORD>.Create;
  VisiblePlayers := TList<WORD>.Create;
  SetLength(VisibleTargets, 1);
  LastTimeGarbaged := Now;
  LastAttackMsg := Now;
  LastBasicAttack := Now;
  AttackMsgCount := 0;
  AttacksAccumulated := 0;
  DroppedCount := 0;
  AttacksReceivedAccumulated := 0;
  IsActive := True;
  IsDirty := False;
  LastReceivedSkillFromCastle := Now;
  InClastleVerus := False;
  Character := characterPointer;
  ClientID := index;
  Self.ChannelId := ChannelId;
  RevivedTime := Now;
  LastSplashTime := Now;
  if ((index >= 2048) and (index <= 3047)) then
  begin
    Self.NpcIdGen := index - 2047;
  end;
  // _prediction.Create;
  _cooldown := TDictionary<WORD, TTime>.Create;
  _buffs := TDictionary<WORD, TDateTime>.Create(40);
end;
function TBaseMob.IsPlayer: Boolean;
begin
  Result := IfThen(ClientID <= MAX_CONNECTIONS);
end;
procedure TBaseMob.UpdateVisibleList(SpawnType: Byte = 0);
var
  i: WORD;
  npcMob: PBaseMob;
  Packet: TSendRemoveMobPacket;
  // cid: Integer;
  // Dificult: Byte;
  // InstanceiD: Byte;
  OtherPlayer: PPlayer;
  PacketDevirSpawn: TSendCreateMobPacket;
  PacketDevirMobsSpawn: TSpawnMobPacket;
  xObj: POBJ;
begin
  IsDirty := False;
  if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
    Exit;
  for i := Low(Servers[Self.ChannelId].Players)
    to High(Servers[Self.ChannelId].Players) do
  begin
    OtherPlayer := @Servers[Self.ChannelId].Players[i];
    if (OtherPlayer^.Status < Playing) then
    begin
      Continue;
    end;
    if (OtherPlayer^.Base.ClientID = Self.ClientID) then
      Continue;
    if (Self.PlayerCharacter.LastPos.InRange
      (OtherPlayer^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID)) then
        Continue;
      Self.AddToVisible(OtherPlayer^.Base);
      if (OtherPlayer^.Account.Header.Pran1.IsSpawned) then
      begin
        OtherPlayer^.SendPranSpawn(0, Self.ClientID, 0);
      end;
      if (OtherPlayer^.Account.Header.Pran2.IsSpawned) then
      begin
        OtherPlayer^.SendPranSpawn(1, Self.ClientID, 0);
      end;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran1.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn(0,
          OtherPlayer^.Base.ClientID, 0);
      end;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran2.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn(1,
          OtherPlayer^.Base.ClientID, 0);
      end;
    end
    else
    begin
      if not(Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID)) then
        Continue;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran1.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranUnspawn(0,
          OtherPlayer^.Base.ClientID);
      end;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran2.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranUnspawn(1,
          OtherPlayer^.Base.ClientID);
      end;
      if (OtherPlayer^.Account.Header.Pran1.IsSpawned) then
      begin
        OtherPlayer^.SendPranUnspawn(0, Self.ClientID);
      end;
      if (OtherPlayer^.Account.Header.Pran2.IsSpawned) then
      begin
        OtherPlayer^.SendPranUnspawn(1, Self.ClientID);
      end;
      Self.RemoveFromVisible(OtherPlayer^.Base);
      if (OtherPlayer^.Base.IsActive = False) then
      begin
        ZeroMemory(@Packet, sizeof(Packet));
        Packet.Header.size := sizeof(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := OtherPlayer^.Base.ClientID;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;
  end;
  if(Servers[Self.ChannelId].Players[Self.ClientID].IsInstantiated) then
    for i := Low(Servers[Self.ChannelId].NPCs)
      to High(Servers[Self.ChannelId].NPCs) do
    begin
      if (Servers[Self.ChannelId].NPCs[i].Base.ClientID = 0) then
        Continue;
      // cid := Servers[Self.ChannelId].NPCs[i].Base.ClientId;
      npcMob := @Servers[Self.ChannelId].NPCs[i].Base;
      if (Self.PlayerCharacter.LastPos.InRange(npcMob^.PlayerCharacter.LastPos,
        DISTANCE_TO_WATCH)) then
      begin
        if (Self.VisibleNPCS.Contains(npcMob^.ClientID)) then
          Continue;
        Self.VisibleNPCS.Add(npcMob^.ClientID);
        npcMob^.SendCreateMob(SPAWN_NORMAL, Self.ClientID, False);
      end
      else
      begin
        if not(Self.VisibleNPCS.Contains(npcMob^.ClientID)) then
          Continue;
        Self.VisibleNPCS.Remove(npcMob^.ClientID);
        ZeroMemory(@Packet, sizeof(Packet));
        Packet.Header.size := sizeof(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := npcMob^.ClientID;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;
  for i := Low(Servers[Self.ChannelId].DevirNPC)
    to High(Servers[Self.ChannelId].DevirNPC) do
  begin
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].DevirNPC[i]
      .PlayerChar.LastPos, (DISTANCE_TO_WATCH))) then
    begin
      if (Self.VisibleNPCS.Contains(i)) then
        Continue;
      Self.VisibleNPCS.Add(i);
      ZeroMemory(@PacketDevirSpawn, sizeof(TSendCreateMobPacket));
      PacketDevirSpawn.Header.size := sizeof(TSendCreateMobPacket);
      PacketDevirSpawn.Header.Index := i;
      PacketDevirSpawn.Header.Code := $349;
      Move(Servers[Self.ChannelId].DevirNPC[i].PlayerChar.Base.Name,
        PacketDevirSpawn.Name[0], 16);
      PacketDevirSpawn.Equip[0] := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.Equip[0].Index;
      PacketDevirSpawn.Position := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.LastPos;
      PacketDevirSpawn.MaxHP := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirSpawn.CurHP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.MaxMP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.CurMP := PacketDevirSpawn.MaxHP;
      if(Servers[Self.ChannelId].Devires[i-3335].IsOpen) then
      begin
        PacketDevirSpawn.ItemEff[0] := $35;
      end;
      PacketDevirSpawn.Altura := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirSpawn.Tronco := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirSpawn.Perna := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirSpawn.Corpo := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;
      PacketDevirSpawn.IsService := 1;
      PacketDevirSpawn.EffectType := $1;
      PacketDevirSpawn.IsService := 1;
      PacketDevirSpawn.Unk0 := $28;
      Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.size);

      if(PacketDevirSpawn.ItemEff[0] = $35) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendDevirChange(i, $1D);
      end;
    end
    else
    begin
      if not(Self.VisibleNPCS.Contains(i)) then
        Continue;
      Self.VisibleNPCS.Remove(i);
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
  for i := Low(Servers[Self.ChannelId].DevirGuards)
    to High(Servers[Self.ChannelId].DevirGuards) do
  begin
    if (Servers[Self.ChannelId].DevirGuards[i].Base.IsDead) then
      Continue;
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].DevirGuards
      [i].PlayerChar.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisibleNPCs.Contains(i)) then
        Continue;
      Self.VisibleNPCs.Add(i);
      Self.AddTargetToList(@Servers[Self.ChannelId].DevirGuards[i]
        .Base);
      ZeroMemory(@PacketDevirMobsSpawn, sizeof(TSpawnMobPacket));
      PacketDevirMobsSpawn.Header.size := sizeof(TSpawnMobPacket);
      PacketDevirMobsSpawn.Header.Index := i;
      PacketDevirMobsSpawn.Header.Code := $35E;
      PacketDevirMobsSpawn.Equip[0] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Equip[0].Index;
        PacketDevirMobsSpawn.Equip[2] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Equip[2].Index; // elmo
        PacketDevirMobsSpawn.Equip[3] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Equip[3].Index; // armadura
        PacketDevirMobsSpawn.Equip[4] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Equip[4].Index; // luva
        PacketDevirMobsSpawn.Equip[5] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Equip[5].Index;  // bota
      PacketDevirMobsSpawn.Equip[6] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Equip[6].Index;  // arma
        PacketDevirMobsSpawn.Equip[7] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Equip[7].Index; // escudo
      PacketDevirMobsSpawn.Position := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.LastPos;
      PacketDevirMobsSpawn.MaxHP := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirMobsSpawn.CurHP := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.CurHP;
      PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.Level :=
        (Servers[Self.ChannelId].DevirGuards[i].PlayerChar.Base.Level + 1) * 13;
      if(Self.Character <> nil) then
        if (Self.Character.Nation = Servers[Self.ChannelId].DevirGuards[i]
          .PlayerChar.Base.Nation) then
        begin // aqui o player � da na��o do guarda, n�o dispon�vel para atacar.
          PacketDevirMobsSpawn.IsService := True;
        end
        else
        begin // aqui � dispon�vel atacar
          PacketDevirMobsSpawn.IsService := False;
        end;
      PacketDevirMobsSpawn.Effects[0] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.DuploAtk;
      PacketDevirMobsSpawn.Altura := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirMobsSpawn.Tronco := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirMobsSpawn.Perna := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirMobsSpawn.Corpo := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;
      PacketDevirMobsSpawn.MobType := 0;
      PacketDevirMobsSpawn.MobName :=
        StrToInt(String(Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Name));
      Self.SendPacket(PacketDevirMobsSpawn, PacketDevirMobsSpawn.Header.size);
      // Servers[Self.ChannelId].DevirGuards[i].Base.SendCreateMob(SPAWN_NORMAL,
      // Self.ClientID, False);
    end
    else
    begin
      if not(Self.VisibleNPCs.Contains(i)) then
        Continue;
      Self.VisibleNPCs.Remove(i);
      Self.RemoveTargetFromList(@Servers[Self.ChannelId].DevirGuards[i]
        .Base);
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
  for i := Low(Servers[Self.ChannelId].DevirStones)
    to High(Servers[Self.ChannelId].DevirStones) do
  begin
    if (Servers[Self.ChannelId].DevirStones[i].Base.IsDead) then
      Continue;
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].DevirStones
      [i].PlayerChar.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisibleNPCs.Contains(i)) then
        Continue;
      Self.VisibleNPCs.Add(i);
      Self.AddTargetToList(@Servers[Self.ChannelId].DevirStones[i]
        .Base);
      ZeroMemory(@PacketDevirMobsSpawn, sizeof(TSpawnMobPacket));
      PacketDevirMobsSpawn.Header.size := sizeof(TSpawnMobPacket);
      PacketDevirMobsSpawn.Header.Index := i;
      PacketDevirMobsSpawn.Header.Code := $35E;
      PacketDevirMobsSpawn.Position := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.LastPos;
      PacketDevirMobsSpawn.Equip[0] := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.Equip[0].Index;
      PacketDevirMobsSpawn.MaxHP := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirMobsSpawn.CurHP := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.CurHP;
      PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.Level :=
        (Servers[Self.ChannelId].DevirStones[i].PlayerChar.Base.Level + 1) * 13;
      if(Self.Character <> nil) then
        if (Self.Character.Nation = Servers[Self.ChannelId].DevirStones[i]
          .PlayerChar.Base.Nation) then
        begin // aqui o player � da na��o do guarda, n�o dispon�vel para atacar.
          PacketDevirMobsSpawn.IsService := True;
        end
        else
        begin // aqui � dispon�vel atacar
          PacketDevirMobsSpawn.IsService := False;
        end;
      PacketDevirMobsSpawn.Effects[0] := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.DuploAtk;
      PacketDevirMobsSpawn.Altura := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirMobsSpawn.Tronco := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirMobsSpawn.Perna := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirMobsSpawn.Corpo := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;
      PacketDevirMobsSpawn.MobType := 1;
      PacketDevirMobsSpawn.MobName :=
        StrToInt(String(Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.Name));
      Self.SendPacket(PacketDevirMobsSpawn, PacketDevirMobsSpawn.Header.size);
      // Servers[Self.ChannelId].DevirStones[i].Base.SendCreateMob(SPAWN_NORMAL,
      // Self.ClientID, False);
    end
    else
    begin
      if not(Self.VisibleNPCs.Contains(i)) then
        Continue;
      Self.VisibleNPCs.Remove(i);
      Self.RemoveTargetFromList(@Servers[Self.ChannelId].DevirStones[i]
        .Base);
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
  {for I := Low(Servers[Self.Channelid].SecureAreas) to
    High(Servers[Self.Channelid].SecureAreas) do
  begin
    if(Servers[Self.Channelid].SecureAreas[i].IsActive) then
    begin
      if(Servers[Self.Channelid].SecureAreas[i].
      SecureClientiD = 0) then
        Continue;
      if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.Channelid].SecureAreas[i].Position, DISTANCE_TO_WATCH)) then
      begin
        if not(Self.VisibleNPCs.Contains(Servers[Self.Channelid].SecureAreas[i].
          SecureClientiD)) then
        begin
          Self.VisibleNPCs.Add(Servers[Self.Channelid].SecureAreas[i].
            SecureClientiD);
          ZeroMemory(@PacketDevirMobsSpawn, sizeof(TSpawnMobPacket));
          PacketDevirMobsSpawn.Header.Size := sizeof(TSpawnMobPacket);
          PacketDevirMobsSpawn.Header.index := Servers[Self.Channelid].SecureAreas[i].
            SecureClientiD;
          PacketDevirMobsSpawn.Header.Code := $35E;
          PacketDevirMobsSpawn.Equip[0] := Servers[Self.Channelid].SecureAreas[i].TotemFace;
          PacketDevirMobsSpawn.Position := Servers[Self.Channelid].SecureAreas[i].Position;
           PacketDevirMobsSpawn.MaxHP := 100000;
          PacketDevirMobsSpawn.CurHP := PacketDevirMobsSpawn.MaxHP;
          PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
          PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
          PacketDevirMobsSpawn.Level := 95;
          PacketDevirMobsSpawn.IsService := true;
          PacketDevirMobsSpawn.Effects[0] := $35;
          PacketDevirMobsSpawn.Altura := 10;
          PacketDevirMobsSpawn.Tronco := 119;
          PacketDevirMobsSpawn.Perna := 119;
          PacketDevirMobsSpawn.Corpo := 20;
          PacketDevirMobsSpawn.MobType := 4;
          PacketDevirMobsSpawn.MobName := StrToInt('942');
          Self.SendPacket(PacketDevirMobsSpawn, PacketDevirMobsSpawn.Header.Size);
        end;
      end
      else
      begin
        if (Self.VisibleNPCs.Contains(Servers[Self.Channelid].SecureAreas[i].
          SecureClientiD)) then
        begin
          Self.VisibleNPCs.Remove(Servers[Self.Channelid].SecureAreas[i].
          SecureClientiD);
          ZeroMemory(@Packet, sizeof(Packet));
          Packet.Header.size := sizeof(Packet);
          Packet.Header.Index := $7535;
          Packet.Header.Code := $101;
          Packet.Index := Servers[Self.Channelid].SecureAreas[i].
            SecureClientiD;
          Self.SendPacket(Packet, Packet.Header.size);
        end;
      end;
    end
    else
    begin
      if(Servers[Self.Channelid].SecureAreas[i].
      SecureClientiD = 0) then
        Continue;
      if (Self.VisibleNPCs.Contains(Servers[Self.Channelid].SecureAreas[i].
      SecureClientiD)) then
      begin
        Self.VisibleNPCs.Remove(Servers[Self.Channelid].SecureAreas[i].
          SecureClientiD);
        ZeroMemory(@Packet, sizeof(Packet));
        Packet.Header.size := sizeof(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := Servers[Self.Channelid].SecureAreas[i].
          SecureClientiD;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;
  end;
  }
  for I := Low(Servers[Self.ChannelId].OBJ) to High(Servers[Self.ChannelId].OBJ) do
  begin
    if not(Servers[Self.ChannelId].OBJ[i].Index = 0) then
    begin
      xObj := @Servers[Self.ChannelId].OBJ[i];
      if(xObj.Position.InRange(Self.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
      begin
        if not(Self.VisibleMobs.Contains(xObj.Index)) then
        begin
          Self.VisibleMobs.Add(xObj.Index);
          ZeroMemory(@PacketDevirSpawn, sizeof(TSendCreateMobPacket));
          PacketDevirSpawn.Header.size := sizeof(TSendCreateMobPacket);
          PacketDevirSpawn.Header.Index := i;
          PacketDevirSpawn.Header.Code := $349;
          System.AnsiStrings.StrPLCopy(PacketDevirSpawn.Name, IntToStr(xObj.NameID), sizeof(IntToStr(xObj.NameID)));
          PacketDevirSpawn.Equip[0] := xObj.Face;
          PacketDevirSpawn.Equip[6] := xObj.Weapon;
          PacketDevirSpawn.Position := xObj.Position;
          PacketDevirSpawn.MaxHP := 100000;
          PacketDevirSpawn.MaxMP := 100000;
          PacketDevirSpawn.CurHP := 100000;
          PacketDevirSpawn.CurMP := 100000;
          PacketDevirSpawn.Altura := 7;
          PacketDevirSpawn.Tronco := 119;
          PacketDevirSpawn.Perna := 119;
          PacketDevirSpawn.Corpo := 1;
          PacketDevirSpawn.IsService := 1;
          if(xObj.Face = 320) then
            System.AnsiStrings.StrPLCopy(PacketDevirSpawn.Title,
              ItemList[xObj.ContentItemID].Name, sizeof(PacketDevirSpawn.Title));
          Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.Size);
        end;
      end
      else
      begin
        if (Self.VisibleMobs.Contains(Servers[Self.ChannelId].OBJ[i].Index)) then
        begin
          Self.VisibleMobs.Remove(Servers[Self.ChannelId].OBJ[i].Index);
          ZeroMemory(@Packet, sizeof(Packet));
          Packet.Header.size := sizeof(Packet);
          Packet.Header.Index := $7535;
          Packet.Header.Code := $101;
          Packet.Index := i;
          Self.SendPacket(Packet, Packet.Header.Size);
        end;
      end;
    end;
  end;

  for i := Low(Servers[Self.ChannelId].CastleObjects)
    to High(Servers[Self.ChannelId].CastleObjects) do
  begin
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].CastleObjects[i]
      .PlayerChar.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisibleNPCS.Contains(i)) then
        Continue;

      Self.VisibleNPCS.Add(i);

      ZeroMemory(@PacketDevirSpawn, sizeof(TSendCreateMobPacket));

      PacketDevirSpawn.Header.size := sizeof(TSendCreateMobPacket);
      PacketDevirSpawn.Header.Index := i;
      PacketDevirSpawn.Header.Code := $349;

      Move(Servers[Self.ChannelId].CastleObjects[i].PlayerChar.Base.Name,
        PacketDevirSpawn.Name[0], 16);

      PacketDevirSpawn.Equip[0] := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.Equip[0].Index;

      PacketDevirSpawn.Position := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.LastPos;

      PacketDevirSpawn.MaxHP := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirSpawn.CurHP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.MaxMP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.CurMP := PacketDevirSpawn.MaxHP;

      PacketDevirSpawn.Altura := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirSpawn.Tronco := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirSpawn.Perna := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirSpawn.Corpo := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;

      PacketDevirSpawn.EffectType := $1;
      PacketDevirSpawn.IsService := 1;
      PacketDevirSpawn.Unk0 := $28;

      Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.size);
    end
    else
    begin
      if not(Self.VisibleNPCS.Contains(i)) then
        Continue;

      Self.VisibleNPCS.Remove(i);

      ZeroMemory(@Packet, sizeof(Packet));

      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;

      Packet.Index := i;

      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;

  // end
  // else
  // begin
  { if (Servers[Self.ChannelId].Players[Self.ClientId].Party.Members.Count > 1)
    then
    begin
    for i in Servers[Self.ChannelId].Players[Self.ClientId].Party.Members do
    begin
    if (i = Self.ClientId) then
    Continue;
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].Players
    [i].Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
    begin
    if (Self.VisiblePlayers.Contains(i)) then
    Continue;
    Self.AddToVisible(Servers[Self.ChannelId].Players[i].Base);
    if (Servers[Self.ChannelId].Players[i].Account.Header.Pran1.IsSpawned)
    then
    begin
    Servers[Self.ChannelId].Players[i].SendPranSpawn(0,
    Self.ClientId, 0);
    end;
    if (Servers[Self.ChannelId].Players[i].Account.Header.Pran2.IsSpawned)
    then
    begin
    Servers[Self.ChannelId].Players[i].SendPranSpawn(1,
    Self.ClientId, 0);
    end;
    if (Servers[Self.ChannelId].Players[Self.ClientId]
    .Account.Header.Pran1.IsSpawned) then
    begin
    Servers[Self.ChannelId].Players[Self.ClientId].SendPranSpawn
    (0, i, 0);
    end;
    if (Servers[Self.ChannelId].Players[Self.ClientId]
    .Account.Header.Pran2.IsSpawned) then
    begin
    Servers[Self.ChannelId].Players[Self.ClientId].SendPranSpawn
    (1, i, 0);
    end;
    end
    else
    begin
    if not(Self.VisiblePlayers.Contains(i)) then
    Continue;
    if (Servers[Self.ChannelId].Players[Self.ClientId]
    .Account.Header.Pran1.IsSpawned) then
    begin
    Servers[Self.ChannelId].Players[Self.ClientId]
    .SendPranUnspawn(0, i);
    end;
    if (Servers[Self.ChannelId].Players[Self.ClientId]
    .Account.Header.Pran2.IsSpawned) then
    begin
    Servers[Self.ChannelId].Players[Self.ClientId]
    .SendPranUnspawn(1, i);
    end;
    if (Servers[Self.ChannelId].Players[i].Account.Header.Pran1.IsSpawned)
    then
    begin
    Servers[Self.ChannelId].Players[i].SendPranUnspawn(0,
    Self.ClientId);
    end;
    if (Servers[Self.ChannelId].Players[i].Account.Header.Pran2.IsSpawned)
    then
    begin
    Servers[Self.ChannelId].Players[i].SendPranUnspawn(1,
    Self.ClientId);
    end;
    Self.RemoveFromVisible(Servers[Self.ChannelId].Players[i].Base);
    if (Servers[Self.ChannelId].Players[i].Base.IsActive = False) then
    begin
    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.size := sizeof(Packet);
    Packet.Header.Index := $7535;
    Packet.Header.Code := $101;
    Packet.Index := i;
    Self.SendPacket(Packet, Packet.Header.size);
    end;
    end;
    end;
    end;
    Dificult := Servers[Self.ChannelId].Players[Self.ClientId]
    .DungeonIDDificult;
    InstanceiD := Servers[Self.ChannelId].Players[Self.ClientId]
    .DungeonInstanceID;
    for i := Low(Servers[Self.ChannelId].DungeonInstances[InstanceiD].Mobs)
    to High(Servers[Self.ChannelId].DungeonInstances[InstanceiD].Mobs) do
    begin
    if(Servers[Self.ChannelId].DungeonInstances[InstanceiD].Mobs[i].IntName = 0) then
    Continue;
    Logger.Write('Self X: ' +
    Self.PlayerCharacter.LastPos.X.ToString, TLogType.Packets);
    Logger.Write('Self y: ' +
    Self.PlayerCharacter.LastPos.y.ToString, TLogType.Packets);
    Logger.Write('mob X: ' +
    Servers[Self.ChannelId]
    .DungeonInstances[InstanceiD].Mobs[i].Position.X.ToString, TLogType.Packets);
    Logger.Write('mob y: ' +
    Servers[Self.ChannelId]
    .DungeonInstances[InstanceiD].Mobs[i].Position.y.ToString, TLogType.Packets);
    Logger.Write(' ', TLogType.Packets);
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId]
    .DungeonInstances[InstanceiD].Mobs[i].Position, DISTANCE_TO_WATCH))
    then
    begin // spawnando o bicho de acordo com a posi��o
    if (Self.VisibleMobs.Contains(Servers[Self.ChannelId].DungeonInstances
    [InstanceiD].Mobs[i].Base.ClientId)) then
    Continue;
    Self.VisibleMobs.Add(Servers[Self.ChannelId].DungeonInstances
    [InstanceiD].Mobs[i].Base.ClientId);
    Servers[Self.ChannelId].Players[Self.ClientId].SendSpawnMobDungeon
    (@Servers[Self.ChannelId].DungeonInstances[InstanceiD].Mobs[i]);
    end
    else // se ele n�o ta perto, ta longe, verificar se tem na visiblemobs
    begin
    if not(Self.VisibleMobs.Contains(Servers[Self.ChannelId]
    .DungeonInstances[InstanceiD].Mobs[i].Base.ClientId)) then
    Continue;
    Self.VisibleMobs.Remove(Servers[Self.ChannelId].DungeonInstances
    [InstanceiD].Mobs[i].Base.ClientId);
    Servers[Self.ChannelId].Players[Self.ClientId].SendRemoveMobDungeon
    (@Servers[Self.ChannelId].DungeonInstances[InstanceiD].Mobs[i]);
    end;
    end;
    end;
  }
  {
    for i in VisibleMobs do
    begin
    if (i > MAX_CONNECTIONS) and (i < 3048) then
    begin
    npcMob := @Servers[Self.ChannelId].NPCs[i].Base;
    if (Self.PlayerCharacter.LastPos.InRange(npcMob.PlayerCharacter.LastPos,
    DISTANCE_TO_FORGET)) then
    begin
    Continue;
    end
    else
    begin
    Self.RemoveFromVisible(npcMob^);
    end;
    end
    else if (i <= MAX_CONNECTIONS) then
    begin
    OtherPlayer := @Servers[Self.ChannelId].Players[i];
    if (OtherPlayer.Status >= TPlayerStatus.Playing) then
    begin
    if (Self.PlayerCharacter.LastPos.InRange
    (OtherPlayer.Base.PlayerCharacter.LastPos, DISTANCE_TO_FORGET)) then
    begin
    Continue;
    end
    else
    begin
    Self.RemoveFromVisible(OtherPlayer.Base);
    end;
    end
    else
    begin
    //OtherPlayer.Base.SendRemoveMob(0, Self.ClientId, False);
    end;
    end;
    end; }
end;
procedure TBaseMob.AddToVisible(var mob: TBaseMob; SpawnType: Byte = 0);
begin
  if (Self.IsPlayer) then
  begin
    if not(VisiblePlayers.Contains(mob.ClientID)) then
    begin
      //if (Servers[Self.ChannelId].Players[Self.ClientID].IsInstantiated) then
      //begin
        VisiblePlayers.Add(mob.ClientID);
        mob.AddToVisible(Self);
        mob.SendCreateMob(SPAWN_NORMAL, Self.ClientID, False);
      //end;
      if not(Self.AddTargetToList(@mob)) then
      begin
        Logger.Write('Não foi possível adicionar alvo na lista de targets.',
          TLogType.Error);
      end;
    end;
  end
  else
  begin
    if (mob.IsPlayer) then
    begin
      VisiblePlayers.Add(mob.ClientID);
      if not(mob.VisiblePlayers.Contains(Self.ClientID)) then
      begin
        mob.VisiblePlayers.Add(Self.ClientID);
      end;
    end;
  end;
end;
procedure TBaseMob.RemoveFromVisible(mob: TBaseMob; SpawnType: Byte = 0);
begin
  try
    if ((mob.IsActive = False) or (mob.ClientID = 0)) then
      Exit;
    // if(mob.ClientID = 0) then
    // Exit;
    if (Self.IsActive = False) then
      Exit;
    VisiblePlayers.Remove(mob.ClientID);
    if (Self.IsPlayer) then
      mob.SendRemoveMob(0, Self.ClientID);
    if (mob.VisiblePlayers.Contains(Self.ClientID)) then
    begin
      mob.RemoveFromVisible(Self);
      mob.RemoveTargetFromList(@Self);
    end;
    Self.RemoveTargetFromList(@mob);
    if (target <> NIL) AND (target.ClientID = mob.ClientID) then
      target := NIL;
  except
    on E: Exception do
    begin
      Logger.Write('Error at removefromvisible: ' + E.Message, TLogType.Error);
    end;
  end;
end;
function TBaseMob.AddTargetToList(target: PBaseMob): Boolean;
var
  id, id2: WORD;
begin
  Result := False;
  try
    if not(ContainsTargetInList(target.ClientID, id2)) then
    begin
      VisibleTargetsCnt := Length(VisibleTargets) + 1;
      SetLength(VisibleTargets, VisibleTargetsCnt);
      //id := VisibleTargetsCnt;
      if (GetEmptyTargetInList(id)) then
      begin
        VisibleTargets[id].ClientID := target.ClientID;

         case target.ClientID of
            1..1000:
              begin
                VisibleTargets[id].Position := target.PlayerCharacter.LastPos;
                VisibleTargets[id].Player := target;
                VisibleTargets[id].TargetType := 0;
              end;
            1001..3339, 3370..9147:
              begin
                VisibleTargets[id].Position :=
                  Servers[Self.ChannelId].MOBS.TMobS[target.Mobid].MobsP[target.SecondIndex].Base.PlayerCharacter.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
            3340 .. 3354:
              begin
                VisibleTargets[id].Position := Servers[Self.ChannelId]
                  .DevirStones[target.ClientID].PlayerChar.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
            3355 .. 3369:
              begin
                VisibleTargets[id].Position := Servers[Self.ChannelId]
                  .DevirGuards[target.ClientID].PlayerChar.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
         end;
        Result := True;
      end
      else
      begin
        VisibleTargetsCnt := Length(VisibleTargets) + 1;
        SetLength(VisibleTargets, VisibleTargetsCnt);
        id := VisibleTargetsCnt-1;
        VisibleTargets[id].ClientID := target.ClientID;

         case target.ClientID of
            1..1000:
              begin
                VisibleTargets[id].Position := target.PlayerCharacter.LastPos;
                VisibleTargets[id].Player := target;
                VisibleTargets[id].TargetType := 0;
              end;
            1001..3339, 3370..9147:
              begin
                VisibleTargets[id].Position :=
                  Servers[Self.ChannelId].MOBS.TMobS[target.Mobid].MobsP[target.SecondIndex].Base.PlayerCharacter.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
            3340 .. 3354:
              begin
                VisibleTargets[id].Position := Servers[Self.ChannelId]
                  .DevirStones[target.ClientID].PlayerChar.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
            3355 .. 3369:
              begin
                VisibleTargets[id].Position := Servers[Self.ChannelId]
                  .DevirGuards[target.ClientID].PlayerChar.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
         end;
        Result := True;
      end;
    end
    else
    begin
      Result := True;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('AddTargetToList: ' + E.Message, TLogType.Error);
    end;
  end;
end;
function TBaseMob.RemoveTargetFromList(target: PBaseMob): Boolean;
var
  id: WORD;
begin
  Result := False;
  if (ContainsTargetInList(target, id)) then
  begin
    VisibleTargets[id].ClientID := 0;
    VisibleTargets[id].TargetType := 0;
    VisibleTargets[id].Position.x := 0;
    VisibleTargets[id].Position.y := 0;
    VisibleTargets[id].Player := nil;
    VisibleTargets[id].mob := nil;
    dec(VisibleTargetsCnt, 1);
    Result := True;
  end;
end;
function TBaseMob.ContainsTargetInList(target: PBaseMob; out id: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;

  if(Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    if (VisibleTargets[i].ClientID = target.ClientID) then
    begin
      id := i;
      Result := True;
      break;
    end;
  end;
end;
function TBaseMob.ContainsTargetInList(ClientID: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;

  if(Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    if (VisibleTargets[i].ClientID = ClientID) then
    begin
      Result := True;
      break;
    end;
  end;
end;
function TBaseMob.ContainsTargetInList(ClientID: WORD; out id: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;

  if(Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    if (VisibleTargets[i].ClientID = ClientID) then
    begin
      Result := True;
      id := i;
      break;
    end;
  end;
end;
function TBaseMob.GetEmptyTargetInList(out Index: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;
  if (Length(Self.VisibleTargets) > 0) then
  begin
    for i := Low(VisibleTargets) to High(VisibleTargets) do
    begin
      if (VisibleTargets[i].ClientID > 0) then
        Continue;

      Index := i;
      Result := True;
      break;
    end;
  end;

  {if(Result = False) then
  begin
    SetLength(VisibleTargets, Length(VisibleTargets) + 1);
    Index := High(VisibleTargets);
    Result := True;
  end;}
end;
function TBaseMob.GetTargetInList(ClientID: WORD): PBaseMob;
var
  i: WORD;
begin
  Result := nil;

  if(Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    if (VisibleTargets[i].ClientID = ClientID) then
    begin
      case VisibleTargets[i].TargetType of
        0:
          Result := PBaseMob(VisibleTargets[i].Player);
        1:
          Result := PBaseMob(VisibleTargets[i].mob);
      end;
      break;
    end;
  end;
end;
function TBaseMob.ClearTargetList(): Boolean;
var
  i: WORD;
begin
  Result := False;

  if(Length(VisibleTargets) = 0) then
  begin
    VisibleTargetsCnt := 0;

    Result := True;
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    VisibleTargets[i].ClientID := 0;
    VisibleTargets[i].TargetType := 0;
    VisibleTargets[i].Position.x := 0;
    VisibleTargets[i].Position.y := 0;
    VisibleTargets[i].Player := nil;
    VisibleTargets[i].mob := nil;
  end;
  SetLength(VisibleTargets, 0); //////
  VisibleTargetsCnt := 0;

  Result := True;
end;
function TBaseMob.TargetGarbageService(): Boolean;
var
  OtherList: Array of TMobTarget;
  i, cnt, cnt2, id, id2: WORD;
begin
  cnt := 0;
  Result := False;

  if(Length(VisibleTargets) = 0) then
  begin
    Result := True;
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    if(VisibleTargets[i].TargetType = 0) then
    begin
      if(VisibleTargets[i].Player = nil) then
        Continue;
      if ((VisibleTargets[i].ClientID > 0) and not(PBaseMob(VisibleTargets[i].Player).IsDead)) then
      begin
        Inc(cnt, 1);
        SetLength(OtherList, cnt);
        id := (cnt - 1);
        OtherList[id].ClientID := VisibleTargets[i].ClientID;
        OtherList[id].TargetType := VisibleTargets[i].TargetType;
        OtherList[id].Position := VisibleTargets[i].Position;
        OtherList[id].Player := VisibleTargets[i].Player;
        OtherList[id].mob := VisibleTargets[i].mob;
      end;
      VisibleTargets[i].ClientID := 0;
      VisibleTargets[i].TargetType := 0;
      VisibleTargets[i].Position.x := 0;
      VisibleTargets[i].Position.y := 0;
      VisibleTargets[i].Player := nil;
      VisibleTargets[i].mob := nil;
    end
    else if(VisibleTargets[i].TargetType = 1) then
    begin
      if(VisibleTargets[i].Mob = nil) then
        Continue;

      if ((VisibleTargets[i].ClientID > 0) and not(PBaseMob(VisibleTargets[i].Mob).IsDead)) then
      begin
        Inc(cnt, 1);
        SetLength(OtherList, cnt);
        id := (cnt - 1);
        OtherList[id].ClientID := VisibleTargets[i].ClientID;
        OtherList[id].TargetType := VisibleTargets[i].TargetType;

        case VisibleTargets[i].ClientID of
          2001..3339, 3370..9147:
            begin
              OtherList[id].Position :=
                Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(VisibleTargets[i].Mob).Mobid].MobsP[PBaseMob(VisibleTargets[i].Mob).SecondIndex].Base.PlayerCharacter.LastPos;
            end;
          3340 .. 3354:
            begin
              OtherList[id].Position := Servers[Self.ChannelId]
                .DevirStones[PBaseMob(VisibleTargets[i].Mob).ClientID].PlayerChar.LastPos;
            end;
          3355 .. 3369:
            begin
              OtherList[id].Position := Servers[Self.ChannelId]
                .DevirGuards[PBaseMob(VisibleTargets[i].Mob).ClientID].PlayerChar.LastPos;
            end;
        end;

        OtherList[id].Position := VisibleTargets[i].Position;
        OtherList[id].Player := VisibleTargets[i].Player;
        OtherList[id].mob := VisibleTargets[i].mob;
      end;
      VisibleTargets[i].ClientID := 0;
      VisibleTargets[i].TargetType := 0;
      VisibleTargets[i].Position.x := 0;
      VisibleTargets[i].Position.y := 0;
      VisibleTargets[i].Player := nil;
      VisibleTargets[i].mob := nil;
    end;
  end;
  SetLength(VisibleTargets, 0); ////////////////
  VisibleTargetsCnt := 0;
  cnt2 := 0;
  if (cnt > 0) then
  begin
    for i := 0 to Length(OtherList)-1 do
    begin
      Inc(cnt2, 1);
      SetLength(VisibleTargets, cnt2);
      //id2 := Length(VisibleTargets);
      id2 := (cnt2 - 1);
      VisibleTargets[id2].ClientID := OtherList[i].ClientID;
      VisibleTargets[id2].TargetType := OtherList[i].TargetType;
      VisibleTargets[id2].Position := OtherList[i].Position;
      VisibleTargets[id2].Player := OtherList[i].Player;
      VisibleTargets[id2].mob := OtherList[i].mob;
    end;
    Result := True;
  end;
end;

  function TBaseMob.CurrentPosition: TPosition;
  var
  Delta: Single;
    begin
        if not _currentPosition.IsValid then
        _currentPosition := PlayerCharacter.LastPos;
        if not(_prediction.CanPredict) then
     begin
        Result := _currentPosition;
        Exit;
      end;
        Result := _prediction.Interpolate(Delta);
        { // if not TFunctions.UpdateWorld(ClientId, Result, WORLD_MOB) then
        // begin
        // Result := _currentPosition;
        // exit;
        // end;
        // if Character.Last.Distance(_currentPosition) > 4 then
        // IsDirty := true; }
       Result := PlayerCharacter.LastPos;
        _currentPosition := Result;
     end;
procedure TBaseMob.SetDestination(const Destination: TPosition);
begin
  _prediction.Source := PlayerCharacter.LastPos;
  if (_prediction.Source = Destination) then
    Exit;
  _prediction.Timer.Stop;
  _prediction.Timer.Reset;
  _prediction.Timer.Start;
  _prediction.Destination := Destination;
  _prediction.CalcETA(PlayerCharacter.SpeedMove);
end;
procedure TBaseMob.addvisible(m: TBaseMob);
begin
  Self.AddToVisible(m);
end;
procedure TBaseMob.removevisible(m: TBaseMob);
begin
  Self.RemoveFromVisible(m);
end;
procedure TBaseMob.AddHP(Value: Integer; ShowUpdate: Boolean);
var
  DanoConvertido: Integer;


begin
  // Se tiver o buff 88 ativo, converte cura em dano
  if Self.BuffExistsByIndex(88) then
  begin
    DanoConvertido := Value * 2;

    // Aplica o dano
    Self.RemoveHP(DanoConvertido, ShowUpdate, True);

    // Incrementa o contador
    Inc(Self.NegarCuraCount);

    // Mensagem opcional para feedback visual
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
      Format('Cura revertida! Você sofreu %d de dano.', [DanoConvertido]), 16, 0, 0);

    // Verifica se já aplicou 3 vezes
    if Self.NegarCuraCount>= 3 then
    begin
      Self.RemoveBuffByIndex(88); // Remove o buff
      Self.NegarCuraCount := 0;     // Reseta o contador

      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
        'O buff "88" foi removido após 3 reversões de cura.', 16, 0, 0);
    end;

    Exit;
  end;

  // Caso contrário, aplica a cura normalmente
  Self.Character.CurrentScore.CurHP := Self.Character.CurrentScore.CurHP + Value;

  // Limita ao HP máximo
  if Self.Character.CurrentScore.CurHP > Self.Character.CurrentScore.MaxHP then
    Self.Character.CurrentScore.CurHP := Self.Character.CurrentScore.MaxHP;

  // Atualiza visualmente
  if ShowUpdate then
    Self.SendCurrentHPMP(True);
end;
procedure TBaseMob.AddMP(Value: Integer; ShowUpdate: Boolean);
begin
  if (Self.ClientID >= 3048) then
    Exit;
  Inc(Self.Character.CurrentScore.CurMP, Value);
  Self.SendCurrentHPMP(ShowUpdate);
end;
procedure TBaseMob.RemoveHP(Value: Integer; ShowUpdate: Boolean; StayOneHP: Boolean);
var
  Packet: TSendCurrentHPMPPacket;
begin

  if (Self.ClientID >= 3048) then
  begin
    //if not(Self.Mobid > 0) then
      //Exit;

    deccardinal(Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP, Value);
    {if(StayOneHP) then
    begin
      if(Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP = 0) then
        Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP := 1;
    end; }
    ZeroMemory(@Packet, sizeof(TSendCurrentHPMPPacket));
    Packet.Header.size := sizeof(TSendCurrentHPMPPacket);
    Packet.Header.Code := $103; // AIKA
    Packet.Header.Index := Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].Index;
    if(ShowUpdate) then
      Packet.Null := 1;
    Packet.MaxHP := Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].InitHP;
    Packet.MaxMP := Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].InitHP;
    Packet.CurHP := Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP;
    Packet.CurMP := Packet.MaxMP;

    Self.SendToVisible(Packet, Packet.Header.Size, False);
    {if(Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].AttackerID > 0) then
    begin
      Servers[Self.ChannelId].Players[Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
        [Self.SecondIndex].AttackerID].Base.SendToVisible(Packet, Packet.Header.Size);
    end
    else
      Self.SendToVisible(Packet, Packet.Header.Size, False);}
    Exit;
  end;
  deccardinal(Self.Character.CurrentScore.CurHP, Value);

  if(Self.Character.CurrentScore.CurHP <=
    Trunc((Self.Character.CurrentScore.MaxHp / 100 ) * 50)) then
  begin
    Self.RemoveBuffByIndex(108);
  end;

  if(StayOneHP) then
  begin
    if(Self.Character.CurrentScore.CurHP = 0) then
      Self.Character.CurrentScore.CurHP := 0;
  end;
  // mod dia 30/04/2021
  Self.SendCurrentHPMP(ShowUpdate);

  if (Self.BuffExistsByIndex(134)) then
    if (Self.Character.CurrentScore.CurHP <
      (Self.Character.CurrentScore.MaxHP div 2)) then
    begin
      //Helper := mob.GetBuffIDByIndex(134);
      //mob.AddHP(mob.CalcCure2(SkillData[Helper].EFV[0], mob, Helper), True);
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('Cura preventiva entrou em açãoo e feitiço foi desfeito.', 0);
      Self.RemoveBuffByIndex(134);
    end;

  if(Self.Character.CurrentScore.CurHP = 0) then
  begin
    //Self.Character.CurrentScore.CurHP := 0;
    Self.SendCurrentHPMP();
    Self.SendEffect($0);
    Exit;
  end;
end;
procedure TBaseMob.RemoveMP(Value: Integer; ShowUpdate: Boolean);
begin
  if (Self.ClientID >= 3048) then
    Exit;
  deccardinal(Self.Character.CurrentScore.CurMP, Value);
  Self.SendCurrentHPMP(ShowUpdate);
end;
procedure TBaseMob.WalkinTo(Pos: TPosition);
{ var
  Dist, h: Integer;
  i: Integer;
  nx, ny: Single; }
begin
  Self.WalkTo(Pos, 70);
  // Dist := Self.PlayerCharacter.LastPos.Distance(Pos);
  // h := Round(Dist div 4);
  // if (h < 1) then
  // h := 1;
  { if (Self.PlayerCharacter.LastPos.X > Pos.X) and
    (Self.PlayerCharacter.LastPos.Y > Pos.Y) then
    begin
    for i := 1 to h do
    begin
    if (Self.PlayerCharacter.LastPos.X - 4) <= Pos.X then
    nx := Pos.X
    else
    nx := Self.PlayerCharacter.LastPos.X - 4;
    if (Self.PlayerCharacter.LastPos.Y - 4) <= Pos.Y then
    ny := Pos.Y
    else
    ny := Self.PlayerCharacter.LastPos.Y - 4;
    Self.WalkTo(TPosition.Create(nx, ny), 100);
    end;
    end;
    if (Self.PlayerCharacter.LastPos.X < Pos.X) and
    (Self.PlayerCharacter.LastPos.Y < Pos.Y) then
    begin
    for i := 1 to h do
    begin
    if (Self.PlayerCharacter.LastPos.X + 4) >= Pos.X then
    nx := Pos.X
    else
    nx := Self.PlayerCharacter.LastPos.X + 4;
    if (Self.PlayerCharacter.LastPos.Y + 4) >= Pos.Y then
    ny := Pos.Y
    else
    ny := Self.PlayerCharacter.LastPos.Y + 4;
    Self.WalkTo(TPosition.Create(nx, ny), 100);
    end;
    end;
    if (Self.PlayerCharacter.LastPos.X > Pos.X) and
    (Self.PlayerCharacter.LastPos.Y < Pos.Y) then
    begin
    for i := 1 to h do
    begin
    if (Self.PlayerCharacter.LastPos.X - 4) <= Pos.X then
    nx := Pos.X
    else
    nx := Self.PlayerCharacter.LastPos.X - 4;
    if (Self.PlayerCharacter.LastPos.Y + 4) >= Pos.Y then
    ny := Pos.Y
    else
    ny := Self.PlayerCharacter.LastPos.Y + 4;
    Self.WalkTo(TPosition.Create(nx, ny), 100);
    end;
    end;
    if (Self.PlayerCharacter.LastPos.X < Pos.X) and
    (Self.PlayerCharacter.LastPos.Y > Pos.Y) then
    begin
    for i := 1 to h do
    begin
    if (Self.PlayerCharacter.LastPos.X + 4) >= Pos.X then
    nx := Pos.X
    else
    nx := Self.PlayerCharacter.LastPos.X + 4;
    if (Self.PlayerCharacter.LastPos.Y - 4) <= Pos.Y then
    ny := Pos.Y
    else
    ny := Self.PlayerCharacter.LastPos.Y - 4;
    Self.WalkTo(TPosition.Create(nx, ny), 100);
    end;
    end; }
end;
procedure TBaseMob.SetEquipEffect(const Equip: TItem; SetType: Integer;
  ChangeConjunt: Boolean = True; VerifyExpired: Boolean = True);
var
  i, ResultOf, EmptySlot: Integer;
begin
  if(ItemList[Equip.Index].ItemType = 10) then
    Exit;

  if(VerifyExpired) then
  begin
    if ((ItemList[Equip.Index].Expires) and not(Equip.IsSealed)) then
    begin
      ResultOf := CompareDateTime(Now, Equip.ExpireDate);
      //se o item est� expirado (roupa pran ou montaria)
      if (ResultOf = 1) then
      begin
        Exit;
      end
      else if((Equip.Time = $FFFF) and (TItemFunctions.GetItemEquipSlot(Equip.Index) = 9)) then
        Exit;
    end;
  end;

  if (Conjuntos[Equip.Index] > 0) and (ChangeConjunt) then
    SetConjuntEffect(Equip.Index, SetType);
  case SetType of
    EQUIPING_TYPE:
      begin
        for i := 0 to 2 do
        begin
          if Equip.Effects.Index[i] > 0 then
            Inc(Self.MOB_EF[Equip.Effects.Index[i]],
              Equip.Effects.Value[i] * 2);
          if ItemList[Equip.Index].EF[i] > 0 then
            Inc(Self.MOB_EF[ItemList[Equip.Index].EF[i]],
              ItemList[Equip.Index].EFV[i]);


          {if (ItemList[Equip.Index].HP > 0) then
          begin
            Inc(Self.MOB_EF[EF_HP],ItemList[Equip.Index].HP);
          end;
          if (ItemList[Equip.Index].MP > 0) then
          begin
            Inc(Self.MOB_EF[EF_MP],ItemList[Equip.Index].MP);
          end;}
        end;

        if(ItemList[Equip.Index].ItemType = 8) then
        begin
          EmptySlot := SearchEmptyEffect5Slot();
          if not(EmptySlot = 255) then
            Self.EFF_5[EmptySlot] := ItemList[Equip.Index].MeshIDEquip;
        end;
      end;
    DESEQUIPING_TYPE:
      begin
        for i := 0 to 2 do
        begin
          if Equip.Effects.Index[i] > 0 then
            dec(Self.MOB_EF[Equip.Effects.Index[i]],
              Equip.Effects.Value[i] * 2);
          if ItemList[Equip.Index].EF[i] > 0 then
            dec(Self.MOB_EF[ItemList[Equip.Index].EF[i]],
              ItemList[Equip.Index].EFV[i]);


          {if (ItemList[Equip.Index].HP > 0) then
          begin
            Dec(Self.MOB_EF[EF_HP],ItemList[Equip.Index].HP);
          end;
          if (ItemList[Equip.Index].MP > 0) then
          begin
            Dec(Self.MOB_EF[EF_MP],ItemList[Equip.Index].MP);
          end;}
        end;

        if(ItemList[Equip.Index].ItemType = 8) then
        begin
          EmptySlot := GetSlotOfEffect5(ItemList[Equip.Index].MeshIDEquip);
          if not(EmptySlot = 255) then
            Self.EFF_5[EmptySlot] := 0;
        end;
      end;
    SAME_ITEM_TYPE:
      begin
        // Alterar apenas os atributos de acordo com o refine;
      end;
  end;
end;
procedure TBaseMob.SetConjuntEffect(Index: Integer; SetType: Integer);
var
  CfgEffect: Integer;
begin
  if Index = 0 then
    Exit;
  Self.EQUIP_CONJUNT[TItemFunctions.GetItemEquipSlot(Index)] :=
    Conjuntos[Index];
  CfgEffect := TItemFunctions.GetConjuntCount(Self, Index);
  case CfgEffect of
    3:
      ConfigEffect(3, Conjuntos[Index], SetType);
    4:
      ConfigEffect(4, Conjuntos[Index], SetType);
    5:
      ConfigEffect(5, Conjuntos[Index], SetType);
    6:
      ConfigEffect(6, Conjuntos[Index], SetType);
  end;
  if SetType = DESEQUIPING_TYPE then
    Self.EQUIP_CONJUNT[TItemFunctions.GetItemEquipSlot(Index)] := 0;
end;
procedure TBaseMob.ConfigEffect(Count: Integer; ConjuntId: Integer;
  SetType: Integer);
var
  i: Integer;
  EmptySlot: Byte;
  Dano : Integer;
begin
  EmptySlot := 255;
  case SetType of
    EQUIPING_TYPE:
      begin
        for i := 0 to 5 do
        begin
          if SetItem[ConjuntId].EffSlot[i] <> Count then
            Continue;
          Inc(Self.MOB_EF[SetItem[ConjuntId].EF[i]], SetItem[ConjuntId].EFV[i]);
          if (SetItem[ConjuntId].EF[i] = EF_CALLSKILL) then
          begin // se for eff_5
            EmptySlot := SearchEmptyEffect5Slot();
            if (EmptySlot = 255) then
              Continue;
            Self.EFF_5[EmptySlot] := SetItem[ConjuntId].EFV[i];


          end;
        end;
      end;
    DESEQUIPING_TYPE:
      begin
        for i := 0 to 5 do
        begin
          if SetItem[ConjuntId].EffSlot[i] <> Count then
            Continue;
          dec(Self.MOB_EF[SetItem[ConjuntId].EF[i]], SetItem[ConjuntId].EFV[i]);
          if (SetItem[ConjuntId].EF[i] = EF_CALLSKILL) then
          begin // se for eff_5
            EmptySlot := GetSlotOfEffect5(SetItem[ConjuntId].EFV[i]);
            if (EmptySlot = 255) then
              Continue;
            Self.EFF_5[EmptySlot] := 0;
          end;
        end;
      end;
  end;
  Dano := Dano + 40000;  // dobra o dano final
end;

procedure TBaseMob.SetOnTitleActiveEffect();
var
  i: Integer;
begin
  if(Self.PlayerCharacter.ActiveTitle.Index > 0) then
  begin
    for I := 0 to 2 do
    begin
      if(Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EF[i] = 0) then
          Continue;

      Self.IncreasseMobAbility(Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EF[i],
        Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EFV[i]);
    end;
  end;
end;

procedure TBaseMob.SetOffTitleActiveEffect();
var
  i: Integer;
begin
  if(Self.PlayerCharacter.ActiveTitle.Index > 0) then
  begin
    for I := 0 to 2 do
    begin
      if(Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EF[i] = 0) then
          Continue;

      Self.DecreasseMobAbility(Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EF[i],
        Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EFV[i]);
    end;
  end;
end;
function TBaseMob.MatchClassInfo(ClassInfo: Byte): Boolean;
begin
  Result := (Self.GetMobClass = Self.GetMobClass(ClassInfo));
end;
function TBaseMob.IsCompleteEffect5(out CountEffects: Byte): Boolean;
var
  i: Byte;
begin
  Result := False;
  for i := 0 to 2 do
  begin
    if (EFF_5[i] > 0) then
    begin
      Inc(CountEffects);
      Result := True;
    end;
  end;
   if (Self.GetMobAbility(EF_CALLSKILL) > 0) then
   begin
   Result := True;
  end;
end;
function TBaseMob.SearchEmptyEffect5Slot(): Byte;
var
  i: Byte;
begin
  Result := 255;
  for i := 0 to 2 do
  begin
    if (Self.EFF_5[i] = 0) then
    begin
      Result := i;
      break;
    end;
  end;
end;
function TBaseMob.GetSlotOfEffect5(CallID: WORD): Byte;
var
  i: Byte;
begin
  Result := 255;
  for i := 0 to 2 do
  begin
    if (Self.EFF_5[i] = CallID) then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TBaseMob.LureMobsInRange;
var
  i: integer;
begin
  for I := Low(Self.VisibleTargets) to High(Self.VisibleTargets) do
  begin
    if(Self.VisibleTargets[i].TargetType = 1) then
    begin
      if(Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
        PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].CurrentPos.Distance(
          Self.PlayerCharacter.LastPos) <= 8) then
      begin
        if (not(Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
        PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].isGuard) and not(
        Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
        PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].isMutant)) then
        begin
          if not(AnsiPos('Max', String(Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].Name)) > 0) then
          begin
            if not(Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
            PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].IsAttacked) then
            begin
              Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
              PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].IsAttacked := True;
              Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
              PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].AttackerID := Self.ClientID;
              Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
              PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].FirstPlayerAttacker := Self.ClientID;
            end;
          end;
        end;
      end;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Sends'}
procedure TBaseMob.SendToVisible(var Packet; size: WORD; sendToSelf: Boolean);
var
  i: WORD;
  xPlayer: PPlayer;
begin
  sendToSelf := IfThen(sendToSelf, IsPlayer, False);
  if (sendToSelf) then
    Self.SendPacket(Packet, size);
  if (Self.ClientID <= 3048) then
  begin
    for i in VisiblePlayers do
    begin
      try
        xPlayer := @Servers[Self.ChannelId].Players[i];
        if (xPlayer.Status >= Playing) then
          xPlayer.SendPacket(Packet, size);
      except
        Continue;
      end;
    end;
  end
  else
  begin
    for i in VisibleMobs do
    begin
      try
        if (i > MAX_CONNECTIONS) then
          Continue; // new
        xPlayer := @Servers[Self.ChannelId].Players[i];
        if (xPlayer.Status >= Playing) then
          xPlayer.SendPacket(Packet, size);
      except
        continue;
      end;
    end;
  end;
end;
procedure TBaseMob.SendPacket(var Packet; size: WORD);
begin
  Servers[ChannelId].SendPacketTo(ClientID, Packet, size);
end;
procedure TBaseMob.SendCreateMob(SpawnType: WORD = 0; sendTo: WORD = 0;
  SendSelf: Boolean = True; Polimorf: WORD = 0);
var
  Packet: TSendCreateMobPacket;
  Packet2: TSpawnMobPacket;
  PacketAct: TSendActionPacket;
  RlkSlot: Byte;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));

  if (Polimorf > 0) then
  begin
    //Self.SendRemoveMob(0, 0, False);

    ZeroMemory(@Packet2, sizeof(Packet2));

    Packet2.Header.Size := sizeof(Packet2);
    Packet2.Header.Code := $35E;
    Packet2.Header.Index := Self.ClientID;

    Packet2.Position := Self.PlayerCharacter.LastPos;
    Packet2.Rotation := Self.PlayerCharacter.Rotation;
    Packet2.CurHP := Self.Character.CurrentScore.CurHP;
    Packet2.CurMP := Self.Character.CurrentScore.CurMP;
    Packet2.MaxHP := Self.Character.CurrentScore.MaxHp;
    Packet2.MaxMP := Self.Character.CurrentScore.MaxMp;

    Packet2.Level := Self.Character.Level;
    Packet2.SpawnType := 0;

    //Packet2.Unk_0 := $0A;

    Packet2.Equip[0] := Polimorf;
    Packet2.Equip[1] := Polimorf;
    Packet2.Equip[6] := 0;
    Packet2.Equip[7] := 0;
    Packet2.Altura := 8;
    Packet2.Tronco := 119;
    Packet2.Perna := 119;
    Packet2.Corpo := 0;
    Packet2.IsService := False;
    Packet2.MobType := 1;
    Packet2.Nation := Self.Character.Nation;
    Packet2.MobName := Self.clientid;

   // Packet2.MobName := Self.ClientID;

    if (sendTo > 0) then
      Servers[Self.ChannelId].SendPacketTo(sendTo, Packet2, Packet2.Header.size)
    else
    begin
      Self.SendPacket(Packet2, Packet2.Header.Size);

      for i in Self.VisiblePlayers do
      begin
        if(Servers[Self.ChannelId].Players[i].Base.Character.Nation =
          Self.Character.Nation) then
        begin
          Packet2.Nation := 0;
        end
        else
        begin
          Packet2.Nation := Self.Character.Nation;
        end;

        Servers[Self.ChannelId].Players[i].SendPacket(Packet2, Packet2.Header.Size);
      end;

      //Self.SendToVisible(Packet2, Packet2.Header.size, SendSelf);
    end;
  end
  else
  begin
    if (Self.PlayerCharacter.PlayerKill) then
      Inc(SpawnType, $80);

    Self.GetCreateMob(Packet, sendTo);
    Packet.SpawnType := SpawnType;

    if(Self.InClastleVerus) then
    begin
      Packet.GuildIndexAndNation := Self.NationForCastle * 4096;
    end;

    if (sendTo > 0) then
      Servers[Self.ChannelId].SendPacketTo(sendTo, Packet, Packet.Header.size)
    else
      Self.SendToVisible(Packet, Packet.Header.size, SendSelf);

    if(Self.ClientID <= MAX_CONNECTIONS) then
    begin
      RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID],
        40, INV_TYPE, 0);
      if(RlkSlot <> 255) then
      begin
        Self.SendEffect(32);
      end;
    end;

    if((Self.CurrentAction <> 0) and (sendTo > 0)) then
    begin
      ZeroMemory(@PacketAct, sizeof(PacketAct));

      PacketAct.Header.size := sizeof(PacketAct);
      PacketAct.Header.Index := Self.ClientID;
      PacketAct.Header.Code := $304;

      PacketAct.Index := Self.CurrentAction;
      PacketAct.InLoop := 1;

      Servers[Self.ChannelId].SendPacketTo(SendTo, PacketAct, PacketAct.Header.size);
    end
    else if(Servers[Self.ChannelId].Players[sendTo].Base.CurrentAction <> 0) then
    begin
      ZeroMemory(@PacketAct, sizeof(PacketAct));

      PacketAct.Header.size := sizeof(PacketAct);
      PacketAct.Header.Index := SendTo;
      PacketAct.Header.Code := $304;

      PacketAct.Index := Servers[Self.ChannelId].Players[sendTo].Base.CurrentAction;
      if(Servers[Self.ChannelId].Players[sendTo].Base.CurrentAction = 65) then
        PacketAct.InLoop := 1;

      Self.SendPacket(PacketAct, PacketAct.Header.size);
    end;
  end;

  {if (Polimorf > 0) then
  begin
    Self.SendCurrentHPMP(True);
  end;}

end;
procedure TBaseMob.SendRemoveMob(delType: Integer = DELETE_NORMAL;
  sendTo: WORD = 0; SendSelf: Boolean = True);
var
  Packet: TSendRemoveMobPacket;
  mob: TBaseMob;
  i: WORD;
begin
  Packet.Header.size := sizeof(TSendRemoveMobPacket);
  Packet.Header.Code := $101; // aika
  Packet.Header.Index := $7535;
  Packet.Index := Self.ClientID;
  Packet.DeleteType := delType;
  if (SendSelf) and (Self.IsPlayer) then
  begin
    Self.SendPacket(Packet, Packet.Header.size);
  end;
  if (sendTo = 0) then
  begin
    SendToVisible(Packet, Packet.Header.size, SendSelf);
  end
  else
  begin
    Servers[ChannelId].SendPacketTo(sendTo, Packet, Packet.Header.size);
    Exit;
  end;
  for i in VisiblePlayers do
  begin
    if (GetMob(i, ChannelId, mob)) then
      RemoveFromVisible(mob);
  end;
  VisiblePlayers.Clear;
end;
procedure TBaseMob.SendRefreshLevel;
var
  Packet: TSendCurrentLevel;
begin
  if (Self.ClientID >= 3048) then
    Exit;
  ZeroMemory(@Packet, sizeof(TSendCurrentLevel));
  Packet.Header.size := sizeof(TSendCurrentLevel);
  Packet.Header.Code := $108; // AIKA
  Packet.Header.Index := ClientID;
  Packet.Level := Character.Level - 1;
  Packet.Unk := $CC;
  Packet.Exp := Character.Exp;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TBaseMob.SendCurrentHPMP(Update: Boolean);
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  ZeroMemory(@Packet, sizeof(TSendCurrentHPMPPacket));
  Packet.Header.size := sizeof(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103; // AIKA
  Packet.Header.Index := ClientID;
  Character.CurrentScore.MaxHP := Self.GetCurrentHP;
  Character.CurrentScore.MaxMP := Self.GetCurrentMP;

  if Character.CurrentScore.CurHP > Character.CurrentScore.MaxHP then
    Character.CurrentScore.CurHP := Character.CurrentScore.MaxHP;

  if Character.CurrentScore.CurMP > Character.CurrentScore.MaxMP then
    Character.CurrentScore.CurMP := Character.CurrentScore.MaxMP;

  Packet.CurHP := Character.CurrentScore.CurHP;
  Packet.MaxHP := Character.CurrentScore.MaxHP;
  Packet.CurMP := Character.CurrentScore.CurMP;
  Packet.MaxMP := Character.CurrentScore.MaxMP;

  if (Update) then
    Packet.Null := 1;
  SendToVisible(Packet, Packet.Header.size);
  Sleep(1);
end;
procedure TBaseMob.SendCurrentHPMPMob();
var
  Packet: TSendCurrentHPMPPacket;
begin
  if(Self.IsDungeonMob) then
    Exit;

  if(Self.Mobid = 0) then
    Exit;

  ZeroMemory(@Packet, sizeof(TSendCurrentHPMPPacket));

  Packet.Header.size := sizeof(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103; // AIKA
  Packet.Header.Index := ClientID;

  Packet.CurHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP;
  Packet.MaxHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;
  Packet.CurMP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP;
  Packet.MaxMP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;

  SendToVisible(Packet, Packet.Header.size);
end;
procedure TBaseMob.SendStatus;
var
  Packet: TSendRefreshStatus;
  temp_buff: Array [0..12] of Byte;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  // Self.GetCurrentScore;
  ZeroMemory(@Packet, $2C);
  Packet.Header.size := $2C;
  Packet.Header.Code := $10A; // AIKA
  Packet.Header.Index := $7535;
  Packet.DNFis := PlayerCharacter.Base.CurrentScore.DNFis;
  Packet.DEFFis := PlayerCharacter.Base.CurrentScore.DEFFis;
  Packet.DNMAG := PlayerCharacter.Base.CurrentScore.DNMAG;
  Packet.DEFMAG := PlayerCharacter.Base.CurrentScore.DEFMAG;
  Packet.SpeedMove := PlayerCharacter.SpeedMove;
  Packet.Critico := PlayerCharacter.Base.CurrentScore.Critical;
  Packet.Esquiva := PlayerCharacter.Base.CurrentScore.Esquiva;
  Packet.Acerto := PlayerCharacter.Base.CurrentScore.Acerto;
  Packet.Duplo := PlayerCharacter.DuploAtk;
  Packet.Resist := PlayerCharacter.Resistence;
  SendPacket(Packet, Packet.Header.size);
  ZeroMemory(@temp_buff, 12);
  TPacketHandlers.RequestAllAttributes(Servers[Self.ChannelId].Players[Self.ClientID], temp_buff);
end;
procedure TBaseMob.SendRefreshPoint;
var
  Packet: TSendRefreshPoint;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  ZeroMemory(@Packet, sizeof(TSendRefreshPoint));
  Packet.Header.size := sizeof(TSendRefreshPoint);
  Packet.Header.Code := $109; // AIKA
  Packet.Header.Index := $7535;
  Move(PlayerCharacter.Base.CurrentScore, Packet.Pontos, sizeof(Packet.Pontos));
  Packet.SkillsPoint := Self.Character.CurrentScore.SkillPoint;
  Packet.StatusPoint := Self.Character.CurrentScore.Status;
  SendPacket(Packet, Packet.Header.size);
end;
procedure TBaseMob.SendRefreshKills;
var
  Packet: TUpdateHonorAndKills;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $12A;
  Packet.Honor := Self.Character.CurrentScore.Honor;
  Packet.Kills := Self.Character.CurrentScore.KillPoint;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TBaseMob.SendEquipItems(SendSelf: Boolean = True);
// var
// packet: TRefreshEquips;
// x: Byte;
// sItem: TItem;
// effValue: Byte;
begin
end;
procedure TBaseMob.SendRefreshItemSlot(SlotType, SlotItem: WORD; Item: TItem;
  Notice: Boolean);
var
  Packet: TRefreshItemPacket;
  Packet2: TRefreshMountPacket;
  Packet3: TRefreshItemPranPacket;
begin
  case SlotType of
    INV_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot
          (Self.Character.Inventory[SlotItem].Index) of
          9: // mount item
            begin
              ZeroMemory(@Packet2, sizeof(Packet2));
              Packet2.Header.size := sizeof(Packet2);
              Packet2.Header.Index := $7535;
              Packet2.Header.Code := $F0E;
              Packet2.Notice := Notice;
              Packet2.TypeSlot := SlotType;
              Packet2.Slot := SlotItem;
              Packet2.Item.Index := Item.Index;
              Packet2.Item.APP := Item.APP;
              Packet2.Item.Slot1 := Item.Effects.Index[0];
              Packet2.Item.Slot2 := Item.Effects.Index[1];
              Packet2.Item.Slot3 := Item.Effects.Index[2];
              Packet2.Item.Enc1 := Item.Effects.Value[0];
              Packet2.Item.Enc2 := Item.Effects.Value[1];
              Packet2.Item.Enc3 := Item.Effects.Value[2];
              Packet2.Item.Time := Item.Time;
              Packet2.Item.MIN := Item.MIN;
              Self.SendPacket(Packet2, Packet2.Header.size);
            end;
          10: // pran item
            begin
              ZeroMemory(@Packet3, sizeof(Packet3));
              Packet3.Header.size := sizeof(TRefreshItemPranPacket);
              Packet3.Header.Index := $7535;
              Packet3.Header.Code := $F0E;
              Packet3.Notice := Notice;
              Packet3.TypeSlot := SlotType;
              Packet3.Slot := SlotItem;
              Packet3.Item.Index := Item.Index;
              Packet3.Item.APP := Item.APP;
              Packet3.Item.Identific := Item.Identific;
              if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran1.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Level;
              end
              else if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran2.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Level;
                Packet3.Item.NotUse[0] := 1;
              end;
              Self.SendPacket(Packet3, Packet3.Header.size);
            end;
        else
          begin
            ZeroMemory(@Packet, sizeof(Packet));
            Packet.Header.size := sizeof(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
    EQUIP_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot
          (Self.Character.Equip[SlotItem].Index) of
          9: // mount item
            begin
              ZeroMemory(@Packet2, sizeof(Packet2));
              Packet2.Header.size := sizeof(Packet2);
              Packet2.Header.Index := $7535;
              Packet2.Header.Code := $F0E;
              Packet2.Notice := Notice;
              Packet2.TypeSlot := SlotType;
              Packet2.Slot := SlotItem;
              Packet2.Item.Index := Item.Index;
              Packet2.Item.APP := Item.APP;
              Packet2.Item.Slot1 := Item.Effects.Index[0];
              Packet2.Item.Slot2 := Item.Effects.Index[1];
              Packet2.Item.Slot3 := Item.Effects.Index[2];
              Packet2.Item.Enc1 := Item.Effects.Value[0];
              Packet2.Item.Enc2 := Item.Effects.Value[1];
              Packet2.Item.Enc3 := Item.Effects.Value[2];
              Packet2.Item.MIN := Item.MIN;
              Packet2.Item.Time := Item.Time;
              Self.SendPacket(Packet2, Packet2.Header.size);
            end;
          10: // pran item
            begin
              ZeroMemory(@Packet3, sizeof(Packet3));
              Packet3.Header.size := sizeof(TRefreshItemPranPacket);
              Packet3.Header.Index := $7535;
              Packet3.Header.Code := $F0E;
              Packet3.Notice := Notice;
              Packet3.TypeSlot := SlotType;
              Packet3.Slot := SlotItem;
              Packet3.Item.Index := Item.Index;
              Packet3.Item.APP := Item.APP;
              Packet3.Item.Identific := Item.Identific;
              if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran1.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Level;
              end
              else if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran2.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Level;
                Packet3.Item.NotUse[0] := 1;
              end;
              Self.SendPacket(Packet3, Packet3.Header.size);
            end;
        else
          begin
            ZeroMemory(@Packet, sizeof(Packet));
            Packet.Header.size := sizeof(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
    STORAGE_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot(Servers[Self.ChannelId].Players
          [Self.ClientID].Account.Header.Storage.Itens[SlotItem].Index) of
          9: // mount item
            begin
              ZeroMemory(@Packet2, sizeof(Packet2));
              Packet2.Header.size := sizeof(Packet2);
              Packet2.Header.Index := $7535;
              Packet2.Header.Code := $F0E;
              Packet2.Notice := Notice;
              Packet2.TypeSlot := SlotType;
              Packet2.Slot := SlotItem;
              Packet2.Item.Index := Item.Index;
              Packet2.Item.APP := Item.APP;
              Packet2.Item.Slot1 := Item.Effects.Index[0];
              Packet2.Item.Slot2 := Item.Effects.Index[1];
              Packet2.Item.Slot3 := Item.Effects.Index[2];
              Packet2.Item.Enc1 := Item.Effects.Value[0];
              Packet2.Item.Enc2 := Item.Effects.Value[1];
              Packet2.Item.Enc3 := Item.Effects.Value[2];
              Packet2.Item.MIN := Item.MIN;
              Packet2.Item.Time := Item.Time;
              Self.SendPacket(Packet2, Packet2.Header.size);
            end;
          10: // pran item
            begin
              ZeroMemory(@Packet3, sizeof(Packet3));
              Packet3.Header.size := sizeof(TRefreshItemPranPacket);
              Packet3.Header.Index := $7535;
              Packet3.Header.Code := $F0E;
              Packet3.Notice := Notice;
              Packet3.TypeSlot := SlotType;
              Packet3.Slot := SlotItem;
              Packet3.Item.Index := Item.Index;
              Packet3.Item.APP := Item.APP;
              Packet3.Item.Identific := Item.Identific;
              if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran1.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Level;
              end
              else if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran2.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Level;
                Packet3.Item.NotUse[0] := 1;
              end;
              Self.SendPacket(Packet3, Packet3.Header.size);
            end;
        else
          begin
            ZeroMemory(@Packet, sizeof(Packet));
            Packet.Header.size := sizeof(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
  else
    begin
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(TRefreshItemPacket);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $F0E;
      Packet.Notice := Notice;
      Packet.TypeSlot := SlotType;
      Packet.Slot := SlotItem;
      Packet.Item := Item;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
end;
procedure TBaseMob.SendRefreshItemSlot(SlotItem: WORD; Notice: Boolean);
var
  Packet: TRefreshItemPacket;
  Packet2: TRefreshMountPacket;
begin
  if not(TItemFunctions.GetItemEquipSlot(Self.Character.Inventory[SlotItem].
    Index) = 9) then
  begin
    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.size := sizeof(TRefreshItemPacket);
    Packet.Header.Index := $7535;
    Packet.Header.Code := $F0E;
    Packet.Notice := Notice;
    Packet.TypeSlot := $1;
    Packet.Slot := SlotItem;
    Packet.Item := Self.Character.Inventory[SlotItem];
    Self.SendPacket(Packet, Packet.Header.size);
  end
  else
  begin
    ZeroMemory(@Packet2, sizeof(Packet2));
    Packet2.Header.size := sizeof(Packet2);
    Packet2.Header.Index := $7535;
    Packet2.Header.Code := $F0E;
    Packet2.Notice := Notice;
    Packet2.TypeSlot := $1;
    Packet2.Slot := SlotItem;
    Packet2.Item.Index := Self.Character.Inventory[SlotItem].Index;
    Packet2.Item.APP := Self.Character.Inventory[SlotItem].APP;
    Packet2.Item.Slot1 := Self.Character.Inventory[SlotItem].Effects.Index[0];
    Packet2.Item.Slot2 := Self.Character.Inventory[SlotItem].Effects.Index[1];
    Packet2.Item.Slot3 := Self.Character.Inventory[SlotItem].Effects.Index[2];
    Packet2.Item.Enc1 := Self.Character.Inventory[SlotItem].Effects.Value[0];
    Packet2.Item.Enc2 := Self.Character.Inventory[SlotItem].Effects.Value[1];
    Packet2.Item.Enc3 := Self.Character.Inventory[SlotItem].Effects.Value[2];
    Packet2.Item.Time := Self.Character.Inventory[SlotItem].Time;
    Self.SendPacket(Packet2, Packet2.Header.size);
  end;
end;
procedure TBaseMob.SendSpawnMobs;
var
  i: Integer;
begin
  for i in Self.VisibleMobs do
  begin
    if (i = 0) OR (i = Self.ClientID) then
    begin
      Exit;
    end;
    if (i <= MAX_CONNECTIONS) then
    begin
      // Servers[ChannelId].Players[i].Base.SendCreateMob(SPAWN_NORMAL, Self.ClientId);
    end
    else
    begin
      // NPCs[i].Base.SendCreateMob(SPAWN_NORMAL, Self.ClientId);
    end;
  end;
end;
procedure TBaseMob.GenerateBabyMob;
// var pos: TPosition; i, j: BYTE; mIndex, id: WORD;
// party : PParty;
// var
// babyId, babyClientId: WORD;
// party : PParty;
// i, j: Byte;
// pos: TPosition;
begin
end;
procedure TBaseMob.UngenerateBabyMob(ungenEffect: WORD);
// evok pode ser usado pra skill de att
// var pos: TPosition; i,j: BYTE; party : PParty; find: boolean;
begin
end;
{$ENDREGION}
{$REGION 'Gets'}
procedure TBaseMob.GetCreateMob(out Packet: TSendCreateMobPacket; P1: WORD);
type
  A = record
    hi, lo: Byte;
  end;
var
  i, j, k: Integer;
  Index: WORD;
  Count, Count2: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := ClientID;
  Packet.Header.Code := $349;
  Packet.Rotation := PlayerCharacter.Rotation;
  Move(Character^.Name, Packet.Name[0], 16);
  Packet.Equip[0] := Character^.Equip[0].Index;
  Packet.Equip[1] := Character^.Equip[1].Index;
  for i := 2 to 7 do
  begin
    if (Character^.Equip[i].APP = 0) or not(Self.IsPlayer) then
    begin
      Packet.Equip[i] := Character^.Equip[i].Index;
      Continue;
    end;
    Packet.Equip[i] := Character^.Equip[i].APP;
  end;
  Packet.SpeedMove := Self.PlayerCharacter.SpeedMove;
  Packet.MaxHP := Character^.CurrentScore.MaxHP;
  Packet.MaxMP := Character^.CurrentScore.MaxHP;
  if Self.IsPlayer then
  begin
    Packet.MaxHP := Self.GetCurrentHP;
    Packet.MaxMP := Self.GetCurrentMP;
    Packet.TitleId := Self.ActiveTitle;
    Packet.Unk0 := $0A;
    Packet.Effects[1] := $1D;
    Packet.GuildIndexAndNation := Character^.Nation * 4096;
    if (Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.Base.GuildIndex) > 0 then
    begin
      AnsiStrings.StrPCopy(Packet.Title,
        AnsiString(Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
        .Character.GuildSlot].Name));
      Packet.GuildIndexAndNation :=
        StrToInt('$' + IntToStr(Character.Nation) +
        IntToHex(Servers[Self.ChannelId].Players[Self.ClientID]
        .Character.Base.GuildIndex, 3));
    end;
  end
  else
  begin
    Packet.EffectType := $1;
    Packet.IsService := 1;
    Packet.Unk0 := $28;
    if (Self.ClientID <= 3047) then
      AnsiStrings.StrPCopy(Packet.Title,
        AnsiString(Servers[ChannelId].NPCs[Self.ClientID]
        .NPCFile.Header.Title));
  end;
  Packet.ItemEff[7] := Character^.Equip[6].Refi div 16;
  Packet.Position := PlayerCharacter.LastPos;
  Packet.CurHP := Character^.CurrentScore.CurHP;
  Packet.CurMP := Character^.CurrentScore.CurMP;
  if Packet.CurHP > Packet.MaxHP then
    Packet.CurHP := Packet.MaxHP;
  if Packet.CurMP > Packet.MaxMP then
    Packet.CurMP := Packet.MaxMP;
  Packet.Altura := Character^.CurrentScore.Sizes.Altura;
  Packet.Tronco := Character^.CurrentScore.Sizes.Tronco;
  Packet.Perna := Character^.CurrentScore.Sizes.Perna;
  Packet.Corpo := Character^.CurrentScore.Sizes.Corpo;
  Packet.TitleId := Self.PlayerCharacter.ActiveTitle.Index;
  Packet.Titlelevel := Self.PlayerCharacter.ActiveTitle.Level - 1;
  if (PersonalShop.Index > 0) and (PersonalShop.Name <> '') then
  begin
    AnsiStrings.StrCopy(Packet.Title, Self.PersonalShop.Name);
    Packet.Corpo := 3;
    Packet.EffectType := 2;
  end;
  i := 0;
  for Index in Self._buffs.Keys do
  begin
    Packet.Buffs[i] := Index;
    Packet.Time[i] := DateTimeToUnix(IncSecond(Self._buffs[Index],
      SkillData[Index].Duration));
    Inc(i);
  end;
  if ((Self.ClientID >= 2048) and (Self.ClientID <= 3047)) then
  begin // isso aqui � s� por conta do s�mbolo quest
    Packet.EffectType := 0;

    for i := Low(Self.NpcQuests) to High(Self.NpcQuests) do
    begin
      if (Self.NpcQuests[i].QuestID = 0) then
        Continue;
      if (Self.NpcQuests[i].LevelMin > Servers[Self.ChannelId].Players[P1]
        .Base.Character.Level) then
      begin
        if (Packet.EffectType = 0) then
          Packet.EffectType := 07;
        Continue;
      end;
      { Verificar se a quest ja foi completa }
      Count := 0;
      Count2 := 0;
      for k := Low(Servers[Self.ChannelId].Players[P1].PlayerQuests)
        to High(Servers[Self.ChannelId].Players[P1].PlayerQuests) do
      begin
        if(Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Quest.QuestID =
          Self.NpcQuests[i].QuestID) then
        begin
          for j := 0 to 4 do
          begin
            if(Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Quest.RequirimentsAmount[j] = 0) then
              Continue
            else
              Inc(Count2);

            if (Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Complete[j] >=
              Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Quest.RequirimentsAmount[j]) then
            begin
              if not(Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Complete[j] = 0) then
                Inc(Count);
            end;
          end;
          if (not(Servers[Self.ChannelId].Players[P1].PlayerQuests[k].IsDone)) then
          begin
            if(Count = Count2) then
            begin
              Packet.EffectType := 4;
            end
            else
            begin
              Packet.EffectType := 3;
            end;
          end
          else
          begin
            {if(Count = Count2) then
            begin
              Packet.EffectType := 4;
            end
            else
            begin
              Packet.EffectType := 3;
            end; }
            if(Packet.EffectType <> 4) or (Packet.EffectType <> 3) then
              Packet.EffectType := Self.NpcQuests[i].QuestMark
            else
            begin
              if(Count = Count2) then
              begin
                Packet.EffectType := 4;
              end
              else
              begin
                Packet.EffectType := 3;
              end;
            end;
          end;
        end;
      end;

      if((Packet.EffectType = 4) or (Packet.EffectType = 3)) then
        break;

      Packet.EffectType := Self.NpcQuests[i].QuestMark;
    end;
  end;
end;
class function TBaseMob.GetMob(Index: WORD; Channel: Byte;
  out mob: TBaseMob): Boolean;
begin
  Result := False;
  if (index = 0) OR (index > MAX_SPAWN_ID) then
  begin
    Exit;
  end;
  if (index > MAX_CONNECTIONS) then
    // mob := Servers[Channel].Players[index].Base
    // else
    mob := Servers[Channel].NPCs[index].Base
  else
    Exit;
  if mob.Character = nil then
    Exit;
  Result := mob.IsActive;
end;
{
  class function TBaseMob.GetMob(Pos: TPosition; Channel: Byte;
  out mob: TBaseMob): Boolean;
  begin
  Result := GetMob(Servers[Channel].MobGrid[Round(Pos.Y)][Round(Pos.X)],
  Channel, mob);
  end; }
class function TBaseMob.GetMob(Index: WORD; Channel: Byte;
  out mob: PBaseMob): Boolean;
begin
  if (index = 0) then
  begin
    Result := False;
    Exit;
  end;
  if (index <= MAX_CONNECTIONS) then
    mob := @Servers[Channel].Players[index].Base
  else
    mob := @Servers[Channel].NPCs[index].Base;
  Result := mob.IsActive;
end;
function TBaseMob.GetMobAbility(eff: Integer): Integer;
begin
  Result := Self.MOB_EF[eff];
end;
procedure TBaseMob.IncreasseMobAbility(eff: Integer; Value: Integer);
begin
  Inc(Self.MOB_EF[eff], Value);
end;
procedure TBaseMob.DecreasseMobAbility(eff: Integer; Value: Integer);
begin
  if (Value < 0) then
  begin
    Value := Value * (-1);
    Inc(Self.MOB_EF[eff], Value);
  end
  else
    decInt(Self.MOB_EF[eff], Value); //mexi aqui nesse decint
end;
function TBaseMob.GetCurrentHP(): DWORD;
var
  hp_inc, hp_perc: DWORD;
  i: Integer;
begin
  // Cálculo do HP base
  {hp_inc := GetMobAbility(EF_HP);
  Inc(hp_inc, (Round(HPIncrementPerLevel[GetMobClass(Character.ClassInfo)]*15.3) *
    Character.Level)+ HPADD);
  Inc(hp_inc, (PlayerCharacter.Base.CurrentScore.CONS * 27));
  Inc(hp_inc, Self.GetEquipedItensHPMPInc);}

  // Cálculo do HP base
hp_inc := GetMobAbility(EF_HP);
Inc(hp_inc, (Round(HPIncrementPerLevel[GetMobClass(Character.ClassInfo)] * HPPLAYER) *
  Character.Level) + HPADD) ;
Inc(hp_inc, (PlayerCharacter.Base.CurrentScore.CONS * 27));
Inc(hp_inc, Self.GetEquipedItensHPMPInc);

// Ajuste do HP base por classe
case GetMobClass(Character.ClassInfo) of
  0: // Warrior
    Inc(hp_inc, Round(hp_inc * HPWR)); // Exemplo: +15% para Warrior
  1: // Templar
    Inc(hp_inc, Round(hp_inc * HPTP)); // Exemplo: +10% para Templar
  2: // Attacker
    Inc(hp_inc, Round(hp_inc * HPATT)); // Exemplo: +20% para Attacker
  3: // Dual
    Inc(hp_inc, Round(hp_inc * HPDUAL)); // Exemplo: +5% para Dual
  4: // Mage
    Inc(hp_inc, Round(hp_inc * HPFC)); // Exemplo: -10% para Mage
  5: // Cleric
    Inc(hp_inc, Round(hp_inc * HPSANTA)); // Exemplo: -5% para Cleric
end;


  // Verificação dos itens equipados nos slots de 2 a 7
  for i := 2 to 7 do
  begin
    // Verifica se o refinamento do item é >= 230
    if (Self.Character.Equip[i].Refi >= 230) then
    begin
      // Aumenta o HP em 9000
      Inc(hp_inc, 9000);
    end;
  end;

   // Verificação dos itens equipados nos slots de 2 a 7
  for i := 2 to 7 do
  begin
    // Verifica se o refinamento do item é >= 220
    if (Self.Character.Equip[i].Refi >= 220) then
    begin
      // Aumenta o HP em 80000
      Inc(hp_inc, 8000);
    end;
  end;


   // Verificação dos itens equipados nos slots de 2 a 7
  for i := 2 to 7 do
  begin
    // Verifica se o refinamento do item é >= 250
    if (Self.Character.Equip[i].Refi >= 250) then
    begin
      // Aumenta o HP em 12000
      Inc(hp_inc, 12000);
    end;
  end;





  // Bônus de Marshal e outros bônus de habilidades
  hp_perc := GetMobAbility(EF_MARSHAL_PER_HP);
  Inc(hp_inc, (hp_perc * Round(hp_inc div 100))DIV 2);

  // Bônus de relíquias da nação
  if(Self.Character <> nil) then
    if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    begin
      hp_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_HP];
      Inc(hp_inc, (hp_perc * Round(hp_inc div 100)));
    end;

  // Outros bônus percentuais
  hp_perc := GetMobAbility(EF_PER_HP);
  Inc(hp_inc, (hp_perc * Round(hp_inc div 100)));

  // divide o hp do geral
  hp_inc := Round(hp_inc * HPGERALL);

  // Garante que o HP não seja menor ou igual a 0
  if (hp_inc <= 0) then
    hp_inc := 1;

  Result := hp_inc;


end;

function TBaseMob.GetCurrentMP(): DWORD;
var
  mp_inc, mp_perc: DWORD;
  i: Integer;
begin
  // Cálculo do MP base
  {mp_inc := GetMobAbility(EF_MP);
  Inc(mp_inc, (Round(MPIncrementPerLevel[GetMobClass(Character.ClassInfo)]*12.3) *
    Character.Level)+ MPADD);
  Inc(mp_inc, (PlayerCharacter.Base.CurrentScore.luck * 27));
  Inc(mp_inc, Self.GetEquipedItensHPMPInc); }

  // Cálculo do MP base
mp_inc := GetMobAbility(EF_MP);
Inc(mp_inc, (Round(MPIncrementPerLevel[GetMobClass(Character.ClassInfo)] * MPPLAYER) *
  Character.Level) + MPADD);
Inc(mp_inc, (PlayerCharacter.Base.CurrentScore.luck * 27));
Inc(mp_inc, Self.GetEquipedItensHPMPInc);

// Ajuste do MP base por classe
case GetMobClass(Character.ClassInfo) of
  0: // Warrior
    Inc(mp_inc, Round(mp_inc * MPWR)); // Exemplo: -10% para Warrior (menor MP)
  1: // Templar
    Inc(mp_inc, Round(mp_inc * MPTP)); // Exemplo: -5% para Templar
  2: // Attacker
    Inc(mp_inc, Round(mp_inc * MPATT)); // Exemplo: -8% para Attacker
  3: // Dual
    Inc(mp_inc, Round(mp_inc * MPDUAL)); // Exemplo: +5% para Dual
  4: // Mage
     begin
    var BonusFactor: single;
    var BuffMultiplier: Single := 1.0; // Multiplicador de MP base, inicia como 1 (nenhum buff)


     if (Self.Character.Level > 85) and (Self.Character.Level <= 89) then
     begin
      BonusFactor := 10000;
      end
     else
     if (Self.Character.Level > 90) and (Self.Character.Level <= 95) then
      begin
       BonusFactor := 12000;
      end
      else
      if (Self.Character.Level > 96) and (Self.Character.Level <= 97) then
      begin
       BonusFactor := 13000;
      end
      else
      if (Self.Character.Level > 98) and (Self.Character.Level <= 98) then
      begin
       BonusFactor := 14000;
      end
      else
       if (Self.Character.Level = 99) then
      begin
       BonusFactor := 15000;
      end;

     // Verifica se o personagem tem os buffs 9065 ou 9066
      if Self.BuffExistsByIndex(545) then
        BuffMultiplier := BuffMultiplier + 0.90; // Aumenta MP em 90%

      if Self.BuffExistsByIndex(544) then
        BuffMultiplier := BuffMultiplier + 0.25; // Aumenta MP em 25%



      // Aplica o bônus ajustado ao cálculo de MP
      Inc(mp_inc, Round((mp_inc * MPFC + BonusFactor) * BuffMultiplier));



  end;
    //Inc(mp_inc, Round(mp_inc * MPFC)); // Exemplo: +20% para Mage (mais MP)
  5: // Cleric
    Inc(mp_inc, Round(mp_inc * MPSANTA)); // Exemplo: +15% para Cleric
end;


  // Verificação dos itens equipados nos slots de 2 a 7
  for i := 2 to 7 do
  begin
    // Verifica se o refinamento do item é >= 250
    if (Self.Character.Equip[i].Refi >= 250) then
    begin
      // Aumenta o MP em 10000
      Inc(mp_inc, 20000);
    end;
  end;
  // Verificação dos itens equipados nos slots de 2 a 7
  for i := 2 to 7 do
  begin
    // Verifica se o refinamento do item é >= 250
    if (Self.Character.Equip[i].Refi >= 220) then
    begin
      // Aumenta o MP em 10000
      Inc(mp_inc, 15000);
    end;
  end;

  // Verificação dos itens equipados nos slots de 2 a 7
  for i := 2 to 7 do
  begin
    // Verifica se o refinamento do item é >= 250
    if (Self.Character.Equip[i].Refi >= 230) then
    begin
      // Aumenta o MP em 10000
      Inc(mp_inc, 18000);
    end;
  end;


  // Bônus de Marshal e outros bônus de habilidades
  mp_perc := GetMobAbility(EF_MARSHAL_PER_MP);
  Inc(mp_inc, (mp_perc * Round(mp_inc div 100))DIV 2);

  // Bônus de relíquias da nação
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    mp_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_HP];
    Inc(mp_inc, (mp_perc * Round(mp_inc div 100)));
  end;

  // Outros bônus percentuais
  mp_perc := GetMobAbility(EF_PER_MP);
  Inc(mp_inc, (mp_perc * Round(mp_inc div 100)));

   mp_inc := Round(mp_inc  * MPGERAL );

  // Garante que o MP não seja menor ou igual a 0
  if (mp_inc <= 0) then
    mp_inc := 1;

  Result := mp_inc;
end;


function TBaseMob.GetRegenerationHP(): DWORD;
var
  hp_inc: Integer;
  hp_perc: Single;
  curHp: DWORD;
const
  REC_BASE: Single = 0.05; // antes de 30/04/2021 era 0.05
begin
  hp_inc := 0;
  Inc(hp_inc, Self.GetMobAbility(EF_PRAN_REGENHP));
  Inc(hp_inc, PlayerCharacter.Base.CurrentScore.CONS * 2);
  if (hp_inc < 0) then
    hp_inc := 0;
  hp_perc := REC_BASE + ((hp_inc div 100) div 10);
  curHp := Self.GetCurrentHP;
  Inc(hp_inc, Self.GetMobAbility(EF_REGENHP));
  Result := Trunc(curHp * hp_perc);
  if(Result > Trunc(curHp * 0.15)) then
    Result := Trunc(curHp * 0.15);
end;
function TBaseMob.GetRegenerationMP(): DWORD;
var
  mp_inc: Integer;
  mp_perc: Single;
  curMp: DWORD;
const
  REC_BASE: Single = 0.03;
begin
  mp_inc := 0;

  Inc(mp_inc, Self.GetMobAbility(EF_PRAN_REGENMP));
  Inc(mp_inc, PlayerCharacter.Base.CurrentScore.Luck * 2);

  if (mp_inc < 0) then
    mp_inc := 0;

  mp_perc := REC_BASE + ((mp_inc div 100) div 10);
  curMp := Self.GetCurrentMP;

  Inc(mp_inc, Self.GetMobAbility(EF_REGENMP));
  Result := Trunc(curMp * mp_perc);

  if(Result > Trunc(curMp * 0.15)) then
    Result := Trunc(curMp * 0.15);
end;

function TBaseMob.GetEquipedItensHPMPInc: DWORD;
var
  i: Byte;
  Refine: Byte;
begin
  Result := 0;
  for i := 2 to 7 do
  begin
    if (i = 6) then
      Continue;
    if(Self.Character.Equip[i].Time > 0) then
      continue;
    Refine := TItemFunctions.GetReinforceFromItem(Self.Character.Equip[i]);
    if (Refine = 0) then
      Continue;
    Inc(Result, TItemFunctions.GetItemReinforceHPMPInc(Self.Character.Equip[i].
      Index, Refine - 1));
  end;
end;
function TBaseMob.GetMobClass(ClassInfo: Integer = 0): Integer;
begin
  Result := 0;
  if (Self.ClientID > MAX_CONNECTIONS) then
  begin
    Exit;
  end;
  if (ClassInfo = 0) then
    ClassInfo := Self.Character.ClassInfo;
  // war
  if (ClassInfo >= 1) and (ClassInfo <= 9) then
    Result := 0;
  // templar
  if (ClassInfo >= 11) and (ClassInfo <= 19) then
    Result := 1;
  // att
  if (ClassInfo >= 21) and (ClassInfo <= 29) then
    Result := 2;
  // dual
  if (ClassInfo >= 31) and (ClassInfo <= 39) then
    Result := 3;
  // mago
  if (ClassInfo >= 41) and (ClassInfo <= 49) then
    Result := 4;
  // cleriga
  if (ClassInfo >= 51) and (ClassInfo <= 59) then
    Result := 5;
end;
procedure TBaseMob.GetEquipDamage(const Equip: TItem);
var
  FisAtk: WORD;
  MagAtk: WORD;
  RefineIndex: WORD;
  Reinforce: Byte;
begin
  FisAtk := 0;
  MagAtk := 0;

  // Verifica se o item está equipado
  if Equip.Index = 0 then
  begin
    Exit;
  end;

  // Verifica se o valor mínimo do item é maior que 0
  if(Equip.MIN = 0) then
  begin
    Exit;
  end;

  // Lógica para itens com refinamento abaixo de 16
  if not(Equip.Refi >= 16) then
  begin
    FisAtk := ItemList[Equip.Index].ATKFis;
    MagAtk := ItemList[Equip.Index].MagAtk;
  end
  else
  begin
    // Lógica para itens com refinamento igual ou superior a 16
    if not(Equip.Time > 0) then
    begin
      Reinforce := Round(Equip.Refi div 16) - 1;
      RefineIndex := TItemFunctions.GetItemReinforce2Index(Equip.Index);
      Inc(FisAtk, Reinforce2[RefineIndex].AttributeFis[Reinforce]);
      Inc(MagAtk, Reinforce2[RefineIndex].AttributeMag[Reinforce]);
    end
    else
    begin
      FisAtk := ItemList[Equip.Index].ATKFis div 100;
      MagAtk := ItemList[Equip.Index].MagAtk div 100;
    end;
  end;

  // Aplicação dos valores totais de ataque para refinamento >= 250
  if Equip.Refi = 250 then
  begin

   const
   ATK_ADD = 1800;

    case Self.GetMobClass() of
      0:  // Classe 0 - Exemplo: Guerreiro (Dano Físico alto)
        begin
          FisAtk := 7000 + ATK_ADD;  // Atribui o valor total de ataque físico para esta classe
          MagAtk := 2200 + ATK_ADD;  // Atribui um valor menor de ataque mágico
        end;
      1:  // Classe 1 - Exemplo: Mago (Dano Mágico alto)
        begin
          FisAtk := 8500 + ATK_ADD;  // Dano físico menor
          MagAtk := 1500 + ATK_ADD;  // Dano mágico alto
        end;
      2:  // Classe 2 - Exemplo: Atirador
        begin
          FisAtk := 8500 + ATK_ADD;  // Foco em dano físico
          MagAtk := 3800 + ATK_ADD;  // Algum dano mágico, mas menor
        end;
      3:  // Classe 3 - Exemplo: Dual (Equilibrado)
        begin
          FisAtk := 6000 + ATK_ADD;  // Valor médio para ataque físico
          MagAtk := 3000 + ATK_ADD;  // Valor médio para ataque mágico
        end;
      4:  // Classe 4 - Exemplo: Classe com foco em dano mágico
        begin
          FisAtk := 2000 + ATK_ADD;  // Dano físico menor
          MagAtk := 7500 + ATK_ADD;  // Dano mágico alto
        end;
      5:  // Classe 5 - Exemplo: Classe com foco em dano físico
        begin
          FisAtk := 2000 + ATK_ADD;  // Dano físico alto
          MagAtk := 7500 + ATK_ADD;  // Dano mágico menor
        end;
    end;
  end;

  // Aplicação dos valores totais de ataque para refinamento >= 220
  if Equip.Refi = 220 then


  begin
   const
   ATK_ADD = 1000;

    case Self.GetMobClass() of
      0:
        begin
          FisAtk := 5000 + ATK_ADD;  // Valor total de ataque físico para classe 0
          MagAtk := 1500+ ATK_ADD;  // Valor total de ataque mágico para classe 0
        end;
      1:
        begin
          FisAtk := 6200+ ATK_ADD;
          MagAtk := 1000+ ATK_ADD;  // Foco em ataque mágico     //ok
        end;
      2:
        begin
          FisAtk := 5500+ ATK_ADD;  // Atirador - mais físico    //ok
          MagAtk := 2800+ ATK_ADD;
        end;
      3:
        begin
          FisAtk := 4000+ ATK_ADD;
          MagAtk := 1000+ ATK_ADD;  // Dual - equilibrado        // ok
        end;
      4:
        begin
          FisAtk := 1500+ ATK_ADD;
          MagAtk := 5500+ ATK_ADD;  // Classe focada em magia      // ok
        end;
      5:
        begin
          FisAtk := 1500+ ATK_ADD;
          MagAtk := 5200+ ATK_ADD;  // Classe focada em físico    //ok
        end;
    end;
  end;

  // Aplicação dos valores totais de ataque para refinamento >= 230
  if Equip.Refi = 230 then
  begin
  const
   ATK_ADD = 1500;


    case Self.GetMobClass() of
      0:
        begin
          FisAtk := 6000 + ATK_ADD ;  // Valor total de ataque físico para classe 0
          MagAtk := 1800+ ATK_ADD ;
        end;
      1:
        begin
          FisAtk := 7300+ ATK_ADD ;
          MagAtk := 1000+ ATK_ADD ; // Foco em ataque mágico
        end;
      2:
        begin
          FisAtk := 6500+ ATK_ADD ;
          MagAtk := 3200+ ATK_ADD ;
        end;
      3:
        begin
          FisAtk := 5000+ ATK_ADD ;
          MagAtk := 2000+ ATK_ADD ;  // Dual - equilibrado
        end;
      4:
        begin
          FisAtk := 1800+ ATK_ADD ;
          MagAtk := 6500+ ATK_ADD ;  // Classe focada em magia
        end;
      5:
        begin
          FisAtk := 1900+ ATK_ADD ;
          MagAtk := 6300+ ATK_ADD ;  // Classe focada em físico
        end;
    end;
  end;

  // Atualiza os valores de ataque do personagem
  PlayerCharacter.Base.CurrentScore.DNMAG := MagAtk;
  PlayerCharacter.Base.CurrentScore.DNFis := FisAtk;
end;




procedure TBaseMob.GetEquipDefense(const Equip: TItem);
var
  FisDef: DWORD;
  MagDef: DWORD;
  RefineIndex: WORD;
  Reinforce: Byte;
begin
  FisDef := 0;
  MagDef := 0;

  if Equip.Index = 0 then
  begin
    Exit
  end;

  if not(Equip.Refi >= 16) then
  begin
    FisDef := ItemList[Equip.Index].DEFFis;
    MagDef := ItemList[Equip.Index].DEFMAG;
  end
  else
  begin
    if not(Equip.Time > 0) then
    begin
      Reinforce := Round(Equip.Refi div 16) - 1;

      RefineIndex := TItemFunctions.GetItemReinforce2Index(Equip.Index);

      Inc(FisDef, Reinforce2[RefineIndex].AttributeFis[Reinforce]);
      Inc(MagDef, Reinforce2[RefineIndex].AttributeMag[Reinforce]);
    end
    else
    begin
      FisDef := ItemList[Equip.Index].DEFFis div 100;
      MagDef := ItemList[Equip.Index].DEFMAG div 100;
    end;
  end;

  Inc(PlayerCharacter.Base.CurrentScore.DEFMAG, MagDef);
  Inc(PlayerCharacter.Base.CurrentScore.DEFFis, FisDef);
end;

// Implementação da função que calcula a defesa e aplica bônus de HP e MP
procedure TBaseMob.GetEquipsDefense;
var
  i: Integer;
  HPBonus, MPBonus: Integer;
begin
  // Zera as defesas mágicas e físicas
  Self.PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  Self.PlayerCharacter.Base.CurrentScore.DEFFis := 0;

  // Inicializa os bônus de HP e MP
  HPBonus := 0;
  MPBonus := 0;

  for i := 2 to 7 do
  begin
    if (i = 6) then
      Continue;

    // Verificação do refinamento do item      +15
    if (Self.Character.Equip[i].Refi = 250) then
    begin

    // define o valor de Def magina e Fisica do refine
    const
     DEFENSE_MULTIPLIER = 0.05;

      // Aplicação dos bônus de defesa mágica e física por classe
      case Self.GetMobClass() of
        0:  // Classe 0 - Exemplo: Guerreiro (Defesa física maior)
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER ) + 8123;
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER ) + 9321;
          end;
        1:  // Classe 1 - Exemplo: Mago (Defesa mágica maior)
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER ) + 8923;
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER ) + 9923;
          end;
        2:  // Classe 2 - Exemplo: Atirador (Equilíbrio entre defesas)
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER ) + 5849;
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER ) + 5849;
          end;
        3:  // Classe 3 - Exemplo: Dual (Equilibrado)
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER ) + 5849;
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER ) + 5849;
          end;
        4:  // Classe 4 - Exemplo: Defesa mágica predominante
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER ) + 11923;
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER ) + 6923;
          end;
        5:  // Classe 5 - Exemplo: Defesa física predominante
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER ) + 11923;
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER ) + 6923;
          end;
      end;

      // Também aplica o bônus no HP e MP para cada classe
      Self.PlayerCharacter.Base.CurrentScore.MaxHP := Round(Self.PlayerCharacter.Base.CurrentScore.MaxHP * DEFENSE_MULTIPLIER ) + 15200;
      Self.PlayerCharacter.Base.CurrentScore.MaxMP := Round(Self.PlayerCharacter.Base.CurrentScore.MaxMP * DEFENSE_MULTIPLIER ) + 15200;

      // Multiplicador de Defes magina e Fisica no valor final aplicado

      Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG   ) * 2;
      Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis  ) *2;

    end;

    // Verificação do refinamento do item      +13
    if (Self.Character.Equip[i].Refi = 220) then
    begin


    // define o valor de Def magina e Fisica do refine
    const
     DEFENSE_MULTIPLIER = 0.05;

      // Aplicação dos bônus de defesa mágica e física por classe
      case Self.GetMobClass() of
        0:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER) + 6123;    //ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 7321;
          end;
        1:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER) + 6923;  //ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 7923;
          end;
        2:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG *DEFENSE_MULTIPLIER) + 5849;     //ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 5849;
          end;
        3:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER) + 5849;      //ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 5849;
          end;
        4:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER) + 9923; //ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 3923;
          end;
        5:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER) + 9923; // ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 3923;
          end;
      end;

      // Aplicação dos bônus de HP e MP
      Self.PlayerCharacter.Base.CurrentScore.MaxHP := Round(Self.PlayerCharacter.Base.CurrentScore.MaxHP * DEFENSE_MULTIPLIER ) + 10200;
      Self.PlayerCharacter.Base.CurrentScore.MaxMP := Round(Self.PlayerCharacter.Base.CurrentScore.MaxMP * DEFENSE_MULTIPLIER ) + 10200;

       // Multiplicador de Defes magina e Fisica no valor final aplicado

      Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG  ) * 2;
      Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis  ) *2;

    end;

    // Verificação do refinamento do item    +14
    if (Self.Character.Equip[i].Refi = 230) then
    begin

    // define o valor de Def magina e Fisica do refine
    const
     DEFENSE_MULTIPLIER = 0.05;

      // Aplicação dos bônus de defesa mágica e física por classe
      case Self.GetMobClass() of
         0:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER) + 7123;    //ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 8321;
          end;
        1:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER) + 7923;  //ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 8923;
          end;
        2:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG *DEFENSE_MULTIPLIER) + 6849;     //ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 6849;
          end;
        3:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER) + 6849;      //ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 6849;
          end;
        4:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER) + 10923; //ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 4923;
          end;
        5:
          begin
            Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG * DEFENSE_MULTIPLIER) + 10923; // ok
            Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis * DEFENSE_MULTIPLIER) + 4923;
          end;
      end;

      // Aplicação dos bônus de HP e MP
      Self.PlayerCharacter.Base.CurrentScore.MaxHP := Round(Self.PlayerCharacter.Base.CurrentScore.MaxHP * DEFENSE_MULTIPLIER ) + 24200;
      Self.PlayerCharacter.Base.CurrentScore.MaxMP := Round(Self.PlayerCharacter.Base.CurrentScore.MaxMP * DEFENSE_MULTIPLIER ) + 25200;

       // Multiplicador de Defes magina e Fisica no valor final aplicado

      Self.PlayerCharacter.Base.CurrentScore.DEFMAG := Round(Self.PlayerCharacter.Base.CurrentScore.DEFMAG  ) * 2;
      Self.PlayerCharacter.Base.CurrentScore.DEFFis := Round(Self.PlayerCharacter.Base.CurrentScore.DEFFis  ) *2;


    end;

    if (Self.Character.Equip[i].MIN = 0) then
      continue;

    // Calcula a defesa para cada equipamento
    Self.GetEquipDefense(Self.Character.Equip[i]);
  end;

  // Aplica os bônus finais de HP e MP
  if HPBonus > 0 then
    Self.PlayerCharacter.Base.CurrentScore.MaxHP := Self.PlayerCharacter.Base.CurrentScore.MaxHP + HPBonus;

  if MPBonus > 0 then
    Self.PlayerCharacter.Base.CurrentScore.MaxMP := Self.PlayerCharacter.Base.CurrentScore.MaxMP + MPBonus;
end;


// Implementação da função que calcula a redução de dano baseada nos itens equipados
function TBaseMob.GetEquipedItensDamageReduce: DWORD;
var
  i: Integer;
  DamageReduce: DWORD;
begin
  DamageReduce := 0;

  // Loop nos itens equipados nos slots 2 a 7
  for i := 2 to 7 do
  begin
    // Verifica se o item tem um valor válido
    if (Self.Character.Equip[i].MIN = 0) then
      continue;

    // Se o refinamento for maior que 250, adiciona uma redução de dano
    if (Self.Character.Equip[i].Refi = 250) then
    begin
      Inc(DamageReduce, 100);  // Valor de exemplo para redução de dano
    end;
  end;

  Result := DamageReduce;  // Retorna a redução de dano calculada
end;





procedure TBaseMob.GetCurrentScore;
var
  Damage_perc: Integer;
  Def_perc: integer;
  Multiplier: Integer;
  Item11285Found, ItemConditionFound: Boolean;
  Item11286Found, ItemCondition2Found: Boolean;
  Item11287Found, ItemCondition3Found: Boolean;
  i: Integer;
  StatusLog: String;
  CharacterName: String;
  EquippedItemCount: integer;

  Difference: Integer;
  AdjustedResistance: Integer;
  AdjustedCritical: Integer;
begin
  if (Self.ClientID > MAX_CONNECTIONS) then
    Exit;

    // Obter o nome do personagem (substitua pela lógica correta para obter o nome)
     CharacterName := Self.Character.Name;

  // Verificar se o item 14190 está no inventário
  Item11285Found := False;
  for i := 0 to High(Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory) do
  begin
   if (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 14190) or
     (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 14191) then
    begin
      Item11285Found := True;
      Break;
    end;
  end;

  // Verificar se os itens 12226, 12721, 12751, 12781, 12811 estão nos slots de 1 a 9
  // Contagem de itens equipados nos slots de 1 a 9
  EquippedItemCount := 0;
  for i := 1 to 9 do // Verificando apenas os slots de 1 a 9
  begin
    if (Self.Character.Equip[i].Index <> 0) then // Verifica se há um item equipado
    begin
      Inc(EquippedItemCount); // Incrementa a contagem
    end;
  end;

  // Verificar se os itens específicos estão nos slots de 1 a 9
  ItemCondition2Found := False;
  for i := 1 to 9 do // Verificando apenas os slots de 1 a 9
  begin
    if
       // Set Alugado
       //wr
       (Self.Character.Equip[i].Index = 2574) or
       (Self.Character.Equip[i].Index = 2829) or
       (Self.Character.Equip[i].Index = 2859) or
       (Self.Character.Equip[i].Index = 2889) or
       (Self.Character.Equip[i].Index = 2919) or
       (Self.Character.Equip[i].Index = 14190) or
       //tp
       (Self.Character.Equip[i].Index = 2539) or
       (Self.Character.Equip[i].Index = 2799) or
       (Self.Character.Equip[i].Index = 2949) or
       (Self.Character.Equip[i].Index = 2979) or
       (Self.Character.Equip[i].Index = 3009) or
       (Self.Character.Equip[i].Index = 3039) or
       (Self.Character.Equip[i].Index = 14190) or
       //att
       (Self.Character.Equip[i].Index = 2714) or
       (Self.Character.Equip[i].Index = 3069) or
       (Self.Character.Equip[i].Index = 3099) or
       (Self.Character.Equip[i].Index = 3129) or
       (Self.Character.Equip[i].Index = 3159) or
       (Self.Character.Equip[i].Index = 14190) or
       //Dual
       (Self.Character.Equip[i].Index = 2679) or
       (Self.Character.Equip[i].Index = 3189) or
       (Self.Character.Equip[i].Index = 3219) or
       (Self.Character.Equip[i].Index = 3249) or
       (Self.Character.Equip[i].Index = 3279) or
       (Self.Character.Equip[i].Index = 14190) or
       //FC
       (Self.Character.Equip[i].Index = 2749) or
       (Self.Character.Equip[i].Index = 3429) or
       (Self.Character.Equip[i].Index = 3459) or
       (Self.Character.Equip[i].Index = 3489) or
       (Self.Character.Equip[i].Index = 3519) or
       (Self.Character.Equip[i].Index = 14190) or
       //Santa
       (Self.Character.Equip[i].Index = 12721) or
       (Self.Character.Equip[i].Index = 12721) or
       (Self.Character.Equip[i].Index = 12751) or
       (Self.Character.Equip[i].Index = 12781) or
       (Self.Character.Equip[i].Index = 14190) or
       (Self.Character.Equip[i].Index = 12811) or

        // Set Alugado free 7 dias

         //wr
       (Self.Character.Equip[i].Index = 6738) or
       (Self.Character.Equip[i].Index = 7005) or
       (Self.Character.Equip[i].Index = 7035) or
       (Self.Character.Equip[i].Index = 7065) or
       (Self.Character.Equip[i].Index = 7095) or
       (Self.Character.Equip[i].Index = 14190) or
       //tp
       (Self.Character.Equip[i].Index = 6703) or
       (Self.Character.Equip[i].Index = 6975) or
       (Self.Character.Equip[i].Index = 7124) or
       (Self.Character.Equip[i].Index = 7154) or
       (Self.Character.Equip[i].Index = 7184) or
       (Self.Character.Equip[i].Index = 7214) or
       (Self.Character.Equip[i].Index = 14190) or
       //att
       (Self.Character.Equip[i].Index = 6878) or
       (Self.Character.Equip[i].Index = 7245) or
       (Self.Character.Equip[i].Index = 7275) or
       (Self.Character.Equip[i].Index = 7305) or
       (Self.Character.Equip[i].Index = 7335) or
       (Self.Character.Equip[i].Index = 14190) or
       //Dual
       (Self.Character.Equip[i].Index = 6843) or
       (Self.Character.Equip[i].Index = 7365) or
       (Self.Character.Equip[i].Index = 7395) or
       (Self.Character.Equip[i].Index = 7425) or
       (Self.Character.Equip[i].Index = 7455) or
       (Self.Character.Equip[i].Index = 14190) or
       //FC
       (Self.Character.Equip[i].Index = 6948) or
       (Self.Character.Equip[i].Index = 7485) or
       (Self.Character.Equip[i].Index = 7515) or
       (Self.Character.Equip[i].Index = 7545) or
       (Self.Character.Equip[i].Index = 7575) or
       (Self.Character.Equip[i].Index = 14190) or
       //Santa
       (Self.Character.Equip[i].Index = 6913) or
       (Self.Character.Equip[i].Index = 7605) or
       (Self.Character.Equip[i].Index = 7635) or
       (Self.Character.Equip[i].Index = 7665) or
       (Self.Character.Equip[i].Index = 7695) or
       (Self.Character.Equip[i].Index = 12811) or


       // Set Conquistador Poderoso 7 dias

         //wr
       (Self.Character.Equip[i].Index = 3942) or
       (Self.Character.Equip[i].Index = 3943) or
       (Self.Character.Equip[i].Index = 3944) or
       (Self.Character.Equip[i].Index = 3945) or
       (Self.Character.Equip[i].Index = 3946) or
       (Self.Character.Equip[i].Index = 14190) or
       //tp
       (Self.Character.Equip[i].Index = 3948) or
       (Self.Character.Equip[i].Index = 3949) or
       (Self.Character.Equip[i].Index = 3950) or
       (Self.Character.Equip[i].Index = 3951) or
       (Self.Character.Equip[i].Index = 3952) or
       (Self.Character.Equip[i].Index = 3953) or
       (Self.Character.Equip[i].Index = 14190) or
       //att
       (Self.Character.Equip[i].Index = 3955) or
       (Self.Character.Equip[i].Index = 3956) or
       (Self.Character.Equip[i].Index = 3957) or
       (Self.Character.Equip[i].Index = 3958) or
       (Self.Character.Equip[i].Index = 3959) or
       (Self.Character.Equip[i].Index = 14190) or
       //Dual
       (Self.Character.Equip[i].Index = 3961) or
       (Self.Character.Equip[i].Index = 3962) or
       (Self.Character.Equip[i].Index = 3963) or
       (Self.Character.Equip[i].Index = 3964) or
       (Self.Character.Equip[i].Index = 3965) or
       (Self.Character.Equip[i].Index = 14190) or
       //FC
       (Self.Character.Equip[i].Index = 3967) or
       (Self.Character.Equip[i].Index = 3968) or
       (Self.Character.Equip[i].Index = 3969) or
       (Self.Character.Equip[i].Index = 3970) or
       (Self.Character.Equip[i].Index = 3971) or
       (Self.Character.Equip[i].Index = 14190) or
       //Santa
       (Self.Character.Equip[i].Index = 3973) or
       (Self.Character.Equip[i].Index = 3974) or
       (Self.Character.Equip[i].Index = 3975) or
       (Self.Character.Equip[i].Index = 3976) or
       (Self.Character.Equip[i].Index = 3977) or
       (Self.Character.Equip[i].Index = 12811) or

       // Set Alugado conquistador Perverso

         //wr
       (Self.Character.Equip[i].Index = 3979) or
       (Self.Character.Equip[i].Index = 3980) or
       (Self.Character.Equip[i].Index = 3981) or
       (Self.Character.Equip[i].Index = 3982) or
       (Self.Character.Equip[i].Index = 3983) or
       (Self.Character.Equip[i].Index = 14190) or
       //tp
       (Self.Character.Equip[i].Index = 3985) or
       (Self.Character.Equip[i].Index = 3986) or
       (Self.Character.Equip[i].Index = 3987) or
       (Self.Character.Equip[i].Index = 3988) or
       (Self.Character.Equip[i].Index = 3989) or
       (Self.Character.Equip[i].Index = 3990) or
       (Self.Character.Equip[i].Index = 14190) or
       //att
       (Self.Character.Equip[i].Index = 3992) or
       (Self.Character.Equip[i].Index = 3993) or
       (Self.Character.Equip[i].Index = 3994) or
       (Self.Character.Equip[i].Index = 3995) or
       (Self.Character.Equip[i].Index = 3996) or
       (Self.Character.Equip[i].Index = 14190) or
       //Dual
       (Self.Character.Equip[i].Index = 3998) or
       (Self.Character.Equip[i].Index = 3999) or
       (Self.Character.Equip[i].Index = 4000) or
       (Self.Character.Equip[i].Index = 4001) or
       (Self.Character.Equip[i].Index = 4002) or
       (Self.Character.Equip[i].Index = 14190) or
       //FC
       (Self.Character.Equip[i].Index = 4004) or
       (Self.Character.Equip[i].Index = 4005) or
       (Self.Character.Equip[i].Index = 4006) or
       (Self.Character.Equip[i].Index = 4007) or
       (Self.Character.Equip[i].Index = 4008) or
       (Self.Character.Equip[i].Index = 14190) or
       //Santa
       (Self.Character.Equip[i].Index = 4010) or
       (Self.Character.Equip[i].Index = 4011) or
       (Self.Character.Equip[i].Index = 4012) or
       (Self.Character.Equip[i].Index = 4013) or
       (Self.Character.Equip[i].Index = 4014) or
       (Self.Character.Equip[i].Index = 12811) or

       // Set Conquistador Poderoso 2

         //wr
       (Self.Character.Equip[i].Index = 6736) or
       (Self.Character.Equip[i].Index = 7003) or
       (Self.Character.Equip[i].Index = 7033) or
       (Self.Character.Equip[i].Index = 7063) or
       (Self.Character.Equip[i].Index = 7093) or
       (Self.Character.Equip[i].Index = 14190) or
       //tp
       (Self.Character.Equip[i].Index = 6701) or
       (Self.Character.Equip[i].Index = 6973) or
       (Self.Character.Equip[i].Index = 7122) or
       (Self.Character.Equip[i].Index = 7152) or
       (Self.Character.Equip[i].Index = 7182) or
       (Self.Character.Equip[i].Index = 7212) or
       (Self.Character.Equip[i].Index = 14190) or
       //att
       (Self.Character.Equip[i].Index = 6876) or
       (Self.Character.Equip[i].Index = 7243) or
       (Self.Character.Equip[i].Index = 7273) or
       (Self.Character.Equip[i].Index = 7303) or
       (Self.Character.Equip[i].Index = 7333) or
       (Self.Character.Equip[i].Index = 14190) or
       //Dual
       (Self.Character.Equip[i].Index = 6841) or
       (Self.Character.Equip[i].Index = 7363) or
       (Self.Character.Equip[i].Index = 7393) or
       (Self.Character.Equip[i].Index = 7423) or
       (Self.Character.Equip[i].Index = 7453) or
       (Self.Character.Equip[i].Index = 14190) or
       //FC
       (Self.Character.Equip[i].Index = 6946) or
       (Self.Character.Equip[i].Index = 7483) or
       (Self.Character.Equip[i].Index = 7513) or
       (Self.Character.Equip[i].Index = 7543) or
       (Self.Character.Equip[i].Index = 7573) or
       (Self.Character.Equip[i].Index = 14190) or
       //Santa
       (Self.Character.Equip[i].Index = 6911) or
       (Self.Character.Equip[i].Index = 7603) or
       (Self.Character.Equip[i].Index = 7633) or
       (Self.Character.Equip[i].Index = 7663) or
       (Self.Character.Equip[i].Index = 7693) or
       (Self.Character.Equip[i].Index = 12811) or

       // Set Alugado conquistador Perverso 2

         //wr
       (Self.Character.Equip[i].Index = 6737) or
       (Self.Character.Equip[i].Index = 7004) or
       (Self.Character.Equip[i].Index = 7034) or
       (Self.Character.Equip[i].Index = 7064) or
       (Self.Character.Equip[i].Index = 7094) or
       (Self.Character.Equip[i].Index = 14190) or
       //tp
       (Self.Character.Equip[i].Index = 6702) or
       (Self.Character.Equip[i].Index = 6974) or
       (Self.Character.Equip[i].Index = 7123) or
       (Self.Character.Equip[i].Index = 7153) or
       (Self.Character.Equip[i].Index = 7183) or
       (Self.Character.Equip[i].Index = 3990) or
       (Self.Character.Equip[i].Index = 14190) or
       //att
       (Self.Character.Equip[i].Index = 6877) or
       (Self.Character.Equip[i].Index = 7244) or
       (Self.Character.Equip[i].Index = 7274) or
       (Self.Character.Equip[i].Index = 7304) or
       (Self.Character.Equip[i].Index = 7334) or
       (Self.Character.Equip[i].Index = 14190) or
       //Dual
       (Self.Character.Equip[i].Index = 6842) or
       (Self.Character.Equip[i].Index = 7364) or
       (Self.Character.Equip[i].Index = 7394) or
       (Self.Character.Equip[i].Index = 7424) or
       (Self.Character.Equip[i].Index = 7454) or
       (Self.Character.Equip[i].Index = 14190) or
       //FC
       (Self.Character.Equip[i].Index = 6947) or
       (Self.Character.Equip[i].Index = 7484) or
       (Self.Character.Equip[i].Index = 7514) or
       (Self.Character.Equip[i].Index = 7544) or
       (Self.Character.Equip[i].Index = 7574) or
       (Self.Character.Equip[i].Index = 14190) or
       //Santa
       (Self.Character.Equip[i].Index = 6912) or
       (Self.Character.Equip[i].Index = 7604) or
       (Self.Character.Equip[i].Index = 7634) or
       (Self.Character.Equip[i].Index = 7664) or
       (Self.Character.Equip[i].Index = 7694) or
       (Self.Character.Equip[i].Index = 12811) or

       // Set Alugado Seguidor do Sol

         //wr
       (Self.Character.Equip[i].Index = 19121) or
       (Self.Character.Equip[i].Index = 19331) or
       (Self.Character.Equip[i].Index = 19361) or
       (Self.Character.Equip[i].Index = 19391) or
       (Self.Character.Equip[i].Index = 19421) or
        //tp
       (Self.Character.Equip[i].Index = 19151) or
       (Self.Character.Equip[i].Index = 19451) or
       (Self.Character.Equip[i].Index = 19481) or
       (Self.Character.Equip[i].Index = 19511) or
       (Self.Character.Equip[i].Index = 19541) or
       (Self.Character.Equip[i].Index = 19301) or

       //att
       (Self.Character.Equip[i].Index = 19181) or
       (Self.Character.Equip[i].Index = 19571) or
       (Self.Character.Equip[i].Index = 19601) or
       (Self.Character.Equip[i].Index = 19631) or
       (Self.Character.Equip[i].Index = 19661) or

       //Dual
       (Self.Character.Equip[i].Index = 19211) or
       (Self.Character.Equip[i].Index = 19691) or
       (Self.Character.Equip[i].Index = 19721) or
       (Self.Character.Equip[i].Index = 19751) or
       (Self.Character.Equip[i].Index = 19781) or

       //FC
       (Self.Character.Equip[i].Index = 19241) or
       (Self.Character.Equip[i].Index = 19811) or
       (Self.Character.Equip[i].Index = 19841) or
       (Self.Character.Equip[i].Index = 19871) or
       (Self.Character.Equip[i].Index = 19901) or

       //Santa
       (Self.Character.Equip[i].Index = 19271) or
       (Self.Character.Equip[i].Index = 19931) or
       (Self.Character.Equip[i].Index = 19961) or
       (Self.Character.Equip[i].Index = 19991) or
       (Self.Character.Equip[i].Index = 20021) or

        // Seguidor so sol novo
        // WR (Warrior)
        (Self.Character.Equip[i].Index = 1066) or
        (Self.Character.Equip[i].Index = 1680) or
        (Self.Character.Equip[i].Index = 1711) or
        (Self.Character.Equip[i].Index = 1738) or
        (Self.Character.Equip[i].Index = 1769) or

        // TP (Templária)
        (Self.Character.Equip[i].Index = 1032) or
        (Self.Character.Equip[i].Index = 1800) or
        (Self.Character.Equip[i].Index = 1831) or
        (Self.Character.Equip[i].Index = 1858) or
        (Self.Character.Equip[i].Index = 1889) or
        (Self.Character.Equip[i].Index = 1307) or

        // ATT (Atirador)
        (Self.Character.Equip[i].Index = 1207) or
        (Self.Character.Equip[i].Index = 1920) or
        (Self.Character.Equip[i].Index = 1951) or
        (Self.Character.Equip[i].Index = 1978) or
        (Self.Character.Equip[i].Index = 2009) or

        // Dual
        (Self.Character.Equip[i].Index = 1172) or
        (Self.Character.Equip[i].Index = 2040) or
        (Self.Character.Equip[i].Index = 2071) or
        (Self.Character.Equip[i].Index = 2098) or
        (Self.Character.Equip[i].Index = 2129) or

        // FC (Feiticeiro)
        (Self.Character.Equip[i].Index = 1277) or
        (Self.Character.Equip[i].Index = 2160) or
        (Self.Character.Equip[i].Index = 2191) or
        (Self.Character.Equip[i].Index = 2218) or
        (Self.Character.Equip[i].Index = 2249) or

        // Santa
        (Self.Character.Equip[i].Index = 1242) or
        (Self.Character.Equip[i].Index = 2280) or
        (Self.Character.Equip[i].Index = 2311) or
        (Self.Character.Equip[i].Index = 2338) or
        (Self.Character.Equip[i].Index = 2369) or




       // Set alugado Protetor de Mani
         //wr
       (Self.Character.Equip[i].Index = 19122) or
       (Self.Character.Equip[i].Index = 19132) or
       (Self.Character.Equip[i].Index = 19162) or
       (Self.Character.Equip[i].Index = 19392) or
       (Self.Character.Equip[i].Index = 19422) or

       //tp
       (Self.Character.Equip[i].Index = 19152) or
       (Self.Character.Equip[i].Index = 19452) or
       (Self.Character.Equip[i].Index = 19482) or
       (Self.Character.Equip[i].Index = 19512) or
       (Self.Character.Equip[i].Index = 19542) or
       (Self.Character.Equip[i].Index = 19302) or

       //att
       (Self.Character.Equip[i].Index = 6876) or
       (Self.Character.Equip[i].Index = 7243) or
       (Self.Character.Equip[i].Index = 7273) or
       (Self.Character.Equip[i].Index = 7303) or
       (Self.Character.Equip[i].Index = 7333) or

       //Dual
       (Self.Character.Equip[i].Index = 19182) or
       (Self.Character.Equip[i].Index = 19572) or
       (Self.Character.Equip[i].Index = 19602) or
       (Self.Character.Equip[i].Index = 19632) or
       (Self.Character.Equip[i].Index = 19662) or

       //FC
       (Self.Character.Equip[i].Index = 19212) or
       (Self.Character.Equip[i].Index = 19692) or
       (Self.Character.Equip[i].Index = 19722) or
       (Self.Character.Equip[i].Index = 19752) or
       (Self.Character.Equip[i].Index = 19782) or

       //Santa
       (Self.Character.Equip[i].Index = 19242) or
       (Self.Character.Equip[i].Index = 19812) or
       (Self.Character.Equip[i].Index = 19842) or
       (Self.Character.Equip[i].Index = 19872) or
       (Self.Character.Equip[i].Index = 19902) or

       //Seguidor de Mani novo

       // WR (Warrior)
        (Self.Character.Equip[i].Index = 2841) or
        (Self.Character.Equip[i].Index = 2871) or
        (Self.Character.Equip[i].Index = 2901) or
        (Self.Character.Equip[i].Index = 2931) or
        (Self.Character.Equip[i].Index = 2557) or

        // TP (Templária)
        (Self.Character.Equip[i].Index = 2961) or
        (Self.Character.Equip[i].Index = 2991) or
        (Self.Character.Equip[i].Index = 3021) or
        (Self.Character.Equip[i].Index = 3051) or
        (Self.Character.Equip[i].Index = 2522) or
        (Self.Character.Equip[i].Index = 2811) or

        // ATT (Atirador)
        (Self.Character.Equip[i].Index = 3081) or
        (Self.Character.Equip[i].Index = 3111) or
        (Self.Character.Equip[i].Index = 3141) or
        (Self.Character.Equip[i].Index = 3171) or
        (Self.Character.Equip[i].Index = 2697) or

        // Dual
        (Self.Character.Equip[i].Index = 3201) or
        (Self.Character.Equip[i].Index = 3231) or
        (Self.Character.Equip[i].Index = 3261) or
        (Self.Character.Equip[i].Index = 3291) or
        (Self.Character.Equip[i].Index = 2662) or

        // FC (Feiticeiro)
        (Self.Character.Equip[i].Index = 3321) or
        (Self.Character.Equip[i].Index = 3351) or
        (Self.Character.Equip[i].Index = 3381) or
        (Self.Character.Equip[i].Index = 3411) or
        (Self.Character.Equip[i].Index = 2767) or

        // Santa
        (Self.Character.Equip[i].Index = 3441) or
        (Self.Character.Equip[i].Index = 3471) or
        (Self.Character.Equip[i].Index = 3501) or
        (Self.Character.Equip[i].Index = 3531) or
        (Self.Character.Equip[i].Index = 2732)  then



    begin
      ItemConditionFound := True;
      Break;
    end;
  end;




    begin
      if (Self.ClientID > MAX_CONNECTIONS) then
        Exit;
      ZeroMemory(@PlayerCharacter.Base.CurrentScore, 10);
      PlayerCharacter.Base.CurrentScore.DNFis := 0;
      PlayerCharacter.Base.CurrentScore.DNMAG := 0;
      PlayerCharacter.Base.CurrentScore.DEFFis := 0;
      PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
      PlayerCharacter.Base.CurrentScore.BonusDMG := 0;
      PlayerCharacter.Base.CurrentScore.Critical := 0;
      PlayerCharacter.Base.CurrentScore.Esquiva := 0;
      PlayerCharacter.Base.CurrentScore.Acerto := 0;
      PlayerCharacter.DuploAtk := 0;
      PlayerCharacter.SpeedMove := 0;
      PlayerCharacter.Resistence := 0;
      PlayerCharacter.HabAtk := 0;
      PlayerCharacter.DamageCritical := 0;
      PlayerCharacter.ResDamageCritical := 0;
      PlayerCharacter.MagPenetration := 0;
      PlayerCharacter.FisPenetration := 0;
      PlayerCharacter.CureTax := 0;
      PlayerCharacter.CritRes := 0;
      PlayerCharacter.DuploRes := 0;
      PlayerCharacter.ReduceCooldown := 0;
      PlayerCharacter.PvPDamage := 0;
      PlayerCharacter.PvPDefense := 0;

  //>>>>>>>>>>>>>>>>>>>Melhorador de Set 10%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

         begin
      if (Self.ClientID > MAX_CONNECTIONS) then
        Exit;

      // Obter o nome do personagem (substitua pela lógica correta para obter o nome)
      CharacterName := Self.Character.Name;

      // Verificar se o item 14190 está no inventário
      Item11286Found := False;
      for i := 0 to High(Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory) do
      begin
        if (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 15409) or
        (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 15409) or
        (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 15539) or
        (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 15540) then
        begin
          Item11286Found := True;
          Break;
        end;
      end;

          // Contagem de itens equipados nos slots de 1 a 9
      EquippedItemCount := 0;
      for i := 1 to 9 do // Verificando apenas os slots de 1 a 9
      begin
        if (Self.Character.Equip[i].Index <> 0) then // Verifica se há um item equipado
        begin
          Inc(EquippedItemCount); // Incrementa a contagem
        end;
      end;

      // Verificar se os itens específicos estão nos slots de 1 a 9
      ItemCondition2Found := False;
      for i := 1 to 9 do // Verificando apenas os slots de 1 a 9
      begin
        if
           // Wars tank
           // War
           (Self.Character.Equip[i].Index = 12073) or
           (Self.Character.Equip[i].Index = 12379) or
           (Self.Character.Equip[i].Index = 12409) or
           (Self.Character.Equip[i].Index = 12439) or
           (Self.Character.Equip[i].Index = 12469) or

           // TP
           (Self.Character.Equip[i].Index = 12108) or
           (Self.Character.Equip[i].Index = 12349) or
           (Self.Character.Equip[i].Index = 12499) or
           (Self.Character.Equip[i].Index = 12529) or
           (Self.Character.Equip[i].Index = 12559) or
           (Self.Character.Equip[i].Index = 12589) or

           // Att
           (Self.Character.Equip[i].Index = 12213) or
           (Self.Character.Equip[i].Index = 12619) or
           (Self.Character.Equip[i].Index = 12649) or
           (Self.Character.Equip[i].Index = 12679) or
           (Self.Character.Equip[i].Index = 12709) or

           //Dual
           (Self.Character.Equip[i].Index = 12248) or
           (Self.Character.Equip[i].Index = 12739) or
           (Self.Character.Equip[i].Index = 12769) or
           (Self.Character.Equip[i].Index = 12799) or
           (Self.Character.Equip[i].Index = 12829) or

           //FC
           (Self.Character.Equip[i].Index = 12283) or
           (Self.Character.Equip[i].Index = 12859) or
           (Self.Character.Equip[i].Index = 12889) or
           (Self.Character.Equip[i].Index = 12919) or
           (Self.Character.Equip[i].Index = 12949) or

           // Santa
           (Self.Character.Equip[i].Index = 12318) or
           (Self.Character.Equip[i].Index = 12979) or
           (Self.Character.Equip[i].Index = 13009) or
           (Self.Character.Equip[i].Index = 13039) or
           (Self.Character.Equip[i].Index = 13069) or


           // wars Dano

                       // War
           (Self.Character.Equip[i].Index = 12072) or
           (Self.Character.Equip[i].Index = 12378) or
           (Self.Character.Equip[i].Index = 12408) or
           (Self.Character.Equip[i].Index = 12438) or
           (Self.Character.Equip[i].Index = 12468) or

           // TP
           (Self.Character.Equip[i].Index = 12107) or
           (Self.Character.Equip[i].Index = 12348) or
           (Self.Character.Equip[i].Index = 12498) or
           (Self.Character.Equip[i].Index = 12528) or
           (Self.Character.Equip[i].Index = 12558) or
           (Self.Character.Equip[i].Index = 12588) or

           // Att
           (Self.Character.Equip[i].Index = 12212) or
           (Self.Character.Equip[i].Index = 12618) or
           (Self.Character.Equip[i].Index = 12648) or
           (Self.Character.Equip[i].Index = 12678) or
           (Self.Character.Equip[i].Index = 12708) or

           //Dual
           (Self.Character.Equip[i].Index = 12247) or
           (Self.Character.Equip[i].Index = 12738) or
           (Self.Character.Equip[i].Index = 12768) or
           (Self.Character.Equip[i].Index = 12798) or
           (Self.Character.Equip[i].Index = 12828) or

           //FC
           (Self.Character.Equip[i].Index = 12282) or
           (Self.Character.Equip[i].Index = 12858) or
           (Self.Character.Equip[i].Index = 12888) or
           (Self.Character.Equip[i].Index = 12918) or
           (Self.Character.Equip[i].Index = 12948) or

           // Santa
           (Self.Character.Equip[i].Index = 12317) or
           (Self.Character.Equip[i].Index = 12978) or
           (Self.Character.Equip[i].Index = 13008) or
           (Self.Character.Equip[i].Index = 13038) or
           (Self.Character.Equip[i].Index = 13068) or

           // Celestial tank
            (Self.Character.Equip[i].Index = 12066) or
            (Self.Character.Equip[i].Index = 12372) or
            (Self.Character.Equip[i].Index = 12402) or
            (Self.Character.Equip[i].Index = 12432) or
            (Self.Character.Equip[i].Index = 12462) or
            (Self.Character.Equip[i].Index = 1151) or

            (Self.Character.Equip[i].Index = 12101) or
            (Self.Character.Equip[i].Index = 12342) or
            (Self.Character.Equip[i].Index = 12492) or
            (Self.Character.Equip[i].Index = 12522) or
            (Self.Character.Equip[i].Index = 12552) or
            (Self.Character.Equip[i].Index = 12582) or

            (Self.Character.Equip[i].Index = 12206) or
            (Self.Character.Equip[i].Index = 12612) or
            (Self.Character.Equip[i].Index = 12642) or
            (Self.Character.Equip[i].Index = 12672) or
            (Self.Character.Equip[i].Index = 12702) or

            (Self.Character.Equip[i].Index = 12241) or
            (Self.Character.Equip[i].Index = 12732) or
            (Self.Character.Equip[i].Index = 12762) or
            (Self.Character.Equip[i].Index = 12792) or
            (Self.Character.Equip[i].Index = 12822) or

            (Self.Character.Equip[i].Index = 12276) or
            (Self.Character.Equip[i].Index = 12852) or
            (Self.Character.Equip[i].Index = 12882) or
            (Self.Character.Equip[i].Index = 12912) or
            (Self.Character.Equip[i].Index = 12942) or

            (Self.Character.Equip[i].Index = 12311) or
            (Self.Character.Equip[i].Index = 12972) or
            (Self.Character.Equip[i].Index = 13002) or
            (Self.Character.Equip[i].Index = 13032) or
            (Self.Character.Equip[i].Index = 13062) or

            // Cellestial dano

              (Self.Character.Equip[i].Index = 12067) or
          (Self.Character.Equip[i].Index = 12373) or
          (Self.Character.Equip[i].Index = 12403) or
          (Self.Character.Equip[i].Index = 12433) or
          (Self.Character.Equip[i].Index = 12463) or
          (Self.Character.Equip[i].Index = 1152) or

          (Self.Character.Equip[i].Index = 12102) or
          (Self.Character.Equip[i].Index = 12343) or
          (Self.Character.Equip[i].Index = 12493) or
          (Self.Character.Equip[i].Index = 12523) or
          (Self.Character.Equip[i].Index = 12553) or
          (Self.Character.Equip[i].Index = 12583) or

          (Self.Character.Equip[i].Index = 12207) or
          (Self.Character.Equip[i].Index = 12613) or
          (Self.Character.Equip[i].Index = 12643) or
          (Self.Character.Equip[i].Index = 12673) or
          (Self.Character.Equip[i].Index = 12703) or

          (Self.Character.Equip[i].Index = 12242) or
          (Self.Character.Equip[i].Index = 12733) or
          (Self.Character.Equip[i].Index = 12763) or
          (Self.Character.Equip[i].Index = 12793) or
          (Self.Character.Equip[i].Index = 12823) or

          (Self.Character.Equip[i].Index = 12277) or
          (Self.Character.Equip[i].Index = 12853) or
          (Self.Character.Equip[i].Index = 12883) or
          (Self.Character.Equip[i].Index = 12913) or
          (Self.Character.Equip[i].Index = 12943) or

          (Self.Character.Equip[i].Index = 12312) or
          (Self.Character.Equip[i].Index = 12973) or
          (Self.Character.Equip[i].Index = 13003) or
          (Self.Character.Equip[i].Index = 13033) or
          (Self.Character.Equip[i].Index = 13063) or

          // Set free 7 dias

          (Self.Character.Equip[i].Index = 6738) or
        (Self.Character.Equip[i].Index = 7005) or
        (Self.Character.Equip[i].Index = 7035) or
        (Self.Character.Equip[i].Index = 7065) or
        (Self.Character.Equip[i].Index = 7095) or

        (Self.Character.Equip[i].Index = 6703) or
        (Self.Character.Equip[i].Index = 6975) or
        (Self.Character.Equip[i].Index = 7124) or
        (Self.Character.Equip[i].Index = 7154) or
        (Self.Character.Equip[i].Index = 7184) or
        (Self.Character.Equip[i].Index = 7214) or

        (Self.Character.Equip[i].Index = 6878) or
        (Self.Character.Equip[i].Index = 7245) or
        (Self.Character.Equip[i].Index = 7275) or
        (Self.Character.Equip[i].Index = 7305) or
        (Self.Character.Equip[i].Index = 7335) or

        (Self.Character.Equip[i].Index = 6843) or
        (Self.Character.Equip[i].Index = 7365) or
        (Self.Character.Equip[i].Index = 7395) or
        (Self.Character.Equip[i].Index = 7425) or
        (Self.Character.Equip[i].Index = 7455) or

        (Self.Character.Equip[i].Index = 6948) or
        (Self.Character.Equip[i].Index = 7485) or
        (Self.Character.Equip[i].Index = 7515) or
        (Self.Character.Equip[i].Index = 7545) or
        (Self.Character.Equip[i].Index = 7575) or

        (Self.Character.Equip[i].Index = 6913) or
        (Self.Character.Equip[i].Index = 7605) or
        (Self.Character.Equip[i].Index = 7635) or
        (Self.Character.Equip[i].Index = 7665) or
        (Self.Character.Equip[i].Index = 7695)
      then


        begin
          ItemCondition2Found := True;
          Break;
        end;
      end;

      // Se os itens não foram encontrados, adicionar um percentual aos atributos
      if not Item11286Found and not ItemCondition2Found then
      begin
        // Exemplo: percentual a ser adicionado (50% no caso)
        const PercentualBonus = MELHORADOR_DANO;

        PlayerCharacter.Base.CurrentScore.DNFis := Trunc(PlayerCharacter.Base.CurrentScore.DNFis * (1 + 0));
        PlayerCharacter.Base.CurrentScore.DNMAG := Trunc(PlayerCharacter.Base.CurrentScore.DNMAG * (1 + 0));
        PlayerCharacter.Base.CurrentScore.DEFFis := Trunc(PlayerCharacter.Base.CurrentScore.DEFFis * (1 + 10000));
        PlayerCharacter.Base.CurrentScore.DEFMAG := Trunc(PlayerCharacter.Base.CurrentScore.DEFMAG * (1 + 10000));
        PlayerCharacter.Base.CurrentScore.BonusDMG := Trunc(PlayerCharacter.Base.CurrentScore.BonusDMG * (1 + 10));
        PlayerCharacter.Base.CurrentScore.Critical := Trunc(PlayerCharacter.Base.CurrentScore.Critical * (1 + 300));
        PlayerCharacter.Base.CurrentScore.Esquiva := Trunc(PlayerCharacter.Base.CurrentScore.Esquiva * (1 + 10));
        PlayerCharacter.Base.CurrentScore.Acerto := Trunc(PlayerCharacter.Base.CurrentScore.Acerto * (1 + 100));
        PlayerCharacter.DuploAtk := Trunc(PlayerCharacter.DuploAtk * (1 + 10));
        PlayerCharacter.SpeedMove := Trunc(PlayerCharacter.SpeedMove * (1 + 0));
        PlayerCharacter.Resistence := Trunc(PlayerCharacter.Resistence * (1 + 10));
        PlayerCharacter.HabAtk := Trunc(PlayerCharacter.HabAtk * (1 + 10));
        PlayerCharacter.DamageCritical := Trunc(PlayerCharacter.DamageCritical * (1 + 10));
        PlayerCharacter.ResDamageCritical := Trunc(PlayerCharacter.ResDamageCritical * (1 + 10));
        PlayerCharacter.MagPenetration := Trunc(PlayerCharacter.MagPenetration * (1 + 10));
        PlayerCharacter.FisPenetration := Trunc(PlayerCharacter.FisPenetration * (1 + 10));
        PlayerCharacter.CureTax := Trunc(PlayerCharacter.CureTax * (1 + 0));
        PlayerCharacter.CritRes := Trunc(PlayerCharacter.CritRes * (1 + 300));
        PlayerCharacter.DuploRes := Trunc(PlayerCharacter.DuploRes * (1 + 10));
        PlayerCharacter.ReduceCooldown := Trunc(PlayerCharacter.ReduceCooldown * (1 + 0));
        PlayerCharacter.PvPDamage := Trunc(PlayerCharacter.PvPDamage * (1 + 5000));
        PlayerCharacter.PvPDefense := Trunc(PlayerCharacter.PvPDefense * (1 + 5000));
      end;
    end;




  //>>>>>>>>>>>>>>>>>>>Melhorador de Set 5%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

         begin
      if (Self.ClientID > MAX_CONNECTIONS) then
        Exit;

      // Obter o nome do personagem (substitua pela lógica correta para obter o nome)
      CharacterName := Self.Character.Name;

      // Verificar se o item 14190 está no inventário
      Item11287Found := False;
      for i := 0 to High(Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory) do
      begin
        if (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 15542) or
        (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 15543) or
        (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 15544) or
        (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 15545) then
        begin
          Item11287Found := True;
          Break;
        end;
      end;

      // Verificar se os itens 12226, 12721, 12751, 12781, 12811 estão nos slots de 1 a 9
           // Contagem de itens equipados nos slots de 1 a 9
        EquippedItemCount := 0;
        for i := 1 to 9 do // Verificando apenas os slots de 1 a 9
        begin
          if (Self.Character.Equip[i].Index <> 0) then // Verifica se há um item equipado
          begin
            Inc(EquippedItemCount); // Incrementa a contagem
          end;
        end;

        // Verificar se os itens específicos estão nos slots de 1 a 9
        ItemCondition2Found := False;
        for i := 1 to 9 do // Verificando apenas os slots de 1 a 9
      begin
        if
           // conquistador

           // War
           (Self.Character.Equip[i].Index = 12076) or
          (Self.Character.Equip[i].Index = 12382) or
          (Self.Character.Equip[i].Index = 12412) or
          (Self.Character.Equip[i].Index = 12442) or
          (Self.Character.Equip[i].Index = 12472) or
           // tp
          (Self.Character.Equip[i].Index = 12111) or
          (Self.Character.Equip[i].Index = 12352) or
          (Self.Character.Equip[i].Index = 12502) or
          (Self.Character.Equip[i].Index = 12532) or
          (Self.Character.Equip[i].Index = 12562) or
          (Self.Character.Equip[i].Index = 12592) or
           // att
          (Self.Character.Equip[i].Index = 12216) or
          (Self.Character.Equip[i].Index = 12622) or
          (Self.Character.Equip[i].Index = 12652) or
          (Self.Character.Equip[i].Index = 12682) or
          (Self.Character.Equip[i].Index = 12712) or
           // dual
          (Self.Character.Equip[i].Index = 12251) or
          (Self.Character.Equip[i].Index = 12742) or
          (Self.Character.Equip[i].Index = 12772) or
          (Self.Character.Equip[i].Index = 12802) or
          (Self.Character.Equip[i].Index = 12832) or
            //fc
          (Self.Character.Equip[i].Index = 12286) or
          (Self.Character.Equip[i].Index = 12862) or
          (Self.Character.Equip[i].Index = 12892) or
          (Self.Character.Equip[i].Index = 12922) or
          (Self.Character.Equip[i].Index = 12952) or
             //santa
          (Self.Character.Equip[i].Index = 12321) or
          (Self.Character.Equip[i].Index = 12982) or
          (Self.Character.Equip[i].Index = 13012) or
          (Self.Character.Equip[i].Index = 13042) or
          (Self.Character.Equip[i].Index = 13072) or

          // Set Alugado


           (Self.Character.Equip[i].Index = 2574) or
          (Self.Character.Equip[i].Index = 2829) or
          (Self.Character.Equip[i].Index = 2859) or
          (Self.Character.Equip[i].Index = 2889) or
          (Self.Character.Equip[i].Index = 2919) or

          (Self.Character.Equip[i].Index = 2539) or
          (Self.Character.Equip[i].Index = 2799) or
          (Self.Character.Equip[i].Index = 2949) or
          (Self.Character.Equip[i].Index = 2979) or
          (Self.Character.Equip[i].Index = 3009) or
          (Self.Character.Equip[i].Index = 3039) or

          (Self.Character.Equip[i].Index = 2714) or
          (Self.Character.Equip[i].Index = 3069) or
          (Self.Character.Equip[i].Index = 3099) or
          (Self.Character.Equip[i].Index = 3129) or
          (Self.Character.Equip[i].Index = 3159) or

          (Self.Character.Equip[i].Index = 2679) or
          (Self.Character.Equip[i].Index = 3189) or
          (Self.Character.Equip[i].Index = 3219) or
          (Self.Character.Equip[i].Index = 3249) or
          (Self.Character.Equip[i].Index = 3279) or

          (Self.Character.Equip[i].Index = 2784) or
          (Self.Character.Equip[i].Index = 3309) or
          (Self.Character.Equip[i].Index = 3339) or
          (Self.Character.Equip[i].Index = 3369) or
          (Self.Character.Equip[i].Index = 3399) or

          (Self.Character.Equip[i].Index = 2749) or
          (Self.Character.Equip[i].Index = 3429) or
          (Self.Character.Equip[i].Index = 3459) or
          (Self.Character.Equip[i].Index = 3489) or
          (Self.Character.Equip[i].Index = 3519) or

          // 80 LV2
          // amanhecer

           (Self.Character.Equip[i].Index = 12236) or
            (Self.Character.Equip[i].Index = 12729) or
            (Self.Character.Equip[i].Index = 12759) or
            (Self.Character.Equip[i].Index = 12789) or
            (Self.Character.Equip[i].Index = 12819) or

            (Self.Character.Equip[i].Index = 12096) or
            (Self.Character.Equip[i].Index = 12339) or
            (Self.Character.Equip[i].Index = 12489) or
            (Self.Character.Equip[i].Index = 12519) or
            (Self.Character.Equip[i].Index = 12549) or
            (Self.Character.Equip[i].Index = 12579) or

            (Self.Character.Equip[i].Index = 12201) or
            (Self.Character.Equip[i].Index = 12609) or
            (Self.Character.Equip[i].Index = 12639) or
            (Self.Character.Equip[i].Index = 12669) or
            (Self.Character.Equip[i].Index = 12699) or

            (Self.Character.Equip[i].Index = 12228) or
            (Self.Character.Equip[i].Index = 12723) or
            (Self.Character.Equip[i].Index = 12753) or
            (Self.Character.Equip[i].Index = 12783) or
            (Self.Character.Equip[i].Index = 12813) or

            (Self.Character.Equip[i].Index = 12271) or
            (Self.Character.Equip[i].Index = 12849) or
            (Self.Character.Equip[i].Index = 12879) or
            (Self.Character.Equip[i].Index = 12909) or
            (Self.Character.Equip[i].Index = 12939) or

            (Self.Character.Equip[i].Index = 12306) or
            (Self.Character.Equip[i].Index = 12969) or
            (Self.Character.Equip[i].Index = 12999) or
            (Self.Character.Equip[i].Index = 13029) or
            (Self.Character.Equip[i].Index = 13059) or
             //vida
             (Self.Character.Equip[i].Index = 12235) or
            (Self.Character.Equip[i].Index = 12728) or
            (Self.Character.Equip[i].Index = 12758) or
            (Self.Character.Equip[i].Index = 12788) or
            (Self.Character.Equip[i].Index = 12818) or

            (Self.Character.Equip[i].Index = 12095) or
            (Self.Character.Equip[i].Index = 12338) or
            (Self.Character.Equip[i].Index = 12488) or
            (Self.Character.Equip[i].Index = 12518) or
            (Self.Character.Equip[i].Index = 12548) or
            (Self.Character.Equip[i].Index = 12578) or

            (Self.Character.Equip[i].Index = 12200) or
            (Self.Character.Equip[i].Index = 12608) or
            (Self.Character.Equip[i].Index = 12638) or
            (Self.Character.Equip[i].Index = 12668) or
            (Self.Character.Equip[i].Index = 12698) or

            (Self.Character.Equip[i].Index = 12227) or
            (Self.Character.Equip[i].Index = 12722) or
            (Self.Character.Equip[i].Index = 12752) or
            (Self.Character.Equip[i].Index = 12782) or
            (Self.Character.Equip[i].Index = 12812) or

            (Self.Character.Equip[i].Index = 12270) or
            (Self.Character.Equip[i].Index = 12848) or
            (Self.Character.Equip[i].Index = 12878) or
            (Self.Character.Equip[i].Index = 12908) or
            (Self.Character.Equip[i].Index = 12938) or

            (Self.Character.Equip[i].Index = 12305) or
            (Self.Character.Equip[i].Index = 12968) or
            (Self.Character.Equip[i].Index = 12998) or
            (Self.Character.Equip[i].Index = 13028) or
            (Self.Character.Equip[i].Index = 13058) or

            // Crep
            (Self.Character.Equip[i].Index = 12234) or
            (Self.Character.Equip[i].Index = 12727) or
            (Self.Character.Equip[i].Index = 12757) or
            (Self.Character.Equip[i].Index = 12787) or
            (Self.Character.Equip[i].Index = 12817) or

            (Self.Character.Equip[i].Index = 12094) or
            (Self.Character.Equip[i].Index = 12337) or
            (Self.Character.Equip[i].Index = 12487) or
            (Self.Character.Equip[i].Index = 12517) or
            (Self.Character.Equip[i].Index = 12547) or
            (Self.Character.Equip[i].Index = 12577) or

            (Self.Character.Equip[i].Index = 12199) or
            (Self.Character.Equip[i].Index = 12607) or
            (Self.Character.Equip[i].Index = 12637) or
            (Self.Character.Equip[i].Index = 12667) or
            (Self.Character.Equip[i].Index = 12697) or

            (Self.Character.Equip[i].Index = 12226) or
            (Self.Character.Equip[i].Index = 12721) or
            (Self.Character.Equip[i].Index = 12751) or
            (Self.Character.Equip[i].Index = 12781) or
            (Self.Character.Equip[i].Index = 12811) or

            (Self.Character.Equip[i].Index = 12269) or
            (Self.Character.Equip[i].Index = 12847) or
            (Self.Character.Equip[i].Index = 12877) or
            (Self.Character.Equip[i].Index = 12907) or
            (Self.Character.Equip[i].Index = 12937) or

            (Self.Character.Equip[i].Index = 12304) or
            (Self.Character.Equip[i].Index = 12967) or
            (Self.Character.Equip[i].Index = 12997) or
            (Self.Character.Equip[i].Index = 13027) or
            (Self.Character.Equip[i].Index = 13057)  or
            // hora do fim

             (Self.Character.Equip[i].Index = 12233) or
            (Self.Character.Equip[i].Index = 12726) or
            (Self.Character.Equip[i].Index = 12756) or
            (Self.Character.Equip[i].Index = 12786) or
            (Self.Character.Equip[i].Index = 12816) or

            (Self.Character.Equip[i].Index = 12093) or
            (Self.Character.Equip[i].Index = 12336) or
            (Self.Character.Equip[i].Index = 12486) or
            (Self.Character.Equip[i].Index = 12516) or
            (Self.Character.Equip[i].Index = 12546) or
            (Self.Character.Equip[i].Index = 12576) or

            (Self.Character.Equip[i].Index = 12198) or
            (Self.Character.Equip[i].Index = 12606) or
            (Self.Character.Equip[i].Index = 12636) or
            (Self.Character.Equip[i].Index = 12666) or
            (Self.Character.Equip[i].Index = 12696) or

            (Self.Character.Equip[i].Index = 12225) or
            (Self.Character.Equip[i].Index = 12720) or
            (Self.Character.Equip[i].Index = 12750) or
            (Self.Character.Equip[i].Index = 12780) or
            (Self.Character.Equip[i].Index = 12810) or

            (Self.Character.Equip[i].Index = 12268) or
            (Self.Character.Equip[i].Index = 12846) or
            (Self.Character.Equip[i].Index = 12876) or
            (Self.Character.Equip[i].Index = 12906) or
            (Self.Character.Equip[i].Index = 12936) or

            (Self.Character.Equip[i].Index = 12303) or
            (Self.Character.Equip[i].Index = 12966) or
            (Self.Character.Equip[i].Index = 12996) or
            (Self.Character.Equip[i].Index = 13026) or
            (Self.Character.Equip[i].Index = 13056) then





        begin
          ItemCondition3Found := True;
          Break;
        end;
      end;

      // Se os itens não foram encontrados, adicionar um percentual aos atributos
      if not Item11287Found and not ItemCondition2Found then
      begin
        // Exemplo: percentual a ser adicionado (50% no caso)
        const PercentualBonus = MELHORADOR_DANO;

        PlayerCharacter.Base.CurrentScore.DNFis := Trunc(PlayerCharacter.Base.CurrentScore.DNFis * (1 + 0));
        PlayerCharacter.Base.CurrentScore.DNMAG := Trunc(PlayerCharacter.Base.CurrentScore.DNMAG * (1 + 0));
        PlayerCharacter.Base.CurrentScore.DEFFis := Trunc(PlayerCharacter.Base.CurrentScore.DEFFis * (1 + 10000));
        PlayerCharacter.Base.CurrentScore.DEFMAG := Trunc(PlayerCharacter.Base.CurrentScore.DEFMAG * (1 + 10000));
        PlayerCharacter.Base.CurrentScore.BonusDMG := Trunc(PlayerCharacter.Base.CurrentScore.BonusDMG * (1 + 10));
        PlayerCharacter.Base.CurrentScore.Critical := Trunc(PlayerCharacter.Base.CurrentScore.Critical * (1 + 300));
        PlayerCharacter.Base.CurrentScore.Esquiva := Trunc(PlayerCharacter.Base.CurrentScore.Esquiva * (1 + 10));
        PlayerCharacter.Base.CurrentScore.Acerto := Trunc(PlayerCharacter.Base.CurrentScore.Acerto * (1 + 100));
        PlayerCharacter.DuploAtk := Trunc(PlayerCharacter.DuploAtk * (1 + 10));
        PlayerCharacter.SpeedMove := Trunc(PlayerCharacter.SpeedMove * (1 + 0));
        PlayerCharacter.Resistence := Trunc(PlayerCharacter.Resistence * (1 + 10));
        PlayerCharacter.HabAtk := Trunc(PlayerCharacter.HabAtk * (1 + 10));
        PlayerCharacter.DamageCritical := Trunc(PlayerCharacter.DamageCritical * (1 + 10));
        PlayerCharacter.ResDamageCritical := Trunc(PlayerCharacter.ResDamageCritical * (1 + 10));
        PlayerCharacter.MagPenetration := Trunc(PlayerCharacter.MagPenetration * (1 + 10));
        PlayerCharacter.FisPenetration := Trunc(PlayerCharacter.FisPenetration * (1 + 10));
        PlayerCharacter.CureTax := Trunc(PlayerCharacter.CureTax * (1 + 0));
        PlayerCharacter.CritRes := Trunc(PlayerCharacter.CritRes * (1 + 300));
        PlayerCharacter.DuploRes := Trunc(PlayerCharacter.DuploRes * (1 + 10));
        PlayerCharacter.ReduceCooldown := Trunc(PlayerCharacter.ReduceCooldown * (1 + 0));
        PlayerCharacter.PvPDamage := Trunc(PlayerCharacter.PvPDamage * (1 + 5000));
        PlayerCharacter.PvPDefense := Trunc(PlayerCharacter.PvPDefense * (1 + 5000));
      end;
    end;





{$REGION 'Get Status Points'}
var
  MaxedAttributesCount: Integer := 0;

begin
  if not IncCriticalperc(PlayerCharacter.Base.CurrentScore.Str,
                     Character.CurrentScore.Str + Self.GetMobAbility(EF_STR),
                     FORCA_INFO, MaxedAttributesCount) then
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Limite para Força atingido. Não é possível adicionar mais pontos.');

  if not IncCriticalperc(PlayerCharacter.Base.CurrentScore.agility,
                     Character.CurrentScore.agility + Self.GetMobAbility(EF_DEX),
                     AGILIDADE_INFO, MaxedAttributesCount) then
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Limite para Agilidade atingido. Não é possível adicionar mais pontos.');

  if not IncCriticalperc(PlayerCharacter.Base.CurrentScore.Int,
                     Character.CurrentScore.Int + Self.GetMobAbility(EF_INT),
                     INTELIGENCIA_INFO, MaxedAttributesCount) then
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Limite para Inteligência atingido. Não é possível adicionar mais pontos.');

  if not IncCriticalperc(PlayerCharacter.Base.CurrentScore.CONS,
                     Character.CurrentScore.CONS + Self.GetMobAbility(EF_CON),
                     CONSTITUICAO_INFO, MaxedAttributesCount) then
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Limite para Constituição atingido. Não é possível adicionar mais pontos.');

  if not IncCriticalperc(PlayerCharacter.Base.CurrentScore.luck,
                     Character.CurrentScore.luck + Self.GetMobAbility(EF_SPI),
                     SORTE_INFO, MaxedAttributesCount) then
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Limite para Sorte atingido. Não é possível adicionar mais pontos.');
end;



{$ENDREGION}
{$REGION 'Get Others Status'}
{$REGION 'SpeedMove'}
  IncSpeedMove(PlayerCharacter.SpeedMove, (40 + Self.GetMobAbility(EF_RUNSPEED)));
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncSpeedMove(PlayerCharacter.SpeedMove, Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_RUNSPEED]);
{$ENDREGION}
{$REGION 'Duplo Atk'}

  // Definindo limites para cada chamada
IncCritical(PlayerCharacter.DuploAtk,
  Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.21), DUPLO_ATAQUE_INFO); // Exemplo de limite 2000 para o atributo DuploAtk com base em força

// Se desejar utilizar essa linha, forneça um limite específico
IncCritical(PlayerCharacter.DuploAtk,
  Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.25), DUPLO_ATAQUE_INFO); // Exemplo de limite 1500 para atributo DuploAtk com base em agilidade

IncCritical(PlayerCharacter.DuploAtk,
  Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_DOUBLE], DUPLO_ATAQUE_INFO); // Exemplo de limite para efeitos de relíquia

IncCritical(PlayerCharacter.DuploAtk,
  Self.GetMobAbility(EF_DOUBLE), DUPLO_ATAQUE_INFO); // Exemplo de limite para habilidades de mob com efeito duplo

{$ENDREGION}
{$REGION 'Critical'}


    const
      MELHORADOR_CRITICAL = MELHORADOR_TAXA_CRITICO; // Incremento de 10%
    const
       CRITICAL_RESISTANCE_RATIO = 0.1; // 10% de impacto recíproco



    begin
      if Item11286Found then
      begin
        IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
          Trunc(PlayerCharacter.Base.CurrentScore.Critical + MELHORADOR_CRITICAL), TAXA_CRITICO_INFO);
      end

      else

      if Item11287Found then
      begin
        IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
          Trunc(PlayerCharacter.Base.CurrentScore.Critical + MELHORADOR_TAXA_CRITICO5), TAXA_CRITICO_INFO);
      end;


      IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
        Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.13), TAXA_CRITICO_INFO);

      if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
          Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_CRITICAL], TAXA_CRITICO_INFO);
      end;

      IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
        Self.GetMobAbility(EF_CRITICAL), TAXA_CRITICO_INFO);
    end;




  {IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.13), TAXA_CRITICO_INFO);

// IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
//     Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.2), 1600);

if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
        Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_CRITICAL], TAXA_CRITICO_INFO);

IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
    Self.GetMobAbility(EF_CRITICAL), TAXA_CRITICO_INFO);}

{$ENDREGION}
{$REGION 'Damage Critical'}


// Ajustar DamageCritical com base no item 11286
begin
  if Item11286Found then
  begin
    // Incrementar dano crítico em 10% do valor atual
    IncCritical(PlayerCharacter.DamageCritical,
      Trunc(PlayerCharacter.DamageCritical + MELHORADOR_DANO_CRITICO), DANO_CRITICO_INFO);
  end

  else

   if Item11287Found then
  begin
    // Incrementar dano crítico em 5% do valor atual
    IncCritical(PlayerCharacter.DamageCritical,
      Trunc(PlayerCharacter.DamageCritical + MELHORADOR_DANO_CRITICO5), DANO_CRITICO_INFO);
  end;



  //Adicionar bônus padrão de força ao dano crítico
  IncCritical(PlayerCharacter.DamageCritical,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.2), DANO_CRITICO_INFO);

  // Adicionar bônus de habilidade ao dano crítico
  IncCritical(PlayerCharacter.DamageCritical,
    Self.GetMobAbility(EF_CRITICAL_POWER), DANO_CRITICO_INFO);

end;

  {IncCritical(PlayerCharacter.DamageCritical,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.2), DANO_CRITICO_INFO);

// IncCritical(PlayerCharacter.DamageCritical,
//     Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.2), 2000);

IncCritical(PlayerCharacter.DamageCritical,
    Self.GetMobAbility(EF_CRITICAL_POWER), DANO_CRITICO_INFO); }

{$ENDREGION}
{$REGION 'Penetration Fis and Mag'}
  IncCooldown(PlayerCharacter.FisPenetration,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.04));
  IncCooldown(PlayerCharacter.MagPenetration,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.34));
  IncCooldown(PlayerCharacter.FisPenetration,
    Self.GetMobAbility(EF_PIERCING_RESISTANCE1));
  IncCooldown(PlayerCharacter.MagPenetration,
    Self.GetMobAbility(EF_PIERCING_RESISTANCE2));
{$ENDREGION}
{$REGION 'PvP Damage'}
  // Aumentar PvPDamage com base na lógica do item 11286
begin
  if Item11286Found then
  begin
    // Incrementar PvPDamage com 10% do valor atual
    IncWord(PlayerCharacter.PvPDamage,
      Trunc(PlayerCharacter.PvPDamage + MELHORADOR_PVP_DAMAGE)); // MELHORADOR_PVP_DAMAGE = 0.1 para 10%
  end
  else
  if Item11287Found then
  begin
    // Incrementar PvPDamage com 10% do valor atual
    IncWord(PlayerCharacter.PvPDamage,
      Trunc(PlayerCharacter.PvPDamage + MELHORADOR_PVP_DAMAGE5)); // MELHORADOR_PVP_DAMAGE = 0.1 para 10%
  end


  else
  begin
    // Incrementar PvPDamage com o valor padrão da habilidade
    IncWord(PlayerCharacter.PvPDamage, Self.GetMobAbility(EF_ATK_NATION2));


  end;

  PlayerCharacter.PvPDamage:= PlayerCharacter.PvPDamage div 2;
end;


{$ENDREGION}
{$REGION 'PvP Defense'}
  // Aumentar PvPDefense com base na lógica do item 11286
    begin
      if Item11286Found then
      begin
        // Incrementar PvPDefense com 10% do valor atual
        IncWord(PlayerCharacter.PvPDefense,
          Trunc(PlayerCharacter.PvPDefense + MELHORADOR_PVP_DEFENSE)); // MELHORADOR_PVP_DEFENSE = 0.1 para 10%
      end
      else
      if Item11287Found then
      begin
        // Incrementar PvPDefense com 10% do valor atual
        IncWord(PlayerCharacter.PvPDefense,
          Trunc(PlayerCharacter.PvPDefense + MELHORADOR_PVP_DEFENSE)); // MELHORADOR_PVP_DEFENSE = 0.1 para 10%
      end
      else
      begin
        // Incrementar PvPDefense com o valor padrão da habilidade
        IncWord(PlayerCharacter.PvPDefense, Self.GetMobAbility(EF_DEF_NATION2));
      end;

      PlayerCharacter.PvPDefense:=PlayerCharacter.PvPDefense div 2
    end;

{$ENDREGION}

{$REGION 'Hab Skill Atk'}
    // Incremento baseado em Luck
    IncWORD(PlayerCharacter.HabAtk, (PlayerCharacter.Base.CurrentScore.Luck * 10));
    if PlayerCharacter.HabAtk = MAX_HAB_ATK then
    begin
      // Registra o evento no log usando Logger.Write
      Logger.Write('Player ' + PlayerCharacter.base.Name + ' foi desconectado por alcançar o limite máximo de HabAtk: '
        + PlayerCharacter.HabAtk.ToString , TLogType.Error);

      // Envia uma mensagem ao jogador antes de desconectá-lo
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
        'Você foi desconectado por alcançar o limite máximo de HabAtk: ' + PlayerCharacter.HabAtk.ToString);

      // Desconecta o jogador
      Servers[Self.ChannelId].Players[Self.ClientID].Disconnect;

      Exit; // Sai da função para evitar processamento adicional
    end;

    // Incremento baseado em Mob Ability
    IncWORD(PlayerCharacter.HabAtk, Self.GetMobAbility(EF_SKILL_DAMAGE));
    if PlayerCharacter.HabAtk = MAX_HAB_ATK then
    begin
      // Registra o evento no log usando Logger.Write
      Logger.Write('Player ' + PlayerCharacter.Base.Name + ' foi desconectado por alcançar o limite máximo de HabAtk: '
        + PlayerCharacter.HabAtk.ToString , TLogType.Error);

      // Envia uma mensagem ao jogador antes de desconectá-lo
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
        'Você foi desconectado por alcançar o limite máximo de HabAtk: ' + PlayerCharacter.HabAtk.ToString);

      // Desconecta o jogador
      Servers[Self.ChannelId].Players[Self.ClientID].Disconnect;

      Exit; // Sai da função para evitar processamento adicional
    end;
{$ENDREGION}

{$REGION 'Cure Tax'}
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.7), TAXA_DE_CURA_INFO);

IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.Cons * 0.3), TAXA_DE_CURA_INFO);

IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.2), TAXA_DE_CURA_INFO);

IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.1), TAXA_DE_CURA_INFO);

// IncCritical(PlayerCharacter.CureTax,
//     Self.GetMobAbility(EF_SKILL_DAMAGE6), 5000);

{$ENDREGION}
{$REGION 'Res Crit'}




    const
      MELHORADOR_RESISTENCIA_CRITICO = MELHORADOR_RESTAX_CRITICO; // Incremento de 10%


      // Incremento condicional com base no item 11286
      if ItemCondition2Found then
      begin
        if Item11286Found then
        begin
          IncCritical(PlayerCharacter.CritRes,
            Trunc(PlayerCharacter.CritRes + MELHORADOR_RESISTENCIA_CRITICO), RESISTENCIA_TAXA_CRITICO_INFO);
        end
      end

      else

      if ItemCondition3Found then
      begin
        if Item11287Found then
        begin
          IncCritical(PlayerCharacter.CritRes,
            Trunc(PlayerCharacter.CritRes + MELHORADOR_RESTAX_CRITICO5), RESISTENCIA_TAXA_CRITICO_INFO);
        end;
      end;


  // Incrementos padrão baseados em atributos
  IncCritical(PlayerCharacter.CritRes,
    Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.7), RESISTENCIA_TAXA_CRITICO_INFO); // 10 cons = 3 rescrit

 // IncCritical(PlayerCharacter.CritRes,
 //   Trunc(PlayerCharacter.Base.CurrentScore.luck * 0.2), RESISTENCIA_TAXA_CRITICO_INFO); // 10 luck = 2 rescrit

  // Incremento baseado na habilidade do personagem
  IncCritical(PlayerCharacter.CritRes,
    Self.GetMobAbility(EF_RESISTANCE6), RESISTENCIA_TAXA_CRITICO_INFO);


 {IncCritical(PlayerCharacter.CritRes,
 Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.15), RESISTENCIA_TAXA_CRITICO_INFO); // 10 cons = 3 rescrit

IncCritical(PlayerCharacter.CritRes,
Trunc(PlayerCharacter.Base.CurrentScore.luck * 0.2), RESISTENCIA_TAXA_CRITICO_INFO); // 10 luck = 2 rescrit

IncCritical(PlayerCharacter.CritRes,
Self.GetMobAbility(EF_RESISTANCE6), RESISTENCIA_TAXA_CRITICO_INFO); }

{$ENDREGION}
{$REGION 'Res Damage Crit'}


const
  MELHORADOR_RES_DANO_CRITICO = MELHORADOR_RESDANO_CRITICO; // Incremento de 10%


  // Incremento condicional com base no item 11286

  if ItemCondition2Found then
    begin
       if Item11286Found then
        begin
          IncCritical(PlayerCharacter.ResDamageCritical,
            Trunc(PlayerCharacter.ResDamageCritical +  MELHORADOR_RES_DANO_CRITICO), RESISTENCIA_A_DANO_CRITICO_INFO);
        end
    end

  else

   if ItemCondition3Found then
   begin
     if Item11287Found then
    begin
      IncCritical(PlayerCharacter.ResDamageCritical,
        Trunc(PlayerCharacter.ResDamageCritical +   MELHORADOR_RESDANO_CRITICO5), RESISTENCIA_A_DANO_CRITICO_INFO);
    end;
   end;


        // Incrementos padrão baseados em atributos
      IncCritical(PlayerCharacter.ResDamageCritical,
        Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.1), RESISTENCIA_A_DANO_CRITICO_INFO); // 10 cons = 10 res damage crit

      // Incremento baseado na habilidade do personagem
      IncCritical(PlayerCharacter.ResDamageCritical,
        Self.GetMobAbility(EF_CRITICAL_DEFENCE), RESISTENCIA_A_DANO_CRITICO_INFO);



 { IncCritical(PlayerCharacter.ResDamageCritical,
  Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.7), RESISTENCIA_A_DANO_CRITICO_INFO); // 10 cons = 10 res damage crit

IncCritical(PlayerCharacter.ResDamageCritical, Self.GetMobAbility(EF_CRITICAL_DEFENCE), RESISTENCIA_A_DANO_CRITICO_INFO);   }

{$ENDREGION}
{$REGION 'Res Duplo'}
  IncCritical(PlayerCharacter.DuploRes, Trunc(PlayerCharacter.Base.CurrentScore.CONS
    * 0.34), RESISTENCIA_A_DUPLO_INFO); // 10 cons = 2 res duplo
  IncCritical(PlayerCharacter.DuploRes, Self.GetMobAbility(EF_RESISTANCE7),RESISTENCIA_A_DUPLO_INFO);
{$ENDREGION}



{$REGION 'Acerto'}
begin
  // Incrementa Acerto com base na agilidade
  IncByte(PlayerCharacter.Base.CurrentScore.Acerto,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.1), ACERTO_INFO);

  // Incrementa Acerto com base no bônus da nação
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncByte(PlayerCharacter.Base.CurrentScore.Acerto,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_HIT], ACERTO_INFO);

  // Incrementa Acerto com base nas habilidades do mob
  IncByte(PlayerCharacter.Base.CurrentScore.Acerto,
    Self.GetMobAbility(EF_HIT), ACERTO_INFO);


end;
{$ENDREGION}



{$ENDREGION}
{$REGION 'Esquiva'}

  IncByte(PlayerCharacter.Base.CurrentScore.Esquiva,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.1),ESQUIVA_INFO);
  //IncByte(PlayerCharacter.Base.CurrentScore.Esquiva,
    //Trunc(PlayerCharacter.Base.CurrentScore.luck * 0.3));
  IncByte(PlayerCharacter.Base.CurrentScore.Esquiva,
    Self.GetMobAbility(EF_PRAN_PARRY),ESQUIVA_INFO);
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncByte(PlayerCharacter.Base.CurrentScore.Esquiva,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PARRY],ESQUIVA_INFO);
  IncByte(PlayerCharacter.Base.CurrentScore.Esquiva,
    Self.GetMobAbility(EF_PARRY),ESQUIVA_INFO);



{$ENDREGION}
{$REGION 'Resistence'}
  IncCritical(PlayerCharacter.Resistence, //resistencia a status anormais, colocar no valid atk
    Round(PlayerCharacter.Base.CurrentScore.Luck * 0.1),RESISTENCIA_INFO);
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCritical(PlayerCharacter.Resistence,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_STATE_RESISTANCE],RESISTENCIA_INFO);
  IncCritical(PlayerCharacter.Resistence, Self.GetMobAbility(EF_STATE_RESISTANCE),RESISTENCIA_INFO);
{$ENDREGION}




{$REGION 'Cooldown Time'}
  IncCooldown(PlayerCharacter.ReduceCooldown,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.25));
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCooldown(PlayerCharacter.ReduceCooldown, Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_COOLTIME]);
  IncCooldown(PlayerCharacter.ReduceCooldown, Self.GetMobAbility(EF_COOLTIME));
{$ENDREGION}





{$REGION 'Get Def'}
  begin
  Self.GetEquipsDefense;

  // Se o item 11285 não estiver no inventário, zere as defesas
  if ItemConditionFound and not Item11285Found then
  begin
    PlayerCharacter.Base.CurrentScore.DEFFis := 0;
    PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  end
  else if ItemCondition2Found then
  begin
    if Item11286Found then
    begin
      // Aumentar o valor atual de DEFFis em 10%, mas limitado a 65535
      PlayerCharacter.Base.CurrentScore.DEFFis :=
        Min(65534, PlayerCharacter.Base.CurrentScore.DEFFis +
        Trunc(PlayerCharacter.Base.CurrentScore.DEFFis * MELHORADOR_DEFIS));

      // Aumentar o valor atual de DEFMAG em 10%, mas limitado a 65535
      PlayerCharacter.Base.CurrentScore.DEFMAG :=
        Min(65534, PlayerCharacter.Base.CurrentScore.DEFMAG +
        Trunc(PlayerCharacter.Base.CurrentScore.DEFMAG * MELHORADOR_DEMAG));
    end;
  end
  else if ItemCondition3Found then
  begin
    if Item11287Found then
    begin
      // Aumentar o valor atual de DEFFis em 5%, mas limitado a 65535
      PlayerCharacter.Base.CurrentScore.DEFFis :=
        Min(65534, PlayerCharacter.Base.CurrentScore.DEFFis +
        Trunc(PlayerCharacter.Base.CurrentScore.DEFFis * MELHORADOR_DEFIS5));

      // Aumentar o valor atual de DEFMAG em 5%, mas limitado a 65535
      PlayerCharacter.Base.CurrentScore.DEFMAG :=
        Min(65534, PlayerCharacter.Base.CurrentScore.DEFMAG +
        Trunc(PlayerCharacter.Base.CurrentScore.DEFMAG * MELHORADOR_DEMAG5));
    end;
  end;

  // Aplicação de bônus de resistência e buffs
  begin
    Def_perc := Self.GetMobAbility(EF_PER_RESISTANCE1);
    IncWord(PlayerCharacter.Base.CurrentScore.DEFFis,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DEFFis,
      Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFFis div 100))));

    if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      Def_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_RESISTANCE1];

    Def_perc := Self.GetMobAbility(EF_PER_RESISTANCE2);
    IncWord(PlayerCharacter.Base.CurrentScore.DEFMAG,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DEFMAG,
      Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFMAG div 100))));

    if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      Def_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_RESISTANCE2];

    // Aplicação de habilidades
    IncWord(PlayerCharacter.Base.CurrentScore.DEFFis,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DEFFis, Self.GetMobAbility(EF_RESISTANCE1)));

    IncWord(PlayerCharacter.Base.CurrentScore.DEFMAG,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DEFMAG, Self.GetMobAbility(EF_RESISTANCE2)));

    IncWord(PlayerCharacter.Base.CurrentScore.DEFFis,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DEFFis, Self.GetMobAbility(EF_PRAN_RESISTANCE1)));

    IncWord(PlayerCharacter.Base.CurrentScore.DEFMAG,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DEFMAG, Self.GetMobAbility(EF_PRAN_RESISTANCE2)));

    // Aplicar a conversão de defesa física e mágica
   PlayerCharacter.Base.CurrentScore.DEFFis := Min(65534, PlayerCharacter.Base.CurrentScore.DEFFis );
   PlayerCharacter.Base.CurrentScore.DEFMAG := Min(65534, PlayerCharacter.Base.CurrentScore.DEFMAG );

    // Se tiver efeito de remoção de armadura, define defesa como 0
    if (Self.GetMobAbility(EF_UNARMOR) > 0) then
    begin
      PlayerCharacter.Base.CurrentScore.DEFFis := 0;
      PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
    end;
  end;
end;

  {$ENDREGION}

{$REGION 'Get Atk'}
  begin
  Self.GetEquipDamage(Self.Character.Equip[6]);

  {$REGION 'Atk Fis'}
  // Se o item 11285 não estiver no inventário, zere o ataque físico
  if ItemConditionFound and not Item11285Found then
  begin
    PlayerCharacter.Base.CurrentScore.DNFis := 0;
  end
  else if ItemCondition2Found then
  begin
    if Item11286Found then
    begin
      // Aumentar o valor atual de DNFis em 10%, mas limitado a 65535
      PlayerCharacter.Base.CurrentScore.DNFis :=
        Min(65534, PlayerCharacter.Base.CurrentScore.DNFis +
        Trunc(PlayerCharacter.Base.CurrentScore.DNFis * MELHORADOR_DANO));
    end;
  end
  else if ItemCondition3Found then
  begin
    if Item11287Found then
    begin
      // Aumentar o valor atual de DNFis em 5%, mas limitado a 65535
      PlayerCharacter.Base.CurrentScore.DNFis :=
        Min(65534, PlayerCharacter.Base.CurrentScore.DNFis +
        Trunc(PlayerCharacter.Base.CurrentScore.DNFis * MELHORADOR_DANO5));
    end;
  end;

  begin
    // Aplicação de atributos base ao dano físico
    IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DNFis,
      Trunc(PlayerCharacter.Base.CurrentScore.Str * 2.6)));

    IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DNFis,
      Trunc(PlayerCharacter.Base.CurrentScore.Agility * 2.6)));

    IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DNFis,
      Self.GetMobAbility(EF_PRAN_DAMAGE1)));

    // Aplicação de buffs de porcentagem
    Damage_perc := Self.GetMobAbility(EF_PER_DAMAGE1);
    IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DNFis,
      Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) * Damage_perc)));

    // Aplicação de buffs baseados na Nação do personagem
    if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    begin
      Damage_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_DAMAGE1];
      IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
        Min(65534 - PlayerCharacter.Base.CurrentScore.DNFis,
        Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) * Damage_perc)));
    end;

    // Redução de dano caso algum efeito negativo esteja ativo
    DecWord(PlayerCharacter.Base.CurrentScore.DNFis,
      Min(PlayerCharacter.Base.CurrentScore.DNFis,
      Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) *
      Self.GetMobAbility(EF_DECREASE_PER_DAMAGE1))));

    // Aplicação de habilidades que aumentam o dano direto
    IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DNFis,
      Self.GetMobAbility(EF_DAMAGE1)));

    // Aplicar a conversão de 3 pontos para 1
    // Removemos a conversão que multiplicava o dano, pois poderia ultrapassar o limite
    // PlayerCharacter.Base.CurrentScore.DNFis := Min(65535, PlayerCharacter.Base.CurrentScore.DNFis * 3);

    // Limitador final para garantir que DNFis não ultrapasse 65535
    PlayerCharacter.Base.CurrentScore.DNFis := Min(65534, PlayerCharacter.Base.CurrentScore.DNFis) ;
  end;


      {$ENDREGION}
  {$REGION 'Atk Magi'}
      begin
  // Se o item 11285 não estiver no inventário, zere o ataque mágico
  if ItemConditionFound and not Item11285Found then
  begin
    PlayerCharacter.Base.CurrentScore.DNMAG := 0;
  end
  else if ItemCondition2Found then
  begin
    if Item11286Found then
    begin
      // Aumentar o valor atual de DNMAG em 5%, mas limitado a 65535
      PlayerCharacter.Base.CurrentScore.DNMAG :=
        Min(65534, PlayerCharacter.Base.CurrentScore.DNMAG +
        Trunc(PlayerCharacter.Base.CurrentScore.DNMAG * MELHORADOR_DANO));
    end;
  end
  else if ItemCondition3Found then
  begin
    if Item11287Found then
    begin
      // Aumentar o valor atual de DNMAG em 10%, mas limitado a 65535
      PlayerCharacter.Base.CurrentScore.DNMAG :=
        Min(65534, PlayerCharacter.Base.CurrentScore.DNMAG +
        Trunc(PlayerCharacter.Base.CurrentScore.DNMAG * MELHORADOR_DANO5));
    end;
  end;

  begin
    // Aumentar DNMAG com base na inteligência do personagem
    IncWord(PlayerCharacter.Base.CurrentScore.DNMAG,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DNMAG,
      Trunc(PlayerCharacter.Base.CurrentScore.Int * 3.2)));

    // Aumentar DNMAG com base em habilidades do mob
    IncWord(PlayerCharacter.Base.CurrentScore.DNMAG,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DNMAG,
      Self.GetMobAbility(EF_PRAN_DAMAGE2)));

    // Aumentar DNMAG com base em porcentagem de dano
    Damage_perc := Self.GetMobAbility(EF_PER_DAMAGE2);
    IncWord(PlayerCharacter.Base.CurrentScore.DNMAG,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DNMAG,
      Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) * Damage_perc)));

    // Aumentar DNMAG com base no efeito de relíquia da nação
    if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    begin
      Damage_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_DAMAGE2];
      IncWord(PlayerCharacter.Base.CurrentScore.DNMAG,
        Min(65534 - PlayerCharacter.Base.CurrentScore.DNMAG,
        Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) * Damage_perc)));
    end;

    // Reduzir DNMAG com base em habilidades do mob
    DecWord(PlayerCharacter.Base.CurrentScore.DNMAG,
      Min(PlayerCharacter.Base.CurrentScore.DNMAG,
      Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) *
      Self.GetMobAbility(EF_DECREASE_PER_DAMAGE2))));

    // Aumentar DNMAG com base em habilidades do mob
    IncWord(PlayerCharacter.Base.CurrentScore.DNMAG,
      Min(65534 - PlayerCharacter.Base.CurrentScore.DNMAG,
      Self.GetMobAbility(EF_DAMAGE2)));

    // Aplicar a conversão de 3 pontos para 1
    // Removemos a conversão que multiplicava o dano, pois poderia ultrapassar o limite
    // PlayerCharacter.Base.CurrentScore.DNMAG := Min(65535, PlayerCharacter.Base.CurrentScore.DNMAG * 3);

    // Limitador final para garantir que DNMAG não ultrapasse 65535
   PlayerCharacter.Base.CurrentScore.DNMAG := Min(65534, PlayerCharacter.Base.CurrentScore.DNMAG);
  end;
end;

    {$ENDREGION}
  end;





  // Ajustes adicionais para dano crítico e resistência a dano crítico
begin
  // 1. Caso o dano crítico ultrapasse 1200, a resistência deve ser fixada em 800
 const
  MaxResDamageCritical = 200; // Valor máximo permitido para resistência a dano crítico
  begin
    if PlayerCharacter.DamageCritical > 1200 then
    begin
      // Verifica se a resistência atual excede o limite
      if PlayerCharacter.ResDamageCritical > MaxResDamageCritical then
      begin
        PlayerCharacter.ResDamageCritical := MaxResDamageCritical;

        // Log opcional para depuração
        // WriteLn(Format('Resistência a dano crítico limitada a %d devido ao dano crítico > 1200.',
        //   [MaxResDamageCritical]));
      end;
    end;
  end;

  // Limitar o dano crítico caso a resistência ultrapasse 1200
  const
    MaxDamageCritical = 200; // Valor máximo permitido para dano crítico
  begin
    if PlayerCharacter.ResDamageCritical > 1200 then
         begin
        // Verifica se o dano crítico atual excede o limite permitido
        if PlayerCharacter.DamageCritical > MaxDamageCritical then
        begin
          PlayerCharacter.DamageCritical := MaxDamageCritical;

          // Log opcional para depuração
          // WriteLn(Format('Dano crítico limitado a %d devido à resistência > 1200.',
          //   [MaxDamageCritical]));
        end;
      end;
     end;


     /// ajuste de limitador entre classes taxa critixca e resistencia a taxa critica


  // Ajustes adicionais para taxa crítico e resistência a taxa crítico
    begin
      // 1. Caso o dano crítico ultrapasse 1200, a resistência deve ser fixada em 800
     const
      MaxResCritical = 200; // Valor máximo permitido para resistência a dano crítico
      begin
        if PlayerCharacter.Base.CurrentScore.Critical > 1200 then
        begin
          // Verifica se a resistência atual excede o limite
          if PlayerCharacter.CritRes> MaxResCritical  then
          begin
            PlayerCharacter.CritRes := MaxResCritical ;

            // Log opcional para depuração
            // WriteLn(Format('Resistência a taxa crítico limitada a %d devido ao dano crítico > 1200.',
            //   [MaxResDamageCritical]));
          end;
        end;
      end;

      // Limitar o taxa crítico caso a resistência ultrapasse 1200
      const
        MaxCritical = 200; // Valor máximo permitido para dano crítico
      begin
        if PlayerCharacter.CritRes > 1200 then
             begin
            // Verifica se o dano crítico atual excede o limite permitido
            if PlayerCharacter.Base.CurrentScore.Critical> MaxCritical then
            begin
              PlayerCharacter.Base.CurrentScore.Critical := MaxCritical;

              // Log opcional para depuração
              // WriteLn(Format('Dano crítico limitado a %d devido à resistência > 1200.',
              //   [MaxDamageCritical]));
            end;
          end;
         end;
    end;


    // limitador de ataque fisico magifo e defesa fisica e magica

      const
        Maxfis = 19830; // Valor máximo permitido para dano crítico
      begin
        if PlayerCharacter.Base.CurrentScore.DNFis   > 26213then
             begin
            // Verifica se o dano crítico atual excede o limite permitido
            if PlayerCharacter.Base.CurrentScore.DNMAG>  Maxfis then
            begin
              PlayerCharacter.Base.CurrentScore.DNMAG :=  Maxfis;

              // Log opcional para depuração
              // WriteLn(Format('Dano crítico limitado a %d devido à resistência > 1200.',
              //   [MaxDamageCritical]));
            end;
          end;
         end;

         const
        MaxMag = 19830; // Valor máximo permitido para dano crítico
      begin
        if PlayerCharacter.Base.CurrentScore.DEFFis   > 26213 then
             begin
            // Verifica se o dano crítico atual excede o limite permitido
            if PlayerCharacter.Base.CurrentScore.DEFMAG>  MaxMag then
            begin
              PlayerCharacter.Base.CurrentScore.DEFMAG :=  MaxMag;

              // Log opcional para depuração
              // WriteLn(Format('Dano crítico limitado a %d devido à resistência > 1200.',
              //   [MaxDamageCritical]));
            end;
          end;
         end;


         const
        MaxMagi = 19830; // Valor máximo permitido para dano crítico
      begin
        if PlayerCharacter.Base.CurrentScore.DNMAG   > 23213 then
             begin
            // Verifica se o dano crítico atual excede o limite permitido
            if PlayerCharacter.Base.CurrentScore.DNFis>  MaxMagi then
            begin
              PlayerCharacter.Base.CurrentScore.DNFis :=  MaxMagi;

              // Log opcional para depuração
              // WriteLn(Format('Dano crítico limitado a %d devido à resistência > 1200.',
              //   [MaxDamageCritical]));
            end;
          end;
         end;


            const
        Maxfisc = 19830; // Valor máximo permitido para dano crítico
      begin
        if PlayerCharacter.Base.CurrentScore.DEFMAG   > 26213 then
             begin
            // Verifica se o dano crítico atual excede o limite permitido
            if PlayerCharacter.Base.CurrentScore.DEFFis>  Maxfisc then
            begin
              PlayerCharacter.Base.CurrentScore.DEFFis :=  Maxfisc;

              // Log opcional para depuração
              // WriteLn(Format('Dano crítico limitado a %d devido à resistência > 1200.',
              //   [MaxDamageCritical]));
            end;
          end;
         end;










  // 1. Caso o dano crítico ultrapasse 1200, dano pvp
 const
   MaxPvPDefense = 100 ; // Valor máximo permitido para PvP Damage
  begin
    // Caso o PvP Damage ultrapasse 1200, limitar ao máximo permitido
    if PlayerCharacter.PvPDamage > 1200 then
      begin
        PlayerCharacter.PvPDamage  := PlayerCharacter.PvPDamage
        + trunc((PlayerCharacter.PvPDamage div 100) * 1);

          begin
            // Verifica se o PvP Damage atual excede o limite
            if PlayerCharacter.PvPDefense > MaxPvPDefense then
            begin
              PlayerCharacter.PvPDefense := MaxPvPDefense;

              // Log opcional para depuração
              // WriteLn(Format('Defesa PvP limitada a %d devido ao PvP Damage > 1200.',
              //   [MaxPvPDamage]));
            end;
        end;
      end;

  end;


   // 2. Caso o dano crítico ultrapasse 1200, resistencia pvp
  const
  MaxPvPDamage = 100;  // Valor máximo permitido para PvP Defense
  begin
    // Caso o PvP Damage ultrapasse 1200, limitar o PvP Defense
    if PlayerCharacter.PvPDefense > 1200 then
    begin
      PlayerCharacter.PvPDamage  := PlayerCharacter.PvPDamage +
       trunc((PlayerCharacter.PvPDamage div 100) * 1) ;

      begin
        // Verifica se o PvP Defense atual excede o limite
        if PlayerCharacter.PvPDamage > MaxPvPDamage then
        begin
          PlayerCharacter.PvPDamage := MaxPvPDamage;

          // Log opcional para depuração
          // WriteLn(Format('PvP Defense limitado a %d devido ao PvP Damage > 1200.',
          //   [MaxPvPDefense]));
        end;
      end;
    end;
  end;







  // 3. Caso a resistência ultrapasse 1000, adicionar +700 à resistência
 { if PlayerCharacter.ResDamageCritical > 900 then
  begin
    PlayerCharacter.ResDamageCritical := PlayerCharacter.ResDamageCritical + 700;

    // Ajustar dano crítico para 300, conforme a nova condição
    PlayerCharacter.DamageCritical := 300;

    // Log opcional para depuração
   // WriteLn(Format('Resistência a dano crítico aumentada em 500. Novo valor: %d. Dano crítico ajustado para 400.',
   //   [PlayerCharacter.ResDamageCritical]));
  end; }

  // 4. Comparação entre dano crítico e resistência a dano crítico
 { Difference := PlayerCharacter.ResDamageCritical - PlayerCharacter.DamageCritical;

  if (Abs(Difference) >= 0) and (Abs(Difference) <= 400) then
  begin
    // Reduz o dano crítico em 50%
    PlayerCharacter.DamageCritical := PlayerCharacter.DamageCritical div 2;

    // Log opcional para depuração
    //WriteLn(Format('Dano crítico ajustado devido à diferença com resistência a dano crítico: %d',
    //  [PlayerCharacter.DamageCritical]));
  end; }


 // Verificação e ajuste do valor máximo de Acerto e Esquiva
  const
    MAX_ACERTO = 255; // Limite máximo para Acerto
    begin
    // Limitar o valor de Acerto
    if PlayerCharacter.Base.CurrentScore.Acerto > MAX_ACERTO then
      PlayerCharacter.Base.CurrentScore.Acerto := MAX_ACERTO;

  end;

  const
    MAX_ESQUIVA = 255 ; // Limite máximo para Acerto
    begin
    // Limitar o valor de Acerto
    // Limitar o valor de Esquiva
  if PlayerCharacter.Base.CurrentScore.Esquiva > MAX_ESQUIVA then
    PlayerCharacter.Base.CurrentScore.Esquiva := MAX_ESQUIVA;

  end;


    // Incremento baseado no dano crítico alcançado
  if PlayerCharacter.DamageCritical > 0 then
  begin
    // Calcula os pontos bônus diretamente e adiciona ao valor atual
    PlayerCharacter.DamageCritical := PlayerCharacter.DamageCritical +
      trunc((PlayerCharacter.DamageCritical div 100) * TDANOCRITICO);

    // Log opcional para depuração
    // WriteLn(Format('Dano crítico incrementado. Novo valor: %d', [PlayerCharacter.DamageCritical]));
  end;


  // Incremento baseado no dano demage crítico alcançado
  if PlayerCharacter.ResDamageCritical  > 0 then
  begin
    // Calcula os pontos bônus diretamente e adiciona ao valor atual
    PlayerCharacter.ResDamageCritical  := PlayerCharacter.ResDamageCritical  +
      trunc((PlayerCharacter.ResDamageCritical  div 100) * TRESDANOCRITICO);

    // Log opcional para depuração
    // WriteLn(Format('Dano crítico incrementado. Novo valor: %d', [PlayerCharacter.DamageCritical]));
  end;

   // Incremento baseado no dano taxa crítico alcançado
  if PlayerCharacter.CritRes > 0 then
  begin
    // Calcula os pontos bônus diretamente e adiciona ao valor atual
    PlayerCharacter.CritRes := PlayerCharacter.CritRes +
      trunc((PlayerCharacter.CritRes div 100) * TTAXACRITICA);

    // Log opcional para depuração
    // WriteLn(Format('Dano crítico incrementado. Novo valor: %d', [PlayerCharacter.DamageCritical]));
  end;

  if PlayerCharacter.Base.CurrentScore.Critical > 0 then
  begin
    // Calcula os pontos bônus diretamente e adiciona ao valor atual
    PlayerCharacter.Base.CurrentScore.Critical  := PlayerCharacter.Base.CurrentScore.Critical  +
      trunc((PlayerCharacter.Base.CurrentScore.Critical  div 100) * TRESTAXACRITICA);

    // Log opcional para depuração
    // WriteLn(Format('Dano crítico incrementado. Novo valor: %d', [PlayerCharacter.DamageCritical]));
  end;














 // Incremento baseado taxa crítico alcançado
 {if PlayerCharacter.ResDamageCritical > 1200 then
 begin
  if PlayerCharacter.Base.CurrentScore.Critical > 0 then
  begin
    // Calcula os pontos bônus diretamente e adiciona ao valor atual
    PlayerCharacter.Base.CurrentScore.Critical := PlayerCharacter.Base.CurrentScore.Critical +
      trunc((PlayerCharacter.Base.CurrentScore.Critical div 100) * 50);

      PlayerCharacter.CritRes := PlayerCharacter.CritRes +
        trunc((PlayerCharacter.CritRes div 100) * 30);


    // Log opcional para depuração
    // WriteLn(Format('Dano crítico incrementado. Novo valor: %d', [PlayerCharacter.DamageCritical]));
  end;
 end;



  // Incremento baseado no dano resistencia  crítico alcançado
 if PlayerCharacter.DamageCritical > 1200 then
 begin
    if PlayerCharacter.CritRes > 0 then
    begin
      // Calcula os pontos bônus diretamente e adiciona ao valor atual
     PlayerCharacter.CritRes := PlayerCharacter.CritRes +
        trunc((PlayerCharacter.CritRes div 100) * 50);

      // Log opcional para depuração
      // WriteLn(Format('Dano crítico incrementado. Novo valor: %d', [PlayerCharacter.DamageCritical]));
    end;
 end;}







  // Comparação entre dano crítico e resistência a dano crítico
 { begin
    Difference := PlayerCharacter.ResDamageCritical - PlayerCharacter.DamageCritical;

    if (Abs(Difference) >= 0) and (Abs(Difference) <= 400) then
    begin
      // Reduz o dano crítico em 50%
      PlayerCharacter.DamageCritical := PlayerCharacter.DamageCritical div 4;

      // Log opcional para depuração
      //WriteLn(Format('Dano crítico ajustado devido à diferença com resistência a dano crítico: %d', [PlayerCharacter.DamageCritical]));
    end;
  end;   }



  // Coletar todos os status em uma string formatada
  StatusLog := Format(
    'DNFis: %d, DNMAG: %d, DEFFis: %d, DEFMAG: %d, BonusDMG: %d, Critical: %d, ' +
    'Esquiva: %d, Acerto: %d, DuploAtk: %d, SpeedMove: %d, Resistence: %d, ' +
    'HabAtk: %d, DamageCritical: %d, ResDamageCritical: %d, MagPenetration: %d, ' +
    'FisPenetration: %d, CureTax: %d, CritRes: %d, DuploRes: %d, ReduceCooldown: %d, ' +
    'PvPDamage: %d, PvPDefense: %d',
    [
      PlayerCharacter.Base.CurrentScore.DNFis,
      PlayerCharacter.Base.CurrentScore.DNMAG,
      PlayerCharacter.Base.CurrentScore.DEFFis,
      PlayerCharacter.Base.CurrentScore.DEFMAG,
      PlayerCharacter.Base.CurrentScore.BonusDMG,
      PlayerCharacter.Base.CurrentScore.Critical,
      PlayerCharacter.Base.CurrentScore.Esquiva,
      PlayerCharacter.Base.CurrentScore.Acerto,
      PlayerCharacter.DuploAtk,
      PlayerCharacter.SpeedMove,
      PlayerCharacter.Resistence,
      PlayerCharacter.HabAtk,
      PlayerCharacter.DamageCritical,
      PlayerCharacter.ResDamageCritical,
      PlayerCharacter.MagPenetration,
      PlayerCharacter.FisPenetration,
      PlayerCharacter.CureTax,
      PlayerCharacter.CritRes,
      PlayerCharacter.DuploRes,
      PlayerCharacter.ReduceCooldown,
      PlayerCharacter.PvPDamage,
      PlayerCharacter.PvPDefense
    ]
  );




  // Chamar a função LogItem para registrar o log
  LogItem(CharacterName, StatusLog);

   // Chame a função para salvar os status no banco de dados
  //SaveStatusToDatabase(Self.ClientID, CharacterName, Self);





  {$ENDREGION}
end;
end;
end;






{
  procedure TBaseMob.ForEachInRange(range: Byte;
  proc: TProc<TPosition, TBaseMob, TBaseMob>);
  var
  MobId, Index: WORD;
  mob, Current: TBaseMob;
  Channel: Byte;
  begin
  if not(PlayerCharacter.LastPos.IsValid) then
  Exit;
  index := Self.ClientId;
  Channel := Self.ChannelId;
  Current := Self;
  PlayerCharacter.LastPos.ForEach(range,
  procedure(Pos: TPosition)
  begin
  MobId := Servers[Channel].MobGrid[Round(Pos.Y)][Round(Pos.X)];
  // pode gerar erro
  if (MobId = 0) OR (MobId = index) then
  begin
  Exit;
  end;
  if (MobId <= MAX_CONNECTIONS) then
  begin
  mob := Servers[Channel].Players[MobId].Base;
  end
  else
  begin
  mob := Servers[Channel].NPCs[MobId].Base;
  end;
  if not(mob.IsActive) then
  begin
  Exit;
  end;
  proc(Pos, Current, mob);
  end);
  end;
  class procedure TBaseMob.ForEachInRange(Pos: TPosition; range: Byte;
  proc: TProc<TPosition, TBaseMob>; ChannelId: Byte);
  var
  MobId: WORD;
  mob: TBaseMob;
  begin
  if not(Pos.IsValid) then
  Exit;
  Pos.ForEach(range,
  procedure(p: TPosition)
  begin
  MobId := Servers[ChannelId].MobGrid[Round(p.Y)][Round(p.X)];
  // pode gerar erro
  if (MobId = 0) then
  Exit;
  if (MobId <= MAX_CONNECTIONS) then
  mob := Servers[ChannelId].Players[MobId].Base
  else
  mob := Servers[ChannelId].NPCs[MobId].Base;
  if not(mob.IsActive) then
  Exit;
  proc(p, mob);
  end);
  end; }





{$ENDREGION}
{$REGION 'Buffs'}
procedure TBaseMob.SendRefreshBuffs();
var
  Packet: TSendBuffsPacket;
  i: Integer;
  Index: WORD;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $16E;
  Packet.Header.Index := Self.ClientID;
  Self.RefreshBuffs;
  i := 0;
  for Index in Self._buffs.Keys do
  begin
    Packet.Buffs[i] := Index;
    Packet.Time[i] := DateTimeToUnix(IncSecond(Self._buffs[Index],
      (SkillData[Index].Duration)));
    Inc(i);
  end;
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Self.SendToVisible(Packet, Packet.Header.size, False)
  else
    Self.SendToVisible(Packet, Packet.Header.size);
end;
procedure TBaseMob.SendAddBuff(BuffIndex: WORD);
var
  Packet: TUpdateBuffPacket;
  EndTime: TDateTime;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $16F;
  Packet.Buff := BuffIndex;
  EndTime := IncSecond(Self._buffs[BuffIndex], (SkillData[BuffIndex].Duration));
  Packet.EndTime := DateTimeToUnix(EndTime);
  if (Self.ClientID >= 3048) then
    Self.SendToVisible(Packet, Packet.Header.size, False)
  else
    Self.SendPacket(Packet, Packet.Header.size);
  Self.SendRefreshBuffs;
  Self.SendRefreshPoint;
  Self.SendStatus;
end;
function TBaseMob.RefreshBuffs: Integer;
var
  Index: WORD;
  EndTime: TDateTime;
  // TimeNow: TDateTime;
  i: Integer;
begin
  Result := 0;
  for Index in Self._buffs.Keys do
  begin
    EndTime := IncSecond(Self._buffs[Index], SkillData[Index].Duration);
    // TimeNow := Now;
    if (EndTime < Now) then
    begin
      if (Self.RemoveBuff(Index)) then
      begin
        Inc(Result);
      end;
    end;
  end;
  if(Result > 0) then
  begin
    Self.SendCurrentHPMP(True);
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;

  // mod se der merda foi aqui por conta verificar if clientid <= max_connections
  if (Self.ClientID <= MAX_CONNECTIONS) then
  begin
    for i := Low(Self.PlayerCharacter.Buffs)
      to High(Self.PlayerCharacter.Buffs) do
    begin
      EndTime := IncSecond(Self.PlayerCharacter.Buffs[i].CreationTime,
        SkillData[Self.PlayerCharacter.Buffs[i].Index].Duration);
      if (EndTime <= Now) then
      begin
        ZeroMemory(@Self.PlayerCharacter.Buffs[i],
          sizeof(Self.PlayerCharacter.Buffs[i]));
      end;
    end;
  end;
end;

var
 LastPlayerWithBuff6649: Integer = -1;

function TBaseMob.AddBuff(BuffIndex: WORD; Refresh: Boolean = True;
  AddTime: Boolean = False; TimeAditional: Integer = 0): Boolean;
var
  BuffSlot: Integer;
  Index: WORD;


begin

    // buff ganhador do royalle
   { begin
      // Verifica se o buff sendo adicionado é o 6649
      if BuffIndex = 9185 then
      begin
        // Verifica se já existe alguém com o buff 6649
        if LastPlayerWithBuff6649 <> -1 then
        begin
          // Remove o buff do jogador anterior
          if Servers[0].Players[LastPlayerWithBuff6649].Base.BuffExistsByIndex(9185) then
          begin
            Servers[0].Players[LastPlayerWithBuff6649].Base.BuffExistsByIndex(9185);
            Servers[0].Players[LastPlayerWithBuff6649].SendClientMessage('Você perdeu o buff Batlle Rroyalle.', 16, 1, 1);
          end;
        end;

        // Atualiza a referência do jogador com o buff 6649
        LastPlayerWithBuff6649 := Self.ClientID;
      end;
    end;  }

     // Impede buffs específicos ou dentro do intervalo 3217..3232 caso esteja com a bolha (36) ou buff 136

 { if (((BuffIndex = 5023) or (BuffIndex = 5024) or  (BuffIndex = 129) or  (BuffIndex = 2993) or (BuffIndex = 3226))
   and
       (Self.BuffExistsByIndex(36) or Self.BuffExistsByIndex(136))) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
      'Você não pode receber esse buff enquanto estiver com proteção ativa.');

    Exit;
  end;  }
      // evitar utilizar o reflete com a bolha

  if (Self.BuffExistsByIndex(36)) and not ((BuffIndex >= 1057) and (BuffIndex <= 1536)) then
begin
  Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
    'Você não pode receber esse buff enquanto estiver com proteção ativa.');

  Exit;
end;




    if (Self.BuffExistsByIndex(365)) and not ((BuffIndex >= 1057) and (BuffIndex <= 1536)) then
begin
  Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
    'Você não pode receber esse buff enquanto estiver com proteção ativa.');

  Exit;
end;











  if(BuffIndex = 7257) or (BuffIndex = 9133) then
    Exit;
  if(Self.BuffExistsByIndex(SkillData[BuffIndex].Index)) then
  begin
    Self.RemoveBuffByIndex(SkillData[BuffIndex].Index);
  end;
  if (Self._buffs.ContainsKey(BuffIndex)) then
  begin
    Result := True;
    if(Self.Character <> nil) then
    begin //arrumar pro debuff n�o aumentar em nation mas sim no inimigo
      if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        TimeAditional := TimeAditional +
          ((Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_ATIME0] *
          SkillData[BuffIndex].Duration) div 100);
      end;

      if((SkillData[BuffIndex].Duration >= 600) and
        (SkillData[BuffIndex].MP > 0)) then
      begin
        if(Self.GetMobAbility(EF_SKILL_ATIME6) > 0) then
        begin
          TimeAditional := TimeAditional +
            (Self.GetMobAbility(EF_SKILL_ATIME6) * 60);
        end;
      end;
    end;
    if (TimeAditional > 0) then
      Self._buffs[BuffIndex] := IncSecond(Now, TimeAditional)
    else
      Self._buffs[BuffIndex] := Now;
    Self.SendRefreshBuffs;
    BuffSlot := Self.GetBuffSlot(BuffIndex);
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime :=
        Self._buffs[BuffIndex];
    end;
  end
  else
  begin
    Result := True;
    if(Self.Character <> nil) then
    begin //arrumar pro debuff n�o aumentar em nation mas sim no inimigo
      if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        TimeAditional := TimeAditional +
          ((Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_ATIME0] *
          SkillData[BuffIndex].Duration) div 100);
      end;

      if((SkillData[BuffIndex].Duration >= 600) and
        (SkillData[BuffIndex].MP > 0)) then
      begin
        if(Self.GetMobAbility(EF_SKILL_ATIME6) > 0) then
        begin
          TimeAditional := TimeAditional +
            (Self.GetMobAbility(EF_SKILL_ATIME6) * 60);
        end;
      end;
    end;
    Self._buffs.Add(BuffIndex, IncSecond(Now, TimeAditional));
    Self.AddBuffEffect(BuffIndex);
    Self.GetCurrentScore;
    BuffSlot := Self.GetEmptyBuffSlot;
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].Index := BuffIndex;
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime :=
        Self._buffs[BuffIndex];
    end;
  end;
  if (Refresh) then
  begin
    Self.SendAddBuff(BuffIndex);
  end;
end;
function TBaseMob.AddBuffWhenEntering(BuffIndex: Integer;
  BuffTime: TDateTime): Boolean;
begin
  Result := True;
  if (Self._buffs.ContainsKey(BuffIndex)) then
    Exit;
  Self._buffs.Add(BuffIndex, BuffTime);
  Self.AddBuffEffect(BuffIndex);
   Self.GetCurrentScore;
   Self.SendAddBuff(BuffIndex);
end;
function TBaseMob.GetBuffSlot(BuffIndex: WORD): Integer;
var
  i: Integer;
begin
  Result := -1;
  if (Self.ClientID > MAX_CONNECTIONS) then
    Exit;
  for i := 0 to 59 do
  begin
    if (Self.PlayerCharacter.Buffs[i].Index = BuffIndex) then
    begin
      Result := i;
      break;
    end
    else
      Continue;
  end;
end;
function TBaseMob.GetEmptyBuffSlot(): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to 59 do
  begin
    if (Self.PlayerCharacter.Buffs[i].Index = 0) then
    begin
      Result := i;
      break;
    end
    else
      Continue;
  end;
end;
function TBaseMob.RemoveBuff(BuffIndex: WORD): Boolean;
var
  BuffSlot: Integer;
  Query: TQuery;
  CharID: Integer;
begin

  // **Nova Verificação: Impede a remoção de buffs específicos se o Buff de índice 36 estiver ativo**
  {if Self.BuffExistsByIndex(36) and (BuffIndex = 6498) or (BuffIndex  = 6499) or (BuffIndex  = 208) or
                 (BuffIndex  = 272) or (BuffIndex  = 348) or (BuffIndex  = 5163) or
                 (BuffIndex  = 5193) or (BuffIndex  = 1461) or (BuffIndex  = 4001)   then
    begin
      Result := False; // Indica que a remoção não foi realizada
     // Self.SendClientMessage('Você está sob proteção da Bolha. Este buff não pode ser removido agora.');
      Exit;
    end;}



  Result := False;
  if (Self._buffs.ContainsKey(BuffIndex)) then
  begin
    Self.RemoveBuffEffect(BuffIndex);
    Self._buffs.Remove(BuffIndex);
    BuffSlot := Self.GetBuffSlot(BuffIndex);
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].Index := 0;
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime := 0;
    end;
  end;
  if not(Self._buffs.ContainsKey(BuffIndex)) then
    Result := True;
  Self.GetCurrentScore;
  Self.SendStatus;
  Self.SendRefreshPoint;
  Self.SendRefreshBuffs;
  case SkillData[BuffIndex].Index of
    35: //uniao divina
      begin
        Self.UniaoDivina := '';
      end;
    42:
      begin
        Self.HPRListener := False;
      end;
    49: //contagem regressiva
      begin
        Randomize;
        Self.RemoveHP((RandomRange(15, 90) +
          SkillData[BuffIndex].EFV[0]*1), True, True);

      end;
    65: //x14
      begin
        Self.DestroyPet(Self.PetClientID);
        Self.PetClientID := 0;

      end;

    73: //mjolnir
      begin
        Self.RemoveHP((RandomRange(15, 90) +
          SkillData[BuffIndex].EFV[0]*10), True, True);
      end;
    //91: //pocao logo aika
      //begin
       // Self.SendCreateMob(SPAWN_NORMAL);
      //  Self.SendEffect(0);
      //end;

    99: // polimorfo
     begin
        Self.SendCreateMob(SPAWN_NORMAL);

      end;






    108: // eclater
      begin
       // Se o mob estiver com proteção ativa (buff 36 ou 136), não aplica o dano
        if Self.BuffExistsByIndex(36) or Self.BuffExistsByIndex(136) then
        Exit;
        Randomize;
        if(Self.GetMobAbility(EF_ACCELERATION1) > 0) then
        begin
          Self.RemoveHP((RandomRange(15, 90) +
            SkillData[BuffIndex].EFV[0]  + SkillData[BuffIndex].Damage), True, True) ;
        end
        else
          Self.RemoveHP((RandomRange(15, 90) +
            SkillData[BuffIndex].EFV[0] ), True, True);

      end;

    120:
      begin
        Self.HPRListener := False;
      end;

      14:
     begin
        Self.HPRListener := False;
      end;

    125:  // mão de cura
      begin
        Self.HPRListener := False;
      end;
    134: // cura preventiva
      begin
        Self.CalcAndCure(BuffIndex, @Self);
      end;



  end;

   // == Inserção da lógica para redefinir altura/tronco quando os buffs específicos forem removidos ==

  // Obtém o ID do personagem (caso Self seja o jogador). Se o Mob não for jogador, ajuste conforme necessário.
  CharID := Self.ClientID;

  // Verifica se o buff removido é um dos que alteram altura ou tronco
  // OBS: Este código checa se ainda há algum desses buffs ativos. Se a intenção é "ao remover 9122, 9123 ou 9126",
  //      considere trocar por "if (SkillData[BuffIndex].Index in [9122, 9123, 9126]) then".

  if BuffExistsByIndex(9122) or BuffExistsByIndex(9123) or BuffExistsByIndex(9126) then
  begin
    Query := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE));
    try
      if not(Query.Query.Connection.Connected) then
      begin
        Exit;
      end;

      // Atualiza altura e tronco para os valores padrão
      Query.SetQuery('UPDATE characters SET altura = 7, tronco = 119 WHERE id = :CharID');
      Query.AddParameter2('CharID', CharID);
      Query.Run(False);
    finally
      Query.Free;
    end;

    // Envia mensagem ao jogador informando para relogar
    Self.SendClientMessage('Seu buff terminou. Relogue para voltar ao normal!');
  end;
end;
procedure TBaseMob.RemoveAllDebuffs();
var
  i, cnt: WORD;
begin
  cnt := 0;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if ((SkillData[i].BuffDebuff = 3) or (SkillData[i].BuffDebuff = 4)) then
    begin
      Self.RemoveBuff(i);
      Inc(cnt);
    end
    else
      Continue;
  end;
  if not(cnt = 0) then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
end;
procedure TBaseMob.AddBuffEffect(Index: WORD);
var
  i: Integer;
begin
  if (Self.IsDungeonMob) then
    Exit;
  for i := 0 to 3 do
  begin
    if(i = EF_RUNSPEED) then
    begin
      if((Self.MOB_EF[EF_RUNSPEED] + SkillData[Index].EFV[i]) >= 13) then
      begin
        Self.MOB_EF[EF_RUNSPEED] := 13;
      end
      else
      begin
        Self.IncreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
      end;
    end
    else
      Self.IncreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
  end;
end;
procedure TBaseMob.RemoveBuffEffect(Index: WORD);
var
  i: Integer;
begin
  if (Self.IsDungeonMob) then
    Exit;
  for i := 0 to 3 do
  begin
    Self.DecreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
  end;

end;
function TBaseMob.GetBuffToRemove(): DWORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff <> 1) then
      Continue;
    Result := i;
    break;
  end;
end;
function TBaseMob.GetDeBuffToRemove(): DWORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff <> 3) or (SkillData[i].BuffDebuff <> 4) then
      Continue;
    Result := i;
    break;
  end;
end;
function TBaseMob.GetDebuffCount(): WORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff = 3) or (SkillData[i].BuffDebuff = 4) then
    begin
      Inc(Result);
    end
    else
      Continue;
  end;
end;
function TBaseMob.GetBuffCount(): WORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff = 1) then
    begin
      Inc(Result);
    end
    else
      Continue;
  end;
end;
procedure TBaseMob.RemoveBuffByIndex(Index: WORD);
var
  i: WORD;
  Query: TQuery;
  CharID: Integer;

begin
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].Index = Index) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Self.SendRefreshBuffs;
        Self.SendCurrentHPMP;
        Self.SendStatus;
        Self.SendRefreshPoint;

        // Obtém o ID do personagem
        CharID := Self.ClientID;

        // Verifica se o buff removido é um dos que alteram altura ou tronco
        if BuffExistsByIndex(9122) or BuffExistsByIndex(9123) or BuffExistsByIndex(9126) then
        begin
          Query := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
            AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
            AnsiString(MYSQL_DATABASE));
          try
            if not(Query.Query.Connection.Connected) then
            begin
              Exit;
            end;

            // Atualiza altura e tronco para os valores padrão
            Query.SetQuery('UPDATE characters SET altura = 7, tronco = 119 WHERE id = :CharID');
            Query.AddParameter2('CharID', CharID);
            Query.Run(False);
          finally
            Query.Free;
          end;
          // Envia mensagem ao jogador informando para relogar
          Self.SendClientMessage('Seu buff terminou. Relogue para voltar ao normal!');
        end;
      end;
      break;
    end
    else
      Continue;
  end;
end;

function TBaseMob.GetBuffSameIndex(BuffIndex: DWORD): Boolean;
var
  j: DWORD;
  Index: DWORD;
begin
  Result := False;
  if (Self._buffs.Count = 0) then
    Exit;
  for j in Self._buffs.Keys do
  begin
    if (SkillData[BuffIndex].Index = SkillData[j].Index) then
    begin
      Self.RemoveBuff(j);
      Result := True;
      //break;
    end
    else
    begin
      Continue;
    end;
  end;
end;
function TBaseMob.BuffExistsByIndex(BuffIndex: DWORD): Boolean;
var
  i: Integer;
  Index: DWORD;
begin
  Result := False;
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  if (BuffIndex = 0) then
    Exit;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (BuffIndex = SkillData[i].Index) then
    begin
      Result := True;
      break;
    end;
  end;
end;
function TBaseMob.BuffExistsByID(BuffID: DWORD): Boolean;
var
  i: Integer;
  Index: DWORD;
begin
  Result := False;
  if {(Self.ClientID >= 3048) or} (Self.IsDungeonMob) then
    Exit;
  if (BuffID = 0) then
    Exit;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (BuffID = i) then
    begin
      Result := True;
      break;
    end;
  end;
end;

function TBaseMob.BuffExistsInArray(const BuffList: Array of DWORD): Boolean;
var
  i, j: Integer;
begin
  Result := False;

  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  if (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    for j in BuffList do
    begin
       if(SkillData[i].Index = j) then
       begin
         Result := True;
         break;
       end;
    end;

    if(Result) then
      break;
  end;
end;

function TBaseMob.BuffExistsSopa(): Boolean;
var
  i: Integer;
begin
  Result := False;

  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  if (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if(Copy(String(SkillData[i].Name), 0, 4) = 'Sopa') then
    begin
      Result := True;
      break;
    end;
  end;
end;
function TBaseMob.GetBuffIDByIndex(Index: DWORD): WORD;
var
  i, id: WORD;
begin
  Result := 0;
  if {(Self.ClientID >= 3048) or} (Self.IsDungeonMob) then
    Exit;
  if (Index = 0) then
    Exit;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (Index = SkillData[i].Index) then
    begin
      Result := id;
      break;
    end;
  end;
end;
procedure TBaseMob.RemoveBuffs(Quant: Byte);
var
  i, cnt: WORD;
  Query: TQuery;
  CharID: Integer;
begin
  if (Self._buffs.Count = 0) then
    Exit;
  cnt := 0;
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (cnt >= Quant) then
      break;
    if (SkillData[i].BuffDebuff = 1) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Inc(cnt);
        Continue;
      end;
    end
    else
      Continue;
  end;
  if not(cnt = 0) then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
   // ----------------------------------------------
  // APLICA LÓGICA PARA REDEFINIR ALTURA/TRONCO AQUI
  // se desejar verificar APÓS remover vários buffs
  // ----------------------------------------------
  // Exemplo: se, depois de remover esses buffs, o jogador não possuir
  // mais 9122, 9123 ou 9126, então redefina altura e tronco:
  if (not BuffExistsByIndex(9122)) and
     (not BuffExistsByIndex(9123)) and
     (not BuffExistsByIndex(9126)) then
  begin
    // Ajuste conforme seu caso: se for 1 jogador por TBaseMob, ou use
    // Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Id etc.
    CharID := Self.ClientID;

    Query := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE));
    try
      if not(Query.Query.Connection.Connected) then
        Exit;

      // Atualiza altura e tronco para valores padrão
      Query.SetQuery('UPDATE characters SET altura = 7, tronco = 119 WHERE id = :CharID');
      Query.AddParameter2('CharID', CharID);
      Query.Run(False);
    finally
      Query.Free;
    end;

    // Envia mensagem ao jogador
    Self.SendClientMessage('Os buffs especiais terminaram. Relogue para voltar ao normal!');
  end;



end;
procedure TBaseMob.RemoveDebuffs(Quant: Byte);
var
  i, cnt: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;
  cnt := 0;
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (cnt >= Quant) then
      break;
    if ((SkillData[i].BuffDebuff = 3) or (SkillData[i].BuffDebuff = 4)) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Inc(cnt);
        Continue;
      end;
    end
    else
      Continue;
  end;
  if not(cnt = 0) then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
end;
procedure TBaseMob.ZerarBuffs();
var
  i: Integer;
begin
  for I in Self._buffs.Keys do
  begin
    Self.RemoveBuff(i);
  end;
end;
{$ENDREGION}
{$REGION 'Attack & Skills'}
procedure TBaseMob.CheckCooldown(var Packet: TSendSkillUse);
var
  EndTime: TTime;
  SocketClosed: Boolean;
  StatusLog: String;
  CharacterName: String;
  SkillCooldown: Integer;

begin
   if (SkillData[Packet.Skill].Level = 0) then
  begin // Ataque básico
    if (MilliSecondsBetween(Now, Self.LastBasicAttack) < MIN_DELAY_ATTACK) then
    begin
      Inc(Self.AttackMsgCount); // Aumenta o contador de abuso

      case Self.AttackMsgCount of
        2: Self.SendClientMessage('️ Primeiro aviso: Você está atacando muito rápido. Aguarde o tempo correto!');
        3: Self.SendClientMessage('️ Segundo aviso: Se continuar atacando rápido demais, será desconectado.');
        4: Self.SendClientMessage('  Último aviso: Próxima tentativa irregular e você será desconectado!');
        5:
        begin
          Self.SendClientMessage(' Uso irregular de ataque detectado! Você foi desconectado.');

          // Registra o log da infração
          LogInfo(Self.Character.Name, 'Uso irregular de ataque detectado.');

          // Desconecta o jogador
          Servers[Self.ChannelId].Players[Self.ClientID].Disconnect;
          Exit;
        end;
      end;

      Exit;
    end
  else
    begin
      // Se o jogador respeitou o cooldown, resetar o contador para evitar punição injusta
      Self.AttackMsgCount := 0;
    end;

    // Atualiza o tempo do último ataque básico
    Self.LastBasicAttack := Now;
    Self.SendToVisible(Packet, Packet.Header.size, True);
  end


      else // Skills (Level > 0)
    begin
      // Define o cooldown mínimo da skill baseado na classe do jogador
      case self.GetMobClass(self.Character.ClassInfo) of
        0:  // Guerreiro ️ (Ataques físicos pesados)
          SkillCooldown := 300;  // 700ms entre habilidades
        1:  // Templária  (Buffs e cura)
          SkillCooldown  := 300;  // 900ms entre habilidades
        2:  // Atirador  (Tiros rápidos)
          SkillCooldown  := 300;  // 500ms entre habilidades
        3:  // Dual  (Combos rápidos)
          SkillCooldown  := 300;  // 600ms entre habilidades
        4: // Feiticeiro
          SkillCooldown  := 100;   // 750ms entre habilidades
        5: //Santa
          SkillCooldown  := 100;   // 1600ms entre habilidades
      end;

     // Verifica se a habilidade ainda está em cooldown
      if (MilliSecondsBetween(Now, Self.LastSkillUse) < MIN_DELAY_SKILL) then
      begin
        Inc(Self.AttackMsgCount); // Aumenta o contador de abuso

        case Self.AttackMsgCount of
          2: Self.SendClientMessage('️ Primeiro aviso: Use suas habilidades corretamente.');
          3: Self.SendClientMessage('️ Segundo aviso: Você está usando habilidades muito rápido.');
          4: Self.SendClientMessage('️ Último aviso: Se continuar, será desconectado!');
          5:
          begin
            Self.SendClientMessage(' Uso irregular de habilidades detectado! Você foi desconectado.');
            Servers[Self.ChannelId].Players[Self.ClientID].Disconnect;
            Exit;
          end;
        end;

        Exit;
      end
      else
      begin
        // Se o jogador respeitou o cooldown, reseta o contador de tentativas
        Self.AttackMsgCount := 0;
      end;

      // Atualiza o tempo do último uso da habilidade
      Self.LastSkillUse := Now;
      Self.SendToVisible(Packet, Packet.Header.size, True);
    end;


    if (Self._cooldown.ContainsKey(Packet.Skill)) then
    begin
      EndTime := IncMillisecond(Self._cooldown[Packet.Skill],
        SkillData[Packet.Skill].Cooldown);
      if not(EndTime < Now) then
      begin
        Exit;
      end;
    end;
    Self.UsingSkill := Packet.Skill;
    Self.SendToVisible(Packet, Packet.Header.size, True);
     if (SkillData[Packet.Skill].SuccessRate = 1) and
      (SkillData[Packet.Skill].range > 0) then
  begin
      if (Self._cooldown.ContainsKey(Packet.Skill)) then
   begin
      EndTime := IncMillisecond(Self._cooldown[Packet.Skill],
      SkillData[Packet.Skill].Cooldown);
      if not(EndTime <= Now) then
    begin
      Exit;
     end;
      end;
      Self.UsingSkill := Packet.Skill;
      Self.SendToVisible(Packet, Packet.Header.size, True);
      end
      else
  begin
      if (Self._cooldown.ContainsKey(Packet.Skill)) then
   begin
      EndTime := IncMillisecond(Self._cooldown[Packet.Skill],
      SkillData[Packet.Skill].Cooldown);
      if not(EndTime <= Now) then
    begin
      Exit;
     end;
    end;
      Self.UsingSkill := Packet.Skill;
      Self.SendToVisible(Packet, Packet.Header.size, True);
    end;
end;

procedure TBaseMob.SendCurrentAllSkillCooldown();
var
  Packet: Tp12C;
  i: Integer;
  CurrTime: TTime;
  OPlayer: PPlayer;
begin
  ZeroMemory(@Packet, sizeof(Tp12C));
  Packet.Header.size := sizeof(Tp12C);
  Packet.Header.Index := $7535; // era 0
  Packet.Header.Code := $12C;

  OPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  for I := 0 to 5 do
  begin
    if(Self._cooldown.ContainsKey(OPlayer.Character.Skills.Basics[i].Index +
       OPlayer.Character.Skills.Basics[i].Level-1)) then
    begin
      Self._cooldown.TryGetValue(OPlayer.Character.Skills.Basics[i].Index +
       OPlayer.Character.Skills.Basics[i].Level-1, CurrTime);
      Packet.Skills[i] := SkillData[OPlayer.Character.Skills.Basics[i].Index +
       OPlayer.Character.Skills.Basics[i].Level-1].Duration -
       ((SkillData[OPlayer.Character.Skills.Basics[i].Index +
       OPlayer.Character.Skills.Basics[i].Level-1].Duration div 100) *
       Self.PlayerCharacter.ReduceCooldown) -
        (SecondsBetween(CurrTime, Now));
    end;
  end;

  for I := 0 to 39 do
  begin
    if(Self._cooldown.ContainsKey(OPlayer.Character.Skills.Others[i].Index +
       OPlayer.Character.Skills.Others[i].Level-1)) then
    begin
      Self._cooldown.TryGetValue(OPlayer.Character.Skills.Others[i].Index +
       OPlayer.Character.Skills.Others[i].Level-1, CurrTime);
      Packet.Skills[i] := SkillData[OPlayer.Character.Skills.Others[i].Index +
       OPlayer.Character.Skills.Others[i].Level-1].Duration -
       ((SkillData[OPlayer.Character.Skills.Others[i].Index +
       OPlayer.Character.Skills.Others[i].Level-1].Duration div 100) *
       Self.PlayerCharacter.ReduceCooldown) -
        (SecondsBetween(CurrTime, Now));
    end;
  end;

  Self.SendPacket(Packet, Packet.Header.Size);
end;

function TBaseMob.CheckCooldown2(SkillID: DWORD): Boolean;
var
  EndTime: TTime;
  CD: DWORD;
begin
  Result := True;
  if (Self._cooldown.ContainsKey(SkillID)) then
  begin
    if(Self.GetMobClass() = 3) then
      CD := ((SkillData[SkillID].Cooldown *
        PlayerCharacter.ReduceCooldown+50) div 100)
    else
      CD := ((SkillData[SkillID].Cooldown *
        PlayerCharacter.ReduceCooldown) div 100);

    EndTime := IncMillisecond(Self._cooldown[SkillID],
      ((SkillData[SkillID].Cooldown) - CD));
    if not(EndTime < Now) then
    begin
      Result := False;
    end
    else
    begin
      Self._cooldown[SkillID] := Now;
      Result := True;
    end;
  end
  else
  begin
    Self._cooldown.Add(SkillID, Now);
    Result := True;
  end;
end;
procedure TBaseMob.SendDamage(Skill, Anim: DWORD; mob: PBaseMob;
  DataSkill: P_SkillData);
var
  Packet: TRecvDamagePacket;
  Add_Buff: Boolean;
  j: Integer;
  DropExp: Boolean;
  DropItem: Boolean;
  MobsP: PMobSPoisition;
  xDano, helper: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.TargetID := mob^.ClientID;
  Packet.MobAnimation := DataSkill^.TargetAnimation;
  // try
  xDano := Self.GetDamage(Skill, mob, Packet.DnType);
  // except
  // Packet.Dano := ((Self.PlayerCharacter.Base.CurrentScore.DNFis +
  // Self.PlayerCharacter.Base.CurrentScore.DNMAG) div 2);
  // Packet.DnType := TDamageType.Normal;
  // end;
  if (xDano > 0) then
  begin
    Self.AttackParse(Skill, Anim, mob, xDano, Packet.DnType, Add_Buff,
      Packet.MobAnimation, DataSkill);

    if(xDano > 0) then
    begin
      Inc(xDano, (RandomRange((xDano div 20), (xDano div 10)) + 13));
    end;
  end
  else if(xDano < 0) then
  begin
    xDano := 0;
  end;

  Packet.DANO := xDano;
   // ataque padrão das classes
  if(Skill = 0) then
  begin
    case Self.GetMobClass() of
      0:
        begin
          if(mob.ClientID <= MAX_CONNECTIONS) then
           Packet.Dano := Trunc(Packet.Dano  * WAR_ATACK );
        end;


      1:
        begin
          if(mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Trunc(Packet.Dano * TP_ATACK  );
        end;

      2:
        begin
          if(mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Trunc(Packet.Dano * ATT_ATACK  );

          if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 1);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);

            if(Self.Character.Equip[15].Index = 0) then
            begin
              Helper := TItemFunctions.GetItemSlotByItemType(
                Servers[Self.ChannelId].Players[Self.ClientID], 50, INV_TYPE);

              if(Helper <> 255) and (ItemList[Self.Character.Inventory[Helper].Index]
                .Classe = Self.Character.ClassInfo) then
              begin
                Move(Self.Character.Inventory[Helper],
                  Self.Character.Equip[15], sizeof(TItem));
                Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
                  Self.Character.Equip[15], False);
                ZeroMemory(@Self.Character.Inventory[Helper], sizeof(TITem));
                Self.SendRefreshItemSlot(INV_TYPE, Helper,
                  Self.Character.Inventory[Helper], False);

                Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
                'Suas balas acabaram e foram equipadas novas balas a partir do invent�rio.');
              end;
            end;
          end;
        end;

      3:
        begin
          if(mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Trunc(Packet.Dano * DUAL_ATACK/3);

          if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 2);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);

            if(Self.Character.Equip[15].Index = 0) then
            begin
              Helper := TItemFunctions.GetItemSlotByItemType(
                Servers[Self.ChannelId].Players[Self.ClientID], 50, INV_TYPE);

              if(Helper <> 255) and (ItemList[Self.Character.Inventory[Helper].Index]
                .Classe = Self.Character.ClassInfo) then
              begin
                Move(Self.Character.Inventory[Helper],
                  Self.Character.Equip[15], sizeof(TItem));
                Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
                  Self.Character.Equip[15], False);
                ZeroMemory(@Self.Character.Inventory[Helper], sizeof(TITem));
                Self.SendRefreshItemSlot(INV_TYPE, Helper,
                  Self.Character.Inventory[Helper], False);

                Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
                'Suas balas acabaram e foram equipadas novas balas a partir do invent�rio.');
              end;
            end;
          end;
        end;

          4:
        begin
          if(mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Packet.Dano + Trunc(Packet.Dano * FC_ATACK );
        end;

        5:
        begin
          if(mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Packet.Dano + Trunc(Packet.Dano * SANTA_ATACK );
        end;


    end;
  end ;


  if (Self.BuffExistsByIndex(77)) then
  begin // inv dual
    Self.RemoveBuffByIndex(77);
  end;
  if (Self.BuffExistsByIndex(53)) then
  begin // inv att
    Self.RemoveBuffByIndex(53);
  end;
  if (mob^.BuffExistsByIndex(153)) then
  begin // predador
    mob^.RemoveBuffByIndex(153);
  end;

  if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
  begin
    if (Packet.Dano >= DungeonInstances[Servers[Self.ChannelId].Players
      [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid].CurrentHP) then
    begin
      mob.IsDead := True;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP := 0;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[mob.Mobid].IsAttacked := False;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[mob.Mobid].AttackerID := 0;
       DungeonInstances
        [Servers[Self.ChannelId].Players[Self.ClientId].DungeonInstanceID].Mobs
        [mob.Mobid].deadTime := Now;
      if (Self.VisibleMobs.Contains(mob.ClientID)) then
        Self.VisibleMobs.Remove(mob.ClientID);
      Self.MobKilledInDungeon(mob);
      Packet.MobAnimation := 30;
    end
    else
    begin
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP :=
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP - Packet.Dano;
    end;
    mob.LastReceivedAttack := Now;
    Packet.MobCurrHP := DungeonInstances
      [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs
      [mob.Mobid].CurrentHP;
    Self.SendToVisible(Packet, Packet.Header.size);
    Exit;
  end;
  MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[0].MobsP
      [1];
  if(mob^.SecondIndex > 0) then
    MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP
      [mob^.SecondIndex];

  if ((mob^.ClientID >= 3048) and (mob^.ClientID <= 9147)) then
  begin
    case mob^.ClientID of
      3340 .. 3354:
        begin // stones
          if ((Packet.Dano >= Servers[Self.ChannelId].DevirStones[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP) and not(mob^.IsDead)) then
          begin
            mob^.IsDead := True;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := 0;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .IsAttacked := False;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID].AttackerID := 0;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID].deadTime := Now;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID].KillStone(mob^.ClientID,
            Self.ClientId);
            if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
            begin
              Self.VisibleNPCs.Remove(mob^.ClientID);
              Self.RemoveTargetFromList(mob);
              // essa skill tem retorno no caso de erro
            end;
            for j in Self.VisiblePlayers do
            begin
              if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(mob^.ClientID)) then
              begin
                Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(mob^.ClientID);
                Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
              end;
            end;
            mob^.VisibleMobs.Clear;
            // Self.MobKilled(mob, DropExp, DropItem, False);
            Packet.MobAnimation := 30;
          end
          else
          begin
            Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
              .DevirStones[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
              Packet.Dano;
              if (Now >= IncSecond(mob^.LastReceivedAttack, 2)) then
            begin
              case mob^.ClientID of
                  3340..3344:
                  begin
                    Helper:= Servers[Self.ChannelId].DevirGuards[j].GetDevirIdByStoneOrGuardId(mob^.ClientID);
                    Servers[Self.ChannelId].SendServerMsgForNation
                    ('O Pedra do Devir de ' + AnsiString(Servers[Self.ChannelId].DevirNpc[Helper+3335].DevirName) + ' está sendo atacado.',
                    Servers[Self.ChannelId].NationID);
                  end;
              end;
            end;
          end;
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          //Sleep(1);
          Exit;
        end;
      3355 .. 3369:
        begin // guards
          if ((Packet.Dano >= Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP)and not(mob^.IsDead)) then
          begin
            mob^.IsDead := True;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := 0;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .IsAttacked := False;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID].AttackerID := 0;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID].deadTime := Now;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID].KillGuard(mob^.ClientID,
            Self.ClientId);
            if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
            begin
              Self.VisibleNPCs.Remove(mob^.ClientID);
              Self.RemoveTargetFromList(mob);
              // essa skill tem retorno no caso de erro
            end;
            for j in Self.VisiblePlayers do
            begin
              if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(mob^.ClientID)) then
              begin
                Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(mob^.ClientID);
                Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
              end;
            end;
            mob^.VisibleMobs.Clear;
            // Self.MobKilled(mob, DropExp, DropItem, False);
            Packet.MobAnimation := 30;
          end
          else
          begin
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
              .DevirGuards[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
              Packet.Dano;
              if (Now >= IncSecond(mob^.LastReceivedAttack, 2)) then
            begin
            Helper:= Servers[Self.ChannelId].DevirGuards[j].GetDevirIdByStoneOrGuardId(mob^.ClientID);
            Servers[Self.ChannelId].SendServerMsgForNation
                ('O Totem de ' + AnsiString(Servers[Self.ChannelId].DevirNpc[Helper+3335].DevirName) + ' está sendo atacado.',
                Servers[Self.ChannelId].NationID);
            end;

          end;
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          //Sleep(1);
          Exit;
        end;
    else
      begin


        if not(MobsP.IsAttacked) then
        begin
          MobsP.FirstPlayerAttacker := Self.ClientID;
        end;

        if (Packet.Dano >= MobsP^.HP) then
        begin
          mob^.IsDead := True;
          MobsP^.HP := 0;
          MobsP^.IsAttacked := False;
          MobsP^.AttackerID := 0;
          MobsP^.deadTime := Now;

          MobsP.Base.SendEffect($0);

          mob.SendCurrentHPMPMob;
          if (Self.VisibleMobs.Contains(mob^.ClientID)) then
          begin
            Self.VisibleMobs.Remove(mob^.ClientID);
            Self.RemoveTargetFromList(mob);
            // essa skill tem retorno no caso de erro
          end;
          for j := Low(Servers[Self.ChannelId].Players) to
            High(Servers[Self.ChannelId].Players) do
          begin
            if((Servers[Self.ChannelId].Players[j].Status < Playing) or
              (Servers[Self.ChannelId].Players[j].SocketClosed)) then
              COntinue;

            if(Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains(mob^.ClientID)) then
            begin
              Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove(mob^.ClientID);
              Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
            end;
          end;
          try
            if not(Servers[Self.ChannelId].Players[Self.ClientID].SocketClosed) then
            begin
              if(mob.SecondIndex > 0) then
              begin
                if(mob.ClientID >= 3049) and (mob.ClientID <= 9147) then
                begin
                  if(Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].IsActiveToSpawn) then
                    Self.MobKilled(mob, DropExp, DropItem, False);
                end;
              end;
            end;
          except
            on E: Exception do
            begin
              Logger.Write('Erro no MobKiller: ' + E.Message + 't ' +
                DateTimeToStr(Now), TLogType.Error);
            end;
          end;

          mob^.VisibleMobs.Clear;
          Packet.MobAnimation := 30;
        end
        else
        begin
          MobsP^.HP := MobsP^.HP - Packet.Dano;
        end;
        mob^.LastReceivedAttack := Now;
        Packet.MobCurrHP := MobsP^.HP;
        Self.SendToVisible(Packet, Packet.Header.size);
        //Sleep(1);
        Exit;
      end;
    end;
  end
  else if (mob.ClientID >= 9148)  then
  begin
    if(Servers[Self.ChannelId].PETS[mob.ClientID].PetType = X14) then
    begin
    /// Define valores fixos para os atributos do pet X14


      Servers[Self.ChannelId].PETS[mob.ClientID].base.PlayerCharacter.ResDamageCritical := 5000; // Define resistência a dano crítico fixa para 50
      Servers[Self.ChannelId].PETS[mob.ClientID].Base.PlayerCharacter.CritRes := 50000; // Define taxa crítica fixa para 20
      Servers[Self.ChannelId].PETS[mob.ClientID].Base.PlayerCharacter.DamageCritical := 5000;
          // Define HP fixo para o pet X14
      Servers[Self.ChannelId].PETS[mob.ClientID].Base.PlayerCharacter.
      Base.CurrentScore.CurHP := 10000; // Defina o valor de HP fixo desejado





      Servers[Self.ChannelId].PETS[mob.ClientID].IsAttacked := True;
      Servers[Self.ChannelId].PETS[mob.ClientID].AttackerID := Self.ClientID;
      if (Packet.Dano >= mob.PlayerCharacter.Base.CurrentScore.CurHP ) then
      begin

        Packet.MobAnimation := 30;
        mob.IsDead := True;
         if(Servers[Self.ChannelId].PETS[mob.ClientID].IntName > 0) then
        begin
          if(Servers[Self.ChannelId].PETS[mob.ClientID].Base.IsActive) then
            Servers[Self.ChannelId].Players[Self.ClientID].Base.DestroyPet(
              mob.ClientID);
        end;
        Servers[Self.ChannelId].PETS[mob.ClientID].Base.Destroy;
        ZeroMemory(@Servers[Self.ChannelId].PETS[mob.ClientID], sizeof(TPet));
      end
      else
      begin
        DecCardinal(mob.PlayerCharacter.Base.CurrentScore.CurHP,
          Packet.DANO);
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob.PlayerCharacter.Base.CurrentScore.CurHP;
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      //Sleep(1);
      Exit;
    end;
  end;

  if(SecondsBetween(Now, mob.RevivedTime) <= 7) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Alvo acabou de nascer.');
    Exit;
  end;

  if (Packet.Dano >= mob^.Character.CurrentScore.CurHP) then
  begin
    if (Servers[Self.ChannelId].Players[mob^.ClientID].Dueling) then
    begin
      mob^.Character.CurrentScore.CurHP := 10;
    end
    else
    begin
      mob^.Character.CurrentScore.CurHP := 0;
      mob^.SendEffect($0);
      Packet.MobAnimation := 30;
      mob^.IsDead := True;
      if(Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare) then
      Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem(
      Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
      mob^.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      if (mob^.Character.Nation > 0) and (Self.Character.Nation > 0) then
      begin
        if ((mob^.Character.Nation <> Self.Character.Nation) or
          (Self.InClastleVerus)) then
        begin
          Self.PlayerKilled(mob);
        end;
      end;
      // Inc(Self.PlayerCharacter.Base.CurrentScore.KillPoint);
      // Self.SendRefreshKills;
      // Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
      // ('Seus pontos de PvP foram incrementados em 1.');
      // Self.SendRefreshPoint;
    end;
  end
  else
  begin
    if (Packet.Dano > 0) then
      mob^.RemoveHP(Packet.Dano, False);

    if(Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare) then
    Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem(
    Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
    mob^.LastReceivedAttack := Now;
    Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
    // Self.SendCurrentHPMP;
    Self.SendToVisible(Packet, Packet.Header.size);
  end;

  //Sleep(1);
end;
function TBaseMob.GetDamage(Skill: DWORD; mob: PBaseMob;
  out DnType: TDamageType): UInt64;
var
  ResultDamage: Integer;
  MobDef, defHelp: Integer;
  IsPhysical: Boolean;
   BaseDamage, ReducedDamage: UInt64;


begin

  try
    Result := 0;
     Self.GetCurrentScore;
    if (mob^.ClientID >= 9148) then
    begin // ataque dos pets � diferenciado
      Randomize;
      Result := (((Self.PlayerCharacter.Base.CurrentScore.DNFis +
        Self.PlayerCharacter.Base.CurrentScore.DNMAG) div 2) +
        (Random(99) + 15));
      DnType := TDamageType.Normal;
      Exit;
    end;
{$REGION 'Verifica se esta imune'}
    if (mob^.GetMobAbility(EF_IMMUNITY) > 0) then
    begin
      DnType := TDamageType.Immune;
      Exit;
    end;
    if (mob^.BuffExistsByIndex(19)) then
    begin
      if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
      begin
        mob^.RemoveBuffByIndex(19);
        Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
      end
      else
      begin
        mob^.RemoveBuffByIndex(19);
        DnType := TDamageType.Block;
        Exit;
      end;
    end;
    if (mob^.BuffExistsByIndex(91)) then
    begin
      if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
      begin
        mob^.RemoveBuffByIndex(91);
        Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
      end
      else
      begin
        mob^.RemoveBuffByIndex(91);
        DnType := TDamageType.Miss2;
        Exit;
      end;
    end;
{$ENDREGION}
{$REGION 'Verifica se o ataque � fisico ou magico'}
    case Self.GetMobClass of
      0 .. 3:
        begin
          IsPhysical := True;
        end;
    else
      if (Skill = 0) then
        IsPhysical := True
      else
        IsPhysical := False;
    end;
{$ENDREGION}
    if (IsPhysical) then
    begin
      ResultDamage := Self.PlayerCharacter.Base.CurrentScore.DNFis;
      MobDef := mob.PlayerCharacter.Base.CurrentScore.DEFFis;
      defHelp := (Self.PlayerCharacter.FisPenetration);
      if (defHelp > 0) then
      begin
        dec(MobDef, ((mob.PlayerCharacter.Base.CurrentScore.DEFFis div 100) *
          defHelp));
      end;
    end
    else
    begin
      ResultDamage := Self.PlayerCharacter.Base.CurrentScore.DNMAG;
      MobDef := mob.PlayerCharacter.Base.CurrentScore.DEFMAG;
      defHelp := (Self.PlayerCharacter.MagPenetration);
      if (defHelp > 0) then
      begin
        dec(MobDef, ((mob.PlayerCharacter.Base.CurrentScore.DEFMAG div 100) *
          defHelp));
      end;
    end;
    DnType := Self.GetDamageType3(Skill, IsPhysical, mob);
    if (DnType = Miss) then
    begin
      Result := 0;
      Exit;
    end;
    Randomize;
    ResultDamage := ResultDamage - (MobDef shr 3);
    if (mob^.ClientID <= MAX_CONNECTIONS) then
      Dec(ResultDamage,
        ((ResultDamage div 100) * (mob.GetEquipedItensDamageReduce div 10)));


    if (ResultDamage <= 0) then
      ResultDamage := 1;
    Result := ResultDamage;
  except
    on E: Exception do
    begin
      Logger.Write('TBaseMob.GetDamage Error: ' + E.Message, TLogType.Error);
      Result := (((Self.PlayerCharacter.Base.CurrentScore.DNFis +
        Self.PlayerCharacter.Base.CurrentScore.DNMAG) div 2) -
        (((mob^.PlayerCharacter.Base.CurrentScore.DEFMAG +
        mob^.PlayerCharacter.Base.CurrentScore.DEFFis) div 2) shr 3));
      DnType := TDamageType.Normal;
      Randomize;
      Inc(Result, (RandomRange(10, 120) + 15));
    end;
  end;
end;
function TBaseMob.GetDamageType(Skill: DWORD; IsPhysical: Boolean;
  mob: PBaseMob): TDamageType;
var
  RamdomArray: ARRAY [0 .. 999] OF Byte;
  RamdomSlot: WORD;
  Chance: Integer;
  DuploChance: WORD;
  CritChance, CritHelp: WORD;
  DuploHelp: WORD;
  MissHelp: WORD;
  AllChance: Word;
  xRes: TDamageType;
  function GetEmpty: WORD;
  var
    i: WORD;
  begin
    Result := 0;
    for i := 0 to 999 do
    begin
      if (RamdomArray[i] = 0) then
        Inc(Result);
    end;
  end;
  procedure SetChance(Chance: WORD; const Type1: Byte);
  var
    i: Integer;
    Empty: WORD;
    cnt: WORD;
  begin
    if (Chance = 0) then
      Exit;
    cnt := 0;
    for i := 0 to 999 do
    begin
      if(cnt >= Chance) then
        break;
      if (RamdomArray[i] = 0) then
      begin
        RamdomArray[i] := Type1;
        inc(cnt);
      end
      else
        Continue;
    end;
    AllChance := AllChance + Chance;
      {
    Empty := GetEmpty;
    if (Chance > Empty) then
      Chance := Empty;
    for i := 1 to Chance do
    begin
      RamdomSlot := RandomRange(0, 767);
      while (RamdomArray[RamdomSlot] <> 0) do
      begin
        RamdomSlot := RandomRange(0, 767);
      end;
      RamdomArray[RamdomSlot] := Type1;
    end; }
  end;
begin
  ZeroMemory(@RamdomArray, 1000);
  Randomize;
{$REGION 'Seta a chance basica dos tipos de dano'}
  if (IsPhysical) then
    Chance := 20
  else
    Chance := 30;
  SetChance(Chance, Byte(TDamageType.Critical));
  SetChance((Chance div 2), Byte(TDamageType.Miss));
{$ENDREGION}
{$REGION 'Seta de acordo com os status'}
  CritHelp := mob^.GetMobAbility(EF_RESISTANCE6) + mob^.PlayerCharacter.CritRes;

  {if (CritHelp > Self.PlayerCharacter.Base.CurrentScore.Critical) then
  begin
    CritChance := 0;
  end
  else
  begin
    CritChance := Self.PlayerCharacter.Base.CurrentScore.Critical;
    decword(CritChance, CritHelp);
  end;
  SetChance(CritChance, Byte(TDamageType.Critical)); }

      var
      PercentageDifference: Single;
    begin
      // Obter valores de Critical e CritHelp
      var CriticalValue := Self.PlayerCharacter.Base.CurrentScore.Critical;
      var CritResValue := CritHelp;

      // Calcular a diferença percentual
      if (CriticalValue > 0) or (CritResValue > 0) then
        PercentageDifference := ((CriticalValue - CritResValue) / Max(CriticalValue, CritResValue)) * 100
      else
        PercentageDifference := 0;

      // Determinar a chance de crítico com base na diferença percentual
      if PercentageDifference >= 50 then
        CritChance := 50
      else if PercentageDifference >= 20 then
        CritChance := 25
      else if PercentageDifference >= 10 then
        CritChance := 15
      else if PercentageDifference >= 5 then
        CritChance := 10
      else
        CritChance := 0;

      // Garante que CritChance esteja entre 0% e 100%
      if CritChance > 100 then
        CritChance := 100
      else if CritChance < 0 then
        CritChance := 0;

      // Configura a chance no sistema
      SetChance(CritChance, Byte(TDamageType.Critical));
    end;


  if (IsPhysical) then
  begin
    SetChance(20, Byte(TDamageType.Double));
    SetChance(20, Byte(TDamageType.DoubleCritical));
    DuploHelp := mob^.GetMobAbility(EF_RESISTANCE7) +
      mob^.PlayerCharacter.DuploRes;
    if (DuploHelp > Self.PlayerCharacter.DuploAtk) then
    begin
      DuploChance := 0;
    end
    else
    begin
      DuploChance := Self.PlayerCharacter.DuploAtk;
      decword(DuploChance, DuploHelp); // redu��o de duplo
    end;
    DuploHelp :=
      ((Self.PlayerCharacter.DuploAtk + Self.PlayerCharacter.Base.CurrentScore.
      Critical) div 3);
    if (CritHelp >= DuploHelp) then
    begin
      DuploHelp := 10;
    end;
    SetChance(DuploHelp, Byte(TDamageType.DoubleCritical));
    SetChance(DuploChance, Byte(TDamageType.Double));
  end
  else
  begin
    SetChance(20, Byte(TDamageType.DoubleCritical));
    DuploHelp :=
      ((Self.PlayerCharacter.DuploAtk + Self.PlayerCharacter.Base.CurrentScore.
      Critical) div 2);
    if (DuploHelp <= CritHelp) then
    begin
      DuploHelp := 20;
    end;
    SetChance(DuploHelp, Byte(TDamageType.DoubleCritical));
  end;
  MissHelp := mob^.PlayerCharacter.Base.CurrentScore.Esquiva;
  decword(MissHelp, Self.PlayerCharacter.Base.CurrentScore.Acerto);
  SetChance(MissHelp, Byte(TDamageType.Miss));
{$ENDREGION}
  if(AllChance > 998) then
    AllChance := 998;
  xRes := TDamageType(RamdomArray[RandomRange(1, AllChance+1)]);
  if(xRes = TDamageType.Double) then
  begin
    if((Skill > 0) and (IsPhysical)) then
    begin
      xRes := TDamageType.Normal;
    end;
  end;
  Result := xRes;
end;
function TBaseMob.GetDamageType2(Skill: DWORD; IsPhysical: Boolean;
  mob: PBaseMob): TDamageType;
var
   RamdomArray: ARRAY [0 .. 999] OF Byte;
   InitialSlot: WORD;
  MissRate, HitRate, CritRate, ResCritRate, DuploCritRate, DuploRate,
    DuploResRate: Integer;
  Helper1  , Helper2, Helper3, Helper4, Helper5, Helper6, Helper7  : Integer;
 procedure SetChance(Chance: WORD; const Type1: Byte);
    var
    i: Integer;
    begin
    if (Chance = 0) then
    Exit;
    for i := 1 to Chance do
    begin
    if (InitialSlot >= 999) then
    Continue;
    RamdomArray[InitialSlot] := Type1;
    Inc(InitialSlot);
    end;
    end;
begin
  Result := TDamageType.Normal;
  Randomize;
  Helper1 := RandomRange(1, 101);
  MissRate := ((mob^.PlayerCharacter.Base.CurrentScore.Esquiva div 250) * 100);
  if (MissRate > 80) then
    MissRate := 80; // 20% de margem de erro 1/5
  if (Helper1 <= MissRate) then
  begin // o alvo se esquivou
    HitRate := ((Self.PlayerCharacter.Base.CurrentScore.Acerto div 250) * 100);
    if (HitRate > 70) then
      HitRate := 70;
    Helper1 := RandomRange(1, 101);
    if (Helper1 <= HitRate) then
    begin // mas meu acerto furou o miss do alvo
      Result := TDamageType.Normal;
    end
    else
    begin // meu acerto não conseguiu furar a esquiva do alvo, e deu miss msm
      Result := TDamageType.Miss;
      Exit;
    end;
  end;
  CritRate := ((Self.PlayerCharacter.Base.CurrentScore.Critical div 250) * 100);
  if (CritRate > 80) then
    CritRate := 80; // 20% de critico imperfeito
  Helper3 := Random(100);
  Helper1 := RandomRange(1, 101);
  if (Helper1 <= CritRate) then
  begin // critei no alvo, sera que o alvo resiste ao meu critico?
    ResCritRate :=
      (((mob^.GetMobAbility(EF_RESISTANCE6) + mob^.PlayerCharacter.CritRes)
      div 250) * 100);
    if (ResCritRate > 60) then
      ResCritRate := 60; // 30% de resistencia a critico imperfeita
     Helper4 := Random(100);
    Helper1 := RandomRange(1, 101);
    if (Helper1 <= ResCritRate) then
    begin // critei, mas o alvo resistiu ao meu critico
      Result := TDamageType.Normal;
    end
    else
    begin // opa critei mesmo, nem a resistencia dele foi capaz de me parar
      DuploCritRate :=
        ((((Self.PlayerCharacter.Base.CurrentScore.Critical +
        Self.PlayerCharacter.DuploAtk) div 2) div 250) * 100);
      if (DuploCritRate > 60) then
        DuploCritRate := 60; // 40% de duplo critico imperfeito
       Helper5 := Random(100);
      Helper1 := RandomRange(1, 101);
      if (Helper1 <= DuploCritRate) then
      begin // carai, consegui duplo critico, M.A. de crit_rate + duplo_rate
        Result := TDamageType.Critical;
      end
      else
        Result := TDamageType.DoubleCritical;
      Exit;
    end;
  end;
  DuploRate := ((Self.PlayerCharacter.DuploAtk div 250) * 100);
  if (DuploRate > 80) then
    DuploRate := 80;
   Helper6 := Random(100);
  Helper1 := RandomRange(1, 101);
  if (Helper1 <= DuploRate) then
  begin // boa boa consegui dar duplo no cara
    DuploResRate :=
      (((mob^.GetMobAbility(EF_RESISTANCE7) + mob^.PlayerCharacter.DuploRes)
      div 250) * 100);
    if (DuploResRate > 60) then
      DuploResRate := 60;
     Helper7 := Random(100);
    Helper1 := RandomRange(1, 101);
    if (Helper1 <= DuploResRate) then
    begin // o alvo conseguiu resistir ao meu duplo, opora
      Result := TDamageType.Normal;
    end
    else
    begin
      Result := TDamageType.Double;
    end;
  end;
end;


function TBaseMob.GetDamageType3(Skill: DWORD; IsPhysical: Boolean; mob: PBaseMob): TDamageType;
var
  Esquiva, Acerto: WORD;
  Critico, ResistenciaCrit: WORD;
  Duplo, ResistenciaDuplo: WORD;
  DuploCritico, ResistenciaDuploCritico: WORD;
  TaxaCritica, TaxaAcerto, TaxaDuplo, TaxaDuploCritico: Integer;
  TaxaRand: Integer;
  Helper: Extended;
  HelperX: Integer;
  AlwaysCrit: Boolean;
begin
  AlwaysCrit := False;
  Result := TDamageType.Normal;

  {$REGION 'Calculando Acerto x Esquiva'}
  Esquiva := mob.PlayerCharacter.Base.CurrentScore.Esquiva; // Esquiva do alvo
  Acerto := Self.PlayerCharacter.Base.CurrentScore.Acerto;

  if not(mob.IsPlayer) then
  begin
    Randomize;
    Acerto := Acerto + RandomRange(20, 40);
  end;

  TaxaAcerto := Acerto - Esquiva;

  if(TaxaAcerto >= 0) then
  begin
    Randomize;
    TaxaRand := RandomRange(1, 101);

    if(TaxaAcerto > 10) then
      TaxaAcerto := 10;

    if((TaxaRand + TaxaAcerto) <= 20) and (Esquiva >= 7) then
    begin
      Result := TDamageType.Miss;
      Inc(Self.MissCount); // Ajustado para Inc sem usar IncWord, pois MissCount deve ser Integer ou similar

      if(Self.MissCount >= 3) then
      begin
        Result := TDamageType.Normal;
        Self.MissCount := 0;
      end
      else
        Exit;
    end;
  end
  else
  begin
    TaxaAcerto := Abs(TaxaAcerto);

    Helper := (TaxaAcerto / 255);
    HelperX := Trunc(Helper * 100);

    Randomize;
    TaxaRand := RandomRange(1, 101);

    HelperX := HelperX + 25;

    if(TaxaAcerto > 10) then
      TaxaAcerto := 10;

    if((TaxaRand <= (30 + TaxaAcerto)) and (Esquiva >= 3)) then
    begin
      Result := TDamageType.Miss;
      Inc(Self.MissCount); // Ajustado para Inc

      if(Self.MissCount >= 3) then
      begin
        Result := TDamageType.Normal;
        Self.MissCount := 0;
      end
      else
        Exit;
    end;
  end;
  {$ENDREGION}

  {$REGION 'Calculando Critico x Resistencia Critico'}
  Critico := Self.PlayerCharacter.Base.CurrentScore.Critical;
  ResistenciaCrit := Trunc((mob.PlayerCharacter.CritRes + 10) * 1.4);

  if not(mob.IsPlayer) then
  begin
    if(Critico >= 100) then
      AlwaysCrit := True;
  end;

  TaxaCritica := Critico - ResistenciaCrit;

  if(TaxaCritica >= 0) then
  begin
    Randomize;
    TaxaRand := RandomRange(1, 101);

    if(TaxaCritica > 25) then
      TaxaCritica := 25;

    if((TaxaRand + TaxaCritica >= 40) and (Critico >= 5)) then
    begin
      Result := TDamageType.Critical;
    end;

    if(AlwaysCrit) then
    begin
      Randomize;
      if(RandomRange(1, 4) = 2) then
        Result := TDamageType.Critical;
    end;
  end
  else
  begin
    TaxaCritica := Abs(TaxaCritica);

    Helper := (TaxaCritica / 255);
    HelperX := Trunc(Helper * 100);

    Randomize;
    TaxaRand := RandomRange(1, 101);

    if(TaxaCritica > 5) then
      TaxaCritica := 5;

    if((TaxaRand <= (15 - TaxaCritica)) and (Critico >= 9)) then
    begin
      Result := TDamageType.Critical;
    end;
  end;

  if(Self.BuffExistsByID(6347)) then
    Result := TDamageType.Critical;
  {$ENDREGION}

  case Result of
    Normal:
    begin
      {$REGION 'Calculando duplo x resistencia a duplo'}
      if(Skill = 0) then
      begin
        Duplo := Self.PlayerCharacter.DuploAtk;
        ResistenciaDuplo := Trunc((mob.PlayerCharacter.DuploRes + 5) * 1.5);

        TaxaDuplo := Duplo - ResistenciaDuplo;

        if(TaxaDuplo >= 0) then
        begin
          Randomize;
          TaxaRand := RandomRange(1, 101);

          if(TaxaDuplo > 10) then
            TaxaDuplo := 10;

          if((TaxaRand >= (80 - TaxaDuplo)) and (Duplo >= 3)) then
          begin
            Result := TDamageType.Double;
          end;
        end
        else
        begin
          TaxaDuplo := Abs(TaxaDuplo);

          Helper := (TaxaDuplo / 255);
          HelperX := Trunc(Helper * 100);

          Randomize;
          TaxaRand := RandomRange(1, 101);

          if(TaxaDuplo > 10) then
            TaxaDuplo := 10;

          if((TaxaRand <= (15 + TaxaDuplo)) and (Duplo >= 5)) then
          begin
            Result := TDamageType.Double;
          end;
        end;
      end;
      {$ENDREGION}
    end;

    Critical:
    begin
      {$REGION 'Calculando duplo critico'}
      DuploCritico := (Self.PlayerCharacter.DuploAtk +
        Self.PlayerCharacter.Base.CurrentScore.Critical) div 2;

      ResistenciaDuploCritico := Trunc(((mob.PlayerCharacter.DuploRes +
        mob.PlayerCharacter.CritRes) * 1.4) / 2);

      TaxaDuploCritico := DuploCritico - ResistenciaDuploCritico;

      if(TaxaDuploCritico >= 0) then
      begin
        Randomize;
        TaxaRand := RandomRange(1, 101);

        if(TaxaRand >= 95) then // Ajuste para 80% de chance
        begin
          Result := TDamageType.DoubleCritical;
        end;
      end
      else
      begin
        TaxaDuploCritico := Abs(TaxaDuploCritico);

        Helper := (TaxaDuploCritico / 500);
        HelperX := Trunc(Helper * 100);

        Randomize;
        TaxaRand := RandomRange(1, 101 + HelperX);

        HelperX := HelperX ; // Ajuste para aumentar a chance de duplo crítico

        if(TaxaRand <= HelperX) then
        begin
          Result := TDamageType.DoubleCritical;
        end;
      end;
      {$ENDREGION}
    end;
  end;
end;


procedure TBaseMob.CalcAndCure(Skill: DWORD; mob: PBaseMob);
const
  MAX_CURE_LIMIT = 80000;           // Cura máxima padrão
  MAX_CURE_LIMIT_CRITICAL = 30000;   // Cura máxima com dano crítico alto
var
  Cure: Cardinal;
  curePerc: Integer;
  MaxLimit: Cardinal;
  BeforeHP, HealedAmount: Integer;
begin
  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);

  Inc(Cure, SkillData[Skill].Damage);
  Inc(Cure, ((Cure div 40) * Self.GetMobAbility(EF_DAMAGE6)));
  Inc(Cure, (Self.GetMobAbility(EF_SKILL_DAMAGE6)));

  if (Self.ClientID <> mob.ClientID) then
  begin
    Inc(Cure, ((Cure div 40) * mob.GetMobAbility(EF_DAMAGE6)));
    Inc(Cure, (mob.GetMobAbility(EF_SKILL_DAMAGE6)));
  end;

  Inc(Cure, ((Cure div 100) * mob.PlayerCharacter.CureTax));
  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));
  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_PER_CURE_PREPARE)));

  Randomize;
  curePerc := ((RandomRange(20, 299) div 2) + 35);
  Inc(Cure, curePerc);

  DecCardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  // Anticura ativa
  if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
  begin
    mob.NegarCuraCount := 3;
    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount - 1;
    Exit;
  end
  else if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0)) then
  begin
    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.NegarCuraCount := mob.NegarCuraCount - 1;
    mob.LastReceivedAttack := Now;

    if (mob.NegarCuraCount = 0) then
      mob.RemoveBuffByIndex(88);

    Exit;
  end;

  // 🔹 Multiplica a cura por 3 antes de aplicá-la ao mob
  Cure := Cure * CURAPLAYER;

  // Limita a cura se o dano crítico for muito alto
  if (Self.PlayerCharacter.DamageCritical > 600) or (mob.PlayerCharacter.DamageCritical > 600) then
    MaxLimit := MAX_CURE_LIMIT_CRITICAL
  else
    MaxLimit := MAX_CURE_LIMIT;

  if Cure > MaxLimit then
    Cure := MaxLimit;

  // Armazena o HP antes da cura
  BeforeHP := mob.Character.CurrentScore.CurHP;

  // Aplica a cura
  mob.AddHP(Cure, True);

  // Calcula quanto foi efetivamente curado
  HealedAmount := mob.Character.CurrentScore.CurHP - BeforeHP;
  if HealedAmount < 0 then
  HealedAmount := 0;

  mob.GetCurrentScore;
  mob.SendCurrentHPMP;




  // Mensagem para o player
  if (mob.ClientID = Self.ClientID) then
  begin
    Servers[Self.ChannelId].Players[mob.ClientId].SendClientMessage(
      'Seu HP foi restaurado em ' + AnsiString(IntToStr(HealedAmount)), 16);
  end
  else
  begin
    Servers[Self.ChannelId].Players[mob.ClientId].SendClientMessage(
      'Seu HP foi restaurado em ' + AnsiString(IntToStr(HealedAmount)) +
      ' por [' + AnsiString(Self.Character.Name) + '].', 16);
  end;
end;




function TBaseMob.CalcCure(Skill: DWORD; mob: PBaseMob): Integer;
var
  Cure: Cardinal;
  curePerc: Integer;
begin
  Result := 0;

  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);

  Inc(Cure, SkillData[Skill].Damage);

  Inc(Cure, ((Cure div 40) * Self.GetMobAbility(EF_DAMAGE6)));
  Inc(Cure, (Self.GetMobAbility(EF_SKILL_DAMAGE6)));
  if(Self.ClientID <> mob.ClientID) then
  begin
    Inc(Cure, ((Cure div 40) * mob.GetMobAbility(EF_DAMAGE6)));
    Inc(Cure, (mob.GetMobAbility(EF_SKILL_DAMAGE6)));
  end;

  Inc(Cure, ((Cure div 100) * mob.PlayerCharacter.CureTax));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_PER_CURE_PREPARE)));

  Randomize;
  curePerc := ((RandomRange(20, 299) div 2) + 35);
  Inc(Cure, curePerc);

  DecCardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  if((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
  begin
    mob.NegarCuraCount := 3;

    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount -1;

    Exit;
  end
  else if((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0)) then
  begin
    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount -1;

    if(mob.NegarCuraCount = 0) then
    begin
      mob.RemoveBuffByIndex(88);
    end;

    Exit;
  end;

  Result := Cure;
end;

function TBaseMob.CalcCure2(BaseCure: DWORD; mob: PBaseMob; xSkill: Integer): Integer;
var
  Cure: Cardinal;
  curePerc: Integer;
begin
  Result := 0;

  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);
  Cure := Cure + BaseCure;


  if(xSkill > 0) then
  begin
    Inc(Cure, SkillData[xSkill].Damage);
  end;

  Inc(Cure, ((Cure div 40) * Self.GetMobAbility(EF_DAMAGE6)));
  Inc(Cure, (Self.GetMobAbility(EF_SKILL_DAMAGE6)));
  if(Self.ClientID <> mob.ClientID) then
  begin
    Inc(Cure, ((Cure div 40) * mob.GetMobAbility(EF_DAMAGE6)));
    Inc(Cure, (mob.GetMobAbility(EF_SKILL_DAMAGE6)));
  end;

  Inc(Cure, ((Cure div 100) * mob.PlayerCharacter.CureTax));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_PER_CURE_PREPARE)));

  Randomize;
  curePerc := ((RandomRange(20, 299) div 2) + 35);
  Inc(Cure, curePerc);

  DecCardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  if(SkillData[xSkill].Index <> 125) then
  begin
    if((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
    begin
      mob.NegarCuraCount := 3;

      mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
      mob.LastReceivedAttack := Now;
      mob.NegarCuraCount := mob.NegarCuraCount -1;

      Exit;
    end
    else if((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0)) then
    begin
      mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
      mob.LastReceivedAttack := Now;
      mob.NegarCuraCount := mob.NegarCuraCount -1;

      if(mob.NegarCuraCount = 0) then
      begin
        mob.RemoveBuffByIndex(88);
      end;

      Exit;
    end;
  end;

  Result := Cure;
end;
procedure TBaseMob.HandleSkill(Skill, Anim: DWORD; mob: PBaseMob;
  SelectedPos: TPosition; DataSkill: P_SkillData);
var
  Packet: TRecvDamagePacket;
  gotDano: Integer;
  gotDMGType: TDamageType;
  Add_Buff: Boolean;
  Resisted: Boolean;
  DropExp, DropItem: Boolean;
  j: Integer;
  s: Integer;
  Helper2: Byte;
  SelfPlayer, OtherPlayer: PPlayer;
  Mobs: PMobSa;
  MobsP: PMobSPoisition;
  Rand: Integer;
begin
  s := sizeof(Packet);
  ZeroMemory(@Packet, s);
  Packet.Header.size := s;
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  if (mob^.ClientID = Self.ClientID) then
    Packet.TargetID := Self.ClientID
  else
    Packet.TargetID := mob^.ClientID;
  Packet.MobAnimation := DataSkill^.TargetAnimation;

   if (SkillData[Skill].SuccessRate = 1) and (SkillData[Skill].range > 0) then
begin
  // Verifica se é uma habilidade específica que precisa de ajuste de posição
  if ((SkillData[Skill].Index = 102) or (SkillData[Skill].Index = 118)) then
  begin
    SelectedPos := mob.PlayerCharacter.LastPos;
  end;

  // Chama AreaSkill com os parâmetros necessários
  Self.AreaSkill(Skill, Anim, mob, SelectedPos, @SkillData[Skill], 100.0, 0);
end;

  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  if (DataSkill^.SuccessRate = 1) and (DataSkill^.range = 0) then
  begin // skills de ataque single[Target]
    Resisted := False;
    case Self.GetMobClass() of
      2:
      begin
        if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 1);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);
          end;
      end;

      3:
        begin
          if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 2);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);
          end;
        end;
    end;
    Self.TargetSkill(Skill, Anim, mob, gotDano, gotDMGType, Add_Buff, Resisted);

    if (gotDano > 0) then
    begin
      Self.AttackParse(Skill, Anim, mob, gotDano, gotDMGType, Add_Buff,
        Packet.MobAnimation, DataSkill);

      if(gotDano > 0) then
      begin
        Inc(gotDano, ((RandomRange((gotDano div 20), (gotDano div 10))) + 13));
      end;
    end
    else
    begin
      if not(gotDMGType in [Critical, Normal, Double]) then
        Add_Buff := False;
    end;

    if (Add_Buff = True) then
    begin
      if not(Resisted) then
        Self.TargetBuffSkill(Skill, Anim, mob, DataSkill);
    end;
    Packet.Dano := gotDano;
    Packet.DnType := gotDMGType;
    if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
    begin
      if (Packet.Dano >= DungeonInstances[Servers[Self.ChannelId].Players
        [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid].CurrentHP) then
      begin
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP := 0;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[mob.Mobid].IsAttacked := False;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[mob.Mobid].AttackerID := 0;
        { DungeonInstances
          [Servers[Self.ChannelId].Players[Self.ClientId].DungeonInstanceID]
          .Mobs[mob.Mobid].deadTime := Now; }
        if (Self.VisibleMobs.Contains(mob.ClientID)) then
          Self.VisibleMobs.Remove(mob.ClientID);
        mob.VisibleMobs.Clear;
        Self.MobKilledInDungeon(mob);
        Packet.MobAnimation := 30;
        mob.IsDead := True;
      end
      else
      begin
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP :=
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP - Packet.Dano;
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := DungeonInstances
        [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs
        [mob.Mobid].CurrentHP;
      Self.SendToVisible(Packet, Packet.Header.size);
      Exit;
    end;

    MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[0].MobsP[1];
    if(mob^.SecondIndex > 0) then
      MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP
        [mob^.SecondIndex];

    if (mob^.ClientID <= MAX_CONNECTIONS) then

    begin
      if(SecondsBetween(Now, mob.RevivedTime) <= 7) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Alvo acabou de nascer.');
        Exit;
      end;
          // divide a pancada de sangue por 2
      {if ((DataSkill^.index = PANCADA ) and (Packet.Dano > (Self.Character.CurrentScore.MaxHp * 2 ) )) then
      begin
        Packet.Dano:= (Self.Character.CurrentScore.MaxHp * 2 );
      end;}

      OtherPlayer := @Servers[mob^.ChannelId].Players[mob^.ClientID];
      if (Packet.Dano >= mob^.Character.CurrentScore.CurHP) then
      begin
        if (OtherPlayer^.Dueling) then
        begin
          mob^.Character.CurrentScore.CurHP := 10;
        end
        else
        begin
          mob^.Character.CurrentScore.CurHP := 0;
          mob^.SendEffect($0);
          Packet.MobAnimation := 30;
          mob^.IsDead := True;
          if(Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare) then
            Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem(
            Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          if (mob^.Character.Nation > 0) and (Self.Character.Nation > 0) then
          begin
            if ((mob^.Character.Nation <> Self.Character.Nation) or
              (Self.InClastleVerus))  then
            begin
              Self.PlayerKilled(mob);
            end;
          end;
        end;
      end
      else
      begin
        if (Packet.Dano > 0) then
          mob^.RemoveHP(Packet.Dano, False);
        if(Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare) then
          Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem(
          Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
        mob^.LastReceivedAttack := Now;
        Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
        Self.SendToVisible(Packet, Packet.Header.size);
      end;

      Exit;
    end
    else if (((mob^.ClientID >= 3048) and (mob^.ClientID < 9148)) or (MobsP.isTemp)) then
    begin
      // Mobs := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid];
      case mob^.ClientID of
        3340 .. 3354:
          begin // stones
            if ((Packet.Dano >= Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP)and not(mob^.IsDead)) then
            begin
              mob^.IsDead := True;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 0;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .IsAttacked := False;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .AttackerID := 0;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .deadTime := Now;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID].
                KillStone(mob^.ClientID, Self.ClientId);
              if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
              begin
                Self.VisibleNPCs.Remove(mob^.ClientID);
                Self.RemoveTargetFromList(mob);
                // essa skill tem retorno no caso de erro
              end;
              for j in Self.VisiblePlayers do
              begin
                if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(mob^.ClientID)) then
                begin
                  Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(mob^.ClientID);
                  Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
                end;
              end;
              mob^.VisibleMobs.Clear;
              // Self.MobKilled(mob, DropExp, DropItem, False);
              Packet.MobAnimation := 30;
            end
            else
            begin
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
                .DevirStones[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
                Packet.Dano;
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Self.SendToVisible(Packet, Packet.Header.size);
            Exit;


          end;
        3355 .. 3369:
          begin // guards
            if ((Packet.Dano >= Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP)and not(mob^.IsDead)) then
            begin
              mob^.IsDead := True;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 0;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .IsAttacked := False;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .AttackerID := 0;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .deadTime := Now;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID].
                KillGuard(mob^.ClientID, Self.ClientId);
              if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
              begin
                Self.VisibleNPCs.Remove(mob^.ClientID);
                Self.RemoveTargetFromList(mob);
                // essa skill tem retorno no caso de erro
              end;
              for j in Self.VisiblePlayers do
              begin
                if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(mob^.ClientID)) then
                begin
                  Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(mob^.ClientID);
                  Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
                end;
              end;
              mob^.VisibleMobs.Clear;
              // Self.MobKilled(mob, DropExp, DropItem, False);
              Packet.MobAnimation := 30;
            end
            else
            begin
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
                .DevirGuards[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
                Packet.Dano;
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Self.SendToVisible(Packet, Packet.Header.size);
            //Sleep(1);
            Exit;
          end;
      else
        begin
          MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP
            [mob.SecondIndex];

          if not(MobsP.IsAttacked) then
          begin
            MobsP.FirstPlayerAttacker := Self.ClientID;
          end;

          if (Packet.Dano >= MobsP^.HP) then
          begin
            MobsP^.HP := 0;
            MobsP^.IsAttacked := False;
            MobsP^.AttackerID := 0;
            MobsP^.deadTime := Now;

            MobsP.Base.SendEffect($0);
            if (Self.VisibleMobs.Contains(mob^.ClientID)) then
            begin
              Self.VisibleMobs.Remove(mob^.ClientID);
              Self.RemoveTargetFromList(mob);
            end;
            for j in Self.VisiblePlayers do
            begin
              if(Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains(mob^.ClientID)) then
              begin
                Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove(mob^.ClientID);
                Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
              end;
            end;
            // ver aquele bang de tirar na lista propia
            mob^.VisibleMobs.Clear;
            mob^.IsDead := True;
            { Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
              ('Adquiriu ' + AnsiString(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid]
              .MobExp.ToString) + ' + ' +
              AnsiString((Servers[Self.ChannelId].Players[Self.ClientId]
              .AddExp(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobExp,
              EXP_TYPE_MOB) - Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobExp)
              .ToString) + ' exp.', 0); }
            Self.MobKilled(mob, DropExp, DropItem, False);
            Packet.MobAnimation := 30;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := MobsP^.HP;
            Self.SendToVisible(Packet, Packet.Header.size);
          end
          else
          begin
            deccardinal(MobsP^.HP, Packet.Dano);
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := MobsP^.HP;
            Self.SendToVisible(Packet, Packet.Header.size);
          end;

          //Sleep(1);
          Exit;
        end;
      end;
    end
    else if (mob^.ClientID >= 9148) then
    begin
      Servers[Self.ChannelId].PETS[mob.ClientID].IsAttacked := True;
      Servers[Self.ChannelId].PETS[mob.ClientID].AttackerID := Self.ClientID;
      if (Packet.Dano >= mob.PlayerCharacter.Base.CurrentScore.CurHP) then
      begin
        mob.PlayerCharacter.Base.CurrentScore.CurHP := 0;
        Packet.MobAnimation := 30;
        mob.IsDead := True;
        {for j in mob.VisibleMobs do
        begin
          if not(j >= 3048) then
          begin
            Servers[Self.ChannelId].Players[j].UnSpawnPet(mob.ClientID);
          end;
        end; }

        if(Servers[Self.ChannelId].PETS[mob.ClientID].IntName > 0) then
        begin
          if(Servers[Self.ChannelId].PETS[mob.ClientID].Base.IsActive) then
            Servers[Self.ChannelId].Players[Self.ClientID].Base.DestroyPet(
              mob.ClientID);
        end;
        Servers[Self.ChannelId].PETS[mob.ClientID].Base.Destroy;
        ZeroMemory(@Servers[Self.ChannelId].PETS[mob.ClientID], sizeof(TPet));
      end
      else
      begin
        DecCardinal(mob.PlayerCharacter.Base.CurrentScore.CurHP,
          Packet.DANO);
         //:=
          //mob.PlayerCharacter.Base.CurrentScore.CurHP - Packet.Dano;
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob.PlayerCharacter.Base.CurrentScore.CurHP;
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      //Sleep(1);
      Exit;
    end;
  end;
  if (DataSkill^.SuccessRate = 0) and (DataSkill^.range = 0) then
  begin // skills de buff single[Self div Target]
    Packet.DnType := TDamageType.None;
    Packet.Dano := 0;
    Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;

    if (Self.IsCompleteEffect5(Helper2)) then
    begin
      Randomize;
      Rand := RandomRange(1, 101);
      if (Rand <= (RATE_EFFECT5*Length(Self.EFF_5))) then
      begin
        Self.Effect5Skill(@Self, Helper2, True);
      end;
    end;

    if (DataSkill^.TargetType = 1) then
    begin // [Self]
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      Self.SelfBuffSkill(Skill, Anim, mob, SelectedPos);
    end
    else
    begin // [Target]
      // Self.SendCurrentHPMP;
      if (DataSkill^.Classe >= 61) and (DataSkill^.Classe <= 84) then
      begin // skills de pran
        case SelfPlayer^.SpawnedPran of
          0:
            begin
              Packet.AttackerPos := SelfPlayer^.Account.Header.Pran1.Position;
              Packet.AttackerID := SelfPlayer^.Account.Header.Pran1.id;
              Packet.TargetID := Self.ClientID;
              Randomize;
              Rand := RandomRange(1, 225);
              if (Rand > SelfPlayer^.Account.Header.Pran1.Devotion) then
              begin
                SelfPlayer^.SendClientMessage
                  ('Pran se recusou por conta da familiaridade.');
                Self.SendToVisible(Packet, Packet.Header.size);
                Exit;
              end;
            end;
          1:
            begin
              Packet.AttackerPos := SelfPlayer^.Account.Header.Pran2.Position;
              Packet.AttackerID := SelfPlayer^.Account.Header.Pran2.id;
              Packet.TargetID := Self.ClientID;
              Randomize;
              Rand := RandomRange(1, 225);
              if (Rand > SelfPlayer^.Account.Header.Pran2.Devotion) then
              begin
                SelfPlayer^.SendClientMessage
                  ('Pran se recusou por conta da familiaridade.');
                Self.SendToVisible(Packet, Packet.Header.size);
                Exit;
              end;
            end;
        end;
      end;
      Self.SendToVisible(Packet, Packet.Header.size);
      //Sleep(1);
      Self.TargetBuffSkill(Skill, Anim, mob, DataSkill);
    end;
    Exit;
  end;
  if (DataSkill^.SuccessRate = 0) and (DataSkill^.range > 0) then
  begin // skills de buff em area [ou em party]
    if (Self.IsCompleteEffect5(Helper2)) then
    begin
      Randomize;
      Rand := RandomRange(1, 101);
      if (Rand <= (RATE_EFFECT5*Length(Self.EFF_5))) then
      begin
        Self.Effect5Skill(@Self, Helper2, True);
      end;
    end;

    Packet.DnType := TDamageType.None;
    Packet.Dano := 0;
    Packet.MobCurrHP := mob.Character.CurrentScore.CurHP;
    Packet.DeathPos := SelectedPos;
    Packet.TargetID := Self.ClientID;
    // Self.SendCurrentHPMP;
    Self.SendToVisible(Packet, Packet.Header.size);
    //Sleep(1);
    Self.AreaBuff(Skill, Anim, mob, Packet);
    Exit;
  end;
end;
function TBaseMob.ValidAttack(DmgType: TDamageType; DebuffType: Byte;
  mob: PBaseMob; AuxDano: Integer; xisBoss: Boolean): Boolean;
var
  Rate: Integer;
  Rand: Integer;
  VerifyToCastle: Boolean;
begin
  Result := False;
  VerifyToCastle := False;
  case DmgType of
    Normal, Critical, Double, DoubleCritical:
      begin
        Result := True;
      end;
    Miss:
      Result := False;
  end;
  if (mob = nil) then
    Exit;
  if (mob^.ClientID >= 3048) or (mob^.IsDungeonMob) then
  begin
    if((mob.IsBoss) and not(xisBoss)) then
    begin
      Result := False;
    end;
    Exit;
  end;

  if not(Result) then
    Exit;

  if(AuxDano > 0) then
  begin //aviso da bolha
    if (mob^.BuffExistsByIndex(36) = True) and (mob^.BuffExistsByIndex(365) = True)then
    begin
      Result := False;
      Exit;
    end;
  end
  else //apenas sair
  begin
    if (mob^.BuffExistsByIndex(36) = True) and (mob^.BuffExistsByIndex(365) = True) then
    begin
      dec(mob^.BolhaPoints, 1);
      if (mob^.BolhaPoints = 0) then
      begin
        mob^.RemoveBuffByIndex(36);
       // mob^.RemoveBuffByIndex(365);
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('[' + AnsiString(mob.Character.Name) +
          '] resistiu � sua habilidade de ataque.', 16, 1, 1);
        Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Voc� resistiu ao de ataque de [' +
        AnsiString(Self.Character.Name) + '] Prote��o desativada.', 16, 1, 1);
      end
      else
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('[' + AnsiString(mob.Character.Name) +
          '] resistiu � sua habilidade de ataque.', 16, 1, 1);
        Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Voc� resistiu ao ataque de [' +
        AnsiString(Self.Character.Name) + '] restam ' +
        mob.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
      end;

      Result := False;
      Exit;
    end;
  end;

  if (Result = True) then
  begin
    if (DebuffType = 0) then
      Exit;
    Randomize;
    Rand := RandomRange(1, 255);
    Rate := 0;
    Rate := Trunc(Self.PlayerCharacter.Resistence / 5);
    Rate := Rate + Self.GetMobAbility(EF_STATE_RESISTANCE);
    case DebuffType of
      STUN_TYPE:
        begin
          Rate := 100 + mob^.GetMobAbility(EF_IM_SKILL_STUN);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu � sua habilidade de stun.');
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Voc� resistiu � habilidade de stun de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
      SILENCE_TYPE:
        begin
          Rate := 100 + mob^.GetMobAbility(EF_IM_SILENCE1);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu � sua habilidade de sil�ncio.');
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Voc� resistiu � habilidade de sil�ncio de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
      FEAR_TYPE:
        begin
          Rate := 100 + mob^.GetMobAbility(EF_IM_FEAR);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu � sua habilidade de medo.');
            Servers[mob.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Voc� resistiu � habilidade de medo de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
      LENT_TYPE:
        begin
          Rate := 100 + mob^.GetMobAbility(EF_IM_RUNSPEED);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu � sua habilidade de lentid�o.');
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Voc� resistiu � habilidade de lentid�o de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
      CHOCK_TYPE:
        begin
          Rate := 100 + mob^.GetMobAbility(EF_IM_SKILL_SHOCK);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu � sua habilidade de choque.');
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Voc� resistiu � habilidade de choque de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
      PARALISYS_TYPE:
        begin
          Rate := 100 + mob^.GetMobAbility(EF_IM_SKILL_IMMOVABLE);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu � sua habilidade de paralisia.');
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Voc� resistiu � habilidade de paralisia de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
    end;

    if(VerifyToCastle) then
    begin
      if(mob^.InClastleVerus) then
      begin
        mob^.LastReceivedSkillFromCastle := Now;
      end;
    end;
  end;
end;
procedure TBaseMob.MobKilledInDungeon(mob: PBaseMob);
var
  MobExp, ExpAcquired, NIndex, Helper: Integer;
  i, RandomClientID, j, k: WORD;
begin
  ExpAcquired := 0;
  MobExp := DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
    .DungeonInstanceID].Mobs[mob.Mobid].MobExp;
  for i in Servers[Self.ChannelId].Players[Self.ClientID].Party.Members do
  begin
    case Servers[Self.ChannelId].Players[Self.ClientID].Party.ExpAlocate of
      1: // igualmente
        begin
          MobExp := (MobExp div Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.Members.Count);
          ExpAcquired := Servers[Self.ChannelId].Players[i].AddExp(MobExp, Helper,
            EXP_TYPE_MOB);
        end;
      2: // individualmente
        begin
          if (i = DungeonInstances[Servers[Self.ChannelId].Players
            [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid]
            .FirstPlayerAttacker) then
          begin
            ExpAcquired := Servers[Self.ChannelId].Players[i].AddExp(MobExp, Helper,
              EXP_TYPE_MOB);
          end;
        end;
    end;
    case Servers[Self.ChannelId].Players[Self.ClientID].Party.ItemAlocate of
      1: // em ordem
        begin
          NIndex := Servers[Self.ChannelId].Players[Self.ClientID]
            .Party^.LastSlotItemReceived;
          if (i = Servers[Self.ChannelId].Players[Self.ClientID].Party.Leader)
          then
          begin
            Self.DropItemFor(@Servers[Self.ChannelId].Players
              [Servers[Self.ChannelId].Players[Self.ClientID]
              .Party^.Members.ToArray[NIndex]].Base, mob);
            Inc(Servers[Self.ChannelId].Players[Self.ClientID]
              .Party^.LastSlotItemReceived);
            NIndex := Servers[Self.ChannelId].Players[Self.ClientID]
              .Party^.LastSlotItemReceived;
          end;
          { if (Servers[Self.ChannelId].Players[Self.ClientID]
            .Party^.Members.ToArray[NIndex] = i) then
            begin
            Inc(Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.LastSlotItemReceived);
            Self.DropItemFor(@Servers[Self.ChannelId].Players[i].Base, mob);
            end; }
          if (NIndex >= (Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.Members.Count)) then // reiniciar a ordem
            Servers[Self.ChannelId].Players[Self.ClientID]
              .Party.LastSlotItemReceived := 0;
        end;
      2: // aleatorio
        begin
          if (i = Servers[Self.ChannelId].Players[Self.ClientID].Party.Leader)
          then
          begin
            Randomize;
            RandomClientID := Servers[Self.ChannelId].Players[Self.ClientID]
              .Party.Members.ToArray
              [RandomRange(0, Servers[Self.ChannelId].Players[Self.ClientID]
              .Party.Members.Count+1)];
            Self.DropItemFor(@Servers[Self.ChannelId].Players[RandomClientID]
              .Base, mob);
          end;
        end;
      3: // individualmente
        begin
          if (i = DungeonInstances[Servers[Self.ChannelId].Players
            [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid]
            .FirstPlayerAttacker) then
          begin
            Self.DropItemFor(@Servers[Self.ChannelId].Players[i].Base, mob);
          end;
        end;
      4: // lider
        begin
          if (i = Servers[Self.ChannelId].Players[Self.ClientID].Party.Leader)
          then
          begin
            Self.DropItemFor(@Servers[Self.ChannelId].Players[i].Base, mob);
          end;
        end;
    end;
    if (ExpAcquired > 0) then
    begin
      // Servers[Self.ChannelId].Players[i].SendClientMessage
      // ('Adquiriu ' + AnsiString(IntToStr(ExpAcquired)) + ' exp.', 0);
      if not(Servers[Self.ChannelId].Players[i].SpawnedPran = 255) then
      begin
        Servers[Self.ChannelId].Players[i].SendClientMessage
          ('Voc� e sua pran n�o podem adquirir experi�ncia em calabou�os. ', 0);
      end;
    end;
    for j := 0 to 49 do
    begin
      if (Servers[Self.ChannelId].Players[i].PlayerQuests[j].id > 0) then
      begin // se existir quest no jogador
        if not(Servers[Self.ChannelId].Players[i].PlayerQuests[j].IsDone) then
        begin // se a quest ainda n�o foi entregue
          for k := 0 to 4 do
          begin // checa cada requiriment de mob
            if (Servers[Self.ChannelId].Players[i].PlayerQuests[j]
              .Quest.RequirimentsType[k] = 1) then
            // se o requiriment checado for de mob kill
            begin
              if (Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                .Quest.Requiriments[k] = DungeonInstances
                [Servers[Self.ChannelId].Players[i].DungeonInstanceID].Mobs
                [mob.Mobid].IntName) then // se o mob morto for o mesmo da quest
              begin
                Inc(Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                  .Complete[k]);
                if (Servers[Self.ChannelId].Players[i].PlayerQuests[j].Complete
                  [k] >= Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                  .Quest.RequirimentsAmount[k]) then
                begin
                  Servers[Self.ChannelId].Players[i].PlayerQuests[j].Complete[k]
                    := Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                    .Quest.RequirimentsAmount[k];
                  Servers[Self.ChannelId].Players[i].SendClientMessage
                    ('Voc� completou a quest [' +
                    AnsiString(Quests[Servers[Self.ChannelId].Players[i]
                    .PlayerQuests[j].Quest.QuestID].Titulo) + ']');
                  // aqui vai o aviso de quest completa
                end;
                Servers[Self.ChannelId].Players[i].UpdateQuest
                  (Servers[Self.ChannelId].Players[i].PlayerQuests[j].id);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;
procedure TBaseMob.MobKilled(mob: PBaseMob; out DroppedExp: Boolean;
  out DroppedItem: Boolean; InParty: Boolean);
var
  i, j: Integer;
  ExpAcquired, PranExpAcquired: Int64;
  MobExp, CalcAux, CalcAuxRlq: Integer;
  DropExp, DropItem: Boolean;
  A, HelperX { B } : Integer;
  NIndex: WORD;
  // ClientIDReceiveItem: WORD;
  RandomClientID: Integer;
  // ItemReceived: Boolean;
  SelfPlayer, OtherPlayer: PPlayer;
  MobsP: PMobSPoisition;
  NumBaus: Integer;
  RandomPlayerID : integer;
  ItemID: Integer;
  PossibleItems: array[1..999] of Integer; // Lista de itens possíveis para o baú
  MobT: PMobSa;


 begin





   // aqui ser� a fun��o que verificar� quest e dar� drop/exp
  ExpAcquired := 0;
  PranExpAcquired := 0;
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  if (mob^.ClientID <= MAX_CONNECTIONS) then
  begin
    Exit;
    //OtherPlayer := @Servers[mob^.ChannelId].Players[mob^.ClientID];
  end
  else if((mob^.ClientID >= 3048) and (mob^.ClientID <= 9147)) then
  begin
    MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP
      [mob^.SecondIndex];
  end
  else
    Exit;

  if (SelfPlayer^.PartyIndex <> 0) and (InParty = False) then
  begin
    A := 0;
    for i in SelfPlayer^.Party.Members do
    begin
      DropExp := False;
      DropItem := False;
      Servers[Self.ChannelId].Players[i].Base.MobKilled(mob, DropExp,
        DropItem, True);
      if (DropExp = True) then
        Inc(A);
    end;
    if (A = 0) then
    begin // cara de outra pt ou fora da pt quem atacou (Exp)
      if(MobsP^.FirstPlayerAttacker <> 0) then
      begin
        if not(MobsP^.FirstPlayerAttacker = Self.ClientID) then
        begin
          DropExp := False;
          DropItem := False;
          Servers[Self.ChannelId].Players[MobsP^.FirstPlayerAttacker]
            .Base.MobKilled(mob, DropExp, DropItem, False);
        end;
      end;
    end;
    Exit;
  end;

  // fuinção que informa e impede o drop com inventario cheio

  {if(TItemFunctions.GetEmptySlot(SelfPlayer^) = 255) then
  begin
    SelfPlayer.SendClientMessage('Seu invent�rio est� cheio. Recompensas n�o ser�o recebidas.');
    Exit;
  end; }





  if (SelfPlayer^.InDungeon) then
  begin
    MobExp := DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
      .DungeonInstanceID].Mobs[mob.Mobid].MobExp;
  end
  else
  begin
    HelperX := (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel-Self.Character.Level);
    case HelperX of
      -255..-8:
        begin //cinza
          MobExp := 1;
        end;
      -7..-3:
        begin //azul
          MobExp := Round(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp * 0.5);
        end;

      -2..2: //amarelo
        begin
          MobExp := (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp * 1);
        end;

      3..5: //laranja
        begin
          MobExp := Round(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp *1.5);
        end;

      6..255: //roxo
      begin
        MobExp := Round(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp * 0.2);
      end;

    else
      MobExp := (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp * 1);
    end;

    if not(MobExp = 1) then
    begin
      MobExp := MobExp * 4;
    end;

   { if((Self.Character.Level+2 >= (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel)) and
    (Self.Character.Level+2 >= (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel))) then


    if (Self.Character.Level+2 >= (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel)) then
      MobExp := Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp
    else if ((Self.Character.Level+4 >= Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel) ) then// essa aqui � a verifica��o dos mobs que tem nome cinza pra n dar xp
    begin
      if (((Self.Character.Level+3 >= Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel)) or (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP[mob.SecondIndex].isMutant)) then
        MobExp := Round(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp *1.5)
      else
        MobExp := (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp div 8);
    end
    else
    if ((Self.Character.Level >= Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel-4) or  Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP[mob.SecondIndex].isMutant) then
    begin
      MobExp := (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp div 3);
    end
    else
      MobExp := 1;}
  end;

  if(Self.Character <> nil) then
    if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    begin
      MobExp := MobExp + ((MobExp div 100) * Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_EXP]);
    end;

  try
    if (InParty) then
    begin // est� em grupo
      if not(MobsP^.CurrentPos.InRange(Self.PlayerCharacter.LastPos, 55)) then
        begin
       SelfPlayer^.SendClientMessage('Você está muito longe para receber Drop e XP.', 0);
        Exit;
       end;
      case SelfPlayer^.Party.ExpAlocate of
        1: // igualmente
          begin
            j := 0;
            for I in SelfPlayer^.Party.Members do
            begin
              if(Self.PlayerCharacter.LastPos.Distance(
                Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos) <= DISTANCE_TO_WATCH) then
              begin
                j := j +1;
              end;
            end;

            if(j = 0) then j := 1;

            MobExp := (MobExp div j);
            if(MobExp = 0) then
              MobExp := 1;
            ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
            DroppedExp := True;
          end;
        2: // individualmente
          begin
             if (SelfPlayer^.InDungeon) then
            begin
              if (Self.ClientID = DungeonInstances[Servers[Self.ChannelId].Players
                [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid]
                .FirstPlayerAttacker) then
              begin
                ExpAcquired := Servers[Self.ChannelId].Players[Self.ClientID]
                  .AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
                DroppedExp := True;
              end;
            end
            else
            begin
              if(MobsP^.FirstPlayerAttacker <> 0) then
              begin
                if (Self.ClientID = MobsP^.FirstPlayerAttacker) then
                begin
                  ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
                  DroppedExp := True;
                end;
              end
              else
              begin
                ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
                DroppedExp := True;
              end;
            end;
          end;
      end;
      if(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].InitHP > 999999) then
      begin //MobsP
        if(Servers[mob^.ChannelId].Players[Self.ClientID].Party.InRaid) then
        begin
          for I in Servers[mob^.ChannelId].Players[Self.ClientID].Party.Members do
          begin
            if MobsP^.CurrentPos.InRange(
                Servers[mob^.ChannelId].Players[i].Base.PlayerCharacter.LastPos, 55) then
                begin
                SelfPlayer^.SendClientMessage('Você está muito longe para receber Drop e XP.', 0);
                end;


            Randomize;
            if(RandomRange(0, 2) = 1) then
            begin
              DroppedItem := True;
              Self.DropItemFor(@Servers[mob^.ChannelId].Players[i].Base, mob);
            end;
          end;

          for I := 1 to 3 do
          begin
            if(Servers[mob^.ChannelId].Players[Self.ClientID].Party.PartyAllied[i]=0) then
              Continue;
            for j in Servers[mob^.ChannelId].Parties[
              Servers[mob^.ChannelId].Players[Self.ClientID].Party.PartyAllied[i]].Members do
            begin

             if MobsP^.CurrentPos.InRange(
                Servers[mob^.ChannelId].Players[i].Base.PlayerCharacter.LastPos, 55) then
                begin
                SelfPlayer^.SendClientMessage('Você está muito longe para receber Drop e XP.', 0);
                end;

              Randomize;
              if(RandomRange(0, 2) = 1) then
              begin
                DroppedItem := True;
                Self.DropItemFor(@Servers[mob^.ChannelId].Players[j].Base, mob);
              end;
            end;
          end;
        end
        else
        begin
          for I in Servers[mob^.ChannelId].Players[Self.ClientID].Party.Members do
          begin
            Randomize;
            if(RandomRange(0, 2) = 1) then
            begin
              DroppedItem := True;
              Self.DropItemFor(@Servers[mob^.ChannelId].Players[i].Base, mob);
            end;
          end;
        end;
      end
      else
      begin
        case SelfPlayer^.Party.ItemAlocate of
          1: // em ordem
              begin
              NIndex := SelfPlayer^.Party.LastSlotItemReceived;
              if (SelfPlayer^.Party.Members.ToArray[NIndex] = Self.ClientID) then
              begin
                Inc(SelfPlayer^.Party.LastSlotItemReceived);

                DroppedItem := True;
                Self.DropItemFor(@Self, mob);
                if (NIndex >= (SelfPlayer^.Party.Members.Count - 1)) then
                  // reiniciar a ordem
                  SelfPlayer^.Party.LastSlotItemReceived := 0;
              end;

            end;

          2: // aleatorio
            begin
              if (Self.ClientID = SelfPlayer^.Party.Leader) then
              begin

                 if MobsP^.CurrentPos.InRange(
                Servers[mob^.ChannelId].Players[i].Base.PlayerCharacter.LastPos, 55) then
                begin
                SelfPlayer^.SendClientMessage('Você está muito longe para receber Drop e XP.', 0);
                end;

                Randomize;
                RandomClientID := SelfPlayer^.Party.Members.ToArray
                  [RandomRange(0, SelfPlayer^.Party.Members.Count)];
                DroppedItem := True;
                // criar func pra entregar o item pelo client id
                Self.DropItemFor(@Servers[Self.ChannelId].Players[RandomClientID]
                  .Base, mob);
              end;
            end;
          3: // individual
            begin
              if (SelfPlayer^.InDungeon) then
              begin
               if (Self.ClientID = DungeonInstances[Servers[Self.ChannelId].Players
                  [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid]
                  .FirstPlayerAttacker) and MobsP^.CurrentPos.InRange(Self.PlayerCharacter.LastPos, 55) then
                begin
                  // criar func pra entregar o item pelo client id
                  Self.DropItemFor(@Self, mob);
                  DroppedItem := True;
                end;
              end
              else
              begin
                //if(MobsP^.FirstPlayerAttacker <> 0) then
               // begin
               //   if (Self.ClientID = MobsP^.FirstPlayerAttacker) then
              //    begin
                //    // criar func pra entregar o item pelo client id
               //     Self.DropItemFor(@Self, mob);
               //     DroppedItem := True;
               //   end;
              //  end
               // else
              //  begin
                if(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP[
                  mob.SecondIndex].FirstPlayerAttacker > 0) and
                  MobsP^.CurrentPos.InRange(Self.PlayerCharacter.LastPos, 55) then
                begin
                  if(Servers[Self.ChannelId].Players[Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP[
                  mob.SecondIndex].FirstPlayerAttacker].Status >= Playing) then
                  begin
                    if not(Servers[Self.ChannelId].Players[Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP[
                      mob.SecondIndex].FirstPlayerAttacker].SocketClosed) then
                    begin
                      Self.DropItemFor(@Self, mob);
                      DroppedItem := True;
                    end;
                  end;
                end;
              //  end;
              end;
            end;
          4: // lider
            begin

             if (Self.ClientID = SelfPlayer^.Party.Leader) and
              MobsP^.CurrentPos.InRange(Self.PlayerCharacter.LastPos, 55) then
              begin






                // criar func pra entregar o item pelo client id
                Self.DropItemFor(@Self, mob);
                DroppedItem := True;
              end;







            end;
        end;
      end;
    end
    else // n�o est� em grupo
    begin

      ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);

      if MobsP^.CurrentPos.InRange(Self.PlayerCharacter.LastPos, 55) then
      begin
        SelfPlayer.SendClientMessage('Seu invent�rio est� cheio. Recompensas n�o ser�o recebidas.');
       // Exit;
      end;

      Self.DropItemFor(@Self, mob);
      // criar func pra entregar o item pelo client id
    end;
  except
   // Logger.Write('erro na entrega em grupo de xp / solo', TLogTYpe.Error);
  end;
  try
    if not(ExpAcquired = 0) then
    begin
      try
        case SelfPlayer^.SpawnedPran of
          0:
            begin
              case SelfPlayer^.Account.Header.Pran1.Level of
                0 .. 3: // pran fada
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp) >
                      PranExpList[5]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[4];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 3 do
                      begin
                        SelfPlayer^.AddPranLevel(0);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                4: // pran fada ~ pran crian�a
                  begin
                    case SelfPlayer^.Account.Header.Pran1.ClassPran of
                      61, 71, 81:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp) >
                          PranExpList[20]) then
                        begin
                          SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[19];
                          for i := SelfPlayer^.Account.Header.Pran1.Level to 18 do
                          begin
                            SelfPlayer^.AddPranLevel(0);
                          end;
                        end
                        else
                          SelfPlayer^.AddPranExp(0, PranExpAcquired);
                      end;
                    end;
                  end;
                5 .. 18: // pran crian�a
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp) >
                      PranExpList[20]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[19];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 18 do
                      begin
                        SelfPlayer^.AddPranLevel(0);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                19: // pran crian�a ~ pran adolescente
                  begin
                    case SelfPlayer^.Account.Header.Pran1.ClassPran of
                      62, 72, 82:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                          PranExpAcquired := 0;
                        end;
                    else
                    begin
                        PranExpAcquired := (ExpAcquired div 3);
                        if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp) >
                          PranExpList[50]) then
                        begin
                          SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[49];
                          for i := SelfPlayer^.Account.Header.Pran1.Level to 48 do
                          begin
                            SelfPlayer^.AddPranLevel(0);
                          end;
                        end
                        else
                          SelfPlayer^.AddPranExp(0, PranExpAcquired);
                      end;
                    end;
                  end;
                20 .. 48: // pran adolescente
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp) >
                      PranExpList[50]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[49];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 48 do
                      begin
                        SelfPlayer^.AddPranLevel(0);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                49:
                  begin // pran adolescente ~ pran adulta
                    case SelfPlayer^.Account.Header.Pran1.ClassPran of
                      63, 73, 83:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(0, PranExpAcquired);
                        //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                          //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                50 .. 69: // pran adulta
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
              end;
            end;
          1:
            begin
              case SelfPlayer^.Account.Header.Pran2.Level of
                0 .. 3: // pran fada
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp) >
                      PranExpList[5]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[4];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 3 do
                      begin
                        SelfPlayer^.AddPranLevel(1);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                4: // pran fada ~ pran crian�a
                  begin
                    case SelfPlayer^.Account.Header.Pran2.ClassPran of
                      61, 71, 81:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp) >
                          PranExpList[20]) then
                        begin
                          SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[19];
                          for i := SelfPlayer^.Account.Header.Pran2.Level to 18 do
                          begin
                            SelfPlayer^.AddPranLevel(1);
                          end;
                        end
                        else
                          SelfPlayer^.AddPranExp(1, PranExpAcquired);
                      end;
                    end;
                  end;
                5 .. 18: // pran crian�a
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp) >
                      PranExpList[20]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[19];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 18 do
                      begin
                        SelfPlayer^.AddPranLevel(1);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                19: // pran crian�a ~ pran adolescente
                  begin
                    case SelfPlayer^.Account.Header.Pran2.ClassPran of
                      62, 72, 82:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp) >
                          PranExpList[50]) then
                        begin
                          SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[49];
                          for i := SelfPlayer^.Account.Header.Pran2.Level to 48 do
                          begin
                            SelfPlayer^.AddPranLevel(1);
                          end;
                        end
                        else
                          SelfPlayer^.AddPranExp(1, PranExpAcquired);
                      end;
                    end;
                  end;
                20 .. 48: // pran adolescente
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp) >
                      PranExpList[50]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[49];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 48 do
                      begin
                        SelfPlayer^.AddPranLevel(1);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                49:
                  begin // pran adolescente ~ pran adulta
                    case SelfPlayer^.Account.Header.Pran2.ClassPran of
                      63, 73, 83:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(1, PranExpAcquired);
                        //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                          //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                50 .. 69: // pran adulta
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
              end;
            end;
        end;
      except
        Logger.Write('erro no bghls das prans quando mata', TLogTYpe.Error);
      end;

      if(Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_EXP] > 0) then
      begin
        CalcAux := (Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_EXP] * (CalcAuxRlq div 100));
        if(SelfPlayer^.SpawnedPran <> 255) then
          SelfPlayer^.SendClientMessage('Adquiriu ' + AnsiString(IntToStr(ExpAcquired-CalcAux)
            ) + ' exp + ' + AnsiString(IntToStr(CalcAux)) + ', Pran ' + AnsiString(IntToStr(PranExpAcquired)) + '.', 0)
        else
          SelfPlayer^.SendClientMessage('Adquiriu ' + AnsiString(IntToStr(ExpAcquired-CalcAux)
            ) + ' exp + ' + AnsiString(IntToStr(CalcAux)) + '.', 0);
      end
      else
      begin
        if(SelfPlayer^.SpawnedPran <> 255) then
          SelfPlayer^.SendClientMessage('Adquiriu ' + AnsiString(IntToStr(ExpAcquired)
            ) + ' exp, Pran ' + AnsiString(IntToStr(PranExpAcquired)) + '.', 0)
        else
          SelfPlayer^.SendClientMessage('Adquiriu ' + AnsiString(IntToStr(ExpAcquired)
            ) + ' exp.', 0);
      end;
    end;
  except
    Logger.Write('erro na msg de xp', TLogTYpe.Error);
  end;

  try
    for i := 0 to 49 do
    begin
      if (SelfPlayer^.PlayerQuests[i].id > 0) then
      begin // se existir quest no jogador
        if not(SelfPlayer^.PlayerQuests[i].IsDone) then
        begin // se a quest ainda n�o foi entregue
          for j := 0 to 4 do
          begin // checa cada requiriment de mob
            if (SelfPlayer^.PlayerQuests[i].Quest.RequirimentsType[j] = 1) then
            // se o requiriment checado for de mob kill
            begin
              if (SelfPlayer^.PlayerQuests[i].Quest.Requiriments[j] = Servers
                [mob^.ChannelId].Mobs.TMobS[mob^.Mobid].IntName) then
              // se o mob morto for o mesmo da quest
              begin
                Inc(SelfPlayer^.PlayerQuests[i].Complete[j]);
                if (SelfPlayer^.PlayerQuests[i].Complete[j] >=
                  SelfPlayer^.PlayerQuests[i].Quest.RequirimentsAmount[j]) then
                begin
                  SelfPlayer^.PlayerQuests[i].Complete[j] :=
                    SelfPlayer^.PlayerQuests[i].Quest.RequirimentsAmount[j];
                  SelfPlayer^.SendClientMessage('Voc� completou a quest [' +
                    AnsiString(Quests[SelfPlayer^.PlayerQuests[i].Quest.QuestID]
                    .Titulo) + ']');
                  // aqui vai o aviso de quest completa
                end;
                SelfPlayer^.UpdateQuest(SelfPlayer^.PlayerQuests[i].id);
              end;
            end;
          end;
        end;
      end;
    end;
  except
    Logger.Write('erro na contagem da quest pra atualizar', TLogTYpe.Error);
  end;

     // buffs por matar mobs evento royalle

    begin
  // Verifica se o nível do mob está dentro da faixa desejada (0 a 1)
  if (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel >= 361) and
     (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel <= 400) then
  begin
    // Define uma lista de buffs/debuffs possíveis
    var BuffList: array[0..83] of Integer;
    BuffList[0] := 48;    // ID do Buff 1
      BuffList[1] := 304;   // ID do Buff 2
      BuffList[2] := 320;   // ID do Buff 3
      BuffList[3] := 352;   // ID do Buff 4
      BuffList[4] := 368;   // ID do Buff 5
      BuffList[5] := 400;   // ID do Buff 6
      BuffList[6] := 448;   // ID do Buff 7
      BuffList[7] := 480;   // ID do Buff 8
      BuffList[8] := 1152;  // ID do Buff 9
      BuffList[9] := 1184;  // ID do Buff 10
      BuffList[10] := 1248; // ID do Buff 11
      BuffList[11] := 1280; // ID do Buff 12
      BuffList[12] := 1312; // ID do Buff 13
      BuffList[13] := 1328; // ID do Buff 14
      BuffList[14] := 1344; // ID do Buff 15
      BuffList[15] := 1360; // ID do Buff 16
      BuffList[16] := 1440; // ID do Buff 17
      BuffList[17] := 1488; // ID do Buff 18
      BuffList[18] := 1520; // ID do Buff 19
      BuffList[19] := 1536; // ID do Buff 20
      BuffList[20] := 2048; // ID do Buff 21
      BuffList[21] := 2080; // ID do Buff 22
      BuffList[22] := 2128; // ID do Buff 23
      BuffList[23] := 2144; // ID do Buff 24
      BuffList[24] := 2192; // ID do Buff 25
      BuffList[25] := 2256; // ID do Buff 26
      BuffList[26] := 2272; // ID do Buff 27
      BuffList[27] := 1368; // ID do Buff 28
      BuffList[28] := 2400; // ID do Buff 29
      BuffList[29] := 2464; // ID do Buff 30
      BuffList[30] := 2496; // ID do Buff 31
      BuffList[31] := 2992; // ID do Buff 32
      BuffList[32] := 3024; // ID do Buff 33
      BuffList[33] := 3044; // ID do Buff 34
      BuffList[34] := 3088; // ID do Buff 35
      BuffList[35] := 3152; // ID do Buff 36
      BuffList[36] := 3200; // ID do Buff 37
      BuffList[37] := 3264; // ID do Buff 38
      BuffList[38] := 3312; // ID do Buff 39
      BuffList[39] := 3440; // ID do Buff 40
      BuffList[40] := 3983; // ID do Buff 41
      BuffList[41] := 4163; // ID do Buff 42
      BuffList[42] := 4192; // ID do Buff 43
      BuffList[43] := 4335; // ID do Buff 44
      BuffList[44] := 4929; // ID do Buff 45
      BuffList[45] := 5009; // ID do Buff 46
      BuffList[46] := 5072; // ID do Buff 47
      BuffList[47] := 5120; // ID do Buff 48
      BuffList[48] := 5232; // ID do Buff 49
      BuffList[49] := 5296; // ID do Buff 50
      BuffList[50] := 5344; // ID do Buff 51
      BuffList[51] := 6059; // ID do Buff 52
      BuffList[52] := 6040; // ID do Buff 53
      BuffList[53] := 6126; // ID do Buff 54
      BuffList[54] := 6134; // ID do Buff 55
      BuffList[55] := 6172; // ID do Buff 56
      BuffList[56] := 6219; // ID do Buff 57
      BuffList[57] := 6384; // ID do Buff 58
      BuffList[58] := 6605; // ID do Buff 59
      BuffList[59] := 6606; // ID do Buff 60
      BuffList[60] := 6616; // ID do Buff 61
      BuffList[61] := 6624; // ID do Buff 62
      BuffList[62] := 6629; // ID do Buff 63
      BuffList[63] := 6633; // ID do Buff 64
      BuffList[64] := 6634; // ID do Buff 65
      BuffList[65] := 6638; // ID do Buff 66
      BuffList[66] := 6645; // ID do Buff 67
      BuffList[67] := 8696; // ID do Buff 68
      BuffList[68] := 9111; // ID do Buff 69
      BuffList[69] := 9151; // ID do Buff 70
      BuffList[70] := 9011; // ID do Buff 71
      BuffList[71] := 9010; // ID do Buff 72
      BuffList[72] := 9012; // ID do Buff 73
      BuffList[73] := 9007; // ID do Buff 74
      BuffList[74] := 8699; // ID do Buff 75
      BuffList[75] := 8694; // ID do Buff 76
      BuffList[76] := 8403; // ID do Buff 77
      BuffList[77] := 7248; // ID do Buff 78
      BuffList[78] := 7249; // ID do Buff 79
      BuffList[79] := 6976; // ID do Buff 80
      BuffList[80] := 6643; // ID do Buff 81
      BuffList[81] := 9093; // ID do Buff 82
      BuffList[82] := 9095; // ID do Buff 83
      BuffList[83] := 9206; // ID do Buff 84


    // Define a probabilidade de aplicar o buff (exemplo: 70% de chance)
    var ChanceToApplyBuff := 70; // Valor em porcentagem (70 = 70%)

    // Gera um número aleatório entre 1 e 100 para verificar a probabilidade
    Randomize; // Inicializa o gerador de números aleatórios
    var RandomChance := Random(100) + 1; // Gera um número entre 1 e 100

    // Verifica se o número gerado está dentro da probabilidade definida
    if RandomChance <= ChanceToApplyBuff then
    begin
      // Escolhe um buff aleatório da lista
      var RandomIndex := Random(Length(BuffList)); // Gera um índice aleatório
      var ChosenBuff := BuffList[RandomIndex]; // Seleciona o buff com base no índice

      // Aplica o buff/debuff escolhido ao jogador
      Self.AddBuff(ChosenBuff);

      // Envia uma mensagem ao jogador informando sobre o buff/debuff recebido
      SelfPlayer.SendClientMessage('Você recebeu um Buff/Debuff aleatório: ');
    end
    else
    begin
      // Caso a probabilidade falhe, envia uma mensagem ao jogador
      SelfPlayer.SendClientMessage('Você não recebeu nenhum Buff/Debuff desta vez.');
    end;
  end;
end;












end;
procedure TBaseMob.DropItemFor(PlayerBase: PBaseMob; mob: PBaseMob);
var
  DropTax: Integer;
  ReceiveFrom: Integer;
  ItemTypeFrom: Integer;
  ItemTax: Integer;
  MaxLen: Integer;
  RandomItem, Helper: Integer;
  ItemID, cnt, i, j, k: Integer;
  OtherPlayer: PPlayer;
  MobT: PMobSa;
 // ItemsToDrop: array of Integer;
 ItemsGroup1, ItemsGroup2, ItemsGroup3: array of Integer;  // Grupos de itens
  MobGroup1, MobGroup2, MobGroup3: array of Integer;        // Grupos de mobs
  RandomIndex: Integer;
  Player: TPlayer;
  Party: PParty;
  GlobalDropRate : integer;
  Group1DropRate: integer;
  Group2DropRate : integer;
  SelectedPlayerID : word;
  NumBaus: Integer;
  DropItems: array[0..4] of Integer; // IDs
  DropQuantities: array[0..4] of Integer; // Quantidades
   ChosenItem, ChosenQuantity: Integer;
  LastBauGenerationTime: TDateTime;
  CurrentTime: TDateTime;
  LastSpawnDate: TDateTime; // Variável global ou de controle para rastrear o último spawn
   ItemsToDrop: array of Integer;
  DayValid: Boolean;




label
  ReCase,
  ReCase1;

const
  // Itens para quarta-feira (nível 200-250)
  ItemsToDropWednesday: array[0..8] of Integer = (6381, 6384, 6422, 6396, 6407, 14192, 14192, 14192, 14192);
  // Itens para sábado (nível 200-250)
  ItemsToDropSaturday: array[0..8] of Integer = (6372, 6392, 6386, 6401, 6441, 14192, 14192, 14192, 14192);

  // Itens para mobs nível 301-310
  ItemsToDrop_301_310: array[0..7] of Integer = (6403, 6404, 6405, 9467, 11529, 19039, 19041, 19042);

  NumberOfBaús: Integer = 9; // Número total de baús a serem gerados (1 item por baú)

begin
  // Obtém a data e hora atual
  CurrentTime := Now;

  // Inicializa a variável DayValid como false
  DayValid := False;

  // Verifica se é quarta-feira (20h às 23h59) ou sábado (16h às 23h59) para mobs de nível 200-250
  if ((DayOfWeek(CurrentTime) = 4) and (HourOf(CurrentTime) >= 20) and (HourOf(CurrentTime) < 24)) or
     ((DayOfWeek(CurrentTime) = 7) and (HourOf(CurrentTime) >= 16) and (HourOf(CurrentTime) < 24)) then
  begin
    if (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel >= 200) and
       (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel <= 250) then
    begin
      SetLength(ItemsToDrop, Length(ItemsToDropWednesday));
      Move(ItemsToDropWednesday[0], ItemsToDrop[0], SizeOf(ItemsToDropWednesday));
      DayValid := True;
    end;
  end;

  // Verifica se é segunda-feira (20h às 24h) ou quinta-feira (16h às 24h) para mobs de nível 301-310
  if ((DayOfWeek(CurrentTime) = 2) and (HourOf(CurrentTime) >= 20) and (HourOf(CurrentTime) < 24)) or
     ((DayOfWeek(CurrentTime) = 5) and (HourOf(CurrentTime) >= 16) and (HourOf(CurrentTime) < 24)) then
  begin
    if (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel >= 301) and
       (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel <= 310) then
    begin
      SetLength(ItemsToDrop, Length(ItemsToDrop_301_310));
      Move(ItemsToDrop_301_310[0], ItemsToDrop[0], SizeOf(ItemsToDrop_301_310));
      DayValid := True;
    end;
  end;

  // Se for um dia válido, o mob estiver na nação 4 e estiver dentro das faixas de nível corretas, gera os baús
  if DayValid and (Servers[mob.ChannelId].NationID = 4) then
  begin
    // Verifica se os baús já foram gerados hoje
    if Trunc(LastSpawnDate) <> Trunc(CurrentTime) then
    begin
      // Atualiza a data do último spawn
      LastSpawnDate := CurrentTime;

      // Gera os baús no chão
      Randomize;
      for i := 0 to NumberOfBaús - 1 do
      begin
        ChosenItem := ItemsToDrop[i];
        Servers[PlayerBase.ChannelId].CreateMapObject(@Self, 320, ChosenItem);
      end;
    end;
  end;





// Continua com o drop normal do mob, independentemente do evento












  if(Servers[mob.ChannelId].Mobs.TMobS[mob.Mobid].MobsP[mob.SecondIndex].isGuard) then
    Exit;   //patch dropando item em guarda
  Randomize;
  ItemTypeFrom := DROP_NORMAL_ITEM; // pre select
  ItemID := 0;
  MaxLen := 0;
  ReceiveFrom := 0;
  DropTax := RandomRange(1, 101);
  OtherPlayer := @Servers[PlayerBase.ChannelId].Players[PlayerBase.ClientID];
  MobT := @Servers[mob.ChannelId].Mobs.TMobS[mob.Mobid];
    // Verifica se o mob é do tipo 1
  {if (mob.Mobid = 1) then
  begin
    ItemID := 5251;
    if (TItemFunctions.GetItemEquipSlot(ItemID) = 0) then
      TItemFunctions.PutItem(OtherPlayer^, ItemID, 1)
    else
      TItemFunctions.PutEquipament(OtherPlayer^, ItemID);
    Exit;
  end;}





  if (OtherPlayer^.InDungeon) then
  begin
    if (DropTax > 1) then
    begin
      cnt := 0;
      for i := 0 to 41 do
      begin
        if (DungeonInstances[Servers[PlayerBase.ChannelId].Players
          [PlayerBase.ClientID].DungeonInstanceID].MobsDrop[mob.Mobid].Drops
          [i] > 0) then
        begin
          Inc(cnt);
        end
        else
          break;
      end;
      if (cnt = 0) then
        cnt := 1
      else
      begin
        Randomize;
        ItemTax := RandomRange(1, cnt); // if gives nah item then puts it -1
      end;
      RandomItem := DungeonInstances[Servers[PlayerBase.ChannelId].Players
        [PlayerBase.ClientID].DungeonInstanceID].MobsDrop[mob.Mobid]
        .Drops[ItemTax];
      if (TItemFunctions.GetItemEquipSlot(RandomItem) = 0) then
        TItemFunctions.PutItem(Servers[PlayerBase.ChannelId].Players
          [PlayerBase.ClientID], RandomItem, 1)
      else
        TItemFunctions.PutEquipament(Servers[PlayerBase.ChannelId].Players
          [PlayerBase.ClientID], RandomItem);
    end;
    Exit;
  end;

  if(Self.Character <> nil) then
  begin
    if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    begin
      Inc(DropTax, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_DROP_RATE] *
        (DropTax div 100));
    end;

    if(Self.GetMobAbility(EF_PARTY_PER_DROP_RATE) > 0) then
      Inc(DropTax, (Self.GetMobAbility(EF_PARTY_PER_DROP_RATE) div 2));

    Inc(Self.DroppedCount);

    if(DroppedCount >= 4) then
    begin
      Inc(DropTax, 50);
      DroppedCount := 0;
    end;
  end;

  {if (DropTax > 50) then
  begin // a taxa de drop padrao � 50, Rlk_eff + olho de gato_eff + DropTax
    case MobT^.MobLevel of
      0 .. 20:
        begin
          ReceiveFrom := MONSTERS_0_20;
           end;
      21 .. 40:
        begin
          ReceiveFrom := MONSTERS_21_40;
        end;
      41 .. 60:
        begin
          ReceiveFrom := MONSTERS_41_60;
          case MobT^.IntName of
            1373: // plantas
              begin
                ReceiveFrom := MONSTERS_PLANTA;
              end;
            1374: // croshu azul
              begin
                ReceiveFrom := MONSTERS_CROSHU_AZUL;
              end;
            1375: // butos
              begin
                ReceiveFrom := MONSTERS_BUTO;
              end;
            1376: // croshu verm
              begin
                ReceiveFrom := MONSTERS_CROSHU_VERM;
              end;
          end;
        end;
      61 .. 80:
        begin
          ReceiveFrom := MONSTERS_61_80;
          case MobT^.IntName of
            1377: // penzas
              begin
                ReceiveFrom := leopold1;
              end;
            1378: // verits
              begin
                ReceiveFrom := leopold1;
              end;
          end;
        end;
      81 .. 255:
        begin
          ReceiveFrom := MONSTERS_81_99;
        end;

        256 .. 999:
        begin
          ReceiveFrom := bossdg13;

        end;


      1000..65535:
        begin
          case MobT^.IntName of
            1373: // plantas
              begin
                MobT^.DropIndex := MONSTERS_PLANTA;
              end;
            1374: // croshu azul
              begin
                MobT^.DropIndex := MONSTERS_CROSHU_AZUL;
              end;
            1375: // butos
              begin
                MobT^.DropIndex := MONSTERS_BUTO;
              end;
            1376: // croshu verm
              begin
                MobT^.DropIndex := MONSTERS_CROSHU_VERM;
              end;
            1377: // penzas
              begin
                MobT^.DropIndex := MONSTERS_PENZA;
              end;
            1378: // verits
              begin
                MobT^.DropIndex := MONSTERS_VERIT;
              end;
              1: // verits
              begin
                MobT^.DropIndex := bossdg13;
              end;


          end;
        end;
    end;   }

    Randomize;
    if (Self.Character.Nation = 4) then
        begin
      ItemTax := 2; // Garante 100% de chance de drop (sempre seleciona item lendário)
    end
    else
    begin
    ItemTax := RandomRange(1, 101);

    if(Self.Character <> nil) then
      if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        decint(ItemTax, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_DROP_RATE]);
      end;
    end;
    if(ItemTax = 0) then ItemTax := 2;
    case ItemTax of
      1:
        begin
          ItemTypeFrom := DROP_LEGENDARY_ITEM;
          //MaxLen := High(Drops[MobT^.DropIndex].LegendaryItems);
        end;
      2 .. 13:
        begin
          ItemTypeFrom := DROP_RARE_ITEM;
          //MaxLen := High(Drops[MobT^.DropIndex].RareItems);
        end;
      14 .. 33:
        begin
          ItemTypeFrom := DROP_SUPERIOR_ITEM;
          //MaxLen := High(Drops[MobT^.DropIndex].SuperiorItems);
        end;
      34 .. 255:
        begin
          ItemTypeFrom := DROP_NORMAL_ITEM;
          //MaxLen := High(Drops[MobT^.DropIndex].NormalItems);
        end;
    end;



    if (MaxLen = 0) then
    begin
      ItemTypeFrom := DROP_NORMAL_ITEM;
      MaxLen := High(Drops[MobT^.DropIndex].NormalItems);
    end;

    if(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].InitHP > 999999) then
    begin
      ReCase:
        case ItemTypeFrom of
          DROP_NORMAL_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].NormalItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].NormalItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].NormalItems[RandomItem];
          end;
          DROP_SUPERIOR_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].SuperiorItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].SuperiorItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].SuperiorItems[RandomItem];
          end;
          DROP_RARE_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].RareItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].RareItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].RareItems[RandomItem];
          end;
          DROP_LEGENDARY_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].LegendaryItems) = 0) then
            begin
              ItemTypeFrom := 1;
              goto ReCase;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].LegendaryItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].LegendaryItems[RandomItem];
          end;
        end;
    end
    else
    begin
      ReCase1:
        case ItemTypeFrom of
          DROP_NORMAL_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].NormalItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase1;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].NormalItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].NormalItems[RandomItem];
          end;
          DROP_SUPERIOR_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].SuperiorItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase1;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].SuperiorItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].SuperiorItems[RandomItem];
          end;
          DROP_RARE_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].RareItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase1;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].RareItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].RareItems[RandomItem];
          end;
          DROP_LEGENDARY_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].LegendaryItems) = 0) then
            begin
              ItemTypeFrom := 1;
              Exit;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].LegendaryItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].LegendaryItems[RandomItem];
          end;
        end;
    end;

    if(ItemList[ItemID].ItemType = 713) then
    begin
      for k := Low(Servers) to High(Servers) do
      begin
        for i := 0 to 4 do
        begin
          for j := 0 to 4 do
          begin
            if (Servers[k].Devires[i].Slots[j].ItemID <> 0) then
            begin
              if(ItemList[Servers[k].Devires[i].Slots[j].ItemID].UseEffect =
                ItemList[ItemID].UseEffect) then
                Exit;
            end;
          end;
        end;

        for I := Low(Servers[k].OBJ) to High(Servers[k].OBJ) do
        begin
          if(Servers[k].OBJ[i].ContentItemID = 0) then
            Continue;

          if(ItemList[Servers[k].OBJ[i].ContentItemID].UseEffect =
            ItemList[ItemID].UseEffect) then
            Exit;
        end;

        for I := Low(Servers[k].Players) to High(Servers[k].Players) do
        begin
          if not(Servers[k].Players[i].Status >= Playing) then
            Continue;

          for j := 0 to 59 do
          begin
            if(Servers[k].Players[i].Base.Character.Inventory[j].Index = 0) then
              Continue;

            if(Servers[k].Players[i].Base.Character.Inventory[j].Index = ItemID) then
            begin
              Exit;
            end;

            if(ItemList[Servers[k].Players[i].Base.Character.Inventory[j].Index].ItemType
              = 40) then
            begin
              if(ItemList[Servers[k].Players[i].Base.character.Inventory[j].Index].UseEffect =
                ItemList[ItemID].UseEffect) then
              Exit;
            end;
          end;


          Helper := TItemFunctions.GetItemSlotByItemType(Servers[k].Players[i],
            40, INV_TYPE, 0);
          if(Helper <> 255) then
          begin
            if(ItemList[Servers[k].Players[i].Base.character.Inventory[Helper].Index].UseEffect =
            ItemList[ItemID].UseEffect) then
              Exit;
          end;
        end;
      end;

      Servers[Self.ChannelId].SendServerMsg('Jogador <' +
        Self.Character.Name + '> encontrou o [' +
        ItemList[ItemID].Name+'].', 32, 0, 16);
    end;



begin
  // Verifica se é um dia específico (exemplo: segunda-feira , quarta, sabado e domingo)
  var IsSpecialDay: Boolean := (DayOfWeek(Date) = 2) or (DayOfWeek(Date) = 4) or
  (DayOfWeek(Date) = 6) or (DayOfWeek(Date) = 7) or (DayOfWeek(Date) = 1); // Segunda e Quarta
  var HasItem14197: Boolean := False;

  // Verifica se o jogador possui o item 14197 no inventário
  for i := 0 to High(Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory) do
  begin
   if (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 14197) or
     (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 14198) or
     (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[i].Index = 14199) then
    begin
      HasItem14197 := True;
      Break;
    end;
  end;

  /// Determina a quantidade de itens a entregar com base nas condições
var ItemCount: Integer := 1; // Padrão: entrega 1 item

if IsSpecialDay and (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Nation = 4) then
begin
  // Dias específicos e nação 4
  if HasItem14197 then
    ItemCount := 4 + 2 // 4 itens pelos dias específicos + 2 itens pelo bônus do item
  else
    ItemCount := 4; // Apenas o bônus dos dias específicos
end
else if IsSpecialDay then
begin
  // Dias específicos fora da nação 4
  if HasItem14197 then
    ItemCount := 2 + 2 // 2 itens pelos dias específicos + 2 itens pelo bônus do item
  else
    ItemCount := 2; // Apenas o bônus dos dias específicos
end
else
begin
  // Fora dos dias específicos
  if HasItem14197 then
    ItemCount := 2; // Apenas o bônus do item no inventário
  // Caso contrário, permanece com 1 item padrão
end;

// Entrega os itens
for  j := 1 to ItemCount do
begin
  if TItemFunctions.GetItemEquipSlot(ItemID) = 0 then
    TItemFunctions.PutItem(OtherPlayer^, ItemID, 1) // Entrega o item normal
  else
    TItemFunctions.PutEquipament(OtherPlayer^, ItemID); // Entrega o equipamento
end;

end;
end;






//end;
procedure TBaseMob.PlayerKilled(mob: PBaseMob; xRlkSlot: Byte = 0);
var
  i, j, k: Integer;
  Party: PParty;
  Honor: Integer;
  GuildPlayer: PPlayer;
  RandomTax: Integer;
  RlkSlot: Byte;
  Item: PItem;
  TitleGoaled: Boolean;
  Player: TPlayer;
  NumBaus: Integer;
begin

  if(xRlkSlot = 0) then
    RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[mob^.ClientID],
      40, INV_TYPE, 0)
  else
    RlkSlot := xRlkSlot;

  if(RlkSlot <> 255) then
  begin
    Item := @mob^.Character.Inventory[RlkSlot];
    Servers[Self.ChannelId].CreateMapObject(@Servers[Self.ChannelId].Players[Self.ClientID],
      320, Item.Index);
    {Servers[Self.ChannelId].SendServerMsg('O jogador ' +
      AnsiString(mob^.Character.Name) + ' dropou a rel�quia <' +
      AnsiString(ItemList[Item.Index].Name) + '>.');}
    ZeroMemory(Item, sizeof(TItem));
    mob.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
    RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[mob^.ClientID],
      40, INV_TYPE, 0);
    if(RlkSlot <> 255) then
    begin
      Self.PlayerKilled(mob, RlkSlot); //loopzin pra dropar todas as rel�quias que tiver
      Exit;
    end;
    Servers[Self.ChannelId].Players[mob^.ClientID].SendEffect(0);
  end;

  if (mob^.BuffExistsByIndex(126)) then
  begin // efeito duradouro
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Alvo est� sob Efeito Duradouro. Imposs�vel receber PvP/Honra.');
    Exit;
  end
  else
  begin
    if not(mob.InClastleVerus) then
      mob^.AddBuff(6471);
  end;

  if(Self.BuffExistsByIndex(126)) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Voc� est� sob Efeito Duradouro. Imposs�vel receber PvP/Honra.');
    Exit;
  end;

  if(mob.Character.Level < 25) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Voc� s� pode receber PvP de alvos acima do Nv 25.');
    Exit;
  end;

  if(Self.Character.Level < 25) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Voc� s� pode receber PvP de alvos acima do Nv 25.');
    Exit;
  end;

    Player:= Servers[Self.ChannelId].Players[Self.ClientID];

  if (Player.PartyIndex <> 0) then
  begin
    if not(Player.Party.InRaid) then
    begin

      Party := Player.Party;
      for i in Party.Members do
      begin
        if not(i = Self.ClientID) then
        begin
          if not(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.InRange(
            Self.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
            Continue;
        end;

        var
          DayOfWeek: Integer;
            begin

            Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
              KillPoint, 1);
            Servers[Self.ChannelId].Players[i].SendClientMessage
              ('Seus pontos de PvP foram incrementados.');
            Honor := HONOR_PER_KILL;
            Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
              Honor, Honor);
            Servers[Self.ChannelId].Players[i].SendClientMessage
              ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
            Servers[Self.ChannelId].Players[i].Base.SendRefreshKills();
            //RandomTax := Random(100);
            //if (RandomTax <= PVP_ITEM_DROP_TAX) then
            //begin
              /// pra dropar caveira e tals

          begin
          // Obtém o dia da semana (0 = Domingo, 1 = Segunda, ..., 6 = Sábado)
          DayOfWeek := DayOfTheWeek(Now);
                begin
                    // Verifica se o dia da semana não é domingo (1)
                   if (DayOfWeek = 5) or (DayOfWeek = 6)  or (DayOfWeek = 0) then   // Duplo caveira de sexta e sabado
                      TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 11285, SKULL_MULTIPLIER * 2) // Dobra o valor
                    else
                      TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 11285, SKULL_MULTIPLIER); // Valor normal


                end;

          end;
           // TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 11285,
           //   SKULL_MULTIPLIER);



           begin
          // Obtém o dia da semana (0 = Domingo, 1 = Segunda, ..., 6 = Sábado)
          DayOfWeek := DayOfTheWeek(Now);
                begin
                    // Verifica se o dia da semana não é domingo (1)
                   if (DayOfWeek = 5) or (DayOfWeek = 6)  then   // Duplo caveira de sexta e sabado
                      TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 8480, SKULL_PENA * 10) // Dobra o valor
                    else
                      TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 8480, SKULL_PENA); // Valor normal

                end;

          end;



            //TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 8480, SKULL_PENA);

            // Cria os baús no mapa para o jogador que matou (atacante)
                 begin
            if (mob^.Character.Nation = 4) then
            begin

              // Criar 20 baús com o item 5987 (1 unidade por baú)
              for var cont := 1 to 20 do
                Servers[Self.ChannelId].CreateMapObject(@Servers[Self.ChannelId].Players[mob^.ClientID], 320, 5987);

              // Criar 1 baú com o item 5640
              Servers[Self.ChannelId].CreateMapObject(@Servers[Self.ChannelId].Players[mob^.ClientID], 320, 5640);

              // Mensagem opcional para o servidor
              Servers[Self.ChannelId].SendServerMsg('O jogador ' +
                AnsiString(Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Name) +
                ' criou 20 Moedas Elter e 1 Gold.');
            end;
          end;



        end;


            //TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 15958, 1);
         // end;

          {TitleGoaled := False;

          for j := 0 to 95 do
          begin
            if(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Index = 0) then
              Continue;

            if(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Index = 27) then
            begin
              Inc(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Progress, 1);

              if(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Progress >=
              Titles[27].TitleLevel[Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Level].TitleGoal) then
              begin
                Servers[Self.ChannelId].Players[i].UpdateTitleLevel(27, Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level+1,
                  True);
                Servers[Self.ChannelId].Players[i].SendClientMessage('Seu t tulo ['+
                  Titles[27].TitleLevel[Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Level].TitleName +
                  '] foi atualizado.');
              end
              else
                Servers[Self.ChannelId].Players[i].UpdateTitleLevel(27, Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level,
                  False);

              TitleGoaled := True;
              break;
            end;
          end;

          if not(TitleGoaled) then
          begin
            Servers[Self.ChannelId].Players[i].AddTitle(27, 0, False);
          end;}

          {if (Servers[Self.ChannelId].Players[i].Character.Base.GuildIndex > 0) then
          begin
            if(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Level <= 6) then
            begin
              GuildLeveled := False;
              if (Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Exp >= GuildExpList
                [Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Level + 1]) then
              begin
                Inc(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Level);
                GuildLeveled := true;
              end;
              Inc(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Exp, Honor);
              //Servers[Self.ChannelId].Players[i].SendClientMessage('Pontos de experi ncia da legi o foram incrementados em '+
                //Honor.ToString + ' pontos.');
              for j := 0 to 127 do
              begin
                if (Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot]
                  .Members[j].Logged) then
                begin
                  for k := Low(Servers) to High(Servers) do
                  begin
                    if (Servers[k].GetPlayerByCharIndex
                      (Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot]
                      .Members[j].CharIndex, GuildPlayer)) then
                    begin
                      if (GuildPlayer.Status >= Playing) then
                      begin
                        Servers[k].Players[GuildPlayer.Base.ClientID].SendGuildInfo;
                        if (GuildLeveled) then
                        begin
                          Servers[k].Players[GuildPlayer.Base.ClientID].
                            SendClientMessage('A sua guild subiu de level!');
                        end;
                      end;
                      break;
                    end;
                  end;
                end;
              end;
            end;
          end;}
        end;
      end
    else
    begin
      Party := Player.Party;
      for i in Party.Members do
      begin
        if not(i = Self.ClientID) then
        begin
          if not(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.InRange(
            Self.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
            Continue;
        end;
        Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
          KillPoint, 1);
        Servers[Self.ChannelId].Players[i].SendClientMessage
          ('Seus pontos de PvP foram incrementados.');
        Honor := HONOR_PER_KILL;
        Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
          Honor, Honor);
        Servers[Self.ChannelId].Players[i].SendClientMessage
          ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
        Servers[Self.ChannelId].Players[i].Base.SendRefreshKills();
          TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 11285,
          SKULL_MULTIPLIER);


        end;

      for j := 1 to 3 do
      begin
        if (Player.Party.PartyAllied[j] = 0) then
          Continue;
        for I in Servers[Player.ChannelIndex].Parties
          [Player.Party.PartyAllied[j]].Members do
        begin
          if (Servers[Player.ChannelIndex].Players[I]
            .Base.PlayerCharacter.LastPos.InRange
            (Player.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
          begin

            Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
              KillPoint, 1);
            Servers[Self.ChannelId].Players[i].SendClientMessage
              ('Seus pontos de PvP foram incrementados.');
            Honor := HONOR_PER_KILL;
            Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
              Honor, Honor);
            Servers[Self.ChannelId].Players[i].SendClientMessage
              ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
            Servers[Self.ChannelId].Players[i].Base.SendRefreshKills();
              TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 11285,
              SKULL_MULTIPLIER);

          end;
        end;
      end;
    end;
      end
  else
  begin
    Inc(Servers[Self.ChannelId].Players[Self.ClientID]
      .Base.Character.CurrentScore.KillPoint, 1);
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Seus pontos de PvP foram incrementados.');
    Inc(Servers[Self.ChannelId].Players[Self.ClientID]
      .Base.Character.CurrentScore.Honor, HONOR_PER_KILL);
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Adquiriu ' + AnsiString(IntToStr(HONOR_PER_KILL)) + ' pontos de honra.');
    Servers[Self.ChannelId].Players[Self.ClientID].Base.SendRefreshKills();
    //RandomTax := Random(100);
    //if (RandomTax <= PVP_ITEM_DROP_TAX) then
    //begin
      /// pra dropar caveira e tals
    TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID],
      11285, SKULL_MULTIPLIER);
      //TItemFunctions.PutItem(Servers[Self.ChannelId].Players
        //[Self.ClientID], 5768, 1);
      //TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID],
        //15958, 1);
   // end;

    TitleGoaled := False;

    for j := 0 to 95 do
    begin
      if(Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Index = 0) then
        Continue;

      if(Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Index = 27) then
      begin
        Inc(Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Progress, 1);

        if(Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Progress >=
        Titles[27].TitleLevel[Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level].TitleGoal) then
        begin
            Servers[Self.ChannelId].Players[Self.ClientID].UpdateTitleLevel(27, Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level+1,
              True);
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Seu t�tulo ['+
              Titles[27].TitleLevel[Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level].TitleName +
              '] foi atualizado.');
        end
        else
          Servers[Self.ChannelId].Players[Self.ClientID].UpdateTitleLevel(27, Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level,
            False);

        TitleGoaled := True;
        break;
      end;
    end;

    if not(TitleGoaled) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].AddTitle(27, 0, False);
    end;
    {if (Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.Base.GuildIndex > 0) then
    begin
      Inc(Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
        .Character.GuildSlot].Exp, HONOR_PER_KILL);
      for j := 0 to 127 do
      begin
        if (Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
          .Character.GuildSlot].Members[j].Logged) then
        begin
          Inc(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Level);
          GuildLeveled := true;
        end;
        Inc(Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
          .Character.GuildSlot].Exp, HONOR_PER_KILL);
        //Servers[Self.ChannelId].Players[i].SendClientMessage('Pontos de experi�ncia da legi�o foram incrementados em '+
          //Honor.ToString + ' pontos.');
        for j := 0 to 127 do
        begin
          if (Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
            .Character.GuildSlot].Members[j].Logged) then
          begin
            if (Servers[k].GetPlayerByCharIndex
              (Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
              .Character.GuildSlot].Members[j].CharIndex, GuildPlayer)) then
            begin
              if (GuildPlayer.Status >= Playing) then
              begin
                Servers[k].Players[GuildPlayer.Base.ClientID].SendGuildInfo;
              end;
              break;
            end;
          end;
        end;
      end;
    end;}
  end;

end;
procedure TBaseMob.SelfBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
  Pos: TPosition);
var
  h1, h2: Integer;
  Item: PItem;
  RlkSlot: Byte;
  PartyId: WORD;
  i, RandomClientID, j, k: WORD;
  dano: integer;
begin
  if not((SkillData[Skill].Classe >= 61) and
    (SkillData[Skill].Classe <= 84)) then
  begin
    if ((Self.BuffExistsByIndex(53)) or (Self.BuffExistsByIndex(77))) then
    begin
      Self.RemoveBuffByIndex(53);
      Self.RemoveBuffByIndex(77);
    end;
  end;
  case SkillData[Skill].Index of
    124, 127, 137, 160:
      begin
        Self.AddBuff(Skill, True, True,
          (Self.GetMobAbility(EF_SKILL_ATIME6) * 60));
      end;
    32:
      begin
        Self.DefesaPoints := 3;
        Self.AddBuff(Skill);
      end;
    36:  // bolha templaria
      begin
        Self.BolhaPoints := SkillData[Skill].EFV[0];
        Self.AddBuff(Skill);
      end;

    365:  // Salvador Imprudente
    begin
      // Define os pontos da Bolha (aumentando em +5)
      Self.BolhaPoints := SkillData[Skill].EFV[0] ;

      // Aplica o buff original da skill 365 no próprio jogador
      Self.AddBuff(Skill);

    end;






     364:  // Forja de aço
    begin
       // Aplica o buff original da skill 364 no próprio jogador
      Self.AddBuff(Skill);
       end;




       54:  // najimun
    begin
      // Obtém o multiplicador da skill

      // Modifica os atributos da skill antes de aplicá-la
      SkillData[Skill].EFV[0]  := SkillData[Skill].EFV[0] ;

      // Aplica o buff original da skill
      Self.AddBuff(Skill);
    end;








      {365:  // Salvador Imprudente
      begin
        Self.BolhaPoints := SkillData[Skill].EFV[0]+5;
        Self.AddBuff(Skill);
        Self.AddBuff(7356);

      end;}

    42:
      begin
        Self.HPRListener := True;
        Self.HPRAction := 2;
        Self.HPRSkillID := Skill;
        Self.HPRSkillEtc1 := (SkillData[Skill].EFV[2]);
        Self.AddBuff(Skill);
      end;
    53: //inv atirador ocultar
      begin
        while (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0) <> 255) do
        begin
          RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);
          if(RlkSlot <> 255) then
          begin
            Item := @Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[RlkSlot];
            Servers[Self.ChannelId].CreateMapObject(@Self, 320, Item.Index);
            Servers[Self.ChannelId].SendServerMsg('O jogador ' +
              AnsiString(Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Name) + ' dropou a rel�quia <' +
              AnsiString(ItemList[Item.Index].Name) + '>.');
            ZeroMemory(Item, sizeof(TItem));
            Servers[Self.ChannelId].Players[Self.ClientID].Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
          end;
        end;
        Self.AddBuff(Skill);
      end;

      153: //inv atirador
      begin
        while (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].
        Players[Self.ClientID], 40, INV_TYPE, 0) <> 255) do

        begin
          RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);
          if (RlkSlot <> 255) then
          begin
            Item := @Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[RlkSlot];
            Servers[Self.ChannelId].CreateMapObject(@Self, 320, Item.Index);
            Servers[Self.ChannelId].SendServerMsg('O jogador ' +
              AnsiString(Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Name) + ' dropou a relíquia <' +
              AnsiString(ItemList[Item.Index].Name) + '>.');
            ZeroMemory(Item, sizeof(TItem));
            Servers[Self.ChannelId].Players[Self.ClientID].Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
          end;
        end;

        // Nova funcionalidade adicionada
        Servers[Self.ChannelId].Players[Self.ClientID].DisparosRapidosBarReset(Skill);
        Self._cooldown.Clear;

        // Aplicação do Buff
        Self.AddBuff(Skill);

      end;












    72: // teleport
      begin
        if(TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players[Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Imposs�vel usar com rel�quia.');
          Exit;
        end;

        if(Self.InClastleVerus) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Imposs�vel usar em guerra. Use o teleporte.');
          Exit;
        end;
        if(Self.Character.Nation > 0) then
        begin
          if(Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Imposs�vel usar em outros pa�ses.');
            Exit;
          end;
        end;

        Servers[Self.ChannelId].Players[Self.ClientID]
          .Teleport(TPosition.Create(3450, 690));
      end;
    77: //inv dual
      begin
        while (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0) <> 255) do
        begin
          RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);
          if(RlkSlot <> 255) then
          begin
            Item := @Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[RlkSlot];
            Servers[Self.ChannelId].CreateMapObject(@Self, 320, Item.Index);
            {Servers[Self.ChannelId].SendServerMsg('O jogador ' +
              AnsiString(Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Name) + ' dropou a reliquia <' +
              AnsiString(ItemList[Item.Index].Name) + '>.'); }
            ZeroMemory(Item, sizeof(TItem));
            Servers[Self.ChannelId].Players[Self.ClientID].Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
          end;
        end;
        Self.AddBuff(Skill);
      end;

       75: // ação imediata
       begin
        while (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0) <> 255) do
        begin
          RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);
          if(RlkSlot <> 255) then
          begin
            Item := @Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[RlkSlot];
            Servers[Self.ChannelId].CreateMapObject(@Self, 320, Item.Index);
            {Servers[Self.ChannelId].SendServerMsg('O jogador ' +
              AnsiString(Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Name) + ' dropou a reliquia <' +
              AnsiString(ItemList[Item.Index].Name) + '>.'); }
            ZeroMemory(Item, sizeof(TItem));
            Servers[Self.ChannelId].Players[Self.ClientID].Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
          end;
        end;
        Self.AddBuff(7360);
        Self.AddBuff(Skill);
      end;


      120:
      begin
        Self.HPRListener := True;
        Self.HPRAction := 1;
        Self.HPRSkillID := Skill;
        Self.AddBuff(Skill);
      end;

      14:  // despertar
      begin
        Self.HPRListener := True;
        Self.HPRAction := 1;
        Self.HPRSkillID := Skill;
        Self.AddBuff(Skill);
      end;



      167:
      begin
        Self.CalcAndCure(Skill, mob);
        mob.CalcAndCure(Skill, mob);
        Self.HPRListener := True;
        Self.HPRAction := 1;
        Self.HPRSkillID := Skill;
        Self.AddBuff(Skill);
      end;

   150:
    begin
    //var
    //dano: integer;
      begin
      Self.LaminaPoints := SkillData[Skill].EFV[0];
      // Multiplicando o dano final por 3
      Dano := Dano * 3;
      end;

      // Reduzindo a quantidade de hits pela metade (agora /4)
      Self.LaminaPoints := Self.LaminaPoints div 1;

      Self.LaminaID := Skill;
      Self.EventListener := True;
      Self.EventAction := 1;

      // Aplica o buff relacionado à habilidade
      Self.AddBuff(Skill);

       end;



    201: // fluxo de mana
      begin
        h1 := (Self.Character.CurrentScore.MaxMP div 2);
        Randomize;
        case Self.PlayerCharacter.Base.CurrentScore.Int of
          0 .. 20:
            begin
              h2 := Random(10);
            end;
          21 .. 40:
            begin
              h2 := Random(20);
            end;
          41 .. 60:
            begin
              h2 := Random(30);
            end;
          61 .. 80:
            begin
              h2 := Random(40);
            end;
          81 .. 65535:
            begin
              h2 := Random(50);
            end;
        end;
        Self.AddMP(h1 + ((Self.Character.CurrentScore.MaxMP div 100) *
          h2), True);
      end;
    208: // faz parte dos efeitos 5, essa aq pode ser recupercao de hp ou mp
      begin
        if (SkillData[Skill].Damage = 200) then
        begin // recupera mp
          Self.AddMP(((Self.Character.CurrentScore.MaxMP div 100) * 15), True);
        end;
        if (SkillData[Skill].Damage = 300) then
        begin // recupera hp
          Self.AddHP(((Self.Character.CurrentScore.MaxHP div 100) * 15), True);
        end
        else
        begin
          Self.AddBuff(Skill);
        end;
      end;
    337:
      begin
        Self.RemoveAllDebuffs;
        Self.AddBuff(Skill);
      end;
    131: // cura massa defensiva cl
      begin
        Self.CalcAndCure(Skill, mob);
        Self.AddBuff(7362);
      end;
    128: // liberta��o de mana cl
      begin
        mob.HPRListener := True;
        mob.HPRAction := 3;
        mob.HPRSkillID := Skill;
        mob.HPRSkillEtc1 := ((Self.Character.CurrentScore.DNMag shr 3) +
          SkillData[Skill].EFV[0]);
        mob.AddBuff(Skill);
      end;
    457: // agua benta cl
      begin
        if TItemFunctions.GetInvAvailableSlots(Servers[Self.ChannelId].Players
          [Self.ClientID]) = 0 then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Invent�rio cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID],
          SkillData[Skill].Damage);
      end;
    DEMOLICAO_X14:
      begin
        if(Self.PetClientID > 0) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Voc� n�o pode possuir dois PETs ao mesmo tempo.');
          Exit;
        end;

        Self.CreatePet(X14, Pos, Skill);
        Servers[Self.ChannelId].Players[Self.ClientID].SpawnPet(Self.PetClientID);
        Self.AddBuff(Skill);
      end;
    113: // teleporte em massa fc
      begin
        if(Self.InClastleVerus) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Imposs�vel usar em guerra. Use o teleporte.');
          Exit;
        end;
        if(TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players[Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Imposs�vel usar com rel�quia.');
          Exit;
        end;
        if(Self.Character.Nation > 0) then
        begin
          if(Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Imposs�vel usar em outros pa�ses.');
            Exit;
          end;
        end;
        Self.WalkTo(Pos, 70, MOVE_TELEPORT);
      end;
    89: // disparos rapidos dual
      begin
        Servers[Self.ChannelId].Players[Self.ClientID]
          .DisparosRapidosBarReset(Skill);
        Self._cooldown.Clear;
        Self.AddBuff(Skill);
      end;



    196, 220, 244: //forma fa�rica da pran
      begin
        if(Servers[Self.ChannelId].Players[Self.ClientID].FaericForm = False) then
        begin
          h1 := Servers[Self.ChannelId].Players[Self.ClientID].SpawnedPran;
          Servers[Self.ChannelId].Players[Self.ClientID].SendPranUnspawn(h1, 0);
          Servers[Self.ChannelId].Players[Self.ClientID].FaericForm := True;
          Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn(h1, 0, 0);
        end
        else
        begin
          h1 := Servers[Self.ChannelId].Players[Self.ClientID].SpawnedPran;
          Self.SendEffect(0);
          Servers[Self.ChannelId].Players[Self.ClientID].FaericForm := False;
          Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn(h1, 0, 0);
        end;
      end
  else
    begin
      Self.AddBuff(Skill);
    end;
  end;
end;
procedure TBaseMob.TargetBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
  DataSkill: P_SkillData; Posx, Posy: DWORD);
var
  Helper, Helper2: Integer;
  i: Integer;
  BoolHelper: Boolean;
begin
  {case Skill of
    6879:
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendAnimationDeadOf(mob.ClientID);
      end;
  end;}

  case DataSkill^.Index of
    124, 127, 137, 160:
      begin
        mob^.AddBuff(Skill, True, True,
          (Self.GetMobAbility(EF_SKILL_ATIME6) * 60));
      end;
    15:
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := RandomRange(30, 60); // 30 -> 60  //30,31,32
          end
          else
          begin // dano menor
            Helper2 := RandomRange(15, 30); // 15 -> 30
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNFis div 2),
            Self.Character.CurrentScore.DNFis+1);
          if(Helper2 > 1000) then
          begin
            Randomize;
            Helper2 := 1000 + RandomRange(1, 200);
          end;
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := (DataSkill^.EFV[0] + Helper2);
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;
    26: // remediar tp
      begin
        Self.CalcAndCure(Skill, mob);
      end;
    35: //uniao divina
      begin
        mob.UniaoDivina := String(Self.Character.Name);
        mob^.AddBuff(Skill);
      end;
    39: // el tycia tp
          begin
        // Obtém o MP atual disponível do personagem
        var MPAtualDisponivel := Self.Character.CurrentScore.CurMP;

        // Se não tiver MP, não faz nada
        if MPAtualDisponivel <= 0 then
        begin
          Self.SendClientMessage('Você precisa ter MP para ativar essa habilidade.');
          Exit;
        end;

        // Remove todo o MP atual
        Self.RemoveMP(MPAtualDisponivel, True);

        // Calcula o HP recuperado: 50% do MP consumido
        var HPRecuperado := Trunc(MPAtualDisponivel * 1.5); // 50%

        // Calcula o HP faltando para completar o MaxHP
        var HPAtual := mob^.Character.CurrentScore.CurHP;
        var HPMaximo := mob^.Character.CurrentScore.MaxHP;
        var HPFaltando := HPMaximo - HPAtual;

        // Se não há HP para recuperar, sai da função
        if HPFaltando <= 0 then
        begin
          Self.SendClientMessage('O alvo já está com HP cheio.');
          Exit;
        end;

        // Limita a cura ao HP faltando
        if HPRecuperado > HPFaltando then
          HPRecuperado := HPFaltando;

        // Define o novo HP do mob
        mob^.Character.CurrentScore.CurHP := HPAtual + HPRecuperado;

        // Envia atualização de HP/MP para o mob
        mob^.SendCurrentHPMP(True);
      end;
    55:
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 40);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := RandomRange(60, 120);
          end
          else
          begin // dano menor
            Helper2 := RandomRange(30, 59);
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNFis div 2),
            Self.Character.CurrentScore.DNFis+1);
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := ((DataSkill^.EFV[0] + Helper2) div DataSkill^.Duration)* 1;
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;

    154: // Veneno Hidra
      begin
       mob^.Chocado := True ;
       mob^.AddBuff(Skill);
       end;

    79: //veneno da lentid�o
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 :=  120 + 150;
          end
          else
          begin // dano menor
            Helper2 :=  + 130;
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNFis div 2),
            Self.Character.CurrentScore.DNFis+1);
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := ((DataSkill^.EFV[0] + Helper2) div DataSkill^.Duration);
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);


      end;

      74://e espinho venenoso
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := 120 + 130;
          end
          else
          begin // dano menor
            Helper2 := 59 + 110;
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNFis div 2),
            Self.Character.CurrentScore.DNFis+1);
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := ((DataSkill^.EFV[0] + Helper2) div DataSkill^.Duration);
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;

      80: // requin
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) *80);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := 120 + 1000;
          end
          else
          begin // dano menor
            Helper2 := 59 + 900;
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNFis div 2),
            Self.Character.CurrentScore.DNFis+1);
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := ((DataSkill^.EFV[0] + Helper2) div DataSkill^.Duration);
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;


    250: // Sofrimento Mago
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := RandomRange(60, 120);
          end
          else
          begin // dano menor
            Helper2 := RandomRange(30, 59);
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNMag div 2),
            Self.Character.CurrentScore.DNMag+1);
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := (DataSkill^.EFV[0] + Helper2)* 15;
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;


    99: // polimorfo


    begin
    if not (mob.Character.Nation in [1, 2, 3, 4]) then
     begin
       self.SendClientMessage('Só pode ser utilizado em Nações oficiais.');
       Exit;
      end;

        begin
     // Se o buff 33 não estiver ativo ou não for um oponente, continuar com o polimorfismo
      mob^.Polimorfed := True;

      if (mob^.ClientID <= MAX_CONNECTIONS) then
      begin
        // Verificar se o CurHP é maior que 50% de MaxHP
        if mob^.Character.CurrentScore.CurHP > (mob^.Character.CurrentScore.MaxHP div 2)
        and (mob^.Character.CurrentScore.MaxMP div 2) then
        begin
          // Define CurHP para 1/3  de MaxHP, defesa fisica e mnagica se for maior
          mob^.Character.CurrentScore.CurHP := mob^.Character.CurrentScore.CurHP
          - (mob^.Character.CurrentScore.CurHP div 2);
          mob^.Character.CurrentScore.CurMP := mob^.Character.CurrentScore.CurMP
          - (mob^.Character.CurrentScore.CurMP div 2);

           mob^.Character.CurrentScore.DEFFis :=0;
           mob^.Character.CurrentScore.DEFMAG := 0;     //PlayerCharacter.CritRes

           mob^.PlayerCharacter.CritRes  := mob^.PlayerCharacter.CritRes
          - (mob^.PlayerCharacter.CritRes div 4);

          mob^.PlayerCharacter.CritRes  := mob^.PlayerCharacter.ResDamageCritical
          - (mob^.PlayerCharacter.ResDamageCritical div 4);






        end;

        // Envia a criação do mob com o status polimorfado
        mob^.SendCreateMob(SPAWN_NORMAL, 0, True, 282);

        // Adiciona o buff de polimorfismo
        mob^.AddBuff(Skill);
      end;
    end;
    end;








    {99: // polimorfo
      begin
      mob^.Polimorfed := True;
      if (mob^.ClientID <= MAX_CONNECTIONS) then
      begin
        // Verificar se o CurHP é maior que 50% de MaxHP
        if mob^.Character.CurrentScore.CurHP > (mob^.Character.CurrentScore.MaxHP div 2) then
        begin
          // Define CurHP para 50% de MaxHP se for maior
          mob^.Character.CurrentScore.CurHP := (mob^.Character.CurrentScore.MaxHP div 2);
        end;
        // Envia a criação do mob com o status polimorfado
        mob^.SendCreateMob(SPAWN_NORMAL, 0, True, 282);
        // Adiciona o buff
        mob^.AddBuff(Skill);
      end;
    end;}



    140: // limpar cl
      begin
        mob^.RemoveDebuffs(1);
      end;

    122: // cura cl

        begin
        // Definir o tempo de cast para 0 (instantâneo)
        SkillData[Skill].CastTime := 0;
        // Calcular e curar o alvo
        Self.CalcAndCure(Skill, mob) ;
        // self.Character.CurrentScore.CurHP := (mob^.Character.CurrentScore.CurHP );
        // mob^.Character.CurrentScore.CurHP := (mob^.Character.CurrentScore.CurHP );
        // Aplicar o debuff no target
         mob^.RemoveDebuffs(1);
         Self.CalcAndCure (Skill, mob);


    end;

      //begin
      //  Self.CalcAndCure(Skill, mob);
      //end;

    125: // mao de cura cl
      begin
      mob^.HPRListener := True;
      mob^.HPRAction := 2;
      mob^.HPRSkillID := Skill;
      mob^.HPRSkillEtc1 := Round((Self.CalcCure2(DataSkill^.EFV[0], mob, Skill) / DataSkill^.Duration) * 3);
      mob^.AddBuff(Skill);
    end;

    RESSUREICAO:
      begin
        if(mob.IsDead) then
        begin
          if(Self.PartyId = 0) then
            Exit;

          if(mob.PartyId = 0) then
            Exit;

          if(Servers[Self.ChannelId].Players[Self.ClientID].Party.InRaid) then
          begin
            if(mob.PartyId <> Self.PartyId) then
            begin
              BoolHelper := False;

              for I := 1 to 3 do
              begin
                if(Servers[Self.ChannelId].Players[Self.ClientID].Party.PartyAllied[i] = 0) then
                  Continue;

                if(Servers[Self.ChannelId].Players[Self.ClientID].Party.PartyAllied[i] =
                  mob.PartyId) then
                begin
                  BoolHelper := True;
                  break;
                end;
              end;

              if not(BoolHelper) then
                Exit;
            end;
          end
          else
          begin
            if(mob.PartyId <> Self.PartyId) then
              Exit;
          end;

          mob.IsDead := False;

          mob.Character.CurrentScore.CurHP :=
            ((mob.Character.CurrentScore.MaxHp div 100) * SkillData[Skill].Damage);
          mob.SendEffect(1);
          mob.SendCurrentHPMP(True);

          Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage(
            'Voce foi ressuscitado pelo jogador ' +
              AnsiString(Self.Character.Name) + '.');

              mob.addbuff(10038)
        end;

      end;
    131: // cura massa defensiva cl
      begin
        Self.CalcAndCure(Skill, mob);
        mob^.AddBuff(7362);
      end;
    337: // 75 wr
    begin
      // Remove debuffs e aplica o buff principal da habilidade 337
      mob^.RemoveDebuffs(1);
      mob^.AddBuff(Skill);

      // Verifica se o mob é o jogador
      if mob^.IsPlayer then
      begin
        // Aplica a habilidade 221 ao jogador, mas impede as habilidades 226, 393 e 153
        if (Skill <> 226) and (Skill <> 393) and (Skill <> 159) and (Skill <> 99) then
          mob^.AddBuff(221);  // Aplica a habilidade 221 ao jogador

         end;
    end;
    128: // liberta��o de mana cl
      begin
        mob^.HPRListener := True;
        mob^.HPRAction := 3;
        mob^.HPRSkillID := Skill;
        mob^.HPRSkillEtc1 := (Self.CalcCure2(DataSkill^.EFV[0], mob, Skill) + DataSkill^.EFV[0]);
        mob^.AddBuff(Skill);
      end;
    133: //raio solar
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 8);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := RandomRange(30, 59);
          end
          else
          begin // dano menor
            Helper2 := RandomRange(10, 29);
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNMag div 2),
          Self.Character.CurrentScore.DNMag+1);
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := ((DataSkill^.EFV[0] * 1) + Helper2);
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);



      end;

    138: // recupera��o cl
      begin
        Self.CalcAndCure(Skill, mob);
        mob^.RemoveAllDebuffs;
      end;
    162: // aurea do explendor cl

        begin
          Self.CalcAndCure(Skill, mob);
          mob^.AddBuff(Skill);

          // Adiciona imunidade ao player que utiliza a habilidade
          Self.AddBuff( EF_IMMUNITY); // Duração de 30 segundos, ajustar conforme necessário

        end;

    459: // cura concentrada cl

      begin
      // Inicializa a cura usando a função CalcCure2 com a base de 10
      mob^.AddHP(Self.CalcCure2(10000, mob), True);
      end;




    167: // Gloria de Excelsis
    begin
      Self.CalcAndCure(Skill, mob);
      mob.CalcAndCure(Skill, mob);
      mob^.RemoveDebuffs(1);             // Remove um debuff
      Self.CalcAndCure(Skill, mob);      // Cura inicial
      mob^.AddBuff(Skill);               // Aplica buff no alvo
      Self.AddBuff(Skill);               // Aplica buff no caster (caso necessário)
      end;



    458: // flores da gloria
      begin
        Self.CalcAndCure(Skill, mob);
      end;
    113: // teleporte em massa fc
      begin
        Helper := TItemFunctions.GetItemReliquareSlot(Servers[mob^.ChannelId].Players[mob.ClientID]);

        if(Helper <> 255) then
        begin
          Servers[mob^.ChannelId].Players[mob.ClientID].SendClientMessage('Imposs�vel telar com rel�quia.');
          Exit;
        end;

        if(mob.InClastleVerus) then
        begin
          Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage('Imposs�vel usar em guerra. Use o teleporte.');
          Exit;
        end;

        if(Self.Character.Nation > 0) then
        begin
          if(Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Imposs�vel usar em outros pa�ses.');
            Exit;
          end;
        end;

        if(mob^.Character.Nation > 0) then
        begin
          if(mob^.Character.Nation = Servers[mob^.ChannelId].NationID) then
            mob^.WalkTo(TPosition.Create(Posx, Posy), 70, MOVE_TELEPORT);
        end
        else
        mob^.WalkTo(TPosition.Create(Posx, Posy), 70, MOVE_TELEPORT);
      end;
    248: // ceu sereno (pran skill)
      begin
        mob^.HPRListener := True;
        mob^.HPRAction := 2;
        mob^.HPRSkillID := Skill;
        mob^.HPRSkillEtc1 := DataSkill^.EFV[0];
        mob^.AddBuff(Skill);
      end
  else
    begin
      try
        mob^.AddBuff(Skill);
      except
        on E: Exception do
        begin
          Logger.Write('Error at mob.AddBuff ' + E.Message, TLogType.Error);
        end;
      end;
    end;
  end;
   mob.SendCurrentHPMP;
    mob.SendStatus;
    mob.SendRefreshPoint;
end;
procedure TBaseMob.TargetSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Classe of
    1, 2:
      begin
        Self.WarriorSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
    11, 12: // templar skill
      begin
        Self.TemplarSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
    21, 22: // rifleman skill
      begin
        Self.RiflemanSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
          Resisted);
      end;
    31, 32: // dualgunner skill
      begin
        Self.DualGunnerSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
          Resisted);
      end;
    41, 42: // magician skill
      begin
        Self.MagicianSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
          Resisted);
      end;
    51, 52: // cleric skill
      begin
        Self.ClericSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
  end;
end;
procedure TBaseMob.AreaBuff(Skill, Anim: DWORD; mob: PBaseMob;
  Packet: TRecvDamagePacket);
var
  i, cnt: Integer;
  PrePosition: TPosition;
begin
  if ((Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex = 0) or
  (SkillData[Skill].Index = LAMINA_PROMESSA)) then
  begin // Se n�o estiver em party, buffa s� em si mesmo
    Self.SelfBuffSkill(Skill, Anim, mob, Packet.DeathPos);
    // Logger.Write(Packet.DeathPos.X.ToString, TLogType.Packets);
  end
  else
  begin
    cnt := 0;
    // Se estiver em party, vai buffar em si mesmo + Party
    if (Self.VisiblePlayers.Count = 0) then
    begin
      Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players
        [Self.ClientID].Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
        Trunc(Packet.DeathPos.y));
    end
    else
    begin
      for i in Self.VisiblePlayers do
      begin
        if (Servers[Self.ChannelId].Players[i].Status < Playing) or
          (Servers[Self.ChannelId].Players[i].Base.IsDead) then
          Continue;
        if (Servers[Self.ChannelId].Players[i].PartyIndex = 0) then
          Continue;
        if (cnt = 0) then
        begin
          PrePosition := Self.PlayerCharacter.LastPos;
          Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players
            [Self.ClientID].Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
            Trunc(Packet.DeathPos.y));
          cnt := 1;
        end;
        if (Servers[Self.ChannelId].Players[Self.ClientID].Party.
          Index <> Servers[Self.ChannelId].Players[i].Party.Index) then
          Continue;

        if not(PrePosition.InRange(
          Servers[Self.ChannelId].Players[i]
          .Base.PlayerCharacter.LastPos, Trunc(SkillData[Skill].Range * 1.5))) then
          Continue;

        Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players[i]
          .Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
          Trunc(Packet.DeathPos.y));
        Packet.Animation := 0;
        Packet.TargetID := i;
        Packet.AttackerHP := Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.CurHP;
        // Packet.DeathPos := Servers[Self.ChannelId].Players[i]
        // .Base.PlayerCharacter.LastPos;
        Self.SendToVisible(Packet, Packet.Header.size);
      end;
    end;
  end;
  if (SkillData[Skill].Index = 167) then
    Self.UsingLongSkill := True;
end;
procedure TBaseMob.AreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  SkillPos: TPosition; DataSkill: P_SkillData; DamagePerc: Single; ElThymos: Integer);
var
  Dano: Integer;
  DmgType: TDamageType;
  SelfPlayer: PPlayer;
  OtherPlayer: PPlayer;
  NewMob, mob_teleport: PBaseMob;
  NewMobSP: PMobSPoisition;
  Packet: TRecvDamagePacket;
  i, j, cnt: Integer;
  Add_Buff: Boolean;
  Resisted: Boolean;
  Mobid, mobpid: Integer;
  MoveTarget: Boolean;
  DropExp, DropItem: Boolean;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.DeathPos := SkillPos;
  if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
  begin     //SkillData[Skill]
    Packet.AttackerPos := SkillPos;
  end
  else
  begin
    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  end;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.MobAnimation := DataSkill^.TargetAnimation;
  Self.UsingLongSkill := False;

  if(ElThymos > 0) then
  begin
    Packet.SkillID := 0;
    Packet.Animation := 0;
    Packet.MobAnimation := 26;
  end;

  if(SkillData[Skill].Index = DEMOLICAO_X14) then
  begin
    Self.SelfBuffSkill(Skill, Anim, mob, SkillPos);
    Packet.TargetID := 0;
    Packet.Dano := 0;
    Packet.DnType := TDamageType.None;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
    Exit;
  end;
  case Self.GetMobClass() of
    2,3:
      begin
        if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
        begin
          TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 1);
          Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
            Self.Character.Equip[15], False);
        end;
      end;
  end;
  if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
  begin
    cnt := 0;
    for i := Low(VisibleTargets) to High(VisibleTargets) do
    begin
      if (VisibleTargets[i].ClientID = 0) then
        Continue;
      Mobid := TMobFuncs.GetMobDgGeralID(Self.ChannelId, i,
        Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID);
        if (Mobid = -1) then
        Continue;
      NewMob := Self.GetTargetInList(VisibleTargets[i].ClientID);
      if (NewMob = nil) then
        Continue;
      if (NewMob^.IsDead) then
        Continue;
      Mobid := NewMob^.Mobid;
      if (DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[Mobid].IsAttacked = False) then
      begin
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[Mobid].IsAttacked := True;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[Mobid].FirstPlayerAttacker := Self.ClientID;
      end;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[Mobid].AttackerID := Self.ClientID;
      if (DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[Mobid].Position.Distance(SkillPos) <=
        (DataSkill^.range * 1.5)) then
      begin
        Packet.TargetID := NewMob^.ClientID;
        Resisted := False;
        case DataSkill^.Classe of
          1, 2: // warrior skill
            begin
              Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                Add_Buff, Resisted, MoveTarget);
            end;
          11, 12: // templar skill
            begin
              Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                Add_Buff, Resisted);
            end;
          21, 22: // rifleman skill
            begin
              Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                Add_Buff, Resisted);
            end;
          31, 32: // dualgunner skill
            begin
              Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                Add_Buff, Resisted);
            end;
          41, 42: // magician skill
            begin
              Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                Add_Buff, Resisted);
            end;
          51, 52: // cleric skill
            begin
              Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                Resisted);
            end;
        end;
        Inc(cnt);
        if(Dano > 0) then
        begin
          Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
            Packet.MobAnimation, DataSkill);
          if(Dano > 0) then
          begin
            Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));
          end;
        end;

        if (Add_Buff = True) then
        begin
          if not(Resisted) then
            Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
        end;
        Packet.Dano := Dano;
        Packet.DnType := DmgType;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[Mobid].IsAttacked := True;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[Mobid].AttackerID := Self.ClientID;
        if (Packet.Dano >= DungeonInstances[Servers[Self.ChannelId].Players
          [Self.ClientID].DungeonInstanceID].Mobs[Mobid].CurrentHP) then
        begin
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].CurrentHP := 0;
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].IsAttacked := False;
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].AttackerID := 0;
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].deadTime := Now;
          if (Self.VisibleMobs.Contains(NewMob^.ClientID)) then
            Self.VisibleMobs.Remove(NewMob^.ClientID);
          NewMob^.VisibleMobs.Clear;
          Self.MobKilledInDungeon(NewMob);
          Packet.MobAnimation := 30;
          NewMob^.IsDead := True;
          Self.RemoveTargetFromList(NewMob);
        end
        else
        begin
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].CurrentHP :=
            DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].CurrentHP - Packet.Dano;
        end;
        NewMob.LastReceivedAttack := Now;
        Packet.MobCurrHP := DungeonInstances
          [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID]
          .Mobs[Mobid].CurrentHP;
        Self.SendToVisible(Packet, Packet.Header.size);
        //Sleep(1);
      end;
    end;
    if (cnt = 0) then
    begin
      Packet.TargetID := 0;
      /// ////era $7535
      Packet.Dano := 0;
      Packet.DnType := TDamageType.Normal;
      Packet.AttackerPos := SkillPos;
      Packet.DeathPos := SkillPos;
      Self.SendToVisible(Packet, Packet.Header.size);
      //Sleep(1);
    end;
    // aquele inc(cnt) comentado tem que fazer ele funfar aqui
    Exit;
  end;

  cnt := 0;
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  for i := Low(VisibleTargets) to High(VisibleTargets) do
  begin
    if (VisibleTargets[i].ClientID = 0) then
      Continue;

    if(ElThymos > 0) then
    begin
      if(VisibleTargets[i].ClientID = mob.ClientID) then
        Continue;
    end;

    case VisibleTargets[i].TargetType of
      0:
        begin
          if(VisibleTargets[i].Player = nil) then
            Continue;

          NewMob := VisibleTargets[i].Player;
          OtherPlayer := @Servers[Self.ChannelId].Players
            [VisibleTargets[i].ClientID];
          if (NewMob^.IsDead) then
            Continue;
          if(OtherPlayer.SocketClosed) then
            Continue;
          if(OtherPlayer.Status < Playing) then
            Continue;
          if (SkillPos.InRange(NewMob^.PlayerCharacter.LastPos,
            Trunc(DataSkill^.range * 1.5))) then
          begin
            if (TPosition.Create(2947, 1664)
              .InRange(NewMob^.PlayerCharacter.LastPos, 10)) then
              Continue;
            if ((SelfPlayer^.Character.Base.GuildIndex > 0) and
              (SelfPlayer.Character.Base.GuildIndex = OtherPlayer^.Character.
              Base.GuildIndex) and not(SelfPlayer^.Dueling)) then
              Continue;
            if (SelfPlayer^.PartyIndex > 0) and
              (SelfPlayer.PartyIndex = OtherPlayer^.PartyIndex) then
              Continue;
            if ((Self.Character.Nation = NewMob^.Character.Nation) and
              (SelfPlayer^.Character.PlayerKill = False) and
              not(SelfPlayer^.Dueling)) then
              Continue;
            if (SelfPlayer^.Dueling) then
            begin
              if (NewMob^.ClientID <> SelfPlayer^.DuelingWith) then
                Continue;
              if (SecondsBetween(Now, SelfPlayer^.DuelInitTime) <= 15) then
                Continue;
            end;

            if((SelfPlayer^.Character.GuildSlot > 0) and (Servers[SelfPlayer^.ChannelIndex].Players[
            NewMob^.ClientID].Character.GuildSlot > 0)) then
            begin
              if(Guilds[SelfPlayer^.Character.GuildSlot].Ally.Leader =
                Guilds[Servers[SelfPlayer^.ChannelIndex].Players[
                NewMob^.ClientID].Character.GuildSlot].Ally.Leader) then
              Exit;
            end;

            if(SecondsBetween(Now, NewMob.RevivedTime) <= 7) then
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Alvo acabou de nascer.');
              Continue;
            end;
            Inc(cnt);
            Packet.TargetID := NewMob^.ClientID;
            Resisted := False;
            case DataSkill^.Classe of
              1, 2: // warrior skill
                begin
                  Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted, MoveTarget);
                end;
              11, 12: // templar skill
                begin
                  Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
              21, 22: // rifleman skill
                begin
                  Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
              31, 32: // dualgunner skill
                begin
                  Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
              41, 42: // magician skill
                begin
                  Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
              51, 52: // cleric skill
                begin
                  Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
            end;
            if (Dano > 0) then
            begin
              if (ElThymos > 0) then
              begin
                Self.AttackParse(0, Anim, NewMob, Dano, DmgType, Add_Buff,
                  Packet.MobAnimation, DataSkill);
              end
              else
              begin
                Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                  Packet.MobAnimation, DataSkill);
              end;

              if(Dano > 0) then
              begin
                Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));

                if(DamagePerc > 0) then
                begin
                  Dano := Trunc((Dano div 100) * DamagePerc);
                end;
              end;
            end
            else
            begin
              if not(DmgType in [Critical, Normal, Double]) then
                Add_Buff := False;
            end;
            if (Add_Buff = True) then
            begin
              if not(Resisted) then
                Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
            end;
            if((ElThymos > 0) and (Dano > 0)) then
            begin
              Dano := Round((Dano / 100) * DamagePerc);
            end;
            if (DmgType = Miss) then
              Dano := 0;


            Packet.Dano := Dano;
            Packet.DnType := DmgType;
            if (Packet.Dano >= NewMob^.Character.CurrentScore.CurHP) then
            begin
              if (OtherPlayer^.Dueling) then
              begin
                NewMob^.Character.CurrentScore.CurHP := 10;
              end
              else
              begin
                NewMob^.Character.CurrentScore.CurHP := 0;
                NewMob^.SendEffect($0);
                Packet.MobAnimation := 30;
                NewMob^.IsDead := True;
                if(Servers[Self.ChannelId].Players[NewMob^.ClientID].CollectingReliquare) then
                  Servers[Self.ChannelId].Players[NewMob^.ClientID].SendCancelCollectItem(
                  Servers[Self.ChannelId].Players[NewMob^.ClientID].CollectingID);
                NewMob^.LastReceivedAttack := Now;
                Packet.MobCurrHP := NewMob^.Character.CurrentScore.CurHP;
                if(cnt>1) then
                begin
                  Packet.AttackerID := Self.ClientID;
                  Packet.Animation := 0;
                end
                else
                begin
                  Packet.AttackerID := Self.ClientID;
                end;
                if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
                begin     //SkillData[Skill]
                  Packet.AttackerPos := SKillPos;
                  Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
                end
                else
                begin
                  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                  Packet.DeathPos := SkillPos;
                end;

                Self.SendToVisible(Packet, Packet.Header.size);
                if (NewMob^.Character.Nation > 0) and (Self.Character.Nation > 0)
                then
                begin
                  if ((NewMob^.Character.Nation <> Self.Character.Nation) or
                    (Self.InClastleVerus)) then
                  begin
                    Self.PlayerKilled(NewMob);
                  end;
                end;
              end;
            end
            else
            begin
              if (Packet.Dano > 0) then
                NewMob^.RemoveHP(Packet.Dano, False);
              if(Servers[Self.ChannelId].Players[NewMob^.ClientID].CollectingReliquare) then
                Servers[Self.ChannelId].Players[NewMob^.ClientID].SendCancelCollectItem(
                Servers[Self.ChannelId].Players[NewMob^.ClientID].CollectingID);
              NewMob^.LastReceivedAttack := Now;
              Packet.MobCurrHP := NewMob^.Character.CurrentScore.CurHP;
              if(cnt>1) then
              begin
                Packet.AttackerID := Self.ClientID;
                Packet.Animation := 0;
              end
              else
              begin
                Packet.AttackerID := Self.ClientID;
              end;
              if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
              begin     //SkillData[Skill]
                Packet.AttackerPos := SKillPos;
                Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
              end
              else
              begin
                Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                Packet.DeathPos := SkillPos;
              end;

              Self.SendToVisible(Packet, Packet.Header.size);
            end;

            //Sleep(1);
          end;
        end;
      1:
        begin
          if(VisibleTargets[i].mob = nil) then
            Continue;
          NewMob := VisibleTargets[i].mob;
          if(NewMob.ClientID> 9147) then
            Continue;
          if not(Servers[Self.ChannelId].MOBS.TMobS[NewMob.Mobid].IsActiveToSpawn) then
            Continue;
          if (NewMob^.IsDead) then
            Continue;
          case NewMob^.ClientID of
            3340 .. 3354:
              begin // stones
                if (SkillPos.InRange(Servers[Self.ChannelId].DevirStones
                  [NewMob^.ClientID].PlayerChar.LastPos,
                  Trunc(DataSkill^.range * 1.5))) then
                begin
                  if (Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .PlayerChar.Base.Nation = Integer(Servers[Self.Channelid].Players[Self.ClientID].
                    Account.Header.Nation)) then
                    Continue;
                  Inc(cnt);
                  Packet.TargetID := NewMob^.ClientID;
                  Resisted := False;
                  case DataSkill^.Classe of
                    1, 2: // warrior skill
                      begin
                        Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, MoveTarget);
                      end;
                    11, 12: // templar skill
                      begin
                        Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    21, 22: // rifleman skill
                      begin
                        Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    31, 32: // dualgunner skill
                      begin
                        Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    41, 42: // magician skill
                      begin
                        Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    51, 52: // cleric skill
                      begin
                        Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                  end;
                  if(Dano > 0) then
                  begin
                    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                      Packet.MobAnimation, DataSkill);

                    if(Dano > 0) then
                    begin
                      Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));

                      if(DamagePerc > 0) then
                      begin
                        Dano := Trunc((Dano div 100) * DamagePerc);
                      end;
                    end;
                  end;
                  if (Add_Buff = True) then
                  begin
                    if not(Resisted) then
                      Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                  end;
                  if (DmgType = Miss) then
                    Dano := 0;
                  if((ElThymos > 0) and (Dano > 0)) then
                  begin
                    Dano := Round((Dano / 100) * DamagePerc);
                  end;

                  Packet.Dano := Dano;
                  Packet.DnType := DmgType;
                  Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .IsAttacked := True;
                  Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .AttackerID := Self.ClientID;
                  if ((Packet.Dano >= Servers[Self.ChannelId].DevirStones
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP)and not(NewMob^.IsDead)) then
                  begin
                    NewMob^.IsDead := True;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP := 0;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .IsAttacked := False;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .AttackerID := 0;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .deadTime := Now;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID].
                      KillStone(Newmob^.ClientID, Self.ClientId);
                    if (Self.VisibleNPCs.Contains(NewMob^.ClientID)) then
                    begin
                      Self.VisibleNPCs.Remove(NewMob^.ClientID);
                      Self.RemoveTargetFromList(NewMob);
                      // essa skill tem retorno no caso de erro
                    end;
                    for j in Self.VisiblePlayers do
                    begin
                      if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(NewMob^.ClientID)) then
                      begin
                        Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(NewMob^.ClientID);
                        Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(NewMob);
                      end;
                    end;
                    NewMob^.VisibleMobs.Clear;
                    // Self.MobKilled(mob, DropExp, DropItem, False);
                    Packet.MobAnimation := 30;
                  end
                  else
                  begin
                    deccardinal(Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP,Packet.Dano);
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  if(cnt>1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
                  if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
                  begin     //SkillData[Skill]
                    Packet.AttackerPos := SKillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  //Sleep(1);
                end;
              end;
            3355 .. 3369:
              begin // guards
                if (SkillPos.InRange(Servers[Self.ChannelId].DevirGuards
                  [NewMob^.ClientID].PlayerChar.LastPos,
                  Trunc(DataSkill^.range * 1.5))) then
                begin
                  if (Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .PlayerChar.Base.Nation = Integer(Servers[Self.Channelid].Players[Self.ClientID].
                    Account.Header.Nation)) then
                    Continue;
                  Inc(cnt);
                  Packet.TargetID := NewMob^.ClientID;
                  Resisted := False;
                  case DataSkill^.Classe of
                    1, 2: // warrior skill
                      begin
                        Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, MoveTarget);
                      end;
                    11, 12: // templar skill
                      begin
                        Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    21, 22: // rifleman skill
                      begin
                        Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    31, 32: // dualgunner skill
                      begin
                        Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    41, 42: // magician skill
                      begin
                        Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    51, 52: // cleric skill
                      begin
                        Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                  end;
                  if(Dano > 0) then
                  begin
                    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                      Packet.MobAnimation, DataSkill);

                    if(Dano > 0) then
                    begin
                      Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));

                      if(DamagePerc > 0) then
                      begin
                        Dano := Trunc((Dano div 100) * DamagePerc);
                      end;
                    end;
                  end;
                  if (Add_Buff = True) then
                  begin
                    if not(Resisted) then
                      Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                  end;
                  if (DmgType = Miss) then
                    Dano := 0;
                  if((ElThymos > 0) and (Dano > 0)) then
                  begin
                    Dano := Round((Dano / 100) * DamagePerc);
                  end;

                  Packet.Dano := Dano;
                  Packet.DnType := DmgType;
                  Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .IsAttacked := True;
                  Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .AttackerID := Self.ClientID;
                  if ((Packet.Dano >= Servers[Self.ChannelId].DevirGuards
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP)and not(NewMob^.IsDead)) then
                  begin
                    NewMob^.IsDead := True;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP := 0;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .IsAttacked := False;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .AttackerID := 0;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .deadTime := Now;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID].
                      KillGuard(Newmob^.ClientID, Self.ClientId);
                    if (Self.VisibleNPCs.Contains(NewMob^.ClientID)) then
                    begin
                      Self.VisibleNPCs.Remove(NewMob^.ClientID);
                      Self.RemoveTargetFromList(NewMob);
                      // essa skill tem retorno no caso de erro
                    end;
                    for j in Self.VisiblePlayers do
                    begin
                      if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(NewMob^.ClientID)) then
                      begin
                        Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(NewMob^.ClientID);
                        Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(NewMob);
                      end;
                    end;
                    NewMob^.VisibleMobs.Clear;
                    // Self.MobKilled(mob, DropExp, DropItem, False);
                    Packet.MobAnimation := 30;
                  end
                  else
                  begin
                    deccardinal(Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP, Packet.Dano);
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  if(cnt>1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
                  if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
                  begin     //SkillData[Skill]
                    Packet.AttackerPos := SKillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  //Sleep(1);
                end;
              end
          else
            begin
              NewMobSP := @Servers[Self.ChannelId].Mobs.TMobS[NewMob^.Mobid]
                .MobsP[NewMob^.SecondIndex];
              if (SkillPos.InRange(NewMobSP^.CurrentPos,
                Trunc(DataSkill^.range * 1.5))) then
              begin
                if ((NewMobSP^.isGuard) and
                  ((NewMob^.PlayerCharacter.Base.Nation = Self.Character.Nation) or
                  (Self.Character.Nation = 0)))
                then
                  Continue;

                if not(NewMobSP.IsAttacked) then
                begin
                  NewMobSP.FirstPlayerAttacker := Self.ClientID;
                end;

                Inc(cnt);
                Packet.TargetID := NewMob^.ClientID;
                Resisted := False;
                case DataSkill^.Classe of
                  1, 2: // warrior skill
                    begin
                      Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted, MoveTarget);
                    end;
                  11, 12: // templar skill
                    begin
                      Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  21, 22: // rifleman skill
                    begin
                      Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  31, 32: // dualgunner skill
                    begin
                      Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                        DmgType, Add_Buff, Resisted);
                    end;
                  41, 42: // magician skill
                    begin
                      Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  51, 52: // cleric skill
                    begin
                      Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                end;
                if(Dano > 0) then
                begin
                  Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                    Packet.MobAnimation, DataSkill);

                  if(Dano > 0) then
                  begin
                    Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));

                    if(DamagePerc > 0) then
                    begin
                      Dano := Trunc((Dano div 100) * DamagePerc);
                    end;
                  end;
                end;
                if (Add_Buff = True) then
                begin
                  if not(Resisted) then
                    Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                end;
                if (DmgType = Miss) then
                  Dano := 0;
                if((ElThymos > 0) and (Dano > 0)) then
                begin
                  Dano := Round((Dano / 100) * DamagePerc);
                end;
                Packet.Dano := Dano;
                Packet.DnType := DmgType;
                NewMobSP^.IsAttacked := True;
                NewMobSP^.AttackerID := Self.ClientID;
                if (Packet.Dano >= NewMobSP^.HP) then
                begin
                  NewMobSP^.HP := 0;
                  NewMobSP^.IsAttacked := False;
                  NewMobSP^.AttackerID := 0;
                  NewMobSP^.deadTime := Now;
                  NewMob.SendEffect($0);
                  NewMob^.IsDead := True;
                  NewMob.SendCurrentHPMPMob;
                  if (Self.VisibleMobs.Contains(NewMob^.ClientID)) then
                  begin
                    Self.VisibleMobs.Remove(NewMob^.ClientID);
                    Self.RemoveTargetFromList(NewMob);
                  end;
                  for j in Self.VisiblePlayers do
                  begin
                    if(Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains(NewMob^.ClientID)) then
                    begin
                      Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove(NewMob^.ClientID);
                      Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(NewMob);
                    end;
                  end;
                  NewMob^.VisibleMobs.Clear;
                  Self.MobKilled(NewMob, DropExp, DropItem, False);
                  Packet.MobAnimation := 30;
                  if(cnt>1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
                  begin     //SkillData[Skill]
                    Packet.AttackerPos := SKillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  Packet.MobCurrHP := 0;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  //Sleep(1);
                end
                else
                begin

                  deccardinal(NewMobSP^.HP, Packet.Dano);
                  Packet.MobCurrHP := NewMobSP^.HP;
                  NewMob^.LastReceivedAttack := Now;
                  if(cnt>1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
                  begin     //SkillData[Skill]
                    Packet.AttackerPos := SKillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  NewMob.SendCurrentHPMPMob;
                  //Sleep(1);
                end;
              end;
            end;
          end;
        end;
    end;
  end;
  if ((cnt = 0) and (ElThymos = 0)) then
  begin
    Packet.TargetID := 0;
    Packet.Dano := 0;
    Packet.DnType := TDamageType.Normal;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
  end;
  // tem que continuar transformando tudo em pointer pra isso ficar dinamico
  // tem que terminar de completar a funcao acima de player
  // fazer a de mobs
  // ver se o dungeons la em cima pode encaixar junto
  // dps excluir aqui embaixo
  // 16/03/2021
  {
    if (Self.VisiblePlayers.Count > 0) then
    begin
    for i in Self.VisiblePlayers do
    begin
    if (Servers[Self.ChannelId].Players[i].Base.ClientID = Self.ClientID) then
    Continue;
    if (Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.
    InRange(SkillPos, (SkillData[Skill].range * 2.5))) then
    begin
    NewMob := @Servers[Self.ChannelId].Players[i].Base;
    if (NewMob.IsDead) then
    Continue;
    if ((Servers[Self.ChannelId].Players[Self.ClientID]
    .Character.Base.GuildIndex > 0) and
    (Servers[Self.ChannelId].Players[Self.ClientID]
    .Character.Base.GuildIndex = Servers[Self.ChannelId].Players[i]
    .Character.Base.GuildIndex) and
    not(Servers[Self.ChannelId].Players[Self.ClientID].Dueling)) then
    Continue; // mesma guild, se nao tiver duelando
    if (Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex > 0) and
    (Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex = Servers
    [Self.ChannelId].Players[i].PartyIndex) then
    Continue; // mesma party
    if ((Self.Character.Nation = NewMob.Character.Nation) and
    (Servers[Self.ChannelId].Players[Self.ClientID]
    .Character.PlayerKill = False) and
    not(Servers[Self.ChannelId].Players[Self.ClientID].Dueling)) then
    Continue; // mesma na��o e pk desligado, se nao tiver duelando
    if (Servers[Self.ChannelId].Players[Self.ClientID].Dueling) then
    begin
    if (i <> Servers[Self.ChannelId].Players[Self.ClientID].DuelingWith)
    then
    Continue;
    if (SecondsBetween(Now, Servers[Self.ChannelId].Players[Self.ClientID]
    .DuelInitTime) <= 15) then
    // fix de atk em area antes do tempo acabar
    Continue;
    end;
    Packet.TargetID := NewMob.ClientID;
    Resisted := False;
    case SkillData[Skill].Classe of
    1, 2: // warrior skill
    begin
    Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted, MoveTarget);
    end;
    11, 12: // templar skill
    begin
    Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    21, 22: // rifleman skill
    begin
    Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    31, 32: // dualgunner skill
    begin
    Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    41, 42: // magician skill
    begin
    Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    51, 52: // cleric skill
    begin
    Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Resisted);
    end;
    end;
    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Packet.MobAnimation);
    if (Add_Buff = True) then
    begin
    if not(Resisted) then
    Self.TargetBuffSkill(Skill, Anim, NewMob);
    end;
    Packet.Dano := Dano;
    Packet.DnType := DmgType;
    if (Packet.Dano >= NewMob.Character.CurrentScore.CurHP) then
    begin
    if (Servers[Self.ChannelId].Players[NewMob.ClientID].Dueling) then
    begin
    NewMob.Character.CurrentScore.CurHP := 10;
    end
    else
    begin
    NewMob.Character.CurrentScore.CurHP := 0;
    NewMob.SendEffect($0);
    Packet.MobAnimation := 30;
    NewMob.IsDead := True;
    if (NewMob.Character.Nation > 0) and (Self.Character.Nation > 0)
    then
    begin
    if (NewMob.Character.Nation <> Self.Character.Nation) then
    begin
    Self.PlayerKilled(NewMob);
    end;
    end;
    // Inc(Self.PlayerCharacter.Base.CurrentScore.KillPoint);
    // Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
    // ('Seus pontos de PvP foram incrementados em 1.');
    // Self.SendRefreshKills;
    // Self.SendRefreshPoint;
    end;
    end
    else
    begin
    NewMob.RemoveHP(Packet.Dano, False);
    end;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := NewMob.Character.CurrentScore.CurHP;
    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
    Packet.DeathPos := SkillPos;
    // Self.SendCurrentHPMP;
    { if (cnt = 0) then
    Self.SendToVisible(Packet, Packet.Header.size)
    else
    Self.SendToVisible(Packet, Packet.Header.size, False);
    Inc(cnt); }
  { end;
    end;
    end;
    if (Self.VisibleMobs.Count > 0) then
    begin
    for i in Self.VisibleMobs do
    begin
    if ((i >= 3048) and (i <= 9147)) then
    begin
    Mobid := TMobFuncs.GetMobGeralID(Self.ChannelId, i, mobpid);
    if (Mobid = -1) then
    Continue;
    /// /////////
    NewMob := @Servers[Self.ChannelId].Mobs.TMobS[Mobid].MobsP[mobpid].Base;
    if (NewMob.IsDead) then
    Continue;
    if ((Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].CurrentPos.Distance(SkillPos) <=
    (SkillData[Skill].range * 2.5))) { or
    ((Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].CurrentPos.Distance(Self.PlayerCharacter.LastPos)
    <= (SkillData[Skill].range)) and (Self.GetMobClass = 2)))
  } { then
    begin
    if ((Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].isGuard) and
    (Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].Base.PlayerCharacter.Base.Nation = Self.
    Character.Nation)) then
    Continue;
    Packet.TargetID := i;
    Resisted := False;
    case SkillData[Skill].Classe of
    1, 2: // warrior skill
    begin
    Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted, MoveTarget);
    end;
    11, 12: // templar skill
    begin
    Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    21, 22: // rifleman skill
    begin
    Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    31, 32: // dualgunner skill
    begin
    Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    41, 42: // magician skill
    begin
    Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    51, 52: // cleric skill
    begin
    Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    end;
    Inc(cnt);
    try
    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Packet.MobAnimation);
    except
    on E: Exception do
    begin // apagar dps isso e mais 2 exceptions
    Logger.Write('Error at AttackParse mob area attack: ' + E.Message,
    TLogType.Warnings);
    end;
    end;
    if (Add_Buff = True) then
    begin
    if not(Resisted) then
    Self.TargetBuffSkill(Skill, Anim, NewMob);
    end;
    Packet.Dano := Dano;
    Packet.DnType := DmgType;
    Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].IsAttacked := True;
    Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].AttackerID := Self.ClientID;
    if (Packet.Dano >= Servers[mob.ChannelId].Mobs.TMobS[NewMob.Mobid]
    .MobsP[NewMob.SecondIndex].HP) then
    begin
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [mob.SecondIndex].HP := 0;
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].IsAttacked := False;
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].AttackerID := 0;
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].deadTime := Now;
    if (Self.VisibleMobs.Contains(Servers[NewMob.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].Index)) then
    begin
    Self.VisibleMobs.Remove(Servers[NewMob.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].Index);
    end;
    NewMob.VisibleMobs.Clear;
    Self.MobKilled(NewMob, DropExp, DropItem, False);
    Packet.MobAnimation := 30;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := 0;
    Self.SendToVisible(Packet, Packet.Header.size);
    NewMob.IsDead := True;
    end
    else
    begin
    Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].HP := Servers[Self.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].HP - Packet.Dano;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := Servers[NewMob.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].HP;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
    end;
    end;
    end
    else if (mob.ClientID >= 9148) then
    begin
    NewMob := @Servers[Self.ChannelId].PETS[mob.ClientID].Base;
    if (NewMob.IsDead) then
    Continue;
    if (Servers[Self.ChannelId].PETS[NewMob.ClientID]
    .Base.PlayerCharacter.LastPos.Distance(SkillPos) <=
    (SkillData[Skill].range)) then
    begin
    Packet.TargetID := NewMob.ClientID;
    Resisted := False;
    case SkillData[Skill].Classe of
    1, 2: // warrior skill
    begin
    Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted, MoveTarget);
    end;
    11, 12: // templar skill
    begin
    Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    21, 22: // rifleman skill
    begin
    Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    31, 32: // dualgunner skill
    begin
    Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    41, 42: // magician skill
    begin
    Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    51, 52: // cleric skill
    begin
    Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    end;
    Inc(cnt);
    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Packet.MobAnimation);
    if (Add_Buff = True) then
    begin
    if not(Resisted) then
    Self.TargetBuffSkill(Skill, Anim, NewMob);
    end;
    Packet.Dano := Dano;
    Packet.DnType := DmgType;
    Servers[Self.ChannelId].PETS[NewMob.ClientID].IsAttacked := True;
    Servers[Self.ChannelId].PETS[NewMob.ClientID].AttackerID :=
    Self.ClientID;
    if (Packet.Dano >= NewMob.Character.CurrentScore.CurHP) then
    begin
    NewMob.PlayerCharacter.Base.CurrentScore.CurHP := 0;
    Packet.MobAnimation := 30;
    NewMob.IsDead := True;
    for j in NewMob.VisibleMobs do
    begin
    if not(j >= 3048) then
    begin
    Servers[Self.ChannelId].Players[j].UnSpawnPet(NewMob.ClientID);
    end;
    end;
    Inc(Self.PlayerCharacter.Base.CurrentScore.KillPoint);
    Self.SendRefreshKills;
    Servers[Self.ChannelId].PETS[NewMob.ClientID].Base.Destroy;
    ZeroMemory(@Servers[Self.ChannelId].PETS[NewMob.ClientID],
    sizeof(TPet));
    end
    else
    begin
    NewMob.PlayerCharacter.Base.CurrentScore.CurHP :=
    NewMob.PlayerCharacter.Base.CurrentScore.CurHP - Packet.Dano;
    end;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := NewMob.PlayerCharacter.Base.CurrentScore.CurHP;
    // Self.SendCurrentHPMP;
    Self.SendToVisible(Packet, Packet.Header.size);
    end;
    Continue;
    end;
    end;
    end;
    if (cnt = 0) then
    begin
    Logger.Write('Sem alvo disponivel.', TLogType.Packets);
    Packet.TargetID := Self.ClientID;
    /// ////era $7535
    Packet.Dano := 0;
    Packet.DnType := TDamageType.Normal;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
    end; }
end;
procedure TBaseMob.AttackParse(Skill, Anim: DWORD; mob: PBaseMob;
  var Dano: Integer; var DmgType: TDamageType; out AddBuff: Boolean;
  out MobAnimation: Byte; DataSkill: P_SkillData);
var
  HpPerc, MpPerc: Integer;
 // CriticalResTax: Integer;
  Helper: Integer;
  HelperInByte: Byte;
  Help1, Help2: Integer;
  OtherPlayer: PPlayer;
  BoolHelp: Boolean;
  OnePercentOfTheDamage: Integer;
  var BuffKey: WORD;
  MobT: PMobSa;
  CurrentTime: TDateTime;
  DanoExtra: Integer;
   Index: WORD;






  begin






  // Verifica se o mob está no nível entre 200 e 300
  if (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel >= 200) and
   (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel <=300) then
  begin
    // Verifica se não é quarta-feira (dia 4) ou se o horário é antes das 22:00
      if not (((DayOfWeek(Now) = 4) and (HourOf(Now) >= 21)) or
        ((DayOfWeek(Now) = 7) and (HourOf(Now) >= 16))) then
    begin
      // Bloqueia o dano e exibe uma mensagem ao jogador
      Dano := 0;
      DmgType := TDamageType.None;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
        'Boss de Evento de Reliquia. Só recebe Dano de Quarta Apartir das 21 e Sabádo Apartir das 16.', 16, 1, 1);
      Exit; // Sai do procedimento sem aplicar dano
    end;
  end;

  // Verifica se o mob está no nível entre 200 e 300
  if (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel >= 300) and
   (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel <=310) then
  begin
    // Verifica se não é Segunda Feira e quinta feira  (dia 4) ou se o horário é antes das 22:00
      if not (((DayOfWeek(Now) = 2) and (HourOf(Now) >= 20)) or
        ((DayOfWeek(Now) = 5) and (HourOf(Now) >= 16))) then
    begin
      // Bloqueia o dano e exibe uma mensagem ao jogador
      Dano := 0;
      DmgType := TDamageType.None;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
        'Boss de Evento de Reliquia de drop . Só recebe Dano de Quarta Apartir das 21 e Sabádo Apartir das 16.', 16, 1, 1);
      Exit; // Sai do procedimento sem aplicar dano
    end;
  end;


  // Se for um jogador atacando um mob
if (not Self.IsPlayer) and (not mob^.IsPlayer) then

begin
  // Verifica se o jogador não se moveu
  if (Self.FLastPosition.X = CurrentPosition.X) and
     (Self.FLastPosition.Y = CurrentPosition.Y) then
  begin
    Inc(Self.FAttackCountWhileStatic); // Aumenta contador
    if Self.FAttackCountWhileStatic >= 20 then // Se chegou a 120 ataques sem mover
    begin
      LogItem(Self.Character.Name, 'Desconectado por ataque abusivo sem movimentação.');
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('Você foi desconectado por ataque contínuo sem movimentação.');
      Servers[Self.ChannelId].Players[Self.ClientID].Disconnect;
      Exit;
    end;
  end
  else
  begin
    // Se o jogador se moveu, resetamos o contador
    Self.FAttackCountWhileStatic := 0;
    Self.FLastPosition := CurrentPosition;
  end;
end;





// Log do ataque mob
// WriteLn(Format('Mob atacado! ID: %d', [mob^.MobID]));

if Self.BuffExistsByIndex(5136) then
begin
  Dano := 0; // Bloqueia o dano
  //DnType := TDamageType.Immune; // Define o tipo de dano como imunidade
  Exit;
end;


  // AddBuff := True;
  if (Skill > 0) then


  begin

        Inc(Dano, (DataSkill^.Damage+Self.PlayerCharacter.HabAtk) div 2);
        Inc(Dano, Self.PlayerCharacter.HabAtk);
        Inc(Dano, Self.GetMobAbility(EF_SKILL_DAMAGE));
        Inc(Dano, Self.GetMobAbility(EF_PRAN_SKILL_DAMAGE));



    if(Self.Character <> nil) then
      if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
        Inc(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_PER_DAMAGE] *
          (Dano div 100));





  end
  else
  begin
    if(Self.GetMobAbility(EF_SPLASH) > 0) then
    begin //efeito de bater em �rea no ataque b�sico
      if(SecondsBetween(Now, LastSplashTime) >= 1) then
      begin
        LastSplashTime := Now;

        Self.AreaSkill(177, SkillData[177].Anim, mob, Self.PlayerCharacter.LastPos, @SkillData[177],
          Self.GetMobAbility(EF_SPLASH), 1);
      end;
    end;
  end;

  if(Skill > 0) then
  begin
    if((Self.GetMobClass() = 2) or (Self.GetMobClass() = 4) and
      (SkillData[Skill].Adicional > 0)) then
    begin
      Randomize;

      if(SkillData[Skill].Adicional <= RandomRange(1, 101)) then
        DmgType := Critical;
    end;




  end;

  { case DmgType of
    Critical:
      begin
        Dano := Trunc(Dano * 1.5);
        OnePercentOfTheDamage:= Dano div 100;
        Dano := Trunc(Dano * 1.1);
        Helper := Self.PlayerCharacter.DamageCritical;
        Helper := Helper - (mob^.PlayerCharacter.ResDamageCritical);
        if (Helper < 0) then
        begin
          Helper := (Helper * (-1));
          DecInt(Dano, ((OnePercentOfTheDamage) * Helper));
        end
        else
        begin
         Inc(Dano, (OnePercentOfTheDamage * Helper));
        end;
      end;
    Double:

    begin
      Dano := (Dano * 2);
    end;

    DoubleCritical:
      begin
        Dano := Trunc(Dano * 1.5);

        OnePercentOfTheDamage:= Dano div 100;
        Dano := Trunc(Dano * 2.1);
        Helper := Self.PlayerCharacter.DamageCritical;
        Helper := Helper - (mob^.PlayerCharacter.ResDamageCritical);
        if (Helper < 0) then
        begin
          Helper := (Helper * (-1));
          DecInt(Dano, ((OnePercentOfTheDamage) * Helper));
        end
        else
        begin
         Inc(Dano, ((OnePercentOfTheDamage) * Helper));
        end;;

         // Mensagem para o jogador que causou o dano
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
            Format(' Você causou um dano de DUPLO CRÍTICO: %d!', [Dano]),
            255, 0, 0); // Cor vermelha

          // Mensagem para o jogador que RECEBEU o dano
          if (mob.IsPlayer) then
          begin
            Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage(
              Format('Você recebeu um dano de DUPLO CRÍTICO: %d!', [Dano]),
              255, 0, 0); // Cor vermelha
              end;





      end;
  end; }


    case DmgType of
    Critical:
      begin
      Dano := trunc(Dano * 1.1);
        OnePercentOfTheDamage := Dano div 100;
        Dano := Trunc(Dano * 1.5);
        Helper := Self.PlayerCharacter.DamageCritical;
        Helper := Helper - (mob^.PlayerCharacter.ResDamageCritical);

        if (Helper < 0) then
        begin
          Helper := (Helper * (-1));
          DecInt(Dano, ((OnePercentOfTheDamage) * Helper));
        end
        else
        begin
          Inc(Dano, ((OnePercentOfTheDamage) * Helper));
        end;



        // **Aplicando o limite máximo de dano crítico**
        if (mob.IsPlayer) then
        begin
            if (Self.Character.Level = 85) and (Dano > MAX_CRITICAL_DAMAGE) then
                Dano := MAX_CRITICAL_DAMAGE


            else if (Self.Character.Level = 95) and (Dano > MAX_CRITICAL_DAMAGE95) then
                Dano := MAX_CRITICAL_DAMAGE95



            else if (Self.Character.Level = 99) and (Dano > MAX_CRITICAL_DAMAGE99) then
                Dano := MAX_CRITICAL_DAMAGE99;
        end;


      end;

       Double:
      begin
        Dano := Dano * 2; // Ativa o dano duplo
      end;


     DoubleCritical:
      begin
        // Verifica se a habilidade usada tem índice 0 (Skill.Index)
        if SkillData[Skill].Index <> 0 then
        begin
          // Se NÃO for a skill de índice 0, sair sem aplicar o duplo crítico
          DmgType := TDamageType.Normal; // Ou Double / Critical, conforme sua lógica
          Exit;
        end;

        // A partir daqui, sabemos que a habilidade é a correta (índice 0)

        Dano := Dano * 2;
        OnePercentOfTheDamage := Dano div 100;
        Dano := Trunc(Dano * 2.1);

        Helper := Self.PlayerCharacter.DamageCritical - mob^.PlayerCharacter.ResDamageCritical;

        if Helper < 0 then
        begin
          Helper := -Helper;
          DecInt(Dano, OnePercentOfTheDamage * Helper);
        end
        else
        begin
          Inc(Dano, OnePercentOfTheDamage * Helper);
        end;

        // Aplica limite máximo de dano crítico se o alvo for jogador
        if mob.IsPlayer then
        begin
          if (Self.Character.Level = 85) and (Dano > MAX_CRITICAL_DAMAGE2) then
            Dano := MAX_CRITICAL_DAMAGE
          else if (Self.Character.Level = 95) and (Dano > MAX_CRITICAL_DAMAGE952) then
            Dano := MAX_CRITICAL_DAMAGE95
          else if (Self.Character.Level = 99) and (Dano > MAX_CRITICAL_DAMAGE992) then
            Dano := MAX_CRITICAL_DAMAGE99;

          // Mensagem para quem causou o dano
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
            ('Você causou um dano de DUPLO CRÍTICO!'));

          // Mensagem para quem recebeu o dano
          if mob.IsPlayer then
          begin
            Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage(
              ('Você recebeu um dano de DUPLO CRÍTICO!'));
          end;
        end;
      end;

         end;

    { Critical:
      begin
        OnePercentOfTheDamage := Dano div 100;

        // Obter os valores de CurrentScore.Critical e CritRes
        var CriticalValue := Self.PlayerCharacter.Base.CurrentScore.Critical;
        var CritResValue := mob^.PlayerCharacter.CritRes;

        // Cálculo da diferença percentual entre os valores
        var Difference := CriticalValue - CritResValue;
        var PercentageDifference: Single;

        if (CriticalValue > 0) or (CritResValue > 0) then
          PercentageDifference := (Difference / Max(CriticalValue, CritResValue)) * 100
        else
          PercentageDifference := 0;

        // Determinar a chance de crítico com base na diferença percentual
        var CriticalChance: Integer;
        if Abs(PercentageDifference) < 5 then
          CriticalChance := 0
        else if Abs(PercentageDifference) <= 5 then
          CriticalChance := 10
        else if Abs(PercentageDifference) <= 10 then
          CriticalChance := 15
        else if Abs(PercentageDifference) <= 20 then
          CriticalChance := 25
        else if Abs(PercentageDifference) >= 50 then
          CriticalChance := 50;

        // Limitar a chance para 0% a 100%
        if CriticalChance > 100 then
          CriticalChance := 100
        else if CriticalChance < 0 then
          CriticalChance := 0;

        // Decidir se o crítico ocorre
        Randomize;
        if RandomRange(1, 101) <= CriticalChance then
        begin
          // Crítico ocorre
          Dano := Trunc(Dano * 1.1); // Modificador do dano crítico
          var DamageCritical := Self.PlayerCharacter.DamageCritical; // Ajuste baseado no dano crítico específico
          DamageCritical := DamageCritical - mob^.PlayerCharacter.ResDamageCritical; // Redução pela resistência ao dano crítico
          if (DamageCritical < 0) then
          begin
            DamageCritical := DamageCritical * (-1);
            DecInt(Dano, (OnePercentOfTheDamage * DamageCritical)); // Reduz o dano crítico
          end
          else
          begin
            Inc(Dano, (OnePercentOfTheDamage * DamageCritical)); // Aumenta o dano crítico
          end;

          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Ataque Crítico! Dano: ' + Dano.ToString);
        end
        else
        begin
          // Crítico não ocorre
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Ataque Normal! Chance de Crítico: ' + CriticalChance.ToString + '%');
        end;
      end; }







  if (mob^.GetMobAbility(EF_TYPE45) > 0) then
  begin // raio solar da santa da 10% a mais de dano em cima da vitima
    Inc(Dano, ((Dano div 100) * 10));

  end;

  if (mob^.BuffExistsByIndex(432)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Help1.ToString + ' pontos de ataque.');
      DecInt(Dano, Help1);
      mob^.RemoveBuffByIndex(432);
    end;
  end;
  if (mob^.BuffExistsByIndex(123)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Help1.ToString + ' pontos de ataque.');
      DecInt(Dano, Help1);
      mob^.RemoveBuffByIndex(123);
    end;
  end;

  // Adicione aqui a verificação para limitar o dano em mobs:
  if not mob^.IsPlayer then // Verifica se o alvo NÃO é um player (ou seja, é um mob)
  begin
    // Aplicar limite de dano apenas para mobs
    if Dano > DAMO_MAX_MOB then
      Dano := DAMO_MAX_MOB;
  end;




  if (mob^.BuffExistsByIndex(131)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Help1.ToString + ' pontos de ataque.');
      DecInt(Dano, Help1);
      mob^.RemoveBuffByIndex(131);
    end;
  end;
  if (mob^.BuffExistsByIndex(142)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB2);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB2, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Help1.ToString + ' pontos de ataque.');
      DecInt(Dano, Help1);
      mob^.RemoveBuffByIndex(142);
    end;
  end;
  if (mob^.Polimorfed) then
  begin
    DmgType := TDamageType.DoubleCritical;
    mob^.Polimorfed := False;
    if (mob^.ClientID <= MAX_CONNECTIONS) then
    begin
      mob^.RemoveBuffByIndex(99);
      mob^.SendCreateMob(SPAWN_NORMAL);
    end;
  end;
  if(Self.GetMobAbility(EF_DRAIN_HP) > 0) then
  begin
    HpPerc := Self.GetMobAbility(EF_DRAIN_HP);
    Self.AddHP(((Dano div 100) * HpPerc), True);
  end;
  if(Self.GetMobAbility(EF_DRAIN_MP) > 0) then
  begin
    MpPerc := Self.GetMobAbility(EF_DRAIN_MP);
    Self.AddMP(((Dano div 100) * MpPerc), True);
  end;
  if (Self.GetMobAbility(EF_HP_ATK_RES) > 0) then
  begin
    HpPerc := Self.GetMobAbility(EF_HP_ATK_RES);
    Self.AddHP(((Dano div 100) * HpPerc), True);
  end;

  {if (Self.BuffExistsByIndex(5)) then
  begin
    Help1 := SkillData[Skill].EFV[2];
    Self.AddHP(((Dano div 100) * Help1), True);
  end;

  if (mob^.GetMobAbility(EF_MP_EFFICIENCY) > 0) then
  begin
    Help1 := ((Dano div 200) * mob^.GetMobAbility(EF_MP_EFFICIENCY));
    // 50% do dano reduzido pelo escudo negro
  end; }

     // escudo nego mago
     if (mob^.BuffExistsByIndex(101)) then
    begin
      var DanoMitigado: Integer;
      var ConsumoMana: Integer;
      var EscudoMP: Integer;
      var PercentualMana: Integer;

      // Obtém a mana atual do personagem
      EscudoMP := mob^.Character.CurrentScore.CurMP;

      // Calcula o dano mitigado (60% do dano total)
      DanoMitigado := (Dano * 60) div 100;

      // Define o percentual de consumo de MP com base no nível do personagem
      if (mob^.Character.Level <= 85) then
        PercentualMana := 60
      else if (mob^.Character.Level <= 90) then
        PercentualMana := 65
      else if (mob^.Character.Level <= 95) then
        PercentualMana := 70
      else if (mob^.Character.Level <= 98) then
        PercentualMana := 75
      else // Nível 99
        PercentualMana := 90;

      // Calcula o consumo de mana baseado no percentual do dano mitigado
      ConsumoMana := (DanoMitigado * PercentualMana) div 100;

      // Verifica se a mana é suficiente para sustentar o escudo
      if (ConsumoMana > EscudoMP) then
      begin
            mob^.RemoveBuffByIndex(101); // Remove o escudo pois a mana acabou
            // Envia mensagem para o jogador que perdeu o escudo
        Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage(
          '[' + AnsiString(mob^.Character.Name) + '] teve seu escudo mágico destruído!',
          16, 1, 1);

        // Envia mensagem para o atacante informando que quebrou o escudo
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
          'Você destruiu o escudo mágico de [' + AnsiString(mob^.Character.Name) + ']!',
          16, 1, 1);
      end
      else
      begin
        mob^.RemoveMP(ConsumoMana, True); // Remove a quantidade proporcional de MP ao dano mitigado
        Dano := 0; // O HP não sofre dano enquanto a mana for suficiente

        // Envia mensagem ao jogador no formato correto
        Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage(
          '[' + AnsiString(mob^.Character.Name) + '] absorveu ' +
          IntToStr(DanoMitigado) + ' de dano com o escudo mágico.', 16, 1, 1);
      end;
    end;





  if (mob.BuffExistsByIndex(111)) then
  begin // nevoa fc
    mob.RemoveBuffByIndex(111);
  end;

  //  dano choque da dual

    begin
      if (mob.BuffExistsByIndex(86)) then
      begin
        // Definir o aumento do dano baseado no nível do atacante
        if (Self.Character.Level < 85) then
          DanoExtra := 110  // +10%
        else if (Self.Character.Level < 90) then
          DanoExtra := 115  // +15%
        else if (Self.Character.Level < 95) then
          DanoExtra := 120  // +20%
        else if (Self.Character.Level < 98) then
          DanoExtra := 125  // +25%
        else
          DanoExtra := 130; // +30% (nível 99)

        // Multiplica o dano pelo percentual definido
        if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
          Dano := (Dano * DanoExtra) div 100; // Aplica o multiplicador de percentual
        end;

        // Remove o buff de choque após aplicar o dano
        mob.RemoveBuffByIndex(86);
      end;
    end;


  if (mob.BuffExistsByIndex(63)) then
  begin // choque att
    mob.RemoveBuffByIndex(63);
  end;
  if (mob.BuffExistsByIndex(153)) then
  begin // predador
    mob.RemoveBuffByIndex(153);
  end;

  if (mob^.ClientID <= MAX_CONNECTIONS) then
  begin

    if ((mob^.Character.Nation <> Self.Character.Nation) and
      (mob^.Character.Nation > 0) and (Self.Character.Nation > 0)) then
    begin
      Inc(Dano, Self.PlayerCharacter.PvPDamage);
      DecInt(Dano, mob.PlayerCharacter.PvPDefense);

      if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
        Inc(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_ATK_NATION] *
          (Dano div 100));
      Helper := Dano;

      {Inc(Dano, ((Helper div 100) * Self.GetMobAbility(EF_MARSHAL_ATK_NATION)));
      Helper := Dano;
      DecInt(Dano, ((Helper div 100) * mob.GetMobAbility(EF_MARSHAL_DEF_NATION))); }

      if(Servers[Self.ChannelId].NationID = mob.Character.Nation) then
        DecInt(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_DEF_NATION]
          * (Dano div 100));
      end;
    if(Self.IsSecureArea) then
    begin
      DmgType := None;
      Dano := 0;
      MobAnimation := 0;
      Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
        ('Voc� est� em uma �rea segura, n�o pode lan�ar skills.');
      Exit;
    end;
    if(mob^.IsSecureArea) then
    begin
      DmgType := None;
      Dano := 0;
      MobAnimation := 0;
      Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
        ('O alvo est� dentro de uma �rea segura e n�o foi afetado pela sua habilidade.');
      Exit;
    end;
  end
  else
  begin
    if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      Inc(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_ATK_MONSTER] *
        (Dano div 100));
  end;
  HelperInByte := 0;
  if (Self.IsCompleteEffect5(HelperInByte)) then
  begin
    Randomize;
    Help1 := RandomRange(1, 101);
    if (Help1 <= (RATE_EFFECT5*Length(Self.EFF_5))) then
    begin
      Self.Effect5Skill(mob, HelperInByte);
    end;
  end;
  if (Self.GetMobAbility(EF_DECREASE_PER_DAMAGE1) > 0) then
  begin
    DecInt(Dano,
      ((Dano div 100) * Self.GetMobAbility(EF_DECREASE_PER_DAMAGE1)));
  end;
  if (mob^.GetMobAbility(EF_HP_CONVERSION) > 0) then
  begin
    DecInt(Dano, ((Dano div 100) * mob^.GetMobAbility(EF_HP_CONVERSION)));
  end;
  if (mob^.BuffExistsByIndex(337)) then
  begin
    if not ((SkillData[Skill].Index = 8) or (SkillData[Skill].Index = 90) or
        mob^.BuffExistsByIndex(8) or mob^.BuffExistsByIndex(90)) then
    begin // 75
      AddBuff := False; // Impedir adicionar o buff se não for 8 ou 90
       Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu à sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu à habilidade de ataque de [' +
        AnsiString(Self.Character.Name) + ']', 16, 1, 1);
    end;
  end;

  if (mob^.BuffExistsByIndex(38)) then
  begin
    Help1 := mob^.GetMobAbility(EF_REFLECTION2);
    Self.RemoveHP(((Dano div 100) * 40), True, True);
    //DecInt(Dano, (Dano div 100) * Help1);
   // mob^.RemoveBuffByIndex(38);
    Dano := 0;
    DmgType := TDamageType.None;
  end;
  if (Dano > 0) then
  begin
    Helper := mob^.GetMobAbility(EF_REFLECTION1);
    if (Helper > 0) then
    begin
      Self.RemoveHP(Helper, False, True);
      Self.SendCurrentHPMP(True);
    end;
    if (mob^.BuffExistsByIndex(222)) then
    begin
      Helper := mob^.GetMobAbility(EF_SKILL_ABSORB1);
      if (Helper > 0) then
      begin
        if (Dano >= Helper) then
        begin
          mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Helper);
          mob^.RemoveBuffByIndex(222);
        end
        else
          mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
        DecInt(Dano, Helper);
      end;
    end;
  end;
  if (mob^.BuffExistsByIndex(32)) then
  begin
    Dec(Dano, ((Dano div 100) * mob.GetMobAbility(EF_POINT_DEFENCE)));
    dec(mob^.DefesaPoints, 1);
    if (mob^.DefesaPoints = 0) then
      mob^.RemoveBuffByIndex(32);
  end;
  if(mob^.BuffExistsByIndex(35) and (Trim(mob.UniaoDivina) <> '')) then
  begin
    Helper := Dano;
    DecInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_TRANSFER)));
    DecInt(Helper, Dano);
    OtherPlayer := Servers[Self.ChannelId].GetPlayer(mob.UniaoDivina);
    BoolHelp := False;
    if(OtherPlayer <> nil) then
    begin
      if (not(OtherPlayer.Base.IsDead) and (OtherPlayer.Status >= Playing) and
      not(OtherPlayer.SocketClosed)) then
      begin
        OtherPlayer.Base.RemoveHP(Helper, True, True);
        OtherPlayer.Base.LastReceivedAttack := Now;
        OtherPlayer.SendClientMessage('Seu HP foi consumido em ' + Helper.ToString +
        ' pontos pelo buff [Uni�o Divina] no membro <' +
        AnsiString(mob.Character.Name) + '>.', 16);
      end
      else
      begin
        mob.RemoveBuffByIndex(35);
        mob.UniaoDivina := '';
        BoolHelp := True;
      end;
    end;
    if not(BoolHelp) then
    begin
      DecInt(mob.MOB_EF[EF_TRANSFER_LIMIT], Helper);
      if(mob.MOB_EF[EF_TRANSFER_LIMIT] = 0) then
      begin
        mob.RemoveBuffByIndex(35);
        mob.UniaoDivina := '';
      end;
    end;
  end;


    // Dano recebido na Bolha da templaria
 if ((mob^.BuffExistsByIndex(36) = True) and not (DataSkill^.Index = 0)) then
 //if (mob^.BuffExistsByIndex(36)) then
    begin

    // Verifica se há algum BuffIndex entre 1 e 500 ativo e reduz a bolha
     var i: Integer;

         // Bloqueia a aplicação do debuff enquanto a bolha estiver ativa
      Dano := 0;
      DmgType := TDamageType.None;
      AddBuff := False;

    for i := 1 to 700 do
    begin
      if mob^.BuffExistsByIndex(i) then
      begin
        dec(mob^.BolhaPoints, 1);
        Break; // Sai do loop ao encontrar o primeiro buff ativo
      end;
    end;



   // Verifica se o buff de índice 80 está ativo
    if (mob^.BuffExistsByIndex(80)) then
        dec(mob^.BolhaPoints, 5) // Remove 5 pontos se o buff 80 existir

   else

        // Verifica se o buff de índice 80 está ativo
    if (mob^.BuffExistsByIndex(108)) then
        dec(mob^.BolhaPoints, 4) // Remove 5 pontos se o buff 80 existir


   else



  // Se a habilidade usada for Index 136, reduz a bolha com o dano da skill
  if (DataSkill^.Index = 136) then
  begin
    dec(mob^.BolhaPoints, DataSkill^.Damage);
  end;

  // Caso não se encaixe em nenhuma das condições acima, reduz 1 ponto da bolha
  if (mob^.BolhaPoints > 0) then
  begin
    Dano := 0;
    DmgType := TDamageType.None;
    AddBuff := False;
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('[' + AnsiString(mob.Character.Name) + '] resistiu a sua habilidade de ataque.', 16, 1, 1);
    Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
      ('Você resistiu ao ataque de [' + AnsiString(Self.Character.Name) + '] restam ' +
      mob.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
  end
  else
  begin
    // Se a bolha atingir 0 pontos, remove o buff e zera o dano
    mob^.RemoveBuffByIndex(36);
    Dano := 0;
    DmgType := TDamageType.None;
    AddBuff := False;
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('[' + AnsiString(mob.Character.Name) + '] resistiu a sua habilidade de ataque.', 16, 1, 1);
    Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
      ('Você resistiu ao ataque de [' + AnsiString(Self.Character.Name) + '] Proteção desativada.', 16, 1, 1);
  end;
 end;


    // Impedimento: Se o oponente estiver sob o buff 103, ele recebe dano adicional baseado no nível
  if (mob.BuffExistsByIndex(103)) then
  begin
    var PercentualDano: Single;

    // Define o percentual de dano adicional com base no nível do oponente
   if (Self.Character.Level <= 85) then
    PercentualDano := 1.05 // +5%
  else if (Self.Character.Level <= 90) then
    PercentualDano := 1.07 // +7%
  else if (Self.Character.Level <= 95) then
    PercentualDano := 1.10 // +10%
  else if (Self.Character.Level <= 98) then
    PercentualDano := 1.12 // +12%
  else // Nível 99
    PercentualDano := 1.15; // +15%

    // Aplica o aumento de dano
    dano := Round(dano * PercentualDano)  ;
  end;


  // efeito sobre a bruma

  if (self.BuffExistsByIndex(111)) then
  begin

       begin
      // Zera a resistência à taxa crítica do jogador
      self.PlayerCharacter.CritRes := 0;
      self.GetCurrentScore;  // Recalcula os pontos de status desconsiderando o buff removido
      self.SendRefreshPoint; // Envia os pontos atualizados ao servidor
    end;

  end;

  // efeito trovão ruinoso

  if (self.BuffExistsByIndex(434)) then
  begin

       begin
      // Zera a resistência à taxa crítica do jogador
      self.PlayerCharacter.CritRes := 0;
      self.PlayerCharacter.ResDamageCritical := 0;
      self.GetCurrentScore;  // Recalcula os pontos de status desconsiderando o buff removido
      self.SendRefreshPoint; // Envia os pontos atualizados ao servidor
    end;

  end;




    // choque subito

    if (mob.BuffExistsByIndex(86)) then
    begin

       // Multiplica o dano por 2
      if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
         Dano := Dano * 10;  // Dano é multiplicado por 2
        end;


    end;






    // REACAO_CADEIA:
   { if (mob.BuffExistsByIndex(410)) then
        begin
        // Verifica se a classe do atacante é 32 ou 33 antes de aplicar o bônus
        if (Self.Character.ClassInfo = 32) or (Self.Character.ClassInfo= 33) then
        begin
          // verifica o dano
          if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
          begin
            begin
              Dano := (Dano * 110) div 100; // Aumenta 10% do dano total
            end;
          end;
        end;
      end;}




    // dor do predado
      var
    BonusHP: Integer;

    if (Self.Character.ClassInfo = 32) or (Self.Character.ClassInfo= 33) then
      begin
      if (mob.BuffExistsByIndex(408)) then
      begin

         if (mob.ClientID <= MAX_CONNECTIONS) then
        begin
          if (Dano >= mob.Character.CurrentScore.CurHP) then
          begin
            // Aumenta a recuperação de HP ao matar o inimigo
            Inc(Self.Character.CurrentScore.CurHP, ((Self.Character.CurrentScore.MaxHP div 100) * 100));
          end;
        end;

              begin
          // Define o percentual desejado (por exemplo, 10%)
          BonusHP := (Self.Character.CurrentScore.MaxHP * 5) div 100;

          // Aumenta o HP atual com base no percentual calculado
          Inc(Self.Character.CurrentScore.CurHP, BonusHP);
        end;

        Self.SendCurrentHPMP(True);


      end;
    end;




    // Verifica se o BuffIndex 365 está ativo no jogador   bola da templaria


  if ((mob^.BuffExistsByIndex(365) = True) and not(DataSkill^.Index = 0)) then
  begin

  // Verifica se há algum BuffIndex entre 1 e 500 ativo e reduz a bolha
    var i: Integer;
    for i := 1 to 700 do
    begin
      if mob^.BuffExistsByIndex(i) then
      begin
        dec(mob^.BolhaPoints, 1);
        Break; // Sai do loop ao encontrar o primeiro buff ativo
      end;
    end;



   // Verifica se o buff de índice 80 está ativo
    if (mob^.BuffExistsByIndex(80)) then
        dec(mob^.BolhaPoints, 5) // Remove 5 pontos se o buff 80 existir

    else
    if(DataSkill^.Index = 136) then
    begin
      dec(mob^.BolhaPoints, DataSkill^.Damage);
    end
    else
      dec(mob^.BolhaPoints, 1);

    if (mob^.BolhaPoints = 0) then
    begin
      mob^.RemoveBuffByIndex(365);
      Dano := 0;
      DmgType := TDamageType.None;
      AddBuff := False;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu a sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Voce resistiu ao de ataque de [' +
        AnsiString(Self.Character.Name) + '] Proteção desativada.', 16, 1, 1);
    end
    else
    begin
      Dano := 0;
      DmgType := TDamageType.None;
      AddBuff := False;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu a sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Voc� resistiu ao ataque de [' +
        AnsiString(Self.Character.Name) + '] restam ' +
        mob.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
    end;
  end;


  if not(Dano = 0) and not(mob^.ClientID >= 3048) then
  begin
    if (mob^.BuffExistsByIndex(460)) then
    begin
      if (Dano > mob^.Character.CurrentScore.CurHP) then
      begin
        mob^.RemoveBuffByIndex(460);
        mob^.RemoveAllDebuffs;
        mob^.ResolutoPoints := 0;
        mob^.Character.CurrentScore.CurHP :=
          ((mob^.Character.CurrentScore.MaxHP div 100) * 50);
        mob^.Character.CurrentScore.CurMP :=
          ((mob^.Character.CurrentScore.MaxMP div 100) * 45);
        mob^.SendCurrentHPMP(True);
        mob^.addbuff(5121);

        Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
          ('Você foi revivido graças ao buff [Pedra da Alma].');
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('O seu alvo foi revivido graças ao buff [Pedra da Alma].');
      end;
    end;
  end;

  if (mob.BuffExistsByIndex(154)) then
  begin // Veneno Hidra
    mob.Chocado := False
  end;

  if(mob^.GetMobAbility(EF_ADD_DAMAGE1) > 0) then

  begin //requiem
    Inc(Dano, (mob^.GetMobAbility(EF_ADD_DAMAGE1)*2));
  end;

  if (mob^.BuffExistsByIndex(90)) then
  begin // Estripador de Dual
    if ((DmgType = Critical) or (DmgType = DoubleCritical)) then
    begin
      // Verifica se o dano aplicado é menor ou igual a 300000
     // if (Dano <= 300000) then
        mob.AddBuff(6367);
    end;
  end;

   // remove o inv da acção imediata e festival de balas
  if (Self.ValidAttack(DmgType)) then
  begin
    if (mob.BuffExistsByIndex(24)) then
    begin
      // Remove o buff 7354 caso o buff 24 esteja ativo no alvo
     // Self.RemoveBuff(7354);
    end;

    // Remove o buff 7354 caso o jogador cause qualquer dano
    if (Dano > 0) then
    begin
      //Self.RemoveBuff(7354);
    end;
  end;




  // resoluto points

  if (mob^.ResolutoPoints > 0) then
  begin
    // Impede que continue se o mob tiver a bolha ativa (buff 36)
    if (mob^.BuffExistsByIndex(36)) and (mob^.BuffExistsByIndex(136))then
    Exit;

     if (SecondsBetween(Now, mob^.ResolutoTime) >= 8) then
    begin
      mob^.ResolutoPoints := 0;
    end
    else if (AddBuff) then
    begin
      dec(mob^.ResolutoPoints, 1);
      MobAnimation := 26;
      Self.TargetBuffSkill(6879, 0, mob, @SkillData[6879]);
      if(mob.Mobid = 0) then
      begin
        Randomize;
        Helper := RandomRange(1, -2);
        if(Helper = 0) then
          Self.WalkBacked(TPosition.create(mob.PlayerCharacter.LastPos.X-1,
            mob.PlayerCharacter.LastPos.Y+1) , 209, mob)
        else
          Self.WalkBacked(TPosition.create(mob.PlayerCharacter.LastPos.X+Helper,
            mob.PlayerCharacter.LastPos.Y+Helper) , 209, mob);
      end;
    end;
  end;
  {if (mob^.BuffExistsByIndex(134)) then
    if (mob^.Character.CurrentScore.CurHP <
      (mob^.Character.CurrentScore.MaxHP div 2)) then
    begin
      //Helper := mob.GetBuffIDByIndex(134);
      //mob.AddHP(mob.CalcCure2(SkillData[Helper].EFV[0], mob, Helper), True);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Cura preventiva entrou em a��o e feiti�o foi desfeito.', 0);
      mob^.RemoveBuffByIndex(134);
    end;}

  if(Self.GetMobClass() = 4) then
  begin
    if(DataSkill.Adicional > 0) then
    begin
      if((mob.GetMobAbility(EF_ACCELERATION1) > 0) or
        (mob.GetMobAbility(EF_ACCELERATION2) > 0) or
        (mob.GetMobAbility(EF_ACCELERATION3) > 0)) then
      begin
        Dano := Dano + DataSkill.Adicional;
      end;
    end;
  end;

  if((mob.ClientID >= 3048) and (mob.ClientID <= 9147)) then
  begin
    if(Self.GetMobAbility(EF_ATK_MONSTER) > 0) then
    begin
      Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_MONSTER)));
    end;
    if(mob.GetMobAbility(197) > 0) then
    begin
      if(Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
      begin
        Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
      end;

      if(Self.GetMobAbility(EF_ATK_DEMON) > 0) then
      begin
        Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
      end;
    end;
    if(Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType >= 1024) then
    begin
      case (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType-1024) of
        0: //humanoide
          begin
            if(Self.GetMobAbility(EF_ATK_ALIEN) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_ALIEN)));
            end;
          end;

        1: //animal
          begin
            if(Self.GetMobAbility(EF_ATK_BEAST) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_BEAST)));
            end;
          end;

        2: //plantas
          begin
            if(Self.GetMobAbility(EF_ATK_PLANT) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_PLANT)));
            end;
          end;

        3: //inseto
          begin
            if(Self.GetMobAbility(EF_ATK_INSECT) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_INSECT)));
            end;
          end;

        4: //demonio
          begin
            if(Self.GetMobAbility(EF_ATK_DEMON) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
            end;
          end;

        5: //morto vivo
          begin
            if(Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
            end;
          end;

        6: //misto
          begin
            if(Self.GetMobAbility(EF_ATK_COMPLEX) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_COMPLEX)));
            end;
          end;

        7: //estrutura
          begin
            if(Self.GetMobAbility(EF_ATK_STRUCTURE) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_STRUCTURE)));
            end;
          end;

        else
          begin
            if(Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
            end;

            if(Self.GetMobAbility(EF_ATK_DEMON) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
            end;
          end;
      end;
    end;
    {else
    begin
      case (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType) of
        0: //humanoide
          begin
            if(Self.GetMobAbility(EF_ATK_ALIEN) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_ALIEN)));
            end;
          end;

        1: //animal
          begin
            if(Self.GetMobAbility(EF_ATK_BEAST) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_BEAST)));
            end;
          end;

        2: //plantas
          begin
            if(Self.GetMobAbility(EF_ATK_PLANT) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_PLANT)));
            end;
          end;

        3: //inseto
          begin
            if(Self.GetMobAbility(EF_ATK_INSECT) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_INSECT)));
            end;
          end;

        4: //demonio
          begin
            if(Self.GetMobAbility(EF_ATK_DEMON) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
            end;
          end;

        5: //morto vivo
          begin
            if(Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
            end;
          end;

        6: //misto
          begin
            if(Self.GetMobAbility(EF_ATK_COMPLEX) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_COMPLEX)));
            end;
          end;

        7: //estrutura
          begin
            if(Self.GetMobAbility(EF_ATK_STRUCTURE) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_STRUCTURE)));
            end;
          end;

        else
          begin
            if(Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
            end
            else if(Self.GetMobAbility(EF_ATK_DEMON) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
            end;
          end;
      end;
    end; }
  end;



      // Agora aplicamos os modificadores de Marechal
      Helper := Dano; // Salva o dano final antes de aplicar os modificadores de Marechal

      Inc(Dano, ((Helper div 100) * Self.GetMobAbility(EF_MARSHAL_ATK_NATION))); // Bônus de ataque Marechal
      Helper := Dano; // Atualiza o Helper para garantir que a defesa seja aplicada corretamente


      DecInt(Dano, ((Helper div 100) * mob.GetMobAbility(EF_MARSHAL_DEF_NATION))); // Redução de defesa Marechal


      // limite de dano nos mobs
      if (Dano > DAMO_MAX_MOB) then
    Dano := DAMO_MAX_MOB; // Limita o dano máximo para mobs





      // Se o player possuir a habilidade 517, o dano será multiplicado por 100
       { if Self.GetMobAbility(517) = 517 then
          Dano := Dano * 100;}

      //if (MobT^.IntName = 145)  then

      // Limite de Dano boss DG
  {  if (MobT^.IntName = 145) or (mob^.MobId = 97) or (mob^.MobId = 281) or (mob^.MobId = 108) or (mob.Mobid = 357)
     then
    begin
      Dano := ((Dano * DANO_BOSS) div 100) - 50000 ; // Aplica uma redução de 50% ao dano
    end; }


     // Limite de Dano Mobs DG
   { if (mob.Mobid = 339) or (mob.Mobid = 338) or (mob.Mobid = 58) or (mob.Mobid = 82) or (mob.Mobid = 329)
      or (mob.Mobid = 20) or (mob.Mobid = 83) or (mob.Mobid = 316)  or (mob.Mobid = 315) then
    begin
      Dano := ((Dano * DANO_MOBS_DG) div 100) - 2000 ; // Aplica uma redução de 50% ao dano
    end;}


     // Limite de Dano Mobs Boss Mapas
    {if  (mob.Mobid = 332)  or (mob.Mobid = 115) then
    begin
      Dano := ((Dano * DANO_MOBS_MP) div 100) - 95500 ; // Aplica uma redução de 50% ao dano
    end;  }

      // if(Dano > 400000) then
    //Dano := 1;
    var
     ClassDamageMultiplier: Single;
  begin
      // Definir multiplicador de dano baseado na classe do jogador
      case Self.GetMobClass() of
        0: ClassDamageMultiplier := WAR_ATACK_SKILL;   // Guerreiro (dano normal)
        1: ClassDamageMultiplier := TP_ATACK_SKILL;   // Templário (10% a mais de dano)
        2: ClassDamageMultiplier := ATT_ATACK_SKILL;   // Atirador/Arqueiro (20% a mais de dano)
        3: ClassDamageMultiplier := DUAL_ATACK_SKILL;   // Dual/Assassino (30% a mais de dano)
        4: ClassDamageMultiplier := FC_ATACK_SKILL;   // Feiticeiro/Mago (40% a mais de dano)
        5: ClassDamageMultiplier := SANTA_ATACK_SKILL;  // Santa/Suporte (15% a mais de dano)
      else
       // ClassDamageMultiplier := 1.0; // Caso padrão (nenhuma mudança)
      end;

      // Aplicar o multiplicador de dano antes da verificação final
      Dano := Trunc(Dano * ClassDamageMultiplier);



      var
      MaxCriticalDanoPorNivel:integer;

      // **GARANTIR QUE O DANO FINAL SEJA LIMITADO APENAS NO MOMENTO DA APLICAÇÃO**
     { if (mob.IsPlayer) and ((DmgType = Critical) or (DmgType = DoubleCritical)) then
      begin
        // Determinar o limite de dano crítico baseado no nível do jogador

        if (Self.Character.Level >= 0 ) and (Self.Character.Level <= 85) then
          MaxCriticalDanoPorNivel := MAX_CRITICAL_DAMAGE // Mantém o valor atual para nível 85 ou inferior
        else
        if (Self.Character.Level >= 95) and (Self.Character.Level <= 99) then
          MaxCriticalDanoPorNivel := MAX_CRITICAL_DAMAGE99 // Mantém o valor atual para nível 85 ou inferior
        else
        if (Self.Character.Level >= 96) and (Self.Character.Level <= 95) then
          MaxCriticalDanoPorNivel := MAX_CRITICAL_DAMAGE95
        else
          MaxCriticalDanoPorNivel := 160000; // Jogadores nível 99 podem ter no máximo 1.100.000

        // Aplicar o limitador de dano crítico baseado no nível
        if (Dano > MaxCriticalDanoPorNivel) then
          Dano := MaxCriticalDanoPorNivel;
      end
      else
       begin
        // Se o alvo não for um jogador, o dano pode ser tratado de forma diferente ou ignorado
        // Exemplo: Limitar o dano apenas para mobs
        if (Dano > DAMO_MAX_MOB) then
          Dano := DAMO_MAX_MOB; // Limita o dano máximo para mobs
      end;  }



    // Verifica se a nação do jogador é 1, 2 ou 3
    if (Self.Character.Nation in [1, 2, 3]) then
       begin
      // Verifica se o alvo é um jogador (não um mob)
        if (mob^.IsPlayer) then
        begin
          // Se for jogador, verifica os limites de dano de acordo com o nível
          if (Self.Character.Level >= 85) and (Self.Character.Level <= 95) and (Dano > DAMO_MAX_PCP) then
          begin
            // Aplica um valor aleatório dentro do intervalo [MIN_DANO_LVL85, DAMO_MAX_PCP]
            Dano := RandomRange(MINP_DANO_LVL85, DAMO_MAX_PCP + 1);
          end
          else if (Self.Character.Level >= 96) and (Self.Character.Level <= 98) and (Dano > DANOMAXIMO_LVL95) then
          begin
            // Aplica um valor aleatório dentro do intervalo [MIN_DANO_LVL96, DANOMAXIMO_LVL95]
            Dano := RandomRange(MINP_DANO_LVL96, DANOMAXIMO_LVL95 + 1);
          end
          else if (Self.Character.Level >= 98) and (Self.Character.Level <= 99) and (Dano > DANOMAXIMO_LVL99) then
          begin
            // Aplica um valor aleatório dentro do intervalo [MIN_DANO_LVL98, DANOMAXIMO_LVL99]
            Dano := RandomRange(MINP_DANO_LVL98, DANOMAXIMO_LVL99 + 1);
          end;
        end
        else
          if (mob^.IsPlayer) then
          begin
            if (Self.Character.Nation = 4) then
            begin
              // Nação 4: Não respeita nenhum limitador
              WriteLn('Nação ID 4 detectada. Limitadores de dano ignorados.');
            end;
          end

          else

          begin
            // Tratamento especial para ataques de mobs
            if mob^.IsPlayer then
            begin
             Dano := DAMO_MAX_MOB; // Limita o dano máximo para mobs
              end ;

          end;

        // Aplica os efeitos das relíquias antes da verificação do limite
        Inc(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_ATK_NATION] *
          (Dano div 100));



        // Garante que o dano nunca seja negativo ou menor que 1
        if (Dano < 1) then
          Dano := 0;

        // Verifica se quem está atacando é um jogador
          if Self.IsPlayer then
          begin
            // Verificação para enviar mensagens ou desconectar o jogador
            if (Dano >= DANODISCONECT1) and (Dano < DANODISCONECT2) then
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('Atenção! Você causou um dano muito alto.');
            end
            else if (Dano >= DANODISCONECT2) and (Dano < DANODISCONECT3) then
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('Alerta! Dano extremamente alto.');
            end
            else if (Dano >= DANODISCONECT1 +1) then
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('Você foi desconectado por aplicar dano excessivo.');
              Servers[Self.ChannelId].Players[Self.ClientID].Disconnect;
            end;
          end;

      end;

    end;




      // Ajuste com verificação do buff 6600 para a nação 3
    {begin
      // Verifica se tanto o atacante (Self) quanto o alvo (mob) são jogadores
      if (Self.IsPlayer) and (mob.IsPlayer) then
      begin

        // Verifica se o buff 6600 está ativo no jogador da nação 3

        begin
          // Jogadores da nação 3 recebem 3x mais dano de jogadores das nações 1, 2 ou 4
          if (mob.Character.Nation = 3) and (Self.Character.Nation in [1, 2, 4]) then
          begin
            Dano := Dano * 1;
          end
          // Jogadores da nação 3 aplicam 2x menos dano em jogadores das nações 1, 2 ou 4
          else if (Self.Character.Nation = 3) and (mob.Character.Nation in [1, 2, 4]) then
          begin
            Dano := Dano div 3;
          end;
        end;
      end;
    end; }


   { if (mob.IsPlayer) then
    begin
      if (Dano > DANOMAXIMO) then
        Dano := DANOMAXIMO;

      // Se o dano for absurdamente alto, zere-o (proteção contra exploits)
      if (Dano > 900000000) then
        Dano := 0;
    end;

    // **GARANTIR QUE O DANO FINAL SEJA LIMITADO APENAS NO MOMENTO DA APLICAÇÃO**
  if (mob.IsPlayer) and ((DmgType = Critical) or (DmgType = DoubleCritical)) then
  begin
    if (Dano > MAX_CRITICAL_DAMAGE) then
      Dano := MAX_CRITICAL_DAMAGE;
  end;      }







    // Garantir que o dano não seja menor que 1
     if (Dano < 1) then
     Dano := 0;


     // **Divisão de dano para mobs de nível 301 a 310**
    if (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel >= 301) and
       (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel <= 310) then
    begin
      Dano := Dano div 4; // Reduz o dano
    end;


     // **Divisão de dano para mobs de nível 359 a 360**
    if (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel >= 359) and
       (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel <= 360) then
    begin
      Dano := Dano  div  4; // Reduz o dano
    end;


     // **Divisão de dano para mobs de nível 350 a 358**
    if (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel >= 350) and
       (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel <= 359) then
    begin
      Dano := Dano div 3; // Reduz o dano
    end;

    // **Divisão de dano para mobs de nível 350 a 358**
    if (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel >= 319) and
       (Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobLevel <= 320) then
    begin
      Dano := Dano div 2; // Reduz o dano
    end;


    //DANO GERAL DOS PLAYERS
    //Dano:= dano div DANOGERALPVP;

      // Verifica se o jogador tem o título específico antes de aplicar o dano  - titulo elter dano
    if (mob.PlayerCharacter.ActiveTitle.Index = 82) then
    begin

        begin
            // Aplica a redução de 50% no dano recebido
            Dano := Round(Dano * 0.90);

            // Opcional: Envia uma mensagem ao jogador informando sobre a redução
           // Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage(
             //   'Seu título especial reduziu o dano recebido em 50%.', 16, 1, 1);

        end;
    end;

     // Verifica se o jogador tem o título específico antes de aplicar o dano  - titulo elter tank
    if (mob.PlayerCharacter.ActiveTitle.Index = 84) then
    begin

          begin
          // Aplica a redução de 50% no dano recebido
          Dano := Round(Dano * 0.85);

          // Opcional: Envia uma mensagem ao jogador informando sobre a redução
         // Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage(
           //   'Seu título especial reduziu o dano recebido em 50%.', 16, 1, 1);
      end;
    end;





  //  Dano := Round(Dano * DANOGERALPVP); // Aplica o fator percentual e arredonda o resultado

    // Redução de dano para o buff 6600 (60% de redução, deixa 40% do dano)
    if (mob.BuffExistsByID(6600)) then
    begin
      Dano := Round(Dano * 0.5); // Deixa 50% do dano original
    end;

    // Redução de dano para o buff 6601 (10% de redução, deixa 90% do dano)
    if (mob.BuffExistsByID(6601)) then
    begin
      Dano := Round(Dano * 0.9); // Deixa 90% do dano original
    end;

    // Redução de dano para o buff 6602 (40% de redução, deixa 60% do dano)
    if (mob.BuffExistsByID(6602)) then
    begin
      Dano := Round(Dano * 0.6); // Deixa 60% do dano original
    end;

    // Redução de dano para o buff 7364 (20% de redução, deixa 80% do dano)
    if (mob.BuffExistsByID(7364)) then
    begin
      Dano := Round(Dano * 0.8); // Deixa 80% do dano original
    end;



    //DANO GERAL DOS PLAYERS
      Dano:= dano div DANOGERALPVP;

  // Garante que o dano NÃO ultrapasse 50% do HP atual do JOGADOR
  if mob^.IsPlayer then
  begin
    // Define o limite como 50% do HP atual do jogador
    var MaxDano := mob^.Character.CurrentScore.MaxHP div 2;

    // Se o dano for maior que o limite, ajusta
    if Dano > MaxDano then
      Dano := MaxDano;
  end;


  // AUMENTAR DANO EM MOBS (NÃO AFETA JOGADORES)
    if not mob^.IsPlayer then
    begin
      // Aumenta o dano em 50% apenas em mobs
      Dano := Trunc(Dano * DANOGERALMOB);
    end;






        // Verifica se o player tem o buff 9000 ativo e aplica a multiplicação APENAS NO FINAL
      if Self.BuffExistsByID(9000) then
      begin
        Dano := 999999999; // Multiplica o dano apenas no final, após todas as verificações
      end;













end;
procedure TBaseMob.AttackParseForMobs(Skill, Anim: DWORD; mob: PBaseMob; var Dano: Integer;
  var DmgType: TDamageType; out AddBuff: Boolean; out MobAnimation: Byte);
var
  HpPerc, MpPerc: Integer;
  Helper: Integer;
  HelperInByte: Byte;
  Help1: Integer;
  OtherPlayer: PPlayer;
  Mobid, mobpid: Integer;
begin

      // Continue com o processamento normal do dano
      if (mob.GetMobAbility(EF_AMP_PHYSICAL) > 0) then
      begin
        Inc(Dano, ((Dano div 100) * mob.GetMobAbility(EF_AMP_PHYSICAL)));
      end;

      if (mob.GetMobAbility(EF_TYPE45) > 0) then
      begin // raio solar da santa da 10% a mais de dano em cima da vitima
        Inc(Dano, ((Dano div 100) * 10));
      end;

      if ((mob.BuffExistsByIndex(432)) and (Dano > 0)) then
      begin
        Help1 := mob.GetMobAbility(EF_SKILL_ABSORB1);
        if (Help1 > Dano) then
        begin
          Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
           // ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
            ('Voc� absorveu o ataque  ');
          mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
          Dano := 0;
          DmgType := TDamageType.None;
        end
        else
        begin
          Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
            // ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
            ('Voc� absorveu o ataque  ');
          DecInt(Dano, Help1);
          mob.RemoveBuffByIndex(432);
        end;
      end;

      if ((mob.BuffExistsByIndex(123)) and (Dano > 0)) then
      begin
        Help1 := mob.GetMobAbility(EF_SKILL_ABSORB1);
        if (Help1 > Dano) then
        begin
          Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
            ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
          mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
          Dano := 0;
          DmgType := TDamageType.None;
        end
        else
        begin
          Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
          // ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
            ('Voc� absorveu o ataque  ');
          DecInt(Dano, Help1);
          mob.RemoveBuffByIndex(123);
        end;
      end;

      if ((mob.BuffExistsByIndex(131)) and (Dano > 0)) then
      begin
        Help1 := mob.GetMobAbility(EF_SKILL_ABSORB1);
        if (Help1 > Dano) then
        begin
          Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
           // ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
            ('Voc� absorveu o ataque  ');
          mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
          Dano := 0;
          DmgType := TDamageType.None;
        end
        else
        begin
          Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
           // ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
            ('Voc� absorveu o ataque  ');
          DecInt(Dano, Help1);
          mob.RemoveBuffByIndex(131);
        end;
      end;

      if ((mob.BuffExistsByIndex(142)) and (Dano > 0)) then
      begin
        Help1 := mob.GetMobAbility(EF_SKILL_ABSORB2);
        if (Help1 > Dano) then
        begin
          Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
           // ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
            ('Voc� absorveu o ataque  ');
          mob.DecreasseMobAbility(EF_SKILL_ABSORB2, Dano);
          Dano := 0;
          DmgType := TDamageType.None;
        end
        else
        begin
          Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
           // ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
            ('Voc� absorveu o ataque  ');
          DecInt(Dano, Help1);
          mob.RemoveBuffByIndex(142);
        end;
      end;

      if (mob.Polimorfed) then
      begin
        DmgType := TDamageType.DoubleCritical;
        mob.Polimorfed := False;

        if (mob.ClientID <= MAX_CONNECTIONS) then
        begin
          mob.RemoveBuffByIndex(99);
          mob.SendCreateMob(SPAWN_NORMAL);
        end;
      end;

      if (mob.BuffExistsByIndex(101)) then
      begin
        Help1 := mob.GetMobAbility(EF_HP_CONVERSION);

        Help1 := ((Dano div 100) * Help1);
        if (DWORD(Help1) >= mob.Character.CurrentScore.CurMP) then
        begin
          mob.RemoveMP((Help1 * (mob.GetMobAbility(EF_MP_EFFICIENCY) div 100)), True);
          mob.RemoveBuffByIndex(101);
        end
        else
          mob.RemoveMP((Help1 * (mob.GetMobAbility(EF_MP_EFFICIENCY) div 100)), True);

        decint(Dano, Help1);
      end;

      if (mob.BuffExistsByIndex(111)) then
      begin // nevoa fc
        mob.RemoveBuffByIndex(111) ;
      end;

      if (mob.BuffExistsByIndex(86)) then
      begin
         // Multiplica o dano por 2
      if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
         Dano := Dano * 10;  // Dano é multiplicado por 2
        end;

        begin // choque dual
          mob.RemoveBuffByIndex(86);
        end;

      end;


      if (mob.BuffExistsByIndex(63)) then
      begin // choque att
        mob.RemoveBuffByIndex(63);
      end;

      if (mob.BuffExistsByIndex (153)) then
      begin // predador
        mob.RemoveBuffByIndex(153);
      end;

      HelperInByte := 0;

      if (mob.GetMobAbility(EF_HP_CONVERSION) > 0) then
      begin
        DecInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_HP_CONVERSION)));
      end;

      if (mob.BuffExistsByIndex(38)) then
      begin
        Help1 := mob.GetMobAbility(EF_REFLECTION2);

        if(not(mob.IsPlayer) and not(Self.IsDungeonMob)) then
        begin
          Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP :=
           Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP -
           ((Dano div 100) * Help1);
          Self.SendCurrentHPMPMob();
        end;

        Dano := 0;
        DmgType := TDamageType.None;

        //mob.RemoveBuffByIndex(38);
      end;

      if (Dano > 0) then
      begin
        Helper := mob.GetMobAbility(EF_REFLECTION1);
        if (Helper > 0) then
        begin
          if(not(mob.IsPlayer) and not(Self.IsDungeonMob)) then
          begin
            Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP :=
             Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP -
             ((Dano div 100) * Help1);
            Self.SendCurrentHPMPMob();
          end;
        end;

        if (mob.BuffExistsByIndex(222)) then
        begin
          Helper := mob.GetMobAbility(EF_SKILL_ABSORB1);

          if (Helper > 0) then
          begin
            if (Dano >= Helper) then
            begin
              mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Helper);
              mob.RemoveBuffByIndex(222);
            end
            else
              mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);

            Dec(Dano, Helper);
          end;
        end;
      end;

      if (mob.BuffExistsByIndex(32)) then
      begin
        DecInt(Dano, ((Dano div SkillData[Skill].Adicional) * mob.GetMobAbility(EF_POINT_DEFENCE)));

        Dec(mob.DefesaPoints, 1);

        if (mob.DefesaPoints = 0) then
          mob.RemoveBuffByIndex(32);
      end;

      if(mob.BuffExistsByIndex(35) and (Trim(mob.UniaoDivina) <> '')) then
      begin
        Helper := Dano;

        DecInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_TRANSFER)));

        decInt(Helper, Dano);

        OtherPlayer := Servers[Self.ChannelId].GetPlayer(mob.UniaoDivina);

        if(Assigned(OtherPlayer)) then
        begin
          if (not(OtherPlayer.Base.IsDead) and (OtherPlayer.Status >= Playing)) then
          begin
            OtherPlayer.Base.RemoveHP(Helper, True, True);
            OtherPlayer.SendClientMessage('Seu HP foi consumido em ' + Helper.ToString +
            ' pontos pelo buff [Uni�o Divina] no membro <' +
            AnsiString(OtherPlayer.Base.Character.Name) + '>.', 16);
          end;
        end;

        DecInt(mob.MOB_EF[EF_TRANSFER_LIMIT], Helper);

        if(mob.MOB_EF[EF_TRANSFER_LIMIT] = 0) then
        begin
          mob.RemoveBuffByIndex(35);
          mob.UniaoDivina := '';
        end;
      end;

      if not(Dano = 0) and not(mob.ClientID >= 3048) then
      begin
        if (mob.BuffExistsByIndex(460)) then
        begin
          if (Dano > mob.Character.CurrentScore.CurHP) then
          begin
            mob.RemoveBuffByIndex(460);
            mob.RemoveAllDebuffs;
            mob.ResolutoPoints := 0;
            mob.Character.CurrentScore.CurHP :=
              ((mob.Character.CurrentScore.MaxHP div 100) * 50);
            mob.Character.CurrentScore.CurMP :=
              ((mob.Character.CurrentScore.MaxMP div 100) * 45);
            mob.SendCurrentHPMP(True);
            mob^.addbuff(5121);

            Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
              ('Você foi revivido graças ao buff [Pedra da Alma].');
          end;
        end;
      end;

      if(mob.BuffExistsByIndex(80)) then
      begin //requiem
        Inc(Dano, mob.GetMobAbility(EF_ADD_DAMAGE1));
      end;

      if (mob.BuffExistsByIndex(90)) then
      begin // estripador de dual
        if ((DmgType = Critical) or (DmgType = DoubleCritical)) then
         mob.AddBuff(3262); // Aplica o buff apenas em críticos
         mob.addbuff(6367);

      end;

      if (mob.ResolutoPoints > 0) then
      begin

        if (SecondsBetween(Now, mob.ResolutoTime) >= 8) then
        begin
          mob.ResolutoPoints := 0;
        end
        else if (AddBuff) then
        begin
          dec(mob.ResolutoPoints, 1);
          MobAnimation := 26;
          mob.TargetBuffSkill(6879, 0, mob, @SkillData[6879]);
        end;
      end;

      {if (mob.BuffExistsByIndex(134)) then
        if (mob.Character.CurrentScore.CurHP <
          (mob.Character.CurrentScore.MaxHP div 2)) then
        begin
          //Helper := mob.GetBuffIDByIndex(134);
          //mob.AddHP(mob.CalcCure2(SkillData[Helper].EFV[0], mob, Helper), True);
          Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
              ('Cura preventiva entrou em a��o e feiti�o foi desfeito.', 0);
          mob.RemoveBuffByIndex(134);
        end; }

      case (Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobType-1024) of
        0: //humanoide
          begin
            if(mob.GetMobAbility(EF_DEF_ALIEN) > 0) then
            begin
              DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_ALIEN)));
            end;
          end;

        1: //animal
          begin
            if(mob.GetMobAbility(EF_DEF_BEAST) > 0) then
            begin
              DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_BEAST)));
            end;
          end;

        2: //plantas
          begin
            if(mob.GetMobAbility(EF_DEF_PLANT) > 0) then
            begin
              DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_PLANT)));
            end;
          end;

        3: //inseto
          begin
            if(mob.GetMobAbility(EF_DEF_INSECT) > 0) then
            begin
              DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_INSECT)));
            end;
          end;

        4: //demonio
          begin
            if(mob.GetMobAbility(EF_DEF_DEMON) > 0) then
            begin
              DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_DEMON)));
            end;
          end;

        5: //morto vivo
          begin
            if(mob.GetMobAbility(EF_DEF_UNDEAD) > 0) then
            begin
              DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_UNDEAD)));
            end;
          end;

        6: //misto
          begin
            if(mob.GetMobAbility(EF_DEF_COMPLEX) > 0) then
            begin
              DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_COMPLEX)));
            end;
          end;

        7: //estrutura
          begin
            if(mob.GetMobAbility(EF_DEF_STRUCTURE) > 0) then
            begin
              DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_STRUCTURE)));
            end;
          end;
      end;

       // bolhja templaria mobs
      // if ((mob^.BuffExistsByIndex(36) = True) and not (DataSkill^.Index = 0)) then
     if (self.BuffExistsByIndex(36) and self.BuffExistsByIndex(36)) then
        begin

        // Verifica se há algum BuffIndex entre 1 e 500 ativo e reduz a bolha
         var i: Integer;

        for i := 1 to 700 do
        begin
          if self.BuffExistsByIndex(i) then
          begin
            dec(mob^.BolhaPoints, 1);
            Break; // Sai do loop ao encontrar o primeiro buff ativo
          end;
        end;

      // Caso não se encaixe em nenhuma das condições acima, reduz 1 ponto da bolha
      if (self.BolhaPoints > 0) then
      begin
        Dano := 0;
        DmgType := TDamageType.None;
        AddBuff := False;
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('[' + AnsiString(mob.Character.Name) + '] resistiu a sua habilidade de ataque.', 16, 1, 1);
        Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
          ('Você resistiu ao ataque de [' + AnsiString(Self.Character.Name) + '] restam ' +
          mob.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
      end
      else
      begin
        // Se a bolha atingir 0 pontos, remove o buff e zera o dano
        mob^.RemoveBuffByIndex(36);
        Dano := 0;
        DmgType := TDamageType.None;
        AddBuff := False;
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('[' + AnsiString(mob.Character.Name) + '] resistiu a sua habilidade de ataque.', 16, 1, 1);
        Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
          ('Você resistiu ao ataque de [' + AnsiString(Self.Character.Name) + '] Proteção desativada.', 16, 1, 1);
      end;
     end;


      if(Dano < 1) then
        Dano := 0;


        //DANO GERAL DOS PLAYERS
  // Dano:= dano + Round( dano * DANOGERALMOB) ;

    end;

procedure TBaseMob.Effect5Skill(mob: PBaseMob; EffCount: Byte; xPassive: Boolean);
var
  Packet: TRecvDamagePacket;
  Skill: Integer;
  i, cnt: Integer;
  FRand: Integer;
  PList: Array [0 .. 2] of WORD;
  MobsP: PMobSPoisition;
begin
  // if (mob^.ClientID >= 3048) then
  // Exit; // mais pra frente setar aqui pra atacar eff5 em mobs tbm
  if (EffCount > 1) then
  begin // se tiver mais de 1 efeito 5 equipado, escolher entre eles
    ZeroMemory(@PList, 6);
    cnt := 0;
    for i := 0 to 2 do
    begin
      if (EFF_5[i] > 0) then
      begin
        PList[cnt] := EFF_5[i];
        Inc(cnt);
      end;
    end;
    Randomize;
    FRand := RandomRange(1, (cnt + 1));
    Skill := PList[FRand - 1];
  end
  else
  begin
    for i := 0 to 2 do
    begin
      if (EFF_5[i] > 0) then
      begin
        Skill := EFF_5[i];
        break;
      end;
    end;
  end;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := SkillData[Skill].Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.MobAnimation := SkillData[Skill].TargetAnimation;
  if ((SkillData[Skill].TargetType = 21) and not(xPassive)) then
  begin
    Packet.TargetID := mob^.ClientID;
    Self.TargetBuffSkill(Skill, SkillData[Skill].Anim, mob, @SkillData[Skill]);
    Packet.Dano :=
      ((PlayerCharacter.Base.CurrentScore.DNFis +
      PlayerCharacter.Base.CurrentScore.DNMAG) div 3);

    if(SkillData[Skill].Damage > 0) then
    begin
      Packet.Dano := Packet.Dano + SkillData[Skill].Damage;
    end;
    { Self.GetDamage(Skill, mob, Packet.DnType); }
    Packet.DnType := TDamageType.Critical;
    if (SkillData[Skill].Adicional > 0) then
    begin
      Packet.Dano := (Packet.Dano * 2);
    end;
    if(Packet.DANO >= 20000) then
    begin
      Packet.DANO := 20000;
    end;
    Randomize;
    Packet.Dano := Packet.Dano + RandomRange(20, 200);

    if(SkillData[Skill].Index = 180) then
    begin
      mob.RemoveBuff(mob.GetBuffToRemove);
    end;

    {
      if (mob.ClientId >= 3048) then
      begin
      if (Packet.Dano >= Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
      [mob.SecondIndex].HP) then
      begin
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
      [mob.SecondIndex].HP := 0;
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP[mob.SecondIndex]
      .IsAttacked := False;
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP[mob.SecondIndex]
      .AttackerID := 0;
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP[mob.SecondIndex]
      .DeadTime := Now;
      if (Self.VisibleMobs.Contains(Servers[mob.ChannelId].MOBS.TMobS
      [mob.Mobid].MobsP[mob.SecondIndex].Index)) then
      Self.VisibleMobs.Remove(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid]
      .MobsP[mob.SecondIndex].Index);
      mob.VisibleMobs.Clear;
      Servers[Self.ChannelId].Players[Self.ClientId]
      .AddExp(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobExp,
      EXP_TYPE_MOB);
      Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
      ('Voc� recebeu ' + AnsiString(Servers[mob.ChannelId].MOBS.TMobS
      [mob.Mobid].MobExp.ToString) + ' pontos de experi�ncia.', 0);
      mob.SendEffect($0);
      Packet.MobAnimation := 30;
      mob.IsDead := True;
      end
      else
      begin
      mob.RemoveHP(Packet.Dano, False);
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob.Character.CurrentScore.CurHP;
      Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      Exit;
      end;
    }
    if (mob^.ClientID >= 3048) then
    begin
      case mob^.ClientID of
        3340 .. 3354:
          begin // stones
            if (Packet.Dano >= Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP) then
            begin
              //mob^.IsDead := True;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 100;
              //Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                //.IsAttacked := False;
              //Servers[Self.ChannelId].DevirStones[mob^.ClientID].AttackerID := 0;
              //Servers[Self.ChannelId].DevirStones[mob^.ClientID].deadTime := Now;
              //Servers[Self.ChannelId].DevirStones[mob^.ClientID].KillStone(mob^.ClientID,
              //Self.ClientId);
              //if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
             // begin
             //   Self.VisibleNPCs.Remove(mob^.ClientID);
              //  Self.RemoveTargetFromList(mob);
             //   // essa skill tem retorno no caso de erro
             // end;
             // mob^.VisibleMobs.Clear;
             // // Self.MobKilled(mob, DropExp, DropItem, False);
             // Packet.MobAnimation := 30;
            end
            else
            begin
              deccardinal(Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP, Packet.Dano);
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP;
            Packet.TargetID :=
              Servers[Self.ChannelId].DevirStones[mob^.ClientID].Base.ClientID;
            Self.SendToVisible(Packet, Packet.Header.size);
            //Sleep(1);
            Exit;
          end;
        3355 .. 3369:
          begin // guards
            if (Packet.Dano >= Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP) then
            begin
              //mob^.IsDead := True;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 100;
             // Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              //  .IsAttacked := False;
              //Servers[Self.ChannelId].DevirGuards[mob^.ClientID].AttackerID := 0;
              //Servers[Self.ChannelId].DevirGuards[mob^.ClientID].deadTime := Now;
             // Servers[Self.ChannelId].DevirGuards[mob^.ClientID].KillGuard(mob^.ClientID,
              //Self.ClientId);
              //if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
              //begin
              //  Self.VisibleNPCs.Remove(mob^.ClientID);
              //  Self.RemoveTargetFromList(mob);
              //  // essa skill tem retorno no caso de erro
             // end;
             // mob^.VisibleMobs.Clear;
              // Self.MobKilled(mob, DropExp, DropItem, False);
             // Packet.MobAnimation := 30;
            end
            else
            begin
              deccardinal(Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP, Packet.DANO);
            end;
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP;
          Packet.TargetID := Servers[Self.ChannelId].DevirGuards[mob^.ClientID].Base.ClientID;
          Self.SendToVisible(Packet, Packet.Header.size);
          //Sleep(1);
          Exit;
        end;
      else
        begin
          MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP
            [mob.SecondIndex];
          if (Packet.Dano >= MobsP^.HP) then
          begin
            MobsP^.HP := 10;
          end
          else
          begin
            deccardinal(MobsP^.HP, Packet.Dano);
          end;
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := MobsP^.HP;
          Packet.TargetID := MobsP.Base.ClientID;
          Self.SendToVisible(Packet, Packet.Header.size, True);
          //Sleep(1);
        end;
      end;
    end
    else
    begin
      if (Packet.Dano >= mob^.Character.CurrentScore.CurHP) then
      begin
        mob^.Character.CurrentScore.CurHP := 100;
      end
      else
      begin
        mob^.RemoveHP(Packet.Dano, False);
      end;
      mob^.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
      Packet.TargetID := mob.ClientID;
      Self.SendToVisible(Packet, Packet.Header.size, True);
      //Sleep(1);
    end;
  end
  else
  begin
    if not(SkillData[Skill].TargetType = 21) then
    begin
      Packet.TargetID := Self.ClientID;
      Packet.AttackerID := 0;
      Packet.Dano := 0;
      Packet.DnType := TDamageType.None;
      Packet.MobAnimation := SkillData[Skill].TargetAnimation;
      Self.SelfBuffSkill(Skill, SkillData[Skill].Anim, mob,
        TPosition.Create(0, 0));
      Packet.MobCurrHP := Self.Character.CurrentScore.CurHP;
      Self.SendToVisible(Packet, Packet.Header.size);
      //Sleep(1);
    end;
  end;
end;
function TBaseMob.IsSecureArea(): Boolean;
var
  i: Integer;
begin
  Result := False;
  for I := 0 to 9 do
  begin
    {if(Servers[Self.ChannelId].SecureAreas[i].IsActive) then
    begin
      if(Servers[Self.ChannelId].SecureAreas[i].Position.InRange(
        Self.PlayerCharacter.LastPos, 8)) then
      begin
        Result := True;
      end;
    end;}
  end;
end;
procedure TBaseMob.WarriorSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
  var BonusHP:integer;
begin
  case SkillData[Skill].Index of
    ATAQUE_PODEROSO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    AVANCO_PODEROSO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
        case mob.ClientId of
          1..1000: //MAX_CONNECTIONS players
            begin
              Self.WalkAvanced(mob.PlayerCharacter.LastPos, Skill);
            end;
          3048..9147: //mobs
            begin
              case mob.ClientId of
                3340..3354: //stones
                  begin
                    Self.WalkAvanced(Servers[Self.ChannelId].DevirStones[mob.ClientID].PlayerChar.LastPos,
                      Skill);
                  end;
                3355..3369: //guards
                  begin
                    Self.WalkAvanced(Servers[Self.ChannelId].DevirGuards[mob.ClientID].PlayerChar.LastPos,
                      Skill);
                  end;
              else //mobs normais
                begin
                  Self.WalkAvanced(Servers[Self.ChannelId].MOBS.TMobS[mob.MobID].MobsP[mob.SecondIndex].CurrentPos,
                    Skill);
                end;
              end;
            end;
        end;
        // Self.WalkinTo(Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
        // [mob.SecondIndex].CurrentPos)
        // else
        // Self.WalkinTo(mob.PlayerCharacter.LastPos);
      end;
    QUEBRAR_ARMADURA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    INCITAR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;

    RESOLUTO:
    begin

      Dano := Self.GetDamage(Skill, mob, DmgType);

      if (Self.ValidAttack(DmgType, 0, mob, Dano)) then

      begin
        mob.ResolutoPoints := SkillData[Skill].Damage;
        mob.ResolutoTime := Now;
        mob.addbuff(6879);
      end;
    end;



      ESTOCADA:
      begin
        DmgType := Self.GetDamageType2(Skill, True, mob);
        Dano := 200;

        // Verifica se há buffs para remover e remove apenas os buffs com IDs específicos
        if mob._buffs.Count > 0 then
        begin
          var BuffCount := 0;
          var BuffKey: WORD;

          // Itera pelos buffs e remove apenas os com IDs específicos
          for BuffKey in mob._buffs.Keys do
          begin
          { if (BuffKey = 6498) or (BuffKey = 6499) or (BuffKey = 208) or
               (BuffKey = 272) or (BuffKey = 348) or (BuffKey = 5163) or
               (BuffKey = 5193) or (BuffKey = 1461) or (Buffkey = 4001) or (Buffkey = 4016) then }
            begin
              // Remove o buff e atualiza o status do mob
              if mob.RemoveBuff(BuffKey) then
              begin
                mob.GetCurrentScore;  // Recalcula os pontos de status desconsiderando o buff removido
                mob.SendRefreshPoint; // Envia os pontos atualizados ao servidor
              end;



              Inc(BuffCount);
              if BuffCount >= 1 then
                Break; // Remove no máximo 2 buffs
            end;

             mob.RemoveBuffs(SkillData[Skill].Damage);
          end;
        end;

        // Aplica o buff 6373 ao mob
        mob._buffs.Add(6373, Now);

        // Multiplica o dano por 2
        if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
          CanDebuff := True;
          Dano := Dano * 2;  // Dano é multiplicado por 2
        end;
      end;


    FERIDA_MORTAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
     PANCADA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);

        if (Self.ValidAttack(DmgType, 0)) then
        begin
          // Verifica se o mob tem o buff 36 (bolha/defesa)
          if not mob.BuffExistsByIndex(36) or mob.BuffExistsByIndex(162) or
          mob.BuffExistsByIndex(365) or mob.BuffExistsByIndex(135) or
          mob.BuffExistsByIndex(101) or mob.BuffExistsByIndex(432) or
          mob.BuffExistsByIndex(91) or mob.BuffExistsByIndex(19) then
          begin
            // Só aplica o dano adicional se NÃO tiver o buff 36
            if SkillData[Skill].Adicional > 0 then
            begin
              BonusHP := (Self.Character.CurrentScore.CurHP * SkillData[Skill].Adicional) div 100;
              BonusHP := BonusHP + SkillData[Skill].Adicional;

              // Aplica o dano adicional diretamente, ignorando defesas
              mob.RemoveHP(BonusHP, True, True);

              // Envia mensagem ao atacante
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
                Format('Você causou %d de dano adicional com base no seu HP.', [BonusHP]), 16, 0, 0);

              // Envia mensagem ao alvo (se for jogador)
              if mob.IsPlayer then
              begin
                Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage(
                  Format('Você sofreu %d de dano adicional do ataque de %s.', [BonusHP, Self.Character.Name]), 16, 0, 0);
              end;
            end;
          end
          else
          begin
            // Opcional: informa que o dano foi bloqueado pela bolha
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
              'O alvo está protegido. Dano adicional não aplicado.', 16, 1, 1);
          end;

          // Aplica o dano normal com redução de defesa/resistência
          mob.RemoveHP(Dano, True, True);
        end;
      end;
      end;


end;
procedure TBaseMob.TemplarSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    STIGMA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    PROFICIENCIA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    NEMESIS:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    TRAVAR_ALVO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;

        dano:= dano div 2
      end;
    ATRACAO_DIVINA:

      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;

        case mob.ClientId of
          1..1000: // Players
            begin
              Self.WalkinTo(mob.PlayerCharacter.LastPos);
            end;
          3340..3354: // Stones - apenas aplica o dano, sem movimento
            begin
              // Apenas aplica o dano sem mover a pedra
            end;
          3355..3369: // Guards - apenas aplica o dano, sem movimento
            begin
              // Apenas aplica o dano sem mover o guarda
            end;
          else // Mobs normais
            begin
              Self.WalkinTo(Servers[Self.ChannelId].MOBS.TMobS[mob.MobID].MobsP[mob.SecondIndex].CurrentPos);
            end;
        end;
      end;


    CARGA_DIVINA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
        case mob.ClientId of
          1..1000: //MAX_CONNECTIONS players
            begin
              Self.WalkinTo(mob.PlayerCharacter.LastPos);
            end;
          3048..9147: //mobs
            begin
              case mob.ClientId of
                3340..3354: //stones
                  begin
                    Self.WalkinTo(Servers[Self.ChannelId].DevirStones[mob.ClientID].PlayerChar.LastPos);
                  end;
                3355..3369: //guards
                  begin
                    Self.WalkinTo(Servers[Self.ChannelId].DevirGuards[mob.ClientID].PlayerChar.LastPos);
                  end;
              else //mobs normais

                if (mob.ClientId >= 9048) then
                begin
                  Self.WalkinTo(Servers[Self.ChannelId].MOBS.TMobS[mob.MobID].MobsP[mob.SecondIndex].CurrentPos);
                end;
              end;
            end;
        end;
      end;
  end;
end;

procedure TBaseMob.RiflemanSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
var
  Helper: Int64;
  DebuffPower: integer;


begin
  case SkillData[Skill].Index of
    ELIMINACAO:
      begin
        Dano := 0; // Self.GetDamage(Skill, mob, DmgType);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
          Exit;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
            Exit;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
            Exit;
          end;
        end;

        DmgType := Self.GetDamageType3(Skill, True, mob);

        if(ValidAttack(DmgType, 0, mob, 0)) then
        begin
          mob.RemoveBuffs(1);
        end;
      end;
    TIRO_FATAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;

        end;
      end;
    TIRO_ANGULAR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);


          Dano := Dano + (PlayerCharacter.base.CurrentScore.Critical * 10 ); // Soma o dano crítico ao dano normal
      end;

    TIRO_NA_PERNA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    PERSEGUIDOR:
      begin
        Dano := 0;//Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, True, mob);
        if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then

        begin
          CanDebuff := True;
        end;
      end;

    PRIMEIRO_ENCONTRO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType)*3;
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    ELIMINAR_ALVO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        Dano := Dano * 10;  // dobra o dano final
      end;
    PONTO_VITAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    MARCA_PERSEGUIDOR:
      begin
        DmgType := Self.GetDamageType3(Skill, True, mob);

        Dano := 0;

        if(DmgType = Miss) then
          Exit;

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
          Exit;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
            Exit;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
            Exit;
          end;
        end;

        if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    CONTRA_GOLPE:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType) * 3;
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
          Helper := ((Dano div 100) * SkillData[Skill].Adicional);
          Inc(Dano, Helper);
          DmgType := TDamageType.Critical;
        end;
      end;
    ATAQUE_ATORDOANTE:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    INSPIRAR_MATANCA:
  begin
    Dano := Self.GetDamage(Skill, mob, DmgType);
    if (Self.ValidAttack(DmgType)) then
    begin
      // Ajuste o multiplicador ou adicione uma constante para aumentar o HP recuperado
      Helper := ((Dano div 100) * SkillData[Skill].Adicional) * 10; // Multiplicador maior
      Inc(Self.Character.CurrentScore.CurHP, Helper);

      if (mob.ClientID <= MAX_CONNECTIONS) then
      begin
        if (Dano >= mob.Character.CurrentScore.CurHP) then
        begin
          // Aumenta a recuperação de HP ao matar o inimigo
          Inc(Self.Character.CurrentScore.CurHP, ((Self.Character.CurrentScore.MaxHP div 100) * 100));
        end;
      end;

      // Adiciona um bônus adicional ao HP recuperado
      Inc(Self.Character.CurrentScore.CurHP, 300000); // Adiciona 100 de HP extra

      Self.SendCurrentHPMP(True);
    end;
  end;

    SENTENCA:
      begin
      var
        Percentual:= 450 ;

        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Randomize;
          Helper := Random(100);
          if (Helper <= UInt64(SkillData[Skill].DamageRange - 20)) then
          begin
            Dano := Dano + Dano;
          end;
        end;
        Dano := Round(Dano + (Dano * (Percentual / 100.0)));
      end;
    POSTURA_FANTASMA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Self.SelfBuffSkill(SkillData[Skill].Adicional, Anim, mob,
            TPosition.Create(0, 0));
        end;
      end;
    DESTINO:
      begin
        // verificar se est� oculto Dano + Adicional
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := (mob.Character.CurrentScore.DEFFis shr 3);
          Inc(Dano, Helper);
          Self.SelfBuffSkill(SkillData[Skill].Adicional, Anim, mob,
            TPosition.Create(0, 0));
        end;
      end;
  end;
end;
procedure TBaseMob.DualGunnerSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
var
  Helper: Int64;

begin
  case SkillData[Skill].Index of
    MJOLNIR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
         //Dano := Dano * 4;  // dobra o dano final
      end;
    ESPINHO_VENENOSO:
      begin
        Dano := 0; //Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, True, mob);
        if (Self.ValidAttack(DmgType, PARALISYS_TYPE, mob, 0, True)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    TIRO_DESCONTROLADO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    VENENO_LENTIDAO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob, 0, True)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    REQUIEM:
      begin
        // configurar o getDamage para reconhecer o dano de cada ataque
        Dano := 0;//Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, True, mob);
        Inc(Dano, (mob^.GetMobAbility(EF_ADD_DAMAGE1)*4));
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;

      end;
    VENENO_MANA:
    begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
            Helper := SkillData[Skill].Adicional;
            Inc(Dano, Helper);

            // Definir o valor de remoção de MP com base no nível do alvo
            var MPRemovido: Integer;


            if (mob^.character.Level >= 0) and (mob^.character.Level <= 99) then
                MPRemovido := SkillData[Skill].Adicional * 50

            else
                MPRemovido := 0; // Caso o nível esteja fora do esperado, não remove MP

            // Aplicar a remoção do MP com o valor fixo definido
            mob.RemoveMP(Helper + MPRemovido, True);

            // O jogador ganha MP apenas do valor base (sem o extra fixo)
            Self.AddMP(Helper, True);

            CanDebuff := True;
           // Dano := Dano * 2;  // dobra o dano final
        end;
    end;


    CHOQUE_SUBITO:
      begin
        Dano := 0; // Self.GetDamage(Skill, mob, DmgType);
        DmgType := Normal;

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;


        if (Self.ValidAttack(DmgType, CHOCK_TYPE, mob, Dano )) then
        begin
          CanDebuff := True;
        end



        else
          Resisted := True;
      end;
    NEGAR_CURA:
    begin
    Dano := 0;
    DmgType := Self.GetDamageType3(Skill, True, mob);

    if (Self.ValidAttack(DmgType, 0, mob, Dano)) then
      begin
        CanDebuff := True;
      end;
    end;

    ESTRIPADOR:
      begin // configurar o getDamage para a cada critico = stun
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          mob.AddBuff(3262); // Aplica o buff apenas em críticos
          mob.addbuff(6367);
        end;
         Dano := Dano * 2;  // dobra o dano final
      end;
    VENENO_HIDRA:
    begin
      Dano := Self.GetDamage(Skill, mob, DmgType);

      // Verifica se a skill é a 219
      if Skill = 219 then
      begin
        // Sempre aplica o stun sem resistência para a skill 219
        CanDebuff := True;
        Resisted := False; // Garante que não ocorra resistência
      end
      else
      begin
        // Comportamento padrão para outras skills
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
        begin
          Resisted := True;
        end;
      end;
    end;



    CHOQUE_HIDRA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if Self.ValidAttack(DmgType, CHOCK_TYPE, mob) then
        begin
          if mob^.Chocado then
          begin
            Helper := (Dano div 100) * SkillData[Skill].Adicional;
            Inc(Dano, Helper);
             end
          else
          begin
            CanDebuff := True;
          end;
        end
        else
        begin
          Resisted := True;
        end;
        Dano := Dano * 4;  // dobra o dano final
      end;
    DOR_PREDADOR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          // no getDamage, a cada ataque = ++HP
          CanDebuff := True;
        end;
         Dano := Dano * 4;  // dobra o dano final
      end;
    MORTE_DECIDIDA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Randomize;
          Helper := Random(100);
          if (Helper < 30) then
            Helper := 30;
          Helper := (((SkillData[Skill].Damage + 1000) div 100) * Helper);
          Inc(Dano, Helper);
           Dano := Dano * 4;  // dobra o dano final
        end;
      end;
    REACAO_CADEIA:
    begin
      Dano := Self.GetDamage(Skill, mob, DmgType);
      if (Self.ValidAttack(DmgType)) then
      begin
        Self.AddBuff(Skill);
        mob.addbuff( 7357)
      end;
        Dano := Dano * 4;  // dobra o dano final
    end;


    BOMBA_MALDITA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          // a cada buff = Dano + (Adicional * qnt de buff)
          CanDebuff := True;
        end;
      end;
  end;

 // dano:=dano * 2
end;
procedure TBaseMob.MagicianSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
var
  Helper: Int64;
  BonusHP: integer;
begin
  case SkillData[Skill].Index of
    CHAMA_CAOTICA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
          Dano := Dano  div 4;  // Triplica o dano final
      end;
    SOFRIMENTO:
      begin
        Dano := 1; Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;

    POLIMORFO:
     if (mob.Character.Nation > 0) then
        begin
          if not (mob.Character.Nation in [1, 2, 3, 4]) then
            begin
              self.SendClientMessage('Só pode ser utilizado em Nações oficiais.');
              Exit;
            end;


          begin
            // Inicializar o dano como 0
            Dano := 0;

            // Verificar se o alvo (player ou mob) está sob o efeito do buff 19 ou usando a skill de ID 33
            if mob^.BuffExistsByIndex(19) or (mob^.BuffExistsByIndex(33)) then
            begin
              // Informar ao jogador que o ataque foi resistido
             // Informar ao jogador que o ataque foi resistido usando a estrutura fornecida
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
            'O jogador alvo resistiu à sua habilidade devido a um buff ativo.', 0);

              // Sair sem aplicar o dano, pois o ataque foi cancelado
              Exit;
            end;

            // Aplicar dano se os buffs 19 ou skill 33 não estiverem ativos
            Self.GetDamage(Skill, mob, DmgType);
            DmgType := Self.GetDamageType3(Skill, False, mob);

            // Verificar se o ataque é válido
            if (Self.ValidAttack(DmgType, 0, mob, 0)) then
            begin
              CanDebuff := True;
            end;
          end;
        end;


    ONDA_CHOQUE:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    INFERNO_CAOTICO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    IMPEDIMENTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    CORROER:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := ((Dano div 100) * SkillData[Skill].Adicional) * 10 + 300000;
          Inc(Self.Character.CurrentScore.CurHP, Helper);
          Self.SendCurrentHPMP(True);
        end;

        mob.AddBuff(7359);
      end;
    LANCA_RAIO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    MAO_ESCURIDAO:
      begin
        Dano := 0; Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    VINCULO:
    begin
      Dano := Self.GetDamage(Skill, mob, DmgType);
      if (Self.ValidAttack(DmgType)) then
      begin
        // Calcula 75% do dano aplicado
        Helper := (Dano *  SkillData[Skill].Adicional) div 100;

        // Remove esse valor do HP do atacante (Self)
        Self.RemoveHP(Helper, True);
      end;
     // dano:=dano * 8;
    end;


    {CRISTALIZAR_MANA:
      begin

        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := 0;
          // Alterando o cálculo para basear no MP do jogador
          Helper := ((Self.Character.CurrentScore.CurMP div 100) *
          SkillData[Skill].Adicional);
           Inc(Dano, Helper);
        end;

      end;}


       CRISTALIZAR_MANA:
     begin
        Dano := Self.GetDamage(Skill, mob, DmgType);

        if (Self.ValidAttack(DmgType, 0)) then
        begin
          // Verifica se o mob tem o buff 36 (bolha/defesa)
          if not mob.BuffExistsByIndex(36) or mob.BuffExistsByIndex(162) or
          mob.BuffExistsByIndex(365) or mob.BuffExistsByIndex(135) or
          mob.BuffExistsByIndex(101) or mob.BuffExistsByIndex(432) or
          mob.BuffExistsByIndex(91) or mob.BuffExistsByIndex(19) then
          begin
            // Só aplica o dano adicional se NÃO tiver o buff 36
            if SkillData[Skill].Adicional > 0 then
            begin
              BonusHP := (Self.Character.CurrentScore.CurMp * SkillData[Skill].Adicional) div 100;
              BonusHP := BonusHP + SkillData[Skill].Adicional;

              // Aplica o dano adicional diretamente, ignorando defesas
              mob.RemoveHP(BonusHP, True, True);

              // Envia mensagem ao atacante
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
                Format('Você causou %d de dano adicional com base no seu HP.', [BonusHP]), 16, 0, 0);

              // Envia mensagem ao alvo (se for jogador)
              if mob.IsPlayer then
              begin
                Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage(
                  Format('Você sofreu %d de dano adicional do ataque de %s.', [BonusHP, Self.Character.Name]), 16, 0, 0);
              end;
            end;
          end
          else
          begin
            // Opcional: informa que o dano foi bloqueado pela bolha
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
              'O alvo está protegido. Dano adicional não aplicado.', 16, 1, 1);
          end;

          // Aplica o dano normal com redução de defesa/resistência
          mob.RemoveHP(Dano, True, True);
        end;
      end;


     {CRISTALIZAR_MANA:
    begin
      var
      Percentual := 25;   // Valor inicial de aumento de dano
      Dano := Self.GetDamage(Skill, mob, DmgType);

      if (Self.ValidAttack(DmgType)) then
      begin
        Helper := 0;

        if (Self.ClientID <= MAX_CONNECTIONS) then
          Helper := ((Self.Character.CurrentScore.CurMP div 100) * SkillData[Skill].Adicional);

        Inc(Dano, Helper);

        // Cálculo de 5% da mana atual do atacante como adicional de dano
        var ManaBonus := Round(Self.Character.CurrentScore.CurMP * 0.05);
        Inc(Dano, ManaBonus);

        // Ajuste do percentual com base no nível do personagem
        case Self.Character.Level of
          0..84: Percentual := 25;
          85..89: Percentual := 30;
          90..94: Percentual := 35;
          95..97: Percentual := 40;
          98..99: Percentual := 60;
        end;

        Dano := Round(Dano + (Dano * (Percentual / 100)));
      end;
    end ;}
  end;



end;

procedure TBaseMob.ClericSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
var
  Helper: Int64;

begin
  case SkillData[Skill].Index of
    FLECHA_SAGRADA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := ((Dano div 100) * SkillData[Skill].Adicional);
          Inc(Dano, Helper);
        end;
      end;

    RETORNO_MAGICA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Inc(Dano, SkillData[Skill].Adicional);
          mob.RemoveBuffs(20);
           end;


             begin
          DmgType := Self.GetDamageType2(Skill, True, mob);
          Dano := 200;

          // Verifica se há buffs para remover e remove apenas os buffs com IDs específicos
          if mob._buffs.Count > 0 then
          begin
            var BuffCount := 0;
            var BuffKey: WORD;

            // Itera pelos buffs e remove apenas os com IDs específicos
            for BuffKey in mob._buffs.Keys do
            begin
              if (BuffKey = 6498) or (BuffKey = 6499) or (BuffKey = 208) or
                 (BuffKey = 272) or (BuffKey = 348) or (BuffKey = 5163) or
                 (BuffKey = 5193) or (BuffKey = 1461) or (Buffkey = 4001) or
                 (Buffkey = 4016) or not (Buffkey = 6600) and (buffkey = 6601) and (buffkey = 6602) then
              begin
                // Remove o buff e atualiza o status do mob
                if mob.RemoveBuff(BuffKey) then
                begin
                  mob.GetCurrentScore;  // Recalcula os pontos de status desconsiderando o buff removido
                  mob.SendRefreshPoint; // Envia os pontos atualizados ao servidor
                end;



                Inc(BuffCount);
                if BuffCount >= 2 then
                  Break; // Remove no máximo 2 buffs
              end;
            end;
          end;


        end;

      end;

       RAIO_SOLAR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := ((Dano div 100) * SkillData[Skill].Adicional);
          Inc(Dano, Helper);
        end;
      end;

  end;



 // dano:= dano * 1

end;
procedure TBaseMob.WarriorAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; out MoveToTarget: Boolean);
begin
  case SkillData[Skill].Index of
    TEMPESTADE_LAMINA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    AREA_IMPACTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    CANCAO_GUERRA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    SALTO_IMPACTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    GRITO_MEDO:
      begin

        {if Dano > 0 then
          begin
          Dano := 0;
        end;}

         Dano := 0; Self.GetDamage(Skill, mob, DmgType);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;
         //skill Grrito do Medo dando dano
        if (Self.ValidAttack(DmgType, FEAR_TYPE, mob, Dano)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    LAMINA_CARREGADA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    INVESTIDA_MORTAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);

        // Verifica se o alvo é um guarda
        if (mob.ClientId >= 3355) and (mob.ClientId <= 3369) then
        begin
          // Desabilita o dano e o efeito se o alvo for um guarda
         // Player.SendClientMessage('Essa habilidade não tem efeito em guardas.');
          Exit;
        end;

        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;

        Self.WalkinTo(mob.PlayerCharacter.LastPos);
        case mob.ClientId of
          1..1000: // MAX_CONNECTIONS players
          begin
            Self.WalkinTo(mob.PlayerCharacter.LastPos);
          end;
          3048..9147: // mobs
          begin
            case mob.ClientId of
              3340..3354: // stones
              begin
                Self.WalkinTo(Servers[Self.ChannelId].DevirStones[mob.ClientID].PlayerChar.LastPos);
              end;
              3355..3369: // guards
              begin
                // Não faz nada pois o efeito e dano em guardas estão desabilitados
                Exit;
              end;
            else // mobs normais
              begin
                Self.WalkinTo(Servers[Self.ChannelId].MOBS.TMobS[mob.MobID].MobsP[mob.SecondIndex].CurrentPos);
              end;
            end;
          end;
        end;
      end;

    PODER_ABSOLUTO:
      begin
        DmgType := Self.GetDamageType2(Skill, True, mob);
        Dano := 200;

        // Verifica se o oponente tem o BuffIndex 36 (Bolha ativa)
        if mob^.BuffExistsByIndex(36) and mob^.BuffExistsByIndex(136) then
        begin
          // Envia mensagem ao jogador informando que o buff não foi aplicado
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
            '[' + AnsiString(mob.Character.Name) + '] está protegido pela Bolha. O buff não foi aplicado.',
            16, 1, 1
          );

          // Sai da função antes de aplicar o buff

          Exit;
        end;

        // Aplica o buff 6373 ao mob
        mob._buffs.Add(6367, Now);

        // Multiplica o dano por 2
        if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
          CanDebuff := True;
        end;

        if Self.Character.Level = 95 then
          Dano := Dano * 1
        else if Self.Character.Level = 99 then
          Dano := Dano * 1
        else
          Dano := Dano * 1; // Multiplicador padrão para outros níveis
      end;


    LIMITE_BRUTAL:
    begin

    // Verifica se o oponente tem o BuffIndex 36 (Bolha ativa)
        if mob^.BuffExistsByIndex(36) and mob^.BuffExistsByIndex(136)  then
        begin
          // Envia mensagem ao jogador informando que o dano contínuo não pode ser aplicado
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
            '[' + AnsiString(mob.Character.Name) + '] está protegido pela Bolha. O efeito de dano contínuo não foi ativado.',
            16, 1, 1
          );

          // Sai daat função antes de configurar a remoção de HP
          Exit;
        end;


      begin
        // Calcula o dano base
        Dano := Self.GetDamage(Skill, mob, DmgType);

        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;

          // Ajusta o dano baseado no nível do jogador
          if Self.Character.Level = 95 then
            Dano := Dano  div 2
          else if Self.Character.Level = 99 then
            Dano := Dano div 2
          else
            Dano := Dano  div 2; // Multiplicador padrão para outros níveis


          // Configuração para dano contínuo (executado apenas se a Bolha NÃO estiver ativa)
          Self.SKDSkillEtc1 := Round(Dano * 1); // Aplica 90% do dano por tick
          Self.SKDTarget := mob^.ClientID;
          Self.SKDListener := True;  // Ativa o listener para processar os "ticks" do dano contínuo
          Self.SKDAction := 2;  // Define que é um efeito contínuo
          Self.SKDSkillID := Skill;

           mob^.AddBuff(Skill);
        end;
      end;
    end;


    POSTURA_FINAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
  end;
end;
procedure TBaseMob.TemplarAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    INCITAR_MULTIDAO:
      begin
        Dano := 0; Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, True, mob);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;

        if(Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
          if (mob.BuffExistsByIndex(53)) then
          begin
            mob.RemoveBuffByIndex(53);
          end;
          if (mob.BuffExistsByIndex(77)) then
          begin
            mob.RemoveBuffByIndex(77);
          end;
        end;
      end;
    EMISSAO_DIVINA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
         mob.AddBuff(1264);
      end;
    LAMINA_PROMESSA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        dano:= dano div 2
      end;
    SANTUARIO:
       begin
        // Calcular o dano
        Dano := Self.GetDamage(Skill, mob, DmgType);

        // Verificar se o ataque é válido
        if (Self.ValidAttack(DmgType)) then
        begin

         var BuffCount := 0;
          var BuffKey: WORD;
          // Verificar se o alvo não é um jogador (ou seja, é um mob)
          //if not mob.IsPlayer then
          begin
           // CanDebuff := True;  // Aplicar o buff/debuff apenas em mobs

            // Itera pelos buffs e remove apenas os com IDs específicos
            BuffCount := 0;
            for BuffKey in mob._buffs.Keys do
            begin
              if (BuffKey = 6498) or (BuffKey = 6499) or (BuffKey = 208) or
                 (BuffKey = 272) or (BuffKey = 348) or (BuffKey = 5163) or
                 (BuffKey = 5193) or (BuffKey = 1461) or (BuffKey = 4001) or (BuffKey = 4016) then
              begin
                // Remove o buff e atualiza o status do mob
                if mob.RemoveBuff(BuffKey) then
                begin
                  mob.GetCurrentScore;  // Recalcula os pontos de status desconsiderando o buff removido
                  mob.SendRefreshPoint; // Envia os pontos atualizados ao servidor
                end;

                Inc(BuffCount);
                if BuffCount >= 1 then
                  Break; // Remove no máximo 2 buffs
              end;
            end;
          end;
        end;
      end;

      CRUZ_JULGAMENTO:
    begin
      Dano := Self.GetDamage(Skill, mob, DmgType);

      // Divide o dano por 2 (ou outro valor desejado)
      //ssssDano := Dano div 2;  // Divisão inteira

    end;


    {CRUZ_JULGAMENTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;}
    ESCUDO_VINGADOR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
  end;
end;
procedure TBaseMob.RiflemanAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    CONTAGEM_REGRESSIVA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;

         end;
    TIRO_ANGULAR_AREA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    DETONACAO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    RAJADA_SONICA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    GOLPE_FANTASMA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType) * 3 ;  //  Dobra o dano da skill
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;

      end;
    NAPALM:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    ARMADILHA_MULTIPLA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
  end;

  // dano:= dano *2 ;





end;
procedure TBaseMob.DualGunnerAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    FUMACA_SANGRENTA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    EXPLOSAO_RADIANTE:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    DISPARO_DEMOLIDOR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    PONTO_CEGO:
    begin
      Dano := Self.GetDamage(Skill, mob, DmgType);

      // Verifica se o ataque é válido
      if (Self.ValidAttack(DmgType)) then
      begin
        CanDebuff := True;

        // Aplica o buff de ID 8462 no mob
        if Assigned(mob) then
        begin
          mob.AddBuff(9064); // Adiciona o buff de ID 8462 ao mob
        end;
      end;
    end;

   FESTIVAL_BALAS:
    begin
      // Calcula o dano da habilidade
      Dano := Self.GetDamage(Skill, mob, DmgType);

      if (Self.ValidAttack(DmgType)) then
      begin
        CanDebuff := True;

        // Aplica o buff no inimigo primeiro
        mob.AddBuff(7358);
      end;

      // Aplica o dano ao alvo (mob)
      mob.GetDamage(Skill, mob, DmgType);




      // Agora, após todo o dano ter sido aplicado, aplica o buff no jogador
      Self.AddBuff(7360);
    end;



  end;
end;
procedure TBaseMob.MagicianAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    INFERNO_CAOTICO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    ENXAME_ESCURIDAO:
      begin
        // Self.UsingLongSkill := True;
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    ECLATER:
      begin
        Dano := 0; Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    ESPLENDOR_CAOTICO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
        //  Resisted := True;
      end;
    BRUMA:
      begin
        Dano := 0; // Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;

        if (Self.ValidAttack(DmgType, STUN_TYPE, mob, Dano, True)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;

    QUEDA_NEGRA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    PECADOS_MORTAIS:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
          Self.SKDListener := True;
          Self.SKDAction := 2;
          Self.SKDSkillID := Skill;
          Self.SKDTarget := mob.ClientID;
          Self.SKDSkillEtc1 := SkillData[Skill].EFV[0];
        end
        else
          Resisted := True;
      end;
    PROEMINECIA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    TEMPESTADE_RAIOS:
      begin
        Self.UsingLongSkill := True;
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
   EXPLOSAO_TREVAS:
  begin
    Dano := Self.GetDamage(Skill, mob, DmgType);
    if (Self.ValidAttack(DmgType)) then
    begin
      CanDebuff := True;

      // Calcular a quantidade de MP a ser removida (25% a mais do que o dano ao HP)
      var MPRemovido: Integer;
      MPRemovido := Round(Dano * 1.25) * 25;

      // Remover MP do alvo
      mob.RemoveMP(MPRemovido, True);
    end;
  end;


    TROVAO_RUINOSO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    TEMPESTADE:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    FURACAO_NEGRO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
          self.addbuff(7363)

        end
        else
          Resisted := True;
          self.addbuff(9146)


      end;
    PORTAO_ABISSAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
  end;
end;
procedure TBaseMob.ClericAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    SENSOR_MAGICO:
      begin
        Dano := 0; Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;

        if(Self.ValidAttack(DmgType, 0, mob, Dano)) then
        begin
          if (mob.BuffExistsByIndex(53)) then
          begin
            mob.RemoveBuffByIndex(53);
          end;
          if (mob.BuffExistsByIndex(77)) then
          begin
            mob.RemoveBuffByIndex(77);
          end;
        end;
      end;
    RAIO_SOLAR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
          Exit;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
            Exit;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
            Exit;
          end;
        end;

        Dano := 0;//Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    UEGENES_LUX:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
       // dano:=dano *30
      end;

    CRUZ_PENITENCIAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
        // dano:= dano * 30;
      end;
    EDEN_PIEDOSO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
        //dano:= dano *30
      end;
    DIXIT:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;



  end;


end;
{$ENDREGION}
{$REGION 'Effect Functions'}
procedure TBaseMob.SendEffect(EffectIndex: DWORD);
var
  Packet: TSendClientIndexPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $117;
  Packet.Index := Self.ClientID;
  Packet.Effect := EffectIndex;
  Self.SendToVisible(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Move/Teleport'}
procedure TBaseMob.Teleport(Pos: TPosition);
begin
  if not(Pos.IsValid) then
    Exit;
  Self.PlayerCharacter.LastPos := Pos;
  Self.SendCreateMob;
  // Self.UpdateVisibleList;
end;
procedure TBaseMob.Teleport(Posx, Posy: WORD);
begin
  Self.Teleport(TPosition.Create(Posx.ToSingle, Posy.ToSingle));
end;
procedure TBaseMob.Teleport(Posx, Posy: string);
begin
  Self.Teleport(TPosition.Create(Posx.ToSingle, Posy.ToSingle));
end;
procedure TBaseMob.WalkTo(Pos: TPosition; speed: WORD; MoveType: Byte);
var
  Packet: TMovementPacket;
begin
  if not(Pos.IsValid) then
    Exit;
  Self.PlayerCharacter.LastPos := Pos;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $301;
  Packet.Destination := Pos;
  Packet.MoveType := MoveType;
  Packet.speed := speed;
  Self.SendToVisible(Packet, Packet.Header.size, True);
  Self.UpdateVisibleList;
end;
procedure TBaseMob.WalkAvanced(Pos: TPosition; SkillID: Integer);
var
  Packet: TMovementPacket;
begin
   if not(Pos.IsValid) then
    Exit;

  if(Self.PlayerCharacter.LastPos.Distance(Pos) > 18) then
    Exit;
  Self.PlayerCharacter.LastPos := Pos;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $301;
  Packet.Destination := Pos;
  Packet.MoveType := 0;
  Packet.Unk := SkillID;
  Packet.Speed := 125; //era 125
  Self.SendToVisible(Packet, Packet.Header.size, True);
  Self.UpdateVisibleList;
end;
procedure TBaseMob.WalkBacked(Pos: TPosition; SkillID: Integer; Mob: PBaseMob);
var
  PacketAtk: TRecvDamagePacket;
  PacketMove: TMovementPacket;
begin
  ZeroMemory(@PacketMove, sizeof(PacketMove));
  PacketMove.Header.size := sizeof(PacketMove);
  PacketMove.Header.Index := mob.ClientID;
  PacketMove.Header.Code := $301;
  PacketMove.Destination := Pos;
  mob.PlayerCharacter.LastPos := Pos;
  PacketMove.MoveType := 0;
  PacketMove.Unk := SkillID;
  PacketMove.Speed := 15;
  ZeroMemory(@PacketAtk, sizeof(PacketAtk));
  PacketAtk.Header.size := sizeof(PacketAtk);
  PacketAtk.Header.Index := Self.ClientID;
  PacketAtk.Header.Code := $102;
  PacketAtk.SkillID := SkillID;
  PacketAtk.AttackerPos := Self.PlayerCharacter.LastPos;
  PacketAtk.AttackerID := Self.ClientID;
  PacketAtk.Animation := SkillData[SkillID].Anim;
  PacketAtk.AttackerHP := Self.Character.CurrentScore.CurHP;
  PacketAtk.TargetID := mob.ClientID;
  PacketAtk.MobAnimation := SkillData[SkillID].TargetAnimation;
  PacketAtk.DNType := TDamageType.none;
  PacketAtk.DANO := 0;
  PacketAtk.MobCurrHP := mob.Character.CurrentScore.CurHP;
  PacketAtk.DeathPos := mob.PlayerCharacter.LastPos;
  Self.SendToVisible(PacketAtk, PacketAtk.Header.size, True);
  mob.SendToVisible(PacketMove, PacketMove.Header.size, True);
  mob.UpdateVisibleList;
end;
{$ENDREGION}
{$REGION 'Pets'}
procedure TBaseMob.CreatePet(PetType: TPetType; Pos: TPosition; SkillID: DWORD);
var
  pId: Integer;
begin
  pId := TFunctions.FreePetId(Self.ChannelId);
  ZeroMemory(@Servers[Self.ChannelId].PETS[pId], sizeof(TPet));
  Self.PetClientID := pId;
  Servers[Self.ChannelId].PETS[pId].Base.Create(nil, pId, Self.ChannelId);
  Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.ClientID :=
    Servers[Self.ChannelId].PETS[pId].Base.ClientID;
  case PetType of
    X14:
      begin
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxHP := (SkillData[SkillID].Attribute div 5);
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurHP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxMP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNFis := ((SkillData[SkillID].Attribute div 10) div 4);;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DNFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFFis := ((SkillData[SkillID].Attribute div 10) div 2);
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DEFFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[0].
          Index := 328; // x14 face
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[1].
          Index := 328;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Altura := 7;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Tronco := $77;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Perna := $77;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Corpo := 0;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Exp := 1;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Level :=
          Self.PlayerCharacter.Base.Level;
        Servers[Self.ChannelId].PETS[pId].PetType := X14;
        Servers[Self.ChannelId].PETS[pId].Duration :=
          (SkillData[SkillID].Duration);
        Servers[Self.ChannelId].PETS[pId].IntName := SkillData[SkillID].EFV[0];
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.LastPos := Pos;
        Servers[Self.ChannelId].PETS[pId].MasterClientID := Self.ClientID;
      end;
    NORMAL_PET:
      begin // soon
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxHP := ItemList[SkillID].HP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurHP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxMP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNFis := ItemList[SkillID].ATKFis * 2;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DNFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFFis := ItemList[SkillID].MagATK * 2;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DEFFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[0].
          Index := ItemList[SkillID].Duration; // duration will be the mob face
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[1].
          Index := ItemList[SkillID].Duration;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Altura := ItemList[SkillID].TextureID;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Tronco := ItemList[SkillID].TextureID*ItemList[SkillID].MeshIDWeapon;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Perna := ItemList[SkillID].TextureID*ItemList[SkillID].MeshIDWeapon;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Corpo := ItemList[SkillID].TextureID*ItemList[SkillID].MeshIDWeapon;;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Exp := 1;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Level := 50;
        Servers[Self.ChannelId].PETS[pId].PetType := NORMAL_PET;
        Servers[Self.ChannelId].PETS[pId].Duration := 0;
        Servers[Self.ChannelId].PETS[pId].IntName := ItemList[SkillID].DelayUse;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.LastPos := Pos;
        Servers[Self.ChannelId].PETS[pId].MasterClientID := Self.ClientID;
      end;
  end;
end;

procedure TBaseMob.DestroyPet(PetID: WORD);
var
  i: Integer;
begin
  Servers[Self.ChannelId].Players[Self.ClientID].UnSpawnPet(PetID);
  for I in Self.VisiblePlayers do
  begin
    Servers[Self.ChannelId].Players[i].UnSpawnPet(PetID);
  end;

  ZeroMemory(@Servers[Self.ChannelId].PETS[PetID], sizeof(TPet));
end;
{$ENDREGION}
{$REGION 'TPrediction'}
procedure TPrediction.Create;
begin
  Timer := TStopwatch.Create;
end;
function TPrediction.Delta: Single;
begin
  if ETA > 0 then
    Result := Elapsed / ETA
  else
    Result := 1;
end;
function TPrediction.Elapsed: Integer;
begin
  Result := Timer.ElapsedTicks;
end;
function TPrediction.CanPredict: Boolean;
begin
  Result := ((ETA > 0) AND (Source.IsValid) AND (Destination.IsValid));
end;
function TPrediction.Interpolate(out d: Single): TPosition;
begin
  d := Delta;
  if (d >= 1) then
  begin
    ETA := 0;
    Result := Destination;
  end
  else
    Result := TPosition.Lerp(Source, Destination, d);
end;
procedure TPrediction.CalcETA(speed: Byte);
var
  Dist: WORD;
begin
  Dist := Source.Distance(Destination);
  speed := speed * 190;
  ETA := (AI_DELAY_MOVIMENTO + (Dist * (1000 - speed)));
end;
{$ENDREGION}
end.






