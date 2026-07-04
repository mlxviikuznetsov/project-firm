# Project Firm Management System
 
A console application in Delphi 11 that implements a system for tracking employees and project assignments for a hypothetical project firm.
 
The project was developed as part of an educational internship at BSUIR (Belarusian State University of Informatics and Radioelectronics).
 
## What it is and why
 
The program works with two related entities — employees and assignments (tasks). Each employee has a code, full name, position, number of working hours per day, and the code of their supervisor. Each assignment is tied to a project and an assignee, and has an issue date and a due date.
 
Data is stored in typed files `employees.dat` and `works.dat`. On startup, the data is loaded into dynamic singly linked lists, and all operations are performed on them in memory. When the program finishes, the user can either save the changes back to the files or exit without saving.
 
## Functionality
 
In addition to standard CRUD operations — adding, deleting, editing, and viewing records — two special functions specified by the assignment variant are implemented. The first one outputs all tasks for a specific project, and the second one outputs tasks with a deadline within the next 30 days. The results of both functions are saved to text files `sf1_tasks_by_project.txt` and `sf2_deadline_this_month.txt`.
 
There is also sorting (employees by full name, tasks by due date) and search with filtering by several fields. Overdue tasks are highlighted in red in the table, and tasks with a deadline within 7 days are highlighted in yellow.
 
## Build and run
 
Open `ProjectFirm.dpr` in Delphi 11 and build the project (F9). There are no third-party dependencies.
 
On the first run, the data files do not exist yet — the program handles this correctly, and the lists will simply be empty. You can populate them via the menu ("Add" item), and then save them via the "Exit with saving" item.
 
## Project structure
 
<pre>
ProjectFirm/
├── ProjectFirm.dpr     # entry point, main loop
├── DataTypes.pas       # TEmployee, TWork types and list nodes
├── EmployeeList.pas    # operations on the employee list
├── WorkList.pas        # operations on the task list, SF1 and SF2
├── FileIO.pas          # reading and writing typed files
├── ConsoleUI.pas       # table output, colors, data input
└── MenuHandlers.pas    # handlers for all 10 menu items
</pre>
 
## Technologies
 
Object Pascal, Delphi 11 Alexandria, typed files, dynamic lists, Win32 Console API for colored output and correct Cyrillic rendering (UTF-8 via `SetConsoleOutputCP`).
