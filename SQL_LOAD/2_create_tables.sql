CREATE TABLE hotels (
    hotel_id VARCHAR(20),
    hotel_name VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50),
    hotel_type VARCHAR(20),
    rooms INT
);

CREATE TABLE interactions (
    interaction_id VARCHAR(30),
    timestamp TIMESTAMP,
    hotel_id VARCHAR(20),
    channel VARCHAR(30),
    language VARCHAR(5),
    request_type VARCHAR(50),
    complexity VARCHAR(20)
);

CREATE TABLE handling (
    interaction_id VARCHAR(30),
    handled_by VARCHAR(20),
    response_time_s FLOAT,
    resolved VARCHAR(10)
);