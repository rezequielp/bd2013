USE `bd2013` ;
DROP procedure IF EXISTS `get_bill` ;

DELIMITER $$
USE `bd2013`$$

-- FIXME BILL Y PRICE DEBERIAN SER FLOAT?
-- Suponemos que my_offer tiene la promo my_special o my_special is NULL
CREATE PROCEDURE `get_bill` (IN my_client SMALLINT,
                             IN my_offer SMALLINT,
                             IN my_special SMALLINT,
                             OUT bill SMALLINT)
BEGIN

    DECLARE benef TINYINT(2);
    DECLARE special_max_time SMALLINT UNSIGNED;

    DROP TABLE IF EXISTS offers_with_special;
    DROP TABLE IF EXISTS purchased_videos;
    DROP TABLE IF EXISTS videos_to_insert;
    DROP TABLE IF EXISTS videos_to_update;

    DROP TABLE IF EXISTS clients_special;

    DROP TABLE IF EXISTS purchased_offers;
    CREATE TEMPORARY TABLE purchased_offers LIKE offer;

    -- ------------------------------------------------------------------------
    -- Si la oferta venia con una promo
    -- ------------------------------------------------------------------------
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

        -- --------------------------------------------------------------------
        -- Genero una entrada en cli-spe:
        -- --------------------------------------------------------------------
        -- Obtengo los beneficios que otorga la promo
        SELECT benefits
        FROM special
        WHERE special_id = my_special
        INTO benef;

        -- Obtengo el max_time de la promo
        SELECT max_time
        FROM special
        WHERE special_id = my_special
        INTO special_max_time;

        INSERT INTO cli_spe
        VALUES (my_client, my_special, benef,
                DATE_ADD(CURDATE(), INTERVAL special_max_time DAY))
        ON DUPLICATE KEY UPDATE
            special_id = my_special,
            remaining_discounts = benef,
            deadline = DATE_ADD(CURDATE(), INTERVAL special_max_time DAY);

        -- Esto sirve para agregar en offer_cli, vid_cli:
        -- Inserto todas las ofertas de esta promo
        -- siempre y cuando no haya sido comprada en este mismo dia
        -- ASI ANDA!
        INSERT INTO purchased_offers
        SELECT *
        FROM offers_with_special
        WHERE offer_id NOT IN
            (SELECT offer_id
             FROM offer_cli
             WHERE client_id = my_client AND purchase_date = CURDATE());

    -- ------------------------------------------------------------------------
    -- Si la oferta no viene con promo asignada
    -- ------------------------------------------------------------------------
    ELSE
        -- Obtengo la oferta a comprar (es una sola)
        INSERT INTO purchased_offers
        SELECT *
        FROM offer
        WHERE offer_id NOT IN
            (SELECT offer_id
             FROM offer_cli
             WHERE client_id = my_client AND purchase_date = CURDATE())
        AND offer_id = my_offer;

        -- Si no compro la oferta en el mismo dia
        IF EXISTS (SELECT * FROM purchased_offers) THEN

            -- Buscar en cli_spe si existen entradas de special validas
            CREATE TEMPORARY TABLE clients_special
                SELECT *
                FROM cli_spe NATURAL JOIN special
                WHERE remaining_discounts > 0
                      AND CURDATE() < deadline
                      AND client_id = my_client;

            -- Si el cliente tiene una promo valida activa
            IF EXISTS (SELECT * FROM clients_special) THEN

                -- Busco el descuento de esta promo en special y lo aplico al
                -- precio de my_offer, en las ofertas compradas
                UPDATE purchased_offers JOIN
                    (SELECT discount FROM clients_special) AS t
                SET price = price * (1 - discount/ 100);

                -- Devuelvo la cuenta a cobrar
                SELECT price FROM purchased_offers INTO bill;

                -- Decremento por el uso del descuento
                UPDATE cli_spe
                SET remaining_discounts = remaining_discounts - 1
                WHERE client_id = my_client;

            END IF;
        -- Si ya compro la oferta en el mismo dia, no hago nada (DEVUELVO MENSAJE)
        ELSE
            SELECT "NO PUEDES COMPRAR UNA OFERTA MAS DE UNA VEZ POR DIA";

        END IF;
    END IF;

    -- ------------------------------------------------------------------------
    -- Para cada video y cada oferta de la promo, genero la entrada
    -- vid_cli, offer_cli correspondiente:
    -- ------------------------------------------------------------------------

    -- Registro las ofertas compradas con el precio calculado
    INSERT INTO offer_cli
    SELECT offer_id, my_client, CURDATE(), price
    FROM purchased_offers;

    -- Videos que estan en ofertas correspondientes a mi promo
    CREATE TEMPORARY TABLE purchased_videos
        SELECT video_id, offer_id
        FROM
            ((SELECT video_id, offer_id
              FROM vid_offer)
            UNION
             (SELECT video_id, offer_id
              FROM vid_pkg NATURAL JOIN pkg_offer)) AS t
            NATURAL JOIN purchased_offers;

    -- Inserto o updateo los videos en vid_cli los videos de las ofertas compradas
    INSERT INTO vid_cli
        SELECT video_id, my_client, 0, max_plays, DATE_ADD(CURDATE(), INTERVAL max_time DAY)
        FROM purchased_videos NATURAL JOIN purchased_offers
    ON DUPLICATE KEY UPDATE
        vid_cli.max_plays = vid_cli.max_plays + purchased_offers.max_plays,
        vid_cli.deadline = DATE_ADD(CURDATE(), INTERVAL purchased_offers.max_time DAY);

END$$

DELIMITER ;

-- select * from cli_spe;
-- select * from offer_cli;
-- select * from vid_cli;

-- CALL get_offer_1 (1, 1, 1, @bill);
