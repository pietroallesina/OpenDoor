<?php
require_once __DIR__ . '/../classes/Operatore.php';

// Database credentials
$db_user = 'access';
$db_password = json_decode(file_get_contents(__DIR__ . '/../config/config.json'), true)['db_password'];

session_start();
