unit ItemFunctions;
interface
uses MiscData, Player, BaseMob, Windows, PlayerData, PacketHandlers,
 RoyaleHandler;
type


  TItemFunctions = class(TObject)

  public
    { Item Amount }
    class function GetItemAmount(item: TItem): BYTE; static;
    class procedure SetItemAmount(var item: TItem; quant: WORD;
      Somar: Boolean = False); static;
    class procedure DecreaseAmount(item: PItem; Quanti: WORD = 1); overload;
    class procedure DecreaseAmount(var Player: TPlayer; Slot: BYTE;
      Quanti: WORD = 1); overload;
    class function AgroupItem(SrcItem, DestItem: PItem): Boolean;
    { Item Price }
    class function GetBuyItemPrice(item: TItem; var Price: TItemPrice;
      quant: WORD = 1): Boolean;
    { Item Propertys }
    class function CanAgroup(item: TItem): Boolean; overload;
    class function CanAgroup(item: TItem; Quanti: WORD): Integer; overload;
    { Put e Remove item }
    class function PutItem(var Player: TPlayer; item: TItem;
      StartSlot: BYTE = 0; Notice: Boolean = False): Integer;overload;
    class function PutItem(var Player: TPlayer; Index: WORD; quant: WORD = 1)
      : Integer; overload;
    class function PutEquipament(var Player: TPlayer; Index: Integer;
      Refine: Integer = 0): Integer;
    class function RemoveItem(var Player: TPlayer;
      const SlotType, Slot: Integer): Boolean;
    class function PutItemOnEvent(var Player: TPlayer; ItemIndex: WORD; ItemAmount: WORD = 1)
      : Boolean;
    class function PutItemOnEventByCharIndex(var Player: TPlayer; CharIndex: Integer;
      ItemIndex: WORD): Boolean;
    { Item Duration }
    class function SetItemDuration(var item: TItem): Boolean;
    { Conjunt & Equip }
    class function GetItemEquipSlot(Index: Integer): Integer;
    class function GetItemEquipPranSlot(Index: Integer): Integer;
    class function GetConjuntCount(const BaseMB: TBaseMob;
      Index: Integer): Integer;
    class function GetItemBySlot(var Player: TPlayer; Slot: BYTE;
      out item: TItem): Boolean;
    class function GetClass(ClassInfo: Integer = 0): Integer;
    { Inventory Slots }
    class function GetInvItemCount(const Player: TPlayer): Integer;
    class function GetInvAvailableSlots(const Player: TPlayer): Integer;
    class function GetInvMaxSlot(const Player: TPlayer): Integer;
    class function GetInvPranMaxSlot(const Player: TPlayer): Integer;
    class function GetEmptySlot(const Player: TPlayer): BYTE; static;
    class function GetEmptyPranSlot(const Player: TPlayer): BYTE; static;
    class function VerifyItemSlot(var Player: TPlayer; Slot: Integer;
      const item: TItem): Boolean;
    class function VerifyBagSlot(const Player: TPlayer; Slot: Integer): Boolean;
    class function GetItemSlot(const Player: TPlayer; item: TItem;
      SlotType: BYTE; StartSlot: BYTE = 0): BYTE; static;
    class function GetItemSlot2(const Player: TPlayer; ItemID: WORD)
      : BYTE; static;
    class function GetItemSlotByItemType(const Player: TPlayer; ItemType: WORD;
      SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
    class function GetItemSlotAndAmountByIndex(const Player: TPlayer;
      ItemIndex: WORD; out Slot, Refi: BYTE): Boolean;
    class function GetItemReliquareSlot(const Player: TPlayer): Byte;
    class function GetItemThatExpires(const Player: TPlayer; SlotType: BYTE): Byte;
    { Ramdom Select Functions }
    class function SelectRamdomItem(const Items: ARRAY OF WORD;
      const Chances: ARRAY OF WORD): WORD;
    { Reinforce }
    class function GetResultRefineItem(const item: WORD; Extract: WORD;
      Refine: BYTE): BYTE;
    class function GetItemReinforceChance(const item: WORD; Refine: BYTE): WORD;
    class function ReinforceItem(var Player: TPlayer; item: DWORD; Item2: DWORD;
      Item3: DWORD): BYTE;
    class function GetArmorReinforceIndex(const item: WORD): WORD;
    class function GetReinforceCust(const Index: WORD): Cardinal;
    class function GetItemReinforce2Index(ItemIndex: WORD): WORD;
    class function GetItemReinforce3Index(ItemIndex: WORD): WORD;
    { Enchant }
    class function Enchantable(item: TItem): Boolean;
    class function GetEmptyEnchant(item: TItem): BYTE;
    class function EnchantItem(var Player: TPlayer; ItemSlot: DWORD;
      Item2: DWORD): BYTE;
    { Change App }
    class function Changeable(item: TItem): Boolean;
    class function ChangeApp(var Player: TPlayer; item: DWORD; Athlon: DWORD;
      NewApp: DWORD): BYTE;
    { Mount Enchant }
    class function EnchantMount(var Player: TPlayer; ItemSlot: DWORD;
      Item2: DWORD): BYTE;
    { Premium Inventory Function }
    class function FindPremiumIndex(Index: WORD): WORD;
    { Use item }
    class function UsePremiumItem(var Player: TPlayer; Slot: Integer): Boolean;
    class function UseItem(var Player: TPlayer; Slot: Integer;
      Type1: DWORD = 0): Boolean;
    { Item Reinforce Stats }
    class function GetItemReinforceDamageReduction(Index: WORD;
      Refine: BYTE): WORD;
    class function GetItemReinforceHPMPInc(Index: WORD; Refine: BYTE): WORD;
    class function GetReinforceFromItem(const item: TItem): BYTE;
    { ItemDB Functions }
    class function UpdateMovedItems(var Player: TPlayer;
      SrcItemSlot, DestItemSlot: BYTE; SrcSlotType, DestSlotType: BYTE;
      SrcItem, DestItem: PItem): Boolean;
    { Recipe Functions }
    class function GetIDRecipeArray(RecipeItemID: WORD): WORD;
  end;
implementation
uses GlobalDefs, Log, SysUtils, DateUtils, FilesData, Math, Util, SQL,
  NPCHandlers, Packets ;




  procedure LogItemUsage5251(str: String);
var
  NomeDoLog: string;
  Arquivo: TextFile;
begin
  NomeDoLog := GetCurrentDir + '\Logs\LogItem5251.txt';

  if not(DirectoryExists(GetCurrentDir + '\Logs')) then
    ForceDirectories(GetCurrentDir + '\Logs');

  AssignFile(Arquivo, NomeDoLog);
  if FileExists(NomeDoLog) then
    Append(Arquivo)
  else
    ReWrite(Arquivo);

  try
    WriteLn(Arquivo, str);
    WriteLn(Arquivo, '-------------------------------------------------------------------------------');
  finally
    CloseFile(Arquivo);
  end;
end;





{$REGION 'Item Amount'}
class function TItemFunctions.GetItemAmount(item: TItem): BYTE;
begin
  if ItemList[item.Index].CanAgroup then
  begin
    Result := item.Refi;
  end
  else
  begin
    Result := 1;
  end;
end;
class procedure TItemFunctions.SetItemAmount(var item: TItem; quant: WORD;
  Somar: Boolean = False);
begin
  if ItemList[item.Index].CanAgroup then
  begin
    if (Somar = True) then
    begin
      Inc(item.Refi, quant);
    end
    else
    begin
      item.Refi := quant;
    end;
  end
  else
  begin
    Exit;
  end;
end;
class procedure TItemFunctions.DecreaseAmount(item: PItem; Quanti: WORD = 1);
begin
  if (item.Refi - Quanti) > 0 then
  begin
    Dec(item.Refi, Quanti);
  end
  else
  begin
    ZeroMemory(item, sizeof(TItem));
  end;
end;
class procedure TItemFunctions.DecreaseAmount(var Player: TPlayer; Slot: BYTE;
  Quanti: WORD = 1);
var
  item: PItem;
begin
  item := @Player.Character.Base.Inventory[Slot];
  Self.DecreaseAmount(item, Quanti);
end;
class function TItemFunctions.AgroupItem(SrcItem: PItem;
  DestItem: PItem): Boolean;
var
  quant: WORD;
  Aux: TItem;
begin
  Result := False;
  if ItemList[SrcItem.Index].CanAgroup then
  begin
    if (SrcItem.Refi + DestItem.Refi) > MAX_SLOT_AMOUNT then
    begin
      if (SrcItem.Refi = 1000) or (DestItem.Refi = 1000) then
      begin
        Move(DestItem^, Aux, sizeof(TItem));
        Move(SrcItem^, DestItem^, sizeof(TItem));
        Move(Aux, SrcItem^, sizeof(TItem));
        Result := True;
        Exit;
      end;
      quant := (SrcItem.Refi + DestItem.Refi) - MAX_SLOT_AMOUNT;
      TItemFunctions.SetItemAmount(SrcItem^, MAX_SLOT_AMOUNT);
      TItemFunctions.SetItemAmount(DestItem^, quant);
    end
    else
    begin
      Inc(SrcItem^.Refi, DestItem^.Refi);
      ZeroMemory(DestItem, sizeof(TItem));
      Result := True;
      Exit;
    end;
  end
end;
{$ENDREGION}
{$REGION 'Item Price'}
class function TItemFunctions.GetBuyItemPrice(item: TItem;
  var Price: TItemPrice; quant: WORD = 1): Boolean;
begin
  if (ItemList[item.Index].TypePriceItem > 0) then
  begin
    Price.PriceType := PRICE_ITEM;
    Price.Value1 := ItemList[item.Index].TypePriceItem;
    Price.Value2 := ItemList[item.Index].TypePriceItemValue * quant;
    Result := True;
    Exit;
  end
  else if ((ItemList[item.Index].PriceHonor > 0) and (
    ItemList[item.Index].SellPrince = 0)) then
  begin
    Price.PriceType := PRICE_HONOR;
    Price.Value1 := ItemList[item.Index].PriceHonor * quant;
    Price.Value2 := ItemList[item.Index].PriceMedal * quant;
    Result := True;
    Exit;
  end
  else if (ItemList[item.Index].PriceMedal > 0) then
  begin
    Price.PriceType := PRICE_MEDAL;
    Price.Value1 := ItemList[item.Index].PriceMedal * quant;
    Price.Value2 := ItemList[item.Index].PriceGold * quant;
    Result := True;
    Exit;
  end
  else
  begin
    Price.PriceType := PRICE_GOLD;
    Price.Value1 := ItemList[item.Index].SellPrince * quant;
    Result := True;
    Exit;
  end;
end;
{$ENDREGION}
{$REGION 'Item Propertys'}
class function TItemFunctions.CanAgroup(item: TItem): Boolean;
begin
  if (ItemList[item.Index].CanAgroup) then
  begin
    Result := True;
    Exit;
  end;
  Result := False;
end;
class function TItemFunctions.CanAgroup(item: TItem; Quanti: WORD): Integer;
begin
  if not(ItemList[item.Index].CanAgroup) then
  begin
    Result := ITEM_UNAGRUPABLE;
  end
  else if (item.Refi + Quanti > 1000) then
  begin
    Result := ITEM_QUANT_EXCEDE;
  end
  else
  begin
    Result := ITEM_AGRUPABLE;
  end;
end;
{$ENDREGION}
{$REGION 'Put & Remove Item'}
class function TItemFunctions.PutItem(var Player: TPlayer; item: TItem;
  StartSlot: BYTE = 0; Notice: Boolean = False): Integer;
var
  Slot, InInventory: BYTE;
  quant, i, j: WORD;
  ItemInv: TItem;
begin
  Slot := 0;
  Result := -1;
  InInventory := Self.GetItemSlot(Player, item, INV_TYPE, StartSlot);
  if (ItemList[item.Index].Expires) and not(ItemList[item.Index].CanSealed) then
  begin
    Self.SetItemDuration(item);
  end;
  if (ItemList[item.Index].CanSealed) then
  begin
    item.IsSealed := True;
  end;
  case InInventory of
    0 .. 128:
      begin
        case Self.CanAgroup(Player.Character.Base.Inventory[InInventory],
          item.Refi) of
          ITEM_UNAGRUPABLE:
            begin
              Slot := Self.GetEmptySlot(Player);
              if (Slot = 255) then
              begin
                Player.SendClientMessage('Inventário cheio!');
                Exit;
              end;
              if (item.Index = 5300) then
              begin
                if (Player.Character.Base.Inventory[61].Index = 0) then
                  Slot := 61
                else if (Player.Character.Base.Inventory[62].Index = 0) then
                  Slot := 62
                else
                  Exit;
              end;
              Move(item, Player.Character.Base.Inventory[Slot], sizeof(TItem));
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot,
                Player.Character.Base.Inventory[Slot], Notice);
            end;
          ITEM_QUANT_EXCEDE:
            begin
              Move(item, ItemInv, sizeof(TItem));
              quant := MAX_SLOT_AMOUNT - Player.Character.Base.Inventory
                [InInventory].Refi;
              if (quant > 0) then
              begin
                Self.SetItemAmount(Player.Character.Base.Inventory[InInventory],
                  MAX_SLOT_AMOUNT);
                Player.Base.SendRefreshItemSlot(INV_TYPE, InInventory,
                  Player.Character.Base.Inventory[InInventory], Notice);
                Dec(ItemInv.Refi, quant);
                Result := Self.PutItem(Player, ItemInv, InInventory + 1);
              end
              else
              begin
                Result := Self.PutItem(Player, ItemInv, InInventory + 1);
              end;
            end;
          ITEM_AGRUPABLE:
            begin
              Self.SetItemAmount(Player.Character.Base.Inventory[InInventory],
                item.Refi, True);
              Player.Base.SendRefreshItemSlot(INV_TYPE, InInventory,
                Player.Character.Base.Inventory[InInventory], Notice);
            end;
        end;
      end;
    255:
      begin
        Slot := Self.GetEmptySlot(Player);
        Move(item, Player.Character.Base.Inventory[Slot], sizeof(TItem));
        Player.Base.SendRefreshItemSlot(INV_TYPE, Slot,
          Player.Character.Base.Inventory[Slot], Notice);
        if(ItemList[Player.Character.Base.Inventory[Slot].Index].ItemType = 40) then
        begin
          for I := Low(Servers) to High(Servers) do
          begin
            Servers[i].SendServerMsgForNation
              ('O jogador <'+AnsiString(Player.Base.Character.Name)+
              '> adquiriu o tesouro sagrado [' +
                AnsiString(ItemList[Player.Character.Base.Inventory[Slot].Index].Name) + '].'
                {'] do templo de ' +
                 AnsiString(
              Servers[Player.Channelindex].DevirNpc[Player.OpennedTemple].
              PlayerChar.Base.PranName[0])}, Integer(
              Player.Account.Header.Nation), 16, 32, 16);
          end;
          Player.SendEffect(32);
        end;
      end;
  end;







  if (Result = -1) and (Slot <> 255) then
    Result := Slot;
end;
class function TItemFunctions.PutItem(var Player: TPlayer;
  Index, quant: WORD): Integer;
var
  item: TItem;
begin
  ZeroMemory(@item, sizeof(item));
  item.Index := Index;
  item.APP := Index;
  item.Refi := quant;
  item.MIN := ItemList[item.Index].Durabilidade;
  item.MAX := item.MIN;
  Result := Self.PutItem(Player, item, 0, True)
end;
class function TItemFunctions.PutEquipament(var Player: TPlayer; Index: Integer;
  Refine: Integer = 0): Integer;
var
  item: TItem;
begin
  ZeroMemory(@item, sizeof(TItem));
  item.Index := Index;
  item.APP := Index;
  item.MAX := ItemList[item.Index].Durabilidade;
  item.MIN := item.MAX;
  item.Refi := Refine;
  Result := Self.PutItem(Player, item, 0, True)
end;
class function TItemFunctions.RemoveItem(var Player: TPlayer;
  const SlotType, Slot: Integer): Boolean;
var
  item: PItem;
begin
  Result := False;
  item := Nil;
  case SlotType of
    INV_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 63) then
        begin
          item := @Player.Character.Base.Inventory[Slot];
        end
        else
          Exit;
      end;
    STORAGE_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 83) then
        begin
          item := @Player.Account.Header.Storage.Itens[Slot];
        end
        else
          Exit;
      end;
    CASH_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 23) then
        begin
          item^ := Player.Account.Header.CashInventory.Items[Slot].ToItem;
        end
        else
          Exit;
      end;
    EQUIP_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 15) then
        begin
          item := @Player.Character.Base.Equip[Slot];
        end
        else
          Exit;
      end;
    PRAN_EQUIP_TYPE:
      begin
        if(Player.SpawnedPran = 255) then
          Exit;

        case Player.SpawnedPran of
          0:
          begin
            if (Slot >= 1) and (Slot <= 5) then
            begin
              item := @Player.Account.Header.Pran1.Equip[Slot];
            end
            else
              Exit;
          end;

          1:
          begin
            if (Slot >= 1) and (Slot <= 5) then
            begin
              item := @Player.Account.Header.Pran2.Equip[Slot];
            end
            else
              Exit;
          end;
        end;


      end;
    PRAN_INV_TYPE:
      begin
        if(Player.SpawnedPran = 255) then
          Exit;

        case Player.SpawnedPran of
          0:
          begin
            if (Slot >= 0) and (Slot <= 41) then
            begin
              item := @Player.Account.Header.Pran1.Inventory[Slot];
            end
            else
              Exit;
          end;

          1:
          begin
            if (Slot >= 0) and (Slot <= 41) then
            begin
              item := @Player.Account.Header.Pran2.Inventory[Slot];
            end
            else
              Exit;
          end;
        end;
      end;

  else
    begin
      Exit;
    end;
  end;
  if (item = Nil) then
    Exit;

    // Log para o item 5251
  if item^.Index = 5251 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;


    // Log para o item  9548
  if item^.Index = 9548 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;


    // Log para o item 9839
  if item^.Index = 9839 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;


    // Log para o item 8865
  if item^.Index = 8865 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;


    // Log para o item 9839
  if item^.Index = 9839 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;


    // Log para o item 8864
  if item^.Index = 5251 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 17001
  if item^.Index = 17001 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 17002
  if item^.Index = 17002 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

   // Log para o item 14139
  if item^.Index = 14139 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 14140
  if item^.Index = 14140 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 14141
  if item^.Index = 14141 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 10295
  if item^.Index = 10295 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 10296
  if item^.Index = 10296 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 14148
  if item^.Index = 14148 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 14149
  if item^.Index = 14149 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 14150
  if item^.Index = 14150 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 14151
  if item^.Index = 14151 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 14153
  if item^.Index = 14153 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 14154
  if item^.Index = 14154 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 14155
  if item^.Index = 14155 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 14156
  if item^.Index = 14156 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;

  // Log para o item 14158
  if item^.Index = 14158 then
  begin
    LogItemUsage5251(Format('O item id: %d foi removido do slot %d do Player %s na data %s. Quantidade: %d',
      [item^.Index, Slot, Player.Account.Header.Username, DateTimeToStr(Now), item^.Refi]));
  end;



  ZeroMemory(item, sizeof(TItem));
  Player.Base.SendRefreshItemSlot(SlotType, Slot, item^, False);
  Result := True;
end;
class function TItemFunctions.PutItemOnEvent(var Player: TPlayer;
  ItemIndex: WORD; ItemAmount: WORD): Boolean;
var
  SQLComp: TQuery;
  charid: Integer;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[PutItemOnEvent]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[PutItemOnEvent]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    if(Player.Base.Character.CharIndex = 0) then
      charid := Player.Account.Characters[0].Index
    else
      charid := Player.Base.Character.CharIndex;

    SQLComp.SetQuery
      (format('INSERT INTO items (slot_type, owner_id, item_id, refine, slot) VALUES '
      + '(%d, %d, %d, %d, 1)', [EVENT_ITEM, charid, ItemIndex, ItemAmount]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.PutItemOnEvent ' + E.Message,
        TLogType.Error);
    end;
  end;
  SQLComp.Destroy;
end;
class function TItemFunctions.PutItemOnEventByCharIndex(var Player: TPlayer; CharIndex: Integer;
  ItemIndex: WORD): Boolean;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[PutItemOnEventByCharIndex]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[PutItemOnEventByCharIndex]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      (format('INSERT INTO items (slot_type, owner_id, item_id, refine, slot) VALUES '
      + '(%d, %d, %d, %d, 0)', [EVENT_ITEM, CharIndex, ItemIndex, 1]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.PutItemOnEvent ' + E.Message,
        TLogType.Error);
    end;
  end;
  SQLComp.Destroy;
end;
{$ENDREGION}
{$REGION 'Item Duration'}
class function TItemFunctions.SetItemDuration(var item: TItem): Boolean;
begin
  Result := True;
  if (ItemList[item.Index].Expires) then
  begin
    item.ExpireDate := IncHour(Now, ItemList[item.Index].Duration + 2);
  end
  else
  begin
    Result := False;
  end;
end;
{$ENDREGION}
{$REGION 'Conjunt & Equip'}
class function TItemFunctions.GetItemEquipSlot(Index: Integer): Integer;
begin
  Result := 0;
  if (ItemList[Index].ItemType = 50) or (ItemList[Index].ItemType = 52) then
  begin
    Result := 15;
  end;
  if (ItemList[Index].ItemType > 0) and (ItemList[Index].ItemType < 16) then
  begin
    Result := ItemList[Index].ItemType;
    Exit;
  end
  else if (ItemList[Index].ItemType > 1000) and (ItemList[Index].ItemType < 1011)
  then
  begin
    Result := 6;
    Exit;
  end;
end;
class function TItemFunctions.GetItemEquipPranSlot(Index: Integer): Integer;
begin
  Result := ItemList[Index].ItemType - 18;
end;
class function TItemFunctions.GetConjuntCount(const BaseMB: TBaseMob;
  Index: Integer): Integer;
var
  Count, Conjunt: Integer;
  i: Integer;

begin
  Conjunt := Conjuntos[Index];
  Count := 0;
  for i := 0 to 15 do
  begin
   if BaseMB.EQUIP_CONJUNT[i] = Conjunt then
      Inc(Count, 1);
  end;
  Result := Count;
end;
class function TItemFunctions.GetItemBySlot(var Player: TPlayer; Slot: BYTE;
  out item: TItem): Boolean;
begin
  Result := False;
  if (Slot > 63) then
    Exit;
  item := Player.Base.Character.Inventory[Slot];
  Result := True;
end;
class function TItemFunctions.GetClass(ClassInfo: Integer = 0): Integer;
begin
  Result := 0;
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
{$ENDREGION}
{$REGION 'Inventory Slots'}
class function TItemFunctions.VerifyItemSlot(var Player: TPlayer; Slot: Integer;
  const item: TItem): Boolean;
var
  OriginalItem: TItem;
begin
  ZeroMemory(@OriginalItem, sizeof(TItem));
  OriginalItem := Player.Character.Base.Inventory[Slot];
  Result := False;
  if not(CompareMem(@OriginalItem, @item, sizeof(TItem))) then
    Exit;
  Result := True;
end;
class function TItemFunctions.GetInvItemCount(const Player: TPlayer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Self.GetInvMaxSlot(Player) do
  begin
    if (Player.Character.Base.Inventory[i].Index > 0) then
    begin
      Inc(Result);
    end;
  end;
end;
class function TItemFunctions.GetInvAvailableSlots(const Player
  : TPlayer): Integer;
var
  Used: Integer;
  Available: Integer;
begin
  Used := Self.GetInvItemCount(Player);
  Available := 15;
  if Player.Character.Base.Inventory[61].Index > 0 then
    Inc(Available, 15);
  if Player.Character.Base.Inventory[62].Index > 0 then
    Inc(Available, 15);
  if Player.Character.Base.Inventory[63].Index > 0 then
    Inc(Available, 15);
  Result := Available - Used;
end;
class function TItemFunctions.GetInvMaxSlot(const Player: TPlayer): Integer;
begin
  Result := 14;
  if Player.Character.Base.Inventory[61].Index > 0 then
    Result := 29;
  if Player.Character.Base.Inventory[62].Index > 0 then
    Result := 44;
  if Player.Character.Base.Inventory[63].Index > 0 then
    Result := 59;
end;
class function TItemFunctions.GetInvPranMaxSlot(const Player: TPlayer): Integer;
begin
  Result := 19;
  case Player.SpawnedPran of
    0:
      begin
        if(Player.Account.Header.Pran1.Inventory[41].Index > 0) then
          Result := 39;
      end;
    1:
      begin
        if(Player.Account.Header.Pran2.Inventory[41].Index > 0) then
          Result := 39;
      end;
  end;
end;
class function TItemFunctions.GetEmptySlot(const Player: TPlayer): BYTE;
var
  i: BYTE;
  MAX_SLOT: BYTE;

begin
  Result := 255;
  MAX_SLOT := GetInvMaxSlot(Player);
  for i := 0 to MAX_SLOT do
  begin
    if Player.Character.Base.Inventory[i].Index <> 0 then
      Continue;
    case i of
      0 .. 14:
        begin
          Result := i;
          Exit;
        end;
      15 .. 29:
        begin
          if (Player.Character.Base.Inventory[61].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
      30 .. 44:
        begin
          if (Player.Character.Base.Inventory[62].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
      45 .. 59:
        begin
          if (Player.Character.Base.Inventory[63].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
    end;
  end;
  


end;



class function TItemFunctions.GetEmptyPranSlot(const Player: TPlayer): BYTE;
var
  i: BYTE;
  MAX_SLOT: BYTE;
begin
  Result := 255;
  MAX_SLOT := GetInvPranMaxSlot(Player);
  case Player.SpawnedPran of
    0:
      begin
        for i := 0 to MAX_SLOT do
        begin
          if (Player.Account.Header.Pran1.Inventory[i].Index <> 0) then
            Continue;
          case i of
            0..19:
              begin
                Result := i;
                Exit;
              end;
            20..39:
              begin
                if(Player.Account.Header.Pran1.Inventory[41].Index <> 0) then
                begin
                  Result := i;
                  Exit;
                end;
              end;
          end;
        end;
      end;
    1:
      begin
        for i := 0 to MAX_SLOT do
        begin
          if (Player.Account.Header.Pran2.Inventory[i].Index <> 0) then
            Continue;
          case i of
            0..19:
              begin
                Result := i;
                Exit;
              end;
            20..39:
              begin
                if(Player.Account.Header.Pran2.Inventory[41].Index <> 0) then
                begin
                  Result := i;
                  Exit;
                end;
              end;
          end;
        end;
      end;
  end;
end;
class function TItemFunctions.VerifyBagSlot(const Player: TPlayer;
  Slot: Integer): Boolean;
begin
  Result := False;
  case Slot of
    0 .. 14:
      Result := True;
    15 .. 29:
      begin
        if (Player.Character.Base.Inventory[61].Index > 0) then
          Result := True;
      end;
    30 .. 44:
      if (Player.Character.Base.Inventory[62].Index > 0) then
        Result := True;
    45 .. 59:
      if (Player.Character.Base.Inventory[63].Index > 0) then
        Result := True;
  end;
end;
class function TItemFunctions.GetItemSlot(const Player: TPlayer; item: TItem;
  SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
var
  i: Integer;
begin
  case SlotType of
    INV_TYPE:
      begin
        for i := StartSlot to 63 do
        begin
          if Player.Character.Base.Inventory[i].Index <> item.Index then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
       
      end;
    EQUIP_TYPE:
      begin
        for i := StartSlot to 15 do
        begin
          if Player.Character.Base.Equip[i].Index <> item.Index then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;

      end;
    STORAGE_TYPE:
      begin
        for i := StartSlot to 85 do
        begin
          if Player.Account.Header.Storage.Itens[i].Index <> item.Index then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;

      end;
  end;
  Result := 255;
end;
class function TItemFunctions.GetItemSlot2(const Player: TPlayer;
  ItemID: WORD): BYTE;
var
  i: BYTE;
begin
  Result := 255;
  for i := 0 to 59 do // inventory
  begin
    if (Player.Character.Base.Inventory[i].Index = ItemID) then
    begin
      Result := i;

      Break;
    end
    else
    begin
      Continue;
    end;
  end;
end;
class function TItemFunctions.GetItemSlotByItemType(const Player: TPlayer;
  ItemType: WORD; SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
var
  i: Integer;

begin
  case SlotType of
    INV_TYPE:
      begin
        for i := StartSlot to 63 do
        begin
          if ItemList[Player.Character.Base.Inventory[i].Index].ItemType <> ItemType
          then
          begin
            Continue;
          end;
          Result := i;



          exit
        end;
      end;
    EQUIP_TYPE:
      begin
        for i := StartSlot to 15 do
        begin
          if ItemList[Player.Character.Base.Equip[i].Index].ItemType <> ItemType
          then
          begin
            Continue;
          end;
          Result := i;

                  Exit;
        end;
      end;
    STORAGE_TYPE:
      begin
        for i := StartSlot to 85 do
        begin
          if ItemList[Player.Account.Header.Storage.Itens[i].Index].ItemType <> ItemType
          then
          begin
            Continue;
          end;
          Result := i;
          
          Exit;
        end;
      end;
  end;
  Result := 255;
end;
class function TItemFunctions.GetItemSlotAndAmountByIndex(const Player: TPlayer;
  ItemIndex: WORD; out Slot, Refi: BYTE): Boolean;
var
  i: WORD;
begin
  Result := False;
  for i := 0 to 59 do
  begin
    if (Player.Base.Character.Inventory[i].Index = ItemIndex) then
    begin
      Result := True;
      Slot := i;
      Refi := Player.Base.Character.Inventory[i].Refi;
      Break;
    end
    else
      Continue;
  end;
end;
class function TItemFunctions.GetItemReliquareSlot(const Player: TPlayer): Byte;
var
  i: Byte;
begin
  Result := 255;
  for I := 0 to 59 do
  begin
    if(Player.base.character.inventory[i].Index = 0) then
      Continue;
    if(ItemList[Player.base.character.inventory[i].Index].ItemType = 40) then
    begin
      Result := i;
      break;
    end;
  end;
end;
class function TItemFunctions.GetItemThatExpires(const Player: TPlayer; SlotType: BYTE): Byte;
var
  i: Byte;
  Item: PItem;
begin
  Result := 255;
  case SlotType of
    INV_TYPE:
      begin
        for I := 0 to 59 do
        begin
          Item := @Player.Base.Character.Inventory[i];
          if(item.Index = 0) then
            Continue;
          if(ItemList[item.Index].Expires) then
          begin
            Result := i;
            Break;
          end;
        end;
      end;
    EQUIP_TYPE:
      begin
        for I := 0 to 15 do
        begin
          Item := @Player.Base.Character.Equip[i];
          if(item.Index = 0) then
            Continue;
          if(ItemList[item.Index].Expires) then
          begin
            Result := i;
            Break;
          end;
        end;
      end;
  end;
end;
{$ENDREGION}
{$REGION 'Ramdom Select Functions'}
class function TItemFunctions.SelectRamdomItem(const Items: ARRAY OF WORD;
  const Chances: ARRAY OF WORD): WORD;
var
  RandomTax, cnt: BYTE;
  RamdomArray: ARRAY OF WORD;
  i, j: Integer;
  RamdomSlot: Integer;
begin
  Result := 0;
  try
    Randomize;
    RandomTax := Random(100);
    cnt := 0;
    for i := 0 to Length(Items) - 1 do
    begin
      if (RandomTax <= Chances[i]) then
      begin
        SetLength(RamdomArray, cnt + 1);
        RamdomArray[cnt] := Items[i];
        Inc(cnt);
      end
      else
        Continue;
    end;
    if(Length(RamdomArray) = 0) then
    begin
      Randomize;
      RamdomSlot := RandomRange(0, Length(Items));
      Result := Items[RamdomSlot];
    end
    else
    begin
      Randomize;
      RamdomSlot := RandomRange(0, Length(RamdomArray));
      Result := RamdomArray[RamdomSlot];
    end;
  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.SelectRamdomItem ' + E.Message,
        TLogType.Error);
      Logger.Write('TItemFunctions.SelectRamdomItem ' + E.Message,
        TLogType.Warnings);
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Reinforce'}
class function TItemFunctions.GetResultRefineItem(const item: WORD;
  Extract: WORD; Refine: BYTE): BYTE;
var
  //RamdomArray: ARRAY [0 .. 999] OF BYTE;
  RamdomSlot: Integer;
  Chance{, BreakChance, ReduceChance}: WORD;
{  procedure SetChance(const Chance: WORD; const Type1: BYTE);
  var
    i: Integer;
  begin
    if (Chance = 0) then
      Exit;
    for i := 0 to Chance - 1 do
    begin
      RamdomSlot := Random(1000);
      while (RamdomArray[RamdomSlot] <> 3) do
      begin
        RamdomSlot := Random(1000);
      end;
      RamdomArray[RamdomSlot] := Type1;
    end;
  end;  }
begin
  //FillMemory(@RamdomArray, Length(RamdomArray), $3);
  { Pega a chance de refine }
  //Self.GetItemReinforceChance(item, Refine);
  //0 volta -2
  //1 volta -1
  //2 sucesso
  if(Refine <= 0) then
    Chance := ChancesOfRefinament[Refine]
  else
    Chance := ChancesOfRefinament[Refine-1];

  Randomize;
  RamdomSlot := 100;
  RamdomSlot := RandomRange(1, 101);

  if(ItemList[item].Rank > 0) then
    RamdomSlot := RamdomSlot * ItemList[item].Rank;

  if(RamdomSlot <= Chance) then
  begin //deu bom
    Result := 2;
    Exit;
  end
  else
  begin
    case Refine of
      0..3: //de +0 até +3
      begin  //100% de chance, impossivel voltar
        Result := 2;
        Exit;
      end;
      4..5: //de +4 até +6
      begin
        if(Extract = 0) then
        begin
          Result := 1;
          Exit;
        end;
        case ItemList[Extract].ItemType of
          63, 65: //extrato normal
          begin
            Result := 1;
            Exit;
          end;
          64, 66: //extrato enriquecido
          begin
            Result := 3;
            Exit;
          end;
        end;
      end;
      6..16: //de +7 até +11
      begin
         if(Extract = 0) then
        begin
          Result := 0;
          Exit;
        end;
        case ItemList[Extract].ItemType of
          63, 65: //extrato normal
          begin
            Result := 1;
            Exit;
          end;
          64, 66: //extrato enriquecido
          begin
            Result := 3;
            Exit;
          end;
        end;
      end;
    end;
  end;
{$REGION 'Seta as Chances'}
 { BreakChance := Trunc((1000 - Chance) / 3);
  ReduceChance := BreakChance;
  case ItemList[Extract].ItemType of
    63:
      begin
        BreakChance := 0;
      end;
    65:
      begin
        BreakChance := 0;
      end;
    64:
      begin
        BreakChance := 0;
        ReduceChance := 0;
      end;
    66:
      begin
        BreakChance := 0;
        ReduceChance := 0;
      end;
  end;       }
{$ENDREGION}
{$REGION 'Seta as Chances na array'}
{  Randomize;
  SetChance(BreakChance, 0);
  SetChance(ReduceChance, 1);
  SetChance(Chance, 2);
                          }
{$ENDREGION}
  //RamdomSlot := Random(1000);
  //Result := RamdomArray[RamdomSlot];
end;
class function TItemFunctions.GetItemReinforceChance(const item: WORD;
  Refine: BYTE): WORD;
begin
  Result := 0;
  if (ItemList[item].UseEffect <= 0) then
    Exit;
  case Self.GetItemEquipSlot(item) of
    0 .. 5:
      begin
        Result := ReinforceA01[ItemList[item].UseEffect].Chance[Refine];
      end;
    6:
      begin
        Result := ReinforceW01[ItemList[item].UseEffect].Chance[Refine];
      end;
    7:
      begin
        Result := ReinforceA01[ItemList[item].UseEffect].Chance[Refine];
      end;
  else
    begin
      Result := 0;
    end;
  end;
end;
class function TItemFunctions.ReinforceItem(var Player: TPlayer; item: DWORD;
  Item2: DWORD; Item3: DWORD): BYTE;
var
  ItemIndex: Integer;
  HiraKaize: PItem;
  Extract: Integer;
  Refine: Integer;
begin
  Result := 4;
  ItemIndex := Player.Character.Base.Inventory[item].Index;
  HiraKaize := @Player.Character.Base.Inventory[Item2];
  if (Item3 = $FFFFFFFF) then
  begin
    Extract := 0;
  end
  else
  begin
    Extract := Player.Character.Base.Inventory[Item3].Index;
  end;
{$REGION 'Checagens Importantes'}
  if (ItemList[HiraKaize.Index].Rank < ItemList[ItemIndex].Rank) then
  begin
    Exit;
  end;
  if (Extract > 0) and (ItemList[Extract].Rank < ItemList[ItemIndex].Rank) then
  begin
    Exit;
  end;
  if (Self.GetReinforceCust(ItemIndex) > Player.Character.Base.Gold ) then
  begin
    Result := 5;
    Exit;
  end;
  if(Player.Character.Base.Inventory[item].Refi >= 175) then
  begin
    Result := 6;
    Exit;
  end;
{$ENDREGION}
  if not(ItemList[ItemIndex].Fortification) then
  begin
    if not(HiraKaize.Refi > 0) then
    begin
      Exit;
    end;
    if (Extract > 0) then
    begin
      if (Player.Base.Character.Inventory[Item3].Refi > 0) then
      begin
        Self.DecreaseAmount(Player, Item3);
      end
      else
      begin
        Exit;
      end;
    end;
    Self.DecreaseAmount(HiraKaize);
    Dec(Player.Base.Character.Gold, Self.GetReinforceCust(ItemIndex));
    Result := Self.GetResultRefineItem(ItemIndex, Extract,
      Trunc(Player.Character.Base.Inventory[item].Refi / $10));
    case Result of
      0:
        begin
          ZeroMemory(@Player.Character.Base.Inventory[item], sizeof(TItem));
          //Dec(Player.Character.Base.Inventory[item].Refi, 32);
        end;
      1:
        begin
          Dec(Player.Character.Base.Inventory[item].Refi, $10);
        end;
      2:
        begin
          Inc(Player.Character.Base.Inventory[item].Refi, $10);
        end;
      3:
      begin
        Player.SendClientMessage('Refinação falhou. O item não será destruido.');
        Exit;
      end;
    end;
  end
  else
  begin
    Player.SendClientMessage('Esse item não pode ser refinado.');
    Exit;
  end;
  if(Player.Character.Base.Inventory[item].Index = 0) then
  begin
    Player.Base.SendRefreshItemSlot(INV_TYPE, item, Player.Character.Base.Inventory[item],
      False);
  end
  else
  begin
    Refine := Round(Player.Character.Base.Inventory[item].Refi / 16);
    if (Result = 2) and (Refine >= 11) then
    begin
      Servers[Player.ChannelIndex].SendServerMsg
        (AnsiString(string(Player.Character.Base.Name) + ' refinou com sucesso ' +
        string(ItemList[ItemIndex].Name) + ' +' + Refine.ToString), 16, 0, 0,
        False, Player.Base.ClientID);
    end;
  end;
end;
class function TItemFunctions.GetArmorReinforceIndex(const item: WORD): WORD;
  function GetRefineClass(Classe: BYTE): BYTE;
  begin
    Result := 6;
    case Classe of
      01 .. 10:
        Result := 1;
      11 .. 20:
        Result := 0;
      21 .. 30:
        Result := 2;
      31 .. 40:
        Result := 3;
      41 .. 50:
        Result := 4;
      51 .. 60:
        Result := 5;
    end;
  end;
var
  ItemType: WORD;
begin
  Result := 0;
  if not(ItemList[item].ItemType >= 2) and not(ItemList[item].ItemType <= 7)
  then
    Exit;
  ItemType := ItemList[item].ItemType;
  if (ItemType = 7) then
    ItemType := 6;
  Result := ((ItemType - 2) * 30) + ItemList[item].UseEffect;
end;
class function TItemFunctions.GetReinforceCust(const Index: WORD): Cardinal;
begin
  case Self.GetItemEquipSlot(Index) of
    2 .. 5:
      begin
        Result := ReinforceA01[ItemList[Index].UseEffect-1].ReinforceCust * CUSTO_REFIN ;
      end;
    6:
      begin
        Result := ReinforceW01[ItemList[Index].UseEffect-1].ReinforceCust * CUSTO_REFIN;
      end;
    7:
      begin
        Result := ReinforceA01[ItemList[Index].UseEffect-1].ReinforceCust * CUSTO_REFIN;
      end;
  else
    begin
      Result := 0;
    end;
  end;
end;
class function TItemFunctions.GetItemReinforce2Index(ItemIndex: WORD): WORD;
var
  ReinforceIndex: WORD;
  ItemUseEffect: WORD;
  ClassInfo: BYTE;
  EquipSlot: BYTE;
begin
  ReinforceIndex := 0;
  ItemUseEffect := ItemList[ItemIndex].UseEffect;
  case ItemUseEffect of
    0 .. 35:
      ReinforceIndex := reinforce2sectionSize * 0;
    36 .. 70:
      begin
        ReinforceIndex := reinforce2sectionSize * 1;
        Dec(ReinforceIndex, 35);
      end;
    71 .. 105:
      begin
        ReinforceIndex := reinforce2sectionSize * 2;
        Dec(ReinforceIndex, 70);
      end;
  end;
  ClassInfo := Self.GetClass(ItemList[ItemIndex].Classe);
  EquipSlot := Self.GetItemEquipSlot(ItemIndex);
  if (EquipSlot = 6) then
  begin
    case ClassInfo of
      0:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Sword));
        end;
      1:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Blade));
        end;
      2:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Rifle));
        end;
      3:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Pistol));
        end;
      4:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Staff));
        end;
      5:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Wand));
        end;
    end;
    Result := (ReinforceIndex + ItemUseEffect);
    Exit;
  end;
  case EquipSlot of
    2:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Helmet) + (ClassInfo * 30)));
      end;
    3:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Armor) + (ClassInfo * 30)));
      end;
    4:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Gloves) + (ClassInfo * 30)));
      end;
    5:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Shoes) + (ClassInfo * 30)));
      end;
    7:
      begin
        Inc(ReinforceIndex, WORD(Reinforce2_Area_Shield));
      end;
  end;
  Result := (ReinforceIndex + ItemUseEffect);
