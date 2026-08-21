unit ui_main;

interface

uses shogigam, aiopp, crt;

procedure MainMenu;
function GetUserInput: string;
procedure SinglePlayerGame;
procedure PlayerVsPlayer;
procedure DisplayRules;

implementation

procedure CenterText(Text: string);
var
  ScreenWidth: integer;
begin
  ScreenWidth := 80;

  GotoXY((ScreenWidth div 2) - (Length(Text) div 2), 12);

  Writeln(Text);
end;


procedure WriteLine(Text: string; VerticalOffset: integer);
var
  ScreenWidth: integer;
begin
  ScreenWidth := 80;

  GotoXY((ScreenWidth div 2) - (Length(Text) div 2), 12 + VerticalOffset);

  Writeln(Text);
end;


function GetUserInput: string;
var
  UserInput: string;
begin
  Readln(UserInput);
  GetUserInput := UserInput;
end;


procedure MainMenu;
var
  UserChoice: string;
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

    UserChoice := GetUserInput;

    if Length(UserChoice) > 0 then
    begin
      case UserChoice[1] of
        '1': SinglePlayerGame;
        '2': PlayerVsPlayer;
        '3': DisplayRules;
        '4': Halt;
      end;
    end;

  until False;
end;


procedure SinglePlayerGame;
var
  Board: TBoard;
  CurrentPlayer: TPlayer;
  DifficultyLevel: byte;
  Key: char;
begin
  SetupBoard(Board);
  CurrentPlayer := Sente;

  ClrScr;

  Writeln('Select AI difficulty:');
  Writeln;
  Writeln('1. Easy');
  Writeln('2. Medium');
  Writeln('3. Hard');
  Writeln;
  Write('Difficulty: ');

  Readln(DifficultyLevel);

  if DifficultyLevel < 1 then
    DifficultyLevel := 1;

  if DifficultyLevel > 3 then
    DifficultyLevel := 3;

  { Draw initialized board }
  DisplayBoard(Board);

  Writeln;
  Writeln('Single Player vs AI');
  Writeln('Difficulty: ', DifficultyLevel);
  Writeln('Sente moves first.');
  Writeln;
  Writeln('Press any key to return to the main menu.');

  Key := ReadKey;
end;

procedure PlayerVsPlayer;
var
  Board: TBoard;
  CurrentPlayer: TPlayer;
  Key: char;
begin
  SetupBoard(Board);
  CurrentPlayer := Sente;

  { Draw initialized board }
  DisplayBoard(Board);

  Writeln;
  Writeln('Player vs Player');
  Writeln('Sente moves first.');
  Writeln;
  Writeln('Press any key to return to the main menu.');

  Key := ReadKey;
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
  Key: char;
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

  Writeln;
  Writeln('Press any key to return.');

  Key := ReadKey;
end;

end.