<?php
	require_once('config.php');
	file_put_contents('Post.log',implode(',',$_POST));
	
	$content = isset($_POST['comment']) ? trim($_POST['comment']) : NULL;
	$sign = trim($_POST['sign']);
	if(!empty($sign)) $content .= " <$sign>";

	if (function_exists('get_magic_quotes_gpc') && get_magic_quotes_gpc()) $content = stripslashes($content);
	if ($_POST['script'] == 'CustomClient') $NoRedirect = true;

	$format_url = '&fn='.$_POST['fontname'].'&fs='.$_POST['fontsize'].'&fc='.$_POST['fontcolor'];
	$format = $_POST['fontname'].'|'.$_POST['fontsize'].'|'.$_POST['fontcolor'].'|DEF_FP';
	$sw = isset($_POST['sw']) && intval($_POST['sw']) > 0 ? (int) $_POST['sw'] : 32;
	$script = 'index.php?time='.time().(empty($sign) ? '' : '&sign='.urlencode($sign));

	if(empty($content)){
		header("Location: $script&info=null$format_url");
		exit;
	}
	$hexiefile = 'HexieList.lst';
	if(file_exists($hexiefile)){
		$hexielist = file($hexiefile);
		foreach($hexielist as $hexieline){
			if(preg_match('/'.trim($hexieline).'/mi',$content)){
				header("Location: $script&info=return$format_url");
				ob_flush();
				exit;
			}
		}
	}
	$time = time();
	$len = strlen($content);
	$ip = $_SERVER['REMOTE_ADDR'];
	$sent = false;
	
	if($NAMIKO_USE_UDP && strlen($content) > $NAMIKO_MAX_LENGTH){
		header("Location: $script&info=oversize&detail=$len$format_url");
		exit;
	}
	
	if($NAMIKO_USE_UDP){
		$socket = socket_create($stype, SOCK_DGRAM, SOL_UDP);
		if (!$socket) {
			if(!$fastr && $zone == $sid) header("Location: $script&info=socket_create_fail$format_url&detail=". socket_strerror($socket));
		}else{
			socket_set_option($socket,SOL_SOCKET,SO_RCVTIMEO,array("sec"=>3,"usec"=>0));
			$data = json_encode(array('Request' => 'Data','Auth' => $NAMIKO_KEY,'Content' => $content,'Source' => $ip,'Time' => $time,'N' => $_POST['fontname'],'S' => $_POST['fontsize'],'C' => $_POST['fontcolor'],'D' => 'DEF_FP'));
			if(@socket_sendto($socket, $data, strlen($data), 0, $NAMIKO_SERVER_ADDRESS, $NAMIKO_SERVER_PORT)) {				
				if(@socket_recvfrom($socket,$buf,8192,0,$NAMIKO_SERVER_ADDRESS,$NAMIKO_SERVER_PORT)){
					if($buf && $recv = json_decode($buf)){
						/*print_r($recv);
						exit;*/
						if($recv->Result == 'Recvived'){
							header("Location: $script&info=success$format_url");
						}elseif($recv->Result == 'Rejected'){
							header("Location: $script&info=discarded$format_url");
						}else{
							header("Location: $script&info=discarded2$format_url");
						}
					}else{
						header("Location: $script&info=unexpected_result$format_url");
					}
				}else{
					header("Location: $script&info=socket_recv_fail$format_url");
				}
			}else{
				header("Location: $script&info=socket_send_fail$format_url&detail=".socket_last_error());
			}
		}
	}
	if($NAMIKO_DB_FUNC || !$sent){
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