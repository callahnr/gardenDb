/*
	Garden Database Script
	2.09.2020
	@author : Nathan Callahan
	@author : Soumya Mitra

	@description: This database is a record keeper for gardeners. It stores all information for the care of each plant in a garden from sowing to harvest. It maintains a record
	of the weather conditions and condtion of the plant throughout the lifetime of the plant.
		Tables:
			-Plant: Records individual plant information
			-PlantType: Records plant species information
			-Weather: Records weather conditions
			-Havest: Records the information from a harvest. (i.e. harvested amount, date of harvest, ect.)
			-ActionTbl: A table of actions taken while tending
			-LocationTbl: Records of the location. Allows for multiple beds or fields and unlimited columns and rows per field.
			-Photos: Records the file path of photos taken of plants and stores the height and width of the images.
			-Soil: Record of soil conditions.
			-Tended: Record of tending date and actions taken (i.e. fertilized, watered, ect.)

*/

USE master;
GO

DROP DATABASE IF EXISTS Garden;
GO

CREATE DATABASE Garden;
GO

USE Garden;
GO


CREATE TABLE Weather (
	weatherId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	humidity			INT				NOT NULL,
	temperature			INT				NOT NULL,
	precipitation		INT				NOT NULL,
	overcast			INT				NOT NULL,
	windSpeed			INT				NOT NULL,
	windDirection		CHAR	 		NOT NULL DEFAULT('N'),
	dateTime			DATETIME		NOT NULL
);

CREATE TABLE PlantType (
	plantTypeId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantName			VARCHAR(40)		NOT NULL,
	plantBreed			VARCHAR(40)		NOT NULL,
	daysToHarvest		INT				NOT NULL DEFAULT(0),
	description			VARCHAR(100)	NOT NULL DEFAULT(''),
	bloomTrigger		VARCHAR(40)		NOT NULL DEFAULT('N/A')
);

CREATE TABLE Harvest (
	harvestId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantId				INT				NOT NULL,
	dateTime			DATETIME		NOT NULL,
	numHarvest			FLOAT			NOT NULL,
	numWaste			FLOAT			NOT NULL
)


CREATE TABLE ActionTbl (
	actionId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	planted				BIT				NOT NULL,
	watered				BIT				NOT NULL,
	fertilized			BIT				NOT NULL,
	depested			BIT				NOT NULL,
	noAction			BIT				NOT NULL
)

CREATE TABLE LocationTbl (
	locationId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	fieldColumn			INT				NOT NULL,
	fieldRow			INT				NOT NULL,
	field				VARCHAR(30)		NOT NULL
);

CREATE TABLE Photos (
	photoId				INT				NOT NULL	PRIMARY KEY		IDENTITY,
	photPath			VARCHAR(60)		NOT NULL,
	width				INT				NOT NULL,
	height				INT				NOT NULL
)

CREATE TABLE Soil (
	soilId				INT				NOT NULL	PRIMARY KEY		IDENTITY,
	dateTime			DATETIME		NOT NULL,
	pH					FLOAT			NOT NULL,
	moistureLvl			FLOAT			NOT NULL,
	nitrogenLvl			FLOAT			NOT NULL,
	phosoLvl			FLOAT			NOT NULL
);

CREATE TABLE Tended (
	tendedId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	actionId			INT				NOT NULL	FOREIGN KEY REFERENCES ActionTbl(actionId),
	plantId				INT				NOT NULL,
	soilId				INT				NOT NULL	FOREIGN KEY REFERENCES Soil(soilId),
	dateTimeStamp		DATETIME		NOT NULL,
	countOrWeight		BIT				NOT NULL,
	plantCondition		VARCHAR(30)		NOT NULL
);

CREATE TABLE Plant	 (					
	plantId				INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantTypeId			INT				NOT NULL	FOREIGN KEY REFERENCES PlantType(plantTypeId),
	harvestId			INT				NOT NULL	FOREIGN KEY REFERENCES Harvest(harvestId),
	tendedId			INT				NOT NULL	FOREIGN KEY REFERENCES Tended(tendedId),
	locationId			INT				NOT NULL	FOREIGN KEY REFERENCES LocationTbl(locationId),
	photoId				INT				NOT NULL	FOREIGN KEY REFERENCES Photos(photoId)
)

ALTER TABLE Harvest ADD FOREIGN KEY (plantId) REFERENCES Plant(plantId);
ALTER TABLE Tended ADD FOREIGN KEY (plantId) REFERENCES Plant(plantId);



SELECT * FROM PlantType;