end;
class function TItemFunctions.GetItemReinforce3Index(ItemIndex: WORD): WORD;
var
  ReinforceIndex: WORD;
  ItemUseEffect: WORD;
  EquipSlot: BYTE;
begin
  ReinforceIndex := 0;
  ItemUseEffect := ItemList[ItemIndex].UseEffect;
  case ItemUseEffect of
    0 .. 35:
      ReinforceIndex := reinforce3sectionSize * 0;
    36 .. 70:
      begin
        ReinforceIndex := reinforce3sectionSize * 1;
        Dec(ReinforceIndex, 35);
      end;
    71 .. 105:
      begin
        ReinforceIndex := reinforce3sectionSize * 2;
        Dec(ReinforceIndex, 70);
      end;
  end;
  EquipSlot := Self.GetItemEquipSlot(ItemIndex);
  case (EquipSlot) of
    2:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Helmet));
    3:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Armor));
    4:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Gloves));
    5:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Shoes));
    7:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Shield));
  end;
  Result := (ReinforceIndex + ItemUseEffect);
end;
{$ENDREGION}
{$REGION 'Enchant'}
class function TItemFunctions.Enchantable(item: TItem): Boolean;
var
  i: BYTE;
begin
  Result := False;
  for i := 0 to 2 do
  begin
    if (item.Effects.Index[i] = 0) then
    begin
      Result := True;
      Break;
    end
    else
      Continue;
  end;
end;
class function TItemFunctions.GetEmptyEnchant(item: TItem): BYTE;
var
  i: BYTE;
begin
  Result := 255;
  for i := 0 to 2 do
  begin
    if (item.Effects.Index[i] = 0) then
    begin
      Result := i;
      Break;
    end
    else
      Continue;
  end;
end;
class function TItemFunctions.EnchantItem(var Player: TPlayer;
  ItemSlot, Item2: DWORD): BYTE;
var
  EmptyEnchant: BYTE;
  EnchantIndex, EnchantValue: WORD;
  ItemSlotType: Integer;
  R1, RandomEnch, OldRandomEnch: Integer;
  i: Integer;
