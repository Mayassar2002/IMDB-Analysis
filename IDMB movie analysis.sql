-- Q1. Find the total number of rows in each table of the schema?
SELECT table_name,
       table_rows
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_SCHEMA = 'imdb'; 

-- Q2. Which columns in the movie table have null values?
describe movie;
SELECT "title", COUNT(*) AS NULL_COUNT FROM movie
WHERE title IS NULL 
UNION 
SELECT "year", COUNT(*) AS NULL_COUNT FROM movie
WHERE year IS NULL 
UNION
SELECT "date_published", COUNT(*) AS NULL_COUNT FROM movie
WHERE date_published IS NULL 
UNION 
SELECT "duration", COUNT(*) AS NULL_COUNT FROM movie
WHERE duration IS NULL 
UNION 
SELECT "country", COUNT(*) AS NULL_COUNT FROM movie
WHERE country IS NULL 
UNION 
SELECT "worlwide_gross_income", COUNT(*) AS NULL_COUNT FROM movie
WHERE worlwide_gross_income IS NULL 
UNION 
SELECT "languages", COUNT(*) AS NULL_COUNT FROM movie
WHERE languages IS NULL 
UNION 
SELECT "production_company", COUNT(*) AS NULL_COUNT FROM movie
WHERE production_company IS NULL;

-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
SELECT year, COUNT(TITLE) AS No_of_movie FROM movie
GROUP BY year;
-- trend look month wise
SELECT MONTH(date_published) AS Month_wise,COUNT(title) AS Count_of_movie FROM movie
GROUP BY 1
ORDER BY 2 DESC;

-- -- Q4. How many movies were produced in the USA or India in the year 2019??
SELECT country,COUNT(title) AS Count_of_movie FROM movie
WHERE year = 2019
GROUP BY 1
ORDER BY 2 DESC;

-- Q5. Find the unique list of the genres present in the data set?
SELECT DISTINCT genre FROM genre;
-- Q6.Which genre had the highest number of movies produced overall?
SELECT genre, COUNT(title) AS No_of_movie FROM movie M INNER JOIN genre G 
ON M.id=G.movie_id
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 1;
-- Q7. How many movies belong to only one genre?
WITH CTE AS (SELECT COUNT(G.genre),M.ID FROM genre G INNER JOIN movie M 
ON G.movie_id=M.id
GROUP BY  2
HAVING COUNT(genre) =1)
SELECT COUNT(ID) FROM MOVIE;

WITH AGG
     AS (SELECT m.ID,
                Count(g.GENRE) AS Genre
         FROM   MOVIE m
                INNER JOIN GENRE g
                        ON g.MOVIE_ID = m.ID
         GROUP  BY ID
         HAVING Count(g.GENRE) = 1)
SELECT Count(ID) AS movie_count
FROM   AGG; 
-- Q8.What is the average duration of movies in each genre?
SELECT genre,AVG(duration) AS Average_Duration FROM movie M INNER JOIN genre G 
ON M.id=G.movie_id
GROUP BY genre;
-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

WITH CTE AS 
(SELECT genre,COUNT(movie_id), RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS Ranks FROM genre
GROUP BY genre) 
SELECT genre, ranks FROM CTE WHERE genre = "thriller";

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
SELECT MAX(avg_rating) AS MAX_VALUE,MIN(avg_rating) AS MIN_VALUE FROM ratings
UNION
SELECT MAX(total_votes) AS MAX_VALUE,MIN(total_votes) AS MIN_VALUE FROM ratings
UNION
SELECT MAX(median_rating) AS MAX_VALUE,MIN(median_rating) AS MIN_VALUE FROM ratings
;

SELECT ROUND(MIN(AVG_RATING), 1) AS min_avg_rating,
       ROUND(MAX(AVG_RATING), 1) AS max_avg_rating,
       MIN(TOTAL_VOTES)          AS min_total_votes,
       MAX(TOTAL_VOTES)          AS max_total_votes,
       MIN(MEDIAN_RATING)        AS min_median_rating,
       MAX(MEDIAN_RATING)        AS max_median_rating
FROM   RATINGS; 

-- Q11. Which are the top 10 movies based on average rating?
SELECT title, avg_rating FROM movie M INNER JOIN ratings R 
ON M.ID=R.movie_id
ORDER BY 2 DESC 
LIMIT 10;

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
SELECT median_rating,COUNT(movie_id) FROM ratings
GROUP BY 1
ORDER BY 1 DESC;


-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
SELECT genre,COUNT(title) AS Total_no_movies FROM movie M INNER JOIN genre G ON M.id=G.movie_id
INNER JOIN ratings R ON R.movie_id=M.id
WHERE YEAR = 2017 AND country LIKE "USA" AND total_votes > 1000
GROUP BY genre
ORDER BY 2 DESC;

-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
SELECT title FROM movie M INNER JOIN ratings R ON M.id=R.movie_id
WHERE title like  "The%" AND avg_rating > 8;

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
SELECT * FROM movie M INNER JOIN ratings R ON M.ID=R.movie_id
WHERE date_published  BETWEEN "2018-04-01" AND "2019-04-01"
AND median_rating = 8;

