unit shogigam;

interface


uses util, crt;

type
  TPlayer = (NoPlayer, Sente, Gote);
  TPiece = (None, Pawn, Lance, Knight, SilverGeneral, GoldGeneral, 
            PromotedSilverGeneral, PromotedKnight, PromotedLance, 
            PromotedPawn, Bishop, Rook, DragonHorse, DragonKing, King);
  TSquare = record
    Piece: TPiece;
    Owner: TPlayer;
  end;

  TBoard = array[1..9, 1..9] of TSquare;

const PieceValue: array[TPiece] of integer =
    (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14);

function IsInsideBoard(Col, Row: integer): boolean;
function IsValidMove(var Board: TBoard; FromCol, FromRow, ToCol, ToRow: integer; var CurrentPlayer: TPlayer): boolean;
function PieceToChar(Piece: TPiece; Owner: TPlayer): char;

procedure SetupBoard(var Board: TBoard);
procedure DisplayBoard(var Board: TBoard; var CurrentPlayer: TPlayer);
procedure MakeMove(var Board: TBoard; FromCol, FromRow, ToCol, ToRow: integer);
procedure PlayGame(var Board: TBoard; var CurrentPlayer: TPlayer; DifficultyLevel: byte);
procedure SwitchPlayer(var CurrentPlayer: TPlayer);
procedure SaveGame(var Board: TBoard; FileName: string);
procedure LoadGame(var Board: TBoard; FileName: string);
procedure HandleError(ErrorCode: integer);
implementation


procedure SetupBoard(var Board: TBoard);
var
  Row, Col: integer;
begin
  (* Clear board *)
  for Row := 1 to 9 do
    for Col := 1 to 9 do
    begin
      Board[Col, Row].Piece := None;
      Board[Col, Row].Owner := NoPlayer;
    end;

  (* Gote *)
  Board[1,1].Piece := Lance;
  Board[2,1].Piece := Knight;
  Board[3,1].Piece := SilverGeneral;
  Board[4,1].Piece := GoldGeneral;
  Board[5,1].Piece := King;
  Board[6,1].Piece := GoldGeneral;
  Board[7,1].Piece := SilverGeneral;
  Board[8,1].Piece := Knight;
  Board[9,1].Piece := Lance;

  for Col := 1 to 9 do
    Board[Col,1].Owner := Gote;

  Board[2,2].Piece := Rook;
  Board[2,2].Owner := Gote;
  Board[8,2].Piece := Bishop;
  Board[8,2].Owner := Gote;

  for Col := 1 to 9 do
  begin
    Board[Col,3].Piece := Pawn;
    Board[Col,3].Owner := Gote;
  end;

  (* Sente *)
  for Col := 1 to 9 do
  begin
    Board[Col,7].Piece := Pawn;
    Board[Col,7].Owner := Sente;
  end;

  Board[2,8].Piece := Bishop;
  Board[2,8].Owner := Sente;
  Board[8,8].Piece := Rook;
  Board[8,8].Owner := Sente;

  Board[1,9].Piece := Lance;
  Board[2,9].Piece := Knight;
  Board[3,9].Piece := SilverGeneral;
  Board[4,9].Piece := GoldGeneral;
  Board[5,9].Piece := King;
  Board[6,9].Piece := GoldGeneral;
  Board[7,9].Piece := SilverGeneral;
  Board[8,9].Piece := Knight;
  Board[9,9].Piece := Lance;

  for Col := 1 to 9 do
    Board[Col,9].Owner := Sente;

end;

function IsInsideBoard(Col, Row: integer): boolean;
begin
  IsInsideBoard := (Col >= 1) and (Col <= 9) and (Row >= 1) and (Row <= 9);
end;

