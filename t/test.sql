DROP TABLE IF EXISTS players;
create table players(
  id          INTEGER   PRIMARY KEY   AUTOINCREMENT,
  first_name  TEXT                NOT NULL,
  last_name   TEXT                NOT NULL
);

.tables

SELECT *
FROM players;

insert into players(first_name, last_name)
values("fred", "masony");

SELECT *
FROM players
ORDER BY last_name;
