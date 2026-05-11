unit EmployeeList;

interface

uses DataTypes, SysUtils;

var
  EmpHead: PEmployeeNode = nil;

procedure EmpAddToEnd(const E: TEmployee);
function EmpDeleteByCode(Code: Integer): Boolean;
function EmpFindByCode(Code: Integer): PEmployeeNode;
function EmpUpdateByCode(Code: Integer; const NewData: TEmployee): Boolean;
procedure EmpClearList;
procedure EmpSortByName;
function EmpCount: Integer;

implementation

procedure EmpAddToEnd(const E: TEmployee);
var
  NewNode, Cur: PEmployeeNode;
begin
  New(NewNode);
  NewNode^.Data := E;
  NewNode^.Next := nil;
  if EmpHead = nil then
    EmpHead := NewNode
  else
  begin
    Cur := EmpHead;
    while Cur^.Next <> nil do Cur := Cur^.Next;
    Cur^.Next := NewNode;
  end;
end;

function EmpDeleteByCode(Code: Integer): Boolean;
var
  Cur, Prev: PEmployeeNode;
begin
  Result := False;
  Cur := EmpHead;
  Prev := nil;
  while Cur <> nil do
  begin
    if Cur^.Data.Code = Code then
    begin
      if Prev = nil then EmpHead := Cur^.Next
      else Prev^.Next := Cur^.Next;
      Dispose(Cur);
      Result := True;
      Exit;
    end;
    Prev := Cur;
    Cur := Cur^.Next;
  end;
end;

function EmpFindByCode(Code: Integer): PEmployeeNode;
var Cur: PEmployeeNode;
begin
  Result := nil;
  Cur := EmpHead;
  while Cur <> nil do
  begin
    if Cur^.Data.Code = Code then
    begin
      Result := Cur;
      Exit;
    end;
    Cur := Cur^.Next;
  end;
end;

function EmpUpdateByCode(Code: Integer; const NewData: TEmployee): Boolean;
var Node: PEmployeeNode;
begin
  Node := EmpFindByCode(Code);
  if Node <> nil then
  begin
    Node^.Data := NewData;
    Result := True;
  end
  else Result := False;
end;

procedure EmpClearList;
var Cur, Tmp: PEmployeeNode;
begin
  Cur := EmpHead;
  while Cur <> nil do
  begin
    Tmp := Cur^.Next;
    Dispose(Cur);
    Cur := Tmp;
  end;
  EmpHead := nil;
end;

procedure EmpSortByName;
var
  Sorted: Boolean;
  Cur: PEmployeeNode;
  Tmp: TEmployee;
begin
  if EmpHead = nil then Exit;
  repeat
    Sorted := True;
    Cur := EmpHead;
    while Cur^.Next <> nil do
    begin
      if Cur^.Data.FullName > Cur^.Next^.Data.FullName then
      begin
        Tmp := Cur^.Data;
        Cur^.Data := Cur^.Next^.Data;
        Cur^.Next^.Data := Tmp;
        Sorted := False;
      end;
      Cur := Cur^.Next;
    end;
  until Sorted;
end;

function EmpCount: Integer;
var Cur: PEmployeeNode;
begin
  Result := 0;
  Cur := EmpHead;
  while Cur <> nil do
  begin
    Inc(Result);
    Cur := Cur^.Next;
  end;
end;
end.
