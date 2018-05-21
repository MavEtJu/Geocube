<?php

if (!isset($_REQUEST["pass"]))
	$_REQUEST["pass"] = "";
if (!isset($_REQUEST["user"]))
	$_REQUEST["user"] = "";

$user = $_REQUEST["user"];
$pass = $_REQUEST["pass"];

if ($user == "")
	$user = $_COOKIE["geocube_owntracks_user"];

if ($user == "" || $pass == "")
	form();

// Attach to the database, based on the username provided.
$b64username = base64_encode($user);
$dbdir = "db/" .  substr($b64username, 0, 1) .
        "/" .  substr($b64username, 1, 1) .
        "/" .  substr($b64username, 2, 1) .
        "/" .  substr($b64username, 3, 1);
$dbname = $dbdir . "/" . $b64username;
if (file_exists($dbname) == FALSE)
	form();

$db = new PDO("sqlite:$dbname");

// Grab password to decode
$stm = $db->prepare("SELECT value FROM config WHERE key='password'");
$stm->execute();
$array = $stm->fetch();
$password = $array["value"];

if (password_verify($pass, $password) != $password)
	form();

$session = random_str(32);
setcookie("geocube_owntracks_user", $user, 0);
setcookie("geocube_owntracks_session", $session, 0);
header("Location: " . dirname($_SERVER["PHP_SELF"]) . "/device.php");

$stm = $db->prepare("UPDATE config SET value = :session WHERE key = 'session'");
$stm->bindParam(":session", $session);
$stm->execute();

function form()
{
	setcookie("geocube_owntracks_user", "", time()-3600);
	setcookie("geocube_owntracks_session", "", time()-3600);

	global $user;
?>
	<h1>Geocube Keep Track</h1>

	<p>
	In Geocube -> Settings, set the OwnTracks Password. Once set you
	can login here with the OwnTracks Username as defined there.
	</p>

	<form method="post" action="<?= $_SERVER["PHP_SELF"] ?>">
	Username: <input type="text" name="user" value="<?= $user ?>">
	<br />
	Password: <input type="password" name="pass" value="">
	<br />
	<input type="submit" name="login" value="Login">
	</form>
<?php
    exit(0);
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

