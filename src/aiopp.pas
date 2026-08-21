unit aiopp;

interface

uses shogigam, crt;

procedure PlayAI(var Board: TBoard; DifficultyLevel: byte);

implementation

const
  ScoreInfinity = 30000;
  DirectionCol: array[1..4] of integer = (-1, 1, 0, 0);

  DirectionRow: array[1..4] of integer = (0, 0, -1, 1);

function OpponentOf(Player: TPlayer): TPlayer;
begin
  if Player = Sente then
    OpponentOf := Gote
  else if Player = Gote then
    OpponentOf := Sente
  else
    OpponentOf := NoPlayer;
end;

procedure RandomMove(var Board: TBoard; AIPlayer: TPlayer);
var
  FromCol, FromRow: integer;
  ToCol, ToRow: integer;
  Direction: integer;
  Attempts: integer;
begin
  Attempts := 0;

  repeat
    FromCol := Random(9) + 1;
    FromRow := Random(9) + 1;

    Direction := Random(4) + 1;

    ToCol := FromCol + DirectionCol[Direction];

    ToRow := FromRow + DirectionRow[Direction];

    Attempts := Attempts + 1;

    if IsValidMove(
      Board,
      FromCol,
      FromRow,
      ToCol,
      ToRow,
      AIPlayer
    ) then
    begin
      MakeMove(
        Board,
        FromCol,
        FromRow,
        ToCol,
        ToRow
      );

      Exit;
    end;

  until Attempts >= 500;
end;

procedure BasicAIMove(var Board: TBoard; AIPlayer: TPlayer);
var
  FromCol, FromRow: integer;
  ToCol, ToRow: integer;
  Direction: integer;
begin
  for FromRow := 1 to 9 do
  begin
    for FromCol := 1 to 9 do
    begin
      if Board[FromCol, FromRow].Owner = AIPlayer then
      begin
        for Direction := 1 to 4 do
        begin
          ToCol := FromCol + DirectionCol[Direction];

          ToRow := FromRow + DirectionRow[Direction];

          if IsValidMove(
            Board,
            FromCol,
            FromRow,
            ToCol,
            ToRow,
            AIPlayer
          ) then
          begin
            MakeMove(
              Board,
              FromCol,
              FromRow,
              ToCol,
              ToRow
            );

            Exit;
          end;
        end;
      end;
    end;
  end;
end;

function EvaluateBoard(Board: TBoard; AIPlayer: TPlayer): integer;
var
  Row, Col: integer;
  Score: integer;
begin
  Score := 0;

  for Row := 1 to 9 do
  begin
    for Col := 1 to 9 do
    begin
      if Board[Col, Row].Piece <> None then
      begin
        if Board[Col, Row].Owner = AIPlayer then
        begin
          Score := Score + PieceValue[Board[Col, Row].Piece];
        end
        else
        begin
          Score := Score - PieceValue[Board[Col, Row].Piece];
        end;
      end;
    end;
  end;

  EvaluateBoard := Score;
end;

function Minimax(Board: TBoard; Depth: integer; CurrentPlayer: TPlayer; AIPlayer: TPlayer; Alpha, Beta: integer): integer;
var
  FromCol, FromRow: integer;
  ToCol, ToRow: integer;
  Direction: integer;

  Value: integer;
  BestValue: integer;

  FromSquare: TSquare;
  ToSquare: TSquare;

  MoveFound: boolean;