begin
  Result := 0;
  if (Player.Base.Character.Inventory[ItemSlot].Index = 0) then
    Exit;
  if (Player.Base.Character.Inventory[Item2].Index = 0) then
    Exit;
  if (Self.Enchantable(Player.Base.Character.Inventory[ItemSlot])) then
  begin
    if (ItemList[Player.Base.Character.Inventory[Item2].Index].ItemType = 508)
    then
    begin
      if (ItemList[Player.Base.Character.Inventory[Item2].Index].EF[0] = 0) then
      begin
        ItemSlotType := Self.GetItemEquipSlot(Player.Base.Character.Inventory
          [ItemSlot].Index);
        Randomize;
        RandomEnch := 0;
        case ItemSlotType of
          2 .. 5, 7:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  begin
                    R1 := RandomRange(0, Length(VaizanP_Set));
                    RandomEnch := VaizanP_Set[R1];
                  end;
                5321:
                  begin
                    R1 := RandomRange(0, Length(VaizanM_Set));
                    RandomEnch := VaizanM_Set[R1];
                  end;
                5322:
                  begin
                    R1 := RandomRange(0, Length(VaizanG_Set));
                    RandomEnch := VaizanG_Set[R1];
                  end;
              end;
            end;
          6:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  begin
                    R1 := RandomRange(0, Length(VaizanP_Wep));
                    RandomEnch := VaizanP_Wep[R1];
                  end;
                5321:
                  begin
                    R1 := RandomRange(0, Length(VaizanM_Wep));
                    RandomEnch := VaizanM_Wep[R1];
                  end;
                5322:
                  begin
                    R1 := RandomRange(0, Length(VaizanG_Wep));
                    RandomEnch := VaizanG_Wep[R1];
                  end;
              end;
            end;
          11 .. 14:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  begin
                    R1 := RandomRange(0, Length(VaizanP_Acc));
                    RandomEnch := VaizanP_Acc[R1];
                  end;
                5321:
                  begin
                    R1 := RandomRange(0, Length(VaizanM_Acc));
                    RandomEnch := VaizanM_Acc[R1];
                  end;
                5322:
                  begin
                    R1 := RandomRange(0, Length(VaizanG_Acc));
                    RandomEnch := VaizanG_Acc[R1];
                  end;
              end;
            end;
        end;
        EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
          [ItemSlot]);
        if (EmptyEnchant = 255) then
        begin
          Result := 1; // SendPlayerError
          Exit;
        end;
        for I := 0 to 2 do
        begin
          if(Player.Character.Base.Inventory[ItemSlot].Effects.Index[i] =
            ItemList[RandomEnch].EF[0]) then
          begin
            OldRandomEnch := RandomEnch;

            case ItemSlotType of
              2 .. 5, 7:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      begin
                        R1 := RandomRange(0, Length(VaizanP_Set));
                        RandomEnch := VaizanP_Set[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanP_Set[R1-1]
                          else
                            RandomEnch := VaizanP_Set[R1+1];
                        end;
                      end;
                    5321:
                      begin
                        R1 := RandomRange(0, Length(VaizanM_Set));
                        RandomEnch := VaizanM_Set[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanM_Set[R1-1]
                          else
                            RandomEnch := VaizanM_Set[R1+1];
                        end;
                      end;
                    5322:
                      begin
                        R1 := RandomRange(0, Length(VaizanG_Set));
                        RandomEnch := VaizanG_Set[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanG_Set[R1-1]
                          else
                            RandomEnch := VaizanG_Set[R1+1];
                        end;
                      end;
                  end;
                end;
              6:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      begin
                        R1 := RandomRange(0, Length(VaizanP_Wep));
                        RandomEnch := VaizanP_Wep[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanP_Wep[R1-1]
                          else
                            RandomEnch := VaizanP_Wep[R1+1];
                        end;
                      end;
                    5321:
                      begin
                        R1 := RandomRange(0, Length(VaizanM_Wep));
                        RandomEnch := VaizanM_Wep[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanM_Wep[R1-1]
                          else
                            RandomEnch := VaizanM_Wep[R1+1];
                        end;
                      end;
                    5322:
                      begin
                        R1 := RandomRange(0, Length(VaizanG_Wep));
                        RandomEnch := VaizanG_Wep[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanG_Wep[R1-1]
                          else
                            RandomEnch := VaizanG_Wep[R1+1];
                        end;
                      end;
                  end;
                end;
              11 .. 14:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      begin
                        R1 := RandomRange(0, Length(VaizanP_Acc));
                        RandomEnch := VaizanP_Acc[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanP_Acc[R1-1]
                          else
                            RandomEnch := VaizanP_Acc[R1+1];
                        end;
                      end;
                    5321:
                      begin
                        R1 := RandomRange(0, Length(VaizanM_Acc));
                        RandomEnch := VaizanM_Acc[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanM_Acc[R1-1]
                          else
                            RandomEnch := VaizanM_Acc[R1+1];
                        end;
                      end;
                    5322:
                      begin
                        R1 := RandomRange(0, Length(VaizanG_Acc));
                        RandomEnch := VaizanG_Acc[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanG_Acc[R1-1]
                          else
                            RandomEnch := VaizanG_Acc[R1+1];
                        end;
                      end;
                  end;
                end;
            end;
            //Result := 4; // SendPlayerMessage
            //Exit;
          end;
        end;
        EnchantIndex := ItemList[RandomEnch].EF[0];
        EnchantValue := ItemList[RandomEnch].EFV[0];
        Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
          EnchantIndex;
        Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
          (EnchantValue);
        Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
      end
      else
      begin
        EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
          [ItemSlot]);
        if (EmptyEnchant = 255) then
        begin
          Result := 1; // SendPlayerError
          Exit;
        end;
        for I := 0 to 2 do
        begin
          if(Player.Character.Base.Inventory[ItemSlot].Effects.Index[i] =
            ItemList[Player.Base.Character.Inventory[Item2].
          Index].EF[0]) then
          begin
            if not(ItemList[Player.Base.Character.Inventory[Item2].
              Index].ItemType = 33) then //pular se for estrela da pran
            begin
              Result := 3; // SendPlayerMessage
              Exit;
            end;
          end;
        end;
        EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
          Index].EF[0];
        EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
          Index].EFV[0];
        Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
          EnchantIndex;
        Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
          EnchantValue;
        Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
      end;
      Result := 2;
      Exit;
    end;
    EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
      [ItemSlot]);
    if (EmptyEnchant = 255) then
    begin
      Result := 1; // SendPlayerError
      Exit;
    end;
    for I := 0 to 2 do
    begin
      if(Player.Character.Base.Inventory[ItemSlot].Effects.Index[i] =
        ItemList[Player.Base.Character.Inventory[Item2].
      Index].EF[0]) then
      begin
        if not(ItemList[Player.Base.Character.Inventory[Item2].
          Index].ItemType = 33) then //pular se for estrela da pran
        begin
          Result := 3; // SendPlayerMessage
          Exit;
        end;
      end;
    end;
    EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EF[0];
    EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EFV[0];
    Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
      EnchantIndex;
    Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
      EnchantValue;
    Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
  end;
  Result := 2;
end;
{$ENDREGION}
{$REGION 'Change APP'}
class function TItemFunctions.Changeable(item: TItem): Boolean;
begin
  Result := False;
  if (item.APP = 0) or (item.Index = item.APP) then
  begin
    Result := True;
  end;
end;
class function TItemFunctions.ChangeApp(var Player: TPlayer;
  item, Athlon, NewApp: DWORD): BYTE;
var
  MItem, MAthlon, MNewApp: TItem;
begin
  Result := 0;
  MItem := Player.Character.Base.Inventory[item];
  MAthlon := Player.Character.Base.Inventory[Athlon];
  MNewApp := Player.Character.Base.Inventory[NewApp];
  if (MItem.Index = 0) then
    Exit;
  if (MAthlon.Index = 0) then
    Exit;
  if (MNewApp.Index = 0) then
    Exit;
  if not(Player.Base.GetMobClass(ItemList[MNewApp.Index].Classe)
    = Player.Base.GetMobClass(ItemList[MItem.Index].Classe)) then
  begin
    Result := 1;
    Exit;
  end;
  if (ItemList[MItem.Index].CanAgroup) then
  begin
    Result := 1;
    Exit;
  end;
  if (ItemList[MNewApp.Index].CanAgroup) then
  begin
    Result := 1;
    Exit;
  end;
  if (Self.Changeable(MItem)) then
  begin
    Player.Character.Base.Inventory[item].APP := Player.Character.Base.Inventory
      [NewApp].Index;
    ZeroMemory(@Player.Character.Base.Inventory[NewApp], sizeof(TItem));
    Self.DecreaseAmount(@Player.Character.Base.Inventory
      [Self.GetItemSlot2(Player, MAthlon.Index)]);
    Player.Base.SendRefreshItemSlot(Self.GetItemSlot2(Player,
      MAthlon.Index), False);
    Result := 2;
  end;
end;
{$ENDREGION}
{$REGION 'Enchant Mount'}
class function TItemFunctions.EnchantMount(var Player: TPlayer;
  ItemSlot, Item2: DWORD): BYTE;
type
  TSpecialRefi = record
    hi, lo: BYTE;
  end;
var
  EmptyEnchant: BYTE;
  EnchantIndex, EnchantValue: WORD;
begin
  Result := 0;
  if (Player.Base.Character.Inventory[ItemSlot].Index = 0) then
    Exit;
  if (Player.Base.Character.Inventory[Item2].Index = 0) then
    Exit;
  if (ItemList[Player.Base.Character.Inventory[Item2].Index].ItemType <> 518)
  then
  begin
    Exit;
  end;
  if (Self.Enchantable(Player.Base.Character.Inventory[ItemSlot])) then
  begin
    EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
      [ItemSlot]);
    if (EmptyEnchant = 255) then
    begin
      Result := 1; // SendPlayerError
      Exit;
    end;
    EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EF[0];
    EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EFV[0];
    { case EmptyEnchant of
      0:
      begin
      Player.Character.Base.Inventory[ItemSlot].Effects.Index[0] :=
      EnchantIndex;
      Player.Character.Base.Inventory[ItemSlot].MIN :=
      EnchantValue;
      end;
      1:
      begin
      Player.Character.Base.Inventory[ItemSlot].Effects.Index[2] :=
      EnchantIndex;
      Player.Character.Base.Inventory[ItemSlot].MAX :=
      EnchantValue;
      end;
      2:
      begin
      Refi1.lo := EnchantValue;
      Player.Character.Base.Inventory[ItemSlot].Effects.Value[1] :=
      EnchantIndex;
      Move(Refi1, Player.Character.Base.Inventory[ItemSlot].Refi, 2);
      end;
      end; }
    Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
      EnchantIndex;
    Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
      EnchantValue;
    Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
  end
  else
  begin
    Result := 1;
    Exit;
  end;
  Result := 2;
end;
{$ENDREGION}
{$REGION 'Premium Inventory Function'}
class function TItemFunctions.FindPremiumIndex(Index: WORD): WORD;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(PremiumItems) - 1 do
  begin
    if (PremiumItems[i].Index = Index) then
    begin
      Result := i;
      Break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Use Item'}
class function TItemFunctions.UsePremiumItem(var Player: TPlayer;
  Slot: Integer): Boolean;
var
  item: TItem;
  Premium: PItemCash;
begin
  if (Self.GetInvAvailableSlots(Player) = 0) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;
  Premium := @Player.Account.Header.CashInventory.Items[Slot];
  ZeroMemory(@item, sizeof(TItem));
  item.Index := PremiumItems[Premium.Index].ItemIndex;
  Self.SetItemAmount(item, PremiumItems[Premium.Index].Amount);
  if (ItemList[item.Index].Expires) then
  begin
    Self.SetItemAmount(item, 0);
  end;
  Self.PutItem(Player, item, 0, True);
  ZeroMemory(@item, sizeof(TItem));
  ZeroMemory(Premium, sizeof(TItemCash));
  Player.Base.SendRefreshItemSlot(CASH_TYPE, Slot, item, False);
  Result := (Premium.Index = 0);
end;
class function TItemFunctions.UseItem(var Player: TPlayer; Slot: Integer;
  Type1: DWORD): Boolean;
var
  item, SecondItem: PItem;
  i: Integer;
  BagSlot: Integer;
  Decrease: Cardinal;
  RecipeIndex, RandomTax, EmptySlot: WORD;
  ItemSlot, ItemAmount: BYTE;
  ItemExists, HaveAmount: Boolean;
  Level, ReliqSlot: WORD;
  LevelExp: UInt64;
  AddExp: UInt64;
  Rand: Integer;
  PosX: TPosition;
  Honor: Integer;
  Helper: Integer;
  SQLComp: TQuery;
  SlotType: BYTE;
  //ItemSlot: BYTE;
  RefineValue: Integer;
  ItemCode: DWORD;
  NewRefineValue: Integer;
  TargetChannelID: Byte;
  TargetNationID: Byte;
   Packet: TChangeChannelPacket;  // Mapeando o Packet para o Buffer
   Buffer: array[0..255] of Byte; // Declaração do Buffer




     // Personalities: Array [0 .. 5] of Integer;
  // p: Integer;
begin
  item := @Player.Character.Base.Inventory[Slot];

  Result := False;

  Decrease := 1;

  if Player.Character.Base.Level < ItemList[item.Index].Level then
    Exit;

  {// pergaminho para telar para leopold em Odeon
    if (item.Index = 8451) then
  begin
      Player.Teleport(TPosition.Create(914,3700));
  end;}





    // pergaminho para telar para leopold em Odeon




      // Pergaminho para teletransportar para Leopold em Odeon
   { if (item.Index = 8451) then
    begin
      if (Player.Base.Character.Nation > 0) then
      begin
        if (Servers[Player.ChannelIndex].NationID <> 4) then
        begin
          Player.SendClientMessage('Pergaminho só pode ser utilizado em Leopold.');
          Exit;
        end;

        // Cria um array de bytes para o ID do canal
        var ChannelID: array[0..0] of Byte;
        ChannelID[0] := 4;  // Atribui o valor 4 ao array de bytes

        // Usa a função ChangeChannel para transferir o jogador para o canal 4
        if TPacketHandlers.ChangeChannel(Player, ChannelID) then
        begin
          // Se a mudança de canal for bem-sucedida, teleporta o jogador
          Player.Teleport(TPosition.Create(914, 3700));  // Coordenada específica de Leopold

          // Reset de interações e mensagem de sucesso
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Player.SendClientMessage('Teleporte realizado com sucesso para a nação Leopold!');
        end
        else
        begin
          Player.SendClientMessage('Erro ao tentar mudar para o canal de Leopold.');
        end;
      end
      else
      begin
        Player.SendClientMessage('Impossível usar este item no canal desejado.');
        Exit;
      end;
    end;   }







     // pergamminho para telar para o tiamat em outras nações
   { if (item.Index = 8217) then
    begin
      if (Player.Base.Character.Nation > 0) then
      begin
            if (  Servers[Player.ChannelIndex]
              .NationID <> 4) then
            begin
              Player.SendClientMessage
                ('Pergaminho só pode ser utilizado em Leopold.');
              Exit;
            end;
            ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);

           if(ReliqSlot <> 255) then
            begin
            Player.SendClientMessage('Impossível usar com relíquia.');
            Exit;
           end;

            Player.Teleport(TPosition.Create(2943,1667));
       end
      else
      begin
        Player.SendClientMessage
       ('Impossível usar este item no canal desejado.');
        Exit;

       end;
     end;}




          // Pergaminho drop Dg Abismo Boss +14yy
    if (item.Index = 9655) then
    begin
      if (Player.Base.Character.Nation > 0) then
      begin
        if (Servers[Player.ChannelIndex].NationID <> 4) then
        begin
          Player.SendClientMessage('Pergaminho só pode ser utilizado em Leopold..');
          Exit;
        end;

        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);

        if (ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Impossível usar com relíquia.');
          Exit;
        end;

        // Gerar um número aleatório entre 0 e 2 para escolher a localização
        case Random(3) of
          0: Player.Teleport(TPosition.Create(2644, 2761));  // Localização 1
          1: Player.Teleport(TPosition.Create(2612, 2761));  // Localização 2
          2: Player.Teleport(TPosition.Create(2580, 2761));  // Localização 3
        end;
      end;
    end;




    // Polimorfo Player  Aranha

          begin
          // Verifica se o item é um item de transformação (polimorfo)
          if (item.Index = 4692) then  // Substitua pelo ID do item que ativa o polimorfo
          begin
            if Player.Base.ClientID <= MAX_CONNECTIONS then
            begin
              // Envia a recriação do jogador com o visual do mob (polimorfado)
              Player.Base.SendCreateMob(SPAWN_NORMAL, 0, True, 433);  // 282 é o ID do visual que o jogador terá

              // Mensagem para o jogador
              Servers[Player.Base.ChannelId].Players[Player.Base.ClientID].SendClientMessage(
                'Você se transformou em um monstro!');
            end;


            Result := True;  // O item foi usado com sucesso
          end
          else
          begin
            // Outras funcionalidades de uso de item
            Result := False;
          end;
        end;


        // Polimorfo Player  Moira

          begin
          // Verifica se o item é um item de transformação (polimorfo)
          if (item.Index = 4693) then  // Substitua pelo ID do item que ativa o polimorfo
          begin
            if Player.Base.ClientID <= MAX_CONNECTIONS then
            begin
              // Envia a recriação do jogador com o visual do mob (polimorfado)
              Player.Base.SendCreateMob(SPAWN_NORMAL, 0, True, 505);  // 282 é o ID do visual que o jogador terá

              // Mensagem para o jogador
              Servers[Player.Base.ChannelId].Players[Player.Base.ClientID].SendClientMessage(
                'Você se transformou em um monstro!');
            end;


            Result := True;  // O item foi usado com sucesso
          end
          else
          begin
            // Outras funcionalidades de uso de item
            Result := False;
          end;
        end;


          // Polimorfo Player  predadora

          begin
          // Verifica se o item é um item de transformação (polimorfo)
          if (item.Index = 4694) then  // Substitua pelo ID do item que ativa o polimorfo
          begin
            if Player.Base.ClientID <= MAX_CONNECTIONS then
            begin
              // Envia a recriação do jogador com o visual do mob (polimorfado)
              Player.Base.SendCreateMob(SPAWN_NORMAL, 0, True, 323 );  // 282 é o ID do visual que o jogador terá

              // Mensagem para o jogador
              Servers[Player.Base.ChannelId].Players[Player.Base.ClientID].SendClientMessage(
                'Você se transformou em um monstro!');
            end;


            Result := True;  // O item foi usado com sucesso
          end
          else
          begin
            // Outras funcionalidades de uso de item
            Result := False;
          end;
        end;

        // Polimorfo Player  Moira

          begin
          // Verifica se o item é um item de transformação (polimorfo)
          if (item.Index = 4693) then  // Substitua pelo ID do item que ativa o polimorfo
          begin
            if Player.Base.ClientID <= MAX_CONNECTIONS then
            begin
              // Envia a recriação do jogador com o visual do mob (polimorfado)
              Player.Base.SendCreateMob(SPAWN_NORMAL, 0, True, 505);  // 282 é o ID do visual que o jogador terá

              // Mensagem para o jogador
              Servers[Player.Base.ChannelId].Players[Player.Base.ClientID].SendClientMessage(
                'Você se transformou em um monstro!');
            end;


            Result := True;  // O item foi usado com sucesso
          end
          else
          begin
            // Outras funcionalidades de uso de item
            Result := False;
          end;
        end;

         // Polimorfo Player Pran

          begin
          // Verifica se o item é um item de transformação (polimorfo)
          if (item.Index = 4695) then  // Substitua pelo ID do item que ativa o polimorfo
          begin
            if Player.Base.ClientID <= MAX_CONNECTIONS then
            begin
              // Envia a recriação do jogador com o visual do mob (polimorfado)
              Player.Base.SendCreateMob(SPAWN_NORMAL, 0, True, 115);  // 282 é o ID do visual que o jogador terá

              // Mensagem para o jogador
              Servers[Player.Base.ChannelId].Players[Player.Base.ClientID].SendClientMessage(
                'Você se transformou em uma pran Adulta!');
            end;


            Result := True;  // O item foi usado com sucesso
          end
          else
          begin
            // Outras funcionalidades de uso de item
            Result := False;
          end;
        end;

        // Polimorfo Player Golen de aço

          begin
          // Verifica se o item é um item de transformação (polimorfo)
          if (item.Index = 4696) then  // Substitua pelo ID do item que ativa o polimorfo
          begin
            if Player.Base.ClientID <= MAX_CONNECTIONS then
            begin
              // Envia a recriação do jogador com o visual do mob (polimorfado)
              Player.Base.SendCreateMob(SPAWN_NORMAL, 0, True, 271);  // 282 é o ID do visual que o jogador terá

              // Mensagem para o jogador
              Servers[Player.Base.ChannelId].Players[Player.Base.ClientID].SendClientMessage(
                'Você se transformou em um Golen de Aço!');
            end;


            Result := True;  // O item foi usado com sucesso
          end
          else
          begin
            // Outras funcionalidades de uso de item
            Result := False;
          end;
        end;

        // Polimorfo Player hupt

          begin
          // Verifica se o item é um item de transformação (polimorfo)
          if (item.Index = 4697) then  // Substitua pelo ID do item que ativa o polimorfo
          begin
            if Player.Base.ClientID <= MAX_CONNECTIONS then
            begin
              // Envia a recriação do jogador com o visual do mob (polimorfado)
              Player.Base.SendCreateMob(SPAWN_NORMAL, 0, True, 314);  // 282 é o ID do visual que o jogador terá

              // Mensagem para o jogador
              Servers[Player.Base.ChannelId].Players[Player.Base.ClientID].SendClientMessage(
                'Você se transformou no Asafa!');
            end;


            Result := True;  // O item foi usado com sucesso
          end
          else
          begin
            // Outras funcionalidades de uso de item
            Result := False;
          end;
        end;

        // Polimorfo Player Feiticeiro Negro

          begin
          // Verifica se o item é um item de transformação (polimorfo)
          if (item.Index = 4698) then  // Substitua pelo ID do item que ativa o polimorfo
          begin
            if Player.Base.ClientID <= MAX_CONNECTIONS then
            begin
              // Envia a recriação do jogador com o visual do mob (polimorfado)
              Player.Base.SendCreateMob(SPAWN_NORMAL, 0, True, 285);  // 282 é o ID do visual que o jogador terá

              // Mensagem para o jogador
              Servers[Player.Base.ChannelId].Players[Player.Base.ClientID].SendClientMessage(
                'Você se transformou em um Feiticeiro Negro!');
            end;


            Result := True;  // O item foi usado com sucesso
          end
          else
          begin
            // Outras funcionalidades de uso de item
            Result := False;
          end;
        end;

        // Polimorfo Player Cobra
          begin
          // Verifica se o item é um item de transformação (polimorfo)
          if (item.Index = 4699) then  // Substitua pelo ID do item que ativa o polimorfo
          begin
            if Player.Base.ClientID <= MAX_CONNECTIONS then
            begin
              // Envia a recriação do jogador com o visual do mob (polimorfado)
              Player.Base.SendCreateMob(SPAWN_NORMAL, 0, True, 240);  // 282 é o ID do visual que o jogador terá

              // Mensagem para o jogador
              Servers[Player.Base.ChannelId].Players[Player.Base.ClientID].SendClientMessage(
                'Você se transformou em um Boneco de Neve!');
            end;


            Result := True;  // O item foi usado com sucesso
          end
          else
          begin
            // Outras funcionalidades de uso de item
            Result := False;
          end;
        end;

        // Polimorfo Player Slime

          begin
          // Verifica se o item é um item de transformação (polimorfo)
          if (item.Index = 4700) then  // Substitua pelo ID do item que ativa o polimorfo
          begin
            if Player.Base.ClientID <= MAX_CONNECTIONS then
            begin
              // Envia a recriação do jogador com o visual do mob (polimorfado)
              Player.Base.SendCreateMob(SPAWN_NORMAL, 0, True, 545);  // 282 é o ID do visual que o jogador terá

              // Mensagem para o jogador
              Servers[Player.Base.ChannelId].Players[Player.Base.ClientID].SendClientMessage(
                'Você se transformou em um Slime !');
            end;


            Result := True;  // O item foi usado com sucesso
          end
          else
          begin
            // Outras funcionalidades de uso de item
            Result := False;
          end;
        end;










     //Item que dá 100 pontos de honrra
      if (item.Index = 8630) then
      begin
        Honor := 100;  // Adiciona 10 pontos de honra

        // Adiciona os pontos de honra ao jogador
        Inc(Player.Base.Character.CurrentScore.Honor, Honor);
        Player.SendClientMessage('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
        Player.Base.SendRefreshKills();
      end;


   // poção do gigante
   if (item.Index = 15535) then
    begin
      SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
        AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
        AnsiString(MYSQL_DATABASE));
      try
        if not(SQLComp.Query.Connection.Connected) then
        begin
          Player.SendClientMessage('Erro: Não foi possível conectar ao banco de dados.');
          Exit;
        end;

        // Verifica se o tronco é 220 e impede a alteração da altura
      SQLComp.SetQuery('SELECT tronco FROM characters WHERE id = :CharID');
      SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
      SQLComp.Run(True);

      if (SQLComp.Query.FieldByName('tronco').AsInteger = 220) then
      begin
        Player.SendClientMessage('Alteração de altura não permitida.Personagem ja alterado.');
        Exit;
      end;



        // Verifica se a altura já é 10
        SQLComp.SetQuery('SELECT altura FROM characters WHERE id = :CharID');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(True);

        if (SQLComp.Query.FieldByName('altura').AsInteger = 10) then
        begin
          // Remove o buff 9122 se estiver ativo
          Player.Base.RemoveBuff(9122);

          Player.SendClientMessage('Seu personagem já está no modo gigante.');
          Exit;
        end;

        // Atualiza a altura para 10 se for 7 ou 4
        SQLComp.SetQuery('UPDATE characters SET altura = 10 WHERE id = :CharID AND altura IN (7, 4)');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(False);

        // Verifica se a altura foi realmente alterada
        SQLComp.SetQuery('SELECT altura FROM characters WHERE id = :CharID');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(True);

        if (SQLComp.Query.FieldByName('altura').AsInteger <> 10) then
        begin
          Player.SendClientMessage('Erro ao atualizar a altura. Tente novamente.');
          Exit;
        end;

        // Adiciona o buff 9122 ao jogador
        Player.Base.AddBuff(9122);

        Player.SendClientMessage('Você se tornou um Gigante, Relogue por favor!', 32);
      finally
        SQLComp.Destroy;
      end;
    end;



  // poção nanicolina
     if (item.Index = 15536) then
    begin
      SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
        AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
        AnsiString(MYSQL_DATABASE));
      try
        if not(SQLComp.Query.Connection.Connected) then
        begin
          Player.SendClientMessage('Erro: Não foi possível conectar ao banco de dados.');
          Exit;
        end;
        // Verifica se o tronco é 220 e impede a alteração da altura
            SQLComp.SetQuery('SELECT tronco FROM characters WHERE id = :CharID');
            SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
            SQLComp.Run(True);

            if (SQLComp.Query.FieldByName('tronco').AsInteger = 220) then
            begin
              Player.SendClientMessage('Alteração de altura não permitida.Personagem ja alterado');
              Exit;
            end;

        // Verifica se a altura já é 4
        SQLComp.SetQuery('SELECT altura FROM characters WHERE id = :CharID');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(True);

        if (SQLComp.Query.FieldByName('altura').AsInteger = 4) then
        begin
          // Remove o buff 9123 se estiver ativo
          Player.Base.RemoveBuff(9123);

          Player.SendClientMessage('Seu personagem já está no modo Nanico.');
          Exit;
        end;

        // Atualiza a altura para 4 se for 7 ou 10
        SQLComp.SetQuery('UPDATE characters SET altura = 4 WHERE id = :CharID AND altura IN (7, 10)');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(False);

        // Verifica se a altura foi realmente alterada
        SQLComp.SetQuery('SELECT altura FROM characters WHERE id = :CharID');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(True);

        if (SQLComp.Query.FieldByName('altura').AsInteger <> 4) then
        begin
          Player.SendClientMessage('Erro ao atualizar a altura. Tente novamente.');
          Exit;
        end;

        // Adiciona o buff 9123 ao jogador
        Player.Base.AddBuff(9126);

        Player.SendClientMessage('Você se tornou um Nanico, Relogue por favor!', 32);
      finally
        SQLComp.Destroy;
      end;
    end;

    // poção do cabeção
    if (item.Index = 15537) then
    begin
      SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
        AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
        AnsiString(MYSQL_DATABASE));
      try
        if not(SQLComp.Query.Connection.Connected) then
        begin
          Player.SendClientMessage('Erro: Não foi possível conectar ao banco de dados.');
          Exit;
        end;

        // Verifica se a altura é 4 ou 10 e impede a alteração do tronco
        SQLComp.SetQuery('SELECT altura FROM characters WHERE id = :CharID');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(True);

        if (SQLComp.Query.FieldByName('altura').AsInteger IN [4, 10]) then
        begin
          Player.SendClientMessage('Alteração não permitida! Já utilizando poção de alteração.');
          Exit;
        end;

        // Verifica se o tronco já é 220
        SQLComp.SetQuery('SELECT tronco FROM characters WHERE id = :CharID');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(True);

        if (SQLComp.Query.FieldByName('tronco').AsInteger = 220) then
        begin
          // Remove o buff 9122 se estiver ativo
          Player.Base.RemoveBuff(9126);

          Player.SendClientMessage('Seu personagem já está cabeçudo.');
          Exit;
        end;

        // Atualiza o tronco para 220 se for 119
        SQLComp.SetQuery('UPDATE characters SET tronco = 220 WHERE id = :CharID AND tronco = 119');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(False);

        // Verifica se o tronco foi realmente alterado
        SQLComp.SetQuery('SELECT tronco FROM characters WHERE id = :CharID');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(True);

        if (SQLComp.Query.FieldByName('tronco').AsInteger <> 220) then
        begin
          Player.SendClientMessage('Erro ao atualizar o tronco. Tente novamente.');
          Exit;
        end;

        // Adiciona o buff 9122 ao jogador
        Player.Base.AddBuff(9126);

        Player.SendClientMessage('Você está cabeçudo, relogue por favor!, Relogue por favor!', 32);
      finally
        SQLComp.Destroy;
      end;
    end;

    // poção voltar ao normal

    if (item.Index = 15538) then
    begin
      SQLComp := TQuery.Create(
        AnsiString(MYSQL_SERVER),
        MYSQL_PORT,
        AnsiString(MYSQL_USERNAME),
        AnsiString(MYSQL_PASSWORD),
        AnsiString(MYSQL_DATABASE)
      );
      try
        // Verifica a conexão
        if not(SQLComp.Query.Connection.Connected) then
        begin
          Player.SendClientMessage('Erro: Não foi possível conectar ao banco de dados.');
          Exit;
        end;

        // 1) Verifica se tronco é 220 para impedir alteração
        SQLComp.SetQuery('SELECT tronco, altura FROM characters WHERE id = :CharID');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(True);

        if (SQLComp.Query.FieldByName('tronco').AsInteger = 220) then
        begin
          Player.SendClientMessage('Alteração não permitida. Personagem já alterado.');
          Exit;
        end;

        // 2) Verifica se altura e tronco já estão em (7, 119)
        if (SQLComp.Query.FieldByName('altura').AsInteger = 7) and
           (SQLComp.Query.FieldByName('tronco').AsInteger = 119) then
        begin
          Player.SendClientMessage('Seu personagem já está Normal.');
          Exit;
        end;

        // 3) Faz UPDATE apenas se altura != 7 ou tronco != 119
        SQLComp.SetQuery(
          'UPDATE characters ' +
          'SET altura = 7, tronco = 119 ' +
          'WHERE id = :CharID ' +
          '  AND (altura <> 7 OR tronco <> 119)'
        );
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(False);

        // 4) Valida se a atualização funcionou
        SQLComp.SetQuery('SELECT altura, tronco FROM characters WHERE id = :CharID');
        SQLComp.AddParameter2('CharID', Player.Base.Character.CharIndex);
        SQLComp.Run(True);

        if (SQLComp.Query.FieldByName('altura').AsInteger <> 7) or
           (SQLComp.Query.FieldByName('tronco').AsInteger <> 119) then
        begin
          Player.SendClientMessage('Erro ao atualizar altura e tronco. Tente novamente.');
          Exit;
        end;

        // Caso queira adicionar um buff ou alguma mensagem específica:
         Player.Base.RemoveBuff(9122);
         Player.Base.RemoveBuff(9123);
         Player.Base.RemoveBuff(9126);
        Player.SendClientMessage('Relogue para o seu Personnagem voltar ao normal !');

      finally
        SQLComp.Destroy;
      end;
    end;










      // Manipulação do item
    if (item.Index = 14201) then // Substitua pelo ID do item para iniciar o evento
    begin
      // Inicia o evento Battle Royale
      TRoyaleHandler.StartRoyaleEvent;

      // Mensagem de confirmação
      Player.SendClientMessage('O evento Battle Royale foi iniciado!');
    end;

      // Manipulação do item
    if (item.Index = 14202) then // Substitua pelo ID do item para iniciar o evento
    begin
      // Inicia o evento Battle Royale
      TRoyaleHandler.StartRoyaleEvent;

      // Mensagem de confirmação
      Player.SendClientMessage('O evento Battle Royale foi iniciado!');
    end;



      //Item que dá 150k pontos de honrra
      if (item.Index = 8864) then
      begin
        Honor := 150000;  // Adiciona 150k pontos de honra

        // Adiciona os pontos de honra ao jogador
        Inc(Player.Base.Character.CurrentScore.Honor, Honor);
        Player.SendClientMessage('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
        Player.Base.SendRefreshKills();
      end;


       //Item que dá 50k pontos de honrra
      if (item.Index = 10295) then
      begin
        Honor := 50000;  // Adiciona 50k pontos de honra

        // Adiciona os pontos de honra ao jogador
        Inc(Player.Base.Character.CurrentScore.Honor, Honor);
        Player.SendClientMessage('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
        Player.Base.SendRefreshKills();
      end;

       // Item de Troca de Nação para Odeon
         begin
        // Verifica se o item é o que troca a nação (exemplo: ID 11287)
        if (item.Index = 4119) then
        begin
          if (Player.Base.Character.Nation = 0) then
          begin
            Player.SendClientMessage('Você não possui nação.');
            Exit;
          end;

          // Verifica se o jogador está em uma guilda
          if (Player.Character.GuildSlot > 0) then
          begin
            Player.SendClientMessage('Você não pode trocar de nação estando em uma guilda.');
            Exit;
          end;

          // Defina a nova nação desejada (exemplo: mudar para Astur com ID 1)
          Player.Account.Header.Nation := TCitizenship(2); // Aqui, 1 é o ID de odeon
          Player.SendClientMessage('Você trocou para a nação Odeon.');


          // Notifica os jogadores do canal sobre a mudança de nação
          Servers[Player.ChannelIndex].SendServerMsg(
            'O jogador <' + AnsiString(Player.Base.Character.Name) + '> trocou para a nação Odeon.', 32, 16
          );

          // Atualiza o estado do jogador no servidor
          Player.Base.SendRefreshKills();
        end;
      end;


      // Item de Troca de Nação para Tibérica
         begin
        // Verifica se o item é o que troca a nação
        if (item.Index = 4120) then
        begin
          if (Player.Base.Character.Nation = 0) then
          begin
            Player.SendClientMessage('Você não possui nação.');
            Exit;
          end;

          // Verifica se o jogador está em uma guilda
          if (Player.Character.GuildSlot > 0) then
          begin
            Player.SendClientMessage('Você não pode trocar de nação estando em uma guilda.');
            Exit;
          end;

          // Defina a nova nação desejada (exemplo: mudar para Astur com ID 1)
          Player.Account.Header.Nation := TCitizenship(1); // Aqui, 1 é o ID de odeon
          Player.SendClientMessage('Você trocou para a nação Tibérica.');


          // Notifica os jogadores do canal sobre a mudança de nação
          Servers[Player.ChannelIndex].SendServerMsg(
            'O jogador <' + AnsiString(Player.Base.Character.Name) + '> trocou para a nação Tibérica.', 32, 16
          );

          // Atualiza o estado do jogador no servidor
          Player.Base.SendRefreshKills();
        end;
      end;




      // Item de Troca de Nação para Elzinore
         begin
        // Verifica se o item é o que troca a nação
        if (item.Index = 4121) then
        begin
          if (Player.Base.Character.Nation = 0) then
          begin
            Player.SendClientMessage('Você não possui nação.');
            Exit;
          end;

          // Verifica se o jogador está em uma guilda
          if (Player.Character.GuildSlot > 0) then
          begin
            Player.SendClientMessage('Você não pode trocar de nação estando em uma guilda.');
            Exit;
          end;

          // Defina a nova nação desejada (exemplo: mudar para Astur com ID 1)
          Player.Account.Header.Nation := TCitizenship(3); // Aqui, 1 é o ID de odeon
          Player.SendClientMessage('Você trocou para a nação Elzinore.');


          // Notifica os jogadores do canal sobre a mudança de nação
          Servers[Player.ChannelIndex].SendServerMsg(
            'O jogador <' + AnsiString(Player.Base.Character.Name) + '> trocou para a nação Elzinore.', 32, 16
          );

          // Atualiza o estado do jogador no servidor
          Player.Base.SendRefreshKills();
        end;
      end;


     // Item de Troca de ClassInfo para 33 Pistoleira
    begin
      // Verifica se o item utilizado é o correto
      if (item.Index = 4123) then
      begin
        // Verifica se o jogador não está com a classe 32
        if (Player.Base.Character.ClassInfo <> 32) then
        begin
          Player.SendClientMessage('Você precisa estar com a classe para realizar esta alteração.');
          Exit;
        end;

        // Verifica se o jogador já possui a classe 33
        if (Player.Base.Character.ClassInfo = 33) then
        begin
          Player.SendClientMessage('Você já possui a classe específica.');
          Exit;
        end;

        // Caso todas as condições sejam atendidas, altera o ClassInfo do jogador para 33
        Player.Base.Character.ClassInfo := 33;
        Player.SendClientMessage('Seu ClassInfo foi alterada. Relogue para aplicar as mudanças.');

        // Notifica os jogadores do canal sobre a mudança
        Servers[Player.ChannelIndex].SendServerMsg(
          'O jogador <' + AnsiString(Player.Base.Character.Name) + '> alterou sua classe .', 32, 16
        );

        // Atualiza o estado do jogador no servidor
        Player.Base.SendRefreshKills();
      end;
    end;



      // Item de Troca de ClassInfo WR
      begin
          // Verifica se o item é o que altera o ClassInfo (exemplo: ID 4119)
          if (item.Index = 4124) then

          begin

           if (Player.Base.Character.ClassInfo <> 2) then
          begin
            Player.SendClientMessage('Você precisa estar com a classe atual  para realizar esta alteração.');
            Exit;
          end;



            if (Player.Base.Character.ClassInfo = 3) then
            begin
              Player.SendClientMessage('Você já possui a Classe Especifica.');
              Exit;
            end;

            // Verifica condições, como se o jogador está em uma guilda
           { if (Player.Character.GuildSlot > 0) then
            begin
              Player.SendClientMessage('Você não pode alterar o ClassInfo estando em uma guilda.');
              Exit;
            end; }

            // Altera o ClassInfo do jogador
            Player.Base.Character.ClassInfo := 3;
            Player.SendClientMessage('Seu ClassInfo foi alterado Relogar.');

            // Notifica os jogadores do canal sobre a mudança
            Servers[Player.ChannelIndex].SendServerMsg(
              'O jogador <' + AnsiString(Player.Base.Character.Name) + '> alterou o Sua Classe.', 32, 16
            );

            // Atualiza o estado do jogador no servidor
            Player.Base.SendRefreshKills();

        end;
      end;


      // Item de Troca de ClassInfo Templaria
      begin
        // Verifica se o item é o que altera o ClassInfo (exemplo: ID 4119)
        if (item.Index = 4125) then
        begin

         if (Player.Base.Character.ClassInfo <> 12) then
          begin
            Player.SendClientMessage('Você precisa estar com a classe atual  para realizar esta alteração.');
            Exit;
          end;



            if (Player.Base.Character.ClassInfo = 13) then
            begin
              Player.SendClientMessage('Você já possui a Classe Especifica.');
              Exit;
            end;

            // Verifica condições, como se o jogador está em uma guilda
           { if (Player.Character.GuildSlot > 0) then
            begin
              Player.SendClientMessage('Você não pode alterar o ClassInfo estando em uma guilda.');
              Exit;
            end; }

            // Altera o ClassInfo do jogador
            Player.Base.Character.ClassInfo := 13;
            Player.SendClientMessage('Seu ClassInfo foi alterado Relogar.');

            // Notifica os jogadores do canal sobre a mudança
            Servers[Player.ChannelIndex].SendServerMsg(
              'O jogador <' + AnsiString(Player.Base.Character.Name) + '> alterou o Sua Classe.', 32, 16
            );

            // Atualiza o estado do jogador no servidor
            Player.Base.SendRefreshKills();
        end;
      end;

      // Item de Troca de ClassInfo att
      begin
        // Verifica se o item é o que altera o ClassInfo (exemplo: ID 4119)
        if (item.Index = 4126) then
        begin

         if (Player.Base.Character.ClassInfo <> 22) then
          begin
            Player.SendClientMessage('Você precisa estar com a classe atual  para realizar esta alteração.');
            Exit;
          end;


            if (Player.Base.Character.ClassInfo = 23) then
            begin
              Player.SendClientMessage('Você já possui a Classe Especifica.');
              Exit;
            end;

            // Verifica condições, como se o jogador está em uma guilda
           { if (Player.Character.GuildSlot > 0) then
            begin
              Player.SendClientMessage('Você não pode alterar o ClassInfo estando em uma guilda.');
              Exit;
            end; }

            // Altera o ClassInfo do jogador
            Player.Base.Character.ClassInfo := 23;
            Player.SendClientMessage('Seu ClassInfo foi alterado Relogar.');

            // Notifica os jogadores do canal sobre a mudança
            Servers[Player.ChannelIndex].SendServerMsg(
              'O jogador <' + AnsiString(Player.Base.Character.Name) + '> alterou o Sua Classe.', 32, 16
            );

            // Atualiza o estado do jogador no servidor
            Player.Base.SendRefreshKills();
        end;
      end;






      // Item de Troca de ClassInfo fc
      begin
        // Verifica se o item é o que altera o ClassInfo (exemplo: ID 4119)
          if (item.Index = 4127) then
           begin
             if (Player.Base.Character.ClassInfo <> 42) then
            begin
              Player.SendClientMessage('Você precisa estar com a classe atual  para realizar esta alteração.');
              Exit;
            end;



            if (Player.Base.Character.ClassInfo = 43) then
            begin
              Player.SendClientMessage('Você já possui a Classe Especifica.');
              Exit;
            end;

            // Verifica condições, como se o jogador está em uma guilda
           { if (Player.Character.GuildSlot > 0) then
            begin
              Player.SendClientMessage('Você não pode alterar o ClassInfo estando em uma guilda.');
              Exit;
            end; }

            // Altera o ClassInfo do jogador
            Player.Base.Character.ClassInfo := 43;
            Player.SendClientMessage('Seu ClassInfo foi alterado Relogar.');

            // Notifica os jogadores do canal sobre a mudança
            Servers[Player.ChannelIndex].SendServerMsg(
              'O jogador <' + AnsiString(Player.Base.Character.Name) + '> alterou o Sua Classe.', 32, 16
            );

            // Atualiza o estado do jogador no servidor
            Player.Base.SendRefreshKills();
          end;

      end;

      // Item de Troca de ClassInfo santa
    begin
        // Verifica se o item é o que altera o ClassInfo (exemplo: ID 4119)
        if (item.Index = 4128) then

        begin
         if (Player.Base.Character.ClassInfo <> 52) then
        begin
          Player.SendClientMessage('Você precisa estar com a classe atual  para realizar esta alteração.');
          Exit;
        end;



          if (Player.Base.Character.ClassInfo = 53) then
          begin
            Player.SendClientMessage('Você já possui a Classe Especifica.');
            Exit;
          end;

          // Verifica condições, como se o jogador está em uma guilda
         { if (Player.Character.GuildSlot > 0) then
          begin
            Player.SendClientMessage('Você não pode alterar o ClassInfo estando em uma guilda.');
            Exit;
          end; }

          // Altera o ClassInfo do jogador
          Player.Base.Character.ClassInfo := 53;
          Player.SendClientMessage('Seu ClassInfo foi alterado Relogar.');

          // Notifica os jogadores do canal sobre a mudança
          Servers[Player.ChannelIndex].SendServerMsg(
            'O jogador <' + AnsiString(Player.Base.Character.Name) + '> alterou o Sua Classe.', 32, 16
          );

          // Atualiza o estado do jogador no servidor
          Player.Base.SendRefreshKills();

      end;
      end;


       //Item que dá 150k pontos de honrra Loja especial
      if (item.Index = 11713) then
      begin
        Honor := 150000;  // Adiciona 50k pontos de honra

        // Adiciona os pontos de honra ao jogador
        Inc(Player.Base.Character.CurrentScore.Honor, Honor);
        Player.SendClientMessage('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
        Player.Base.SendRefreshKills();
      end;



       //Item que dá 1k pontos de honrra
      if (item.Index = 10296) then
      begin
        Honor := 1000;  // Adiciona 5k pontos de honra

        // Adiciona os pontos de honra ao jogador
        Inc(Player.Base.Character.CurrentScore.Honor, Honor);
        Player.SendClientMessage('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
        Player.Base.SendRefreshKills();
      end;

       //Item que dá 150k pontos de honrra
      if (item.Index = 11528) then
      begin
        Honor := 150000;  // Adiciona 150k pontos de honra

        // Adiciona os pontos de honra ao jogador
        Inc(Player.Base.Character.CurrentScore.Honor, Honor);
        Player.SendClientMessage('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
        Player.Base.SendRefreshKills();
      end;


      //procedure RedistributeBasePoints(var Player: TPlayer);

      //Reseta os pontos do personagem
      if (item.Index = 8192) then
      begin
        var
          TotalBasePoints: Integer;
        begin
          // Calcular a soma dos pontos base do personagem
          with Player.Base.Character.CurrentScore do
          begin
            TotalBasePoints := Str + agility + Int + Cons + Luck;

            // Adicionar os pontos ao campo Status
            Status := Status + TotalBasePoints;

            // Resetar os pontos base
            Str := 0;
            agility := 0;
            Int := 0;
            Cons := 0;
            Luck := 0;

            // Opcional: Enviar mensagem para o jogador sobre a redistribuição
            Player.SendClientMessage('Todos os pontos base foram redistribuídos para o Status e podem ser redistribuídos pelo jogador .');
            Player.Base.SendRefreshKills();
          end;
        end;
      end;

            // Núcleo de Refine 0 para +11   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      if (item.Index = 4135) then
      begin
        // Declaração das variáveis para o slot e o valor de refinamento
        var Refi: BYTE;
        var ItemIDList: TArray<Integer>;
        var RefinementStepMin: BYTE := 0;   // Define o valor mínimo de refinamento como 0
        var RefinementStepMax: BYTE := 187; // Define o valor máximo de refinamento como +11 (188)


      // Definir a lista de IDs dos itens que podem ser refinados
  ItemIDList := TArray<Integer>.Create(  12067, 12373, 12403, 12433, 12463,
    12102, 12343, 12493, 12523, 12553, 12583, 19211,19691,19721,19751,19781,
    12102, 12613, 12643, 12673, 12703,
    12242, 12733, 12763, 12793, 12823,
    12277, 12853, 12883, 12913, 12943,
    12312, 12973, 13003, 13033, 13063,
    12066, 12372, 12402, 12432, 12462,
    12101, 12342, 12492, 12522, 12552, 12582,
    12206, 12612, 12642, 12672, 12702,
    12241, 12732, 12762, 12792, 12822,
    12276, 12852, 12882, 12912, 12942,
    12311, 12972, 13002, 13032, 13062,
    12073, 12072, 12379, 12378, 12409,
    12408, 12439, 12438, 12469, 12468,
    12108, 12107, 12349, 12348, 12499,
    12498, 12529, 12528, 12559, 12558, 12589, 12588,
    12213, 12212, 12619, 12618, 12649,
    12648, 12679, 12678, 12709, 12708,
    12248, 12247, 12739, 12738, 12769,
    12768, 12799, 12798, 12829, 12828,
    12283, 12282, 12859, 12858, 12889,
    12888, 12919, 12918, 12949, 12948,
    12318, 12317, 12979, 12978, 13009,
    13008, 13039, 13038, 13069, 13068,
    12233, 12234, 12235, 12236, 12726, 12727, 12728, 12729,
    12756, 12757, 12758, 12759, 12786, 12787, 12788, 12789,
    12816, 12817, 12818, 12819,
    12093, 12094, 12095, 12096, 12336, 12337, 12338, 12339,
    12486, 12487, 12488, 12489, 12516, 12517, 12518, 12519,
    12546, 12547, 12548, 12549, 12576, 12577, 12578, 12579,
    12198, 12199, 12200, 12201, 12606, 12607, 12608, 12609,
    12636, 12637, 12638, 12639, 12666, 12667, 12668, 12669,
    12696, 12697, 12698, 12699,
    12225, 12226, 12227, 12228, 12720, 12721, 12722, 12723,
    12750, 12751, 12752, 12753, 12780, 12781, 12782, 12783,
    12810, 12811, 12812, 12813,
    12268, 12269, 12270, 12271, 12846, 12847, 12848, 12849,
    12876, 12877, 12878, 12879, 12906, 12907, 12908, 12909,
    12936, 12937, 12938, 12939,
    12303, 12304, 12305, 12306, 12966, 12967, 12968, 12969,
    12996, 12997, 12998, 12999, 13026, 13027, 13028, 13029,
    13056, 13057, 13058, 13059,12076, 12382, 12412, 12442, 12472,
    12111, 12352, 12502, 12532, 12562, 12592,
    12216, 12622, 12652, 12682, 12712,
    12251, 12742, 12772, 12802, 12832,
    12286, 12862, 12892, 12922, 12952,
    12321, 12982, 13012 , 13042, 13072, 12056,12091,12196,12231,12266,12301,12340,12370,12400,
    12430,12460,12490,12520,12550,12580,12610,12640,12670,12700,12730,12760,12790,12820,12850,12880,12910,
    12940,12970,13000, 13030,13060,
    2818,2848,2878,2908,2938,2968,2998,3028,3058,
    3088,3118,3148,3178,3208,3238,3268,3298,3328,3358,
    3388,3418,3448,3478,3508,3538,5698,2528,2563,2668,2703,2738,2773,2818,
    2738,2703,2668,2563,2528,
    2569,2824,2854,2884,2914,2534,2944,2974,3004,3034,2794,2709,3064,3094,3124,3154,
    2674,3184,3214,3244,3274,2779,3304,3334,3364,3394,2744,3424,3454,3484,3514,
    2570,2825,2855,2885,2915,2535,2945,2975,3005,3035,2795,2709,3064,3094,3124,3154,
    2675,3185,3215,3245,3275,2780,3305,3335,3365,3395,2745,3425,3455,3485,3515,
    2571,2826,2856,2886,2916,2536,2946,2976,3006,3036,2796,2711,3066,3096,3126,3156,2676,3186,3216,3246,3276,
    2781,3306,3336,3366,3396,2746,3426,3456,3486,3516 , 2574,2829,2859,2889,2919,2539,2799,2949,2978,3009,3039,
    2714,3069,3099,3129,3159,2679,3189,3219,3249,3279,2784,3309,3339,3369,3399,2749,3429,3459,3489,3519,
    6738,7005,7035,7065,7095,6703,6975,7124,7154,7184,7214,6878,7245,7275,7305,7335,6843,7365,7395,7425,7455,
    6948,7485,7515,7545,7575,6913,7605,7635,7665,7695,
    6736,7003,7033,7063,7093,6701,6973,7122,7152,7182,7212,6876,7243,7273,7303,7333,6841,7363,7393,7423,7453,
    6946,7483,7513,7543,7573, 6911,7603,7633,7663,7693,6737,7004,7034,7064,7094,6702,6974,7123,7153,7183,7213,
    6877,7244,7274,7304,7334,6842,7364,7394,7424,7454, 6947,7484,7514,7544,7574,6912,7604,7634,7664,7694,19211,19691,19721,19751,19781
    ,19121,19331,19361,19391,19421,19122,19332,19362,19392,19422,
    19151,19451,19481,19511,19541,19301,19152,19452,19482,19512,19542,19302,
    19181,19571,19601,19631,19661,19182,19572,19602,19632,19662,
    19211,19691,19721,19751,19781,19212,19692,19722,19752,19782,
    19241,19811,19841,19871,19901,19242,19812,19842,19872,19902,
    19271,19931,19961,19991,20021, 19272,19932,19962,19992,20022
    ,1066,1680,1711,1738,1769,1032,1800,1831,1858,1889,1307,1207,1920,1951,1978,2009,1172,2040,
    2071,2098,2129,1277,2160,2191,2218,2249,1242,2280,2311,2338,2369,
    2841,2871,2901,2931,2557,2961,2991,3021,3051,2522,2811,3081,3111,3141,3171,2697,
     3201,3231,3261,3291,2662,3321,3351,3381,3411,2767,3441,3471,3501,3531,2732


     );


        // Loop para verificar se algum dos itens da lista está no inventário
        for i := 0 to High(ItemIDList) do
        begin
          if TItemFunctions.GetItemSlotAndAmountByIndex(Player, ItemIDList[i], ItemSlot, Refi) then
          begin
            // Verificar se o item já está no nível máximo de refinamento (+11)
            if Refi >= RefinementStepMax then
            begin
              // Envia uma mensagem ao jogador informando que o item já está no valor máximo
              Player.SendClientMessage(Format('O item %d já está no valor máximo de refinamento +11.', [ItemIDList[i]]));
              Continue; // Verifica o próximo item na lista

             // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4135, 1);


            end;

            // Verifica se o item está no nível mínimo para iniciar o refinamento (entre 0 e +11)
            if (Refi >= RefinementStepMin) and (Refi < RefinementStepMax) then
            begin
              // Se o item está em +10 (valor 171), o próximo refinamento será +11, correspondente a 188
              if Refi = 171 then
              begin
                Refi := RefinementStepMax; // Define o valor diretamente como 188 para +11
              end
              else
              begin
                // Aumenta o valor de refinamento em uma etapa, normalmente
                Inc(Refi, 17); // Cada incremento representa +1 no valor de refinamento (17 é a diferença entre cada nível de refinamento)
              end;

              // Atualiza o refinamento do item no inventário
              Player.Base.Character.Inventory[ItemSlot].Refi := Refi;

              // Envia uma mensagem ao jogador informando sobre a nova etapa de refinamento
              Player.SendClientMessage(Format('O valor de refinamento do item foi atualizado para +%d.', [(Refi div 17)]));

              // Adicione aqui a lógica de salvamento no banco de dados, se necessário

              // Verifica se atingiu o valor máximo de refinamento
              if Refi >= RefinementStepMax then
              begin
                Player.SendClientMessage('O refinamento do item atingiu o valor máximo de +11.');
              end;

              // Sai do loop após refinar o primeiro item que atende aos critérios
              Break;
            end
            else
            begin
              Player.SendClientMessage('O refinamento do item precisa estar entre 0 e +11 para iniciar o refinamento.');
               // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4135, 1);
              Break; // Sai do loop, já que o refinamento não atende ao critério


            end;
          end;
        end;

        // Caso nenhum item tenha sido encontrado ou todos já estejam no nível máximo
        if i > High(ItemIDList) then
        begin
          Player.SendClientMessage('Nenhum dos itens foi encontrado no seu inventário ou já estão refinados ao máximo.');
          // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4135, 1);
        end;

        // Mensagem confirmando o uso do item 4132, se o processo ocorreu
        Player.SendClientMessage('O item Núcleo de Refinamento foi usado com sucesso.');
      end;



/// Núcleo de Refine 11 para 12>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if (item.Index = 4132) then
begin
  // Declaração das variáveis para o slot e o valor de refinamento
  var Refi: BYTE;
  var ItemIDList: TArray<Integer>;
  var RefinementStepMin: BYTE := 176; // Define o valor mínimo de refinamento como +11 (177)
  var RefinementStepMax: BYTE := 198; // Define o valor máximo de refinamento como +12 (198)

     // Definir a lista de IDs dos itens que podem ser refinados
  ItemIDList := TArray<Integer>.Create(  12067, 12373, 12403, 12433, 12463,
    12102, 12343, 12493, 12523, 12553, 12583, 19211,19691,19721,19751,19781,
    12102, 12613, 12643, 12673, 12703,
    12242, 12733, 12763, 12793, 12823,
    12277, 12853, 12883, 12913, 12943,
    12312, 12973, 13003, 13033, 13063,
    12066, 12372, 12402, 12432, 12462,
    12101, 12342, 12492, 12522, 12552, 12582,
    12206, 12612, 12642, 12672, 12702,
    12241, 12732, 12762, 12792, 12822,
    12276, 12852, 12882, 12912, 12942,
    12311, 12972, 13002, 13032, 13062,
    12073, 12072, 12379, 12378, 12409,
    12408, 12439, 12438, 12469, 12468,
    12108, 12107, 12349, 12348, 12499,
    12498, 12529, 12528, 12559, 12558, 12589, 12588,
    12213, 12212, 12619, 12618, 12649,
    12648, 12679, 12678, 12709, 12708,
    12248, 12247, 12739, 12738, 12769,
    12768, 12799, 12798, 12829, 12828,
    12283, 12282, 12859, 12858, 12889,
    12888, 12919, 12918, 12949, 12948,
    12318, 12317, 12979, 12978, 13009,
    13008, 13039, 13038, 13069, 13068,
    12233, 12234, 12235, 12236, 12726, 12727, 12728, 12729,
    12756, 12757, 12758, 12759, 12786, 12787, 12788, 12789,
    12816, 12817, 12818, 12819,
    12093, 12094, 12095, 12096, 12336, 12337, 12338, 12339,
    12486, 12487, 12488, 12489, 12516, 12517, 12518, 12519,
    12546, 12547, 12548, 12549, 12576, 12577, 12578, 12579,
    12198, 12199, 12200, 12201, 12606, 12607, 12608, 12609,
    12636, 12637, 12638, 12639, 12666, 12667, 12668, 12669,
    12696, 12697, 12698, 12699,
    12225, 12226, 12227, 12228, 12720, 12721, 12722, 12723,
    12750, 12751, 12752, 12753, 12780, 12781, 12782, 12783,
    12810, 12811, 12812, 12813,
    12268, 12269, 12270, 12271, 12846, 12847, 12848, 12849,
    12876, 12877, 12878, 12879, 12906, 12907, 12908, 12909,
    12936, 12937, 12938, 12939,
    12303, 12304, 12305, 12306, 12966, 12967, 12968, 12969,
    12996, 12997, 12998, 12999, 13026, 13027, 13028, 13029,
    13056, 13057, 13058, 13059,12076, 12382, 12412, 12442, 12472,
    12111, 12352, 12502, 12532, 12562, 12592,
    12216, 12622, 12652, 12682, 12712,
    12251, 12742, 12772, 12802, 12832,
    12286, 12862, 12892, 12922, 12952,
    12321, 12982, 13012 , 13042, 13072, 12056,12091,12196,12231,12266,12301,12340,12370,12400,
    12430,12460,12490,12520,12550,12580,12610,12640,12670,12700,12730,12760,12790,12820,12850,12880,12910,
    12940,12970,13000, 13030,13060,
    2818,2848,2878,2908,2938,2968,2998,3028,3058,
    3088,3118,3148,3178,3208,3238,3268,3298,3328,3358,
    3388,3418,3448,3478,3508,3538,5698,2528,2563,2668,2703,2738,2773,2818,
    2738,2703,2668,2563,2528,
    2569,2824,2854,2884,2914,2534,2944,2974,3004,3034,2794,2709,3064,3094,3124,3154,
    2674,3184,3214,3244,3274,2779,3304,3334,3364,3394,2744,3424,3454,3484,3514,
    2570,2825,2855,2885,2915,2535,2945,2975,3005,3035,2795,2709,3064,3094,3124,3154,
    2675,3185,3215,3245,3275,2780,3305,3335,3365,3395,2745,3425,3455,3485,3515,
    2571,2826,2856,2886,2916,2536,2946,2976,3006,3036,2796,2711,3066,3096,3126,3156,2676,3186,3216,3246,3276,
    2781,3306,3336,3366,3396,2746,3426,3456,3486,3516 , 2574,2829,2859,2889,2919,2539,2799,2949,2978,3009,3039,
    2714,3069,3099,3129,3159,2679,3189,3219,3249,3279,2784,3309,3339,3369,3399,2749,3429,3459,3489,3519,6738,7005,7035,7065,7095,6703,6975,7124,7154,7184,7214,6878,7245,7275,7305,7335,6843,7365,7395,7425,7455,
    6948,7485,7515,7545,7575,6913,7605,7635,7665,7695,3942,3943,3944,3945,3946,3948,3949,3950,3951,3952,3953,3955,3956,3957,3958,3959,3961,3962,3963,3964,3965,
    3967,3968,3969,3970,3971,3973,3974,3975,3979,3977, 3979,3890,3981,3982,3983,3985,3986,3987,3988,3989,3990,
    3992,3993,3994,3995,3996,3998,3999,4000,4001,4002,4004,4005,4006,4007,4008,4010,4011,4012,4013,4014 ,
    6736,7003,7033,7063,7093,6701,6973,7122,7152,7182,7212,6876,7243,7273,7303,7333,6841,7363,7393,7423,7453,
    6946,7483,7513,7543,7573, 6911,7603,7633,7663,7693,6737,7004,7034,7064,7094,6702,6974,7123,7153,7183,7213,
    6877,7244,7274,7304,7334,6842,7364,7394,7424,7454, 6947,7484,7514,7544,7574,6912,7604,7634,7664,7694,19211,19691,19721,19751,19781
    ,19121,19331,19361,19391,19421,19122,19332,19362,19392,19422,
    19151,19451,19481,19511,19541,19301,19152,19452,19482,19512,19542,19302,
    19181,19571,19601,19631,19661,19182,19572,19602,19632,19662,
    19211,19691,19721,19751,19781,19212,19692,19722,19752,19782,
    19241,19811,19841,19871,19901,19242,19812,19842,19872,19902,
    19271,19931,19961,19991,20021, 19272,19932,19962,19992,20022
    ,1066,1680,1711,1738,1769,1032,1800,1831,1858,1889,1307,1207,1920,1951,1978,2009,1172,2040,
    2071,2098,2129,1277,2160,2191,2218,2249,1242,2280,2311,2338,2369,
    2841,2871,2901,2931,2557,2961,2991,3021,3051,2522,2811,3081,3111,3141,3171,2697,
     3201,3231,3261,3291,2662,3321,3351,3381,3411,2767,3441,3471,3501,3531,2732
     );



  // Loop para verificar se algum dos itens da lista está no inventário
  for i := 0 to High(ItemIDList) do
  begin
    if TItemFunctions.GetItemSlotAndAmountByIndex(Player, ItemIDList[i], ItemSlot, Refi) then
    begin
      // Verificar se o item já está no nível máximo de refinamento (+12)
      if Refi >= RefinementStepMax then
      begin
        // Envia uma mensagem ao jogador informando que o item já está no valor máximo
        Player.SendClientMessage(Format('O item %d já está no valor máximo de refinamento +12.', [ItemIDList[i]]));
        Continue; // Verifica o próximo item na lista
        // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4132, 1);

      end;

      // Verifica se o item está no intervalo permitido para refinamento (+11)
      if (Refi >= RefinementStepMin) and (Refi < RefinementStepMax) then
      begin
        // Se o refinamento está entre 177 e 192, ele será incrementado para +12 (198)
        Refi := RefinementStepMax; // Define o valor diretamente como 198 para +12

        // Atualiza o refinamento do item no inventário
        Player.Base.Character.Inventory[ItemSlot].Refi := Refi;

        // Envia uma mensagem ao jogador informando sobre a nova etapa de refinamento
        Player.SendClientMessage('O valor de refinamento do item foi atualizado para +12 .');

        // Verifica se atingiu o valor máximo de refinamento
        if Refi >= RefinementStepMax then
        begin
          Player.SendClientMessage('O refinamento do item atingiu o valor máximo de +12.');
        end;

        // Sai do loop após refinar o primeiro item que atende aos critérios
        Break;
      end
      else
      begin
        Player.SendClientMessage('O refinamento do item precisa estar entre +11 para ser refinado +12.');
        // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4132, 1);
        Break; // Sai do loop, já que o refinamento não atende ao critério

      end;
    end;
  end;

  // Caso nenhum item tenha sido encontrado ou todos já estejam no nível máximo
  if i > High(ItemIDList) then
  begin
    Player.SendClientMessage('Nenhum dos itens foi encontrado no seu inventário ou já estão refinados ao máximo.');
     // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4132, 1);
  end;

  // Mensagem confirmando o uso do item 4132, se o processo ocorreu
  Player.SendClientMessage('O item Núcleo de Refinamento foi usado com sucesso.');
end;



 // Núcleo de Refine 0 para +12 e +13 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if (item.Index = 4133) then
begin
  // Declaração das variáveis para o slot e o valor de refinamento
  var Refi: BYTE;
  var ItemIDList: TArray<Integer>;
  var RefinementMin198: BYTE := 198;  // Valor de refinamento mínimo referente a +12 (198)
  var RefinementMin207: BYTE := 207;  // Outro valor de refinamento mínimo referente a +12 (207)
  var RefinementStepMax: BYTE := 220; // Define o valor máximo de refinamento (equivalente a +13)

     // Definir a lista de IDs dos itens que podem ser refinados
  ItemIDList := TArray<Integer>.Create(  12067, 12373, 12403, 12433, 12463,
    12102, 12343, 12493, 12523, 12553, 12583, 12583, 19211,19691,19721,19751,19781,
    12102, 12613, 12643, 12673, 12703,
    12242, 12733, 12763, 12793, 12823,
    12277, 12853, 12883, 12913, 12943,
    12312, 12973, 13003, 13033, 13063,
    12066, 12372, 12402, 12432, 12462,
    12101, 12342, 12492, 12522, 12552, 12582,
    12206, 12612, 12642, 12672, 12702,
    12241, 12732, 12762, 12792, 12822,
    12276, 12852, 12882, 12912, 12942,
    12311, 12972, 13002, 13032, 13062,
    12073, 12072, 12379, 12378, 12409,
    12408, 12439, 12438, 12469, 12468,
    12108, 12107, 12349, 12348, 12499,
    12498, 12529, 12528, 12559, 12558, 12589, 12588,
    12213, 12212, 12619, 12618, 12649,
    12648, 12679, 12678, 12709, 12708,
    12248, 12247, 12739, 12738, 12769,
    12768, 12799, 12798, 12829, 12828,
    12283, 12282, 12859, 12858, 12889,
    12888, 12919, 12918, 12949, 12948,
    12318, 12317, 12979, 12978, 13009,
    13008, 13039, 13038, 13069, 13068,
    12233, 12234, 12235, 12236, 12726, 12727, 12728, 12729,
    12756, 12757, 12758, 12759, 12786, 12787, 12788, 12789,
    12816, 12817, 12818, 12819,
    12093, 12094, 12095, 12096, 12336, 12337, 12338, 12339,
    12486, 12487, 12488, 12489, 12516, 12517, 12518, 12519,
    12546, 12547, 12548, 12549, 12576, 12577, 12578, 12579,
    12198, 12199, 12200, 12201, 12606, 12607, 12608, 12609,
    12636, 12637, 12638, 12639, 12666, 12667, 12668, 12669,
    12696, 12697, 12698, 12699,
    12225, 12226, 12227, 12228, 12720, 12721, 12722, 12723,
    12750, 12751, 12752, 12753, 12780, 12781, 12782, 12783,
    12810, 12811, 12812, 12813,
    12268, 12269, 12270, 12271, 12846, 12847, 12848, 12849,
    12876, 12877, 12878, 12879, 12906, 12907, 12908, 12909,
    12936, 12937, 12938, 12939,
    12303, 12304, 12305, 12306, 12966, 12967, 12968, 12969,
    12996, 12997, 12998, 12999, 13026, 13027, 13028, 13029,
    13056, 13057, 13058, 13059,12076, 12382, 12412, 12442, 12472,
    12111, 12352, 12502, 12532, 12562, 12592,
    12216, 12622, 12652, 12682, 12712,
    12251, 12742, 12772, 12802, 12832,
    12286, 12862, 12892, 12922, 12952,
    12321, 12982, 13012 , 13042, 13072, 12056,12091,12196,12231,12266,12301,12340,12370,12400,
    12430,12460,12490,12520,12550,12580,12610,12640,12670,12700,12730,12760,12790,12820,12850,12880,12910,
    12940,12970,13000, 13030,13060,
    2818,2848,2878,2908,2938,2968,2998,3028,3058,
    3088,3118,3148,3178,3208,3238,3268,3298,3328,3358,
    3388,3418,3448,3478,3508,3538,5698,2528,2563,2668,2703,2738,2773,2818,
    2738,2703,2668,2563,2528,
    2569,2824,2854,2884,2914,2534,2944,2974,3004,3034,2794,2709,3064,3094,3124,3154,
    2674,3184,3214,3244,3274,2779,3304,3334,3364,3394,2744,3424,3454,3484,3514,
    2570,2825,2855,2885,2915,2535,2945,2975,3005,3035,2795,2709,3064,3094,3124,3154,
    2675,3185,3215,3245,3275,2780,3305,3335,3365,3395,2745,3425,3455,3485,3515,
    2571,2826,2856,2886,2916,2536,2946,2976,3006,3036,2796,2711,3066,3096,3126,3156,2676,3186,3216,3246,3276,
    2781,3306,3336,3366,3396,2746,3426,3456,3486,3516 , 2574,2829,2859,2889,2919,2539,2799,2949,2978,3009,3039,
    2714,3069,3099,3129,3159,2679,3189,3219,3249,3279,2784,3309,3339,3369,3399,2749,3429,3459,3489,3519,
    6738,7005,7035,7065,7095,6703,6975,7124,7154,7184,7214,6878,7245,7275,7305,7335,6843,7365,7395,7425,7455,
    6948,7485,7515,7545,7575,6913,7605,7635,7665,7695,
    3942,3943,3944,3945,3946,3948,3949,3950,3951,3952,3953,3955,3956,3957,3958,3959,3961,3962,3963,3964,3965,
    3967,3968,3969,3970,3971,3973,3974,3975,3979,3977, 3979,3890,3981,3982,3983,3985,3986,3987,3988,3989,3990,
    3992,3993,3994,3995,3996,3998,3999,4000,4001,4002,4004,4005,4006,4007,4008,4010,4011,4012,4013,4014 ,
    6736,7003,7033,7063,7093,6701,6973,7122,7152,7182,7212,6876,7243,7273,7303,7333,6841,7363,7393,7423,7453,
    6946,7483,7513,7543,7573, 6911,7603,7633,7663,7693,6737,7004,7034,7064,7094,6702,6974,7123,7153,7183,7213,
    6877,7244,7274,7304,7334,6842,7364,7394,7424,7454, 6947,7484,7514,7544,7574,6912,7604,7634,7664,7694,19211,19691,19721,19751,19781
    ,19121,19331,19361,19391,19421,19122,19332,19362,19392,19422,
    19151,19451,19481,19511,19541,19301,19152,19452,19482,19512,19542,19302,
    19181,19571,19601,19631,19661,19182,19572,19602,19632,19662,
    19211,19691,19721,19751,19781,19212,19692,19722,19752,19782,
    19241,19811,19841,19871,19901,19242,19812,19842,19872,19902,
    19271,19931,19961,19991,20021, 19272,19932,19962,19992,20022
    ,1066,1680,1711,1738,1769,1032,1800,1831,1858,1889,1307,1207,1920,1951,1978,2009,1172,2040,
    2071,2098,2129,1277,2160,2191,2218,2249,1242,2280,2311,2338,2369,
    2841,2871,2901,2931,2557,2961,2991,3021,3051,2522,2811,3081,3111,3141,3171,2697,
     3201,3231,3261,3291,2662,3321,3351,3381,3411,2767,3441,3471,3501,3531,2732
     );

  // Loop para verificar se algum dos itens da lista está no inventário
  for i := 0 to High(ItemIDList) do
  begin
    if TItemFunctions.GetItemSlotAndAmountByIndex(Player, ItemIDList[i], ItemSlot, Refi) then
    begin
      // Verificar se o item já está no nível máximo de refinamento (+13)
      if Refi >= RefinementStepMax then
      begin
        // Envia uma mensagem ao jogador informando que o item já está no valor máximo
        Player.SendClientMessage(Format('O item %d já está no valor máximo de refinamento +13.', [ItemIDList[i]]));
        Continue; // Verifica o próximo item na lista
         // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4133, 1);
      end;

      // Verifica se o item está no intervalo de refinamento para +12 (198 ou 207)
      if (Refi >= RefinementMin198) and (Refi <= RefinementMin207) then
      begin
        // Se o refinamento está entre 198 e 207, ajusta o valor diretamente para 230 (+13)
        Refi := RefinementStepMax;

        // Atualiza o refinamento do item no inventário
        Player.Base.Character.Inventory[ItemSlot].Refi := Refi;

        // Envia uma mensagem ao jogador informando sobre a nova etapa de refinamento
        if Refi >= RefinementStepMax then
        begin
          Player.SendClientMessage('O refinamento do item foi atualizado para +13 .');
        end;

        // Adicione aqui a lógica de salvamento no banco de dados, se necessário

        // Verifica se atingiu o valor máximo de refinamento
        if Refi >= RefinementStepMax then
        begin
          Player.SendClientMessage('O refinamento do item atingiu o valor máximo de +13.');
        end;

        // Sai do loop após refinar o primeiro item que atende aos critérios
        Break;
      end
      else
      begin
        Player.SendClientMessage('O refinamento do item precisa estar no +12 para ser considerado +13.');
        // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4133, 1);
        Break; // Sai do loop, já que o refinamento não atende ao critério

      end;
    end;
  end;

  // Caso nenhum item tenha sido encontrado ou todos já estejam no nível máximo
  if i > High(ItemIDList) then
  begin
    Player.SendClientMessage('Nenhum dos itens foi encontrado no seu inventário ou já estão refinados ao máximo.');
     // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4133, 1);
  end;

  // Mensagem confirmando o uso do item 4133, se o processo ocorreu
  Player.SendClientMessage('O item Núcleo de Refinamento foi usado com sucesso.');
end;



 // Núcleo de Refine 0 para +13 e +14 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if (item.Index = 4134) then
begin
  // Declaração das variáveis para o slot e o valor de refinamento
  var Refi: BYTE;
  var ItemIDList: TArray<Integer>;
  var RefinementMin198: BYTE := 208;  // Valor de refinamento mínimo referente a +12 (198)
  var RefinementMin207: BYTE := 229;  // Outro valor de refinamento mínimo referente a +12 (207)
  var RefinementStepMax: BYTE := 230; // Define o valor máximo de refinamento (equivalente a +13)

      // Definir a lista de IDs dos itens que podem ser refinados
  ItemIDList := TArray<Integer>.Create(  12067, 12373, 12403, 12433, 12463,
    12102, 12343, 12493, 12523, 12553, 12583, 12583, 19211,19691,19721,19751,19781,
    12102, 12613, 12643, 12673, 12703,
    12242, 12733, 12763, 12793, 12823,
    12277, 12853, 12883, 12913, 12943,
    12312, 12973, 13003, 13033, 13063,
    12066, 12372, 12402, 12432, 12462,
    12101, 12342, 12492, 12522, 12552, 12582,
    12206, 12612, 12642, 12672, 12702,
    12241, 12732, 12762, 12792, 12822,
    12276, 12852, 12882, 12912, 12942,
    12311, 12972, 13002, 13032, 13062,
    12073, 12072, 12379, 12378, 12409,
    12408, 12439, 12438, 12469, 12468,
    12108, 12107, 12349, 12348, 12499,
    12498, 12529, 12528, 12559, 12558, 12589, 12588,
    12213, 12212, 12619, 12618, 12649,
    12648, 12679, 12678, 12709, 12708,
    12248, 12247, 12739, 12738, 12769,
    12768, 12799, 12798, 12829, 12828,
    12283, 12282, 12859, 12858, 12889,
    12888, 12919, 12918, 12949, 12948,
    12318, 12317, 12979, 12978, 13009,
    13008, 13039, 13038, 13069, 13068,
    12233, 12234, 12235, 12236, 12726, 12727, 12728, 12729,
    12756, 12757, 12758, 12759, 12786, 12787, 12788, 12789,
    12816, 12817, 12818, 12819,
    12093, 12094, 12095, 12096, 12336, 12337, 12338, 12339,
    12486, 12487, 12488, 12489, 12516, 12517, 12518, 12519,
    12546, 12547, 12548, 12549, 12576, 12577, 12578, 12579,
    12198, 12199, 12200, 12201, 12606, 12607, 12608, 12609,
    12636, 12637, 12638, 12639, 12666, 12667, 12668, 12669,
    12696, 12697, 12698, 12699,
    12225, 12226, 12227, 12228, 12720, 12721, 12722, 12723,
    12750, 12751, 12752, 12753, 12780, 12781, 12782, 12783,
    12810, 12811, 12812, 12813,
    12268, 12269, 12270, 12271, 12846, 12847, 12848, 12849,
    12876, 12877, 12878, 12879, 12906, 12907, 12908, 12909,
    12936, 12937, 12938, 12939,
    12303, 12304, 12305, 12306, 12966, 12967, 12968, 12969,
    12996, 12997, 12998, 12999, 13026, 13027, 13028, 13029,
    13056, 13057, 13058, 13059,12076, 12382, 12412, 12442, 12472,
    12111, 12352, 12502, 12532, 12562, 12592,
    12216, 12622, 12652, 12682, 12712,
    12251, 12742, 12772, 12802, 12832,
    12286, 12862, 12892, 12922, 12952,
    12321, 12982, 13012 , 13042, 13072, 12056,12091,12196,12231,12266,12301,12340,12370,12400,
    12430,12460,12490,12520,12550,12580,12610,12640,12670,12700,12730,12760,12790,12820,12850,12880,12910,
    12940,12970,13000, 13030,13060,
    2818,2848,2878,2908,2938,2968,2998,3028,3058,
    3088,3118,3148,3178,3208,3238,3268,3298,3328,3358,
    3388,3418,3448,3478,3508,3538,5698,2528,2563,2668,2703,2738,2773,2818,
    2738,2703,2668,2563,2528,
    2569,2824,2854,2884,2914,2534,2944,2974,3004,3034,2794,2709,3064,3094,3124,3154,
    2674,3184,3214,3244,3274,2779,3304,3334,3364,3394,2744,3424,3454,3484,3514,
    2570,2825,2855,2885,2915,2535,2945,2975,3005,3035,2795,2709,3064,3094,3124,3154,
    2675,3185,3215,3245,3275,2780,3305,3335,3365,3395,2745,3425,3455,3485,3515,
    2571,2826,2856,2886,2916,2536,2946,2976,3006,3036,2796,2711,3066,3096,3126,3156,2676,3186,3216,3246,3276,
    2781,3306,3336,3366,3396,2746,3426,3456,3486,3516 , 2574,2829,2859,2889,2919,2539,2799,2949,2978,3009,3039,
    2714,3069,3099,3129,3159,2679,3189,3219,3249,3279,2784,3309,3339,3369,3399,2749,3429,3459,3489,3519,
    6738,7005,7035,7065,7095,6703,6975,7124,7154,7184,7214,6878,7245,7275,7305,7335,6843,7365,7395,7425,7455,
    6948,7485,7515,7545,7575,6913,7605,7635,7665,7695,
    3942,3943,3944,3945,3946,3948,3949,3950,3951,3952,3953,3955,3956,3957,3958,3959,3961,3962,3963,3964,3965,
    3967,3968,3969,3970,3971,3973,3974,3975,3979,3977, 3979,3890,3981,3982,3983,3985,3986,3987,3988,3989,3990,
    3992,3993,3994,3995,3996,3998,3999,4000,4001,4002,4004,4005,4006,4007,4008,4010,4011,4012,4013,4014,
    6736,7003,7033,7063,7093,6701,6973,7122,7152,7182,7212,6876,7243,7273,7303,7333,6841,7363,7393,7423,7453,
    6946,7483,7513,7543,7573, 6911,7603,7633,7663,7693,6737,7004,7034,7064,7094,6702,6974,7123,7153,7183,7213,
    6877,7244,7274,7304,7334,6842,7364,7394,7424,7454, 6947,7484,7514,7544,7574,6912,7604,7634,7664,7694,19211,19691,19721,19751,19781
    ,19121,19331,19361,19391,19421,19122,19332,19362,19392,19422,
    19151,19451,19481,19511,19541,19301,19152,19452,19482,19512,19542,19302,
    19181,19571,19601,19631,19661,19182,19572,19602,19632,19662,
    19211,19691,19721,19751,19781,19212,19692,19722,19752,19782,
    19241,19811,19841,19871,19901,19242,19812,19842,19872,19902,
    19271,19931,19961,19991,20021, 19272,19932,19962,19992,20022
    ,1066,1680,1711,1738,1769,1032,1800,1831,1858,1889,1307,1207,1920,1951,1978,2009,1172,2040,
    2071,2098,2129,1277,2160,2191,2218,2249,1242,2280,2311,2338,2369,
    2841,2871,2901,2931,2557,2961,2991,3021,3051,2522,2811,3081,3111,3141,3171,2697,
     3201,3231,3261,3291,2662,3321,3351,3381,3411,2767,3441,3471,3501,3531,2732
     );

  // Loop para verificar se algum dos itens da lista está no inventário
  for i := 0 to High(ItemIDList) do
  begin
    if TItemFunctions.GetItemSlotAndAmountByIndex(Player, ItemIDList[i], ItemSlot, Refi) then
    begin
      // Verificar se o item já está no nível máximo de refinamento (+13)
      if Refi >= RefinementStepMax then
      begin
        // Envia uma mensagem ao jogador informando que o item já está no valor máximo
        Player.SendClientMessage(Format('O item %d já está no valor máximo de refinamento +14.', [ItemIDList[i]]));
        Continue; // Verifica o próximo item na lista
         // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4132, 1);
      end;

      // Verifica se o item está no intervalo de refinamento para +13 (198 ou 207)
      if (Refi >= RefinementMin198) and (Refi <= RefinementMin207) then
      begin
        // Se o refinamento está entre 198 e 207, ajusta o valor diretamente para 230 (+14)
        Refi := RefinementStepMax;

        // Atualiza o refinamento do item no inventário
        Player.Base.Character.Inventory[ItemSlot].Refi := Refi;

        // Envia uma mensagem ao jogador informando sobre a nova etapa de refinamento
        if Refi >= RefinementStepMax then
        begin
          Player.SendClientMessage('O refinamento do item foi atualizado para +14 .');
        end;

        // Adicione aqui a lógica de salvamento no banco de dados, se necessário

        // Verifica se atingiu o valor máximo de refinamento
        if Refi >= RefinementStepMax then
        begin
          Player.SendClientMessage('O refinamento do item atingiu o valor máximo de +14.');
        end;

        // Sai do loop após refinar o primeiro item que atende aos critérios
        Break;
      end
      else
      begin
        Player.SendClientMessage('O refinamento do item precisa estar no +13 para ser considerado +14.');
        // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4134, 1);
        Break; // Sai do loop, já que o refinamento não atende ao critério

      end;
    end;
  end;

  // Caso nenhum item tenha sido encontrado ou todos já estejam no nível máximo
  if i > High(ItemIDList) then
  begin
    Player.SendClientMessage('Nenhum dos itens foi encontrado no seu inventário ou já estão refinados ao máximo.');
     // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4134, 1);
  end;

  // Mensagem confirmando o uso do item 4133, se o processo ocorreu
  Player.SendClientMessage('O item Núcleo de Refinamento foi usado com sucesso.');
end;


    // Núcleo de Refine 0 para +14 e +15 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if (item.Index = 4131) then
begin
  // Declaração das variáveis para o slot e o valor de refinamento
  var Refi: BYTE;
  var ItemIDList: TArray<Integer>;
  var RefinementMin198: BYTE := 230;  // Valor de refinamento mínimo referente a +14 (198)
  var RefinementMin207: BYTE := 249;  // Outro valor de refinamento mínimo referente a +14 (207)
  var RefinementStepMax: BYTE := 250; // Define o valor máximo de refinamento (equivalente a +15)

      // Definir a lista de IDs dos itens que podem ser refinados
  ItemIDList := TArray<Integer>.Create(  12067, 12373, 12403, 12433, 12463,
    12102, 12343, 12493, 12523, 12553, 12583, 12583, 19211,19691,19721,19751,19781,
    12102, 12613, 12643, 12673, 12703,
    12242, 12733, 12763, 12793, 12823,
    12277, 12853, 12883, 12913, 12943,
    12312, 12973, 13003, 13033, 13063,
    12066, 12372, 12402, 12432, 12462,
    12101, 12342, 12492, 12522, 12552, 12582,
    12206, 12612, 12642, 12672, 12702,
    12241, 12732, 12762, 12792, 12822,
    12276, 12852, 12882, 12912, 12942,
    12311, 12972, 13002, 13032, 13062,
    12073, 12072, 12379, 12378, 12409,
    12408, 12439, 12438, 12469, 12468,
    12108, 12107, 12349, 12348, 12499,
    12498, 12529, 12528, 12559, 12558, 12589, 12588,
    12213, 12212, 12619, 12618, 12649,
    12648, 12679, 12678, 12709, 12708,
    12248, 12247, 12739, 12738, 12769,
    12768, 12799, 12798, 12829, 12828,
    12283, 12282, 12859, 12858, 12889,
    12888, 12919, 12918, 12949, 12948,
    12318, 12317, 12979, 12978, 13009,
    13008, 13039, 13038, 13069, 13068,
    12233, 12234, 12235, 12236, 12726, 12727, 12728, 12729,
    12756, 12757, 12758, 12759, 12786, 12787, 12788, 12789,
    12816, 12817, 12818, 12819,
    12093, 12094, 12095, 12096, 12336, 12337, 12338, 12339,
    12486, 12487, 12488, 12489, 12516, 12517, 12518, 12519,
    12546, 12547, 12548, 12549, 12576, 12577, 12578, 12579,
    12198, 12199, 12200, 12201, 12606, 12607, 12608, 12609,
    12636, 12637, 12638, 12639, 12666, 12667, 12668, 12669,
    12696, 12697, 12698, 12699,
    12225, 12226, 12227, 12228, 12720, 12721, 12722, 12723,
    12750, 12751, 12752, 12753, 12780, 12781, 12782, 12783,
    12810, 12811, 12812, 12813,
    12268, 12269, 12270, 12271, 12846, 12847, 12848, 12849,
    12876, 12877, 12878, 12879, 12906, 12907, 12908, 12909,
    12936, 12937, 12938, 12939,
    12303, 12304, 12305, 12306, 12966, 12967, 12968, 12969,
    12996, 12997, 12998, 12999, 13026, 13027, 13028, 13029,
    13056, 13057, 13058, 13059,12076, 12382, 12412, 12442, 12472,
    12111, 12352, 12502, 12532, 12562, 12592,
    12216, 12622, 12652, 12682, 12712,
    12251, 12742, 12772, 12802, 12832,
    12286, 12862, 12892, 12922, 12952,
    12321, 12982, 13012 , 13042, 13072, 12056,12091,12196,12231,12266,12301,12340,12370,12400,
    12430,12460,12490,12520,12550,12580,12610,12640,12670,12700,12730,12760,12790,12820,12850,12880,12910,
    12940,12970,13000, 13030,13060,
    2818,2848,2878,2908,2938,2968,2998,3028,3058,
    3088,3118,3148,3178,3208,3238,3268,3298,3328,3358,
    3388,3418,3448,3478,3508,3538,5698,2528,2563,2668,2703,2738,2773,2818,
    2738,2703,2668,2563,2528,
    2569,2824,2854,2884,2914,2534,2944,2974,3004,3034,2794,2709,3064,3094,3124,3154,
    2674,3184,3214,3244,3274,2779,3304,3334,3364,3394,2744,3424,3454,3484,3514,
    2570,2825,2855,2885,2915,2535,2945,2975,3005,3035,2795,2709,3064,3094,3124,3154,
    2675,3185,3215,3245,3275,2780,3305,3335,3365,3395,2745,3425,3455,3485,3515,
    2571,2826,2856,2886,2916,2536,2946,2976,3006,3036,2796,2711,3066,3096,3126,3156,2676,3186,3216,3246,3276,
    2781,3306,3336,3366,3396,2746,3426,3456,3486,3516 , 2574,2829,2859,2889,2919,2539,2799,2949,2978,3009,3039,
    2714,3069,3099,3129,3159,2679,3189,3219,3249,3279,2784,3309,3339,3369,3399,2749,3429,3459,3489,3519,6738,7005,7035,7065,7095,6703,6975,7124,7154,7184,7214,6878,7245,7275,7305,7335,6843,7365,7395,7425,7455,
    6948,7485,7515,7545,7575,6913,7605,7635,7665,7695,
    3942,3943,3944,3945,3946,3948,3949,3950,3951,3952,3953,3955,3956,3957,3958,3959,3961,3962,3963,3964,3965,
    3967,3968,3969,3970,3971,3973,3974,3975,3979,3977, 3979,3890,3981,3982,3983,3985,3986,3987,3988,3989,3990,
    3992,3993,3994,3995,3996,3998,3999,4000,4001,4002,4004,4005,4006,4007,4008,4010,4011,4012,4013,4014 ,
    6736,7003,7033,7063,7093,6701,6973,7122,7152,7182,7212,6876,7243,7273,7303,7333,6841,7363,7393,7423,7453,
    6946,7483,7513,7543,7573, 6911,7603,7633,7663,7693,6737,7004,7034,7064,7094,6702,6974,7123,7153,7183,7213,
    6877,7244,7274,7304,7334,6842,7364,7394,7424,7454, 6947,7484,7514,7544,7574,6912,7604,7634,7664,7694,19211,19691,19721,19751,19781
    ,19121,19331,19361,19391,19421,19122,19332,19362,19392,19422,
    19151,19451,19481,19511,19541,19301,19152,19452,19482,19512,19542,19302,
    19181,19571,19601,19631,19661,19182,19572,19602,19632,19662,
    19211,19691,19721,19751,19781,19212,19692,19722,19752,19782,
    19241,19811,19841,19871,19901,19242,19812,19842,19872,19902,
    19271,19931,19961,19991,20021, 19272,19932,19962,19992,20022
    ,1066,1680,1711,1738,1769,1032,1800,1831,1858,1889,1307,1207,1920,1951,1978,2009,1172,2040,
    2071,2098,2129,1277,2160,2191,2218,2249,1242,2280,2311,2338,2369,
    2841,2871,2901,2931,2557,2961,2991,3021,3051,2522,2811,3081,3111,3141,3171,2697,
     3201,3231,3261,3291,2662,3321,3351,3381,3411,2767,3441,3471,3501,3531,2732
     );

  // Loop para verificar se algum dos itens da lista está no inventário
  for i := 0 to High(ItemIDList) do
  begin
    if TItemFunctions.GetItemSlotAndAmountByIndex(Player, ItemIDList[i], ItemSlot, Refi) then
    begin
      // Verificar se o item já está no nível máximo de refinamento (+13)
      if Refi >= RefinementStepMax then
      begin
        // Envia uma mensagem ao jogador informando que o item já está no valor máximo
        Player.SendClientMessage(Format('O item %d já está no valor máximo de refinamento +15.', [ItemIDList[i]]));
        Continue; // Verifica o próximo item na lista
         // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4131, 1);
      end;

      // Verifica se o item está no intervalo de refinamento para +12 (198 ou 207)
      if (Refi >= RefinementMin198) and (Refi <= RefinementMin207) then
      begin
        // Se o refinamento está entre 198 e 207, ajusta o valor diretamente para 230 (+13)
        Refi := RefinementStepMax;

        // Atualiza o refinamento do item no inventário
        Player.Base.Character.Inventory[ItemSlot].Refi := Refi;

        // Envia uma mensagem ao jogador informando sobre a nova etapa de refinamento
        if Refi >= RefinementStepMax then
        begin
          Player.SendClientMessage('O refinamento do item foi atualizado para +15.');
        end;

        // Adicione aqui a lógica de salvamento no banco de dados, se necessário

        // Verifica se atingiu o valor máximo de refinamento
        if Refi >= RefinementStepMax then
        begin
          Player.SendClientMessage('O refinamento do item atingiu o valor máximo de +15.');
        end;

        // Sai do loop após refinar o primeiro item que atende aos critérios
        Break;
      end
      else
      begin
        Player.SendClientMessage('O refinamento do item precisa estar no 14 para ser considerado +15.');

         // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4131, 1);
        Break; // Sai do loop, já que o refinamento não atende ao critério

      end;
    end;
  end;

  // Caso nenhum item tenha sido encontrado ou todos já estejam no nível máximo
  if i > High(ItemIDList) then
  begin
    Player.SendClientMessage('Nenhum dos itens foi encontrado no seu inventário ou já estão refinados ao máximo.');
     // Adiciona o item 4131 ao inventário do jogador
             TItemFunctions.PutItem(Player, 4131, 1);
  end;

  // Mensagem confirmando o uso do item 4133, se o processo ocorreu
  Player.SendClientMessage('O item Núcleo de Refinamento foi usado com sucesso.');
end;


















  {//pergamminho para telar para o tiamat em outras nações
   if (item.Index = 8217) then
  begin
      Player.Teleport(TPosition.Create(2943,1667));
  end;}

  case ItemList[item.Index].ItemType of
{$REGION 'Gold e Cash'}
    ITEM_TYPE_USE_GOLD_COIN:
      begin
        Player.AddGold((ItemList[item.Index].SellPrince));

        Player.SendClientMessage('Você recebeu o valor de [' +
          ItemList[item.Index].SellPrince.ToString() + '] em gold.');
      end;

      ITEM_TYPE_USE_CASH_COIN:
      begin
        Player.AddCash((ItemList[item.Index].UseEffect));

        Player.SendClientMessage('Você recebeu o valor de [' +
          ItemList[item.Index].UseEffect.ToString() + '] em cash.');
      end;

      ITEM_TYPE_USE_RICH_GOLD_COIN:
      begin
        Player.AddGold((ItemList[item.Index].SellPrince));

        Player.SendClientMessage('Você recebeu o valor de [' +
          ItemList[item.Index].SellPrince.ToString() + '] em gold.');
      end;
{$ENDREGION}
{$REGION 'Baús e Caixas'}
    ITEM_TYPE_BAU:
      begin
        case ItemList[item.Index].UseEffect of
{$REGION 'Caixa do Elter Aposentado'}
          1133: //caixa que vem raro 50 evento full +9
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 2822, 48);
                    Self.PutEquipament(Player, 2852, 48);
                    Self.PutEquipament(Player, 2882, 48);
                    Self.PutEquipament(Player, 2912, 48);
                    Self.PutEquipament(Player, 6724, 48);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 2792, 48);
                    Self.PutEquipament(Player, 2942, 48);
                    Self.PutEquipament(Player, 2972, 48);
                    Self.PutEquipament(Player, 3002, 48);
                    Self.PutEquipament(Player, 3032, 48);
                    Self.PutEquipament(Player, 6689, 48);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 3062, 48);
                    Self.PutEquipament(Player, 3092, 48);
                    Self.PutEquipament(Player, 3122, 48);
                    Self.PutEquipament(Player, 3152, 48);
                    Self.PutEquipament(Player, 6864, 48);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 3182, 48);
                    Self.PutEquipament(Player, 3212, 48);
                    Self.PutEquipament(Player, 3242, 48);
                    Self.PutEquipament(Player, 3272, 48);
                    Self.PutEquipament(Player, 6829, 48);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 3302, 48);
                    Self.PutEquipament(Player, 3332, 48);
                    Self.PutEquipament(Player, 3362, 48);
                    Self.PutEquipament(Player, 3392, 48);
                    Self.PutEquipament(Player, 6934, 48);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 3422, 48);
                    Self.PutEquipament(Player, 3452, 48);
                    Self.PutEquipament(Player, 3482, 48);
                    Self.PutEquipament(Player, 3512, 48);
                    Self.PutEquipament(Player, 6899, 48);
                  end;
              end;
            end;
{$ENDREGION}
{$REGION 'Caixa dos Fundadores'}
          1134: //caixa dos fundadores 01
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Self.PutItem(Player, 13562, 1);	//XP
			        Self.PutItem(Player, 8013, 1);	//Bag
              Self.PutItem(Player, 8029, 1);	//Pran
			        Self.PutItem(Player, 8106, 100);	//ComidaPran
              Self.PutItem(Player, 4359, 150);	//Lagrima
              Player.AddTitle(80, 1);
            end;

          1135: //caixa dos fundadores 02
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 8012, 1);	//XP
              Self.PutItem(Player, 7903, 1);	//Bag
              Self.PutItem(Player, 7909, 1);	//Pran
              self.PutItem(player, 8106, 200);	//ComidaPran
              self.PutItem(player, 4359, 350);	//4359

              Player.AddCash(10000);
              Player.SendCashInventory;
              Player.AddTitle(81, 1);
            end;

          1136: //caixa dos fundadores 03
            begin
               if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 8065, 1); //xp 30 dias
              Self.PutItem(Player, 7904, 1);
              Self.PutItem(Player, 7910, 1);
              self.PutItem(player, 8106, 500);
              self.PutItem(player, 4359, 750);
              self.PutItem(player, 8087, 1);
              self.PutItem(player, 14143, 1);
              self.PutItem(player, 14144, 1);

              Player.AddCash(30000);
              Player.SendCashInventory;
              Player.AddTitle(82, 1);
            end;

          1137: //caixa dos fundadores 04
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 8065, 1); //xp 30 dias
              Self.PutItem(Player, 8031, 1);
              Self.PutItem(Player, 8032, 1);
              Self.PutItem(Player, 8106, 1000);
              Self.PutItem(Player, 4359, 1000);
              self.PutItem(Player, 8250, 1);
              self.PutItem(player, 8088, 1);
              self.PutItem(player, 14145, 1);


              Player.AddCash(60000);
              Player.SendCashInventory;
              Player.AddTitle(83, 1);
            end;

             1338: //Título Resoluto Notável
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

            var HasTitle: Boolean := False;
            var j: Integer;

            // Verifica se o jogador já possui o título (index 20)
            for j := 0 to 95 do
            begin
              if (Player.Base.PlayerCharacter.Titles[j].Index = 20) then
              begin
                HasTitle := True;
                Break;
              end;
            end;

            if HasTitle then
            begin
              Player.SendClientMessage('Você já possui este título.');
              Exit;
            end;

            // Adiciona o título ao jogador
            Player.AddTitle(20, 1);
            Player.SendClientMessage('Título Resoluto Notável adicionado com sucesso!');
          end;


             1339: //Título Padrão Notável
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

            var HasTitle: Boolean := False;
            var j: Integer;

            // Verifica se o jogador já possui o título (index 21)
            for j := 0 to 95 do
            begin
              if (Player.Base.PlayerCharacter.Titles[j].Index = 21) then
              begin
                HasTitle := True;
                Break;
              end;
            end;

            if HasTitle then
            begin
              Player.SendClientMessage('Você já possui este título.');
              Exit;
            end;

            Player.AddTitle(21, 1);
            Player.SendClientMessage('Título Padrão Notável adicionado com sucesso!');
          end;

          1340: //Título Macro Notável
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

            var HasTitle: Boolean := False;
            var j: Integer;

            for j := 0 to 95 do
            begin
              if (Player.Base.PlayerCharacter.Titles[j].Index = 22) then
              begin
                HasTitle := True;
                Break;
              end;
            end;

            if HasTitle then
            begin
              Player.SendClientMessage('Você já possui este título.');
              Exit;
            end;

            Player.AddTitle(22, 1);
            Player.SendClientMessage('Título Macro Notável adicionado com sucesso!');
          end;

          1341: //Título Estripador Notável
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

            var HasTitle: Boolean := False;
            var j: Integer;

            for j := 0 to 95 do
            begin
              if (Player.Base.PlayerCharacter.Titles[j].Index = 23) then
              begin
                HasTitle := True;
                Break;
              end;
            end;

            if HasTitle then
            begin
              Player.SendClientMessage('Você já possui este título.');
              Exit;
            end;

            Player.AddTitle(23, 1);
            Player.SendClientMessage('Título Estripador Notável adicionado com sucesso!');
          end;

          1342: //Título Escudo Notável
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

            var HasTitle: Boolean := False;
            var j: Integer;

            for j := 0 to 95 do
            begin
              if (Player.Base.PlayerCharacter.Titles[j].Index = 24) then
              begin
                HasTitle := True;
                Break;
              end;
            end;

            if HasTitle then
            begin
              Player.SendClientMessage('Você já possui este título.');
              Exit;
            end;

            Player.AddTitle(24, 1);
            Player.SendClientMessage('Título Escudo Notável adicionado com sucesso!');
          end;

          1343: //Título Lilola Notável
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

            var HasTitle: Boolean := False;
            var j: Integer;

            for j := 0 to 95 do
            begin
              if (Player.Base.PlayerCharacter.Titles[j].Index = 25) then
              begin
                HasTitle := True;
                Break;
              end;
            end;

            if HasTitle then
            begin
              Player.SendClientMessage('Você já possui este título.');
              Exit;
            end;

            Player.AddTitle(25, 1);
            Player.SendClientMessage('Título Lilola Notável adicionado com sucesso!');
          end;

          1344: //Título Fundador SSS
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

             var HasTitle: Boolean := False;
             var j: Integer;

            for j := 0 to 95 do
            begin
              if (Player.Base.PlayerCharacter.Titles[j].Index = 83) then
              begin
                HasTitle := True;
                Break;
              end;
            end;

            if HasTitle then
            begin
              Player.SendClientMessage('Você já possui este título.');
              Exit;
            end;

            //Player.AddTitle(84, 1, False);
            Player.SendClientMessage('Título Fundador SSS adicionado com sucesso!');
          end;

          1360: //Título Mestre do PVP
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

             var HasTitle: Boolean := False;
              var j: Integer;

            for j := 0 to 95 do
            begin
              if (Player.Base.PlayerCharacter.Titles[j].Index = 81) then
              begin
                HasTitle := True;
                Break;
              end;
            end;

            if HasTitle then
            begin
              Player.SendClientMessage('Você já possui este título.');
              Exit;
            end;

            Player.AddTitle(81, 1, False);
            Player.SendClientMessage('Título Mestre do PVP adicionado com sucesso!');
          end;

          1370: //Título Ganhador Batlle Royale
          begin
           var j: Integer;

           // Conecta ao banco de dados para verificar/remover títulos existentes
            SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
             AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
            AnsiString(MYSQL_DATABASE));

           // Itera sobre todos os jogadores online para remover o título e desconectar aqueles que o possuem
              for var CurrentPlayer in Servers[Player.Base.ChannelId].Players do
              begin
                if Assigned(@CurrentPlayer) and CurrentPlayer.Base.IsActive then
                begin
                  try
                    // Verifica se o jogador possui o título na memória local
                    var TitleFound: Boolean := False;

                    for j := 0 to 95 do
                    begin
                      if (CurrentPlayer.Base.PlayerCharacter.Titles[j].Index = 85) then
                      begin
                        TitleFound := True;
                        Break;
                      end;
                    end;

                    if TitleFound then
                    begin
                      // Remove o título da memória local
                      //CurrentPlayer.RemoveTitle(85);



                      // Desconecta o jogador
                      CurrentPlayer.Disconnect;//('Você foi desconectado porque o título exclusivo [Campeão do Battle Royale] foi transferido para outro jogador.');
                    end;
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro ao remover título ou desconectar o jogador: ' + E.Message, TlogType.Error);
                    end;
                  end;
                end;
              end;



            try
              if not(SQLComp.Query.Connection.Connected) then
              begin
                Logger.Write('Falha de conexão individual com mysql.[AddTitle]',
                  TlogType.Warnings);
                Logger.Write('PERSONAL MYSQL FAILED LOAD.[AddTitle]', TlogType.Error);
                Exit;
              end;

              // Remove todas as referências ao título no banco de dados
              SQLComp.SetQuery('DELETE FROM titles WHERE title_index = :title_id');
              SQLComp.AddParameter2('title_id', 85);
              SQLComp.Run(false);
                finally

              end;





              // Verifica se há espaço suficiente no inventário do jogador
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              // Verifica se o jogador já possui o título
              var HasTitle: Boolean := False;
            //  var j: Integer;

              for j := 0 to 95 do
              begin
                if (Player.Base.PlayerCharacter.Titles[j].Index = 85) then
                begin
                  HasTitle := True;
                  Break;
                end;
              end;

              if HasTitle then
              begin
                Player.SendClientMessage('Você já possui este título.');
                Exit;
              end;

              // Adiciona o título ao jogador
              Player.AddTitle(85, 1, true);
              Player.SendClientMessage('Título Ganhador Battle Royale adicionado com sucesso!');


            end;
          1361: //Título Matador de Boss
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

             var HasTitle: Boolean := False;
            var j: Integer;

            for j := 0 to 95 do
            begin
              if (Player.Base.PlayerCharacter.Titles[j].Index = 80) then
              begin
                HasTitle := True;
                Break;
              end;
            end;

            if HasTitle then
            begin
              Player.SendClientMessage('Você já possui este título.');
              Exit;
            end;

            Player.AddTitle(80, 1, False);
            Player.SendClientMessage('Título Matador de Boss adicionado com sucesso!');
          end;



           1383: //Título Elter Wars
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

            var HasTitle: Boolean := False;
            var j: Integer;

            // Verifica se o jogador já possui o título
            for j := 0 to 95 do
            begin
              if (Player.Base.PlayerCharacter.Titles[j].Index = 82) then
              begin
                HasTitle := True;
                Break;
              end;
            end;

            if HasTitle then
            begin
              Player.SendClientMessage('Você já possui este título.');
              Exit;
            end;

            // Adiciona o título e exibe a mensagem de sucesso
            Player.AddTitle(82, 1);
            Player.SendClientMessage('Título Elter Wars adicionado com sucesso!');
            Player.SendClientMessage('️ Favor relogar para ativar o título.');
          end;


            1393: //Título Elter Wars Tank
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

            var HasTitle: Boolean := False;
            var j: Integer;

            // Verifica se o jogador já possui o título
            for j := 0 to 95 do
            begin
              if (Player.Base.PlayerCharacter.Titles[j].Index = 84) then
              begin
                HasTitle := True;
                Break;
              end;
            end;

            if HasTitle then
            begin
              Player.SendClientMessage('Você já possui este título.');
              Exit;
            end;

            // Adiciona o título e exibe a mensagem de sucesso
            Player.AddTitle(84, 1);
            Player.SendClientMessage('Título Elter Wars Tank adicionado com sucesso!');
            Player.SendClientMessage(' Favor relogar para ativar o título.');
          end;



            1345: //Addexp
            begin

            // Definir o limite máximo de experiência permitido
            const MaxExpAllowed = 3375024933;

            // Obter a experiência atual diretamente do Player.Character.Base.Exp
            var CurrentExp := Player.Character.Base.Exp;

            // Verificar se já atingiu ou ultrapassou o limite
            if (CurrentExp >= MaxExpAllowed) then
            begin
              Player.SendClientMessage('Você já atingiu o limite máximo de experiência.');
              Exit;
            end;

            // Calcular a diferença necessária para atingir o limite
            var ExpToAdd := MaxExpAllowed - CurrentExp;

            // Adicionar somente a quantidade necessária
            Player.AddExp(ExpToAdd, Helper);
          end;


             1346: // AddExp Evolução do 70 ao 85
          begin

            // Definir o limite máximo de experiência permitido
            const MaxExpAllowed = 3375024933;

            // Obter a experiência atual diretamente do Player.Character.Base.Exp
            var CurrentExp := Player.Character.Base.Exp;

            // Verificar se já atingiu ou ultrapassou o limite
            if (CurrentExp >= MaxExpAllowed) then
            begin
              Player.SendClientMessage('Você já atingiu o limite máximo de experiência.');
              Exit;
            end;

            // Calcular a diferença necessária para atingir o limite
            var ExpToAdd := MaxExpAllowed - CurrentExp;

            // Adicionar somente a quantidade necessária
            Player.AddExp(ExpToAdd, Helper);
          end;


            1348: // AddExp Evolução do 85 ao 99
          begin

            // Definir o limite máximo de experiência permitido
            const MaxExpAllowed = 13780203528;

            // Obter a experiência atual diretamente do Player.Character.Base.Exp
            var CurrentExp := Player.Character.Base.Exp;

            // Verificar se já atingiu ou ultrapassou o limite
            if (CurrentExp >= MaxExpAllowed) then
            begin
              Player.SendClientMessage('Você já atingiu o limite máximo de experiência.');
              Exit;
            end;

            // Calcular a diferença necessária para atingir o limite
            var ExpToAdd := MaxExpAllowed - CurrentExp;

            // Adicionar somente a quantidade necessária
            Player.AddExp(ExpToAdd, Helper);
          end;

          1354: // AddExp  Onyx de 5%
           begin
            // Obter a experiência atual do jogador
            var CurrentExp: Int64 := Player.Character.Base.Exp;

            // Calcular exatamente 2% da experiência atual
            var ExpToAdd: Int64 := trunc(CurrentExp * 0.25);

            // Adicionar apenas a quantidade calculada
            Player.AddExp(ExpToAdd, Helper);
           end;



           1355: // AddExp Onyx de 2%
          begin
            // Se o jogador estiver no nível máximo, não ganha mais XP
            if (Player.Character.Base.Level >= LEVEL_CAP) then
              Exit;

            // Obter o nível atual do jogador
            Level := Player.Character.Base.Level;

            // Obter a experiência total necessária para alcançar o próximo nível
            var ExpRequired: Int64 := ExpList[Level] - ExpList[Level - 1];

            // Obter a experiência atual do jogador
            var CurrentExp: Int64 := Player.Character.Base.Exp;

            // Calcular a experiência que ainda falta para subir de nível
            var ExpRemaining: Int64 := ExpList[Level] - CurrentExp;

            // Calcular exatamente 2% da experiência restante para o próximo nível
            var ExpToAdd: Int64 := trunc(ExpRemaining * 0.025);

            // Garantir que ao menos 1 XP seja adicionado para evitar XP zero
            if ExpToAdd < 1 then
              ExpToAdd := 1;

            // Adicionar apenas a quantidade calculada
            Player.AddExp(ExpToAdd, Helper);
          end;





           1356: // AddExp Onyx de 1%
          begin
            // Se o jogador estiver no nível máximo, não ganha mais XP
            if (Player.Character.Base.Level >= LEVEL_CAP) then
              Exit;

            // Obter o nível atual do jogador
            Level := Player.Character.Base.Level;

            // Obter a experiência total necessária para alcançar o próximo nível
            var ExpRequired: Int64 := ExpList[Level] - ExpList[Level - 1];

            // Obter a experiência atual do jogador
            var CurrentExp: Int64 := Player.Character.Base.Exp;

            // Calcular a experiência que ainda falta para subir de nível
            var ExpRemaining: Int64 := ExpList[Level] - CurrentExp;

            // Calcular exatamente 2% da experiência restante para o próximo nível
            var ExpToAdd: Int64 := trunc(ExpRemaining * 0.015) ;

            // Garantir que ao menos 1 XP seja adicionado para evitar XP zero
            if ExpToAdd < 1 then
              ExpToAdd := 1;

            // Adicionar apenas a quantidade calculada
            Player.AddExp(ExpToAdd, Helper);
          end;


          1357: //Add Soma LH
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player, 4850, 40);
            end;

            1358: //Add doce do rejuvenecimento
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player, 4428, 40);
            end;



            1347: //Add pena de gelo
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player, 8480, 500);
            end;

            1380: //Add caveira
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player, 11285, 100);
            end;


            1399: //moeda elter
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player, 5987, 500);
            end;


            1350: //flan
            begin
              if (Self.GetInvAvailableSlots(Player) < 2) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player, 6097, 500);
            end;

            1398: //moeda gratidão wars
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player, 5251, 500);
            end;

            1397: //moeda gratidão wars
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player, 5251, 250);
            end;

            1396: //moeda elter
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player, 5987, 250);
            end;

             1395: //moeda elter
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player, 5987, 100);
            end;

            1394: //moeda Gratidão
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player, 5251, 100);
            end;

            1381: //caixa Elter private 1 Dano  (55,00)
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 9548, 1); //100 cavveira
              Self.PutItem(Player, 8865, 2); // 1000 penas de gelo
              Self.PutItem(Player, 9839, 100); // 100 moedas de Eventos Wars
             // Self.PutItem(Player, 17002, 1);// Poção Wars
              self.PutItem(Player, 8864, 2); // 150k de honrra
              //self.PutItem(Player, 11520, 1); //titulo Elter Wars
              self.PutItem(Player, 5251 ,20); // 20 moedas gratidão wars
              self.PutItem(Player, 20417 ,20); // Pedra Demoniaca
              self.PutItem(Player, 20402 ,20); // Pedra guardia
              self.PutItem(Player, 8250,1); // Ax Poderoso
              //self.PutItem(Player, 11714,1); // Titulo Elter Wars




              Player.AddCash(5600000);        // 160 K de cash
              Player.SendCashInventory;

            end;

            1382: //caixa Elter private inicio dano  120,00)
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 9548, 1); //100 cavveira
              Self.PutItem(Player, 8865, 2); // 1000 penas de gelo
              Self.PutItem(Player, 9839, 100); // 100 moedas de Eventos Wars
             // Self.PutItem(Player, 17002, 1);// Poção Wars
              self.PutItem(Player, 8864, 2); // 150k de honrra
             // self.PutItem(Player, 11520,1); // Titulo Elter Wars
              self.PutItem(Player, 14148,1); // Set Wars
              self.PutItem(Player, 14151,1); // Set Celestial
              self.PutItem(Player, 19050,1); // Evolução Acelerada
              self.PutItem(Player, 5251,20); // 20 moedas gratidão wars
              self.PutItem(Player, 8250,1); // Ax Poderoso
             // self.PutItem(Player, 11714,1); // Titulo Elter Wars


              Player.AddCash(5600000);        // 560K de cash
              Player.SendCashInventory;

            end;

             1400: //bau premiação 1 lugar pvp ranking
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;


              Self.PutItem(Player, 9839, 500); // 100 moedas de Eventos Wars
              Self.PutItem(Player, 5987, 500);// Poção Wars
              self.PutItem(Player, 8864, 2); // 150k de honrra

            end;

            1401: //bau premiação 2 lugar pvp ranking
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;


              Self.PutItem(Player, 9839, 250); // 100 moedas de Eventos Wars
              Self.PutItem(Player, 5987, 250);// Poção Wars
              self.PutItem(Player, 8864, 1); // 150k de honrra

            end;




            1402: //bau premiação 3 lugar pvp ranking
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;


              Self.PutItem(Player, 9839, 100); // 100 moedas de Eventos Wars
              Self.PutItem(Player, 5987, 100);// Poção Wars
              self.PutItem(Player, 10295, 1); // 150k de honrra

            end;

             1403: //Baú poção polimorfo e
            begin
              if (Self.GetInvAvailableSlots(Player) < 10) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;


              Self.PutItem(Player, 4695, 10); // polimorfo pran
              Self.PutItem(Player, 4696, 10); // polimorfo golen de aço
              self.PutItem(Player, 4697, 10); // polimorfo ave
              Self.PutItem(Player, 4698, 10); // polimorfoo feiticeiro
              Self.PutItem(Player, 4699, 10); // polimorfo  cobra
              self.PutItem(Player, 4700, 10);  // polimirfo slime
              Self.PutItem(Player, 15535, 10); // poção do gigante
              Self.PutItem(Player, 15536, 10); // poção do nanismo
              self.PutItem(Player, 15537, 10); // poção do cabeçudo
              Self.PutItem(Player, 15538, 10); // poção voltar ao normal

            end;

            1200: //bAU DE CARNAVAL TITULO ELTER
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 11520, 1); //titilo elter dano
              Self.PutItem(Player, 11714, 1); //titilo elter dano


            end;

            1201: //BAU DE CARNAVAL TITULO ELTER
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 14191, 1); //renovador 7 dias

            end;

             1202: //BAU DE CARNAVAL moedas eventos
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 9839, 500); //500 moedas ded evento
              Self.PutItem(Player, 4580, 20); //20 athlon

            end;

              1203: //bau Montaria Wars
            begin
              if (Self.GetInvAvailableSlots(Player) < 1) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Self.PutItem(Player, 375,1); // 100 moedas de Eventos Wars


            end;

            1204: //bau Montaria TP
            begin
              if (Self.GetInvAvailableSlots(Player) < 1) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Self.PutItem(Player, 377,1); // 100 moedas de Eventos Wars


            end;

             1205: //bau Montaria ATT
            begin
              if (Self.GetInvAvailableSlots(Player) < 1) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Self.PutItem(Player, 409,1); // 100 moedas de Eventos Wars


            end;

             1206: //bau Montaria dual
            begin
              if (Self.GetInvAvailableSlots(Player) < 1) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Self.PutItem(Player, 411,1); // 100 moedas de Eventos Wars


            end;

             1207: //bau Montaria fc
            begin
              if (Self.GetInvAvailableSlots(Player) < 1) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Self.PutItem(Player, 900,1); // 100 moedas de Eventos Wars


            end;

             1208: //bau Montaria dua
            begin
              if (Self.GetInvAvailableSlots(Player) < 1) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Self.PutItem(Player, 902,1); // 100 moedas de Eventos Wars


            end;


             1384: //caixa Elter private inicio Tank (120,00)
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 9548, 1); //100 cavveira
              Self.PutItem(Player, 8865, 2); // 1000 penas de gelo
              Self.PutItem(Player, 9839, 100); // 100 moedas de Eventos Wars
             // Self.PutItem(Player, 17002, 1);// Poção Wars
              self.PutItem(Player, 8864, 2); // 150k de honrra
             // self.PutItem(Player, 11520,1); // Titulo Elter Wars
              self.PutItem(Player, 14149,1); // Set Wars
              self.PutItem(Player, 14150,1); // Set Celestial
              self.PutItem(Player, 19050,1); // Evolução Acelerada
              self.PutItem(Player, 5251,20); // 20 moedas gratidão wars
              self.PutItem(Player, 8250,1); // Ax Poderoso
             // self.PutItem(Player, 11714,1); // Ax Poderoso


              Player.AddCash(5600000);        // 560K de cash
              Player.SendCashInventory;

            end;

            1385: //Add Moeda de evento
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
               self.PutItem(player,9839, 300);
            end;

             1405: //buff do Marechal
            begin
              if (Self.GetInvAvailableSlots(Player) < 1) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Self.PutItem(Player, 18586,1); // buss do marechal


            end;





