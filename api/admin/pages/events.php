<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $basePath = dirname(dirname(__DIR__)); // This will give us the api root directory
    require_once $basePath . '/config/database.php';
    require_once $basePath . '/models/Event.php';

    $database = new Database();
    $db = $database->getConnection();
    if (!$db) {
        throw new Exception('Database connection failed');
    }
    
    $event = new Event($db);
} catch (Exception $e) {
    die('Error: ' . $e->getMessage());
}
?>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h2>Events</h2>
    <button type="button" class="btn btn-primary" onclick="openEventForm()">Add Event</button>
</div>

<div class="table-responsive">
    <table class="table table-striped">
        <thead>
            <tr>
                <th>Title (DE)</th>
                <th>Title (FR)</th>
                <th>Date</th>
                <th>Location</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php
            try {
                $stmt = $event->read();
                while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                    echo "<tr>";
                    echo "<td>" . htmlspecialchars($row['title_de']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['title_fr']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['date']) . "</td>";
                    echo "<td>" . htmlspecialchars(($row['location_name_de'] ?? '-') . ' / ' . ($row['location_name_fr'] ?? '-')) . "</td>";
                    echo "<td class='action-buttons'>";
                    $editBtn = sprintf('<button class="btn btn-sm btn-outline-primary me-2" onclick="openEventForm(\'%s\')" title="Edit"><i class="bi bi-pencil"></i></button>', $row['id']);
                    $deleteBtn = sprintf('<button class="btn btn-sm btn-outline-danger" onclick="deleteEvent(\'%s\')" title="Delete"><i class="bi bi-trash"></i></button>', $row['id']);
                    echo $editBtn . $deleteBtn;
                    echo "</td>";
                    echo "</tr>";
                }
            } catch (Exception $e) {
                echo "<tr><td colspan='4' class='text-danger'>Error loading events: " . htmlspecialchars($e->getMessage()) . "</td></tr>";
            }
            ?>
        </tbody>
    </table>
</div>

<script>
function previewImage(input) {
    const preview = document.getElementById('imagePreview');
    const form = input.closest('form');
    
    // Clear any existing preview
    preview.innerHTML = '';
    
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.innerHTML = `<img src="${e.target.result}" class="img-thumbnail" style="max-height: 200px">`;
        };
        reader.readAsDataURL(input.files[0]);
        
        // Clear the existing imageURL when a new file is selected
        const imageUrlInput = form.querySelector('input[name="imageURL"]');
        if (imageUrlInput) {
            imageUrlInput.value = '';
        }
    }
}

