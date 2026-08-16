unit ui_main;

interface
uses shogi_game, ai_opponent, crt;

procedure MainMenu();
function GetUserInput: string;
procedure SinglePlayerGame();
procedure PlayerVsPlayer();
procedure DisplayRules();

implementation

procedure MainMenu();
begin
  WriteLn('Shogi Game - Main Menu');
  WriteLn('1. Single Player vs AI');
  WriteLn('2. Player vs Player');
  WriteLn('3. Display Rules');
  WriteLn('4. Exit');
  case GetUserInput() of
    '1': SinglePlayerGame();
    '2': PlayerVsPlayer();
    '3': DisplayRules();
    '4': Halt;
  end;
end;

function GetUserInput: string;
begin
  ReadLn(Result);
end;

procedure SinglePlayerGame();
var
  Board: TBoard;
  DifficultyLevel: byte;
begin
  SetupBoard(Board); // Initialize the board
  WriteLn('Select AI difficulty (1-3): ');
  ReadLn(DifficultyLevel);
  while not GameOver do
    PlayAI(Board, DifficultyLevel);
end;

procedure PlayerVsPlayer();
var
  Board: TBoard;
begin
  SetupBoard(Board); // Initialize the board
  while not GameOver do
    PlayGame(Board, True);
    PlayGame(Board, False);
end;

procedure DisplayRules();
var
  i: byte;
begin
  ClrScr;
  WriteLn('Shogi Game Rules:');
  WriteLn('------------------');
  for i := Low(TPiece) to High(TPiece) do
    WriteLn(PieceValue[i], ' - ', TPiece(i));
  ReadKey;
end;

{ Additional functions and procedures for UI }

end.