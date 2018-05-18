<?php

$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

/*

	Array
	(
	    [username] => Edwin
	    [data] => xxxxx
	)

	Array
	(
	    [info] => App started
	    [batteryLevel] => -1
	    [coordinate] => Array
		(
		    [latitude] => -34.32576751709
		    [longitude] => 150.89172363281
		    [accuracy] => 0
		    [altitude] => 0
		)

	    [timeDelivered] => 1525954336
	    [timeSubmitted] => 1525954336
	)

*/

if (!isset($input["username"]))
	exit(0);

// Attach to the database, based on the username provided.
$b64username = base64_encode($input["username"]);
$dbdir = "db/" .  substr($b64username, 0, 1) .
	"/" .  substr($b64username, 1, 1) .
	"/" .  substr($b64username, 2, 1) .
	"/" .  substr($b64username, 3, 1);
if (file_exists($dbdir) == FALSE)
	mkdir($dbdir, 0755, true);
$dbname = $dbdir . "/" . $b64username;
$db = new PDO("sqlite:$dbname");

if (!isset($input["data"])) {
	// Create a new user

	$secret = random_str(32);

	$db->exec("
		CREATE TABLE IF NOT EXISTS config(
			id INTEGER PRIMARY KEY, 
		     	key TEXT, 
		     	value TEXT
		)
		");
	$db->exec("
		CREATE TABLE IF NOT EXISTS waypoints(
			id INTEGER PRIMARY KEY, 
		     	timeSubmitted INT,
		     	timeDelivered INT,
		     	timeInserted INT,
		     	coordLatitude FLOAT,
		     	coordLongitude FLOAT,
		     	coordAccuracy INT,
		     	coordAltitude INT,
		     	batteryLevel FLOAT,
		     	info TEXT
		)
		");

	$db->exec("DELETE FROM config");
	$db->exec("DELETE FROM waypoints");

	$stm = $db->prepare("INSERT INTO config(key, value) values('secret', :secret)");
	$stm->bindParam(":secret", $secret);
	$stm->execute();

	$stm = $db->prepare("INSERT INTO config(key, value) values('password', '')");
	$stm->execute();

	$d = array("secret" => $secret);
	$output = json_encode($d);
	echo "$output\n";

	exit(0);
}

// Deal with an incoming waypoint

// Grab secret to decode
$stm = $db->prepare("SELECT value FROM config WHERE key='secret'");
$stm->execute();
$array = $stm->fetch();
$secret = $array["value"];

$dataJSON64 = base64_decode($input["data"]);
$dataJSON = decode($dataJSON64, $secret);
$data = json_decode($dataJSON, TRUE);

// If a password is set, then update it
if ($data["password"] != "") {
	$stm = $db->prepare("UPDATE config SET value = :password WHERE key = 'password'");
	$stm->bindParam(":password", $data["password"]);
	$stm->execute();
}

// At the end, add the waypoint

$stm = $db->prepare("INSERT INTO waypoints(timeSubmitted, timeDelivered, timeInserted, coordLatitude, coordLongitude, coordAccuracy, coordAltitude, batteryLevel, info) values(:timeSubmitted, :timeDelivered, :timeInserted, :coordLatitude, :coordLongitude, :coordAccuracy, :coordAltitude, :batteryLevel, :info)");

$stm->bindParam(":timeSubmitted",  $data["timeSubmitted"]);
$stm->bindParam(":timeDelivered",  $data["timeDelivered"]);
$stm->bindParam(":timeInserted",   time());
$stm->bindParam(":coordLatitude",  $data["coordinate"]["latitude"]);
$stm->bindParam(":coordLongitude", $data["coordinate"]["longitude"]);
$stm->bindParam(":coordAccuracy",  $data["coordinate"]["accuracy"]);
$stm->bindParam(":coordAltitude",  $data["coordinate"]["altitude"]);
$stm->bindParam(":batteryLevel",   $data["batteryLevel"]);
$stm->bindParam(":info",           $data["info"]);

$stm->execute();

sendokay();
exit(0);

function sendokay()
{
	$out = array(
		"return" => "ok",
	);
	print json_encode($out);
}

function random_str($length, $keyspace = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
{
    $pieces = [];
    $max = mb_strlen($keyspace, '8bit') - 1;
    for ($i = 0; $i < $length; ++$i) {
        $pieces []= $keyspace[rand(0, $max)];
    }
    return implode('', $pieces);
}

function decode($sin, $key)
{
	$keylen = strlen($key);
	$sout = "";
	for ($i = 0; $i < strlen($sin); $i++) {
		$sout .= chr(ord(substr($sin, $i, 1)) ^ ord(substr($key, $i % $keylen, 1)));
	}
	return $sout;
}

?>
