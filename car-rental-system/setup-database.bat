@echo off
chcp 65001 >nul
title Car Rental System - Database Setup

echo ==========================================
echo    Car Rental System - Database Setup
echo ==========================================
echo.

echo 🗄️ Setting up database...
echo.

REM Check if .env file exists
if not exist .env (
    echo ❌ .env file not found. Please run install.bat first.
    pause
    exit /b 1
)

echo 📥 Running database migrations...
php spark migrate

if %errorlevel% neq 0 (
    echo ❌ Migration failed
    pause
    exit /b 1
)

echo ✅ Migrations completed successfully

echo.
echo 🌱 Running database seeders...
php spark db:seed UserSeeder

if %errorlevel% neq 0 (
    echo ❌ User seeder failed
    pause
    exit /b 1
)

php spark db:seed CarSeeder

if %errorlevel% neq 0 (
    echo ❌ Car seeder failed
    pause
    exit /b 1
)

echo ✅ Seeders completed successfully

echo.
echo 🎉 Database setup completed!
echo.
echo 📋 Database contains:
echo - 3 users (1 admin, 2 regular users)
echo - 6 sample cars
echo - Sample rental data
echo.
echo 🔑 Default accounts:
echo Admin: admin@carrental.com / admin123
echo User: john@example.com / user123
echo User: jane@example.com / user123
echo.

pause