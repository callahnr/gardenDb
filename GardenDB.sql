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

--===================================================================
--======================== TABLES ===================================
--===================================================================


CREATE TABLE Weather (
	weatherId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	humidity			INT				NOT NULL,
	temperature			INT				NOT NULL,
	precipitation		INT				NOT NULL,
	overcast			INT				NOT NULL,
	windSpeed			INT				NOT NULL,
	windDirection		CHAR	 		NOT NULL DEFAULT('N'),
	dateTimeStamp		DATETIME		NOT NULL
);

CREATE TABLE PlantType (
	plantTypeId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantName			VARCHAR(40)		NOT NULL,
	plantBreed			VARCHAR(40)		NOT NULL,
	daysToHarvest		INT				NOT NULL DEFAULT(0),
	description			VARCHAR(100)	NOT NULL DEFAULT(''),
	archived			INT				NOT NULL DEFAULT(0)
);

CREATE TABLE Harvest (
	harvestId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantId				INT				NOT NULL,
	dateTimeStamp		DATETIME		NOT NULL,
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
	fieldName			VARCHAR(30)		NOT NULL,
	fieldColumn			INT				NOT NULL	DEFAULT(-1),
	fieldRow			INT				NOT NULL	DEFAULT(-1)
);

CREATE TABLE Photos (
	photoId				INT				NOT NULL	PRIMARY KEY		IDENTITY,
	photPath			VARCHAR(60)		NOT NULL,
	width				INT				NOT NULL,
	height				INT				NOT NULL
)

CREATE TABLE Soil (
	soilId				INT				NOT NULL	PRIMARY KEY		IDENTITY,
	dateTimeStamp		DATETIME		NOT NULL,
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
	plantTypeId			INT				NOT NULL				FOREIGN KEY REFERENCES PlantType(plantTypeId),
	locationId			INT				NOT NULL				FOREIGN KEY REFERENCES LocationTbl(locationId),
	harvestId			INT				FOREIGN KEY REFERENCES Harvest(harvestId),
	tendedId			INT				FOREIGN KEY REFERENCES Tended(tendedId),
	photoId				INT				FOREIGN KEY REFERENCES Photos(photoId),
	archived			INT				NOT NULL	DEFAULT(0)
)

ALTER TABLE Harvest ADD FOREIGN KEY (plantId) REFERENCES Plant(plantId);
ALTER TABLE Tended ADD FOREIGN KEY (plantId) REFERENCES Plant(plantId);


--===================================================================
--================= STORED PROCEEDURES ==============================
--===================================================================


--================= ADD/UPDATE/ARCHIVE PLANTS =======================
--spAddUpdateArchivePlant  
-- Adds/Updates/Archives a plant to/from the database
GO

	CREATE PROCEDURE spAddUpdateDeletePlant
		@plantId		INT,
		@plantTypeId	INT,
		@harvestId		INT,
		@tendedId		INT,
		@locationId		INT,
		@photoId		INT,
		@archived		INT
		
AS BEGIN
----------------------------------
------CREATE NEW PLANT PROFILE----
----------------------------------
	IF(@plantId = 0) BEGIN   
		IF EXISTS(SELECT TOP(1) NULL FROM Plants
		WHERE plantId = @plantId)  BEGIN
			SELECT -1 AS plantId
			PRINT 'PLANT-ID ALREADY EXISTS'
		END
		ELSE BEGIN
			INSERT INTO Plants (
				plantId,	
				plantTypeId,
				harvestId,
				tendedId,
				locationId,
				photoId	
					)
			VALUES (
				@plantId,
				@plantTypeId,
				@harvestId,
				@tendedId,
				@locationId,
				@photoId	
				 )
			SELECT @@IDENTITY AS plantId
		END
	END 

----------------------------------
------- ARCHIVE PLANT PROFILE ----
----------------------------------
	ELSE IF(@archived = 1) BEGIN

---- CHECKS IF PLANT EXISTS ----
		IF NOT EXISTS (SELECT NULL FROM users WHERE plantId = @plantId) BEGIN
			SELECT -1 AS plantId
			PRINT 'PLANT-ID DOES NOT EXIST'
		END ELSE

----CHECKS IF PLANT ID IS LINKED IN OTHER TABLES AND SOFT DELETS IF TRUE----
		IF	EXISTS (SELECT TOP(1) NULL FROM Harvest 
			WHERE plantId = @plantId) OR
			EXISTS (SELECT TOP(1) NULL FROM Tended 
			WHERE plantId = @plantId) BEGIN
				UPDATE	Plants 
				SET		archived = 1 
				WHERE	plantId = @plantId 
				SELECT @plantId AS plantId
				PRINT 'PLANT ARCHIVED'
		END

