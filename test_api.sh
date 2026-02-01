#!/bin/bash

# API Test Suite
# Tests all endpoints and provides sample data

set -e

BASE_URL="http://localhost:5000/api"
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counter
test_count=0

# Helper functions
print_test_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}TEST $1: $2${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

assert_status_code() {
    local expected=$1
    local actual=$2
    local test_name=$3
    
    if [ "$actual" = "$expected" ]; then
        echo -e "${GREEN}✓ PASS: Status code $actual (expected $expected)${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL: Status code $actual (expected $expected)${NC}"
        ((TESTS_FAILED++))
    fi
}

check_json_field() {
    local response=$1
    local field=$2
    local test_name=$3
    
    if echo "$response" | jq -e ".$field" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS: Field '$field' exists${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL: Field '$field' missing${NC}"
        echo "Response: $response"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Health Check
print_test_header "1" "Health Check Endpoint"

response=$(curl -s -w "\n%{http_code}" "$BASE_URL/health")
status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

assert_status_code "200" "$status_code" "Health check"
check_json_field "$body" "status" "Health status field"
echo "Response: $body"

# Test 2: Submit Valid Entry
print_test_header "2" "Submit Valid Entry"

response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/submit" \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "John Doe",
    "user_age": 30,
    "event_date": "2026-02-15"
  }')

status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

assert_status_code "201" "$status_code" "Valid submission"
check_json_field "$body" "submission" "Submission in response"
check_json_field "$body" "message" "Message in response"
echo "Response: $body"

# Test 3: Submit Second Entry
print_test_header "3" "Submit Another Entry"

response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/submit" \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "Jane Smith",
    "user_age": 25,
    "event_date": "2026-03-20"
  }')

status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

assert_status_code "201" "$status_code" "Second submission"
echo "Response: $body"

# Test 4: Submit Third Entry
print_test_header "4" "Submit Third Entry"

response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/submit" \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "Bob Johnson",
    "user_age": 45,
    "event_date": "2026-01-10"
  }')

status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

assert_status_code "201" "$status_code" "Third submission"
echo "Response: $body"

# Test 5: Get All Submissions
print_test_header "5" "Get All Submissions"

response=$(curl -s -w "\n%{http_code}" "$BASE_URL/submissions")
status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

assert_status_code "200" "$status_code" "Get all submissions"

# Count entries
count=$(echo "$body" | jq 'length')
echo "Found $count submissions"
echo "Response (first 3): $(echo "$body" | jq '.[0:3]')"

if [ "$count" -ge 3 ]; then
    echo -e "${GREEN}✓ PASS: At least 3 submissions returned${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ FAIL: Expected at least 3 submissions, got $count${NC}"
    ((TESTS_FAILED++))
fi

# Test 6: Get Single Submission
print_test_header "6" "Get Single Submission by ID"

response=$(curl -s -w "\n%{http_code}" "$BASE_URL/submission/1")
status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

assert_status_code "200" "$status_code" "Get submission by ID"
check_json_field "$body" "id" "Submission ID"
check_json_field "$body" "user_name" "User name field"
echo "Response: $body"

# Test 7: Get Non-existent Submission
print_test_header "7" "Get Non-existent Submission (404)"

response=$(curl -s -w "\n%{http_code}" "$BASE_URL/submission/99999")
status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

assert_status_code "404" "$status_code" "Non-existent submission"
check_json_field "$body" "error" "Error message"
echo "Response: $body"

# Test 8: Invalid Age (Out of Range)
print_test_header "8" "Invalid Age - Out of Range (400)"

response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/submit" \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "Invalid Age User",
    "user_age": 200,
    "event_date": "2026-02-15"
  }')

status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

assert_status_code "400" "$status_code" "Invalid age validation"
check_json_field "$body" "error" "Error message"
echo "Response: $body"

# Test 9: Invalid Date Format
print_test_header "9" "Invalid Date Format (400)"

response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/submit" \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "Bad Date User",
    "user_age": 30,
    "event_date": "02/15/2026"
  }')

status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

assert_status_code "400" "$status_code" "Invalid date format"
check_json_field "$body" "error" "Error message"
echo "Response: $body"

# Test 10: Missing Required Field
print_test_header "10" "Missing Required Field (400)"

response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/submit" \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "Incomplete User"
  }')

status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

assert_status_code "400" "$status_code" "Missing field validation"
check_json_field "$body" "error" "Error message"
echo "Response: $body"

# Test 11: Empty Name
print_test_header "11" "Empty Name Field (400)"

response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/submit" \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "",
    "user_age": 30,
    "event_date": "2026-02-15"
  }')

status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

assert_status_code "400" "$status_code" "Empty name validation"
echo "Response: $body"

# Summary
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TEST SUMMARY${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

TOTAL=$((TESTS_PASSED + TESTS_FAILED))
PERCENTAGE=$((TESTS_PASSED * 100 / TOTAL))

echo -e "\n${BLUE}Success Rate: $PERCENTAGE% ($TESTS_PASSED/$TOTAL)${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ ALL TESTS PASSED${NC}"
    exit 0
else
    echo -e "\n${RED}✗ SOME TESTS FAILED${NC}"
    exit 1
fi
