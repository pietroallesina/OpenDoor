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

        <iframe src="https://calendar.google.com/calendar/embed?src=pietro.allesina%40gmail.com&ctz=Europe%2FRome"
            style="border: 0; width: 100%; height: 60vh;" frameborder="0" scrolling="no">
        </iframe>

    </main>

</body>
</html>