<?php
    require_once '../includes/header.php';

    function login_operatore($cognome, $nome, $password) {
        try {
            $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        } catch (Exception $e) {
            die("Database connection failed: " . $e->getMessage());
        }

        $query = "CALL procedura_login_operatore(?, ?, @password)";
        $params = [$cognome, $nome];

        try {
            $mysqli->execute_query($query, $params);
        } catch (Exception $e) {
            echo "<p>Errore durante il login: " . $e->getMessage() . "</p>";
            $mysqli->close();
            exit();    
        }

        // Recupero la password hashata dall'operatore
        try {
            $result = $mysqli->query("SELECT @password AS password");
            $true_password = $result->fetch_assoc()['password'];
        } catch (Exception $e) {
            echo "<p>Errore durante il recupero della password: " . $e->getMessage() . "</p>";
            $mysqli->close();
            exit();
        }

        // Verifico la password inserita
        if (!password_verify($password, $true_password)) {
            echo "<p>Credenziali non valide. Riprova.</p>";
        }
        else {
            post_login($nome); // Login successful, redirect to dashboard
        }

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
        <?php headerTemplate(); ?>
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
        <p><a href="home">Torna alla home</a></p>

    </body>
</html>