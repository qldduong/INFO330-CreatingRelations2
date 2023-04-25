-- Transition to 3NF
-- Final concern: Fixing the "effectiveness" table? 


-------------------------------------------------------------------------------------------------------------
-- against_x is transitively dependent on pokedex_number, so the primary key of the effectiveness table needs to be changed
-- Replace with a composite key of each pokemon's types 


-- Inserting a "" placeholder for empty type_2s into types_t || Will be represented as type 19
INSERT INTO types_t(type_name) VALUES ('');

-- Create the "wip_key" temp table of all the types for each pokemon
CREATE TABLE wip_key AS SELECT type1, type2, tweaked_data.pokedex_number FROM tweaked_data, effectiveness WHERE tweaked_data.pokedex_number = effectiveness.pokedex_number;



-- Create the "effectiveness_2" table
-- Connects all the types for every pokemon + their effectiveness againt other types
CREATE TABLE IF NOT EXISTS effectiveness_2 AS SELECT type1, type2, against_bug, against_dark, against_dragon, against_electric,
against_fairy, against_fight, against_fire, against_flying, against_ghost, against_grass, against_ground,
against_ice, against_normal, against_poison, against_psychic, against_rock, against_steel, against_water
FROM wip_key, effectiveness WHERE wip_key.pokedex_number = effectiveness.pokedex_number;


-- Testing code to look at effectiveness_2: 
-- SELECT type1, type2, against_bug, against_dark, against_dragon, against_electric, against_fairy, against_fight FROM effectiveness_2 LIMIT 30;



-- Updates effectiveness_2 to list type_ids instead of type names
UPDATE effectiveness_2 SET type1 = (SELECT types_t.type_id FROM types_t WHERE effectiveness_2.type1 = types_t.type_name);
UPDATE effectiveness_2 SET type2 = (SELECT types_t.type_id FROM types_t WHERE effectiveness_2.type2 = types_t.type_name);



-- Now, we only want unique types combinations + their resistances 
CREATE TABLE IF NOT EXISTS effectiveness_3 AS SELECT type1, type2, against_bug, against_dark, against_dragon, against_electric,
against_fairy, against_fight, against_fire, against_flying, against_ghost, against_grass, against_ground,
against_ice, against_normal, against_poison, against_psychic, against_rock, against_steel, against_water
FROM effectiveness_2 GROUP BY type1, type2;



-- Drop old effectiveness table
DROP TABLE effectiveness;


-- Creating the "effectiveness_temp" table, which contains unique type combos + their multipliers against other types
CREATE TABLE IF NOT EXISTS effectiveness_temp(type_1_id INT NOT NULL, type_2_id INT DEFAULT 19 NOT NULL,
'against_bug' REAL, 'against_dark' REAL, 'against_dragon' REAL,
'against_electric' REAL, 'against_fairy' REAL, 'against_fight' REAL, 'against_fire' REAL,
'against_flying' REAL, 'against_ghost' REAL, 'against_grass' REAL, 'against_ground' REAL,
'against_ice' REAL, 'against_normal' REAL, 'against_poison' REAL, 'against_psychic' REAL,
'against_rock' REAL, 'against_steel' REAL, 'against_water' REAL,
PRIMARY KEY(type_1_id, type_2_id), FOREIGN KEY(type_1_id) REFERENCES types_t(type_id),
FOREIGN KEY(type_2_id) REFERENCES types_t(type_id)); 


-- Inserting into "effectiveness_temp"
INSERT INTO effectiveness_temp(type_1_id, type_2_id, against_bug, against_dark, against_dragon, 
against_electric, against_fairy, against_fight, against_fire, 
against_flying, against_ghost, against_grass, against_ground,against_ice, 
against_normal, against_poison, against_psychic, against_rock, against_steel, against_water)

SELECT type1, type2, against_bug, against_dark, against_dragon, against_electric,
against_fairy, against_fight, against_fire, against_flying, against_ghost, against_grass, against_ground,
against_ice, against_normal, against_poison, against_psychic, against_rock, against_steel, against_water
FROM effectiveness_3;


-- Creating the final "effectiveness" table, which is just effectiveness_temp but ordered by type_1_id and type_2_id
CREATE TABLE effectiveness AS SELECT type_1_id, type_2_id, against_bug, against_dark, against_dragon, 
against_electric, against_fairy, against_fight, against_fire, 
against_flying, against_ghost, against_grass, against_ground,against_ice, 
against_normal, against_poison, against_psychic, against_rock, against_steel, against_water
FROM effectiveness_temp ORDER BY type_1_id, type_2_id;

-------------------------------------------------------------------------------------------------------------

-- Dropping excess tables
DROP TABLE tweaked_data;
DROP TABLE test_table;
DROP TABLE table_1nf; 
DROP TABLE wip_key;
DROP TABLE effectiveness_2;
DROP TABLE effectiveness_3;
DROP TABLE effectiveness_temp;

-- Oh my god did I finally finish