----HARD DELETES ROW IF PLANT ID IS NOT LINKED TO ANY OTHER TABLES----
		ELSE BEGIN
			DELETE FROM Plants WHERE plantId = @plantId
			PRINT 'PLANT-ID HARD DELETED'
		END
	END
END

--================= ADD/UPDATE/ARCHIVE PLANT-TYPE =====================

--spAddUpdateArchivePlantType   
--Adds/Updates/Archives a plant type to/from the database
GO

	CREATE PROCEDURE spAddUpdateArchivePlantType
		@plantTypeId			INT,
		@plantName				VARCHAR(40),
		@plantBreed				VARCHAR(40),
		@daysToHarvest			INT,
		@description			VARCHAR(100),
		@archived				INT
AS BEGIN
----------------------------------
------CREATE NEW PLANT-TYPE ------
----------------------------------
	IF(@plantTypeId = 0) 
		BEGIN   
			IF EXISTS(SELECT TOP(1) NULL FROM Plants
			WHERE plantTypeId = @plantTypeId)  
			BEGIN
				SELECT -1 AS plantTypeId
				PRINT 'PLANT-TYPE-ID ALREADY EXISTS'
			END
		ELSE 
			BEGIN
				INSERT INTO PlantType (
					plantTypeId,	
					plantName,
					plantBreed,	
					daysToHarvest,
					description	
				)
				VALUES (
					@plantTypeId,
					@plantName,
					@plantBreed,
					@daysToHarvest,
					@description
				)
				SELECT @@IDENTITY AS plantTypeId
			END
		END

---------------------------------------
------- ARCHIVE PLANT-TYPE PROFILE -----
---------------------------------------
	ELSE IF(@archived = 1) 
	BEGIN

---- CHECKS IF PLANT-TYPE EXISTS ----
		IF NOT EXISTS (SELECT NULL FROM PlantType WHERE plantTypeId = @plantTypeId) 
		BEGIN
			SELECT -1 AS plantTypeId
			PRINT 'PLANT-TYPE-ID DOES NOT EXIST'
		END 
		ELSE

----CHECKS IF PLANT-TYPE ID IS LINKED IN OTHER TABLES AND SOFT DELETS IF TRUE----
		IF	EXISTS (SELECT TOP(1) NULL FROM Plants 
			WHERE plantTypeId = @plantTypeId)
		BEGIN
				UPDATE	PlantType 
				SET		archived = 1 
				WHERE	plantTypeId = @plantTypeId 
				SELECT @plantTypeId AS plantTypeId
				PRINT 'PLANT-TYPE ARCHIVED'
		END

----HARD DELETES ROW IF PLANT-TYPE ID IS NOT LINKED TO ANY OTHER TABLES----
		ELSE BEGIN
			DELETE FROM plantTypeId WHERE plantTypeId = @plantTypeId
			PRINT 'PLANT-TYPE-ID HARD DELETED'
		END
	END
END

--================= LIST OF PLANTS BY TYPE =======================
--spGetPlantByType 
--Gets a list of all plants based on type
GO
	CREATE PROCEDURE spGetPlantByType
		@plantTypeId			INT
	AS
	BEGIN
	---- CHECKS IF PLANT-TYPE EXISTS ----
		IF NOT EXISTS (SELECT NULL FROM PlantType WHERE plantTypeId = @plantTypeId) 
		BEGIN
			SELECT -1 AS plantTypeId
			PRINT 'PLANT-TYPE-ID DOES NOT EXIST'
		END 
		ELSE
			SELECT *
			FROM Plant 
			WHERE plantTypeId = @plantTypeId
	END

--================= LIST OF PLANTS BY ACTION =======================
--spGetPlantsByAction 
--Get a list of plants based on the action taken on them (i.e. All plants that were watered)
--spGetPlantsTendedByPlantType --Get a list 
--spGetPlantsTendedByDate --Get a list of all plants tended on a specific day
--spGetHarvestByPlantType --Get a sum of all harvests by plant type
--spGetHarvestByPlant --Get the harvest of an individual plant
--spGetWeatherByDate --Get all weather data of a specific date
--spGetPrecipByDate --Get precipitation of a specific date
--spGetSoilByPlant --Get soil conditions of a plant listed by date
--spGetSoilListByPh --Get soil list by pH range ordered by location
--spGetPlantConditionByDate --Get conditions recorded of all plants by date
--spGetLocByPlantType --Get the locations (col, row, field) of all plants of a type
--spGetLocByPlant --Get the specific location (column, row, field) of one plant
--spGetPhotosByType --Get all photos (path/to/photos) returned by plant type
--spAddDeletePhoto --Add/Delete photos (path/to/photos) of a specific plant or type
--spErrorRecord --Record database errors

