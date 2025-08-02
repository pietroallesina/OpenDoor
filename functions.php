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

    function post_login($nome) {
        $_SESSION['stato_operatore'] = LOGGED;
        $_SESSION['nome_operatore'] = $nome;
        if ($_SESSION['stato_operatore'] === LOGGED) {
            header("Location: dashboard.php");
        }
    }

    session_start();
    if (!isset($_SESSION['stato_operatore'])) {
        $_SESSION['stato_operatore'] = UNLOGGED;
    }
    if (!isset($_SESSION['db_status'])) {
        $_SESSION['db_status'] = get_db_status();
    }
?>