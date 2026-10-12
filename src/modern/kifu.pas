unit kifu;

interface

uses util;

const
  MaxKifuMoves = 512;

type
  TKifuMove = record
    Player: TPlayer;
    IsDrop: boolean;
    FromCol, FromRow, ToCol, ToRow: integer;
    Piece: TPiece;
    Promote: boolean;
  end;
  TKifuMoveList = array[1..MaxKifuMoves] of TKifuMove;

function LoadKifu(
  FileName: string;
  var Moves: TKifuMoveList;
  var MoveCount: integer): boolean;
function ApplyKifuMove(
  var Board: TBoard;
  var CurrentPlayer: TPlayer;
  var CapturedPieces: TCapturedPieces;
  Move: TKifuMove;
  var ErrorText: string): boolean;

implementation

function CsaPiece(Code: string): TPiece;
begin
  CsaPiece := None;
  if Code = 'FU' then CsaPiece := Pawn
  else if Code = 'KY' then CsaPiece := Lance
  else if Code = 'KE' then CsaPiece := Knight
  else if Code = 'GI' then CsaPiece := SilverGeneral
  else if Code = 'KI' then CsaPiece := GoldGeneral
  else if Code = 'KA' then CsaPiece := Bishop
  else if Code = 'HI' then CsaPiece := Rook
  else if Code = 'OU' then CsaPiece := King
  else if Code = 'TO' then CsaPiece := PromotedPawn
  else if Code = 'NY' then CsaPiece := PromotedLance
  else if Code = 'NK' then CsaPiece := PromotedKnight
  else if Code = 'NG' then CsaPiece := PromotedSilverGeneral
  else if Code = 'UM' then CsaPiece := DragonHorse
  else if Code = 'RY' then CsaPiece := DragonKing;
end;

function LoadKifu(
  FileName: string;
  var Moves: TKifuMoveList;
  var MoveCount: integer): boolean;
