unit shogigam;

interface

uses util, crt;

const PieceValue: array[TPiece] of integer =
    (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14);

procedure SetupBoard(var Board: TBoard);
procedure DisplayBoard(
  var Board: TBoard;
  var CurrentPlayer: TPlayer;
  var CapturedPieces: TCapturedPieces);
procedure ClearCapturedPieces(var CapturedPieces: TCapturedPieces);
procedure SetLastMove(FromCol, FromRow: integer);
procedure MakeMove(
  var Board: TBoard;
  FromCol, FromRow, ToCol, ToRow: integer;
  Promote: boolean;
  var CapturedPieces: TCapturedPieces);
procedure MakeDrop(
  var Board: TBoard;
  Col, Row: integer;
  Piece: TPiece;
  var CapturedPieces: TCapturedPieces;
  CurrentPlayer: TPlayer);
procedure PlayGame(
  var Board: TBoard;
  var CurrentPlayer: TPlayer;
  DifficultyLevel: byte;
  var CapturedPieces: TCapturedPieces);
procedure SwitchPlayer(var CurrentPlayer: TPlayer);
function SaveGame(
  var Board: TBoard;
  var CurrentPlayer: TPlayer;
  DifficultyLevel: byte;
  var CapturedPieces: TCapturedPieces;
  FileName: string): boolean;
function LoadGame(
  var Board: TBoard;
  var CurrentPlayer: TPlayer;
  var DifficultyLevel: byte;
  var CapturedPieces: TCapturedPieces;
  FileName: string): boolean;

implementation

var
  LastMoveCol, LastMoveRow: integer;


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

  SetLastMove(0, 0);

end;

procedure DisplayBoard(
  var Board: TBoard;
  var CurrentPlayer: TPlayer;
  var CapturedPieces: TCapturedPieces);
var
  Row, Col, BoardLeft, BoardTop: integer;
  Symbol: char;
  Piece: TPiece;
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
      if (Col = LastMoveCol) and (Row = LastMoveRow) then
        Symbol := '#';
      Write(' ', Symbol, ' |');
    end;

    Write(' ', Row:1);

    GotoXY(BoardLeft, BoardTop + 2 + (Row * 2));
    Write('+---+---+---+---+---+---+---+---+---+');
  end;

  GotoXY(1, BoardTop + 2);
  Write('Sente hand:');
  GotoXY(1, BoardTop + 3);
  for Piece := Pawn to King do
    if Piece in [Pawn, Lance, Knight, SilverGeneral, GoldGeneral, Bishop, Rook] then
      if CapturedPieces[Sente, Piece] > 0 then
        Write(PieceToChar(Piece, Sente), '=', CapturedPieces[Sente, Piece], ' ');

  GotoXY(64, BoardTop + 2);
  Write('Gote hand:');
  GotoXY(64, BoardTop + 3);
  for Piece := Pawn to King do
    if Piece in [Pawn, Lance, Knight, SilverGeneral, GoldGeneral, Bishop, Rook] then
      if CapturedPieces[Gote, Piece] > 0 then
        Write(PieceToChar(Piece, Gote), '=', CapturedPieces[Gote, Piece], ' ');

  GotoXY(1, BoardTop + 21);
  if CurrentPlayer = Sente then
    Writeln('Sente''s turn.')
  else
    Writeln('Gote''s turn.');

  GotoXY(1, BoardTop + 22);
end;

procedure SetLastMove(FromCol, FromRow: integer);
begin
  LastMoveCol := FromCol;
  LastMoveRow := FromRow;
end;

procedure ClearCapturedPieces(var CapturedPieces: TCapturedPieces);
var
  Player: TPlayer;
  Piece: TPiece;
begin
  for Player := NoPlayer to Gote do
    for Piece := None to King do
      CapturedPieces[Player, Piece] := 0;
end;

procedure MakeMove(
  var Board: TBoard;
  FromCol, FromRow, ToCol, ToRow: integer;
  Promote: boolean;
  var CapturedPieces: TCapturedPieces);
var
  MovingPiece, CapturedPiece: TPiece;
  MovingPlayer: TPlayer;
begin
  MovingPiece := Board[FromCol, FromRow].Piece;
  MovingPlayer := Board[FromCol, FromRow].Owner;
  CapturedPiece := Board[ToCol, ToRow].Piece;

  if CapturedPiece <> None then
  begin
    CapturedPiece := UnpromotePiece(CapturedPiece);
    CapturedPieces[MovingPlayer, CapturedPiece] :=
      CapturedPieces[MovingPlayer, CapturedPiece] + 1;
  end;

  if Promote then
    MovingPiece := PromotePiece(MovingPiece);

  Board[ToCol, ToRow].Piece := MovingPiece;
  Board[ToCol, ToRow].Owner := MovingPlayer;
  Board[FromCol, FromRow].Piece := None;
  Board[FromCol, FromRow].Owner := NoPlayer;