{$ENDREGION}
{$REGION 'caixa dos carrascos fundadores'}

            1138: //caixa que vem raro 50 evento full +11
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 2579, 178);
                    Self.PutEquipament(Player, 2834, 178);
                    Self.PutEquipament(Player, 2864, 178);
                    Self.PutEquipament(Player, 2894, 178);
                    Self.PutEquipament(Player, 2924, 178);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 2544, 178);
                    Self.PutEquipament(Player, 2954, 178);
                    Self.PutEquipament(Player, 2984, 178);
                    Self.PutEquipament(Player, 3014, 178);
                    Self.PutEquipament(Player, 3044, 178);
                    Self.PutEquipament(Player, 2804, 178);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 2719, 178);
                    Self.PutEquipament(Player, 3074, 178);
                    Self.PutEquipament(Player, 3104, 178);
                    Self.PutEquipament(Player, 3134, 178);
                    Self.PutEquipament(Player, 3164, 178);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 2684, 178);
                    Self.PutEquipament(Player, 3194, 178);
                    Self.PutEquipament(Player, 3224, 178);
                    Self.PutEquipament(Player, 3254, 178);
                    Self.PutEquipament(Player, 3284, 178);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 2789, 178);
                    Self.PutEquipament(Player, 3314, 178);
                    Self.PutEquipament(Player, 3344, 178);
                    Self.PutEquipament(Player, 3374, 178);
                    Self.PutEquipament(Player, 3404, 178);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 2754, 178);
                    Self.PutEquipament(Player, 3434, 178);
                    Self.PutEquipament(Player, 3464, 178);
                    Self.PutEquipament(Player, 3494, 178);
                    Self.PutEquipament(Player, 3524, 178);
                  end;
              end;
            end;

             1188: //caixa Set Alugado +15
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 2574, 250);
                    Self.PutEquipament(Player, 2829, 250);
                    Self.PutEquipament(Player, 2859, 250);
                    Self.PutEquipament(Player, 2889, 250);
                    Self.PutEquipament(Player, 2919, 250);
                    //Self.PutEquipament(Player, 14190, 1);

                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 2539, 250);
                    Self.PutEquipament(Player, 2799, 250);
                    Self.PutEquipament(Player, 2949, 250);
                    Self.PutEquipament(Player, 2979, 250);
                    Self.PutEquipament(Player, 3009, 250);
                    Self.PutEquipament(Player, 3039, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 2714, 250);
                    Self.PutEquipament(Player, 3069, 250);
                    Self.PutEquipament(Player, 3099, 250);
                    Self.PutEquipament(Player, 3129, 250);
                    Self.PutEquipament(Player, 3159, 250);
                  //  Self.PutEquipament(Player, 14190, 1);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 2679, 250);
                    Self.PutEquipament(Player, 3189, 250);
                    Self.PutEquipament(Player, 3219, 250);
                    Self.PutEquipament(Player, 3249, 250);
                    Self.PutEquipament(Player, 3279, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 2784, 250);
                    Self.PutEquipament(Player, 3309, 250);
                    Self.PutEquipament(Player, 3339, 250);
                    Self.PutEquipament(Player, 3369, 250);
                    Self.PutEquipament(Player, 3399, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 2749, 250);
                    Self.PutEquipament(Player, 3429, 250);
                    Self.PutEquipament(Player, 3459, 250);
                    Self.PutEquipament(Player, 3489, 250);
                    Self.PutEquipament(Player, 3519, 250);
                  //  Self.PutEquipament(Player, 14190, 1);
                  end;
              end;
            end;


             1189: //caixa Set Alugado Free +15
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 6738, 250);
                    Self.PutEquipament(Player, 7005, 250);
                    Self.PutEquipament(Player, 7035, 250);
                    Self.PutEquipament(Player, 7065, 250);
                    Self.PutEquipament(Player, 7095, 250);
                    Self.PutEquipament(Player, 14191, 1);

                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6703, 250);
                    Self.PutEquipament(Player, 6975, 250);
                    Self.PutEquipament(Player, 7124, 250);
                    Self.PutEquipament(Player, 7154, 250);
                    Self.PutEquipament(Player, 7184, 250);
                    Self.PutEquipament(Player, 7214, 250);
                    Self.PutEquipament(Player, 14191, 1);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 6878, 250);
                    Self.PutEquipament(Player, 7245, 250);
                    Self.PutEquipament(Player, 7275, 250);
                    Self.PutEquipament(Player, 7305, 250);
                    Self.PutEquipament(Player, 7335, 250);
                    Self.PutEquipament(Player, 14191, 1);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 6843, 250);
                    Self.PutEquipament(Player, 7365, 250);
                    Self.PutEquipament(Player, 7395, 250);
                    Self.PutEquipament(Player, 7425, 250);
                    Self.PutEquipament(Player, 7455, 250);
                    Self.PutEquipament(Player, 14191, 1);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 6948, 250);
                    Self.PutEquipament(Player, 7485, 250);
                    Self.PutEquipament(Player, 7515, 250);
                    Self.PutEquipament(Player, 7545, 250);
                    Self.PutEquipament(Player, 7575, 250);
                    Self.PutEquipament(Player, 14191, 1);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 6913, 250);
                    Self.PutEquipament(Player, 7605, 250);
                    Self.PutEquipament(Player, 7635, 250);
                    Self.PutEquipament(Player, 7665, 250);
                    Self.PutEquipament(Player, 7695, 250);
                    Self.PutEquipament(Player, 14191, 1);
                  end;
              end;
            end;


             1190: //caixa Set conquistador poderoso +15  lv2
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 6736, 250);
                    Self.PutEquipament(Player, 7003, 250);
                    Self.PutEquipament(Player, 7033, 250);
                    Self.PutEquipament(Player, 7063, 250);
                    Self.PutEquipament(Player, 7093, 250);
                   // Self.PutEquipament(Player, 14190, 1);

                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6701, 250);
                    Self.PutEquipament(Player, 6973, 250);
                    Self.PutEquipament(Player, 7122, 250);
                    Self.PutEquipament(Player, 7152, 250);
                    Self.PutEquipament(Player, 7182, 250);
                    Self.PutEquipament(Player, 7212, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 6876, 250);
                    Self.PutEquipament(Player, 7243, 250);
                    Self.PutEquipament(Player, 7273, 250);
                    Self.PutEquipament(Player, 7303, 250);
                    Self.PutEquipament(Player, 7333, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 6841, 250);
                    Self.PutEquipament(Player, 7363, 250);
                    Self.PutEquipament(Player, 7393, 250);
                    Self.PutEquipament(Player, 7423, 250);
                    Self.PutEquipament(Player, 7453, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 6946, 250);
                    Self.PutEquipament(Player, 7483, 250);
                    Self.PutEquipament(Player, 7513, 250);
                    Self.PutEquipament(Player, 7543, 250);
                    Self.PutEquipament(Player, 7573, 250);
                    //Self.PutEquipament(Player, 14190, 1);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 6911, 250);
                    Self.PutEquipament(Player, 7603, 250);
                    Self.PutEquipament(Player, 7633, 250);
                    Self.PutEquipament(Player, 7663, 250);
                    Self.PutEquipament(Player, 7693, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;
              end;
            end;


            1191: //caixa Set conquistador Perverso +15 lv2
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 6737, 250);
                    Self.PutEquipament(Player, 7004, 250);
                    Self.PutEquipament(Player, 7034, 250);
                    Self.PutEquipament(Player, 7064, 250);
                    Self.PutEquipament(Player, 7094, 250);
                   // Self.PutEquipament(Player, 14190, 1);

                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6702, 250);
                    Self.PutEquipament(Player, 6974, 250);
                    Self.PutEquipament(Player, 7123, 250);
                    Self.PutEquipament(Player, 7153, 250);
                    Self.PutEquipament(Player, 7183, 250);
                    Self.PutEquipament(Player, 7213, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 6877, 250);
                    Self.PutEquipament(Player, 7244, 250);
                    Self.PutEquipament(Player, 7274, 250);
                    Self.PutEquipament(Player, 7304, 250);
                    Self.PutEquipament(Player, 7334, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 6842, 250);
                    Self.PutEquipament(Player, 7364, 250);
                    Self.PutEquipament(Player, 7394, 250);
                    Self.PutEquipament(Player, 7424, 250);
                    Self.PutEquipament(Player, 7454, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 6947, 250);
                    Self.PutEquipament(Player, 7484, 250);
                    Self.PutEquipament(Player, 7514, 250);
                    Self.PutEquipament(Player, 7544, 250);
                    Self.PutEquipament(Player, 7574, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 6912, 250);
                    Self.PutEquipament(Player, 7604, 250);
                    Self.PutEquipament(Player, 7634, 250);
                    Self.PutEquipament(Player, 7664, 250);
                    Self.PutEquipament(Player, 7694, 250);
                   // Self.PutEquipament(Player, 14190, 1);
                  end;
              end;
            end;



             1193: //caixa Set conquistador poderoso   lv2
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 6763, 0);
                    Self.PutEquipament(Player, 7003, 0);
                    Self.PutEquipament(Player, 7033, 0);
                    Self.PutEquipament(Player, 7063, 0);
                    Self.PutEquipament(Player, 7093, 0);


                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6701, 0);
                    Self.PutEquipament(Player, 6973, 0);
                    Self.PutEquipament(Player, 7122, 0);
                    Self.PutEquipament(Player, 7152, 0);
                    Self.PutEquipament(Player, 7182, 0);
                    Self.PutEquipament(Player, 7212, 0);

                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 6876, 0);
                    Self.PutEquipament(Player, 7243, 0);
                    Self.PutEquipament(Player, 7273, 0);
                    Self.PutEquipament(Player, 7303, 0);
                    Self.PutEquipament(Player, 7333, 0);

                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 6841, 0);
                    Self.PutEquipament(Player, 7363, 0);
                    Self.PutEquipament(Player, 7393, 0);
                    Self.PutEquipament(Player, 7423, 0);
                    Self.PutEquipament(Player, 7453, 0);

                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 6946, 0);
                    Self.PutEquipament(Player, 7483, 0);
                    Self.PutEquipament(Player, 7513, 0);
                    Self.PutEquipament(Player, 7543, 0);
                    Self.PutEquipament(Player, 7573, 0);

                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 6911, 0);
                    Self.PutEquipament(Player, 7603, 0);
                    Self.PutEquipament(Player, 7633, 0);
                    Self.PutEquipament(Player, 7663, 0);
                    Self.PutEquipament(Player, 7693, 0);

                  end;
              end;
            end;


            1192: //caixa Set conquistador Perverso lv2
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 6737, 0);
                    Self.PutEquipament(Player, 7004, 0);
                    Self.PutEquipament(Player, 7034, 0);
                    Self.PutEquipament(Player, 7064, 0);
                    Self.PutEquipament(Player, 7094, 0);


                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6702, 0);
                    Self.PutEquipament(Player, 6974, 0);
                    Self.PutEquipament(Player, 7123, 0);
                    Self.PutEquipament(Player, 7153, 0);
                    Self.PutEquipament(Player, 7183, 0);
                    Self.PutEquipament(Player, 7213, 0);

                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 6877, 0);
                    Self.PutEquipament(Player, 7244, 0);
                    Self.PutEquipament(Player, 7274, 0);
                    Self.PutEquipament(Player, 7304, 0);
                    Self.PutEquipament(Player, 7334, 0);

                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 6842, 0);
                    Self.PutEquipament(Player, 7364, 0);
                    Self.PutEquipament(Player, 7394, 0);
                    Self.PutEquipament(Player, 7424, 0);
                    Self.PutEquipament(Player, 7454, 0);

                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 6947, 0);
                    Self.PutEquipament(Player, 7484, 0);
                    Self.PutEquipament(Player, 7514, 0);
                    Self.PutEquipament(Player, 7544, 0);
                    Self.PutEquipament(Player, 7574, 0);

                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 6912, 0);
                    Self.PutEquipament(Player, 7604, 0);
                    Self.PutEquipament(Player, 7634, 0);
                    Self.PutEquipament(Player, 7664, 0);
                    Self.PutEquipament(Player, 7694
                    , 0);

                  end;
              end;
            end;

             1179: //Set Seguidor do Sol +12
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0: // WR
                  begin
                    Self.PutEquipament(Player, 1066, 188);
                    Self.PutEquipament(Player, 1680, 188);
                    Self.PutEquipament(Player, 1711, 188);
                    Self.PutEquipament(Player, 1738, 188);
                    Self.PutEquipament(Player, 1769, 188);
                  end;

                1: // TP (Templária)
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  // TP tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 1032, 188);
                    Self.PutEquipament(Player, 1800, 188);
                    Self.PutEquipament(Player, 1831, 188);
                    Self.PutEquipament(Player, 1858, 188);
                    Self.PutEquipament(Player, 1889, 188);
                    Self.PutEquipament(Player, 1307, 188);
                  end;

                2: // ATT (Atirador)
                  begin
                    Self.PutEquipament(Player, 1207, 188);
                    Self.PutEquipament(Player, 1920, 188);
                    Self.PutEquipament(Player, 1951, 188);
                    Self.PutEquipament(Player, 1978, 188);
                    Self.PutEquipament(Player, 2009, 188);
                  end;

                3: // Dual
                  begin
                    Self.PutEquipament(Player, 1172, 188);
                    Self.PutEquipament(Player, 2040, 188);
                    Self.PutEquipament(Player, 2071, 188);
                    Self.PutEquipament(Player, 2098, 188);
                    Self.PutEquipament(Player, 2129, 188);
                  end;

                4: // FC (Feiticeiro)
                  begin
                    Self.PutEquipament(Player, 1277, 188);
                    Self.PutEquipament(Player, 2160, 188);
                    Self.PutEquipament(Player, 2191, 188);
                    Self.PutEquipament(Player, 2218, 188);
                    Self.PutEquipament(Player, 2249, 188);
                  end;

                5: // Santa
                  begin
                    Self.PutEquipament(Player, 1242, 188);
                    Self.PutEquipament(Player, 2280, 188);
                    Self.PutEquipament(Player, 2311, 188);
                    Self.PutEquipament(Player, 2338, 188);
                    Self.PutEquipament(Player, 2369, 188);
                  end;
              end;
            end;


            // Set Protetor de Mani +12

             1180: // Protetor de Mani +12
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0: // WR (Warrior)
                  begin
                    Self.PutEquipament(Player, 2841, 188);
                    Self.PutEquipament(Player, 2871, 188);
                    Self.PutEquipament(Player, 2901, 188);
                    Self.PutEquipament(Player, 2931, 188);
                    Self.PutEquipament(Player, 2557, 188);
                  end;

                1: // TP (Templária)
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  // TP tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 2961, 188);
                    Self.PutEquipament(Player, 2991, 188);
                    Self.PutEquipament(Player, 3021, 188);
                    Self.PutEquipament(Player, 3051, 188);
                    Self.PutEquipament(Player, 2522, 188);
                    Self.PutEquipament(Player, 2811, 188);
                  end;

                2: // ATT (Atirador)
                  begin
                    Self.PutEquipament(Player, 3081, 188);
                    Self.PutEquipament(Player, 3111, 188);
                    Self.PutEquipament(Player, 3141, 188);
                    Self.PutEquipament(Player, 3171, 188);
                    Self.PutEquipament(Player, 2697, 188);
                  end;

                3: // Dual
                  begin
                    Self.PutEquipament(Player, 3201, 188);
                    Self.PutEquipament(Player, 3231, 188);
                    Self.PutEquipament(Player, 3261, 188);
                    Self.PutEquipament(Player, 3291, 188);
                    Self.PutEquipament(Player, 2662, 188);
                  end;

                4: // FC (Feiticeiro)
                  begin
                    Self.PutEquipament(Player, 3321, 188);
                    Self.PutEquipament(Player, 3351, 188);
                    Self.PutEquipament(Player, 3381, 188);
                    Self.PutEquipament(Player, 3411, 188);
                    Self.PutEquipament(Player, 2767, 188);
                  end;

                5: // Santa
                  begin
                    Self.PutEquipament(Player, 3441, 188);
                    Self.PutEquipament(Player, 3471, 188);
                    Self.PutEquipament(Player, 3501, 188);
                    Self.PutEquipament(Player, 3531, 188);
                    Self.PutEquipament(Player, 2732, 188);
                  end;
              end;
            end;


              1181: // Set Seguidor do Sol +15
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

            case Player.Base.GetMobClass of
              0: // WR (Warrior)
                begin
                  Self.PutEquipament(Player, 1066, 250);
                  Self.PutEquipament(Player, 1680, 250);
                  Self.PutEquipament(Player, 1711, 250);
                  Self.PutEquipament(Player, 1738, 250);
                  Self.PutEquipament(Player, 1769, 250);
                end;

              1: // TP (Templária)
                begin
                  if (Self.GetInvAvailableSlots(Player) < 6) then
                  begin  // TP tem o escudo a mais
                    Player.SendClientMessage('Inventário cheio.');
                    Exit;
                  end;

                  Self.PutEquipament(Player, 1032, 250);
                  Self.PutEquipament(Player, 1800, 250);
                  Self.PutEquipament(Player, 1831, 250);
                  Self.PutEquipament(Player, 1858, 250);
                  Self.PutEquipament(Player, 1889, 250);
                  Self.PutEquipament(Player, 1307, 250);
                end;

              2: // ATT (Atirador)
                begin
                  Self.PutEquipament(Player, 1207, 250);
                  Self.PutEquipament(Player, 1920, 250);
                  Self.PutEquipament(Player, 1951, 250);
                  Self.PutEquipament(Player, 1978, 250);
                  Self.PutEquipament(Player, 2009, 250);
                end;

              3: // Dual
                begin
                  Self.PutEquipament(Player, 1172, 250);
                  Self.PutEquipament(Player, 2040, 250);
                  Self.PutEquipament(Player, 2071, 250);
                  Self.PutEquipament(Player, 2098, 250);
                  Self.PutEquipament(Player, 2129, 250);
                end;

              4: // FC (Feiticeiro)
                begin
                  Self.PutEquipament(Player, 1277, 250);
                  Self.PutEquipament(Player, 2160, 250);
                  Self.PutEquipament(Player, 2191, 250);
                  Self.PutEquipament(Player, 2218, 250);
                  Self.PutEquipament(Player, 2249, 250);
                end;

              5: // Santa
                begin
                  Self.PutEquipament(Player, 1242, 250);
                  Self.PutEquipament(Player, 2280, 250);
                  Self.PutEquipament(Player, 2311, 250);
                  Self.PutEquipament(Player, 2338, 250);
                  Self.PutEquipament(Player, 2369, 250);
                end;
            end;
          end;


            // Set Protetor de Mani +15

             1182: // Set Protetor de Mani +15
          begin
            if (Self.GetInvAvailableSlots(Player) < 5) then
            begin
              Player.SendClientMessage('Inventário cheio.');
              Exit;
            end;

            case Player.Base.GetMobClass of
              0: // WR (Warrior)
                begin
                  Self.PutEquipament(Player, 2841, 250);
                  Self.PutEquipament(Player, 2871, 250);
                  Self.PutEquipament(Player, 2901, 250);
                  Self.PutEquipament(Player, 2931, 250);
                  Self.PutEquipament(Player, 2557, 250);
                end;

              1: // TP (Templária)
                begin
                  if (Self.GetInvAvailableSlots(Player) < 6) then
                  begin  // TP tem o escudo a mais
                    Player.SendClientMessage('Inventário cheio.');
                    Exit;
                  end;

                  Self.PutEquipament(Player, 2961, 250);
                  Self.PutEquipament(Player, 2991, 250);
                  Self.PutEquipament(Player, 3021, 250);
                  Self.PutEquipament(Player, 3051, 250);
                  Self.PutEquipament(Player, 2522, 250);
                  Self.PutEquipament(Player, 2811, 250);
                end;

              2: // ATT (Atirador)
                begin
                  Self.PutEquipament(Player, 3081, 250);
                  Self.PutEquipament(Player, 3111, 250);
                  Self.PutEquipament(Player, 3141, 250);
                  Self.PutEquipament(Player, 3171, 250);
                  Self.PutEquipament(Player, 2697, 250);
                end;

              3: // Dual
                begin
                  Self.PutEquipament(Player, 3201, 250);
                  Self.PutEquipament(Player, 3231, 250);
                  Self.PutEquipament(Player, 3261, 250);
                  Self.PutEquipament(Player, 3291, 250);
                  Self.PutEquipament(Player, 2662, 250);
                end;

              4: // FC (Feiticeiro)
                begin
                  Self.PutEquipament(Player, 3321, 250);
                  Self.PutEquipament(Player, 3351, 250);
                  Self.PutEquipament(Player, 3381, 250);
                  Self.PutEquipament(Player, 3411, 250);
                  Self.PutEquipament(Player, 2767, 250);
                end;

              5: // Santa
                begin
                  Self.PutEquipament(Player, 3441, 250);
                  Self.PutEquipament(Player, 3471, 250);
                  Self.PutEquipament(Player, 3501, 250);
                  Self.PutEquipament(Player, 3531, 250);
                  Self.PutEquipament(Player, 2732, 250);
                end;
            end;
          end;




            1139: //caixa que vem Wars  +12 dano
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 12072, 188);
                    Self.PutEquipament(Player, 12378, 188);
                    Self.PutEquipament(Player, 12408, 188);
                    Self.PutEquipament(Player, 12438, 188);
                    Self.PutEquipament(Player, 12468, 188);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12107, 188);
                    Self.PutEquipament(Player, 12348, 188);
                    Self.PutEquipament(Player, 12498, 188);
                    Self.PutEquipament(Player, 12528, 188);
                    Self.PutEquipament(Player, 12558, 188);
                    Self.PutEquipament(Player, 12588, 188);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 12212, 188);
                    Self.PutEquipament(Player, 12618, 188);
                    Self.PutEquipament(Player, 12648, 188);
                    Self.PutEquipament(Player, 12678, 188);
                    Self.PutEquipament(Player, 12708, 188);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 12247, 188);
                    Self.PutEquipament(Player, 12738, 188);
                    Self.PutEquipament(Player, 12768, 188);
                    Self.PutEquipament(Player, 12798, 188);
                    Self.PutEquipament(Player, 12828, 188);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 12282, 188);
                    Self.PutEquipament(Player, 12858, 188);
                    Self.PutEquipament(Player, 12888, 188);
                    Self.PutEquipament(Player, 12918, 188);
                    Self.PutEquipament(Player, 12948, 188);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 12317, 188);
                    Self.PutEquipament(Player, 12978, 188);
                    Self.PutEquipament(Player, 13008, 188);
                    Self.PutEquipament(Player, 13038, 188);
                    Self.PutEquipament(Player, 13068, 188);
                  end;
              end;
            end;

            1140: //caixa Celestial Wars +11
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 12069, 198);
                    Self.PutEquipament(Player, 12375, 198);
                    Self.PutEquipament(Player, 12405, 198);
                    Self.PutEquipament(Player, 12435, 198);
                    Self.PutEquipament(Player, 12465, 198);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12103, 198);
                    Self.PutEquipament(Player, 12344, 198);
                    Self.PutEquipament(Player, 12494, 198);
                    Self.PutEquipament(Player, 12524, 198);
                    Self.PutEquipament(Player, 12554, 198);
                    Self.PutEquipament(Player, 12584, 198);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 12206, 198);
                    Self.PutEquipament(Player, 12612, 198);
                    Self.PutEquipament(Player, 12642, 198);
                    Self.PutEquipament(Player, 12672, 198);
                    Self.PutEquipament(Player, 12702, 198);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 3188, 198);
                    Self.PutEquipament(Player, 3218, 198);
                    Self.PutEquipament(Player, 3248, 198);
                    Self.PutEquipament(Player, 3278, 198);
                    Self.PutEquipament(Player, 2678, 198);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 12276, 198);
                    Self.PutEquipament(Player, 12852, 198);
                    Self.PutEquipament(Player, 12882, 198);
                    Self.PutEquipament(Player, 12912, 198);
                    Self.PutEquipament(Player, 12942, 198);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 12311, 198);
                    Self.PutEquipament(Player, 12972, 198);
                    Self.PutEquipament(Player, 13002, 198);
                    Self.PutEquipament(Player, 13032, 198);
                    Self.PutEquipament(Player, 13062, 198);
                  end;
              end;
            end;

            1141: //caixa que vem raro 85 leopold
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 12056, 188);
                    Self.PutEquipament(Player, 12370, 188);
                    Self.PutEquipament(Player, 12400, 188);
                    Self.PutEquipament(Player, 12430, 188);
                    Self.PutEquipament(Player, 12460, 188);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12091, 188);
                    Self.PutEquipament(Player, 12340, 188);
                    Self.PutEquipament(Player, 12490, 188);
                    Self.PutEquipament(Player, 12520, 188);
                    Self.PutEquipament(Player, 12550, 188);
                    Self.PutEquipament(Player, 12580, 188);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 12196, 188);
                    Self.PutEquipament(Player, 12610, 188);
                    Self.PutEquipament(Player, 12640, 188);
                    Self.PutEquipament(Player, 12670, 188);
                    Self.PutEquipament(Player, 12700, 188);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 12231, 188);
                    Self.PutEquipament(Player, 12730, 188);
                    Self.PutEquipament(Player, 12760, 188);
                    Self.PutEquipament(Player, 12790, 188);
                    Self.PutEquipament(Player, 12820, 188);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 12266, 188);
                    Self.PutEquipament(Player, 12850, 188);
                    Self.PutEquipament(Player, 12880, 188);
                    Self.PutEquipament(Player, 12910, 188);
                    Self.PutEquipament(Player, 12940, 188);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 12301, 188);
                    Self.PutEquipament(Player, 12970, 188);
                    Self.PutEquipament(Player, 13000, 188);
                    Self.PutEquipament(Player, 13030, 188);
                    Self.PutEquipament(Player, 13060, 188);
                  end;
              end;
            end;

            1142: //caixa que vem conjunto primeiro ano comemorativo
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutEquipament(Player, 13216, 1);
              Self.PutEquipament(Player, 13217, 1);
              Self.PutEquipament(Player, 13218, 1);
              Self.PutEquipament(Player, 13219, 1);
            end;

            1143: //caixa que vem app azul academia
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 12074, 1);
                    Self.PutEquipament(Player, 12380, 1);
                    Self.PutEquipament(Player, 12410, 1);
                    Self.PutEquipament(Player, 12440, 1);
                    Self.PutEquipament(Player, 12470, 1);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12109, 1);
                    Self.PutEquipament(Player, 12350, 1);
                    Self.PutEquipament(Player, 12500, 1);
                    Self.PutEquipament(Player, 12530, 1);
                    Self.PutEquipament(Player, 12560, 1);
                    Self.PutEquipament(Player, 12590, 1);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 12214, 1);
                    Self.PutEquipament(Player, 12620, 1);
                    Self.PutEquipament(Player, 12650, 1);
                    Self.PutEquipament(Player, 12680, 1);
                    Self.PutEquipament(Player, 12710, 1);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 12249, 1);
                    Self.PutEquipament(Player, 12740, 1);
                    Self.PutEquipament(Player, 12770, 1);
                    Self.PutEquipament(Player, 12800, 1);
                    Self.PutEquipament(Player, 12830, 1);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 12284, 1);
                    Self.PutEquipament(Player, 12860, 1);
                    Self.PutEquipament(Player, 12890, 1);
                    Self.PutEquipament(Player, 12920, 1);
                    Self.PutEquipament(Player, 12950, 1);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 12319, 1);
                    Self.PutEquipament(Player, 12980, 1);
                    Self.PutEquipament(Player, 13010, 1);
                    Self.PutEquipament(Player, 13040, 1);
                    Self.PutEquipament(Player, 13070, 1);
                  end;
              end;
            end;

            1144: //caixa que vem app vermelha academia
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 12075, 1);
                    Self.PutEquipament(Player, 12381, 1);
                    Self.PutEquipament(Player, 12411, 1);
                    Self.PutEquipament(Player, 12441, 1);
                    Self.PutEquipament(Player, 12471, 1);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12110, 1);
                    Self.PutEquipament(Player, 12351, 1);
                    Self.PutEquipament(Player, 12501, 1);
                    Self.PutEquipament(Player, 12531, 1);
                    Self.PutEquipament(Player, 12561, 1);
                    Self.PutEquipament(Player, 12591, 1);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 12215, 1);
                    Self.PutEquipament(Player, 12621, 1);
                    Self.PutEquipament(Player, 12651, 1);
                    Self.PutEquipament(Player, 12681, 1);
                    Self.PutEquipament(Player, 12711, 1);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 12250, 1);
                    Self.PutEquipament(Player, 12741, 1);
                    Self.PutEquipament(Player, 12771, 1);
                    Self.PutEquipament(Player, 12801, 1);
                    Self.PutEquipament(Player, 12831, 1);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 12285, 1);
                    Self.PutEquipament(Player, 12861, 1);
                    Self.PutEquipament(Player, 12891, 1);
                    Self.PutEquipament(Player, 12921, 1);
                    Self.PutEquipament(Player, 12951, 1);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 12320, 1);
                    Self.PutEquipament(Player, 12981, 1);
                    Self.PutEquipament(Player, 13011, 1);
                    Self.PutEquipament(Player, 13041, 1);
                    Self.PutEquipament(Player, 13071, 1);
                  end;
              end;
            end;

            1145: //caixa que vem app conquistador
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 1687, 1);
                    Self.PutEquipament(Player, 1717, 1);
                    Self.PutEquipament(Player, 1747, 1);
                    Self.PutEquipament(Player, 1777, 1);
                    Self.PutEquipament(Player, 1063, 1);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 1807, 1);
                    Self.PutEquipament(Player, 1837, 1);
                    Self.PutEquipament(Player, 1867, 1);
                    Self.PutEquipament(Player, 1897, 1);
                    Self.PutEquipament(Player, 1028, 1);
                    Self.PutEquipament(Player, 1301, 1);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 1927, 1);
                    Self.PutEquipament(Player, 1957, 1);
                    Self.PutEquipament(Player, 1987, 1);
                    Self.PutEquipament(Player, 2017, 1);
                    Self.PutEquipament(Player, 1203, 1);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 2047, 1);
                    Self.PutEquipament(Player, 2077, 1);
                    Self.PutEquipament(Player, 2107, 1);
                    Self.PutEquipament(Player, 2137, 1);
                    Self.PutEquipament(Player, 1168, 1);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 2167, 1);
                    Self.PutEquipament(Player, 2197, 1);
                    Self.PutEquipament(Player, 2227, 1);
                    Self.PutEquipament(Player, 2257, 1);
                    Self.PutEquipament(Player, 1273, 1);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 2287, 1);
                    Self.PutEquipament(Player, 2317, 1);
                    Self.PutEquipament(Player, 2347, 1);
                    Self.PutEquipament(Player, 2377, 1);
                    Self.PutEquipament(Player, 1238, 1);
                  end;
              end;
            end;


             1158: //caixa Aparencia Cavaleiros Wars
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 3550, 1);
                    Self.PutEquipament(Player, 3551, 1);
                    Self.PutEquipament(Player, 3552, 1);
                    Self.PutEquipament(Player, 3553, 1);
                    end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 3555, 1);
                    Self.PutEquipament(Player, 3556, 1);
                    Self.PutEquipament(Player, 3557, 1);
                    Self.PutEquipament(Player, 3558, 1);

                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 3560, 1);
                    Self.PutEquipament(Player, 3561, 1);
                    Self.PutEquipament(Player, 3562, 1);
                    Self.PutEquipament(Player, 3563, 1);

                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 3565, 1);
                    Self.PutEquipament(Player, 3566, 1);
                    Self.PutEquipament(Player, 3567, 1);
                    Self.PutEquipament(Player, 3568, 1);

                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 3570, 1);
                    Self.PutEquipament(Player, 3571, 1);
                    Self.PutEquipament(Player, 3572, 1);
                    Self.PutEquipament(Player, 3573, 1);

                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 3575, 1);
                    Self.PutEquipament(Player, 3576, 1);
                    Self.PutEquipament(Player, 3577, 1);
                    Self.PutEquipament(Player, 3578, 1);
                                      end;
              end;
            end;


            1146: //80 lv2 hora do fim
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12058, 188);
                    Self.PutEquipament(Player, 12366, 188);
                    Self.PutEquipament(Player, 12396, 188);
                    Self.PutEquipament(Player, 12426, 188);
                    Self.PutEquipament(Player, 12456, 188);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12093, 188);
                    Self.PutEquipament(Player, 12336, 188);
                    Self.PutEquipament(Player, 12486, 188);
                    Self.PutEquipament(Player, 12516, 188);
                    Self.PutEquipament(Player, 12546, 188);
                    Self.PutEquipament(Player, 12576, 188);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12198, 188);
                    Self.PutEquipament(Player, 12606, 188);
                    Self.PutEquipament(Player, 12636, 188);
                    Self.PutEquipament(Player, 12666, 188);
                    Self.PutEquipament(Player, 12696, 188);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12233, 188);
                    Self.PutEquipament(Player, 12726, 188);
                    Self.PutEquipament(Player, 12756, 188);
                    Self.PutEquipament(Player, 12786, 188);
                    Self.PutEquipament(Player, 12816, 188);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12268, 188);
                    Self.PutEquipament(Player, 12846, 188);
                    Self.PutEquipament(Player, 12876, 188);
                    Self.PutEquipament(Player, 12906, 188);
                    Self.PutEquipament(Player, 12936, 188);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12303, 188);
                    Self.PutEquipament(Player, 12966, 188);
                    Self.PutEquipament(Player, 12996, 188);
                    Self.PutEquipament(Player, 13026, 188);
                    Self.PutEquipament(Player, 13056, 188);
                  end;
              end;
            end;

            1147: //80 lv2 crepusculo
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12059, 188);
                    Self.PutEquipament(Player, 12367, 188);
                    Self.PutEquipament(Player, 12397, 188);
                    Self.PutEquipament(Player, 12427, 188);
                    Self.PutEquipament(Player, 12457, 188);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12094, 188);
                    Self.PutEquipament(Player, 12337, 188);
                    Self.PutEquipament(Player, 12487, 188);
                    Self.PutEquipament(Player, 12517, 188);
                    Self.PutEquipament(Player, 12547, 188);
                    Self.PutEquipament(Player, 12577, 188);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12199, 188);
                    Self.PutEquipament(Player, 12607, 188);
                    Self.PutEquipament(Player, 12637, 188);
                    Self.PutEquipament(Player, 12667, 188);
                    Self.PutEquipament(Player, 12697, 188);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12234, 188);
                    Self.PutEquipament(Player, 12727, 188);
                    Self.PutEquipament(Player, 12757, 188);
                    Self.PutEquipament(Player, 12787, 188);
                    Self.PutEquipament(Player, 12817, 188);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12269, 188);
                    Self.PutEquipament(Player, 12847, 188);
                    Self.PutEquipament(Player, 12877, 188);
                    Self.PutEquipament(Player, 12907, 188);
                    Self.PutEquipament(Player, 12937, 188);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12304, 188);
                    Self.PutEquipament(Player, 12967, 188);
                    Self.PutEquipament(Player, 12997, 188);
                    Self.PutEquipament(Player, 13027, 188);
                    Self.PutEquipament(Player, 13057, 188);
                  end;
              end;
            end;

            1149: //80 lv2 Vida
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12060, 188);
                    Self.PutEquipament(Player, 12368, 188);
                    Self.PutEquipament(Player, 12398, 188);
                    Self.PutEquipament(Player, 12428, 188);
                    Self.PutEquipament(Player, 12458, 188);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12095, 188);
                    Self.PutEquipament(Player, 12338, 188);
                    Self.PutEquipament(Player, 12488, 188);
                    Self.PutEquipament(Player, 12518, 188);
                    Self.PutEquipament(Player, 12548, 188);
                    Self.PutEquipament(Player, 12578, 188);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12200, 188);
                    Self.PutEquipament(Player, 12608, 188);
                    Self.PutEquipament(Player, 12638, 188);
                    Self.PutEquipament(Player, 12668, 188);
                    Self.PutEquipament(Player, 12698, 188);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12235, 188);
                    Self.PutEquipament(Player, 12728, 188);
                    Self.PutEquipament(Player, 12758, 188);
                    Self.PutEquipament(Player, 12788, 188);
                    Self.PutEquipament(Player, 12818, 188);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12270, 188);
                    Self.PutEquipament(Player, 12848, 188);
                    Self.PutEquipament(Player, 12878, 188);
                    Self.PutEquipament(Player, 12908, 188);
                    Self.PutEquipament(Player, 12938, 188);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12305, 188);
                    Self.PutEquipament(Player, 12968, 188);
                    Self.PutEquipament(Player, 12998, 188);
                    Self.PutEquipament(Player, 13028, 188);
                    Self.PutEquipament(Player, 13058, 188);
                  end;
              end;
            end;


            1148: //80 lv2 amanhcer
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12061, 188);
                    Self.PutEquipament(Player, 12369, 188);
                    Self.PutEquipament(Player, 12399, 188);
                    Self.PutEquipament(Player, 12429, 188);
                    Self.PutEquipament(Player, 12459, 188);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12096, 188);
                    Self.PutEquipament(Player, 12339, 188);
                    Self.PutEquipament(Player, 12489, 188);
                    Self.PutEquipament(Player, 12519, 188);
                    Self.PutEquipament(Player, 12549, 188);
                    Self.PutEquipament(Player, 12579, 188);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12201, 188);
                    Self.PutEquipament(Player, 12609, 188);
                    Self.PutEquipament(Player, 12639, 188);
                    Self.PutEquipament(Player, 12669, 188);
                    Self.PutEquipament(Player, 12699, 188);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12236, 188);
                    Self.PutEquipament(Player, 12729, 188);
                    Self.PutEquipament(Player, 12759, 188);
                    Self.PutEquipament(Player, 12789, 188);
                    Self.PutEquipament(Player, 12819, 188);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12271, 188);
                    Self.PutEquipament(Player, 12849, 188);
                    Self.PutEquipament(Player, 12879, 188);
                    Self.PutEquipament(Player, 12909, 188);
                    Self.PutEquipament(Player, 12939, 188);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12306, 188);
                    Self.PutEquipament(Player, 12969, 188);
                    Self.PutEquipament(Player, 12999, 188);
                    Self.PutEquipament(Player, 13029, 188);
                    Self.PutEquipament(Player, 13059, 188);
                  end;
              end;
            end;
              // sets refinados 80 level 2 13 14 e 15


            1168: //80 lv2 hora do fim + 13
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12058, 220);
                    Self.PutEquipament(Player, 12366, 220);
                    Self.PutEquipament(Player, 12396, 220);
                    Self.PutEquipament(Player, 12426, 220);
                    Self.PutEquipament(Player, 12456, 220);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12093, 220);
                    Self.PutEquipament(Player, 12336, 220);
                    Self.PutEquipament(Player, 12486, 220);
                    Self.PutEquipament(Player, 12516, 220);
                    Self.PutEquipament(Player, 12546, 220);
                    Self.PutEquipament(Player, 12576, 220);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12198, 220);
                    Self.PutEquipament(Player, 12606, 220);
                    Self.PutEquipament(Player, 12636, 220);
                    Self.PutEquipament(Player, 12666, 220);
                    Self.PutEquipament(Player, 12696, 220);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12233, 220);
                    Self.PutEquipament(Player, 12726, 220);
                    Self.PutEquipament(Player, 12756, 220);
                    Self.PutEquipament(Player, 12786, 220);
                    Self.PutEquipament(Player, 12816, 220);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12268, 220);
                    Self.PutEquipament(Player, 12846, 220);
                    Self.PutEquipament(Player, 12876, 220);
                    Self.PutEquipament(Player, 12906, 220);
                    Self.PutEquipament(Player, 12936, 220);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12303, 220);
                    Self.PutEquipament(Player, 12966, 220);
                    Self.PutEquipament(Player, 12996, 220);
                    Self.PutEquipament(Player, 13026, 220);
                    Self.PutEquipament(Player, 13056, 220);
                  end;
              end;
            end;

            1165: //80 lv2 crepusculo +13
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12059, 220);
                    Self.PutEquipament(Player, 12367, 220);
                    Self.PutEquipament(Player, 12397, 220);
                    Self.PutEquipament(Player, 12427, 220);
                    Self.PutEquipament(Player, 12457, 220);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12094, 220);
                    Self.PutEquipament(Player, 12337, 220);
                    Self.PutEquipament(Player, 12487, 220);
                    Self.PutEquipament(Player, 12517, 220);
                    Self.PutEquipament(Player, 12547, 220);
                    Self.PutEquipament(Player, 12577, 220);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12199, 220);
                    Self.PutEquipament(Player, 12607, 220);
                    Self.PutEquipament(Player, 12637, 220);
                    Self.PutEquipament(Player, 12667, 220);
                    Self.PutEquipament(Player, 12697, 220);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12234, 220);
                    Self.PutEquipament(Player, 12727, 220);
                    Self.PutEquipament(Player, 12757, 220);
                    Self.PutEquipament(Player, 12787, 220);
                    Self.PutEquipament(Player, 12817, 220);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12269, 220);
                    Self.PutEquipament(Player, 12847, 220);
                    Self.PutEquipament(Player, 12877, 220);
                    Self.PutEquipament(Player, 12907, 220);
                    Self.PutEquipament(Player, 12937, 220);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12304, 220);
                    Self.PutEquipament(Player, 12967, 220);
                    Self.PutEquipament(Player, 12997, 220);
                    Self.PutEquipament(Player, 13027, 220);
                    Self.PutEquipament(Player, 13057, 220);
                  end;
              end;
            end;

            1166: //80 lv2 Vida                 +13
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12060, 220);
                    Self.PutEquipament(Player, 12368, 220);
                    Self.PutEquipament(Player, 12398, 220);
                    Self.PutEquipament(Player, 12428, 220);
                    Self.PutEquipament(Player, 12458, 220);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12095, 220);
                    Self.PutEquipament(Player, 12338, 220);
                    Self.PutEquipament(Player, 12488, 220);
                    Self.PutEquipament(Player, 12518, 220);
                    Self.PutEquipament(Player, 12548, 220);
                    Self.PutEquipament(Player, 12578, 220);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12200, 220);
                    Self.PutEquipament(Player, 12608, 220);
                    Self.PutEquipament(Player, 12638, 220);
                    Self.PutEquipament(Player, 12668, 220);
                    Self.PutEquipament(Player, 12698, 220);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12235, 220);
                    Self.PutEquipament(Player, 12728, 220);
                    Self.PutEquipament(Player, 12758, 220);
                    Self.PutEquipament(Player, 12788, 220);
                    Self.PutEquipament(Player, 12818, 220);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12270, 220);
                    Self.PutEquipament(Player, 12848, 220);
                    Self.PutEquipament(Player, 12878, 220);
                    Self.PutEquipament(Player, 12908, 220);
                    Self.PutEquipament(Player, 12938, 220);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12305, 220);
                    Self.PutEquipament(Player, 12968, 220);
                    Self.PutEquipament(Player, 12998, 220);
                    Self.PutEquipament(Player, 13028, 220);
                    Self.PutEquipament(Player, 13058, 220);
                  end;
              end;
            end;


            1167: //80 lv2 amanhcer    +13
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12061, 220);
                    Self.PutEquipament(Player, 12369, 220);
                    Self.PutEquipament(Player, 12399, 220);
                    Self.PutEquipament(Player, 12429, 220);
                    Self.PutEquipament(Player, 12459, 220);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12096, 220);
                    Self.PutEquipament(Player, 12339, 220);
                    Self.PutEquipament(Player, 12489, 220);
                    Self.PutEquipament(Player, 12519, 220);
                    Self.PutEquipament(Player, 12549, 220);
                    Self.PutEquipament(Player, 12579, 220);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12201, 220);
                    Self.PutEquipament(Player, 12609, 220);
                    Self.PutEquipament(Player, 12639, 220);
                    Self.PutEquipament(Player, 12669, 220);
                    Self.PutEquipament(Player, 12699, 220);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12236, 220);
                    Self.PutEquipament(Player, 12729, 220);
                    Self.PutEquipament(Player, 12759, 220);
                    Self.PutEquipament(Player, 12789, 220);
                    Self.PutEquipament(Player, 12819, 220);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12271, 220);
                    Self.PutEquipament(Player, 12849, 220);
                    Self.PutEquipament(Player, 12879, 220);
                    Self.PutEquipament(Player, 12909, 220);
                    Self.PutEquipament(Player, 12939, 220);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12306, 220);
                    Self.PutEquipament(Player, 12969, 220);
                    Self.PutEquipament(Player, 12999, 220);
                    Self.PutEquipament(Player, 13029, 220);
                    Self.PutEquipament(Player, 13059, 220);
                  end;
              end;
            end;



            1169: //80 lv2 hora do fim    +14
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12058, 230);
                    Self.PutEquipament(Player, 12366, 230);
                    Self.PutEquipament(Player, 12396, 230);
                    Self.PutEquipament(Player, 12426, 230);
                    Self.PutEquipament(Player, 12456, 230);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12093, 230);
                    Self.PutEquipament(Player, 12336, 230);
                    Self.PutEquipament(Player, 12486, 230);
                    Self.PutEquipament(Player, 12516, 230);
                    Self.PutEquipament(Player, 12546, 230);
                    Self.PutEquipament(Player, 12576, 230);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12198, 230);
                    Self.PutEquipament(Player, 12606, 230);
                    Self.PutEquipament(Player, 12636, 230);
                    Self.PutEquipament(Player, 12666, 230);
                    Self.PutEquipament(Player, 12696, 230);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12233, 230);
                    Self.PutEquipament(Player, 12726, 230);
                    Self.PutEquipament(Player, 12756, 230);
                    Self.PutEquipament(Player, 12786, 230);
                    Self.PutEquipament(Player, 12816, 230);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12268, 230);
                    Self.PutEquipament(Player, 12846, 230);
                    Self.PutEquipament(Player, 12876, 230);
                    Self.PutEquipament(Player, 12906, 230);
                    Self.PutEquipament(Player, 12936, 230);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12303, 230);
                    Self.PutEquipament(Player, 12966, 230);
                    Self.PutEquipament(Player, 12996, 230);
                    Self.PutEquipament(Player, 13026, 230);
                    Self.PutEquipament(Player, 13056, 230);
                  end;
              end;
            end;

            1170: //80 lv2 crepusculo     +14
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12059, 230);
                    Self.PutEquipament(Player, 12367, 230);
                    Self.PutEquipament(Player, 12397, 230);
                    Self.PutEquipament(Player, 12427, 230);
                    Self.PutEquipament(Player, 12457, 230);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12094, 230);
                    Self.PutEquipament(Player, 12337, 230);
                    Self.PutEquipament(Player, 12487, 230);
                    Self.PutEquipament(Player, 12517, 230);
                    Self.PutEquipament(Player, 12547, 230);
                    Self.PutEquipament(Player, 12577, 230);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12199, 230);
                    Self.PutEquipament(Player, 12607, 230);
                    Self.PutEquipament(Player, 12637, 230);
                    Self.PutEquipament(Player, 12667, 230);
                    Self.PutEquipament(Player, 12697, 230);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12234, 230);
                    Self.PutEquipament(Player, 12727, 230);
                    Self.PutEquipament(Player, 12757, 230);
                    Self.PutEquipament(Player, 12787, 230);
                    Self.PutEquipament(Player, 12817, 230);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12269, 230);
                    Self.PutEquipament(Player, 12847, 230);
                    Self.PutEquipament(Player, 12877, 230);
                    Self.PutEquipament(Player, 12907, 230);
                    Self.PutEquipament(Player, 12937, 230);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12304, 230);
                    Self.PutEquipament(Player, 12967, 230);
                    Self.PutEquipament(Player, 12997, 230);
                    Self.PutEquipament(Player, 13027, 230);
                    Self.PutEquipament(Player, 13057, 230);
                  end;
              end;
            end;

            1172: //80 lv2 Vida             +14
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12060, 230);
                    Self.PutEquipament(Player, 12368, 230);
                    Self.PutEquipament(Player, 12398, 230);
                    Self.PutEquipament(Player, 12428, 230);
                    Self.PutEquipament(Player, 12458, 230);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12095, 230);
                    Self.PutEquipament(Player, 12338, 230);
                    Self.PutEquipament(Player, 12488, 230);
                    Self.PutEquipament(Player, 12518, 230);
                    Self.PutEquipament(Player, 12548, 230);
                    Self.PutEquipament(Player, 12578, 230);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12200, 230);
                    Self.PutEquipament(Player, 12608, 230);
                    Self.PutEquipament(Player, 12638, 230);
                    Self.PutEquipament(Player, 12668, 230);
                    Self.PutEquipament(Player, 12698, 230);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12235, 230);
                    Self.PutEquipament(Player, 12728, 230);
                    Self.PutEquipament(Player, 12758, 230);
                    Self.PutEquipament(Player, 12788, 230);
                    Self.PutEquipament(Player, 12818, 230);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12270, 230);
                    Self.PutEquipament(Player, 12848, 230);
                    Self.PutEquipament(Player, 12878, 230);
                    Self.PutEquipament(Player, 12908, 230);
                    Self.PutEquipament(Player, 12938, 230);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12305, 230);
                    Self.PutEquipament(Player, 12968, 230);
                    Self.PutEquipament(Player, 12998, 230);
                    Self.PutEquipament(Player, 13028, 230);
                    Self.PutEquipament(Player, 13058, 230);
                  end;
              end;
            end;


            1718: //80 lv2 amanhcer      +14
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12061, 230);
                    Self.PutEquipament(Player, 12369, 230);
                    Self.PutEquipament(Player, 12399, 230);
                    Self.PutEquipament(Player, 12429, 230);
                    Self.PutEquipament(Player, 12459, 230);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12096, 230);
                    Self.PutEquipament(Player, 12339, 230);
                    Self.PutEquipament(Player, 12489, 230);
                    Self.PutEquipament(Player, 12519, 230);
                    Self.PutEquipament(Player, 12549, 230);
                    Self.PutEquipament(Player, 12579, 230);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12201, 230);
                    Self.PutEquipament(Player, 12609, 230);
                    Self.PutEquipament(Player, 12639, 230);
                    Self.PutEquipament(Player, 12669, 230);
                    Self.PutEquipament(Player, 12699, 230);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12236, 230);
                    Self.PutEquipament(Player, 12729, 230);
                    Self.PutEquipament(Player, 12759, 230);
                    Self.PutEquipament(Player, 12789, 230);
                    Self.PutEquipament(Player, 12819, 230);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12271, 230);
                    Self.PutEquipament(Player, 12849, 230);
                    Self.PutEquipament(Player, 12879, 230);
                    Self.PutEquipament(Player, 12909, 230);
                    Self.PutEquipament(Player, 12939, 230);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12306, 230);
                    Self.PutEquipament(Player, 12969, 230);
                    Self.PutEquipament(Player, 12999, 230);
                    Self.PutEquipament(Player, 13029, 230);
                    Self.PutEquipament(Player, 13059, 230);
                  end;
              end;
            end;


            1173: //80 lv2 hora do fim      +15
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12058, 250);
                    Self.PutEquipament(Player, 12366, 250);
                    Self.PutEquipament(Player, 12396, 250);
                    Self.PutEquipament(Player, 12426, 250);
                    Self.PutEquipament(Player, 12456, 250);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12093, 250);
                    Self.PutEquipament(Player, 12336, 250);
                    Self.PutEquipament(Player, 12486, 250);
                    Self.PutEquipament(Player, 12516, 250);
                    Self.PutEquipament(Player, 12546, 250);
                    Self.PutEquipament(Player, 12576, 250);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12198, 250);
                    Self.PutEquipament(Player, 12606, 250);
                    Self.PutEquipament(Player, 12636, 250);
                    Self.PutEquipament(Player, 12666, 250);
                    Self.PutEquipament(Player, 12696, 250);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12233, 250);
                    Self.PutEquipament(Player, 12726, 250);
                    Self.PutEquipament(Player, 12756, 250);
                    Self.PutEquipament(Player, 12786, 250);
                    Self.PutEquipament(Player, 12816, 250);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12268, 250);
                    Self.PutEquipament(Player, 12846, 250);
                    Self.PutEquipament(Player, 12876, 250);
                    Self.PutEquipament(Player, 12906, 250);
                    Self.PutEquipament(Player, 12936, 250);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12303, 250);
                    Self.PutEquipament(Player, 12966, 250);
                    Self.PutEquipament(Player, 12996, 250);
                    Self.PutEquipament(Player, 13026, 250);
                    Self.PutEquipament(Player, 13056, 250);
                  end;
              end;
            end;

            1174: //80 lv2 crepusculo      +15
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12059, 250);
                    Self.PutEquipament(Player, 12367, 250);
                    Self.PutEquipament(Player, 12397, 250);
                    Self.PutEquipament(Player, 12427, 250);
                    Self.PutEquipament(Player, 12457, 250);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12094, 250);
                    Self.PutEquipament(Player, 12337, 250);
                    Self.PutEquipament(Player, 12487, 250);
                    Self.PutEquipament(Player, 12517, 250);
                    Self.PutEquipament(Player, 12547, 250);
                    Self.PutEquipament(Player, 12577, 250);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12199, 250);
                    Self.PutEquipament(Player, 12607, 250);
                    Self.PutEquipament(Player, 12637, 250);
                    Self.PutEquipament(Player, 12667, 250);
                    Self.PutEquipament(Player, 12697, 250);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12234, 250);
                    Self.PutEquipament(Player, 12727, 250);
                    Self.PutEquipament(Player, 12757, 250);
                    Self.PutEquipament(Player, 12787, 250);
                    Self.PutEquipament(Player, 12817, 250);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12269, 250);
                    Self.PutEquipament(Player, 12847, 250);
                    Self.PutEquipament(Player, 12877, 250);
                    Self.PutEquipament(Player, 12907, 250);
                    Self.PutEquipament(Player, 12937, 250);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12304, 250);
                    Self.PutEquipament(Player, 12967, 250);
                    Self.PutEquipament(Player, 12997, 250);
                    Self.PutEquipament(Player, 13027, 250);
                    Self.PutEquipament(Player, 13057, 250);
                  end;
              end;
            end;

            1175: //80 lv2 Vida           +15
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12060, 250);
                    Self.PutEquipament(Player, 12368, 250);
                    Self.PutEquipament(Player, 12398, 250);
                    Self.PutEquipament(Player, 12428, 250);
                    Self.PutEquipament(Player, 12458, 250);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12095, 250);
                    Self.PutEquipament(Player, 12338, 250);
                    Self.PutEquipament(Player, 12488, 250);
                    Self.PutEquipament(Player, 12518, 250);
                    Self.PutEquipament(Player, 12548, 250);
                    Self.PutEquipament(Player, 12578, 250);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12200, 250);
                    Self.PutEquipament(Player, 12608, 250);
                    Self.PutEquipament(Player, 12638, 250);
                    Self.PutEquipament(Player, 12668, 250);
                    Self.PutEquipament(Player, 12698, 250);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12235, 250);
                    Self.PutEquipament(Player, 12728, 250);
                    Self.PutEquipament(Player, 12758, 250);
                    Self.PutEquipament(Player, 12788, 250);
                    Self.PutEquipament(Player, 12818, 250);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12270, 250);
                    Self.PutEquipament(Player, 12848, 250);
                    Self.PutEquipament(Player, 12878, 250);
                    Self.PutEquipament(Player, 12908, 250);
                    Self.PutEquipament(Player, 12938, 250);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12305, 250);
                    Self.PutEquipament(Player, 12968, 250);
                    Self.PutEquipament(Player, 12998, 250);
                    Self.PutEquipament(Player, 13028, 250);
                    Self.PutEquipament(Player, 13058, 250);
                  end;
              end;
            end;


            1176: //80 lv2 amanhcer      +15
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12061, 250);
                    Self.PutEquipament(Player, 12369, 250);
                    Self.PutEquipament(Player, 12399, 250);
                    Self.PutEquipament(Player, 12429, 250);
                    Self.PutEquipament(Player, 12459, 250);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12096, 250);
                    Self.PutEquipament(Player, 12339, 250);
                    Self.PutEquipament(Player, 12489, 250);
                    Self.PutEquipament(Player, 12519, 250);
                    Self.PutEquipament(Player, 12549, 250);
                    Self.PutEquipament(Player, 12579, 250);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12201, 250);
                    Self.PutEquipament(Player, 12609, 250);
                    Self.PutEquipament(Player, 12639, 250);
                    Self.PutEquipament(Player, 12669, 250);
                    Self.PutEquipament(Player, 12699, 250);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12236, 250);
                    Self.PutEquipament(Player, 12729, 250);
                    Self.PutEquipament(Player, 12759, 250);
                    Self.PutEquipament(Player, 12789, 250);
                    Self.PutEquipament(Player, 12819, 250);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12271, 250);
                    Self.PutEquipament(Player, 12849, 250);
                    Self.PutEquipament(Player, 12879, 250);
                    Self.PutEquipament(Player, 12909, 250);
                    Self.PutEquipament(Player, 12939, 250);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12306, 250);
                    Self.PutEquipament(Player, 12969, 250);
                    Self.PutEquipament(Player, 12999, 250);
                    Self.PutEquipament(Player, 13029, 250);
                    Self.PutEquipament(Player, 13059, 250);
                  end;
              end;
            end;

            1150: //wars + 12 tanke
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12073, 188);
                    Self.PutEquipament(Player, 12379, 188);
                    Self.PutEquipament(Player, 12409, 188);
                    Self.PutEquipament(Player, 12439, 188);
                    Self.PutEquipament(Player, 12469, 188);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12108, 188);
                    Self.PutEquipament(Player, 12349, 188);
                    Self.PutEquipament(Player, 12499, 188);
                    Self.PutEquipament(Player, 12529, 188);
                    Self.PutEquipament(Player, 12559, 188);
                    Self.PutEquipament(Player, 12589, 188);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12213, 188);
                    Self.PutEquipament(Player, 12619, 188);
                    Self.PutEquipament(Player, 12649, 188);
                    Self.PutEquipament(Player, 12679, 188);
                    Self.PutEquipament(Player, 12709, 188);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12248, 188);
                    Self.PutEquipament(Player, 12739, 188);
                    Self.PutEquipament(Player, 12769, 188);
                    Self.PutEquipament(Player, 12799, 188);
                    Self.PutEquipament(Player, 12829, 188);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12283, 188);
                    Self.PutEquipament(Player, 12859, 188);
                    Self.PutEquipament(Player, 12889, 188);
                    Self.PutEquipament(Player, 12919, 188);
                    Self.PutEquipament(Player, 12949, 188);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12318, 188);
                    Self.PutEquipament(Player, 12979, 188);
                    Self.PutEquipament(Player, 13009, 188);
                    Self.PutEquipament(Player, 13039, 188);
                    Self.PutEquipament(Player, 13069, 188);
                  end;
              end;
            end;


             1151: //CELESTIAL +12 tank
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12066, 198);
                    Self.PutEquipament(Player, 12372, 198);
                    Self.PutEquipament(Player, 12402, 198);
                    Self.PutEquipament(Player, 12432, 198);
                    Self.PutEquipament(Player, 12462, 198);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12101, 198);
                    Self.PutEquipament(Player, 12342, 198);
                    Self.PutEquipament(Player, 12492, 198);
                    Self.PutEquipament(Player, 12522, 198);
                    Self.PutEquipament(Player, 12552, 198);
                    Self.PutEquipament(Player, 12582, 198);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12206, 198);
                    Self.PutEquipament(Player, 12612, 198);
                    Self.PutEquipament(Player, 12642, 198);
                    Self.PutEquipament(Player, 12672, 198);
                    Self.PutEquipament(Player, 12702, 198);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12241, 198);
                    Self.PutEquipament(Player, 12732, 198);
                    Self.PutEquipament(Player, 12762, 198);
                    Self.PutEquipament(Player, 12792, 198);
                    Self.PutEquipament(Player, 12822, 198);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12276, 198);
                    Self.PutEquipament(Player, 12852, 198);
                    Self.PutEquipament(Player, 12882, 198);
                    Self.PutEquipament(Player, 12912, 198);
                    Self.PutEquipament(Player, 12942, 198);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12311, 198);
                    Self.PutEquipament(Player, 12972, 198);
                    Self.PutEquipament(Player, 13002, 198);
                    Self.PutEquipament(Player, 13032, 198);
                    Self.PutEquipament(Player, 13062, 198);
                  end;
              end;
            end;

            1152: //CELESTIAL +12 DANO
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12067, 198);
                    Self.PutEquipament(Player, 12373, 198);
                    Self.PutEquipament(Player, 12403, 198);
                    Self.PutEquipament(Player, 12433, 198);
                    Self.PutEquipament(Player, 12463, 198);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12102, 198);
                    Self.PutEquipament(Player, 12343, 198);
                    Self.PutEquipament(Player, 12493, 198);
                    Self.PutEquipament(Player, 12523, 198);
                    Self.PutEquipament(Player, 12553, 198);
                    Self.PutEquipament(Player, 12583, 198);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12207, 198);
                    Self.PutEquipament(Player, 12613, 198);
                    Self.PutEquipament(Player, 12643, 198);
                    Self.PutEquipament(Player, 12673, 198);
                    Self.PutEquipament(Player, 12703, 198);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12242, 198);
                    Self.PutEquipament(Player, 12733, 198);
                    Self.PutEquipament(Player, 12763, 198);
                    Self.PutEquipament(Player, 12793, 198);
                    Self.PutEquipament(Player, 12823, 198);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12277, 198);
                    Self.PutEquipament(Player, 12853, 198);
                    Self.PutEquipament(Player, 12883, 198);
                    Self.PutEquipament(Player, 12913, 198);
                    Self.PutEquipament(Player, 12943, 198);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12312, 198);
                    Self.PutEquipament(Player, 12973, 198);
                    Self.PutEquipament(Player, 13003, 198);
                    Self.PutEquipament(Player, 13033, 198);
                    Self.PutEquipament(Player, 13063, 198);
                  end;
              end;
            end;


             1160: //CELESTIAL +13 tank
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12066, 220);
                    Self.PutEquipament(Player, 12372, 220);
                    Self.PutEquipament(Player, 12402, 220);
                    Self.PutEquipament(Player, 12432, 220);
                    Self.PutEquipament(Player, 12462, 220);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12101, 220);
                    Self.PutEquipament(Player, 12342, 220);
                    Self.PutEquipament(Player, 12492, 220);
                    Self.PutEquipament(Player, 12522, 220);
                    Self.PutEquipament(Player, 12552, 220);
                    Self.PutEquipament(Player, 12582, 220);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12206, 220);
                    Self.PutEquipament(Player, 12612, 220);
                    Self.PutEquipament(Player, 12642, 220);
                    Self.PutEquipament(Player, 12672, 220);
                    Self.PutEquipament(Player, 12702, 220);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12241, 220);
                    Self.PutEquipament(Player, 12732, 220);
                    Self.PutEquipament(Player, 12762, 220);
                    Self.PutEquipament(Player, 12792, 220);
                    Self.PutEquipament(Player, 12822, 220);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12276, 220);
                    Self.PutEquipament(Player, 12852, 220);
                    Self.PutEquipament(Player, 12882, 220);
                    Self.PutEquipament(Player, 12912, 220);
                    Self.PutEquipament(Player, 12942, 220);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12311, 220);
                    Self.PutEquipament(Player, 12972, 220);
                    Self.PutEquipament(Player, 13002, 220);
                    Self.PutEquipament(Player, 13032, 220);
                    Self.PutEquipament(Player, 13062, 220);
                  end;
              end;
            end;


         1159:   //CELESTIAL +13  DANO
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12067, 220);
                    Self.PutEquipament(Player, 12373, 220);
                    Self.PutEquipament(Player, 12403, 220);
                    Self.PutEquipament(Player, 12433, 220);
                    Self.PutEquipament(Player, 12463, 220);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12102, 220);
                    Self.PutEquipament(Player, 12343, 220);
                    Self.PutEquipament(Player, 12493, 220);
                    Self.PutEquipament(Player, 12523, 220);
                    Self.PutEquipament(Player, 12553, 220);
                    Self.PutEquipament(Player, 12583, 220);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12207, 220);
                    Self.PutEquipament(Player, 12613, 220);
                    Self.PutEquipament(Player, 12643, 220);
                    Self.PutEquipament(Player, 12673, 220);
                    Self.PutEquipament(Player, 12703, 220);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12242, 220);
                    Self.PutEquipament(Player, 12733, 220);
                    Self.PutEquipament(Player, 12763, 220);
                    Self.PutEquipament(Player, 12793, 220);
                    Self.PutEquipament(Player, 12823, 220);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12277, 220);
                    Self.PutEquipament(Player, 12853, 220);
                    Self.PutEquipament(Player, 12883, 220);
                    Self.PutEquipament(Player, 12913, 220);
                    Self.PutEquipament(Player, 12943, 220);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12312, 220);
                    Self.PutEquipament(Player, 12973, 220);
                    Self.PutEquipament(Player, 13003, 220);
                    Self.PutEquipament(Player, 13033, 220);
                    Self.PutEquipament(Player, 13063, 220);
                  end;
              end;
            end;


             1162: // CELESTIAL +14 TANK
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12066, 230);
                    Self.PutEquipament(Player, 12372, 230);
                    Self.PutEquipament(Player, 12402, 230);
                    Self.PutEquipament(Player, 12432, 230);
                    Self.PutEquipament(Player, 12462, 230);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12101, 230);
                    Self.PutEquipament(Player, 12342, 230);
                    Self.PutEquipament(Player, 12492, 230);
                    Self.PutEquipament(Player, 12522, 230);
                    Self.PutEquipament(Player, 12552, 230);
                    Self.PutEquipament(Player, 12582, 230);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12206, 230);
                    Self.PutEquipament(Player, 12612, 230);
                    Self.PutEquipament(Player, 12642, 230);
                    Self.PutEquipament(Player, 12672, 230);
                    Self.PutEquipament(Player, 12702, 230);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12241, 230);
                    Self.PutEquipament(Player, 12732, 230);
                    Self.PutEquipament(Player, 12762, 230);
                    Self.PutEquipament(Player, 12792, 230);
                    Self.PutEquipament(Player, 12822, 230);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12276, 230);
                    Self.PutEquipament(Player, 12852, 230);
                    Self.PutEquipament(Player, 12882, 230);
                    Self.PutEquipament(Player, 12912, 230);
                    Self.PutEquipament(Player, 12942, 230);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12311, 230);
                    Self.PutEquipament(Player, 12972, 230);
                    Self.PutEquipament(Player, 13002, 230);
                    Self.PutEquipament(Player, 13032, 230);
                    Self.PutEquipament(Player, 13062, 230);
                  end;
              end;
            end;




             1164: // CELESTIAL +15 TANK
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12066, 250);
                    Self.PutEquipament(Player, 12372, 250);
                    Self.PutEquipament(Player, 12402, 250);
                    Self.PutEquipament(Player, 12432, 250);
                    Self.PutEquipament(Player, 12462, 250);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12101, 250);
                    Self.PutEquipament(Player, 12342, 250);
                    Self.PutEquipament(Player, 12492, 250);
                    Self.PutEquipament(Player, 12522, 250);
                    Self.PutEquipament(Player, 12552, 250);
                    Self.PutEquipament(Player, 12582, 250);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12206, 250);
                    Self.PutEquipament(Player, 12612, 250);
                    Self.PutEquipament(Player, 12642, 250);
                    Self.PutEquipament(Player, 12672, 250);
                    Self.PutEquipament(Player, 12702, 250);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12241, 250);
                    Self.PutEquipament(Player, 12732, 250);
                    Self.PutEquipament(Player, 12762, 250);
                    Self.PutEquipament(Player, 12792, 250);
                    Self.PutEquipament(Player, 12822, 250);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12276, 250);
                    Self.PutEquipament(Player, 12852, 250);
                    Self.PutEquipament(Player, 12882, 250);
                    Self.PutEquipament(Player, 12912, 250);
                    Self.PutEquipament(Player, 12942, 250);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12311, 250);
                    Self.PutEquipament(Player, 12972, 250);
                    Self.PutEquipament(Player, 13002, 250);
                    Self.PutEquipament(Player, 13032, 250);
                    Self.PutEquipament(Player, 13062, 250);
                  end;
              end;
            end;


        1163: // CELESTIAL +15 DANO
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12067, 250);
                    Self.PutEquipament(Player, 12373, 250);
                    Self.PutEquipament(Player, 12403, 250);
                    Self.PutEquipament(Player, 12433, 250);
                    Self.PutEquipament(Player, 12463, 250);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12102, 250);
                    Self.PutEquipament(Player, 12343, 250);
                    Self.PutEquipament(Player, 12493, 250);
                    Self.PutEquipament(Player, 12523, 250);
                    Self.PutEquipament(Player, 12553, 250);
                    Self.PutEquipament(Player, 12583, 250);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12207, 250);
                    Self.PutEquipament(Player, 12613, 250);
                    Self.PutEquipament(Player, 12643, 250);
                    Self.PutEquipament(Player, 12673, 250);
                    Self.PutEquipament(Player, 12703, 250);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12242, 250);
                    Self.PutEquipament(Player, 12733, 250);
                    Self.PutEquipament(Player, 12763, 250);
                    Self.PutEquipament(Player, 12793, 250);
                    Self.PutEquipament(Player, 12823, 250);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12277, 250);
                    Self.PutEquipament(Player, 12853, 250);
                    Self.PutEquipament(Player, 12883, 250);
                    Self.PutEquipament(Player, 12913, 250);
                    Self.PutEquipament(Player, 12943, 250);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12312, 250);
                    Self.PutEquipament(Player, 12973, 250);
                    Self.PutEquipament(Player, 13003, 250);
                    Self.PutEquipament(Player, 13033, 250);
                    Self.PutEquipament(Player, 13063, 250);
                  end;
              end;
            end;


            1161: // CELESTIAL +14 DANO
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12067, 230);
                    Self.PutEquipament(Player, 12373, 230);
                    Self.PutEquipament(Player, 12403, 230);
                    Self.PutEquipament(Player, 12433, 230);
                    Self.PutEquipament(Player, 12463, 230);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12102, 230);
                    Self.PutEquipament(Player, 12343, 230);
                    Self.PutEquipament(Player, 12493, 230);
                    Self.PutEquipament(Player, 12523, 230);
                    Self.PutEquipament(Player, 12553, 230);
                    Self.PutEquipament(Player, 12583, 230);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12207, 230);
                    Self.PutEquipament(Player, 12613, 230);
                    Self.PutEquipament(Player, 12643, 230);
                    Self.PutEquipament(Player, 12673, 230);
                    Self.PutEquipament(Player, 12703, 230);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12242, 230);
                    Self.PutEquipament(Player, 12733, 230);
                    Self.PutEquipament(Player, 12763, 230);
                    Self.PutEquipament(Player, 12793, 230);
                    Self.PutEquipament(Player, 12823, 230);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12277, 230);
                    Self.PutEquipament(Player, 12853, 230);
                    Self.PutEquipament(Player, 12883, 230);
                    Self.PutEquipament(Player, 12913, 230);
                    Self.PutEquipament(Player, 12943, 230);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12312, 230);
                    Self.PutEquipament(Player, 12973, 230);
                    Self.PutEquipament(Player, 13003, 230);
                    Self.PutEquipament(Player, 13033, 230);
                    Self.PutEquipament(Player, 13063, 230);
                  end;
              end;
            end;


             1155: //CELESTIAL +1 DANO
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12067, 1);
                    Self.PutEquipament(Player, 12373, 1);
                    Self.PutEquipament(Player, 12403, 1);
                    Self.PutEquipament(Player, 12433, 1);
                    Self.PutEquipament(Player, 12463, 1);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12102, 1);
                    Self.PutEquipament(Player, 12343, 1);
                    Self.PutEquipament(Player, 12493, 1);
                    Self.PutEquipament(Player, 12523, 1);
                    Self.PutEquipament(Player, 12553, 1);
                    Self.PutEquipament(Player, 12583, 1);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12207, 1);
                    Self.PutEquipament(Player, 12613, 1);
                    Self.PutEquipament(Player, 12643, 1);
                    Self.PutEquipament(Player, 12673, 1);
                    Self.PutEquipament(Player, 12703, 1);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12242, 1);
                    Self.PutEquipament(Player, 12733, 1);
                    Self.PutEquipament(Player, 12763, 1);
                    Self.PutEquipament(Player, 12793, 1);
                    Self.PutEquipament(Player, 12823, 1);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12277, 1);
                    Self.PutEquipament(Player, 12853, 1);
                    Self.PutEquipament(Player, 12883, 1);
                    Self.PutEquipament(Player, 12913, 1);
                    Self.PutEquipament(Player, 12943, 1);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12312, 1);
                    Self.PutEquipament(Player, 12973, 1);
                    Self.PutEquipament(Player, 13003, 1);
                    Self.PutEquipament(Player, 13033, 1);
                    Self.PutEquipament(Player, 13063, 1);
                  end;
              end;
            end;

              1157: //CELESTIAL +12 tank  +1
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12066, 1);
                    Self.PutEquipament(Player, 12372, 1);
                    Self.PutEquipament(Player, 12402, 1);
                    Self.PutEquipament(Player, 12432, 1);
                    Self.PutEquipament(Player, 12462, 1);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12101, 1);
                    Self.PutEquipament(Player, 12342, 1);
                    Self.PutEquipament(Player, 12492, 1);
                    Self.PutEquipament(Player, 12522, 1);
                    Self.PutEquipament(Player, 12552, 1);
                    Self.PutEquipament(Player, 12582, 1);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12206, 1);
                    Self.PutEquipament(Player, 12612, 1);
                    Self.PutEquipament(Player, 12642, 1);
                    Self.PutEquipament(Player, 12672, 1);
                    Self.PutEquipament(Player, 12702, 1);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12241, 1);
                    Self.PutEquipament(Player, 12732, 1);
                    Self.PutEquipament(Player, 12762, 1);
                    Self.PutEquipament(Player, 12792, 1);
                    Self.PutEquipament(Player, 12822, 1);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12276, 1);
                    Self.PutEquipament(Player, 12852, 1);
                    Self.PutEquipament(Player, 12882, 1);
                    Self.PutEquipament(Player, 12912, 1);
                    Self.PutEquipament(Player, 12942, 1);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12311, 1);
                    Self.PutEquipament(Player, 12972, 1);
                    Self.PutEquipament(Player, 13002, 1);
                    Self.PutEquipament(Player, 13032, 1);
                    Self.PutEquipament(Player, 13062, 1);
                  end;
              end;
            end;



             1178: //Conquistador +15
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12076, 250);
                    Self.PutEquipament(Player, 12382, 250);
                    Self.PutEquipament(Player, 12412, 250);
                    Self.PutEquipament(Player, 12442, 250);
                    Self.PutEquipament(Player, 12472, 250);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12111, 250);
                    Self.PutEquipament(Player, 12352, 250);
                    Self.PutEquipament(Player, 12502, 250);
                    Self.PutEquipament(Player, 12532, 250);
                    Self.PutEquipament(Player, 12562, 250);
                    Self.PutEquipament(Player, 12592, 250);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12216, 250);
                    Self.PutEquipament(Player, 12622, 250);
                    Self.PutEquipament(Player, 12652, 250);
                    Self.PutEquipament(Player, 12682, 250);
                    Self.PutEquipament(Player, 12712, 250);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12251, 250);
                    Self.PutEquipament(Player, 12742, 250);
                    Self.PutEquipament(Player, 12772, 250);
                    Self.PutEquipament(Player, 12802, 250);
                    Self.PutEquipament(Player, 12832, 250);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12286, 250);
                    Self.PutEquipament(Player, 12862, 250);
                    Self.PutEquipament(Player, 12892, 250);
                    Self.PutEquipament(Player, 12922, 250);
                    Self.PutEquipament(Player, 12952, 250);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12321, 250);
                    Self.PutEquipament(Player, 12982, 250);
                    Self.PutEquipament(Player, 13012, 250);
                    Self.PutEquipament(Player, 13042, 250);
                    Self.PutEquipament(Player, 13072, 250);
                  end;
              end;
            end;

             1177: //Conquistador +12
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:   //wr
                  begin
                    Self.PutEquipament(Player, 12076, 198);
                    Self.PutEquipament(Player, 12382, 198);
                    Self.PutEquipament(Player, 12412, 198);
                    Self.PutEquipament(Player, 12442, 198);
                    Self.PutEquipament(Player, 12472, 198);
                  end;

                1:   // tp
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12111, 198);
                    Self.PutEquipament(Player, 12352, 198);
                    Self.PutEquipament(Player, 12502, 198);
                    Self.PutEquipament(Player, 12532, 198);
                    Self.PutEquipament(Player, 12562, 198);
                    Self.PutEquipament(Player, 12592, 198);
                  end;

                2:     // att
                  begin
                    Self.PutEquipament(Player, 12216, 198);
                    Self.PutEquipament(Player, 12622, 198);
                    Self.PutEquipament(Player, 12652, 198);
                    Self.PutEquipament(Player, 12682, 198);
                    Self.PutEquipament(Player, 12712, 198);
                  end;

                3:     // dual
                  begin
                    Self.PutEquipament(Player, 12251, 198);
                    Self.PutEquipament(Player, 12742, 198);
                    Self.PutEquipament(Player, 12772, 198);
                    Self.PutEquipament(Player, 12802, 198);
                    Self.PutEquipament(Player, 12832, 198);
                  end;

                4:    // fc
                  begin
                    Self.PutEquipament(Player, 12286, 198);
                    Self.PutEquipament(Player, 12862, 198);
                    Self.PutEquipament(Player, 12892, 198);
                    Self.PutEquipament(Player, 12922, 198);
                    Self.PutEquipament(Player, 12952, 198);
                  end;

                5:   // santa
                  begin
                    Self.PutEquipament(Player, 12321, 198);
                    Self.PutEquipament(Player, 12982, 198);
                    Self.PutEquipament(Player, 13012, 198);
                    Self.PutEquipament(Player, 13042, 198);
                    Self.PutEquipament(Player, 13072, 198);
                  end;
              end;
            end;

