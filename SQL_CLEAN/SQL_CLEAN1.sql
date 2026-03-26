-- 0. Create a backup table before cleaning

CREATE TABLE interactions_backup1 AS 
SELECT * FROM interactions;


-- 0 exploration sql files
SELECT * FROM interactions LIMIT 3;

-- 1. CONTAR registros totales
SELECT COUNT(*) as total_records
FROM interactions;


-- 2. DETECT MISSING VALUES (NULL)
SELECT 
    COUNT(*) - COUNT(hotel_id) as missing_hotel_id,
    COUNT(*) - COUNT(channel) as missing_channel,
    COUNT(*) - COUNT(language) as missing_language,
    COUNT(*) - COUNT(request_type) as missing_request_type,
    COUNT(*) - COUNT(timestamp) as missing_timestamp
FROM interactions;

-- 3. Replace NULL values in 'language' with 'unknown'

UPDATE interactions
SET language = 'N/A'
WHERE language IS NULL;

UPDATE interactions
SET request_type = 'N/A'
WHERE request_type IS NULL;

-- Veryfying the updates

SELECT 
    COUNT(*) - COUNT(hotel_id) as missing_hotel_id,
    COUNT(*) - COUNT(channel) as missing_channel,
    COUNT(*) - COUNT(language) as missing_language,
    COUNT(*) - COUNT(request_type) as missing_request_type,
    COUNT(*) - COUNT(timestamp) as missing_timestamp
FROM interactions;

