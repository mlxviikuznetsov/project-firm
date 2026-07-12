unit MenuHandlers;

{ Handlers for all menu items.
  Each procedure corresponds to one menu item and is fully self-contained. }

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

{ Internal helper procedures }

procedure ShowEmployees(Head: PEmployeeNode);
var
  Cur: PEmployeeNode;
  i: Integer;
begin
  if Head = nil then
  begin
    SetColor(CLR_ERROR);
    WriteLn('  Employee list is empty.');
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
  DrawLine(80);
  SetColor(CLR_OK);
  WriteLn('  Total employees: ', i - 1);
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
    WriteLn('  Task list is empty.');
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
  DrawLine(86);
  SetColor(CLR_OK);
  WriteLn('  Total tasks: ', i - 1);
  ResetColor;
  WriteLn('  (!) Red = overdue, Yellow = due <= 7 days');
end;

// Find the smallest employee code (starting from 1) not yet in use
function GetNextAvailableEmpCode: Integer;
var
  Cur: PEmployeeNode;
  Candidate: Integer;
  Taken: Boolean;
begin
  Candidate := 0;
  repeat
    Taken := False;
    Cur := EmpHead;
    while Cur <> nil do
    begin
      if Cur^.Data.Code = Candidate then
      begin
        Taken := True;
        Break;
      end;
      Cur := Cur^.Next;
    end;
    if Taken then Inc(Candidate);
  until not Taken;
  Result := Candidate;
end;

// Input employee data
function InputEmployee(const Defaults: TEmployee; IsNew: Boolean;
                       var Employee: TEmployee): Boolean;
begin
  Employee := Defaults;
  Result := True;
  if IsNew then
  begin
    Employee.Code := PromptIntRange('Employee code', Defaults.Code, 0, 9999);
    if EmpFindByCode(Employee.Code) <> nil then
    begin
      SetColor(CLR_ERROR);
      WriteLn('  Employee code ', Employee.Code, ' is already in use.');
      ResetColor;
      Result := False;
      Exit;
    end;
  end;
  Employee.FullName := ShortString(PromptStr('Full name'));
  if Employee.FullName = '' then Employee.FullName := Defaults.FullName;
  Employee.Position := ShortString(PromptStr('Position'));
  if Employee.Position = '' then Employee.Position := Defaults.Position;
  Employee.WorkHours := PromptIntRange('Working hours per day',
                                       Defaults.WorkHours, 0, 24);
  Employee.BossCode := PromptIntRange('Boss code (-1 = none)',
                                      Defaults.BossCode, -1, 9999);
end;

// Input task data
function InputWork(const Defaults: TWork; IsNew: Boolean): TWork;
begin
  Result := Defaults;
  Result.ProjectName := ShortString(PromptStr('Project name'));
  if Result.ProjectName = '' then Result.ProjectName := Defaults.ProjectName;
  Result.Task := ShortString(PromptStr('Task'));
  if Result.Task = '' then Result.Task := Defaults.Task;
  Result.ExecutorCode := PromptIntRange('Executor code',
                                        Defaults.ExecutorCode, 0, 9999);
  Result.IssueDate := PromptDate('Issue date (dd.mm.yyyy)',
                                 Defaults.IssueDate);
  Result.Deadline := PromptDateNotBefore('Deadline (dd.mm.yyyy)',
                                Defaults.Deadline, Result.IssueDate);
end;

{ Item 1. Read data from file }
procedure DoReadFromFile;
begin
  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 1. READ DATA FROM FILE ]');
  ResetColor;
  WriteLn;
  WriteLn('  Loading from employees.dat and works.dat...');
  LoadFromFiles;
  WriteLn;
  SetColor(CLR_OK);
  WriteLn('  Employees loaded : ', EmpCount);
  WriteLn('  Tasks loaded     : ', WorkCount);
  ResetColor;
  PressEnter;
end;

