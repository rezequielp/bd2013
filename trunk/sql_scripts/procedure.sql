USE `bd2013`;
DROP procedure IF EXISTS `get_offer`;

DELIMITER $$
USE `bd2013`$$

-- Suponemos que my_offer tiene la promo my_special o my_special is NULL
CREATE PROCEDURE `get_offer`(IN cli_id INT,
                             IN my_offer INT,
                             IN my_special INT,
                             OUT bill)
READS SQL DATA
BEGIN

    DECLARE currDate DATE;
    SET currDate = CURRENT_DATE();

    CREATE TEMPORARY TABLE tempOffers (
            `offer_id` SMALLINT UNSIGNED NOT NULL,
            `o_description` VARCHAR(100) NOT NULL,
            `price` SMALLINT UNSIGNED NOT NULL,
            `max_plays` SMALLINT UNSIGNED NOT NULL,
            `max_time` SMALLINT UNSIGNED NOT NULL,
            PRIMARY KEY (`offer_id`));

    -- La oferta viene con una promo
    IF my_special IS NOT NULL THEN

        -- busco todas las ofertas con esta promo (incluida my_offer)
        INSERT INTO tempOffers
        SELECT *
        FROM offer NATURAL JOIN
            (SELECT offer_id
            FROM offer_spe
            WHERE special_id = my_special);

        -- Sumo todos los precios de las ofertas
        SELECT SUM(price)
        FROM tempOffers
        INTO bill;

        -- Genero una entrada en cli-spe
        DECLARE benef TINYINT(2) UNSIGNED;

        -- obtengo los beneficios que otorga la promo
        SELECT benefits
        FROM special
        WHERE special_id = my_special
        LIMIT 1
        INTO benef

        -- ya tengo la promo, actualizo los datos
        IF my_special IN (SELECT special_id FROM cli_spe) THEN
            UPDATE cli_spe
            SET remaining_discounts = benef,
                initial_date = currDate
            WHERE special_id = my_special;
        -- no la tengo, la agrego
        ELSE
            INSERT INTO cli_spe(client_id, special_id, remaining_discounts, initial_date)
            VALUES (cli_id, my_special, benef, currDate);
        END IF

        -- esta tabla es una copia de tempoOffers (no se para que la necesitabamos)
        CREATE TEMPORARY TABLE tempOffers2 (
            `offer_id` SMALLINT UNSIGNED NOT NULL;
    
        INSERT INTO tempOffers2
        SELECT offer_id
        FROM tempOffers;
        
        -- para cada video en cada oferta de la promo, generar la entrada vid_offer_cli  		correspondiente
       ALTER TABLE tempOffers2
        ADD COLUMN cli_id SMALLINT UNSIGNED DEFAULT cli_id,
        ADD COLUMN fechaActual DATE DEFAULT currDate;
        
        -- PSEUDOCODIGO (ESTO CAMBIARLO)
        for offer in tempOffers:
            tabla =
            select video_id
            from vid_offer
            where offer_id = offer.offer_id

            for video_id in tabla
                INSERT INTO vid_offer_cli(video_id, client_id, plays)
                VALUES(video_id, cli_id, offer.plays)

    -- La oferta no viene con promo asignada
    ELSE:
        -- busco la oferta que quiere comprar
        INSERT INTO tempOffers
        SELECT *
        FROM offer
        WHERE offer_id = my_offer);

        -- ver en cli_spe si existen entradas con M>0
        -- chequear en special si la fecha caduco. (uso modo 2)
        CREATE TEMPORARY TABLE tempCli_SpeJoinSpe (
            `client_id` SMALLINT UNSIGNED NOT NULL,
            `special_id` SMALLINT UNSIGNED NOT NULL,
            `remaining_discounts` TINYINT(2) UNSIGNED NOT NULL,
            `initial_date` DATE NOT NULL,
            `special_id` SMALLINT UNSIGNED NOT NULL,
            `requires` TINYINT(2) UNSIGNED NOT NULL,
            `benefits` TINYINT(2) UNSIGNED NOT NULL,
            `discount` TINYINT(3) UNSIGNED NOT NULL,
            `deadline` DATE NOT NULL,
            `duration` TINYINT(2) UNSIGNED NOT NULL);

        INSERT INTO tempCli_SpeJoinSpe
            SELECT *
            FROM cli_spe NATURAL JOIN special
            WHERE remaining_discounts > 0 AND currDate < deadline
            -- podria ser por initial_date (pero no es lo mismo)
            ORDER BY deadline ASC
            LIMIT 1;

        -- si el cliente tiene una promo valida activa
        IF EXISTS tempCli_SpeJoinSpe THEN
            -- busco el descuento de esta promo en special
            -- ( ESTO SE DEVUELVE) aplico el desc al precio de my_offer, en la tabla offer
            SELECT price * (1 - discount/ 100)
            FROM Offer,
                (SELECT discount
                 FROM tempCli_SpeJoinSpe) AS t
            WHERE Offer.offer_id == my_offer
            INTO bill;

            -- decremento M, en cli_spe
            UPDATE cli_spe
            SET remaining_discounts = remaining_discounts - 1
            WHERE client_id = cli_id AND special_id = my_special

            -- para cada video en la oferta, agregar la entrada en vid_offer_cli correspondiente
            -- ya compro la oferta alguna otra vez, updateo
            IF my_offer IN (SELECT offer_id FROM vid_offer_cli WHERE client_id = cli_id LIMIT 1) THEN
                -- se updatean todos los videos que perteneces a my_offer
                -- no hace falta despaquetar videos si la oferta tiene paquetes
                UPDATE vid_offer_cli
                SET plays = 0,
                    purchase_date = currDate
                WHERE offer_id = my_offer AND client_id = cli_id;

            -- oferta nueva, inserto
            ELSE
                -- los videos que voy a agregar en vid_offer_cli, sin duplicados
                CREATE TEMPORARY TABLE tempVideos_id (
                `video_id` SMALLINT UNSIGNED NOT NULL,
                UNIQUE (`video_id`)
                );

                -- despaqueto los videos de cada paquete en la oferta
                -- FOR en seudocodigo
                FOR paquete_id IN pkg_offer WHERE offer_id = my_offer
                    INSERT INTO tempVideos_id
                        SELECT video_id
                        FROM vid_pkg
                        WHERE package_id = paquete_id
                -- END FOR
                -- ademas agrego posibles videos no empaquetados que esten en la oferta
                INSERT INTO tempVideos_id
                    SELECT video_id
                    FROM vid_offer
                    WHERE offer_id = my_offer

                -- le agrego las columnas 
                ALTER TABLE tempVideos_id ADD COLUMN offer_id SMALLINT DEFAULT my_offer,
                ALTER TABLE tempVideos_id ADD COLUMN client_id SMALLINT DEFAULT cli_id,
                ALTER TABLE tempVideos_id ADD COLUMN plays SMALLINT DEFAULT tempOffers.offer_id
                ALTER TABLE tempVideos_id ADD COLUMN purchase_date DEFAULT currDate,

                -- agrego la lista de video_id que obtuve, en vid_offer_cli
                INSERT INTO vid_offer_cli(video_id, offer_id, client_id)
                    SELECT *
                    FROM tempVideos_id
            END IF
            
        ELSE:
            -- ( ESTO SE DEVUELVE) busco el precio de my_offer en la tabla oferta
            -- genero entrada en cli_off
            -- para cada video en oferta generar la entrada cli_vid correspondiente 
        END IF
    END IF


        
        

END $$

DELIMITER ;
