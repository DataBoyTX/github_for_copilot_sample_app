#!/bin/bash

# Web App Docker - Startup Script
# This script helps with building and running the application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        echo "Please install Docker from: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    print_success "Docker is installed"
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
        exit 1
    fi
    print_success "Docker Compose is installed"
}

# Start containers
start_containers() {
    print_header "Starting Docker Containers"
    
    if docker-compose ps | grep -q "web"; then
        print_info "Containers already running. Stopping first..."
        docker-compose down
    fi
    
    print_info "Building and starting containers..."
    docker-compose up --build -d
    
    print_info "Waiting for services to be ready..."
    sleep 5
    
    # Check if web service is running
    if docker-compose ps web | grep -q "Up"; then
        print_success "Web service is running"
    else
        print_error "Web service failed to start"
        docker-compose logs web
        exit 1
    fi
}

# Check health
check_health() {
    print_header "Checking Application Health"
    
    max_attempts=30
    attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:5000/api/health &> /dev/null; then
            print_success "Application is healthy"
            return 0
        fi
        
        attempt=$((attempt + 1))
        print_info "Waiting for application to be ready... ($attempt/$max_attempts)"
        sleep 1
    done
    
    print_error "Application failed to become healthy"
    return 1
}

# Show status
show_status() {
    print_header "Application Status"
    docker-compose ps
}

# Show info
show_info() {
    print_header "Application Information"
    echo ""
    echo -e "${GREEN}Web Application is running!${NC}"
    echo ""
    echo -e "${BLUE}Access Points:${NC}"
    echo "  Frontend:  http://localhost:5000"
    echo "  API Base:  http://localhost:5000/api"
    echo ""
    echo -e "${BLUE}API Endpoints:${NC}"
    echo "  POST   /api/submit           - Submit new data"
    echo "  GET    /api/submissions      - Get all submissions"
    echo "  GET    /api/submission/<id>  - Get specific submission"
    echo "  GET    /api/health           - Health check"
    echo ""
    echo -e "${BLUE}Useful Commands:${NC}"
    echo "  ./startup.sh stop           - Stop the application"
    echo "  ./startup.sh logs           - View application logs"
    echo "  ./startup.sh restart        - Restart containers"
    echo "  ./startup.sh clean          - Stop and remove all data"
    echo ""
}

# Stop containers
stop_containers() {
    print_header "Stopping Docker Containers"
    docker-compose down
    print_success "Containers stopped"
}

# View logs
show_logs() {
    print_header "Application Logs"
    docker-compose logs -f web
}

# Restart containers
restart_containers() {
    print_header "Restarting Containers"
    docker-compose restart
    print_success "Containers restarted"
}

# Clean everything
clean_all() {
    print_header "Cleaning Up"
    echo -e "${RED}WARNING: This will remove all containers and data${NC}"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        docker-compose down -v
        rm -f data/submissions.db
        print_success "Cleanup complete"
    else
        print_info "Cleanup cancelled"
    fi
}

# Main script
main() {
    case "${1:-start}" in
        start)
            check_prerequisites
            start_containers
            check_health
            show_info
            ;;
        stop)
            stop_containers
            ;;
        restart)
            restart_containers
            ;;
        logs)
            show_logs
            ;;
        status)
            show_status
            ;;
        clean)
            clean_all
            ;;
        *)
            echo "Usage: $0 {start|stop|restart|logs|status|clean}"
            echo ""
            echo "Commands:"
            echo "  start    - Build and start the application (default)"
            echo "  stop     - Stop the application"
            echo "  restart  - Restart containers"
            echo "  logs     - View application logs (streaming)"
            echo "  status   - Show container status"
            echo "  clean    - Stop and remove all data"
            exit 1
            ;;
    esac
}

main "$@"
