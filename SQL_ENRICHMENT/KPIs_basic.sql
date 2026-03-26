-- Verificar que todo coincide
SELECT 
    'Total records match' as validation,
    COUNT(*) as count_full,
    (SELECT COUNT(*) FROM INTERACTION_MATCH_ENRICHED) as count_match,
    CASE 
        WHEN COUNT(*) >= (SELECT COUNT(*) FROM INTERACTION_MATCH_ENRICHED) 
        THEN '✅ OK' 
        ELSE '❌ ERROR' 
    END as status
FROM INTERACTION_FULL_ENRICHED;


-- Resumen general
SELECT 
    'Total interactions' as metric,
    COUNT(*)::TEXT as value
FROM INTERACTION_FULL_ENRICHED

UNION ALL

SELECT 
    'With handling data',
    COUNT(*)::TEXT
FROM INTERACTION_MATCH_ENRICHED

UNION ALL

SELECT 
    'Unique hotels',
    COUNT(DISTINCT hotel_id)::TEXT
FROM INTERACTION_FULL_ENRICHED

UNION ALL

SELECT 
    'Date range',
    MIN(timestamp)::DATE || ' to ' || MAX(timestamp)::DATE
FROM INTERACTION_FULL_ENRICHED;


-- Verificar features creadas
SELECT 'hotel_size' as feature, hotel_size_category as category, COUNT(*) as count
FROM INTERACTION_FULL_ENRICHED
GROUP BY hotel_size_category

UNION ALL

SELECT 'response_speed', response_speed, COUNT(*)
FROM INTERACTION_MATCH_ENRICHED
GROUP BY response_speed

UNION ALL

SELECT 'handled_by', handled_by, COUNT(*)
FROM INTERACTION_MATCH_ENRICHED
GROUP BY handled_by;


-- KPIs

-- Comparación simple AI vs Human
SELECT 
    handled_by,
    COUNT(*) as total_interactions,
    AVG(response_time_s) as avg_response_time,
    COUNT(CASE WHEN resolved = 'TRUE' THEN 1 END) as resolved_count
FROM INTERACTION_MATCH_ENRICHED
WHERE handled_by IS NOT NULL
GROUP BY handled_by;


