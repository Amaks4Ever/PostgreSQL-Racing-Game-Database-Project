-- Retrieve all records from each table (for testing)
SELECT * FROM users;
SELECT * FROM cars;
SELECT * FROM maps;
SELECT * FROM races;

-- Join tables to calculate speed (length/time)
SELECT
    u.user_name,
    c.name AS car_name,
    m.name AS map_name,
    m.length_mil,
    r.time_sec,
    ROUND(m.length_mil::numeric / r.time_sec * 3600) AS speed
FROM races r
JOIN users u ON r.id_u = u.id
JOIN cars c ON r.id_c = c.id
JOIN maps m ON r.id_m = m.id
LIMIT 15;

-- Find top 15 fastest races (by speed)
SELECT
    r.id_u,
    r.id_c,
    m.name AS map_name,
    m.length_mil,
    r.time_sec,
    ROUND(m.length_mil::numeric / r.time_sec * 3600) AS speed
FROM races r
JOIN maps m ON r.id_m = m.id
ORDER BY speed DESC
LIMIT 15;

-- Find top 5 cars by average speed across all races
SELECT
    r.id_c,
    ROUND(AVG(m.length_mil::numeric / r.time_sec * 3600)) AS avg_speed
FROM races r
JOIN maps m ON r.id_m = m.id
GROUP BY r.id_c
ORDER BY avg_speed DESC
LIMIT 5;

-- Retrieve top 5 cars by average speed (using subquery)
SELECT c.name
FROM cars c
JOIN (
    SELECT
        id_c,
        ROUND(AVG(m.length_mil::numeric / races.time_sec * 3600)) AS avg_speed
    FROM races
    JOIN maps m ON races.id_m = m.id
    GROUP BY id_c
    ORDER BY avg_speed DESC
    LIMIT 5
) AS speed_tab ON c.id = speed_tab.id_c;
