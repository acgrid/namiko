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
$NAMIKO_SERVER_IPV6 = false; // Turn this to true if connect to desktop terminal via TCPv6
$NAMIKO_SERVER_ADDRESS = '172.21.78.83'; // The IPv4/IPv6 address of Desktop Terminal
$NAMIKO_SERVER_PORT = '7777'; // The listening port of Desktop Terminal
$NAMIKO_MAX_LENGTH = 300; // Max Comment length accepted calculated in bytes
$NAMIKO_SEND_ONCE = false; // If you need more than one desktop clients reading data via HTTP, turn this option FASLE

/* Database	*/

// Note that Database is requried on condition that $NAMIKO_USE_TCP is false, which Desktop Terminal will check for new comments periodly.

$NAMIKO_DB_FUNC = true; // If this option is true, save comments in database even if $NAMIKO_USE_TCP is false;
$NAMIKO_DB_HOST = '127.0.0.1';
$NAMIKO_DB_USER = 'root';
$NAMIKO_DB_PASS = '';
$NAMIKO_DB_NAME = '';

/* Timing */
$NAMIKO_TIMEZONE = 'Asia/Shanghai'; // Timezone of Server

/* Security */
$NAMIKO_KEY = '233-614-789-998'; // Set the value the same as that of Desktop Terminal

/* Customization */

// The first element of following arrays stands for using default at server. Strongly recommend reserving them.

$NAMIKO_FONTNAME = array('DEF_FN' => '默认字体'); // Font List with format 'English Font Name' => 'Display name you desired', the following is the same.
$NAMIKO_FONTSIZE = array('DEF_FS' => '默认大小');
$NAMIKO_FONTCOLOR = array('DEF_FC' => '默认颜色'); // Must use C/Delphi color style: $00BBGGRR means #RRGGBB in HTML/CSS

/* Wall Options */
define('NAMIKO_WALL_SALT','salt_sarw3lknoa');
$NAMIKO_WALL_REFRESH = 20; // Refresh interval
$NAMIKO_WALL_ADMIN_REFRESH = 10;
$NAMIKO_WALL_LIMIT = 8; // Default displayed comment quantity
$NAMIKO_WALL_DISPLAY_EXTRA = 10; // Extra quantity displayed when More is clicked.
$NAMIKO_WALL_ADMINPASS = 'YA2U@PARA';

/* Don't modify contents below this line! */
if(!$NAMIKO_USE_TCP or $NAMIKO_DB_FUNC){
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
