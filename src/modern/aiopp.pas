unit aiopp;

interface

uses shogigam, util;

procedure PlayAI(
  var Board: TBoard;
  DifficultyLevel: byte;
  var CapturedPieces: TCapturedPieces);

implementation

const
  ScoreInfinity = 30000;
  MaxAIMoves = 1024;
  AIPieceValue: array[TPiece] of integer =
    (0, 1, 3, 4, 5, 6, 6, 6, 6, 6, 8, 10, 13, 15, 0);

type
  TAIMove = record
    FromCol, FromRow, ToCol, ToRow: integer;
    Piece: TPiece;
    IsDrop: boolean;
    Promote: boolean;
  end;
  TAIMoveList = array[1..MaxAIMoves] of TAIMove;

function OpponentOf(Player: TPlayer): TPlayer;
begin
  if Player = Sente then
    OpponentOf := Gote
  else if Player = Gote then
    OpponentOf := Sente
  else
    OpponentOf := NoPlayer;
end;

procedure AddMove(
  var Moves: TAIMoveList;
  var MoveCount: integer;
  FromCol, FromRow, ToCol, ToRow: integer;
  Piece: TPiece;
  IsDrop, Promote: boolean);
begin
  if MoveCount >= MaxAIMoves then
    Exit;

  MoveCount := MoveCount + 1;
  Moves[MoveCount].FromCol := FromCol;
  Moves[MoveCount].FromRow := FromRow;
  Moves[MoveCount].ToCol := ToCol;
  Moves[MoveCount].ToRow := ToRow;
  Moves[MoveCount].Piece := Piece;
  Moves[MoveCount].IsDrop := IsDrop;
  Moves[MoveCount].Promote := Promote;
end;

procedure GenerateMoves(
  var Board: TBoard;
  Player: TPlayer;
  var CapturedPieces: TCapturedPieces;
  var Moves: TAIMoveList;
  var MoveCount: integer);
var
  FromCol, FromRow, ToCol, ToRow: integer;
  Piece: TPiece;
  MovingPiece: TPiece;
  MustPromoteMove: boolean;
begin
  MoveCount := 0;

  for FromRow := 1 to 9 do
    for FromCol := 1 to 9 do
      if Board[FromCol, FromRow].Owner = Player then
      begin
        MovingPiece := Board[FromCol, FromRow].Piece;

        for ToRow := 1 to 9 do
          for ToCol := 1 to 9 do
            if IsLegalMove(
              Board, FromCol, FromRow, ToCol, ToRow, Player, False) then
            begin
              MustPromoteMove := MustPromote(MovingPiece, ToRow, Player);

              if not MustPromoteMove then
                AddMove(
                  Moves, MoveCount, FromCol, FromRow, ToCol, ToRow,
                  MovingPiece, False, False);

              if CanPromote(MovingPiece, FromRow, ToRow, Player) and
                 IsLegalMove(
                   Board, FromCol, FromRow, ToCol, ToRow, Player, True) then
                AddMove(
                  Moves, MoveCount, FromCol, FromRow, ToCol, ToRow,
                  MovingPiece, False, True);
            end;
      end;

  for Piece := Pawn to Rook do
    if CapturedPieces[Player, Piece] > 0 then
      for ToRow := 1 to 9 do
        for ToCol := 1 to 9 do
          if IsValidDrop(Board, Piece, ToCol, ToRow, Player) and
             not IsPawnDropMate(
               Board, ToCol, ToRow, Player, CapturedPieces) then
            AddMove(
              Moves, MoveCount, 0, 0, ToCol, ToRow, Piece, True, False);
end;

procedure ApplyMove(
  var Board: TBoard;
  Move: TAIMove;
  Player: TPlayer;
  var CapturedPieces: TCapturedPieces);
begin
  if Move.IsDrop then
  begin
    Board[Move.ToCol, Move.ToRow].Piece := Move.Piece;
    Board[Move.ToCol, Move.ToRow].Owner := Player;
    CapturedPieces[Player, Move.Piece] :=
      CapturedPieces[Player, Move.Piece] - 1;
  end
  else
    MakeMove(
      Board,
      Move.FromCol,
      Move.FromRow,
      Move.ToCol,
      Move.ToRow,
      Move.Promote,
      CapturedPieces);
end;

function MovePriority(var Board: TBoard; Move: TAIMove): integer;
var
  Priority: integer;
