unit Util;
interface
uses System.Threading, GLobalDefs, Math;
function IFThen(cond: boolean; aTrue: variant; aFalse: variant): variant; overload;
function IFThen(cond: boolean): boolean; overload;
function IncWord(var Variable: Word; Value: Integer): boolean; overload;
function IncByte(var Variable: Byte; Value: Integer; MaxLimit: Integer): Boolean; overload;
function IntMV(var x: integer; Value: Integer): boolean; overload;
function Dec(var x: integer; Value: Integer): boolean; overload;
function DecCardinal(var x: Cardinal; Value: Integer): boolean; overload;
function DecInt(var x: Integer; Value: Integer): Boolean; overload;
function DecWORD(var x: WORD; Value: Integer): boolean; overload;
function Dec(var x: Word; Value: Integer): boolean; overload;
function Dec(var x: Byte; Value: Integer): boolean; overload;
function Dec(var x: Int64; Value: Variant): boolean; overload;
function DecUInt64(var x: UInt64; Value: Variant): boolean; overload;
function IncSpeedMove(var Variable: Word; Value: Integer): Boolean; overload;
function IncCooldown(var Variable: Word; Value: Integer): Boolean; overload;
function IncCriticalperc(var Variable: Word; Value: Integer; MaxLimit: Integer; var MaxedAttributesCount: Integer): Boolean; overload;
function CalculateChance(var Tax: Integer;HelpForTheWinner: WORD ): Boolean;
function IncCritical(var Variable: Word; Value: Integer; MaxLimit: Integer): Boolean; overload;
type
  DWORD = Longword;
  TLoopState = TParallel.TLoopState;

implementation
function IFThen(cond: boolean; aTrue: variant; aFalse: variant): variant;

begin
  if cond then
    Result := aTrue
  else
    Result := aFalse;
end;
function IFThen(cond: boolean): boolean;
begin
  Result := IFThen(cond, true, false);
end;
function IncWord(var Variable: Word; Value: Integer): boolean;
var
  Res: Integer;
begin
  Res := Variable + Value;
  if(Res >= MAX_WORD_SIZE) then
  begin
    Variable := MAX_WORD_SIZE;
  end
  else if (Res <= MIN_WORD_SIZE) then
  begin
    Variable := MIN_WORD_SIZE;
  end
  else
    Variable := Res;
  Result := True;
end;
function IncByte(var Variable: Byte; Value: Integer; MaxLimit: Integer): Boolean; overload;
var
  Res: Integer;
begin
  Res := Variable + Value;
  if Res >= MaxLimit then
    Variable := MaxLimit
  else if Res <= 0 then
    Variable := 0
  else
    Variable := Res;
  Result := True;
end;
function IntMV(var x: integer; Value: Integer): boolean;
var
  Res: Integer;
begin
  //if()
end;
function Dec(var x: integer; Value: Integer): boolean;
begin
  x := x - Value;
  Result := True;
end;
function DecCardinal(var x: Cardinal; Value: Integer): boolean;
var
  Res: Integer;
begin
  Res := x - Value;
  if (Res < MIN_WORD_SIZE) then
  begin
    x := 0;
  end
  else
    x := Res;
  Result := True;
end;
function DecInt(var x: Integer; Value: Integer): Boolean; overload;
var
  Res: Integer;
begin
  Res := x - Value;
  if (Res < MIN_WORD_SIZE) then
  begin
    x := 0;
  end
  else
    x := Res;
  Result := True;
end;
function DecWORD(var x: WORD; Value: Integer): boolean;
var
  Res: Integer;
begin
  Res := x - Value;
  if (Res < MIN_WORD_SIZE) then
  begin
    x := 0;
  end
  else if(Res > MAX_WORD_SIZE) then
  begin
    x := MAX_WORD_SIZE;
  end
  else
    x := Res;
  Result := True;
end;
function Dec(var x: Word; Value: Integer): boolean;
var
  Res: Integer;
begin
  Res := x - Value;
  if (Res < MIN_WORD_SIZE) then
  begin
    x := 0;
  end
  else if(Res > MAX_WORD_SIZE) then
  begin
    x := MAX_WORD_SIZE;
  end
  else
    x := Res;
  Result := True;
end;
function Dec(var x: Byte; Value: Integer): boolean;
var
  Res: Integer;
begin
  Res := x - Value;
  if (Res < MIN_BYTE_SIZE) then
  begin
    x := MIN_BYTE_SIZE;
  end
  else if(Res > MAX_BYTE_SIZE) then
  begin
    x := MAX_BYTE_SIZE;
  end
  else
    x := Res;
  Result := True;
