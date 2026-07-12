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

var
  Choice: string;
begin
  { Main program loop }
  repeat
    PrintHeader;
    PrintMainMenu;
    Choice := PromptStr('Enter menu item number');
    WriteLn;
    if Choice = '1' then DoReadFromFile
    else if Choice = '2' then DoView
    else if Choice = '3' then DoSort
    else if Choice = '4' then DoSearch
    else if Choice = '5' then DoAdd
    else if Choice = '6' then DoDelete
    else if Choice = '7' then DoEdit
    else if Choice = '8' then DoReports
    else if Choice = '9' then DoExitNoSave
    else if Choice = '10' then DoExitSave
    else
    begin
      SetColor(CLR_ERROR);
      WriteLn('  Invalid choice. Enter a number from 1 to 10.');
      ResetColor;
      PressEnter;
    end;
  until False; // Exit via Halt in DoExitNoSave/DoExitSave
end.