begin
  Priority := 0;

  if Move.IsDrop then
    Priority := 1
  else if Board[Move.ToCol, Move.ToRow].Piece <> None then
    Priority := AIPieceValue[Board[Move.ToCol, Move.ToRow].Piece] * 10;

  if Move.Promote then
    Priority := Priority + 20;

  MovePriority := Priority;
end;

procedure OrderMoves(var Board: TBoard; var Moves: TAIMoveList; MoveCount: integer);
var
  i, j, BestIndex: integer;
  BestPriority, CurrentPriority: integer;
  TemporaryMove: TAIMove;
begin
  for i := 1 to MoveCount - 1 do
  begin
    BestIndex := i;
    BestPriority := MovePriority(Board, Moves[i]);

    for j := i + 1 to MoveCount do
    begin
      CurrentPriority := MovePriority(Board, Moves[j]);
      if CurrentPriority > BestPriority then
      begin
        BestIndex := j;
        BestPriority := CurrentPriority;
      end;
    end;

    if BestIndex <> i then
    begin
      TemporaryMove := Moves[i];
      Moves[i] := Moves[BestIndex];
      Moves[BestIndex] := TemporaryMove;
    end;
  end;
end;

function EvaluateBoard(
  var Board: TBoard;
  AIPlayer: TPlayer;
  var CapturedPieces: TCapturedPieces): integer;
var
  Row, Col: integer;
  Piece: TPiece;
  Score: integer;
  Progress: integer;
begin
  Score := 0;

  for Row := 1 to 9 do
    for Col := 1 to 9 do
      if Board[Col, Row].Piece <> None then
      begin
        if Board[Col, Row].Owner = AIPlayer then
          Score := Score + AIPieceValue[Board[Col, Row].Piece]
        else
          Score := Score - AIPieceValue[Board[Col, Row].Piece];

        Progress := 0;
        if Board[Col, Row].Owner = Sente then
          Progress := 10 - Row
        else if Board[Col, Row].Owner = Gote then
          Progress := Row - 1;

        if Board[Col, Row].Piece in [Pawn, Lance, Knight] then
        begin
          if Board[Col, Row].Owner = AIPlayer then
            Score := Score + Progress
          else
            Score := Score - Progress;
        end
        else if Board[Col, Row].Piece in [Bishop, Rook, DragonHorse, DragonKing] then
        begin
          Progress := 4 - Abs(5 - Col);
          if Board[Col, Row].Owner = AIPlayer then
            Score := Score + Progress
          else
            Score := Score - Progress;
        end;
      end;

  for Piece := Pawn to Rook do
  begin
    Score := Score +
      CapturedPieces[AIPlayer, Piece] * AIPieceValue[Piece];
    Score := Score -
      CapturedPieces[OpponentOf(AIPlayer), Piece] * AIPieceValue[Piece];
  end;

  EvaluateBoard := Score;
end;

function KingSafetyScore(var Board: TBoard; Player: TPlayer): integer; forward;

function EvaluateStrategicMove(
  var Board: TBoard;
  Move: TAIMove;
  Player: TPlayer;
  var CapturedPieces: TCapturedPieces;
  AttackingStyle: boolean): integer;
var
  Opponent: TPlayer;
  Score: integer;
  CapturedPiece: TPiece;
  Col, Row: integer;
begin
  Opponent := OpponentOf(Player);
  CapturedPiece := None;
  if not Move.IsDrop then
    CapturedPiece := Board[Move.ToCol, Move.ToRow].Piece;
  ApplyMove(Board, Move, Player, CapturedPieces);
  Score := EvaluateBoard(Board, Player, CapturedPieces);

  if IsInCheck(Board, Opponent) then
    Score := Score + 35;
  if IsInCheck(Board, Player) then
    Score := Score - 1000;
  if not AttackingStyle then
    Score := Score + KingSafetyScore(Board, Player) * 8;
  if Move.Promote then
    Score := Score + 15;

  if CapturedPiece <> None then
    Score := Score + AIPieceValue[CapturedPiece] * 3;

  if Move.IsDrop then
  begin
    Col := Move.ToCol;
    Row := Move.ToRow;
    if AttackingStyle then
      Score := Score + (10 - Abs(5 - Col)) + (10 - Abs(5 - Row))
    else
      Score := Score - Abs(5 - Col) - Abs(5 - Row);
  end;

  EvaluateStrategicMove := Score;
end;

