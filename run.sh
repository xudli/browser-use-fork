#!/bin/bash

# Browser-Use MCP HTTP Server Docker Management Script

set -e

COMPOSE_FILE="docker-compose.yml"
SERVICE_NAME="browser-use-mcp-http"

# Check for docker-compose command availability
if command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    echo "❌ Error: Neither 'docker-compose' nor 'docker compose' command found."
    echo "Please install Docker Compose or use Docker Desktop."
    exit 1
fi

case "$1" in
    "start")
        echo "🚀 Starting browser-use MCP HTTP server..."
        $DOCKER_COMPOSE up -d
        echo "✅ Server started! Access it at: http://localhost:3000/mcp/"
        echo "📊 Check status with: ./run.sh status"
        echo "📋 View logs with: ./run.sh logs"
        ;;
    "stop")
        echo "🛑 Stopping browser-use MCP HTTP server..."
        $DOCKER_COMPOSE down
        echo "✅ Server stopped!"
        ;;
    "restart")
        echo "🔄 Restarting browser-use MCP HTTP server..."
        $DOCKER_COMPOSE down
        $DOCKER_COMPOSE up -d
        echo "✅ Server restarted!"
        ;;
    "build")
        echo "🏗️ Building browser-use MCP HTTP server image..."
        $DOCKER_COMPOSE build
        echo "✅ Build completed!"
        ;;
    "logs")
        echo "📋 Showing logs for browser-use MCP HTTP server..."
        $DOCKER_COMPOSE logs -f $SERVICE_NAME
        ;;
    "status")
        echo "📊 Checking browser-use MCP HTTP server status..."
        $DOCKER_COMPOSE ps
        echo ""
        echo "🩺 Health check:"
        curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:3000/mcp/ || echo "❌ Server not responding"
        ;;
    "shell")
        echo "🐚 Opening shell in browser-use MCP container..."
        $DOCKER_COMPOSE exec $SERVICE_NAME /bin/bash
        ;;
    "clean")
        echo "🧹 Cleaning up Docker resources..."
        $DOCKER_COMPOSE down -v
        docker system prune -f
        echo "✅ Cleanup completed!"
        ;;
    "test")
        echo "🧪 Testing browser-use MCP HTTP server..."
        echo "Sending initialize request..."
        curl -X POST http://localhost:3000/mcp/ \
          -H "Content-Type: application/json" \
          -H "Accept: application/json, text/event-stream" \
          -d '{
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
              "protocolVersion": "2024-11-05",
              "capabilities": {"tools": {}},
              "clientInfo": {"name": "test-client", "version": "1.0.0"}
            }
          }' | jq . || echo "❌ Test failed or jq not installed"
        ;;
    *)
        echo "📖 Browser-Use MCP HTTP Server Docker Management"
        echo ""
        echo "Usage: $0 {start|stop|restart|build|logs|status|shell|clean|test}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the MCP HTTP server"
        echo "  stop    - Stop the MCP HTTP server"
        echo "  restart - Restart the MCP HTTP server"
        echo "  build   - Build the Docker image"
        echo "  logs    - Show server logs"
        echo "  status  - Check server status and health"
        echo "  shell   - Open shell in container"
        echo "  clean   - Clean up Docker resources"
        echo "  test    - Test server with a sample request"
        echo ""
        echo "Examples:"
        echo "  $0 start          # Start the server"
        echo "  $0 logs           # View logs"
        echo "  $0 test           # Test the API"
        echo ""
        exit 1
        ;;
esac