{ Item 2. View lists }
procedure DoView;
var Choice: string;
begin
  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 2. VIEW LISTS ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- View employee list');
  WriteLn('  2 -- View task list');
  WriteLn('  0 -- Back');
  WriteLn;
  Choice := PromptStr('Choice');
  if Choice = '1' then
  begin
    PrintHeader;
    SetColor(CLR_ACCENT);
    WriteLn('  [ 2. EMPLOYEE LIST ]');
    ResetColor;
    WriteLn;
    ShowEmployees(EmpHead);
  end
  else if Choice = '2' then
  begin
    PrintHeader;
    SetColor(CLR_ACCENT);
    WriteLn('  [ 2. TASK LIST ]');
    ResetColor;
    WriteLn;
    ShowWorks(WorkHead);
  end;
  if Choice <> '0' then PressEnter;
end;

{ Item 3. Sort }
procedure DoSort;
var Choice: string;
begin
  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 3. SORT ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- Employees by full name (A->Z)');
  WriteLn('  2 -- Tasks by deadline (ascending)');
  WriteLn('  0 -- Back');
  WriteLn;
  Choice := PromptStr('Choice');
  if Choice = '1' then
  begin
    EmpSortByName;
    PrintHeader;
    SetColor(CLR_OK);
    WriteLn('  Employees sorted by full name:');
    ResetColor;
    WriteLn;
    ShowEmployees(EmpHead);
  end
  else if Choice = '2' then
  begin
    WorkSortByDeadline;
    PrintHeader;
    SetColor(CLR_OK);
    WriteLn('  Tasks sorted by deadline:');
    ResetColor;
    WriteLn;
    ShowWorks(WorkHead);
  end;
  if Choice <> '0' then PressEnter;
end;

{ Item 4. Search }
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
  WriteLn('  [ 4. SEARCH ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- Search employee by full name');
  WriteLn('  2 -- Search task by project name');
  WriteLn('  3 -- Search task by executor code');
  WriteLn('  0 -- Back');
  WriteLn;
  Choice := PromptStr('Choice');

  if Choice = '1' then
  begin
    Query := PromptStr('Enter full name (or part)');
    if Query = '' then Exit;
    PrintHeader;
    SetColor(CLR_OK);
    WriteLn('  Employee search results for: "' + Query + '"');
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
    DrawLine(80);
    SetColor(CLR_OK);
    WriteLn('  Found: ', Found);
    ResetColor;
    PressEnter;
  end
  else if Choice = '2' then
  begin
    Query := PromptStr('Enter project name (or part)');
    if Query = '' then Exit;
    PrintHeader;
    SetColor(CLR_OK);
    WriteLn('  Task search results by project: "' + Query + '"');
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
    DrawLine(86);
    SetColor(CLR_OK);
    WriteLn('  Found: ', Found);
    ResetColor;
    PressEnter;
  end
  else if Choice = '3' then
  begin
    i := PromptInt('Executor code', 0);
    PrintHeader;
    SetColor(CLR_OK);
    WriteLn('  Tasks of executor #', i, ':');
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
    DrawLine(86);
    SetColor(CLR_OK);
    WriteLn('  Found: ', Found);
    ResetColor;
    PressEnter;
  end;
end;

{ Item 5. Add }
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
  Blank_E.BossCode := -1;
  Blank_W.IssueDate := Now;
  Blank_W.Deadline := Now + 30;

  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 5. ADD ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- Add employee');
  WriteLn('  2 -- Add task');
  WriteLn('  0 -- Back');
  WriteLn;
  Choice := PromptStr('Choice');

  if Choice = '1' then
  begin
    WriteLn;
    Blank_E.Code := GetNextAvailableEmpCode;
    if InputEmployee(Blank_E, True, E) then
    begin
      if E.FullName <> '' then
      begin
        EmpAddToEnd(E);
        SetColor(CLR_OK);
        WriteLn('  [OK] Employee added. Total: ', EmpCount);
        ResetColor;
      end
      else
      begin
        SetColor(CLR_ERROR);
        WriteLn('  Add cancelled.');
        ResetColor;
      end;
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
      WriteLn('  [OK] Task added. Total: ', WorkCount);
      ResetColor;
    end
    else
    begin
      SetColor(CLR_ERROR);
      WriteLn('  Add cancelled.');
      ResetColor;
    end;
    PressEnter;
  end;
end;

{ Item 6. Delete }
procedure DoDelete;
var
  Choice: string;
  Code, Idx: Integer;
