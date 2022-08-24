/* ------------------------------------- RSVP Movie Case Study ------------------------------------- */

USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any 
 column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?

SELECT Count(*) AS Rows_director_mapping
FROM   director_mapping; -- Number of Rows = 3867
SELECT Count(*) AS Rows_genre
FROM   genre; -- Number of Rows = 14662
SELECT Count(*) AS Rows_movie
FROM   movie; -- Number of Rows = 7997
SELECT Count(*) AS Rows_names
FROM   names; -- Number of Rows = 25735
SELECT Count(*) AS rows_ratings
FROM   ratings; -- Number of Rows = 7997
SELECT Count(*) AS rows_role_mapping
FROM   role_mapping; -- Number of Rows = 15615

-- ------------------------------------------------------------------------------------------------- --

-- Q2. Which columns in the movie table have null values?

DESCRIBE movie;

SELECT Count(*)
FROM   movie; -- Total rows in the movie table is 7997
SELECT Count(title) "title"
FROM   movie; -- (7997 - 7997) = 0 null values 
SELECT Count(year) "year"
FROM   movie; -- (7997 - 7997) = 0 null values
SELECT Count(date_published) "date_published"
FROM   movie; -- (7997 - 7997) = 0 null values
SELECT Count(duration) "duration"
FROM   movie; -- (7997 - 7997) = 0 null values
SELECT Count(country) "country"
FROM   movie; -- (7997 - 7977) = 20 null values
SELECT Count(languages) "languages"
FROM   movie; -- (7997 - 7803) = 194 null values
SELECT Count(worlwide_gross_income) "worlwide_gross_income"
FROM   movie; -- (7997 - 4273) = 3724 null values
SELECT Count(production_company) "production_company"
FROM   movie; -- (7997 - 7469) = 528 null values

-- Therefore Columns country, languages, worlwide_gross_income, production_company have null values.

-- ------------------------------------------------------------------------------------------------- --

/* Now as you can see four columns of the movie table has null values. 
Let's look at the at the movies released each year. */

-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

SELECT year,
       Count(id) AS number_of_movies
FROM   imdb.movie
GROUP  BY year;

SELECT Month(date_published) AS month,
       Count(id) AS number_of_movies
FROM   imdb.movie
GROUP  BY Month(date_published)
ORDER  BY Month(date_published); 

-- Therefore the highest number of movies is produced in the month of march and the least in december.

-- ------------------------------------------------------------------------------------------------- --

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, 
let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. 
Lets find the number of movies produced by USA or India for the last year.*/

-- Q4. How many movies were produced in the USA or India in the year 2019??

SELECT Count(DISTINCT id) total_movies, year
FROM   movie
WHERE  (country LIKE '%india%'
        OR country LIKE'%usa%')
           AND year = 2019;
           
-- Therefore 1059 Movies produced in the USA or India in the year 2019.         

-- ------------------------------------------------------------------------------------------------- --

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?

SELECT DISTINCT( genre )
FROM   genre;

-- Therefore the unique generes are :
-- Drama, Fantasy, Thriller, Comedy, Horror, Family, Romance, Adventure, Action, Sci-Fi, Crime, Mystery, Others

-- ------------------------------------------------------------------------------------------------- --

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?

SELECT genre,
       Count(movie_id) AS Movie_Count
FROM   genre
GROUP  BY genre
ORDER  BY Count(movie_id) DESC
LIMIT  1;

-- Therefore Drama has the highest number of movies produced overall with a movie count of 4285

-- ------------------------------------------------------------------------------------------------- --

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?

WITH total_movie_count
     AS (SELECT genre,
                Count(movie_id) AS movie_count
         FROM   genre
         GROUP  BY movie_id
         ORDER  BY Count(movie_id))
SELECT Count(*) as Total_movie_count
FROM   total_movie_count
WHERE  movie_count = 1; 
 
-- Therefore 3289 movies belong to only one genre. 

-- ------------------------------------------------------------------------------------------------- --

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

