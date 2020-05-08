/*
	Garden Database Script
	2.09.2020
	@author : Nathan Callahan
	@author : Soumya Mitra

	@description: This database is a record keeper for gardeners. It stores all information for the care of each plant in a garden 
	from sowing to harvest. It maintains a record of the weather conditions and condtion of the plant throughout the lifetime of the plant.

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
	windDirection		CHAR	 		NOT NULL	DEFAULT('N'),
	recordedDate		DATETIME		NOT NULL
);

CREATE TABLE PlantType (
	plantTypeId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantName			VARCHAR(40)		NOT NULL,
	plantBreed			VARCHAR(40)		NOT NULL,
	daysToHarvest		INT				NOT NULL	DEFAULT(0),
	description			VARCHAR(100)	NOT NULL	DEFAULT(''),
	archived			BIT				NOT NULL	DEFAULT(0)
);

CREATE TABLE Harvest (
	harvestId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantId				INT				NOT NULL,
	recordedDate		DATETIME		NOT NULL,
	numHarvest			FLOAT			NOT NULL,
	numWaste			FLOAT			NOT NULL
)


CREATE TABLE ActionTbl (
	actionId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	planted				BIT				NOT NULL	DEFAULT(0),
	watered				BIT				NOT NULL	DEFAULT(0),
	fertilized			BIT				NOT NULL	DEFAULT(0),
	depested			BIT				NOT NULL	DEFAULT(0),
	noAction			BIT				NOT NULL	DEFAULT(0)
)

CREATE TABLE LocationTbl (
	locationId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	fieldColumn			INT				NOT NULL,
	fieldRow			INT				NOT NULL,
	field				VARCHAR(30)		NOT NULL
);

--CREATE TABLE Photos (
--	photoId				INT				NOT NULL	PRIMARY KEY		IDENTITY,
--	photoPath			VARCHAR(60)		NOT NULL,
--	width				INT				NOT NULL,
--	height				INT				NOT NULL
--)

CREATE TABLE SoilCondition (
	soilCondId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	recordedDate		DATETIME		NOT NULL,
	pH					FLOAT			NOT NULL,
	moistureLvl			FLOAT			NOT NULL,
	nitrogenLvl			FLOAT			NOT NULL,
	phosoLvl			FLOAT			NOT NULL
);

CREATE TABLE Tended (
	tendedId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	actionId			INT				NOT NULL	FOREIGN KEY REFERENCES ActionTbl(actionId),
	plantId				INT				NOT NULL,
	soilCondId			INT				NOT NULL	FOREIGN KEY REFERENCES SoilCondition(soilCondId),
	recordedDate		DATETIME		NOT NULL,
	plantCondition		VARCHAR(30)		NOT NULL
);

CREATE TABLE Plant	 (					
	plantId				INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantTypeId			INT				NOT NULL	FOREIGN KEY REFERENCES PlantType(plantTypeId),
	harvestId			INT				NOT NULL	FOREIGN KEY REFERENCES Harvest(harvestId),
	tendedId			INT				NOT NULL	FOREIGN KEY REFERENCES Tended(tendedId),
	locationId			INT				NOT NULL	FOREIGN KEY REFERENCES LocationTbl(locationId),
--	photoId				INT				NOT NULL	FOREIGN KEY REFERENCES Photos(photoId),
	archived			INT				NOT NULL	DEFAULT(0)
)

ALTER TABLE Harvest ADD FOREIGN KEY (plantId) REFERENCES Plant(plantId);
ALTER TABLE Tended	ADD FOREIGN KEY (plantId) REFERENCES Plant(plantId);
GO


/*=====================================================================================================================================
														 STORED PROCEEDURES
  =====================================================================================================================================*/


                                    --*************** ADD/UPDATE/DELETE Weather *****************
CREATE PROCEDURE spAddUpdateDelete_Weather
	@weatherId			INT,	
	@humidity			INT,	
	@temperature		INT,			
	@precipitation		INT,	
	@overcast			INT,	
	@windSpeed			INT,	
	@windDirection		CHAR,	 
	@recordedDate		DATETIME,
	@delete				BIT = 0
AS BEGIN
	
BEGIN TRY
	IF(@weatherId = 0) BEGIN			-- ADD weather
		IF EXISTS (SELECT TOP(1) NULL FROM Weather WHERE weatherId = @weatherId) BEGIN
			SELECT	[message] = 'Weather ID already exists',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN

		INSERT INTO Weather	(humidity, temperature, precipitation, overcast, windSpeed, windDirection, recordedDate) VALUES
							(@humidity, @temperature, @precipitation, @overcast, @windSpeed, @windDirection, @recordedDate)
		SELECT	@@IDENTITY AS weatherId,
				[success] = CAST(1 AS BIT)
		END

	END ELSE IF(@delete = 1) BEGIN		-- DELETE weather
		IF NOT EXISTS (SELECT TOP(1) NULL FROM Weather WHERE weatherId = @weatherId) BEGIN
			SELECT	[message] = 'Weather ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN

			DELETE FROM Weather WHERE weatherId = @weatherId
			SELECT	0 as weatherId, 
					[success] = CAST(1 AS BIT)
		END

	END ELSE BEGIN						-- UPDATE weather
		IF NOT EXISTS (SELECT TOP(1) NULL FROM Weather WHERE weatherId = @weatherId) BEGIN
			SELECT	[message] = 'Weather ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			
			UPDATE Weather
			SET humidity = @humidity, temperature = @temperature, precipitation = @precipitation, 
				overcast = @overcast, windSpeed = @windSpeed, windDirection = @windDirection, recordedDate = @recordedDate
			WHERE weatherId = @weatherId

			SELECT	@weatherId as weatherId, 
					[success] = CAST(1 AS BIT)
		END

	END
