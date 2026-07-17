<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    require_once __DIR__ . '/../../config/database.php';
    require_once __DIR__ . '/../../models/Showing.php';
    require_once __DIR__ . '/../../models/Movie.php';
    require_once __DIR__ . '/../../models/Location.php';

    $database = new Database();
    $db = $database->getConnection();
    if (!$db) {
        throw new Exception('Database connection failed');
    }
    
    // First get all movies
    $movieObj = new Movie($db);
    $movieStmt = $movieObj->read();
    $movies = $movieStmt->fetchAll(PDO::FETCH_ASSOC);
    
    $showing = new Showing($db);
    $movie = new Movie($db);
    $location = new Location($db);
} catch (Exception $e) {
    die('Error: ' . $e->getMessage());
}
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Showings</h2>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#formModal" onclick="loadShowingForm()">
        <i class="bi bi-plus-circle"></i> Add Showing
    </button>
</div>

<div class="table-responsive">
    <table class="table table-striped">
        <thead>
            <tr>
                <th>Movie</th>
                <th>Location</th>
                <th>Date & Time</th>
                <th>Special Info</th>
                <th>Weblink</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php
            try {
                $stmt = $showing->read();
                while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                    echo "<tr>";
                    error_log('Row data: ' . print_r($row, true));
                    
                    // Get movie title from movies array
                    $movieTitle = '-';
                    foreach ($movies as $movie) {
                        if ($movie['id'] === $row['movieID']) {
                            $movieTitle = $movie['title'];
                            break;
                        }
                    }
                    
                    echo "<td>" . htmlspecialchars($movieTitle) . "</td>";
                    echo "<td>" . htmlspecialchars(($row['location_name_de'] ?? '-') . ' / ' . ($row['location_name_fr'] ?? '-')) . "</td>";
                    echo "<td>" . htmlspecialchars($row['date'] ?? '-') . "</td>";
                    echo "<td>" . htmlspecialchars($row['special_info'] ?? '-') . "</td>";
                    echo "<td>" . ($row['weblink'] ? "<a href='" . htmlspecialchars($row['weblink']) . "' target='_blank'>View</a>" : '-') . "</td>";
                    echo "<td class='action-buttons'>";
                    $editBtn = sprintf('<button class="btn btn-sm btn-outline-primary me-2" onclick="loadShowingForm(\'%s\')" data-bs-toggle="modal" data-bs-target="#formModal"><i class="bi bi-pencil"></i></button>', $row['id']);
                    $deleteBtn = sprintf('<button class="btn btn-sm btn-outline-danger" onclick="deleteShowing(\'%s\')"><i class="bi bi-trash"></i></button>', $row['id']);
                    echo $editBtn . $deleteBtn;
                    echo "</td>";
                    echo "</tr>";
                }
            } catch (Exception $e) {
                echo "<tr><td colspan='6' class='text-danger'>Error loading showings: " . htmlspecialchars($e->getMessage()) . "</td></tr>";
            }
            ?>
        </tbody>
    </table>
</div>

