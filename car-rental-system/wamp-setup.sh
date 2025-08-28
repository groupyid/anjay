#!/bin/bash

echo "=========================================="
echo "   Car Rental System - WAMP Setup"
echo "=========================================="
echo ""

echo "🚀 Setting up application for WAMP..."
echo ""

# Check if WAMP is installed
if [ ! -d "/opt/wamp64/www" ] && [ ! -d "/opt/wamp/www" ]; then
    echo "❌ WAMP not found. Please install WAMP first."
    echo "📥 Download from: https://www.wampserver.com/"
    exit 1
fi

# Determine WAMP path
if [ -d "/opt/wamp64/www" ]; then
    WAMP_PATH="/opt/wamp64/www"
elif [ -d "/opt/wamp/www" ]; then
    WAMP_PATH="/opt/wamp/www"
fi

APP_NAME="car-rental-system"

echo "✅ WAMP found at: $WAMP_PATH"
echo "📁 Application name: $APP_NAME"

# Check if application already exists
if [ -d "$WAMP_PATH/$APP_NAME" ]; then
    echo "⚠️  Application already exists in WAMP www"
    read -p "Do you want to overwrite? (y/N): " OVERWRITE
    if [[ $OVERWRITE =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing application..."
        rm -rf "$WAMP_PATH/$APP_NAME"
    else
        echo "❌ Setup cancelled"
        exit 1
    fi
fi

# Copy application to WAMP www
echo "📋 Copying application to WAMP www..."
cp -r . "$WAMP_PATH/$APP_NAME"

if [ $? -ne 0 ]; then
    echo "❌ Failed to copy application"
    exit 1
fi

echo "✅ Application copied successfully"

# Update .htaccess for WAMP
echo "⚙️  Updating .htaccess for WAMP..."
cd "$WAMP_PATH/$APP_NAME"

# Create .htaccess for WAMP
cat > public/.htaccess << 'EOF'
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^ index.php [L]
EOF

echo "✅ .htaccess updated for WAMP"

# Update environment file
echo "📝 Updating environment configuration..."
if [ -f .env ]; then
    sed -i "s|http://localhost/car-rental-system/public/|http://localhost/$APP_NAME/public/|g" .env
    echo "✅ Environment configuration updated"
fi

# Check if mod_rewrite is enabled
echo "🔍 Checking mod_rewrite status..."
if [ -f "$WAMP_PATH/../bin/apache/apache2.4.*/modules/mod_rewrite.so" ]; then
    echo "✅ mod_rewrite module found"
else
    echo "⚠️  mod_rewrite module not found. Please enable it in WAMP."
fi

echo ""
echo "🎉 WAMP setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Start WAMP (make sure icon is green)"
echo "2. Right-click WAMP icon and enable mod_rewrite"
echo "3. Open phpMyAdmin: http://localhost/phpmyadmin"
echo "4. Create database: car_rental_db"
echo "5. Import database.sql file"
echo "6. Access application: http://localhost/$APP_NAME/public/"
echo ""
echo "🔑 Default accounts:"
echo "Admin: admin@carrental.com / admin123"
echo "User: john@example.com / user123"
echo ""
echo "💡 Make sure mod_rewrite is enabled in WAMP"
echo "💡 WAMP icon should be green (all services running)"
echo ""