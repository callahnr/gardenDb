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
	windDirection		VARCHAR(5)	 	NOT NULL	DEFAULT('N'),
);

CREATE TABLE PlantType (
	plantTypeId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantName			VARCHAR(40)		NOT NULL,
	plantBreed			VARCHAR(40)		NOT NULL,
	daysToHarvest		INT				NOT NULL	DEFAULT(0),
	[description]		VARCHAR(5000)	NOT NULL	DEFAULT(''),
	archived			BIT				NOT NULL	DEFAULT(0)
);

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
	actionId			INT				NOT NULL	FOREIGN KEY		REFERENCES ActionTbl(actionId),
	plantId				INT				NOT NULL	FOREIGN KEY		REFERENCES Plant(plantId),
	soilCondId			INT				NOT NULL	FOREIGN KEY		REFERENCES SoilCondition(soilCondId),
	weatherId			INT				NOT NULL	FOREIGN KEY		REFERENCES Weather(weatherId),
	recordedDate		DATETIME		NOT NULL,
	plantCondition		VARCHAR(30)		NOT NULL
);

CREATE TABLE Harvest (
	harvestId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantId				INT				NOT NULL	FOREIGN KEY REFERENCES Plant(plantId),
	recordedDate		DATETIME		NOT NULL,
	numHarvest			FLOAT			NOT NULL,
	numWaste			FLOAT			NOT NULL
)
GO


/***********************************************************************************  
						CREATE VIEWS
************************************************************************************/
CREATE VIEW vwPlantList AS	
	SELECT p.plantId, pt.plantName, pt.plantBreed, pt.[description]
	FROM Plant p, PlantType pt 
	WHERE p.plantTypeId = pt.plantTypeId AND p.archived = 0
GO


CREATE VIEW vwTypeList AS					
	SELECT pt.plantName, pt.plantBreed, pt.description
	FROM plantType pt
GO


CREATE VIEW vwWateredList AS	
	SELECT DISTINCT p.plantId, pt.plantName, pt.plantBreed, t.recordedDate, a.watered
	FROM	(Plant p	LEFT JOIN Tended t ON p.plantId = t.plantId 
						LEFT JOIN ActionTbl a ON t.actionId = a.actionId 
						LEFT JOIN PlantType pt ON pt.plantTypeId = p.plantTypeId
			)
	WHERE a.watered = 1
GO


CREATE VIEW vwDepestedList AS	
	SELECT DISTINCT p.plantId, pt.plantName, pt.plantBreed, t.recordedDate, a.watered
	FROM	(Plant p	LEFT JOIN Tended t ON p.plantId = t.plantId 
						LEFT JOIN ActionTbl a ON t.actionId = a.actionId 
						LEFT JOIN PlantType pt ON pt.plantTypeId = p.plantTypeId
			)
	WHERE a.depested = 1
GO

CREATE VIEW vwFertilizedList AS		
	SELECT DISTINCT p.plantId, pt.plantName, pt.plantBreed, t.recordedDate, a.watered
	FROM	(Plant p	LEFT JOIN Tended t ON p.plantId = t.plantId 
						LEFT JOIN ActionTbl a ON t.actionId = a.actionId 
						LEFT JOIN PlantType pt ON pt.plantTypeId = p.plantTypeId
			)
	WHERE a.fertilized = 1
GO

CREATE VIEW vwPlantedList AS	
	SELECT	p.plantId, pt.plantName, pt.plantBreed, t.recordedDate, a.planted
	FROM	(Plant p	LEFT JOIN Tended t ON p.plantId = t.plantId 
						LEFT JOIN ActionTbl a ON t.actionId = a.actionId 
						LEFT JOIN PlantType pt ON pt.plantTypeId = p.plantTypeId
			)
	WHERE a.planted = 1
GO

CREATE VIEW vwHarvestDate AS			-- projected harvest date
	SELECT p.plantId, pt.daysToHarvest, t.recordedDate AS [datePlanted], DATEADD(day, pt.daysToHarvest, t.recordedDate) AS [harvestDate]
	FROM Plant p	LEFT JOIN PlantType pt ON p.plantTypeId = pt.plantTypeId, Tended t 
					LEFT JOIN ActionTbl a on t.actionId = a.actionId

	WHERE p.plantId = t.plantId
GO

