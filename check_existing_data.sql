-- Check Existing Data for Testing
-- Run this to see what provinces have users

-- 1. Check all provinces in database
SELECT 
    p.id,
    p.name as province_name,
    COUNT(u.id) as user_count
FROM province p
LEFT JOIN "user" u ON p.id = u.province_id
GROUP BY p.id, p.name
ORDER BY user_count DESC, p.name;

-- 2. Check users by province
SELECT 
    p.name as province_name,
    COUNT(u.id) as user_count,
    COUNT(ch.id) as chat_count,
    STRING_AGG(u.name, ', ') as user_names
FROM province p
LEFT JOIN "user" u ON p.id = u.province_id
LEFT JOIN chat_history ch ON u.id = ch.user_id
WHERE u.id IS NOT NULL
GROUP BY p.id, p.name
ORDER BY user_count DESC;

-- 3. Check provinces without users (available for testing)
SELECT 
    p.id,
    p.name as province_name
FROM province p
LEFT JOIN "user" u ON p.id = u.province_id
WHERE u.id IS NULL
ORDER BY p.name
LIMIT 10;