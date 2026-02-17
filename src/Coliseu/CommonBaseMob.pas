unit CommonBaseMob;

interface

type
  TScore = class
  public
    CurHP: Integer;
    CurMP: Integer;
    KillPoint: Integer;
  end;

  TCharacter = class
  private
    FPlayerID: Integer;
    FName: string;
    FCurrentScore: TScore;
  public
    constructor Create;
    property PlayerID: Integer read FPlayerID write FPlayerID;
    property Name: string read FName write FName;
    property CurrentScore: TScore read FCurrentScore write FCurrentScore;
  end;

  TBaseMob = class
  public
    Character: TCharacter;
    constructor Create;
  end;

implementation

constructor TCharacter.Create;
begin
  inherited Create;
  FCurrentScore := TScore.Create;
end;

constructor TBaseMob.Create;
begin
  inherited Create;
  Character := TCharacter.Create;
end;

end.