begin
  PrintHeader;
  SetColor(CLR_ACCENT);
  WriteLn('  [ 6. DELETE ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- Delete employee (by code)');
  WriteLn('  2 -- Delete task (by row number)');
  WriteLn('  0 -- Back');
  WriteLn;
  Choice := PromptStr('Choice');

  if Choice = '1' then
  begin
    WriteLn;
    ShowEmployees(EmpHead);
    WriteLn;
    Code := PromptInt('Employee code to delete', -1);
    if (Code <> -1)
    and Confirm('Delete employee #' + IntToStr(Code) + '?') then
    begin
      if EmpDeleteByCode(Code) then
      begin
        SetColor(CLR_OK);
        WriteLn('  [OK] Employee deleted.');
        ResetColor;
      end
      else
      begin
        SetColor(CLR_ERROR);
        WriteLn('  Employee with code ', Code, ' not found.');
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
    Idx := PromptInt('Row number to delete (starting from 1)', -1) - 1;
    if (Idx >= 0)
    and Confirm('Delete task #' + IntToStr(Idx + 1) + '?') then
    begin
      if WorkDeleteByIndex(Idx) then
      begin
        SetColor(CLR_OK);
        WriteLn('  [OK] Task deleted.');
        ResetColor;
      end
      else
      begin
        SetColor(CLR_ERROR);
        WriteLn('  Task #', Idx + 1, ' not found.');
        ResetColor;
      end;
    end;
    PressEnter;
  end;
end;

{ Item 7. Edit }
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
  WriteLn('  [ 7. EDIT ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- Edit employee (by code)');
  WriteLn('  2 -- Edit task (by row number)');
  WriteLn('  0 -- Back');
  WriteLn;
  Choice := PromptStr('Choice');

  if Choice = '1' then
  begin
    WriteLn;
    ShowEmployees(EmpHead);
    WriteLn;
    Code := PromptInt('Employee code to edit', -1);
    Node1 := EmpFindByCode(Code);
    if Node1 = nil then
    begin
      SetColor(CLR_ERROR);
      WriteLn('  Not found.');
      ResetColor;
      PressEnter;
      Exit;
    end;
    WriteLn('  (Enter -- keep current value)');
    WriteLn;
    InputEmployee(Node1^.Data, False, NewE);
    NewE.Code := Code;
    EmpUpdateByCode(Code, NewE);
    SetColor(CLR_OK);
    WriteLn('  [OK] Record updated.');
    ResetColor;
    PressEnter;
  end
  else if Choice = '2' then
  begin
    WriteLn;
    ShowWorks(WorkHead);
    WriteLn;
    Idx := PromptInt('Row number to edit (starting from 1)', -1) - 1;
    Node2 := WorkGetByIndex(Idx);
    if Node2 = nil then
    begin
      SetColor(CLR_ERROR);
      WriteLn('  Not found.');
      ResetColor;
      PressEnter;
      Exit;
    end;
    WriteLn('  (Enter -- keep current value)');
    WriteLn;
    NewW := InputWork(Node2^.Data, False);
    WorkUpdateByIndex(Idx, NewW);
    SetColor(CLR_OK);
    WriteLn('  [OK] Record updated.');
    ResetColor;
    PressEnter;
  end;
end;

{ Item 8. Project reports (SF1 + SF2) }

