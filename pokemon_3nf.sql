-- Transition to 3NF
-- Final concern: Fixing the "effectiveness" table? 


___________________________________________________________________________________
-- Current "effectiveness" table

-- Create the "effectiveness" table
-- Stats like "against_fire", "against_dark", etc. are long and repeated- grouping them into a separate table for readability 
-- Auto-generated integer 'efec_id' primary key // Foreign key: pokedex_number from central_pokemon

CREATE TABLE IF NOT EXISTS effectiveness('efec_id' INTEGER PRIMARY KEY NOT NULL, 'pokedex_number',
'against_bug' REAL, 'against_dark' REAL, 'against_dragon' REAL,
'against_electric' REAL, 'against_fairy' REAL, 'against_fight' REAL, 'against_fire' REAL,
'against_flying' REAL, 'against_ghost' REAL, 'against_grass' REAL, 'against_ground' REAL,
'against_ice' REAL, 'against_normal' REAL, 'against_poison' REAL, 'against_psychic' REAL,
'against_rock' REAL, 'against_steel' REAL, 'against_water' REAL,
FOREIGN KEY (pokedex_number) REFERENCES central_pokemon(pokedex_number));

-- Inserting into the effectiveness table (drawing data from tweaked_data) 
INSERT INTO effectiveness(pokedex_number, against_bug, against_dark, against_dragon, against_electric,
against_fairy, against_fight, against_fire, against_flying, against_ghost, against_grass, against_ground,
against_ice, against_normal, against_poison, against_psychic, against_rock, against_steel, against_water)

SELECT w.pokedex_number, against_bug, against_dark, against_dragon, against_electric,
against_fairy, against_fight, against_fire, against_flying, against_ghost, against_grass, against_ground,
against_ice, against_normal, against_poison, against_psychic, against_rock, against_steel, against_water 

FROM tweaked_data as t, central_pokemon as w WHERE w.pokedex_number = t.pokedex_number;

___________________________________________________________________________________

-- against_x is transitively dependent on pokedex_number, so the primary key of the effectiveness table needs to be changed
-- Replace with a composite key of each pokemon's types 

-- Reference CREATE TABLE type_trash2 AS SELECT type1, type2 FROM tweaked_data LIMIT 30;

-- Inserting a "" placeholder for empty type_2s into types_t
INSERT INTO types_t(type_name) VALUES ('');

-- Create the "wip_key" temp table of all the types for each pokemon
CREATE TABLE wip_key AS SELECT type1, type2, tweaked_data.pokedex_number FROM tweaked_data, effectiveness WHERE tweaked_data.pokedex_number = effectiveness.pokedex_number;

SELECT DISTINCT (type1, type2) FROM wip_key ORDER BY type_1;

-- Create the "effectiveness_2" table
-- Connects all the types for every pokemon + their effectiveness againt other types
CREATE TABLE effectiveness_2 AS SELECT type1, type2, against_bug, against_dark, against_dragon, against_electric,
against_fairy, against_fight, against_fire, against_flying, against_ghost, against_grass, against_ground,
against_ice, against_normal, against_poison, against_psychic, against_rock, against_steel, against_water
FROM wip_key, effectiveness WHERE wip_key.pokedex_number = effectiveness.pokedex_number;

-- I NEED TO SELECT ONLY DISTINCT COMBOS OF ABILITIES 


-- Updates effectiveness_2 to list type_ids instead of type names
UPDATE effectiveness_2 SET type1 = (SELECT types_t.type_id FROM types_t WHERE effectiveness_2.type1 = types_t.type_name);
UPDATE effectiveness_2 SET type2 = (SELECT types_t.type_id FROM types_t WHERE effectiveness_2.type2 = types_t.type_name);


CREATE TABLE distinct_type_combos AS SELECT DISTINCT type1, type2 FROM effectiveness_2 ORDER BY type1;


SELECT d.type1, d.type2, against_bug, against_dark, against_dragon, against_electric,
against_fairy, against_fight, against_fire, against_flying, against_ghost, against_grass, against_ground,
against_ice, against_normal, against_poison, against_psychic, against_rock, against_steel, against_water
FROM effectiveness_2 as e, distinct_type_combos as d WHERE e.type1 = d.type1 AND e.type2 = d.type2 LIMIT 10; 

-- Drop old effectiveness table
DROP TABLE effectiveness;



-- Creating the new "effectiveness" table
CREATE TABLE IF NOT EXISTS effectiveness(type_1_id INT NOT NULL, type_2_id INT DEFAULT 19 NOT NULL,
'against_bug' REAL, 'against_dark' REAL, 'against_dragon' REAL,
'against_electric' REAL, 'against_fairy' REAL, 'against_fight' REAL, 'against_fire' REAL,
'against_flying' REAL, 'against_ghost' REAL, 'against_grass' REAL, 'against_ground' REAL,
'against_ice' REAL, 'against_normal' REAL, 'against_poison' REAL, 'against_psychic' REAL,
'against_rock' REAL, 'against_steel' REAL, 'against_water' REAL,
PRIMARY KEY(type_1_id, type_2_id), FOREIGN KEY(type_1_id) REFERENCES types_t(type_id),
FOREIGN KEY(type_2_id) REFERENCES types_t(type_id)); 


INSERT INTO effectiveness(type_1_id, type_2_id, against_bug, against_dark, against_dragon, 
against_electric, against_fairy, against_fight, against_fire, 
against_flying, against_ghost, against_grass, against_ground,against_ice, 
against_normal, against_poison, against_psychic, against_rock, against_steel, against_water)

SELECT UNIQUE(type1, type2), against_bug, against_dark, against_dragon, against_electric,
against_fairy, against_fight, against_fire, against_flying, against_ghost, against_grass, against_ground,
against_ice, against_normal, against_poison, against_psychic, against_rock, against_steel, against_water 
FROM effectiveness_2;




