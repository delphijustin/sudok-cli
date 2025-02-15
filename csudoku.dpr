program csudoku;

{$APPTYPE CONSOLE}
{$RESOURCE PUZZLES1.RES}
{$RESOURCE PUZZLES2.RES}
{$RESOURCE PUZZLES3.RES}
{$RESOURCE PUZZLES4.RES}
{$RESOURCE PUZZLES5.RES}
{$RESOURCE CSUDOKU32.RES}
uses
  classes,
  SysUtils,
  windows,
  graphics,
  shellapi,
  forms,
  csudoku1 in 'csudoku1.pas' {SudokuPicture};
const
readonlydigit:array[boolean]of string=('>',
'readonly>');
readonlyclass:array[boolean]of string=('','nomodify');
var i,j:integer;
htmlt:extended=-1;
wrote,unsize:dword;
toptenname:array[0..max_path]of char;
systime:tsystemtime;
sCell,sudoGame,sGame:string;
gamef:ansistring;
currentUndo:longint;
gamenum:word;
winnerbmp:TBitmap;
conCanvas:tcanvas;
conRect:TRect;
label printPuzzle,checkPuzzle;
function GetConsoleWindow:hwnd;stdcall;external kernel32;
procedure saveGame;
var wrote:dword;
I:integer;
undoData:pointer;
begin
(* This procedure saves the game *)
hsaved:=createfile(savname,generic_write,file_share_read or file_share_write or
file_share_delete,nil,create_always,file_attribute_normal,0);
writefile(hsaved,puzzledat,sizeof(puzzledat),wrote,nil);
for I:=0to undo.Count-1do begin undodata:=undo[i];writefile(hsaved,undodata,4,
wrote,nil);end;
closehandle(hsaved);
end;
function getOutputFormat:integer;
begin
result:=-1;
if args.IndexOf('/view')>0then result:=0;
if comparetext('html',args.values['/view'])=0then result:=1;
if comparetext('csv',args.values['/view'])=0then result:=2;
if comparetext('jpeg',args.values['/view'])=0then result:=3;
if comparetext('bitmap',args.values['/view'])=0then result:=4;
if comparetext('printer',args.values['/view'])=0then result:=5;
if comparetext('newbatch',args.values['/view'])=0then result:=6;
if comparetext('oldbatch',args.values['/view'])=0then result:=7;
end;
function gameClock(reserved:pointer):dword;
var caption:array[byte]of char;
begin
while true do begin
setconsoletitle(strfmt(caption,'delphijustin Sudoku(%d days, %s)',[trunc(
puzzledat.seconds*encodetime(0,0,1,0)),formatdatetime('hh:mm:ss',
puzzledat.seconds*encodetime(0,0,1,0))]));inc(puzzledat.seconds);
sleep(1000);savegame;
end;
result:=0;
end;
function InRange(x,y,z:Integer):boolean;
begin
result:=(x>=y)and(x<=z);
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
foreground_blue;cell:PByte=nil);
begin
if getoutputformat>-1then exit;
if cell<>nil then
case cell^ and sudo_highlight of
sudo_red:SetConsoleTextAttribute(conout,color or background_red);
sudo_green:SetConsoleTextAttribute(conout,color or background_green)
else SetConsoleTextAttribute(conout,color);
end else SetConsoleTextAttribute(conout,color);
end;

function getDigit(x:byte):byte;
begin
result:=puzzledat.puzzle[x]and sudo_number;
end;

