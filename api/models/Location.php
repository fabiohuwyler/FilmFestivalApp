<?php
class Location {
    private $conn;
    private $table_name = "locations";

    public $id;
    public $weblink;
    public $name_de;
    public $name_fr;
    public $address_de;
    public $address_fr;
    public $latitude;
    public $longitude;
    public $accessibilityInfo_de;
    public $accessibilityInfo_fr;
    public $imageURL;
    public $description_de;
    public $description_fr;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function read() {
        try {
            $query = "SELECT id, name_de, name_fr, address_de, address_fr, latitude, longitude, 
                             accessibilityInfo_de, accessibilityInfo_fr, imageURL, description_de, 
                             description_fr 
                     FROM " . $this->table_name;
            error_log('Location read query: ' . $query);
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            
            error_log('Location read result count: ' . $stmt->rowCount());
            return $stmt;
        } catch (PDOException $e) {
            error_log('Error in Location read: ' . $e->getMessage());
            throw $e;
        }
    }

    public function readOne() {
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = ? LIMIT 0,1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->id);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $this->name_de = $row['name_de'];
        $this->name_fr = $row['name_fr'];
        $this->address_de = $row['address_de'];
        $this->address_fr = $row['address_fr'];
        $this->latitude = $row['latitude'];
        $this->longitude = $row['longitude'];
        $this->accessibilityInfo_de = $row['accessibilityInfo_de'];
        $this->accessibilityInfo_fr = $row['accessibilityInfo_fr'];
        $this->imageURL = $row['imageURL'];
        $this->description_de = $row['description_de'];
        $this->description_fr = $row['description_fr'];
        $this->weblink = $row['weblink'];
        
        return $row;
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
            // First, check if the table exists and its structure
            $checkTable = "DESCRIBE " . $this->table_name;
            $tableStmt = $this->conn->query($checkTable);
            $columns = $tableStmt->fetchAll(PDO::FETCH_COLUMN);
            $hasWeblink = in_array('weblink', $columns);
            error_log('Table columns: ' . print_r($columns, true));

            // Build column list and placeholders based on available columns
            $columnList = ['id', 'name_de', 'name_fr', 'address_de', 'address_fr'];
            $values = [$this->generateUUID(), $this->name_de, $this->name_fr, $this->address_de, $this->address_fr];

            if ($this->latitude !== null) {
                $columnList[] = 'latitude';
                $values[] = $this->latitude;
            }
            if ($this->longitude !== null) {
                $columnList[] = 'longitude';
                $values[] = $this->longitude;
            }
            if ($this->accessibilityInfo_de !== null) {
                $columnList[] = 'accessibilityInfo_de';
                $values[] = $this->accessibilityInfo_de;
            }
            if ($this->accessibilityInfo_fr !== null) {
                $columnList[] = 'accessibilityInfo_fr';
                $values[] = $this->accessibilityInfo_fr;
            }
            if ($this->imageURL !== null) {
                $columnList[] = 'imageURL';
                $values[] = $this->imageURL;
            }
            if ($this->description_de !== null) {
                $columnList[] = 'description_de';
                $values[] = $this->description_de;
            }
            if ($this->description_fr !== null) {
                $columnList[] = 'description_fr';
                $values[] = $this->description_fr;
            }
            if ($hasWeblink && $this->weblink !== null) {
                $columnList[] = 'weblink';
                $values[] = $this->weblink;
            }

            $placeholders = array_fill(0, count($columnList), '?');
            $query = "INSERT INTO " . $this->table_name . "
                    (" . implode(', ', $columnList) . ")
                    VALUES (" . implode(', ', $placeholders) . ")";

            error_log('Insert query: ' . $query);
            error_log('Insert values: ' . print_r($values, true));

            $stmt = $this->conn->prepare($query);

            // Sanitize input
            $this->name = htmlspecialchars(strip_tags($this->name));
            $this->address = htmlspecialchars(strip_tags($this->address));
            $this->latitude = $this->latitude ? filter_var($this->latitude, FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION) : null;
            $this->longitude = $this->longitude ? filter_var($this->longitude, FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION) : null;
            $this->accessibilityInfo = $this->accessibilityInfo ? htmlspecialchars(strip_tags($this->accessibilityInfo)) : null;
            // Don't sanitize imageURL as it needs to keep its URL format
            $this->imageURL = $this->imageURL ?: null;
            $this->description = $this->description ? htmlspecialchars(strip_tags($this->description)) : null;
            if ($hasWeblink) {
                $this->weblink = $this->weblink ? htmlspecialchars(strip_tags($this->weblink)) : null;
            }

