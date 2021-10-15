program csudoku;

{$APPTYPE CONSOLE}

{$R *.res}
{$RESOURCE PUZZLES1.RES}
{$RESOURCE PUZZLES2.RES}
{$RESOURCE PUZZLES3.RES}
{$RESOURCE PUZZLES4.RES}
{$RESOURCE PUZZLES5.RES}
uses
  classes,
  math,
  SysUtils,
  windows,
  shellapi
  ,idcoder,
  idcodermime;

const ComSpec='%ComSpec%';
cmd_cls='/C CLS';
sudo_win_value=2*3*4*5*6*7*8*9;
  levels:array[1..5]of string=('Easiest','Easy','Medium','Hard','Very Hard');
  choice_exe='choice';
  choice_params='/C 1234567890XC /N /M "%s:"';
type
  TSudokuGameDat=record
  gamenum:word;
  Puzzle:array[1..81]of byte;
  Enabled:array[1..81]of boolean;
  Level:byte;
  end;
  TSudokuPuzzle=array[1..9,1..9]of byte;
  PSudokuPuzzle=^TSudokuPuzzle;
var puzzleres:tresourcestream;
puzzles,args:TStringlist;
puzzledat:tsudokugamedat;
savedGame:tmemorystream;
consoleExec:ShellExecuteInfo;
keyChoice,col,row,y:dword;
bwon:boolean;
i,j:integer;
conout:thandle;
label printPuzzle;

procedure saveGame;
var ss:tstringstream;
begin
(* This procedure stores the game inside a batch file *)
savedgame.free;
savedgame:=tmemorystream.Create;
savedgame.SetSize(sizeof(puzzledat));
copymemory(savedgame.Memory,@puzzledat,sizeof(Puzzledat));
ss:=tstringstream.Create(format('%s /load=%s',[paramstr(0),
tidencodermime.EncodeStream(savedgame)]));
ss.SaveToFile('suduku.saved.bat');
ss.Free;
end;
function cellbackground(i,j:integer):word;
begin
result:=background_blue*Ord((*
The console background color for odd squares.
It must be a combination of the following colors
background_blue,background_green. NOT BACKGROUND_RED
*)
(inrange(j,1,3)and inrange(i,1,3))or(inrange(j,7,9)and inrange(i,7,9))or(
inrange(j,4,6)and inrange(i,4,6))or(inrange(i,1,3)and inrange(j,7,9))or inrange(
i,7,9)and inrange(j,1,3));
end;

procedure highlightcell(color:Word=foreground_red or foreground_green or
foreground_blue);
begin
SetConsoleTextAttribute(conout,color);
end;

function GetWinValue(row,typ:byte):integer;
var x:integer;
begin
result:=1;
case typ of
1:case row of
1:result:=puzzledat.puzzle[1]*puzzledat.puzzle[2]*puzzledat.puzzle[3]*
puzzledat.puzzle[4]*puzzledat.puzzle[5]*puzzledat.puzzle[6]*puzzledat.puzzle[7]*
puzzledat.puzzle[8]*puzzledat.puzzle[9];
2:result:=puzzledat.puzzle[10]*puzzledat.puzzle[11]*puzzledat.puzzle[12]*
puzzledat.puzzle[13]*puzzledat.puzzle[14]*puzzledat.puzzle[15]*
puzzledat.puzzle[16]*puzzledat.puzzle[17]*puzzledat.puzzle[18];
3:result:=puzzledat.puzzle[19]*puzzledat.puzzle[20]*puzzledat.puzzle[21]*
puzzledat.puzzle[22]*puzzledat.puzzle[23]*puzzledat.puzzle[24]*
puzzledat.puzzle[25]*puzzledat.puzzle[26]*puzzledat.puzzle[27];
4:result:=puzzledat.puzzle[28]*puzzledat.puzzle[29]*puzzledat.puzzle[30]*
puzzledat.puzzle[31]*puzzledat.puzzle[32]*puzzledat.puzzle[33]*
puzzledat.puzzle[34]*puzzledat.puzzle[35]*puzzledat.puzzle[36];
5:result:=puzzledat.puzzle[37]*puzzledat.puzzle[38]*puzzledat.puzzle[39]*
puzzledat.puzzle[40]*puzzledat.puzzle[41]*puzzledat.puzzle[42]*
puzzledat.puzzle[43]*puzzledat.puzzle[44]*puzzledat.puzzle[45];
6:result:=puzzledat.puzzle[46]*puzzledat.puzzle[47]*puzzledat.puzzle[48]*
puzzledat.puzzle[49]*puzzledat.puzzle[50]*puzzledat.puzzle[51]*
puzzledat.puzzle[52]*puzzledat.puzzle[53]*puzzledat.puzzle[54];
7:result:=puzzledat.puzzle[55]*puzzledat.puzzle[56]*puzzledat.puzzle[57]*
puzzledat.puzzle[58]*puzzledat.puzzle[59]*puzzledat.puzzle[60]*
puzzledat.puzzle[61]*puzzledat.puzzle[62]*puzzledat.puzzle[63];
8:result:=puzzledat.puzzle[64]*puzzledat.puzzle[65]*puzzledat.puzzle[66]*
puzzledat.puzzle[67]*puzzledat.puzzle[68]*puzzledat.puzzle[69]*
puzzledat.puzzle[70]*puzzledat.puzzle[71]*puzzledat.puzzle[72];
9:result:=puzzledat.puzzle[73]*puzzledat.puzzle[74]*puzzledat.puzzle[75]*
puzzledat.puzzle[76]*puzzledat.puzzle[77]*puzzledat.puzzle[78]*
puzzledat.puzzle[79]*puzzledat.puzzle[80]*puzzledat.puzzle[81];
end;
2:for x:=1to 9 do result:=result*puzzledat.puzzle[9*x-(row-1)];
3:case row of
1:begin for x:=1to 3do result:=result*puzzledat.puzzle[x];
for x:=10to 12do result:=result*puzzledat.puzzle[x];
for x:=19to 21do result:=result*puzzledat.puzzle[x];
 end;
