<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';
include_once '../../models/Showing.php';

$database = new Database();
$db = $database->getConnection();

$showing = new Showing($db);
$stmt = $showing->read();
$num = $stmt->rowCount();

if($num > 0) {
    $showings_arr = array();

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        error_log('Row data: ' . print_r($row, true));
        
        $showing_item = array(
            "id" => $row['id'],
            "date" => $row['date'],
            "locationID" => $row['locationID'],
            "movieID" => $row['movieID'],
            "weblink" => $row['weblink'],
            "special_info" => $row['special_info'],
            "location_name_de" => $row['location_name_de'],
            "location_name_fr" => $row['location_name_fr'],
            "movie_title" => $row['movie_title'],
            "movie_db_id" => $row['movie_db_id']
        );

        array_push($showings_arr, $showing_item);
    }

    http_response_code(200);
    echo json_encode($showings_arr);
} else {
    http_response_code(404);
    echo json_encode(array("message" => "No showings found."));
}
