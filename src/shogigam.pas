unit shogigam;

interface

uses crt;

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
function IsValidMove(var Board: TBoard; FromCol, FromRow: integer; ToCol, ToRow: integer; CurrentPlayer: TPlayer): boolean;
function PieceToChar(Piece: TPiece): char;

procedure SetupBoard(var Board: TBoard);
procedure DisplayBoard(var Board: TBoard);
procedure MakeMove(var Board: TBoard; FromCol, FromRow: integer; ToCol, ToRow: integer);
procedure PlayGame(var Board: TBoard; var CurrentPlayer: TPlayer);
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

function IsValidMove( var Board: TBoard; FromCol, FromRow: integer; ToCol, ToRow: integer; CurrentPlayer: TPlayer): boolean;
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

  IsValidMove := True;
end;

function PieceToChar(Piece: TPiece): char;
begin
  case Piece of
    Pawn: PieceToChar := 'P';
    Lance: PieceToChar := 'L';
    Knight: PieceToChar := 'N';
    SilverGeneral: PieceToChar := 'S';
    GoldGeneral: PieceToChar := 'G';
    Bishop: PieceToChar := 'B';
    Rook: PieceToChar := 'R';
    King: PieceToChar := 'K';
    PromotedPawn: PieceToChar := 'T';
    PromotedLance: PieceToChar := 'M';
    PromotedKnight: PieceToChar := 'Q';
    PromotedSilverGeneral: PieceToChar := 'V';
    DragonHorse: PieceToChar := 'H';
    DragonKing: PieceToChar := 'D';

    else
      PieceToChar := ' ';
  end;
end;

procedure DisplayBoard(var Board: TBoard);
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
      Symbol := PieceToChar(Board[Col, Row].Piece);
      Write(' ', Symbol, ' |');
    end;

    Write(' ', Row:1);

    GotoXY(BoardLeft, BoardTop + 2 + (Row * 2));
    Write('+---+---+---+---+---+---+---+---+---+');
  end;
end;

procedure MakeMove(var Board: TBoard; FromCol, FromRow: integer; ToCol, ToRow: integer);
begin
  (* moving including piece and ownership *)
  Board[ToCol, ToRow] :=
    Board[FromCol, FromRow];


  (* Empty original square *)
  Board[FromCol, FromRow].Piece := None;
  Board[FromCol, FromRow].Owner := NoPlayer;
end;

procedure PlayGame(var Board: TBoard; var CurrentPlayer: TPlayer);
begin
  (*
    Human move input will be implemented here.

    Eventually this procedure will:

      1. Display the board.
      2. Ask for a source square.
      3. Ask for a destination square.
      4. Call IsValidMove.
      5. Call MakeMove.
      6. Handle promotion.
      7. Handle captures/drops.
  *)
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
    1: WriteLn('Invalid move.');
    2: WriteLn('Game saved successfully.');
    3: WriteLn('Failed to save game.');
    4: WriteLn('Game loaded successfully.');
    5: WriteLn('Failed to load game.');
  end;
end;

end.