var
  MatchFile: Text;
  Token, UpperToken: string[16];
  ErrorCode: integer;
  MovesMode, InComment, TokenOverflow: boolean;
  Ch: char;
  Move: TKifuMove;
  UsIPlayer, CsaPlayer: TPlayer;
  PieceCode: string;
  function AddMove: boolean;
  begin
    AddMove := False;
    if MoveCount >= MaxKifuMoves then
      Exit;
    MoveCount := MoveCount + 1;
    Moves[MoveCount] := Move;
    AddMove := True;
  end;
  function ParseUsi(TokenText: string; Player: TPlayer): boolean;
  var
    SourceFile, TargetFile: integer;
    SourceRank, TargetRank: char;
  begin
    ParseUsi := False;
    TokenText := UpperString(TokenText);
    Move.Player := Player;
    Move.Piece := None;
    Move.IsDrop := False;
    Move.Promote := False;

    if (Length(TokenText) = 4) and (TokenText[2] = '*') then
    begin
      Move.Piece := CharToPiece(TokenText[1]);
      Val(TokenText[3], TargetFile, ErrorCode);
      if ErrorCode <> 0 then Exit;
      Move.ToCol := 10 - TargetFile;
      TargetRank := TokenText[4];
      Move.IsDrop := True;
      Move.FromCol := 0;
      Move.FromRow := 0;
    end
    else if (Length(TokenText) = 4) or (Length(TokenText) = 5) then
    begin
      Val(TokenText[1], SourceFile, ErrorCode);
      if ErrorCode <> 0 then Exit;
      SourceRank := TokenText[2];
      Val(TokenText[3], TargetFile, ErrorCode);
      if ErrorCode <> 0 then Exit;
      TargetRank := TokenText[4];
      Move.FromCol := 10 - SourceFile;
      Move.FromRow := Ord(SourceRank) - Ord('A') + 1;
      Move.Promote := (Length(TokenText) = 5) and (TokenText[5] = '+');
      if (Length(TokenText) = 5) and not Move.Promote then Exit;
    end
    else
      Exit;

    Move.ToCol := 10 - TargetFile;
    Move.ToRow := Ord(TargetRank) - Ord('A') + 1;
    if not (InRange(Move.ToCol, 1, 9) and InRange(Move.ToRow, 1, 9)) then
      Exit;
    if Move.IsDrop then
    begin
      if Move.Piece = None then Exit;
    end
    else if not (InRange(Move.FromCol, 1, 9) and
                 InRange(Move.FromRow, 1, 9)) then
      Exit;
    ParseUsi := True;
  end;
  function ParseCsa(TokenText: string): boolean;
  var
    FromFile, FromRank, ToFile, ToRank: integer;
  begin
    ParseCsa := False;
    if Length(TokenText) < 7 then Exit;
    if (TokenText[1] <> '+') and (TokenText[1] <> '-') then Exit;
    CsaPlayer := Sente;
    if TokenText[1] = '-' then CsaPlayer := Gote;
    Val(Copy(TokenText, 2, 1), FromFile, ErrorCode);
    if ErrorCode <> 0 then Exit;
    Val(Copy(TokenText, 3, 1), FromRank, ErrorCode);
    if ErrorCode <> 0 then Exit;
    Val(Copy(TokenText, 4, 1), ToFile, ErrorCode);
    if ErrorCode <> 0 then Exit;
    Val(Copy(TokenText, 5, 1), ToRank, ErrorCode);
    if ErrorCode <> 0 then Exit;
    PieceCode := Copy(UpperString(TokenText), 6, 2);
    Move.Player := CsaPlayer;
    Move.ToCol := 10 - ToFile;
    Move.ToRow := ToRank;
    Move.Piece := CsaPiece(PieceCode);
    Move.Promote := Move.Piece in [PromotedPawn, PromotedLance,
      PromotedKnight, PromotedSilverGeneral, DragonHorse, DragonKing];
    Move.IsDrop := (FromFile = 0) and (FromRank = 0);
    if Move.IsDrop then
      Move.FromCol := 0
    else
      Move.FromCol := 10 - FromFile;
    Move.FromRow := FromRank;
    if Move.Piece = None then Exit;
    if not (InRange(ToFile, 1, 9) and InRange(ToRank, 1, 9)) then Exit;
    if Move.IsDrop then
    begin
      Move.Piece := UnpromotePiece(Move.Piece);
      Move.Promote := False;
    end
    else if not (InRange(FromFile, 1, 9) and InRange(FromRank, 1, 9)) then
      Exit;
    ParseCsa := True;
  end;
  procedure ProcessToken;
  begin
    if (Token <> '') and not TokenOverflow then
    begin
      UpperToken := UpperString(Token);
      if UpperToken = 'POSITION' then
        MovesMode := False
      else if UpperToken = 'MOVES' then
        MovesMode := True
      else if ParseCsa(Token) then
      begin
        if not AddMove then
          MoveCount := MaxKifuMoves + 1;
      end
      else if MovesMode and ParseUsi(Token, UsIPlayer) then
      begin
        if not AddMove then
          MoveCount := MaxKifuMoves + 1
        else if UsIPlayer = Sente then
          UsIPlayer := Gote
        else
          UsIPlayer := Sente;
      end;
    end;
    Token := '';
    TokenOverflow := False;
  end;
begin
  LoadKifu := False;
  MoveCount := 0;
  Assign(MatchFile, FileName);
  {$I-}
  Reset(MatchFile);
  ErrorCode := IOResult;
  {$I+}
  if ErrorCode <> 0 then Exit;

  MovesMode := True;
  InComment := False;
  TokenOverflow := False;
  UsIPlayer := Sente;
  while not Eof(MatchFile) do
  begin
    if Eoln(MatchFile) then
    begin
      ProcessToken;
      InComment := False;
      ReadLn(MatchFile);
    end
    else
    begin
      Read(MatchFile, Ch);
      if not InComment then
      begin
        if (Ch = '#') or (Ch = ';') then
        begin
          ProcessToken;
          InComment := True;
        end
        else if Ch <= ' ' then
          ProcessToken
        else if Length(Token) < 16 then
          Token := Token + Ch
        else
          TokenOverflow := True;
      end
    end;
    if MoveCount > MaxKifuMoves then
    begin
      Close(MatchFile);
      MoveCount := 0;
      Exit;
    end;
  end;
  ProcessToken;
  if MoveCount > MaxKifuMoves then
  begin
    Close(MatchFile);
    MoveCount := 0;
    Exit;
  end;
  Close(MatchFile);
  LoadKifu := MoveCount > 0;
