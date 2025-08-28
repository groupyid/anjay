@echo off
echo ==========================================
echo    Car Rental System - MAMP Runner
echo ==========================================
echo.

echo 🔍 Checking MAMP status...

REM Check if MAMP is running
tasklist /FI "IMAGENAME eq MAMP.exe" 2>NUL | find /I /N "MAMP.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo ✅ MAMP is running
) else (
    echo ❌ MAMP is not running
    echo 🚀 Starting MAMP...
    start "" "C:\MAMP\MAMP.exe"
    echo ⏳ Waiting for MAMP to start...
    timeout /t 10 /nobreak >nul
)

echo 🌐 Checking Apache status...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8888/' -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
if %ERRORLEVEL%==0 (
    echo ✅ Apache is running on port 8888
) else (
    echo ❌ Apache is not running on port 8888
    echo 💡 Please start Apache in MAMP control panel
    pause
    exit /b 1
)

echo 🗄️ Checking MySQL status...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8888/phpMyAdmin/' -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
if %ERRORLEVEL%==0 (
    echo ✅ MySQL is running on port 8888
) else (
    echo ❌ MySQL is not running on port 8888
    echo 💡 Please start MySQL in MAMP control panel
    pause
    exit /b 1
)

echo.
echo 🎉 MAMP services are running!
echo.
echo 📋 Access URLs:
echo 🌐 Application: http://localhost:8888/car-rental-system/public/
echo 🗄️ phpMyAdmin: http://localhost:8888/phpMyAdmin/
echo.
echo 🔑 Default accounts:
echo Admin: admin@carrental.com / admin123
echo User: john@example.com / user123
echo.
echo 💡 Keep MAMP running to use the application
echo 💡 Use MAMP control panel to start/stop services
echo.
pause