procedure StrategicAIMove(
  var Board: TBoard;
  AIPlayer: TPlayer;
  var CapturedPieces: TCapturedPieces;
  AttackingStyle: boolean);
var
  Moves: TAIMoveList;
  MoveCount, MoveIndex: integer;
  BestIndex, BestValue, Value: integer;
  SavedBoard: TBoard;
  SavedCapturedPieces: TCapturedPieces;
begin
  GenerateMoves(Board, AIPlayer, CapturedPieces, Moves, MoveCount);
  OrderMoves(Board, Moves, MoveCount);
  if MoveCount = 0 then
    Exit;

  BestIndex := 1;
  BestValue := -ScoreInfinity;

  for MoveIndex := 1 to MoveCount do
  begin
    SavedBoard := Board;
    SavedCapturedPieces := CapturedPieces;
    Value := EvaluateStrategicMove(
      Board, Moves[MoveIndex], AIPlayer, CapturedPieces, AttackingStyle);
    Board := SavedBoard;
    CapturedPieces := SavedCapturedPieces;

    if Value > BestValue then
    begin
      BestValue := Value;
      BestIndex := MoveIndex;
    end;
  end;

  ApplyMove(Board, Moves[BestIndex], AIPlayer, CapturedPieces);
end;

function KingSafetyScore(var Board: TBoard; Player: TPlayer): integer;
var
  KingCol, KingRow: integer;
  Col, Row, Danger: integer;
  Opponent: TPlayer;
begin
  KingSafetyScore := 0;
  KingCol := 0;
  KingRow := 0;

  if Player = Sente then
    Opponent := Gote
  else
    Opponent := Sente;

  for Row := 1 to 9 do
    for Col := 1 to 9 do
      if (Board[Col, Row].Piece = King) and
         (Board[Col, Row].Owner = Player) then
      begin
        KingCol := Col;
        KingRow := Row;
      end;

  if KingCol = 0 then
    Exit;

  Danger := 0;
  for Row := KingRow - 1 to KingRow + 1 do
    for Col := KingCol - 1 to KingCol + 1 do
      if IsInsideBoard(Col, Row) and
         IsSquareAttacked(Board, Col, Row, Opponent) then
        Danger := Danger + 1;

  KingSafetyScore := 8 - Danger;
end;

function IsTacticalMove(var Board: TBoard; Move: TAIMove): boolean;
begin
  IsTacticalMove := Move.Promote;
  if not Move.IsDrop and (Board[Move.ToCol, Move.ToRow].Piece <> None) then
    IsTacticalMove := True;
end;

function Quiescence(
  var Board: TBoard;
  CurrentPlayer, AIPlayer: TPlayer;
  Depth, Alpha, Beta: integer;
  var CapturedPieces: TCapturedPieces): integer;
var
  Moves: TAIMoveList;
  MoveCount, MoveIndex: integer;
  StandPat, Value, BestValue: integer;
  SavedBoard: TBoard;
  SavedCapturedPieces: TCapturedPieces;
  InCheck: boolean;
