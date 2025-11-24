DROP DATABASE IF EXISTS Netflix_p4;
CREATE DATABASE Netflix_P4;

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
    show_id VARCHAR(5),
    type VARCHAR(10),
    title VARCHAR(250),
    director VARCHAR(550),
    casts VARCHAR(1050),
    country VARCHAR(550),
    date_added VARCHAR(55),
    release_year INT,
    rating VARCHAR(15),
    duration VARCHAR(15),
    listed_in VARCHAR(250),
    description VARCHAR(550)
);

-- Importing Netflix.csv file 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_titles.csv'  -- change this file path to your local directory path
INTO TABLE netflix
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Business Problems Solutions
-- 1. Count the Number of Movies vs TV Shows
SELECT Type,count(*) as Total
FROM netflix GROUP BY Type;

-- 2. Find the Most Common Rating for Movies and TV Shows
With
	RatingCount As(
		SELECT
			Type,
            rating,
            count(*) as Total
		FROM netflix
        GROUP BY Type,rating
        ORDER BY Type
    ),
    RankedRating As(
		SELECT
			Type,
            rating,
			Total,
            rank() over(partition by Type order by Total DESC) as rnk
		FROM RatingCount
    )
    SELECT Type,rating as "Common Rating" FROM RankedRating
    WHERE rating IS NOT NULL AND rnk=1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
   SELECT * FROM netflix
   WHERE release_year= 2020;
   
   -- 4. Find the Top 5 Countries with the Most Content on Netflix
SELECT
	Country,
    count(show_ID) as Total_Content
FROM netflix
WHERE Country <> ''
GROUP BY Country
ORDER BY Total_Content DESC
LIMIT 5;


-- 5. Identify the Longest Movie
SELECT 
    title as Movie_Name,
    duration  
FROM netflix
WHERE Type='Movie' AND
duration = (SELECT Max(duration) FROM netflix WHERE Type='Movie');


-- 6. Find Content Added in the Last 5 Years
SELECT * FROM netflix
WHERE STR_TO_DATE(date_added,'%M %d, %Y') >= DATE_SUB(curdate(),INTERVAL 5 YEAR);


-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT
	Type,
    Title
FROM netflix WHERE director LIKE "%Rajiv Chilaka%";


-- 8. List All TV Shows with More Than 5 Seasons
SELECT title,duration FROM netflix
WHERE Type='Tv Show' AND CAST(SUBSTRING_INDEX(duration,' ',1) AS unsigned) >5;


-- 9. Count the Number of Content Items in Each Genre
SELECT 
	jt.listed_in as Genre,
    Count(*) as No_Of_Contents
FROM netflix n
JOIN JSON_TABLE(
	CONCAT('["',REPLACE(n.listed_in,',','","'),'"]'),
    '$[*]' COLUMNS (listed_in VARCHAR(100) PATH '$')
    ) jt
GROUP BY Genre
ORDER BY No_Of_Contents DESC;


-- 10.Find each year and the average numbers of content release in India on netflix
-- return top 5 year with highest avg content release!
SELECT 
	YEAR(STR_TO_DATE(date_added,"%M %d,%Y")) AS Year,
    -- release_year,
    ROUND(Count(show_id)/(SELECT count(*) FROM Netflix WHERE Country='India')*100,2)  As Avg_Content_Release
FROM Netflix
WHERE Country='India'
GROUP BY Year
ORDER BY Avg_Content_Release DESC
LIMIT 5;

-- 11. List All Movies that are Documentaries
SELECT title as Movie_name FROM Netflix
WHERE listed_in LIKE "%documentaries%";

-- 12. Find All Content Without a Director
SELECT * FROM Netflix
WHERE director= '';     -- there's space for director rather than a NULL VALUE


-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT
	Type,
    count(*) As No_Of_Times
FROM Netflix
WHERE Type='Movie' AND casts LIKE "%Salman Khan%" 
AND YEAR(STR_TO_DATE(date_added,"%M %d, %Y")) >= 10
GROUP BY Type;

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT
	jt.casts,
    count(*) as No_Of_Movies
FROM Netflix n JOIN JSON_TABLE(
	CONCAT('["',REPLACE(n.casts,',','","'),'"]'),
    '$[*]' COLUMNS (casts VARCHAR(100) PATH '$')
) jt
WHERE n.Country='India' AND jt.casts <> ''
GROUP BY jt.casts
ORDER BY No_Of_Movies DESC
LIMIT 10;


-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
	CASE
		WHEN description LIKE "%kill%" OR "%violence%" THEN "Mature Audience"
        ELSE "Avail_for_all"
	END Category,
    count(*) as Total_Collection
FROM Netflix
GROUP BY Category;


