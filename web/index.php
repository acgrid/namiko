<!DOCTYPE html>
<html lang="zh-cn" dir="ltr">
<head><title>Comitime 11 弹幕</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
<h2>Comitime 11</h2>
<?php
error_reporting(E_ALL - E_NOTICE);
require_once('config.php');
if(time() - $_GET['time'] < 10){
	$ret_time = strftime('%H:%M:%S',$_GET['time']).' ';
	switch($_GET['info']){
		case('success'):
		echo '<span style="color: Green">'.$ret_time.'发送成功</span><br />';
		break;
		case('socket_connect_fail'):
		echo '<span style="color: Red">'.$ret_time.'服务器未就绪</span><br />';
		break;
		case('unexpected_result'):
		echo '<span style="color: Red">'.$ret_time.'服务器未接受',$_GET['detail'],'</span><br />';
		break;
		case('discarded'):
		echo '<span style="color: Red">'.$ret_time.'您提交的弹幕不符合有关规定，未能显示敬请谅解。</span><br />';
		break;	
		case('null'):
		echo '<span style="color: Orange">'.$ret_time.'您发送了空白弹幕。</span><br />'; 
		break;
		case('return'):
		$fast = true;
		echo '<span style="color: Orange">'.$ret_time.'您的已收到，如无意外将被显示。</span><br />'; 
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
	}elseif(!$NAMIKO_USE_TCP && !$fast){
		if($touch = @file_get_contents('DesktopTouch.log')){
			list($t_time,$count) = explode('|',$touch);
			if(time() - $t_time > 10){
				echo '<span style="color: Orange">弹幕准备中，请稍候访问。</span><br />';
			}else{
				echo '<span style="color: Green">',strftime('%H:%M:%S',$t_time)," 正常运行 已有 <b>$count</b> 条弹幕</span><br />";
			}
		}else{
			echo '<span style="color: Orange">弹幕准备中，请稍候访问。</span><br />';
		}
	}
?>
<form action="submit.php" method="post">
署名：<input type="text" name="sign" size="15" value="<?php echo $_GET['sign']; ?>" /><br />
评论内容：<input type="text" name="comment" size="40" value="" /><input type="submit" value="发射" />
<input type="hidden" name="script" value="<?php echo $_SERVER['PHP_SELF']; ?>" /><br /><input type="hidden" name="fastreturn" value="true" /></form>
<ul>
<li>最大长度大约为<?php printf('%u',$NAMIKO_MAX_LENGTH / 3)  ?>个文字。</li>
<li>请遵守弹幕礼仪，避免与本次活动无关的言论；禁止人身攻击、无意义刷屏、宣扬国家法律明令禁止的违规内容。</li>
<li>请尊重表演者和其他观众，在吐槽的同时请您全力应援。</li>
<li>由于网络以及程序原因，您的弹幕可能无法被显示或呈现最佳显示效果，敬请谅解。</li>
</ul></body></html>