<script>
function loadShowingForm(id = null) {
    const title = id ? 'Edit Showing' : 'Add Showing';
    $('.modal-title').text(title);
    console.log('Loading form for showing:', id);
    
    // First, fetch movies and locations for the dropdowns
    Promise.all([
        fetch('../api/movies/read.php'),
        fetch('../api/locations/read.php')
    ])
    .then(responses => Promise.all(responses.map(r => r.json())))
    .then(([movies, locations]) => {
        let movieOptions = movies.map(movie => 
            `<option value="${movie.id}">${movie.title}</option>`
        ).join('');
        
        let locationOptions = locations.map(loc => 
            `<option value="${loc.id}">${loc.name_de} / ${loc.name_fr}</option>`
        ).join('');
        
        let formHtml = `
            <form id="showingForm" onsubmit="saveShowing(event)">
                <input type="hidden" name="id">
                <div class="mb-3">
                    <label for="movieID" class="form-label">Movie *</label>
                    <select name="movieID" class="form-control" required>
                        <option value="">Select a movie</option>
                        ${movies.map(movie => 
                            `<option value="${movie.id}">${movie.title}</option>`
                        ).join('')}
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label">Location *</label>
                    <select class="form-control" name="locationID" required>
                        <option value="">Select a location...</option>
                        ${locationOptions}
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label">Date and Time * (24h format)</label>
                    <input type="datetime-local" class="form-control" name="date" required step="60">
                </div>
                <div class="mb-3">
                    <label class="form-label">Special Info</label>
                    <input type="text" class="form-control" name="special_info" placeholder="e.g., Mit Regisseur*in">
                </div>
                <div class="mb-3">
                    <label class="form-label">Weblink</label>
                    <input type="url" class="form-control" name="weblink">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save</button>
                </div>
            </form>
        `;
        
        $('.modal-body').html(formHtml);
        
        if (id) {
            fetch(`../api/showings/read_one.php?id=${id}`)
                .then(response => response.json())
                .then(showing => {
                    console.log('Received showing data:', showing);
                    // Wait for form to be ready
                    setTimeout(() => {
                        const form = document.getElementById('showingForm');
                        if (form) {
                            console.log('Setting form values');
                            form.elements['id'].value = showing.id;
                            form.elements['movieID'].value = showing.movieID;
                            form.elements['locationID'].value = showing.locationID;
                            
                            // Format date for datetime-local input (preserve local timezone)
                            if (showing.date) {
                                console.log('Setting date:', showing.date);
                                // Parse the date string as local time
                                const dateStr = showing.date.replace(' ', 'T');
                                const dateObj = new Date(dateStr);
                                const year = dateObj.getFullYear();
                                const month = String(dateObj.getMonth() + 1).padStart(2, '0');
                                const day = String(dateObj.getDate()).padStart(2, '0');
                                const hours = String(dateObj.getHours()).padStart(2, '0');
                                const minutes = String(dateObj.getMinutes()).padStart(2, '0');
                                const formattedDate = `${year}-${month}-${day}T${hours}:${minutes}`;
                                console.log('Formatted date:', formattedDate);
                                form.elements['date'].value = formattedDate;
                            }
                            
                            if (showing.special_info) {
                                console.log('Setting special info:', showing.special_info);
                                form.elements['special_info'].value = showing.special_info;
                            }
                            if (showing.weblink) {
                                console.log('Setting weblink:', showing.weblink);
                                form.elements['weblink'].value = showing.weblink;
                            }
                        } else {
                            console.error('Form not found!');
                        }
                    }, 500);
                })
                .catch(error => console.error('Error:', error));
        }
    });
}

function saveShowing(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);
    const data = Object.fromEntries(formData.entries());
    
    // Convert datetime-local to MySQL format (keep local timezone)
    if (data.date) {
        // Parse as local time, not UTC
        const date = new Date(data.date);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        const seconds = String(date.getSeconds()).padStart(2, '0');
        data.date = `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
    }
    
    const url = data.id ? '../api/showings/update.php' : '../api/showings/create.php';
    
    console.log('Sending data:', data);
    
    fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data)
    })
    .then(response => {
        console.log('Response status:', response.status);
        return response.json().catch(e => {
            console.error('JSON parse error:', e);
            throw new Error('Invalid JSON response');
        });
    })
    .then(result => {
        console.log('Response data:', result);
        if (result.message) {
            location.reload();
        } else {
            alert('Error saving showing: ' + (result.error || 'Unknown error'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error saving showing: ' + error.message);
    });
}

function deleteShowing(id) {
    if (confirm('Are you sure you want to delete this showing?')) {
        fetch('../api/showings/delete.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ id: id })
        })
        .then(response => response.json())
        .then(result => {
            if (result.message) {
                location.reload();
            } else {
                alert('Error deleting showing');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting showing');
        });
    }
}
</script>