SELECT genre,
       Round(Sum(duration) / Count(duration), 2) AS avg_duration
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
GROUP  BY genre
ORDER  BY avg_duration DESC; 

-- Therefore Action movies have the most duration of 112.88 minutes and Horror movies has the least duration of 92.72 minutes.

-- ------------------------------------------------------------------------------------------------- --

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)

WITH genre_wise_movies
     AS (WITH rank_of_thriller
              AS (SELECT genre,
                         Count(id) AS movie_count
                  FROM   movie m
                         INNER JOIN genre g
                                 ON m.id = g.movie_id
                  GROUP  BY genre
                  ORDER  BY Count(id))
         SELECT *,
                Rank()
                  OVER (
                    ORDER BY movie_count DESC) AS genre_rank
          FROM   rank_of_thriller)
SELECT *
FROM   genre_wise_movies
WHERE  genre = 'thriller';

-- Therefore Thriller is ranked as the 3rd in genres with movie count of 1484

-- ------------------------------------------------------------------------------------------------- --

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?

SELECT Min(avg_rating)    AS min_avg_rating,
       Max(avg_rating)    AS max_avg_rating,
       Min(total_votes)   AS min_total_votes,
       Max(total_votes)   AS max_total_votes,
       Min(median_rating) AS min_median_rating,
       Max(median_rating) AS max_median_rating
FROM   ratings; 

-- Therefore Min and Max Average rating is 1.0 and 10.0 respectively
-- Therefore Min and Max Total votes is 100 and 725138 respectively
-- Therefore Min and Max Median rating is 1 and 10 respectively

-- ------------------------------------------------------------------------------------------------- --

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?

WITH avg_rating
     AS (SELECT m.title AS title,
                avg_rating,
                row_number()
                  OVER(
                    ORDER BY avg_rating DESC) AS row_number_of_movies,
				Dense_Rank()
                  OVER(
                    ORDER BY avg_rating DESC) AS movie_rank
         FROM   ratings AS r
                INNER JOIN movie m
                        ON m.id = r.movie_id)
SELECT *
FROM   avg_rating
WHERE  movie_rank <= 10;

-- Therefore 'Kirket' and 'Love in Kilnerry' is ranked as 1st with an average rating of 10.0 
-- and our favourite movie 'Fan' is present in the top 10 movies with an average rating of 9.6

-- ------------------------------------------------------------------------------------------------- --

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.

SELECT median_rating,
       Count(movie_id) AS movie_count
FROM   ratings
GROUP  BY median_rating
ORDER  BY movie_count DESC; 

-- Therefore median rating of 7 is highest in number of movies count as 2257 
-- and median rating of 1 has the least number of movies count as 94

-- ------------------------------------------------------------------------------------------------- --

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??

WITH production_company_movies
     AS (SELECT m.production_company AS production_company,
                Count(m.id) AS movie_count,
                Dense_rank()
                  OVER(
                    ORDER BY Count(m.id) DESC) AS prod_company_rank
         FROM   ratings AS r
                INNER JOIN movie m
                        ON m.id = r.movie_id
         WHERE  avg_rating > 8
                AND production_company IS NOT NULL
         GROUP  BY production_company)
SELECT *
FROM   production_company_movies
WHERE  prod_company_rank = 1; 

-- Therefore "Dream Warrior Pictures" and "National Theatre Live" has produced the most number of hit movies with movie count as 3. 

-- ------------------------------------------------------------------------------------------------- --

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

SELECT genre,
       Count(id) AS movie_count
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
       INNER JOIN genre g
               ON r.movie_id = g.movie_id
WHERE  total_votes > 1000
       AND country LIKE '%usa%'
       AND Year(date_published) = 2017
       AND Month(date_published) = 3
GROUP  BY genre
ORDER BY movie_count DESC;

-- Therefore during March 2017 in the USA, the highest number of movies released is in Drama genre with movie count as 24
-- and the least is in Family genre with movie count as 1 which had more than 1,000 votes

-- ------------------------------------------------------------------------------------------------- --

-- Lets try to analyse with a unique problem statement.

-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?