function IsValidMove( var Board: TBoard; FromCol, FromRow, ToCol, ToRow: integer; var CurrentPlayer: TPlayer): boolean;
begin
  IsValidMove := False;

  (* check if legally on board *)
  if not IsInsideBoard(FromCol, FromRow) then
    Exit;

  (*placement must be on board *)
  if not IsInsideBoard(ToCol, ToRow) then
    Exit;

  (* valid source space *)
  if Board[FromCol, FromRow].Piece = None then
    Exit;

  (* Player owns piece *)
  if Board[FromCol, FromRow].Owner <> CurrentPlayer then
    Exit;

  (* do not capture own piece *)
  if Board[ToCol, ToRow].Owner = CurrentPlayer then
    Exit;

  (*cannot move to same space *)
  if (FromCol = ToCol) and
     (FromRow = ToRow) then
    Exit;

  (* piece specific rules *)
  case Board[FromCol, FromRow].Piece of
    Pawn:
      begin
        (* one step forward *)
        if CurrentPlayer = Sente then
          IsValidMove := (ToCol = FromCol) and (ToRow = FromRow - 1)
        else
          IsValidMove := (ToCol = FromCol) and (ToRow = FromRow + 1);
      end;

    Lance:
      begin
        (* any number steps only forward *)
        if CurrentPlayer = Sente then
          IsValidMove := (ToCol = FromCol) and (ToRow < FromRow)
        else
          IsValidMove := (ToCol = FromCol) and (ToRow > FromRow);
      end;

    Knight:
      begin
        (* two steps forward and one step left or right *)
        IsValidMove := ((ToCol = FromCol + 2) and (Abs(ToRow - FromRow) = 1)) or
                      ((ToCol = FromCol - 2) and (Abs(ToRow - FromRow) = 1)) or
                      ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow + 2)) or
                      ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow - 2));
      end;

    SilverGeneral:
      begin
        (* one step diagonally any direction or straight ahead *)
        if CurrentPlayer = Sente then
          IsValidMove := ((Abs(ToCol - FromCol) = 1) and (Abs(ToRow - FromRow) = 1)) or
                          ((ToCol = FromCol) and (ToRow = FromRow - 1))
        else
          IsValidMove := ((Abs(ToCol - FromCol) = 1) and (Abs(ToRow - FromRow) = 1)) or
                          ((ToCol = FromCol) and (ToRow = FromRow + 1));
      end;

    GoldGeneral:
      begin
        if CurrentPlayer = Sente then
          IsValidMove := ((ToCol = FromCol) and (ToRow = FromRow - 1)) or (* forwards *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow - 1)) or (* diagonal forward *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow)) or (* l and r *)
                          ((ToCol = FromCol) and (ToRow = FromRow + 1)) (* backward *)
        else
          IsValidMove := ((ToCol = FromCol) and (ToRow = FromRow + 1)) or (* gote logic for same *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow + 1)) or
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow)) or
                          ((ToCol = FromCol) and (ToRow = FromRow - 1));
      end;
    (* maybe make a function for gold so all pieces that move like it follow the same logic instead of rewriting *)
    Bishop:
      begin
        (* any number of steps diagonally*)
        IsValidMove := Abs(ToCol - FromCol) = Abs(ToRow - FromRow);
      end;

    Rook:
      begin
        (* vertical or horizontal any number of steps*)
        IsValidMove := (ToCol = FromCol) or (ToRow = FromRow);
      end;

    King:
      begin
        (* one step any direction*)
        IsValidMove := (Abs(ToCol - FromCol) <= 1) and (Abs(ToRow - FromRow) <= 1);
      end;

    PromotedPawn:
      begin
        if CurrentPlayer = Sente then
          IsValidMove := ((ToCol = FromCol) and (ToRow = FromRow - 1)) or (* forwards *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow - 1)) or (* diagonal forward *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow)) or (* l and r *)
                          ((ToCol = FromCol) and (ToRow = FromRow + 1)) (* backward *)
        else
          IsValidMove := ((ToCol = FromCol) and (ToRow = FromRow + 1)) or (* gote logic for same *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow + 1)) or
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow)) or
                          ((ToCol = FromCol) and (ToRow = FromRow - 1));
      end;

    PromotedLance:
      begin
        if CurrentPlayer = Sente then
          IsValidMove := ((ToCol = FromCol) and (ToRow = FromRow - 1)) or (* forwards *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow - 1)) or (* diagonal forward *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow)) or (* l and r *)
                          ((ToCol = FromCol) and (ToRow = FromRow + 1)) (* backward *)
        else
          IsValidMove := ((ToCol = FromCol) and (ToRow = FromRow + 1)) or (* gote logic for same *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow + 1)) or
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow)) or
                          ((ToCol = FromCol) and (ToRow = FromRow - 1));
      end;

    PromotedKnight:
      begin
        if CurrentPlayer = Sente then
          IsValidMove := ((ToCol = FromCol) and (ToRow = FromRow - 1)) or (* forwards *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow - 1)) or (* diagonal forward *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow)) or (* l and r *)
                          ((ToCol = FromCol) and (ToRow = FromRow + 1)) (* backward *)
        else
          IsValidMove := ((ToCol = FromCol) and (ToRow = FromRow + 1)) or (* gote logic for same *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow + 1)) or
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow)) or
                          ((ToCol = FromCol) and (ToRow = FromRow - 1));
      end;

    PromotedSilverGeneral:
      begin
        if CurrentPlayer = Sente then
          IsValidMove := ((ToCol = FromCol) and (ToRow = FromRow - 1)) or (* forwards *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow - 1)) or (* diagonal forward *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow)) or (* l and r *)
                          ((ToCol = FromCol) and (ToRow = FromRow + 1)) (* backward *)
        else
          IsValidMove := ((ToCol = FromCol) and (ToRow = FromRow + 1)) or (* gote logic for same *)
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow + 1)) or
                          ((Abs(ToCol - FromCol) = 1) and (ToRow = FromRow)) or
                          ((ToCol = FromCol) and (ToRow = FromRow - 1));
      end;

    DragonHorse:
      begin
        (* moves like Bishop and one step orthogonally *)
        IsValidMove := (Abs(ToCol - FromCol) = Abs(ToRow - FromRow)) or
                      ((Abs(ToCol - FromCol) <= 1) and (Abs(ToRow - FromRow) <= 1));
      end;

    DragonKing:
      begin
        (* moves like Rook and one step diagonally *)
        IsValidMove := (ToCol = FromCol) or (ToRow = FromRow) or
                      ((Abs(ToCol - FromCol) <= 1) and (Abs(ToRow - FromRow) <= 1));
      end;
    else
      IsValidMove := False;
  end;