END TRY BEGIN CATCH
	
	IF(@@TRANCOUNT > 0) ROLLBACK TRAN

END CATCH

	IF(@@TRANCOUNT > 0) COMMIT TRAN

END
GO



									  --*************** ADD/UPDATE/DELETE PlantType *****************
CREATE PROCEDURE spAddUpdateDelete_PlantType
	@plantTypeId		INT,	
	@plantName			VARCHAR(40),
	@plantBreed			VARCHAR(40),
	@daysToHarvest		INT,
	@description		VARCHAR(100),
	@delete				BIT = 0
AS BEGIN

BEGIN TRY
	IF(@plantTypeId = 0) BEGIN			-- ADD plantType
		IF EXISTS (SELECT TOP(1) NULL FROM PlantType WHERE PlantTypeId = @plantTypeId) BEGIN
			SELECT	[message] = 'plantType ID already exists',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN

		INSERT INTO PlantType (plantName, plantBreed, daysToHarvest, description) VALUES
							  (@plantName, @plantBreed, @daysToHarvest, @description)
		SELECT	@@IDENTITY AS plantTypeId,
				[success] = CAST(1 AS BIT)
		END

	END ELSE IF(@delete = 1) BEGIN		-- SOFT DELETE plantType
		IF NOT EXISTS (SELECT TOP(1) NULL FROM PlantType WHERE PlantTypeId = @plantTypeId) BEGIN
			SELECT	[message] = 'plantType ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			UPDATE PlantType
			SET archived = 1
			WHERE plantTypeId = @plantTypeId
			SELECT	0 as plantTypeId,
					[success] = CAST(1 AS BIT)
		END

	END ELSE BEGIN						-- UPDATE plantType
		IF NOT EXISTS (SELECT TOP(1) NULL FROM PlantType WHERE PlantTypeId = @plantTypeId) BEGIN
			SELECT	[message] = 'plantType ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			
			UPDATE PlantType
			SET plantName = @plantName, plantBreed = @plantBreed, daysToHarvest = @daysToHarvest, description = @description
			WHERE plantTypeId = @plantTypeId

			SELECT	@plantTypeId AS plantTypeId,
					[success] = CAST(1 AS BIT)
		END

	END
END TRY BEGIN CATCH
	
	IF(@@TRANCOUNT > 0) ROLLBACK TRAN

END CATCH

	IF(@@TRANCOUNT > 0) COMMIT TRAN

END
GO



                                    --*************** ADD/UPDATE Harvest *****************
CREATE PROCEDURE spAddUpdate_Harvest
	@harvestId			INT,	
	@plantId			INT,	
	@recordedDate		DATETIME,
	@numHarvest			FLOAT,
	@numWaste			FLOAT
AS BEGIN

	BEGIN TRY
	IF(@harvestId = 0) BEGIN			-- ADD Harvest
		IF EXISTS (SELECT TOP(1) NULL FROM Harvest WHERE harvestId = @harvestId) BEGIN
			SELECT	[message] = 'harvest ID already exists',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN

		INSERT INTO Harvest (plantId, recordedDate, numHarvest, numWaste) VALUES
							(@plantId, @recordedDate, @numHarvest, @numWaste)
		SELECT	@@IDENTITY AS harvestId,
				[success] = CAST(1 AS BIT)
		END

	END ELSE BEGIN						-- UPDATE Harvest
		IF NOT EXISTS (SELECT TOP(1) NULL FROM Harvest WHERE harvestId = @harvestId) BEGIN
			SELECT	[message] = 'harvest ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			
			UPDATE Harvest
			SET plantId = @plantId, recordedDate = @recordedDate, numHarvest = @numHarvest, numWaste = @numWaste

			SELECT	@harvestId AS harvestId,
					[success] = CAST(1 AS BIT)
		END

	END
END TRY BEGIN CATCH
	
	IF(@@TRANCOUNT > 0) ROLLBACK TRAN

END CATCH

	IF(@@TRANCOUNT > 0) COMMIT TRAN
END
GO



                                  --*************** ADD/UPDATE *****************

	
















             --======================================== ADD/UPDATE/ARCHIVE PLANTS ===================================
--spAddUpdateArchivePlant  
-- Adds/Updates/Archives a plant to/from the database
GO

