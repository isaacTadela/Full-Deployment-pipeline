CREATE SCHEMA IF NOT EXISTS `db` ;
USE `db`;

CREATE TABLE IF NOT EXISTS `treatments` (
  id int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  fullName varchar(255) NOT NULL,
  vehicle varchar(255) NOT NULL,
  treatment varchar(255) NOT NULL,
  cost int(7) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

  updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
  mobile int(10) ZEROFILL NOT NULL,
  email varchar(255) NOT NULL,
  city varchar(255) NOT NULL,
  img varchar(255) NOT NULL,
  active BOOLEAN DEFAULT true
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS `users` (
  id int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  password varchar(255) NOT NULL,
  creation_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  modification_time DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS `customers` (
  id int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  email varchar(255) NOT NULL,
  name varchar(255) NOT NULL,
  active BOOLEAN DEFAULT false
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