end;

function PieceToChar(Piece: TPiece; Owner: TPlayer): char;
begin
  case Piece of
    Pawn: 
      begin
        if Owner = Sente then
          PieceToChar := 'P'
        else
          PieceToChar := 'p';
      end;
    Lance: 
      begin
        if Owner = Sente then
          PieceToChar := 'L'
        else
          PieceToChar := 'l';
      end;
    Knight:
      begin
        if Owner = Sente then
          PieceToChar := 'N'
        else
          PieceToChar := 'n';
      end;
    SilverGeneral:
      begin
        if Owner = Sente then
          PieceToChar := 'S'
        else
          PieceToChar := 's';
      end;
    GoldGeneral:
      begin
        if Owner = Sente then
          PieceToChar := 'G'
        else
          PieceToChar := 'g';
      end;
    Bishop:
      begin
        if Owner = Sente then
          PieceToChar := 'B'
        else
          PieceToChar := 'b';
      end;
    Rook:
      begin
        if Owner = Sente then
          PieceToChar := 'R'
        else
          PieceToChar := 'r';
      end;
    King:
      begin
        if Owner = Sente then
          PieceToChar := 'K'
        else
          PieceToChar := 'k';
      end;
    PromotedPawn:
      begin
        if Owner = Sente then
          PieceToChar := 'T'
        else
          PieceToChar := 't';
      end;
    PromotedLance:
      begin
        if Owner = Sente then
          PieceToChar := 'M'
        else
          PieceToChar := 'm';
      end;
    PromotedKnight:
      begin
        if Owner = Sente then
          PieceToChar := 'Q'
        else
          PieceToChar := 'q';
      end;
    PromotedSilverGeneral:
      begin
        if Owner = Sente then
          PieceToChar := 'V'
        else
          PieceToChar := 'v';
      end;
    DragonHorse:
      begin
        if Owner = Sente then
          PieceToChar := 'H'
        else
          PieceToChar := 'h';
      end;
    DragonKing:
      begin
        if Owner = Sente then
          PieceToChar := 'D'
        else
          PieceToChar := 'd';
      end;

    else
      PieceToChar := ' ';
  end;
end;

procedure DisplayBoard(var Board: TBoard; var CurrentPlayer: TPlayer);
var
  Row, Col, BoardLeft, BoardTop: integer;
  Symbol: char;
begin
  ClrScr;

  BoardLeft := 21;
  BoardTop := 1;

  GotoXY(BoardLeft + 16, BoardTop);
  Write('SHOGI');

  GotoXY(BoardLeft + 2, BoardTop + 1);
  Write('9   8   7   6   5   4   3   2   1');

  GotoXY(BoardLeft, BoardTop + 2);
  Write('+---+---+---+---+---+---+---+---+---+');

  for Row := 1 to 9 do
  begin
    GotoXY(BoardLeft, BoardTop + 2 + (Row * 2) - 1);
    Write('|');

    for Col := 1 to 9 do
    begin
      Symbol := PieceToChar(Board[Col, Row].Piece, Board[Col, Row].Owner);
      Write(' ', Symbol, ' |');
    end;

    Write(' ', Row:1);

    GotoXY(BoardLeft, BoardTop + 2 + (Row * 2));
    Write('+---+---+---+---+---+---+---+---+---+');
  end;

  if CurrentPlayer = Sente then
      begin
        Writeln;
        Writeln('Sente''s turn.');
      end
    else
      begin
        Writeln;
        Writeln('Gote''s turn.');
      end;
