unit util;

interface

uses crt;

function GetStringInput: string;
function GetIntegerInput: integer;
function GetCharInput: char;
function StrToIntDef(S : string; Default : integer) : integer;
function InRange(Value, Min, Max: integer): Boolean;
function UpperString(const S: string): string;
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

function UpperString(const S: string): string;
var
  i: integer;
begin
  for i := 1 to Length(S) do
    S[i] := UpCase(S[i]);
  UpperString := S;
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