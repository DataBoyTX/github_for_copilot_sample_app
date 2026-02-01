# Setup Instructions

Complete guide to setting up and running the Web Application.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Detailed Setup](#detailed-setup)
4. [Troubleshooting](#troubleshooting)
5. [Manual Setup (Without startup.sh)](#manual-setup-without-startupsh)

## Prerequisites

### Required Software

- **Docker** (version 20.10+)
  - Download: https://www.docker.com/products/docker-desktop
  - Verify: `docker --version`

- **Docker Compose** (version 2.0+)
  - Usually comes with Docker Desktop
  - Verify: `docker-compose --version`

### System Requirements

- **Disk Space**: At least 5GB free
- **Memory**: 4GB RAM recommended
- **OS**: Windows, macOS, or Linux

### For WSL Users (Windows)

If using WSL (Windows Subsystem for Linux):
1. Ensure Docker Desktop is configured to use WSL 2
2. Run commands in your WSL terminal, not Command Prompt
3. You may need to install additional build tools

## Quick Start

### Option 1: Using the Startup Script (Recommended)

```bash
# Navigate to the project directory
cd /path/to/web-app-docker

# Make the script executable (first time only)
chmod +x startup.sh

# Start the application
./startup.sh start

# The script will:
# ✓ Check prerequisites
# ✓ Build Docker images
# ✓ Start containers
# ✓ Verify health
# ✓ Display access information
```

Then open your browser to: **http://localhost:5000**

### Option 2: Using docker-compose (Direct)

```bash
# Navigate to the project directory
cd /path/to/web-app-docker

# Build and start containers
docker-compose up --build -d

# Wait a few seconds for services to start
# Then visit: http://localhost:5000
```

## Detailed Setup

### Step 1: Install Docker

**Windows:**
1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Run the installer
3. Restart your computer
4. Open PowerShell/WSL and verify: `docker --version`

**macOS:**
1. Download Docker Desktop for Mac
2. Drag Docker.app to Applications folder
3. Launch Docker from Applications
4. Verify: `docker --version`

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER
# Logout and login again, or run: newgrp docker
```

### Step 2: Clone or Extract Project

```bash
# If using git:
git clone <repository-url>
cd web-app-docker

# Or if you have the files already
cd /path/to/web-app-docker
```

### Step 3: Create Data Directory

```bash
# Linux/macOS
mkdir -p data

# Windows (PowerShell)
New-Item -Type Directory -Force data
```

### Step 4: Build and Start

```bash
# Option A: Using startup script
chmod +x startup.sh
./startup.sh start

# Option B: Direct docker-compose
docker-compose up --build -d

# Wait 5-10 seconds for services to start
```

### Step 5: Verify Installation

```bash
# Check container status
docker-compose ps

# Test health endpoint
curl http://localhost:5000/api/health

# Open browser
# Navigate to: http://localhost:5000
```

Expected output shows containers as "Up":
```
NAME            COMMAND             SERVICE    STATUS              PORTS
web-app-docker-web-1    "python app.py"   web    Up 5 seconds    0.0.0.0:5000->5000/tcp
```

## Usage

### Access the Application

- **Web UI**: http://localhost:5000
- **API Base**: http://localhost:5000/api

### Common Commands

```bash
# Start application
./startup.sh start

# Stop application
./startup.sh stop

# Restart application
./startup.sh restart

# View live logs
./startup.sh logs

# Check status
./startup.sh status

# Stop and remove all data
./startup.sh clean

# Alternative: Direct docker-compose commands
docker-compose up -d      # Start
docker-compose down       # Stop
docker-compose logs -f    # View logs
docker-compose ps         # Status
docker-compose restart    # Restart
```

### Testing the API

Use curl to test endpoints:

```bash
# Health check
curl http://localhost:5000/api/health

# Submit data
curl -X POST http://localhost:5000/api/submit \
  -H "Content-Type: application/json" \
  -d '{"user_name":"John","user_age":30,"event_date":"2026-02-15"}'

# Get all submissions
curl http://localhost:5000/api/submissions

# Get specific submission
curl http://localhost:5000/api/submission/1
```

See `API_TESTING.md` for comprehensive API testing examples.

## Troubleshooting

### Docker not starting

**Problem**: "Cannot connect to Docker daemon"

**Solution**:
```bash
# Linux: Start Docker service
sudo systemctl start docker

# macOS: Start Docker Desktop from Applications
# Windows: Open Docker Desktop
```

### Port 5000 already in use

**Problem**: "Error response from daemon: bind: address already in use"

**Solution 1**: Find and stop the other application
```bash
# On Linux/macOS
lsof -i :5000
kill -9 <PID>

# On Windows (PowerShell)
Get-Process -Id (Get-NetTCPConnection -LocalPort 5000).OwningProcess | Stop-Process
```

**Solution 2**: Change port in docker-compose.yml
```yaml
services:
  web:
    ports:
      - "8000:5000"  # Change 8000 to any available port
```

### Database not persisting

**Problem**: Data is lost after restart

**Solution**: Ensure data volume exists
```bash
# Check volumes
docker volume ls

# In docker-compose.yml, ensure this section exists:
volumes:
  - ./data:/data
```

### Application won't start

**Problem**: Containers keep restarting

**Solution**: Check logs
```bash
./startup.sh logs
# or
docker-compose logs web
```

Look for specific error messages and fix accordingly.

### WSL-specific issues

**Problem**: Permission denied or network issues

**Solution**:
```bash
# Ensure WSL 2 is set as default
wsl --set-default-version 2

# Restart WSL
wsl --shutdown

# Restart Docker Desktop

# Run commands in WSL terminal
wsl
cd /path/to/web-app-docker
./startup.sh start
```

### "Cannot find module" or import errors

**Problem**: Python dependencies not installed

**Solution**: Rebuild containers
```bash
docker-compose down
docker-compose up --build -d
```

## Manual Setup (Without startup.sh)

If the script doesn't work, use these commands directly:

### Check prerequisites
```bash
docker --version
docker-compose --version
```

### Build images
```bash
docker-compose build
```

### Start containers
```bash
docker-compose up -d
```

### Wait for startup
```bash
sleep 10
```

### Verify health
```bash
curl http://localhost:5000/api/health
```

### View logs
```bash
docker-compose logs
```

### Stop containers
```bash
docker-compose down
```

## Development Mode

To enable hot-reloading for development:

1. Edit `docker-compose.yml`:
```yaml
services:
  web:
    environment:
      - FLASK_ENV=development
```

2. Rebuild and restart:
```bash
docker-compose up --build -d
```

3. Changes to `app/app.py` will auto-reload

## Next Steps

1. **Test the Application**: Visit http://localhost:5000
2. **Read API Documentation**: See `API_TESTING.md`
3. **Explore the Code**:
   - Backend: `app/app.py`
   - Frontend: `frontend/index.html` and `frontend/app.js`
4. **Experiment**: Modify the code and rebuild with `docker-compose up --build`

## Support

For issues or questions:
1. Check logs: `./startup.sh logs`
2. Verify Docker is running: `docker ps`
3. Ensure port 5000 is available
4. Review `API_TESTING.md` for endpoint examples
5. Check `README.md` for project overview
