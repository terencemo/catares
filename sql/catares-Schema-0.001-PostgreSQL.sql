-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Thu Nov 10 20:07:32 2011
-- 
--
-- Table: amenities
--
DROP TABLE "amenities" CASCADE;
CREATE TABLE "amenities" (
  "id" serial NOT NULL,
  "name" character varying(50) NOT NULL,
  "for_hall" bit NOT NULL,
  "for_room" bit NOT NULL,
  "rate" numeric NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: buildings
--
DROP TABLE "buildings" CASCADE;
CREATE TABLE "buildings" (
  "id" serial NOT NULL,
  "name" character varying(50) NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: roles
--
DROP TABLE "roles" CASCADE;
CREATE TABLE "roles" (
  "id" serial NOT NULL,
  "name" character varying(50) NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: timeslots
--
DROP TABLE "timeslots" CASCADE;
CREATE TABLE "timeslots" (
  "id" serial NOT NULL,
  "name" character varying(50) NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: users
--
DROP TABLE "users" CASCADE;
CREATE TABLE "users" (
  "id" serial NOT NULL,
  "name" character varying(50) NOT NULL,
  "pass" 50 NOT NULL,
  "lastlogin" timestamp NOT NULL,
  "fullname" character varying(255) NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: billings
--
DROP TABLE "billings" CASCADE;
CREATE TABLE "billings" (
  "id" serial NOT NULL,
  "booked_by" integer NOT NULL,
  "created" timestamp NOT NULL,
  "charges" numeric NOT NULL,
  "discount" numeric NOT NULL,
  "total" numeric NOT NULL,
  "deposit" numeric NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "billings_idx_booked_by" on "billings" ("booked_by");

--
-- Table: halls
--
DROP TABLE "halls" CASCADE;
CREATE TABLE "halls" (
  "id" serial NOT NULL,
  "building_id" integer NOT NULL,
  "name" character varying(50) NOT NULL,
  "descr" character varying(50) NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "halls_idx_building_id" on "halls" ("building_id");

--
-- Table: meals
--
DROP TABLE "meals" CASCADE;
CREATE TABLE "meals" (
  "id" serial NOT NULL,
  "timeslot_id" integer NOT NULL,
  "type" character varying(15) NOT NULL,
  "rate" numeric NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "meals_idx_timeslot_id" on "meals" ("timeslot_id");

--
-- Table: roomclasses
--
DROP TABLE "roomclasses" CASCADE;
CREATE TABLE "roomclasses" (
  "id" serial NOT NULL,
  "building_id" integer NOT NULL,
  "name" character varying(50) NOT NULL,
  "rate" numeric NOT NULL,
  "descr" character varying(50) NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "roomclasses_idx_building_id" on "roomclasses" ("building_id");

--
-- Table: transactions
--
DROP TABLE "transactions" CASCADE;
CREATE TABLE "transactions" (
  "id" serial NOT NULL,
  "descr" character varying(255) NOT NULL,
  "user_id" integer NOT NULL,
  "type" character varying(15) NOT NULL,
  "created" timestamp NOT NULL,
  "amount" numeric NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "transactions_idx_user_id" on "transactions" ("user_id");

--
-- Table: rooms
--
DROP TABLE "rooms" CASCADE;
CREATE TABLE "rooms" (
  "id" serial NOT NULL,
  "roomclass_id" integer NOT NULL,
  "number" character varying(10) NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "rooms_idx_roomclass_id" on "rooms" ("roomclass_id");

--
-- Table: userroles
--
DROP TABLE "userroles" CASCADE;
CREATE TABLE "userroles" (
  "id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "role_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "userroles_idx_role_id" on "userroles" ("role_id");
CREATE INDEX "userroles_idx_user_id" on "userroles" ("user_id");

--
-- Table: halltimeslots
--
DROP TABLE "halltimeslots" CASCADE;
CREATE TABLE "halltimeslots" (
  "id" serial NOT NULL,
  "timeslot_id" integer NOT NULL,
  "hall_id" integer NOT NULL,
  "start" character varying(50) NOT NULL,
  "end" character varying(50) NOT NULL,
  "rate" numeric NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "halltimeslots_idx_hall_id" on "halltimeslots" ("hall_id");
CREATE INDEX "halltimeslots_idx_timeslot_id" on "halltimeslots" ("timeslot_id");

--
-- Table: roombookings
--
DROP TABLE "roombookings" CASCADE;
CREATE TABLE "roombookings" (
  "id" serial NOT NULL,
  "billing_id" integer NOT NULL,
  "room_id" integer NOT NULL,
  "checkin" timestamp NOT NULL,
  "checkout" timestamp NOT NULL,
  "amount" numeric NOT NULL,
  "checkedout" bit NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "roombookings_idx_billing_id" on "roombookings" ("billing_id");
CREATE INDEX "roombookings_idx_room_id" on "roombookings" ("room_id");

--
-- Table: hallbookings
--
DROP TABLE "hallbookings" CASCADE;
CREATE TABLE "hallbookings" (
  "id" serial NOT NULL,
  "halltimeslot_id" integer NOT NULL,
  "date"  NOT NULL,
  "billing_id" integer NOT NULL,
  "amount" numeric NOT NULL,
  "checkedout" bit NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "hallbookings_idx_billing_id" on "hallbookings" ("billing_id");
CREATE INDEX "hallbookings_idx_halltimeslot_id" on "hallbookings" ("halltimeslot_id");

--
-- Table: roomamenitybookings
--
DROP TABLE "roomamenitybookings" CASCADE;
CREATE TABLE "roomamenitybookings" (
  "id" serial NOT NULL,
  "amenity_id" integer NOT NULL,
  "roombooking_id" integer NOT NULL,
  "count" integer NOT NULL,
  "cost" numeric NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "roomamenitybookings_idx_amenity_id" on "roomamenitybookings" ("amenity_id");
CREATE INDEX "roomamenitybookings_idx_roombooking_id" on "roomamenitybookings" ("roombooking_id");

--
-- Table: hallamenitybookings
--
DROP TABLE "hallamenitybookings" CASCADE;
CREATE TABLE "hallamenitybookings" (
  "id" serial NOT NULL,
  "amenity_id" integer NOT NULL,
  "hallbooking_id" integer NOT NULL,
  "count" integer NOT NULL,
  "cost" numeric NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "hallamenitybookings_idx_amenity_id" on "hallamenitybookings" ("amenity_id");
CREATE INDEX "hallamenitybookings_idx_hallbooking_id" on "hallamenitybookings" ("hallbooking_id");

--
-- Table: mealbookings
--
DROP TABLE "mealbookings" CASCADE;
CREATE TABLE "mealbookings" (
  "id" serial NOT NULL,
  "meal_id" integer NOT NULL,
  "booking_id" integer,
  "count" integer NOT NULL,
  "cost" numeric NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "mealbookings_idx_booking_id" on "mealbookings" ("booking_id");
CREATE INDEX "mealbookings_idx_meal_id" on "mealbookings" ("meal_id");

--
-- Foreign Key Definitions
--

ALTER TABLE "billings" ADD FOREIGN KEY ("booked_by")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "halls" ADD FOREIGN KEY ("building_id")
  REFERENCES "buildings" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "meals" ADD FOREIGN KEY ("timeslot_id")
  REFERENCES "timeslots" ("id") DEFERRABLE;

ALTER TABLE "roomclasses" ADD FOREIGN KEY ("building_id")
  REFERENCES "buildings" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "transactions" ADD FOREIGN KEY ("user_id")
  REFERENCES "users" ("id") DEFERRABLE;

ALTER TABLE "rooms" ADD FOREIGN KEY ("roomclass_id")
  REFERENCES "roomclasses" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "userroles" ADD FOREIGN KEY ("role_id")
  REFERENCES "roles" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "userroles" ADD FOREIGN KEY ("user_id")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "halltimeslots" ADD FOREIGN KEY ("hall_id")
  REFERENCES "halls" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "halltimeslots" ADD FOREIGN KEY ("timeslot_id")
  REFERENCES "timeslots" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "roombookings" ADD FOREIGN KEY ("billing_id")
  REFERENCES "billings" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "roombookings" ADD FOREIGN KEY ("room_id")
  REFERENCES "rooms" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "hallbookings" ADD FOREIGN KEY ("billing_id")
  REFERENCES "billings" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "hallbookings" ADD FOREIGN KEY ("halltimeslot_id")
  REFERENCES "halltimeslots" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "roomamenitybookings" ADD FOREIGN KEY ("amenity_id")
  REFERENCES "amenities" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "roomamenitybookings" ADD FOREIGN KEY ("roombooking_id")
  REFERENCES "roombookings" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "hallamenitybookings" ADD FOREIGN KEY ("amenity_id")
  REFERENCES "amenities" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "hallamenitybookings" ADD FOREIGN KEY ("hallbooking_id")
  REFERENCES "hallbookings" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "mealbookings" ADD FOREIGN KEY ("booking_id")
  REFERENCES "hallbookings" ("id") ON DELETE CASCADE DEFERRABLE;

ALTER TABLE "mealbookings" ADD FOREIGN KEY ("meal_id")
  REFERENCES "meals" ("id") DEFERRABLE;

ALTER TABLE "mealbookings" ADD FOREIGN KEY ("booking_id")
  REFERENCES "roombookings" ("id") ON DELETE CASCADE DEFERRABLE;

