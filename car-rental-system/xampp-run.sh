#!/bin/bash

echo "=========================================="
echo "   Car Rental System - XAMPP Runner"
echo "=========================================="
echo ""

# Check if XAMPP is running
echo "🔍 Checking XAMPP status..."

# Check if XAMPP processes are running
if pgrep -f "httpd" > /dev/null; then
    echo "✅ XAMPP services are running"
else
    echo "❌ XAMPP services are not running"
    echo "🚀 Please start XAMPP manually"
    echo "💡 Use XAMPP control panel to start Apache and MySQL"
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
    echo "💡 Please start Apache in XAMPP control panel"
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
    echo "💡 Please start MySQL in XAMPP control panel"
    exit 1
fi

echo ""
echo "🎉 XAMPP services are running!"
echo ""
echo "📋 Access URLs:"
if [ "$PORT" = "80" ]; then
    echo "🌐 Application: http://localhost/car-rental-system/public/"
    echo "🗄️  phpMyAdmin: http://localhost/phpmyadmin/"
else
    echo "🌐 Application: http://localhost:8080/car-rental-system/public/"
    echo "🗄️  phpMyAdmin: http://localhost:8080/phpmyadmin/"
fi
echo ""
echo "🔑 Default accounts:"
echo "Admin: admin@carrental.com / admin123"
echo "User: john@example.com / user123"
echo ""
echo "💡 Keep XAMPP running to use the application"
echo "💡 Use XAMPP control panel to start/stop services"
echo ""