-- Quick Dummy Data Insert
-- Execute this in pgAdmin or any PostgreSQL client

-- Insert 10 diverse users from different regions
INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id) VALUES
('Budi Jakarta', 'budi.jkt@test.com', '081111111111', 'password123', 'petani', NOW(), '1985-01-01', 'L', 'JAKARTA SELATAN', 31, NULL),
('Sari Bandung', 'sari.bdg@test.com', '081222222222', 'password123', 'petani', NOW(), '1990-02-02', 'P', 'KOTA BANDUNG', 12, 73),
('Ahmad Surabaya', 'ahmad.sby@test.com', '081333333333', 'password123', 'petani', NOW(), '1988-03-03', 'L', 'KOTA SURABAYA', 11, 78),
('Dewi Medan', 'dewi.mdn@test.com', '081444444444', 'password123', 'petani', NOW(), '1992-04-04', 'P', 'KOTA MEDAN', 2, 23),
('Eko Denpasar', 'eko.dps@test.com', '081555555555', 'password123', 'petani', NOW(), '1987-05-05', 'L', 'KOTA DENPASAR', 17, 171),
('Fitri Makassar', 'fitri.mks@test.com', '081666666666', 'password123', 'petani', NOW(), '1991-06-06', 'P', 'KOTA MAKASSAR', 28, 281),
('Hendi Balikpapan', 'hendi.bpp@test.com', '081777777777', 'password123', 'petani', NOW(), '1986-07-07', 'L', 'KOTA BALIKPAPAN', 25, 252),
('Indah Padang', 'indah.pdg@test.com', '081888888888', 'password123', 'petani', NOW(), '1989-08-08', 'P', 'KOTA PADANG', 3, 30),
('Joko Semarang', 'joko.smg@test.com', '081999999999', 'password123', 'petani', NOW(), '1984-09-09', 'L', 'KOTA SEMARANG', 13, 125),
('Kirana Banda Aceh', 'kirana.ba@test.com', '081000000000', 'password123', 'petani', NOW(), '1993-10-10', 'P', 'KOTA BANDA ACEH', 1, 1);

-- Insert chat history
INSERT INTO chat_history (user_id, question, answer, sources, created_at, session_id) 
SELECT 
    u.id,
    'Bagaimana cara menanam ' || 
    CASE u.province_id 
        WHEN 31 THEN 'sayuran di lahan sempit Jakarta?'
        WHEN 12 THEN 'strawberry di dataran tinggi Jawa Barat?'
        WHEN 11 THEN 'tebu di Jawa Timur?'
        WHEN 2 THEN 'durian di Sumatra Utara?'
        WHEN 17 THEN 'subak di Bali?'
        ELSE 'padi di daerah saya?'
    END,
    'Sesuai kondisi wilayah ' || p.name || ', disarankan menggunakan teknik budidaya yang sesuai dengan iklim dan topografi lokal.',
    'Panduan Pertanian Regional',
    NOW(),
    'session_' || LPAD(u.id::text, 3, '0')
FROM "user" u
JOIN province p ON u.province_id = p.id
WHERE u.email LIKE '%@test.com';

-- Check results
SELECT 
    u.name,
    u.region,
    p.name as province,
    r.name as regency,
    COUNT(ch.id) as chat_count
FROM "user" u
LEFT JOIN province p ON u.province_id = p.id
LEFT JOIN regency r ON u.regency_id = r.id
LEFT JOIN chat_history ch ON u.id = ch.user_id
WHERE u.email LIKE '%@test.com'
GROUP BY u.id, u.name, u.region, p.name, r.name
ORDER BY u.id;