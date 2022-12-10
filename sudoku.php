<?php
$csudoku_exe="/cygdrive/c/sudoku-console-main/csudoku.exe";//path to csudoku.exe
$rooturl="/";//the url directory where sudoku.php exists
$puzzle="";
$t=$_POST['t']*1;
for($i=0;$i<81;$i++)
if($_POST['x'.$i]*1>0){
$puzzle.=$_POST['x'.$i];
}else{
$puzzle.="0";
}
$cmdParams="";
if($_POST['b']=="Save"){
$saved=array($puzzle,$t,$_POST['num'],$_POST['lvl']);
setcookie('sudoku',implode("_",$saved),time()+60*60*24*7,$rooturl,$_SERVER['SERVER_NAME']);;
}
$won=2;
if($_POST['b']=="Load"){
$saved=explode("_",$_COOKIE['sudoku']);
$cmdParams.=" /puzzle=".$saved[0];
$cmdParams.=" /time=".$saved[1];
$cmdParams.=" /game=".$saved[2];
$cmdParams.=" /level=".$saved[3];
}
if(strlen($_POST['num'])>0&&$_POST['b']=="New game")
$cmdParams.=" /game=".$_POST['num']*1;
if(strlen($_POST['num'])>0&&$_POST['b']!="New game")
$cmdParams.=" /puzzle=".$puzzle;
if($_POST['b']=='Check')
passthru($csudoku_exe." /test /puzzle=".$puzzle,$won);
if($_POST['lvl']*1>0&&$_POST['lvl']*1<6&&$_POST['b']!="Load")
$cmdParams.=" /level=".$_POST['lvl'];
if($won==1){?><!doctype html>
<html>
<head>
<title>Sudoku Winner</title>
</head>
<body>
<h1>Congradulations, you won!</h1>
<form method="post">
Game#:<input type="text" name="num">
Level:<input type="number" name="lvl" value="1" min="1" max="5">
<input type="submit" name="b" value="New game"></form>
<?php die('</body></html>');}
passthru($csudoku_exe." /view=html".$cmdParams." /time=".$t);
?>