-- Example of a function with a SQL injection vulnerability (unsafe dynamic SQL)
CREATE OR REPLACE FUNCTION get_user_by_username_unsafe(in_username TEXT)
RETURNS SETOF users AS $$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT * FROM users WHERE user_name = ''' || in_username || '''';
END;
$$ LANGUAGE plpgsql;

-- Safer version using parameterized query with EXECUTE...USING
CREATE OR REPLACE FUNCTION get_user_by_username_safe(in_username TEXT)
RETURNS SETOF users AS $$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT * FROM users WHERE user_name = $1'
    USING in_username;
END;
$$ LANGUAGE plpgsql;

-- Using pgcrypto for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE secure_users (
    id SERIAL PRIMARY KEY,
    username TEXT,
    password_hash TEXT
);

-- Insert a user with a hashed password
INSERT INTO secure_users (username, password_hash)
VALUES ('user1', crypt('mySecretPassword', gen_salt('bf')));

-- Verify password by comparing with hash
SELECT username
FROM secure_users
WHERE username = 'user1'
  AND password_hash = crypt('mySecretPassword', password_hash);
