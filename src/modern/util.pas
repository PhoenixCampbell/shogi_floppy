unit util;

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
  TCapturedPieces = array[TPlayer, TPiece] of integer;
  TMove = record
    FromCol, FromRow, ToCol, ToRow: integer;
    Promote: boolean;
  end;

function GetStringInput: string;
function GetIntegerInput: integer;
function GetCharInput: char;
function StrToIntDef(S : string; Default : integer) : integer;
function InRange(Value, Min, Max: integer): Boolean;
function UpperString(S: string): string;
function PieceToChar(Piece: TPiece; Owner: TPlayer): char;
function CharToPiece(Symbol: char): TPiece;
function CanPromote(Piece: TPiece; FromRow, ToRow: integer; CurrentPlayer: TPlayer): boolean;
function MustPromote(Piece: TPiece; ToRow: integer; CurrentPlayer: TPlayer): boolean;
function PromotePiece(Piece: TPiece): TPiece;
function UnpromotePiece(Piece: TPiece): TPiece;
function IsInsideBoard(Col, Row: integer): boolean;
function IsValidDrop(
  var Board: TBoard;
  Piece: TPiece;
  Col, Row: integer;
  CurrentPlayer: TPlayer): boolean;
function IsValidMove(
  var Board: TBoard;
  FromCol, FromRow, ToCol, ToRow: integer;
  var CurrentPlayer: TPlayer): boolean;

procedure CenterText(Text: string);
procedure PauseForUser;
procedure WriteLine(Text: string; VerticalOffset: integer);
procedure HandleError(ErrorCode: integer);

implementation

function GetStringInput: string;
var
  Input: string;
begin
  Readln(Input);
  GetStringInput := Input;
end;

function GetIntegerInput: integer;
var
  Input: string;
  Value, ErrorCode: integer;
begin
  repeat
    Readln(Input);

    Val(Input, Value, ErrorCode);

    if ErrorCode <> 0 then
      Write('Invalid input. Please enter an integer: ');

  until ErrorCode = 0;

  GetIntegerInput := Value;
end;

function GetCharInput: char;
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

(* StrToIntDef does not exist apparently in turbo pascal 4.0 *)
function StrToIntDef(S : string; Default : integer) : integer;
var
  ResultValue, ErrorCode   : integer;
begin
  Val(S, ResultValue, ErrorCode);
  
  if ErrorCode = 0 then
    StrToIntDef := ResultValue
  else
    StrToIntDef := Default;
end;

function InRange(Value, Min, Max: integer): Boolean;
begin
  InRange := (Value >= Min) and (Value <= Max);
end;

function UpperString(S: string): string;
var
  i: integer;
begin
  for i := 1 to Length(S) do
    S[i] := UpCase(S[i]);
  UpperString := S;
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

function CharToPiece(Symbol: char): TPiece;
begin
  case UpCase(Symbol) of
    'P': CharToPiece := Pawn;
    'L': CharToPiece := Lance;
    'N': CharToPiece := Knight;
    'S': CharToPiece := SilverGeneral;
    'G': CharToPiece := GoldGeneral;
    'B': CharToPiece := Bishop;
    'R': CharToPiece := Rook;
    else CharToPiece := None;
  end;
end;

function CanPromote(Piece: TPiece; FromRow, ToRow: integer; CurrentPlayer: TPlayer): boolean;
begin
  CanPromote := False;

  if not (Piece in [Pawn, Lance, Knight, SilverGeneral, Bishop, Rook]) then
    Exit;

  if CurrentPlayer = Sente then
    CanPromote := (FromRow <= 3) or (ToRow <= 3)
  else if CurrentPlayer = Gote then
    CanPromote := (FromRow >= 7) or (ToRow >= 7);
end;

function MustPromote(Piece: TPiece; ToRow: integer; CurrentPlayer: TPlayer): boolean;
begin
  MustPromote := False;

  case Piece of
    Pawn, Lance:
      if CurrentPlayer = Sente then
        MustPromote := (ToRow = 1)
      else if CurrentPlayer = Gote then
        MustPromote := (ToRow = 9);

    Knight:
      if CurrentPlayer = Sente then
        MustPromote := (ToRow <= 2)
      else if CurrentPlayer = Gote then
        MustPromote := (ToRow >= 8);
  end;
end;

function PromotePiece(Piece: TPiece): TPiece;
begin
  case Piece of
    Pawn: PromotePiece := PromotedPawn;
    Lance: PromotePiece := PromotedLance;
    Knight: PromotePiece := PromotedKnight;
    SilverGeneral: PromotePiece := PromotedSilverGeneral;
    Bishop: PromotePiece := DragonHorse;
    Rook: PromotePiece := DragonKing;
    else PromotePiece := Piece;
  end;
