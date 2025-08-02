<?php
    require_once 'functions.php';
?>

<!DOCTYPE html>
<html>
    <head>
        <title>Benvenuto!</title>
        <link rel="stylesheet" href="style.css">
        <link rel="icon" href="../includes/favicon.ico" type="image/x-icon">
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="Pagina principale del sito di gestione di Porta Aperta">
        <meta name="keywords" content="Porta Aperta, gestione, operatore, accesso, registrazione">
    </head>

    <body>
        <h1>Pagina principale</h1>
        <p style="text-align: center;">Benvenuto nella pagina principale del sito di gestione di Porta Aperta!</p>
        <?php
            if ($_SESSION['db_status']) {
                echo "<p style='color: green;'>La connessione al database è attiva.</p>";
            } else {
                echo "<p style='color: red;'>La connessione al database è fallita.</p>";
            }
        ?>
        <p style="text-align: center;">Sei un nuovo operatore? <a href="register.php">Registrati qui</a>.</p>
        <p style="text-align: center;">Se sei già registrato, <a href="login.php">effettua l'accesso</a>.</p>
    </body>
</html>