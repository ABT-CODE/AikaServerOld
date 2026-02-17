unit ItemHelper;

interface

procedure PutItemWrapper(PlayerID: Integer; ItemID, Quantity: Integer);

implementation

uses
  ItemFunctions, Player;

procedure PutItemWrapper(PlayerID: Integer; ItemID, Quantity: Integer);
begin
  // Aqui chamamos a função de ItemFunctions
  TItemFunctions.PutItem(Servers[Player.ChannelIndex].Players[PlayerID], ItemID, Quantity);
end;

end.

