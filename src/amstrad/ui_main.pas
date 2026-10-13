unit ui_main;

interface

uses shogigam, aiopp, util, kifu, crt, dos;

procedure MainMenu;
procedure SinglePlayerGame;
procedure PlayerVsPlayer;
procedure ResumeGame;
procedure StudyKifu;
procedure DisplayRules;

implementation

function DirectoryOf(FilePath: string): string;
var
  Index: integer;
begin
  Index := Length(FilePath);
  while (Index > 0) and (FilePath[Index] <> '\') do
    Index := Index - 1;
  if Index = 0 then
    DirectoryOf := ''
  else if (Index = 3) and (FilePath[2] = ':') then
    DirectoryOf := Copy(FilePath, 1, 3)
  else
    DirectoryOf := Copy(FilePath, 1, Index - 1);
end;

function ParentDirectory(DirectoryPath: string): string;
var
  Index: integer;
begin
  Index := Length(DirectoryPath);
  if (Index > 3) and (DirectoryPath[Index] = '\') then
    Index := Index - 1;
  while (Index > 0) and (DirectoryPath[Index] <> '\') do
    Index := Index - 1;
  if Index = 0 then
    ParentDirectory := ''
  else if (Index = 3) and (DirectoryPath[2] = ':') then
    ParentDirectory := Copy(DirectoryPath, 1, 3)
  else if Index = 1 then
    ParentDirectory := '\'
  else
    ParentDirectory := Copy(DirectoryPath, 1, Index - 1);
end;

function FindKifuAt(DirectoryPath: string): string;
var
  Candidate: string;
  Search: SearchRec;
begin
  FindKifuAt := '';
  if DirectoryPath = '' then Exit;
  if DirectoryPath[Length(DirectoryPath)] = '\' then
    Candidate := DirectoryPath + 'KIFU'
  else
    Candidate := DirectoryPath + '\KIFU';
  FindFirst(Candidate + '\*.*', AnyFile, Search);
  if DosError = 0 then
    FindKifuAt := Candidate + '\';
end;

function FindKifuDirectory: string;
var
  BaseDirectory, Candidate, ExecutableDirectory: string;
  CurrentDirectory: string[67];
  Pass: integer;
begin
  FindKifuDirectory := '';
  GetDir(0, CurrentDirectory);
  ExecutableDirectory := DirectoryOf(ParamStr(0));
  for Pass := 1 to 2 do
  begin
    if Pass = 1 then
      BaseDirectory := CurrentDirectory
    else if ExecutableDirectory <> '' then
      BaseDirectory := ExecutableDirectory
    else
      BaseDirectory := CurrentDirectory;
    repeat
      Candidate := FindKifuAt(BaseDirectory);
      if Candidate <> '' then
      begin
        FindKifuDirectory := Candidate;
        Exit;
      end;
      Candidate := ParentDirectory(BaseDirectory);
      if Candidate = BaseDirectory then
        BaseDirectory := ''
      else
        BaseDirectory := Candidate;
    until BaseDirectory = '';
  end;
end;

procedure SelectTimeControl(var Clock: TGameClock);
var
  Choice: integer;
  Minutes: integer;
begin
  ClrScr;
  CenterText('Select time control:');
  Writeln;
  Writeln('0. No timer');
  Writeln('1. 10 minutes');
  Writeln('2. 30 minutes');
  Writeln('3. 60 minutes');
  repeat
    GotoXY(1, 22);
    Write('Time control: ');
    Choice := GetIntegerInput;
    if (Choice < 0) or (Choice > 3) then
      Writeln('Please enter a number from 0 to 3.');
  until (Choice >= 0) and (Choice <= 3);

  case Choice of
    1: Minutes := 10;
    2: Minutes := 30;
    3: Minutes := 60;
    else Minutes := 0;
  end;
  InitializeClock(Clock, Minutes);
end;

function NumberedKifuName(Number: integer): string;
var
  Name: string;
begin
  Name := 'GAME000.CSA';
  Name[5] := Chr(Ord('0') + (Number div 100));
  Name[6] := Chr(Ord('0') + ((Number div 10) mod 10));
  Name[7] := Chr(Ord('0') + (Number mod 10));
  NumberedKifuName := Name;
end;

procedure OfferKifuExport;
var
  Input, FileName, FilePath, KifuDirectory: string;
  FileIndex: integer;
  Search: SearchRec;
begin
  if not CanExportGameHistory then
  begin
    Writeln('Kifu export unavailable for this game history.');
    PauseForUser;
    Exit;
  end;
  Write('Save this game as a kifu? (Y/N): ');
  Input := UpperString(GetStringInput);
  if Input <> 'Y' then Exit;

  KifuDirectory := FindKifuDirectory;
  if KifuDirectory = '' then
  begin
    Writeln('Kifu folder not found.');
    PauseForUser;
    Exit;
  end;
  FileIndex := 1;
  FileName := NumberedKifuName(FileIndex);
  FilePath := KifuDirectory + FileName;
  FindFirst(FilePath, AnyFile, Search);
  while (DosError = 0) and (FileIndex < 999) do
  begin
    FileIndex := FileIndex + 1;
    FileName := NumberedKifuName(FileIndex);
    FilePath := KifuDirectory + FileName;
    FindFirst(FilePath, AnyFile, Search);
  end;
  if DosError = 0 then
  begin
    Writeln('No unused GAMEnnn.CSA filenames remain.');
    PauseForUser;
    Exit;
  end;
  if SaveKifuFile(FilePath) then
    Writeln('Saved kifu: ', FileName)
  else
    Writeln('Could not save kifu: ', FileName);
  PauseForUser;
end;

procedure MainMenu;
var
  UserChoice: integer;
begin
  repeat
    ClrScr;

    CenterText('Shogi Game - Main Menu  1.14.36');

    WriteLine('1. Single Player vs AI', 2);
    WriteLine('2. Player vs Player', 4);
    WriteLine('3. Load saved game', 6);
    WriteLine('4. Study kifu', 8);
    WriteLine('5. Display Rules', 10);
    WriteLine('6. Exit', 12);

    GotoXY(1, 22);
    Write('Select option: ');

    UserChoice := GetIntegerInput; (* Get integer input *)

    case UserChoice of
      1: SinglePlayerGame;
      2: PlayerVsPlayer;
      3: ResumeGame;
      4: StudyKifu;
      5: DisplayRules;
      6: Halt;
    end;

  until False;
end;

procedure SinglePlayerGame;
var
  Board: TBoard;
  CurrentPlayer: TPlayer;
  DifficultyLevel: byte;
  CapturedPieces: TCapturedPieces;
  Clock: TGameClock;
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

  SelectTimeControl(Clock);

  (* Writeln('Single Player  Difficulty: ', DifficultyLevel); *)
  CurrentPlayer := Sente;
  Writeln('Sente moves first.');

  repeat
    PlayGame(Board, CurrentPlayer, DifficultyLevel, CapturedPieces, Clock);

    if CurrentPlayer <> Gote then
      Exit;

    if CurrentPlayer = Gote then
    begin
      if IsCheckmate(Board, CurrentPlayer, CapturedPieces) then
      begin
        OfferKifuExport;
        Exit;
      end;

      ClrScr;
      DisplayBoard(Board, CurrentPlayer, CapturedPieces, Clock);
      Writeln;
      Writeln('Computer is moving...');

      BeginClockTurn(Clock);
      PlayAI(Board, DifficultyLevel, CapturedPieces);
      UpdateClock(Clock, CurrentPlayer);
      if Clock.Enabled and (Clock.RemainingMs[CurrentPlayer] = 0) then
      begin
        ClrScr;
        Writeln('Time expired. Sente wins.');
        PauseForUser;
        Exit;
      end;

      SwitchPlayer(CurrentPlayer);

      if IsCheckmate(Board, CurrentPlayer, CapturedPieces) then
      begin
        ClrScr;
        DisplayBoard(Board, CurrentPlayer, CapturedPieces, Clock);
        if CurrentPlayer = Sente then
          Writeln('Checkmate. Gote wins.')
        else
          Writeln('Checkmate. Sente wins.');
        PauseForUser;
        OfferKifuExport;
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
  Clock: TGameClock;
begin
  SelectTimeControl(Clock);
  SetupBoard(Board);
  ClearCapturedPieces(CapturedPieces);
  CurrentPlayer := Sente;

  PlayGame(Board, CurrentPlayer, 0, CapturedPieces, Clock);
  if IsCheckmate(Board, CurrentPlayer, CapturedPieces) then
    OfferKifuExport;
end;

procedure ResumeGame;
var
  Board: TBoard;
  CurrentPlayer: TPlayer;
  DifficultyLevel: byte;
  CapturedPieces: TCapturedPieces;
  Clock: TGameClock;
begin
  if not LoadGame(
    Board,
    CurrentPlayer,
    DifficultyLevel,
    CapturedPieces,
    Clock,
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
    PlayGame(Board, CurrentPlayer, DifficultyLevel, CapturedPieces, Clock);
    if IsCheckmate(Board, CurrentPlayer, CapturedPieces) then
      OfferKifuExport;
    Exit;
  end;

  repeat
    PlayGame(Board, CurrentPlayer, DifficultyLevel, CapturedPieces, Clock);

    if CurrentPlayer <> Gote then
      Exit;

    if IsCheckmate(Board, CurrentPlayer, CapturedPieces) then
    begin
      OfferKifuExport;
      Exit;
    end;

    ClrScr;
    DisplayBoard(Board, CurrentPlayer, CapturedPieces, Clock);
    Writeln;
    Writeln('Computer is moving...');

    BeginClockTurn(Clock);
    PlayAI(Board, DifficultyLevel, CapturedPieces);
    UpdateClock(Clock, CurrentPlayer);
    if Clock.Enabled and (Clock.RemainingMs[CurrentPlayer] = 0) then
    begin
      ClrScr;
      Writeln('Time expired. Sente wins.');
      PauseForUser;
      Exit;
    end;
    SwitchPlayer(CurrentPlayer);

    if IsCheckmate(Board, CurrentPlayer, CapturedPieces) then
    begin
      ClrScr;
      DisplayBoard(Board, CurrentPlayer, CapturedPieces, Clock);
      if CurrentPlayer = Sente then
        Writeln('Checkmate. Gote wins.')
      else
        Writeln('Checkmate. Sente wins.');
      PauseForUser;
      OfferKifuExport;
      Exit;
    end;
  until False;
end;

function IsKifuFile(FileName: string): boolean;
var
  DotPosition: integer;
  Extension: string;
begin
  DotPosition := Length(FileName);
  while (DotPosition > 0) and (FileName[DotPosition] <> '.') do
    DotPosition := DotPosition - 1;
  if DotPosition = 0 then
  begin
    IsKifuFile := False;
    Exit;
  end;
  Extension := UpperString(Copy(FileName, DotPosition,
    Length(FileName) - DotPosition + 1));
  IsKifuFile := (Extension = '.TXT') or (Extension = '.USI') or
    (Extension = '.CSA');
end;

procedure StudyKifu;
var
  Search: SearchRec;
  Moves: TKifuMoveList;
  MoveCount, Ply, Index: integer;
  Board: TBoard;
  CurrentPlayer: TPlayer;
  CapturedPieces: TCapturedPieces;
  Clock: TGameClock;
  FileName, Input, ErrorText: string;
  KifuDirectory: string;
  ValidFile: boolean;
  DoneViewing: boolean;
begin
  ClrScr;
  CenterText('Kifu Studies');
  Writeln;
  KifuDirectory := FindKifuDirectory;
  if KifuDirectory = '' then
  begin
    Writeln('Kifu folder not found.');
    PauseForUser;
    Exit;
  end;
  Writeln('Files in KIFU:');
  FindFirst(KifuDirectory + '*.*', AnyFile, Search);
  while DosError = 0 do
  begin
    if (Search.Name <> 'README.md') and IsKifuFile(Search.Name) and
        ((Search.Attr and Directory) = 0) then
      Writeln('  ', Search.Name);
    FindNext(Search);
  end;
  Writeln;
  Write('Match filename (Q to return): ');
  FileName := GetStringInput;
  if UpperString(FileName) = 'Q' then Exit;
  if (Pos('/', FileName) > 0) or (Pos('\', FileName) > 0) or
      (Pos(':', FileName) > 0) then
  begin
    Writeln('Enter a filename from KIFU only.');
    PauseForUser;
    Exit;
  end;
  FileName := KifuDirectory + FileName;
  if not LoadKifu(FileName, Moves, MoveCount) then
  begin
    Writeln('Could not load a supported match file.');
    PauseForUser;
    Exit;
  end;

  Ply := 0;
  InitializeClock(Clock, 0);
  DoneViewing := False;
  while not DoneViewing do
  begin
    SetupBoard(Board);
    ClearCapturedPieces(CapturedPieces);
    CurrentPlayer := Sente;
    ValidFile := True;
    Index := 1;
    while (Index <= Ply) and ValidFile do
    begin
      ValidFile := ApplyKifuMove(Board, CurrentPlayer, CapturedPieces,
        Moves[Index], ErrorText);
      if ValidFile then
      begin
        if Moves[Index].IsDrop then
          SetLastMove(0, 0)
        else
          SetLastMove(Moves[Index].FromCol, Moves[Index].FromRow);
        SetLastMoveTarget(Moves[Index].ToCol, Moves[Index].ToRow);
      end;
      if ValidFile then
        Index := Index + 1;
    end;
    if not ValidFile then
    begin
      Writeln(ErrorText, ' At move ', Index, '.');
      PauseForUser;
      Exit;
    end;

    DisplayBoard(Board, CurrentPlayer, CapturedPieces, Clock);
    GotoXY(1, 25);
    Write('Ply ', Ply, '/', MoveCount,
      '  N: next  P: previous  Q: quit  ');
    Input := UpperString(GetStringInput);
    if (Input = 'N') and (Ply < MoveCount) then
      Ply := Ply + 1
    else if (Input = 'P') and (Ply > 0) then
      Ply := Ply - 1
    else if Input = 'Q' then
      DoneViewing := True;
  end;
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