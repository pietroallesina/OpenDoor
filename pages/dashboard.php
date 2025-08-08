<?php
require_once __DIR__ . '/../includes/init.php';

if (!isset($_SESSION['operatore'])) {
    header("Location: /home");
    exit();
}
?>

<!DOCTYPE html>
<html>
<head>
    <?php require_once '../includes/head.php'; ?>
    <link rel="stylesheet" href="/css/dashboard.css" type="text/css">

    <!-- FullCalendar JS -->
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
    <script src="/js/calendar.js"></script>

</head>

<body>
    <!-- <header> -->
        <?php require_once '../includes/header.php'; ?>
    <!-- </header> -->

    <main>
        <h1>Pannello di controllo</h1>

        <div id="calendar"></div>

    </main>

</body>
</html>