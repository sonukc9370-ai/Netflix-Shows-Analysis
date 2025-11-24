# 🎬 Netflix Movies and TV Shows Data Analysis
![Netflix](Images/netflix_image.jpeg)

## 📌 Overview

This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following `README` provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## 📋 Prerequisites
- MySQL 8.0 or higher
- CSV file: `netflix_data.csv`
- Required MySQL permissions for LOAD DATA INFILE


## 📝 Schema Design

The project uses a database named `Netflix_P4` with a primary table `netflix`.

```sql
DROP DATABASE IF EXISTS Netflix_p4;
CREATE DATABASE Netflix_P4;
USE Netflix_P4;

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
```

## 📥 Data Import

The data is imported from a CSV file using the `LOAD DATA INFILE` command for efficiency.

> **⚠️ Important Note:** Please update the file path in the command below to match the location of your `netflix_titles.csv` file on your local machine.
> Alternatively, you can use the **Table Data Import Wizard** in your SQL client if you encounter permission errors.

```sql
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_titles.csv'
INTO TABLE netflix
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

---

## 🚀 Key Analysis (Complex Queries)

Below are some of the advanced SQL queries used to solve specific business problems, utilizing Common Table Expressions (CTEs), JSON string manipulation, and Window Functions.

### 1. Find the Most Common Rating for Movies and TV Shows
*Identifies the most frequent rating for each content type using Window Functions.*
```sql
WITH RatingCount AS (
    SELECT 
        Type, 
        rating, 
        COUNT(*) AS Total 
    FROM netflix 
    GROUP BY Type, rating 
    ORDER BY Type
),
RankedRating AS (
    SELECT 
        Type, 
        rating, 
        Total, 
        RANK() OVER(PARTITION BY Type ORDER BY Total DESC) AS rnk 
    FROM RatingCount
)
SELECT 
    Type, 
    rating AS "Common Rating" 
FROM RankedRating
WHERE rating IS NOT NULL AND rnk = 1;
```

### 2. Count the Number of Content Items in Each Genre
*Uses JSON parsing to handle genres listed as comma-separated values.*
```sql
SELECT 
    jt.listed_in AS Genre, 
    COUNT(*) AS No_Of_Contents 
FROM netflix n 
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(n.listed_in, ',', '","'), '"]'),
    '$[*]' COLUMNS (listed_in VARCHAR(100) PATH '$')
) jt 
GROUP BY Genre 
ORDER BY No_Of_Contents DESC;
```

### 3. Top 5 Years with Highest Average Content Release
*Calculates the yearly average release share for India.*
```sql
SELECT 
    YEAR(STR_TO_DATE(date_added, "%M %d,%Y")) AS Year, 
    ROUND(
        COUNT(show_id) / (SELECT COUNT(*) FROM Netflix WHERE Country = 'India') * 100, 2
    ) AS Avg_Content_Release 
FROM Netflix 
WHERE Country = 'India' 
GROUP BY Year 
ORDER BY Avg_Content_Release DESC 
LIMIT 5;
```

### 4. Top 10 Actors with Most Movies (India)
*Splits the 'casts' column to find the most popular actors in Indian content.*
```sql
SELECT 
    jt.casts, 
    COUNT(*) AS No_Of_Movies 
FROM Netflix n 
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(n.casts, ',', '","'), '"]'),
    '$[*]' COLUMNS (casts VARCHAR(100) PATH '$')
) jt 
WHERE n.Country = 'India' AND jt.casts <> '' 
GROUP BY jt.casts 
ORDER BY No_Of_Movies DESC 
LIMIT 10;
```

### 5. Categorize Content by Keywords ('Kill' & 'Violence')
*Segments content into 'Mature' or 'General' categories based on description keywords.*
```sql
SELECT 
    CASE 
        WHEN description LIKE "%kill%" OR description LIKE "%violence%" THEN "Mature Audience"
        ELSE "Avail_for_all"
    END Category, 
    COUNT(*) AS Total_Collection 
