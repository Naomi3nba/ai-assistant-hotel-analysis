-- ==========================================
-- RESUMEN COMPLETO DE VISTAS Y TABLAS
-- ==========================================

SELECT 
    'INTERACTION_FULL_ENRICHED (VIEW)' as dataset_name,
    COUNT(*) as total_records,
    'Volume analysis - All interactions + hotels + temporal features + hotel_size' as description
FROM INTERACTION_FULL_ENRICHED

UNION ALL

SELECT 
    'INTERACTION_MATCH_ENRICHED (VIEW)',
    COUNT(*),
    'Performance analysis - Complete data + hotels + handling + all features + response_speed'
FROM INTERACTION_MATCH_ENRICHED

UNION ALL

SELECT 
    'interactions_full (VIEW)',
    COUNT(*),
    'OLD - interactions + hotels (without features)'
FROM interactions_full

UNION ALL

SELECT 
    'interactions_match (VIEW)',
    COUNT(*),
    'OLD - interactions + hotels + handling (without features)'
FROM interactions_match

UNION ALL

SELECT 
    '--- TABLES (BASE) ---',
    NULL,
    '---'

UNION ALL

SELECT 
    'interactions (TABLE)',
    COUNT(*),
    'Base table - cleaned interactions'
FROM interactions

UNION ALL

SELECT 
    'handling1 (TABLE)',
    COUNT(*),
    'Base table - cleaned handling records'
FROM handling1

UNION ALL

SELECT 
    'hotels (TABLE)',
    COUNT(*),
    'Base table - hotel information'
FROM hotels;