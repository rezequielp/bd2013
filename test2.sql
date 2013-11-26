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

-- La oferta no viene con promo asignada

SET @my_offer:= 51;
SET @cli_id:= 2;
SET @bill:= 0;
SET @currDate:= CURDATE();

DROP TABLE IF EXISTS tempOffers;
DROP TABLE IF EXISTS tempCli_SpeJoinSpe;


CREATE TEMPORARY TABLE tempOffers LIKE offer; 

-- busco la oferta que quiere comprar (es una sola)
INSERT INTO tempOffers
        SELECT *
        FROM offer
        WHERE offer_id = @my_offer;

-- ver en cli_spe si existen entradas con M>0
-- chequear en special si la fecha caduco.
CREATE TEMPORARY TABLE tempCli_SpeJoinSpe
    SELECT *
    FROM cli_spe NATURAL JOIN special
    WHERE remaining_discounts > 0 AND @currDate < deadline
        AND client_id = @cli_id;

SELECT * FROM tempOffers;
SELECT * FROM cli_spe NATURAL JOIN special;
SELECT * FROM tempCli_SpeJoinSpe;

-- si el cliente tiene una promo valida activa

-- IF EXISTS (SELECT * FROM tempCli_SpeJoinSpe) THEN

    -- busco el descuento de esta promo en special
    -- ( ESTO SE DEVUELVE) aplico el desc al precio de my_offer, en la tabla offer
 SET @bill:= 
    (SELECT price * (1 - discount/ 100)
    FROM tempOffers,
        (SELECT discount
        FROM tempCli_SpeJoinSpe) AS t);

SELECT @bill;

UPDATE cli_spe
SET remaining_discounts = remaining_discounts - 1
WHERE client_id = cli_id AND special_id = @my_special

-- para cada video en la oferta, agregar la entrada en vid_cli correspondiente
CREATE TEMPORARY TABLE videos_on_purchased_offers
    (SELECT video_id, offer_id FROM vid_offer NATURAL JOIN offer_cli)
    UNION
    (SELECT video_id, offer_id FROM vid_pkg NATURAL JOIN pkg_offer NATURAL JOIN offer_cli);
-- si ya compro la oferta el mismo dia, no hago nada (DEVUELVO MENSAJE)
--
-- IF my_offer IN (SELECT offer_id FROM vid_cli WHERE client_id = cli_id LIMIT 1) THEN










select * from cli_spe;
select * from offer_cli;
select * from vid_cli;
END$$

DELIMITER ;

-- source /home/eze/BD2013/svn/test.sql
-- CALL get_offer_1 (1, 1, 1, @bill);