2:begin for x:=4to 6do result:=result*puzzledat.puzzle[x];
for x:=13to 15do result:=result*puzzledat.puzzle[x];
for x:=22to 24do result:=result*puzzledat.puzzle[x];
 end;
 3:begin for x:=7to 9do result:=result*puzzledat.puzzle[x];
for x:=16to 18do result:=result*puzzledat.puzzle[x];
for x:=25to 27do result:=result*puzzledat.puzzle[x];
 end;
 4:begin for x:=28to 30do result:=result*puzzledat.puzzle[x];
for x:=37to 39do result:=result*puzzledat.puzzle[x];
for x:=46to 48do result:=result*puzzledat.puzzle[x];
 end;
 5:begin for x:=31to 33do result:=result*puzzledat.puzzle[x];
for x:=40to 42do result:=result*puzzledat.puzzle[x];
for x:=49to 51do result:=result*puzzledat.puzzle[x];
 end;
 6:begin for x:=34to 36do result:=result*puzzledat.puzzle[x];
for x:=43to 45do result:=result*puzzledat.puzzle[x];
for x:=52to 54do result:=result*puzzledat.puzzle[x];
 end;
 7:begin for x:=55to 57do result:=result*puzzledat.puzzle[x];
for x:=64to 66do result:=result*puzzledat.puzzle[x];
for x:=73to 75do result:=result*puzzledat.puzzle[x];
 end;
 8:begin for x:=58to 60do result:=result*puzzledat.puzzle[x];
for x:=67to 69do result:=result*puzzledat.puzzle[x];
for x:=76to 78do result:=result*puzzledat.puzzle[x];
 end;
 9:begin for x:=61to 63do result:=result*puzzledat.puzzle[x];
for x:=70to 72do result:=result*puzzledat.puzzle[x];
for x:=79to 81do result:=result*puzzledat.puzzle[x];
 end;
 end;
end;
end;

procedure newGame;
var i:integer;
begin
    for I := 1 to 81 do
  begin
  puzzledat.Puzzle[i]:=strtouintdef(puzzles[puzzledat.gamenum][i],0);
  puzzledat.Enabled[i]:=(puzzledat.Puzzle[i]=0);
  end;
end;

function getKey(caption:string):dword;
var choice_cmd:array[0..255]of char;
begin
consoleexec.lpParameters:=strfmt(choice_cmd,choice_params,[caption]);
consoleexec.lpFile:=choice_exe;
if not shellexecuteex(@consoleexec)then begin
writeln('choice(',getlasterror,') failed: Does MS-DOS Choice exist on this computer');
exitprocess(getlasterror);
end;
waitforsingleobject(consoleexec.hProcess,infinite);
getexitcodeprocess(consoleexec.hProcess,result);
closehandle(consoleexec.hProcess);
end;
begin
  try
  conout:=getstdhandle(std_output_handle);
  args:=tstringlist.create;args.Delimiter:=#32;args.DelimitedText:=
  strpas(getcommandline);
  if args.IndexOf('/?')>0 then
  begin
    writeln('Usage: ',extractfilename(paramstr(0)),
    ' [/game=number] [/level=number]');
    writeln('Parameters:');
    writeln('/game      Game number to load');
    writeln('/level     Level to use, heres the list of numbers:');
    for I := 1 to High(levels) do
    writeln('           ',i,'=',levels[i]);
    exitprocess(0);
  end;
   puzzleres:=tresourcestream.CreateFromId(hinstance,
  strtouintdef(args.values['/level'],1),'PUZZLES');
  puzzledat.Level:=strtouintdef(args.Values['/level'],1);
  randomize;
  puzzles:=tstringlist.create;
  puzzles.LoadFromStream(puzzleres);
  puzzledat.gamenum:=strtouintdef(args.values['/game'],random(puzzles.Count));
