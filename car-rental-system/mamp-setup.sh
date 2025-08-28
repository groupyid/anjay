#!/bin/bash

echo "=========================================="
echo "   Car Rental System - MAMP Setup"
echo "=========================================="
echo ""

echo "🚀 Setting up application for MAMP..."
echo ""

# Check if MAMP is installed
if [ ! -d "/Applications/MAMP/htdocs" ]; then
    echo "❌ MAMP not found. Please install MAMP first."
    echo "📥 Download from: https://www.mamp.info/"
    exit 1
fi

echo "✅ MAMP found"

# Get MAMP htdocs path
MAMP_PATH="/Applications/MAMP/htdocs"
APP_NAME="car-rental-system"

echo "📁 MAMP htdocs path: $MAMP_PATH"
echo "📁 Application name: $APP_NAME"

# Check if application already exists
if [ -d "$MAMP_PATH/$APP_NAME" ]; then
    echo "⚠️  Application already exists in MAMP htdocs"
    read -p "Do you want to overwrite? (y/N): " OVERWRITE
    if [[ $OVERWRITE =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing application..."
        rm -rf "$MAMP_PATH/$APP_NAME"
    else
        echo "❌ Setup cancelled"
        exit 1
    fi
fi

# Copy application to MAMP htdocs
echo "📋 Copying application to MAMP htdocs..."
cp -r . "$MAMP_PATH/$APP_NAME"

if [ $? -ne 0 ]; then
    echo "❌ Failed to copy application"
    exit 1
fi

echo "✅ Application copied successfully"

# Update .htaccess for MAMP
echo "⚙️  Updating .htaccess for MAMP..."
cd "$MAMP_PATH/$APP_NAME"

# Create .htaccess for MAMP
cat > public/.htaccess << 'EOF'
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^ index.php [L]
EOF

echo "✅ .htaccess updated for MAMP"

# Update environment file
echo "📝 Updating environment configuration..."
if [ -f .env ]; then
    sed -i "s|http://localhost/car-rental-system/public/|http://localhost:8888/$APP_NAME/public/|g" .env
    echo "✅ Environment configuration updated"
fi

# Check if mod_rewrite is enabled
echo "🔍 Checking mod_rewrite status..."
if [ -f "$MAMP_PATH/../bin/apache/conf/httpd.conf" ]; then
    if grep -q "mod_rewrite" "$MAMP_PATH/../bin/apache/conf/httpd.conf"; then
        echo "✅ mod_rewrite module found"
    else
        echo "⚠️  mod_rewrite module not found. Please enable it in MAMP."
    fi
fi

echo ""
echo "🎉 MAMP setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Start MAMP"
echo "2. Start Apache and MySQL services"
echo "3. Open phpMyAdmin: http://localhost:8888/phpMyAdmin/"
echo "4. Create database: car_rental_db"
echo "5. Import database.sql file"
echo "6. Access application: http://localhost:8888/$APP_NAME/public/"
echo ""
echo "🔑 Default accounts:"
echo "Admin: admin@carrental.com / admin123"
echo "User: john@example.com / user123"
echo ""
echo "💡 Make sure mod_rewrite is enabled in MAMP"
echo "💡 MAMP services should be running (green indicators)"
echo ""