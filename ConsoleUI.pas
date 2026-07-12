unit ConsoleUI;

{ Helper module: console I/O, table drawing, menus. }
interface
uses
  Windows, SysUtils, DataTypes;
// Clear screen
procedure ClearScreen;
// Colored output
procedure SetColor(FG: Byte);
procedure ResetColor;
// Horizontal line
procedure DrawLine(Width: Integer; Ch: Char = '-');
// Program header
procedure PrintHeader;
// Print main menu
procedure PrintMainMenu;
// Read a string with a prompt
function  PromptStr(const Prompt: string): string;
// Read an integer with a prompt and default value
function  PromptInt(const Prompt: string; Default: Integer): Integer;
// Read a date with a prompt and default value
function  PromptDate(const Prompt: string; Default: TDateTime): TDateTime;
// Truncate an arbitrary text field for fixed-width column display
function TruncateStr(const S: string; MaxLen: Integer): string;
// Print employee table
procedure PrintEmployeeHeader;
procedure PrintEmployeeRow(Idx: Integer; const E: TEmployee);
// Print work/task table
procedure PrintWorkHeader;
procedure PrintWorkRow(Idx: Integer; const W: TWork);
// Wait for Enter key press
procedure PressEnter;
// Confirmation (Y/N)
function  Confirm(const Msg: string): Boolean;
const
  // Windows Console colors
  CLR_DEFAULT  = 7;   // light gray
  CLR_HEADER   = 11;  // light blue
  CLR_ACCENT   = 14;  // yellow
  CLR_OK       = 10;  // green
  CLR_ERROR    = 12;  // red
  CLR_ROWALT   = 8;   // dark gray for alternating rows
implementation
procedure ClearScreen;
var
  hOut: THandle;
  csbi: TConsoleScreenBufferInfo;
  dwConSize, dwWritten: DWORD;
  coordScreen: TCoord;
begin
  hOut := GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleScreenBufferInfo(hOut, csbi);
  dwConSize := csbi.dwSize.X * csbi.dwSize.Y;
  coordScreen.X := 0; coordScreen.Y := 0;
  FillConsoleOutputCharacter(hOut, ' ', dwConSize, coordScreen, dwWritten);
  FillConsoleOutputAttribute(hOut, csbi.wAttributes,
                             dwConSize, coordScreen, dwWritten);
  SetConsoleCursorPosition(hOut, coordScreen);
end;
procedure SetColor(FG: Byte);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FG);
end;
procedure ResetColor;
begin
  SetColor(CLR_DEFAULT);
end;
procedure DrawLine(Width: Integer; Ch: Char = '-');
var i: Integer;
begin
  for i := 1 to Width do Write(Ch);
  WriteLn;
end;
procedure PrintHeader;
begin
  ClearScreen;
  SetColor(CLR_HEADER);
  DrawLine(60, '=');
  WriteLn('  PROJECT FIRM -- Employee and Task Management');
  DrawLine(60, '=');
  ResetColor;
end;
procedure PrintMainMenu;
begin
  SetColor(CLR_ACCENT);
  WriteLn;
  WriteLn('  [ MAIN MENU ]');
  ResetColor;
  WriteLn('  1.  Read data from file');
  WriteLn('  2.  View lists');
  WriteLn('  3.  Sort');
  WriteLn('  4.  Search');
  WriteLn('  5.  Add');
  WriteLn('  6.  Delete');
  WriteLn('  7.  Edit');
  SetColor(CLR_HEADER);
  WriteLn('  8.  Project reports (SF)');
  ResetColor;
  WriteLn('  9.  Exit without saving');
  WriteLn('  10. Exit with saving');
  WriteLn;
end;
function PromptStr(const Prompt: string): string;
begin
  SetColor(CLR_ACCENT);
  Write('  ' + Prompt + ': ');
  ResetColor;
  ReadLn(Result);
  Result := Trim(Result);
end;
function PromptInt(const Prompt: string; Default: Integer): Integer;
var S: string;
begin
  SetColor(CLR_ACCENT);
  Write('  ' + Prompt + ' [' + IntToStr(Default) + ']: ');
  ResetColor;
  ReadLn(S);
  S := Trim(S);
  if S = '' then Result := Default
  else Result := StrToIntDef(S, Default);
end;
function PromptDate(const Prompt: string; Default: TDateTime): TDateTime;
var S: string;
begin
  SetColor(CLR_ACCENT);
  Write('  ' + Prompt + ' [' + DateToStr(Default) + ']: ');
  ResetColor;
  ReadLn(S);
  S := Trim(S);
  if S = '' then Result := Default
  else
  begin
    try Result := StrToDate(S);
    except Result := Default;
    end;
  end;
end;
function TruncateStr(const S: string; MaxLen: Integer): string;
begin
  if Length(S) > MaxLen then
    Result := Copy(S, 1, MaxLen - 3) + '...'
  else
    Result := S;
end;
// Employee table
const EMP_FMT = ' %-4s | %-30s | %-20s | %-7s | %-6s';
procedure PrintEmployeeHeader;
begin
  SetColor(CLR_HEADER);
  WriteLn(Format(EMP_FMT, ['#', 'Full Name', 'Position', 'Hrs/day', 'Boss']));
  DrawLine(80);
  ResetColor;
end;
procedure PrintEmployeeRow(Idx: Integer; const E: TEmployee);
begin
  if Odd(Idx) then SetColor(CLR_ROWALT) else ResetColor;
  WriteLn(Format(EMP_FMT, [
    IntToStr(Idx),
    TruncateStr(string(E.FullName), 30),
    TruncateStr(string(E.Position), 20),
    IntToStr(E.WorkHours),
    IntToStr(E.BossCode)
  ]));
  ResetColor;
end;
// Task table
const WORK_FMT = ' %-3s | %-20s | %-22s | %-5s | %-10s | %-10s';
procedure PrintWorkHeader;
begin
  SetColor(CLR_HEADER);
  WriteLn(Format(WORK_FMT, [
    '#', 'Project', 'Task', 'Exec.', 'Issued', 'Deadline'
  ]));
  DrawLine(86);
  ResetColor;
end;
procedure PrintWorkRow(Idx: Integer; const W: TWork);
var
  DaysLeft: Integer;
begin
  if Odd(Idx) then SetColor(CLR_ROWALT) else ResetColor;
  DaysLeft := Trunc(W.Deadline - Now);
  // Highlight overdue in red
  if DaysLeft < 0 then SetColor(CLR_ERROR)
  else if DaysLeft <= 7 then SetColor(CLR_ACCENT);
  WriteLn(Format(WORK_FMT, [
    IntToStr(Idx),
    TruncateStr(string(W.ProjectName), 20),
    TruncateStr(string(W.Task), 22),
    IntToStr(W.ExecutorCode),
    DateToStr(W.IssueDate),
    DateToStr(W.Deadline)
  ]));
  ResetColor;
end;
procedure PressEnter;
begin
  WriteLn;
  SetColor(CLR_ACCENT);
  Write('  Press Enter to continue...');
  ResetColor;
  ReadLn;
end;
function Confirm(const Msg: string): Boolean;
var S: string;
begin
  SetColor(CLR_ERROR);
  Write('  ' + Msg + ' (y/n): ');
  ResetColor;
  ReadLn(S);
  Result := (Trim(AnsiLowerCase(S)) = 'y');
end;
end.

