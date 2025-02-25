﻿unit MazeSave;

interface
uses
  MazeMain;

const
  ProgDir = 'Maze\';
  TypeFileAddr = 'MazeHistory.ini';
  TextFileDir = 'Mazes\';

Procedure SaveMazeToFile(Const MazeToSave: TMaze; const MazeStat: TMazeStat);
Procedure SaveMazeToTypeFile(Const MazeStat: TMazeStat; const FileAddr: String);
Function GetRecordsAmount(const FileAddr: String): Integer;
Function ReadFromTypeFile(const RecordToRead: Integer; const FileAddr: string): TMazeStat;
Procedure ClearTypeFile(const FileAddr: String);
Procedure DeleteRecord(const RecordToDel: Integer; const FileAddr: String);

Implementation
Uses
  SysUtils, shlobj, Windows;

function GetAppDataPath: String;
var
  path: array [0..MAX_PATH] of char;
  UserPath: String;
begin
 SHGetFolderPath(0, CSIDL_APPDATA, 0, SHGFP_TYPE_CURRENT, @path);
 userPath:= Path;
 UserPath:= UserPath + '\' + ProgDir;
 if not DirectoryExists(UserPath) then
   CreateDir(UserPath);
 Result := UserPath;
end;

//Write maze to text file
Procedure WriteMaze(Const MazeToWrite: TMaze; Const StartPos, EndPos: TPos; const FileHand: TextFile);
Var
  PrintMazeY, PrintMazeX: Integer;
begin
  // Displaying the maze visualization
  For PrintMazeX := 0 to 2 * Length(MazeToWrite[0]) + 1 do
    Write(FileHand, '#');
  Writeln(FileHand);
  For PrintMazeY := 0 to Length(MazeToWrite) - 1 do
  Begin
    Write(FileHand, '#');
    For PrintMazeX := 0 to Length(MazeToWrite[0]) - 1 do
    Begin

      { Determine what type the cell belongs to
        Display the corresponding symbol }
      If (PrintMazeY = StartPos.PosY) and (PrintMazeX = StartPos.PosX) then
        Write(FileHand, #149, ' ')
      else If MazeToWrite[PrintMazeY, PrintMazeX] = Wall then
        Write(FileHand, '##')
      else If (PrintMazeY = EndPos.PosY) and (PrintMazeX = EndPos.PosX) then
        Write(FileHand, ' o')
      else
        Write(FileHand, '  ');
    End;

    Writeln(FileHand, '#');
  End;
  For PrintMazeX := 0 to 2 * Length(MazeToWrite[0]) + 1 do
    Write(FileHand, '#');
end;

//Write maze to text file
Procedure SaveMazeToFile(Const MazeToSave: TMaze; const MazeStat: TMazeStat);
var
  F: TextFile;
  NewFileName, NewFileName2: string;
begin
  //Path := GetAppDataPath+ '\' + TextFileDir;
  CreateDir(TextFileDir);

  //Generate file name
  DateTimeToString(NewFileName, 'ddmmyy/hhnnss', Now);
  NewFileName2 := MazeStat.FileName + '_'+ NewFileName;
  //Save
  AssignFile(F, TextFileDir + NewFileName2 + '.txt');
  Rewrite(F);

  WriteMaze(MazeToSave, MazeStat.StartPoint, MazeStat.EndPoint, F);

  CloseFile(F);
end;

//Save to Typed File
Procedure SaveMazeToTypeFile(Const MazeStat: TMazeStat; const FileAddr: String);
var
  F: File of TMazeStat;
  Path: String;
begin
  Path := GetAppDataPath + FileAddr;
  try
    AssignFile(F, Path);
    Reset(F)
  except
    Rewrite(F);
  end;

  {if FileExists(FileAddr) then
    Reset(F)
  else
    Rewrite(F);  }

  Seek(F, FileSize(F));
  Write(F, MazeStat);

  CloseFile(F);
end;

//Get FileSize
Function GetRecordsAmount(const FileAddr: String): Integer;
var
  F: File of TMazeStat;
  Path: String;
begin
  Path := GetAppDataPath + FileAddr;
  if not FileExists(Path) then
  begin
    Result := 0;
    Exit;
  end;
  AssignFile(F, Path);
  Reset(F);

  Result := FileSize(F);

  CloseFile(F);
end;

//Get Record with number
Function ReadFromTypeFile(const RecordToRead: Integer; const FileAddr: string): TMazeStat;
var
  F: File of TMazeStat;
  Path: String;
begin
  Path := GetAppDataPath + FileAddr;
  if not FileExists(Path) then Exit;

  AssignFile(F, Path);
  Reset(F);

  Seek(F, RecordToRead-1);
  Read(F, Result);

  CloseFile(F);
end;

//Delete all records in type file
Procedure ClearTypeFile(const FileAddr: String);
var
  F: File of TMazeStat;
  Path: String;
begin
  Path := GetAppDataPath + FileAddr;
  AssignFile(F, Path);
  Rewrite(F);
  CloseFile(F);
end;

//Delete record with number
procedure DeleteRecord(const RecordToDel: Integer; const FileAddr: String);
var
  F: File of TMazeStat;
  I: Integer;
  Buff: TMazeStat;
  Path: String;
begin
  Path := GetAppDataPath + FileAddr;
  if (RecordToDel > GetRecordsAmount(FileAddr)) or (not FileExists(Path)) then
    Exit;

  AssignFile(F, Path);
  Reset(F);

  Seek(F,RecordToDel-1);

  //Shift all records
  for i := RecordToDel-1 to FileSize(F)-2 do
  begin
    seek(f,i+1);
    read(f,Buff);
    seek(f,i);
    write(f,Buff);
  end;
  Seek(F, FileSize(F)-1);
  Truncate(F);
  CloseFile(F);
end;

end.