SELECT m.title,
       r.avg_rating,
       g.genre
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
       INNER JOIN genre g
               ON g.movie_id = r.movie_id
WHERE  m.title LIKE "the%"
       AND r.avg_rating > 8
GROUP BY title
ORDER BY avg_rating DESC;
       
-- Therefore in Drama genre the movie "The Brighton Miracle" has the highest average rating of 9.5 
-- and "The King and I" has the least average rating of 8.2.

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.

SELECT m.title,
       r.median_rating,
       g.genre
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
       INNER JOIN genre g
               ON g.movie_id = r.movie_id
WHERE  m.title LIKE "the%"
       AND r.median_rating > 8
GROUP BY title
ORDER BY avg_rating DESC; 
       
-- Therefore the movie "The Brighton Miracle" in Drama genre has the highest Median rating of 10.
-- Therefore the movie "The Brighton Miracle" in Drama genre has the highest Average and Median rating.

-- ------------------------------------------------------------------------------------------------- --

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT Count(m.id) Movie_Count,
       r.median_rating
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
WHERE  r.median_rating = 8
       AND m.date_published BETWEEN '2018-04-01' AND '2019-04-01'; 

-- Therefore there are 361 movies released between 1 April 2018 and 1 April 2019 with a median rating of 8

-- ------------------------------------------------------------------------------------------------- --

-- Once again, try to solve the problem given below.

-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT m.country,
       Sum(r.total_votes) AS Total_Votes
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
WHERE  m.country IN ( "germany", "italy" )
GROUP  BY m.country; 

-- Therefore German movies have more number of votes than Italian movies

-- Answer is Yes

-- ------------------------------------------------------------------------------------------------- --

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/

SELECT Count(*)
FROM   names; -- 25735 rows

SELECT Count(NAME)
FROM   names; -- 25735 rows

SELECT Count(height)
FROM   names; -- 8400 rows

SELECT Count(date_of_birth)
FROM   names; -- 12304 rows

SELECT Count(known_for_movies)
FROM   names; -- 10509 rows

-- Therefore Except name all other columns have null values

-- ------------------------------------------------------------------------------------------------- --

-- Segment 3:

-- Q18. Which columns in the names table have null values??

SELECT Count(*) - Count(NAME)             AS name_nulls,
       Count(*) - Count(height)           height_nulls,
       Count(*) - Count(date_of_birth)    date_of_birth_nulls,
       Count(*) - Count(known_for_movies) known_for_movies_nulls
FROM   names; 

-- Therefore Except name all other columns have null values

-- ------------------------------------------------------------------------------------------------- --

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)

WITH genre_category AS
(
           SELECT     genre,
                      Dense_rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
           FROM       movie                                        AS m
           INNER JOIN genre                                        AS g
           ON         g.movie_id = m.id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id
           WHERE      avg_rating > 8
           GROUP BY   genre limit 3 )
SELECT     n.NAME            AS director_name ,
           Count(d.movie_id) AS movie_count
FROM       director_mapping  AS d
INNER JOIN genre G
using      (movie_id)
INNER JOIN names AS n
ON         n.id = d.name_id
INNER JOIN genre_category
using      (genre)
INNER JOIN ratings
using      (movie_id)
WHERE      avg_rating > 8
GROUP BY   director_name
ORDER BY   movie_count DESC limit 3 ;

-- Therefore James Mangold is the top director with movie count as 4.

-- ------------------------------------------------------------------------------------------------- --

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?

SELECT n.name AS actor_name,
       Count(m.id)
FROM   ratings r
       INNER JOIN movie m
               ON m.id = r.movie_id
       INNER JOIN role_mapping rm
               ON m.id = rm.movie_id
       INNER JOIN names n
               ON n.id = rm.name_id
WHERE  r.median_rating >= 8
GROUP  BY n.name
ORDER  BY Count(m.id) DESC
LIMIT  2; 

-- Therefore Mammootty and Mohanlal are the top two actors.

-- ------------------------------------------------------------------------------------------------- --

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?

