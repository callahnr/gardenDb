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
	windDirection		CHAR	 		NOT NULL	DEFAULT('N'),
	recordedDate		DATETIME		NOT NULL
);

CREATE TABLE PlantType (
	plantTypeId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantName			VARCHAR(40)		NOT NULL,
	plantBreed			VARCHAR(40)		NOT NULL,
	daysToHarvest		INT				NOT NULL	DEFAULT(0),
	description			VARCHAR(5000)	NOT NULL	DEFAULT(''),
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
	fieldName			VARCHAR(30)		NOT NULL,
	fieldColumn			INT				NOT NULL,
	fieldRow			INT				NOT NULL
	
);

CREATE TABLE SoilCondition (
	soilCondId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	recordedDate		DATETIME		NOT NULL,
	pH					FLOAT			NOT NULL,
	moistureLvl			FLOAT			NOT NULL,
	nitrogenLvl			FLOAT			NOT NULL,
	phosoLvl			FLOAT			NOT NULL
);

CREATE TABLE Plant	 (					
	plantId				INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantTypeId			INT				NOT NULL	FOREIGN KEY REFERENCES PlantType(plantTypeId),
	locationId			INT				NOT NULL	FOREIGN KEY REFERENCES LocationTbl(locationId),
	archived			INT				NOT NULL	DEFAULT(0)
);

CREATE TABLE Tended (
	tendedId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	actionId			INT				NOT NULL	FOREIGN KEY REFERENCES ActionTbl(actionId),
	plantId				INT				NOT NULL	FOREIGN KEY REFERENCES Plant(plantId),
	soilCondId			INT				NOT NULL	FOREIGN KEY REFERENCES SoilCondition(soilCondId),
	recordedDate		DATETIME		NOT NULL,
	plantCondition		VARCHAR(30)		NOT NULL
);



-- ALTER TABLE Harvest ADD FOREIGN KEY (plantId) REFERENCES Plant(plantId);
--ALTER TABLE Tended	ADD FOREIGN KEY (plantId) REFERENCES Plant(plantId);

GO






--SET IDENTITY_INSERT SoilCondition ON
--INSERT INTO SoilCondition (soilCondId, recordedDate, pH, moistureLvl, nitrogenLvl, phosoLvl) 
--VALUES 
--(1,   '11/21/2019', -3.6, 0.98, 0.52, 0.24),
--(2,   '2/8/2020',    5.9, 0.22, 0.99, 0.53),
--(3,   '10/1/2019',   0.2, 0.47, 0.12, 0.39),
--(4,   '6/10/2019',   5.6, 0.67, 0.55, 0.01),
--(5,   '2/20/2020',   3.9, 0.8, 0.9, 0.26),
--(6,   '4/21/2020',   2.6, 0.57, 0.89, 0.99),
--(7,   '4/16/2020',  -3.4, 0.12, 0.73, 0.99),
--(8,   '10/13/2019',  3.4, 0.75, 0.49, 0.01),
--(9,   '9/16/2019',  -5.1, 0.46, 0.91, 0.23),
--(10,  '10/17/2019', -2.1, 0.13, 0.92, 0.79)
--SET IDENTITY_INSERT SoilCondition OFF
--SELECT * FROM SoilCondition


--SET IDENTITY_INSERT Harvest ON
--INSERT INTO Harvest (harvestId, plantId, recordedDate, numHarvest, numWaste) 
--VALUES 
--(1, 1, '6/10/2019', 8, 18),
--(2, 2, '11/15/2019', 51, 3),
--(3, 3, '12/10/2019', 48, 8),
--(4, 4, '11/13/2019', 86, 16),
--(5, 5, '10/28/2019', 88, 6),
--(6, 6, '2/5/2020', 62, 14),
--(7, 7, '12/19/2019', 93, 3),
--(8, 8, '9/27/2019', 64, 1),
--(9, 9, '8/6/2019', 55, 1),
--(10,10, '4/16/2020', 1, 14)
--SET IDENTITY_INSERT Harvest OFF
--SELECT * FROM Harvest




--SET IDENTITY_INSERT LocationTbl ON
--INSERT INTO LocationTbl (locationId, fieldName, fieldColumn, fieldRow) 
--VALUES
--(1, 'NORTH',   1, 1),
--(2, 'NORTH',   1, 2),
--(3, 'NORTH',   1, 3),
--(4, 'NORTH',   1, 4),
--(5, 'NORTH',   1, 5),
--(6, 'NORTH',   1, 6),
--(7, 'NORTH',   1, 7),
--(8, 'NORTH',   1, 8),
--(9, 'NORTH',   1, 9),
--(10,'NORTH',  1, 10)
--SET IDENTITY_INSERT LocationTbl OFF
--SELECT * FROM LocationTbl
--ORDER BY fieldColumn, fieldRow



