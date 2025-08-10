-- Quick Test: 3 Users from Different Regions
-- Execute this in pgAdmin for immediate testing

INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id) VALUES
('Test Yogyakarta', 'test.yogya@test.com', '081111111111', 'password123', 'petani', NOW(), '1990-01-01', 'L', 'YOGYAKARTA', 14, 145),
('Test Manado', 'test.manado@test.com', '081222222222', 'password123', 'petani', NOW(), '1985-05-15', 'P', 'KOTA MANADO', 27, 271),
('Test Pontianak', 'test.pontianak@test.com', '081333333333', 'password123', 'petani', NOW(), '1988-08-20', 'L', 'KOTA PONTIANAK', 23, 231);

-- Add chat history for these users
INSERT INTO chat_history (user_id, question, answer, sources, created_at, session_id) 
SELECT 
    u.id,
    CASE u.province_id 
        WHEN 14 THEN 'Bagaimana cara budidaya gudeg di Yogyakarta?'
        WHEN 27 THEN 'Tanaman apa yang cocok di iklim Sulawesi Utara?'
        WHEN 23 THEN 'Bagaimana mengatasi lahan gambut di Kalimantan Barat?'
    END,
    CASE u.province_id 
        WHEN 14 THEN 'Yogyakarta cocok untuk budidaya nangka muda untuk gudeg. Gunakan varietas lokal yang manis.'
        WHEN 27 THEN 'Sulawesi Utara cocok untuk kelapa, cengkeh, dan pala. Manfaatkan iklim tropis lembab.'
        WHEN 23 THEN 'Lahan gambut Kalimantan perlu drainase yang baik. Cocok untuk sagu dan kelapa.'
    END,
    'Regional Agriculture Guide',
    NOW(),
    'session_test_' || u.id
FROM "user" u
WHERE u.email LIKE 'test.%@test.com' 
AND u.email IN ('test.yogya@test.com', 'test.manado@test.com', 'test.pontianak@test.com');

-- Check results
SELECT 
    u.name,
    u.region, 
    p.name as province_name,
    COUNT(ch.id) as chat_count
FROM "user" u
LEFT JOIN province p ON u.province_id = p.id  
LEFT JOIN chat_history ch ON u.id = ch.user_id
WHERE u.email LIKE 'test.%@test.com'
GROUP BY u.id, u.name, u.region, p.name
ORDER BY u.id DESC;