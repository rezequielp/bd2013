 
DROP TABLE IF EXISTS tempOffers;

CREATE TEMPORARY TABLE tempOffers LIKE offer;

DECLARE my_special TINYINT(2) UNSIGNED;
SET my_special = 30;

-- busco todas las ofertas con esta promo (incluida my_offer)
-- que estan en el mismo grupo de ofertas que my_offer
INSERT INTO tempOffers
        SELECT *
        FROM offer NATURAL JOIN
            (SELECT offer_id
            FROM offer_spe
            WHERE special_id = my_special) AS t;

-- Sumo todos los precios de las ofertas
        SELECT SUM(price)
        FROM tempOffers;
--    INTO bill;

DECLARE benef TINYINT(2) UNSIGNED;

        SELECT benefits
        FROM special
        WHERE special_id = my_special
        INTO benef;

SELECT * FROM tempOffers;

DELIMITER $$

CREATE PROCEDURE asd (OUT result TINYINT)
BEGIN
DECLARE benef TINYINT UNSIGNED;
SET benef = 7;
SELECT benef INTO result;

END$$

DELIMITER ;