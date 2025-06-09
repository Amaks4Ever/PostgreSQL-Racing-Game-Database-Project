-- Create table to log changes in 'races' times
CREATE TABLE races_logs (
    id SERIAL PRIMARY KEY,
    id_r INT,
    old_time INT,
    new_time INT,
    change_date TIMESTAMP DEFAULT NOW()
);

-- Trigger function to record time_sec updates in 'races'
DROP FUNCTION IF EXISTS trig_log_race_time();
CREATE OR REPLACE FUNCTION trig_log_race_time()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.time_sec IS DISTINCT FROM NEW.time_sec THEN
        INSERT INTO races_logs(id_r, old_time, new_time) 
        VALUES (OLD.id, OLD.time_sec, NEW.time_sec);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to fire after update on 'races'
DROP TRIGGER IF EXISTS race_time_change ON races;
CREATE TRIGGER race_time_change
AFTER UPDATE ON races
FOR EACH ROW EXECUTE FUNCTION trig_log_race_time();

-- Create table to log changes in 'users' name
CREATE TABLE user_logs (
    id SERIAL PRIMARY KEY,
    id_u INT,
    old_name TEXT,
    new_name TEXT,
    date_ch TIMESTAMP DEFAULT NOW()
);

-- Trigger function to record user_name updates in 'users'
DROP FUNCTION IF EXISTS trig_log_user_name();
CREATE OR REPLACE FUNCTION trig_log_user_name()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.user_name IS DISTINCT FROM NEW.user_name THEN
        INSERT INTO user_logs (id_u, old_name, new_name)
        VALUES (OLD.id, OLD.user_name, NEW.user_name);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to fire after update on 'users'
DROP TRIGGER IF EXISTS user_name_change ON users;
CREATE TRIGGER user_name_change
AFTER UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION trig_log_user_name();

-- Example usage of triggers
UPDATE races SET time_sec = 269 WHERE id = 25;
SELECT * FROM races WHERE id = 25;
SELECT * FROM races_logs;

UPDATE users SET user_name = 'TurboGang' WHERE id = 3;
SELECT * FROM users WHERE id = 3;
SELECT * FROM user_logs;
