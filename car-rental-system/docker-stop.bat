@echo off
chcp 65001 >nul
title Car Rental System - Docker Stop

echo ==========================================
echo    Car Rental System - Docker Stop
echo ==========================================
echo.

echo 🛑 Stopping Docker containers...
echo.

docker-compose down

if %errorlevel% neq 0 (
    echo ❌ Failed to stop containers
    pause
    exit /b 1
)

echo ✅ Containers stopped successfully

echo.
echo 💡 To start containers again, run: docker-run.bat
echo.

pause