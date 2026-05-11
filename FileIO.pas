unit FileIO;

interface

uses DataTypes, EmployeeList, WorkList, SysUtils;

const
  EMP_FILE = 'employees.dat';
  WORK_FILE = 'works.dat';

procedure LoadFromFiles;
procedure SaveToFiles;

implementation

procedure LoadFromFiles;
var
  EmpFile: file of TEmployee;
  WorkFile: file of TWork;
  E: TEmployee;
  W: TWork;
begin
  EmpClearList;
  if FileExists(EMP_FILE) then
  begin
    AssignFile(EmpFile, EMP_FILE);
    Reset(EmpFile);
    try
      while not Eof(EmpFile) do
      begin
        Read(EmpFile, E);
        EmpAddToEnd(E);
      end;
    finally
      CloseFile(EmpFile);
    end;
  end;

  WorkClearList;
  if FileExists(WORK_FILE) then
  begin
    AssignFile(WorkFile, WORK_FILE);
    Reset(WorkFile);
    try
      while not Eof(WorkFile) do
      begin
        Read(WorkFile, W);
        WorkAddToEnd(W);
      end;
    finally
      CloseFile(WorkFile);
    end;
  end;
end;

procedure SaveToFiles;
var
  EmpFile: file of TEmployee;
  WorkFile: file of TWork;
  C1: PEmployeeNode;
  C2: PWorkNode;
begin
  AssignFile(EmpFile, EMP_FILE); Rewrite(EmpFile);
  try
    C1 := EmpHead;
    while C1 <> nil do
    begin
      Write(EmpFile, C1^.Data);
      C1 := C1^.Next;
    end;
  finally CloseFile(EmpFile);
  end;

  AssignFile(WorkFile, WORK_FILE); Rewrite(WorkFile);
  try
    C2 := WorkHead;
    while C2 <> nil do
    begin
      Write(WorkFile, C2^.Data);
      C2 := C2^.Next;
    end;
  finally CloseFile(WorkFile);
  end;
end;

end.
