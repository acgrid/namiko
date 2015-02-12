<?php
function ColorConvert($CColor){
	$R = substr($CColor,7,2);
	$G = substr($CColor,5,2);
	$B = substr($CColor,3,2);
	return "#$R$G$B";
}
?>