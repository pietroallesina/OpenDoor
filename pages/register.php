<?php
require_once '../includes/init.php';

function registrazione_operatore(string $cognome, string $nome, int $is_admin, string $password, string &$msg): void
{
    try {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        $query = "CALL procedura_inserimento_operatore(?, ?, ?, ?)";
        $params = [$cognome, $nome, password_hash($password, PASSWORD_DEFAULT), $is_admin];
        $mysqli->execute_query($query, $params);
    } catch (Exception $e) {
        $msg = "Errore durante la registrazione: " . $e->getMessage();
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return;
    }

    $mysqli->close();

    require_once '../classes/Operatore.php';
    $operatore = new Operatore($cognome, $nome, $is_admin);
    $_SESSION['operatore'] = $operatore;
    header("Location: dashboard");
    exit(); // always exit after a redirect
}

/*********************************************************/

if (isset($_SESSION['operatore'])) {
    header("Location: dashboard");
    exit(); // always exit after a redirect
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $msg = '';
    if ($_POST["password"] != $_POST["password-check"]) {
        $msg = "Le password non coincidono";
    } else {
        $cognome = $_POST['cognome'];
        $nome = $_POST['nome'];
        $password = $_POST['password'];
        $is_admin = $_POST['isadmin'] ?? 0;
        registrazione_operatore($cognome, $nome, $is_admin, $password, $msg);
    }
}
?>

<!DOCTYPE html>
<html>

<head>
    <?php require_once '../includes/head.php'; ?>
</head>

<body>

    <header>
        <?php require_once '../includes/header.php'; ?>
    </header>

    <main>
        <h1>Registrazione Operatore</h1>
        <form method="post" action="">
            <label for="cognome">Cognome:</label>
            <input type="text" id="cognome" name="cognome" required>
            <br>
            
            <label for="nome">Nome:</label>
            <input type="text" id="nome" name="nome" required>
            <br>
            
            <label for="password">Inserisci password:</label>
            <input type="password" id="password" name="password" required>
            <br>
            
            <label for="password-confirm">Conferma password:</label>
            <input type="password" id="password-confirm" name="password-check" required>
            <br>

            <label for="isadmin"> Amministratore </label>
            <input type="checkbox" id="isadmin" name="isadmin" value=1>
            <br>

            <input type="submit" value="Registrati">
        </form>

        <?php if (isset($msg) && $msg != '') : ?>
            <p> <?php echo $msg ?> </p>
        <?php endif; ?>

        <p>
            Sei già registrato?
            <a href="login">Accedi</a>
        </p>
    </main>

</body>
</html>