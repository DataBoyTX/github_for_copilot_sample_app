# API Testing Guide

This guide shows how to test the Web Application API using curl commands.

## Prerequisites

Make sure the application is running:
```bash
./startup.sh start
```

## Health Check

Test if the application is running:

```bash
curl http://localhost:5000/api/health
```

Expected response:
```json
{
  "status": "healthy"
}
```

## Submit Data

### Example 1: Submit a simple entry

```bash
curl -X POST http://localhost:5000/api/submit \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "John Doe",
    "user_age": 30,
    "event_date": "2026-02-15"
  }'
```

Expected response (201 Created):
```json
{
  "message": "Submission successful",
  "submission": {
    "id": 1,
    "user_name": "John Doe",
    "user_age": 30,
    "event_date": "2026-02-15",
    "submitted_at": "2026-02-01 12:34:56"
  }
}
```

### Example 2: Submit multiple entries

```bash
# Entry 2
curl -X POST http://localhost:5000/api/submit \
  -H "Content-Type: application/json" \
  -d '{"user_name": "Jane Smith", "user_age": 25, "event_date": "2026-03-20"}'

# Entry 3
curl -X POST http://localhost:5000/api/submit \
  -H "Content-Type: application/json" \
  -d '{"user_name": "Bob Johnson", "user_age": 45, "event_date": "2026-01-10"}'
```

### Example 3: Invalid data (age out of range)

```bash
curl -X POST http://localhost:5000/api/submit \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "Invalid Person",
    "user_age": 200,
    "event_date": "2026-02-15"
  }'
```

Expected response (400 Bad Request):
```json
{
  "error": "Age must be between 0 and 150"
}
```

### Example 4: Missing required field

```bash
curl -X POST http://localhost:5000/api/submit \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "Incomplete User",
    "user_age": 30
  }'
```

Expected response (400 Bad Request):
```json
{
  "error": "Missing required fields"
}
```

### Example 5: Invalid date format

```bash
curl -X POST http://localhost:5000/api/submit \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "Bad Date User",
    "user_age": 30,
    "event_date": "02/15/2026"
  }'
```

Expected response (400 Bad Request):
```json
{
  "error": "Invalid date format. Use YYYY-MM-DD"
}
```

## Retrieve All Submissions

Get all submissions (sorted by newest first):

```bash
curl http://localhost:5000/api/submissions
```

Expected response (200 OK):
```json
[
  {
    "id": 3,
    "user_name": "Bob Johnson",
    "user_age": 45,
    "event_date": "2026-01-10",
    "submitted_at": "2026-02-01 12:36:15"
  },
  {
    "id": 2,
    "user_name": "Jane Smith",
    "user_age": 25,
    "event_date": "2026-03-20",
    "submitted_at": "2026-02-01 12:35:42"
  },
  {
    "id": 1,
    "user_name": "John Doe",
    "user_age": 30,
    "event_date": "2026-02-15",
    "submitted_at": "2026-02-01 12:34:56"
  }
]
```

## Retrieve Single Submission

Get a specific submission by ID:

```bash
curl http://localhost:5000/api/submission/1
```

Expected response (200 OK):
```json
{
  "id": 1,
  "user_name": "John Doe",
  "user_age": 30,
  "event_date": "2026-02-15",
  "submitted_at": "2026-02-01 12:34:56"
}
```

### Non-existent submission

```bash
curl http://localhost:5000/api/submission/999
```

Expected response (404 Not Found):
```json
{
  "error": "Submission not found"
}
```

## Bulk Testing Script

Save this as `test_api.sh` to test multiple scenarios:

```bash
#!/bin/bash

BASE_URL="http://localhost:5000/api"

echo "=== Health Check ==="
curl $BASE_URL/health | jq .

echo -e "\n=== Submitting Data ==="
curl -X POST $BASE_URL/submit \
  -H "Content-Type: application/json" \
  -d '{"user_name": "Test User", "user_age": 28, "event_date": "2026-02-10"}' | jq .

echo -e "\n=== Getting All Submissions ==="
curl $BASE_URL/submissions | jq .

echo -e "\n=== Getting First Submission ==="
curl $BASE_URL/submission/1 | jq .

echo -e "\n=== Error Test: Invalid Age ==="
curl -X POST $BASE_URL/submit \
  -H "Content-Type: application/json" \
  -d '{"user_name": "Bad Age", "user_age": 999, "event_date": "2026-02-10"}' | jq .

echo -e "\n=== Error Test: Missing Field ==="
curl -X POST $BASE_URL/submit \
  -H "Content-Type: application/json" \
  -d '{"user_name": "Missing Age"}' | jq .
```

Run it with: `chmod +x test_api.sh && ./test_api.sh`

## Response Status Codes

| Code | Meaning | Scenarios |
|------|---------|-----------|
| 200 | OK | Successful GET requests |
| 201 | Created | Successful POST requests |
| 400 | Bad Request | Validation errors, missing fields |
| 404 | Not Found | Submission ID doesn't exist |
| 500 | Server Error | Unexpected server error |

## Tips

- Use `jq` to pretty-print JSON: `curl ... | jq .`
- Use `-v` flag for verbose output: `curl -v http://...`
- Use `-X` to specify HTTP method: `curl -X POST http://...`
- Use `-H` to add headers: `curl -H "Content-Type: application/json" ...`
- Use `-d` for data/body: `curl -d '{"key": "value"}' ...`
