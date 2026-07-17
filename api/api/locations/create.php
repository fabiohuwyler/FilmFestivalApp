<?php
// Required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database and object files
include_once '../../config/database.php';
include_once '../../models/Location.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize location object
$location = new Location($db);

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Make sure required fields are present
if (empty($data->name_de) || empty($data->name_fr) || empty($data->address_de) || empty($data->address_fr)) {
    http_response_code(400);
    echo json_encode(array("message" => "Unable to create location. Required data is incomplete. Need name_de, name_fr, address_de, and address_fr."));
    exit();
}

// Set location property values
$location->name_de = $data->name_de;
$location->name_fr = $data->name_fr;
$location->address_de = $data->address_de;
$location->address_fr = $data->address_fr;
$location->latitude = $data->latitude ?? null;
$location->longitude = $data->longitude ?? null;
$location->accessibilityInfo_de = $data->accessibilityInfo_de ?? null;
$location->accessibilityInfo_fr = $data->accessibilityInfo_fr ?? null;
$location->imageURL = $data->imageURL ?? null;
$location->description_de = $data->description_de ?? null;
$location->description_fr = $data->description_fr ?? null;
$location->weblink = $data->weblink ?? null;

// Create the location
try {
    error_log('Creating location with data: ' . print_r($data, true));
    
    if($location->create()) {
        http_response_code(201);
        echo json_encode(array("message" => "Location was created."));
    } else {
        error_log('Failed to create location');
        http_response_code(503);
        echo json_encode(array("message" => "Unable to create location."));
    }
} catch(Exception $e) {
    error_log('Exception creating location: ' . $e->getMessage());
    http_response_code(503);
    echo json_encode(array(
        "message" => "Unable to create location.",
        "error" => $e->getMessage()
    ));
}
?>
