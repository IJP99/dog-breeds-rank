use project_dogs;

-- turn off the safe mode to update a table
SET SQL_SAFE_UPDATES = 0;

create table breed (breed_name varchar(50) primary key,
affect_family int,
good_with_children int,
good_other_dogs int,
shedding_level int,
coat_grooming_freq int,
drooling_level int,
coat_type varchar(30),
coat_length varchar(30),
openness_strangers int,
playfullness_level int,
protective_nature int,
adaptability int,
trainability_level int,
energy_level int,
barking_level int,
mental_stimulation int);

CREATE TABLE breed_2 (
    Breed VARCHAR(50), 
    type VARCHAR(50), 
    score INT, 
    popularity_ranking INT, 
    size VARCHAR(50), 
    intelligence varchar(50),
    congenital_ailments VARCHAR(100), 
    score_for_kids INT, 
    size_1 VARCHAR(50), 
    lifetime_cost varchar(20),
    intelligence_rank INT, 
    intelligence_percent varchar(20), 
    longevity_years INT,
    number_of_genetic_ailments INT, 
    genetic_ailments VARCHAR(100), 
    purchase_price varchar(20),
    food_costs_per_year varchar(20), 
    grooming_frequency VARCHAR(50), 
    suitability_for_children VARCHAR(50)
);

-- Set the abnormal character into a white space
UPDATE project_dogs.breed SET breed_name = REPLACE(breed_name, 'Â', '');
update project_dogs.breed_2 set lifetime_cost = replace(lifetime_cost,"$", ""); 
update project_dogs.breed_2 set intelligence_percent = replace(intelligence_percent,"%", ""); 
update project_dogs.breed_2 set purchase_price = replace(purchase_price,"$", ""); 
update project_dogs.breed_2 set food_costs_per_year = replace(food_costs_per_year,"$", ""); 


-- Create a new column with the overall score

WITH general_data as (
	select *,
		((affect_family 
        + (good_with_children *2) 
        + (good_other_dogs *2) 
        - shedding_level 
        - (coat_grooming_freq *2) 
        - drooling_level 
        + (openness_strangers *2) 
        + (playfullness_level /2) 
        + (protective_nature /2) 
        + adaptability 
        + trainability_level 
        + energy_level 
        - barking_level 
        + mental_stimulation)/14) as general_score
	from project_dogs.breed)
select breed_name,
round(general_score,2),
dense_rank() OVER(ORDER BY general_score DESC) AS 'Rank'
from general_data
order by general_score desc
limit 15; 

-- top 5 dogs with better trainability level + adaptability + openness to strangers

select breed_name, round((trainability_level + adaptability + openness_strangers)/3,2) as sociability from project_dogs.breed
order by sociability desc
limit 10;


-- top 5 dogs that need more attention
with attention_data as (
	select *,
		round(((shedding_level + coat_grooming_freq + drooling_level + energy_level + mental_stimulation)/5),2) as attention_score
     from project_dogs.breed)
select breed_name, attention_score,
dense_rank() OVER(ORDER BY attention_score desc) AS 'Rank'
from attention_data;

-- top 5 dogs better as a friend
with friendly_data as (
	select *,
		round(((affect_family + good_with_children + good_other_dogs + openness_strangers + playfullness_level)/5),2) as sociability
     from project_dogs.breed)
select breed_name, sociability,
dense_rank() OVER(ORDER BY sociability DESC) AS 'Rank'
from friendly_data;

select * from project_dogs.breed_2;


-- Genetic ailments

SELECT Breed, number_of_genetic_ailments,
           ROW_NUMBER() OVER (ORDER BY number_of_genetic_ailments asc) AS row_num
    FROM breed_2
    where Breed = "Flat-Coated Retriever"
	or Breed = "Labrador Retriever"
	or Breed = "Irish Setter"
	or Breed = "Golden Retriever"
	or Breed = "French bulldog"
	or Breed = "Boston Terrier";
    
-- Lifetime cost of the determine dogs

