unit ItemFunctionsBase;

interface

uses
  Player;

type
  TItemFunctionsBase = class
  public
    class procedure PutItem(var Player: TPlayer; Item: TItem; StartSlot: BYTE = 0; Notice: Boolean = False); static;
  end;

implementation

class procedure TItemFunctionsBase.PutItem(var Player: TPlayer; Item: TItem; StartSlot: BYTE = 0; Notice: Boolean = False);
begin
  // Função para adicionar o item ao inventário do jogador
  // (coloque a lógica aqui)
end;

end.

