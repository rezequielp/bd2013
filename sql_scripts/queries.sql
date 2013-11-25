-----------------------------------------------------------
-- Most played videos
-----------------------------------------------------------
SELECT video_id, SUM(plays) AS plays_sum
FROM vid_cli
GROUP BY video_id
ORDER BY plays_sum DESC;

-----------------------------------------------------------
-- Videos with maximum plays
-----------------------------------------------------------
-- Option 1
-----------------------------------------------------------
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

-----------------------------------------------------------
-- Option 2
-----------------------------------------------------------
CREATE TEMPORARY TABLE tempTable
SELECT MAX(plays_sum) AS max_plays
FROM
    (SELECT SUM(plays) AS plays_sum
    FROM vid_cli
    GROUP BY video_id) AS tbl;

SELECT video_id, SUM(plays)
FROM vid_cli
GROUP BY video_id
HAVING psum IN
    (SELECT * FROM tempTable);

DROP TABLE tempTable;

-----------------------------------------------------------
-- Option 3
-----------------------------------------------------------
-- Mas eficiente pero mas largo
CREATE TEMPORARY TABLE temp1
SELECT video_id, SUM(plays) AS plays_sum
FROM vid_cli
GROUP BY video_id;

CREATE TEMPORARY TABLE temp2
SELECT MAX(plays_sum)
FROM temp1;

SELECT video_id, plays_sum
FROM temp1
WHERE plays_sum IN (SELECT * FROM temp2);

DROP TABLE temp1;
DROP TABLE temp2;

-----------------------------------------------------------
-- Videos with maximum remaining_time
-- ES AL PEDO ESTA CONSULTA
-----------------------------------------------------------
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


-----------------------------------------------------------
-- Remaining plays for available videos, per client
-----------------------------------------------------------
SELECT video_id, client_id, max_plays - plays AS remaining_plays
FROM vid_cli
WHERE max_plays - plays > 0
    AND (TO_DAYS(deadline) - TO_DAYS(CURRENT_DATE())) > 0
ORDER BY client_id;


-----------------------------------------------------------
-- Remaining play time for available videos, per client
-----------------------------------------------------------
-- VER QUE ANDE
SELECT video_id, client_id, TO_DAYS(deadline) - TO_DAYS(CURRENT_DATE())
FROM vid_cli
WHERE TO_DAYS(deadline) - TO_DAYS(CURRENT_DATE()) > 0
    AND (max_plays - plays) > 0
ORDER BY client_id;

-----------------------------------------------------------
-- Most purchased movies
-----------------------------------------------------------

-- estas son la cant. de veces que cada oferta fue comprada
CREATE TEMPORARY TABLE num_purchased_offers
SELECT offer_id, COUNT(*) AS o_count
FROM offer_cli
GROUP BY offer_id;

-- estos son los videos que estan en una oferta que fue comprada
CREATE TEMPORARY TABLE videos_on_purchased_offers
    (SELECT video_id, offer_id FROM vid_offer NATURAL JOIN offer_cli)
    UNION
    (SELECT video_id, offer_id FROM vid_pkg NATURAL JOIN pkg_offer NATURAL JOIN offer_cli);

-- Aca el natural join es por offer_id, lo que genera una tabla con la veces que
-- fue obtenido ese video_id por la cant de veces que fue comprada esa oferta
-- y sumo esas cantidad para que me resulte el total comprado de cada video
SELECT video_id, SUM(o_count) AS purchased_count
FROM num_purchased_offers NATURAL JOIN videos_on_purchased_offers
GROUP BY video_id
ORDER BY video_id DESC;

-----------------------------------------------------------
-- Movies with maximum purchases
-- (uso los 2 temp table de la query "Most purchased movies")
-----------------------------------------------------------
--ESTAS CONSULTAS NO ANDAN

-- la cantidad de veces que fue comprado cada video
CREATE TEMPORARY TABLE temp1
    SELECT video_id, SUM(o_count) AS purchased_count
    FROM num_purchased_offers NATURAL JOIN videos_on_purchased_offers
    GROUP BY video_id;

-- el valor (cant. de compra) del video mas comprado
CREATE TEMPORARY TABLE temp2
    SELECT MAX(purchased_count)
    FROM temp1
    LIMIT 1;

SELECT video_id, purchased_count
FROM temp1
WHERE purchased_count IN (SELECT * FROM temp2);


-- Otra forma usando num_purchased_offers, videos_on_purchased_offers y temp1
SELECT video_id, SUM(o_count) AS purchased_count
FROM num_purchased_offers NATURAL JOIN videos_on_purchased_offers
GROUP BY video_id
HAVING purchased_count IN (SELECT MAX(o_count)
                            FROM temp1);



DROP TABLE temp1;
DROP TABLE temp2;
DROP TABLE num_purchased_offers;
DROP TABLE videos_on_purchased_offers;

-----------------------------------------------------------
-- Clients according their plays
-----------------------------------------------------------

SELECT client_id, name, SUM(plays) AS plays_count
FROM vid_cli NATURAL JOIN client
GROUP BY client_id
ORDER BY plays ASC;

-----------------------------------------------------------
-- Purchased movies by genre of client X
-----------------------------------------------------------

SELECT client_id, genre, COUNT(*) AS video_count
FROM vid_cli NATURAL JOIN video
GROUP BY genre
HAVING client_id = 1; -- poner client_id!


-----------------------------------------------------------
-- Favorite genre of each client
-----------------------------------------------------------

SELECT client_id, genre, MAX(video_count)
FROM
    (SELECT client_id, genre, COUNT(*) AS video_count
    FROM vid_cli NATURAL JOIN video
    GROUP BY client_id, genre
    ) AS t;

-----------------------------------------------------------
-- Offered videos
-----------------------------------------------------------

(SELECT video_id, offer_id
FROM vid_pkg NATURAL JOIN pkg_offer)
UNION
(SELECT video_id, offer_id
FROM vid_offer)
ORDER BY offer_id;
