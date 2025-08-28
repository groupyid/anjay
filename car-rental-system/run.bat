@echo off
chcp 65001 >nul
title Car Rental System - Development Server

echo ==========================================
echo    Car Rental System - Development Server
echo ==========================================
echo.

echo 🚀 Starting development server...
echo 📍 Server will run at: http://localhost:8000
echo 📁 Document root: public/
echo.
echo ⚠️  This is for development only!
echo ⚠️  Do not use in production!
echo.
echo 💡 Press Ctrl+C to stop the server
echo.

cd /d "%~dp0"
php -S localhost:8000 -t public/

pause