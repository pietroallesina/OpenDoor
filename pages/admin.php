<?php
session_start();

if (!isset($_SESSION['operatore']) || !$_SESSION['operatore']->isAdmin()) {
    header("Location: home");
    exit();
}
?>

<!DOCTYPE html>
<html>
    <head>
        <title>Admin</title>
        <?php require_once '../includes/header.php'; ?>
    </head>

    <body>
        <?php require_once '../includes/navbar.php'; ?>

        <h1>Area Riservata</h1>
        <p>Benvenuto, <?php echo $_SESSION['operatore']->nome(); ?>!</p>
        <p><a href="logout">Logout</a></p>
    </body>
</html>