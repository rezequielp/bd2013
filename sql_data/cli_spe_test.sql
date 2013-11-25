# 1

DROP TABLE IF EXISTS temp1;
DROP TABLE IF EXISTS temp2;
DROP TABLE IF EXISTS temp3;

-- 15 clientes elegidos arbitrariamente
CREATE TEMPORARY TABLE temp1
    SELECT client_id
    FROM client
    WHERE MOD(client_id, 2) = 0
    LIMIT 15;

-- specials que estan en ofertas
CREATE TEMPORARY TABLE temp2
    SELECT DISTINCT special_id, benefits AS remaining_discounts, max_time
    FROM offer_spe NATURAL JOIN special
    WHERE MOD(special_id, 2) = 0;

-- asocio clients con specials
-- esto esta muy feo, sobre todo la concatenacion por id (fijarse como concat tablas)
CREATE TEMPORARY TABLE temp3
    SELECT * 
    FROM temp1, temp2
    WHERE client_id = special_id;

-- finalmente genero los datos en cli_spe
INSERT INTO cli_spe (client_id, special_id, remaining_discounts, deadline)
    SELECT client_id, special_id, remaining_discounts, DATE_ADD(CURDATE(), INTERVAL max_time DAY)
    FROM temp3;

DROP TABLE temp1;
DROP TABLE temp2;
DROP TABLE temp3;