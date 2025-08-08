<?php
header('Content-Type: application/json');

// Adjust the path as needed based on your folder structure
require_once __DIR__ . '/../../includes/calendar.php';

try {
    // Example: call a function that returns an array of events
    $events = getEventsInWindow( "2025-08-07", "20:00", "22:00");

    $data = [];

    foreach ($events as $event) {
        $start = $event->getStart()->getDateTime() ?: $event->getStart()->getDate();
        $data[] = [
            'summary' => $event->getSummary(),
            'start' => $start,
            'htmlLink' => $event->getHtmlLink(),
        ];
    }

    echo json_encode($data);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}