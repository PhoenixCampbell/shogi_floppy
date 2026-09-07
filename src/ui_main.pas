unit ui_main;

interface

uses shogigam, aiopp, crt;

procedure MainMenu;
function GetStringInput: string;
function GetIntegerInput: Integer;
function GetCharInput: Char;
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

function GetStringInput: string;
var
  Input: string;
begin
  Readln(Input);
  GetStringInput := Input;
end;


function GetIntegerInput: Integer;
var
  Input: string;
  Value: Integer;
  ErrorCode: Integer;
begin
  repeat
    Readln(Input);

    Val(Input, Value, ErrorCode);

    if ErrorCode <> 0 then
      Write('Invalid input. Please enter an integer: ');

  until ErrorCode = 0;

  GetIntegerInput := Value;
end;


function GetCharInput: Char;
var
  Input: string;
begin
  repeat
    Readln(Input);

    if Length(Input) <> 1 then
      Write('Invalid input. Please enter one character: ');

  until Length(Input) = 1;

  GetCharInput := Input[1];
end;

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
    PlayGame(Board, CurrentPlayer, DifficultyLevel
    );

    if CurrentPlayer = Gote then
    begin
      ClrScr;
      DisplayBoard(Board);
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