procedure WriteWorkToFile(var F: TextFile; Idx: Integer; const W: TWork);
begin
  WriteLn(F, '  ', Idx, '. Project   : ', W.ProjectName);
  WriteLn(F, '     Task      : ', W.Task);
  WriteLn(F, '     Exec. (#) : ', W.ExecutorCode);
  WriteLn(F, '     Issued    : ', DateToStr(W.IssueDate));
  WriteLn(F, '     Deadline  : ', DateToStr(W.Deadline));
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
  WriteLn('  [ 8. PROJECT REPORTS ]');
  ResetColor;
  WriteLn;
  WriteLn('  1 -- SF1: Tasks for a specific project');
  WriteLn('  2 -- SF2: Tasks for the upcoming month (30 days)');
  WriteLn('  0 -- Back');
  WriteLn;
  Choice := PromptStr('Choice');

  // SF1
  if Choice = '1' then
  begin
    ProjName := PromptStr('Project name');
    if ProjName = '' then Exit;

    WorkGetByProject(ProjName, Nodes, Count);

    PrintHeader;
    SetColor(CLR_ACCENT);
    WriteLn('  SF1 -- Tasks for project: "' + ProjName + '"');
    ResetColor;
    WriteLn;

    if Count = 0 then
    begin
      SetColor(CLR_ERROR);
      WriteLn('  No tasks found for this project.');
      ResetColor;
    end
    else
    begin
      PrintWorkHeader;
      for i := 0 to Count - 1 do
        PrintWorkRow(i + 1, Nodes[i]^.Data);
      DrawLine(86);
      SetColor(CLR_OK);
      WriteLn('  Tasks found: ', Count);
      ResetColor;

      // Write to file
      FileName := 'sf1_tasks_by_project.txt';
      AssignFile(F, FileName);
      Rewrite(F);
      try
        WriteLn(F, 'TASKS FOR PROJECT: ' + ProjName);
        WriteLn(F, 'Generated on: ' + DateTimeToStr(Now));
        WriteLn(F, StringOfChar('=', 62));
        for i := 0 to Count - 1 do
          WriteWorkToFile(F, i + 1, Nodes[i]^.Data);
        WriteLn(F, 'Total: ', Count, ' task(s)');
      finally CloseFile(F);
      end;

      SetColor(CLR_OK);
      WriteLn('  Result saved to: ', FileName);
      ResetColor;
    end;
    PressEnter;
  end

  // SF2
  else if Choice = '2' then
  begin
    WorkGetDeadlineThisMonth(Nodes, Count);

    PrintHeader;
    SetColor(CLR_ACCENT);
    WriteLn('  SF2 -- Tasks due within the next 30 days');
    WriteLn('  (from ', DateToStr(Now), ' to ', DateToStr(Now + 30), ')');
    ResetColor;
    WriteLn;

    if Count = 0 then
    begin
      SetColor(CLR_ERROR);
      WriteLn('  No tasks found with a deadline in the next 30 days.');
      ResetColor;
    end
    else
    begin
      PrintWorkHeader;
      for i := 0 to Count - 1 do
        PrintWorkRow(i + 1, Nodes[i]^.Data);
      DrawLine(86);
      SetColor(CLR_OK);
      WriteLn('  Tasks found: ', Count);
      ResetColor;

      // Write to file
      FileName := 'sf2_deadline_this_month.txt';
      AssignFile(F, FileName);
      Rewrite(F);
      try
        WriteLn(F, 'TASKS DUE WITHIN THE NEXT 30 DAYS');
        WriteLn(F, 'Period: ' + DateToStr(Now) + ' - ' + DateToStr(Now + 30));
        WriteLn(F, 'Generated on: ' + DateTimeToStr(Now));
        WriteLn(F, StringOfChar('=', 62));
        for i := 0 to Count - 1 do
          WriteWorkToFile(F, i + 1, Nodes[i]^.Data);
        WriteLn(F, 'Total: ', Count, ' task(s)');
      finally CloseFile(F);
      end;

      SetColor(CLR_OK);
      WriteLn('  Result saved to: ', FileName);
      ResetColor;
    end;
    PressEnter;
  end;
end;

{ Item 9. Exit without saving }
procedure DoExitNoSave;
begin
  WriteLn;
  if Confirm('Exit without saving? All changes will be lost') then
  begin
    EmpClearList;
    WorkClearList;
    SetColor(CLR_ACCENT);
    WriteLn('  Goodbye!');
    ResetColor;
    Halt(0);
  end;
end;

{ Item 10. Exit with saving }
procedure DoExitSave;
begin
  WriteLn;
  WriteLn('  Saving data...');
  SaveToFiles;
  SetColor(CLR_OK);
  WriteLn('  Saved: employees.dat (', EmpCount, ' records)');
  WriteLn('  Saved: works.dat     (', WorkCount, ' records)');
  ResetColor;
  EmpClearList;
  WorkClearList;
  SetColor(CLR_ACCENT);
  WriteLn('  Goodbye!');
  ResetColor;
  Halt(0);
end;

end.
