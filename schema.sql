-- trigger function from
-- http://www.revsys.com/blog/2006/aug/04/automatically-updating-a-timestamp-column-in-postgresql/
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified = now();
    RETURN NEW;
END;
$$ language 'plpgsql';


DROP TABLE IF EXISTS user_approval CASCADE;
DROP TABLE IF EXISTS user_login CASCADE;
DROP TABLE IF EXISTS user_info  CASCADE;
DROP TABLE IF EXISTS link       CASCADE;
DROP TABLE IF EXISTS fact_link  CASCADE;
DROP TABLE IF EXISTS venue      CASCADE;
DROP TABLE IF EXISTS fact_approval CASCADE;
DROP TABLE IF EXISTS fact       CASCADE;

CREATE TABLE user_login (
    id          SERIAL              PRIMARY KEY,
    name        VARCHAR(64)         UNIQUE,
    salt        BYTEA,              /* if any of salt, pw_hash, cost are NULL, */
    cost        INTEGER,            /* it means the user cannot log in (system user) */
    pw_hash     BYTEA,
    created     TIMESTAMP           NOT NULL DEFAULT NOW(),
    modified    TIMESTAMP           NOT NULL DEFAULT NOW()
);
CREATE TRIGGER update_user_login_modtime BEFORE UPDATE on user_login FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TABLE user_info (
    id              SERIAL          PRIMARY KEY,
    login_id        INTEGER         NOT NULL REFERENCES user_login (id) ON DELETE CASCADE,
    real_name       VARCHAR(64),
    email           VARCHAR(255),
    created         TIMESTAMP       NOT NULL DEFAULT NOW(),
    modified        TIMESTAMP       NOT NULL DEFAULT NOW()
);
CREATE TRIGGER update_user_info_modtime BEFORE UPDATE ON user_info FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TABLE link (
    id          SERIAL              PRIMARY KEY,
    url         VARCHAR(255)        NOT NULL,
    text        VARCHAR(255)        NOT NULL,
    entered_by  INTEGER             NOT NULL REFERENCES user_login (id),
    created     TIMESTAMP           NOT NULL DEFAULT NOW(),
    modified    TIMESTAMP           NOT NULL DEFAULT NOW()
);
CREATE TRIGGER update_link_modtime BEFORE UPDATE ON link FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TABLE venue (
    id          SERIAL              PRIMARY KEY,
    name        VARCHAR(255)        NOT NULL,
    address     VARCHAR(255)        NOT NULL,
    lat         FLOAT,
    lon         FLOAT,
    created     TIMESTAMP           NOT NULL DEFAULT NOW(),
    modified    TIMESTAMP           NOT NULL DEFAULT NOW()
);
CREATE TRIGGER update_venue_modtime BEFORE UPDATE ON venue FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TABLE fact (
    id          SERIAL primary key,
    artist      VARCHAR(255)        NOT NULL,
    "date"      DATE,
    venue       INTEGER                      REFERENCES venue      (id),
    entered_by  INTEGER             NOT NULL REFERENCES user_login (id),
    created     TIMESTAMP           NOT NULL DEFAULT NOW(),
    modified    TIMESTAMP           NOT NULL DEFAULT NOW()
);
CREATE TRIGGER update_fact_modtime BEFORE UPDATE ON fact FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TABLE fact_link (
    id          SERIAL              PRIMARY KEY,
    fact        INTEGER             NOT NULL REFERENCES fact (id),
    link        INTEGER             NOT NULL REFERENCES link (id),
    entered_by  INTEGER             NOT NULL REFERENCES user_login (id),
    created     TIMESTAMP           NOT NULL DEFAULT NOW(),
    modified    TIMESTAMP           NOT NULL DEFAULT NOW()
);
CREATE TRIGGER update_fact_link_modtime BEFORE UPDATE ON fact_link FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TABLE fact_approval (
    id          SERIAL              PRIMARY KEY,
    fact        INTEGER             NOT NULL REFERENCES fact (id),
    by_user     INTEGER             NOT NULL REFERENCES user_login (id),
    score       INTEGER             NOT NULL DEFAULT 1,
    created     TIMESTAMP           NOT NULL DEFAULT NOW(),
    modified    TIMESTAMP           NOT NULL DEFAULT NOW()
);
CREATE TRIGGER update_fact_approval_modtime BEFORE UPDATE ON fact_approval FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TABLE user_approval (
    id          SERIAL              PRIMARY KEY,
    user_login  INTEGER             NOT NULL REFERENCES user_login (id),
    by_user     INTEGER             NOT NULL REFERENCES user_login (id),
    score       INTEGER             NOT NULL DEFAULT 1,
    created     TIMESTAMP           NOT NULL DEFAULT NOW(),
    modified    TIMESTAMP           NOT NULL DEFAULT NOW()
);
CREATE TRIGGER update_user_approval_modtime BEFORE UPDATE ON user_approval FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
