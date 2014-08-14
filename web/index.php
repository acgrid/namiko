<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="zh-cn" dir="ltr">
<head><title>namiko实时弹幕系统 on CT10</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
<h1>Comitime 10</h1>
<h3>亚娜来一卡</h3>
<?php
error_reporting(E_ALL - E_NOTICE);
require('config.php');
require('func.php');
if(time() - $_GET['time'] < 10){
	$ret_time = strftime('%H:%M:%S',$_GET['time']).' ';
	switch($_GET['info']){
		case('success'):
		echo '<span style="color: Green">'.$ret_time.'发送成功</span><br />';
		break;
		case('socket_connect_fail'):
		echo '<span style="color: Red">'.$ret_time.'服务器未就绪</span><br />';
		break;
		case('socket_send_fail'):
		echo '<span style="color: Red">'.$ret_time.'网络错误</span><br />';
		break;
		case('socket_recv_fail'):
		echo '<span style="color: Red">'.$ret_time.'现场未就绪</span><br />';
		break;
		case('unexpected_result'):
		echo '<span style="color: Red">'.$ret_time.'服务器未接受',$_GET['detail'],'</span><br />';
		break;
		case('discarded'):
		echo '<span style="color: Red">'.$ret_time.'您提交的弹幕含有无意义的信息，未能显示敬请谅解。</span><br />';
		break;	
		case('null'):
		echo '<span style="color: Orange">'.$ret_time.'您发送了空白弹幕。</span><br />'; 
		break;
		case('return'):
		$fast = true;
		echo '<span style="color: Orange">'.$ret_time.'您的请求已提交 请看大屏幕。</span><br />'; 
		break;
		case('oversize'):
		echo '<span style="color: Orange">'.$ret_time.'您的弹幕过长，未能显示敬请谅解。('.$_GET['detail']."/$NAMIKO_MAX_LENGTH)</span><br />"; 
		break;		
	}
}
	if($NAMIKO_USE_TCP && !$fast){
		$socket = socket_create($stype , SOCK_STREAM, SOL_TCP);
		if (!$socket) {
			echo '<span style="color: Red">Web端错误：无法启动Socket套接字。</span><br />';
		}else{
			$result = @socket_connect($socket, $NAMIKO_SERVER_ADDRESS, $NAMIKO_SERVER_PORT);
			if (!$result) {
				echo '<span style="color: Red">桌面端错误：TCP连接失败。</span><br />';
			}else{
				$in = "QUERY\r\n";
				$in .= "QUIT\r\n";
				socket_write($socket, $in, strlen($in));
				
				$out = '';
				while ($out = socket_read($socket, 2048)) {
					$info .= $out;
				}
				if($r_time = strstr($info,'301 Time: ')) $r_time = substr($r_time,strpos($r_time,': ')+2,strpos($r_time,"\r")-strpos($r_time,': ')-1);
				if($count = strstr($info,'302 Comment Count: ')) $count = substr($count,strpos($count,': ')+2,strpos($count,"\r")-strpos($count,': ')-1);
				socket_close($socket);
				if($r_time) {
					$working = true;
					echo '<span style="color: Green">',"$r_time 弹幕系统正常运行 已有 <b>$count</b> 条弹幕</span><br />";
				}else{
					echo '<span style="color: Orange">获取服务器信息失败，请 <a href="',$_SERVER['PHP_SELF'],'">刷新</a></span><br />';
				}
			}
		}
	}elseif($NAMIKO_USE_UDP){
		$socket = socket_create($stype, SOCK_DGRAM, SOL_UDP);
		if(!$socket) echo '<span style="color: Red">Web端错误：无法启动Socket套接字:',SocketError(),'</span><br />';
		socket_set_option($socket,SOL_SOCKET,SO_RCVTIMEO,array("sec"=>3,"usec"=>0));
		$data = json_encode(array('Request' => 'Query'));
		if(!socket_sendto($socket, $data, strlen($data), 0, $NAMIKO_SERVER_ADDRESS, $NAMIKO_SERVER_PORT)) echo '<span style="color: Red">网络错误：UDP发送失败: ',SocketError(),'</span><br />';
		if(!@socket_recvfrom($socket,$buf,8192,0,$NAMIKO_SERVER_ADDRESS,$NAMIKO_SERVER_PORT)) echo '<span style="color: Red">网络错误：UDP接收失败: ',SocketError(),'</span><br />';
		socket_close($socket);
		if($buf && $recv = json_decode($buf)){
			if(isset($recv->LocalTime) && isset($recv->CommentCount)) printf('<span style="color: Green">%s 弹幕系统正常运行 已有 <b>%s</b> 条弹幕</span><br />',$recv->LocalTime,$recv->CommentCount);
		}else{
			echo '<span style="color: Orange">获取服务器信息失败，请 <a href="',$_SERVER['PHP_SELF'],'">刷新</a></span><br />';
			print_r($buf);
		}
	}else{
		if($touch = @file_get_contents('DesktopTouch.log')){
			list($t_time,$count) = explode('|',$touch);
			if(mktime() - $t_time > 5){
				echo '<span style="color: Orange">桌面端超时：没有回应。</span><br />';
			}else{
				echo '<span style="color: Green">',strftime('%H:%M:%S',$t_time)," 弹幕系统正常运行 已有 <b>$count</b> 条弹幕</span><br />";
			}
		}else{
			echo '<span style="color: Orange">桌面端错误：没有连接记录。</span><br />';
		}
	}
?>
<form action="submit.php" method="post">
<select name="fontname"><?php
	foreach($NAMIKO_FONTNAME as $FN => $FND){
		echo '<option value="'.$FN.'" ';
		if($_GET['fn'] == $FN) echo 'selected="selected"';
		echo ">$FND</option>";
	}
?></select>
<select name="fontsize"><?php
	foreach($NAMIKO_FONTSIZE as $FS => $FSD){
		echo '<option value="'.$FS.'" ';
		if($_GET['fs'] == $FS) echo 'selected="selected"';
		echo ">$FSD</option>";
	}
?></select>
<select name="fontcolor"><?php
	require_once('func.php');
	foreach($NAMIKO_FONTCOLOR as $FC => $FCD){
		echo '<option value="'.$FC.'" style="color: '.ColorConvert($FC).'" ';
		if($_GET['fc'] == $FC) echo 'selected="selected"';
		echo ">$FCD</option>";
	}
?></select><br />
署名：<input type="text" name="sign" size="15" value="<?php echo htmlspecialchars($_GET['sign']); ?>" /><br />
内容：<input type="text" name="comment" size="40" value="" /><input type="submit" value="发射" /><br />
<input type="hidden" name="script" value="<?php echo $_SERVER['PHP_SELF']; ?>" />
<input type="hidden" name="zone" value="1" />
</form><span style="color: Red;">无意义的弹幕一律没收不退还。最大长度<?php echo $NAMIKO_MAX_LENGTH ?>个字节。</span></body></html>