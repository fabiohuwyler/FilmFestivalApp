<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Movies - Your Filmfestival Festival Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .modal:not(.show) {
            display: none;
        }
        /* Ensure modal content is visible to screen readers */
        .modal-dialog {
            position: relative;
            pointer-events: auto;
        }
    </style>
</head>
<body>

<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $basePath = dirname(dirname(__DIR__)); // This will give us the api root directory
    require_once $basePath . '/config/database.php';
    require_once $basePath . '/models/Movie.php';

    $database = new Database();
    $db = $database->getConnection();
    if (!$db) {
        throw new Exception('Database connection failed');
    }
    
    $movie = new Movie($db);
} catch (Exception $e) {
    die('Error: ' . $e->getMessage());
}

?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Movies</h2>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#formModal" onclick="loadMovieForm()">
        <i class="bi bi-plus-circle"></i> Add Movie
    </button>
</div>

<div class="table-responsive">
    <table class="table table-striped">
        <thead>
            <tr>
                <th>Title</th>
                <th>Duration</th>
                <th>Director</th>
                <th>Language</th>
                <th>Subtitles</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php
            try {
                $stmt = $movie->read();
                while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                echo "<tr>";
                echo "<td>" . htmlspecialchars($row['title']) . "</td>";
                echo "<td>" . htmlspecialchars($row['duration']) . " min</td>";
                echo "<td>" . htmlspecialchars($row['director'] ?? '-') . "</td>";
                echo "<td>" . htmlspecialchars($row['originlang'] ?? '-') . "</td>";
                echo "<td>" . htmlspecialchars($row['subtitles'] ?? '-') . "</td>";
                echo "<td class='action-buttons'>";
                $editBtn = sprintf('<button class="btn btn-sm btn-outline-primary me-2" onclick="loadMovieForm(\'%s\')" data-bs-toggle="modal" data-bs-target="#formModal"><i class="bi bi-pencil"></i></button>', $row['id']);
                $deleteBtn = sprintf('<button class="btn btn-sm btn-outline-danger" onclick="deleteMovie(\'%s\')"><i class="bi bi-trash"></i></button>', $row['id']);
                echo $editBtn . $deleteBtn;
                echo "</td>";
                echo "</tr>";
                }
            } catch (Exception $e) {
                echo "<tr><td colspan='5' class='text-danger'>Error loading movies: " . htmlspecialchars($e->getMessage()) . "</td></tr>";
            }
            ?>
        </tbody>
    </table>
</div>

<!-- Modal -->
<div class="modal" id="formModal" tabindex="-1" role="dialog" aria-labelledby="formModalLabel">
    <!-- Remove fade class and add data-bs-backdrop="static" to prevent focus issues -->
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="formModalLabel">Add/Edit Movie</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <!-- Form will be loaded here -->
            </div>
        </div>
    </div>
</div>