{$ENDREGION}
{$REGION 'Caixa de Presente para Novatos'}
          1:
            begin
              case Player.Base.GetMobClass of
                0: // set war
                  begin
                    if Self.GetInvAvailableSlots(Player) < 5 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6727, 1);

                    Self.PutEquipament(Player, 6997, 1);
                    Self.PutEquipament(Player, 7027, 1);
                    Self.PutEquipament(Player, 7057, 1);
                    Self.PutEquipament(Player, 7087, 1);
                  end;

                1: // set tp
                  begin
                    if Self.GetInvAvailableSlots(Player) < 6 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6692, 1);
                    Self.PutEquipament(Player, 1304, 1);

                    Self.PutEquipament(Player, 7117, 1);
                    Self.PutEquipament(Player, 7147, 1);
                    Self.PutEquipament(Player, 7177, 1);
                    Self.PutEquipament(Player, 7207, 1);
                  end;

                2: // set att
                  begin
                    if Self.GetInvAvailableSlots(Player) < 5 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6867, 112);

                    Self.PutEquipament(Player, 7237, 112);
                    Self.PutEquipament(Player, 7267, 112);
                    Self.PutEquipament(Player, 7297, 112);
                    Self.PutEquipament(Player, 7327, 112);
                  end;

                3: // set dual
                  begin
                    if Self.GetInvAvailableSlots(Player) < 5 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6832, 112);

                    Self.PutEquipament(Player, 7357, 112);
                    Self.PutEquipament(Player, 7387, 112);
                    Self.PutEquipament(Player, 7417, 112);
                    Self.PutEquipament(Player, 7447, 112);
                  end;

                4: // set fc
                  begin
                    if Self.GetInvAvailableSlots(Player) < 5 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6937, 112);

                    Self.PutEquipament(Player, 7477, 112);
                    Self.PutEquipament(Player, 7507, 112);
                    Self.PutEquipament(Player, 7537, 112);
                    Self.PutEquipament(Player, 7567, 112);
                  end;

                5: // set cl
                  begin
                    if Self.GetInvAvailableSlots(Player) < 5 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6902, 112);

                    Self.PutEquipament(Player, 7597, 112);
                    Self.PutEquipament(Player, 7627, 112);
                    Self.PutEquipament(Player, 7657, 112);
                    Self.PutEquipament(Player, 7687, 112);
                  end;
              end;
            end;

