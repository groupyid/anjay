#!/bin/bash

# Car Rental System Installation Script
# Script ini akan membantu setup aplikasi Car Rental System

echo "=========================================="
echo "   Car Rental System - Installation"
echo "=========================================="
echo ""

# Check if PHP is installed
if ! command -v php &> /dev/null; then
    echo "❌ PHP tidak ditemukan. Silakan install PHP terlebih dahulu."
    exit 1
fi

# Check PHP version
PHP_VERSION=$(php -r "echo PHP_VERSION;")
REQUIRED_VERSION="7.4.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PHP_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ PHP version $PHP_VERSION tidak didukung. Minimal PHP 7.4.0"
    exit 1
fi

echo "✅ PHP $PHP_VERSION ditemukan"

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo "❌ MySQL tidak ditemukan. Silakan install MySQL terlebih dahulu."
    exit 1
fi

echo "✅ MySQL ditemukan"

# Check if Composer is installed
if ! command -v composer &> /dev/null; then
    echo "❌ Composer tidak ditemukan. Silakan install Composer terlebih dahulu."
    exit 1
fi

echo "✅ Composer ditemukan"

echo ""
echo "📋 Setup Database"
echo "=================="

# Get database credentials
read -p "Database host [localhost]: " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "Database name [car_rental_db]: " DB_NAME
DB_NAME=${DB_NAME:-car_rental_db}

read -p "Database username [root]: " DB_USER
DB_USER=${DB_USER:-root}

read -s -p "Database password: " DB_PASS
echo ""

# Test database connection
echo "🔍 Testing database connection..."
if mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" -e "SELECT 1;" &> /dev/null; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed"
    exit 1
fi

# Create database if not exists
echo "🗄️ Creating database..."
mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Import database structure
echo "📥 Importing database structure..."
mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" < database.sql

if [ $? -eq 0 ]; then
    echo "✅ Database structure imported successfully"
else
    echo "❌ Failed to import database structure"
    exit 1
fi

# Update database configuration
echo "⚙️ Updating database configuration..."
sed -i "s/'hostname' => 'localhost'/'hostname' => '$DB_HOST'/g" app/Config/Database.php
sed -i "s/'database' => 'car_rental_db'/'database' => '$DB_NAME'/g" app/Config/Database.php
sed -i "s/'username' => 'root'/'username' => '$DB_USER'/g" app/Config/Database.php
sed -i "s/'password' => ''/'password' => '$DB_PASS'/g" app/Config/Database.php

echo "✅ Database configuration updated"

# Install Composer dependencies
echo ""
echo "📦 Installing Composer dependencies..."
composer install --no-dev --optimize-autoloader

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Set permissions
echo "🔐 Setting file permissions..."
chmod -R 755 writable/
chmod -R 755 public/

echo "✅ File permissions set"

# Create .env file
echo "📝 Creating environment file..."
cp env .env

# Update .env with database info
sed -i "s/database.default.hostname = localhost/database.default.hostname = $DB_HOST/g" .env
sed -i "s/database.default.database = car_rental_db/database.default.database = $DB_NAME/g" .env
sed -i "s/database.default.username = root/database.default.username = $DB_USER/g" .env
sed -i "s/database.default.password = /database.default.password = $DB_PASS/g" .env

echo "✅ Environment file created"

# Generate encryption key
echo "🔑 Generating encryption key..."
ENCRYPTION_KEY=$(openssl rand -hex 32)
sed -i "s/your-secret-key-here/$ENCRYPTION_KEY/g" .env

echo "✅ Encryption key generated"

# Update base URL
echo "🌐 Updating base URL..."
read -p "Base URL [http://localhost/car-rental-system/public/]: " BASE_URL
BASE_URL=${BASE_URL:-http://localhost/car-rental-system/public/}
sed -i "s|http://localhost/car-rental-system/public/|$BASE_URL|g" .env

echo "✅ Base URL updated"

echo ""
echo "🎉 Installation completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Configure your web server to point to the 'public' folder"
echo "2. Make sure mod_rewrite is enabled (for Apache)"
echo "3. Access your application at: $BASE_URL"
echo ""
echo "🔑 Default accounts:"
echo "Admin: admin@carrental.com / admin123"
echo "User: john@example.com / user123"
echo ""
echo "📚 For more information, check the README.md file"
echo ""
echo "=========================================="
echo "   Installation Complete!"
echo "=========================================="