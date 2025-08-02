<?php
    require_once 'functions.php';

    function registra_operatore($cognome, $nome, $password) {
        try {
            $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        } catch (Exception $e) {
            die("Database connection failed: " . $e->getMessage());
        }

        $query = "CALL procedura_inserimento_operatore(?, ?, ?, ?)";
        $params = [$cognome, $nome, password_hash($password, PASSWORD_DEFAULT), 0]; // 1 for Admin, 0 for User

        try {
            $mysqli->execute_query($query, $params);
            post_login($nome); // Automatically log in after registration
        } catch (Exception $e) {
            echo "<p>Errore durante la registrazione: " . $e->getMessage() . "</p>";
        }

        $mysqli->close();
        exit();
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $cognome = $_POST['cognome'];
        $nome = $_POST['nome'];
        $password = $_POST['password'];
        registra_operatore($cognome, $nome, $password);
    }
?>

<!DOCTYPE html>
<html>
    <head>
        <title>Registrazione</title>
        <link rel="stylesheet" href="style.css">
    </head>

    <body>
        <h1>Registrazione Nuovo Utente</h1>
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
            <input type="submit" value="Registrati">
        </form>

        <br>
        <p><a href="index.php">Torna alla home</a></p>

    </body>
</html>