CREATE VIEW vwPlantLocation AS		
	SELECT p.plantId, l.fieldName, l.fieldColumn, l.fieldRow 
	FROM Plant p JOIN LocationTbl l on p.locationId = l.locationId
GO

/* =====================================================================

	Name:           spAddUpdateDelete_Weather
	Purpose:        Add or Update or Delete a Weather Record

======================================================================== */
CREATE PROCEDURE spAddUpdateDelete_Weather
	@weatherId			INT,	
	@humidity			INT,	
	@temperature		INT,			
	@precipitation		INT,	
	@overcast			INT,	
	@windSpeed			INT,	
	@windDirection		VARCHAR(5),	
	@delete				BIT = 0
AS BEGIN
	
BEGIN TRY
	IF(@weatherId = 0) BEGIN		
		IF EXISTS (SELECT TOP(1) NULL FROM Weather WHERE weatherId = @weatherId) BEGIN
			SELECT	[message] = 'Weather ID already exists',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN

		INSERT INTO Weather	(humidity, temperature, precipitation, overcast, windSpeed, windDirection) VALUES
							(@humidity, @temperature, @precipitation, @overcast, @windSpeed, @windDirection)
		SELECT	@@IDENTITY AS weatherId,
				[success] = CAST(1 AS BIT)
		END

	END ELSE IF(@delete = 1) BEGIN	
		IF NOT EXISTS (SELECT TOP(1) NULL FROM Weather WHERE weatherId = @weatherId) BEGIN
			SELECT	[message] = 'Weather ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN

			DELETE FROM Weather WHERE weatherId = @weatherId
			SELECT	0 as weatherId, 
					[success] = CAST(1 AS BIT)
		END

	END ELSE BEGIN	
		IF NOT EXISTS (SELECT TOP(1) NULL FROM Weather WHERE weatherId = @weatherId) BEGIN
			SELECT	[message] = 'Weather ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			
			UPDATE Weather
			SET humidity = @humidity, temperature = @temperature, precipitation = @precipitation, 
				overcast = @overcast, windSpeed = @windSpeed, windDirection = @windDirection
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

/* =====================================================================

	Name:           spAddUpdateDelete_PlantType
	Purpose:        Add or Update or Delete a PlantType Record

======================================================================== */
CREATE PROCEDURE spAddUpdateDelete_PlantType
	@plantTypeId		INT,	
	@plantName			VARCHAR(40),
	@plantBreed			VARCHAR(40),
	@daysToHarvest		INT,
	@description		VARCHAR(100),
	@delete				BIT = 0
AS BEGIN

BEGIN TRY
	IF(@plantTypeId = 0) BEGIN	
		IF EXISTS (SELECT TOP(1) NULL FROM PlantType WHERE PlantTypeId = @plantTypeId) BEGIN
			SELECT	[message] = 'plantType ID already exists',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN

		INSERT INTO PlantType (plantName, plantBreed, daysToHarvest, description) VALUES
							  (@plantName, @plantBreed, @daysToHarvest, @description)
		SELECT	@@IDENTITY AS plantTypeId,
				[success] = CAST(1 AS BIT)
		END

	END ELSE IF(@delete = 1) BEGIN	
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

	END ELSE BEGIN		
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

/* =====================================================================

	Name:           spAddUpdate_Harvest
	Purpose:        Add or Update a Harvest Record

======================================================================== */
CREATE PROCEDURE spAddUpdate_Harvest
	@harvestId			INT,	
	@plantId			INT,	
	@recordedDate		DATETIME,
	@numHarvest			FLOAT,
	@numWaste			FLOAT
AS BEGIN

	BEGIN TRY
	IF(@harvestId = 0) BEGIN			
		IF EXISTS (SELECT TOP(1) NULL FROM Harvest WHERE harvestId = @harvestId) BEGIN
			SELECT	[message] = 'harvest ID already exists',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN

		INSERT INTO Harvest (plantId, recordedDate, numHarvest, numWaste) VALUES
							(@plantId, @recordedDate, @numHarvest, @numWaste)
		SELECT	@@IDENTITY AS harvestId,
				[success] = CAST(1 AS BIT)
		END

	END ELSE BEGIN				
		IF NOT EXISTS (SELECT TOP(1) NULL FROM Harvest WHERE harvestId = @harvestId) BEGIN
			SELECT	[message] = 'harvest ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			
			UPDATE Harvest
			SET plantId = @plantId, recordedDate = @recordedDate, numHarvest = @numHarvest, numWaste = @numWaste
			WHERE harvestId = @harvestId
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

