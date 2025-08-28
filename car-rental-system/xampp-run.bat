@echo off
echo ==========================================
echo    Car Rental System - XAMPP Runner
echo ==========================================
echo.

echo 🔍 Checking XAMPP status...

REM Check if XAMPP processes are running
tasklist /FI "IMAGENAME eq httpd.exe" 2>NUL | find /I /N "httpd.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo ✅ XAMPP services are running
) else (
    echo ❌ XAMPP services are not running
    echo 🚀 Please start XAMPP manually
    echo 💡 Use XAMPP control panel to start Apache and MySQL
    pause
    exit /b 1
)

echo 🌐 Checking Apache status...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost/' -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
if %ERRORLEVEL%==0 (
    echo ✅ Apache is running on port 80
    set PORT=80
) else (
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/' -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
    if %ERRORLEVEL%==0 (
        echo ✅ Apache is running on port 8080
        set PORT=8080
    ) else (
        echo ❌ Apache is not running
        echo 💡 Please start Apache in XAMPP control panel
        pause
        exit /b 1
    )
)

echo 🗄️ Checking MySQL status...
if %PORT%==80 (
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost/phpmyadmin/' -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
) else (
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/phpmyadmin/' -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
)

if %ERRORLEVEL%==0 (
    echo ✅ MySQL is running
) else (
    echo ❌ MySQL is not running
    echo 💡 Please start MySQL in XAMPP control panel
    pause
    exit /b 1
)

echo.
echo 🎉 XAMPP services are running!
echo.
echo 📋 Access URLs:
if %PORT%==80 (
    echo 🌐 Application: http://localhost/car-rental-system/public/
    echo 🗄️ phpMyAdmin: http://localhost/phpmyadmin/
) else (
    echo 🌐 Application: http://localhost:8080/car-rental-system/public/
    echo 🗄️ phpMyAdmin: http://localhost:8080/phpmyadmin/
)
echo.
echo 🔑 Default accounts:
echo Admin: admin@carrental.com / admin123
echo User: john@example.com / user123
echo.
echo 💡 Keep XAMPP running to use the application
echo 💡 Use XAMPP control panel to start/stop services
echo.
pause