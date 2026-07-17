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

// Make sure id is present
if (empty($data->id)) {
    http_response_code(400);
    echo json_encode(array("message" => "Unable to delete showing. No ID provided."));
    exit();
}

// Set showing id
$showing->id = $data->id;

// Delete the showing
try {
    if($showing->delete()) {
        http_response_code(200);
        echo json_encode(array("message" => "Showing was deleted."));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Unable to delete showing."));
    }
} catch(Exception $e) {
    http_response_code(503);
    echo json_encode(array(
        "message" => "Unable to delete showing.",
        "error" => $e->getMessage()
    ));
}
?>
