<?php
    require_once 'functions.php';

    function accesso_operatore($cognome, $nome, $password) {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        if ($mysqli->connect_error) {
            die("Connection failed: " . $mysqli->connect_error);
        }

        // Prepare and bind
        $stmt = $mysqli->prepare("SELECT password FROM Operatori WHERE Cognome = ? AND Nome = ?");
        if (!$stmt) {
            die("Prepare failed: " . $mysqli->error);
        }
        if (!$stmt->bind_param("ss", $cognome, $nome)) {
            die("Bind failed: " . $stmt->error);
        }

        // Execute the statement
        if ($stmt->execute()) {
            $stmt->store_result();
            if ($stmt->num_rows > 0) {
                $stmt->bind_result($hashed_password);
                $stmt->fetch();
                if (password_verify($password, $hashed_password)) {
                    post_login($nome);
                } else {
                    echo "Credenziali non valide.";
                }
            } else {
                echo "Credenziali non valide.";
            }
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
        accesso_operatore($cognome, $nome, $password);
    }
?>

<!DOCTYPE html>
<html>
    <head>
        <title>Login</title>
        <link rel="stylesheet" href="index.css">
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