select Breed, lifetime_cost,
dense_rank() OVER (ORDER BY lifetime_cost asc) AS "rank"
from project_dogs.breed_2
where Breed = "Flat-Coated Retriever"
	or Breed = "Labrador Retriever"
	or Breed = "Irish Setter"
	or Breed = "Golden Retriever"
	or Breed = "French bulldog"
	or Breed = "Boston Terrier";
    
  -- food cost per year of the determine dogs
  
select Breed, food_costs_per_year,
dense_rank() OVER (ORDER BY food_costs_per_year asc) AS "rank"
from project_dogs.breed_2
where Breed = "Flat-Coated Retriever"
	or Breed = "Labrador Retriever"
	or Breed = "Irish Setter"
	or Breed = "Golden Retriever"
	or Breed = "French bulldog"
	or Breed = "Boston Terrier";
    
-- Popularity ranking of the determine dogs

select Breed, popularity_ranking
from project_dogs.breed_2
where Breed = "Flat-Coated Retriever"
	or Breed = "Labrador Retriever"
	or Breed = "Irish Setter"
	or Breed = "Golden Retriever"
	or Breed = "French bulldog"
	or Breed = "Boston Terrier"
order by popularity_ranking asc;

-- longevity of the determine dogs

select Breed, longevity_years
from project_dogs.breed_2
where Breed = "Flat-Coated Retriever"
	or Breed = "Labrador Retriever"
	or Breed = "Irish Setter"
	or Breed = "Golden Retriever"
	or Breed = "French bulldog"
	or Breed = "Boston Terrier"
order by longevity_years desc;

-- top 5 least health issues (Border Terrier, Flat-Coated Retriever, Siberian Husky, Brussels Griffon, English Cocker Spaniel)

WITH least_genetic_ailments AS (
    SELECT Breed, number_of_genetic_ailments,
           ROW_NUMBER() OVER (ORDER BY number_of_genetic_ailments ASC) AS row_num
    FROM breed_2
    LIMIT 5
),
most_genetic_ailments AS (
    SELECT Breed, number_of_genetic_ailments,
           ROW_NUMBER() OVER (ORDER BY number_of_genetic_ailments DESC) AS row_num
    FROM breed_2
    LIMIT 5
)
SELECT l.Breed AS least_genetic_breed, l.number_of_genetic_ailments AS least_genetic_ailments,
       m.Breed AS most_genetic_breed, m.number_of_genetic_ailments AS most_genetic_ailments
FROM least_genetic_ailments l
LEFT JOIN most_genetic_ailments m ON l.row_num = m.row_num
UNION ALL
SELECT l.Breed AS least_genetic_breed, l.number_of_genetic_ailments AS least_genetic_ailments,
       m.Breed AS most_genetic_breed, m.number_of_genetic_ailments AS most_genetic_ailments
FROM least_genetic_ailments l
RIGHT JOIN most_genetic_ailments m ON l.row_num = m.row_num;

-- 3. Most common health problems (hip problems)

WITH CombinedAilments AS (
    SELECT congenital_ailments AS ailment
    FROM breed_2
    WHERE congenital_ailments != 'none'
    UNION ALL
    SELECT genetic_ailments AS ailment
    FROM breed_2
    WHERE genetic_ailments != 'none'
),
AilmentCounts AS (
    SELECT ailment, COUNT(*) AS count
    FROM CombinedAilments
    GROUP BY ailment
)
SELECT ailment, count
FROM AilmentCounts
WHERE count = (SELECT MAX(count) FROM AilmentCounts)
   OR count = (SELECT MIN(count) FROM AilmentCounts); 
   
-- 4. Kid friendly dogs (Border Collie, Australian Cattle Dog, Dachshund, Chihuahua)

SELECT Breed
FROM breed_2
WHERE score_for_kids >= 4 AND suitability_for_children = 3
LIMIT 5; 

-- 5. breeds that meet all the criteria (Australian Cattle Dog, Chihuahua)

SELECT Breed
FROM breed_2
WHERE score_for_kids >= 4
  AND suitability_for_children = 3
  AND congenital_ailments <= 1  AND NUMBER_OF_GENETIC_AILMENTS <= 1
  AND LONGEVITY_YEARS >= 12;  