unit SharedFunctions;

interface

uses
  ExtCtrls, Player, ItemFunctions; // Certifique-se de incluir as unidades necessárias

procedure DeliverItemAfterDelay(PlayerID: Integer);

implementation

procedure DeliverItemAfterDelay(PlayerID: Integer);
var
  ItemDeliveryTimer: TTimer;
begin
  ItemDeliveryTimer := TTimer.Create(nil);
  ItemDeliveryTimer.Interval := 300000; // 5 minutos em milissegundos
  ItemDeliveryTimer.OnTimer := procedure(Sender: TObject)
  var
    TeleportedPlayer: TBaseMob;
  begin
    ItemDeliveryTimer.Enabled := False;
    ItemDeliveryTimer.Free;

    // Busca o jogador usando o PlayerID
    TeleportedPlayer := Servers[Player.ChannelIndex].GetPlayer(PlayerID);
    if Assigned(TeleportedPlayer) then
    begin
      // Adiciona o item ao jogador
      TItemFunctions.PutItem(Servers[TeleportedPlayer.ChannelIndex].Players[PlayerID], 5251, 10);
      WriteLn('Item 5251 entregue ao jogador com ID ', PlayerID);
    end;
  end;
  ItemDeliveryTimer.Enabled := True;
end;

end.