end;

procedure MakeDrop(
  var Board: TBoard;
  Col, Row: integer;
  Piece: TPiece;
  var CapturedPieces: TCapturedPieces;
  CurrentPlayer: TPlayer);
begin
  Board[Col, Row].Piece := Piece;
  Board[Col, Row].Owner := CurrentPlayer;
  CapturedPieces[CurrentPlayer, Piece] :=
    CapturedPieces[CurrentPlayer, Piece] - 1;
end;

procedure PlayGame(
  var Board: TBoard;
  var CurrentPlayer: TPlayer;
  DifficultyLevel: byte;
  var CapturedPieces: TCapturedPieces);
var
  FromCol, FromRow, ToCol, ToRow: integer;
  CursorCol, CursorRow: integer;
  MoveComplete, PromotionChoice, InputValid: boolean;
  DropRequested: boolean;
  DropPiece: TPiece;
  DropCol, DropRow: integer;
  Input: string;
  function SelectSquare(var Col, Row: integer; Prompt: string): char;
  var
    Key: char;
    OldAttr: byte;
  begin
    repeat
      ClrScr;
      DisplayBoard(Board, CurrentPlayer, CapturedPieces);
      GotoXY(22 + ((9 - Col) * 4), 4 + ((Row - 1) * 2));
      OldAttr := TextAttr;
      TextAttr := $70;
      Write(' ', PieceToChar(Board[10 - Col, Row].Piece,
        Board[10 - Col, Row].Owner));
      Write(' ');
      TextAttr := OldAttr;
      GotoXY(1, 24);
      Write(Prompt, ' ', Col, ', ', Row,
        '  ENTER to select  ');

      Key := ReadKey;
      if Key = #0 then
      begin
        Key := ReadKey;
        case Ord(Key) of
          72: if Row > 1 then Row := Row - 1;
          80: if Row < 9 then Row := Row + 1;
          75: if Col < 9 then Col := Col + 1;
          77: if Col > 1 then Col := Col - 1;
        end;
      end
      else if Key = #13 then
        SelectSquare := #0
      else
      begin
        Key := UpCase(Key);
        if (Key = 'D') or (Key = 'S') or (Key = 'R') or (Key = 'E') or
           (Key = 'Q') or (Key = 'X') then
        begin
          SelectSquare := Key;
          Exit;
        end;
      end;
    until Key = #13;
  end;
