<?php
require_once '../includes/init.php';
require_once '../vendor/autoload.php';

if (!isset($_SESSION['operatore'])) {
    header("Location: /home");
    exit();
}

$client = new Google_Client();
$client->setApplicationName('OpenDoor Calendar');
$client->setScopes(Google_Service_Calendar::CALENDAR);
$client->setAuthConfig('../private/calendar-auth.json');
$client->setAccessType('offline');

$service = new Google_Service_Calendar($client);
$calendarId = 'portaaperta.calendario@gmail.com';

$events = $service->events->listEvents($calendarId, [
    'maxResults' => 10,
    'orderBy' => 'startTime',
    'singleEvents' => true,
]);

?>

<!DOCTYPE html>
<html>
<head>
    <?php require_once '../includes/head.php'; ?>
    <link rel="stylesheet" href="/css/dashboard.css" type="text/css">
</head>

<body>
    <!-- <header> -->
        <?php require_once '../includes/header.php'; ?>
    <!-- </header> -->

    <main>
        <h1>Menu Operatore</h1>

        <iframe class="calendar"
            src="https://calendar.google.com/calendar/embed?src=portaaperta.calendario%40gmail.com&ctz=Europe%2FRome"
        ></iframe>

        <?php
        
        foreach ($events->getItems() as $event) {
            echo "<p>" . $event->getSummary() . " - " . $event->getStart()->getDateTime() . "</p>";
        }

        ?>

    </main>

</body>
</html>