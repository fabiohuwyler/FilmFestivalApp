<?php
class Event {
    private $conn;
    private $table_name = "events";

    public $id;
    public $title_de;
    public $title_fr;
    public $description_de;
    public $description_fr;
    public $date;
    public $imageURL;
    public $locationID;
    public $weblink;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function read() {
        $query = "SELECT e.*, l.name_de as location_name_de, l.name_fr as location_name_fr 
                 FROM " . $this->table_name . " e
                 LEFT JOIN locations l ON e.locationID = l.id";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt;
    }

    public function readOne() {
        try {
            $query = "SELECT e.*, l.name_de as location_name_de, l.name_fr as location_name_fr 
                     FROM " . $this->table_name . " e
                     LEFT JOIN locations l ON e.locationID = l.id 
                     WHERE e.id = ? LIMIT 0,1";
            error_log('Event readOne query: ' . $query . ' with id: ' . $this->id);
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            $stmt->execute();
            
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$row) {
                error_log('No event found with id: ' . $this->id);
                return false;
            }
            
            error_log('Found event data: ' . print_r($row, true));
            
            $this->title_de = $row['title_de'] ?? null;
            $this->title_fr = $row['title_fr'] ?? null;
            $this->description_de = $row['description_de'] ?? null;
            $this->description_fr = $row['description_fr'] ?? null;
            $this->date = $row['date'] ?? null;
            $this->imageURL = $row['imageURL'] ?? null;
            $this->locationID = $row['locationID'] ?? null;
            $this->weblink = $row['weblink'] ?? null;
            
            return $row;
        } catch (PDOException $e) {
            error_log('Error in Event readOne: ' . $e->getMessage());
            throw $e;
        }
    }

    private function generateUUID() {
        return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }

    public function create() {
        try {
            $query = "INSERT INTO " . $this->table_name . "
                    (id, title_de, title_fr, description_de, description_fr, date, imageURL, locationID, weblink)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            $stmt = $this->conn->prepare($query);

            // Generate UUID
            $this->id = $this->generateUUID();

            // Sanitize input
            $this->title_de = htmlspecialchars(strip_tags($this->title_de));
            $this->title_fr = htmlspecialchars(strip_tags($this->title_fr));
            $this->description_de = htmlspecialchars(strip_tags($this->description_de));
            $this->description_fr = htmlspecialchars(strip_tags($this->description_fr));
            $this->date = htmlspecialchars(strip_tags($this->date));
            $this->imageURL = $this->imageURL ? htmlspecialchars(strip_tags($this->imageURL)) : null;
            $this->locationID = htmlspecialchars(strip_tags($this->locationID));
            $this->weblink = $this->weblink ? htmlspecialchars(strip_tags($this->weblink)) : null;

            // Bind values
            $stmt->bindParam(1, $this->id);
            $stmt->bindParam(2, $this->title_de);
            $stmt->bindParam(3, $this->title_fr);
            $stmt->bindParam(4, $this->description_de);
            $stmt->bindParam(5, $this->description_fr);
            $stmt->bindParam(6, $this->date);
            $stmt->bindParam(7, $this->imageURL);
            $stmt->bindParam(8, $this->locationID);
            $stmt->bindParam(9, $this->weblink);

            if($stmt->execute()) {
                return true;
            }
            return false;
        } catch(PDOException $e) {
            error_log('Error creating event: ' . $e->getMessage());
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }

    public function update() {
        try {
            $query = "UPDATE " . $this->table_name . "
                    SET title_de = ?, title_fr = ?, description_de = ?, description_fr = ?, date = ?,
                        imageURL = ?, locationID = ?, weblink = ?
                    WHERE id = ?";

            $stmt = $this->conn->prepare($query);

            // Sanitize input
            $this->title_de = htmlspecialchars(strip_tags($this->title_de));
            $this->title_fr = htmlspecialchars(strip_tags($this->title_fr));
            $this->description_de = htmlspecialchars(strip_tags($this->description_de));
            $this->description_fr = htmlspecialchars(strip_tags($this->description_fr));
            $this->date = htmlspecialchars(strip_tags($this->date));
            $this->imageURL = $this->imageURL ? htmlspecialchars(strip_tags($this->imageURL)) : null;
            $this->locationID = htmlspecialchars(strip_tags($this->locationID));
            $this->weblink = $this->weblink ? htmlspecialchars(strip_tags($this->weblink)) : null;

            // Bind values
            $stmt->bindParam(1, $this->title_de);
            $stmt->bindParam(2, $this->title_fr);
            $stmt->bindParam(3, $this->description_de);
            $stmt->bindParam(4, $this->description_fr);
            $stmt->bindParam(5, $this->date);
            $stmt->bindParam(6, $this->imageURL);
            $stmt->bindParam(7, $this->locationID);
            $stmt->bindParam(8, $this->weblink);
            $stmt->bindParam(9, $this->id);

            return $stmt->execute();
        } catch(PDOException $e) {
            error_log('Error updating event: ' . $e->getMessage());
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }

    public function delete() {
        try {
            $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            return $stmt->execute();
        } catch(PDOException $e) {
            error_log('Error deleting event: ' . $e->getMessage());
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }
}
