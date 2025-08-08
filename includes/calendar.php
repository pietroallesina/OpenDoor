<?php
require_once __DIR__ . '/../vendor/autoload.php';

$authPath = __DIR__ . '/../private/calendar-auth.json';

$client = new Google_Client();
$client->setApplicationName('OpenDoor Calendar');
$client->setScopes(Google_Service_Calendar::CALENDAR);
$client->setAuthConfig($authPath);
$client->setAccessType('offline');

/********************/
/* Useful variables */
/********************/
$service = new Google_Service_Calendar($client);
$calendarId = 'portaaperta.calendario@gmail.com';

/**********************/
/* My custom function */
/**********************/
function getEventsInWindow($day, $start, $end) {
    global $service;
    global $calendarId;

    // Get calendar time zone
    $calendar = $service->calendars->get($calendarId);
    $tz = new DateTimeZone($calendar->getTimeZone());

    // Construct DateTime for window start and end in calendar's time zone
    $windowStart = new DateTime("$day $start:00", $tz);
    $windowEnd = new DateTime("$day $end:00", $tz);

    // Format for API (RFC3339 with offset)
    $timeMin = $windowStart->format(DateTime::RFC3339);
    $timeMax = $windowEnd->format(DateTime::RFC3339);

    // Fetch events in the window
    $eventsList = $service->events->listEvents($calendarId, [
        'timeMin' => $timeMin,
        'timeMax' => $timeMax,
        'singleEvents' => true,
        'orderBy' => 'startTime',
    ]);

    $matchingEvents = [];

    foreach ($eventsList->getItems() as $event) {
        $startTime = $event->getStart()->getDateTime();
        $endTime = $event->getEnd()->getDateTime();

        if (!$startTime || !$endTime) {
            // Skip all-day or date-only events (no time info)
            continue;
        }

        // Convert event times to DateTime in calendar timezone
        $eventStart = new DateTime($startTime, $tz);
        $eventEnd = new DateTime($endTime, $tz);

        // Check if event starts AND ends within the given window
        if ($eventStart >= $windowStart && $eventEnd <= $windowEnd) {
            $matchingEvents[] = $event;
        }
    }

    return $matchingEvents;  // array of Google_Service_Calendar_Event objects
}