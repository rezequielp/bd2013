# 3

DROP TABLE IF EXISTS videos_on_purchased_offers;

-- estos son los videos que estan en una oferta que fue comprada
CREATE TEMPORARY TABLE videos_on_purchased_offers
    (SELECT video_id, offer_id FROM vid_offer NATURAL JOIN offer_cli)
    UNION
    (SELECT video_id, offer_id FROM vid_pkg NATURAL JOIN pkg_offer NATURAL JOIN offer_cli);

-- relaciono cada video que esta ena oferta con el cliente que compro la oferta
INSERT INTO vid_cli
    SELECT video_id, client_id, 0, max_plays, DATE_ADD(CURDATE(), INTERVAL max_time DAY)
    FROM videos_on_purchased_offers NATURAL JOIN offer_cli NATURAL JOIN offer;

DROP TABLE videos_on_purchased_offers;