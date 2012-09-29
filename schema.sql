DROP TABLE IF EXISTS link CASCADE;

CREATE TABLE link (
    id          SERIAL primary key,
    url         VARCHAR(255) NOT NULL,
    text        VARCHAR(255) NOT NULL,
    "entered-by" VARCHAR(255)
);