WITH top_prod AS 
(   
                SELECT production_company,
                Sum(total_votes) AS vote_count,
                Dense_rank()
                  OVER(
                    ORDER BY Sum(total_votes) DESC) AS prod_comp_rank
         FROM   movie m
                INNER JOIN ratings r
                        ON m.id = r.movie_id
         GROUP  BY production_company)
SELECT *
FROM   top_prod
WHERE  prod_comp_rank <= 3;

-- Therefore Marvel Studios is ranked as ranked as No.1 with vote count of over 2.6 million(2656967)

-- ------------------------------------------------------------------------------------------------- --

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, 
-- then the total number of votes should act as the tie breaker.)

WITH top_actors
     AS (SELECT n.NAME
                AS
                actor_name,
                Sum(r.total_votes)
                AS
                   total_votes,
                Count(m.id)
                AS
                   movie_count,
                Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes), 2)
                AS
                actor_avg_rating,
                Dense_rank()
                  OVER(
                    ORDER BY Round(Sum(r.avg_rating *
                  r.total_votes)/Sum(r.total_votes), 2) DESC
                  )
                AS
                   actor_rank
         FROM   ratings r
                INNER JOIN movie m
                        ON m.id = r.movie_id
                INNER JOIN role_mapping rm
                        ON m.id = rm.movie_id
                INNER JOIN names n
                        ON n.id = rm.name_id
         WHERE  m.country = "india"
                AND rm.category = "actor"
         GROUP  BY n.NAME
         HAVING Count(m.id) >= 3)
SELECT *
FROM   top_actors
WHERE  actor_rank = 1; 

-- Therefore Vijay Sethupathi is the top actor with total votes of 23114 and average rating of 8.42

-- ------------------------------------------------------------------------------------------------- --

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. 
-- If the ratings clash, then the total number of votes should act as the tie breaker.)

WITH top_actress AS 
(
				SELECT n.NAME AS actress_name,
                rm.category AS Actor_Category,
                Sum(total_votes) AS total_votes,
                Count(m.id) AS movie_count,
                Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes), 2) AS actor_avg_rating,
                Dense_rank() OVER(ORDER BY Round(Sum(r.avg_rating * r.total_votes)/Sum(r.total_votes), 2) DESC)
                AS actress_rank
         FROM   ratings r
                INNER JOIN movie m
                        ON m.id = r.movie_id
                INNER JOIN role_mapping rm
                        ON m.id = rm.movie_id
                INNER JOIN names n
                        ON n.id = rm.name_id
         WHERE  rm.category = "actress"
                AND m.languages LIKE "%hindi%"
                AND m.country LIKE "%india%"
         GROUP  BY n.NAME
         HAVING Count(m.id) >= 3)
SELECT actress_name,
       total_votes,
       movie_count,
       actor_avg_rating,
       actress_rank
FROM   top_actress
WHERE  actress_rank <= 3; 

-- Therefore Taapsee Pannu is the Top actress with total_votes of 18061 and average rating of 7.74

-- ------------------------------------------------------------------------------------------------- --

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

SELECT m.title,
       CASE
         WHEN avg_rating > 8 THEN "superhit movies"
         WHEN avg_rating BETWEEN 7 AND 8 THEN "hit movies"
         WHEN avg_rating BETWEEN 5 AND 7 THEN "one-time-watch movies"
         ELSE "flop movies"
       END AS Movie_Category_as_per_Audience_rating
FROM   genre g
       INNER JOIN movie m
               ON g.movie_id = m.id
       INNER JOIN ratings r
               ON r.movie_id = m.id
WHERE  g.genre = "thriller";

-- ------------------------------------------------------------------------------------------------- --

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 

WITH average_duration AS
(
           SELECT     g.genre AS genre,
                      ROUND(Avg(m.duration),2) AS avg_duration
           FROM       genre g
           INNER JOIN movie m
           ON         g.movie_id= m.id
           GROUP BY   g.genre )
SELECT   *,
         round(sum(avg_duration) OVER w1) AS running_total_duration,
         round(avg(avg_duration) OVER w2) AS moving_avg_duration
