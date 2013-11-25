# 2

-- inserta ofertas con promo
INSERT INTO offer_cli
    SELECT offer_id, client_id, CURDATE(), price
    FROM cli_spe NATURAL JOIN offer_spe NATURAL JOIN offer;

-- ofertas que no tienen promo
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (51,47,"2014-11-14",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (52,45,"2014-11-01",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (53,1,"2014-11-04",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (54,29,"2014-11-12",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (55,15,"2014-11-21",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (56,8,"2014-11-09",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (57,20,"2014-11-20",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (58,19,"2014-11-22",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (59,2,"2014-11-15",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (60,47,"2014-11-03",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (61,15,"2014-11-18",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (62,4,"2014-11-10",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (63,4,"2014-11-18",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (64,43,"2014-11-12",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (65,21,"2014-11-16",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (66,14,"2014-11-23",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (67,19,"2014-11-11",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (68,33,"2014-11-23",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (69,28,"2014-11-10",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (70,14,"2014-11-05",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (71,30,"2014-11-02",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (72,33,"2014-11-09",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (73,36,"2014-11-14",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (74,20,"2014-11-14",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (75,1,"2014-11-09",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (76,19,"2014-11-10",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (77,15,"2014-11-16",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (78,29,"2014-11-11",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (79,3,"2014-11-06",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (80,44,"2014-11-21",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (51,17,"2014-11-18",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (52,48,"2014-11-08",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (53,19,"2014-11-10",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (54,23,"2014-11-11",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (55,19,"2014-11-07",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (56,27,"2014-11-18",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (57,44,"2014-11-18",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (58,37,"2014-11-19",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (59,7,"2014-11-18",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (60,26,"2014-11-02",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (61,16,"2014-11-20",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (62,39,"2014-11-16",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (63,27,"2014-11-13",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (64,49,"2014-11-02",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (65,21,"2014-11-09",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (66,12,"2014-11-19",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (67,8,"2014-11-10",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (68,49,"2014-11-21",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (69,35,"2014-11-21",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (70,10,"2014-11-05",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (71,36,"2014-11-08",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (72,40,"2014-11-07",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (73,48,"2014-11-06",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (74,25,"2014-11-07",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (75,35,"2014-11-09",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (76,11,"2014-11-22",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (77,6,"2014-11-05",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (78,24,"2014-11-08",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (79,5,"2014-11-17",1);
INSERT INTO `offer_cli` (`offer_id`,`client_id`,`purchase_date`,`charge`) VALUES (80,25,"2014-11-08",1);

-- asi se updatea muchas cosas en puto mysql
UPDATE offer_cli NATURAL JOIN offer
    SET offer_cli.charge = offer.price
    WHERE offer_cli.offer_id >= 51;
