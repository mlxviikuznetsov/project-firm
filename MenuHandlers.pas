unit MenuHandlers;

{ Обработчики всех пунктов меню.
  Каждая процедура соответствует одному пункту и полностью самодостаточна. }

interface

uses
  DataTypes, EmployeeList, WorkList, FileIO, ConsoleUI, SysUtils;

procedure DoReadFromFile;  // 1
procedure DoView;          // 2
procedure DoSort;          // 3
procedure DoSearch;        // 4
procedure DoAdd;           // 5
procedure DoDelete;        // 6
procedure DoEdit;          // 7
procedure DoReports;       // 8
procedure DoExitNoSave;    // 9
procedure DoExitSave;      // 10

implementation

{ Внутренние вспомогательные процедуры }

procedure ShowEmployees(Head: PEmployeeNode);
var
  Cur: PEmployeeNode;
  i: Integer;
begin
  if Head = nil then
  begin
    SetColor(CLR_ERROR);
    WriteLn('  Список сотрудников пуст.');
    ResetColor;
    Exit;
  end;
  PrintEmployeeHeader;
  Cur := Head;
  i := 1;
  while Cur <> nil do
  begin
    PrintEmployeeRow(i, Cur^.Data);
    Inc(i);
    Cur := Cur^.Next;
  end;
  DrawLine(72);
  SetColor(CLR_OK);
  WriteLn('  Итого сотрудников: ', i - 1);
  ResetColor;
end;

procedure ShowWorks(Head: PWorkNode);
var
  Cur: PWorkNode;
  i: Integer;
begin
  if Head = nil then
  begin
    SetColor(CLR_ERROR);
    WriteLn('  Список заданий пуст.');
    ResetColor;
    Exit;
  end;
  PrintWorkHeader;
  Cur := Head;
  i := 1;
  while Cur <> nil do
  begin
    PrintWorkRow(i, Cur^.Data);
    Inc(i);
    Cur := Cur^.Next;
  end;
  DrawLine(78);
  SetColor(CLR_OK);
  WriteLn('  Итого заданий: ', i - 1);
  ResetColor;
  WriteLn('  (!) Красный = просрочено, Жёлтый = срок <= 7 дней');
end;

// Ввод данных сотрудника
function InputEmployee(const Defaults: TEmployee; IsNew: Boolean): TEmployee;
begin
  Result := Defaults;
  if IsNew then
    Result.Code := PromptInt('Код сотрудника', Defaults.Code);
  Result.FullName := ShortString(PromptStr('ФИО'));
  if Result.FullName = '' then Result.FullName := Defaults.FullName;
  Result.Position := ShortString(PromptStr('Должность'));
  if Result.Position = '' then Result.Position := Defaults.Position;
  Result.WorkHours := PromptInt('Рабочих часов в сутки', Defaults.WorkHours);
  Result.BossCode := PromptInt('Код руководителя', Defaults.BossCode);
end;

// Ввод данных задания
function InputWork(const Defaults: TWork; IsNew: Boolean): TWork;
begin
  Result := Defaults;
  Result.ProjectName := ShortString(PromptStr('Название проекта'));
  if Result.ProjectName = '' then Result.ProjectName := Defaults.ProjectName;
  Result.Task := ShortString(PromptStr('Задание'));
  if Result.Task = '' then Result.Task := Defaults.Task;
  Result.ExecutorCode := PromptInt('Код исполнителя', Defaults.ExecutorCode);
  Result.BossCode := PromptInt('Код руководителя', Defaults.BossCode);
  Result.IssueDate := PromptDate('Дата выдачи (дд.мм.гггг)',
                                 Defaults.IssueDate);
  Result.Deadline := PromptDate('Срок выполнения (дд.мм.гггг)',
                                Defaults.Deadline);
end;

{ Пункт 1. Чтение данных из файла }
procedure DoReadFromFile;
begin
  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 1. ЧТЕНИЕ ДАННЫХ ИЗ ФАЙЛА ]');
  ResetColor;
  WriteLn;
  WriteLn('  Загрузка из employees.dat и works.dat...');
  LoadFromFiles;
  WriteLn;
  SetColor(CLR_OK);
  WriteLn('  Загружено сотрудников : ', EmpCount);
  WriteLn('  Загружено заданий     : ', WorkCount);
  ResetColor;
  PressEnter;
