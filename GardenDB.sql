/*
	Garden Database Script
	2.09.2020
	@author : Nathan Callahan
	@author : Soumya Mitra
*/

USE master;
GO

DROP DATABASE IF EXISTS Garden;
GO

CREATE DATABASE Garden;
GO

USE Garden;
GO

CREATE TABLE Plants	 (					
	plantId				INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantTypeId			INT				NOT NULL	FOREIGN KEY,
	sownId				INT				NOT NULL,
	harvestId			INT				NOT NULL,
	tendedId			INT				NOT NULL
);

CREATE TABLE PlantType (
	plantTypeId			INT				NOT NULL	PRIMARY KEY		IDENTITY,
	plantName			VARCHAR(40)		NOT NULL,
	plantSubType		VARCHAR(40)		NOT NULL,
	daysToHarvest		INT				NOT NULL,
	description			VARCHAR(100)	NOT NULL,
	bloomInitiatedBy	VARCHAR(40)		NOT NULL
);



INSERT INTO plants(plantType, plantName, numPlanted)
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
;

SELECT * FROM plants;