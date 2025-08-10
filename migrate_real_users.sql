-- Migrate Real Users to Province ID
-- Update existing real users dengan province_id berdasarkan region text mereka

-- 1. Show what will be updated (DRY RUN)
SELECT 
    u.id,
    u.name,
    u.region,
    u.province_id as current_province_id,
    CASE 
        -- Jakarta variations
        WHEN LOWER(u.region) LIKE '%jakarta%' OR LOWER(u.region) LIKE '%dki%' THEN 31
        
        -- Jawa Barat variations  
        WHEN LOWER(u.region) LIKE '%jawa barat%' OR LOWER(u.region) LIKE '%jabar%' 
             OR LOWER(u.region) LIKE '%bandung%' OR LOWER(u.region) LIKE '%bogor%' 
             OR LOWER(u.region) LIKE '%bekasi%' OR LOWER(u.region) LIKE '%depok%' THEN 12
             
        -- Jawa Timur variations
        WHEN LOWER(u.region) LIKE '%jawa timur%' OR LOWER(u.region) LIKE '%jatim%'
             OR LOWER(u.region) LIKE '%surabaya%' OR LOWER(u.region) LIKE '%malang%' THEN 11
             
        -- Jawa Tengah variations
        WHEN LOWER(u.region) LIKE '%jawa tengah%' OR LOWER(u.region) LIKE '%jateng%'
             OR LOWER(u.region) LIKE '%semarang%' OR LOWER(u.region) LIKE '%solo%' THEN 13
             
        -- Aceh variations
        WHEN LOWER(u.region) LIKE '%aceh%' OR LOWER(u.region) LIKE '%banda aceh%' THEN 1
        
        -- Sumatra Utara variations
        WHEN LOWER(u.region) LIKE '%sumatra utara%' OR LOWER(u.region) LIKE '%sumut%'
             OR LOWER(u.region) LIKE '%medan%' THEN 2
             
        -- Sumatra Barat variations
        WHEN LOWER(u.region) LIKE '%sumatra barat%' OR LOWER(u.region) LIKE '%sumbar%'
             OR LOWER(u.region) LIKE '%padang%' THEN 3
             
        -- Bali variations
        WHEN LOWER(u.region) LIKE '%bali%' OR LOWER(u.region) LIKE '%denpasar%' THEN 17
        
        -- Yogyakarta variations
        WHEN LOWER(u.region) LIKE '%yogyakarta%' OR LOWER(u.region) LIKE '%yogya%' 
             OR LOWER(u.region) LIKE '%jogja%' OR LOWER(u.region) LIKE '%diy%' THEN 14
             
        -- Sulawesi Selatan variations
        WHEN LOWER(u.region) LIKE '%sulawesi selatan%' OR LOWER(u.region) LIKE '%sulsel%'
             OR LOWER(u.region) LIKE '%makassar%' THEN 28
             
        -- Kalimantan Timur variations
        WHEN LOWER(u.region) LIKE '%kalimantan timur%' OR LOWER(u.region) LIKE '%kaltim%'
             OR LOWER(u.region) LIKE '%balikpapan%' OR LOWER(u.region) LIKE '%samarinda%' THEN 25
             
        ELSE NULL
    END as suggested_province_id,
    p.name as suggested_province_name
