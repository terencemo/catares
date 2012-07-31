-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Thu Dec  1 20:28:53 2011
-- 

BEGIN TRANSACTION;

--
-- Table: amenities
--
DROP TABLE amenities;

CREATE TABLE amenities (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(50) NOT NULL,
  for_hall bit NOT NULL,
  for_room bit NOT NULL,
  rate double NOT NULL
);

--
-- Table: buildings
--
DROP TABLE buildings;

CREATE TABLE buildings (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(50) NOT NULL
);

--
-- Table: roles
--
DROP TABLE roles;

CREATE TABLE roles (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(50) NOT NULL
);

--
-- Table: timeslots
--
DROP TABLE timeslots;

CREATE TABLE timeslots (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(50) NOT NULL
);

--
-- Table: users
--
DROP TABLE users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(50) NOT NULL,
  pass varchar(50) NOT NULL,
  lastlogin datetime NOT NULL,
  fullname varchar(255) NOT NULL
);

--
-- Table: billings
--
DROP TABLE billings;

CREATE TABLE billings (
  id INTEGER PRIMARY KEY NOT NULL,
  booked_by integer NOT NULL,
  created datetime,
  charges double,
  discount double,
  total double,
  deposit double
);

CREATE INDEX billings_idx_booked_by ON billings (booked_by);

--
-- Table: halls
--
DROP TABLE halls;

CREATE TABLE halls (
  id INTEGER PRIMARY KEY NOT NULL,
  building_id integer NOT NULL,
  name varchar(50) NOT NULL,
  descr varchar(50) NOT NULL
);

CREATE INDEX halls_idx_building_id ON halls (building_id);

--
-- Table: meals
--
DROP TABLE meals;

CREATE TABLE meals (
  id INTEGER PRIMARY KEY NOT NULL,
  timeslot_id integer NOT NULL,
  type varchar(15) NOT NULL,
  rate double NOT NULL
);

CREATE INDEX meals_idx_timeslot_id ON meals (timeslot_id);

--
-- Table: roomclasses
--
DROP TABLE roomclasses;

CREATE TABLE roomclasses (
  id INTEGER PRIMARY KEY NOT NULL,
  building_id integer NOT NULL,
  name varchar(50) NOT NULL,
  rate double NOT NULL,
  descr varchar(50) NOT NULL
);

CREATE INDEX roomclasses_idx_building_id ON roomclasses (building_id);

--
-- Table: transactions
--
DROP TABLE transactions;

CREATE TABLE transactions (
  id INTEGER PRIMARY KEY NOT NULL,
  descr varchar(255) NOT NULL,
  user_id integer NOT NULL,
  type varchar(15) NOT NULL,
  created datetime NOT NULL,
  amount double NOT NULL
);

CREATE INDEX transactions_idx_user_id ON transactions (user_id);

--
-- Table: rooms
--
DROP TABLE rooms;

CREATE TABLE rooms (
  id INTEGER PRIMARY KEY NOT NULL,
  roomclass_id integer NOT NULL,
  number varchar(10) NOT NULL
);

CREATE INDEX rooms_idx_roomclass_id ON rooms (roomclass_id);

--
-- Table: userroles
--
DROP TABLE userroles;

CREATE TABLE userroles (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id integer NOT NULL,
  role_id integer NOT NULL
);

CREATE INDEX userroles_idx_role_id ON userroles (role_id);

CREATE INDEX userroles_idx_user_id ON userroles (user_id);

--
-- Table: halltimeslots
--
DROP TABLE halltimeslots;

CREATE TABLE halltimeslots (
  id INTEGER PRIMARY KEY NOT NULL,
  timeslot_id integer NOT NULL,
  hall_id integer NOT NULL,
  start varchar(50) NOT NULL,
  end varchar(50) NOT NULL,
  rate double NOT NULL
);

CREATE INDEX halltimeslots_idx_hall_id ON halltimeslots (hall_id);

CREATE INDEX halltimeslots_idx_timeslot_id ON halltimeslots (timeslot_id);

--
-- Table: roombookings
--
DROP TABLE roombookings;

CREATE TABLE roombookings (
  id INTEGER PRIMARY KEY NOT NULL,
  billing_id integer NOT NULL,
  room_id integer NOT NULL,
  checkin datetime NOT NULL,
  checkout datetime NOT NULL,
  amount double NOT NULL,
  checkedout bit NOT NULL
);

CREATE INDEX roombookings_idx_billing_id ON roombookings (billing_id);

CREATE INDEX roombookings_idx_room_id ON roombookings (room_id);

--
-- Table: hallbookings
--
DROP TABLE hallbookings;

CREATE TABLE hallbookings (
  id INTEGER PRIMARY KEY NOT NULL,
  halltimeslot_id integer NOT NULL,
  date  NOT NULL,
  billing_id integer NOT NULL,
  amount double NOT NULL,
  checkedout bit NOT NULL
);

CREATE INDEX hallbookings_idx_billing_id ON hallbookings (billing_id);

CREATE INDEX hallbookings_idx_halltimeslot_id ON hallbookings (halltimeslot_id);

--
-- Table: roomamenitybookings
--
DROP TABLE roomamenitybookings;

CREATE TABLE roomamenitybookings (
  id INTEGER PRIMARY KEY NOT NULL,
  amenity_id integer NOT NULL,
  roombooking_id integer NOT NULL,
  count integer NOT NULL,
  cost double NOT NULL
);

CREATE INDEX roomamenitybookings_idx_amenity_id ON roomamenitybookings (amenity_id);

CREATE INDEX roomamenitybookings_idx_roombooking_id ON roomamenitybookings (roombooking_id);

--
-- Table: hallamenitybookings
--
DROP TABLE hallamenitybookings;

CREATE TABLE hallamenitybookings (
  id INTEGER PRIMARY KEY NOT NULL,
  amenity_id integer NOT NULL,
  hallbooking_id integer NOT NULL,
  count integer NOT NULL,
  cost double NOT NULL
);

CREATE INDEX hallamenitybookings_idx_amenity_id ON hallamenitybookings (amenity_id);

CREATE INDEX hallamenitybookings_idx_hallbooking_id ON hallamenitybookings (hallbooking_id);

--
-- Table: mealbookings
--
DROP TABLE mealbookings;

CREATE TABLE mealbookings (
  id INTEGER PRIMARY KEY NOT NULL,
  meal_id integer NOT NULL,
  booking_id integer,
  count integer NOT NULL,
  cost double NOT NULL
);

CREATE INDEX mealbookings_idx_booking_id ON mealbookings (booking_id);

CREATE INDEX mealbookings_idx_meal_id ON mealbookings (meal_id);

COMMIT;
