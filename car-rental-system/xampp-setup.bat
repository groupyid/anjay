@echo off
chcp 65001 >nul
title Car Rental System - XAMPP Setup

echo ==========================================
echo    Car Rental System - XAMPP Setup
echo ==========================================
echo.

echo 🚀 Setting up application for XAMPP...
echo.

REM Check if XAMPP is installed
if not exist "C:\xampp\htdocs" (
    echo ❌ XAMPP not found. Please install XAMPP first.
    echo 📥 Download from: https://www.apachefriends.org/
    pause
    exit /b 1
)

echo ✅ XAMPP found

REM Get XAMPP htdocs path
set XAMPP_PATH=C:\xampp\htdocs
set APP_NAME=car-rental-system

echo 📁 XAMPP htdocs path: %XAMPP_PATH%
echo 📁 Application name: %APP_NAME%

REM Check if application already exists
if exist "%XAMPP_PATH%\%APP_NAME%" (
    echo ⚠️  Application already exists in XAMPP htdocs
    set /p OVERWRITE="Do you want to overwrite? (y/N): "
    if /i "%OVERWRITE%"=="y" (
        echo 🗑️  Removing existing application...
        rmdir /s /q "%XAMPP_PATH%\%APP_NAME%"
    ) else (
        echo ❌ Setup cancelled
        pause
        exit /b 1
    )
fi

REM Copy application to XAMPP htdocs
echo 📋 Copying application to XAMPP htdocs...
xcopy /E /I /Y "%CD%" "%XAMPP_PATH%\%APP_NAME%"

if %errorlevel% neq 0 (
    echo ❌ Failed to copy application
    pause
    exit /b 1
)

echo ✅ Application copied successfully

REM Update .htaccess for XAMPP
echo ⚙️  Updating .htaccess for XAMPP...
cd /d "%XAMPP_PATH%\%APP_NAME%"

REM Create .htaccess for XAMPP
echo RewriteEngine On > public\.htaccess
echo RewriteCond %%{REQUEST_FILENAME} !-d >> public\.htaccess
echo RewriteCond %%{REQUEST_FILENAME} !-f >> public\.htaccess
echo RewriteRule ^ index.php [L] >> public\.htaccess

echo ✅ .htaccess updated for XAMPP

REM Update environment file
echo 📝 Updating environment configuration...
if exist .env (
    powershell -Command "(Get-Content .env) -replace 'http://localhost/car-rental-system/public/', 'http://localhost/%APP_NAME%/public/' | Set-Content .env"
    echo ✅ Environment configuration updated
)

echo.
echo 🎉 XAMPP setup completed successfully!
echo.
echo 📋 Next steps:
echo 1. Start XAMPP Control Panel
echo 2. Start Apache and MySQL services
echo 3. Open phpMyAdmin: http://localhost/phpmyadmin
echo 4. Create database: car_rental_db
echo 5. Import database.sql file
echo 6. Access application: http://localhost/%APP_NAME%/public/
echo.
echo 🔑 Default accounts:
echo Admin: admin@carrental.com / admin123
echo User: john@example.com / user123
echo.
echo 💡 Make sure mod_rewrite is enabled in Apache
echo.

pause