<?php
require_once __DIR__ . '/../includes/init.php';

function fetchReservationData($id)
{
    global $db_user, $db_password;
    try {
        $mysqli = new mysqli("mysql", $db_user, $db_password, "OpenDoor");

        $query = "CALL procedura_restituisci_dati_prenotazione(?)";
        $result = $mysqli->execute_query($query, [$id]);

        $data = $result->fetch_assoc(); // returns single row
        $mysqli->close();

        return $data;
    } catch (mysqli_sql_exception $e) {
        error_log("Error fetching reservation data: " . $e->getMessage());
        return null;
    }
}

function inserisci_accesso(int $IDprenotazione, string|null $orarioAccesso, int|null $creditiUtilizzati, string|null $note, string &$msg)
{
    global $db_user, $db_password;
    try {
        $mysqli = new mysqli("mysql", $db_user, $db_password, "OpenDoor");

        $query = "CALL procedura_inserimento_accesso(?, ?, ?, ?)";
        $orarioAccesso = ($orarioAccesso == 0) ? null : $orarioAccesso;
        $creditiUtilizzati = ($creditiUtilizzati == 0) ? null : $creditiUtilizzati;
        $params = [$IDprenotazione, $orarioAccesso, $creditiUtilizzati, $note];
        $mysqli->execute_query($query, $params);

    } catch (Exception $e) {
        $msg = $e->getMessage();
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return;
    }

    $msg = "Accesso registrato con successo.";
    $mysqli->close();
    return;
}

function modifica_prenotazione(int $IDprenotazione, string|null $data, string|null $orario, int|null $crediti, string|null $descrizione, string &$msg)
{
    global $db_user, $db_password;
    try {
        $mysqli = new mysqli("mysql", $db_user, $db_password, "OpenDoor");

        $query = "CALL procedura_modifica_prenotazione(?, ?, ?, ?, ?)";

        // Eventuale passaggio dell'argomento orario
        $params = [$IDprenotazione, $data, $orario, $crediti, $descrizione];

        $mysqli->execute_query($query, $params);

    } catch (Exception $e) {
        $msg = $e->getMessage();
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return;
    }

    $mysqli->close();
    $msg = "Prenotazione modificata correttamente!";
    return;
}

$reservationData = null;
if (isset($_GET["id"])) {
    $reservationId = intval($_GET["id"]);
    $reservationData = fetchReservationData($reservationId);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $msg = '';
    $orario = $_POST['orario'] ?? null;
    $crediti = ($_POST['crediti'] ?? null) !== null ? (int)$_POST['crediti'] : null;
    $note = $_POST['note'] ?? null;
    inserisci_accesso($reservationId, $orario, $crediti, $note, $msg);
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
        <h1>Menu prenotazione</h1>

        <?php if ($reservationData): ?>
            <section>
                <h2>Dettagli Prenotazione</h2>
                <p><strong>ID Prenotazione:</strong> <?= htmlspecialchars($reservationData['ID']) ?></p>
                <p><strong>Data e ora:</strong> <?= htmlspecialchars($reservationData['Data'] . ' ' . $reservationData['Orario']) ?></p>
                <p><strong>Cliente:</strong> <?= htmlspecialchars($reservationData['Nome'] . ' ' . $reservationData['Cognome']) ?></p>
                <p><strong>Operatore:</strong> <?= htmlspecialchars($reservationData['Operatore']) ?></p>
                <p><strong>Descrizione:</strong> <?= htmlspecialchars($reservationData['Descrizione']) ?></p>
            </section>

        <?php else: ?>
            <p>Nessuna prenotazione trovata per l'ID specificato.</p>
        <?php endif; ?>

        <section>
            <h2>Azioni Prenotazione</h2>
            <form method="POST" action="">

                <label for="orario"> Orario: </label>
                <select id="orario" name="orario"></select>
                <script>
                    const select = document.getElementById('orario');

                    // Define range and interval
                    const startHour = 9;
                    const endHour = 20;
                    const interval = 15;

                    for (let hour = startHour; hour <= endHour; hour++) {
                        for (let minutes = 0; minutes < 60; minutes += interval) {
                            // Stop if beyond endHour and minutes > 0
                            if (hour === endHour && minutes > 0) break;

                            const h = String(hour).padStart(2, '0');
                            const m = String(minutes).padStart(2, '0');
                            const time = `${h}:${m}`;

                            const option = document.createElement('option');
                            option.value = time;
                            option.textContent = time;
                            select.appendChild(option);
                        }
                    }

                    const now = new Date();
                    let nextHour = now.getHours() + 1;

                    // Clamp to endHour range
                    if (nextHour < startHour) nextHour = startHour;
                    if (nextHour > endHour) nextHour = endHour;

                    // make default time be null
                    select.value = null;

                </script>
                <br>

                <label for="crediti"> Crediti: </label>
                <input type="number" id="crediti" name="crediti">
                <br>

                <label for="note"> Note: </label>
                <textarea id="note" name="note" rows="4" cols="50"></textarea>
                <br>

                <button type="submit">Registra Accesso</button>
            </form>
            <br>

        </section>

        <?php if (isset($msg) && $msg != ''): ?>
            <p> <?php echo $msg ?> </p>
            <br>
        <?php endif; ?>

        <a class="exit-button" onclick="window.close();"> Chiudi finestra </a>
    </main>
</body>

</html>
