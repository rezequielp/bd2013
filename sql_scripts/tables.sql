SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

DROP SCHEMA IF EXISTS bd2013 ;
CREATE SCHEMA IF NOT EXISTS bd2013 ;
USE bd2013 ;

-- -----------------------------------------------------
-- Table Video
-- -----------------------------------------------------
DROP TABLE IF EXISTS `video`;

CREATE TABLE `video` (
  `video_id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(100) NOT NULL,
  `genre` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`video_id`))
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table Package
-- -----------------------------------------------------
--`num_videos` TINYINT UNSIGNED NOT NULL,
DROP TABLE IF EXISTS `package` ;

CREATE TABLE IF NOT EXISTS `package` (
  `package_id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `p_description` VARCHAR(200) NOT NULL,
  `dynamic` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`package_id`))
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table Offer
-- -----------------------------------------------------
-- max_time son la cantidad de dias que se pueden reproducir los elementos
DROP TABLE IF EXISTS `offer` ;

CREATE TABLE IF NOT EXISTS `offer` (
  `offer_id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `o_description` VARCHAR(100) NOT NULL,
  `price` SMALLINT UNSIGNED NOT NULL,
  `max_plays` SMALLINT UNSIGNED NOT NULL,
  `max_time` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`offer_id`))
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table Client
-- -----------------------------------------------------
DROP TABLE IF EXISTS `client` ;

CREATE TABLE IF NOT EXISTS `client` (
  `client_id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `e-mail` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`client_id`))
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table Special
-- -----------------------------------------------------
DROP TABLE IF EXISTS `special` ;

-- max_time son la cantidad de dias que se pueden reproducir los elementos

CREATE TABLE IF NOT EXISTS `special` (
  `special_id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `requires` TINYINT(2) UNSIGNED NOT NULL,
  `benefits` TINYINT(2) UNSIGNED NOT NULL,
  `discount` TINYINT(3) UNSIGNED NOT NULL,
  `max_time` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`special_id`))
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table Vid-Pkg
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vid_pkg` ;

CREATE TABLE IF NOT EXISTS `vid_pkg` (
  `video_id` SMALLINT UNSIGNED NOT NULL,
  `package_id` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`video_id`, `package_id`),
  FOREIGN KEY (`video_id`)
    REFERENCES `video`(`video_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`package_id`)
    REFERENCES `package`(`package_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table Vid-Offer-Cli
-- -----------------------------------------------------
-- AGREGAR `max_plays` A LA DOC
-- AGREGAR `deadline` A LA DOC
-- plays y max_plays no se resetean, uno cuenta la cant. de repr. hechas y el otro las max permitidas
-- deadline tiempo calendario que marca el vencimiento de la activacion del video
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

-- -----------------------------------------------------
-- Table Vid-Offer
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vid_offer` ;

CREATE TABLE IF NOT EXISTS `vid_offer` (
  `video_id` SMALLINT UNSIGNED NOT NULL,
  `offer_id` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`video_id`, `offer_id`),
  FOREIGN KEY (`video_id`)
    REFERENCES `video`(`video_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`offer_id`)
    REFERENCES `offer`(`offer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table Pkg-Offer
-- -----------------------------------------------------
DROP TABLE IF EXISTS `pkg_offer` ;

CREATE TABLE IF NOT EXISTS `pkg_offer` (
  `package_id` SMALLINT UNSIGNED NOT NULL,
  `offer_id` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`package_id`, `offer_id`),
  FOREIGN KEY (`package_id`)
    REFERENCES `package`(`package_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`offer_id`)
    REFERENCES `offer`(`offer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table Offer-Spe
-- -----------------------------------------------------
DROP TABLE IF EXISTS `offer_spe` ;

CREATE TABLE IF NOT EXISTS `offer_spe` (
  `offer_id` SMALLINT UNSIGNED NOT NULL,
  `special_id` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`offer_id`, `special_id`),
  FOREIGN KEY (`offer_id`)
    REFERENCES `offer`(`offer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`special_id`)
    REFERENCES `special`(`special_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table Offer-Cli
-- -----------------------------------------------------
-- AGREGAR `purchase_date` A LA DOC
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

-- -----------------------------------------------------
-- Table Cli-Spe
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cli_spe` ;

-- deadline, fecha calendario que caduca
-- solo client_id es primary key para forzar solo una promo activa por cliente
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