begin
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

  CursorCol := 5;
  CursorRow := 5;
  repeat
    MoveComplete := False;
    
    repeat
      ClrScr;
      DisplayBoard(Board, CurrentPlayer, CapturedPieces);
      
      InputValid := True;

      (* Get From coordinates *)
      Input := SelectSquare(CursorCol, CursorRow, 'From where?');

      if (Input = 'R') or (Input = 'E') or
          (Input = 'Q') or (Input = 'X') then
      begin
        Exit;
      end;

      if Input = 'S' then
      begin
        if SaveGame(Board, CurrentPlayer, DifficultyLevel,
                    CapturedPieces, 'shogi.sav') then
          HandleError(2)
        else
          HandleError(3);
        PauseForUser;
        InputValid := False;
      end;

      DropRequested := Input = 'D';

      if DropRequested then
      begin
        Write('Piece to drop (P/L/N/S/G/B/R): ');
        Input := UpperString(GetStringInput);
        if Length(Input) <> 1 then
          InputValid := False
        else
          DropPiece := CharToPiece(Input[1]);

        if InputValid and
           ((DropPiece = None) or
            (CapturedPieces[CurrentPlayer, DropPiece] <= 0)) then
          InputValid := False;

        if not InputValid then
        begin
          HandleError(1);
          PauseForUser;
        end
        else
        begin
          Input := SelectSquare(CursorCol, CursorRow, 'To where?');
          if Input <> #0 then
          begin
            HandleError(1);
            PauseForUser;
            InputValid := False;
          end;
          DropCol := 10 - CursorCol;
          DropRow := CursorRow;

           if InputValid and
             IsLegalDrop(Board, DropPiece, DropCol, DropRow, CurrentPlayer) and
             not ((DropPiece = Pawn) and
                  IsPawnDropMate(
                    Board, DropCol, DropRow, CurrentPlayer, CapturedPieces)) then
          begin
            MakeDrop(Board, DropCol, DropRow, DropPiece,
              CapturedPieces, CurrentPlayer);
            MoveComplete := True;
          end
          else
          begin
            HandleError(1);
            PauseForUser;
          end;
        end;
      end;

      if (Input <> 'S') and (not DropRequested) and (not MoveComplete) then
      begin
      FromCol := 10 - CursorCol;
      FromRow := CursorRow;
      
      (* Validate From coordinates *)
      if not (InRange(FromCol, 1, 9) and
              InRange(FromRow, 1, 9)) then
      begin
        Writeln(
          'Starting coordinates must be between 1 and 9.'
        );
        PauseForUser;
        InputValid := False;
      end;

      (* Only ask for destination if From was valid *)
      if InputValid then
      begin
        ClrScr;
        DisplayBoard(Board, CurrentPlayer, CapturedPieces);

        Input := SelectSquare(CursorCol, CursorRow, 'To where?');
        ToCol := 10 - CursorCol;
        ToRow := CursorRow;

        if Input <> #0 then
        begin
          HandleError(1);
          PauseForUser;
          InputValid := False;
        end;

        (* Validate To coordinates *)
        if not (InRange(ToCol, 1, 9) and
                InRange(ToRow, 1, 9)) then
        begin
          Writeln(
            'Destination coordinates must be between 1 and 9.'
          );
          PauseForUser;
          InputValid := False;
        end;
      end;

      (* Only process move if all coordinates were valid *)
      if InputValid then
      begin
        if IsLegalMove(
          Board,
          FromCol,
          FromRow,
          ToCol,
          ToRow,
          CurrentPlayer,
          False
        ) then
        begin
          PromotionChoice := False;

          if MustPromote(
            Board[FromCol, FromRow].Piece,
            ToRow,
            CurrentPlayer
          ) then
          begin
            PromotionChoice := True;
            Writeln('This piece must promote.');
          end
          else if CanPromote(
            Board[FromCol, FromRow].Piece,
            FromRow,
            ToRow,
            CurrentPlayer
          ) then
          begin
            repeat
              Write('Promote piece? (Y/N): ');
              Input := GetStringInput;
              Input := UpperString(Input);

              if (Input <> 'Y') and
                 (Input <> 'N') then
              begin
                Writeln('Please enter Y or N.');
              end;

            until (Input = 'Y') or
                  (Input = 'N');

            PromotionChoice := (Input = 'Y');
          end;

          MakeMove(
            Board,
            FromCol,
            FromRow,
            ToCol,
            ToRow,
            PromotionChoice,
            CapturedPieces
          );
          SetLastMove(FromCol, FromRow);

          MoveComplete := True;
        end
        else
        begin
          HandleError(1);
          PauseForUser;
        end;
      end;
      end;

    until MoveComplete;

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

function SaveGame(
  var Board: TBoard;
  var CurrentPlayer: TPlayer;
  DifficultyLevel: byte;
  var CapturedPieces: TCapturedPieces;
  FileName: string): boolean;
var
  FileHandle: Text;
  Row, Col: integer;
  Player: TPlayer;
  Piece: TPiece;
  ErrorCode: integer;
begin
  SaveGame := False;
  Assign(FileHandle, FileName);
  {$I-}
  Rewrite(FileHandle);
  ErrorCode := IOResult;
  {$I+}
  if ErrorCode <> 0 then
    Exit;

  Writeln(FileHandle, Ord(CurrentPlayer));
  Writeln(FileHandle, DifficultyLevel);

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

  for Player := NoPlayer to Gote do
    for Piece := None to King do
      Writeln(FileHandle, CapturedPieces[Player, Piece]);

  Close(FileHandle);
  SaveGame := True;
end;

function LoadGame(
  var Board: TBoard;
  var CurrentPlayer: TPlayer;
  var DifficultyLevel: byte;
  var CapturedPieces: TCapturedPieces;
  FileName: string): boolean;
var
  FileHandle: Text;
  PieceNum, OwnerNum, Row, Col: integer;
  Player: TPlayer;
  Piece: TPiece;
  ErrorCode: integer;
begin
  LoadGame := False;
  Assign(FileHandle, FileName);
  {$I-}
  Reset(FileHandle);
  ErrorCode := IOResult;
  {$I+}
  if ErrorCode <> 0 then
    Exit;

  Readln(FileHandle, PieceNum);
  CurrentPlayer := TPlayer(PieceNum);
  Readln(FileHandle, DifficultyLevel);

  for Row := 1 to 9 do
    for Col := 1 to 9 do
    begin
      Readln(FileHandle, PieceNum, OwnerNum);
      Board[Col, Row].Piece := TPiece(PieceNum);
      Board[Col, Row].Owner := TPlayer(OwnerNum);
    end;

  for Player := NoPlayer to Gote do
    for Piece := None to King do
      Readln(FileHandle, CapturedPieces[Player, Piece]);

  Close(FileHandle);
  SetLastMove(0, 0);
  LoadGame := True;
end;
end.