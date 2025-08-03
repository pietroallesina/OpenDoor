<?php
function registrazione_operatore($cognome, $nome, $password): bool
{
    try {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        $query = "CALL procedura_inserimento_operatore(?, ?, ?, ?)";
        $params = [$cognome, $nome, password_hash($password, PASSWORD_DEFAULT), 0]; // 1 for Admin, 0 for User
        $mysqli->execute_query($query, $params);
    } catch (Exception $e) {
        echo "<p>Errore durante la registrazione: " . $e->getMessage() . "</p>";
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return false;
    }

    $mysqli->close();
    return true;
}

/*********************************************************/

session_start();

if (isset($_SESSION['operatore'])) {
    header("Location: dashboard");
    exit(); // always exit after a redirect
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $cognome = $_POST['cognome'];
    $nome = $_POST['nome'];
    $password = $_POST['password'];
    if (registrazione_operatore($cognome, $nome, $password)) {
        $operatore = new Operatore($cognome, $nome, false);
        $_SESSION['operatore'] = $operatore;
        header("Location: dashboard");
        exit(); // always exit after a redirect
    }
}
?>

<!DOCTYPE html>
<html>

<head>
    <title>Registrazione</title>
    <?php require_once '../includes/header.php'; ?>
</head>

<body>
    <?php require_once '../includes/navbar.php'; ?>

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
    <p><a href="home">Torna alla home</a></p>

</body>

</html>