--===================================================================
--========================= DATA ====================================
--===================================================================


INSERT INTO PlantType (	plantName, plantBreed, daysToHarvest )
VALUES 
('Cilantro', 'Common', 0),
('Cilantro', 'Coriandrum sativum', 0),
('Corn', 'Sweet - Bilicious Hybrid', 0),
('Kohlrabi', 'Early White Vienna', 0),
('Hot Pepper', 'Jalapeno Early',0),
('Melon', 'Watermelon - Orange Tendersweet', 0),
('Cucumber', ' PickelBush', 0),
('Tomato', 'Roma ', 0),
('Sweet Pepper', ' Carnival Blend', 0),
('Hot Pepper', ' Salsa Blend', 0),
('Melon', 'Watermelon - Jubilee', 0),
('Eggplant', ' Black Beauty', 0),
('Tomato', ' Best Boy Hybrid', 0),
('Cucumber', ' Poinsett', 0),
('Squash', ' Scallop', 0),
('Melon', ' Honey Rock', 0),
('Squash', 'Blue Hubbard', 0),
('Beet', 'Detroit Dark Red', 0),
('Melon', 'Cantaloupe - Hearts of Gold', 0),
('Melon', 'Watermelon - Sugar Baby', 0),
('Cucumber', 'Boston Pickling', 0),
('Squash', 'Waltham Butternut', 0),
('Squash', 'Table Queen', 0),
('Squash', 'Vegetable Spaghetti', 0),
('Tomato', 'Striped Stuffer', 0),
('Squash', 'Acorn', 0),
('Salsify', 'Mammoth Sandwich Island', 0),
('Cucumber', 'Straight Eight', 0),
('Pumpkin', 'Small Sugar', 0),
('Mustard', 'Old Fashioned', 0),
('Eggplant', 'Long Purple', 0),
('Dill', 'Mammoth Long Island', 0),
('Parsnip', 'Harris Model', 0),
('Parsnip', 'Hollow Crown', 0),
('Borage', 'Common', 0),
('Mustard', 'Southern Giant Curled', 0),
('Melon', 'Hales Best Jumbo', 0),
('Melon', 'Watermelon - Charleston Grey', 0),
('Bean', 'Fava - Broad Windsor', 0),
('Coriander', 'Long Standing', 0),
('Okra', 'Red Burgundy', 0),
('Cumin', 'Common', 0),
('Thyme', 'Winter', 0),
('Yarrow', 'White', 0),
('Squash', 'Dark Green Zucchini', 0),
('Parsley', 'Moss Curled', 0),
('Bean', 'Lima', 0),
('Okra', 'Perkins Long Pod', 0),
('Amaranth', 'Red Garnet', 0),
('Fennel', 'Florence', 0),
('Basil', 'Italian Large Leaf', 0),
('Caraway', 'Common', 0),
('Melon', 'Watermelon - Black Diamond', 0),
('Pea', 'Green Arrow', 0),
('Pumpkin', 'Mammoth Gold', 0),
('Tomato', 'Floradade', 0),
('Tomato', 'Costoluto Genovese', 0),
('Tomato', 'Brandywine Red', 0),
('Tomato', 'Ace 55', 0),
('Tomato', 'Marglobe Improved', 0),
('Tomato', 'San Marzano', 0),
('Tomato', 'Yellow Pear', 0),
('Tomato', 'Rutgers', 0),
('Tomato', 'Marion', 0),
('Tomato', 'Beefsteak Red', 0),
('Tomato', 'Azoyehka', 0),
('Tomato', 'Chocolate Stripes', 0),
('Tomato', 'Cherokee Purple', 0),
('Tomato', 'Golden Jubilee', 0),
('Tomato', 'Homestead 24', 0),
('Squash', 'Cocozelle', 0),
('Bean', 'Green - Blue Lake (Bush)', 0),
('Pea', 'Little Marvel', 0),
('Bean', 'Golden Wax', 0),
('Pea', 'Sugar Ann', 0),
('Corn', 'Sweet - Golden Bantam', 0)

INSERT INTO LocationTbl ( fieldName, fieldColumn, fieldRow  )
VALUES ('NORTH', 1, 1),('NORTH', 1, 2),('NORTH', 1, 3),('NORTH', 1, 4), ('NORTH', 1, 5), ('NORTH', 2, 1), ('NORTH', 2, 2), ('NORTH', 2, 3), ('NORTH', 2, 4), ('NORTH', 2, 5)

INSERT INTO Plant ( plantTypeId, locationId )
VALUES			  ( 1, 1 ), ( 1, 2), ( 1, 3 ), ( 1, 4 ) 

SELECT * FROM Plant
SELECT * FROM PlantType
SELECT * FROM LocationTbl