FROM "user" u
LEFT JOIN province p ON p.id = (
    CASE 
        WHEN LOWER(u.region) LIKE '%jakarta%' OR LOWER(u.region) LIKE '%dki%' THEN 31
        WHEN LOWER(u.region) LIKE '%jawa barat%' OR LOWER(u.region) LIKE '%jabar%' 
             OR LOWER(u.region) LIKE '%bandung%' OR LOWER(u.region) LIKE '%bogor%' 
             OR LOWER(u.region) LIKE '%bekasi%' OR LOWER(u.region) LIKE '%depok%' THEN 12
        WHEN LOWER(u.region) LIKE '%jawa timur%' OR LOWER(u.region) LIKE '%jatim%'
             OR LOWER(u.region) LIKE '%surabaya%' OR LOWER(u.region) LIKE '%malang%' THEN 11
        WHEN LOWER(u.region) LIKE '%jawa tengah%' OR LOWER(u.region) LIKE '%jateng%'
             OR LOWER(u.region) LIKE '%semarang%' OR LOWER(u.region) LIKE '%solo%' THEN 13
        WHEN LOWER(u.region) LIKE '%aceh%' OR LOWER(u.region) LIKE '%banda aceh%' THEN 1
        WHEN LOWER(u.region) LIKE '%sumatra utara%' OR LOWER(u.region) LIKE '%sumut%'
             OR LOWER(u.region) LIKE '%medan%' THEN 2
        WHEN LOWER(u.region) LIKE '%sumatra barat%' OR LOWER(u.region) LIKE '%sumbar%'
             OR LOWER(u.region) LIKE '%padang%' THEN 3
        WHEN LOWER(u.region) LIKE '%bali%' OR LOWER(u.region) LIKE '%denpasar%' THEN 17
        WHEN LOWER(u.region) LIKE '%yogyakarta%' OR LOWER(u.region) LIKE '%yogya%' 
             OR LOWER(u.region) LIKE '%jogja%' OR LOWER(u.region) LIKE '%diy%' THEN 14
        WHEN LOWER(u.region) LIKE '%sulawesi selatan%' OR LOWER(u.region) LIKE '%sulsel%'
             OR LOWER(u.region) LIKE '%makassar%' THEN 28
        WHEN LOWER(u.region) LIKE '%kalimantan timur%' OR LOWER(u.region) LIKE '%kaltim%'
             OR LOWER(u.region) LIKE '%balikpapan%' OR LOWER(u.region) LIKE '%samarinda%' THEN 25
        ELSE NULL
    END
)
WHERE u.email NOT LIKE '%@test.com' 
  AND u.email NOT LIKE '%@dummy.com'
  AND u.region IS NOT NULL
  AND u.region != ''
ORDER BY u.id;

-- 2. ACTUAL UPDATE (uncomment to execute)
/*
UPDATE "user" 
SET province_id = CASE 
    -- Jakarta variations
    WHEN LOWER(region) LIKE '%jakarta%' OR LOWER(region) LIKE '%dki%' THEN 31
    
    -- Jawa Barat variations  
    WHEN LOWER(region) LIKE '%jawa barat%' OR LOWER(region) LIKE '%jabar%' 
         OR LOWER(region) LIKE '%bandung%' OR LOWER(region) LIKE '%bogor%' 
         OR LOWER(region) LIKE '%bekasi%' OR LOWER(region) LIKE '%depok%' THEN 12
         
    -- Jawa Timur variations
    WHEN LOWER(region) LIKE '%jawa timur%' OR LOWER(region) LIKE '%jatim%'
         OR LOWER(region) LIKE '%surabaya%' OR LOWER(region) LIKE '%malang%' THEN 11
         
    -- Jawa Tengah variations
    WHEN LOWER(region) LIKE '%jawa tengah%' OR LOWER(region) LIKE '%jateng%'
         OR LOWER(region) LIKE '%semarang%' OR LOWER(region) LIKE '%solo%' THEN 13
         
    -- Aceh variations
    WHEN LOWER(region) LIKE '%aceh%' OR LOWER(region) LIKE '%banda aceh%' THEN 1
    
    -- Sumatra Utara variations
    WHEN LOWER(region) LIKE '%sumatra utara%' OR LOWER(region) LIKE '%sumut%'
         OR LOWER(region) LIKE '%medan%' THEN 2
         
    -- Sumatra Barat variations
    WHEN LOWER(region) LIKE '%sumatra barat%' OR LOWER(region) LIKE '%sumbar%'
         OR LOWER(region) LIKE '%padang%' THEN 3
         
    -- Bali variations
    WHEN LOWER(region) LIKE '%bali%' OR LOWER(region) LIKE '%denpasar%' THEN 17
    
    -- Yogyakarta variations
    WHEN LOWER(region) LIKE '%yogyakarta%' OR LOWER(region) LIKE '%yogya%' 
         OR LOWER(region) LIKE '%jogja%' OR LOWER(region) LIKE '%diy%' THEN 14
         
    -- Sulawesi Selatan variations
    WHEN LOWER(region) LIKE '%sulawesi selatan%' OR LOWER(region) LIKE '%sulsel%'
         OR LOWER(region) LIKE '%makassar%' THEN 28
         
    -- Kalimantan Timur variations
    WHEN LOWER(region) LIKE '%kalimantan timur%' OR LOWER(region) LIKE '%kaltim%'
         OR LOWER(region) LIKE '%balikpapan%' OR LOWER(region) LIKE '%samarinda%' THEN 25
         
    ELSE province_id -- Keep existing value if no match
END
WHERE email NOT LIKE '%@test.com' 
  AND email NOT LIKE '%@dummy.com'
  AND region IS NOT NULL
  AND region != '';

-- Show results after update
SELECT 'Migration completed' as status;
*/