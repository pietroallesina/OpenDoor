<?php
require_once __DIR__ . '/../includes/init.php';
require_once __DIR__ . '/../classes/Cliente.php';
require_once __DIR__ . '/../classes/Prenotazione.php';

function trova_clienti(string $cognome, string $nome, string &$msg) { // restituisce array di oggetti Cliente
    $clienti = [];
    try {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        $query = "CALL procedura_restituisci_dati_cliente(?, ?)";
        $params = [$cognome, $nome];

        $result = $mysqli->execute_query($query, $params);

        for ($i = 0; $i < $result->num_rows; $i++) {
            $row = $result->fetch_assoc();
            $clienti[$i] = new Cliente($row['ID'], $cognome, $nome, $row['Regione'], $row['NumeroFamigliari'], $row['AccessiDisponibili'], $row['CreditiDisponibili']);
        }

    } catch (Exception $e) {
        $msg = $e->getMessage();
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return;
    }

    $mysqli->close();
    $msg = 'Clienti trovati';
    return $clienti;
}

function inserisci_prenotazione(int $IDcliente, string $data, int $crediti, int $limite, string &$msg): void
{
    try {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");

        $query = "CALL procedura_inserimento_prenotazione(?, ?, ?, ?)";
        $params = [$IDcliente, $_SESSION['operatore']->ID(), $data, $crediti];

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

$clienti = [];
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $msg = "";
    if (isset($_POST["trova-cliente"])) {
        $clienti = trova_clienti($_POST["cognome"], $_POST["nome"], $msg);
        // return;
    }
    if (isset($_POST["prenota"])) {
        $limite = 100; // dummy value
        inserisci_prenotazione($_POST["IDcliente"], $_POST["giorno"], $_POST["crediti"], $limite, $msg);
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <?php require_once '../includes/head.php'; ?>
    <link rel="stylesheet" href="/css/forms.css" type="text/css">
</head>

<body>
    <main class="newdate-wrapper">

        <section class="trova-cliente">
            <form method="post" action="">
                <label for="nome">Nome:</label>
                <input type="text" id="nome" name="nome" required>
                <br>

                <label for="cognome">Cognome:</label>
                <input type="text" id="cognome" name="cognome" required>
                <br>

                <button type="submit" name="trova-cliente"> Trova </button>
            </form>
            <br>

        </section class="trova-cliente">

        <section class="prenota">
            <form method="post" action="">
                <label for="cliente"> Utenti trovati: </label>
                <select id="cliente" name="IDcliente" required>
                    <?php
                        foreach ($clienti as $cliente) {
                            echo "<option value='{$cliente->ID()}'> {$cliente->regione()} - {$cliente->ID()} </option>";
                        }
                    ?>
                </select>
                <br>

                <label for="giorno"> Giorno: </label>
                <input type="date" id="giorno" name="giorno" required>
                <br>

                <!-- [LATER] Orario -->

                <label for="crediti"> Crediti: </label>
                <input type="number" id="crediti" name="crediti" required>
                <br>

                <button type="submit" name="prenota"
                    <?php echo empty($clienti) ? 'disabled' : ''; ?>
                > Prenota
                </button>
            </form>
            <br>

            <?php if (isset($msg) && $msg != '') : ?>
                <p> <?php echo $msg ?> </p>
                <br>
            <?php endif; ?>

        </section class="prenota">

        <a class="exit-button" onclick="window.close();"> Chiudi finestra </a>

    </main>
</body>

</html>