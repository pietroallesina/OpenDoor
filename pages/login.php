<?php
function login_operatore(string $cognome, string $nome, string $password): bool
{
    try {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        $query = "CALL procedura_login_operatore(?, ?, @password)";
        $params = [$cognome, $nome];
        $mysqli->execute_query($query, $params);
        $result = $mysqli->query("SELECT @password AS password");
        $true_password = $result->fetch_assoc()['password'];
    } catch (Exception $e) {
        echo "<p>Errore durante il login: " . $e->getMessage() . "</p>";
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return false;
    }

    $mysqli->close();

    // Verifico la password inserita
    if (!password_verify($password, $true_password)) {
        echo "<p>Credenziali non valide. Riprova.</p>";
        return false;
    }

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
    if (login_operatore($cognome, $nome, $password)) {
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
    <title>Login</title>
    <?php require_once '../includes/header.php'; ?>
</head>

<body>
    <?php require_once '../includes/navbar.php'; ?>

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