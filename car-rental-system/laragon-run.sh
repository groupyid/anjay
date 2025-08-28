#!/bin/bash

echo "=========================================="
echo "   Car Rental System - Laragon Runner"
echo "=========================================="
echo ""

# Check if Laragon is running
echo "🔍 Checking Laragon status..."

# Check if Laragon processes are running
if pgrep -f "laragon" > /dev/null || pgrep -f "httpd" > /dev/null; then
    echo "✅ Laragon services are running"
else
    echo "❌ Laragon services are not running"
    echo "🚀 Please start Laragon manually"
    echo "💡 Look for Laragon icon in system tray or start services manually"
    exit 1
fi

# Check Apache status
echo "🌐 Checking Apache status..."
if curl -s http://localhost/ > /dev/null; then
    echo "✅ Apache is running on port 80"
    PORT="80"
elif curl -s http://localhost:8080/ > /dev/null; then
    echo "✅ Apache is running on port 8080"
    PORT="8080"
else
    echo "❌ Apache is not running"
    echo "💡 Please start Apache in Laragon"
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
    echo "💡 Please start MySQL in Laragon"
    exit 1
fi

echo ""
echo "🎉 Laragon services are running!"
echo ""
echo "📋 Access URLs:"
if [ "$PORT" = "80" ]; then
    echo "🌐 Application: http://car-rental-system.test/"
    echo "🗄️  phpMyAdmin: http://localhost/phpmyadmin/"
else
    echo "🌐 Application: http://car-rental-system.test:8080/"
    echo "🗄️  phpMyAdmin: http://localhost:8080/phpmyadmin/"
fi
echo ""
echo "🔑 Default accounts:"
echo "Admin: admin@carrental.com / admin123"
echo "User: john@example.com / user123"
echo ""
echo "💡 Keep Laragon running to use the application"
echo "💡 Use Laragon system tray icon to start/stop services"
echo "💡 Virtual host: car-rental-system.test"
echo ""