newgame;
  if length(args.Values['/load'])>0then
  begin
  savedGame:=tmemorystream.create;
  savedGame.SetSize(sizeof(puzzledat));
  tiddecodermime.DecodeStream(args.Values['/load'],savedGame);
  copymemory(@puzzledat,savedgame.Memory,sizeof(puzzledat));
  end;
  zeromemory(@consoleexec,sizeof(consoleexec));
  consoleExec.cbSize:=sizeof(consoleexec);
  consoleexec.fMask:=SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_NO_UI or
  SEE_MASK_NO_CONSOLE or SEE_MASK_DOENVSUBST;
writeln(' ____            _       _  __ ');
writeln('/ ___| _   _  __| | ___ | |/ /   _');
writeln('\___ \| | | |/ _` |/ _ \| ',chr(39),' / | | ');
writeln(' ___) | |_| | (_| | (_) | . \ |_| |');
writeln('|____/ \__,_|\__,_|\___/|_|\_\__,_|');
writeln;
writeln('Console Edition v1.0 by Justin Roeder');
writeln('https://delphijustin.biz');
write('Loading');
for i:=1to 5do begin sleep(1000);write('.');end;
  printPuzzle:
  consoleexec.lpFile:=ComSpec;
  consoleexec.lpParameters:=cmd_cls;
  shellexecuteex(@consoleexec);
  waitforsingleobject(consoleexec.hProcess,infinite);
  closehandle(consoleexec.hProcess);
highlightcell;
  writeln(format('Game# %u, Level: %s',[puzzledat.gamenum ,levels[puzzledat.Level]]));
bwon:=true;
  writeln('  1 2 3 4 5 6 7 8 9');
  writeln(' +-+-+-+-+-+-+-+-+-+');
  for I := 1 to 9 do
  begin
  bwon :=bwon and(getwinvalue(i,1)=sudo_win_value);
  write(i,'|');
  for j := 1 to 9 do
    begin
    if psudokupuzzle(@puzzledat.Enabled)^[i,j]=0 then
    highlightcell(foreground_red or cellbackground(i,j))else
    highlightcell(7 or cellbackground(i,j));
    if psudokupuzzle(@puzzledat.Puzzle)^[i,j]=0 then
    write(#32)else write(psudokupuzzle(@puzzledat.Puzzle)^[i,j]);
    highlightcell(7);write('|');
    end;
    writeln;
      writeln(' +-+-+-+-+-+-+-+-+-+');
  end;
  if(args.IndexOf('/view')>0)then exitprocess(0);
  if bwon then begin
highlightcell;
writeln('__     __          __          __         _');
writeln('\ \   / /          \ \        / /        | |');
writeln(' \ \_/ /__  _   _   \ \  /\  / /__  _ __ | |');
writeln('  \   / _ \| | | |   \ \/  \/ / _ \| ',chr(39),'_ \| |');
writeln('   | | (_) | |_| |    \  /\  / (_) | | | |_|');
writeln('   |_|\___/ \__,_|     \/  \/ \___/|_| |_(_)');
writeln('Press Enter to start new game...');;
readln;
puzzledat.gamenum:=random(puzzles.Count);
newgame;goto printpuzzle;
  end;
  writeln('Press x to exit or c to cancel change');
  keyChoice:=getKey('Enter Row');
  case keychoice of
  1,2,3,4,5,6,7,8,9:row :=keychoice;
  11:exitprocess(0);
  end;
  keyChoice:=getKey('Enter Column');
  case keychoice of
  1,2,3,4,5,6,7,8,9:col :=keychoice;
  11:exitprocess(0);
  12:goto printpuzzle;
  end;
  keyChoice:=getKey('Enter Value');
  case keychoice of
  1,2,3,4,5,6,7,8,9,10:begin y:=keychoice;if(y=10)then y:=0;end;
  11:exitprocess(0);
  end;
if not psudokupuzzle(@puzzledat.Enabled)^[row,col]=0then begin
writeln('That square cannot be changed, press enter to continue');readln;
goto printpuzzle;end;
  psudokupuzzle(@puzzledat.Puzzle)^[row,col]:=y;
  saveGame;
  goto printpuzzle;
  { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