end;

function UnpromotePiece(Piece: TPiece): TPiece;
begin
  case Piece of
    PromotedPawn: UnpromotePiece := Pawn;
    PromotedLance: UnpromotePiece := Lance;
    PromotedKnight: UnpromotePiece := Knight;
    PromotedSilverGeneral: UnpromotePiece := SilverGeneral;
    DragonHorse: UnpromotePiece := Bishop;
    DragonKing: UnpromotePiece := Rook;
    else UnpromotePiece := Piece;
  end;
end;

function IsInsideBoard(Col, Row: integer): boolean;
begin
  IsInsideBoard := (Col >= 1) and (Col <= 9) and (Row >= 1) and (Row <= 9);
end;

function IsValidDrop(
  var Board: TBoard;
  Piece: TPiece;
  Col, Row: integer;
  CurrentPlayer: TPlayer): boolean;
var
  ExistingRow: integer;
begin
  IsValidDrop := False;

  if not IsInsideBoard(Col, Row) then
    Exit;
  if Board[Col, Row].Piece <> None then
    Exit;
  if not (Piece in [Pawn, Lance, Knight, SilverGeneral, GoldGeneral, Bishop, Rook]) then
    Exit;

  if Piece in [Pawn, Lance] then
  begin
    if (CurrentPlayer = Sente) and (Row = 1) then
      Exit;
    if (CurrentPlayer = Gote) and (Row = 9) then
      Exit;
  end;

  if Piece = Knight then
  begin
    if (CurrentPlayer = Sente) and (Row <= 2) then
      Exit;
    if (CurrentPlayer = Gote) and (Row >= 8) then
      Exit;
  end;

  if Piece = Pawn then
    for ExistingRow := 1 to 9 do
      if (Board[Col, ExistingRow].Piece = Pawn) and
         (Board[Col, ExistingRow].Owner = CurrentPlayer) then
        Exit;

  IsValidDrop := True;
end;

function IsValidMove(
  var Board: TBoard;
  FromCol, FromRow, ToCol, ToRow: integer;
  var CurrentPlayer: TPlayer): boolean;
