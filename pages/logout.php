<?php
    require_once '../includes/header.php';

    // Logout script
    session_start();
    // Unset all of the session variables
    $_SESSION = array();
    // Destroy the session
    session_destroy();
?>
<!DOCTYPE html>
<html>
    <head>
        <title>Logout</title>
        <?php headerTemplate() ?>
    </head>
    <body>
        <h1>Logout</h1>
        <p>Sei stato disconnesso con successo.</p>
        <p><a href="home">Torna alla pagina principale</a></p>
    </body>
</html>
