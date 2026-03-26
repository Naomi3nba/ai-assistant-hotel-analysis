-- ==========================================
-- Feature 2: hotel_size_category: 
-- ==========================================

-- Estadistic

SELECT 
    MIN(rooms) as min_rooms,
    MAX(rooms) as max_rooms,
    ROUND(AVG(rooms), 0) as avg_rooms,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY rooms) as percentile_25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY rooms) as median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY rooms) as percentile_75
FROM hotels
WHERE rooms IS NOT NULL;

-- Ver distribución por hotel
SELECT 
    hotel_id,
    hotel_name,
    rooms
FROM hotels
ORDER BY rooms;

-- Contar cuántos hoteles en cada rango (ejemplo)

SELECT 
    CASE 
        WHEN rooms < 100 THEN 'Small (<100)'
        ELSE 'Large (≥100)'
    END as hotel_size_category,
    COUNT(*) as hotels_count
FROM hotels
WHERE rooms IS NOT NULL
GROUP BY hotel_size_category
ORDER BY 
    MIN(CASE 
        WHEN rooms < 100 THEN 1
        ELSE 2
    END);

-- Feature time: 

-- ==========================================
-- CREATE VIEW: INTERACTION_FULL_ENRICHED
-- ==========================================

CREATE VIEW INTERACTION_FULL_ENRICHED AS
SELECT 
    -- Original interaction data
    i.interaction_id,
    i.hotel_id,
    i.timestamp,
    i.channel,
    i.language,
    i.request_type,
    i.complexity,
    
    -- Hotel data
    h.hotel_name,
    h.city,
    h.country,
    h.hotel_type,
    h.rooms,
    
    -- Hotel size category (NEW)
    CASE 
        WHEN h.rooms < 100 THEN 'Small'
        WHEN h.rooms >= 100 THEN 'Large'
        ELSE NULL
    END as hotel_size_category,
    
    -- Temporal features - Day
    TRIM(TO_CHAR(i.timestamp, 'Day')) as day_of_week,
    EXTRACT(DOW FROM i.timestamp) as day_of_week_number,
    
    -- Temporal features - Time
    EXTRACT(HOUR FROM i.timestamp) as hour_of_day,
    CASE
        WHEN EXTRACT(HOUR FROM i.timestamp) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM i.timestamp) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM i.timestamp) BETWEEN 18 AND 22 THEN 'Evening'
        ELSE 'Night'
    END as time_period,
    
    -- Temporal features - Month/Quarter
    EXTRACT(MONTH FROM i.timestamp) as month_number,
    TRIM(TO_CHAR(i.timestamp, 'Month')) as month_name,
    EXTRACT(QUARTER FROM i.timestamp) as quarter

FROM interactions i
LEFT JOIN hotels h ON i.hotel_id = h.hotel_id;


-- Verificar la vista creada

SELECT COUNT(*) as total FROM INTERACTION_FULL_ENRICHED;

-- Ver primeras filas con nuevas features
SELECT 
    interaction_id,
    hotel_id,
    channel,
    language,
    request_type,
    complexity,
    hotel_name,
    city,
    country,
    hotel_type,
    rooms,
    hotel_size_category,
    timestamp,
    day_of_week,
    hour_of_day,
    day_of_week_number,
    time_period,
    month_number,
    month_name,
    quarter
FROM INTERACTION_FULL_ENRICHED;

-- 
SELECT 
    hotel_size_category,
    COUNT(*) as count
FROM INTERACTION_FULL_ENRICHED
GROUP BY hotel_size_category;


--------------------------------------
-- FEATURE: response_time_s
---------------------------------------

-- STADISTICS

SELECT 
    MIN(response_time_s) as min_time,
    MAX(response_time_s) as max_time,
    AVG(response_time_s) as avg_time,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY response_time_s) as percentile_25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY response_time_s) as median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY response_time_s) as percentile_75
FROM handling1
WHERE response_time_s IS NOT NULL;

