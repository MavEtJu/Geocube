<?php

$user = $_COOKIE["geocube_owntracks_user"];
$session = $_COOKIE["geocube_owntracks_session"];

$dateSelected = $_REQUEST["dateSelected"];

date_default_timezone_set("Australia/Sydney");

// Attach to the database, based on the username provided.
$b64username = base64_encode($user);
$dbdir = "db/" .  substr($b64username, 0, 1) .
	"/" .  substr($b64username, 1, 1) .
	"/" .  substr($b64username, 2, 1) .
	"/" .  substr($b64username, 3, 1);
if (file_exists($dbdir) == FALSE)
	mkdir($dbdir, 0755, true);
$dbname = $dbdir . "/" . $b64username;
$db = new PDO("sqlite:$dbname");

// Grab session to confirm
$stm = $db->prepare("SELECT value FROM config WHERE key='session'");
$stm->execute();
$array = $stm->fetch();
$session2 = $array["value"];
if ($session != $session2)
	exit(0);

echo "eqfeed_callback({\"type\":\"FeatureCollection\",";

// Find some metadata
$stm = $db->prepare("SELECT DISTINCT timeSubmitted / 86400 AS c, COUNT(*) FROM waypoints GROUP BY c ORDER BY c DESC"); 
$stm->execute();
$dates = array();
$first = 1;
echo "\"dates\":[\n";
while (($array = $stm->fetch()) != FALSE) {
	if ($first == 0)
		echo ",\n";
	echo "{\"epoch\": ", 86400 * $array["c"], ", \"text\": \"" . strftime("%Y-%m-%d", 86400 * $array["c"]), "\"}";
	$first = 0;
}
echo "],\n";

// Grab the data
$stm = $db->prepare("SELECT _id, timeSubmitted, timeDelivered, timeInserted, coordLatitude, coordLongitude, coordAccuracy, coordAltitude, batteryLevel, info FROM waypoints WHERE :timeStart < timeSubmitted and timeSubmitted < :timeEnd ORDER BY timeSubmitted");
$ts1 = $dateSelected;
$stm->bindParam(":timeStart", $ts1); 
$ts2 = $ts1 + 86400;
$stm->bindParam(":timeEnd", $ts2);
$stm->execute();
echo "\"features\":[\n";
$first = 1;
while (($array = $stm->fetch()) != FALSE) {
	if ($first == 0)
		echo ",{\n";
	else
		echo "{\n";
	echo "\"id\": " . $array[_id] . ",\n";
	echo "\"lat\": " . $array[coordLatitude] . ",\n";
	echo "\"lon\": " . $array[coordLongitude] . ",\n";
	echo "\"latlon\": \"" . sprintf("%0.5f %0.5f", $array[coordLatitude], $array[coordLongitude]) . "\",\n";
	echo "\"text\": \"$array[info]\",\n";
	echo "\"timeSubmitted\": \"" . strftime("%Y-%m-%d %H:%M:%S", $array[timeSubmitted]) . "\"\n";
	echo "}\n";
	$first = 0;
}
echo "]});\n";
exit(0);

?>