end;

{ Пункт 2. Просмотр списков }
procedure DoView;
var Choice: string;
begin
  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 4. ПРОСМОТР СПИСКОВ ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- Просмотр списка сотрудников');
  WriteLn('  2 -- Просмотр списка заданий');
  WriteLn('  0 -- Назад');
  WriteLn;
  Choice := PromptStr('Выбор');
  if Choice = '1' then
  begin
    PrintHeader;
    SetColor(CLR_ACCENT);
    WriteLn('  [ 2. СПИСОК СОТРУДНИКОВ ]');
    ResetColor;
    WriteLn;
    ShowEmployees(EmpHead);
  end
  else if Choice = '2' then
  begin
    PrintHeader;
    SetColor(CLR_ACCENT);
    WriteLn('  [ 3. СПИСОК ЗАДАНИЙ ]');
    ResetColor;
    WriteLn;
    ShowWorks(WorkHead);
  end;
  if Choice <> '0' then PressEnter;
end;

{ Пункт 3. Сортировка }
procedure DoSort;
var Choice: string;
begin
  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 4. СОРТИРОВКА ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- Сотрудников по ФИО (А->Я)');
  WriteLn('  2 -- Заданий по сроку выполнения (возрастание)');
  WriteLn('  0 -- Назад');
  WriteLn;
  Choice := PromptStr('Выбор');
  if Choice = '1' then
  begin
    EmpSortByName;
    PrintHeader;
    SetColor(CLR_OK);
    WriteLn('  Сотрудники отсортированы по ФИО:');
    ResetColor;
    WriteLn;
    ShowEmployees(EmpHead);
  end
  else if Choice = '2' then
  begin
    WorkSortByDeadline;
    PrintHeader;
    SetColor(CLR_OK);
    WriteLn('  Задания отсортированы по сроку выполнения:');
    ResetColor;
    WriteLn;
    ShowWorks(WorkHead);
  end;
  if Choice <> '0' then PressEnter;
end;

{ Пункт 4. Поиск }
procedure DoSearch;
var
  Choice, Query: string;
  Cur1: PEmployeeNode;
  Cur2: PWorkNode;
  Found: Integer;
  i: Integer;
begin
  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 5. ПОИСК ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- Поиск сотрудника по ФИО');
  WriteLn('  2 -- Поиск задания по названию проекта');
  WriteLn('  3 -- Поиск задания по коду исполнителя');
  WriteLn('  0 -- Назад');
  WriteLn;
  Choice := PromptStr('Выбор');

  if Choice = '1' then
  begin
    Query := PromptStr('Введите ФИО (или часть)');
    if Query = '' then Exit;
    PrintHeader;
    SetColor(CLR_OK);
    WriteLn('  Результаты поиска сотрудников по: "' + Query + '"');
    ResetColor;
    WriteLn;
    PrintEmployeeHeader;
    Found := 0;
    Cur1 := EmpHead;
    i := 1;
    while Cur1 <> nil do
    begin
      if Pos(AnsiLowerCase(Query),
             AnsiLowerCase(string(Cur1^.Data.FullName))) > 0 then
      begin
        PrintEmployeeRow(i, Cur1^.Data);
        Inc(Found);
      end;
      Inc(i);
      Cur1 := Cur1^.Next;
    end;
    DrawLine(72);
    SetColor(CLR_OK);
    WriteLn('  Найдено: ', Found);
    ResetColor;
    PressEnter;
  end
  else if Choice = '2' then
  begin
    Query := PromptStr('Введите название проекта (или часть)');
    if Query = '' then Exit;
    PrintHeader;
    SetColor(CLR_OK);
    WriteLn('  Результаты поиска заданий по проекту: "' + Query + '"');
    ResetColor;
    WriteLn;
    PrintWorkHeader;
    Found := 0; Cur2 := WorkHead; i := 1;
    while Cur2 <> nil do
    begin
      if Pos(AnsiLowerCase(Query),
             AnsiLowerCase(string(Cur2^.Data.ProjectName))) > 0 then
      begin
        PrintWorkRow(i, Cur2^.Data);
        Inc(Found);
      end;
      Inc(i);
      Cur2 := Cur2^.Next;
    end;
    DrawLine(78);
    SetColor(CLR_OK);
    WriteLn('  Найдено: ', Found);
    ResetColor;
    PressEnter;
  end
  else if Choice = '3' then
  begin
    i := PromptInt('Код исполнителя', 0);
    PrintHeader;
    SetColor(CLR_OK);
    WriteLn('  Задания исполнителя #', i, ':');
    ResetColor;
    WriteLn;
    PrintWorkHeader;
    Found := 0;
    Cur2 := WorkHead;
    while Cur2 <> nil do
    begin
      if Cur2^.Data.ExecutorCode = i then
      begin
        PrintWorkRow(Found + 1, Cur2^.Data);
        Inc(Found);
      end;
      Cur2 := Cur2^.Next;
    end;
    DrawLine(78);
    SetColor(CLR_OK);
    WriteLn('  Найдено: ', Found);
    ResetColor;
    PressEnter;
  end;