<script>
function loadMovieForm(id = null) {
    const title = id ? 'Edit Movie' : 'Add Movie';
    $('.modal-title').text(title);
    
    let formHtml = `
        <form id="movieForm" onsubmit="saveMovie(event)" enctype="multipart/form-data">
            <input type="hidden" name="id" value="${id || ''}">
            <div class="mb-3">
                <label class="form-label">Title *</label>
                <input type="text" class="form-control" name="title" required>
            </div>
            <div class="mb-3">
                <label class="form-label">German Description</label>
                <textarea class="form-control" name="description_de" rows="3" placeholder="Enter German description"></textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">French Description</label>
                <textarea class="form-control" name="description_fr" rows="3" placeholder="Enter French description"></textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Duration (minutes) *</label>
                <input type="number" class="form-control" name="duration" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Director</label>
                <input type="text" class="form-control" name="director">
            </div>
            <div class="mb-3">
                <label class="form-label">Original Language</label>
                <input type="text" class="form-control" name="originlang">
            </div>
            <div class="mb-3">
                <label class="form-label">Country of Origin</label>
                <input type="text" class="form-control" name="country">
            </div>
            <div class="mb-3">
                <label class="form-label">Subtitles</label>
                <input type="text" class="form-control" name="subtitles" placeholder="e.g. German, French">
            </div>
            <div class="mb-3">
                <label class="form-label">Image</label>
                <div class="d-flex gap-3 align-items-start">
                    <div class="flex-grow-1">
                        <input type="file" class="form-control" name="image" accept="image/*" onchange="previewImage(this)">
                        <input type="hidden" name="imageURL">
                        <div class="form-text">Maximum file size: 5MB. Allowed types: JPG, PNG, GIF</div>
                    </div>
                    <div id="imagePreview"></div>
                </div>
            </div>
            <div class="mb-3">
                <label class="form-label">Trailer URL</label>
                <input type="url" class="form-control" name="trailerURL">
            </div>
            <div class="mb-3">
                <label class="form-label">Content Notes</label>
                <div class="content-notes-container">
                    <?php
                    try {
                        $stmt = $db->query("SELECT * FROM content_notes");
                        while ($note = $stmt->fetch(PDO::FETCH_ASSOC)) {
                            echo "<div class='form-check'>";
                            echo "<input class='form-check-input' type='checkbox' name='content_notes[]' value='{$note['id']}' id='cn_{$note['id']}'>";
                            echo "<label class='form-check-label' for='cn_{$note['id']}'>";
                            echo htmlspecialchars($note['title']);
                            echo "</label>";
                            echo "</div>";
                        }
                    } catch (Exception $e) {
                        echo "<div class='text-danger'>Error loading content notes</div>";
                    }
                    ?>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn btn-primary">Save</button>
            </div>
        </form>
    `;
    
    $('.modal-body').html(formHtml);
    
    if (id) {
        console.log('Loading movie data for id:', id);
        // Load movie data for editing
        fetch(`https://example.com/api/movies/read_one.php?id=${id}`)
            .then(response => response.json())
            .then(data => {
                console.log('Received movie data:', data);
                const form = document.getElementById('movieForm');
                form.title.value = data.title || '';
                form.description_de.value = data.description_de || '';
                form.description_fr.value = data.description_fr || '';
                form.duration.value = data.duration || '';
                form.director.value = data.director || '';
                form.originlang.value = data.originlang || '';
                form.country.value = data.country || '';
                form.subtitles.value = data.subtitles || '';
                form.trailerURL.value = data.trailerURL || '';
                
                // Show current image if it exists
                if (data.imageURL) {
                    const preview = document.getElementById('imagePreview');
                    preview.innerHTML = `<img src="${data.imageURL}" alt="Current image" style="max-width: 100px;">`;
                    form.querySelector('input[name="imageURL"]').value = data.imageURL;
                }

                // Check content notes checkboxes
                console.log('Content notes from API:', data.content_notes);
                // Uncheck all checkboxes first
                form.querySelectorAll('input[name="content_notes[]"]').forEach(checkbox => {
                    checkbox.checked = false;
                });
                
                // Then check the ones from the API if any exist
                if (data.content_notes) {
                    const notes = data.content_notes.split(',');
                    console.log('Split notes:', notes);
                    notes.forEach(noteId => {
                        if (noteId && noteId.trim()) {
                            console.log('Looking for checkbox with id:', `cn_${noteId}`);
                            const checkbox = document.getElementById(`cn_${noteId}`);
                            console.log('Found checkbox:', checkbox);
                            if (checkbox) {
                                checkbox.checked = true;
                                console.log('Checkbox checked:', noteId);
                            }
                        }
                    });
                }
            });
    }
}

function previewImage(input) {
    const preview = document.getElementById('imagePreview');
    const form = input.closest('form');
    const imageUrlInput = form.querySelector('input[name="imageURL"]');
    
    if (input.files && input.files[0]) {
        // New file selected
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.innerHTML = `<img src="${e.target.result}" class="img-thumbnail" style="max-height: 200px">`;
        };
        reader.readAsDataURL(input.files[0]);
        
        // Clear the existing imageURL since we're uploading a new file
        if (imageUrlInput) {
            imageUrlInput.value = '';
        }
    } else {
        // No new file, show existing image if any
        const currentImageUrl = imageUrlInput?.value;
        if (currentImageUrl) {
            preview.innerHTML = `<img src="${currentImageUrl}" class="img-thumbnail" style="max-height: 200px">`;
        } else {
            preview.innerHTML = '';
        }
    }
}

