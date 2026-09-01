<?php
echo "<h1>Starfleet Engineering - PHP " . PHP_VERSION . "</h1>";
$db = new PDO('mysql:host=127.0.0.1;dbname=starfleet', 'web', '********');
echo "<p>MariaDB : " . $db->query('SELECT VERSION()')->fetchColumn() . "</p>";
phpinfo();
