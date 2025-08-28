#!/bin/bash

echo "=========================================="
echo "   Car Rental System - PHP Server Runner"
echo "=========================================="
echo ""

# Check if PHP is available
echo "🔍 Checking PHP availability..."

if ! command -v php &> /dev/null; then
    echo "❌ PHP is not available"
    echo "💡 Please install PHP 7.4 or higher"
    exit 1
fi

# Check PHP version
PHP_VERSION=$(php -r "echo PHP_VERSION;")
REQUIRED_VERSION="7.4.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PHP_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ PHP version $PHP_VERSION is too old"
    echo "💡 Required: PHP 7.4 or higher"
    exit 1
fi

echo "✅ PHP $PHP_VERSION is available"

# Check if MySQL is available
echo "🔍 Checking MySQL availability..."

if ! command -v mysql &> /dev/null; then
    echo "⚠️  MySQL client is not available"
    echo "💡 Please install MySQL client or use phpMyAdmin"
else
    echo "✅ MySQL client is available"
fi

# Check if database exists
echo "🔍 Checking database connection..."

if [ -f .env ]; then
    source .env
    DB_HOST=${DB_HOST:-localhost}
    DB_USER=${DB_USERNAME:-root}
    DB_PASS=${DB_PASSWORD:-}
    DB_NAME=${DB_DATABASE:-car_rental_db}
    
    if command -v mysql &> /dev/null; then
        if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" 2>/dev/null; then
            echo "✅ Database connection successful"
        else
            echo "❌ Database connection failed"
            echo "💡 Please check your database configuration in .env file"
            echo "💡 Or run the installation script first"
        fi
    fi
else
    echo "⚠️  .env file not found"
    echo "💡 Please run the installation script first"
fi

# Check if required extensions are loaded
echo "🔍 Checking PHP extensions..."

REQUIRED_EXTENSIONS=("pdo" "pdo_mysql" "mbstring" "json" "openssl")

for ext in "${REQUIRED_EXTENSIONS[@]}"; do
    if php -m | grep -q "^$ext$"; then
        echo "✅ $ext extension loaded"
    else
        echo "❌ $ext extension not loaded"
        echo "💡 Please install $ext extension"
    fi
done

echo ""
echo "🚀 Starting PHP built-in server..."
echo ""

# Get current directory
CURRENT_DIR=$(pwd)
PUBLIC_DIR="$CURRENT_DIR/public"

# Check if public directory exists
if [ ! -d "$PUBLIC_DIR" ]; then
    echo "❌ Public directory not found"
    exit 1
fi

echo "📁 Serving from: $PUBLIC_DIR"
echo "🌐 URL: http://localhost:8000"
echo ""
echo "💡 Press Ctrl+C to stop the server"
echo "💡 Make sure your database is running"
echo ""

# Start PHP server
cd "$PUBLIC_DIR"
php -S localhost:8000