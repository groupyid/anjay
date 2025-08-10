-- =====================================================
-- DUMMY DATA SQL SCRIPT
-- Create diverse users from different regions in Indonesia
-- =====================================================

-- Clear existing dummy data (optional - uncomment if needed)
-- DELETE FROM chat_history WHERE user_id IN (SELECT id FROM "user" WHERE name LIKE 'Test %' OR name LIKE 'User %');
-- DELETE FROM "user" WHERE name LIKE 'Test %' OR name LIKE 'User %';

-- =====================================================
-- INSERT DIVERSE DUMMY USERS
-- =====================================================

-- 1. DKI JAKARTA USERS
INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id, latitude, longitude) VALUES
('Budi Santoso', 'budi.jakarta@test.com', '081234567001', 'password123', 'petani', NOW(), '1985-03-15', 'L', 'JAKARTA SELATAN', 31, NULL, -6.2607, 106.8106),
('Sari Wulandari', 'sari.dki@test.com', '081234567002', 'password123', 'petani', NOW(), '1990-07-20', 'P', 'JAKARTA UTARA', 31, NULL, -6.1385, 106.8535),
('Ahmad Rahman', 'ahmad.jakut@test.com', '081234567003', 'password123', 'petani', NOW(), '1988-12-10', 'L', 'JAKARTA TIMUR', 31, NULL, -6.2146, 106.8786);

-- 2. JAWA BARAT USERS  
INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id, latitude, longitude) VALUES
('Dedi Kurniawan', 'dedi.bandung@test.com', '081234567004', 'password123', 'petani', NOW(), '1982-05-25', 'L', 'KOTA BANDUNG', 12, 73, -6.9175, 107.6191),
('Fitri Handayani', 'fitri.bogor@test.com', '081234567005', 'password123', 'petani', NOW(), '1992-09-18', 'P', 'KABUPATEN BOGOR', 12, 80, -6.5950, 106.8229),
('Rizki Pratama', 'rizki.bekasi@test.com', '081234567006', 'password123', 'petani', NOW(), '1987-01-30', 'L', 'KOTA BEKASI', 12, 75, -6.2383, 107.0000),
('Maya Sari', 'maya.cirebon@test.com', '081234567007', 'password123', 'petani', NOW(), '1991-11-08', 'P', 'KABUPATEN CIREBON', 12, 81, -6.7063, 108.5572);

-- 3. JAWA TENGAH USERS
INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id, latitude, longitude) VALUES
('Agus Setiawan', 'agus.semarang@test.com', '081234567008', 'password123', 'petani', NOW(), '1986-04-12', 'L', 'KOTA SEMARANG', 13, 125, -6.9666, 110.4167),
('Indira Putri', 'indira.solo@test.com', '081234567009', 'password123', 'petani', NOW(), '1989-08-22', 'P', 'KOTA SURAKARTA', 13, 126, -7.5677, 110.8281),
('Bambang Wijaya', 'bambang.yogya@test.com', '081234567010', 'password123', 'petani', NOW(), '1984-06-14', 'L', 'KABUPATEN KLATEN', 13, 127, -7.7056, 110.6042);

-- 4. JAWA TIMUR USERS
INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id, latitude, longitude) VALUES
('Hendro Susanto', 'hendro.surabaya@test.com', '081234567011', 'password123', 'petani', NOW(), '1983-02-28', 'L', 'KOTA SURABAYA', 11, 78, -7.2575, 112.7521),
('Ratna Dewi', 'ratna.malang@test.com', '081234567012', 'password123', 'petani', NOW(), '1993-10-05', 'P', 'KOTA MALANG', 11, 79, -7.9666, 112.6326),
('Eko Prasetyo', 'eko.sidoarjo@test.com', '081234567013', 'password123', 'petani', NOW(), '1988-12-19', 'L', 'KABUPATEN SIDOARJO', 11, 158, -7.4386, 112.7178);

-- 5. SUMATRA UTARA USERS
INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id, latitude, longitude) VALUES
('Robert Situmorang', 'robert.medan@test.com', '081234567014', 'password123', 'petani', NOW(), '1985-07-16', 'L', 'KOTA MEDAN', 2, 23, 3.5952, 98.6722),
('Tiurma Manalu', 'tiurma.deli@test.com', '081234567015', 'password123', 'petani', NOW(), '1990-03-12', 'P', 'KABUPATEN DELI SERDANG', 2, 24, 3.4523, 98.7123),
('Parulian Hutabarat', 'parulian.toba@test.com', '081234567016', 'password123', 'petani', NOW(), '1987-09-08', 'L', 'KABUPATEN TOBA SAMOSIR', 2, 25, 2.6523, 99.0612);

