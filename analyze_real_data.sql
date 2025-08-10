-- Analyze Real Data untuk Testing
-- Check existing real users dan region mereka

-- 1. Check real users dan region mereka
SELECT 
    u.id,
    u.name,
    u.email,
    u.region,
    u.province_id,
    u.regency_id,
    p.name as province_name,
    r.name as regency_name,
    COUNT(ch.id) as chat_count
FROM "user" u
LEFT JOIN province p ON u.province_id = p.id
LEFT JOIN regency r ON u.regency_id = r.id
LEFT JOIN chat_history ch ON u.id = ch.user_id
WHERE u.email NOT LIKE '%@test.com' 
  AND u.email NOT LIKE '%@dummy.com'
GROUP BY u.id, u.name, u.email, u.region, u.province_id, u.regency_id, p.name, r.name
ORDER BY chat_count DESC, u.created_at DESC;

-- 2. Check unique regions dari real users
SELECT 
    u.region,
    COUNT(*) as user_count,
    COUNT(ch.id) as total_chats
FROM "user" u
LEFT JOIN chat_history ch ON u.id = ch.user_id
WHERE u.email NOT LIKE '%@test.com' 
  AND u.email NOT LIKE '%@dummy.com'
  AND u.region IS NOT NULL
  AND u.region != ''
GROUP BY u.region
ORDER BY user_count DESC;

-- 3. Users yang belum punya province_id (perlu di-migrate)
SELECT 
    u.id,
    u.name,
    u.region,
    u.province_id,
    COUNT(ch.id) as chat_count
FROM "user" u
LEFT JOIN chat_history ch ON u.id = ch.user_id
WHERE u.email NOT LIKE '%@test.com' 
  AND u.email NOT LIKE '%@dummy.com'
  AND u.province_id IS NULL
  AND u.region IS NOT NULL
GROUP BY u.id, u.name, u.region, u.province_id
ORDER BY chat_count DESC;