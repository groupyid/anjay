#!/bin/bash

echo "=========================================="
echo "   Car Rental System - Development Server"
echo "=========================================="
echo ""

echo "🚀 Starting development server..."
echo "📍 Server will run at: http://localhost:8000"
echo "📁 Document root: public/"
echo ""
echo "⚠️  This is for development only!"
echo "⚠️  Do not use in production!"
echo ""
echo "💡 Press Ctrl+C to stop the server"
echo ""

# Change to script directory
cd "$(dirname "$0")"

# Start PHP built-in server
php -S localhost:8000 -t public/