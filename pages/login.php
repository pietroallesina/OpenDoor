<?php
require_once __DIR__ . '/../includes/init.php';

function login_operatore(string $cognome, string $nome, string $password, string &$msg): void
{
    try {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        $query = "CALL procedura_login_operatore(?, ?, @true_password, @isadmin)";
        $params = [$cognome, $nome];
        $mysqli->execute_query($query, $params);

        $result = $mysqli->query("SELECT @true_password AS password");
        $true_password = $result->fetch_assoc()['password'];

        $result = $mysqli->query('SELECT @isadmin AS isadmin');
        $is_admin = $result->fetch_assoc()['isadmin'];

    } catch (Exception $e) {
        $msg = "Errore durante il login: " . $e->getMessage();
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return;
    }

    $mysqli->close();

    // Verifico la password inserita
    if (!password_verify($password, $true_password)) {
        $msg = "Credenziali non valide. Riprova.";
        return;
    }

    $operatore = new Operatore($cognome, $nome, $is_admin);
    $_SESSION['operatore'] = $operatore;
    header("Location: /dashboard");
    exit(); // always exit after a redirect
}

/*********************************************************/

if (isset($_SESSION['operatore'])) {
    header("Location: /dashboard");
    exit(); // always exit after a redirect
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $cognome = $_POST['cognome'];
    $nome = $_POST['nome'];
    $password = $_POST['password'];
    $msg = '';
    login_operatore($cognome, $nome, $password, $msg);
}
?>

<!DOCTYPE html>
<html>

<head>
    <?php require_once __DIR__ . '/../includes/head.php'; ?>
</head>

<body>
    <!-- <header> -->
        <?php require_once __DIR__ . '/../includes/header.php'; ?>
    <!-- </header> -->

    <main>
        <h1>Accesso</h1>

        <section class="access-form">
            <form method="post" action="" class="access-data">
                <label for="nome">Nome:</label>
                <input type="text" id="nome" name="nome" required>
                <br>

                <label for="cognome">Cognome:</label>
                <input type="text" id="cognome" name="cognome" required>
                <br>

                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
                <br>

                <input type="submit" value="Accedi">
            </form>

            <?php if (isset($msg) && $msg != '') : ?>
                <p class="access-msg"> <?php echo $msg ?> </p>
            <?php endif; ?>

            <p>
                Sei un nuovo operatore?
                <a href="/register">Registrati</a>
            </p>
        </section>

    </main>

</body>
</html>