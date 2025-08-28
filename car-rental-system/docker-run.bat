@echo off
chcp 65001 >nul
title Car Rental System - Docker

echo ==========================================
echo    Car Rental System - Docker
echo ==========================================
echo.

echo 🐳 Starting application with Docker...
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

echo ✅ Docker is running

REM Build and start containers
echo 🚀 Building and starting containers...
docker-compose up --build -d

if %errorlevel% neq 0 (
    echo ❌ Failed to start containers
    pause
    exit /b 1
)

echo ✅ Containers started successfully

echo.
echo 🌐 Application URLs:
echo - Main App: http://localhost:8000
echo - phpMyAdmin: http://localhost:8080
echo.
echo 📋 Database Info:
echo - Host: localhost
echo - Port: 3306
echo - Database: car_rental_db
echo - Username: car_rental_user
echo - Password: car_rental_password
echo.
echo 💡 To stop containers, run: docker-compose down
echo 💡 To view logs, run: docker-compose logs -f
echo.

pause