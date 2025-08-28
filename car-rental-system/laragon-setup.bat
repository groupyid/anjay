@echo off
chcp 65001 >nul
title Car Rental System - Laragon Setup

echo ==========================================
echo    Car Rental System - Laragon Setup
echo ==========================================
echo.

echo 🚀 Setting up application for Laragon...
echo.

REM Check if Laragon is installed
if not exist "C:\laragon\www" (
    echo ❌ Laragon not found. Please install Laragon first.
    echo 📥 Download from: https://laragon.org/
    pause
    exit /b 1
)

echo ✅ Laragon found

REM Get Laragon www path
set LARAGON_PATH=C:\laragon\www
set APP_NAME=car-rental-system

echo 📁 Laragon www path: %LARAGON_PATH%
echo 📁 Application name: %APP_NAME%

REM Check if application already exists
if exist "%LARAGON_PATH%\%APP_NAME%" (
    echo ⚠️  Application already exists in Laragon www
    set /p OVERWRITE="Do you want to overwrite? (y/N): "
    if /i "%OVERWRITE%"=="y" (
        echo 🗑️  Removing existing application...
        rmdir /s /q "%LARAGON_PATH%\%APP_NAME%"
    ) else (
        echo ❌ Setup cancelled
        pause
        exit /b 1
    )
fi

REM Copy application to Laragon www
echo 📋 Copying application to Laragon www...
xcopy /E /I /Y "%CD%" "%LARAGON_PATH%\%APP_NAME%"

if %errorlevel% neq 0 (
    echo ❌ Failed to copy application
    pause
    exit /b 1
)

echo ✅ Application copied successfully

REM Update .htaccess for Laragon
echo ⚙️  Updating .htaccess for Laragon...
cd /d "%LARAGON_PATH%\%APP_NAME%"

REM Create .htaccess for Laragon
echo RewriteEngine On > public\.htaccess
echo RewriteCond %%{REQUEST_FILENAME} !-d >> public\.htaccess
echo RewriteCond %%{REQUEST_FILENAME} !-f >> public\.htaccess
echo RewriteRule ^ index.php [L] >> public\.htaccess

echo ✅ .htaccess updated for Laragon

REM Update environment file
echo 📝 Updating environment configuration...
if exist .env (
    powershell -Command "(Get-Content .env) -replace 'http://localhost/car-rental-system/public/', 'http://%APP_NAME%.test/' | Set-Content .env"
    echo ✅ Environment configuration updated
)

REM Create virtual host configuration
echo 🌐 Creating virtual host configuration...
echo ^<VirtualHost *:80^> > "%LARAGON_PATH%\..\etc\apache2\sites-enabled\%APP_NAME%.conf"
echo     ServerName %APP_NAME%.test >> "%LARAGON_PATH%\..\etc\apache2\sites-enabled\%APP_NAME%.conf"
echo     DocumentRoot "%LARAGON_PATH%\%APP_NAME%\public" >> "%LARAGON_PATH%\..\etc\apache2\sites-enabled\%APP_NAME%.conf"
echo     ^<Directory "%LARAGON_PATH%\%APP_NAME%\public"^> >> "%LARAGON_PATH%\..\etc\apache2\sites-enabled\%APP_NAME%.conf"
echo         AllowOverride All >> "%LARAGON_PATH%\..\etc\apache2\sites-enabled\%APP_NAME%.conf"
echo         Require all granted >> "%LARAGON_PATH%\..\etc\apache2\sites-enabled\%APP_NAME%.conf"
echo     ^</Directory^> >> "%LARAGON_PATH%\..\etc\apache2\sites-enabled\%APP_NAME%.conf"
echo ^</VirtualHost^> >> "%LARAGON_PATH%\..\etc\apache2\sites-enabled\%APP_NAME%.conf"

echo ✅ Virtual host configuration created

REM Add hosts entry
echo 📝 Adding hosts entry...
echo 127.0.0.1 %APP_NAME%.test >> C:\Windows\System32\drivers\etc\hosts

echo ✅ Hosts entry added

echo.
echo 🎉 Laragon setup completed successfully!
echo.
echo 📋 Next steps:
echo 1. Start Laragon
echo 2. Start Apache and MySQL services
echo 3. Open phpMyAdmin: http://localhost/phpmyadmin
echo 4. Create database: car_rental_db
echo 5. Import database.sql file
echo 6. Access application: http://%APP_NAME%.test/
echo.
echo 🔑 Default accounts:
echo Admin: admin@carrental.com / admin123
echo User: john@example.com / user123
echo.
echo 💡 Make sure mod_rewrite is enabled in Apache
echo 💡 You may need to restart Laragon for changes to take effect
echo.

pause