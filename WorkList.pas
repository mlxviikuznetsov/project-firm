unit WorkList;

interface

uses DataTypes, SysUtils;

var
  WorkHead: PWorkNode = nil;

procedure WorkAddToEnd(const W: TWork);
function WorkDeleteByIndex(Idx: Integer): Boolean;
function WorkGetByIndex(Idx: Integer): PWorkNode;
function WorkUpdateByIndex(Idx: Integer; const NewData: TWork): Boolean;
procedure WorkClearList;
procedure WorkSortByDeadline;
function WorkCount: Integer;

// SF1 and SF2 return a dynamically allocated array
procedure WorkGetByProject(const ProjName: string;
                           var Nodes: array of PWorkNode; var Count: Integer);
procedure WorkGetDeadlineThisMonth(var Nodes: array of PWorkNode;
                                   var Count: Integer);

implementation

procedure WorkAddToEnd(const W: TWork);
var NewNode, Cur: PWorkNode;
begin
  New(NewNode);
  NewNode^.Data := W;
  NewNode^.Next := nil;
  if WorkHead = nil then WorkHead := NewNode
  else
  begin
    Cur := WorkHead;
    while Cur^.Next <> nil do Cur := Cur^.Next;
    Cur^.Next := NewNode;
  end;
end;

function WorkGetByIndex(Idx: Integer): PWorkNode;
var
  Cur: PWorkNode;
  i: Integer;
begin
  Result := nil; Cur := WorkHead; i := 0;
  while Cur <> nil do
  begin
    if i = Idx then
    begin
      Result := Cur;
      Exit;
    end;
    Inc(i);
    Cur := Cur^.Next;
  end;
end;

function WorkDeleteByIndex(Idx: Integer): Boolean;
var
  Cur, Prev: PWorkNode;
  i: Integer;
begin
  Result := False; Cur := WorkHead; Prev := nil; i := 0;
  while Cur <> nil do
  begin
    if i = Idx then
    begin
      if Prev = nil then WorkHead := Cur^.Next
      else Prev^.Next := Cur^.Next;
      Dispose(Cur);
      Result := True;
      Exit;
    end;
    Prev := Cur;
    Cur := Cur^.Next;
    Inc(i);
  end;
end;

function WorkUpdateByIndex(Idx: Integer; const NewData: TWork): Boolean;
var Node: PWorkNode;
begin
  Node := WorkGetByIndex(Idx);
  if Node <> nil then
  begin
    Node^.Data := NewData;
    Result := True;
  end
  else Result := False;
end;

procedure WorkClearList;
var Cur, Tmp: PWorkNode;
begin
  Cur := WorkHead;
  while Cur <> nil do
  begin
    Tmp := Cur^.Next;
    Dispose(Cur);
    Cur := Tmp;
  end;
  WorkHead := nil;
end;

procedure WorkSortByDeadline;
var
  Sorted: Boolean;
  Cur: PWorkNode;
  Tmp: TWork;
begin
  if WorkHead = nil then Exit;
  repeat
    Sorted := True;
    Cur := WorkHead;
    while Cur^.Next <> nil do
    begin
      if Cur^.Data.Deadline > Cur^.Next^.Data.Deadline then
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

function WorkCount: Integer;
var Cur: PWorkNode;
begin
  Result := 0;
  Cur := WorkHead;
  while Cur <> nil do
  begin
    Inc(Result);
    Cur := Cur^.Next;
  end;
end;

procedure WorkGetByProject(const ProjName: string;
                           var Nodes: array of PWorkNode; var Count: Integer);
var Cur: PWorkNode;
begin
  Count := 0;
  Cur := WorkHead;
  while (Cur <> nil) and (Count <= High(Nodes)) do
  begin
    if AnsiSameText(Trim(string(Cur^.Data.ProjectName)), Trim(ProjName)) then
    begin
      Nodes[Count] := Cur;
      Inc(Count);
    end;
    Cur := Cur^.Next;
  end;
end;

procedure WorkGetDeadlineThisMonth(var Nodes: array of PWorkNode;
                                   var Count: Integer);
var
  Cur: PWorkNode;
  Now_, MonthEnd, DL: TDateTime;
begin
  Count := 0;
  Now_ := Now;
  MonthEnd := Now_ + 30;
  Cur := WorkHead;
  while (Cur <> nil) and (Count <= High(Nodes)) do
  begin
    DL := Cur^.Data.Deadline;
    if (DL >= Now_) and (DL <= MonthEnd) then
    begin
      Nodes[Count] := Cur;
      Inc(Count);
    end;
    Cur := Cur^.Next;
  end;
end;

end.
