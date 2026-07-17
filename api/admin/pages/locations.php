<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $basePath = dirname(dirname(__DIR__)); // This will give us the api root directory
    require_once $basePath . '/config/database.php';
    require_once $basePath . '/models/Location.php';

    $database = new Database();
    $db = $database->getConnection();
    if (!$db) {
        throw new Exception('Database connection failed');
    }
    
    $location = new Location($db);
} catch (Exception $e) {
    die('Error: ' . $e->getMessage());
}
?>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h2>Locations</h2>
    <button type="button" class="btn btn-primary" onclick="openLocationForm()">Add Location</button>
</div>

<div class="table-responsive">
    <table class="table table-striped">
        <thead>
            <tr>
                <th>Name (DE)</th>
                <th>Name (FR)</th>
                <th>Address (DE)</th>
                <th>Address (FR)</th>
                <th>Website</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php
            try {
                $stmt = $location->read();
                while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                    echo "<tr>";
                    echo "<td>" . htmlspecialchars($row['name_de']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['name_fr']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['address_de']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['address_fr']) . "</td>";
                    echo "<td>" . (isset($row['weblink']) && $row['weblink'] ? "<a href='" . htmlspecialchars($row['weblink']) . "' target='_blank'>" . htmlspecialchars($row['weblink']) . "</a>" : "-") . "</td>";
                    echo "<td class='action-buttons'>";
                    $editBtn = sprintf('<button class="btn btn-sm btn-outline-primary me-2" onclick="openLocationForm(\'%s\')" title="Edit"><i class="bi bi-pencil"></i></button>', $row['id']);
                    $deleteBtn = sprintf('<button class="btn btn-sm btn-outline-danger" onclick="deleteLocation(\'%s\')" title="Delete"><i class="bi bi-trash"></i></button>', $row['id']);
                    echo $editBtn . $deleteBtn;
                    echo "</td>";
                    echo "</tr>";
                }
            } catch (Exception $e) {
                echo "<tr><td colspan='4' class='text-danger'>Error loading locations: " . htmlspecialchars($e->getMessage()) . "</td></tr>";
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
    } else {
        // If no new file is selected and we have an existing imageURL, show that
        const imageUrlInput = form.querySelector('input[name="imageURL"]');
        if (imageUrlInput && imageUrlInput.value) {
            preview.innerHTML = `<img src="${imageUrlInput.value}" class="img-thumbnail" style="max-height: 200px">`;
        }
    }
}
function openLocationForm(id = null) {
    const title = id ? 'Edit Location' : 'Add Location';
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
    
    let formHtml = `
        <form id="locationForm" onsubmit="saveLocation(event)" enctype="multipart/form-data">
            <input type="hidden" name="id" value="${id || ''}">
            <input type="hidden" name="imageURL">
            <div class="mb-3">
                <label class="form-label">Name (German) *</label>
                <input type="text" class="form-control" name="name_de" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Name (French) *</label>
                <input type="text" class="form-control" name="name_fr" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Address (German) *</label>
                <input type="text" class="form-control" name="address_de" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Address (French) *</label>
                <input type="text" class="form-control" name="address_fr" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Website</label>
                <input type="url" class="form-control" name="weblink">
            </div>
            <div class="mb-3">
                <label class="form-label">Description (German)</label>
                <textarea class="form-control" name="description_de" rows="3"></textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Description (French)</label>
                <textarea class="form-control" name="description_fr" rows="3"></textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Latitude</label>
                <input type="number" step="any" class="form-control" name="latitude">
            </div>
            <div class="mb-3">
                <label class="form-label">Longitude</label>
                <input type="number" step="any" class="form-control" name="longitude">
            </div>
            <div class="mb-3">
                <label class="form-label">Accessibility Info (German)</label>
                <textarea class="form-control" name="accessibilityInfo_de" rows="2"></textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Accessibility Info (French)</label>
                <textarea class="form-control" name="accessibilityInfo_fr" rows="2"></textarea>
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
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn btn-primary">Save</button>
            </div>
        </form>
    `;
    document.querySelector('.modal-body').innerHTML = formHtml;
    
    if (id) {
        // Load existing location data
        fetch(`https://example.com/api/locations/read_one.php?id=${id}`)
            .then(async response => {
                if (!response.ok) {
                    const text = await response.text();
                    throw new Error(`HTTP error! status: ${response.status}, body: ${text}`);
                }
                return response.json();
            })
            .then(data => {
                console.log('Loaded location data:', data);
                const form = document.getElementById('locationForm');
                for (let field in data) {
                    const input = form.elements[field];
                    if (input && field !== 'imageURL') {
                        input.value = data[field];
                    }
                }
                
                // Show existing image if available
                if (data.imageURL) {
                    let imageURL = data.imageURL;
                    // Convert old image paths to new API paths if needed
                    if (imageURL.includes('/images/')) {
                        imageURL = imageURL.replace('https://huwy.dev/queersicht/images/', 'https://example.com/uploads/');
                    }
                    console.log('Setting image preview:', imageURL);
                    const imagePreview = document.getElementById('imagePreview');
                    imagePreview.innerHTML = `<img src="${imageURL}" class="img-thumbnail" style="max-height: 200px">`;
                    // Store the current image URL in a hidden input
                    const imageUrlInput = form.querySelector('input[name="imageURL"]');
                    if (imageUrlInput) {
                        imageUrlInput.value = imageURL;
                        console.log('Set imageURL input value:', imageURL);
                    } else {
                        console.error('Could not find imageURL input');
                    }
                }
            });
    }
}

