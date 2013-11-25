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
    DECLARE currDate DATE;
    SET currDate = CURDATE();

    DROP TABLE IF EXISTS tempOffers;
    CREATE TEMPORARY TABLE tempOffers LIKE offer;

    ---------------------------------------------------------------------------
    -- Si la oferta venia con una promo
    ---------------------------------------------------------------------------
    IF (my_special IS NOT NULL) THEN
        -- Busco todas las ofertas con esta promo (incluida my_offer)
        -- que estan en el mismo grupo de ofertas que my_offer
        INSERT INTO tempOffers
            SELECT *
            FROM offer NATURAL JOIN
                (SELECT offer_id
                FROM offer_spe
                WHERE special_id = my_special) AS t;

        -- Sumo todos los precios de las ofertas
        SELECT SUM(price)
        FROM tempOffers
        INTO bill;

        ------------------------------------------------------------------------
        -- Genero una entrada en cli-spe:
        ------------------------------------------------------------------------
        -- Obtengo los beneficios que otorga la promo
        DECLARE benef TINYINT(2);
        SELECT benefits
        FROM special
        WHERE special_id = my_special
        INTO benef;

        -- Obtengo el max_time de la promo
        DECLARE special_max_time;
        SELECT max_time
        FROM special
        WHERE special_id = my_special;

        -- Si ya tengo la promo, actualizo los datos
        IF my_special IN (SELECT special_id
                          FROM cli_spe
                          WHERE client_id = my_client) THEN

            UPDATE cli_spe
            SET remaining_discounts = benef
                deadline = DATE_ADD(currDate, INTERVAL special_max_time DAY)
            WHERE special_id = my_special;

        ELSE -- No la tengo, la agrego
            INSERT INTO cli_spe (client_id, special_id, remaining_discounts, initial_date)
            VALUES (my_client, my_special, benef, DATE_ADD(currDate, INTERVAL special_max_time DAY);
        END IF

        ------------------------------------------------------------------------
        -- Para cada video y cada oferta de la promo, genero la entrada
        -- vid_cli, offer_cli correspondiente:
        ------------------------------------------------------------------------
        -- videos que estan en ofertas correspondientes a mi promo
        CREATE TEMPORARY TABLE videos_from_special
            SELECT *
            FROM
                (SELECT video_id, offer_id FROM vid_offer) AS t1
                UNION
                (SELECT video_id, offer_id FROM vid_pkg NATURAL JOIN pkg_offer) AS t2
            NATURAL JOIN offer_spe
            WHERE special_id = my_special;

--         CREATE TEMPORARY TABLE asdasd
--         SELECT *
--         FROM offered_videos NATURAL JOIN offer_spe
--         WHERE special_id = my_special

        -- Inserto todos los videos de esta promo
        INSERT INTO vid_cli
            SELECT video_id, client_id, 0, max_plays, DATE_ADD(currDate, INTERVAL max_time DAY)
            FROM videos_from_special NATURAL JOIN offer;

        -- Inserto todas las ofertas de esta promo
        -- TODO deberia chequear si alguna de estas fue comprada en este mismo
        -- dia, si es asi, la updateo
        INSERT INTO offer_cli
            SELECT offer_id, client_id, currDate, price
            FROM cli_spe NATURAL JOIN offer_spe NATURAL JOIN offer;

            --FROM videos_from_special NATURAL JOIN offer_cli NATURAL JOIN offer;
        END IF
END$$

DELIMITER ;

