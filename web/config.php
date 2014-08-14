<?php
/* 	======================================
	Namiko Realtime Curtain Comment Live
	======================================
	Configuration Script on Web-Terminal
	
	You could choose Web Terminal or Desktop Terminal to act as Server and the other is the Client.
*/

error_reporting(E_ALL - E_NOTICE); // You may set the value to 0 to hide error message in production situation

/* Networking */

$NAMIKO_USE_TCP = false; // When this option is true, Comment will be sent to Desktop Terminal immediately via custom TCP server.
$NAMIKO_USE_UDP = true; // When this option is true, Comment will be sent to Desktop Terminal immediately via custom UDP server.
$NAMIKO_SERVER_IPV6 = false; // Turn this to true if connect to desktop terminal via TCPv6
$NAMIKO_SERVER_ADDRESS = '127.0.0.1'; // The IPv4/IPv6 address of Desktop Terminal
$NAMIKO_SERVER_PORT = '20000'; // The listening port of Desktop Terminal
$NAMIKO_MAX_LENGTH = 600; // Max Comment length accepted calculated in bytes
$NAMIKO_SEND_ONCE = true; // If you need more than one desktop clients reading data via HTTP, turn this option FASLE

/* Database	*/

// Note that Database is requried on condition that $NAMIKO_USE_TCP is false, which Desktop Terminal will check for new comments periodly.

$NAMIKO_DB_FUNC = false; // If this option is true, save comments in database even if $NAMIKO_USE_TCP is false;
$NAMIKO_DB_HOST = '127.0.0.1';
$NAMIKO_DB_USER = 'namiko';
$NAMIKO_DB_PASS = 'namiko';
$NAMIKO_DB_NAME = 'namiko';

/* Timing */
$NAMIKO_TIMEZONE = 'Asia/Shanghai'; // Timezone of Server

/* Security */
$NAMIKO_KEY = '233-614-789-998'; // Set the value the same as that of Desktop Terminal

/* Customization */

// The first element of following arrays stands for using default at server. Strongly recommend reserving them.

$NAMIKO_FONTNAME = array('DEF_FN' => '默认字体', 'SimSun' => '宋体', 'SimHei' => '黑体', '华康少女文字W5(P)' => '华康少女文字'); // Font List with format 'English Font Name' => 'Display name you desired', the following is the same.
$NAMIKO_FONTSIZE = array('DEF_FS' => '默认大小','12' => '萝莉字', '15' => '正太字', '18' => '伪正太字', 20 => '路人字', 24 => '大丈夫 用大字', 36 => '巨巨字', 40 => '大到犯规', 2 => '大到封IP');
$NAMIKO_FONTCOLOR = array('DEF_FC' => '默认颜色','$FFFF0000' => '红', '$FF00FF00' => '绿', '$FF0000FF' => '蓝'); // Must use C/Delphi color style: $AABBGGRR means #RRGGBB in HTML/CSS with alpha value AA (FF is opacity and 00 is transparent

/* Wall Options */
define('NAMIKO_WALL_SALT','salt_sarw3lknoa');
$NAMIKO_WALL_REFRESH = 20; // Refresh interval
$NAMIKO_WALL_ADMIN_REFRESH = 10;
$NAMIKO_WALL_LIMIT = 8; // Default displayed comment quantity
$NAMIKO_WALL_DISPLAY_EXTRA = 10; // Extra quantity displayed when More is clicked.
$NAMIKO_WALL_ADMINPASS = 'YA2U@PARA';

/* Don't modify contents below this line! */
if((!$NAMIKO_USE_TCP && !$NAMIKO_USE_UDP) || $NAMIKO_DB_FUNC){
	$db = new mysqli ( );
	@$db->connect ( $NAMIKO_DB_HOST, $NAMIKO_DB_USER, $NAMIKO_DB_PASS, $NAMIKO_DB_NAME );
	if(mysqli_connect_errno()){
		exit('DB CONN ERROR: '.mysqli_connect_error());
	}else{
		$db->query("SET NAMES 'utf8'");
	}
}
date_default_timezone_set($NAMIKO_TIMEZONE);
$stype = $NAMIKO_SERVER_IPV6 ? AF_INET6 : AF_INET;

?>