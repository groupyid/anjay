#!/bin/bash
# Setup pgAdmin Web Interface

echo "🌐 Setting up pgAdmin Web Interface"
echo "====================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose found"

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose-pgadmin.yml down 2>/dev/null || true

# Start pgAdmin
echo "🚀 Starting pgAdmin Web Interface..."
docker-compose -f docker-compose-pgadmin.yml up -d

# Wait for container to be ready
echo "⏳ Waiting for pgAdmin to start..."
sleep 10

# Check if pgAdmin is running
if docker ps | grep -q pgadmin_web; then
    echo "✅ pgAdmin Web Interface is running!"
    echo ""
    echo "🌐 Access pgAdmin at: http://localhost:5050"
    echo "📧 Email: admin@example.com"
    echo "🔑 Password: admin123"
    echo ""
    echo "🔧 Database Connection Settings:"
    echo "   Host: localhost (or host.docker.internal if using Docker)"
    echo "   Port: 5432"
    echo "   Database: your_database_name"
    echo "   Username: your_db_username"
    echo "   Password: your_db_password"
    echo ""
    echo "📊 To add your existing database:"
    echo "   1. Open http://localhost:5050"
    echo "   2. Login with admin@example.com / admin123"
    echo "   3. Right-click 'Servers' → Create → Server"
    echo "   4. Name: 'Anjay Database'"
    echo "   5. Connection tab:"
    echo "      - Host: host.docker.internal"
    echo "      - Port: 5432"
    echo "      - Database: your_database_name"
    echo "      - Username: your_username"
    echo "      - Password: your_password"
    echo ""
else
    echo "❌ Failed to start pgAdmin. Check Docker logs:"
    docker-compose -f docker-compose-pgadmin.yml logs
fi

echo "====================================="