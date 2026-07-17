<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';
include_once '../../models/Event.php';

$database = new Database();
$db = $database->getConnection();

$event = new Event($db);
$stmt = $event->read();
$num = $stmt->rowCount();

if($num > 0) {
    $events_arr = array();

    error_log('Processing events result set');
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        error_log('Event row data: ' . print_r($row, true));

        $event_item = array(
            "id" => $row['id'] ?? null,
            "title_de" => $row['title_de'] ?? null,
            "title_fr" => $row['title_fr'] ?? null,
            "description_de" => $row['description_de'] ?? null,
            "description_fr" => $row['description_fr'] ?? null,
            "date" => $row['date'] ?? null,
            "imageURL" => $row['imageURL'] ?? null,
            "locationID" => $row['locationID'] ?? null,
            "location_name_de" => $row['location_name_de'] ?? null,
            "location_name_fr" => $row['location_name_fr'] ?? null,
            "weblink" => $row['weblink'] ?? null,
            "showings" => []
        );

        error_log('Processed event item: ' . print_r($event_item, true));
        array_push($events_arr, $event_item);
    }

    http_response_code(200);
    echo json_encode($events_arr);
} else {
    http_response_code(404);
    echo json_encode(array("message" => "No events found."));
}
