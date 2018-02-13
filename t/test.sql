DROP TABLE IF EXISTS players;
create table players(
  player_id          INTEGER   PRIMARY KEY   AUTOINCREMENT,
  first_name  TEXT      NOT NULL,
  last_name   TEXT      NOT NULL
);

DROP TABLE IF EXISTS position;
create table position(
  player_id  INTEGER,
  position   TEXT      NOT NULL
  FOREIGN KEY(player_id) references(player(player_id))
);

.tables

SELECT *
FROM players;

insert into player(first_name, last_name)
values("fred", "masony");

insert into player(first_name, last_name)
values("john", "shea");

SELECT *
FROM players
ORDER BY last_name;
