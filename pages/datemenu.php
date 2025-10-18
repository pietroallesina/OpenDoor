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

$reservationData = null;
if (isset($_GET["id"])) {
    $reservationId = intval($_GET["id"]);
    $reservationData = fetchReservationData($reservationId);
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
                <p><strong>Data:</strong> <?= htmlspecialchars($reservationData['DataPrenotata']) ?></p>
                <p><strong>Cliente:</strong> <?= htmlspecialchars($reservationData['Nome'] . ' ' . $reservationData['Cognome']) ?></p>
                <p><strong>Operatore:</strong> <?= htmlspecialchars($reservationData['Operatore']) ?></p>
                <!-- Aggiungi altri campi rilevanti della prenotazione qui -->
            </section>
        <?php else: ?>
            <p>Nessuna prenotazione trovata per l'ID specificato.</p>
        <?php endif; ?>

        <section>
            <h2>Azioni Prenotazione</h2>
            <ul>
                <li><a href="#">Modifica Prenotazione</a></li>
                <li><a href="#">Cancella Prenotazione</a></li>
            </ul>

        <a class="exit-button" onclick="window.close();"> Chiudi finestra </a>
    </main>
</body>

</html>