end;

function ApplyKifuMove(
  var Board: TBoard;
  var CurrentPlayer: TPlayer;
  var CapturedPieces: TCapturedPieces;
  Move: TKifuMove;
  var ErrorText: string): boolean;
var
  MovingPiece, ExpectedPiece, CapturedPiece: TPiece;
  SimulatedBoard: TBoard;
begin
  ApplyKifuMove := False;
  ErrorText := 'Illegal move in kifu.';
  if Move.Player <> CurrentPlayer then
  begin
    ErrorText := 'Kifu side-to-move does not match the position.';
    Exit;
  end;

  if Move.IsDrop then
  begin
    if not IsValidDrop(Board, Move.Piece, Move.ToCol, Move.ToRow,
        CurrentPlayer) then Exit;
    SimulatedBoard := Board;
    SimulatedBoard[Move.ToCol, Move.ToRow].Piece := Move.Piece;
    SimulatedBoard[Move.ToCol, Move.ToRow].Owner := CurrentPlayer;
    if IsInCheck(SimulatedBoard, CurrentPlayer) then Exit;
    if (Move.Piece = Pawn) and IsPawnDropMate(
        Board, Move.ToCol, Move.ToRow, CurrentPlayer, CapturedPieces) then Exit;
    Board[Move.ToCol, Move.ToRow].Piece := Move.Piece;
    Board[Move.ToCol, Move.ToRow].Owner := CurrentPlayer;
    CapturedPieces[CurrentPlayer, Move.Piece] :=
      CapturedPieces[CurrentPlayer, Move.Piece] - 1;
  end
  else
  begin
    MovingPiece := Board[Move.FromCol, Move.FromRow].Piece;
    if Board[Move.FromCol, Move.FromRow].Owner <> CurrentPlayer then Exit;
    if Move.Promote and (Move.Piece = MovingPiece) then
      Move.Promote := False;
    if Move.Promote and not CanPromote(MovingPiece, Move.FromRow, Move.ToRow,
        CurrentPlayer) then Exit;
    if MustPromote(MovingPiece, Move.ToRow, CurrentPlayer) and
        not Move.Promote then Exit;
    if Move.Piece <> None then
    begin
      ExpectedPiece := MovingPiece;
      if Move.Promote then ExpectedPiece := PromotePiece(MovingPiece);
      if Move.Piece <> ExpectedPiece then Exit;
    end;
    if not IsLegalMove(Board, Move.FromCol, Move.FromRow, Move.ToCol,
        Move.ToRow, CurrentPlayer, Move.Promote) then Exit;
    CapturedPiece := Board[Move.ToCol, Move.ToRow].Piece;
    if CapturedPiece <> None then
    begin
      CapturedPiece := UnpromotePiece(CapturedPiece);
      CapturedPieces[CurrentPlayer, CapturedPiece] :=
        CapturedPieces[CurrentPlayer, CapturedPiece] + 1;
    end;
    if Move.Promote then
      MovingPiece := PromotePiece(MovingPiece);
    Board[Move.ToCol, Move.ToRow].Piece := MovingPiece;
    Board[Move.ToCol, Move.ToRow].Owner := CurrentPlayer;
    Board[Move.FromCol, Move.FromRow].Piece := None;
    Board[Move.FromCol, Move.FromRow].Owner := NoPlayer;
  end;
  if CurrentPlayer = Sente then
    CurrentPlayer := Gote
  else
    CurrentPlayer := Sente;
  ApplyKifuMove := True;
end;

end.