/* =====================================================================

	Name:           spAddUpdate_Action
	Purpose:        Add or Update an Action Record

======================================================================== */
CREATE PROCEDURE spAddUpdate_Action
	@actionId			INT,
	@planted			BIT,
	@watered			BIT,
	@fertilized			BIT,
	@depested			BIT,
	@noAction			BIT	
AS BEGIN
	BEGIN TRY
	IF(@actionId = 0) BEGIN			   -- ADD Action

		INSERT INTO ActionTbl(planted, watered, fertilized, depested, noAction) VALUES
							 (@planted, @watered, @fertilized, @depested, @noAction)
		SELECT	@@IDENTITY AS actionId,
				[success] = CAST(1 AS BIT)
	END ELSE BEGIN						-- UPDATE Action

		IF NOT EXISTS (SELECT TOP(1) NULL FROM ActionTbl WHERE actionId = @actionId) BEGIN
			SELECT	[message] = 'harvest ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			
			UPDATE ActionTbl
			SET planted = @planted, watered = @watered, fertilized = @fertilized, depested = @depested, noAction = @noAction
			WHERE actionId = @actionId
			SELECT	@actionId AS actionId,
					[success] = CAST(1 AS BIT)
		END

	END
END TRY BEGIN CATCH
	
	IF(@@TRANCOUNT > 0) ROLLBACK TRAN

END CATCH

	IF(@@TRANCOUNT > 0) COMMIT TRAN
END
GO

/* =====================================================================

	Name:           spAddUpdate_Location
	Purpose:        Add or Update or Delete a Location Record

======================================================================== */
CREATE PROCEDURE spAddUpdate_Location
	@locationId			INT,		
	@fieldName			VARCHAR(30),
	@fieldColumn		INT,		
	@fieldRow			INT,
	@delete				BIT = 0
AS BEGIN

BEGIN TRY
	IF(@locationId = 0) BEGIN
		INSERT INTO LocationTbl(fieldName, fieldColumn, fieldRow) VALUES
							   (@fieldName, @fieldColumn, @fieldRow)
		SELECT	@@IDENTITY AS locationId,
				[success] = CAST(1 AS BIT)

	END ELSE IF(@delete = 1) BEGIN	
		
		IF NOT EXISTS (SELECT TOP(1) NULL FROM Location WHERE locationId = @locationId) BEGIN
			SELECT	[message] = 'ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN

			DELETE FROM LocationTbl WHERE locationId = @locationId
			SELECT	0 as locationId, 
					[success] = CAST(1 AS BIT)
		END

	END ELSE BEGIN		

		IF NOT EXISTS (SELECT TOP(1) NULL FROM Location WHERE locationId = @locationId) BEGIN
			SELECT	[message] = 'Location ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			
			UPDATE LocationTbl
			SET fieldName = @fieldName, fieldColumn = @fieldColumn, fieldRow = @fieldRow
			WHERE locationId = @locationId

			SELECT	@locationId AS locationId,
					[success] = CAST(1 AS BIT)
		END

	END
END TRY BEGIN CATCH
	
	IF(@@TRANCOUNT > 0) ROLLBACK TRAN

END CATCH

	IF(@@TRANCOUNT > 0) COMMIT TRAN
END
GO

/* =====================================================================

	Name:           spAddUpdate_SoilCondition
	Purpose:        Add or Update or Delete a SoilCondtion Record

======================================================================== */
CREATE PROCEDURE spAddUpdate_SoilCondition
	@soilCondId			INT,	
	@recordedDate		DATETIME,
	@pH					FLOAT,
	@moistureLvl		FLOAT,	
	@nitrogenLvl		FLOAT,	
	@phosoLvl			FLOAT	
