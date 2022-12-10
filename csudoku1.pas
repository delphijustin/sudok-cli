unit csudoku1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,jpeg, shellapi, ExtCtrls,printers;

const ComSpec='%ComSpec%';
cmd_cls='/C CLS';
sudo_number=15;
sudo_cell_used=16;
sudo_green=32;
sudo_red=64;
sudo_highlight=sudo_green or sudo_red;
sudo_win_value=2*3*4*5*6*7*8*9;
  levels:array[1..5]of string=('Easiest','Easy','Medium','Hard','Very Hard');
  choice_exe='choice';
  choice_params='/C 1234567890XCNLUTRG /N /M "%s:"';
  CHOICE_LEVELS=
'/C 12345C /N /M "Choose a level between 1=Easiest and 5=Very Hard, press c to cancel"';
  choice_yesno='/M "%s"';
type
TSudokuGameDat=record
  gamenum:word;
  seconds:dword;
  level:byte;
  Puzzle:array[1..81]of byte;
  end;
  PSudokuGameDat=^TSudokuGameDat;
TTopTen=record
Date:TDateTime;
Seconds:dword;
Level:Byte;
name:array[byte]of char;
end;
PTopTen=^TTopTen;
  TSudokuPicture = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    Panel17: TPanel;
    Panel18: TPanel;
    Panel19: TPanel;
    Panel20: TPanel;
    Panel21: TPanel;
    Panel22: TPanel;
    Panel23: TPanel;
    Panel24: TPanel;
    Panel25: TPanel;
    Panel26: TPanel;
    Panel27: TPanel;
    Panel28: TPanel;
    Panel29: TPanel;
    Panel30: TPanel;
    Panel31: TPanel;
    Panel32: TPanel;
    Panel33: TPanel;
    Panel34: TPanel;
    Panel35: TPanel;
    Panel36: TPanel;
    Panel37: TPanel;
    Panel38: TPanel;
    Panel39: TPanel;
    Panel40: TPanel;
    Panel41: TPanel;
    Panel42: TPanel;
    Panel43: TPanel;
    Panel44: TPanel;
    Panel45: TPanel;
    Panel46: TPanel;
    Panel47: TPanel;
    Panel48: TPanel;
    Panel49: TPanel;
    Panel50: TPanel;
    Panel51: TPanel;
    Panel52: TPanel;
    Panel53: TPanel;
    Panel54: TPanel;
    Panel55: TPanel;
    Panel56: TPanel;
    Panel57: TPanel;
    Panel58: TPanel;
    Panel59: TPanel;
    Panel60: TPanel;
    Panel61: TPanel;
    Panel62: TPanel;
    Panel63: TPanel;
    Panel64: TPanel;
    Panel65: TPanel;
    Panel66: TPanel;
    Panel67: TPanel;
    Panel68: TPanel;
    Panel69: TPanel;
    Panel70: TPanel;
    Panel71: TPanel;
    Panel72: TPanel;
    Panel73: TPanel;
    Panel74: TPanel;
    Panel75: TPanel;
    Panel76: TPanel;
    Panel77: TPanel;
    Panel78: TPanel;
    Panel79: TPanel;
    Panel80: TPanel;
    Panel81: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
  procedure initializePuzzle(puzzledat:psudokugamedat);
    { Public declarations }
  end;
  TSudokuPuzzle=array[1..9,1..9]of byte;
  PSudokuPuzzle=^TSudokuPuzzle;
var puzzleres:tresourcestream;
puzzles,args:TStringlist;
puzzledat:tsudokugamedat;
undo,topten:TList;
consoleExec:ShellExecuteInfo;
keyChoice,tid,col,row,bytesread,y:dword;
savname:array[0..max_path]of char;
bwon:boolean;
conout,hclock:thandle;
hsaved,htopten:thandle;
score:PTopten;
orgPuzzle:array[1..81]of byte;
  SudokuPicture: TSudokuPicture;