--SET IDENTITY_INSERT PlantType ON
--INSERT INTO PlantType (plantName, plantBreed, daysToHarvest, description )
--VALUES 
--('Cilantro', 'Common', 0, 'The highly aromatic, rich and spicy Cilantro adds the perfect flavor to any cuisine! This plant is ideal for harvesting both the cilantro leaves and coriander seeds. The unique flavor of this cilantro is bold and bright with a touch of citrus undertones.'),
--('Cilantro', 'Coriandrum sativum', 0, 'Coriander is an annual herb in the family Apiaceae. It is also known as Chinese parsley, and in the United States the stems and leaves are usually called cilantro'),
--('Corn', 'Bilicious Hybrid', 0, 'Bi-Licious is an excellent mid-season hybrid with bi-colored kernels maturing in 75 or more days. Ears are 8 1/2 inches with 16 rows of kernels. Corn is a warm season crop. Pollination is essential for success so corn needs to be planted in a block of three rows of 12-24 plants (rather than one row).'),
--('Kohlrabi', 'Early White Vienna', 0, 'Round, above-ground "bulbs" with light green, smooth skin have creamy white, tender flesh. Flavor is mild, sweet, turnip-like. Superb raw or steamed. Ready for harvest 55 days from seed sowing.'),
--('Hot Pepper', 'Jalapeno Early',0, 'Cooks Garden Favorite. Dark green, pungent 3" hot peppers are excellent fresh or pickled. Zesty flavor is great in Mexican dishes.' ),
--('Watermelon', 'Orange Tendersweet', 0, 'This heirloom favorite features luscious, bright orange flesh. Tender and very sweet, the oblong striped fruits grow to 35 lb.')
--SET IDENTITY_INSERT PlantType OFF
--SELECT * FROM PlantType



--SET IDENTITY_INSERT Plant ON
--INSERT INTO Plant (plantId, plantTypeId, locationId, harvestId, tendedId) 
--VALUES
--(1,   1,  1,  1,  1),
--(2,   2,  2,  2,  2),
--(3,   3,  3,  3,  3),
--(4,   4,  4,  4,  4),
--(5,   4,  5,  5,  5),
--(6,   2,  6,  6,  6),
--(7,   6,  7,  7,  7),
--(8,   3,  8,  8,  8),
--(9,   1,  9,  9,  9),
--(10,  5, 10, 10, 10)
--SET IDENTITY_INSERT Plant OFF
--SELECT * FROM Plant

--SET IDENTITY_INSERT ActionTbl ON
--INSERT INTO ActionTbl (actionId, planted, watered, fertilized, depested, noAction) 
--VALUES (1, 1, 0, 0, 0, 0),
--(2, 1, 1, 1, 0, 0),
--(3, 0, 0, 0, 0, 0),
--(4, 1, 1, 0, 0, 0),
--(5, 0, 1, 0, 0, 0),
--(6, 0, 1, 0, 1, 0),
--(7, 1, 1, 1, 0, 0),
--(8, 1, 1, 1, 1, 0),
--(9, 0, 1, 0, 1, 0),
--(10, 0, 1, 0, 0, 0)
--SET IDENTITY_INSERT ActionTbl OFF
--SELECT * FROM ActionTbl

--SET IDENTITY_INSERT Tended ON
--INSERT INTO Tended (tendedId, actionId, plantId, soilCondId, recordedDate, countOrWeight, plantCondition) 
--VALUES 
--(1, 1, 1, 1, '11/21/2019', 1, 'INFESTED'),
--(2, 2, 2, 2, '2/8/2020', 0, 'DEHYDRATED'),
--(3, 3, 3, 3, '10/1/2019', 1, 'INFESTED'),
--(4, 4, 4, 4, '6/10/2019', 0, 'WILTED'),
--(5, 5, 5, 5, '2/20/2020', 0, 'BURNT'),
--(6, 6, 6, 6, '4/21/2020', 1, 'WILTED'),
--(7, 7, 7, 7, '4/16/2020', 0, 'BURNT'),
--(8, 8, 8, 8, '10/13/2019', 1, 'HEALTHY'),
--(9, 9, 9, 9, '9/16/2019', 1, 'WILTED'),
--(10, 10, 10, 10, '10/17/2019', 0, 'DEHYDRATED')
--SET IDENTITY_INSERT Tended OFF
--SELECT * FROM Tended 

--GO


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
CREATE PROCEDURE spAddUpdate_Action
	@actionId			INT,
	@planted			BIT,
	@watered			BIT,
	@fertilized			BIT,
	@depested			BIT,
	@noAction			BIT	
AS BEGIN
	BEGIN TRY
	IF(@actionId = 0) BEGIN			-- ADD Harvest

		INSERT INTO ActionTbl(planted, watered, 
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


