<?php
require_once __DIR__ . '/../includes/init.php';

if (!isset($_SESSION['operatore']) || !$_SESSION['operatore']->isAdmin()) {
    header("Location: /home");
    exit();
}

function fetchParams(string &$msg)
{
    global $db_user, $db_password;
    $params = null;
    try {
        $mysqli = new mysqli("mysql", $db_user, $db_password, "OpenDoor");
        $query = "CALL procedura_restituisci_impostazioni()";
        $result = $mysqli->query($query);
        if ($result) {
            $row = $result->fetch_assoc();
            $params = json_decode($row['Parametri'], true);
            $result->free();
        }
    } catch (Exception $e) {
        $msg = $e->getMessage();
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return null;
    }
    
    $mysqli->close();
    return $params;
}

function modifica_parametri(string $new_params, string &$msg): void
{
    global $db_user, $db_password;
    try {
        $mysqli = new mysqli("mysql", $db_user, $db_password, "OpenDoor");
        $query = "CALL procedura_aggiornamento_impostazioni(?)";
        $params = [$new_params];
        $mysqli->execute_query($query, $params);

    } catch (Exception $e) {
        $msg = $e->getMessage();
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return;
    }

    $mysqli->close();
}

function modifica_dbpass(string $new_password): void
{
    global $db_password;
    try {
        $mysqli = new mysqli("mysql", 'access', $db_password, "OpenDoor");
        $query = "CALL procedura_aggiornamento_credenziali(?)";
        $params = [$new_password];
        $mysqli->execute_query($query, $params);

    } catch (Exception $e) {
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return;
    }

    $mysqli->close();

    $config = json_decode(file_get_contents(__DIR__ . '/../config/config.json'), true);
    $config['db_password'] = $new_password;
    file_put_contents(__DIR__ . '/../config/config.json', json_encode($config, JSON_PRETTY_PRINT));
    $db_password = $new_password;

    return;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $msg = "";
    if (isset($_POST['update_db_password'])) {
        $new_db_password = $_POST['new_db_password'];
        modifica_dbpass($new_db_password);
    }
    if (isset($_POST['update_params'])) {
        unset($_POST['update_params']);
        $new_params = json_encode($_POST);
        modifica_parametri($new_params, $msg);
    }
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
        <h1>Area Riservata</h1>

        <section>
            <h2>Modifica parametri di sistema</h2>
            <form method="POST" action="">
                <?php
                $msg = "";
                $params = fetchParams($msg);
                if ($params !== null) {
                    foreach ($params as $key => $value) {
                        echo '<label for="' . htmlspecialchars($key) . '">' . htmlspecialchars($key) . ':</label>';
                        if (is_array($value) || is_object($value)) {
                            $value = json_encode($value);
                        }
                        echo '<input type="text" id="' . htmlspecialchars($key) . '" name="' . htmlspecialchars($key) . '" value="' . htmlspecialchars($value) . '"><br>';
                    }
                } else {
                    echo '<p>Errore nel recupero dei parametri di sistema: ' . htmlspecialchars($msg) . '</p>';
                }
                ?>
                <button type="submit" name="update_params" onClick="return confirm('Sei sicuro di voler aggiornare i parametri?')">Aggiorna Parametri</button>
            </form>
        </section>

        <section>
            <h2>Modifica credenziali database</h2>
            <form method="POST" action="">
                <label for="new_db_password">Nuova password database:</label>
                <input type="password" id="new_db_password" name="new_db_password" required>
                <button type="submit" name="update_db_password">Aggiorna Password</button>
            </form>
        </section>
    </main>
</body>
</html>