-- Calculate average time for each map (window function)
SELECT
    *,
    ROUND(AVG(time_sec) OVER (PARTITION BY id_m)) AS avg_time_per_map
FROM races
WHERE id_m IN (
    SELECT r2.id_m
    FROM races r2
    GROUP BY r2.id_m
    HAVING COUNT(*) > 1
);

-- Demonstrate ROW_NUMBER over each map
SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY id_m ORDER BY time_sec) AS row_num
FROM races
WHERE id_m IN (
    SELECT r2.id_m
    FROM races r2
    GROUP BY r2.id_m
    HAVING COUNT(*) > 1
);

-- Show LAG, LEAD, NTILE for time_sec within each map partition
SELECT
    id_u,
    id_m,
    time_sec,
    LAG(time_sec, 1) OVER (PARTITION BY id_m ORDER BY time_sec) AS prev_time,
    LEAD(time_sec, 1) OVER (PARTITION BY id_m ORDER BY time_sec) AS next_time,
    NTILE(2) OVER (PARTITION BY id_m ORDER BY time_sec) AS ntile_half,
    time_sec - LAG(time_sec, 1) OVER (PARTITION BY id_m ORDER BY time_sec) AS diff_from_prev
FROM races
ORDER BY id_m, time_sec;

-- Window functions with named window (w)
SELECT
    id_u,
    id_m,
    time_sec,
    MIN(time_sec) OVER w AS min_time,
    MAX(time_sec) OVER w AS max_time,
    AVG(time_sec) OVER w AS avg_time,
    SUM(time_sec) OVER w AS sum_time,
    COUNT(time_sec) OVER w AS count_play
FROM races
WINDOW w AS (PARTITION BY id_m)
ORDER BY id_m, time_sec;
