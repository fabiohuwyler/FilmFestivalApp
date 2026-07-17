<?php
// Required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database and object files
include_once '../../config/database.php';
include_once '../../models/ContentNote.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize content note object
$contentNote = new ContentNote($db);

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Make sure all required fields are present
if (empty($data->id) || empty($data->title)) {
    http_response_code(400);
    echo json_encode(array("message" => "Unable to update content note. Required data is incomplete."));
    exit();
}

// Set content note property values
$contentNote->id = $data->id;
$contentNote->title = $data->title;

// Update the content note
try {
    if($contentNote->update()) {
        http_response_code(200);
        echo json_encode(array("message" => "Content note was updated."));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Unable to update content note."));
    }
} catch (Exception $e) {
    http_response_code(503);
    echo json_encode(array("message" => $e->getMessage()));
}