-- 4. Calculate percentage of missing values after cleaning
SELECT
    ROUND(100.0 * SUM(CASE WHEN interaction_id = 'N/A' THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_interaction_id,
-- ROUND(100.0 * SUM(CASE WHEN timestamp = 'N/A' THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_timestamp,
    ROUND(100.0 * SUM(CASE WHEN hotel_id = 'N/A' THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_hotel_id,
    ROUND(100.0 * SUM(CASE WHEN channel = 'N/A' THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_channel,
    ROUND(100.0 * SUM(CASE WHEN language = 'N/A' THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_missing_language,
    ROUND(100.0 * SUM(CASE WHEN request_type = 'N/A' THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_missing_request_type,
    ROUND(100.0 * SUM(CASE WHEN complexity = 'N/A' THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_missing_complexity

FROM interactions;

-- 5. Duplicate records detection

SELECT 
    'Total records' as metrica,
    COUNT(*)::TEXT as valor
FROM interactions

UNION ALL

SELECT 
    'Unique records for hotel_id and timestamp',
    COUNT(DISTINCT (hotel_id, timestamp))::TEXT
FROM interactions

UNION ALL

-- Nivel 3: Duplicates based on hotel_id and timestamp

SELECT 
    'Duplicates based on hotel_id and timestamp',
    (COUNT(*) - COUNT(DISTINCT (hotel_id, timestamp)))::TEXT
FROM interactions

UNION ALL

SELECT 
    '% Duplicates based on hotel_id and timestamp',
    ROUND(100.0 * (COUNT(*) - COUNT(DISTINCT (hotel_id, timestamp))) / COUNT(*), 2)::TEXT || '%'
FROM interactions

UNION ALL

-- Nivel 3: Todas las columnas (duplicados exactos)
SELECT 'Duplicates based on all columns', 
       (COUNT(*) - COUNT(DISTINCT (hotel_id, timestamp, channel, language, request_type, complexity)))::TEXT
FROM interactions

UNION ALL

SELECT 
    '% Duplicates based on all columns',
    ROUND(100.0 * (COUNT(*) - COUNT(DISTINCT (hotel_id, timestamp, channel, language, request_type, complexity))) / COUNT(*), 2)::TEXT || '%'
FROM interactions;

-- Remove duplicate records based on all columns, keeping the first occurrence

DELETE FROM interactions
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM interactions
    GROUP BY hotel_id, timestamp, channel, language, request_type, complexity
);

-- Verification of duplicates removal

SELECT 
    hotel_id, 
    timestamp, 
    channel, 
    language, 
    request_type, 
    complexity,
    COUNT(*) as repeticiones
FROM interactions
GROUP BY hotel_id, timestamp, channel, language, request_type, complexity
HAVING COUNT(*) > 1;

-- Verify formatting of columns

SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'interactions'
ORDER BY ordinal_position;

-- Standardization of 'hotel_id' values

SELECT DISTINCT hotel_id, COUNT(*) as cantidad
FROM interactions
GROUP BY hotel_id
ORDER BY hotel_id;

-- UPDATE 'hotel_99'
UPDATE interactions 
SET hotel_id = 'hotel_09'
WHERE hotel_id = 'hotel_99'; 

-- UPDATE invalid hotel_id to 'hotel_unknown'
UPDATE interactions
SET hotel_id = 'hotel_unknown'
WHERE hotel_id NOT IN (
    'hotel_01', 'hotel_02', 'hotel_03', 'hotel_04', 
    'hotel_05', 'hotel_06', 'hotel_07', 'hotel_08',
    'hotel_09', 'hotel_10', 'hotel_11', 'hotel_12'
);

-- Final verification of hotel_id values
SELECT 
    hotel_id,
    COUNT(*) as cantidad,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM interactions), 2) || '%' as porcentaje
FROM interactions
GROUP BY hotel_id
ORDER BY 
    CASE 
        WHEN hotel_id = 'hotel_unknown' THEN 'zzz'    -- ✅ TEXT
        ELSE hotel_id                                   -- ✅ TEXT
    END;

-- Standardization of 'channel' values
SELECT DISTINCT channel, COUNT(*) as cantidad
FROM interactions
GROUP BY channel
ORDER BY channel;

UPDATE interactions 
SET channel = 'website_chat'
WHERE channel = 'websit_chat';


-- Standardization of 'language' values
SELECT DISTINCT language, COUNT(*) as cantidad
FROM interactions
GROUP BY language
ORDER BY language;


UPDATE interactions
SET language = 'EN'
WHERE language = 'EN ';

UPDATE interactions
SET language = 'EN'
WHERE language = 'ENG';

UPDATE interactions
SET language = 'NO'
WHERE language = 'NO ';

UPDATE interactions
SET language = 'NO'
WHERE language = 'NOR';


SELECT DISTINCT request_type, COUNT(*) as cantidad
FROM interactions
GROUP BY request_type
ORDER BY request_type;

UPDATE interactions
SET request_type = 'service_request'
WHERE request_type = 'servce';

SELECT DISTINCT complexity, COUNT(*) as cantidad
FROM interactions
GROUP BY complexity
ORDER BY complexity;

-- Ver distribución de valores (incluyendo NULL)
UPDATE interactions
SET complexity = '0'
WHERE complexity IS NULL;

UPDATE interactions
SET complexity = 'simple'
WHERE complexity = '0';

-- ==========================================
-- Calculate total records before and after cleaning. 
-- ==========================================

SELECT 
    'Record Data Before cleaning (backup)' as momento,
    COUNT(*)::TEXT as register,
    '100.00%' as porcentage
FROM interactions_backup1

UNION ALL

SELECT 
    'Record Data After cleaning (now)',
    COUNT(*)::TEXT,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM interactions_backup1), 2)::TEXT || '%'
FROM interactions

UNION ALL

SELECT 
    'Records Deleted',
    ((SELECT COUNT(*) FROM interactions_backup1) - (SELECT COUNT(*) FROM interactions))::TEXT,
    ROUND(100.0 * ((SELECT COUNT(*) FROM interactions_backup1) - (SELECT COUNT(*) FROM interactions)) / (SELECT COUNT(*) FROM interactions_backup1), 2)::TEXT || '%'

UNION ALL

SELECT 
    'Retention Rate',
    '',
    ROUND(100.0 * (SELECT COUNT(*) FROM interactions) / (SELECT COUNT(*) FROM interactions_backup1), 2)::TEXT || '%';

__-- ==========================================
-- ELIMINATE duplicated records based on INTERACTION_ID WITH SAME HOTEL_ID

-- Ver cuántos grupos de duplicados hay --> 15
SELECT 
    COUNT(*) as grupos_duplicados
FROM (
    SELECT hotel_id, interaction_id
    FROM interactions
    GROUP BY hotel_id, interaction_id
    HAVING COUNT(*) > 1
) sub;

-- Ver cuántos REGISTROS totales se eliminarán --> 15
SELECT 
    SUM(reps - 1) as registros_a_eliminar
FROM (
    SELECT hotel_id, interaction_id, COUNT(*) as reps
    FROM interactions
    GROUP BY hotel_id, interaction_id
    HAVING COUNT(*) > 1
) sub;

-- Ver ejemplos de INTERACTION_ID duplucados mismo hotel_id, de qué se eliminarán
SELECT 
    hotel_id,
    interaction_id,
    timestamp,
    channel,
    request_type
FROM interactions
WHERE (hotel_id, interaction_id) IN (
    SELECT hotel_id, interaction_id
    FROM interactions
    GROUP BY hotel_id, interaction_id
    HAVING COUNT(*) > 1
)
ORDER BY hotel_id, interaction_id, timestamp;

-- DE LA LISTA ANTERIOR, QUE DATOS DE ELIMINARÁN (manteniendo el primer registro TIMESTAMP MÁS ANTIGUO)

-- ==========================================
-- VER DUPLICADOS REALES Y CUÁL SE ELIMINARÁ
-- ==========================================

-- Ver todos los duplicados con indicador de cuál se mantiene
SELECT 
    hotel_id,
    interaction_id,
    timestamp,
    channel,
    request_type,
    ROW_NUMBER() OVER (
        PARTITION BY hotel_id, interaction_id 
        ORDER BY timestamp ASC
    ) as orden,
    CASE 
        WHEN ROW_NUMBER() OVER (
            PARTITION BY hotel_id, interaction_id 
            ORDER BY timestamp ASC
        ) = 1 THEN 'keep'
        ELSE 'delete'
    END as accion
FROM interactions
WHERE (hotel_id, interaction_id) IN (
    SELECT hotel_id, interaction_id
    FROM interactions
    GROUP BY hotel_id, interaction_id
    HAVING COUNT(*) > 1
)
ORDER BY hotel_id, interaction_id, timestamp;

-- Count how many records will be kept and deleted

SELECT 
    'Total records duplicates' as description,
    COUNT(*) as cantidad
FROM interactions
WHERE (hotel_id, interaction_id) IN (
    SELECT hotel_id, interaction_id
    FROM interactions
    GROUP BY hotel_id, interaction_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT 
    'Keep records',
    COUNT(DISTINCT hotel_id || interaction_id)
FROM interactions
WHERE (hotel_id, interaction_id) IN (
    SELECT hotel_id, interaction_id
    FROM interactions
    GROUP BY hotel_id, interaction_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT 
    'Deleted records',
    COUNT(*) - COUNT(DISTINCT hotel_id || interaction_id)
FROM interactions
WHERE (hotel_id, interaction_id) IN (
    SELECT hotel_id, interaction_id
    FROM interactions
    GROUP BY hotel_id, interaction_id
    HAVING COUNT(*) > 1
);

-- verificar otra vez: 

SELECT COUNT(*) as total_antes FROM interactions; -- 4810

-- PASO 2: ELIMINAR los 12 registros posteriores
DELETE FROM interactions i1
WHERE EXISTS (
    SELECT 1
    FROM interactions i2
    WHERE i1.hotel_id = i2.hotel_id
      AND i1.interaction_id = i2.interaction_id
      AND i1.timestamp > i2.timestamp  -- ✅ Elimina los posteriores
);

-- PASO 3: Ver DESPUÉS
SELECT COUNT(*) as total_despues FROM interactions; -- 4798


-- VERIFY DUPLICATES REMOVAL --> 0

SELECT 
    COUNT(*) as grupos_duplicados
FROM (
    SELECT hotel_id, interaction_id
    FROM interactions
    GROUP BY hotel_id, interaction_id
    HAVING COUNT(*) > 1
) sub;


-- ==========================================
-- CLEANNING DUPLICATES BASED ON SAME INTERACTION_ID WITH DIFERENT HOTEL_ID
-- ==========================================

-- VER TODOS LOS REGISTROS DUPLICADOS (con detalles)
SELECT 
    interaction_id,
    hotel_id,
    timestamp,
    channel,
    request_type,
    complexity
FROM interactions
WHERE interaction_id IN (
    SELECT interaction_id
    FROM interactions
    GROUP BY interaction_id
    HAVING COUNT(DISTINCT hotel_id) > 1
)
ORDER BY interaction_id, hotel_id, timestamp;


-- PASO 1: Ver cuántos hotel_unknownse eliminarán
SELECT 
    'Record hotel_unknown duplicates' as description,
    COUNT(*) as amount
FROM interactions
WHERE hotel_id = 'hotel_unknown'
  AND interaction_id IN (
      SELECT interaction_id
      FROM interactions
      GROUP BY interaction_id
      HAVING COUNT(DISTINCT hotel_id) > 1
  );

-- PASO 2: Ver cuáles son (antes de eliminar)
SELECT 
    interaction_id,
    hotel_id,
    timestamp,
    channel,
    request_type
FROM interactions
WHERE hotel_id = 'hotel_unknown'
  AND interaction_id IN (
      SELECT interaction_id
      FROM interactions
      GROUP BY interaction_id
      HAVING COUNT(DISTINCT hotel_id) > 1
  )
ORDER BY interaction_id;

-- PASO 3: ELIMINAR solo esos 4 registros
DELETE FROM interactions
WHERE hotel_id = 'hotel_unknown'
  AND interaction_id IN (
      SELECT interaction_id
      FROM interactions
      GROUP BY interaction_id
      HAVING COUNT(DISTINCT hotel_id) > 1
  );

-- PASO 4: Verify hotel_unknown duplicates removed
SELECT 
    'Total records after cleaning' as description,
    COUNT(*) as amount
FROM interactions

UNION ALL

SELECT 
    'interaction_id still have duplicates with hoteles',
    COUNT(*)
FROM (
    SELECT interaction_id
    FROM interactions
    GROUP BY interaction_id
    HAVING COUNT(DISTINCT hotel_id) > 1
) sub;


-- KEEP CLEANNING INTERACTION_ID DUPLICATED WITH DIFERENT HOTEL_ID: 

-- PASO 1: Ver cuántos interaction_id aún están en múltiples hoteles
SELECT 
    'interaction_id en múltiples hoteles' as description,
    COUNT(*) as amount
FROM (
    SELECT interaction_id
    FROM interactions
    GROUP BY interaction_id
    HAVING COUNT(DISTINCT hotel_id) > 1
) sub

UNION ALL

SELECT 
    'Total RECORDS AFFECTED',
    COUNT(*)
FROM interactions
WHERE interaction_id IN (
    SELECT interaction_id
    FROM interactions
    GROUP BY interaction_id
    HAVING COUNT(DISTINCT hotel_id) > 1
);


-- PASO 2: Ver cuáles se mantendrán y cuáles se eliminarán
SELECT 
    interaction_id,
    hotel_id,
    timestamp,
    channel,
    request_type,
    ROW_NUMBER() OVER (
        PARTITION BY interaction_id 
        ORDER BY timestamp ASC
    ) as orden,
    CASE 
        WHEN ROW_NUMBER() OVER (
            PARTITION BY interaction_id 
            ORDER BY timestamp ASC
        ) = 1 THEN 'KEEP'
        ELSE 'DELETE'
    END as accion
FROM interactions
WHERE interaction_id IN (
    SELECT interaction_id
    FROM interactions
    GROUP BY interaction_id
    HAVING COUNT(DISTINCT hotel_id) > 1
)
ORDER BY interaction_id, timestamp;



-- PASO 4: ELIMINAR los posteriores (mantiene el más temprano)
DELETE FROM interactions i1
WHERE interaction_id IN (
    SELECT interaction_id
    FROM interactions
    GROUP BY interaction_id
    HAVING COUNT(DISTINCT hotel_id) > 1
)
AND EXISTS (
    SELECT 1
    FROM interactions i2
    WHERE i1.interaction_id = i2.interaction_id
      AND i1.timestamp > i2.timestamp  -- ✅ Elimina los posteriores
);




-- PASO 5: Verify deleted records

SELECT 
    'After deleting duplicates' as stage,
    COUNT(*) as records_total
FROM interactions;

--
SELECT 
    COUNT(*) as total_registros,
    COUNT(DISTINCT interaction_id) as interaction_ids_unicos,
    COUNT(*) - COUNT(DISTINCT interaction_id) as diferencia
FROM interactions;

-- FINAL VERIFICATION DUPLICATES: 

SELECT 
    'Duplicados por interaction_id' as tipo_duplicado,
    COUNT(*) - COUNT(DISTINCT interaction_id) as cantidad
FROM interactions;

-- 2. VERIFICAR: Duplicados por hotel_id + interaction_id (debe ser 0)
SELECT 
    'Duplicados por hotel_id + interaction_id' as tipo_duplicado,
    COUNT(*) as cantidad
FROM (
    SELECT hotel_id, interaction_id
    FROM interactions
    GROUP BY hotel_id, interaction_id
    HAVING COUNT(*) > 1
) sub;

-- 3. VERIFICAR: interaction_id en múltiples hoteles (debe ser 0)
SELECT 
    'interaction_id en múltiples hoteles' as tipo_duplicado,
    COUNT(*) as cantidad
FROM (
    SELECT interaction_id
    FROM interactions
    GROUP BY interaction_id
    HAVING COUNT(DISTINCT hotel_id) > 1
) sub;

SELECT 
    'Duplicados por contenido completo' as tipo_duplicado,
    COUNT(*) as cantidad
FROM (
    SELECT hotel_id, timestamp, channel, language, request_type, complexity
    FROM interactions
    GROUP BY hotel_id, timestamp, channel, language, request_type, complexity
    HAVING COUNT(*) > 1
) sub;

-- VERIFICAR LOS DUPLICADOS POR CONTENIDO COMPLETO

-- Ver los 7 grupos de duplicados por contenido

SELECT 
    interaction_id,
    hotel_id,
    timestamp,
    channel,
    language,
    request_type,
    complexity
FROM interactions
WHERE (hotel_id, timestamp, channel, language, request_type, complexity) IN (
    SELECT hotel_id, timestamp, channel, language, request_type, complexity
    FROM interactions
    GROUP BY hotel_id, timestamp, channel, language, request_type, complexity
    HAVING COUNT(*) > 1
)
ORDER BY hotel_id, timestamp, interaction_id;


---
-- ==========================================
-- ELIMINAR DUPLICADOS POR CONTENIDO
-- (mantiene el de interaction_id más pequeño)
-- ==========================================

-- Ver ANTES
SELECT COUNT(*) as total_antes FROM interactions; -- 4747

-- ELIMINAR
DELETE FROM interactions
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM interactions
    GROUP BY hotel_id, timestamp, channel, language, request_type, complexity
);

-- Ver DESPUÉS
SELECT COUNT(*) as total_despues FROM interactions; --4740

-- Verificar
SELECT 
    COUNT(*) as duplicados_por_contenido
FROM (
    SELECT hotel_id, timestamp, channel, language, request_type, complexity
    FROM interactions
    GROUP BY hotel_id, timestamp, channel, language, request_type, complexity
    HAVING COUNT(*) > 1
) sub;



---- TOTAL: 

SELECT 
    'Total registros actuales' as metrica,
    COUNT(*)::TEXT as valor
FROM interactions

UNION ALL

SELECT 
    'interaction_id únicos',
    COUNT(DISTINCT interaction_id)::TEXT
FROM interactions

UNION ALL

SELECT 
    'Diferencia (debe ser 0)',
    (COUNT(*) - COUNT(DISTINCT interaction_id))::TEXT
FROM interactions

UNION ALL

SELECT 
    'hotel_id + interaction_id únicos',
    COUNT(*)::TEXT
FROM (
    SELECT DISTINCT hotel_id, interaction_id
    FROM interactions
) sub;



SELECT 
    interaction_id,
    COUNT(*) as repeticiones,
    COUNT(DISTINCT hotel_id) as hoteles_diferentes
FROM interactions
GROUP BY interaction_id
HAVING COUNT(*) > 1;



-- ==========================================
-- VERIFICACIÓN FINAL DE DUPLICADOS
-- ==========================================

-- 1. VERIFICAR: Duplicados por interaction_id (debe ser 0)
SELECT 
    'Duplicados por interaction_id' as tipo_duplicado,
    COUNT(*) - COUNT(DISTINCT interaction_id) as cantidad
FROM interactions;
-- Resultado esperado: 0 ✅

-- 2. VERIFICAR: Duplicados por hotel_id + interaction_id (debe ser 0)
SELECT 
    'Duplicados por hotel_id + interaction_id' as tipo_duplicado,
    COUNT(*) as cantidad
FROM (
    SELECT hotel_id, interaction_id
    FROM interactions
    GROUP BY hotel_id, interaction_id
    HAVING COUNT(*) > 1
) sub;
-- Resultado esperado: 0 ✅

-- 3. VERIFICAR: interaction_id en múltiples hoteles (debe ser 0)
SELECT 
    'interaction_id en múltiples hoteles' as tipo_duplicado,
    COUNT(*) as cantidad
FROM (
    SELECT interaction_id
    FROM interactions
    GROUP BY interaction_id
    HAVING COUNT(DISTINCT hotel_id) > 1
) sub;
-- Resultado esperado: 0 ✅

-- 4. VERIFICAR: Duplicados por contenido (original)
SELECT 
    'Duplicados por contenido completo' as tipo_duplicado,
    COUNT(*) as cantidad
FROM (
    SELECT hotel_id, timestamp, channel, language, request_type, complexity
    FROM interactions
    GROUP BY hotel_id, timestamp, channel, language, request_type, complexity
    HAVING COUNT(*) > 1
) sub;
-- Resultado esperado: 0 ✅



-- calculo final antes y despues: 

SELECT 
    'Record Data Before cleaning (backup)' as stage,
    COUNT(*)::TEXT as register,
    '100.00%' as percentage
FROM interactions_backup1

UNION ALL

SELECT 
    'Record Data After cleaning (now)',
    COUNT(*)::TEXT,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM interactions_backup1), 2)::TEXT || '%'
FROM interactions

UNION ALL

SELECT 
    'Records Deleted',
    ((SELECT COUNT(*) FROM interactions_backup1) - (SELECT COUNT(*) FROM interactions))::TEXT,
    ROUND(100.0 * ((SELECT COUNT(*) FROM interactions_backup1) - (SELECT COUNT(*) FROM interactions)) / (SELECT COUNT(*) FROM interactions_backup1), 2)::TEXT || '%'

UNION ALL

SELECT 
    'Retention Rate',
    '',
    ROUND(100.0 * (SELECT COUNT(*) FROM interactions) / (SELECT COUNT(*) FROM interactions_backup1), 2)::TEXT || '%';

