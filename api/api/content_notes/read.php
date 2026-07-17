<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';
include_once '../../models/ContentNote.php';

$database = new Database();
$db = $database->getConnection();

$content_note = new ContentNote($db);
$stmt = $content_note->read();
$num = $stmt->rowCount();

if($num > 0) {
    $content_notes_arr = array();

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        extract($row);
        
        $content_note_item = array(
            "id" => $id,
            "title" => $title,
            "description" => $description
        );

        array_push($content_notes_arr, $content_note_item);
    }

    http_response_code(200);
    echo json_encode($content_notes_arr);
} else {
    http_response_code(404);
    echo json_encode(array("message" => "No content notes found."));
}