-- Q17. Do German movies get more votes than Italian movies? 
SELECT languages,SUM(total_votes)  AS Total_votes FROM movie M INNER JOIN ratings R ON M.ID=R.movie_id
WHERE languages = "GERMAN"
UNION
SELECT languages,SUM(total_votes) AS Total_votes FROM movie M INNER JOIN ratings R ON M.ID=R.movie_id
WHERE languages = "ITALIAN"
GROUP BY languages;
-- Q18. Which columns in the names table have null values??
DESCRIBE names;

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
WITH Top_Genre AS (SELECT r.movie_id,genre,avg_rating FROM genre G INNER JOIN ratings R ON G.movie_id=R.movie_id
WHERE avg_rating > 8
ORDER BY 2 DESC
)
(SELECT name,name_id,genre, avg_rating FROM director_mapping D INNER JOIN TOP_GENRE T
ON D.movie_id=T.movie_id  INNER JOIN names N ON N.id=D.name_id
ORDER BY 4 DESC
LIMIT 3 );

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
WITH ACTOR AS (SELECT category,title,avg_rating,name_id FROM movie M INNER JOIN ratings R ON M.id=R.movie_id 
INNER JOIN role_mapping RM ON RM.movie_id=R.movie_id
WHERE median_rating > 8 AND category = "ACTOR"
)
SELECT name,avg_rating FROM names N INNER JOIN ACTOR A ON N.ID=A.NAME_ID
ORDER BY 2 DESC
LIMIT 3;
SELECT * FROM ratings;
-- Q21. Which are the top three production houses based on the number of votes received by their movies?
SELECT production_company,SUM(total_votes) AS No_of_votes FROM movie M INNER JOIN ratings R 
ON M.id=R.movie_id 
GROUP BY production_company
ORDER BY 2 DESC 
LIMIT 3;

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
WITH CTE AS (SELECT name_id,title,country,avg_rating FROM movie M INNER JOIN ratings R 
ON M.id=R.movie_id INNER JOIN role_mapping RM ON R.movie_id=RM.movie_id
WHERE country = "INDIA"
)
SELECT name,title,avg_rating, country FROM names N INNER JOIN CTE ON CTE.name_id=N.id
ORDER BY avg_rating DESC;

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
WITH Top_act AS (SELECT category,name_id,title,country,avg_rating FROM movie M INNER JOIN ratings R 
ON M.id=R.movie_id INNER JOIN role_mapping RM ON R.movie_id=RM.movie_id
WHERE country = "INDIA" AND category = "actress"
) 
SELECT name,title,avg_rating FROM names N INNER JOIN TOP_ACT T
ON N.id=T.name_id
ORDER BY avg_rating DESC;

-- Q24. Select thriller movies as per avg rating and classify them in the following category: 
/*
Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
*/
-- Q25. What is the genre-wise running total and moving average of the average movie duration? 

WITH Thriller_mov AS (select title,avg_rating,genre FROM movie M INNER JOIN genre G ON M.id=G.movie_id
INNER JOIN ratings R ON G.movie_id=R.movie_id
WHERE genre = "THRILLER")
SELECT title AS Movie,Avg_rating , CASE WHEN avg_rating BETWEEN 7 AND 8 THEN "Hit_movie"
WHEN avg_rating BETWEEN 5 AND 7  THEN "One_time_watch"
WHEN avg_rating < 5 THEN "Flop_movie"
 END AS "Avg_rating"
FROM Thriller_mov;

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
SELECT year,MAX(worlwide_gross_income) FROM movie M INNER JOIN genre G ON M.id=G.movie_id
GROUP BY year;
SELECT COUNT(title) AS Count_of_movie ,genre FROM movie M INNER JOIN genre G ON M.id=G.movie_id
GROUP BY genre
ORDER BY 1 DESC;

-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
SELECT production_company ,COUNT(production_company) AS Movie_count ,
DENSE_RANK() OVER (ORDER BY COUNT(production_company)) AS Production_com_rank
FROM movie m INNER JOIN ratings R ON M.ID=R.movie_id
WHERE avg_rating >= 8 AND languages REGEXP ","  
GROUP BY production_company
;

SELECT     production_company,
           COUNT(PRODUCTION_COMPANY)                                  AS movie_count ,
           DENSE_RANK() OVER(ORDER BY COUNT(PRODUCTION_COMPANY) DESC) AS prod_comp_rank
FROM       MOVIE M
INNER JOIN RATINGS RA
ON         M.ID=RA.MOVIE_ID
WHERE      MEDIAN_RATING>=8
AND        LANGUAGES REGEXP ','
GROUP BY   PRODUCTION_COMPANY
LIMIT      2;


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
SELECT title,avg_rating,name FROM movie M INNER JOIN ratings R ON M.id=R.movie_id
INNER JOIN genre G ON R.movie_id=G.movie_id
INNER JOIN role_mapping RM ON G.movie_id=RM.movie_id
INNER JOIN names N ON N.id=rm.name_id
WHERE avg_rating > 8 AND genre = "DRAMA" AND category = "ACTRESS"
ORDER BY 2 DESC 
LIMIT 3;


