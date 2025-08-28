#!/bin/bash

echo "=========================================="
echo "   Car Rental System - Docker Runner"
echo "=========================================="
echo ""

# Check if Docker is running
echo "🔍 Checking Docker status..."

if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running"
    echo "🚀 Please start Docker Desktop or Docker daemon"
    exit 1
fi

echo "✅ Docker is running"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not available"
    echo "💡 Please install docker-compose"
    exit 1
fi

echo "✅ docker-compose is available"

# Check if containers are already running
if docker-compose ps | grep -q "Up"; then
    echo "⚠️  Containers are already running"
    read -p "Do you want to restart? (y/N): " RESTART
    if [[ $RESTART =~ ^[Yy]$ ]]; then
        echo "🔄 Stopping existing containers..."
        docker-compose down
    else
        echo "✅ Using existing containers"
        goto show_status
    fi
fi

# Build and start containers
echo "🚀 Building and starting containers..."
docker-compose up --build -d

if [ $? -ne 0 ]; then
    echo "❌ Failed to start containers"
    exit 1
fi

echo "✅ Containers started successfully"

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are responding
echo "🔍 Checking service status..."

# Check Nginx
if curl -s http://localhost/ > /dev/null; then
    echo "✅ Nginx is responding"
else
    echo "❌ Nginx is not responding"
    echo "💡 Please wait a moment and try again"
fi

# Check MySQL
if docker-compose exec -T db mysqladmin ping -h localhost --silent; then
    echo "✅ MySQL is responding"
else
    echo "❌ MySQL is not responding"
    echo "💡 Please wait a moment and try again"
fi

# Check phpMyAdmin
if curl -s http://localhost:8080/ > /dev/null; then
    echo "✅ phpMyAdmin is responding"
else
    echo "❌ phpMyAdmin is not responding"
    echo "💡 Please wait a moment and try again"
fi

:show_status
echo ""
echo "🎉 Docker services are running!"
echo ""
echo "📋 Access URLs:"
echo "🌐 Application: http://localhost/"
echo "🗄️  phpMyAdmin: http://localhost:8080/"
echo ""
echo "🔑 Default accounts:"
echo "Admin: admin@carrental.com / admin123"
echo "User: john@example.com / user123"
echo ""
echo "📋 Container status:"
docker-compose ps
echo ""
echo "💡 Use 'docker-compose logs' to view logs"
echo "💡 Use 'docker-compose down' to stop services"
echo ""