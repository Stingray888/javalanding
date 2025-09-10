#!/bin/bash

# Portfolio Landing Page - Build and Run Script
# Usage: ./portfolio.sh [command]
# Commands: build, test, run, stop, clean, help

set -e  # Exit on any error

PROJECT_NAME="microservice-template"
MAIN_CLASS="com.cloudrun.microservicetemplate.MicroserviceTemplateApplication"
PORT=8080

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Maven is installed
check_maven() {
    if ! command -v mvn &> /dev/null; then
        print_error "Maven is not installed or not in PATH"
        print_status "Installing Maven using Homebrew..."
        if command -v brew &> /dev/null; then
            brew install maven
        else
            print_error "Homebrew not found. Please install Maven manually."
            exit 1
        fi
    fi
}

# Function to check if port is in use
check_port() {
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_warning "Port $PORT is already in use"
        return 1
    fi
    return 0
}

# Function to stop running application
stop_app() {
    print_status "Stopping any running instances of the application..."
    
    # Find and kill processes by name
    PIDS=$(pgrep -f "$MAIN_CLASS" 2>/dev/null || true)
    if [ -n "$PIDS" ]; then
        echo "$PIDS" | xargs kill -TERM 2>/dev/null || true
        sleep 2
        # Force kill if still running
        PIDS=$(pgrep -f "$MAIN_CLASS" 2>/dev/null || true)
        if [ -n "$PIDS" ]; then
            echo "$PIDS" | xargs kill -KILL 2>/dev/null || true
        fi
        print_success "Application stopped"
    else
        print_status "No running instances found"
    fi
    
    # Also try to kill by port
    PID_ON_PORT=$(lsof -ti:$PORT 2>/dev/null || true)
    if [ -n "$PID_ON_PORT" ]; then
        kill -TERM $PID_ON_PORT 2>/dev/null || true
        sleep 2
        kill -KILL $PID_ON_PORT 2>/dev/null || true
        print_success "Process on port $PORT stopped"
    fi
}

# Function to build the project
build_project() {
    print_status "Building the project..."
    check_maven
    mvn clean compile
    print_success "Build completed successfully"
}

# Function to run tests
run_tests() {
    print_status "Running tests..."
    check_maven
    mvn test
    print_success "All tests passed"
}

# Function to run the application
run_app() {
    print_status "Starting the portfolio application..."
    check_maven
    
    # Stop any existing instances
    stop_app
    
    # Check if port is available
    if ! check_port; then
        print_error "Cannot start application - port $PORT is in use"
        exit 1
    fi
    
    print_status "Starting application on port $PORT..."
    print_status "Visit http://localhost:$PORT to view your portfolio"
    print_warning "Press Ctrl+C to stop the application"
    
    # Run the application
    mvn exec:java -Dexec.mainClass="$MAIN_CLASS" -Dexec.args="--server.port=$PORT"
}

# Function to run in background
run_background() {
    print_status "Starting the portfolio application in background..."
    check_maven
    
    # Stop any existing instances
    stop_app
    
    # Check if port is available
    if ! check_port; then
        print_error "Cannot start application - port $PORT is in use"
        exit 1
    fi
    
    print_status "Starting application on port $PORT in background..."
    nohup mvn exec:java -Dexec.mainClass="$MAIN_CLASS" -Dexec.args="--server.port=$PORT" > portfolio.log 2>&1 &
    
    # Wait a moment and check if it started
    sleep 3
    if check_port; then
        print_error "Failed to start application"
        exit 1
    else
        print_success "Application started successfully in background"
        print_status "Visit http://localhost:$PORT to view your portfolio"
        print_status "Check portfolio.log for application logs"
        print_status "Use './portfolio.sh stop' to stop the application"
    fi
}

# Function to clean the project
clean_project() {
    print_status "Cleaning the project..."
    check_maven
    mvn clean
    rm -f portfolio.log nohup.out
    print_success "Project cleaned"
}

# Function to show application status
show_status() {
    print_status "Checking application status..."
    
    if ! check_port; then
        print_success "Application is running on port $PORT"
        print_status "Visit http://localhost:$PORT to view your portfolio"
    else
        print_status "Application is not running"
    fi
    
    # Show any running processes
    PIDS=$(pgrep -f "$MAIN_CLASS" 2>/dev/null || true)
    if [ -n "$PIDS" ]; then
        print_status "Found running processes: $PIDS"
    fi
}

# Function to open browser
open_browser() {
    if ! check_port; then
        print_status "Opening portfolio in browser..."
        if command -v open &> /dev/null; then
            open "http://localhost:$PORT"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "http://localhost:$PORT"
        else
            print_status "Please open http://localhost:$PORT in your browser"
        fi
    else
        print_error "Application is not running. Start it first with './portfolio.sh run'"
    fi
}

# Function to show help
show_help() {
    echo "Portfolio Landing Page - Build and Run Script"
    echo ""
    echo "Usage: ./portfolio.sh [command]"
    echo ""
    echo "Commands:"
    echo "  build       - Clean and compile the project"
    echo "  test        - Run all tests"
    echo "  run         - Start the application (foreground)"
    echo "  start       - Start the application in background"
    echo "  stop        - Stop the running application"
    echo "  restart     - Stop and start the application"
    echo "  clean       - Clean build artifacts and logs"
    echo "  status      - Check if application is running"
    echo "  open        - Open the portfolio in browser"
    echo "  logs        - Show application logs (when running in background)"
    echo "  full        - Run full build, test, and start sequence"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./portfolio.sh build      # Build the project"
    echo "  ./portfolio.sh test       # Run tests"
    echo "  ./portfolio.sh run        # Start in foreground"
    echo "  ./portfolio.sh start      # Start in background"
    echo "  ./portfolio.sh stop       # Stop the application"
    echo ""
    echo "The portfolio will be available at: http://localhost:$PORT"
}

# Function to show logs
show_logs() {
    if [ -f "portfolio.log" ]; then
        print_status "Showing application logs (press Ctrl+C to exit)..."
        tail -f portfolio.log
    else
        print_warning "No log file found. Application might not be running in background."
    fi
}

# Function to run full sequence
run_full() {
    print_status "Running full build, test, and start sequence..."
    build_project
    run_tests
    run_background
    print_success "Full sequence completed successfully"
}

# Main script logic
case "${1:-help}" in
    build)
        build_project
        ;;
    test)
        run_tests
        ;;
    run)
        run_app
        ;;
    start)
        run_background
        ;;
    stop)
        stop_app
        ;;
    restart)
        stop_app
        run_background
        ;;
    clean)
        clean_project
        ;;
    status)
        show_status
        ;;
    open)
        open_browser
        ;;
    logs)
        show_logs
        ;;
    full)
        run_full
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
