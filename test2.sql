USE `bd2013`;
DROP procedure IF EXISTS `get_offer_2`;

DELIMITER $$
USE `bd2013`$$

-- FIXME BILL Y PRICE DEBERIAN SER FLOAT?
-- Suponemos que my_offer tiene la promo my_special o my_special is NULL
CREATE PROCEDURE `get_offer_2` (IN my_client SMALLINT,
                                IN my_offer SMALLINT,
                                IN my_special SMALLINT,
                                OUT bill SMALLINT)
BEGIN
    DECLARE `temp_price` SMALLINT;

    DROP TABLE IF EXISTS purchased_offer;
    DROP TABLE IF EXISTS Cli_SpeJoinSpe;
    DROP TABLE IF EXISTS purchased_videos;

    -- Si la oferta no viene con promo asignada
    IF my_special IS NULL THEN

        -- Obtengo la oferta a comprar (es una sola)
        CREATE TEMPORARY TABLE purchased_offer
            SELECT *
            FROM offer
            WHERE offer_id NOT IN
                (SELECT offer_id
                FROM offer_cli
                WHERE client_id = my_client AND purchase_date = CURDATE())
            AND offer_id = my_offer;

        IF EXISTS (SELECT * FROM purchased_offer) THEN
            -- ver en cli_spe si existen entradas con M>0
            -- chequear en special si la fecha caduco.
            CREATE TEMPORARY TABLE Cli_SpeJoinSpe
                SELECT *
                FROM cli_spe NATURAL JOIN special
                WHERE remaining_discounts > 0 AND CURDATE() < deadline
                    AND client_id = my_client;

            -- si el cliente tiene una promo valida activa
            IF EXISTS (SELECT * FROM Cli_SpeJoinSpe) THEN

                -- busco el descuento de esta promo en special
                -- ( ESTO SE DEVUELVE) aplico el desc al precio de my_offer, en la tabla offer
                SELECT price * (1 - discount/ 100)
                FROM purchased_offer,
                    (SELECT discount
                    FROM Cli_SpeJoinSpe) AS t1
                INTO bill;

                SET temp_price = bill;

                -- decremento por el uso del descuento
                UPDATE cli_spe
                SET remaining_discounts = remaining_discounts - 1
                WHERE client_id = my_client;

            ELSE
                SELECT price
                FROM purchased_offer
                INTO temp_price;

            END IF;

            -- registro la oferta con el precio calculado
            INSERT INTO offer_cli
                SELECT offer_id, my_client, CURDATE(), temp_price
                FROM purchased_offer;

            -- videos que estan en ofertas correspondientes a mi promo
            CREATE TEMPORARY TABLE purchased_videos
                SELECT video_id, offer_id
                FROM
                    ((SELECT video_id, offer_id FROM vid_offer)
                    UNION
                    (SELECT video_id, offer_id FROM vid_pkg NATURAL JOIN pkg_offer)) AS t1
                    NATURAL JOIN purchased_offer;

            -- Inserto o updateo los videos en vid_cli los videos de las ofertas compradas
            INSERT INTO vid_cli
                SELECT video_id, my_client, 0, max_plays, DATE_ADD(CURDATE(), INTERVAL max_time DAY)
                FROM purchased_videos NATURAL JOIN purchased_offer
            ON DUPLICATE KEY UPDATE
                vid_cli.max_plays = vid_cli.max_plays + purchased_offer.max_plays,
                vid_cli.deadline = DATE_ADD(CURDATE(), INTERVAL purchased_offer.max_time DAY);

        -- si ya compro la oferta el mismo dia, no hago nada (DEVUELVO MENSAJE)
        ELSE
            SELECT "NO PUEDES COMPRAR UNA OFERTA MAS DE UNA VEZ POR DIA";
        END IF;

    END IF;

select price from purchased_offer;
select * from cli_spe;
select * from offer_cli;
select * from vid_cli;
END$$

DELIMITER ;

-- source /home/eze/BD2013/svn/test2.sql
-- CALL get_offer_2 (1, 1, 1, @bill);
