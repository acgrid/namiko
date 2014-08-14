<?php
function ColorConvert($CColor){
	$R = substr($CColor,7,2);
	$G = substr($CColor,5,2);
	$B = substr($CColor,3,2);
	return "#$R$G$B";
}
function SocketError(){
	$last_error = socket_last_error();
	if($last_error) return "#$last_error ".iconv('gbk','utf-8',socket_strerror($last_error));
}
?>