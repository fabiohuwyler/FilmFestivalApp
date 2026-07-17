<?php
// Required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database and object files
include_once '../../config/database.php';
include_once '../../models/Showing.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize showing object
$showing = new Showing($db);

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Debug log
error_log('Received data: ' . print_r($data, true));

// Make sure required fields are present
if (
    empty($data->movieID) ||
    empty($data->locationID) ||
    empty($data->date)
) {
    http_response_code(400);
    echo json_encode(array("message" => "Unable to create showing. Required data is incomplete."));
    exit();
}

// Set showing property values
$showing->movieID = $data->movieID;
$showing->locationID = $data->locationID;
$showing->date = $data->date;
$showing->weblink = $data->weblink ?? null;
$showing->special_info = $data->special_info ?? null;

// Create the showing
try {
    error_log('Attempting to create showing with: ' . print_r([
        'movieID' => $showing->movieID,
        'locationID' => $showing->locationID,
        'date' => $showing->date,
        'weblink' => $showing->weblink,
        'special_info' => $showing->special_info
    ], true));
    
    if($showing->create()) {
        http_response_code(201);
        echo json_encode(array("message" => "Showing was created."));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Unable to create showing."));
    }
} catch(Exception $e) {
    http_response_code(503);
    echo json_encode(array(
        "message" => "Unable to create showing.",
        "error" => $e->getMessage()
    ));
}
?>