end;

procedure MakeMove(var Board: TBoard; FromCol, FromRow, ToCol, ToRow: integer);
begin
  (* moving including piece and ownership *)
  Board[ToCol, ToRow] :=
    Board[FromCol, FromRow];


  (* Empty original square *)
  Board[FromCol, FromRow].Piece := None;
  Board[FromCol, FromRow].Owner := NoPlayer;
end;

procedure PlayGame(var Board: TBoard; var CurrentPlayer: TPlayer; DifficultyLevel: byte);
var
  FromCol, FromRow, ToCol, ToRow: integer;
  MoveComplete: boolean;
  TempInput: integer;
begin
  repeat
    ClrScr;
    DisplayBoard(Board, CurrentPlayer);

    MoveComplete := False;

    repeat
      (* Get From coordinates *)
      Write('From where? (e.g. 9 9): ');
      TempInput := GetIntegerInput;  (* Read first coordinate (column) *)
      FromCol := 10 - TempInput;     (* Convert to board coordinate *)
      FromRow := GetIntegerInput;    (* Read second coordinate (row) *)
      
      if not (InRange(FromCol, 1, 9) and InRange(FromRow, 1, 9)) then
      begin
        Writeln('Coordinates must be between 1 and 9.');
        Continue;
      end;

      (* Get To coordinates *)
      ClrScr;
      DisplayBoard(Board, CurrentPlayer);

      Write('To where? (e.g. 9 9): ');
      TempInput := GetIntegerInput;  (* Read first coordinate (column) *)
      ToCol := 10 - TempInput;       (* Convert to board coordinate *)
      ToRow := GetIntegerInput;      (* Read second coordinate (row) *)
      
      if not (InRange(ToCol, 1, 9) and InRange(ToRow, 1, 9)) then
      begin
        Writeln('Coordinates must be between 1 and 9.');
        Continue;
      end;

      if IsValidMove(Board, FromCol, FromRow, ToCol, ToRow, CurrentPlayer) then
        begin
          MakeMove(Board, FromCol, FromRow, ToCol, ToRow);
          MoveComplete := True;
        end
      else
        begin
          HandleError(1); 
        end;
    until MoveComplete;
    
    SwitchPlayer(CurrentPlayer);

    if DifficultyLevel > 0 then
      Exit;
  until False;
end;

procedure SwitchPlayer(var CurrentPlayer: TPlayer);
begin
  if CurrentPlayer = Sente then
    CurrentPlayer := Gote
  else if CurrentPlayer = Gote then
    CurrentPlayer := Sente;
end;

procedure SaveGame(var Board: TBoard; FileName: string);
var
  FileHandle: Text;
  Row, Col: integer;
begin
  Assign(FileHandle, FileName);
  Rewrite(FileHandle);

  for Row := 1 to 9 do
    for Col := 1 to 9 do
    begin
      Writeln(
        FileHandle,
        Ord(Board[Col, Row].Piece),
        ' ',
        Ord(Board[Col, Row].Owner)
      );
    end;

  Close(FileHandle);
end;

procedure LoadGame(var Board: TBoard; FileName: string);
var
  FileHandle: Text;
  PieceNum, OwnerNum, Row, Col: integer;
begin
  Assign(FileHandle, FileName);
  Reset(FileHandle);

  for Row := 1 to 9 do
    for Col := 1 to 9 do
    begin
      Readln(FileHandle, PieceNum, OwnerNum);
      Board[Col, Row].Piece := TPiece(PieceNum);
      Board[Col, Row].Owner := TPlayer(OwnerNum);
    end;

  Close(FileHandle);
end;

procedure HandleError(ErrorCode: integer);
begin
  case ErrorCode of
    1: Writeln('Invalid move.');
    2: Writeln('Game saved successfully.');
    3: Writeln('Failed to save game.');
    4: Writeln('Game loaded successfully.');
    5: Writeln('Failed to load game.');
  end;
end;
end.