function GetWinValue(row,typ:byte):integer;
var x:integer;
begin
result:=1;
case typ of
1:case row of
1:result:=getdigit(1)*getdigit(2)*getdigit(3)*
getdigit(4)*getdigit(5)*getdigit(6)*getdigit(7)*
getdigit(8)*getdigit(9);
2:result:=getdigit(10)*getdigit(11)*getdigit(12)*
getdigit(13)*getdigit(14)*getdigit(15)*
getdigit(16)*getdigit(17)*getdigit(18);
3:result:=getdigit(19)*getdigit(20)*getdigit(21)*
getdigit(22)*getdigit(23)*getdigit(24)*
getdigit(25)*getdigit(26)*getdigit(27);
4:result:=getdigit(28)*getdigit(29)*getdigit(30)*
getdigit(31)*getdigit(32)*getdigit(33)*
getdigit(34)*getdigit(35)*getdigit(36);
5:result:=getdigit(37)*getdigit(38)*getdigit(39)*
getdigit(40)*getdigit(41)*getdigit(42)*
getdigit(43)*getdigit(44)*getdigit(45);
6:result:=getdigit(46)*getdigit(47)*getdigit(48)*
getdigit(49)*getdigit(50)*getdigit(51)*
getdigit(52)*getdigit(53)*getdigit(54);
7:result:=getdigit(55)*getdigit(56)*getdigit(57)*
getdigit(58)*getdigit(59)*getdigit(60)*
getdigit(61)*getdigit(62)*getdigit(63);
8:result:=getdigit(64)*getdigit(65)*getdigit(66)*
getdigit(67)*getdigit(68)*getdigit(69)*
getdigit(70)*getdigit(71)*getdigit(72);
9:result:=getdigit(73)*getdigit(74)*getdigit(75)*
getdigit(76)*getdigit(77)*getdigit(78)*
getdigit(79)*getdigit(80)*getdigit(81);
end;
2:for x:=1to 9 do result:=result*getdigit(9*x-(row-1));
3:case row of
1:begin for x:=1to 3do result:=result*getdigit(x);
for x:=10to 12do result:=result*getdigit(x);
for x:=19to 21do result:=result*getdigit(x);
 end;
2:begin for x:=4to 6do result:=result*getdigit(x);
for x:=13to 15do result:=result*getdigit(x);
for x:=22to 24do result:=result*getdigit(x);
 end;
 3:begin for x:=7to 9do result:=result*getdigit(x);
for x:=16to 18do result:=result*getdigit(x);
for x:=25to 27do result:=result*getdigit(x);
 end;
 4:begin for x:=28to 30do result:=result*getdigit(x);
for x:=37to 39do result:=result*getdigit(x);
for x:=46to 48do result:=result*getdigit(x);
 end;
 5:begin for x:=31to 33do result:=result*getdigit(x);
for x:=40to 42do result:=result*getdigit(x);
for x:=49to 51do result:=result*getdigit(x);
 end;
 6:begin for x:=34to 36do result:=result*getdigit(x);
for x:=43to 45do result:=result*getdigit(x);
for x:=52to 54do result:=result*getdigit(x);
 end;
 7:begin for x:=55to 57do result:=result*getdigit(x);
for x:=64to 66do result:=result*getdigit(x);
for x:=73to 75do result:=result*getdigit(x);
 end;
 8:begin for x:=58to 60do result:=result*getdigit(x);
for x:=67to 69do result:=result*getdigit(x);
for x:=76to 78do result:=result*getdigit(x);
 end;
 9:begin for x:=61to 63do result:=result*getdigit(x);
for x:=70to 72do result:=result*getdigit(x);
for x:=79to 81do result:=result*getdigit(x);
 end;
 end;
end;
end;


procedure getrowcol(index:integer;var row,col:dword);
var I,J:Integer;
begin
for i:=1to 9do
for j:=1to 9do
if @psudokupuzzle(@puzzledat.Puzzle)[i,j]=@puzzledat.Puzzle[index]then begin
row:=i;col:=j;
 end;
end;

function getKey(caption:string;choicefmt:string=choice_params):dword;
var choice_cmd:array[0..255]of char;
begin
consoleexec.lpParameters:=strfmt(choice_cmd,pchar(choicefmt),[caption]);
consoleexec.lpFile:=choice_exe;
if not shellexecuteex(@consoleexec)then begin
writeln('choice(',getlasterror,') failed: Does MS-DOS Choice exist on this computer');
exitprocess(getlasterror);
end;
waitforsingleobject(consoleexec.hProcess,infinite);
getexitcodeprocess(consoleexec.hProcess,result);
closehandle(consoleexec.hProcess);
end;