-- 6. SUMATRA BARAT USERS
INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id, latitude, longitude) VALUES
('Fadli Rahman', 'fadli.padang@test.com', '081234567017', 'password123', 'petani', NOW(), '1986-05-20', 'L', 'KOTA PADANG', 3, 30, -0.9471, 100.4172),
('Nurhaliza Putri', 'nur.bukittinggi@test.com', '081234567018', 'password123', 'petani', NOW(), '1991-12-03', 'P', 'KOTA BUKITTINGGI', 3, 31, -0.3037, 100.3692),
('Reza Fauzi', 'reza.agam@test.com', '081234567019', 'password123', 'petani', NOW(), '1989-01-25', 'L', 'KABUPATEN AGAM', 3, 32, -0.2317, 100.1581);

-- 7. ACEH USERS
INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id, latitude, longitude) VALUES
('Muhammad Yusuf', 'yusuf.bandaaceh@test.com', '081234567020', 'password123', 'petani', NOW(), '1984-08-11', 'L', 'KOTA BANDA ACEH', 1, 1, 5.5577, 95.3222),
('Cut Nyak Dien', 'cutnyak.acehbesar@test.com', '081234567021', 'password123', 'petani', NOW(), '1992-04-17', 'P', 'KABUPATEN ACEH BESAR', 1, 8, 5.4519, 95.4043),
('Teuku Ahmad', 'teuku.acehtimur@test.com', '081234567022', 'password123', 'petani', NOW(), '1988-11-29', 'L', 'KABUPATEN ACEH TIMUR', 1, 9, 4.7362, 97.6253);

-- 8. BALI USERS
INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id, latitude, longitude) VALUES
('I Wayan Sudana', 'wayan.denpasar@test.com', '081234567023', 'password123', 'petani', NOW(), '1985-02-14', 'L', 'KOTA DENPASAR', 17, 171, -8.6500, 115.2167),
('Ni Kadek Sari', 'kadek.badung@test.com', '081234567024', 'password123', 'petani', NOW(), '1990-06-21', 'P', 'KABUPATEN BADUNG', 17, 172, -8.5069, 115.1776),
('I Made Wirawan', 'made.gianyar@test.com', '081234567025', 'password123', 'petani', NOW(), '1987-10-07', 'L', 'KABUPATEN GIANYAR', 17, 173, -8.5421, 115.3269);

-- 9. SULAWESI SELATAN USERS
INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id, latitude, longitude) VALUES
('Andi Mappanyukki', 'andi.makassar@test.com', '081234567026', 'password123', 'petani', NOW(), '1986-03-19', 'L', 'KOTA MAKASSAR', 28, 281, -5.1477, 119.4327),
('Nurhayati Dg Ngalle', 'nur.gowa@test.com', '081234567027', 'password123', 'petani', NOW(), '1991-07-13', 'P', 'KABUPATEN GOWA', 28, 282, -5.3114, 119.4418),
('Muhammad Akbar', 'akbar.bone@test.com', '081234567028', 'password123', 'petani', NOW(), '1989-12-26', 'L', 'KABUPATEN BONE', 28, 283, -4.7317, 120.2656);

-- 10. KALIMANTAN TIMUR USERS
INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id, latitude, longitude) VALUES
('Hendra Setiawan', 'hendra.samarinda@test.com', '081234567029', 'password123', 'petani', NOW(), '1984-09-23', 'L', 'KOTA SAMARINDA', 25, 251, -0.5022, 117.1536),
('Siti Maryam', 'siti.balikpapan@test.com', '081234567030', 'password123', 'petani', NOW(), '1992-01-18', 'P', 'KOTA BALIKPAPAN', 25, 252, -1.2379, 116.8315),
('Abdul Rahman', 'abdul.kutaikartanegara@test.com', '081234567031', 'password123', 'petani', NOW(), '1988-05-09', 'L', 'KABUPATEN KUTAI KARTANEGARA', 25, 253, -0.2793, 117.1463);

-- =====================================================
-- INSERT CHAT HISTORY FOR DUMMY USERS
-- =====================================================

-- Chat history untuk users dari berbagai daerah
INSERT INTO chat_history (user_id, question, answer, sources, created_at, session_id) VALUES
-- Jakarta users
(1, 'Bagaimana cara menanam padi di lahan sempit?', 'Untuk menanam padi di lahan sempit, Anda bisa menggunakan sistem tabulampot atau pot besar. Pilih varietas padi yang cocok untuk container seperti padi gogo.', 'Petunjuk Teknis Budidaya Padi', NOW(), 'session_001'),
(2, 'Kapan waktu terbaik tanam jagung di Jakarta?', 'Di Jakarta, waktu terbaik menanam jagung adalah awal musim hujan (Oktober-November) atau akhir musim hujan (Maret-April).', 'Kalender Tanam Jakarta', NOW(), 'session_002'),
(3, 'Pupuk apa yang bagus untuk tanaman cabai?', 'Untuk cabai, gunakan pupuk NPK dengan perbandingan 15:15:15 pada fase vegetatif, dan 10:20:20 pada fase generatif.', 'Panduan Budidaya Cabai', NOW(), 'session_003'),

