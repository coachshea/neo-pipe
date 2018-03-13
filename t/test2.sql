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

SELECT last_name, first_name
FROM player
ORDER BY last_name;
