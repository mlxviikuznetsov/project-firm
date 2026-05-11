program ProjectFirm;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ConsoleUI in 'ConsoleUI.pas',
  DataTypes in 'DataTypes.pas',
  FileIO in 'FileIO.pas',
  MenuHandlers in 'MenuHandlers.pas',
  EmployeeList in 'EmployeeList.pas',
  WorkList in 'WorkList.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