-- Jawa Barat users  
(4, 'Hama apa yang sering menyerang tanaman kentang di Bandung?', 'Di Bandung, hama utama kentang adalah ulat grayak, kutu daun, dan penyakit busuk daun. Gunakan pestisida organik untuk pengendalian.', 'Pengendalian Hama Kentang', NOW(), 'session_004'),
(5, 'Bagaimana cara budidaya strawberry di dataran tinggi Bogor?', 'Strawberry cocok di Bogor dengan ketinggian 800-1200 mdpl. Gunakan mulsa plastik dan sistem irigasi tetes untuk hasil optimal.', 'Budidaya Strawberry Dataran Tinggi', NOW(), 'session_005'),
(6, 'Varietas padi apa yang tahan banjir untuk Bekasi?', 'Untuk daerah rawan banjir seperti Bekasi, gunakan varietas Inpara 1, Inpara 2, atau Inpara 3 yang tahan rendaman.', 'Varietas Padi Tahan Banjir', NOW(), 'session_006'),

-- Aceh users
(20, 'Bagaimana cara budidaya kelapa sawit di Aceh?', 'Kelapa sawit di Aceh cocok ditanam di ketinggian 0-400 mdpl. Pastikan drainase baik dan gunakan bibit unggul bersertifikat.', 'Panduan Kelapa Sawit Aceh', NOW(), 'session_020'),
(21, 'Kapan musim tanam padi terbaik di Aceh Besar?', 'Di Aceh Besar, musim tanam padi terbaik adalah Maret-April dan September-Oktober, sesuai dengan pola hujan lokal.', 'Kalender Tanam Aceh', NOW(), 'session_021'),

-- Bali users
(23, 'Bagaimana sistem subak dalam pertanian Bali?', 'Sistem subak adalah sistem irigasi tradisional Bali yang mengatur pembagian air secara adil dan berkelanjutan untuk sawah.', 'Sistem Subak Bali', NOW(), 'session_023'),
(24, 'Tanaman hortikultura apa yang cocok di Badung?', 'Di Badung cocok tanaman sayuran dataran rendah seperti kangkung, bayam, terong, dan cabai rawit.', 'Hortikultura Bali', NOW(), 'session_024'),

-- Sumatra users
(14, 'Bagaimana cara budidaya durian di Medan?', 'Durian di Medan cocok varietas lokal seperti Durian Ucok. Tanam di tanah gembur dengan drainase baik.', 'Budidaya Durian Sumut', NOW(), 'session_014'),
(17, 'Komoditas unggulan Sumatra Barat apa saja?', 'Komoditas unggulan Sumbar antara lain: rendang (daging), singkong, ubi jalar, dan kopi arabika.', 'Komoditas Unggulan Sumbar', NOW(), 'session_017'),

-- Sulawesi users
(26, 'Bagaimana budidaya rumput laut di Makassar?', 'Rumput laut di Makassar bisa dibudidayakan dengan metode long line di perairan yang jernih dan arus sedang.', 'Budidaya Rumput Laut Sulsel', NOW(), 'session_026'),

-- Kalimantan users
(29, 'Tanaman apa yang cocok di lahan gambut Kalimantan?', 'Di lahan gambut Kalimantan cocok tanaman sagu, kelapa, dan nanas. Perlu pengelolaan air yang baik.', 'Pertanian Lahan Gambut', NOW(), 'session_029');

-- =====================================================
-- SUMMARY STATISTICS
-- =====================================================

-- Check inserted data
SELECT 
    'Total Users Created' as description,
    COUNT(*) as count
FROM "user" 
WHERE email LIKE '%@test.com'

UNION ALL

SELECT 
    'Total Chat Messages',
    COUNT(*)
FROM chat_history 
WHERE user_id IN (SELECT id FROM "user" WHERE email LIKE '%@test.com')

UNION ALL

SELECT 
    'Users by Province',
    COUNT(DISTINCT province_id)
FROM "user" 
WHERE email LIKE '%@test.com' AND province_id IS NOT NULL;

-- Show users by province
SELECT 
    p.name as province_name,
    COUNT(u.id) as user_count,
    STRING_AGG(u.name, ', ') as user_names
FROM "user" u
JOIN province p ON u.province_id = p.id
WHERE u.email LIKE '%@test.com'
GROUP BY p.name
ORDER BY user_count DESC;