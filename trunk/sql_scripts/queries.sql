-- -----------------------------------------------------
-- Most played videos
-- -----------------------------------------------------
SELECT video_id, SUM(plays) AS plays_sum
FROM vid_offer_cli
GROUP BY video_id
ORDER BY plays_sum DESC;

-- -----------------------------------------------------
-- Videos with maximum plays
-- -----------------------------------------------------
-- Option 1
SELECT video_id, SUM(plays) AS psum
FROM vid_offer_cli
GROUP BY video_id
HAVING psum IN
    (SELECT MAX(plays_sum)
    FROM
        (SELECT SUM(plays) AS plays_sum
        FROM vid_offer_cli
        GROUP BY video_id
        ) AS tbl
    );


-- Option 2
--------------------------------------------------------
CREATE TEMPORARY TABLE tempTable
    (max_plays SMALLINT UNSIGNED NOT NULL PRIMARY KEY);

INSERT INTO tempTable (max_plays)
    SELECT MAX(plays_sum)
    FROM
        (SELECT SUM(plays) AS plays_sum
        FROM vid_offer_cli
        GROUP BY video_id
        ) AS tbl;

SELECT video_id, SUM(plays) AS psum
FROM vid_offer_cli
GROUP BY video_id
HAVING psum IN
    (SELECT * FROM tempTable);

DROP TABLE tempTable;

-- Option 3?
-----------------------------------------------------------
-- Mas eficiente pero mas largo
CREATE TEMPORARY TABLE temp1
    (video_id SMALLINT UNSIGNED NOT NULL PRIMARY KEY,
    plays_sum SMALLINT UNSIGNED NOT NULL);

CREATE TEMPORARY TABLE temp2
    (max_plays SMALLINT UNSIGNED NOT NULL PRIMARY KEY);

INSERT INTO temp1
    SELECT video_id, SUM(plays)
    FROM vid_offer_cli
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
FROM video NATURAL JOIN vid_offer_cli
GROUP BY video_id
HAVING rtsum IN
    (SELECT MAX(rtime_sum)
    FROM
        (SELECT SUM(remaining_time) AS rtime_sum
        FROM video NATURAL JOIN vid_offer_cli
        GROUP BY video_id
        ) AS tbl
    );


-- -----------------------------------------------------
-- Available plays per video, client
-- -----------------------------------------------------
SELECT video_id, client_id, max_plays - plays
FROM vid_offer_cli NATURAL JOIN offer;


-- -----------------------------------------------------
-- Available play time per video, offer
-- -----------------------------------------------------
-- VER QUE ANDE
SELECT video_id, offer_id, TO_DAYS(CURRENT_DATE()) - TO_DAYS(purchase_date) AS days
FROM vid_offer_cli NATURAL JOIN offer;
WHERE max_time >= days;

-- -----------------------------------------------------
-- Movies with maximum purchases
-- -----------------------------------------------------
SELECT video_id, COUNT(*) AS vcount
FROM vid_offer_cli
GROUP BY video_id
HAVING vcount IN
    (SELECT MAX(video_count)
    FROM
        (SELECT COUNT(*) AS video_count
        FROM vid_offer_cli
        GROUP BY video_id
        ) AS tbl
    );

-- -----------------------------------------------------
-- Most purchased movies
-- -----------------------------------------------------
SELECT video_id, COUNT(*) AS video_count
FROM vid_offer_cli
GROUP BY video_id
ORDER BY video_count DESC;

-- -----------------------------------------------------
-- Clients according their plays
-- -----------------------------------------------------
SELECT plays, client_id, name
FROM vid_offer_cli NATURAL JOIN client
ORDER BY plays ASC;

-- -----------------------------------------------------
-- Purchased movies by genre of client X
-- -----------------------------------------------------
SELECT client_id, genre, COUNT(*) AS video_count
FROM vid_offer_cli NATURAL JOIN video
GROUP BY genre
HAVING client_id = 1; -- poner client_id!


-- -----------------------------------------------------
-- Favorite genre of each client
-- -----------------------------------------------------
-- PROBAR AGRUPAR POR client_id y genre AL MISMO TIEMPO

SELECT client_id, genre, MAX(video_count)
FROM
    (SELECT client_id, genre, COUNT(*) AS video_count
    FROM vid_offer_cli NATURAL JOIN video
    GROUP BY client_id, genre
    ) AS t;

SELECT video_id
FROM video
WHERE video_id IN ((SELECT video_id
					FROM vid_pkg
					WHERE package_id IN (SELECT package_id 
										  FROM pkg_offer))
					UNION
					(SELECT video_id
					FROM vid_offer));

SELECT video_id
FROM video
WHERE video_id NOT IN (SELECT video_id
						FROM vid_offer);


