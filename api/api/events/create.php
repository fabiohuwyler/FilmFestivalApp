<?php
// Required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database and object files
include_once '../../config/database.php';
include_once '../../models/Event.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize event object
$event = new Event($db);

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Make sure all required fields are present
if (
    empty($data->title_de) ||
    empty($data->title_fr) ||
    empty($data->description_de) ||
    empty($data->description_fr) ||
    empty($data->date) ||
    empty($data->locationID)
) {
    http_response_code(400);
    echo json_encode(array("message" => "Unable to create event. Required data is incomplete."));
    exit();
}

// Set event property values
$event->title_de = $data->title_de;
$event->title_fr = $data->title_fr;
$event->description_de = $data->description_de;
$event->description_fr = $data->description_fr;
$event->date = $data->date;
$event->imageURL = $data->imageURL ?? null;
$event->locationID = $data->locationID;
$event->weblink = $data->weblink ?? null;

// Create the event
try {
    if($event->create()) {
        http_response_code(201);
        echo json_encode(array("message" => "Event was created."));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Unable to create event."));
    }
} catch(Exception $e) {
    http_response_code(503);
    echo json_encode(array(
        "message" => "Unable to create event.",
        "error" => $e->getMessage()
    ));
}
?>
