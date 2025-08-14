<?php

function fetchEventsByDate($start, $end) {
    try {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");

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
        $allDay = ($row["Stato"]=='PRENOTATA');

        $events[] = [
            "title" => $row["Cliente"],
            "allDay" => $allDay,
            "start" => $row["DataPrenotata"],
        ];
    }

    return json_encode($events);
}