#!/bin/bash

# Simple Docker Compose command aliases with smart platform detection

# Function to run docker-start.sh with platform detection
smart_compose() {
    ./docker-start.sh "$@"
}

# Common operations
alias docker-up='smart_compose up -d'
alias docker-down='smart_compose down'
alias docker-logs='smart_compose logs'
alias docker-status='smart_compose ps'
alias docker-build='smart_compose build'
alias docker-rebuild='smart_compose build --no-cache && smart_compose up -d'

# Print available commands
echo "🏥 MedraN Medical AI Assistant Docker Commands Available:"
echo "  docker-up       - Start all services with platform detection"
echo "  docker-down     - Stop all services"  
echo "  docker-logs     - View service logs"
echo "  docker-status   - Show service status"
echo "  docker-build    - Build services"
echo "  docker-rebuild  - Rebuild and restart services"
echo ""
echo "💡 Examples:"
echo "  docker-up                    # Start with auto-detection"
echo "  ./docker-start.sh up -d      # Direct smart launcher"
echo "  ./docker-start.sh logs api   # View API logs"
