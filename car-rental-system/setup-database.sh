#!/bin/bash

echo "=========================================="
echo "   Car Rental System - Database Setup"
echo "=========================================="
echo ""

echo "🗄️ Setting up database..."
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please run install.sh first."
    exit 1
fi

echo "📥 Running database migrations..."
php spark migrate

if [ $? -ne 0 ]; then
    echo "❌ Migration failed"
    exit 1
fi

echo "✅ Migrations completed successfully"

echo ""
echo "🌱 Running database seeders..."
php spark db:seed UserSeeder

if [ $? -ne 0 ]; then
    echo "❌ User seeder failed"
    exit 1
fi

php spark db:seed CarSeeder

if [ $? -ne 0 ]; then
    echo "❌ Car seeder failed"
    exit 1
fi

echo "✅ Seeders completed successfully"

echo ""
echo "🎉 Database setup completed!"
echo ""
echo "📋 Database contains:"
echo "- 3 users (1 admin, 2 regular users)"
echo "- 6 sample cars"
echo "- Sample rental data"
echo ""
echo "🔑 Default accounts:"
echo "Admin: admin@carrental.com / admin123"
echo "User: john@example.com / user123"
echo "User: jane@example.com / user123"
echo ""