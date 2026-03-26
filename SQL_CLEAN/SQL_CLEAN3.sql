-- COMPARE BEETWEEN INTERACTIONS AND HANDLING TABLES

SELECT 
    'Record handling after cleaning' AS description,
    COUNT(*)::TEXT AS records
FROM handling1

UNION ALL

SELECT 
    'Record interactions after cleaning',
    COUNT(*)::TEXT
FROM interactions

UNION ALL

-- -- Ver cuántas interactions NO tienen handling
SELECT 
    'Interactions without handling' AS description,
    COUNT(*)::TEXT AS records
FROM interactions i
LEFT JOIN handling1 h ON i.interaction_id = h.interaction_id
WHERE h.interaction_id IS NULL

UNION ALL

-- Ver cuántos handlings NO tienen interaction (huérfanos)
SELECT 
    'Handlings without interaction' AS description,
    COUNT(*)::TEXT AS records
FROM handling1 h
LEFT JOIN interactions i ON h.interaction_id = i.interaction_id
WHERE i.interaction_id IS NULL

UNION 

SELECT 
    'Matches perfectos (INNER JOIN)',
    (SELECT COUNT(*) 
     FROM interactions i 
     INNER JOIN handling1 h ON i.interaction_id = h.interaction_id)::TEXT;


-- Veryfying duplicates in handling1 and interactions 

SELECT 
    COUNT(*) as total_handlings,
    COUNT(DISTINCT interaction_id) as interaction_ids_unicos,
    COUNT(*) - COUNT(DISTINCT interaction_id) as duplicados
FROM handling1

union ALL
SELECT 
    COUNT(*) as total_interactions,
    COUNT(DISTINCT interaction_id) as interaction_ids_unicos,
    COUNT(*) - COUNT(DISTINCT interaction_id) as duplicados
FROM interactions;


-- ESTRATEGY: 

-- ELIMINAR HANDLINGS HUÉRFANOS
-- ==========================================

-- PASO 1: Ver cuántos se eliminarán
SELECT 
    'Handlings without interaction' as descripcion,
    COUNT(*) as cantidad
FROM handling1
WHERE interaction_id NOT IN (SELECT interaction_id FROM interactions);

-- PASO 2: ELIMINAR
DELETE FROM handling1
WHERE interaction_id NOT IN (SELECT interaction_id FROM interactions);

-- PASO 3: Verificar resultado
SELECT 
    'handling AFTER eliminate' as momento,
    COUNT(*) as registros
FROM handling1;


-- ==========================================
-- CREAR VISTA: interactions_complete
-- ==========================================

CREATE VIEW interactions_complete AS
SELECT 
    i.interaction_id,
    i.hotel_id,
    i.timestamp,
    i.channel,
    i.language,
    i.request_type,
    i.complexity,
    h.handled_by,
    h.response_time_s,
    h.resolved
FROM interactions i
INNER JOIN handling1 h ON i.interaction_id = h.interaction_id;

-- Verify creation of the view - INTERACTIONS COMPLETE

SELECT 
    'interactions_complete' as dataset,
    COUNT(*) as registros
FROM interactions

UNION ALL

SELECT 
    'interactions_handling',
    COUNT(*)
FROM interactions_complete

UNION ALL

SELECT 
    'handling1',
    COUNT(*)
FROM handling1;

-- -- ==========================================
-- VERIFICACIÓN FINAL COMPLETA
-- ==========================================

-- 1. CONTEOS GENERALES
SELECT 
    'interactions (tabla completa)' as dataset,
    COUNT(*) as registros,
    COUNT(DISTINCT interaction_id) as ids_unicos
FROM interactions

UNION ALL

SELECT 
    'handling1 (tabla)',
    COUNT(*),
    COUNT(DISTINCT interaction_id)
FROM handling1

UNION ALL

SELECT 
    'interactions_complete (vista)',
    COUNT(*),
    COUNT(DISTINCT interaction_id)
FROM interactions_complete;



-- verify

SELECT 
    'Matches perfectos' as verificacion,
    COUNT(*) as cantidad
FROM interactions i
INNER JOIN handling1 h ON i.interaction_id = h.interaction_id

UNION ALL

SELECT 
    'Interactions sin handling',
    COUNT(*)
FROM interactions i
LEFT JOIN handling1 h ON i.interaction_id = h.interaction_id
WHERE h.interaction_id IS NULL

UNION ALL

SELECT 
    'Handlings sin interaction',
    COUNT(*)
FROM handling1 h
LEFT JOIN interactions i ON h.interaction_id = i.interaction_id
WHERE i.interaction_id IS NULL;


-- 
-- 3. VERIFICAR SIN DUPLICADOS EN INTERACTIONS
SELECT 
    'Duplicados en interactions' as verificacion,
    COUNT(*) - COUNT(DISTINCT interaction_id) as cantidad
FROM interactions;

-- 4. VERIFICAR SIN DUPLICADOS EN HANDLING
SELECT 
    'Duplicados en handling1' as verificacion,
    COUNT(*) - COUNT(DISTINCT interaction_id) as cantidad
FROM handling1;