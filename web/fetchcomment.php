<?php
	header('Content-Type: text/plain;charset=utf-8');
	require_once('config.php');
	
	if($_GET['key'] <> $NAMIKO_KEY){
		exit(json_encode(array('Result'=>'Bad Auth')));	
	}
	switch($_GET['action']){
		case('init'):
			$result = $db->query('SELECT MAX(`id`) FROM `comment`');
			$row = $result->fetch_row();
			echo json_encode(array('Result'=>'Accept','Version' => 3,'Timestamp' => time(),'FrontID' => $row[0]));
		break;
		case('fetch'):
			if(isset($_GET['fromID'])){
				$response = array();
				$id = intval($_GET['fromID']);
				$query = sprintf('SELECT `id`,`ip`,UNIX_TIMESTAMP(`time`) as `time`,`format`,`content` FROM `comment` WHERE `id` > %u%s LIMIT 30',$id,($NAMIKO_SEND_ONCE ? ' AND `sent` = 0' : ''));
				if($NAMIKO_SEND_ONCE) $db->query("UPDATE `comment` SET `sent` = 1 WHERE `id` > $id");
				$result = $db->query($query);
				while($row = $result->fetch_assoc()){
					$time = $row['time'];
					$ip = $row['ip'];
					$format = $row['format'];
					$len = strlen($row['content']);
					$content = $row['content'];
					$response[] = array('ID'=> $row['id'], 'Timestamp' => $time,'IP' => $ip,'Format' => $format,'Content' => $content);
				}
				$db->close();
				file_put_contents('DesktopTouch.log',time().'|'.$_GET['totalc']);
				//echo json_encode(array('Result' => 'OK','Data' => $response));
				echo json_encode($response);
			}else{
				echo json_encode(array('Result'=>'No Frontier provided'));
			}
		break;
		default:
			echo json_encode(array('Result'=>'No Operation provided'));
		break;
	}
?>