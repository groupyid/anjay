@echo off
echo ==========================================
echo    Car Rental System - PHP Server Runner
echo ==========================================
echo.

echo 🔍 Checking PHP availability...

REM Check if PHP is available
php -v >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ PHP is not available
    echo 💡 Please install PHP 7.4 or higher
    pause
    exit /b 1
)

REM Get PHP version
for /f "tokens=2" %%i in ('php -r "echo PHP_VERSION;"') do set PHP_VERSION=%%i
echo ✅ PHP %PHP_VERSION% is available

echo 🔍 Checking MySQL availability...

REM Check if MySQL client is available
mysql --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ⚠️ MySQL client is not available
    echo 💡 Please install MySQL client or use phpMyAdmin
) else (
    echo ✅ MySQL client is available
)

echo 🔍 Checking database connection...

REM Check if .env file exists
if exist .env (
    echo ✅ .env file found
    
    REM Check database connection (basic check)
    echo 💡 Database connection check requires manual verification
    echo 💡 Please ensure your database is running
) else (
    echo ⚠️ .env file not found
    echo 💡 Please run the installation script first
)

echo 🔍 Checking PHP extensions...

REM Check required extensions
php -m | findstr "pdo" >nul
if %ERRORLEVEL%==0 (
    echo ✅ pdo extension loaded
) else (
    echo ❌ pdo extension not loaded
)

php -m | findstr "pdo_mysql" >nul
if %ERRORLEVEL%==0 (
    echo ✅ pdo_mysql extension loaded
) else (
    echo ❌ pdo_mysql extension not loaded
)

php -m | findstr "mbstring" >nul
if %ERRORLEVEL%==0 (
    echo ✅ mbstring extension loaded
) else (
    echo ❌ mbstring extension not loaded
)

echo.
echo 🚀 Starting PHP built-in server...
echo.

REM Get current directory
set CURRENT_DIR=%CD%
set PUBLIC_DIR=%CURRENT_DIR%\public

REM Check if public directory exists
if not exist "%PUBLIC_DIR%" (
    echo ❌ Public directory not found
    pause
    exit /b 1
)

echo 📁 Serving from: %PUBLIC_DIR%
echo 🌐 URL: http://localhost:8000
echo.
echo 💡 Press Ctrl+C to stop the server
echo 💡 Make sure your database is running
echo.

REM Start PHP server
cd /d "%PUBLIC_DIR%"
php -S localhost:8000