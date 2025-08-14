<?php
/**
 * Receives GET request from /public/js/calendar.js
 */

require_once __DIR__ . "/../../includes/fetchevents.php";

header('Content-Type: application/json');

if ($_SERVER["REQUEST_METHOD"] != "GET") {
    return;
}

if (isset($_GET["start"]) && isset($_GET["end"])) {
    $start = $_GET["start"];
    $end = $_GET["end"];
    echo fetchEventsByDate($start, $end);
    exit;
}