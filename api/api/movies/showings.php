<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';
include_once '../../models/Showing.php';

$database = new Database();
$db = $database->getConnection();

$showing = new Showing($db);

// Get movie ID from URL
$movieId = isset($_GET['movie_id']) ? $_GET['movie_id'] : die();

$stmt = $showing->readForMovie($movieId);
$num = $stmt->rowCount();

if($num > 0) {
    $showings_arr = array();

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        extract($row);

        $showing_item = array(
            "id" => $id,
            "date" => $date,
            "locationID" => $locationID,
            "location_name" => $location_name,
            "weblink" => $weblink,
            "movieID" => $movieID,
            "special_info" => $special_info
        );

        array_push($showings_arr, $showing_item);
    }

    http_response_code(200);
    echo json_encode($showings_arr);
} else {
    http_response_code(404);
    echo json_encode(array("message" => "No showings found for this movie."));
}