CREATE PROCEDURE spAddUpdateDeletePlant
	@plantId		INT,
	@plantTypeId	INT,
	@harvestId		INT,
	@tendedId		INT,
	@locationId		INT,
	@archived		INT
		
AS BEGIN
									-- ====================== ADD PLANT =====================
	IF(@plantId = 0) BEGIN   
		IF EXISTS(SELECT TOP(1) NULL FROM Plants WHERE plantId = @plantId)  BEGIN
			SELECT -1 AS plantId
			PRINT 'PLANT-ID ALREADY EXISTS'
		END
		ELSE BEGIN
			INSERT INTO Plants	(plantTypeId, harvestId, tendedId, locationId, photoId) VALUES 
								(@plantTypeId, @harvestId, @tendedId, @locationId, @photoId)	

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

================= ADD/UPDATE/ARCHIVE PLANT-TYPE =====================

spAddUpdateArchivePlantType   
Adds/Updates/Archives a plant type to/from the database
GO

--	CREATE PROCEDURE spAddUpdateArchivePlantType
--		@plantTypeId			INT,
--		@plantName				VARCHAR(40),
--		@plantBreed				VARCHAR(40),
--		@daysToHarvest			INT,
--		@description			VARCHAR(100),
--		@bloomTrigger			VARCHAR(40),
--		@archived				INT
--AS BEGIN
------------------------------------
--------CREATE NEW PLANT-TYPE ------
------------------------------------
--	IF(@plantId = 0) 
--		BEGIN   
--			IF EXISTS(SELECT TOP(1) NULL FROM Plants
--			WHERE plantTypeId = @plantTypeId)  
--			BEGIN
--				SELECT -1 AS plantTypeId
--				PRINT 'PLANT-TYPE-ID ALREADY EXISTS'
--			END
--		ELSE 
--			BEGIN
--				INSERT INTO PlantType (
--					plantTypeId,	
--					plantName,
--					plantBreed,	
--					daysToHarvest,
--					description,	
--					bloomTrigger
--						)
--				VALUES (
--					@plantTypeId,
--					@plantName,
--					@plantBreed,
--					@daysToHarvest,
--					@description,
--					@bloomTrigger	
--						)
--				SELECT @@IDENTITY AS plantTypeId
--			END
--		END

-----------------------------------------
--------- ARCHIVE PLANT-TYPE PROFILE -----
-----------------------------------------
--	ELSE IF(@archived = 1) 
--	BEGIN

------ CHECKS IF PLANT-TYPE EXISTS ----
--		IF NOT EXISTS (SELECT NULL FROM PlantType WHERE plantTypeId = @plantTypeId) 
--		BEGIN
--			SELECT -1 AS plantTypeId
--			PRINT 'PLANT-TYPE-ID DOES NOT EXIST'
--		END 
--		ELSE

------CHECKS IF PLANT-TYPE ID IS LINKED IN OTHER TABLES AND SOFT DELETS IF TRUE----
--		IF	EXISTS (SELECT TOP(1) NULL FROM Plants 
--			WHERE plantTypeId = @plantTypeId)
--		BEGIN
--				UPDATE	PlantType 
--				SET		archived = 1 
--				WHERE	plantTypeId = @plantTypeId 
--				SELECT @plantTypeId AS plantTypeId
--				PRINT 'PLANT-TYPE ARCHIVED'
--		END

------HARD DELETES ROW IF PLANT-TYPE ID IS NOT LINKED TO ANY OTHER TABLES----
--		ELSE BEGIN
--			DELETE FROM plantTypeId WHERE plantTypeId = @plantTypeId
--			PRINT 'PLANT-TYPE-ID HARD DELETED'
--		END
--	END
--END

----================= LIST OF PLANTS BY TYPE =======================
----spGetPlantByType 
----Gets a list of all plants based on type
--GO
--	CREATE PROCEDURE spGetPlantByType
--		@plantTypeId			INT
--	AS
--	BEGIN
--	---- CHECKS IF PLANT-TYPE EXISTS ----
--		IF NOT EXISTS (SELECT NULL FROM PlantType WHERE plantTypeId = @plantTypeId) 
--		BEGIN
--			SELECT -1 AS plantTypeId
--			PRINT 'PLANT-TYPE-ID DOES NOT EXIST'
--		END 
--		ELSE
--			SELECT *
--			FROM Plant 
--			WHERE plantTypeId = @plantTypeId
--	END

--================= LIST OF PLANTS BY ACTION =======================
--spGetPlantsByAction 
--Get a list of plants based on the action taken on them (i.e. All plants that were watered)


--	CREATE TABLE ActionTbl (
--	actionId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
--	planted				BIT				NOT NULL,
--	watered				BIT				NOT NULL,
--	fertilized			BIT				NOT NULL,
--	depested			BIT				NOT NULL,
--	noAction			BIT				NOT NULL
--)

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
--===================================================================
--===================================================================
SELECT * FROM PlantType;
