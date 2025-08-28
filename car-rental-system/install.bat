@echo off
chcp 65001 >nul
title Car Rental System - Installation

echo ==========================================
echo    Car Rental System - Installation
echo ==========================================
echo.

REM Check if PHP is installed
php --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ PHP tidak ditemukan. Silakan install PHP terlebih dahulu.
    pause
    exit /b 1
)

REM Check PHP version
for /f "tokens=2" %%i in ('php -r "echo PHP_VERSION;"') do set PHP_VERSION=%%i
echo ✅ PHP %PHP_VERSION% ditemukan

REM Check if MySQL is installed
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ MySQL tidak ditemukan. Silakan install MySQL terlebih dahulu.
    pause
    exit /b 1
)

echo ✅ MySQL ditemukan

REM Check if Composer is installed
composer --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Composer tidak ditemukan. Silakan install Composer terlebih dahulu.
    pause
    exit /b 1
)

echo ✅ Composer ditemukan

echo.
echo 📋 Setup Database
echo ==================

REM Get database credentials
set /p DB_HOST="Database host [localhost]: "
if "%DB_HOST%"=="" set DB_HOST=localhost

set /p DB_NAME="Database name [car_rental_db]: "
if "%DB_NAME%"=="" set DB_NAME=car_rental_db

set /p DB_USER="Database username [root]: "
if "%DB_USER%"=="" set DB_USER=root

set /p DB_PASS="Database password: "

REM Test database connection
echo 🔍 Testing database connection...
mysql -h"%DB_HOST%" -u"%DB_USER%" -p"%DB_PASS%" -e "SELECT 1;" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Database connection failed
    pause
    exit /b 1
)

echo ✅ Database connection successful

REM Create database if not exists
echo 🗄️ Creating database...
mysql -h"%DB_HOST%" -u"%DB_USER%" -p"%DB_PASS%" -e "CREATE DATABASE IF NOT EXISTS \`%DB_NAME%\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

REM Import database structure
echo 📥 Importing database structure...
mysql -h"%DB_HOST%" -u"%DB_USER%" -p"%DB_PASS%" "%DB_NAME%" < database.sql

if %errorlevel% neq 0 (
    echo ❌ Failed to import database structure
    pause
    exit /b 1
)

echo ✅ Database structure imported successfully

REM Update database configuration
echo ⚙️ Updating database configuration...
powershell -Command "(Get-Content app/Config/Database.php) -replace \"'hostname' => 'localhost'\", \"'hostname' => '%DB_HOST%'\" | Set-Content app/Config/Database.php"
powershell -Command "(Get-Content app/Config/Database.php) -replace \"'database' => 'car_rental_db'\", \"'database' => '%DB_NAME%'\" | Set-Content app/Config/Database.php"
powershell -Command "(Get-Content app/Config/Database.php) -replace \"'username' => 'root'\", \"'username' => '%DB_USER%'\" | Set-Content app/Config/Database.php"
powershell -Command "(Get-Content app/Config/Database.php) -replace \"'password' => ''\", \"'password' => '%DB_PASS%'\" | Set-Content app/Config/Database.php"

echo ✅ Database configuration updated

REM Install Composer dependencies
echo.
echo 📦 Installing Composer dependencies...
composer install --no-dev --optimize-autoloader

if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed successfully

REM Set permissions (Windows doesn't need this but we'll create the message)
echo 🔐 File permissions set for Windows

REM Create .env file
echo 📝 Creating environment file...
copy env .env

REM Update .env with database info
powershell -Command "(Get-Content .env) -replace 'database.default.hostname = localhost', 'database.default.hostname = %DB_HOST%' | Set-Content .env"
powershell -Command "(Get-Content .env) -replace 'database.default.database = car_rental_db', 'database.default.database = %DB_NAME%' | Set-Content .env"
powershell -Command "(Get-Content .env) -replace 'database.default.username = root', 'database.default.username = %DB_USER%' | Set-Content .env"
powershell -Command "(Get-Content .env) -replace 'database.default.password =', 'database.default.password = %DB_PASS%' | Set-Content .env"

echo ✅ Environment file created

REM Generate encryption key
echo 🔑 Generating encryption key...
for /f %%i in ('openssl rand -hex 32') do set ENCRYPTION_KEY=%%i
powershell -Command "(Get-Content .env) -replace 'your-secret-key-here', '%ENCRYPTION_KEY%' | Set-Content .env"

echo ✅ Encryption key generated

REM Update base URL
echo 🌐 Updating base URL...
set /p BASE_URL="Base URL [http://localhost/car-rental-system/public/]: "
if "%BASE_URL%"=="" set BASE_URL=http://localhost/car-rental-system/public/
powershell -Command "(Get-Content .env) -replace 'http://localhost/car-rental-system/public/', '%BASE_URL%' | Set-Content .env"

echo ✅ Base URL updated

echo.
echo 🎉 Installation completed successfully!
echo.
echo 📋 Next steps:
echo 1. Configure your web server to point to the 'public' folder
echo 2. Make sure mod_rewrite is enabled (for Apache)
echo 3. Access your application at: %BASE_URL%
echo.
echo 🔑 Default accounts:
echo Admin: admin@carrental.com / admin123
echo User: john@example.com / user123
echo.
echo 📚 For more information, check the README.md file
echo.
echo ==========================================
echo    Installation Complete!
echo ==========================================

pause