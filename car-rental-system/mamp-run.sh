#!/bin/bash

echo "=========================================="
echo "   Car Rental System - MAMP Runner"
echo "=========================================="
echo ""

# Check if MAMP is running
echo "🔍 Checking MAMP status..."

# Check if MAMP processes are running
if pgrep -f "MAMP" > /dev/null; then
    echo "✅ MAMP is running"
else
    echo "❌ MAMP is not running"
    echo "🚀 Starting MAMP..."
    open /Applications/MAMP/MAMP.app
    echo "⏳ Waiting for MAMP to start..."
    sleep 10
fi

# Check Apache status
echo "🌐 Checking Apache status..."
if curl -s http://localhost:8888/ > /dev/null; then
    echo "✅ Apache is running on port 8888"
else
    echo "❌ Apache is not running on port 8888"
    echo "💡 Please start Apache in MAMP control panel"
    exit 1
fi

# Check MySQL status
echo "🗄️  Checking MySQL status..."
if curl -s http://localhost:8888/phpMyAdmin/ > /dev/null; then
    echo "✅ MySQL is running on port 8888"
else
    echo "❌ MySQL is not running on port 8888"
    echo "💡 Please start MySQL in MAMP control panel"
    exit 1
fi

echo ""
echo "🎉 MAMP services are running!"
echo ""
echo "📋 Access URLs:"
echo "🌐 Application: http://localhost:8888/car-rental-system/public/"
echo "🗄️  phpMyAdmin: http://localhost:8888/phpMyAdmin/"
echo ""
echo "🔑 Default accounts:"
echo "Admin: admin@carrental.com / admin123"
echo "User: john@example.com / user123"
echo ""
echo "💡 Keep MAMP running to use the application"
echo "💡 Use MAMP control panel to start/stop services"
echo ""