AS BEGIN

	BEGIN TRY
	IF(@soilCondId = 0) BEGIN			   

		INSERT INTO SoilCondition (recordedDate, pH, moistureLvl, nitrogenLvl, phosoLvl) VALUES
								  (@recordedDate, @pH, @moistureLvl, @nitrogenLvl, @phosoLvl)
		SELECT	@@IDENTITY AS soilCondId,
				[success] = CAST(1 AS BIT)
	END ELSE BEGIN						

		IF NOT EXISTS (SELECT TOP(1) NULL FROM SoilCondition WHERE soilCondId = @soilCondId) BEGIN
			SELECT	[message] = 'soil ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			
			UPDATE SoilCondition
			SET recordedDate = @recordedDate, pH = @pH, moistureLvl = @moistureLvl, nitrogenLvl = @nitrogenLvl, phosoLvl = @phosoLvl
			WHERE soilCondId = @soilCondId
			SELECT	@soilCondId AS soilCondId,
					[success] = CAST(1 AS BIT)
		END

	END
END TRY BEGIN CATCH
	
	IF(@@TRANCOUNT > 0) ROLLBACK TRAN

END CATCH

	IF(@@TRANCOUNT > 0) COMMIT TRAN
END
GO

/* =====================================================================

	Name:           spAddUpdateDelete_Plant
	Purpose:        Add or Update or Delete a Plant Record

======================================================================== */

CREATE PROCEDURE spAddUpdateDelete_Plant
	@plantId				INT,
	@plantTypeId			INT,
	@locationId				INT,
	@delete					INT
AS BEGIN

BEGIN TRY
	IF(@plantId = 0) BEGIN			-- ADD plant
		
		INSERT INTO Plant (plantTypeId, locationId, archived) VALUES
						  (@plantTypeId, @locationId, 0)
		SELECT	@@IDENTITY AS plantId,
				[success] = CAST(1 AS BIT)

	END ELSE IF(@delete = 1) BEGIN		-- SOFT DELETE plant
		IF NOT EXISTS (SELECT TOP(1) NULL FROM Plant WHERE PlantId = @plantId) BEGIN
			SELECT	[message] = 'plant ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			UPDATE Plant
			SET archived = 1
			WHERE plantId = @plantId
			SELECT	0 as plantId,
					[success] = CAST(1 AS BIT)
		END

	END ELSE BEGIN						-- UPDATE plant
		IF NOT EXISTS (SELECT TOP(1) NULL FROM Plant WHERE PlantId = @plantId) BEGIN
			SELECT	[message] = 'plant ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			
			UPDATE Plant
			SET plantTypeId = @plantTypeId, locationId = @locationId, archived = 0
			WHERE plantId = @plantId

			SELECT	@plantId AS plantId,
					[success] = CAST(1 AS BIT)
		END

	END
END TRY BEGIN CATCH
	
	IF(@@TRANCOUNT > 0) ROLLBACK TRAN

END CATCH

	IF(@@TRANCOUNT > 0) COMMIT TRAN

END
GO

/* =====================================================================

	Name:           spAddUpdate_Tended
	Purpose:        Add or Update a Tended Record

======================================================================== */
CREATE PROCEDURE spAddUpdate_Tended
	@tendedId			INT,		
	@actionId			INT,		
	@plantId			INT,		
	@soilCondId			INT,		
	@weatherId			INT,		
	@recordedDate		DATETIME,	
	@plantCondition		VARCHAR(30)		
AS BEGIN

	BEGIN TRY
	IF(@tendedId = 0) BEGIN			   -- ADD Tended

		INSERT INTO Tended (actionId, plantId, soilCondId, weatherId, recordedDate, plantCondition)
					VALUES(@actionId, @plantId, @soilCondId, @weatherId, @recordedDate, @plantCondition)
		SELECT	@@IDENTITY AS tendedId,
				[success] = CAST(1 AS BIT)
	END ELSE BEGIN						-- UPDATE Tended

		IF NOT EXISTS (SELECT TOP(1) NULL FROM Tended WHERE tendedId = @tendedId) BEGIN
			SELECT	[message] = 'Tended ID does not exist',
					[success] = CAST(0 AS BIT)
		END ELSE BEGIN
			
			UPDATE Tended
			SET actionId = @actionId, plantId = @plantId, soilCondId = @soilCondId, weatherId = @weatherId,
				recordedDate = @recordedDate, plantCondition = @plantCondition
			WHERE tendedId = @tendedId
			SELECT	@tendedId AS tendedId,
					[success] = CAST(1 AS BIT)
		END

	END
END TRY BEGIN CATCH
	
	IF(@@TRANCOUNT > 0) ROLLBACK TRAN

END CATCH

	IF(@@TRANCOUNT > 0) COMMIT TRAN
