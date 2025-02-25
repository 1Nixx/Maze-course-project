unit MazeStatistics;

interface
uses
  MazeMain;

type
  //Parameters for comparison
  TStatRoute = (SolveLength, FullRoute);

  TStatSolveAlg = record
    case AllSolveAlg: Boolean of
      False: (SolveAlg: TMazeSolveAlg);
  end;

  TStatGenAlg = record
    case AllGenAlg: Boolean of
      False: (GenAlg: TMazeGenAlg);
  end;

  TYValueArr = array of Double;
  TColumnNames = array of String;

  function GetStatistic(const Condition: TStatRoute; const SolveAlg: TStatSolveAlg;
                        const GenAlg: TStatGenAlg; const Sizeable: Boolean): TYValueArr;

  Function GetColumnName(const SolveAlg: TStatSolveAlg; const GenAlg: TStatGenAlg; 
                         const Sizeable: Boolean): TColumnNames;

  Function GetChartTitleText(const Condition: TStatRoute; const SolveAlg: TStatSolveAlg;
                             const GenAlg: TStatGenAlg; const Sizeable: Boolean): String;
implementation
uses
  MazeSave;

  //Calculate amount of columns in chart
  procedure SetAnswLeng(var Answ: TYValueArr; const SolveAlg: TStatSolveAlg;const GenAlg: TStatGenAlg; const Sizeable: Boolean); overload;
  begin
    if SolveAlg.AllSolveAlg = True then
      SetLength(Answ, Ord(High(TMazeSolveAlg))+1)
    else if GenAlg.AllGenAlg = True then
      SetLength(Answ, Ord(High(TMazeGenAlg))+1)
    else if Sizeable = True then
      SetLength(Answ, Ord(High(TMazeSize))+1);
  end;

  procedure SetAnswLeng(var Answ: TColumnNames; const SolveAlg: TStatSolveAlg;const GenAlg: TStatGenAlg; const Sizeable: Boolean); overload;
  begin
    if SolveAlg.AllSolveAlg = True then
      SetLength(Answ, Ord(High(TMazeSolveAlg))+1)
    else if GenAlg.AllGenAlg = True then
      SetLength(Answ, Ord(High(TMazeGenAlg))+1)
    else if Sizeable = True then
      SetLength(Answ, Ord(High(TMazeSize))+1);
  end;

  //Clculate average number
  procedure CalcAverageNumb(var AnswArr: TYValueArr; const Amount: array of Integer);
  var
    I: Integer;
  begin
    for I := 0 to High(AnswArr) do
      if Amount[I] <> 0 then
        AnswArr[i] := AnswArr[I]/Amount[I];
  end;

  //IDstanation between two points
  function GetDistBetweenPoints(const Point1, Point2: TPos): Double;
  begin
    Result := Sqrt(Sqr(Point1.PosX-Point2.PosX)+Sqr(Point1.PosY-Point2.PosY));  
  end;

  //Calculate values for chart
  function GetStatistic(const Condition: TStatRoute; const SolveAlg: TStatSolveAlg;
                        const GenAlg: TStatGenAlg; const Sizeable: Boolean): TYValueArr;
  var
    Stat: TMazeStat;
    i: Integer;
    SetSolveAlg: Set of TMazeSolveAlg;
    SetGenAlg: Set of TMazeGenAlg;
    MazeAmount: array of Integer;
  begin

    //Set available parameters
    if SolveAlg.AllSolveAlg then
      SetSolveAlg := [BFS, DFS, LeftHand, RightHand]
    else
      SetSolveAlg := [SolveAlg.SolveAlg];

    if GenAlg.AllGenAlg then
      SetGenAlg := [HuntAKill, BackTrack, Prim]
    else
      SetGenAlg := [GenAlg.GenAlg];

    SetAnswLeng(Result, SolveAlg, GenAlg, Sizeable);
    SetLength(MazeAmount, Length(Result));

    //Unload all records frome type file
    for I := GetRecordsAmount(TypeFileAddr) downto 1 do
    begin
      Stat := ReadFromTypeFile(I, TypeFileAddr);

      //Uses only available files
      if Stat.MazeSolveAlg in SetSolveAlg then
      begin
        if Stat.MazeGenAlg in SetGenAlg then
        begin
          //Add data to array to calculate chart
          if Sizeable = True then
          begin
            Inc(MazeAmount[Ord(Stat.MazeSize)]);
            Result[Ord(Stat.MazeSize)] := Result[Ord(Stat.MazeSize)] + Stat.VisitedCells.Route/GetDistBetweenPoints(Stat.StartPoint, Stat.EndPoint)
          end
          else
          begin
            if SolveAlg.AllSolveAlg then
            begin
              Inc(MazeAmount[Ord(Stat.MazeSolveAlg)]);
              if Condition = SolveLength then
                Result[Ord(Stat.MazeSolveAlg)] := Result[Ord(Stat.MazeSolveAlg)] + Stat.VisitedCells.Route/GetDistBetweenPoints(Stat.StartPoint, Stat.EndPoint)
              else
                Result[Ord(Stat.MazeSolveAlg)] := Result[Ord(Stat.MazeSolveAlg)] + Stat.VisitedCells.FullRoute/GetDistBetweenPoints(Stat.StartPoint, Stat.EndPoint)
            end
            else if GenAlg.AllGenAlg then
            begin
              Inc(MazeAmount[Ord(Stat.MazeGenAlg)]);
              if Condition = SolveLength then
                Result[Ord(Stat.MazeGenAlg)] := Result[Ord(Stat.MazeGenAlg)] + Stat.VisitedCells.Route/GetDistBetweenPoints(Stat.StartPoint, Stat.EndPoint)
              else
                Result[Ord(Stat.MazeGenAlg)] := Result[Ord(Stat.MazeGenAlg)] + Stat.VisitedCells.FullRoute/GetDistBetweenPoints(Stat.StartPoint, Stat.EndPoint);
            end;
          end;
        end;
      end;
    end;
    CalcAverageNumb(Result, MazeAmount);
  end;

  //Get name of collumns in chart
  Function GetColumnName(const SolveAlg: TStatSolveAlg; const GenAlg: TStatGenAlg;
                         const Sizeable: Boolean): TColumnNames;
  var
    I: Integer;
  Begin
    SetAnswLeng(Result, SolveAlg, GenAlg, Sizeable);  

    for I := Low(Result) to High(Result) do
      if SolveAlg.AllSolveAlg then
        Result[I] := GetSolveAlgStr(TMazeSolveAlg(I))
      else if GenAlg.AllGenAlg then
        Result[I] := GetGenAlgStr(TMazeGenAlg(I))
      else if Sizeable then
        Result[I] := GetMazeSizeStr(TMazeSize(I));
  End;

  //Get name of the chart
  Function GetChartTitleText(const Condition: TStatRoute; const SolveAlg: TStatSolveAlg;
                             const GenAlg: TStatGenAlg; const Sizeable: Boolean): String;

    //Get sequence of names of generations alg
    Function GetGenAlgSetStr(const GenerationCond: TStatGenAlg): String;
    var
      I: Integer;
    Begin
      Result := '';
      if GenerationCond.AllGenAlg then
      begin
        for I := Ord(Low(TMazeGenAlg)) to Ord(High(TMazeGenAlg)) do
          Result := Result + GetGenAlgStr(TMazeGenAlg(I)) + ', ';
        SetLength(Result, Length(Result)-2);
      end
      else
        Result := GetGenAlgStr(GenerationCond.GenAlg);

    end;

    //Get sequence of names of solves alg
    Function GetSolveAlgSetStr(const SolveCond: TStatSolveAlg): String;
    var
      I: Integer;
    Begin
      Result := '';
      if SolveCond.AllSolveAlg then
      begin
        for I := Ord(Low(TMazeSolveAlg)) to Ord(High(TMazeSolveAlg)) do
          Result := Result + GetSolveAlgStr(TMazeSolveAlg(I)) + ', ';
        SetLength(Result, Length(Result)-2);
      end
      else
        Result := GetSolveAlgStr(SolveCond.SolveAlg);
        
    end;

  begin
    Result := '';
    if Condition = SolveLength then
      Result := '������� ����� ����������� ��� ���������(��) ��������� '
                 + GetGenAlgSetStr(GenAlg) + '.'
    else
      Result := '���-�� ���������� ������ ��� ���������(��) ����������� '
                + GetSolveAlgSetStr(SolveAlg) + ' � ���������(��) ��������� ' 
                + GetGenAlgSetStr(GenAlg) + '.';
  end;
  
end.
