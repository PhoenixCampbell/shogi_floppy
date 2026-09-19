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
  UserChoice: integer;
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
  CapturedPieces: TCapturedPieces;
begin
  SetupBoard(Board);
  ClearCapturedPieces(CapturedPieces);
  CurrentPlayer := Sente;

  ClrScr;

  CenterText('Select AI difficulty:');
  Writeln;
  Writeln('1. Easy');
  Writeln('2. Medium');
  Writeln('3. Hard');
  Writeln('4. Attack-Centered');
  Writeln('5. Defense-Centered');

  repeat
    GotoXY(1, 22);
    Write('Difficulty: ');

    DifficultyLevel := GetIntegerInput; (* Get integer input *)

    if (DifficultyLevel < 1) or (DifficultyLevel > 5) then
      Writeln('Invalid input. Please enter a number between 1 and 5.');

  until (DifficultyLevel >= 1) and (DifficultyLevel <= 5);

  (* Writeln('Single Player  Difficulty: ', DifficultyLevel); *)
  CurrentPlayer := Sente;
  Writeln('Sente moves first.');

  repeat
    PlayGame(Board, CurrentPlayer, DifficultyLevel, CapturedPieces);

    if CurrentPlayer <> Gote then
      Exit;

    if CurrentPlayer = Gote then
    begin
      if IsCheckmate(Board, CurrentPlayer, CapturedPieces) then
        Exit;

      ClrScr;
      DisplayBoard(Board, CurrentPlayer, CapturedPieces);
      Writeln;
      Writeln('Computer is moving...');

      PlayAI(Board, DifficultyLevel, CapturedPieces);

      SwitchPlayer(CurrentPlayer);

      if IsCheckmate(Board, CurrentPlayer, CapturedPieces) then
      begin
        ClrScr;
        DisplayBoard(Board, CurrentPlayer, CapturedPieces);
        if CurrentPlayer = Sente then
          Writeln('Checkmate. Gote wins.')
        else
          Writeln('Checkmate. Sente wins.');
        PauseForUser;
        Exit;
      end;
    end;

  until False;
end;

procedure PlayerVsPlayer;
var
  Board: TBoard;
  CurrentPlayer: TPlayer;
  CapturedPieces: TCapturedPieces;
begin
  SetupBoard(Board);
  ClearCapturedPieces(CapturedPieces);
  CurrentPlayer := Sente;

  PlayGame(Board, CurrentPlayer, 0, CapturedPieces);
end;

procedure DisplayRules;
const
  PieceNames: array[TPiece] of string[24] =
    ('None', 'Pawn', 'Lance', 'Knight', 'Silver General', 'Gold General', 'Promoted Silver', 'Promoted Knight',
      'Promoted Lance', 'Promoted Pawn', 'Bishop', 'Rook', 'Dragon Horse',
      'Dragon King', 'King'
    );
  DisplayPieceValues: array[TPiece] of integer =
    (0, 1, 3, 4, 5, 6, 6, 6, 6, 6, 8, 10, 13, 15, 0);
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

    if Piece = King then
      Writeln('Priceless')
    else
      Writeln(DisplayPieceValues[Piece]);
  end;

  PauseForUser;

  ClrScr;

  CenterText('Shogi Game - Controls');
  Writeln;
  Writeln('Drop Pieces:');
  Writeln('  - Press ''D'' to drop a piece');
  Writeln('  - Type its letter: P, L, N, S, G, B, or R');
  Writeln('  - Enter the destination column, then row');
  Writeln;
  Writeln('Escape Game:');
  Writeln('  - Typing ''resign'', ''end'', ''quit'', or ''exit'' at the beginning on');
  Writeln('  your turn will end the game');
  Writeln;
  Writeln('General Controls:');
  Writeln('  - Enter Column / Row to select a square, pressing ''ENTER'' ');
  Writeln('  -  between each input (e.g., ''9'' ENTER then ''5'' ENTER)');
  Writeln;

  PauseForUser;
end;

end.