            // Bind values
            for ($i = 0; $i < count($values); $i++) {
                $stmt->bindParam($i + 1, $values[$i]);
            }

            $result = $stmt->execute();
            if (!$result) {
                error_log('SQL Error: ' . print_r($stmt->errorInfo(), true));
            }
            return $result;
        } catch(PDOException $e) {
            error_log('Error creating location: ' . $e->getMessage());
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }

    public function update() {
        try {
            error_log('Updating location: ' . print_r([
                'id' => $this->id,
                'name_de' => $this->name_de,
                'name_fr' => $this->name_fr,
                'address_de' => $this->address_de,
                'address_fr' => $this->address_fr,
                'imageURL' => $this->imageURL
            ], true));

            // Build query based on available columns
            $query = "UPDATE " . $this->table_name . " SET name_de = ?, name_fr = ?, address_de = ?, address_fr = ?";
            $params = [$this->name_de, $this->name_fr, $this->address_de, $this->address_fr];

            if ($this->latitude !== null) {
                $query .= ", latitude = ?";
                $params[] = $this->latitude;
            }
            if ($this->longitude !== null) {
                $query .= ", longitude = ?";
                $params[] = $this->longitude;
            }
            if ($this->accessibilityInfo_de !== null) {
                $query .= ", accessibilityInfo_de = ?";
                $params[] = $this->accessibilityInfo_de;
            }
            if ($this->accessibilityInfo_fr !== null) {
                $query .= ", accessibilityInfo_fr = ?";
                $params[] = $this->accessibilityInfo_fr;
            }
            if ($this->imageURL !== null) {
                $query .= ", imageURL = ?";
                $params[] = $this->imageURL;
            }
            if ($this->description_de !== null) {
                $query .= ", description_de = ?";
                $params[] = $this->description_de;
            }
            if ($this->description_fr !== null) {
                $query .= ", description_fr = ?";
                $params[] = $this->description_fr;
            }
            if ($this->weblink !== null) {
                $query .= ", weblink = ?";
                $params[] = $this->weblink;
            }

            $query .= " WHERE id = ?";
            $params[] = $this->id;

            error_log('Update query: ' . $query);
            error_log('Update params: ' . print_r($params, true));

            $stmt = $this->conn->prepare($query);

            // Sanitize input
            $this->name = htmlspecialchars(strip_tags($this->name));
            $this->address = htmlspecialchars(strip_tags($this->address));
            $this->latitude = $this->latitude ? filter_var($this->latitude, FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION) : null;
            $this->longitude = $this->longitude ? filter_var($this->longitude, FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION) : null;
            $this->accessibilityInfo = $this->accessibilityInfo ? htmlspecialchars(strip_tags($this->accessibilityInfo)) : null;
            // Don't sanitize imageURL as it needs to keep its URL format
            $this->imageURL = $this->imageURL ?: null;
            $this->description = $this->description ? htmlspecialchars(strip_tags($this->description)) : null;
            if ($hasWeblink) {
                $this->weblink = $this->weblink ? htmlspecialchars(strip_tags($this->weblink)) : null;
            }

            // Bind values
            for ($i = 0; $i < count($params); $i++) {
                $stmt->bindParam($i + 1, $params[$i]);
            }

            $result = $stmt->execute();
            if (!$result) {
                error_log('SQL Error: ' . print_r($stmt->errorInfo(), true));
            }
            return $result;
        } catch(PDOException $e) {
            error_log('Error updating location: ' . $e->getMessage());
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }

    public function delete() {
        try {
            $this->conn->beginTransaction();

            // First delete related events
            $query = "DELETE FROM events WHERE locationID = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            $stmt->execute();

            // Then delete the location
            $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            $result = $stmt->execute();

            $this->conn->commit();
            return $result;
        } catch(PDOException $e) {
            $this->conn->rollBack();
            error_log('Error deleting location: ' . $e->getMessage());
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }
}