var
  i: integer;
  MoveValid: boolean;
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

        MoveValid := IsValidMove;

        (* check for blocking pieces *)
        if MoveValid then
        begin
          if CurrentPlayer = Sente then
          begin
            for i := ToRow + 1 to FromRow - 1 do
              if Board[FromCol, i].Piece <> None then
                MoveValid := False;
          end
          else
          begin
            for i := FromRow + 1 to ToRow - 1 do
              if Board[FromCol, i].Piece <> None then
                MoveValid := False;
          end;
        end;

        isValidMove := MoveValid;
      end;

    Knight:
      begin
        (* two forward, one left/right *)
        if CurrentPlayer = Sente then
          IsValidMove := (Abs(ToCol - FromCol) = 1) and (ToRow = FromRow - 2)
        else
          IsValidMove := (Abs(ToCol - FromCol) = 1) and (ToRow = FromRow + 2);
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
    (* maybe make a function for gold so all pieces that move similarly use same logic *)
    Bishop:
      begin
        (* any number of steps diagonally*)
        if Abs(ToCol - FromCol) = Abs(ToRow - FromRow) then
        begin
          IsValidMove := True;

          (* Check for blocking pieces *)
          if ToCol > FromCol then
          begin
            if ToRow > FromRow then
            begin
              (* Moving diagonally down-right *)
              for i := 1 to ToCol - FromCol - 1 do
                if Board[FromCol + i, FromRow + i].Piece <> None then
                  IsValidMove := False;
            end
            else
            begin
              (* Moving diagonally up-right *)
              for i := 1 to ToCol - FromCol - 1 do
                if Board[FromCol + i, FromRow - i].Piece <> None then
                  IsValidMove := False;
            end;
          end
          else
          begin
            if ToRow > FromRow then
            begin
              (* Moving diagonally down-left *)
              for i := 1 to FromCol - ToCol - 1 do
                if Board[FromCol - i, FromRow + i].Piece <> None then
                  IsValidMove := False;
            end
            else
            begin
              (* Moving diagonally up-left *)
              for i := 1 to FromCol - ToCol - 1 do
                if Board[FromCol - i, FromRow - i].Piece <> None then
                  IsValidMove := False;
            end;
          end;
        end;
      end;

    Rook:
      begin
        (* vertical or horizontal any number of steps*)
        if (ToCol = FromCol) or (ToRow = FromRow) then
        begin
          IsValidMove := True;

          (* Check for blocking pieces *)
          if ToCol = FromCol then
          begin
            (* Vertical movement *)
            if ToRow > FromRow then
            begin
              (* Moving down *)
              for i := FromRow + 1 to ToRow - 1 do
                if Board[FromCol, i].Piece <> None then
                  IsValidMove := False;
            end
            else
            begin
              (* Moving up *)
              for i := ToRow + 1 to FromRow - 1 do
                if Board[FromCol, i].Piece <> None then
                  IsValidMove := False;
            end;
          end
          else
          begin
            (* Horizontal movement *)
            if ToCol > FromCol then
            begin
              (* Moving right *)
              for i := FromCol + 1 to ToCol - 1 do
                if Board[i, FromRow].Piece <> None then
                  IsValidMove := False;
            end
            else
            begin
              (* Moving left *)
              for i := ToCol + 1 to FromCol - 1 do
                if Board[i, FromRow].Piece <> None then
                  IsValidMove := False;
            end;
          end;
        end;
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
        if (Abs(ToCol - FromCol) = Abs(ToRow - FromRow)) or
          ((Abs(ToCol - FromCol) <= 1) and (Abs(ToRow - FromRow) <= 1)) then
        begin
          IsValidMove := True;

          (* Check for blocking pieces for diagonal moves *)
          if Abs(ToCol - FromCol) = Abs(ToRow - FromRow) then
          begin
            if ToCol > FromCol then
            begin
              if ToRow > FromRow then
              begin
                (* Moving diagonally down-right *)
                for i := 1 to ToCol - FromCol - 1 do
                  if Board[FromCol + i, FromRow + i].Piece <> None then
                    IsValidMove := False;
              end
              else
              begin
                (* Moving diagonally up-right *)
                for i := 1 to ToCol - FromCol - 1 do
                  if Board[FromCol + i, FromRow - i].Piece <> None then
                    IsValidMove := False;
              end;
            end
            else
            begin
              if ToRow > FromRow then
              begin
                (* Moving diagonally down-left *)
                for i := 1 to FromCol - ToCol - 1 do
                  if Board[FromCol - i, FromRow + i].Piece <> None then
                    IsValidMove := False;
              end
              else
              begin
                (* Moving diagonally up-left *)
                for i := 1 to FromCol - ToCol - 1 do
                  if Board[FromCol - i, FromRow - i].Piece <> None then
                    IsValidMove := False;
              end;
            end;
          end;
        end;
      end;

    DragonKing:
      begin
        (* moves like Rook and one step diagonally *)
        if (ToCol = FromCol) or (ToRow = FromRow) or
          ((Abs(ToCol - FromCol) <= 1) and (Abs(ToRow - FromRow) <= 1)) then
        begin
          IsValidMove := True;

          (* Check for blocking pieces for orthogonal moves *)
          if ToCol = FromCol then
          begin
            (* Vertical movement *)
            if ToRow > FromRow then
            begin
              (* Moving down *)
              for i := FromRow + 1 to ToRow - 1 do
                if Board[FromCol, i].Piece <> None then
                  IsValidMove := False;
            end
            else
            begin
              (* Moving up *)
              for i := ToRow + 1 to FromRow - 1 do
                if Board[FromCol, i].Piece <> None then
                  IsValidMove := False;
            end;
          end
          else
          begin
            (* Horizontal movement *)
            if ToCol > FromCol then
            begin
              (* Moving right *)
              for i := FromCol + 1 to ToCol - 1 do
                if Board[i, FromRow].Piece <> None then
                  IsValidMove := False;
            end
            else
            begin
              (* Moving left *)
              for i := ToCol + 1 to FromCol - 1 do
                if Board[i, FromRow].Piece <> None then
                  IsValidMove := False;
            end;
          end;
        end;
      end;
    else
      IsValidMove := False;
  end;
end;

procedure CenterText(Text: string);
var
  ScreenWidth: integer;
begin
  ScreenWidth := 80;

  GotoXY((ScreenWidth div 2) - (Length(Text) div 2), 12);

  Writeln(Text);
end;

procedure PauseForUser;
begin
  WriteLn;
  Write('Press any key to continue');
  Readln;
end;

procedure WriteLine(Text: string; VerticalOffset: integer);
var
  ScreenWidth: integer;
begin
  ScreenWidth := 80;

  GotoXY((ScreenWidth div 2) - (Length(Text) div 2), 12 + VerticalOffset);

  Writeln(Text);
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