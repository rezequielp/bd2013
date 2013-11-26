USE `bd2013`;
DROP procedure IF EXISTS `get_offer_1`;

DELIMITER $$
USE `bd2013`$$

-- FIXME BILL Y PRICE DEBERIAN SER FLOAT?
-- Suponemos que my_offer tiene la promo my_special o my_special is NULL
CREATE PROCEDURE `get_offer_1` (IN my_client SMALLINT,
                                IN my_offer SMALLINT,
                                IN my_special SMALLINT,
                                OUT bill SMALLINT)
BEGIN

    DECLARE benef TINYINT(2);
    DECLARE special_max_time SMALLINT UNSIGNED;

    DROP TABLE IF EXISTS offers_with_special;
    DROP TABLE IF EXISTS purchased_offers;
    DROP TABLE IF EXISTS purchased_videos;
    DROP TABLE IF EXISTS videos_to_insert;
    DROP TABLE IF EXISTS videos_to_update;

    -- -------------------------------------------------------------------------
    -- Si la oferta venia con una promo
    -- -------------------------------------------------------------------------
    IF my_special IS NOT NULL THEN
        -- Busco todas las ofertas con esta promo (incluida my_offer)
        -- que estan en el mismo grupo de ofertas que my_offer
        CREATE TEMPORARY TABLE offers_with_special
        SELECT *
        FROM offer NATURAL JOIN
            (SELECT offer_id
            FROM offer_spe
            WHERE special_id = my_special) AS t;

        -- Sumo todos los precios de las ofertas
        SELECT SUM(price)
        FROM offers_with_special
        INTO bill;

        -- ---------------------------------------------------------------------
        -- Genero una entrada en cli-spe:
        -- ---------------------------------------------------------------------
        -- Obtengo los beneficios que otorga la promo
        SELECT benefits
        FROM special
        WHERE special_id = my_special
        LIMIT 1
        INTO benef;

        -- Obtengo el max_time de la promo
        SELECT max_time
        FROM special
        WHERE special_id = my_special
        INTO special_max_time;

        INSERT INTO cli_spe
            VALUES (my_client, my_special, benef, DATE_ADD(CURDATE(), INTERVAL special_max_time DAY))
            ON DUPLICATE KEY UPDATE
                remaining_discounts = benef,
                deadline = DATE_ADD(CURDATE(), INTERVAL special_max_time DAY);

        -- ---------------------------------------------------------------------
        -- Para cada video y cada oferta de la promo, genero la entrada
        -- vid_cli, offer_cli correspondiente:
        -- ---------------------------------------------------------------------
        -- Inserto todas las ofertas de esta promo
        -- TODO deberia chequear si alguna de estas fue comprada en este mismo
        -- dia, si es asi, la updateo
        -- ASI ANDA!
        CREATE TEMPORARY TABLE purchased_offers
            SELECT *
            FROM offers_with_special
            WHERE offer_id
            NOT IN
                (SELECT offer_id
                FROM offer_cli
                WHERE client_id = my_client AND purchase_date = CURDATE());

        INSERT INTO offer_cli
            SELECT offer_id, my_client, CURDATE(), price
            FROM purchased_offers;

        -- videos que estan en ofertas correspondientes a mi promo
        CREATE TEMPORARY TABLE purchased_videos
            SELECT video_id, offer_id
            FROM
                ((SELECT video_id, offer_id FROM vid_offer)
                UNION
                (SELECT video_id, offer_id FROM vid_pkg NATURAL JOIN pkg_offer)) AS t1
                NATURAL JOIN purchased_offers;

        -- Inserto o updateo los videos en vid_cli los videos de las ofertas compradas
        INSERT INTO vid_cli
            SELECT video_id, my_client, 0, max_plays, DATE_ADD(CURDATE(), INTERVAL max_time DAY)
            FROM purchased_videos NATURAL JOIN purchased_offers
        ON DUPLICATE KEY UPDATE
            vid_cli.special_id = my_special,
            vid_cli.max_plays = vid_cli.max_plays + purchased_offers.max_plays,
            vid_cli.deadline = DATE_ADD(CURDATE(), INTERVAL purchased_offers.max_time DAY);

        END IF;

    END IF;
select * from cli_spe;
select * from offer_cli;
select * from vid_cli;
END$$

DELIMITER ;

-- source /home/eze/BD2013/svn/test.sql
-- CALL get_offer_1 (1, 1, 1, @bill);
