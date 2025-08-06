<?php
require_once '../includes/init.php';

if (!isset($_SESSION['operatore'])) {
    header("Location: /home");
    exit();
}
?>

<!DOCTYPE html>
<html>
<head>
    <?php require_once '../includes/head.php'; ?>
</head>

<body>
    <!-- <header> -->
        <?php require_once '../includes/header.php'; ?>
    <!-- </header> -->

    <main>
        <h1>Menu Operatore</h1>

        <p>Benvenuto, <?php echo $_SESSION['operatore']->nome();?>!</p>
    </main>

</body>
</html>