begin
  StandPat := EvaluateBoard(Board, AIPlayer, CapturedPieces);
  if Depth <= 0 then
  begin
    Quiescence := StandPat;
    Exit;
  end;

  GenerateMoves(Board, CurrentPlayer, CapturedPieces, Moves, MoveCount);
  OrderMoves(Board, Moves, MoveCount);
  InCheck := IsInCheck(Board, CurrentPlayer);

  if (MoveCount = 0) and InCheck then
  begin
    if CurrentPlayer = AIPlayer then
      Quiescence := -ScoreInfinity + Depth
    else
      Quiescence := ScoreInfinity - Depth;
    Exit;
  end;

  if CurrentPlayer = AIPlayer then
  begin
    if InCheck then
      BestValue := -ScoreInfinity
    else
      BestValue := StandPat;
    if (not InCheck) and (BestValue >= Beta) then
    begin
      Quiescence := BestValue;
      Exit;
    end;
    if BestValue > Alpha then
      Alpha := BestValue;

    for MoveIndex := 1 to MoveCount do
      if InCheck or IsTacticalMove(Board, Moves[MoveIndex]) then
      begin
        SavedBoard := Board;
        SavedCapturedPieces := CapturedPieces;
        ApplyMove(Board, Moves[MoveIndex], CurrentPlayer, CapturedPieces);
        Value := Quiescence(
          Board, OpponentOf(CurrentPlayer), AIPlayer,
          Depth - 1, Alpha, Beta, CapturedPieces);
        Board := SavedBoard;
        CapturedPieces := SavedCapturedPieces;

        if Value > BestValue then
          BestValue := Value;
        if BestValue > Alpha then
          Alpha := BestValue;
        if Beta <= Alpha then
        begin
          Quiescence := BestValue;
          Exit;
        end;
      end;
  end
  else
  begin
    if InCheck then
      BestValue := ScoreInfinity
    else
      BestValue := StandPat;
    if (not InCheck) and (BestValue <= Alpha) then
    begin
      Quiescence := BestValue;
      Exit;
    end;
    if BestValue < Beta then
      Beta := BestValue;

    for MoveIndex := 1 to MoveCount do
      if InCheck or IsTacticalMove(Board, Moves[MoveIndex]) then
      begin
        SavedBoard := Board;
        SavedCapturedPieces := CapturedPieces;
        ApplyMove(Board, Moves[MoveIndex], CurrentPlayer, CapturedPieces);
        Value := Quiescence(
          Board, OpponentOf(CurrentPlayer), AIPlayer,
          Depth - 1, Alpha, Beta, CapturedPieces);
        Board := SavedBoard;
        CapturedPieces := SavedCapturedPieces;

        if Value < BestValue then
          BestValue := Value;
        if BestValue < Beta then
          Beta := BestValue;
        if Beta <= Alpha then
        begin
          Quiescence := BestValue;
          Exit;
        end;
      end;
  end;

  Quiescence := BestValue;
end;

function Minimax(
  var Board: TBoard;
  CurrentPlayer, AIPlayer: TPlayer;
  Depth, Alpha, Beta: integer;
  var CapturedPieces: TCapturedPieces): integer;
var
  Moves: TAIMoveList;
  MoveCount, MoveIndex: integer;
  Value, BestValue: integer;
  SavedBoard: TBoard;
  SavedCapturedPieces: TCapturedPieces;
begin
  if Depth <= 0 then
  begin
    Minimax := Quiescence(
      Board, CurrentPlayer, AIPlayer, 2, Alpha, Beta, CapturedPieces);
    Exit;
  end;

  GenerateMoves(Board, CurrentPlayer, CapturedPieces, Moves, MoveCount);
  OrderMoves(Board, Moves, MoveCount);

  if MoveCount = 0 then
  begin
    if IsInCheck(Board, CurrentPlayer) then
    begin
      if CurrentPlayer = AIPlayer then
        Minimax := -ScoreInfinity + Depth
      else
        Minimax := ScoreInfinity - Depth;
    end
    else
      Minimax := 0;
    Exit;
  end;

  if CurrentPlayer = AIPlayer then
    BestValue := -ScoreInfinity
  else
    BestValue := ScoreInfinity;

  for MoveIndex := 1 to MoveCount do
  begin
    SavedBoard := Board;
    SavedCapturedPieces := CapturedPieces;
    ApplyMove(Board, Moves[MoveIndex], CurrentPlayer, CapturedPieces);

    Value := Minimax(
      Board,
      OpponentOf(CurrentPlayer),
      AIPlayer,
      Depth - 1,
      Alpha,
      Beta,
      CapturedPieces);

    Board := SavedBoard;
    CapturedPieces := SavedCapturedPieces;

    if CurrentPlayer = AIPlayer then
    begin
      if Value > BestValue then
        BestValue := Value;
      if BestValue > Alpha then
        Alpha := BestValue;
    end
    else
    begin
      if Value < BestValue then
        BestValue := Value;
      if BestValue < Beta then
        Beta := BestValue;
    end;

    if Beta <= Alpha then
    begin
      Minimax := BestValue;
      Exit;
    end;
  end;

  Minimax := BestValue;
end;

procedure PlaySelectedMove(
  var Board: TBoard;
  Move: TAIMove;
  Player: TPlayer;
  var CapturedPieces: TCapturedPieces);
begin
  ApplyMove(Board, Move, Player, CapturedPieces);
end;

procedure RandomMove(
  var Board: TBoard;
  AIPlayer: TPlayer;
  var CapturedPieces: TCapturedPieces);
var
  Moves: TAIMoveList;
  MoveCount, MoveIndex: integer;
