# Car Rental System - CodeIgniter 4

Sistem penyewaan mobil yang dibangun menggunakan CodeIgniter 4 dengan fitur lengkap untuk admin dan user.

## 🚀 Fitur Utama

### Untuk User:
- ✅ Registrasi dan login user
- ✅ Lihat daftar mobil yang tersedia
- ✅ Detail informasi mobil
- ✅ Sistem pemesanan mobil
- ✅ Riwayat rental pribadi
- ✅ Update profil user

### Untuk Admin:
- ✅ Dashboard admin dengan statistik
- ✅ Kelola data mobil (CRUD)
- ✅ Kelola permintaan rental
- ✅ Approve/reject rental
- ✅ Kelola user
- ✅ Laporan dan statistik

## 🛠️ Teknologi yang Digunakan

- **Backend**: CodeIgniter 4 (PHP Framework)
- **Database**: MySQL
- **Frontend**: Bootstrap 5, Font Awesome
- **JavaScript**: Vanilla JS dengan ES6+
- **CSS**: Custom CSS dengan animasi

## 📋 Persyaratan Sistem

- PHP 7.4 atau lebih tinggi
- MySQL 5.7 atau lebih tinggi
- Web server (Apache/Nginx)
- Composer (untuk dependency management)

## 🚀 Cara Install

### 1. Clone Repository
```bash
git clone <repository-url>
cd car-rental-system
```

### 2. Install Dependencies
```bash
composer install
```

### 3. Setup Database
- Buat database baru dengan nama `car_rental_db`
- Update konfigurasi database di `app/Config/Database.php`
- Jalankan migration:
```bash
php spark migrate
```

### 4. Seed Data Awal
```bash
php spark db:seed UserSeeder
php spark db:seed CarSeeder
```

### 5. Setup Web Server
- Point document root ke folder `public/`
- Pastikan folder `writable/` memiliki permission write

### 6. Akses Aplikasi
- Buka browser dan akses aplikasi
- Login dengan akun demo yang tersedia

## 🔑 Akun Demo

### Admin:
- **Email**: admin@carrental.com
- **Password**: admin123

### User:
- **Email**: john@example.com
- **Password**: user123

## 📁 Struktur Folder

```
car-rental-system/
├── app/
│   ├── Config/          # Konfigurasi aplikasi
│   ├── Controllers/     # Controller untuk logic bisnis
│   ├── Database/        # Migration dan seeder
│   ├── Models/          # Model untuk database
│   └── Views/           # Template view
├── public/              # Asset publik (CSS, JS, Images)
├── writable/            # Folder untuk cache, logs, uploads
└── index.php            # Entry point aplikasi
```

## 🗄️ Struktur Database

### Tabel `users`
- id, name, email, password, phone, address, role, created_at, updated_at

### Tabel `cars`
- id, brand, model, year, color, license_plate, daily_rate, description, status, created_at, updated_at

### Tabel `rentals`
- id, user_id, car_id, start_date, end_date, total_days, total_amount, status, created_at, updated_at

## 🔧 Konfigurasi

### Database
Update file `app/Config/Database.php`:
```php
'hostname' => 'localhost',
'username' => 'your_username',
'password' => 'your_password',
'database' => 'car_rental_db',
```

### App
Update file `app/Config/App.php` sesuai kebutuhan:
- Timezone
- Locale
- App name

## 📱 Fitur Responsif

Aplikasi sudah responsive dan dapat diakses dari berbagai device:
- Desktop
- Tablet
- Mobile

## 🎨 Customization

### CSS
- File utama: `public/css/style.css`
- Menggunakan CSS custom dengan animasi
- Support dark theme (opsional)

### JavaScript
- File utama: `public/js/script.js`
- Vanilla JavaScript ES6+
- Fitur interaktif dan validasi form

## 🔒 Keamanan

- Password hashing dengan `password_hash()`
- CSRF protection
- Input validation dan sanitization
- Session management
- Role-based access control

## 📊 Monitoring

- Log aktivitas user
- Statistik rental
- Laporan bulanan
- Dashboard admin real-time

## 🚀 Deployment

### Production
1. Set `ENVIRONMENT = 'production'` di `.env`
2. Disable debug mode
3. Optimize autoloader
4. Setup caching
5. Configure web server

### Staging
1. Set `ENVIRONMENT = 'staging'`
2. Enable error reporting
3. Setup logging

## 🐛 Troubleshooting

### Common Issues:

1. **Permission Error**
   ```bash
   chmod -R 755 writable/
   ```

2. **Database Connection Error**
   - Check database credentials
   - Ensure MySQL service is running

3. **404 Error**
   - Check `.htaccess` file
   - Verify mod_rewrite is enabled

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

Untuk bantuan dan support:
- Email: support@carrental.com
- Documentation: [Link Documentation]
- Issues: [GitHub Issues]

## 🔄 Changelog

### Version 1.0.0
- Initial release
- Basic CRUD operations
- User authentication
- Admin dashboard
- Rental system

---

**Dibuat dengan ❤️ menggunakan CodeIgniter 4**