FROM     average_duration window w1 AS (ORDER BY genre),
         w2 AS (ORDER BY genre);

-- ------------------------------------------------------------------------------------------------- --

-- Round is good to have and not a must have; Same thing applies to sorting

-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

WITH total_gross
     AS (SELECT m.year,
                g.genre,
                title AS movie_name,
                Sum(Cast(Substring(m.worlwide_gross_income, 2) AS unsigned INT)) AS worldwide_gross_income
         FROM   genre g
                INNER JOIN movie m
                        ON g.movie_id = m.id
         GROUP  BY m.year,
                   g.genre)
SELECT *,
       Dense_rank()
       OVER(
           partition BY year
           ORDER BY worldwide_gross_income DESC) AS movie_rank
FROM   total_gross;

-- ------------------------------------------------------------------------------------------------- --

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.

-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?

SELECT m.production_company AS production_company,
       Count(m.id) AS Movie_count,
       Dense_rank()
         OVER(
           ORDER BY Count(id) DESC) AS prod_comp_rank
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
WHERE  languages LIKE "%,%"
       AND m.production_company IS NOT NULL
       AND median_rating >= 8
GROUP  BY m.production_company;

-- Therefore the top 2 the top two production houses that have produced the highest number of hits 
-- among multilingual movies are Star Cinema and Twentieth Century Fox

-- ------------------------------------------------------------------------------------------------- --

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?

WITH top_actress
     AS (SELECT n.NAME AS actress_name,
                Sum(r.total_votes) AS total_votes,
                Count(m.id) AS movie_count,
                Round(Sum(avg_rating * r.total_votes) / Sum(total_votes),2) AS actress_avg_rating,
                Dense_rank()
                  OVER(
                    ORDER BY Count(m.id)
                  DESC) AS actress_rank
         FROM   genre g
                INNER JOIN movie m
                        ON m.id = g.movie_id
                INNER JOIN ratings r
                        ON r.movie_id = m.id
                INNER JOIN role_mapping rm
                        ON rm.movie_id = m.id
                INNER JOIN names n
                        ON n.id = rm.name_id
         WHERE  rm.category = "actress"
                AND g.genre = "drama"
                AND avg_rating>8
         GROUP  BY n.NAME)
SELECT *
FROM   top_actress
WHERE  actress_rank <= 3;

-- Therefore Parvathy Thiruvothu, Susan Brown and Amanda Lawrence are the top 3 actresses 
-- based on number of Super Hit movies in Drama genre

-- ------------------------------------------------------------------------------------------------- --

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations
*/

WITH director_Summary AS
(
           SELECT     dm.name_id       AS director_id,
                      n.NAME           AS director_name,
                      Count(m.id)      AS number_of_movies,
                      Avg(avg_rating)  AS avg_rating,
                      Sum(total_votes) AS total_votes,
                      Min(avg_rating)  AS min_rating,
                      Max(avg_rating)  AS max_rating,
                      Sum(duration)    AS total_duration ,
                      date_published
           FROM       ratings r
           INNER JOIN movie m
           ON         m.id = r.movie_id
           INNER JOIN director_mapping dm
           ON         dm.movie_id=m.id
           INNER JOIN names n
           ON         n.id = dm.name_id
           GROUP BY   n.NAME,
                      date_published 
), 
Time_diff AS
(
         SELECT   *,
                  Lead(date_published,1,"") OVER(partition BY director_name ORDER BY date_published,number_of_movies) AS next_release_date
         FROM     director_Summary 
), 
Summary AS
(
       SELECT *,
              Datediff(next_release_date,date_published) AS date_diff
       FROM   Time_diff )
SELECT   director_id,
         director_name,
         Count(number_of_movies) AS number_of_movies,
         Round(Avg(date_diff)) AS avg_inter_movie_days,
         avg_rating,
         total_votes,
         min_rating,
         max_rating,
         total_duration
FROM     Summary
GROUP BY director_id
ORDER BY Count(number_of_movies) DESC limit 9;

-- ------------------------------------------ THE END  ------------------------------------------------- --