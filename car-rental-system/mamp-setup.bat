@echo off
chcp 65001 >nul
title Car Rental System - MAMP Setup

echo ==========================================
echo    Car Rental System - MAMP Setup
echo ==========================================
echo.

echo 🚀 Setting up application for MAMP...
echo.

REM Check if MAMP is installed
if not exist "C:\MAMP\htdocs" (
    echo ❌ MAMP not found. Please install MAMP first.
    echo 📥 Download from: https://www.mamp.info/
    pause
    exit /b 1
)

echo ✅ MAMP found

REM Get MAMP htdocs path
set MAMP_PATH=C:\MAMP\htdocs
set APP_NAME=car-rental-system

echo 📁 MAMP htdocs path: %MAMP_PATH%
echo 📁 Application name: %APP_NAME%

REM Check if application already exists
if exist "%MAMP_PATH%\%APP_NAME%" (
    echo ⚠️  Application already exists in MAMP htdocs
    set /p OVERWRITE="Do you want to overwrite? (y/N): "
    if /i "%OVERWRITE%"=="y" (
        echo 🗑️  Removing existing application...
        rmdir /s /q "%MAMP_PATH%\%APP_NAME%"
    ) else (
        echo ❌ Setup cancelled
        pause
        exit /b 1
    )
fi

REM Copy application to MAMP htdocs
echo 📋 Copying application to MAMP htdocs...
xcopy /E /I /Y "%CD%" "%MAMP_PATH%\%APP_NAME%"

if %errorlevel% neq 0 (
    echo ❌ Failed to copy application
    pause
    exit /b 1
)

echo ✅ Application copied successfully

REM Update .htaccess for MAMP
echo ⚙️  Updating .htaccess for MAMP...
cd /d "%MAMP_PATH%\%APP_NAME%"

REM Create .htaccess for MAMP
echo RewriteEngine On > public\.htaccess
echo RewriteCond %%{REQUEST_FILENAME} !-d >> public\.htaccess
echo RewriteCond %%{REQUEST_FILENAME} !-f >> public\.htaccess
echo RewriteRule ^ index.php [L] >> public\.htaccess

echo ✅ .htaccess updated for MAMP

REM Update environment file
echo 📝 Updating environment configuration...
if exist .env (
    powershell -Command "(Get-Content .env) -replace 'http://localhost/car-rental-system/public/', 'http://localhost:8888/%APP_NAME%/public/' | Set-Content .env"
    echo ✅ Environment configuration updated
)

REM Check if mod_rewrite is enabled
echo 🔍 Checking mod_rewrite status...
if exist "%MAMP_PATH%\..\bin\apache\conf\httpd.conf" (
    findstr "mod_rewrite" "%MAMP_PATH%\..\bin\apache\conf\httpd.conf" >nul
    if %errorlevel% equ 0 (
        echo ✅ mod_rewrite module found
    ) else (
        echo ⚠️  mod_rewrite module not found. Please enable it in MAMP.
    )
)

echo.
echo 🎉 MAMP setup completed successfully!
echo.
echo 📋 Next steps:
echo 1. Start MAMP
echo 2. Start Apache and MySQL services
echo 3. Open phpMyAdmin: http://localhost:8888/phpMyAdmin/
echo 4. Create database: car_rental_db
echo 5. Import database.sql file
echo 6. Access application: http://localhost:8888/%APP_NAME%/public/
echo.
echo 🔑 Default accounts:
echo Admin: admin@carrental.com / admin123
echo User: john@example.com / user123
echo.
echo 💡 Make sure mod_rewrite is enabled in MAMP
echo 💡 MAMP services should be running (green indicators)
echo.

pause