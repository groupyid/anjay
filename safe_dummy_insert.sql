-- =====================================================
-- SAFE DUMMY DATA INSERT
-- Handles existing data and avoids foreign key errors
-- =====================================================

-- Start transaction for safety
BEGIN;

-- Get current max user ID to avoid conflicts
DO $$
DECLARE
    max_user_id INTEGER;
    new_user_ids INTEGER[];
    i INTEGER;
BEGIN
    -- Get current max ID
    SELECT COALESCE(MAX(id), 0) INTO max_user_id FROM "user";
    
    RAISE NOTICE 'Current max user ID: %', max_user_id;
    
    -- Insert new users with safe IDs
    INSERT INTO "user" (name, email, phone, password, role, created_at, dob, gender, region, province_id, regency_id) VALUES
    ('Test User Jakarta', 'test.jakarta@dummy.com', '081111111111', 'password123', 'petani', NOW(), '1985-01-01', 'L', 'JAKARTA SELATAN', 31, NULL),
    ('Test User Bandung', 'test.bandung@dummy.com', '081222222222', 'password123', 'petani', NOW(), '1990-02-02', 'P', 'KOTA BANDUNG', 12, 73),
    ('Test User Surabaya', 'test.surabaya@dummy.com', '081333333333', 'password123', 'petani', NOW(), '1988-03-03', 'L', 'KOTA SURABAYA', 11, 78),
    ('Test User Medan', 'test.medan@dummy.com', '081444444444', 'password123', 'petani', NOW(), '1992-04-04', 'P', 'KOTA MEDAN', 2, 23),
    ('Test User Denpasar', 'test.denpasar@dummy.com', '081555555555', 'password123', 'petani', NOW(), '1987-05-05', 'L', 'KOTA DENPASAR', 17, 171),
    ('Test User Makassar', 'test.makassar@dummy.com', '081666666666', 'password123', 'petani', NOW(), '1991-06-06', 'P', 'KOTA MAKASSAR', 28, 281),
    ('Test User Balikpapan', 'test.balikpapan@dummy.com', '081777777777', 'password123', 'petani', NOW(), '1986-07-07', 'L', 'KOTA BALIKPAPAN', 25, 252),
    ('Test User Padang', 'test.padang@dummy.com', '081888888888', 'password123', 'petani', NOW(), '1989-08-08', 'P', 'KOTA PADANG', 3, 30),
    ('Test User Semarang', 'test.semarang@dummy.com', '081999999999', 'password123', 'petani', NOW(), '1984-09-09', 'L', 'KOTA SEMARANG', 13, 125),
    ('Test User Banda Aceh', 'test.bandaaceh@dummy.com', '081000000000', 'password123', 'petani', NOW(), '1993-10-10', 'P', 'KOTA BANDA ACEH', 1, 1);
    
    RAISE NOTICE 'Inserted % new users', 10;
    
    -- Insert chat history using actual user IDs
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
            WHEN 28 THEN 'rumput laut di Sulawesi Selatan?'
            WHEN 25 THEN 'sagu di lahan gambut Kalimantan?'
            WHEN 3 THEN 'kopi arabika di Sumatra Barat?'
            WHEN 13 THEN 'padi organik di Jawa Tengah?'
            WHEN 1 THEN 'kelapa sawit di Aceh?'
            ELSE 'padi di daerah saya?'
        END,
        'Sesuai kondisi wilayah ' || p.name || ', disarankan menggunakan teknik budidaya yang sesuai dengan iklim dan topografi lokal. ' ||
        CASE u.province_id 
            WHEN 31 THEN 'Jakarta memerlukan teknik vertikultur dan hidroponik untuk lahan terbatas.'
            WHEN 12 THEN 'Jawa Barat cocok untuk tanaman dataran tinggi dengan suhu sejuk.'
            WHEN 11 THEN 'Jawa Timur ideal untuk tebu dengan tanah aluvial yang subur.'
            WHEN 2 THEN 'Sumatra Utara cocok untuk buah tropis dengan curah hujan tinggi.'
            WHEN 17 THEN 'Bali menggunakan sistem subak untuk pengairan yang efisien.'
            ELSE 'Sesuaikan dengan kondisi iklim dan tanah setempat.'
        END,
        'Panduan Pertanian Regional ' || p.name,
        NOW(),
        'session_' || LPAD(u.id::text, 6, '0')
    FROM "user" u
    JOIN province p ON u.province_id = p.id
    WHERE u.email LIKE '%@dummy.com';
    
    RAISE NOTICE 'Inserted chat history for dummy users';
    
END $$;

-- Commit transaction
COMMIT;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check what we created
SELECT 
    '=== DUMMY DATA SUMMARY ===' as info;

SELECT 
    'Total dummy users created' as description,
    COUNT(*) as count
FROM "user" 
WHERE email LIKE '%@dummy.com';

SELECT 
    'Total chat messages for dummy users' as description,
    COUNT(*) as count
FROM chat_history ch
JOIN "user" u ON ch.user_id = u.id
WHERE u.email LIKE '%@dummy.com';

-- Show users by province
SELECT 
    '=== USERS BY PROVINCE ===' as info;

SELECT 
    p.name as province_name,
    COUNT(u.id) as user_count,
    STRING_AGG(u.name, ', ') as user_names
FROM "user" u
JOIN province p ON u.province_id = p.id
WHERE u.email LIKE '%@dummy.com'
GROUP BY p.id, p.name
ORDER BY p.name;

-- Show chat history details
SELECT 
    '=== CHAT HISTORY SAMPLE ===' as info;

SELECT 
    u.name as user_name,
    u.region,
    p.name as province,
    ch.question,
    LEFT(ch.answer, 100) || '...' as answer_preview
FROM "user" u
JOIN province p ON u.province_id = p.id
JOIN chat_history ch ON u.id = ch.user_id
WHERE u.email LIKE '%@dummy.com'
ORDER BY u.id
LIMIT 5;

-- Check for any foreign key issues
SELECT 
    '=== FOREIGN KEY CHECK ===' as info;

SELECT 
    'Orphaned chat_history records' as check_type,
    COUNT(*) as count
FROM chat_history ch
LEFT JOIN "user" u ON ch.user_id = u.id
WHERE u.id IS NULL;

SELECT 
    'Users without valid province_id' as check_type,
    COUNT(*) as count
FROM "user" u
LEFT JOIN province p ON u.province_id = p.id
WHERE u.province_id IS NOT NULL AND p.id IS NULL;