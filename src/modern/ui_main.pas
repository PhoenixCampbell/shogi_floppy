unit ui_main;

interface

uses shogigam, aiopp, util, crt;

procedure MainMenu;
procedure SinglePlayerGame;
procedure PlayerVsPlayer;
procedure ResumeGame;
procedure DisplayRules;

implementation

procedure MainMenu;
var
  UserChoice: integer;
begin
  repeat
    ClrScr;

    CenterText('Shogi Game - Main Menu  1.5.9');

    WriteLine('1. Single Player vs AI', 2);
    WriteLine('2. Player vs Player', 4);
    WriteLine('3. Load saved game', 6);
    WriteLine('4. Display Rules', 8);
    WriteLine('5. Exit', 10);

    GotoXY(1, 22);
    Write('Select option: ');

    UserChoice := GetIntegerInput; (* Get integer input *)

    case UserChoice of
      1: SinglePlayerGame;
      2: PlayerVsPlayer;
      3: ResumeGame;
      4: DisplayRules;
      5: Halt;
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

procedure ResumeGame;
var
  Board: TBoard;
  CurrentPlayer: TPlayer;
  DifficultyLevel: byte;
  CapturedPieces: TCapturedPieces;
begin
  if not LoadGame(
    Board,
    CurrentPlayer,
    DifficultyLevel,
    CapturedPieces,
    'shogi.sav'
  ) then
  begin
    HandleError(5);
    PauseForUser;
    Exit;
  end;

  HandleError(4);
  PauseForUser;

  if DifficultyLevel = 0 then
  begin
    PlayGame(Board, CurrentPlayer, DifficultyLevel, CapturedPieces);
    Exit;
  end;

  repeat
    PlayGame(Board, CurrentPlayer, DifficultyLevel, CapturedPieces);

    if CurrentPlayer <> Gote then
      Exit;

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
  until False;
end;

