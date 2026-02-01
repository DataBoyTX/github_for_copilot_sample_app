// API Configuration
const API_BASE_URL = 'http://localhost:5000/api';

// DOM Elements
const form = document.getElementById('submissionForm');
const messageDiv = document.getElementById('message');
const submissionsList = document.getElementById('submissionsList');
const submitBtn = document.getElementById('submitBtn');

// Event Listeners
form.addEventListener('submit', handleFormSubmit);

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadSubmissions();
    // Refresh submissions every 3 seconds
    setInterval(loadSubmissions, 3000);
});

// Handle form submission
async function handleFormSubmit(e) {
    e.preventDefault();
    
    // Get form data
    const userName = document.getElementById('userName').value.trim();
    const userAge = document.getElementById('userAge').value.trim();
    const eventDate = document.getElementById('eventDate').value.trim();
    
    // Validate
    if (!userName || !userAge || !eventDate) {
        showMessage('Please fill in all fields', 'error');
        return;
    }
    
    // Show loading state
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<span class="loading"></span> Submitting...';
    
    try {
        const response = await fetch(`${API_BASE_URL}/submit`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                user_name: userName,
                user_age: parseInt(userAge),
                event_date: eventDate
            })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            showMessage('✓ Submission successful!', 'success');
            form.reset();
            loadSubmissions();
        } else {
            showMessage(`✗ Error: ${data.error}`, 'error');
        }
    } catch (error) {
        showMessage(`✗ Network error: ${error.message}`, 'error');
        console.error('Submission error:', error);
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = 'Submit';
    }
}

// Load and display submissions
async function loadSubmissions() {
    try {
        const response = await fetch(`${API_BASE_URL}/submissions`);
        
        if (!response.ok) {
            throw new Error('Failed to load submissions');
        }
        
        const submissions = await response.json();
        
        if (submissions.length === 0) {
            submissionsList.innerHTML = '<div class="empty-message">No submissions yet. Be the first to submit!</div>';
        } else {
            submissionsList.innerHTML = submissions.map(submission => `
                <div class="submission-item">
                    <h4>👤 ${escapeHtml(submission.user_name)}</h4>
                    <p><strong>Age:</strong> ${submission.user_age} years</p>
                    <p><strong>Event Date:</strong> ${submission.event_date}</p>
                    <p class="timestamp">📅 Submitted: ${submission.submitted_at}</p>
                </div>
            `).join('');
        }
    } catch (error) {
        submissionsList.innerHTML = '<div class="empty-message">Error loading submissions</div>';
        console.error('Load error:', error);
    }
}

// Show message to user
function showMessage(text, type) {
    messageDiv.innerHTML = `<div class="message ${type}">${text}</div>`;
    
    // Auto-hide success messages after 3 seconds
    if (type === 'success') {
        setTimeout(() => {
            messageDiv.innerHTML = '';
        }, 3000);
    }
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
