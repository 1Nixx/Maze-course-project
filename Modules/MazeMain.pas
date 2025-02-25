unit MazeMain;

interface
type
  TMaze = array of array of (Wall, Pass, Visited);
  TPos = record
    PosX, PosY: Integer;
  end;
  TMazeSize = (Small, Medium, Large);
  TMazeGenAlg = (HuntAKill, BackTrack, Prim);
  TMazeSolveAlg = (BFS, DFS, LeftHand, RightHand);
  TRoute = array of TPos;

  TMazeStat = packed record
    FileName: String[50];
    DateTime: TDateTime;
    MazeSeed: Integer;
    MazeSize: TMazeSize;
    GenStartPos: TPos;
    StartPoint, EndPoint: TPos;
    MazeGenAlg: TMazeGenAlg;
    MazeSolveAlg: TMazeSolveAlg;
    VisitedCells: packed record
      Route: Integer;
      FullRoute: Integer;
    end;
    TotalTime : packed record
      SolvingTime: Integer;
      GenTime: Integer;
    end;
  end;

  const
  MazeSize: array[TMazeSize, 0..1] of Integer = ((15, 15), (30, 30), (50, 50));

  Procedure CleanMaze(var MazeToClean: TMaze);
  function GetExitCell(const MazeToFind: TMaze): TPos;
  function GetStartCell(const MazeToFind: TMaze): TPos;
  function GetSolveAlgStr(const SolveAlg: TMazeSolveAlg): string;
  function GetGenAlgStr(const GenAlg: TMazeGenAlg): string;
  function GetMazeSizeStr(const MazeSize: TMazeSize): string;

implementation

  Procedure CleanMaze(var MazeToClean: TMaze);
  var
    I: Integer;
    J: Integer;
  begin
    for I := Low(MazeToClean) to High(MazeToClean) do
      for J := Low(MazeToclean[I]) to High(MazeToClean[I]) do
        MazeToClean[I,J] := Wall;
  end;

  function GetExitCell(const MazeToFind: TMaze): TPos;
  var
    I: Integer;
  begin
    for I := High(MazeToFind[0]) downto Low(MazeToFind[0]) do
      if MazeToFind[High(MazeToFind), I] = Pass then
      begin
        Result.PosX := I;
        Result.PosY := High(MazeToFind);
        Exit;
      end;
  end;

  function GetStartCell(const MazeToFind: TMaze): TPos;
  var
    I: Integer;
  begin
    for I := Low(MazeToFind[0]) to High(MazeToFind[0]) do
      if MazeToFind[Low(MazeToFind), I] = Pass then
      begin
        Result.PosX := I;
        Result.PosY := Low(MazeToFind);
        Exit;
      end;
  end;

  ////////////////////////
  //Get text equivalents//
  //   of types items   //
  ////////////////////////

  function GetGenAlgStr(const GenAlg: TMazeGenAlg): string;
  begin
    case GenAlg of
      HuntAKill: Result := 'Hunt-and-Kill';
      BackTrack: Result := 'Backtracker';
      Prim: Result := 'Prim';
    end;
  end;

  function GetMazeSizeStr(const MazeSize: TMazeSize): string;
  begin
    case MazeSize of
      Small: Result := '�����';
      Medium: Result := '�������';
      Large: Result := '�������';
    end;
  end;

  function GetSolveAlgStr(const SolveAlg: TMazeSolveAlg): string;
  begin
    case SolveAlg of
      BFS: Result := 'BFS';
      DFS: Result := 'DFS';
      LeftHand: Result := 'Left hand';
      RightHand: Result := 'Right hand';
    end;
  end;


end.
