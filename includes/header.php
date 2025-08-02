<?php

    const UNLOGGED = 0, LOGGED = 1;

    function get_db_status() {
        try {
            $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
            $status = $mysqli->connect_error ? false : true;
            $mysqli->close();
            return $status;
        } catch (Exception $e) {
            return false;
        }
    }

    function post_login() {
        $_SESSION['stato_operatore'] = LOGGED;
        $_SESSION['nome_operatore'] = $nome;
        if ($_SESSION['stato_operatore'] === LOGGED) {
            header("Location: dashboard");
        }
    }

    function headerTemplate() {
        echo '<link type="text/css" rel="stylesheet" href="/style.css">
        <link rel="icon" href="/favicon.ico" type="image/x-icon">
        <meta charset="UTF-8">';
    }

    session_start();
    if (!isset($_SESSION['stato_operatore'])) {
        $_SESSION['stato_operatore'] = UNLOGGED;
    }
    if (!isset($_SESSION['db_status'])) {
        $_SESSION['db_status'] = get_db_status();
    }