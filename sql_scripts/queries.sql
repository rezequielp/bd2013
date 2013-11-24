-- -----------------------------------------------------
-- Most played videos
-- -----------------------------------------------------
SELECT video_id, SUM(plays) AS plays_sum
FROM vid_cli
GROUP BY video_id
ORDER BY plays_sum DESC;

-- -----------------------------------------------------
-- Videos with maximum plays
-- -----------------------------------------------------
-- Option 1
SELECT video_id, SUM(plays) AS psum
FROM vid_cli
GROUP BY video_id
HAVING psum IN
    (SELECT MAX(plays_sum)
    FROM
        (SELECT SUM(plays) AS plays_sum
        FROM vid_cli
        GROUP BY video_id
        ) AS tbl
    );


-- Option 2
--------------------------------------------------------
CREATE TEMPORARY TABLE tempTable
    (max_plays SMALLINT UNSIGNED NOT NULL);

INSERT INTO tempTable (max_plays)
    SELECT MAX(plays_sum)
    FROM
        (SELECT SUM(plays) AS plays_sum
        FROM vid_cli
        GROUP BY video_id
        ) AS tbl;

SELECT video_id, SUM(plays) AS psum
FROM vid_cli
GROUP BY video_id
HAVING psum IN
    (SELECT * FROM tempTable);

DROP TABLE tempTable;

-- Option 3
-----------------------------------------------------------
-- Mas eficiente pero mas largo
CREATE TEMPORARY TABLE temp1
    (video_id SMALLINT UNSIGNED NOT NULL PRIMARY KEY,
    plays_sum SMALLINT UNSIGNED NOT NULL);

CREATE TEMPORARY TABLE temp2
    (max_plays SMALLINT UNSIGNED NOT NULL);

INSERT INTO temp1
    SELECT video_id, SUM(plays)
    FROM vid_cli
    GROUP BY video_id;

INSERT INTO temp2
    SELECT MAX(plays_sum)
    FROM temp1;

SELECT video_id, plays_sum
FROM temp1
WHERE plays_sum IN (SELECT * FROM temp2);

DROP TABLE temp1;
DROP TABLE temp2;

-- -----------------------------------------------------
-- Videos with maximum remaining_time
-- ES AL PEDO ESTA CONSULTA
-- -----------------------------------------------------
SELECT video_id, SUM(remaining_time) AS rtsum
FROM video NATURAL JOIN vid_cli
GROUP BY video_id
HAVING rtsum IN
    (SELECT MAX(rtime_sum)
    FROM
        (SELECT SUM(remaining_time) AS rtime_sum
        FROM video NATURAL JOIN vid_cli
        GROUP BY video_id
        ) AS tbl
    );


-- -----------------------------------------------------
-- Remaining plays for available videos, per client
-- -----------------------------------------------------
SELECT video_id, client_id, max_plays - plays AS remaining_plays
FROM vid_cli;
WHERE remaining_plays > 0
    AND (TO_DAYS(deadline) - TO_DAYS(CURRENT_DATE())) > 0
ORDER BY client_id;


-- -----------------------------------------------------
-- Remaining play time for available videos, per client
-- -----------------------------------------------------
-- VER QUE ANDE
SELECT video_id, client_id, TO_DAYS(deadline) - TO_DAYS(CURRENT_DATE()) AS days
FROM vid_cli;
WHERE days > 0 AND (max_plays - plays) > 0
ORDER BY client_id;

-- -----------------------------------------------------
-- Most purchased movies
-- -----------------------------------------------------

-- estas son la cant. de veces que cada oferta fue comprada
CREATE TEMPORARY TABLE temp1
    (offer_id SMALLINT UNSIGNED NOT NULL PRIMARY KEY
    o_count SMALLINT UNSIGNED NOT NULL);

-- estos son los videos que estan en una oferta que fue comprada
CREATE TEMPORARY TABLE temp2
    (video_id SMALLINT UNSIGNED NOT NULL PRIMARY KEY,
    offer_id SMALLINT UNSIGNED NOT NULL PRIMARY KEY);

INSERT INTO temp1 (offer_id, o_count)
    SELECT offer_id, COUNT(*) AS o_count
    FROM offer_cli
    GROUP BY offer_id;

INSERT INTO temp2 (video_id, offer_id)
    (SELECT video_id, offer_id
    FROM temp1 NATURAL JOIN pkg_offer NATURAL JOIN vid_pkg)
    UNION
    (SELECT video_id, offer_id
    FROM vid_offer NATURAL JOIN temp1);


-- Aca el natural join es por offer_id, lo que genera una tabla con la veces que
-- fue obtenido ese video_id por la cant de veces que fue comprada esa oferta
-- y sumo esas cantidad para que me resulte el total comprado de cada video
SELECT video_id, SUM(o_count) AS purchased_count
FROM temp1 NATURAL JOIN temp2
GROUP BY video_id
ORDER BY video_id DESC;

DROP TABLE temp1;
DROP TABLE temp2;

-- -----------------------------------------------------
-- Movies with maximum purchases
-- (uso los 2 temp table de la query "Most purchased movies")
-- -----------------------------------------------------

SELECT video_id, SUM(o_count) AS purchased_count
FROM temp1 NATURAL JOIN temp2
GROUP BY video_id;
HAVING purchased_count IN (SELECT MAX(o_count)
FROM )

-- la cantidad de veces que fue comprado cada video
CREATE TEMPORARY TABLE temp3
    (video_id SMALLINT UNSIGNED NOT NULL PRIMARY KEY,
    purchased_count SMALLINT UNSIGNED NOT NULL);

-- el valor (cant. de compra) del video mas comprado
CREATE TEMPORARY TABLE temp4
    (max_purchased SMALLINT UNSIGNED NOT NULL);

INSERT INTO temp3 (video_id, purchased_count)
    SELECT video_id, SUM(o_count) AS purchased_count
    FROM temp1 NATURAL JOIN temp2
    GROUP BY video_id;

INSERT INTO temp4 (max_purchased)
    SELECT MAX(purchased_count)
    FROM temp1
    LIMIT 1;

SELECT video_id, purchased_count
FROM temp3
WHERE purchased_count IN (SELECT * FROM temp2);

DROP TABLE temp3;
DROP TABLE temp4;

-- -----------------------------------------------------
-- Clients according their plays
-- -----------------------------------------------------

SELECT client_id, name, SUM(plays) AS plays_count
FROM vid_cli NATURAL JOIN client
GROUP BY client_id
ORDER BY plays ASC;

-- -----------------------------------------------------
-- Purchased movies by genre of client X
-- -----------------------------------------------------

SELECT client_id, genre, COUNT(*) AS video_count
FROM vid_cli NATURAL JOIN video
GROUP BY genre
HAVING client_id = 1; -- poner client_id!


-- -----------------------------------------------------
-- Favorite genre of each client
-- -----------------------------------------------------

SELECT client_id, genre, MAX(video_count)
FROM
    (SELECT client_id, genre, COUNT(*) AS video_count
    FROM vid_cli NATURAL JOIN video
    GROUP BY client_id, genre
    ) AS t;

-- -----------------------------------------------------
-- Offered videos
-- -----------------------------------------------------

(SELECT video_id, offer_id
FROM vid_pkg NATURAL JOIN pkg_offer)
UNION
(SELECT video_id, offer_id
FROM vid_offer)
ORDER BY offer_id;

