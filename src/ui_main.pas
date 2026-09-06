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

function GetUserInput(ExpectedType: string): Variant;
var
  UserInput: string;
  ChoiceInt: Integer;
begin
  repeat
    Readln(UserInput);
    case ExpectedType of
      'Integer':
        if TryStrToInt(UserInput, ChoiceInt) then (* Check if input is an integer *)
          Exit(ChoiceInt)
        else
          WriteLn('Invalid input. Please enter a valid integer.');

      'Char':
        if Length(UserInput) = 1 then (* check for char input *)
          Exit(UserInput[1])
        else
          WriteLn('Invalid input. Please enter a single character.');

    else
      Exit(UserInput); (* Default case: return the input as a string *)
    end;
  until False; (* Repeat until valid input is provided *)
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

    UserChoice := GetUserInput('Integer'); (* Get integer input *)

    case UserChoice of
      '1': SinglePlayerGame;
      '2': PlayerVsPlayer;
      '3': DisplayRules;
      '4': Halt;
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

    DifficultyLevel := GetUserInput('Integer'); (* Get integer input *)

    if (DifficultyLevel < 1) or (DifficultyLevel > 3) then
      WriteLn('Invalid input. Please enter a number between 1 and 3.');

  until (DifficultyLevel >= 1) and (DifficultyLevel <= 3);

  (* WriteLn('Single Player  Difficulty: ', DifficultyLevel); *)
  WriteLn('Sente moves first.');

  PlayGame(Board, CurrentPlayer);
end;

procedure PlayerVsPlayer;
var
  Board: TBoard;
  CurrentPlayer: TPlayer;
  Key: char;
begin
  SetupBoard(Board);
  CurrentPlayer := Sente;

  PlayGame(Board, CurrentPlayer);
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
  Write('Press any key to return.');

  Key := ReadKey;
end;

end.