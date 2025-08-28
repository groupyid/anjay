#!/bin/bash

echo "=========================================="
echo "   Car Rental System - Laragon Setup"
echo "=========================================="
echo ""

echo "🚀 Setting up application for Laragon..."
echo ""

# Check if Laragon is installed
if [ ! -d "/opt/laragon/www" ] && [ ! -d "/Applications/Laragon/www" ]; then
    echo "❌ Laragon not found. Please install Laragon first."
    echo "📥 Download from: https://laragon.org/"
    exit 1
fi

# Determine Laragon path
if [ -d "/opt/laragon/www" ]; then
    LARAGON_PATH="/opt/laragon/www"
elif [ -d "/Applications/Laragon/www" ]; then
    LARAGON_PATH="/Applications/Laragon/www"
fi

APP_NAME="car-rental-system"

echo "✅ Laragon found at: $LARAGON_PATH"
echo "📁 Application name: $APP_NAME"

# Check if application already exists
if [ -d "$LARAGON_PATH/$APP_NAME" ]; then
    echo "⚠️  Application already exists in Laragon www"
    read -p "Do you want to overwrite? (y/N): " OVERWRITE
    if [[ $OVERWRITE =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing application..."
        rm -rf "$LARAGON_PATH/$APP_NAME"
    else
        echo "❌ Setup cancelled"
        exit 1
    fi
fi

# Copy application to Laragon www
echo "📋 Copying application to Laragon www..."
cp -r . "$LARAGON_PATH/$APP_NAME"

if [ $? -ne 0 ]; then
    echo "❌ Failed to copy application"
    exit 1
fi

echo "✅ Application copied successfully"

# Update .htaccess for Laragon
echo "⚙️  Updating .htaccess for Laragon..."
cd "$LARAGON_PATH/$APP_NAME"

# Create .htaccess for Laragon
cat > public/.htaccess << 'EOF'
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^ index.php [L]
EOF

echo "✅ .htaccess updated for Laragon"

# Update environment file
echo "📝 Updating environment configuration..."
if [ -f .env ]; then
    sed -i "s|http://localhost/car-rental-system/public/|http://$APP_NAME.test/|g" .env
    echo "✅ Environment configuration updated"
fi

# Create virtual host configuration
echo "🌐 Creating virtual host configuration..."
VHOST_CONF="$LARAGON_PATH/../etc/apache2/sites-enabled/$APP_NAME.conf"

cat > "$VHOST_CONF" << EOF
<VirtualHost *:80>
    ServerName $APP_NAME.test
    DocumentRoot "$LARAGON_PATH/$APP_NAME/public"
    <Directory "$LARAGON_PATH/$APP_NAME/public">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

echo "✅ Virtual host configuration created"

# Add hosts entry (requires sudo)
echo "📝 Adding hosts entry..."
if command -v sudo &> /dev/null; then
    echo "127.0.0.1 $APP_NAME.test" | sudo tee -a /etc/hosts
    echo "✅ Hosts entry added"
else
    echo "⚠️  Please manually add '127.0.0.1 $APP_NAME.test' to /etc/hosts"
fi

echo ""
echo "🎉 Laragon setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Start Laragon"
echo "2. Start Apache and MySQL services"
echo "3. Open phpMyAdmin: http://localhost/phpmyadmin"
echo "4. Create database: car_rental_db"
echo "5. Import database.sql file"
echo "6. Access application: http://$APP_NAME.test/"
echo ""
echo "🔑 Default accounts:"
echo "Admin: admin@carrental.com / admin123"
echo "User: john@example.com / user123"
echo ""
echo "💡 Make sure mod_rewrite is enabled in Apache"
echo "💡 You may need to restart Laragon for changes to take effect"
echo ""