procedure DisplayMovementRule(PieceName: string);
begin
  ClrScr;
  CenterText(PieceName + ' Movement');
  Writeln;
  Writeln('The arrows show movement for Sente. Gote moves in reverse.');
  Writeln;

  if PieceName = 'Pawn' then
  begin
    Writeln('    ^');
    Writeln('    |');
    Writeln('  [ P ]');
    Writeln;
    Writeln('One square forward.');
  end
  else if PieceName = 'Lance' then
  begin
    Writeln('    ^');
    Writeln('    |');
    Writeln('    |');
    Writeln('  [ L ]');
    Writeln;
    Writeln('Any number of squares forward, if unobstructed.');
  end
  else if PieceName = 'Knight' then
  begin
    Writeln('  ^   ^');
    Writeln('   \ /');
    Writeln('  [ N ]');
    Writeln;
    Writeln('Two squares forward and one square left or right.');
  end
  else if PieceName = 'Silver General' then
  begin
    Writeln('  \\ ^ /');
    Writeln('   \\|/');
    Writeln('   [ S ]');
    Writeln('   /   \\');
    Writeln;
    Writeln('One square forward, forward-diagonal, or backward-diagonal.');
    Writeln('Sideways and straight backward are not allowed.');
  end
  else if PieceName = 'Gold General' then
  begin
    Writeln('  \\ ^ /');
    Writeln('   \\|/');
    Writeln('<-[ G ]->');
    Writeln('    |');
    Writeln('    v');
    Writeln;
    Writeln('One square forward, forward-diagonal, sideways,');
    Writeln('or straight backward. Not backward-diagonal.');
  end
  else if (PieceName = 'Promoted Pawn') or
          (PieceName = 'Promoted Lance') or
          (PieceName = 'Promoted Knight') or
          (PieceName = 'Promoted Silver General') then
  begin
    Writeln('  \\ ^ /');
    Writeln('   \\|/');
    Writeln('<-[ + ]->');
    Writeln('    |');
    Writeln('    v');
    Writeln;
    Writeln('Moves like a Gold General.');
  end
  else if PieceName = 'Bishop' then
  begin
    Writeln('\\       /');
    Writeln('  \\   /');
    Writeln('   [ B ]');
    Writeln('  /     \\');
    Writeln('/         \\');
    Writeln;
    Writeln('Any number of squares diagonally, if unobstructed.');
  end
  else if PieceName = 'Rook' then
  begin
    Writeln('    ^');
    Writeln('    |');
    Writeln('<--[ R ]-->');
    Writeln('    |');
    Writeln('    v');
    Writeln;
    Writeln('Any number of squares horizontally or vertically, if unobstructed.');
  end
  else if PieceName = 'Dragon Horse' then
  begin
    Writeln('\\     ^     /');
    Writeln('  \\   |   /');
    Writeln('<---[ H ]--->');
    Writeln('  /   |   \\');
    Writeln('/     v     \\');
    Writeln;
    Writeln('Moves like a Bishop, or one square orthogonally.');
  end
  else if PieceName = 'Dragon King' then
  begin
    Writeln('  \\  ^  /');
    Writeln('<---[ D ]--->');
    Writeln('  /  v  \\');
    Writeln;
    Writeln('Moves like a Rook, or one square diagonally.');
  end
  else if PieceName = 'King' then
  begin
    Writeln('  \\ ^ /');
    Writeln('<--[ K ]-->');
    Writeln('  / v \\');
    Writeln;
    Writeln('One square in any direction.');
  end;

  PauseForUser;
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

  DisplayMovementRule('Pawn');
  DisplayMovementRule('Lance');
  DisplayMovementRule('Knight');
  DisplayMovementRule('Silver General');
  DisplayMovementRule('Gold General');
  DisplayMovementRule('Promoted Pawn');
  DisplayMovementRule('Promoted Lance');
  DisplayMovementRule('Promoted Knight');
  DisplayMovementRule('Promoted Silver General');
  DisplayMovementRule('Bishop');
  DisplayMovementRule('Rook');
  DisplayMovementRule('Dragon Horse');
  DisplayMovementRule('Dragon King');
  DisplayMovementRule('King');

  ClrScr;

  CenterText('Shogi Game - Controls');
  Writeln;
  Writeln('Drop Pieces:');
  Writeln('  - Press ''D'' to drop a piece');
  Writeln('  - Type its letter: P, L, N, S, G, B, or R');
  Writeln('  - Press ''ENTER'' to confirm the drop');
  Writeln('  - Key Points: Pawns cannot be dropped in a column that already has one');
  Writeln('  - Additionally, you cannot drop a pawn to give an immediate checkmate');
  Writeln('  - Lastly, you cannot drop a pawn or a lance on the last row, or a knight on');
  Writeln('  - the last two rows as they would have no legal moves after being dropped');
  Writeln;
  Writeln('Escape Game:');
  Writeln('  - Typing ''R'', ''E'', ''Q'', or ''X'' at the beginning of your turn will'); 
  Writeln('  - end the game');
  Writeln;
  Writeln('General Controls:');
  Writeln('  - Using the arrow keys to navigate, choose a starting square then select by'); 
  Writeln('  - pressing ''ENTER'' ');
  Writeln('  - then, choose a landing square, selecting it by pressing ''ENTER'' again');
  Writeln;

  PauseForUser;
  ClrScr;

  CenterText('Shogi Game - Saving and Loading');
  Writeln;
  Writeln('When you can not finish a game, you can save it and load it later.');
  Writeln('  - To save a game, type ''S'' at the beginning of your turn.');
  Writeln('  - To load a game, select the "Load saved game" option from the main menu.');
  Writeln('  - The game will be saved to a file named "shogi.sav" in the current directory.');
  Writeln;

  PauseForUser;
  (* Honestly, Thank you for being interested in playing my game. This took some time and effort *)
  (* Debugging, testing, rewriting, wondering why something was broken, and quite a few late nights *)
  (* If you're reading this, it also means you wanted to see whats under the hood or even help coding *)
  (* And I thank you for that. *)
  (* If you would want to play shogi with me sometime, my handle on 81Dojo and lishogi is Phoenix_Campbell *)
  (* I participate in the weekly Shogi Ladder on 81Dojo when I can and would love to continue to play against *)
  (* Others who were serious enough to find this message *)
  (* Otherwise, if you wanted any help in this code base, email me or visit my website where my contact information *)
  (* Is at phoenixcampbell.com Again, Thank you very much *)
end;
end.