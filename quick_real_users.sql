-- Quick Real Users untuk Testing Berbagai Daerah
-- Users dengan nama dan email yang terlihat real

INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id) VALUES
-- Pengguna dari Yogyakarta
('Andi Setiawan', 'andi.setiawan@gmail.com', '081234567001', 'password123', 'petani', NOW() - INTERVAL '30 days', '1985-03-15', 'L', 'YOGYAKARTA', 14, 145),

-- Pengguna dari Surabaya  
('Sinta Dewi', 'sinta.dewi@yahoo.com', '081234567002', 'password123', 'petani', NOW() - INTERVAL '20 days', '1990-07-22', 'P', 'SURABAYA', 11, 155),

-- Pengguna dari Makassar
('Rahman Husein', 'rahman.husein@outlook.com', '081234567003', 'password123', 'petani', NOW() - INTERVAL '15 days', '1988-11-08', 'L', 'MAKASSAR', 28, 281),

-- Pengguna dari Medan
('Lina Sari', 'lina.sari@gmail.com', '081234567004', 'password123', 'petani', NOW() - INTERVAL '10 days', '1992-05-14', 'P', 'MEDAN', 2, 23),

-- Pengguna dari Denpasar, Bali
('I Kadek Wirawan', 'kadek.wirawan@gmail.com', '081234567005', 'password123', 'petani', NOW() - INTERVAL '5 days', '1987-09-30', 'L', 'DENPASAR', 17, 171);

-- Add realistic chat history
INSERT INTO chat_history (user_id, question, answer, sources, created_at, session_id) 
SELECT 
    u.id,
    CASE u.province_id 
        WHEN 14 THEN 'Bagaimana cara menanam singkong di musim kemarau?'
        WHEN 11 THEN 'Kapan waktu yang tepat untuk menanam tebu di Jawa Timur?'
        WHEN 28 THEN 'Bagaimana mengatasi hama pada tanaman kakao di Sulawesi?'
        WHEN 2 THEN 'Jenis pupuk apa yang cocok untuk kelapa sawit muda?'
        WHEN 17 THEN 'Bagaimana cara budidaya padi organik sistem subak?'
    END,
    CASE u.province_id 
        WHEN 14 THEN 'Untuk menanam singkong di musim kemarau, pilih varietas tahan kering seperti Adira 4. Siram secukupnya dan gunakan mulsa untuk menjaga kelembaban tanah.'
        WHEN 11 THEN 'Waktu terbaik menanam tebu di Jawa Timur adalah awal musim hujan (November-Desember). Pastikan drainase baik untuk menghindari genangan.'
        WHEN 28 THEN 'Hama kakao di Sulawesi dapat diatasi dengan pestisida nabati dari daun mimba. Lakukan penyemprotan secara rutin setiap 2 minggu.'
        WHEN 2 THEN 'Untuk kelapa sawit muda, gunakan pupuk NPK 12:12:17 dengan dosis 250 gram per pohon. Berikan setiap 3 bulan.'
        WHEN 17 THEN 'Padi organik dengan sistem subak menggunakan rotasi air dan pupuk kompos. Koordinasi dengan kelompok tani untuk pengaturan air.'
    END,
    'Panduan Pertanian Regional',
    u.created_at + INTERVAL '1 day',
    'session_' || u.id
FROM "user" u
WHERE u.email IN (
    'andi.setiawan@gmail.com',
    'sinta.dewi@yahoo.com', 
    'rahman.husein@outlook.com',
    'lina.sari@gmail.com',
    'kadek.wirawan@gmail.com'
);

-- Add more chat history untuk diversity
INSERT INTO chat_history (user_id, question, answer, sources, created_at, session_id) 
SELECT 
    u.id,
    CASE u.province_id 
        WHEN 14 THEN 'Berapa lama masa panen singkong?'
        WHEN 11 THEN 'Bagaimana cara pengolahan gula tebu tradisional?'
        WHEN 28 THEN 'Kapan waktu fermentasi kakao yang optimal?'
        WHEN 2 THEN 'Berapa jarak tanam ideal kelapa sawit?'
        WHEN 17 THEN 'Apa manfaat sistem subak untuk lingkungan?'
    END,
    CASE u.province_id 
        WHEN 14 THEN 'Singkong dapat dipanen setelah 8-12 bulan tergantung varietasnya. Tanda matang adalah daun mulai menguning.'
        WHEN 11 THEN 'Gula tebu tradisional dibuat dengan cara menggiling tebu, merebus niranya hingga mengental, lalu dicetak.'
        WHEN 28 THEN 'Fermentasi kakao optimal adalah 5-7 hari dengan suhu 45-50°C. Aduk setiap hari untuk fermentasi merata.'
        WHEN 2 THEN 'Jarak tanam kelapa sawit ideal adalah 9x9 meter atau 8.5x8.5 meter, sekitar 120-140 pohon per hektar.'
        WHEN 17 THEN 'Sistem subak menjaga ekosistem sawah, menghemat air, mencegah hama, dan mempertahankan kearifan lokal.'
    END,
    'Panduan Pertanian Regional',
    u.created_at + INTERVAL '3 days',
    'session_' || u.id || '_2'
FROM "user" u
WHERE u.email IN (
    'andi.setiawan@gmail.com',
    'sinta.dewi@yahoo.com', 
    'rahman.husein@outlook.com',
    'lina.sari@gmail.com',
    'kadek.wirawan@gmail.com'
);

-- Verify what we created
SELECT 
    u.name,
    u.email,
    u.region,
    p.name as province_name,
    COUNT(ch.id) as chat_count
FROM "user" u
LEFT JOIN province p ON u.province_id = p.id
LEFT JOIN chat_history ch ON u.id = ch.user_id
WHERE u.email IN (
    'andi.setiawan@gmail.com',
    'sinta.dewi@yahoo.com', 
    'rahman.husein@outlook.com',
    'lina.sari@gmail.com',
    'kadek.wirawan@gmail.com'
)
GROUP BY u.id, u.name, u.email, u.region, p.name
ORDER BY u.name;