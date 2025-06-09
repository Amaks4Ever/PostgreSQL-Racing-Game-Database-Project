-- Analyze performance of a simple query
EXPLAIN ANALYZE SELECT * FROM races WHERE time_sec > 100;

-- Create an index on races.time_sec to speed up queries
CREATE INDEX idx_races_time_sec ON races(time_sec);
-- After creating index, re-run EXPLAIN to see performance improvement
EXPLAIN ANALYZE SELECT * FROM races WHERE time_sec > 100;
DROP INDEX IF EXISTS idx_races_time_sec;

-- Add a new column 'email' to users and populate it
ALTER TABLE users ADD COLUMN email TEXT;
UPDATE users SET email = user_name || '@mail.com';

-- Insert many random race records for performance testing
INSERT INTO races (id_m, id_u, id_c, time_sec)
SELECT
    (random()*19+1)::INT,
    (random()*50+1)::INT,
    (random()*50+1)::INT,
    ROUND(random()*300+60)
FROM generate_series(1, 95000);

-- Create and drop an index on races.id_u for testing
CREATE INDEX idx_races_id_u ON races(id_u);
EXPLAIN ANALYZE
SELECT u.user_name, m.name AS map_name, c.name AS car_name, r.time_sec
FROM races r
JOIN users u ON r.id_u = u.id
JOIN maps m ON r.id_m = m.id
JOIN cars c ON r.id_c = c.id
WHERE r.id_u IS NOT NULL;
DROP INDEX IF EXISTS idx_races_id_u;
