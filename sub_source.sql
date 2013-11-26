DROP TABLE IF EXISTS `vid_cli` ;

CREATE TABLE IF NOT EXISTS `vid_cli` (
  `video_id` SMALLINT UNSIGNED NOT NULL,
  `client_id` SMALLINT UNSIGNED NOT NULL,
  `plays` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `max_plays` SMALLINT UNSIGNED NOT NULL,
  `deadline` DATE NOT NULL,
  PRIMARY KEY (`video_id`, `client_id`),
  FOREIGN KEY (`video_id`)
    REFERENCES `video`(`video_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`client_id`)
    REFERENCES `client`(`client_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
DEFAULT CHARACTER SET = utf8;


DROP TABLE IF EXISTS `offer_cli` ;

CREATE TABLE IF NOT EXISTS `offer_cli` (
  `offer_id` SMALLINT UNSIGNED NOT NULL,
  `client_id` SMALLINT UNSIGNED NOT NULL,
  `purchase_date` DATE NOT NULL,
  `charge` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`offer_id`, `client_id`, `purchase_date`),
  FOREIGN KEY (`offer_id`)
    REFERENCES `offer`(`offer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`client_id`)
    REFERENCES `client`(`client_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
DEFAULT CHARACTER SET = utf8;


DROP TABLE IF EXISTS `cli_spe` ;

CREATE TABLE IF NOT EXISTS `cli_spe` (
  `client_id` SMALLINT UNSIGNED NOT NULL,
  `special_id` SMALLINT UNSIGNED NOT NULL,
  `remaining_discounts` TINYINT(2) UNSIGNED NOT NULL,
  `deadline` DATE NOT NULL,
  PRIMARY KEY (`client_id`),
  FOREIGN KEY (`client_id`)
    REFERENCES `client`(`client_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`special_id`)
    REFERENCES special(`special_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
DEFAULT CHARACTER SET = utf8;
