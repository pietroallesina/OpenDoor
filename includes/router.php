<?php

// Extract the clean path from the URL
$url = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$url = filter_var($url, FILTER_SANITIZE_URL);
$url = trim($url, '/');
$url = explode('/', $url);

$page = $url[0]; // only the first segment is considered as the page name

// Redirect "/" to "/home"
if ($page === '') {
    header("Location: /home");
    exit;
}

$page = preg_replace('/\.(php|html)$/', '', $page); // Remove file extensions if present
$pagesDir = '../pages/'; // Directory where the pages are stored

// Check if the requested page exists
if (file_exists($pagesDir . $page . '.php')) {
    require_once $pagesDir . $page . '.php';
} else {
    // If the page does not exist, show a 404 error page
    http_response_code(404);
    require_once $pagesDir . '404.php';
}
exit();