async function uploadImage(file) {
    const formData = new FormData();
    formData.append('image', file);
    formData.append('image', file);
    formData.append('type', 'movies');

    try {
        console.log('Starting image upload...');
        console.log('File being uploaded:', file.name, 'Size:', file.size);

        const response = await fetch('https://example.com/api/upload/image.php', {
            method: 'POST',
            body: formData,
            // Don't set Content-Type header - browser will set it with boundary
        });

        console.log('Upload response status:', response.status);
        const responseText = await response.text();
        console.log('Raw response:', responseText);

        let result;
        try {
            result = JSON.parse(responseText);
        } catch (e) {
            console.error('Failed to parse JSON response:', e);
            throw new Error('Server returned invalid JSON: ' + responseText);
        }

        console.log('Parsed response:', result);

        if (!response.ok || result.status === 'error') {
            throw new Error(result.message || 'Upload failed');
        }
        return result.data.thumb_url;
    } catch (error) {
        console.error('Upload error:', error);
        alert('Error uploading image: ' + error.message);
        throw error;
    }
}

async function saveMovie(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);
    
    try {
        console.log('Starting form submission...');
        const movieData = {};
        
        // Add basic fields
        formData.forEach((value, key) => {
            if (key !== 'image' && key !== 'content_notes[]') {
                movieData[key] = value || null; // Convert empty strings to null
            }
        });
        console.log('Basic fields:', movieData);
        
        // Handle image URL
        const imageFile = formData.get('image');
        const currentImageUrl = form.querySelector('input[name="imageURL"]')?.value;
        
        if (imageFile?.size > 0) {
            console.log('Uploading new image:', imageFile.name);
            try {
                const uploadResult = await uploadImage(imageFile);
                console.log('Image uploaded successfully:', uploadResult);
                movieData.imageURL = uploadResult;
            } catch (uploadError) {
                console.error('Image upload failed:', uploadError);
                throw new Error('Failed to upload image: ' + uploadError.message);
            }
        } else if (currentImageUrl) {
            console.log('Keeping existing image URL:', currentImageUrl);
            movieData.imageURL = currentImageUrl;
        } else {
            console.log('No image provided');
            movieData.imageURL = null;
        }
        
        // Handle content notes
        const selectedNotes = [];
        form.querySelectorAll('input[name="content_notes[]"]:checked').forEach(checkbox => {
            if (checkbox.value && checkbox.value.trim()) {
                selectedNotes.push(checkbox.value);
            }
        });
        movieData.content_notes = selectedNotes.length > 0 ? selectedNotes.join(',') : null;
        console.log('Content notes:', movieData.content_notes);
        
        const url = movieData.id ? 'https://example.com/api/movies/update.php' : 'https://example.com/api/movies/create.php';
        console.log('Submitting to URL:', url);
        console.log('Final data:', JSON.stringify(movieData, null, 2));
        
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(movieData)
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        console.log('Server response:', result);
        
        if (result.status === 'error' || !result.message) {
            throw new Error(result.message || 'Unknown error saving movie');
        }
        
        console.log('Success! Closing modal and reloading...');
        const modal = bootstrap.Modal.getInstance(document.getElementById('formModal'));
        if (modal) modal.hide();
        location.reload();
    } catch (error) {
        console.error('Error in saveMovie:', error);
        alert('Error saving movie: ' + (error.message || 'Unknown error'));
        throw error; // Re-throw to see the full stack trace in console
    }
}

async function deleteMovie(id) {
    if (confirm('Are you sure you want to delete this movie?')) {
        try {
            const response = await fetch('https://example.com/api/movies/delete.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ id: id })
            });
            
            const result = await response.json();
            if (result.message) {
                location.reload();
            } else {
                alert('Error deleting movie');
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Error deleting movie: ' + error.message);
        }
    }
}
</script>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Initialize modal when DOM is ready
    let formModal;
    document.addEventListener('DOMContentLoaded', () => {
        formModal = new bootstrap.Modal(document.getElementById('formModal'));
    });
</script>
</body>
</html>