end;

{ Пункт 5. Добавление }
procedure DoAdd;
var
  Choice: string;
  E: TEmployee;
  W: TWork;
  Blank_E: TEmployee;
  Blank_W: TWork;
begin
  FillChar(Blank_E, SizeOf(Blank_E), 0);
  FillChar(Blank_W, SizeOf(Blank_W), 0);
  Blank_E.WorkHours := 8;
  Blank_W.IssueDate := Now;
  Blank_W.Deadline := Now + 30;

  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 6. ДОБАВЛЕНИЕ ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- Добавить сотрудника');
  WriteLn('  2 -- Добавить задание');
  WriteLn('  0 -- Назад');
  WriteLn;
  Choice := PromptStr('Выбор');

  if Choice = '1' then
  begin
    WriteLn;
    E := InputEmployee(Blank_E, True);
    if E.FullName <> '' then
    begin
      EmpAddToEnd(E);
      SetColor(CLR_OK);
      WriteLn('  [OK] Сотрудник добавлен. Всего: ', EmpCount);
      ResetColor;
    end
    else
    begin
      SetColor(CLR_ERROR);
      WriteLn('  Добавление отменено.');
      ResetColor;
    end;
    PressEnter;
  end
  else if Choice = '2' then
  begin
    WriteLn;
    W := InputWork(Blank_W, True);
    if W.ProjectName <> '' then
    begin
      WorkAddToEnd(W);
      SetColor(CLR_OK);
      WriteLn('  [OK] Задание добавлено. Всего: ', WorkCount);
      ResetColor;
    end
    else
    begin
      SetColor(CLR_ERROR);
      WriteLn('  Добавление отменено.');
      ResetColor;
    end;
    PressEnter;
  end;
end;

{ Пункт 6. Удаление }
procedure DoDelete;
var
  Choice: string;
  Code, Idx: Integer;
begin
  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 7. УДАЛЕНИЕ ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- Удалить сотрудника (по коду)');
  WriteLn('  2 -- Удалить задание (по номеру строки)');
  WriteLn('  0 -- Назад');
  WriteLn;
  Choice := PromptStr('Выбор');

  if Choice = '1' then
  begin
    WriteLn;
    ShowEmployees(EmpHead);
    WriteLn;
    Code := PromptInt('Код сотрудника для удаления', -1);
    if (Code <> -1)
    and Confirm('Удалить сотрудника #' + IntToStr(Code) + '?') then
    begin
      if EmpDeleteByCode(Code) then
      begin
        SetColor(CLR_OK);
        WriteLn('  [OK] Сотрудник удалён.');
        ResetColor;
      end
      else
      begin
        SetColor(CLR_ERROR);
        WriteLn('  Сотрудник с кодом ', Code, ' не найден.');
        ResetColor;
      end;
    end;
    PressEnter;
  end
  else if Choice = '2' then
  begin
    WriteLn;
    ShowWorks(WorkHead);
    WriteLn;
    Idx := PromptInt('Номер строки для удаления (с 1)', -1) - 1;
    if (Idx >= 0)
    and Confirm('Удалить задание #' + IntToStr(Idx + 1) + '?') then
    begin
      if WorkDeleteByIndex(Idx) then
      begin
        SetColor(CLR_OK);
        WriteLn('  [OK] Задание удалено.');
        ResetColor;
      end
      else
      begin
        SetColor(CLR_ERROR);
        WriteLn('  Задание #', Idx + 1, ' не найдено.');
        ResetColor;
      end;
    end;
    PressEnter;
  end;