FROM Netflix 
GROUP BY Category;
```

---

## 🔎 Standard Analysis
<details>
<summary><strong>Click to expand Standard Queries</strong></summary>
<br>

**1. Count the Number of Movies vs TV Shows**
```sql
SELECT Type, COUNT(*) AS Total FROM netflix GROUP BY Type;
```

**2. List All Movies Released in a Specific Year (e.g., 2020)**
```sql
SELECT * FROM netflix WHERE release_year = 2020;
```

**3. Find the Top 5 Countries with the Most Content on Netflix**
```sql
SELECT Country, COUNT(show_ID) AS Total_Content 
FROM netflix WHERE Country <> '' 
GROUP BY Country ORDER BY Total_Content DESC LIMIT 5;
```

**4. Identify the Longest Movie**
```sql
SELECT title AS Movie_Name, duration 
FROM netflix 
WHERE Type = 'Movie' 
AND duration = (SELECT MAX(duration) FROM netflix WHERE Type = 'Movie');
```

**5. Find Content Added in the Last 5 Years**
```sql
SELECT * FROM netflix 
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);
```

**6. Find All Movies/TV Shows by Director 'Rajiv Chilaka'**
```sql
SELECT Type, Title FROM netflix WHERE director LIKE "%Rajiv Chilaka%";
```

**7. List All TV Shows with More Than 5 Seasons**
```sql
SELECT title, duration FROM netflix 
WHERE Type = 'Tv Show' 
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
```

**8. List All Movies that are Documentaries**
```sql
SELECT title AS Movie_name FROM Netflix WHERE listed_in LIKE "%documentaries%";
```

**9. Find All Content Without a Director**
```sql
SELECT * FROM Netflix WHERE director = ''; 
```

**10. Find How Many Movies Actor 'Salman Khan' Appeared in Last 10 Years**
```sql
SELECT Type, COUNT(*) AS No_Of_Times 
FROM Netflix 
WHERE Type = 'Movie' 
AND casts LIKE "%Salman Khan%" 
AND YEAR(STR_TO_DATE(date_added, "%M %d, %Y")) >= Year(Curdate())- 10 
GROUP BY Type;
```
</details>

---

## 💡 Key Findings & Insights

### 1. Content Distribution
The library is dominated by Movies, which account for **70%** of total content, while TV Shows make up the remaining **30%**.

![Image1](Images/images1.png)

---

### 2. Top Markets
The **United States (58%)** is the leading content provider, followed closely by **India (18%)** and the **UK (11%)**, indicating Netflix's core production regions.

![Image2](Images/images2.png)

---

### 3. Genre Trends
**International Movies**, **Dramas**, and **Comedies** are the most populated genres, showing a shift towards diverse and dramatic storytelling.

![Images3](Images/images3.png)

---

### 4. Talent Analysis (India)
Actors like **Anupam Kher** and **Shah Rukh Khan** appear most frequently in Indian movies, establishing themselves as key figures in the region's library.

![Images4](Images/images4.png)

---

### 5. Content Classification
Approximately **95.55%** of the shows fall into the **"Mature Audience"** category (based on keywords like *kill* and *violence*), highlighting a significant segment of action/thriller content.

![Images5](Images/images5.png)

## 🛠️ How to Use

1. **Clone the Repository**
   ```bash
   git clone https://github.com/sonukc9370-ai/Netflix-Shows-Analysis
   ```

2. **Set Up the Database**
   * Use the provided `CREATE DATABASE` and `CREATE TABLE` scripts to set up the schema in MySQL.

3. **Import Data**
   * Load the `netflix_titles.csv` file into the database.
   * **Note:** Update the file path in the `LOAD DATA INFILE` script to your local directory or use the Import Wizard.

4. **Run Queries**
   * Execute the queries provided in the analysis section to reproduce the insights.
