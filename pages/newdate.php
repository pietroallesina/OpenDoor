<?php
require_once __DIR__ . '/../includes/init.php';

function prenotazione(string $cognome, string $nome, string $regione, int $famigliari, string &$msg): void
{
    try {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");

        $query = "CALL procedura_inserimento_prenotazione(?, ?, ?, ?)";
        $params = [$cognome, $nome, $regione, $famigliari];
        $mysqli->execute_query($query, $params);
    } catch (Exception $e) {
        $msg = $e->getMessage();
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return;
    }

    $mysqli->close();
    $msg = "Prenotazione inserita correttamente!";
    return;
}

/*********************************************************/

if (!isset($_SESSION['operatore'])) {
    header("Location: /home");
    exit();
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $msg = '';
    $cognome = $_POST['cognome'];
    $nome = $_POST['nome'];
    $regione = $_POST['regione'];
    $famigliari = $_POST['famigliari'];
    prenotazione($cognome, $nome, $regione, $famigliari, $msg);
}
?>

<!DOCTYPE html>
<html>
<head>
    <?php require_once '../includes/head.php'; ?>
    <link rel="stylesheet" href="/css/forms.css" type="text/css">
</head>

<body>
    <main>
        <h1>Nuovo utente</h1>

        <section class="access-form"> <!-- not access but still -->
            <form method="post" action="" class="access-data">
                <label for="nome">Nome:</label>
                <input type="text" id="nome" name="nome" required>
                <br>

                <label for="cognome">Cognome:</label>
                <input type="text" id="cognome" name="cognome" required>
                <br>

                <label for="regione">Regione:</label>
                <select id="regione" name="regione" required>
                    <option value="ITA">Italia</option>
                    <option value="PAK">Pakistan</option>
                    <option value="AN">Altro</option>
                </select>
                <br>

                <label for="famigliari">Famigliari (almeno 1):</label>
                <input type="number" id="famigliari" name="famigliari" min="1" required>
                <br>

                <input type="submit" value="Inserisci">
            </form>
            <br>

            <?php if (isset($msg) && $msg != '') : ?>
                <p> <?php echo $msg ?> </p>
                <br>
            <?php endif; ?>

            <br>
            <a class="exit-button" onclick="window.close();"> Chiudi finestra </a>

        </section>

    </main>
</body>

</html>