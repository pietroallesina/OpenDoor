<?php
require_once '../includes/header.php';

// Invalidate the session and redirect to home
$_SESSION = array();
session_destroy();
header("Location: home");
exit();