END
GO

/* =====================================================================

	Name:           spGetPlantBreedByName
	Purpose:        Gets a list of all plants from the database by name.

======================================================================== */
GO
CREATE PROCEDURE spGetPlantBreedByName
	@plantBreedName		VARCHAR(64),
	@hardMatch			BIT = 0
AS BEGIN
	IF (@hardMatch = 1) BEGIN
		SELECT *
		FROM vwTypeList tl
		WHERE tl.plantBreed = @plantBreedName
	END ELSE BEGIN
		SELECT *
		FROM vwTypeList tl
		WHERE tl.plantBreed LIKE CONCAT('%', @plantBreedName, '%')
	END
END
GO

/* =====================================================================

	Name:           spGetPlantByTypeName
	Purpose:        Gets a list of all plants from the database by name.

======================================================================== */
GO
CREATE PROCEDURE spGetPlantByTypeName
	@plantType				VARCHAR(64),
	@hardMatch				BIT = 0
AS BEGIN
	IF (@hardMatch = 1) BEGIN
		SELECT *
		FROM vwTypeList tl
		WHERE tl.plantName = @plantType
	END ELSE BEGIN
		SELECT *
		FROM vwTypeList tl
		WHERE tl.plantName LIKE CONCAT('%', @plantType, '%')
	END
END
GO

/* =====================================================================

	Name:           spGetWeatherByDate
	Purpose:        Get all weather data between a date range

======================================================================== */
GO
CREATE PROCEDURE spGetWeatherByDate
	@startDate				DATETIME,
	@endDate				DATETIME
AS BEGIN
		SELECT *
		FROM Weather w, Tended t
		WHERE w.weatherId = t.weatherId AND recordedDate BETWEEN @startDate AND @endDate
END
GO


/* =====================================================================

	Name:           spGetPlantConditionByDate
	Purpose:        Get all plant conditions between a date range

======================================================================== */
GO
CREATE PROCEDURE spGetPlantConditionByDate
	@startDate				DATETIME,
	@endDate				DATETIME
AS BEGIN
		SELECT t.plantId, t.recordedDate, t.plantCondition
		FROM Tended t
		WHERE t.recordedDate BETWEEN @startDate AND @endDate
END
GO


/* =====================================================================

	Name:           spGetLocByPlantType
	Purpose:        Get all weather data between a date range

======================================================================== */
GO
CREATE PROCEDURE spGetLocByPlantType
		@plantType		VARCHAR(64)
AS BEGIN
		SELECT DISTINCT pl.*, pt.plantName
		FROM vwPlantLocation pl LEFT JOIN Plant p ON pl.plantId = p.plantTypeId, plantType pt
		WHERE pt.plantName LIKE CONCAT('%', 'Tomato', '%')
END
GO


/* =====================================================================

	Name:           spGetLocByPlantType
	Purpose:        Get all weather data between a date range

======================================================================== */
GO
CREATE PROCEDURE spGetSoilListByPh(
		@startRange		FLOAT,
		@endRange		FLOAT
		)
AS BEGIN

		SELECT sc.*
		FROM soilCondition sc
		WHERE sc.pH BETWEEN @startRange AND @endRange
END
GO
/* =====================================================================

	Name:           spGetHarvestsByDateRange
	Purpose:        Get all weather data between a date range

======================================================================== */
GO
CREATE PROCEDURE spGetHarvestsByDateRange
	@startDate				DATETIME,
	@endDate				DATETIME
AS BEGIN

		SELECT hd.plantId, hd.harvestDate
		FROM vwHarvestDate hd
		WHERE hd.harvestDate BETWEEN @startDate AND @endDate
		GROUP BY hd.plantId, hd.harvestDate
END
GO

/************************************************************************
									INSERT DATA
*************************************************************************/