{$ENDREGION}
{$REGION 'Caixa de batalha do comandante'}
          357: // caixa do T diário 10467
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 4520, 5);
              Self.PutItem(Player, 4521, 5);
              Self.PutItem(Player, 8200, 5);
              Self.PutItem(Player, 4358, 10);
              Self.PutItem(Player, 4398, 10);
            end;
{$ENDREGION}
{$REGION 'Baús da Jornada Elter'}
{$REGION 'Baú da Jornada Elter [Início]'}
          666:
            begin
              if Self.GetInvAvailableSlots(Player) < 3 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Self.PutItem(Player, 8025);
              Self.PutItem(Player, 1611);
              Self.PutItem(Player, 10045);

              Player.AddCash(50000);        // 50K de cash
              Player.SendCashInventory;

            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv10]'}
          667:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 8027, 1);
              Self.PutItem(Player, 1612, 1);
              Self.PutItem(Player, 4514, 50);
              Self.PutItem(Player, 8189, 50);
              Self.PutItem(Player, 4438, 1);
              Self.PutItem(Player, 10046, 1);
              Self.PutItem(Player, 11528, 1);
              self.PutItem(Player, 8250,1); // Ax Poderoso

            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv20]'}
          668:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 13528, 1);
              Self.PutItem(Player, 1614, 1);
              Self.PutItem(Player, 4514, 50);
              Self.PutItem(Player, 8189, 50);
              Self.PutItem(Player, 10047, 1);
            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv30]'}
          669:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //Self.PutItem(Player, 7930, 1);
              Self.PutItem(Player, 1613, 1);
              Self.PutItem(Player, 4514, 50);
             // Self.PutItem(Player, 8212, 20);
              Self.PutItem(Player, 10048, 1);
            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv40]'}
          670:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //Self.PutItem(Player, 7927, 1);
              Self.PutItem(Player, 4514, 50);
             // Self.PutItem(Player, 8212, 20);
              Self.PutItem(Player, 10049, 1);
            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv50]'}
          671:
            begin
              if Self.GetInvAvailableSlots(Player) < 9 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

             // Self.PutItem(Player, 8199, 100);
             // Self.PutItem(Player, 8253, 100);
             // Self.PutItem(Player, 8185, 4);	//Extrato Hira - D
             // Self.PutItem(Player, 8187, 4);	//Extrato Kaize - D
             // Self.PutItem(Player, 8206, 2);	//Enriquecido Hira - D
             // Self.PutItem(Player, 8209, 2);	//Enriquecido Kaize -D
              Self.PutItem(Player, 4483, 1);
              Self.PutItem(Player, 4487, 1);
            //  Self.PutItem(Player, 11527, 1);
              Self.PutItem(Player, 10051, 1);
              Self.PutItem(Player, 11527, 1);

            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv60]'}
          672:
            begin
              if Self.GetInvAvailableSlots(Player) < 11 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 4480, 1);
              Self.PutItem(Player, 4481, 1);
              Self.PutItem(Player, 8252, 100);
              Self.PutItem(Player, 8254, 100);
              Self.PutItem(Player, 8204, 4);
              Self.PutItem(Player, 8205, 4);
              Self.PutItem(Player, 8208, 2);
              Self.PutItem(Player, 8211, 2);
              Self.PutItem(Player, 4373, 1000);
              Self.PutItem(Player, 4405, 1000);
              Self.PutItem(Player, 10051, 1);

            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv70]'}
          673:
            begin
              if Self.GetInvAvailableSlots(Player) < 11 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 4480, 1);
              Self.PutItem(Player, 4481, 1);
              Self.PutItem(Player, 11528, 1);
              Self.PutItem(Player, 13182, 1);
              Self.PutItem(Player, 13183, 1);
              Self.PutItem(Player, 13184, 1);
              Self.PutItem(Player, 13185, 1);
              Self.PutItem(Player, 14148, 1);
              Self.PutItem(Player, 14149, 1);
              Self.PutItem(Player, 14195, 1);
              Self.PutItem(Player, 5987, 150);






            end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'Líquidos'}
{$REGION 'Extrato de Líquido Facion [3 D] – Selado'}
          295:
            begin
              if Self.GetInvAvailableSlots(Player) < 1 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 8007)
            end;
{$ENDREGION}
{$REGION 'Extrato de Líquido Facion [30 D] – Selado'}
          288:
            begin
              if Self.GetInvAvailableSlots(Player) < 1 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 8009);
            end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'Kit Essência do poder'}
          1600:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 10433);
              Self.PutItem(Player, 4271);
              Self.PutItem(Player, 11451);
              Self.PutItem(Player, 4480);
              Self.PutItem(Player, 4481);
            end;
{$ENDREGION}
{$REGION 'Caixas dos Pioneiros'}
{$REGION 'Caixa do Guerreiro Pioneiro'}
          137:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (2846) + i * 30, $50);
              end;

              Self.PutEquipament(Player, 2561, $50);
            end;
{$ENDREGION}
{$REGION 'Caixa da Templária Pioneira'}
          138:
            begin
              if Self.GetInvAvailableSlots(Player) < 6 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (2966) + i * 30, 5);
              end;

              Self.PutEquipament(Player, 2526, $50);
              Self.PutEquipament(Player, 2816, $50);
            end;
{$ENDREGION}
{$REGION 'Caixa do Atirador Pioneiro'}
          139:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (3086) + i * 30, $50);
              end;

              Self.PutEquipament(Player, 2701, $50);
            end;
{$ENDREGION}
{$REGION 'Caixa da Pistoleira Pioneira'}
          140:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (3206) + i * 30, $50);
              end;

              Self.PutEquipament(Player, 2666, $50);
            end;
{$ENDREGION}
{$REGION 'Caixa do Mago Pioneiro'}
          141:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (3326) + i * 30, $50);
              end;

              Self.PutEquipament(Player, 2771, $50);
            end;
{$ENDREGION}
{$REGION 'Caixa da Clériga Pioneira'}
          142:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (3446) + i * 30, $50);
              end;

              Self.PutEquipament(Player, 2736, $50);
            end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'Conjuntos Avançados'}
{$REGION 'Conjunto Avançado [Guerreiro]'}
          39:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7008) + i * 30);
              end;
            end;
{$ENDREGION}
{$REGION 'Conjunto Avançado [Templária]'}
          41:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7127) + i * 30);
              end;
            end;
{$ENDREGION}
{$REGION 'Conjunto Avançado [Atirador]'}
          42:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7248) + i * 30);
              end;
            end;
{$ENDREGION}
{$REGION 'Conjunto Avançado [Pistoleira]'}
          43:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7368) + i * 30);
              end;
            end;
{$ENDREGION}
{$REGION 'Conjunto Avançado [Feiticeiro Negro]'}
          44:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7488) + i * 30);
              end;
            end;
{$ENDREGION}
{$REGION 'Conjunto Avançado [Clériga]'}
          45:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7608) + i * 30);
              end;
            end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'Cavalos de Fogo'}
{$REGION 'Kit do Cavalo de Fogo(Ataque)'}
          1858:
            begin
              if Self.GetInvAvailableSlots(Player) < 3 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 964);
              Self.PutItem(Player, 8163, 3);
              Self.PutItem(Player, 8164, 3);
            end;
{$ENDREGION}
{$REGION 'Kit do Cavalo de Fogo(Mágico)'}
          1859:
            begin
              if Self.GetInvAvailableSlots(Player) < 3 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 965);
              Self.PutItem(Player, 8163, 3);
              Self.PutItem(Player, 8164, 3);
            end;
{$ENDREGION}
{$REGION 'Kit do Cavalo de Fogo(Defesa)'}
          1860:
            begin
              if Self.GetInvAvailableSlots(Player) < 3 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 963);
              Self.PutItem(Player, 8181, 3);
              Self.PutItem(Player, 8182, 3);
            end;
{$ENDREGION}
{$ENDREGION}
        end;
      end;

