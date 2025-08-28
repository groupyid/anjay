#!/bin/bash

echo "=========================================="
echo "   Car Rental System - Docker Stop"
echo "=========================================="
echo ""

echo "🛑 Stopping Docker containers..."
echo ""

docker-compose down

if [ $? -ne 0 ]; then
    echo "❌ Failed to stop containers"
    exit 1
fi

echo "✅ Containers stopped successfully"

echo ""
echo "💡 To start containers again, run: ./docker-run.sh"
echo ""