SET IDENTITY_INSERT Weather ON
INSERT INTO Weather (weatherId, humidity, temperature, precipitation, overcast, windSpeed, windDirection) VALUES 
(1, 37, 39, 63, 35, 25, 'SE'),
(2, 68, 81, 46, 79, 62, 'N'),
(3, 9, 34, 62, 68, 57, 'NE'),
(4, 85, 123, 95, 70, 35, 'E'),
(5, 64, 67, 12, 65, 63, 'W'),
(6, 60, 68, 64, 5, 8, 'N'),
(7, 88, 104, 98, 26, 37, 'W'),
(8, 82, 100, 89, 3, 63, 'W'),
(9, 67, 12, 50, 21, 60, 'NW'),
(10, 20, 37, 50, 78, 4, 'NE'),
(11, 24, 90, 49, 72, 13, 'NW'),
(12, 24, 90, 49, 72, 11, 'S'),
(13, 24, 90, 49, 72, 2, 'SE'),
(14, 24, 90, 49, 72, 4, 'NW'),
(15, 57, 121, 85, 95, 23, 'N')
SET IDENTITY_INSERT Weather OFF

INSERT INTO plantType (plantName, plantBreed, daysToHarvest, [description] ) VALUES 
('Cilantro', 'Common', 45 , 'The highly aromatic, rich and spicy Cilantro adds the perfect flavor to any cuisine! This plant is ideal for harvesting both the cilantro leaves and coriander seeds. The unique flavor of this cilantro is bold and bright with a touch of citrus undertones.'),
('Cilantro', 'Coriandrum sativum', 80 , 'Coriander is an annual herb in the family Apiaceae. It is also known as Chinese parsley, and in the United States the stems and leaves are usually called cilantro'),
('Corn', 'Bilicious Hybrid', 78, 'Bi-Licious is an excellent mid-season hybrid with bi-colored kernels maturing in 75 or more days. Ears are 8 1/2 inches with 16 rows of kernels. Corn is a warm season crop. Pollination is essential for success so corn needs to be planted in a block of three rows of 12-24 plants (rather than one row).'),
('Kohlrabi', 'Early White Vienna', 55, 'Round, above-ground "bulbs" with light green, smooth skin have creamy white, tender flesh. Flavor is mild, sweet, turnip-like. Superb raw or steamed. Ready for harvest 55 days from seed sowing.'),
('Hot Pepper', 'Jalapeno Early', 80, 'Cooks Garden Favorite. Dark green, pungent 3" hot peppers are excellent fresh or pickled. Zesty flavor is great in Mexican dishes.'),
('Watermelon', 'Orange Tendersweet', 90, 'This heirloom favorite features luscious, bright orange flesh. Tender and very sweet, the oblong striped fruits grow to 35 lb.'),
('Cucumber', 'PickelBush', 70, 'Burpee-bred Picklebush has unbelievably compact vines that get only 2 long. White-spined fruits have classic pickle look, deep green with paler stripes. Up to 4 1/2" long, 1 1/2" across at maturity, but use them at any size. Very productive and tolerant to powdery mildew and cucumber mosaic virus.'),
('Tomato', 'Roma ', 80, 'Compact plants produce paste-type tomatoes resistant to Verticillium and Fusarium wilts. Meaty interiors and few seeds. GARDEN HINTS: Fertilize when first fruits form to increase yield. Water deeply once a week during very dry weather. We searched the world to find the best organic seed-Burpee fully guarantees that not a drop of synthetic chemicals was used to make these excellent seeds.')

SET IDENTITY_INSERT locationTbl ON
INSERT INTO locationTbl  (locationId, fieldName, fieldColumn, fieldRow) VALUES 
(1, 'NORTH',   1, 1),
(2, 'NORTH',   1, 2),
(3, 'NORTH',   1, 3),
(4, 'NORTH',   1, 4),
(5, 'NORTH',   1, 5),
(6, 'NORTH',   1, 6),
(7, 'NORTH',   1, 7),
(8, 'NORTH',   1, 8),
(9, 'NORTH',   1, 9),
(10, 'NORTH',  1, 10),
(11, 'NORTH',  1, 11),
(12, 'NORTH',  1, 12)
SET IDENTITY_INSERT locationTbl OFF

SET IDENTITY_INSERT Plant ON
INSERT INTO Plant (plantId, plantTypeId, locationId) VALUES 
(1,   1,  1),
(2,   2,  2),
(3,   5,  3),
(4,   4,  4),
(5,   4,  5),
(6,   5,  6),
(7,   2,  7),
(8,   3,  8),
(9,   6,  9),
(10,  1, 10),
(11,  1, 10),
(12,  1, 10),
(13,  1, 10),
(14,  1, 10),
(15,  2, 11)
SET IDENTITY_INSERT Plant OFF

