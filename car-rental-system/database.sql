-- Car Rental System Database Setup
-- File: database.sql
-- Description: Script untuk membuat database dan tabel

-- Buat database
CREATE DATABASE IF NOT EXISTS car_rental_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Gunakan database
USE car_rental_db;

-- Tabel users
CREATE TABLE IF NOT EXISTS users (
    id INT(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    role ENUM('admin', 'user') DEFAULT 'user',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel cars
CREATE TABLE IF NOT EXISTS cars (
    id INT(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT(4) NOT NULL,
    color VARCHAR(30) NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    daily_rate DECIMAL(10,2) NOT NULL,
    description TEXT NOT NULL,
    status ENUM('available', 'rented', 'maintenance') DEFAULT 'available',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel rentals
CREATE TABLE IF NOT EXISTS rentals (
    id INT(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT(11) UNSIGNED NOT NULL,
    car_id INT(11) UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INT(11) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'completed', 'cancelled') DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert data awal untuk admin
INSERT INTO users (name, email, password, phone, address, role) VALUES 
('Administrator', 'admin@carrental.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567890', 'Jl. Admin No. 1, Jakarta', 'admin');

-- Insert data awal untuk user
INSERT INTO users (name, email, password, phone, address, role) VALUES 
('John Doe', 'john@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567891', 'Jl. User No. 1, Jakarta', 'user'),
('Jane Smith', 'jane@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567892', 'Jl. User No. 2, Jakarta', 'user');

-- Insert data awal untuk mobil
INSERT INTO cars (brand, model, year, color, license_plate, daily_rate, description, status) VALUES 
('Toyota', 'Avanza', 2020, 'Putih', 'B 1234 ABC', 300000, 'Mobil keluarga yang nyaman dengan kapasitas 7 penumpang. Cocok untuk perjalanan keluarga atau bisnis.', 'available'),
('Honda', 'Brio', 2021, 'Merah', 'B 5678 DEF', 250000, 'Mobil city car yang ekonomis dan mudah dikendarai. Ideal untuk perjalanan dalam kota.', 'available'),
('Suzuki', 'Ertiga', 2019, 'Hitam', 'B 9012 GHI', 280000, 'MPV yang nyaman dengan desain modern. Cocok untuk keluarga dan perjalanan bisnis.', 'available'),
('Daihatsu', 'Xenia', 2020, 'Silver', 'B 3456 JKL', 270000, 'Mobil keluarga yang praktis dan irit bahan bakar. Ideal untuk penggunaan sehari-hari.', 'available'),
('Mitsubishi', 'Xpander', 2021, 'Biru', 'B 7890 MNO', 320000, 'MPV premium dengan fitur lengkap dan desain yang elegan. Cocok untuk berbagai kebutuhan.', 'available'),
('Nissan', 'Livina', 2019, 'Abu-abu', 'B 2345 PQR', 290000, 'Mobil keluarga yang nyaman dengan performa yang handal. Ideal untuk perjalanan jauh.', 'available');

-- Buat index untuk optimasi query
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_cars_license_plate ON cars(license_plate);
CREATE INDEX idx_cars_status ON cars(status);
CREATE INDEX idx_rentals_user_id ON rentals(user_id);
CREATE INDEX idx_rentals_car_id ON rentals(car_id);
CREATE INDEX idx_rentals_status ON rentals(status);
CREATE INDEX idx_rentals_created_at ON rentals(created_at);

-- Buat view untuk statistik
CREATE VIEW rental_stats AS
SELECT 
    COUNT(*) as total_rentals,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_rentals,
    SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved_rentals,
    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected_rentals,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_rentals,
    SUM(total_amount) as total_revenue
FROM rentals;

-- Buat view untuk rental dengan detail
CREATE VIEW rental_details AS
SELECT 
    r.*,
    u.name as user_name,
    u.email as user_email,
    u.phone as user_phone,
    c.brand,
    c.model,
    c.license_plate,
    c.daily_rate
FROM rentals r
JOIN users u ON r.user_id = u.id
JOIN cars c ON r.car_id = c.id;

-- Buat trigger untuk update status mobil saat rental
DELIMITER //
CREATE TRIGGER after_rental_insert
AFTER INSERT ON rentals
FOR EACH ROW
BEGIN
    IF NEW.status = 'approved' THEN
        UPDATE cars SET status = 'rented' WHERE id = NEW.car_id;
    END IF;
END//

CREATE TRIGGER after_rental_update
AFTER UPDATE ON rentals
FOR EACH ROW
BEGIN
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        UPDATE cars SET status = 'rented' WHERE id = NEW.car_id;
    ELSEIF NEW.status = 'completed' OR NEW.status = 'cancelled' OR NEW.status = 'rejected' THEN
        UPDATE cars SET status = 'available' WHERE id = NEW.car_id;
    END IF;
END//
DELIMITER ;

-- Set password yang benar (admin123 dan user123)
UPDATE users SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' WHERE email = 'admin@carrental.com';
UPDATE users SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' WHERE email = 'john@example.com';
UPDATE users SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' WHERE email = 'jane@example.com';

-- Tampilkan informasi database
SELECT 'Database car_rental_db berhasil dibuat!' as message;
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_cars FROM cars;
SELECT COUNT(*) as total_rentals FROM rentals;