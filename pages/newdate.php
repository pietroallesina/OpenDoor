<?php
require_once __DIR__ . '/../includes/init.php';
require_once __DIR__ . '/../classes/Cliente.php';
require_once __DIR__ . '/../classes/Prenotazione.php';

function trova_clienti(string $cognome, string $nome, string &$msg): array // restituisce array di oggetti Cliente
{
    global $db_user, $db_password;
    $clienti = [];
    try {
        $mysqli = new mysqli("mysql", $db_user, $db_password, "OpenDoor");
        $query = "CALL procedura_restituisci_dati_cliente(?, ?)";
        $params = [$cognome, $nome];

        $result = $mysqli->execute_query($query, $params);

        for ($i = 0; $i < $result->num_rows; $i++) {
            $row = $result->fetch_assoc();
            $clienti[$i] = new Cliente($row['ID'], $cognome, $nome, $row['Regione'], $row['NumeroFamigliari'], $row['CreditiDisponibili']);
        }

    } catch (Exception $e) {
        $msg = $e->getMessage();
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return [];
    }

    $mysqli->close();
    $msg = 'Utenti trovati';
    return $clienti;
}

function inserisci_prenotazione(int $IDcliente, int $IDoperatore, string $data, string|null $orario, int $crediti, string|null $descrizione, string &$msg): void
{
    global $db_user, $db_password;
    try {
        $mysqli = new mysqli("mysql", $db_user, $db_password, "OpenDoor");

        $query = "CALL procedura_inserimento_prenotazione(?, ?, ?, ?, ?, ?, ?)";

        // Eventuale passaggio dell'argomento orario
        $params = [$IDcliente, $IDoperatore, $data, $orario, $crediti, $descrizione, null];

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
        $orario = (isset($_POST["tutto-il-giorno"])) ? null : $_POST["orario"] . ":00"; // aggiungo i secondi per formato hh:mm:ss
        inserisci_prenotazione($_POST["IDcliente"], $_SESSION['operatore']->ID(), $_POST["giorno"], $orario, $_POST["crediti"], $_POST["descrizione"], $msg);
    }
    // aggiungi opzione di modifica prenotazione in futuro
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

                <!-- all-day selection, if selected disable orario -->
                <label for="tutto-il-giorno"> Tutto il giorno: </label>
                <input type="checkbox" id="tutto-il-giorno" name="tutto-il-giorno">
                <br>

                <!-- Orario, disabilita se tutto il giorno è selezionato -->
                <label for="orario"> Orario: </label>
                <select id="orario" name="orario" required></select>
                <script>
                    const select = document.getElementById('orario');
                    const tuttoIlGiorno = document.getElementById('tutto-il-giorno');

                    // Define range and interval
                    const startHour = 9;
                    const endHour = 20;
                    const interval = 15;

                    // Disable orario if tutto-il-giorno is checked
                    tuttoIlGiorno.addEventListener('change', function () {
                        select.disabled = this.checked;
                    });

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

                    const defaultTime = `${String(nextHour).padStart(2, '0')}:00`;

                    // Try to set the default selection if it exists in dropdown
                    if ([...select.options].some(opt => opt.value === defaultTime)) {
                        select.value = defaultTime;
                    }
                </script>

                <br>
                
                <label for="crediti"> Crediti </label>
                <input type="number" id="crediti" name="crediti" required>
                <script>
                    // Fetch crediti disponibili for selected client
                    const clienti = <?php
                                    $clientiArray = [];
                                    foreach ($clienti as $cliente) {
                                        $clientiArray[$cliente->ID()] = $cliente->creditiDisponibili();
                                    }
                                    echo json_encode($clientiArray);
                                    ?>;

                    const clienteSelect = document.getElementById('cliente');
                    const creditiInput = document.getElementById('crediti');

                    function updateCreditiDisponibili() {
                        const selectedID = clienteSelect.value;
                        const creditiDisponibili = clienti[selectedID] || 0;
                        creditiInput.setAttribute('max', creditiDisponibili);
                        creditiInput.setAttribute('placeholder', `Max: ${creditiDisponibili}`);
                    }

                    // Update on page load and when selection changes
                    updateCreditiDisponibili();
                    clienteSelect.addEventListener('change', updateCreditiDisponibili);
                </script>

                <br>

                <label for="descrizione"> Descrizione: </label>
                <textarea id="descrizione" name="descrizione" rows="4" cols="50"></textarea>
                <br>

                <button type="submit" name="prenota" <?php echo empty($clienti) ? 'disabled' : ''; ?>>
                    Prenota
                </button>
            </form>
            <br>

            <?php if (isset($msg) && $msg != ''): ?>
                <p> <?php echo $msg ?> </p>
                <br>
            <?php endif; ?>

        </section class="prenota">

        <a class="exit-button" onclick="window.close();"> Chiudi finestra </a>

    </main>
</body>

</html>