async function uploadImage(file) {
    const formData = new FormData();
    formData.append('image', file);
    formData.append('type', 'locations');

    try {
        console.log('Starting image upload...');
        console.log('File being uploaded:', file.name, 'Size:', file.size);

        const response = await fetch('https://example.com/api/upload/image.php', {
            method: 'POST',
            body: formData
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

        // Return the exact URL from the server response
        return result.data.thumb_url;
    } catch (error) {
        console.error('Upload error:', error);
        alert('Error uploading image: ' + error.message);
        throw error;
    }
}

async function saveLocation(event) {
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
        
        // Convert form data to object and handle required fields
        const data = {};
        const requiredFields = ['name_de', 'name_fr', 'address_de', 'address_fr'];
        
        for (let [key, value] of formData.entries()) {
            // Always include required fields even if empty
            if (requiredFields.includes(key) || value !== '') {
                // Convert numeric strings to numbers for latitude/longitude
                if (key === 'latitude' || key === 'longitude') {
                    value = parseFloat(value) || null;
                }
                data[key] = value;
            }
        }
        console.log('Form data:', data);
        
        const url = data.id ? 'https://example.com/api/locations/update.php' : 'https://example.com/api/locations/create.php';
        console.log('Submitting to URL:', url);
        
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });

        if (!response.ok) {
            const text = await response.text();
            console.error('Server error response:', text);
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();
        console.log('Server response:', result);
        
        if (result.status === 'error') {
            throw new Error(result.message || 'Unknown error saving location');
        }
        
        console.log('Success! Closing modal and reloading...');
        const modal = bootstrap.Modal.getInstance(document.getElementById('formModal'));
        if (modal) modal.hide();
        location.reload();
    } catch (error) {
        console.error('Error:', error);
        alert('Error saving location: ' + error.message);
    }
}

function deleteLocation(id) {
    if (confirm('Are you sure you want to delete this location?')) {
        fetch('https://example.com/api/locations/delete.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ id: id })
        })
        .then(async response => {
            if (!response.ok) {
                const text = await response.text();
                throw new Error(`HTTP error! status: ${response.status}, body: ${text}`);
            }
            return response.json();
        })
        .then(result => {
            console.log('Delete response:', result);
            if (result.status === 'error') {
                throw new Error(result.message || 'Unknown error deleting location');
            }
            location.reload();
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting location: ' + error.message);
        });
    }
}
</script>
