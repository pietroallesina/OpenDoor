<?php
    require_once 'functions.php';

    function registra_operatore($cognome, $nome, $password) {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        if ($mysqli->connect_error) {
            die("Connection failed: " . $mysqli->connect_error);
        }

        // Prepare and bind
        $stmt = $mysqli->prepare("CALL procedura_inserimento_operatore(?, ?, ?)");
        if (!$stmt) {
            die("Prepare failed: " . $mysqli->error);
        }
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        if (!$stmt->bind_param("sss", $cognome, $nome, $hashed_password)) {
            die("Bind failed: " . $stmt->error);
        }

        // Execute the statement
        if ($stmt->execute()) {
            post_login($nome);
        } else {
            echo "Errore: " . $stmt->error;
        }

        // Close the connections
        $stmt->close();
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
        <link rel="stylesheet" href="index.css">
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