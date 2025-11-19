<?php
require_once __DIR__ . '/init.php';

function fetchEventsByDate($start, $end)
{
    global $db_user, $db_password;
    try {
        $mysqli = new mysqli("mysql", $db_user, $db_password, "OpenDoor");

        $query = "CALL procedura_restituisci_eventi(?, ?)";

        $start = date("Y-m-d", strtotime($start));
        $end = date("Y-m-d", strtotime($end));
        $params = [$start, $end];

        $result = $mysqli->execute_query($query, $params);

    } catch (Exception $e) {
        if (isset($mysqli)) {
            $mysqli->close();
        }
        return;
    }

    $mysqli->close();

    $events = [];
    while ($row = $result->fetch_assoc()) {

        $bgcolor = match ($row["stato"]) {
                'PRENOTATA' => '#007bff', // Blue
                'COMPLETATA' => '#28a745',  // Green
                'ANNULLATA' => '#dc3545', // Red
                default => '#6c757d',     // Gray
        };

        $events[] = [
            "title" => $row["nome"] . " " . $row["cognome"],
            "start" => $row["data"] . (($row["orario"] != "" ) ? "T" . $row["orario"] : ""),
            "end" => $row["data"] . (($row["orario"] != "" ) ? "T" . $row["orario"] : ""),
            "allDay" => ($row["orario"] == "" ) ? true : false,
            "backgroundColor" => $bgcolor,
            "extendedProps" => [
                "id" => $row["id"]
            ]
        ];
    }

    return json_encode($events);
}