SET IDENTITY_INSERT Harvest ON
INSERT INTO Harvest (harvestId, plantId, recordedDate, numHarvest, numWaste) 
VALUES 
(1,	1, '6/10/2020', 8, 18),
(2,	2, '11/15/2020', 51, 3),
(3, 3, '12/10/2020', 48, 8),
(4, 4, '11/13/2020', 86, 16),
(5, 5, '10/28/2020', 88, 6),
(6, 6, '2/5/2020', 62, 14)
SET IDENTITY_INSERT Harvest OFF

SET IDENTITY_INSERT ActionTbl ON
INSERT INTO ActionTbl (actionId, planted, watered, fertilized, depested, noAction) 
VALUES (1, 1, 0, 0, 0, 0),
(2, 1, 1, 1, 0, 0),
(3, 0, 0, 0, 0, 0),
(4, 1, 1, 0, 0, 0),
(5, 0, 1, 0, 0, 0),
(6, 0, 1, 0, 1, 0),
(7, 1, 1, 1, 0, 0),
(8, 1, 1, 1, 1, 0),
(9, 0, 1, 0, 1, 0),
(10, 0, 1, 0, 0, 0),
(11, 0, 0, 0, 0, 0),
(12, 0, 0, 0, 1, 0),
(13, 1, 1, 1, 0, 0),
(14, 1, 0, 1, 0, 0),
(15, 0, 0, 1, 1, 0)
SET IDENTITY_INSERT ActionTbl OFF

SET IDENTITY_INSERT SoilCondition ON
INSERT INTO SoilCondition (soilCondId, recordedDate, pH, moistureLvl, nitrogenLvl, phosoLvl) 
VALUES 
(1,   '11/21/2019', -3.6, 0.98, 0.52, 0.24),
(2,   '2/8/2020',    5.9, 0.22, 0.99, 0.53),
(3,   '10/1/2019',   0.2, 0.47, 0.12, 0.39),
(4,   '6/10/2019',   5.6, 0.67, 0.55, 0.01),
(5,   '2/20/2020',   3.9, 0.8, 0.9, 0.26),
(6,   '4/21/2020',   2.6, 0.57, 0.89, 0.99),
(7,   '4/16/2020',  -3.4, 0.12, 0.73, 0.99),
(8,   '10/13/2019',  3.4, 0.75, 0.49, 0.01),
(9,   '9/16/2019',  -5.1, 0.46, 0.91, 0.23),
(10,  '10/17/2019', -2.1, 0.13, 0.92, 0.79),
(11,  '4/28/2020',  -6.2, 0.41, 0.08, 0.42),
(12,  '11/20/2019', -3.8, 0.23, 0.31, 0.53),
(13,  '12/16/2019',  1.0, 0.64, 0.65, 0.5),
(14,  '4/9/2020',   -4.1, 0.99, 0.36, 0.05),
(15,  '1/16/2020',   4.1,  0.63, 0.15, 0.67),
(16,  '6/7/2019',    1.0,  0.88, 0.22, 0.02)
SET IDENTITY_INSERT SoilCondition OFF

SET IDENTITY_INSERT Tended ON
INSERT INTO Tended (tendedId, actionId, plantId, soilCondId, weatherId, recordedDate, plantCondition) 
VALUES 
(1,   1,  1, 1,  1, '11/21/2019',	'INFESTED'),
(2,   2,  2, 2,  2, '2/8/2020',	'DEHYDRATED'),
(3,   3,  3, 3,  3, '10/1/2019',	'INFESTED'),
(4,   4,  4, 4,  4, '6/10/2019',	 'WILTED'),
(5,   5,  5, 5,  5, '2/20/2020', 'BURNT'),
(6,   6,  6, 6,  6, '4/21/2020', 'WILTED'),
(7,   7,  7, 7,  7, '4/16/2020', 'BURNT'),
(8,   8,  8, 8,  8, '10/13/2019', 'HEALTHY'),
(9,   9,  9, 9,  9, '9/16/2019',  'WILTED'),
(10, 10, 10, 10, 10,'10/17/2019', 'DEHYDRATED'),
(11, 11, 11, 11, 11,'4/28/2020', 'BURNT'),
(12, 12, 12, 12, 12,'11/20/2019', 'INFESTED'),
(13, 13, 13, 13, 13,'12/16/2019', 'DEHYDRATED'),
(14, 14, 14, 14, 14,'4/9/2020', 'INFESTED'),
(15, 15, 15, 15, 15,'1/16/2020', 'DEHYDRATED')
SET IDENTITY_INSERT Tended OFF
GO
/************************************************************************************************************  
												TEST PROCEDURES
*************************************************************************************************************/
	exec spAddUpdateDelete_Weather 0, 56, 76, 2, 25, 20, 'NW'
	select * from Weather