end;

{ Пункт 7. Редактирование }
procedure DoEdit;
var
  Choice: string;
  Code, Idx: Integer;
  Node1: PEmployeeNode;
  Node2: PWorkNode;
  NewE: TEmployee;
  NewW: TWork;
begin
  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 8. РЕДАКТИРОВАНИЕ ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- Редактировать сотрудника (по коду)');
  WriteLn('  2 -- Редактировать задание (по номеру строки)');
  WriteLn('  0 -- Назад');
  WriteLn;
  Choice := PromptStr('Выбор');

  if Choice = '1' then
  begin
    WriteLn;
    ShowEmployees(EmpHead);
    WriteLn;
    Code := PromptInt('Код сотрудника для редактирования', -1);
    Node1 := EmpFindByCode(Code);
    if Node1 = nil then
    begin
      SetColor(CLR_ERROR);
      WriteLn('  Не найдено.');
      ResetColor;
      PressEnter;
      Exit;
    end;
    WriteLn('  (Enter -- оставить текущее значение)');
    WriteLn;
    NewE := InputEmployee(Node1^.Data, False);
    NewE.Code := Code;
    EmpUpdateByCode(Code, NewE);
    SetColor(CLR_OK);
    WriteLn('  [OK] Запись обновлена.');
    ResetColor;
    PressEnter;
  end
  else if Choice = '2' then
  begin
    WriteLn;
    ShowWorks(WorkHead);
    WriteLn;
    Idx := PromptInt('Номер строки для редактирования (с 1)', -1) - 1;
    Node2 := WorkGetByIndex(Idx);
    if Node2 = nil then
    begin
      SetColor(CLR_ERROR);
      WriteLn('  Не найдено.');
      ResetColor;
      PressEnter;
      Exit;
    end;
    WriteLn('  (Enter -- оставить текущее значение)');
    WriteLn;
    NewW := InputWork(Node2^.Data, False);
    WorkUpdateByIndex(Idx, NewW);
    SetColor(CLR_OK);
    WriteLn('  [OK] Запись обновлена.');
    ResetColor;
    PressEnter;
  end;
end;

{ Пункт 8. Отчёты по проектам (СФ1 + СФ2) }

procedure WriteWorkToFile(var F: TextFile; Idx: Integer; const W: TWork);
begin
  WriteLn(F, '  ', Idx, '. Проект    : ', W.ProjectName);
  WriteLn(F, '     Задание   : ', W.Task);
  WriteLn(F, '     Исп. (#)  : ', W.ExecutorCode);
  WriteLn(F, '     Рук. (#)  : ', W.BossCode);
  WriteLn(F, '     Выдано    : ', DateToStr(W.IssueDate));
  WriteLn(F, '     Срок      : ', DateToStr(W.Deadline));
  WriteLn(F, '  ' + StringOfChar('-', 60));
end;

procedure DoReports;
var
  Choice: string;
  ProjName: string;
  Nodes: array[0..999] of PWorkNode;
  Count, i: Integer;
  F: TextFile;
  FileName: string;
