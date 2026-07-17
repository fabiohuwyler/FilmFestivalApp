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

// Make sure id is present
if (empty($data->id)) {
    http_response_code(400);
    echo json_encode(array("message" => "Unable to delete content note. No ID provided."));
    exit();
}

// Set content note id
$contentNote->id = $data->id;

// Delete the content note
try {
    if($contentNote->delete()) {
        http_response_code(200);
        echo json_encode(array("message" => "Content note was deleted."));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Unable to delete content note."));
    }
} catch (Exception $e) {
    http_response_code(503);
    echo json_encode(array("message" => $e->getMessage()));
}
