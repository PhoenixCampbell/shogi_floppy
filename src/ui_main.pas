unit ui_main;

interface
uses shogi_game, ai_opponent, crt; (* Add 'crt' to use functions like GetMaxX and GetMaxY *)
procedure MainMenu();
function GetUserInput: string;
procedure SinglePlayerGame();
procedure PlayerVsPlayer();
procedure DisplayRules();

implementation

(* Function to center a line of text horizontally *)
procedure CenterText(const Text: string);
var
  ScreenWidth, ScreenHeight: integer;
begin
  ScreenWidth := GetMaxX;
  ScreenHeight := GetMaxY;
  ClrScr;

  (* Calculate horizontal and vertical center positions *)
  GotoXY((ScreenWidth div 2) - (Length(Text) div 2), (ScreenHeight div 2));
  WriteLn(Text);
end;

(* Function to write a line of text at the specified vertical offset from the center *)
procedure WriteLine(const Text: string; VerticalOffset: integer);
var
  ScreenWidth, ScreenHeight: integer;
begin
  ScreenWidth := GetMaxX;
  ScreenHeight := GetMaxY;

  (* Calculate horizontal and vertical positions *)
  GotoXY((ScreenWidth div 2) - (Length(Text) div 2), (ScreenHeight div 2) + VerticalOffset);
  WriteLn(Text);
end;

procedure MainMenu();
var
  LineOffsets: array[1..4] of integer = (-3, 0, 3, 6); (* Adjust line offsets as needed *)

begin
  CenterText('Shogi Game - Main Menu');

  WriteLine('1. Single Player vs AI', LineOffsets[1]);
  WriteLine('2. Player vs Player', LineOffsets[2]);
  WriteLine('3. Display Rules', LineOffsets[3]);
  WriteLine('4. Exit', LineOffsets[4]);

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
  SetupBoard(Board); (* Initialize the board *)
  WriteLn('Select AI difficulty (1-3): ');
  ReadLn(DifficultyLevel);
  while not GameOver do
    PlayAI(Board, DifficultyLevel);
end;

procedure PlayerVsPlayer();
var
  Board: TBoard;
  CurrentPlayer: TPlayer;
begin
  SetupBoard(Board); (* Initialize the board *)
  CurrentPlayer := Sente; (* Sente starts first *)
  repeat
    if PlayerTurn then
      PlayGame(Board, CurrentPlayer)
    else
      PlayGame(Board, CurrentPlayer);  
    PlayerTurn := not PlayerTurn; (* Switch turns *)
  until GameOver;
end;

procedure DisplayRules();
const
  PieceNames: array[TPiece] of string = ('None', 'Pawn', 'Lance', 'Knight', 'SilverGeneral', 'GoldGeneral',
                                         'PromotedSilverGeneral', 'PromotedKnight', 'PromotedLance',
                                         'PromotedPawn', 'Bishop', 'Rook', 'DragonHorse', 'DragonKing');

var
  i: byte;
begin
  ClrScr;

  CenterText('Shogi Game Rules:');

  for i := 1 to 9 do
  begin
    WriteLine(PieceNames[i] + ': ' + IntToStr(PieceValue[i]), (i - 1) * 2);
  end;

  ReadKey;
end;

(* Additional functions and procedures for UI *)

end.
