@echo off
echo ==========================================
echo    Car Rental System - Laragon Runner
echo ==========================================
echo.

echo 🔍 Checking Laragon status...

REM Check if Laragon processes are running
tasklist /FI "IMAGENAME eq httpd.exe" 2>NUL | find /I /N "httpd.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo ✅ Laragon services are running
) else (
    echo ❌ Laragon services are not running
    echo 🚀 Please start Laragon manually
    echo 💡 Look for Laragon icon in system tray
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
        echo 💡 Please start Apache in Laragon
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
    echo 💡 Please start MySQL in Laragon
    pause
    exit /b 1
)

echo.
echo 🎉 Laragon services are running!
echo.
echo 📋 Access URLs:
if %PORT%==80 (
    echo 🌐 Application: http://car-rental-system.test/
    echo 🗄️ phpMyAdmin: http://localhost/phpmyadmin/
) else (
    echo 🌐 Application: http://car-rental-system.test:8080/
    echo 🗄️ phpMyAdmin: http://localhost:8080/phpmyadmin/
)
echo.
echo 🔑 Default accounts:
echo Admin: admin@carrental.com / admin123
echo User: john@example.com / user123
echo.
echo 💡 Keep Laragon running to use the application
echo 💡 Use Laragon system tray icon to start/stop services
echo 💡 Virtual host: car-rental-system.test
echo.
pause