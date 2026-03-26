SELECT * FROM hotels LIMIT 5;

-- estructure

SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'hotels'
ORDER BY ordinal_position;

-- count hotels total: 

SELECT COUNT(*) as total_hotels FROM hotels;

-- Verificar coincidencia de hotel_ids
SELECT 
    'Hotels in hotels table' as source,
    COUNT(DISTINCT hotel_id) as count
FROM hotels

UNION ALL

SELECT 
    'Hotels in interactions',
    COUNT(DISTINCT hotel_id)
FROM interactions

UNION ALL

SELECT 
    'Hotels that MATCH',
    COUNT(DISTINCT i.hotel_id)
FROM interactions i
INNER JOIN hotels h ON i.hotel_id = h.hotel_id

UNION ALL

SELECT 
    'Hotels in interactions NOT in hotels',
    COUNT(DISTINCT i.hotel_id)
FROM interactions i
LEFT JOIN hotels h ON i.hotel_id = h.hotel_id
WHERE h.hotel_id IS NULL;


-- How many 'hotel_unknown' are in interactions?
SELECT COUNT(*) FROM interactions WHERE hotel_id = 'hotel_unknown';

-- 01 create view interactions_with_hotels with handling data: (without hotels 'unknown')
-- DROP VIEW interactions_with_hotels;


CREATE VIEW interactions_full AS
SELECT 
    i.*,
    h.hotel_name,
    h.city,
    h.country,
    h.hotel_type,
    h.rooms
FROM interactions i
LEFT JOIN hotels h ON i.hotel_id = h.hotel_id;

-- Export the new view to a CSV file
SELECT * FROM interactions_full;


-- count records in the new view
SELECT COUNT(*) as total_records FROM interactions_full;

-- count records with hotel data vs nulls
SELECT 
    COUNT(*) as total,
    COUNT(hotel_name) as with_hotel_data,
    COUNT(*) - COUNT(hotel_name) as nulls_hotel_unknown
FROM interactions_full;





--02 create view interactions_complete with handling data: (without hotels 'unknown')

DROP VIEW interactions_complete;

CREATE VIEW interactions_match AS
SELECT 
    i.*,
    h.hotel_name,
    h.city,
    h.country,
    h.hotel_type,
    h.rooms,
    hnd.handled_by,
    hnd.response_time_s,
    hnd.resolved
FROM interactions i
LEFT JOIN hotels h ON i.hotel_id = h.hotel_id
INNER JOIN handling1 hnd ON i.interaction_id = hnd.interaction_id;


-- VERIFY THE NEW VIEW
SELECT * FROM interactions_match;  -- CSV export

SELECT 
    COUNT(*) as total,
    COUNT(hotel_name) as with_hotel_data,
    COUNT(*) - COUNT(hotel_name) as nulls_hotel_unknown
FROM interactions_match;

