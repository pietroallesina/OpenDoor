<?php
    $url = $_SERVER['REQUEST_URI'];
    $url = rtrim($url, '/');
    $url = filter_var($url, FILTER_SANITIZE_URL);
    $url = explode('/', $url);

    $page = isset($url[1]) ? $url[1] : 'index'; // Default to index page
    $page = preg_replace('/\.(php|html|htm)$/', '', $page);
    $page = preg_replace('/[^a-zA-Z0-9_-]/', '', $page);
    $file = '../public/' . $page . '.php';

    if (file_exists($file)) {
        http_response_code(200); // OK
        require_once $file;
    } else {
        http_response_code(404);
        require_once '../public/notfound.php';
        exit();
    }