procedure chooselevel;
var lvl:dword;
res:tresourcestream;
sgame:string;
Game:word;
begin
lvl:=getkey('',choice_levels);
if (lvl>0)and(lvl<6)then
begin
res:=tresourcestream.CreateFromID(hinstance,lvl,'PUZZLES');
puzzles.LoadFromStream(res);res.Free;game:=random(puzzles.count);sgame:=inttostr(
game);write('Enter Game# or press enter[',sgame,']:');readln(sgame);game:=
strtointdef(sgame,game);if game>=puzzles.Count then begin
writeln('Enter a number between 0 and ',puzzles.count-1);
write('Press enter to return to the game...');readln;exit;end;
end else exit;
puzzledat.level:=lvl;
puzzledat.gamenum:=game;
newgame(@puzzledat);
end;

procedure UndoLast;
var row,col,y,x:byte;
begin
if undo.Count=0then begin
write('No more undos, press enter to continue...');readln;exit;
end;
x:=hibyte(loword(longint(undo.last)));
y:=lobyte(loword(longint(undo.last)));
row:=lobyte(hiword(longint(undo.last)));
col:=hibyte(hiword(longint(undo.last)));
psudokupuzzle(@puzzledat.Puzzle)^[row,col]:=y;
undo.Remove(Pointer(makelong(makeword(y,x),makeword(row,col))));
end;
function compareTopTen(a,b:PTopTen):Integer;
begin
result:=0;
if a.Seconds<b.Seconds then result:=-1;
if a.Seconds>b.Seconds then result:=1;
end;
procedure viewTopTen(score:PTopTen;pauseMessage:string);
var I:Integer;
wrote:dword;
score0:PTopTen;
begin
htopten:=createfile(toptenname,generic_read or generic_write,file_share_read or
file_share_write or file_share_delete,nil,open_always,file_attribute_normal,0);
topten.Clear;
if score<>nil then topten.Add(score);
for i:=0to 9 do begin new(score0);zeromemory(score0,sizeof(ttopten));
score0.Seconds:=maxdword;readfile(htopten,score0^,sizeof(ttopten),wrote,nil);
topten.Add(score0);end;topten.Sort(@comparetopten);
for I:=0to 9 do begin
if ptopten(topten[i]).Level>0then begin
write(I+1,'. ',PTopTen(topten[i]).name,' ',trunc(ptopten(topten[i]).seconds*
encodeTime(0,0,1,0)),' days ',formatdatetime('hh:mm:ss',encodetime(0,0,1,0)*
PTopten(topten[i]).seconds),#32,levels[ptopten(topten[i]).level]);
if topten[i]=score then write('<-- Thats you');
writeln;
end else writeln(I+1,'. (blank)');
end;
setfilepointer(htopten,0,nil,file_begin);
for I:=0to 9do begin writefile(htopten,topten[i]^,sizeof(ttopten),wrote,nil);
dispose(topten[i]);
end;
closehandle(htopten);
write(pausemessage);readln;
end;

begin
  try
  hclock:=0;
  strplcopy(toptenname,changefileext(paramstr(0),'.ten'),max_path);
  conout:=getstdhandle(std_output_handle);
  puzzledat.gamenum:=maxword;
  args:=tstringlist.create;args.CommaText:=strpas(getcommandline);
  if args.IndexOf('/?')>0 then
  begin
    writeln('Usage: ',extractfilename(paramstr(0)),
' [/game=number] [/level=number] [/view[=html|csv|bitmap|jpeg|newbatch|oldbatch]] [/puzzle=81digitpuzzle [/test]]');
    writeln('Parameters:');
    writeln('/game      Game number to load');
    writeln('/level     Level to use, heres the list of numbers:');
    for I := 1 to High(levels) do
    writeln('           ',i,'=',levels[i]);
    writeln('/view      Print a sudoku puzzle to the console and quit');
    writeln('/puzzle    Load a 81 digit puzzle using 0 as the blank squares');
    writeln('/test      Checks for a solved puzzle, returns 1 for solved 0 if not. You must also specify /puzzle');
    exitprocess(0);
  end;
   puzzleres:=tresourcestream.CreateFromId(hinstance,abs(strtointdef(
   args.values['/level'],1)),'PUZZLES');
  puzzledat.Level:=strtointdef(args.Values['/level'],1);
  randomize;
    undo:=tlist.Create;
  puzzles:=tstringlist.create;
  puzzles.LoadFromStream(puzzleres);
  puzzledat.gamenum:=strtointdef(args.values['/game'],random(puzzles.Count));
  gamenum:=puzzledat.gamenum;
if fileexists(strplcopy(savname,changefileext(paramstr(0),'.sav'),max_path))and
(paramcount=0)then
begin
hsaved:=createfile(savname,generic_read,File_share_read or File_share_write or
File_share_delete,nil,open_existing,file_attribute_normal,0);
readfile(hsaved,puzzledat,sizeof(puzzledat),bytesread,nil);
if(getfilesize(hsaved,nil)>sizeof(puzzledat))and(getfilesize(hsaved,nil)<maxint)
then for I:=1to (getfilesize(hsaved,nil)-sizeof(puzzledat))div 4do begin
readfile(hsaved,currentundo,4,bytesRead,nil);undo.Add(Pointer(currentundo));
end;
closehandle(hsaved);
end else begin if length(args.values['/puzzle'])=81then begin
sudogame:=puzzles[puzzledat.gamenum];
puzzles.Text:=args.Values['/puzzle'];puzzledat.gamenum:=0;
end;newgame(@puzzledat);end;
topten:=tlist.create;
  zeromemory(@consoleexec,sizeof(consoleexec));
  consoleExec.cbSize:=sizeof(consoleexec);
  consoleexec.fMask:=SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_NO_UI or
  SEE_MASK_NO_CONSOLE or SEE_MASK_DOENVSUBST;
  if args.IndexOf('/test')>0then goto checkpuzzle;
  if getoutputformat=-1then begin
writeln(' ____            _       _  __ ');
writeln('/ ___| _   _  __| | ___ | |/ /   _');
writeln('\___ \| | | |/ _` |/ _ \| ',chr(39),' / | | ');
writeln(' ___) | |_| | (_| | (_) | . \ |_| |');
writeln('|____/ \__,_|\__,_|\___/|_|\_\__,_|');
writeln;
writeln('Console Edition v1.1 by Justin Roeder');
writeln('https://delphijustin.biz');
write('Loading');
winnerbmp:=tbitmap.Create;
winnerbmp.LoadFromResourceID(hinstance,1);
concanvas:=tcanvas.Create;
concanvas.Handle:=getdc(getconsolewindow);
for i:=1to 5do begin sleep(1000);write('.');end;
hclock:=createthread(nil,0,@gameclock,nil,0,tid);
  printPuzzle:
  consoleexec.lpFile:=ComSpec;
  consoleexec.lpParameters:=cmd_cls;
  shellexecuteex(@consoleexec);
  waitforsingleobject(consoleexec.hProcess,infinite);
  closehandle(consoleexec.hProcess);
end else begin
case getoutputformat of
6:begin
gamef:='@echo off'#13#10;
for i:=1to 81do begin getrowcol(i,row,col);if puzzledat.Puzzle[i]>0then
gamef:=gamef+format('set s%d_%d=%d'#13#10,[row,col,puzzledat.puzzle[i]and
sudo_number])else
gamef:=gamef+format('set s%d_%d=_'#13#10,[row,col]);end;
gamef:=gamef+
':echoPuzzle'#13#10'cls'#13#10'echo   1 2 3 4 5 6 7 8 9'#13#10'echo  +-+-+-+-+-+-+-+-+-+'#13#10;
for I:=1to 9do begin
gamef:=gamef+format('echo %d�',[i]);
for j:=1to 9do gamef:=gamef+format('%%s%d_%d%%�',[i,j]);
if i=1then gamef:=gamef+format(' Game#: %u Level: %s',[puzzledat.gamenum,levels[
puzzledat.level]]);
gamef:=gamef+#13#10'echo  +-+-+-+-+-+-+-+-+-+'#13#10;
end;
gamef:=gamef+
'choice /C 123456789X /N /M "Enter Row: "'#13#10'if errorlevel 255 goto choiceError'#13#10'if errorlevel 10 goto quit'#13#10;
for i:=9downto 1 do gamef:=gamef+format('if errorlevel %d goto row%d'#13#10,[i,i]);
gamef:=gamef+'goto choiceError'#13#10':setcol'#13#10'choice /C 123456789X /N /M "Enter Column: "'#13#10'if errorlevel 255 goto choiceError'#13#10;
for I:=9downto 1 do gamef:=gamef+format('if errorlevel %d goto col%d'#13#10,[i,i]);
gamef:=gamef+'goto choiceError'#13#10':setval'#13#10'choice /C 1234567890CX /N /M "Enter Value: "'#13#10'if errorlevel 255 goto choiceError'#13#10'if errorlevel 12 goto quit'#13#10'if errorlevel 11 goto echoPuzzle'#13#10;
for I:=10downto 1 do gamef:=gamef+format('if errorlevel %d goto val%d'#13#10,[i,i]);
gamef:=gamef+'goto choiceError'#13#10;
for i:=1to 9do gamef:=gamef+format(':row%d'#13#10'set row=%d'#13#10'goto setcol'#13#10,[i,i]);
for i:=1to 9do gamef:=gamef+format(':col%d'#13#10'set col=%d'#13#10'goto setval'#13#10,[i,i]);
for i:=1to 9do gamef:=gamef+format(':val%d'#13#10'set val=%d'#13#10'goto apply'#13#10,[i,i]);
gamef:=gamef+
':val10'#13#10'set val=_'#13#10':apply'#13#10'set s%row%_%col%=%val%'#13#10'goto echoPuzzle'#13#10':choiceError'#13#10'echo Choice command failed'#13#10'pause'#13#10':quit';
exitprocess(ord(not writefile(conout,gamef[1],length(gamef),wrote,nil)));
end;
7:begin
gamef:='@echo off'#13#10;
for i:=1to 81do begin getrowcol(i,row,col);if puzzledat.Puzzle[i]>0then
gamef:=gamef+format('set s%d_%d=%d'#13#10,[row,col,puzzledat.puzzle[i]and
sudo_number])else
gamef:=gamef+format('set s%d_%d=_'#13#10,[row,col]);end;
gamef:=gamef+
':echoPuzzle'#13#10'cls'#13#10'echo   1 2 3 4 5 6 7 8 9'#13#10'echo  +-+-+-+-+-+-+-+-+-+'#13#10;
for I:=1to 9do begin
gamef:=gamef+format('echo %d!',[i]);
for j:=1to 9do gamef:=gamef+format('%%s%d_%d%%!',[i,j]);
if i=1then gamef:=gamef+format(' Game#: %u Level: %s',[puzzledat.gamenum,levels[
puzzledat.level]]);
gamef:=gamef+#13#10'echo  +-+-+-+-+-+-+-+-+-+'#13#10;
end;
gamef:=gamef+
'choice /C:123456789X /N "Enter Row: "'#13#10'if errorlevel 255 goto choiceError'#13#10'if errorlevel 10 goto quit'#13#10;
for i:=9downto 1 do gamef:=gamef+format('if errorlevel %d goto row%d'#13#10,[i,i]);
gamef:=gamef+'goto choiceError'#13#10':setcol'#13#10'choice /C:123456789X /N "Enter Column: "'#13#10'if errorlevel 255 goto choiceError'#13#10;
for I:=9downto 1 do gamef:=gamef+format('if errorlevel %d goto col%d'#13#10,[i,i]);
gamef:=gamef+'goto choiceError'#13#10':setval'#13#10'choice /C:1234567890CX /N "Enter Value: "'#13#10'if errorlevel 255 goto choiceError'#13#10'if errorlevel 12 goto quit'#13#10'if errorlevel 11 goto echoPuzzle'#13#10;
for I:=10downto 1 do gamef:=gamef+format('if errorlevel %d goto val%d'#13#10,[i,i]);
gamef:=gamef+'goto choiceError'#13#10;
for i:=1to 9do gamef:=gamef+format(':row%d'#13#10'set row=%d'#13#10'goto setcol'#13#10,[i,i]);
for i:=1to 9do gamef:=gamef+format(':col%d'#13#10'set col=%d'#13#10'goto setval'#13#10,[i,i]);
for i:=1to 9do gamef:=gamef+format(':val%d'#13#10'set val=%d'#13#10'goto apply'#13#10,[i,i]);
gamef:=gamef+
':val10'#13#10'set val=_'#13#10':apply'#13#10'set s%row%_%col%=%val%'#13#10'goto echoPuzzle'#13#10':choiceError'#13#10'echo Choice command failed'#13#10'pause'#13#10':quit';
exitprocess(ord(not writefile(conout,gamef[1],length(gamef),wrote,nil)));
end;
-1:;
2:begin gamef:='';
for I:=1to 9do begin
for J:=1to 9do if psudokupuzzle(@puzzledat.Puzzle)^[i,j]>0then
gamef:=gamef+inttostr(psudokupuzzle(@puzzledat.Puzzle)^[i,j]and 15)+','else
gamef:=gamef+',';
gamef:=gamef+#13#10;
end;
exitprocess(ord(not writefile(conout,gamef[1],length(gamef),wrote,nil)));
end;
1:begin
getsystemtime(systime);
htmlt:=0;
texttofloat(pchar(args.Values['/time']),htmlt,fvextended);
if htmlt=0then htmlt:=systemtimetodatetime(systime);
gamef:='<!doctype html><html><head><title>Sudoku '+levels[puzzledat.level]+'</title><style>.tg  {border-collapse:collapse;border-spacing:0;}'+
'.box1{background-color:silver;}'+
'.tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;'+
'  overflow:hidden;padding:10px 5px;word-break:normal;}'+
'.tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;'+
'  font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}'+
'.tg .tg-0lax{text-align:left;vertical-align:top}'+
'.digit{width:24px;}.nomodify{color:blue;}</style><script>var t;'+
'function startGame(){t=new Date("01/01/19970 "+document.getElementById("clock").innerText);setInterval(function(){'+
't.setTime(t.getTime()+1000);document.getElementById("clock").innerText=t.toTimeString().split(" ")[0];},1000);}</script></head>'+
'<body onload="startGame()"><form method="post"><input type="hidden" name="t" value="'+floattostr(htmlt)+'"><center id="clock">'+
formatdatetime('hh:mm:ss',systemtimetodatetime(systime)-htmlt)+
'</center><p><table class="tg"><tbody>';
if length(sudogame)<>81then sudogame:=puzzles[puzzledat.gamenum];
for i:=0to 80do begin scell:=inttostr(puzzledat.puzzle[i+1]and sudo_number);
if(puzzledat.Puzzle[i+1]=0)then scell:='';getrowcol(i+1,row,col);
case i mod 9of
0:gamef:=gamef+'<tr><td class="box'+inttostr(ord(cellbackground(row,col)>0))+
'"><input type="text" maxlength="1" name="x'+inttostr(i)+
'" class="digit '+readonlyclass[sudogame[i+1]<>'0']+'" value="'+scell+'" '+
readonlydigit[sudogame[i+1]<>'0']+'</td>';
8:gamef:=gamef+'<td class="box'+inttostr(ord(cellbackground(row,col)>0))+
'"><input type="text" maxlength="1" name="x'+inttostr(i)+'" class="digit '+readonlyclass[sudogame[i+1]<>'0']+'" value="'+scell+'" '+readonlydigit[sudogame[i+1]<>'0']+'</td></tr>';
else
gamef:=gamef+'<td class="box'+inttostr(ord(cellbackground(row,col)>0))+
'"><input type="text" maxlength="1" name="x'+inttostr(i)+'" class="digit '+readonlyclass[sudogame[i+1]<>'0']+'" value="'+scell+'" '+readonlydigit[sudogame[i+1]<>'0']+'</td>';
end;
end;
gamef:=gamef+
'</tbody></table></p>Game#:<input type="text" name="num" value="';
if(args.IndexOfName('/game')>0)then gamef:=gamef+args.Values['/game']else gamef:=
gamef+inttostr(gamenum);gamef:=gamef+'" name="num"><input type="submit" name="b" value="Check"><input type="submit" value="New game" name="b"><input type="submit" name="b" value="Load"><input type="submit" name="b" value="Save"><br></form></body></html>';
exitprocess(ord(not writefile(conout,gamef[1],length(gamef),wrote,nil)));
end;
3..5:begin
  Application.Initialize;
  application.createform(tsudokupicture,sudokupicture);
  application.run;
end;
end;
end;
highlightcell;
  writeln(format('Game# %u, Level: %s',[puzzledat.gamenum ,levels[puzzledat.Level]]));
bwon:=true;
  writeln('  1 2 3 4 5 6 7 8 9');
  writeln(' +-+-+-+-+-+-+-+-+-+');
  checkpuzzle:
  for I := 1 to 9 do
  begin
  bwon :=bwon and(getwinvalue(i,1)=sudo_win_value);
if args.indexof('/test')<0then begin
 write(i,'|');
  for j := 1 to 9 do
    begin
    if psudokupuzzle(@puzzledat.Puzzle)^[i,j]and sudo_cell_used>0 then
    highlightcell(foreground_red or cellbackground(i,j),@Psudokupuzzle(
    @puzzledat.puzzle)^[i,j])else highlightcell(7 or cellbackground(i,j),
    @Psudokupuzzle(@puzzledat.puzzle)^[i,j]);
    if psudokupuzzle(@puzzledat.Puzzle)^[i,j]AND SUDO_NUMBER=0 then
    write(#32)else write(psudokupuzzle(@puzzledat.Puzzle)^[i,j]and sudo_number);
    highlightcell(7);write('|');
    end;
    writeln;
      writeln(' +-+-+-+-+-+-+-+-+-+');
  end;
  end;
  if args.IndexOf('/test')>0then exitprocess(ord(bwon));
  if(args.IndexOf('/view')>0)or(args.IndexOfName('/view')>0)then exitprocess(0);
  if bwon then begin
highlightcell;
writeln('__     __          __          __         _');
writeln('\ \   / /          \ \        / /        | |');
writeln(' \ \_/ /__  _   _   \ \  /\  / /__  _ __ | |');
writeln('  \   / _ \| | | |   \ \/  \/ / _ \| ',chr(39),'_ \| |');
writeln('   | | (_) | |_| |    \  /\  / (_) | | | |_|');
writeln('   |_|\___/ \__,_|     \/  \/ \___/|_| |_(_)');
suspendthread(hclock);
write('Press enter to continue...');
getclientrect(getconsolewindow,conrect);conrect.Left:=0;conrect.Top:=0;
concanvas.StretchDraw(conrect,winnerbmp);readln;
new(score);
unsize:=256;getusername(score.name,unsize);
sysutils.DeleteFile(changefileext(paramstr(0),'.sav'));
write('Enter Your Name[',score.name,']: ');
score.name[0]:=#0;
score.Date:=now;readln(score.name);
unsize:=256;
if strlen(score.name)=0then getusername(score.name,unsize);
score.Seconds:=puzzledat.seconds;score.Level:=puzzledat.level;
viewTopten(score,'Press Enter to start new game...');
puzzledat.gamenum:=random(puzzles.Count);
newgame(@puzzledat);resumethread(hclock);goto printpuzzle;
 end;
  writeln(
'Press x to exit or c to cancel change, press n for new game, L to change level, press u to undo, press T to see top ten');
  keyChoice:=getKey('Enter Row');
  case keychoice of
  1..9:row :=keychoice;
  11:exitprocess(0);
  13:begin gamenum:=random(puzzles.Count);sgame:=inttostr(gamenum);write(
  'Enter game#[',sgame,']: ');readln(sgame);gamenum:=strtointdef(sgame,
  gamenum);if gamenum>=puzzles.Count then begin writeln(
  'Please choose a number between 0 and ',puzzles.count-1);sleep(10000);
  goto printpuzzle;end;puzzledat.gamenum:=gamenum;
  newgame(@puzzledat);goto printpuzzle;end;
  14:begin chooselevel;goto printpuzzle;end;
  15:begin UndoLast;goto printpuzzle;end;
  16:begin viewtopten(nil,'Press enter to return to the game...');
  goto printpuzzle; end;
  else goto printpuzzle;
  end;
  keyChoice:=getKey('Enter Column');
  case keychoice of
  1..9:col :=keychoice;
  11:exitprocess(0);
  13:begin gamenum:=random(puzzles.Count);sgame:=inttostr(gamenum);write(
  'Enter game#[',sgame,']: ');readln(sgame);gamenum:=strtointdef(sgame,
  gamenum);if gamenum>=puzzles.Count then begin writeln(
  'Please choose a number between 0 and ',puzzles.count);sleep(10000);
  goto printpuzzle;end;puzzledat.gamenum:=gamenum;
  newgame(@puzzledat);goto printpuzzle;end;
  14:begin chooselevel;goto printpuzzle;end;
15:begin undoLast;goto printpuzzle;end;
  16:begin viewtopten(nil,'Press enter to return to the game...');
  goto printpuzzle; end;
  else goto printpuzzle;
  end;
  keyChoice:=getKey(
  'Enter Value, press R to highlight red or g to highlight green');
  case keychoice of
  1..10:begin y:=keychoice;if(y=10)then y:=0;end;
  11:exitprocess(0);
  13:begin gamenum:=random(puzzles.Count);sgame:=inttostr(gamenum);write(
  'Enter game#[',sgame,']: ');readln(sgame);gamenum:=strtointdef(sgame,
  gamenum);if gamenum>=puzzles.Count then begin writeln(
  'Please choose a number between 0 and ',puzzles.count);sleep(10000);
  goto printpuzzle;end;puzzledat.gamenum:=gamenum;
  newgame(@puzzledat);goto printpuzzle;end;
  14:begin chooselevel;goto printpuzzle;end;
 15:begin UndoLast;goto printpuzzle;end;
   16:begin viewtopten(nil,'Press enter to return to the game...');
  goto printpuzzle; end;
  17:y:=sudo_red xor psudokupuzzle(@puzzledat.Puzzle)^[row,col];
  18:y:=sudo_green xor psudokupuzzle(@puzzledat.Puzzle)^[row,col];
  else goto printpuzzle;
  end;
if psudokupuzzle(@puzzledat.puzzle)^[row,col]and sudo_cell_used>0 then begin
writeln('That square cannot be changed, press enter to continue');readln;
goto printpuzzle;end;
currentundo:=makelong(makeword(psudokupuzzle(@puzzledat.Puzzle)^[row,col],
undo.Count mod 256),makeword(row,col));undo.Add(pointer(currentundo));
  psudokupuzzle(@puzzledat.Puzzle)^[row,col]:=y;
  saveGame;
  goto printpuzzle;
  { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
