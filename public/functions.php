<?php

    const UNLOGGED = 0, LOGGED = 1;

    function get_db_status() {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        if ($mysqli->connect_error) {
            $status = false;
        } else {
            $status = true;
        }
        $mysqli->close();
        return $status;
    }

    function post_login($nome) {
        $_SESSION['stato_operatore'] = LOGGED;
        $_SESSION['nome_operatore'] = $nome;
        if ($_SESSION['stato_operatore'] === LOGGED) {
            header("Location: admin.php");
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