procedure newGame(puzzledat:PSudokuGameDat);
implementation

{$R *.DFM}

procedure tsudokupicture.initializePuzzle;
var i:integer;
index,dummy:integer;
begin
label1.Caption:=format('Game: %u Level: %s',[puzzledat.gamenum,levels[
puzzledat.level]]);
for i:=0to componentcount-1do
if comparetext(components[i].classname,'tpanel')=0then begin val(copy(components[
i].name,length('panelx'),2),index,dummy);tpanel(components[i]).caption:=inttostr(
puzzledat.Puzzle[index]and sudo_number);if puzzledat.Puzzle[index]=0then
tpanel(components[i]).caption:='';
end;
end;

procedure newGame;
var i:integer;
begin
undo.Clear;
puzzledat.seconds:=0;
  for I := 1 to 81 do begin
  puzzledat.Puzzle[i]:=strtointdef(puzzles[puzzledat.gamenum][i],0);
  if puzzledat.Puzzle[i]>0then puzzledat.Puzzle[i]:=puzzledat.puzzle[i]or
  sudo_cell_used;
  end;

end;

procedure TSudokuPicture.FormCreate(Sender: TObject);
var
choice_exec:tshellexecuteinfo;
choice_params:array[byte]of char;
ms:tmemorystream;
I,choice:integer;
wrote,ec:dword;
copies:word;
page:PSudokuGamedat;
pagelist:TList;
bmp:tbitmap;
jpg:TJpegimage;
begin
zeromemory(@choice_exec,sizeof(choice_exec));
choice_exec.cbSize:=sizeof(choice_exec);
choice_exec.fMask:=SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_NO_UI or
SEE_MASK_NO_CONSOLE;
choice_exec.lpFile:=choice_exe;
choice_exec.nShow:=sw_hide;
choice_exec.lpParameters:=@choice_params;
ms:=tmemorystream.Create;
if comparetext('printer',args.values['/view'])=0then begin
ec:=2;pagelist:=tlist.Create;
writeln('Choose a printer: ');
for i:=0to printer.Printers.Count-1do
writeln(i,'. ',printer.printers[i]);
write('Pick a number: ');
readln(Choice);
printer.PrinterIndex:=choice;
write('Enter number of copies(0=abort): ');
readln(copies);
if Copies>1then begin
strfmt(choice_exec.lpparameters,choice_yesno,['Make each page different']);
shellexecuteex(@choice_exec);waitforsingleobject(choice_exec.hprocess,infinite);
getexitcodeprocess(choice_exec.hprocess,ec);
if ec=1then for I:=1to Copies do begin new(page);page.gamenum:=
random(puzzles.count);page.level:=puzzledat.level;pagelist.Add(page);newgame(
page);
 end;
end;
printer.Title:='delphijustin Sudoku';
if pagelist.Count=0then pagelist.Add(@puzzledat);
printer.BeginDoc;initializepuzzle(pagelist.first); bmp:=getformimage;
printer.Canvas.StretchDraw(rect(0,0,printer.pagewidth,printer.pageheight),bmp);
for I:=1to pagelist.Count-1do begin initializepuzzle(pagelist[i]);
newgame(pagelist[i]);bmp:=getformimage;printer.NewPage;
printer.Canvas.StretchDraw(rect(0,0,printer.pagewidth,printer.pageheight),bmp);
end;
printer.EndDoc;exitprocess(0);
end;
initializepuzzle(@puzzledat);
bmp:=getformimage;
if comparetext('bitmap',args.values['/view'])=0then bmp.SaveToStream(ms);
if comparetext('jpeg',args.values['/view'])=0then begin jpg:=tjpegimage.Create;
jpg.Assign(bmp);jpg.SaveToStream(ms);end;
writefile(conout,ms.memory^,ms.Size,wrote,nil);
exitprocess(ord(wrote<>ms.size));
end;

end.
