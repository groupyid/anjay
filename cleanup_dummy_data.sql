-- =====================================================
-- CLEANUP DUMMY DATA
-- Remove all test/dummy data if needed
-- =====================================================

-- Show what will be deleted
SELECT 
    '=== DATA TO BE DELETED ===' as info;

SELECT 
    'Dummy users to be deleted' as description,
    COUNT(*) as count
FROM "user" 
WHERE email LIKE '%@dummy.com' OR email LIKE '%@test.com';

SELECT 
    'Chat messages to be deleted' as description,
    COUNT(*) as count
FROM chat_history ch
JOIN "user" u ON ch.user_id = u.id
WHERE u.email LIKE '%@dummy.com' OR u.email LIKE '%@test.com';

-- Uncomment the lines below to actually delete the data
-- WARNING: This will permanently delete dummy data!

/*
-- Delete chat history first (foreign key constraint)
DELETE FROM chat_history 
WHERE user_id IN (
    SELECT id FROM "user" 
    WHERE email LIKE '%@dummy.com' OR email LIKE '%@test.com'
);

-- Delete users
DELETE FROM "user" 
WHERE email LIKE '%@dummy.com' OR email LIKE '%@test.com';

-- Verify deletion
SELECT 'Cleanup completed' as status;
SELECT 'Remaining dummy users' as check_type, COUNT(*) as count
FROM "user" 
WHERE email LIKE '%@dummy.com' OR email LIKE '%@test.com';
*/