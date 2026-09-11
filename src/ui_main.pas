unit ui_main;

interface

uses shogigam, aiopp, util, crt;

procedure MainMenu;
procedure SinglePlayerGame;
procedure PlayerVsPlayer;
procedure DisplayRules;

implementation

procedure MainMenu;
var
  UserChoice: Integer;
begin
  repeat
    ClrScr;

    CenterText('Shogi Game - Main Menu');

    WriteLine('1. Single Player vs AI', 2);
    WriteLine('2. Player vs Player', 4);
    WriteLine('3. Display Rules', 6);
    WriteLine('4. Exit', 8);

    GotoXY(1, 22);
    Write('Select option: ');

    UserChoice := GetIntegerInput; (* Get integer input *)

    case UserChoice of
      1: SinglePlayerGame;
      2: PlayerVsPlayer;
      3: DisplayRules;
      4: Halt;
    end;

  until False;
end;

procedure SinglePlayerGame;
var
  Board: TBoard;
  CurrentPlayer: TPlayer;
  DifficultyLevel: byte;
begin
  SetupBoard(Board);
  CurrentPlayer := Sente;

  ClrScr;

  CenterText('Select AI difficulty:');
  Writeln;
  Writeln('1. Easy');
  Writeln('2. Medium');
  Writeln('3. Hard');

  repeat
    GotoXY(1, 22);
    Write('Difficulty: ');

    DifficultyLevel := GetIntegerInput; (* Get integer input *)

    if (DifficultyLevel < 1) or (DifficultyLevel > 3) then
      Writeln('Invalid input. Please enter a number between 1 and 3.');

  until (DifficultyLevel >= 1) and (DifficultyLevel <= 3);

  (* Writeln('Single Player  Difficulty: ', DifficultyLevel); *)
  CurrentPlayer := Sente;
  Writeln('Sente moves first.');

  repeat
    PlayGame(Board, CurrentPlayer, DifficultyLevel);

    if CurrentPlayer = Gote then
    begin
      ClrScr;
      DisplayBoard(Board, CurrentPlayer);
      Writeln;
      Writeln('Computer is moving...');

      PlayAI(Board, DifficultyLevel);

      SwitchPlayer(CurrentPlayer);
    end;

  until False;
end;

procedure PlayerVsPlayer;
var
  Board: TBoard;
  CurrentPlayer: TPlayer;
begin
  SetupBoard(Board);
  CurrentPlayer := Sente;

  PlayGame(Board, CurrentPlayer, 0);
end;

procedure DisplayRules;
const
  PieceNames: array[TPiece] of string[24] =
    ('None', 'Pawn', 'Lance', 'Knight', 'Silver General', 'Gold General', 'Promoted Silver', 'Promoted Knight',
      'Promoted Lance', 'Promoted Pawn', 'Bishop', 'Rook', 'Dragon Horse',
      'Dragon King', 'King'
    );

var
  Piece: TPiece;
begin
  ClrScr;

  Writeln('Shogi Game - Piece Values');
  Writeln;
  Writeln('Piece                     Value');
  Writeln('------------------------  -----');


  for Piece := Pawn to King do
  begin
    Write(PieceNames[Piece]);

    GotoXY(28, WhereY);

    Writeln(PieceValue[Piece]);
  end;

  PauseForUser;

  ClrScr;

  CenterText('Shogi Game - Controls');
  Writeln;
  Writeln('Drop Pieces:');
  Writeln('  - Press ''D'' to drop a piece');
  Writeln('  - Select piece from your captured pieces');
  Writeln('  - Choose destination square');
  Writeln;
  Writeln('Escape Game:');
  Writeln('  - Press ''Q'' to quit and return to main menu');
  Writeln('  - Press ''ESC'' to exit the game');
  Writeln;
  Writeln('General Controls:');
  Writeln('  - Enter Column / Row to select a square, pressing ''ENTER'' ');
  Writeln('  -  between each input (e.g., ''9'' ENTER then ''5'' ENTER)');
  Writeln('  - Press ''R'' to restart the game');
  Writeln;

  PauseForUser;
end;

end.