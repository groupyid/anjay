#!/bin/bash

echo "=========================================="
echo "   Car Rental System - XAMPP Setup"
echo "=========================================="
echo ""

echo "🚀 Setting up application for XAMPP..."
echo ""

# Check if XAMPP is installed
if [ ! -d "/opt/lampp/htdocs" ] && [ ! -d "/Applications/XAMPP/htdocs" ]; then
    echo "❌ XAMPP not found. Please install XAMPP first."
    echo "📥 Download from: https://www.apachefriends.org/"
    exit 1
fi

# Determine XAMPP path
if [ -d "/opt/lampp/htdocs" ]; then
    XAMPP_PATH="/opt/lampp/htdocs"
elif [ -d "/Applications/XAMPP/htdocs" ]; then
    XAMPP_PATH="/Applications/XAMPP/htdocs"
fi

APP_NAME="car-rental-system"

echo "✅ XAMPP found at: $XAMPP_PATH"
echo "📁 Application name: $APP_NAME"

# Check if application already exists
if [ -d "$XAMPP_PATH/$APP_NAME" ]; then
    echo "⚠️  Application already exists in XAMPP htdocs"
    read -p "Do you want to overwrite? (y/N): " OVERWRITE
    if [[ $OVERWRITE =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing application..."
        rm -rf "$XAMPP_PATH/$APP_NAME"
    else
        echo "❌ Setup cancelled"
        exit 1
    fi
fi

# Copy application to XAMPP htdocs
echo "📋 Copying application to XAMPP htdocs..."
cp -r . "$XAMPP_PATH/$APP_NAME"

if [ $? -ne 0 ]; then
    echo "❌ Failed to copy application"
    exit 1
fi

echo "✅ Application copied successfully"

# Update .htaccess for XAMPP
echo "⚙️  Updating .htaccess for XAMPP..."
cd "$XAMPP_PATH/$APP_NAME"

# Create .htaccess for XAMPP
cat > public/.htaccess << 'EOF'
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^ index.php [L]
EOF

echo "✅ .htaccess updated for XAMPP"

# Update environment file
echo "📝 Updating environment configuration..."
if [ -f .env ]; then
    sed -i "s|http://localhost/car-rental-system/public/|http://localhost/$APP_NAME/public/|g" .env
    echo "✅ Environment configuration updated"
fi

echo ""
echo "🎉 XAMPP setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Start XAMPP Control Panel"
echo "2. Start Apache and MySQL services"
echo "3. Open phpMyAdmin: http://localhost/phpmyadmin"
echo "4. Create database: car_rental_db"
echo "5. Import database.sql file"
echo "6. Access application: http://localhost/$APP_NAME/public/"
echo ""
echo "🔑 Default accounts:"
echo "Admin: admin@carrental.com / admin123"
echo "User: john@example.com / user123"
echo ""
echo "💡 Make sure mod_rewrite is enabled in Apache"
echo ""