{$ENDREGION}
{$REGION 'Baus e caixas com itens aleatorios'}
    ITEM_TYPE_RANDOM_BAU:
      begin
        case ItemList[item.Index].UseEffect of
          1: //caixa do pre teste
            begin
              if (Self.GetInvAvailableSlots(Player) < 1) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //Self.PutItem(Player, 5640, 1); //gold

              //Self.PutItem(Player, 5617, 1); //cash

              //Self.PutItem(Player, 5600, 1); //level

              Self.PutItem(Player, 11678, 1); //caixa set lv 50
             // Self.PutItem(Player, 11680, 1); //caixa acc lv 50
            end;

          629: //caixa do acessório do infrator
            begin
              if (Self.GetInvAvailableSlots(Player) < 4) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutEquipament(Player, 1335, 1);
              Self.PutEquipament(Player, 1363, 1);
              Self.PutEquipament(Player, 1393, 1);
              Self.PutEquipament(Player, 1418, 1);
            end;

{$REGION 'Caixa dourada - obtida no PvP'}
          1030:
            begin
              if(Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Randomize;
              Rand := RandomRange(1, 101);

              case Rand of
                1: //vai dar enriquecido do cap
                  begin
                    case RandomRange(1, 101) of
                      1..20: //C Rico
                        begin
                          case RandomRange(1,4) of
                            1, 2: //Rico C Kaize
                              begin
                                Self.PutItem(Player, 8210, 1);
                              end;

                            3:
                              begin //rico C Hira
                                Self.PutItem(Player, 8207, 1);
                              end;

                          end;
                        end;

                      21..40: //C Normal
                        begin
                          case RandomRange(1,4) of
                            1, 2: //Rico C Kaize
                              begin
                                Self.PutItem(Player, 8188, 1);
                              end;

                            3:
                              begin //rico C Hira
                                Self.PutItem(Player, 8186, 1);
                              end;
                          end;
                        end;

                      41..100:
                        begin
                          Self.PutItem(Player, 5768, 1);
                        end;
                    end;
                  end;

                2..45:
                  begin
                    case RandomRange(1,101) of
                      1..5:
                        begin //pocao defesa 3hrs evento
                          Self.PutItem(Player, 8063, 1);
                        end;

                      6..10:
                        begin //pocao destruicao 3hrs evento
                          Self.PutItem(Player, 8064, 1);
                        end;

                      11..20:
                        begin //sopa status 01
                          Self.PutItem(Player, 4857, 1);
                        end;

                      21..30:
                        begin //sopa status 02
                          Self.PutItem(Player, 4858, 1);
                        end;

                      31..40:
                        begin //sopa status 03
                          Self.PutItem(Player, 4859, 1);
                        end;

                      41..100:
                        begin  //tocha
                          Self.PutItem(Player, 5768, 1);
                        end;
                    end;
                  end;

                46..85, 0: //tocha
                  begin
                    Self.PutItem(Player, 5768, 1);
                  end;

                86, 87: //caixa do tiamat (da a aparencia da academia de batalha)
                  begin
                    Self.PutItem(Player, 15978, 1);
                  end;

                88: // Baú do cristal sagrado
                  begin
                    Self.PutItem(Player, 17031, 1);
                  end;

                89: //cristal azul de montaria  9572
                  begin
                    Self.PutItem(Player, 9572, 1);
                  end;

                91: //presente cristal pran 8270
                  begin
                    Self.PutItem(Player, 8270, 1);
                  end;

                {93: //pacote carrasco +4
                  begin
                    Self.PutItem(Player, 14138, 1);
                  end;}

                94: // Baú do cristal sagrado
                  begin
                    Self.PutItem(Player, 17031, 1);
                    //Self.PutItem(Player, 14141, 1);
                  end;

                {95..100:
                  begin
                    Randomize;
                    case RandomRange(1,101) of
                      0..24: //anel quinto ano
                        begin
                          Self.PutItem(Player, 1335, 1);
                        end;

                      25..49: //brinco quinto ano
                        begin
                          Self.PutItem(Player, 1363, 1);
                        end;

                      50..74: //bracelete quinto ano
                        begin
                          Self.PutItem(Player, 1393, 1);
                        end;

                      75..101:
                        begin //colar quinto ano
                          Self.PutItem(Player, 1418, 1);
                        end;
                    end;
                  end; }
                else //tocha
                  begin
                    Self.PutItem(Player, 5768, 1);
                  end;
              end;
            end;

{$ENDREGION}

{$REGION 'Caixa do Tiamat - Aparencia da Academia de Batalha'}

          1089:
            begin
              if(Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case RandomRange(1, 4) of
                1: //vermelha mais rara
                  begin
                    case Player.Base.GetMobClass of
                      0: //war
                        begin
                          Self.PutEquipament(Player, 12074);

                          Self.PutEquipament(Player, 12380);
                          Self.PutEquipament(Player, 12410);
                          Self.PutEquipament(Player, 12440);
                          Self.PutEquipament(Player, 12470);
                        end;

                      1: //tp
                        begin
                          if(Self.GetInvAvailableSlots(Player) < 6) then
                          begin
                            Player.SendClientMessage('Inventário cheio.');
                            Exit;
                          end;

                          Self.PutEquipament(Player, 12350);

                          Self.PutEquipament(Player, 12109);

                          Self.PutEquipament(Player, 12500);
                          Self.PutEquipament(Player, 12530);
                          Self.PutEquipament(Player, 12560);
                          Self.PutEquipament(Player, 12590);
                        end;

                      2: //att
                        begin
                          Self.PutEquipament(Player, 12214);

                          Self.PutEquipament(Player, 12620);
                          Self.PutEquipament(Player, 12650);
                          Self.PutEquipament(Player, 12680);
                          Self.PutEquipament(Player, 12710);
                        end;

                      3: //dual
                        begin
                          Self.PutEquipament(Player, 12249);

                          Self.PutEquipament(Player, 12740);
                          Self.PutEquipament(Player, 12770);
                          Self.PutEquipament(Player, 12800);
                          Self.PutEquipament(Player, 12830);
                        end;

                      4: //fc
                        begin
                          Self.PutEquipament(Player, 12284);

                          Self.PutEquipament(Player, 12860);
                          Self.PutEquipament(Player, 12890);
                          Self.PutEquipament(Player, 12920);
                          Self.PutEquipament(Player, 12950);
                        end;

                      5: //cl
                        begin
                          Self.PutEquipament(Player, 12319);

                          Self.PutEquipament(Player, 12980);
                          Self.PutEquipament(Player, 13010);
                          Self.PutEquipament(Player, 13040);
                          Self.PutEquipament(Player, 13070);
                        end;
                    end;
                  end;

                2, 3: //azul mais comum
                  begin
                    case Player.Base.GetMobClass of
                      0: //war
                        begin
                          Self.PutEquipament(Player, 12075);

                          Self.PutEquipament(Player, 12381);
                          Self.PutEquipament(Player, 12411);
                          Self.PutEquipament(Player, 12441);
                          Self.PutEquipament(Player, 12471);
                        end;

                      1: //tp
                        begin
                          if(Self.GetInvAvailableSlots(Player) < 6) then
                          begin
                            Player.SendClientMessage('Inventário cheio.');
                            Exit;
                          end;

                          Self.PutEquipament(Player, 12351);

                          Self.PutEquipament(Player, 12110);

                          Self.PutEquipament(Player, 12501);
                          Self.PutEquipament(Player, 12531);
                          Self.PutEquipament(Player, 12561);
                          Self.PutEquipament(Player, 12591);
                        end;

                      2: //att
                        begin
                          Self.PutEquipament(Player, 12215);

                          Self.PutEquipament(Player, 12621);
                          Self.PutEquipament(Player, 12651);
                          Self.PutEquipament(Player, 12681);
                          Self.PutEquipament(Player, 12711);
                        end;

                      3: //dual
                        begin
                          Self.PutEquipament(Player, 12250);

                          Self.PutEquipament(Player, 12741);
                          Self.PutEquipament(Player, 12771);
                          Self.PutEquipament(Player, 12801);
                          Self.PutEquipament(Player, 12831);
                        end;

                      4: //fc
                        begin
                          Self.PutEquipament(Player, 12285);

                          Self.PutEquipament(Player, 12861);
                          Self.PutEquipament(Player, 12891);
                          Self.PutEquipament(Player, 12921);
                          Self.PutEquipament(Player, 12951);
                        end;

                      5: //cl
                        begin
                          Self.PutEquipament(Player, 12320);

                          Self.PutEquipament(Player, 12981);
                          Self.PutEquipament(Player, 13011);
                          Self.PutEquipament(Player, 13041);
                          Self.PutEquipament(Player, 13071);
                        end;
                    end;
                  end;
              end;
            end;

{$ENDREGION}
{$REGION 'Caixa Cristal de montaria'}
          98:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem([4220, 4221, 4222, 4223, 4224,
                4225, 4226, 4227, 4228, 4229, 4230, 4231, 4234, 4235, 4240,
                4241], [20, 20, 20, 20, 20, 20, 15, 15, 15, 5, 25, 25, 3,
                5, 5, 5]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;

{$ENDREGION}
{$REGION 'Caixa cristais de roupa pran'}
          910:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem([9451, 9452, 9453, 9454, 9455, 9456, 9457,
                9458, 9459, 9460, 9461, 9462, 9463, 9464, 9465],
                [5, 5, 2, 2, 2, 25, 25, 25, 25, 25, 15, 15, 5, 5, 30]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;

{$ENDREGION}
{$REGION 'Bau do cristal sagrado'}
          1130, 950:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              {RandomTax := Self.SelectRamdomItem([15748, 15749, 15750, 15751,
                15752, 15753, 15755, 15756, 15758, 15759, 15760, 15761, 15701,
                15702, 15703, 15704, 15705, 15706, 15707, 15708, 15709, 15710,
                15713, 15714, 15715, 15731, 15732, 15733, 15734, 15735, 15738,
                15739, 15740, 15780, 15781, 15788], [10, 5, 5, 5, 10, 10, 5, 5,
                15, 15, 10, 20, 15, 5, 5, 5, 2, 3, 20, 20, 25, 25, 10, 10, 20,
                5, 25, 25, 25, 25, 25, 2, 5, 5, 2, 2]);  }

              RandomTax := Self.SelectRamdomItem([5329, 5332, 5335, 5338,
                5341, 5344, 5348, 5492, 5495, 5350, 5353, 5356, 5359,
                5362, 5365, 5368, 5371, 5374, 5497, 5396, 5398, 5402,
                5405, 5408, 5411, 5413, 5416, 5419, 5422, 5425, 5446,
                5449, 5499, 5500, 5490, 5498], [25, 25, 25, 15, 15, 5, 15, 15,
                15, 15, 5, 20, 15, 15, 15, 15, 5, 5, 20, 20, 25, 25, 5, 5, 20,
                15, 25, 25, 25, 25, 25, 5, 5, 5, 5, 5]);


              {RandomTax := Self.SelectRamdomItem([5329, 5332, 5335, 5338,
                5341, 5344, 5348, 5492, 5495, 5350, 5353, 5356, 5359,
                5362, 5365, 5368, 5371, 5374, 5497, 5396, 5398, 5402,
                5405, 5408, 5411, 5413, 5416, 5419, 5422, 5425, 5446,
                5449, 5499, 5500, 5490, 5498], [25, 25, 25, 15, 15, 10, 15, 15,
                15, 15, 10, 20, 15, 15, 15, 15, 12, 13, 20, 20, 25, 25, 10, 10, 20,
                15, 25, 25, 25, 25, 25, 12, 15, 15, 12, 5]);   }

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;

{$ENDREGION}
//{$REGION 'Closed Beta'}
          10766:
            begin
              Player.AddTitle(78, 1);
            end;
//{$ENDREGION}
//{$REGION 'Closed Beta'}
          10767:
            begin
              Player.AddTitle(94, 1);
            end;

          10768:
            begin
              Player.AddTitle(95, 1);
            end;

{$REGION 'Baú Perdido do Cristal Sagrado [Pran]'}


          16004:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem(
                [8270, 11454, 8262, 4359, 4379, 8063, 8064], [2, 4, 8, 16, 16, 48, 48]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;
{$ENDREGION}
{$REGION 'Baú Perdido do Cristal Sagrado [Montaria]'}
          16003:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem(
              [9572, 4274, 8262, 4359, 4379, 8063, 8064], [2, 4, 8, 16, 16, 48, 48]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;
{$ENDREGION}
{$REGION 'Baú Perdido do Cristal Sagrado [Arma]'}
          16000:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem(
                [9572, 8151, 8159, 8262, 4359, 4379, 8063, 8064], [2, 2, 4, 8, 16, 16, 48, 48]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              if(RandomTax = 9572) then
              begin
                RandomTax := Self.SelectRamdomItem(
                [5349, 5335, 5338, 5341, 5329, 5332, 5344], [5,5,5,5, 15, 15, 20]);
              end;

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;
{$ENDREGION}
{$REGION 'Baú Perdido do Cristal Sagrado [Armadura]'}
          16001:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem(
                [9572, 8169, 8177, 8262, 4359, 4379, 8063, 8064], [4, 2, 4, 8, 16, 16, 48, 48]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              if(RandomTax = 9572) then
              begin
                RandomTax := Self.SelectRamdomItem(
                [5369, 5365, 5362, 5359, 5353, 5350, 5356, 5371, 5374], [4,2,4,4, 15, 15, 20, 25, 25]);
              end;

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;
{$ENDREGION}
{$REGION 'Baú Perdido do Cristal Sagrado [Acessório]'}
          16002:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem(
                [9572, 6502, 6503, 6504, 6505, 8262, 4359, 4379, 8063, 8064], [2, 1, 1, 1, 1, 8, 16, 16, 48, 48]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              if(RandomTax = 9572) then
              begin
                RandomTax := Self.SelectRamdomItem(
                [5404, 5402, 5395, 5411, 5413, 5416, 5419, 5422, 5425], [4,2,1,2,2, 15, 15, 15, 15, 15]);
              end;

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;
{$ENDREGION}

{$REGION 'Baú wars especial boss mapa [aleatorio]'}
          5521:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem(
                [5513, 5514, 5515, 5516, 5517, 5518, 5519, 5520, 5522], [2, 1, 1, 1, 1, 8, 16, 16, 48, 48]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              {if(RandomTax = 9572) then
              begin
                RandomTax := Self.SelectRamdomItem(
                [5513, 5514, 5515, 5516, 5517, 5518, 5519, 5520], [4,2,1,2,2, 15, 15, 15, 15, 15]);
              end; }

              {if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;}

              Self.PutItem(Player, RandomTax);
            end;
{$ENDREGION}


{$REGION 'Festival da Ultima Jornada'}
          16020:
            begin
              if (Self.GetInvAvailableSlots(Player) < 2) then
              begin
                Player.SendClientMessage('Inventário cheio. 2 Espaços necessários.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem([1, 2], [8, 98]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              case RandomTax of
                1:
                  begin
                    case RandomRange(1, 41) of
                      1..20: //C Rico
                        begin
                          case RandomRange(1,4) of
                            1, 2: //Rico C Kaize
                              begin
                                Self.PutItem(Player, 8210, 1);
                              end;

                            3:
                              begin //rico C Hira
                                Self.PutItem(Player, 8207, 1);
                              end;

                          end;
                        end;

                      21..40: //C Normal
                        begin
                          case RandomRange(1,4) of
                            1,2: //Rico C Kaize
                              begin
                                Self.PutItem(Player, 8188, 1);
                              end;

                            3:
                              begin //rico C Hira
                                Self.PutItem(Player, 8186, 1);
                              end;
                          end;
                        end;
                    end;
                  end;
                2:
                  begin
                    case RandomRange(1,105) of
                      1..10:
                        begin //comida pran 01
                          Self.PutItem(Player, 8105, 1);
                        end;
                      11..20:
                        begin //comida pran 02
                          Self.PutItem(Player, 8106, 1);
                        end;
                      21..30:
                        begin //comida pran 03
                          Self.PutItem(Player, 8107, 1);
                        end;
                      31..40:
                        begin //comida pran 04
                          Self.PutItem(Player, 8108, 1);
                        end;
                      41..50:
                        begin //comida pran 05
                          Self.PutItem(Player, 8109, 1);
                        end;
                      51..60:
                        begin //comida pran 06
                          Self.PutItem(Player, 8110, 1);
                        end;
                      61..70:
                        begin //perga do portal
                          Self.PutItem(Player, 8111, 2);
                        end;
                      71..80:
                        begin //reparador D
                          Self.PutItem(Player, 8114, 1);
                          Self.PutItem(Player, 8124, 4);
                        end;
                      81..90:
                        begin //reparador C
                          Self.PutItem(Player, 8115, 1);
                          Self.PutItem(Player, 8125, 4);
                        end;
                      91,92:
                        begin //vaizan brilhante normal
                          Self.PutItem(Player, 8132, 1);
                        end;
                      93,94:
                        begin //vaizan brilhante Superior
                          Self.PutItem(Player, 8133, 1);
                        end;
                      95,96:
                        begin //vaizan brilhante Raro
                          Self.PutItem(Player, 8134, 1);
                        end;
                      97,98:
                        begin //pedra mágica da restauração
                          Self.PutItem(Player, 8137, 1);
                        end;
                      99,104:

                        begin  //double exp
                          Self.PutItem(Player, 4519, 1);
                        end;
                    end;
                  end;
              end;

            end;
{$ENDREGION}
        end;
      end;

{$ENDREGION}
{$REGION 'Poção de HP/MP'}
    ITEM_TYPE_HP_POTION:
      begin
        Inc(Player.Character.Base.CurrentScore.CurHP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
      end;

    ITEM_TYPE_HPMP_LAGRIMAS:
      begin
        Inc(Player.Character.Base.CurrentScore.CurHP,
          ItemList[item.Index].UseEffect);
        Inc(Player.Character.Base.CurrentScore.CurMP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
      end;
{$ENDREGION}
{$REGION 'Poção de HP'}
    ITEM_TYPE_HPMP_POTION:
      begin
        Inc(Player.Character.Base.CurrentScore.CurHP,
          ItemList[item.Index].UseEffect);
        Inc(Player.Character.Base.CurrentScore.CurMP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
      end;

{$ENDREGION}
{$REGION 'Poção de MP'}
    ITEM_TYPE_MP_POTION:
      begin
        Inc(Player.Character.Base.CurrentScore.CurMP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
      end;

{$ENDREGION}
{$REGION 'Símbolo do Viajante'}
    ITEM_TYPE_BAG_INV:
      begin
        Self.SetItemDuration(item^);

        Move(item^, Player.Character.Base.Inventory[63], sizeof(TItem));
        Player.Base.SendRefreshItemSlot(INV_TYPE, 63, item^, False);
        Player.SendClientMessage('Selo de [' +
          AnsiString(ItemList[item.Index].Name) + '] foi removido.');
        ZeroMemory(item, sizeof(TItem));
      end;

{$ENDREGION}
{$REGION 'Símbolo da Determinação'}
    ITEM_TYPE_BAG_STORAGE:
      begin

        BagSlot := 0;

        for i := 1 to 3 do
        begin
          if (Player.Account.Header.Storage.Itens[80 + i].Index = 0) then
          begin
            BagSlot := 80 + i;
          end;
        end;

        if (BagSlot = 0) then
        begin
          Player.SendClientMessage('Limite de expansão atingido.');
          Exit;
        end;

        Self.SetItemDuration(item^);

        Move(item^, Player.Account.Header.Storage.Itens[BagSlot],
          sizeof(TItem));
        Player.Base.SendRefreshItemSlot(INV_TYPE, BagSlot, item^, False);
        Player.SendClientMessage('Selo de [' +
          AnsiString(ItemList[item.Index].Name) + '] foi removido.');
        ZeroMemory(item, sizeof(TItem));
      end;

{$ENDREGION}
{$REGION 'Simbolo do Testamento (Bolsa Pran)'}
     ITEM_TYPE_BAG_PRAN:
      begin
        case Player.SpawnedPran of
          0:
            begin
              if(Player.Account.Header.Pran1.Inventory[41].Index <> 0) then
              begin
                Player.SendClientMessage('Você já possui duas bolsas nessa pran.');
                Exit;
              end;

              BagSlot := 41;

              Self.SetItemDuration(item^);

              Move(item^, Player.Account.Header.Pran1.Inventory[BagSlot],
                sizeof(TItem));
              //Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Player.Base.SendRefreshItemSlot(PRAN_INV_TYPE, BagSlot,
                Player.Account.Header.Pran1.Inventory[BagSlot], False);

              Player.SendClientMessage('Selo de [' +
                AnsiString(ItemList[item.Index].Name) + '] foi removido.');
              ZeroMemory(item, sizeof(TItem));
            end;

          1:
            begin
              if(Player.Account.Header.Pran2.Inventory[41].Index <> 0) then
              begin
                Player.SendClientMessage('Você já possui duas bolsas nessa pran.');
                Exit;
              end;

              BagSlot := 41;

              Self.SetItemDuration(item^);

              Move(item^, Player.Account.Header.Pran2.Inventory[BagSlot],
                sizeof(TItem));
              //Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Player.Base.SendRefreshItemSlot(PRAN_INV_TYPE, BagSlot,
                Player.Account.Header.Pran2.Inventory[BagSlot], False);

              Player.SendClientMessage('Selo de [' +
                AnsiString(ItemList[item.Index].Name) + '] foi removido.');
              ZeroMemory(item, sizeof(TItem));
            end;

        else
          Exit;
        end;
      end;
{$ENDREGION}

{$REGION 'Símbolo da Confiança'}
    ITEM_TYPE_STORAGE_OPEN:
      begin
        Player.OpennedOption := 7;
        Player.OpennedNPC := Player.Base.ClientID;
        Player.SendStorage(STORAGE_TYPE_PLAYER);
      end;
{$ENDREGION}
{$REGION 'Símbolo do vendedor'}
    ITEM_TYPE_SHOP_OPEN:
      begin
        Player.OpennedOption := 5;
        Player.OpennedNPC := 2070;
        TNPChandlers.ShowShop(Player, Servers[Player.ChannelIndex].NPCS[2070]);
      end;
{$ENDREGION}
{$REGION 'Poções que dão buff'}
    ITEM_TYPE_POTION_BUFF:

      begin
        if(Copy(String(ItemList[Item.Index].Name), 0, 4) = 'Sopa') then
        begin
          if not(Player.Base.BuffExistsSopa) then
          begin
            Player.Base.AddBuff(ItemList[item.Index].UseEffect);
            Self.DecreaseAmount(item, Decrease);
            Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
            Result := True;
            Exit;
          end
          else
          begin
            Player.SendClientMessage('Não é combinável com [' +
              AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
            Exit;
          end;
        end;

        if(SkillData[ItemList[Item.Index].UseEffect].Index = 251) then
        begin
          if(Player.Base.BuffExistsByIndex(251)) then
          begin
            Player.SendClientMessage('Não é combinável com [' +
              AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
            Exit;
          end;
        end;

        case SkillData[ItemList[Item.Index].UseEffect].Index of
          298:
            begin
              if(Player.Base.BuffExistsByIndex(176)) then
                Exit;
            end;
          493: //poção valor de batalha
          begin
            if(Player.Base.BuffExistsInArray([494, 495, 496, 497])) then
            begin
              Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
              Exit;
            end;
          end;

          494: //poção valor de batalha
          begin
            if(Player.Base.BuffExistsInArray([493, 495, 496, 497])) then
            begin
              Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
              Exit;
            end;
          end;

          495: //poção valor de batalha
          begin
            if(Player.Base.BuffExistsInArray([494, 493, 496, 497])) then
            begin
              Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
              Exit;
            end;
          end;

          496: //poção valor de batalha
          begin
            if(Player.Base.BuffExistsInArray([494, 495, 493, 497])) then
            begin
              Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
              Exit;
            end;
          end;

          497: //poção valor de batalha
          begin //poção de batalha pvp
            if(Player.Base.BuffExistsInArray([494, 495, 496, 493])) then
            begin
              Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
              Exit;
            end;
          end;

        end;

        Player.Base.AddBuff(ItemList[item.Index].UseEffect);

        end;


{$ENDREGION}
{$REGION 'Itens que dão Exp'}
    {ITEM_TYPE_ADD_EXP_PERC:
      begin
        Player.AddExpPerc(ItemList[item.Index].UseEffect);
      end;

    ITEM_TYPE_USE_TO_UP_LVL:
      begin
        case ItemList[item.Index].UseEffect of
          1:
          begin
            Level := ItemList[item.Index].UseEffect * 50;

            try
              LevelExp := ExpList[Player.Character.Base.Level + (Level - 1)] + 1;
            except
              LevelExp := High(ExpList);
            end;

            AddExp := LevelExp - UInt64(Player.Character.Base.Exp);

            Player.AddExp(AddExp);
            Player.Base.SendRefreshLevel;
          end;

        else
          begin
            Player.AddLevel(ItemList[item.Index].UseEffect);
          end;
        end;
      end;  }
{$ENDREGION}
{$REGION 'Pergaminho do portal'}
    ITEM_TYPE_SCROLL_PORTAL:
      begin
        if(Player.Base.InClastleVerus) then
        begin
          Player.SendClientMessage('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;

        try
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);

          if(ReliqSlot <> 255) then
          begin
            Player.SendClientMessage('Impossível usar com relíquia.');
            Exit;
          end;

          if (Player.Base.Character.Nation > 0) then
          begin
            if (Player.Base.Character.Nation <> Servers[Player.ChannelIndex]
              .NationID) then
            begin
              Player.SendClientMessage
                ('Impossível usar este item no canal desejado.');
              Exit;
            end;
          end;

          PosX := TPosition.Create(ScrollTeleportPosition[Type1]
            .PosX, ScrollTeleportPosition[Type1].PosY);

          if(PosX.IsValid) then
            Player.Teleport(PosX)
          else
          begin
            PosX := TPosition.Create(3450, 690);
            Player.Teleport(PosX);
          end;

        except
          on E: Exception do
          begin
            Player.Teleport(Player.Base.PlayerCharacter.LastPos);
            Logger.Write('erro ao se teleportar. ' + E.Message, TlogType.Error);
            Exit;
          end;

        end;
      end;

{$ENDREGION}
{$REGION 'Pergaminho:Regenchain'}
    ITEM_TYPE_CITY_SCROLL:
      begin
        if(Player.Base.InClastleVerus) then
        begin
          Player.SendClientMessage('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;

        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);

        if(ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Impossível usar com relíquia.');
          Exit;
        end;

        if (Player.Base.Character.Nation > 0) then
        begin
          if (Player.Base.Character.Nation <> Servers[Player.ChannelIndex]
            .NationID) then
          begin
            Player.SendClientMessage
              ('Impossível usar este item no canal desejado.');
            Exit;
          end;
        end;

        Player.SendPlayerToCityPosition();
      end;
{$ENDREGION}
{$REGION 'Pergaminho:CidadeSalva'}
    ITEM_TYPE_LOC_SCROLL:
      begin
        if(Player.Base.InClastleVerus) then
        begin
          Player.SendClientMessage('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;

        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);

        if(ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Impossível usar com relíquia.');
          Exit;
        end;

        if (Player.Base.Character.Nation > 0) then
        begin
          if (Player.Base.Character.Nation <> Servers[Player.ChannelIndex]
            .NationID) then
          begin
            Player.SendClientMessage
              ('Impossível usar este item no canal desejado.');
            Exit;
          end;
        end;

        Player.SendPlayerToSavedPosition();
      end;
{$ENDREGION}
{$REGION 'Símbolo de cidadania'}
    ITEM_TYPE_SET_ACCOUNT_NATION:
      begin
        case ItemList[item.Index].UseEffect of
          99:
            begin
              if Player.Account.Header.Nation > TCitizenship.None then
                Exit;

              Player.Character.Base.Nation := ServerList[Player.ChannelIndex]
                .NationIndex;
              Player.Account.Header.Nation :=
                TCitizenship(ServerList[Player.ChannelIndex].NationIndex);
              Player.RefreshPlayerInfos;
              Player.AddTitle(18, 1);
              //Player.SocketClosed := True;
            end;
        end;
      end;
{$ENDREGION}
{$REGION 'Comida de pran'}
    ITEM_TYPE_PRAN_FOOD:
      begin
        if (Player.SpawnedPran = 0) then
        begin
          if (Player.Account.Header.Pran1.Food >= 121) then
          begin
            Player.Account.Header.Pran1.Food := 121;
            Player.SendClientMessage('Sua pran não consegue comer mais.');
            Exit;
          end;

          case item.Index of // setar a personalidade
            8105: // sopa de batata doce (cute)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Cute, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;

            8106: // perfait de cereja (sexy)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Sexy, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;

            8107: // salada de caviar (smart)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Smart, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;

            8108: // espetinho de camarao (energetic)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Energetic, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;

            8109: // churrasco de york (tough)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Tough, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;

            8110: // peixe duvidoso assado (corrupt)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Corrupt, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
              end;
          end;

          case Item.Index of
            8105..8110:
              begin
                if not(Player.Account.Header.Pran1.Devotion >= 226) then
                  Player.Account.Header.Pran1.Devotion :=
                    Player.Account.Header.Pran1.Devotion + 1;
              end;
          end;

          if (Player.Account.Header.Pran1.MovedToCentral = True) then
            Player.Account.Header.Pran1.MovedToCentral := False;

          if ((Player.Account.Header.Pran1.Food + 15) > 121) then
            Player.Account.Header.Pran1.Food := 121
          else
            Inc(Player.Account.Header.Pran1.Food, 15);

          Player.SendPranToWorld(0);
        end
        else
        if (Player.SpawnedPran = 1) then
        begin
          if (Player.Account.Header.Pran2.Food >= 121) then
          begin
            Player.Account.Header.Pran2.Food := 121;
            Player.SendClientMessage('Sua pran não consegue comer mais.');
            Exit;
          end;

          case item.Index of // setar a personalidade
            8105: // sopa de batata doce (cute)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Cute, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;

            8106: // perfait de cereja (sexy)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Sexy, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;

            8107: // salada de caviar (smart)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Smart, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;

            8108: // espetinho de camarao (energetic)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Energetic, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;

            8109: // churrasco de york (tough)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Tough, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;

            8110: // peixe duvidoso assado (corrupt)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Corrupt, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
              end;
          end;

          if (Player.Account.Header.Pran2.MovedToCentral = True) then
            Player.Account.Header.Pran2.MovedToCentral := False;

          case Item.Index of
            8105..8110:
              begin
                if not(Player.Account.Header.Pran2.Devotion >= 226) then
                  Player.Account.Header.Pran2.Devotion :=
                    Player.Account.Header.Pran2.Devotion + 1;
              end;
          end;

          if ((Player.Account.Header.Pran2.Food + 15) > 121) then
            Player.Account.Header.Pran2.Food := 121
          else
            Inc(Player.Account.Header.Pran2.Food, 15);

          Player.SendPranToWorld(1);
        end
        else
          Exit;

      end;

    ITEM_TYPE_PRAN_DIGEST:
      begin //Digestivo da pran
        if (Player.Account.Header.Pran1.IsSpawned) then
        begin
          if(Player.Account.Header.Pran1.Food <= 13) then
          begin
            Player.SendClientMessage('Sua pran está com muita fome para usar o Digestivo.');
            Exit;
          end;

          Player.Account.Header.Pran1.Food := Player.Account.Header.Pran1.Food div 2;

          Player.SendPranToWorld(0);
        end
        else
        if (Player.Account.Header.Pran2.IsSpawned) then
        begin
          if(Player.Account.Header.Pran2.Food <= 13) then
          begin
            Player.SendClientMessage('Sua pran está com muita fome para usar o Digestivo.');
            Exit;
          end;

          Player.Account.Header.Pran2.Food := Player.Account.Header.Pran2.Food div 2;

          Player.SendPranToWorld(1);
        end;
      end;

{$ENDREGION}
{$REGION 'Receitas'}
    ITEM_TYPE_RECIPE:
      begin
        RecipeIndex := Self.GetIDRecipeArray(item.Index);

        if (RecipeIndex = 3000) then
        begin
          Player.SendClientMessage('A receita não existe no banco de dados.');
          Exit;
        end;

        if (Recipes[RecipeIndex].LevelMin > Player.Base.Character.Level) then
        begin
          Player.SendClientMessage('Level mínimo da receita é ' +
            AnsiString(Recipes[RecipeIndex].LevelMin.ToString) + '.');
          Exit;
        end;

        ItemExists := True;
        HaveAmount := True;

        for i := 0 to 11 do
        begin
          if (Recipes[RecipeIndex].ItemIDRequired[i] = 0) then
            Continue;

          if(Recipes[RecipeIndex].ItemIDRequired[i] = 4202) then
            Recipes[RecipeIndex].ItemIDRequired[i] := 4204;

          if not(Self.GetItemSlotAndAmountByIndex(Player,
            Recipes[RecipeIndex].ItemIDRequired[i], ItemSlot, ItemAmount)) then
          begin
            ItemExists := False;

            Player.SendClientMessage('Você não possui [' +
              AnsiString(ItemList[Recipes[RecipeIndex].ItemIDRequired[i]]
              .Name) + '].');
            Break;
          end
          else
          begin
            if (ItemAmount < Recipes[RecipeIndex].ItemRequiredAmount[i]) then
            begin
              HaveAmount := False;

              Player.SendClientMessage('Você precisa de ' +
                AnsiString(Recipes[RecipeIndex].ItemRequiredAmount[i].ToString)
                + ' do item [' +
                AnsiString(ItemList[Recipes[RecipeIndex].ItemIDRequired[i]]
                .Name) + ']. Separe a quantidade correta em apenas UM slot.');
              Break;
            end;
          end;
        end;

        if (not(ItemExists) or not(HaveAmount)) then
        begin
          Exit;
        end;

        EmptySlot := GetEmptySlot(Player);

        if (EmptySlot = 255) then
        begin
          Player.SendClientMessage('Seu inventário está cheio.');
          Exit;
        end;

        Randomize;
        RandomTax := RandomRange(1, (Recipes[RecipeIndex].SuccessTax div 10)+1);

        if (RandomTax <= (Recipes[RecipeIndex].SuccessTax div 10)) then
        begin // success
          Player.SendClientMessage('Receita bem sucedida.');

          Self.PutItem(Player, Recipes[RecipeIndex].Reward,
            Recipes[RecipeIndex].RewardAmount);

          for i := 0 to 11 do
          begin
            if (Recipes[RecipeIndex].ItemIDRequired[i] = 0) then
              Continue;

            if(Recipes[RecipeIndex].ItemIDRequired[i] = 4202) then
              Recipes[RecipeIndex].ItemIDRequired[i] := 4204;

            if (Self.GetItemSlotAndAmountByIndex(Player,
              Recipes[RecipeIndex].ItemIDRequired[i], ItemSlot, ItemAmount))
            then
            begin
              SecondItem := @Player.Base.Character.Inventory[ItemSlot];
              if((TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex].ItemRequiredAmount[i]) >= 2) and
                (TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex].ItemRequiredAmount[i]) <= 14)) then
              begin
                TItemFunctions.RemoveItem(Player, INV_TYPE, ItemSlot);
              end
              else
              begin
                Self.DecreaseAmount(SecondItem,
                  Recipes[RecipeIndex].ItemRequiredAmount[i]);
                Player.Base.SendRefreshItemSlot(INV_TYPE, ItemSlot,
                  SecondItem^, False);
              end;
            end;
          end;
        end
        else // quebrar receita
        begin
          Player.SendClientMessage('Receita falhou e foi perdida.');
        end;
      end;

{$ENDREGION}





  else
    Exit;

  end;

  Self.DecreaseAmount(item, Decrease);
  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
  Result := True;
end;
{$ENDREGION}
{$REGION 'Item Reinforce Stats'}
class function TItemFunctions.GetItemReinforceDamageReduction(Index: WORD;
  Refine: BYTE): WORD;
begin
  Result := Reinforce3[Self.GetItemReinforce3Index(Index)
    ].DamageReduction[Refine];
end;
class function TItemFunctions.GetItemReinforceHPMPInc(Index: WORD;
  Refine: BYTE): WORD;
begin
  Result := Reinforce3[Self.GetItemReinforce3Index(Index)
    ].HealthIncrementPoints[Refine];
end;
class function TItemFunctions.GetReinforceFromItem(const item: TItem): BYTE;
begin
  Result := 0;
  if (item.Refi = 0) then
    Exit;
  Result := Round(item.Refi / 16);
end;
{$ENDREGION}
{$REGION 'ItemDB Functions'}
class function TItemFunctions.UpdateMovedItems(var Player: TPlayer;
  SrcItemSlot, DestItemSlot: BYTE; SrcSlotType, DestSlotType: BYTE;
  SrcItem, DestItem: PItem): Boolean;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[UpdateMovedItems]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[UpdateMovedItems]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      ('UPDATE items SET slot_type=:pslot_type, slot=:pslot WHERE id=:pid');
    SQLComp.AddParameter2('pslot_type', SrcSlotType);
    SQLComp.AddParameter2('pslot', SrcItemSlot);
    // Player.PlayerSQL.AddParameter2('pid', SrcItem.Iddb);
    SQLComp.Run(False);
    SQLComp.SetQuery
      ('UPDATE items SET slot_type=:pslot_type, slot=:pslot WHERE id=:pid');
    SQLComp.AddParameter2('pslot_type', DestSlotType);
    SQLComp.AddParameter2('pslot', DestItemSlot);
    // Player.PlayerSQL.AddParameter2('pid', DestItem.Iddb);
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('Erro ao salvar os itens movidos acc[' +
        String(Player.Account.Header.Username) + '] items[' +
        String(ItemList[SrcItem.Index].Name) + ' -> ' +
        String(ItemList[DestItem.Index].Name) + '] slot [' +
        SrcItemSlot.ToString + ' -> ' + DestItemSlot.ToString + '] error [' +
        E.Message + '] time [' + DateTimeToStr(Now) + ']', TLogType.Error);
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;
{$ENDREGION}
{$REGION 'Recipe Functions'}
class function TItemFunctions.GetIDRecipeArray(RecipeItemID: WORD): WORD;
var
  i: WORD;
begin
  Result := 3000;
  for i := Low(Recipes) to High(Recipes) do
  begin
    if (Recipes[i].ItemRecipeID = 0) then
      Continue;
    if (Recipes[i].ItemRecipeID = RecipeItemID) then
    begin
      Result := i;
      Break;
    end
    else
      Continue;
  end;
end;
{$ENDREGION}
end.




