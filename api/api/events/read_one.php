<?php
// Required headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json");

// Include database and object files
include_once '../../config/database.php';
include_once '../../models/Event.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize event object
$event = new Event($db);

// Set ID property of event to read
$event->id = isset($_GET['id']) ? $_GET['id'] : die();

// Read the details of event to be edited
try {
    $row = $event->readOne();

    if ($row) {
        // Create array
        $event_arr = array(
            "id" => $event->id,
            "title_de" => $event->title_de,
            "title_fr" => $event->title_fr,
            "description_de" => $event->description_de,
            "description_fr" => $event->description_fr,
            "date" => $event->date,
            "imageURL" => $event->imageURL,
            "locationID" => $event->locationID,
            "weblink" => $event->weblink
        );

        // Set response code - 200 OK
        http_response_code(200);

        // Make it json format
        echo json_encode($event_arr);
    } else {
        // Set response code - 404 Not found
        http_response_code(404);

        // Tell the user event does not exist
        echo json_encode(array("message" => "Event does not exist."));
    }
} catch(Exception $e) {
    // Set response code - 503 Service unavailable
    http_response_code(503);

    // Tell the user
    echo json_encode(array(
        "message" => "Unable to read event.",
        "error" => $e->getMessage()
    ));
}
?>
