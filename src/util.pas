unit util;

interface

uses crt;

function GetStringInput: string;
function GetIntegerInput: Integer;
function GetCharInput: Char;
function InRange(Value, Min, Max: Integer): Boolean;
procedure CenterText(Text: string);
procedure PauseForUser;
procedure WriteLine(Text: string; VerticalOffset: integer);

implementation

function GetStringInput: string;
var
  Input: string;
begin
  Readln(Input);
  GetStringInput := Input;
end;

function GetIntegerInput: Integer;
var
  Input: string;
  Value: Integer;
  ErrorCode: Integer;
begin
  repeat
    Readln(Input);

    Val(Input, Value, ErrorCode);

    if ErrorCode <> 0 then
      Write('Invalid input. Please enter an integer: ');

  until ErrorCode = 0;

  GetIntegerInput := Value;
end;

function GetCharInput: Char;
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

function InRange(Value, Min, Max: Integer): Boolean;
begin
  InRange := (Value >= Min) and (Value <= Max);
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
  ReadKey;
end;

procedure WriteLine(Text: string; VerticalOffset: integer);
var
  ScreenWidth: integer;
begin
  ScreenWidth := 80;

  GotoXY((ScreenWidth div 2) - (Length(Text) div 2), 12 + VerticalOffset);

  Writeln(Text);
end;
end.