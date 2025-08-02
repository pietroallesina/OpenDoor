<?php
    require_once '../includes/functions.php';
    require_once '../includes/header.php';

    if ($_SESSION['stato_operatore'] !== LOGGED) {
        header("Location: home");
        exit();
    }
?>

<!DOCTYPE html>
<html>
    <head>
        <title>Admin</title>
        <?php headerTemplate(); ?>
    </head>

    <body>
        <h1>Area Riservata</h1>
        <!-- <p>Benvenuto, <?php echo $_SESSION['nome_operatore'];?>!</p> -->
        <p><a href="logout">Logout</a></p>
    </body>
</html>