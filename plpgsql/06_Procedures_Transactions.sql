-- Simple stored procedure to insert a new race record
CREATE OR REPLACE PROCEDURE proc_add_race(
    IN m_id INT,
    IN u_id INT,
    IN c_id INT,
    IN time_ INT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO races (id_m, id_u, id_c, time_sec)
    VALUES (m_id, u_id, c_id, time_);
END;
$$;

-- Call the procedure to add races
CALL proc_add_race(15, 2, 10, 146);
CALL proc_add_race(19, 15, 2, 502);
SELECT * FROM races;

-- Validation trigger: prevent inserting races with unrealistic time
DROP FUNCTION IF EXISTS trig_validate_time();
CREATE OR REPLACE FUNCTION trig_validate_time()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.time_sec > 500 THEN
        RAISE NOTICE 'Time value too large, race not inserted';
        RETURN NULL;  -- skip insert
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER race_time_check
BEFORE INSERT ON races
FOR EACH ROW EXECUTE FUNCTION trig_validate_time();

CALL proc_add_race(11, 7, 18, 502);  -- This will trigger validation and not insert
SELECT * FROM races;

-- Table and procedure for logging
CREATE TABLE logs_procedure_test_1 (
    id SERIAL PRIMARY KEY,
    msg TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE PROCEDURE insert_log_test_1(msg TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO logs_procedure_test_1(msg) VALUES (msg);
END;
$$;

CALL insert_log_test_1('test insert #1');
SELECT * FROM logs_procedure_test_1;

-- Procedure with conditional insert or notice
CREATE OR REPLACE PROCEDURE add_time_if_valid(u_id INT, m_id INT, c_id INT, time_sek INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF time_sek > 488 THEN
        RAISE NOTICE 'Time is too large';
    ELSE
        INSERT INTO races(id_u, id_m, id_c, time_sec)
        VALUES (u_id, m_id, c_id, time_sek);
    END IF;
END;
$$;

CALL add_time_if_valid(1, 1, 1, 499);

-- Transaction example with explicit COMMIT (note: COMMIT inside function ends current transaction)
CREATE OR REPLACE PROCEDURE test_transaction()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO logs_procedure_test_1(msg) VALUES ('Start of transaction');
    COMMIT;
    INSERT INTO logs_procedure_test_1(msg) VALUES ('After commit');
END;
$$;
CALL test_transaction();
SELECT * FROM logs_procedure_test_1;

-- Simple logging procedure and table
CREATE TABLE events_log (
    id SERIAL PRIMARY KEY,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE PROCEDURE log_event(event_desc TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO events_log(description) VALUES (event_desc);
END;
$$;

CALL log_event('First event');
CALL log_event('Second event');
SELECT * FROM events_log;

-- Procedure with exception handling
CREATE OR REPLACE PROCEDURE insert_race_if_valid(u_id INT, m_id INT, c_id INT, time_R INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF time_R > 1000 THEN
        RAISE NOTICE 'Time is greater than 1000';
    ELSE
        INSERT INTO races(id_u, id_m, id_c, time_sec)
        VALUES (u_id, m_id, c_id, ROUND(time_R));
    END IF;
END;
$$;
CALL insert_race_if_valid(1, 11, 1, 10000);

-- PL/pgSQL DO block with cursor example
DO $$
DECLARE
    r RECORD;
    cur CURSOR FOR SELECT * FROM users;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO r;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '% %', r.id, r.user_name;
    END LOOP;
END;
$$;

-- PL/pgSQL DO block: loop through users with name starting 'B'
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT * FROM users WHERE user_name LIKE 'B%'
    LOOP
        RAISE NOTICE '% %', r.id, r.user_name;
    END LOOP;
END;
$$;

-- PL/pgSQL DO block: insert into log for short races
DO $$
DECLARE
    r RECORD;
    cur CURSOR FOR SELECT * FROM races WHERE time_sec < 400;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO r;
        EXIT WHEN NOT FOUND;
        INSERT INTO events_log(description)
        VALUES ('Short race by user ' || r.id_u || ' time ' || r.time_sec);
    END LOOP;
    CLOSE cur;
END;
$$;
SELECT * FROM events_log;

-- Exception handling example in DO block
DO $$
DECLARE
    r INT;
BEGIN
    r := 123 / 0;
    RAISE INFO '123 / 0 = %', r;
EXCEPTION WHEN OTHERS THEN
    RAISE INFO 'Division by zero occurred';
END;
$$;

-- Unique violation handling example
DO $$
BEGIN
    INSERT INTO users(id, user_name) VALUES (1, 'Test111');
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'Unique key violation occurred';
END;
$$;

-- Generic exception example
DO $$
BEGIN
    PERFORM 1/0;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'An unexpected error occurred';
END;
$$;
