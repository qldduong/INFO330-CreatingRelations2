-- Create the central table; holds pokemon stats like name and attack; other information will be stored in separate tables

-- central_pokemon uses pokedex_number as its primary key 
CREATE TABLE IF NOT EXISTS central_pokemon('pokedex_number' INT PRIMARY KEY NOT NULL, 'name' TEXT,
'attack' INT,'base_egg_steps' INT, 'base_happiness' INT, 'capture_rate' INT,
'classification' TEXT, 'defense' INT, 'experience_growth' INT,'height_m' REAL, 'hp' INT, 'percentage_male' REAL,
'sp_attack' INT, 'sp_defense' INT, 'speed' INT, 'weight_kg' REAL, 'base_total' INT, 'generation' INT, 'is_legendary' INT);

-- Inserting into central_pokemon (drawing from tweaked_data)
INSERT INTO central_pokemon(pokedex_number, name, attack,
base_egg_steps, base_happiness, capture_rate,
classification, defense, experience_growth, height_m,
hp,percentage_male, sp_attack, sp_defense, speed, weight_kg, base_total, generation, is_legendary)

SELECT pokedex_number, name, attack,
base_egg_steps, base_happiness, capture_rate,
classification, defense, experience_growth, height_m,
hp,percentage_male, sp_attack, sp_defense, speed, weight_kg, base_total, generation, is_legendary 

FROM tweaked_data;
-------------------------------------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------------------------------------

-- Create the "types_t" table
-- Type1 and Type2, "" for pokemon without a second type
-- Auto-generated integer 'type_id' primary key // Foreign key: pokedex_number from central_pokemon


-- Creating a "types_t" table, assigning each unique type its own type_id
CREATE TABLE IF NOT EXISTS types_t('type_id' INTEGER PRIMARY KEY NOT NULL, 'type_name' TEXT);
INSERT INTO types_t(type_name) SELECT DISTINCT type1 FROM tweaked_data;



-- Creating a "pok_type_link" junction table between types_t and central_pokemon
CREATE TABLE IF NOT EXISTS pok_type_link('pok_type_id' INTEGER PRIMARY KEY NOT NULL, 'pokedex_number' INT, 'type_id' INT,
FOREIGN KEY(pokedex_number) REFERENCES central_pokemon(pokedex_number), FOREIGN KEY (type_id) REFERENCES types_t(type_id));

-- Inserting into "pok_type_link"
INSERT INTO pok_type_link(pokedex_number, type_id) SELECT w.pokedex_number, t.type_id FROM
central_pokemon as w, types_t as t, tweaked_data as x WHERE x.pokedex_number = w.pokedex_number
AND (t.type_name = x.type1 OR t.type_name = x.type2); 

-------------------------------------------------------------------------------------------------------------
-- Many-to-Many bad! We'll want to use a linking table instead.

-- Creating an "abilities_t" table, assigning each unique ability its own integer ability_id

CREATE TABLE IF NOT EXISTS abilities_t('abil_id' INTEGER PRIMARY KEY NOT NULL, 'ability_name' TEXT);
INSERT INTO abilities_t(ability_name) SELECT DISTINCT ability FROM test_table; 



-- Creating a "pok_abil_link" junction table between abilities_t and central_pokemon

CREATE TABLE IF NOT EXISTS pok_abil_link('pok_abil_id' INTEGER PRIMARY KEY NOT NULL, 'pokedex_number' INT, 'abil_id' INT,
FOREIGN KEY(pokedex_number) REFERENCES central_pokemon(pokedex_number), FOREIGN KEY(abil_id) REFERENCES abilities_t(abil_id)); 

-- Inserting into "pok_abil_link"
INSERT INTO pok_abil_link(pokedex_number, abil_id) SELECT w.pokedex_number, a.abil_id FROM
central_pokemon as w, abilities_t as a, test_table as t WHERE t.pokedex_number = w.pokedex_number
AND a.ability_name = t.ability; 


-------------------------------------------------------------------------------------------------------------

-- TABLES TO DROP: Imported_pokemon_data, tweaked_data