begin
  GenerateMoves(Board, AIPlayer, CapturedPieces, Moves, MoveCount);
  OrderMoves(Board, Moves, MoveCount);
  if MoveCount > 0 then
  begin
    MoveIndex := Random(MoveCount) + 1;
    PlaySelectedMove(Board, Moves[MoveIndex], AIPlayer, CapturedPieces);
  end;
end;

procedure BasicAIMove(
  var Board: TBoard;
  AIPlayer: TPlayer;
  var CapturedPieces: TCapturedPieces);
var
  Moves: TAIMoveList;
  MoveCount, MoveIndex: integer;
  BestIndex, BestValue, Value: integer;
  SavedBoard: TBoard;
  SavedCapturedPieces: TCapturedPieces;
begin
  GenerateMoves(Board, AIPlayer, CapturedPieces, Moves, MoveCount);
  OrderMoves(Board, Moves, MoveCount);
  if MoveCount = 0 then
    Exit;

  BestIndex := 1;
  BestValue := -ScoreInfinity;

  for MoveIndex := 1 to MoveCount do
  begin
    SavedBoard := Board;
    SavedCapturedPieces := CapturedPieces;
    ApplyMove(Board, Moves[MoveIndex], AIPlayer, CapturedPieces);
    Value := EvaluateBoard(Board, AIPlayer, CapturedPieces);
    Board := SavedBoard;
    CapturedPieces := SavedCapturedPieces;

    if Value > BestValue then
    begin
      BestValue := Value;
      BestIndex := MoveIndex;
    end;
  end;

  PlaySelectedMove(Board, Moves[BestIndex], AIPlayer, CapturedPieces);
end;

procedure FindBestMove(
  var Board: TBoard;
  AIPlayer: TPlayer;
  Depth: integer;
  var CapturedPieces: TCapturedPieces;
  var BestMove: TAIMove;
  var MoveFound: boolean);
var
  Moves: TAIMoveList;
  MoveCount, MoveIndex: integer;
  BestIndex, Value, BestValue: integer;
  SavedBoard: TBoard;
  SavedCapturedPieces: TCapturedPieces;
begin
  GenerateMoves(Board, AIPlayer, CapturedPieces, Moves, MoveCount);
  OrderMoves(Board, Moves, MoveCount);
  MoveFound := False;
  if MoveCount = 0 then
    Exit;

  BestIndex := 1;
  BestValue := -ScoreInfinity;

  for MoveIndex := 1 to MoveCount do
  begin
    SavedBoard := Board;
    SavedCapturedPieces := CapturedPieces;
    ApplyMove(Board, Moves[MoveIndex], AIPlayer, CapturedPieces);
    Value := Minimax(
      Board,
      OpponentOf(AIPlayer),
      AIPlayer,
      Depth - 1,
      -ScoreInfinity,
      ScoreInfinity,
      CapturedPieces);
    Board := SavedBoard;
    CapturedPieces := SavedCapturedPieces;

    if Value > BestValue then
    begin
      BestValue := Value;
      BestIndex := MoveIndex;
    end;
  end;

  BestMove := Moves[BestIndex];
  MoveFound := True;
end;

procedure MinimaxMove(
  var Board: TBoard;
  AIPlayer: TPlayer;
  Depth: integer;
  var CapturedPieces: TCapturedPieces);
var
  SearchDepth: integer;
  CandidateMove, BestMove: TAIMove;
  CandidateFound, MoveFound: boolean;
begin
  MoveFound := False;

  for SearchDepth := 1 to Depth do
  begin
    FindBestMove(
      Board, AIPlayer, SearchDepth, CapturedPieces,
      CandidateMove, CandidateFound);

    if CandidateFound then
    begin
      BestMove := CandidateMove;
      MoveFound := True;
    end;
  end;

  if MoveFound then
    PlaySelectedMove(Board, BestMove, AIPlayer, CapturedPieces);
end;

procedure PlayAI(
  var Board: TBoard;
  DifficultyLevel: byte;
  var CapturedPieces: TCapturedPieces);
const
  AIPlayer = Gote;
begin
  case DifficultyLevel of
    1: RandomMove(Board, AIPlayer, CapturedPieces);
    2: BasicAIMove(Board, AIPlayer, CapturedPieces);
    3: MinimaxMove(Board, AIPlayer, 3, CapturedPieces);
    4: StrategicAIMove(Board, AIPlayer, CapturedPieces, True);
    5: StrategicAIMove(Board, AIPlayer, CapturedPieces, False);
  end;
end;
end.
