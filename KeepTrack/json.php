<?php

$input["username"] = "Mavvie6s";
$input["password"] = "pass";

date_default_timezone_set("Australia/Sydney");

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

// Grab password to confirm
$stm = $db->prepare("SELECT value FROM config WHERE key='password'");
$stm->execute();
$array = $stm->fetch();
$password = $array["value"];
if ($password != $input["password"])
	exit(0);

$stm = $db->prepare("SELECT timeSubmitted, timeDelivered, timeInserted, coordLatitude, coordLongitude, coordAccuracy, coordAltitude, batteryLevel, info FROM waypoints WHERE 1526306400 < timeSubmitted and timeSubmitted < 1526306400 + 86400 ORDER BY timeSubmitted");
$stm->execute();
echo "eqfeed_callback({\"type\":\"FeatureCollection\",\"features\":[\n";
$first = 1;
while (($array = $stm->fetch()) != FALSE) {
	if ($first == 0)
		echo ",{\n";
	else
		echo "{\n";
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
