# Web Application in Docker

A simple web application demonstrating frontend-to-backend communication with user input handling.

## Features

- **JavaScript Frontend**: HTML form with text, number, and date inputs
- **Python Flask Backend**: REST API endpoints for data submission and retrieval
- **SQLite Database**: Persistent storage of user submissions
- **Docker Containerization**: Easy deployment and consistency
- **CORS Support**: Frontend and backend communication
- **Input Validation**: Both client-side and server-side validation

## Project Structure

```
web-app-docker/
├── app/
│   ├── app.py              # Flask application
│   └── requirements.txt     # Python dependencies
├── frontend/
│   ├── index.html          # HTML form and UI
│   └── app.js              # JavaScript logic
├── data/                   # Database storage (volume)
├── Dockerfile              # Docker configuration
├── docker-compose.yml      # Multi-container setup
├── .dockerignore           # Files to exclude from Docker build
└── README.md              # This file
```

## API Endpoints

### POST /api/submit
Submit user information
```json
{
  "user_name": "John Doe",
  "user_age": 30,
  "event_date": "2026-02-01"
}
```
Response: `201 Created` with submission data

### GET /api/submissions
Retrieve all submissions (newest first)
Response: Array of submission objects

### GET /api/submission/<id>
Retrieve a specific submission by ID
Response: Single submission object

### GET /api/health
Health check endpoint
Response: `{"status": "healthy"}`

## Running the Application

### Prerequisites
- Docker
- Docker Compose

### Start the Application

```bash
cd web-app-docker
docker-compose up --build
```

The application will be available at: **http://localhost:5000**

### Stop the Application

```bash
docker-compose down
```

To also remove the database data:
```bash
docker-compose down -v
```

## How It Works

1. **Frontend**: User fills out a form with name, age, and event date
2. **Form Submission**: JavaScript sends data to backend via `fetch` API (JSON)
3. **Backend Processing**: Flask validates and stores data in SQLite
4. **Data Persistence**: Database is stored in a Docker volume (`./data`)
5. **Display**: Frontend fetches all submissions and displays them in real-time (auto-refreshes every 3 seconds)

## Example Usage

1. Open browser to `http://localhost:5000`
2. Fill in the form:
   - Name: "Alice"
   - Age: 25
   - Event Date: 2026-02-15
3. Click "Submit"
4. See your submission appear in the "Recent Submissions" section
5. Submit more entries to build a list

## Validation

### Frontend
- All fields required
- Age: number between 0-150

### Backend
- All fields required
- Age: integer between 0-150
- Date: valid YYYY-MM-DD format
- Name: trimmed string

## Technologies Used

- **Backend**: Flask 2.3.3, Flask-SQLAlchemy 3.0.5, Flask-CORS 4.0.0
- **Database**: SQLite
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Containerization**: Docker, Docker Compose

## GitHub Copilot CLI Integration

This repository is designed to work with the **GitHub Copilot CLI**, a powerful command-line interface for leveraging AI-powered code assistance.

### Installing GitHub Copilot CLI

#### Option 1: Quick Install (Recommended)

Use the provided tarball installation script:

```bash
# Download and run the installation script
chmod +x install_github_copilot_tarball.sh
sudo ./install_github_copilot_tarball.sh
```

The script will:
- Auto-detect your platform (amd64/arm64)
- Download the appropriate tarball for v0.0.400
- Install the binary to `/usr/local/bin/gh`
- Optionally authenticate with GitHub

#### Option 2: Skip Authentication

If you prefer to authenticate manually later:

```bash
sudo ./install_github_copilot_tarball.sh --no-auth
```

Then authenticate when ready:
```bash
gh auth login
```

#### Option 3: Manual Installation

If the script doesn't work for your system:

```bash
# Check GitHub Releases for your platform
# https://github.com/github/copilot-cli/releases

# Download the appropriate tarball for your system
# Extract and install manually
tar -xzf copilot-cli_*.tar.gz
sudo cp gh /usr/local/bin/gh
sudo chmod +x /usr/local/bin/gh
```

### Verifying Installation

```bash
# Check if GitHub Copilot CLI is installed
gh version

# Check authentication status
gh auth status
```

### Using Copilot CLI with This Project

Once installed, you can use Copilot CLI to:

1. **Get help with code explanations:**
   ```bash
   gh copilot explain "cat app/app.py"
   ```

2. **Generate code suggestions:**
   ```bash
   gh copilot suggest "create a flask route to delete submissions"
   ```

3. **Ask general questions:**
   ```bash
   gh copilot ask "how do I add authentication to my flask app"
   ```

### GitHub Copilot CLI Features

- **Slash Commands**: Use `/help`, `/code`, `/explain` in your terminal
- **AI-Powered Assistance**: Get intelligent suggestions for code problems
- **Context-Aware**: Works with your project's code
- **Fast & Efficient**: Get instant assistance without leaving the terminal

For more information:
```bash
gh copilot --help
```

Or visit: https://github.com/github/copilot-cli

## Development Notes

- The Flask app runs in production mode for simplicity. For development, set `FLASK_ENV=development` in docker-compose.yml
- The SQLite database file is stored in a Docker volume for persistence
- Frontend files are mounted as a volume for easy editing
- CORS is enabled to allow frontend requests to backend API
- GitHub Copilot CLI is optional but recommended for enhanced development experience
