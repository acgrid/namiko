<?php
	require_once('config.php');
	
	$content = isset($_POST['comment']) ? trim($_POST['comment']) : NULL;
	$fastr = (bool) $_POST['fastreturn'];
	$wall = (bool) $_POST['wall'];
	$sign = trim($_POST['sign']);
	$zone = (int) $_POST['zone'];
	$hexielist = file_exists('HexieList.lst') ? file('HexieList.lst') : array();
	if(!empty($sign)) $content .= " <$sign>";

	if (function_exists('get_magic_quotes_gpc') && get_magic_quotes_gpc()) $content = stripslashes($content);
	if ($_POST['script'] == 'CustomClient') $NoRedirect = true;

	$format_url = '';
	$format = 'DEF_FN|DEF_FS|DEF_FC|DEF_FP';
	$sw = (int) $_POST['sw'] > 0 ? $_POST['sw'] : 32;
	$duration = (int) $_POST['duration'];
	$script = $_POST['script'].'?time='.mktime().(empty($sign) ? '' : '&sign='.urlencode($sign)).'&zone='.$zone;

	foreach($hexielist as $hexieline){
		if(preg_match('/'.trim($hexieline).'/mi',$content)){
			if($wall){
				echo <<<EOT
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><script type="text/javascript" src="wall.js"></script></head>
<body onload="HexieNotify(parent);">
</body></html>
EOT;
			}else{
				header("Location: $script&info=discarded$format_url");
			}
			exit;
		}
	}	
	$f = fopen('danmaku.html','a+');
	if($f){
		fwrite($f,sprintf("%s\t%s\t%s<br />",date('H:i:s'),$_SERVER['REMOTE_ADDR'],htmlspecialchars($content)));
		fclose($f);
	}
	if($fastr){
		if($wall){
			echo <<<EOT
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><script type="text/javascript" src="wall.js"></script></head>
<body onload="SendNotify(parent);">
</body></html>
EOT;
		}else{
			header("Location: $script&info=return$format_url");
			ob_flush();
		}
	}
	if(empty($content)){
		if(!$fastr) header("Location: $script&info=null$format_url");
		exit;
	}
	$time = mktime();
	$len = strlen($content);
	$ip = $_SERVER['REMOTE_ADDR'];
	$sent = false;
	
	if(!$NAMIKO_USE_TCP && strlen($content) > $NAMIKO_MAX_LENGTH){
		if(!$fastr) header("Location: $script&info=oversize&detail=$len$format_url");
		exit;
	}
	
	if($NAMIKO_USE_TCP){
		if(strlen($content) > $NAMIKO_MAX_LENGTH){
			$detail = "&detail=$len";
			if(!$fastr) header("Location: $script&info=oversize&detail=$len$format_url");
			exit;
		}
		$socket = socket_create($NAMIKO_SERVER_IPV6 ? AF_INET6 : AF_INET, SOCK_STREAM, SOL_TCP);
		socket_set_option($socket, SOL_SOCKET, SO_RCVTIMEO, array('sec'=>$t_sec, 'usec'=>$t_usec));
		socket_set_option($socket, SOL_SOCKET, SO_SNDTIMEO, array('sec'=>$t_sec, 'usec'=>$t_usec));
		if (!$socket) {
			if(!$fastr) header("Location: $script&info=socket_create_fail$format_url&detail=". socket_strerror($socket));
		}else{
			$result = @socket_connect($socket, $NAMIKO_SERVER_ADDRESS, $NAMIKO_SERVER_PORT);
			if (!$result) {
				if(!$fastr) header("Location: $script&info=socket_connect_fail$format_url&detail=". socket_strerror($result));
			}else{
				$in = $announce ? "DATA VER=2\t\tKEY=$NAMIKO_KEY\t\tTIME=$time\t\tIP=$ip\t\tFORMAT=$format\t\tSW=$sw\t\tDURATION=$duration\t\tTEXT=$content\t\t\r\n" : "DATA VER=1\t\tKEY=$singlekey\t\tTIME=$time\t\tIP=$ip\t\tFORMAT=$format\t\tLEN=$len\t\tTEXT=$content\t\t\r\n";
				$in .= "QUIT\r\n";
				socket_write($socket, $in, strlen($in));
				$out = '';
				while ($out = socket_read($socket, 2048)) {
					if(strstr($out,'201 Success')) $sent = true;
					if(strstr($out,'4KW')) $hexie = true;
				}
				socket_close($socket);
				if($sent){
					if(!$fastr && !$NoRedirect) header("Location: $script&info=success$format_url");
				}elseif($hexie){
					if(!$fastr) header("Location: $script&info=discarded$format_url");
				}else{
					if(!$fastr) header("Location: $script&info=unexpected_result$format_url");
				}
			}
		}
	}
	if(!$NAMIKO_USE_TCP || $NAMIKO_DB_FUNC || !$sent){
		$stmt = $db->prepare("INSERT `comment`(ip,content,format,sw,sent) VALUES(?,?,?,?,?)");
		if($stmt){
			$s = $sent ? 1 : 0;
			$stmt->bind_param('sssii',$ip,$content,$format,$sw,$sent);
			if($stmt->execute()){
				if($NoRedirect || $wall) {
					if(!$fastr) echo 'Success';
					exit;
				}else{
					if(!$NAMIKO_USE_TCP) header("Location: $script&info=success$format_url");
				}
			}else{
				$detail = mysqli_connect_error();
				if(!$fastr) header("Location: $script&info=db_execute&detail=$detail$format_url");
			}			
		}else{
			echo 'bind_param() error';
			if(!$fastr) header("Location: $script&info=db_prepare$format_url");
		}
		$db->close();
	}
	
?>