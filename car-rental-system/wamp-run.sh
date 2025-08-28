#!/bin/bash

echo "=========================================="
echo "   Car Rental System - WAMP Runner"
echo "=========================================="
echo ""

# Check if WAMP is running
echo "🔍 Checking WAMP status..."

# Check if WAMP processes are running
if pgrep -f "wamp" > /dev/null || pgrep -f "apache" > /dev/null; then
    echo "✅ WAMP services are running"
else
    echo "❌ WAMP services are not running"
    echo "🚀 Please start WAMP manually"
    echo "💡 Look for WAMP icon in system tray (Windows) or start services manually"
    exit 1
fi

# Check Apache status
echo "🌐 Checking Apache status..."
if curl -s http://localhost/ > /dev/null; then
    echo "✅ Apache is running on port 80"
elif curl -s http://localhost:8080/ > /dev/null; then
    echo "✅ Apache is running on port 8080"
else
    echo "❌ Apache is not running"
    echo "💡 Please start Apache in WAMP"
    exit 1
fi

# Check MySQL status
echo "🗄️  Checking MySQL status..."
if curl -s http://localhost/phpmyadmin/ > /dev/null; then
    echo "✅ MySQL is running on port 80"
elif curl -s http://localhost:8080/phpmyadmin/ > /dev/null; then
    echo "✅ MySQL is running on port 8080"
else
    echo "❌ MySQL is not running"
    echo "💡 Please start MySQL in WAMP"
    exit 1
fi

# Determine port
PORT=""
if curl -s http://localhost/ > /dev/null; then
    PORT="80"
elif curl -s http://localhost:8080/ > /dev/null; then
    PORT="8080"
fi

echo ""
echo "🎉 WAMP services are running!"
echo ""
echo "📋 Access URLs:"
if [ "$PORT" = "80" ]; then
    echo "🌐 Application: http://localhost/car-rental-system/public/"
    echo "🗄️  phpMyAdmin: http://localhost/phpmyadmin/"
else
    echo "🌐 Application: http://localhost:$PORT/car-rental-system/public/"
    echo "🗄️  phpMyAdmin: http://localhost:$PORT/phpmyadmin/"
fi
echo ""
echo "🔑 Default accounts:"
echo "Admin: admin@carrental.com / admin123"
echo "User: john@example.com / user123"
echo ""
echo "💡 Keep WAMP running to use the application"
echo "💡 Use WAMP system tray icon to start/stop services"
echo ""