end;
function Dec(var x: Int64; Value: Variant): boolean;
var
  Res: Variant;
begin
  Res := x - Value;
  if (Res < MIN_BYTE_SIZE) then
  begin
    x := 0;
  end
  else
    x := Res;
  Result := True;
end;
function DecUInt64(var x: UInt64; Value: Variant): boolean;
var
  Res: Variant;
begin
  Res := x - Value;
  if (Res < MIN_BYTE_SIZE) then
  begin
    x := 0;
  end
  else
    x := Res;
  Result := True;
end;
function IncSpeedMove(var Variable: Word; Value: Integer): Boolean; overload;
var
  Res: Integer;
begin
  Res := Variable + Value;
  if(Res >= 70) then
  begin
    Variable := 70;
  end
  else if (Res <= 15) then
  begin
    Variable := 15;
  end
  else
    Variable := Res;
  Result := True;
end;
function IncCooldown(var Variable: Word; Value: Integer): Boolean; overload;
var
  Res: Integer;
begin
  Res := Variable + Value;
  if(Res >= 70) then
  begin
    Variable := 70;
  end
  else if (Res <= 0) then
  begin
    Variable := 0;
  end
  else
    Variable := Res;
  Result := True;
end;



// Implementação da função IncCritical

function IncCritical(var Variable: Word; Value: Integer; MaxLimit: Integer): Boolean; overload;
var
  Res: Integer;
begin
  Res := Variable + Value;
  if Res >= MaxLimit then
    Variable := MaxLimit
  else if Res <= 0 then
    Variable := 0
  else
    Variable := Res;
  Result := True;
end;

function IncCriticalperc(var Variable: Word; Value: Integer; MaxLimit: Integer; var MaxedAttributesCount: Integer): Boolean; overload;
var
  Res: Integer;
  LimitedMax: Integer;
const
  PORC_STATUS: Double = 0.8;  // 80%
begin
  // Se já temos dois atributos no valor máximo
  if (MaxedAttributesCount >= 2) and (Variable < MaxLimit) then
  begin
    // Define o limite de 80% do valor máximo permitido para atributos não máximos
    LimitedMax := Trunc(MaxLimit * PORC_STATUS);  // Usa 80% do valor máximo

    // Se o atributo já alcançou 80%, impede incremento e retorna False
    if Variable >= LimitedMax then
    begin
      Result := False;  // Indica que o incremento foi bloqueado
      Exit;
    end;

    // Define o valor máximo permitido para atributos que não estão no limite
    MaxLimit := LimitedMax;
  end;

  // Calcula o novo valor
  Res := Variable + Value;

  // Aplica o valor calculado ou o limite máximo (ajustado ou total)
  if Res >= MaxLimit then
  begin
    // Se estamos no limite total, incrementa o contador de atributos no máximo
    if Variable < MaxLimit then
      Inc(MaxedAttributesCount);
    Variable := MaxLimit;
  end
  else if Res <= 0 then
  begin
    Variable := 0;  // Mantém o valor mínimo em 0
  end
  else
    Variable := Res;  // Define o valor calculado normalmente

  Result := True;  // Indica que o incremento foi aplicado com sucesso
end;



function CalculateChance(var Tax: Integer;HelpForTheWinner: WORD ): Boolean;
var
  TaxaRand: Integer;
begin
  Result:= False;
  if (Tax < MAX_PERCENTAGE) then      // caso seja superior a 100 porcento
  begin
    if (Tax < 0) then         // caso seja negativo
    begin
     Tax := (Tax * (-1));     // convere para positivo
     if Tax > HelpForTheWinner then  // caso seja maior do que a ajuda
     begin
       Tax:= MAX_PERCENTAGE - Tax;  // diminuir a chance de da sucesso
       if Tax <= 0 then
       Exit;
     end
     else
     Tax := MAX_PERCENTAGE - HelpForTheWinner;   // seja o chance para o 100 - ajuda
    end
    else if( Tax = 0) then  // caso seja iguais  faz um mescla 50/50
    begin
     Tax := 50;
    end
    else if (Tax < HelpForTheWinner) then   // caso a diferença seja menor que  a ajuda seta a ajuda como chance
    begin
      Tax:= HelpForTheWinner;
    end;

    Randomize;
    TaxaRand := RandomRange(1, 101);

   if not (Tax >= TaxaRand ) then
   begin
    Exit;
   end;
  end;
  Result := True;

end;

end.
