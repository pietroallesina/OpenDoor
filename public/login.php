<?php
    require_once 'functions.php';

    function login_operatore($cognome, $nome, $password) {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        if ($mysqli->connect_error) {
            die("Connection failed: " . $mysqli->connect_error);
        }

        $query = "CALL procedura_login_operatore(?, ?, ?)";
        $params = [$cognome, $nome, $password];
        $result = $mysqli->execute_query($query, $params);
        if ($result === false) {
            echo "<p>Errore durante il login: " . $mysqli->error . "</p>";
        } else {
            post_login($nome);
        }

        // $result->free();
        $mysqli->close();
        exit();
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $cognome = $_POST['cognome'];
        $nome = $_POST['nome'];
        $password = $_POST['password'];
        login_operatore($cognome, $nome, $password);
    }
?>

<!DOCTYPE html>
<html>
    <head>
        <title>Login</title>
        <link rel="stylesheet" href="style.css">
    </head>
    
    <body>
        <h1>Login</h1>
        <form method="post" action="">
            <label for="cognome">Cognome:</label>
            <input type="text" id="cognome" name="cognome" required>
            <br>
            <label for="nome">Nome:</label>
            <input type="text" id="nome" name="nome" required>
            <br>
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>
            <br>
            <input type="submit" value="Accedi">
        </form>

        <br>
        <p><a href="index.php">Torna alla home</a></p>

    </body>
</html>