begin
  if Depth <= 0 then
  begin
    Minimax := EvaluateBoard(Board, AIPlayer);

    Exit;
  end;

  MoveFound := False;

  (* AI prioritizes highest scoring moves *)
  if CurrentPlayer = AIPlayer then
  begin
    BestValue := -ScoreInfinity;

    for FromRow := 1 to 9 do
    begin
      for FromCol := 1 to 9 do
      begin
        if Board[FromCol, FromRow].Owner =
           CurrentPlayer then
        begin
          for Direction := 1 to 4 do
          begin
            ToCol := FromCol + DirectionCol[Direction];
            ToRow := FromRow + DirectionRow[Direction];

            if IsValidMove(
              Board,
              FromCol,
              FromRow,
              ToCol,
              ToRow,
              CurrentPlayer
            ) then
            begin
              MoveFound := True;

              (* save original value for restoration *)
              FromSquare := Board[FromCol, FromRow];
              ToSquare := Board[ToCol, ToRow];

              (* Simulate move to test scoring possibility*)
              MakeMove(
                Board,
                FromCol,
                FromRow,
                ToCol,
                ToRow
              );

              Value := Minimax(
                Board,
                Depth - 1,
                OpponentOf(CurrentPlayer),
                AIPlayer,
                Alpha,
                Beta
              );

              (* Restore board *)
              Board[FromCol, FromRow] := FromSquare;
              Board[ToCol, ToRow] := ToSquare;

              if Value > BestValue then
                BestValue := Value;

              if BestValue > Alpha then
                Alpha := BestValue;

              if Beta <= Alpha then
              begin
                Minimax := BestValue;
                Exit;
              end;
            end;
          end;
        end;
      end;
    end;

    if not MoveFound then
      BestValue := EvaluateBoard(Board, AIPlayer);

    Minimax := BestValue;
  end


  (* Minimize score to check against *)
  else
  begin
    BestValue := ScoreInfinity;

    for FromRow := 1 to 9 do
    begin
      for FromCol := 1 to 9 do
      begin
        if Board[FromCol, FromRow].Owner =
           CurrentPlayer then
        begin
          for Direction := 1 to 4 do
          begin
            ToCol := FromCol + DirectionCol[Direction];
            ToRow := FromRow + DirectionRow[Direction];

            if IsValidMove(
              Board,
              FromCol,
              FromRow,
              ToCol,
              ToRow,
              CurrentPlayer
            ) then
            begin
              MoveFound := True;

              (* Save OG position*)
              FromSquare := Board[FromCol, FromRow];
              ToSquare := Board[ToCol, ToRow];

              (* Simulate move *)
              MakeMove(
                Board,
                FromCol,
                FromRow,
                ToCol,
                ToRow
              );

              Value := Minimax(
                Board,
                Depth - 1,
                OpponentOf(CurrentPlayer),
                AIPlayer,
                Alpha,
                Beta
              );

              (* Restore *)
              Board[FromCol, FromRow] := FromSquare;
              Board[ToCol, ToRow] := ToSquare;

              if Value < BestValue then
                BestValue := Value;

              if BestValue < Beta then
                Beta := BestValue;

              if Beta <= Alpha then
              begin
                Minimax := BestValue;
                Exit;
              end;
            end;
          end;
        end;
      end;
    end;

    if not MoveFound then
      BestValue := EvaluateBoard(Board, AIPlayer);

    Minimax := BestValue;
  end;
end;

procedure MinimaxMove(var Board: TBoard; AIPlayer: TPlayer; Depth: integer);
var
  FromCol, FromRow: integer;
  ToCol, ToRow: integer;
  Direction: integer;
  BestFromCol, BestFromRow: integer;
  BestToCol, BestToRow: integer;
  Value: integer;
  BestValue: integer;
  FromSquare: TSquare;
  ToSquare: TSquare;
  MoveFound: boolean;
begin
  BestValue := -ScoreInfinity;
  MoveFound := False;
  BestFromCol := 0;
  BestFromRow := 0;
  BestToCol := 0;
  BestToRow := 0;

  for FromRow := 1 to 9 do
  begin
    for FromCol := 1 to 9 do
    begin
      if Board[FromCol, FromRow].Owner = AIPlayer then
      begin
        for Direction := 1 to 4 do
        begin
          ToCol := FromCol + DirectionCol[Direction];
          ToRow := FromRow + DirectionRow[Direction];

          if IsValidMove(
            Board,
            FromCol,
            FromRow,
            ToCol,
            ToRow,
            AIPlayer
          ) then
          begin
            MoveFound := True;

            (* Hold Board State*)
            FromSquare := Board[FromCol, FromRow];
            ToSquare := Board[ToCol, ToRow];

            (* Check move *)
            MakeMove(
              Board,
              FromCol,
              FromRow,
              ToCol,
              ToRow
            );

            Value := Minimax(
              Board,
              Depth - 1,
              OpponentOf(AIPlayer),
              AIPlayer,
              -ScoreInfinity,
              ScoreInfinity
            );

            (* Restore *)
            Board[FromCol, FromRow] := FromSquare;
            Board[ToCol, ToRow] := ToSquare;

            if Value > BestValue then
            begin
              BestValue := Value;
              BestFromCol := FromCol;
              BestFromRow := FromRow;
              BestToCol := ToCol;
              BestToRow := ToRow;
            end;
          end;
        end;
      end;
    end;
  end;

  (* Perform selected move *)
  if MoveFound then
  begin
    MakeMove(
      Board,
      BestFromCol,
      BestFromRow,
      BestToCol,
      BestToRow
    );
  end;
end;

procedure PlayAI(var Board: TBoard; DifficultyLevel: byte);
const
  AIPlayer = Gote;
begin
  case DifficultyLevel of
    (* Easy *)
    1: RandomMove(Board, AIPlayer);
    (* Medium *)
    2: BasicAIMove(Board, AIPlayer);
    (* Hard *)
    3: MinimaxMove(Board, AIPlayer, 3);

  end;
end;

end.