-- ver cuantos NULLS

SELECT 
    COUNT(*) as total,
    COUNT(response_time_s) as with_data,
    COUNT(*) - COUNT(response_time_s) as nulls
FROM handling1;


-- Distribution of response times

-- Verificar que la distribución es la esperada
SELECT 
    CASE 
        WHEN response_time_s < 60 THEN 'Fast'
        WHEN response_time_s BETWEEN 60 AND 300 THEN 'Medium'
        WHEN response_time_s > 300 THEN 'Slow'
        ELSE NULL
    END as response_speed,
    COUNT(*) as count,
    CAST(100.0 * COUNT(*) / (SELECT COUNT(*) FROM handling1 WHERE response_time_s IS NOT NULL) AS DECIMAL(5,2)) || '%' as percentage
FROM handling1
WHERE response_time_s IS NOT NULL
GROUP BY response_speed
ORDER BY 
    MIN(CASE 
        WHEN response_time_s < 60 THEN 1
        WHEN response_time_s BETWEEN 60 AND 300 THEN 2
        WHEN response_time_s > 300 THEN 3
    END);

-- Create view with response time category for Interactions Match

CREATE VIEW INTERACTION_MATCH_ENRICHED AS
SELECT 
    -- Original interaction data
    i.interaction_id,
    i.hotel_id,
    i.timestamp,
    i.channel,
    i.language,
    i.request_type,
    i.complexity,
    
    -- Hotel data
    h.hotel_name,
    h.city,
    h.country,
    h.hotel_type,
    h.rooms,
    
    -- Hotel size category
    CASE 
        WHEN h.rooms < 100 THEN 'Small'
        WHEN h.rooms >= 100 THEN 'Large'
        ELSE NULL
    END as hotel_size_category,
    
    -- Handling data
    hnd.handled_by,
    hnd.response_time_s,
    hnd.resolved,
    
    -- Response speed category (NEW)
    CASE 
        WHEN hnd.response_time_s < 60 THEN 'Fast'
        WHEN hnd.response_time_s BETWEEN 60 AND 300 THEN 'Medium'
        WHEN hnd.response_time_s > 300 THEN 'Slow'
        ELSE NULL
    END as response_speed,
    
    -- Temporal features - Day
    TRIM(TO_CHAR(i.timestamp, 'Day')) as day_of_week,
    EXTRACT(DOW FROM i.timestamp) as day_of_week_number,
    
    -- Temporal features - Time
    EXTRACT(HOUR FROM i.timestamp) as hour_of_day,
    CASE
        WHEN EXTRACT(HOUR FROM i.timestamp) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM i.timestamp) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM i.timestamp) BETWEEN 18 AND 22 THEN 'Evening'
        ELSE 'Night'
    END as time_period,
    
    -- Temporal features - Month/Quarter
    EXTRACT(MONTH FROM i.timestamp) as month_number,
    TRIM(TO_CHAR(i.timestamp, 'Month')) as month_name,
    EXTRACT(QUARTER FROM i.timestamp) as quarter
    
FROM interactions i
LEFT JOIN hotels h ON i.hotel_id = h.hotel_id
INNER JOIN handling1 hnd ON i.interaction_id = hnd.interaction_id;


-- verify

-- Contar registros
SELECT COUNT(*) as total FROM INTERACTION_MATCH_ENRICHED;

SELECT 
    interaction_id,
    hotel_id,
    timestamp,
    channel,
    language,
    request_type,
    complexity,
    hotel_name,
    city,
    country,
    hotel_type,
    rooms,
    hotel_size_category,
    handled_by,
    response_time_s,
    response_speed,
    hour_of_day,
    day_of_week_number,
    day_of_week,
    month_number,
    month_name,
    quarter,
    time_period,
    resolved
FROM INTERACTION_MATCH_ENRICHED;

SELECT 
    hotel_size_category,
    COUNT(*) as count
FROM INTERACTION_MATCH_ENRICHED
GROUP BY hotel_size_category;