-- Update weather
	exec spAddUpdateDelete_Weather 1, 26, 36, 3, 45, 50, 'W'
	select * from Weather

-- DELETE weather
	exec spAddUpdateDelete_Weather 1, 26, 36, 3, 45, 50, 'W', 1
	select * from Weather

-- ADD plantType
	exec spAddUpdateDelete_PlantType 0, 'Tomato', 'Roma', 20, 'juicy roma tomatoes ~ very delicious', 0
	exec spAddUpdateDelete_PlantType 0, 'Tomato', 'Cherry', 25, 'cherrytomatoes ~ very delicious', 0
	exec spAddUpdateDelete_PlantType 0, 'Tomato', 'Grape', 22, 'tart in taste', 0
	select * from PlantType

-- Update plantType
	exec spAddUpdateDelete_PlantType 1, 'Tomato', 'Roma', 18, 'juicy roma tomatoes ~ very delicious [UPDATED]', 0
	select * from PlantType

-- SOFT DELETE plantType
	exec spAddUpdateDelete_PlantType 2, 'Tomato', 'Cherry', 25, 'cherrytomatoes ~ very delicious', 1
	select * from PlantType

-- Add location
	exec spAddUpdate_Location 0, 'Chestnut Fields', 3, 12
	select * from LocationTbl

-- Create plant seedling/ sapling
	exec spAddUpdateDelete_Plant 0, 3, 1, 0
	select * from Plant

-- Add action for planting the above-created plant
	exec spAddUpdate_Action 0, 1, 0, 0, 0, 0
	select * from ActionTbl

-- Add soil condition while planting 
	exec spAddUpdate_SoilCondition 0, '05/08/2020', 4.5, 76, 35, 68
	select * from SoilCondition

-- Add weather record on that day
	exec spAddUpdateDelete_Weather 0, 45, 78, 5, 58, 24, 'SW', 0

-- Add and keep recorded of the activity of planting sapling in Tended table
	exec spAddUpdate_Tended 0, 1, 1, 1, 2, '05/08/2020', 'healthy plant'
	select * from Tended

GO

EXEC spGetSoilListByPh 0.0, 5.0
EXEC spGetLocByPlantType 'omat';
EXEC spGetPlantConditionByDate '12/8/2019', '12/31/2019'
EXEC spGetWeatherByDate '12/8/2019', '12/31/2019'
EXEC spGetHarvestsByDateRange '12/31/2019', '5/8/2020';
EXEC spGetPlantByTypeName 'Tomato', 1 --Hard Match Test
EXEC spGetPlantByTypeName 'umbe', 0 --Soft Match Test
EXEC spGetPlantBreedByName 'Roma', 1 --Hard Match Test
EXEC spGetPlantBreedByName 'Gold', 0 --Soft Match Test
EXEC spAddUpdateDelete_Weather 0, 65, 2, 33, 5, 2, 'N' -- Add Weather Test
EXEC spAddUpdateDelete_Weather 0, 20, 3, 27, 2, 5, 'N' -- Add Another So we can delete one
EXEC spAddUpdateDelete_Weather 1, 10, 1, 12, 0, 1, 'S' -- Update Weather Test
EXEC spAddUpdateDelete_Weather 1, 10, 1, 12, 0, 1, 'S', 1; -- DELETE from Weather Test

/************************************************************************************************************  
												TEST VIEWS
*************************************************************************************************************/
SELECT * FROM vwDepestedList ORDER BY plantID
SELECT * FROM vwFertilizedList ORDER BY plantID
SELECT * FROM vwHarvestDate ORDER BY plantID
SELECT * FROM vwPlantedList ORDER BY plantID
SELECT * FROM vwPlantList ORDER BY plantId
SELECT * FROM vwPlantLocation ORDER BY plantID
SELECT * FROM vwTypeList ORDER BY plantName
SELECT * FROM vwWateredList ORDER BY plantId