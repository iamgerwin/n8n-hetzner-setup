#!/bin/bash

# n8n Logs Script - View logs for all services

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"

cd "$PROJECT_DIR"

SERVICE=${1:-all}

case $SERVICE in
  all)
    echo "=== All n8n Services Logs ==="
    docker-compose logs -f
    ;;
  n8n)
    echo "=== n8n Main Service Logs ==="
    docker-compose logs -f n8n
    ;;
  worker)
    echo "=== n8n Worker Service Logs ==="
    docker-compose logs -f n8n-worker
    ;;
  postgres)
    echo "=== PostgreSQL Service Logs ==="
    docker-compose logs -f postgres
    ;;
  redis)
    echo "=== Redis Service Logs ==="
    docker-compose logs -f redis
    ;;
  traefik)
    echo "=== Traefik Service Logs ==="
    docker-compose logs -f traefik
    ;;
  *)
    echo "Usage: logs.sh [service]"
    echo ""
    echo "Services:"
    echo "  all        - All services (default)"
    echo "  n8n        - n8n main service"
    echo "  worker     - n8n worker service"
    echo "  postgres   - PostgreSQL database"
    echo "  redis      - Redis cache"
    echo "  traefik    - Traefik reverse proxy"
    ;;
esac
