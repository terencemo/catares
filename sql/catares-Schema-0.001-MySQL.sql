-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Thu Nov 10 20:07:32 2011
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `amenities`;

--
-- Table: `amenities`
--
CREATE TABLE `amenities` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  `for_hall` tinyint NOT NULL,
  `for_room` tinyint NOT NULL,
  `rate` double NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `buildings`;

--
-- Table: `buildings`
--
CREATE TABLE `buildings` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `roles`;

--
-- Table: `roles`
--
CREATE TABLE `roles` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `timeslots`;

--
-- Table: `timeslots`
--
CREATE TABLE `timeslots` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `users`;

--
-- Table: `users`
--
CREATE TABLE `users` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  `pass` varchar(50) NOT NULL,
  `lastlogin` datetime NOT NULL,
  `fullname` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `billings`;

--
-- Table: `billings`
--
CREATE TABLE `billings` (
  `id` integer NOT NULL auto_increment,
  `booked_by` integer NOT NULL,
  `created` datetime NOT NULL,
  `charges` double NOT NULL,
  `discount` double NOT NULL,
  `total` double NOT NULL,
  `deposit` double NOT NULL,
  INDEX `billings_idx_booked_by` (`booked_by`),
  PRIMARY KEY (`id`),
  CONSTRAINT `billings_fk_booked_by` FOREIGN KEY (`booked_by`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `halls`;

--
-- Table: `halls`
--
CREATE TABLE `halls` (
  `id` integer NOT NULL auto_increment,
  `building_id` integer NOT NULL,
  `name` varchar(50) NOT NULL,
  `descr` varchar(50) NOT NULL,
  INDEX `halls_idx_building_id` (`building_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `halls_fk_building_id` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `meals`;

--
-- Table: `meals`
--
CREATE TABLE `meals` (
  `id` integer NOT NULL auto_increment,
  `timeslot_id` integer NOT NULL,
  `type` varchar(15) NOT NULL,
  `rate` double NOT NULL,
  INDEX `meals_idx_timeslot_id` (`timeslot_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `meals_fk_timeslot_id` FOREIGN KEY (`timeslot_id`) REFERENCES `timeslots` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `roomclasses`;

--
-- Table: `roomclasses`
--
CREATE TABLE `roomclasses` (
  `id` integer NOT NULL auto_increment,
  `building_id` integer NOT NULL,
  `name` varchar(50) NOT NULL,
  `rate` double NOT NULL,
  `descr` varchar(50) NOT NULL,
  INDEX `roomclasses_idx_building_id` (`building_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `roomclasses_fk_building_id` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `transactions`;

--
-- Table: `transactions`
--
CREATE TABLE `transactions` (
  `id` integer NOT NULL auto_increment,
  `descr` varchar(255) NOT NULL,
  `user_id` integer NOT NULL,
  `type` varchar(15) NOT NULL,
  `created` datetime NOT NULL,
  `amount` double NOT NULL,
  INDEX `transactions_idx_user_id` (`user_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `transactions_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `rooms`;

--
-- Table: `rooms`
--
CREATE TABLE `rooms` (
  `id` integer NOT NULL auto_increment,
  `roomclass_id` integer NOT NULL,
  `number` varchar(10) NOT NULL,
  INDEX `rooms_idx_roomclass_id` (`roomclass_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `rooms_fk_roomclass_id` FOREIGN KEY (`roomclass_id`) REFERENCES `roomclasses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `userroles`;

--
-- Table: `userroles`
--
CREATE TABLE `userroles` (
  `id` integer NOT NULL auto_increment,
  `user_id` integer NOT NULL,
  `role_id` integer NOT NULL,
  INDEX `userroles_idx_role_id` (`role_id`),
  INDEX `userroles_idx_user_id` (`user_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `userroles_fk_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `userroles_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `halltimeslots`;

--
-- Table: `halltimeslots`
--
CREATE TABLE `halltimeslots` (
  `id` integer NOT NULL auto_increment,
  `timeslot_id` integer NOT NULL,
  `hall_id` integer NOT NULL,
  `start` varchar(50) NOT NULL,
  `end` varchar(50) NOT NULL,
  `rate` double NOT NULL,
  INDEX `halltimeslots_idx_hall_id` (`hall_id`),
  INDEX `halltimeslots_idx_timeslot_id` (`timeslot_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `halltimeslots_fk_hall_id` FOREIGN KEY (`hall_id`) REFERENCES `halls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `halltimeslots_fk_timeslot_id` FOREIGN KEY (`timeslot_id`) REFERENCES `timeslots` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `roombookings`;

--
-- Table: `roombookings`
--
CREATE TABLE `roombookings` (
  `id` integer NOT NULL auto_increment,
  `billing_id` integer NOT NULL,
  `room_id` integer NOT NULL,
  `checkin` datetime NOT NULL,
  `checkout` datetime NOT NULL,
  `amount` double NOT NULL,
  `checkedout` tinyint NOT NULL,
  INDEX `roombookings_idx_billing_id` (`billing_id`),
  INDEX `roombookings_idx_room_id` (`room_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `roombookings_fk_billing_id` FOREIGN KEY (`billing_id`) REFERENCES `billings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `roombookings_fk_room_id` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `hallbookings`;

--
-- Table: `hallbookings`
--
CREATE TABLE `hallbookings` (
  `id` integer NOT NULL auto_increment,
  `halltimeslot_id` integer NOT NULL,
  `date` datetime NOT NULL,
  `billing_id` integer NOT NULL,
  `amount` double NOT NULL,
  `checkedout` tinyint NOT NULL,
  INDEX `hallbookings_idx_billing_id` (`billing_id`),
  INDEX `hallbookings_idx_halltimeslot_id` (`halltimeslot_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `hallbookings_fk_billing_id` FOREIGN KEY (`billing_id`) REFERENCES `billings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `hallbookings_fk_halltimeslot_id` FOREIGN KEY (`halltimeslot_id`) REFERENCES `halltimeslots` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `roomamenitybookings`;

--
-- Table: `roomamenitybookings`
--
CREATE TABLE `roomamenitybookings` (
  `id` integer NOT NULL auto_increment,
  `amenity_id` integer NOT NULL,
  `roombooking_id` integer NOT NULL,
  `count` integer NOT NULL,
  `cost` double NOT NULL,
  INDEX `roomamenitybookings_idx_amenity_id` (`amenity_id`),
  INDEX `roomamenitybookings_idx_roombooking_id` (`roombooking_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `roomamenitybookings_fk_amenity_id` FOREIGN KEY (`amenity_id`) REFERENCES `amenities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `roomamenitybookings_fk_roombooking_id` FOREIGN KEY (`roombooking_id`) REFERENCES `roombookings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `hallamenitybookings`;

--
-- Table: `hallamenitybookings`
--
CREATE TABLE `hallamenitybookings` (
  `id` integer NOT NULL auto_increment,
  `amenity_id` integer NOT NULL,
  `hallbooking_id` integer NOT NULL,
  `count` integer NOT NULL,
  `cost` double NOT NULL,
  INDEX `hallamenitybookings_idx_amenity_id` (`amenity_id`),
  INDEX `hallamenitybookings_idx_hallbooking_id` (`hallbooking_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `hallamenitybookings_fk_amenity_id` FOREIGN KEY (`amenity_id`) REFERENCES `amenities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `hallamenitybookings_fk_hallbooking_id` FOREIGN KEY (`hallbooking_id`) REFERENCES `hallbookings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `mealbookings`;

--
-- Table: `mealbookings`
--
CREATE TABLE `mealbookings` (
  `id` integer NOT NULL auto_increment,
  `meal_id` integer NOT NULL,
  `booking_id` integer,
  `count` integer NOT NULL,
  `cost` double NOT NULL,
  INDEX `mealbookings_idx_booking_id` (`booking_id`),
  INDEX `mealbookings_idx_meal_id` (`meal_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `mealbookings_fk_booking_id` FOREIGN KEY (`booking_id`) REFERENCES `hallbookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mealbookings_fk_meal_id` FOREIGN KEY (`meal_id`) REFERENCES `meals` (`id`),
  CONSTRAINT `mealbookings_fk_booking_id_1` FOREIGN KEY (`booking_id`) REFERENCES `roombookings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

SET foreign_key_checks=1;

