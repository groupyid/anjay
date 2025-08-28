@echo off
chcp 65001 >nul
title Car Rental System - WAMP Setup

echo ==========================================
echo    Car Rental System - WAMP Setup
echo ==========================================
echo.

echo 🚀 Setting up application for WAMP...
echo.

REM Check if WAMP is installed
if not exist "C:\wamp64\www" (
    if not exist "C:\wamp\www" (
        echo ❌ WAMP not found. Please install WAMP first.
        echo 📥 Download from: https://www.wampserver.com/
        pause
        exit /b 1
    ) else (
        set WAMP_PATH=C:\wamp\www
    )
) else (
    set WAMP_PATH=C:\wamp64\www
)

echo ✅ WAMP found at: %WAMP_PATH%

set APP_NAME=car-rental-system

echo 📁 WAMP www path: %WAMP_PATH%
echo 📁 Application name: %APP_NAME%

REM Check if application already exists
if exist "%WAMP_PATH%\%APP_NAME%" (
    echo ⚠️  Application already exists in WAMP www
    set /p OVERWRITE="Do you want to overwrite? (y/N): "
    if /i "%OVERWRITE%"=="y" (
        echo 🗑️  Removing existing application...
        rmdir /s /q "%WAMP_PATH%\%APP_NAME%"
    ) else (
        echo ❌ Setup cancelled
        pause
        exit /b 1
    )
fi

REM Copy application to WAMP www
echo 📋 Copying application to WAMP www...
xcopy /E /I /Y "%CD%" "%WAMP_PATH%\%APP_NAME%"

if %errorlevel% neq 0 (
    echo ❌ Failed to copy application
    pause
    exit /b 1
)

echo ✅ Application copied successfully

REM Update .htaccess for WAMP
echo ⚙️  Updating .htaccess for WAMP...
cd /d "%WAMP_PATH%\%APP_NAME%"

REM Create .htaccess for WAMP
echo RewriteEngine On > public\.htaccess
echo RewriteCond %%{REQUEST_FILENAME} !-d >> public\.htaccess
echo RewriteCond %%{REQUEST_FILENAME} !-f >> public\.htaccess
echo RewriteRule ^ index.php [L] >> public\.htaccess

echo ✅ .htaccess updated for WAMP

REM Update environment file
echo 📝 Updating environment configuration...
if exist .env (
    powershell -Command "(Get-Content .env) -replace 'http://localhost/car-rental-system/public/', 'http://localhost/%APP_NAME%/public/' | Set-Content .env"
    echo ✅ Environment configuration updated
)

REM Check if mod_rewrite is enabled
echo 🔍 Checking mod_rewrite status...
if exist "%WAMP_PATH%\..\bin\apache\apache2.4.*\modules\mod_rewrite.so" (
    echo ✅ mod_rewrite module found
) else (
    echo ⚠️  mod_rewrite module not found. Please enable it in WAMP.
)

echo.
echo 🎉 WAMP setup completed successfully!
echo.
echo 📋 Next steps:
echo 1. Start WAMP (make sure icon is green)
echo 2. Right-click WAMP icon and enable mod_rewrite
echo 3. Open phpMyAdmin: http://localhost/phpmyadmin
echo 4. Create database: car_rental_db
echo 5. Import database.sql file
echo 6. Access application: http://localhost/%APP_NAME%/public/
echo.
echo 🔑 Default accounts:
echo Admin: admin@carrental.com / admin123
echo User: john@example.com / user123
echo.
echo 💡 Make sure mod_rewrite is enabled in WAMP
echo 💡 WAMP icon should be green (all services running)
echo.

pause