
-- ==========================================
-- FINAL CONSOLIDATED REPORT
-- ==========================================

SELECT 
    'SUMMARY - interactions' as section,
    'Original records' as metric,
    (SELECT COUNT(*)::TEXT FROM interactions_backup1) as value,
    '100%' as percentage

UNION ALL

SELECT 
    'SUMMARY - interactions',
    'After cleaning',
    (SELECT COUNT(*)::TEXT FROM interactions),
    ROUND(100.0 * (SELECT COUNT(*) FROM interactions) / 
          (SELECT COUNT(*) FROM interactions_backup1), 2)::TEXT || '%'

UNION ALL

SELECT 
    'SUMMARY - interactions',
    'Records removed',
    ((SELECT COUNT(*) FROM interactions_backup1) - (SELECT COUNT(*) FROM interactions))::TEXT,
    ROUND(100.0 * ((SELECT COUNT(*) FROM interactions_backup1) - (SELECT COUNT(*) FROM interactions)) / 
          (SELECT COUNT(*) FROM interactions_backup1), 2)::TEXT || '%'

UNION ALL

SELECT 
    '---',
    '---',
    '---',
    '---'

UNION ALL

SELECT 
    'SUMMARY - handling',
    'Original records',
    (SELECT COUNT(*)::TEXT FROM handling_backup1),
    '100%'

UNION ALL

SELECT 
    'SUMMARY - handling',
    'After cleaning',
    (SELECT COUNT(*)::TEXT FROM handling1),
    ROUND(100.0 * (SELECT COUNT(*) FROM handling1) / 
          (SELECT COUNT(*) FROM handling_backup1), 2)::TEXT || '%'

UNION ALL

SELECT 
    'SUMMARY - handling',
    'Records removed',
    ((SELECT COUNT(*) FROM handling_backup1) - (SELECT COUNT(*) FROM handling1))::TEXT,
    ROUND(100.0 * ((SELECT COUNT(*) FROM handling_backup1) - (SELECT COUNT(*) FROM handling1)) / 
          (SELECT COUNT(*) FROM handling_backup1), 2)::TEXT || '%'

UNION ALL

SELECT 
    '---',
    '---',
    '---',
    '---'

UNION ALL

SELECT 
    'FINAL DATASETS',
    'interactions (full)',
    (SELECT COUNT(*)::TEXT FROM interactions),
    'For volume KPIs'

UNION ALL

SELECT 
    'FINAL DATASETS',
    'interactions_complete (view)',
    (SELECT COUNT(*)::TEXT FROM interactions_complete),
    'For performance KPIs'

UNION ALL

SELECT 
    'FINAL DATASETS',
    'handling',
    (SELECT COUNT(*)::TEXT FROM handling1),
    'Matched with interactions';