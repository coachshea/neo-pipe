DROP TABLE IF EXISTS player;
CREATE TABLE player(
  player_id   INTEGER   PRIMARY KEY   AUTOINCREMENT,
  first_name  TEXT      NOT NULL,
  last_name   TEXT      NOT NULL
);

DROP TABLE IF EXISTS macro;
CREATE TABLE macro(
  macro_id    INTEGER   PRIMARY KEY   AUTOINCREMENT,
  macro_name  TEXT      NOT NULL
);

DROP TABLE IF EXISTS player_macro;
CREATE TABLE player_macro(
  player_id  INTEGER,
  macro_id  INTEGER,
  FOREIGN KEY(player_id) REFERENCES player(player_id),
  FOREIGN KEY(macro_id) REFERENCES macro(macro_id)
);

.tables

SELECT player_id,
       last_name,
       first_name
FROM player;

INSERT INTO player(first_name, last_name)
VALUES("fred", "masony");

INSERT INTO player(first_name, last_name)
VALUES("john", "shea");

INSERT INTO player(first_name, last_name)
VALUES("joe", "henry");

INSERT INTO player(first_name, last_name)
VALUES("mike", "schmidt");

SELECT *
FROM player
ORDER BY last_name;
