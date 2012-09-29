DROP TABLE IF EXISTS link CASCADE;

CREATE TABLE link (
    id          SERIAL primary key,
    url         VARCHAR(255) NOT NULL,
    text        VARCHAR(255) NOT NULL,
    "entered-by" VARCHAR(255)
);

CREATE TABLE concert (
    id          SERIAL primary key,
    artist      VARCHAR(255) NOT NULL,
    "date"      DATE NOT NULL,
    location    VARCHAR(255) NOT NULL,
    link        INTEGER REFERENCES link (id) ON DELETE CASCADE,
    "entered-by" VARCHAR(255)
);