begin
  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 9. ОТЧЁТЫ ПО ПРОЕКТАМ ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- СФ1: Задачи по конкретному проекту');
  WriteLn('  2 -- СФ2: Задачи на ближайший месяц (30 дней)');
  WriteLn('  0 -- Назад');
  WriteLn;
  Choice := PromptStr('Выбор');

  // СФ1
  if Choice = '1' then
  begin
    ProjName := PromptStr('Название проекта');
    if ProjName = '' then Exit;

    WorkGetByProject(ProjName, Nodes, Count);

    PrintHeader;
    SetColor(CLR_ACCENT);
    WriteLn('  СФ1 -- Задачи по проекту: "' + ProjName + '"');
    ResetColor;
    WriteLn;

    if Count = 0 then
    begin
      SetColor(CLR_ERROR);
      WriteLn('  Заданий по данному проекту не найдено.');
      ResetColor;
    end
    else
    begin
      PrintWorkHeader;
      for i := 0 to Count - 1 do
        PrintWorkRow(i + 1, Nodes[i]^.Data);
      DrawLine(78);
      SetColor(CLR_OK);
      WriteLn('  Найдено заданий: ', Count);
      ResetColor;

      // Запись в файл
      FileName := 'sf1_tasks_by_project.txt';
      AssignFile(F, FileName);
      Rewrite(F);
      try
        WriteLn(F, 'ЗАДАЧИ ПО ПРОЕКТУ: ' + ProjName);
        WriteLn(F, 'Дата формирования: ' + DateTimeToStr(Now));
        WriteLn(F, StringOfChar('=', 62));
        for i := 0 to Count - 1 do
          WriteWorkToFile(F, i + 1, Nodes[i]^.Data);
        WriteLn(F, 'Итого: ', Count, ' задан(ий)');
      finally CloseFile(F);
      end;

      SetColor(CLR_OK);
      WriteLn('  Результат сохранён в: ', FileName);
      ResetColor;
    end;
    PressEnter;
  end

  // СФ2
  else if Choice = '2' then
  begin
    WorkGetDeadlineThisMonth(Nodes, Count);

    PrintHeader;
    SetColor(CLR_ACCENT);
    WriteLn('  СФ2 -- Задачи со сроком выполнения в ближайшие 30 дней');
    WriteLn('  (от ', DateToStr(Now), ' до ', DateToStr(Now + 30), ')');
    ResetColor;
    WriteLn;

    if Count = 0 then
    begin
      SetColor(CLR_ERROR);
      WriteLn('  Заданий с дедлайном в ближайшие 30 дней не найдено.');
      ResetColor;
    end
    else
    begin
      PrintWorkHeader;
      for i := 0 to Count - 1 do
        PrintWorkRow(i + 1, Nodes[i]^.Data);
      DrawLine(78);
      SetColor(CLR_OK);
      WriteLn('  Найдено заданий: ', Count);
      ResetColor;

      // Запись в файл
      FileName := 'sf2_deadline_this_month.txt';
      AssignFile(F, FileName);
      Rewrite(F);
      try
        WriteLn(F, 'ЗАДАЧИ СО СРОКОМ В БЛИЖАЙШИЕ 30 ДНЕЙ');
        WriteLn(F, 'Период: ' + DateToStr(Now) + ' — ' + DateToStr(Now + 30));
        WriteLn(F, 'Дата формирования: ' + DateTimeToStr(Now));
        WriteLn(F, StringOfChar('=', 62));
        for i := 0 to Count - 1 do
          WriteWorkToFile(F, i + 1, Nodes[i]^.Data);
        WriteLn(F, 'Итого: ', Count, ' задан(ий)');
      finally CloseFile(F);
      end;

      SetColor(CLR_OK);
      WriteLn('  Результат сохранён в: ', FileName);
      ResetColor;
    end;
    PressEnter;
  end;
end;

{ Пункт 9. Выход без сохранения }
procedure DoExitNoSave;
begin
  WriteLn;
  if Confirm('Выйти без сохранения? Все изменения будут потеряны') then
  begin
    EmpClearList;
    WorkClearList;
    SetColor(CLR_ACCENT);
    WriteLn('  До свидания!');
    ResetColor;
    Halt(0);
  end;
end;

{ Пункт 10. Выход с сохранением }
procedure DoExitSave;
begin
  WriteLn;
  WriteLn('  Сохранение данных...');
  SaveToFiles;
  SetColor(CLR_OK);
  WriteLn('  Сохранено: employees.dat (', EmpCount, ' записей)');
  WriteLn('  Сохранено: works.dat     (', WorkCount, ' записей)');
  ResetColor;
  EmpClearList;
  WorkClearList;
  SetColor(CLR_ACCENT);
  WriteLn('  До свидания!');
  ResetColor;
  Halt(0);
end;

end.
