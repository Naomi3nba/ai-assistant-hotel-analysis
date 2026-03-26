
-- verify tables

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Create a backup of the handling table before making any changes
CREATE TABLE handling_backup1 AS 
SELECT * FROM handling;

-- Create a backup of the handling table before making any changes 2
CREATE TABLE handling_backup2 AS 
SELECT * FROM handling_backup1;

CREATE TABLE handling1 AS 
SELECT * FROM handling_backup2;

-- 0 exploration sql files
SELECT * FROM handling1 LIMIT 2;

-- verify columns and data types
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'handling1'
ORDER BY ordinal_position;

-- 1 count records before cleaning 
-- total record # 3610
-- total unique interaction_id # 3601

SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT interaction_id) as unique_interaction_ids
FROM handling1;


-- 2. DETECT MISSING VALUES (NULL)
SELECT 
    COUNT(*) - COUNT(interaction_id) as missing_interaction_id,
    COUNT(*) - COUNT(handled_by) as missing_handled_by,
    COUNT(*) - COUNT(response_time_s) as missing_response_time_s,
    COUNT(*) - COUNT(resolved) as missing_resolved
FROM handling1;

-- 3. We dont Replace NULL values in 'response_time_s' with 0, keep "Null"


-- 4. Calculate percentage of missing values after cleaning
SELECT
    ROUND(100.0 * SUM(CASE WHEN interaction_id IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_interaction_id,
    ROUND(100.0 * SUM(CASE WHEN handled_by IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_handled_by,
    ROUND(100.0 * SUM(CASE WHEN response_time_s IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_response_time_s,
    ROUND(100.0 * SUM(CASE WHEN resolved IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_missing_resolved

FROM handling1; 


-- 5. Duplicate records detection

SELECT 
    'Total records' as metrica,
    COUNT(*)::TEXT as valor
FROM handling1

UNION ALL

SELECT 
    'Unique records for interaction_id',
    COUNT(DISTINCT interaction_id)::TEXT
FROM handling1

UNION ALL

-- Nivel 3: Duplicates based on hotel_id and timestamp

SELECT 
    'Duplicates based on interaction_id',
    (COUNT(*) - COUNT(DISTINCT interaction_id))::TEXT
FROM handling1

UNION ALL

SELECT 
    '% Duplicates based on interaction_id',
    ROUND(100.0 * (COUNT(*) - COUNT(DISTINCT interaction_id)) / COUNT(*), 2)::TEXT || '%'
FROM handling1

UNION ALL

-- Nivel 3: Todas las columnas (duplicados exactos)
SELECT 'Duplicates based on all columns', 
       (COUNT(*) - COUNT(DISTINCT (interaction_id, handled_by, response_time_s, resolved)))::TEXT
FROM handling1

UNION ALL

SELECT 
    '% Duplicates based on all columns',
    ROUND(100.0 * (COUNT(*) - COUNT(DISTINCT (interaction_id, handled_by, response_time_s, resolved))) / COUNT(*), 2)::TEXT || '%'
FROM handling1;


-- Remove duplicate records based on all columns, keeping the first occurrence

DELETE FROM handling1
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM handling1
    GROUP BY interaction_id);

-- Verify after duplicate records based on interaction_id --> no data 

SELECT 
    h.interaction_id,
    h.handled_by,
    h.response_time_s,
    h.resolved,
    COUNT(*) OVER (PARTITION BY h.interaction_id) as veces_repetido
FROM handling_backup1 h
WHERE h.interaction_id IN (
    SELECT interaction_id
    FROM handling_backup1
    GROUP BY interaction_id
    HAVING COUNT(*) > 1
)
ORDER BY h.interaction_id, h.handled_by;


-- Verify formatting of columns

SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'handling_backup1'
ORDER BY ordinal_position;


-- Standardization of 'interaction_ID' values

-- interaction 

SELECT DISTINCT interaction_id, COUNT(*) as cantidad
FROM handling1
GROUP BY interaction_id
ORDER BY interaction_id;

-- handled_by
SELECT DISTINCT handled_by, COUNT(*) as cantidad
FROM handling1
GROUP BY handled_by
ORDER BY handled_by;


-- UPDATE 'Ai' to 'AI'
UPDATE handling1 
SET handled_by = 'AI'
WHERE handled_by = 'Ai'; 


-- response_time_s 
SELECT DISTINCT response_time_s, COUNT(*) as cantidad
FROM handling1
GROUP BY response_time_s
ORDER BY response_time_s;

SELECT 
    COUNT(*) as total_registros,
    COUNT(*) FILTER (WHERE response_time_s < 0) as negatives,
    COUNT(*) FILTER (WHERE response_time_s = 0) as zeros,
    COUNT(*) FILTER (WHERE response_time_s > 0) as positives,
    COUNT(*) FILTER (WHERE response_time_s IS NULL) as nulls
FROM handling1;

-- UPDATE RESPONSE TIME < 0 to NULL
UPDATE handling1
SET response_time_s = NULL
WHERE response_time_s < 0;

-- resolved 
SELECT DISTINCT resolved, COUNT(*) as cantidad
FROM handling1
GROUP BY resolved
ORDER BY resolved;


-- UPDATE Resolved 'Yes' to TRUE and 'No' to FALSE
UPDATE handling1
SET resolved = CASE 
    WHEN resolved = 'yes' THEN 'TRUE'
    WHEN resolved = 'no' THEN 'FALSE'
    ELSE resolved
END;

-- TOTAL RECORDS BEFORE / AFTER CLEANING --> 3601 records before and after cleaning, no duplicates, no missing values, standardized values in handled_by, response_time_s and resolved columns.
SELECT COUNT(*) as total_records_after
FROM handling1

unION ALL

SELECT COUNT(*) as total_records_before
FROM handling_backup2;


-- ==========================================
-- Calculate total records before and after cleaning. 
-- ==========================================

SELECT 
    'Record Data Before cleaning (backup)' as stage,
    COUNT(*)::TEXT as register,
    '100.00%' as percentage
FROM handling_backup2

UNION ALL

SELECT 
    'Record Data After cleaning (now)',
    COUNT(*)::TEXT,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM handling_backup2), 2)::TEXT || '%'
FROM handling1

UNION ALL

SELECT 
    'Records Deleted',
    ((SELECT COUNT(*) FROM handling_backup2) - (SELECT COUNT(*) FROM handling1))::TEXT,
    ROUND(100.0 * ((SELECT COUNT(*) FROM handling_backup2) - (SELECT COUNT(*) FROM handling1)) / (SELECT COUNT(*) FROM handling_backup2), 2)::TEXT || '%'

UNION ALL

SELECT 
    'Retention Rate',
    '',
    ROUND(100.0 * (SELECT COUNT(*) FROM handling1) / (SELECT COUNT(*) FROM handling_backup2), 2)::TEXT || '%';


