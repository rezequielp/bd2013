USE `bd2013`;
DROP TRIGGER IF EXISTS tuvieja;

DELIMITER $$
USE `bd2013`$$

CREATE TRIGGER tuvieja AFTER INSERT ON offer_spe
  FOR EACH ROW 
  BEGIN

    DECLARE is_valid TINYINT(2) UNSIGNED;
    SET is_valid = 0;

    SELECT 1
    FROM special
    WHERE requires > (SELECT COUNT(*) AS num_offers
                                FROM offer_spe
                                WHERE offer_spe.special_id = NEW.special_id)
        AND special_id = NEW.special_id
    INTO is_valid;

    IF NOT is_valid THEN
        DELETE FROM offer_spe
        WHERE offer_spe.special_id = NEW.special_id
            AND offer_spe.offer_id = NEW.offer_id;
    END IF;
  END$$


DELIMITER ;
