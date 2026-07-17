<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';
include_once '../../models/Location.php';

$database = new Database();
$db = $database->getConnection();

$location = new Location($db);
$stmt = $location->read();
$num = $stmt->rowCount();

if($num > 0) {
    $locations_arr = array();

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        error_log('Row data: ' . print_r($row, true));
        
        $location_item = array(
            "id" => $row['id'],
            "name_de" => $row['name_de'],
            "name_fr" => $row['name_fr'],
            "address_de" => $row['address_de'],
            "address_fr" => $row['address_fr'],
            "latitude" => floatval($row['latitude']),
            "longitude" => floatval($row['longitude']),
            "accessibilityInfo_de" => $row['accessibilityInfo_de'],
            "accessibilityInfo_fr" => $row['accessibilityInfo_fr'],
            "imageURL" => $row['imageURL'],
            "description_de" => $row['description_de'],
            "description_fr" => $row['description_fr']
        );

        array_push($locations_arr, $location_item);
    }

    http_response_code(200);
    echo json_encode($locations_arr);
} else {
    http_response_code(404);
    echo json_encode(array("message" => "No locations found."));
}
