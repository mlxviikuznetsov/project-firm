unit ConsoleUI;

{ Вспомогательный модуль: ввод/вывод в консоли, рисование таблиц, меню. }
interface
uses
  Windows, SysUtils, DataTypes;
// Очистка экрана
procedure ClearScreen;
// Цветной вывод
procedure SetColor(FG: Byte);
procedure ResetColor;
// Горизонтальная линия
procedure DrawLine(Width: Integer; Ch: Char = '-');
// Шапка программы
procedure PrintHeader;
// Вывод главного меню
procedure PrintMainMenu;
// Чтение строки с подсказкой
function  PromptStr(const Prompt: string): string;
// Чтение целого числа с подсказкой и значением по умолчанию
function  PromptInt(const Prompt: string; Default: Integer): Integer;
// Чтение даты с подсказкой и значением по умолчанию
function  PromptDate(const Prompt: string; Default: TDateTime): TDateTime;
// Вывод таблицы сотрудников
procedure PrintEmployeeHeader;
procedure PrintEmployeeRow(Idx: Integer; const E: TEmployee);
// Вывод таблицы заданий
procedure PrintWorkHeader;
procedure PrintWorkRow(Idx: Integer; const W: TWork);
// Ожидание нажатия Enter
procedure PressEnter;
// Подтверждение (Y/N)
function  Confirm(const Msg: string): Boolean;
const
  // Цвета Windows Console
  CLR_DEFAULT  = 7;   // светло-серый
  CLR_HEADER   = 11;  // голубой
  CLR_ACCENT   = 14;  // жёлтый
  CLR_OK       = 10;  // зелёный
  CLR_ERROR    = 12;  // красный
  CLR_ROWALT   = 8;   // тёмно-серый для чётных строк
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
  WriteLn('  ПРОЕКТНАЯ ФИРМА -- Управление сотрудниками и заданиями');
  DrawLine(60, '=');
  ResetColor;
end;
procedure PrintMainMenu;
begin
  SetColor(CLR_ACCENT);
  WriteLn;
  WriteLn('  [ ГЛАВНОЕ МЕНЮ ]');
  ResetColor;
  WriteLn('  1.  Чтение данных из файла');
  WriteLn('  2.  Просмотр списков');
  WriteLn('  3.  Сортировка');
  WriteLn('  4.  Поиск');
  WriteLn('  5.  Добавление');
  WriteLn('  6.  Удаление');
  WriteLn('  7.  Редактирование');
  SetColor(CLR_HEADER);
  WriteLn('  8.  Отчёты по проектам (СФ)');
  ResetColor;
  WriteLn('  9.  Выход без сохранения');
  WriteLn('  10. Выход с сохранением');
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
// Таблица сотрудников
const EMP_FMT = ' %-4s | %-30s | %-20s | %-6s | %-6s';
procedure PrintEmployeeHeader;
begin
  SetColor(CLR_HEADER);
  WriteLn(Format(EMP_FMT, ['№', 'ФИО', 'Должность', 'Ч/сут', 'Рук.']));
  DrawLine(72);
  ResetColor;
end;
procedure PrintEmployeeRow(Idx: Integer; const E: TEmployee);
begin
  if Odd(Idx) then SetColor(CLR_ROWALT) else ResetColor;
  WriteLn(Format(EMP_FMT, [
    IntToStr(Idx),
    E.FullName,
    E.Position,
    IntToStr(E.WorkHours),
    IntToStr(E.BossCode)
  ]));
  ResetColor;
end;
// Таблица заданий
const WORK_FMT = ' %-3s | %-20s | %-22s | %-4s | %-10s | %-10s';
procedure PrintWorkHeader;
begin
  SetColor(CLR_HEADER);
  WriteLn(Format(WORK_FMT, [
    '№', 'Проект', 'Задание', 'Исп.', 'Выдано', 'Срок'
  ]));
  DrawLine(78);
  ResetColor;
end;
procedure PrintWorkRow(Idx: Integer; const W: TWork);
var
  Task: string;
  DaysLeft: Integer;
begin
  if Odd(Idx) then SetColor(CLR_ROWALT) else ResetColor;
  // Обрезаем задание для вывода в колонке
  Task := string(W.Task);
  if Length(Task) > 22 then Task := Copy(Task, 1, 19) + '...';
  DaysLeft := Trunc(W.Deadline - Now);
  // Подсвечиваем просроченные красным
  if DaysLeft < 0 then SetColor(CLR_ERROR)
  else if DaysLeft <= 7 then SetColor(CLR_ACCENT);
  WriteLn(Format(WORK_FMT, [
    IntToStr(Idx),
    W.ProjectName,
    Task,
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
  Write('  Нажмите Enter для продолжения...');
  ResetColor;
  ReadLn;
end;
function Confirm(const Msg: string): Boolean;
var S: string;
begin
  SetColor(CLR_ERROR);
  Write('  ' + Msg + ' (д/н): ');
  ResetColor;
  ReadLn(S);
  Result := (Trim(AnsiLowerCase(S)) = 'д') or (Trim(AnsiLowerCase(S)) = 'y');
end;
end.
