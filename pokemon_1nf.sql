-- File path: C:\Users\renti\Documents\INFO330\INFO330-CreatingRelations2

-- Steps to make the database 1NF
-- Primary issue: The "abilities" column stores multiple values per cell



-------------------------------------------------------------------------
-- ORIGINAL IMPORTED_POKEMON_DATA SCHEMA HERE:

/*
CREATE TABLE IF NOT EXISTS imported_pokemon_data(
'abilities' TEXT, 'against_bug' TEXT, 'against_dark' TEXT, 'against_dragon' TEXT,
 'against_electric' TEXT, 'against_fairy' TEXT, 'against_fight' TEXT, 'against_fire' TEXT,
 'against_flying' TEXT, 'against_ghost' TEXT, 'against_grass' TEXT, 'against_ground' TEXT,
 'against_ice' TEXT, 'against_normal' TEXT, 'against_poison' TEXT, 'against_psychic' TEXT,
 'against_rock' TEXT, 'against_steel' TEXT, 'against_water' TEXT, 'attack' TEXT,
 'base_egg_steps' TEXT, 'base_happiness' TEXT, 'base_total' TEXT, 'capture_rate' TEXT,
 'classfication' TEXT, 'defense' TEXT, 'experience_growth' TEXT, 'height_m' TEXT,
 'hp' TEXT, 'name' TEXT, 'percentage_male' TEXT, 'pokedex_number' TEXT,
 'sp_attack' TEXT, 'sp_defense' TEXT, 'speed' TEXT, 'type1' TEXT,
 'type2' TEXT, 'weight_kg' TEXT, 'generation' TEXT, 'is_legendary' TEXT);
*/


	
-------------------------------------------------------------------------
-- Import pokemon data
.mode csv
.import pokemon.csv imported_pokemon_data

-- Fixing that one weird capture_rate cell 
UPDATE imported_pokemon_data SET capture_rate = 285 WHERE pokedex_number = 774;

--Re-typing imported_pokemon_data for funzies
-- Also re-named the "classfication" column to "classIfciation" in tweaked_data, as it's misspelled in the original data set


-- Creating tweaked_data (re-typed version of imported_pokemon_data)
CREATE TABLE IF NOT EXISTS tweaked_data(pokedex_number INT,
'abilities' TEXT, 'against_bug' REAL, 'against_dark' REAL, 'against_dragon' REAL,
 'against_electric' REAL, 'against_fairy' REAL, 'against_fight' REAL, 'against_fire' REAL,
 'against_flying' REAL, 'against_ghost' REAL, 'against_grass' REAL, 'against_ground' REAL,
 'against_ice' REAL, 'against_normal' REAL, 'against_poison' REAL, 'against_psychic' REAL,
 'against_rock' REAL, 'against_steel' REAL, 'against_water' REAL, 'attack' INT,
 'base_egg_steps' INT, 'base_happiness' INT, 'base_total' INT, 'capture_rate' INT,
 'classification' TEXT, 'defense' INT, 'experience_growth' INT, 'height_m' REAL,
 'hp' INT, 'name' TEXT, 'percentage_male' REAL,
 'sp_attack' INT, 'sp_defense' INT, 'speed' INT, 'type1' TEXT,
 'type2' TEXT, 'weight_kg' REAL, 'generation' INT, 'is_legendary' INT);

-- Filling tweaked_data with data from imported_pokemon_data
INSERT INTO tweaked_data(pokedex_number, abilities, against_bug, against_dark, against_dragon,
 against_electric, against_fairy, against_fight, against_fire,
 against_flying, against_ghost, against_grass, against_ground,
 against_ice, against_normal, against_poison, against_psychic,
 against_rock, against_steel, against_water, attack,
 base_egg_steps, base_happiness, base_total, capture_rate,
 classification, defense, experience_growth, height_m,
 hp, name, percentage_male,
 sp_attack, sp_defense, speed, type1,
 type2, weight_kg, generation, is_legendary) 


SELECT pokedex_number, abilities, against_bug, against_dark, against_dragon,
 against_electric, against_fairy, against_fight, against_fire,
 against_flying, against_ghost, against_grass, against_ground,
 against_ice, against_normal, against_poison, against_psychic,
 against_rock, against_steel, against_water, attack,
 base_egg_steps, base_happiness, base_total, capture_rate,
 classfication, defense, experience_growth, height_m,
 hp, name, percentage_male,
 sp_attack, sp_defense, speed, type1,
 type2, weight_kg, generation, is_legendary


FROM imported_pokemon_data WHERE pokedex_number IS NOT NULL; 

-------------------------------------------------------------------------------------------------------------
-- Don't split across columns- split across rows instead
-- Splitting abilities lists into multiple separate rows (atomization) 
-- Source: https://www.vivekkalyan.com/splitting-comma-seperated-fields-sqlite 

-- query.sql
CREATE TABLE test_table AS
WITH RECURSIVE split(pokedex_number, ability, str) AS (
    SELECT pokedex_number, '', abilities||',' FROM tweaked_data
    UNION ALL SELECT
    pokedex_number,
    substr(str, 0, instr(str, ',')),
    substr(str, instr(str, ',')+1)
    FROM split WHERE str!=''
) 
SELECT pokedex_number, ability
FROM split
WHERE ability!='' ORDER BY pokedex_number;

-- Getting rid of extra brackets and quotations marks from the "ability" columns:
UPDATE test_table SET ability = REPLACE(ability,'[', ''); -- Remove brackets
UPDATE test_table SET ability = REPLACE(ability,']', ''); -- Remove brackets
UPDATE test_table SET ability = TRIM(ability); -- Remove extra spaces at start/end
UPDATE test_table SET ability = REPLACE(ability, '''' , ''); -- Remove extra quotes

-- Creating a table in 1_nf 
CREATE TABLE table_1nf AS 
 SELECT test_table.pokedex_number, test_table.ability, against_bug, against_dark, against_dragon,
 against_electric, against_fairy, against_fight, against_fire,
 against_flying, against_ghost, against_grass, against_ground,
 against_ice, against_normal, against_poison, against_psychic,
 against_rock, against_steel, against_water, attack,
 base_egg_steps, base_happiness, base_total, capture_rate,
 classification, defense, experience_growth, height_m,
 hp, name, percentage_male,
 sp_attack, sp_defense, speed, type1,
 type2, weight_kg, generation, is_legendary FROM test_table INNER JOIN tweaked_data ON tweaked_data.pokedex_number = test_table.pokedex_number;

-- I THINK THIS ACTUALLY GIVES 1NF

-- SELECT pokedex_number, ability, against_bug, against_dark FROM table_1nf LIMIT 20; -- Viewing / testing code


DROP TABLE imported_pokemon_data; -- Don't need, replaced with tweaked_data

-------------------------------------------------------------------------------------------------------------
-- TABLES TO DROP: test_table
-- Extra tables will be dropped at the end of the 3NF file, as temp tables stay useful for steps after 1NF
