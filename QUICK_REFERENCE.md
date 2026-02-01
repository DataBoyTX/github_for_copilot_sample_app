# Quick Reference Guide

## Start Application

```bash
./startup.sh start
```

Then open: http://localhost:5000

## Stop Application

```bash
./startup.sh stop
```

## Common Issues

### "Cannot connect to Docker daemon"
→ Start Docker Desktop or run `sudo systemctl start docker`

### "Port 5000 already in use"
→ Kill process: `lsof -i :5000 | grep LISTEN | awk '{print $2}' | xargs kill -9`

### "Application not responding"
→ View logs: `./startup.sh logs`

## API Quick Commands

```bash
# Health check
curl http://localhost:5000/api/health

# Submit data
curl -X POST http://localhost:5000/api/submit \
  -H "Content-Type: application/json" \
  -d '{"user_name":"John","user_age":30,"event_date":"2026-02-15"}'

# Get all submissions
curl http://localhost:5000/api/submissions

# Get one submission
curl http://localhost:5000/api/submission/1
```

## File Structure

```
web-app-docker/
├── app/app.py              ← Backend logic
├── app/requirements.txt     ← Python dependencies
├── frontend/index.html      ← Form & UI
├── frontend/app.js         ← JavaScript logic
├── docker-compose.yml      ← Container configuration
├── Dockerfile              ← Backend image
├── startup.sh              ← Start/stop script
├── README.md               ← Project overview
├── SETUP_INSTRUCTIONS.md   ← Detailed setup
├── API_TESTING.md          ← API examples
└── data/                   ← Database (auto-created)
```

## Key Features Demonstrated

✓ **Frontend to Backend**: Form submission via fetch API  
✓ **Multiple Input Types**: Text, number, date validation  
✓ **REST API**: JSON request/response handling  
✓ **Database**: SQLite persistence with SQLAlchemy ORM  
✓ **Docker**: Complete containerization with docker-compose  
✓ **CORS**: Cross-origin requests enabled  
✓ **Validation**: Both frontend and backend validation  
✓ **Auto-refresh**: Frontend refreshes submissions every 3 seconds  

## Useful Commands

| Command | Purpose |
|---------|---------|
| `./startup.sh start` | Start application |
| `./startup.sh stop` | Stop application |
| `./startup.sh restart` | Restart containers |
| `./startup.sh logs` | View live logs |
| `./startup.sh status` | Show container status |
| `./startup.sh clean` | Remove all data |
| `docker-compose ps` | List containers |
| `docker-compose logs -f web` | Stream logs |
| `docker volume ls` | List volumes |

## Access Points

| Resource | URL |
|----------|-----|
| Web UI | http://localhost:5000 |
| API Base | http://localhost:5000/api |
| Health Check | http://localhost:5000/api/health |
| Submissions API | http://localhost:5000/api/submissions |

## Default Database Location

`./data/submissions.db` (auto-created, persists across restarts)

## Notes

- First startup takes longer (building images)
- Database is persistent in Docker volume
- Both frontend and backend validation
- Auto-refresh submissions every 3 seconds
- CORS enabled for browser requests
