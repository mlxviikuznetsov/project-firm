unit DataTypes;

interface
uses SysUtils;
type
  TEmployee = record
    Code      : Integer;
    FullName  : string[100];
    Position  : string[60];
    WorkHours : Integer;
    BossCode  : Integer;
  end;
  TWork = record
    ProjectName  : string[100];
    Task         : string[200];
    ExecutorCode : Integer;
    BossCode     : Integer;
    IssueDate    : TDateTime;
    Deadline     : TDateTime;
  end;
  PEmployeeNode = ^TEmployeeNode;
  TEmployeeNode = record
    Data: TEmployee;
    Next: PEmployeeNode;
  end;
  PWorkNode = ^TWorkNode;
  TWorkNode = record
    Data: TWork;
    Next: PWorkNode;
  end;
implementation
end.