function openEventForm(id = null) {
    const title = id ? 'Edit Event' : 'Add Event';
    document.querySelector('.modal-title').textContent = title;
    
    // Initialize modal
    const modalElement = document.getElementById('formModal');
    let modal = bootstrap.Modal.getInstance(modalElement);
    if (!modal) {
        modal = new bootstrap.Modal(modalElement);
    }
    modal.show();

    // Initialize image preview container
    const imagePreview = document.getElementById('imagePreview');
    if (imagePreview) {
        imagePreview.innerHTML = '';
    }

    // First, fetch locations for the dropdown
    fetch('https://example.com/api/locations/read.php')
        .then(async response => {
            if (!response.ok) {
                const text = await response.text();
                console.error('Error fetching locations:', text);
                throw new Error(`HTTP error! status: ${response.status}, body: ${text}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('Locations data:', data);
            if (!Array.isArray(data)) {
                throw new Error('Expected array of locations, got: ' + JSON.stringify(data));
            }
            
            let locationOptions = data.map(loc => 
                `<option value="${loc.id || ''}">${(loc.name_de || 'Unnamed')} / ${(loc.name_fr || 'Sans nom')}</option>`
            ).join('');
            
            let formHtml = `
                <form id="eventForm" onsubmit="saveEvent(event)" enctype="multipart/form-data">
                    <input type="hidden" name="id" value="${id || ''}">
                    <div class="mb-3">
                        <label class="form-label">Title (German) *</label>
                        <input type="text" class="form-control" name="title_de" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Title (French) *</label>
                        <input type="text" class="form-control" name="title_fr" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Description (German) *</label>
                        <textarea class="form-control" name="description_de" rows="3" required></textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Description (French) *</label>
                        <textarea class="form-control" name="description_fr" rows="3" required></textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Date and Time *</label>
                        <input type="datetime-local" class="form-control" name="date" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Location *</label>
                        <select class="form-control" name="locationID" required>
                            <option value="">Select a location...</option>
                            ${locationOptions}
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Image</label>
                        <div class="d-flex gap-3 align-items-start">
                            <div class="flex-grow-1">
                                <input type="file" class="form-control" name="image" accept="image/*" onchange="previewImage(this)">
                                <div class="form-text">Maximum file size: 5MB. Allowed types: JPG, PNG, GIF</div>
                            </div>
                            <div id="imagePreview"></div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Web Link</label>
                        <input type="url" class="form-control" name="weblink">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            `;
            
            document.querySelector('.modal-body').innerHTML = formHtml;
            
            if (id) {
                // Load existing event data
                fetch(`https://example.com/api/events/read_one.php?id=${id}`)
                    .then(async response => {
                        if (!response.ok) {
                            const text = await response.text();
                            throw new Error(`HTTP error! status: ${response.status}, body: ${text}`);
                        }
                        return response.json();
                    })
                    .then(data => {
                console.log('Loaded event data:', data);
                const form = document.getElementById('eventForm');
                for (let field in data) {
                    const input = form.elements[field];
                    if (input) {
                        if (field === 'date') {
                            // Convert MySQL datetime to local datetime-local format
                            const date = new Date(data[field]);
                            input.value = date.toISOString().slice(0, 16);
                        } else if (field !== 'imageURL') { // Skip imageURL as it's handled separately
                            input.value = data[field];
                        }
                    }
                }
                
                // Show existing image if available
                if (data.imageURL) {
                    // Convert old image paths to new API paths
                    const imageURL = data.imageURL.replace('https://huwy.dev/queersicht/images/', 'https://example.com/uploads/');
                    console.log('Setting image preview:', imageURL);
                    const imagePreview = document.getElementById('imagePreview');
                    imagePreview.innerHTML = `<img src="${imageURL}" class="img-thumbnail" style="max-height: 200px">`;
                    // Store the current image URL in a hidden input
                    const imageUrlInput = form.querySelector('input[name="imageURL"]') || document.createElement('input');
                    imageUrlInput.type = 'hidden';
                    imageUrlInput.name = 'imageURL';
                    imageUrlInput.value = imageURL;
                    if (!form.querySelector('input[name="imageURL"]')) {
                        form.appendChild(imageUrlInput);
                    }
                }
            });
            }
        });
}

async function uploadImage(file) {
    const formData = new FormData();
    formData.append('image', file);
    formData.append('type', 'events');

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

async function saveEvent(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);
    
    try {
        console.log('Starting form submission...');
        
        // Handle image upload first if a new file is selected
        const imageFile = formData.get('image');
        console.log('Image file:', imageFile && imageFile.name);
        
        if (imageFile && imageFile.size > 0) {
            console.log('Uploading image...');
            const imageUrl = await uploadImage(imageFile);
            console.log('Image uploaded successfully:', imageUrl);
            formData.set('imageURL', imageUrl);
        }

        // Remove the file input from the data we'll send to the API
        formData.delete('image');
        
        const data = Object.fromEntries(formData.entries());
        console.log('Form data:', data);
        
        const url = data.id ? 'https://example.com/api/events/update.php' : 'https://example.com/api/events/create.php';
        console.log('Submitting to URL:', url);
        
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });

        const result = await response.json();
        console.log('Server response:', result);
        
        if (result.status === 'error') {
            throw new Error(result.message || 'Unknown error saving event');
        }
        
        console.log('Success! Closing modal and reloading...');
        const modal = bootstrap.Modal.getInstance(document.getElementById('formModal'));
        if (modal) modal.hide();
        location.reload();
    } catch (error) {
        console.error('Error:', error);
        alert('Error saving event: ' + error.message);
    }
}

function deleteEvent(id) {
    if (confirm('Are you sure you want to delete this event?')) {
        fetch('https://example.com/api/events/delete.php', {
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
                alert('Error deleting event');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting event');
        });
    }
}
</script>
