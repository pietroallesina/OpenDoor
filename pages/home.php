<?php
    require_once '../includes/header.php';
    require_once '../includes/functions.php';
?>

<!DOCTYPE html>
<html>
    <head>
        <title>Porta Aperta - Pagina Principale</title>
        <?php headerTemplate(); ?>
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
        <p style="text-align: center;">Sei un nuovo operatore? <a href="register">Registrati qui</a>.</p>
        <p style="text-align: center;">Se sei già registrato, <a href="login">effettua l'accesso</a>.</p>
    </body>
</html>