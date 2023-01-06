USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/


-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
SELECT table_name, table_rows as 'Number of Rows'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'imdb';
 -- other method
--
select count(*) as 'Number of rows in director_mapping table'
from director_mapping;
-- Number of rows in director_mapping table is 3867

SELECT Count(*) AS 'Number of rows in genre table'
FROM   genre; 
-- Number of rows in genre table is 14662

SELECT Count(*) AS 'Number of rows in movie table'
FROM   movie;
-- Number of rows in movie table is 7997
 
SELECT Count(*) AS 'Number of  rows in names table'
FROM  names; 
-- Number of rows in names table is 25735

SELECT Count(*) AS 'Number of rows in ratings table'
FROM   ratings;
-- Number of rows in ratings table is 7997

SELECT Count(*) AS 'Number of rows in role_mapping table'
FROM   role_mapping; 
-- Number of rows in role_mapping table is 15615

-- Q2. Which columns in the movie table have null values?
-- Solution:
			
 select sum(case when id is null then 1 else 0 end) as 'id_null_count',
             sum(case when title is null then 1 else 0 end) as 'title_null_count',
             sum(case when year is null then 1 else 0 end) as 'year_null_count',
             sum(case when date_published is null then 1 else 0 end) as 'date_published_null_count',
             sum(case when duration is null then 1 else 0 end) as 'duration_null_count',
			sum(case when worlwide_gross_income is null then 1 else 0 end) as 'worlwide_gross_income_null_count',
			sum(case when languages is null then 1 else 0 end) as 'languges_null_count',
			sum(case when production_company is null then 1 else 0 end) as 'production_company_null_count'
 from movie;
 
 -- 'worlwide_gross_income' has 3724 null values
 -- 'languages' has 194 null values
 -- 'production_company' has 528 null values
 
		-- Now as you can see four columns of the movie table has null values.
        -- Let's look at the at the movies released each year. 
        
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
-- Solution:

select year, count(id) as 'number_of_movies'
from movie
group by year;

select month(date_published) as month_num, count(id) as 'number_of_movies'
from movie 
group by month_num
order by month_num;

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Solution:
select  count(id) as 'Number of movies produced in the USA or India' , year 
from movie
where country in ( 'USA'  or 'India')  and year ='2019';

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Solution:

select distinct  genre
from genre;
-- Movies belong to 13 genres in the dataset.

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Solution:
select count(movie_id) as 'Number of movies', genre
from genre
group by genre
order by 'Number of movies' ;

--  Drama genre has produced highest number of movies ie. 4285

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Solution:
with OneGenreMovie as
(
select movie_id
from genre
group by movie_id
having count(genre) = 1
)
select count(*) as 'Only one genre movie'
from OneGenreMovie;

-- 3289 movies belong only 1 genre. 

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

select genre, round(avg(duration),2)  as 'avg_duration'
from movie as movies
inner join genre as genres on movies.id=genres.movie_id
group by genre
order by avg_duration desc;
 
--  'Action' genre has the highest duration of 112.88 seconds followed by romance and crime genres.

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)
-- Solution:
with genre_summary as
(
select count(movie_id) as 'movie_count', genre,
         rank() over (order by count(movie_id) desc) as 'Genre Rank' 
from genre
group by genre
)
select *
from genre_summary
where genre = 'Thriller' ;

-- Thriller genre ranks 3rd  and movie count of thriller genre is 1484.

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
-- Solution:
select min(avg_rating) as 'min_avg_rating',
	        max(avg_rating) as 'max_avg_rating',
            min(total_votes) as 'min_total_votes',
            max(total_votes) as 'max_total_votes',
            min(median_rating) as 'min_median_rating',
            max(median_rating) as 'min_median_rating'
from ratings;            
            
/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
-- Solution:
-- It's ok if RANK() or DENSE_RANK() is used too
select  title, avg_rating,
            dense_rank() over (order by avg_rating desc) as 'movie_rank'
from movie as m
inner join ratings r on m.id=r.movie_id
limit 10;

-- -Top 3 movies have average rating >= 9.8
		

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
-- Slution:
SELECT median_rating,
       Count(movie_id) AS movie_count
FROM   ratings
GROUP  BY median_rating
ORDER  BY movie_count DESC; 

-- Movies with a median rating of 7 is highest in number.

-- Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
-- Solution:
-- CTE
WITH production_company_hit_movie_summary
     AS (SELECT production_company,
                Count(id)                           AS 'movie_count',
                Rank()
                  OVER (
                    ORDER BY Count(movie_id) DESC ) AS 'prod_company_rank'
         FROM   movie AS m
                INNER JOIN ratings AS r
                        ON m.id = r.movie_id
         WHERE  avg_rating > 8
                AND production_company IS NOT NULL
         GROUP  BY production_company)
SELECT *
FROM   production_company_hit_movie_summary
WHERE  prod_company_rank = 1; 
-- 'Dream Warrior Pictures' and 'National Theatre Live' Production company has the most number of hit movies
-- They have rank=1 and movie count =3 

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
-- Solution:

SELECT g.genre,
       Count(id) AS 'movie_count'
FROM   genre AS g
       INNER JOIN movie AS m
               ON g.movie_id = m.id
       INNER JOIN ratings AS r
               ON r.movie_id = m.id
WHERE  m.year = 2017
       AND Month(m.date_published) = 3
       AND m.country LIKE '%USA%'
       AND total_votes > 1000
GROUP  BY g.genre
ORDER  BY movie_count DESC; 

-- 24 movies from 'drama' genre released  during March 2017 in the USA and  had more than 1,000 votes.



-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
-- Solution:

SELECT m.title,
       avg_rating,
       genre
FROM   movie AS m
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
       INNER JOIN genre AS g
               ON r.movie_id = g.movie_id
WHERE  title LIKE 'The%'
       AND avg_rating > 8
GROUP  BY title
ORDER  BY avg_rating DESC; 

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Solution:

select count(*) as' movies released' , median_rating
from movie as m 
inner join ratings as r on  m.id=r.movie_id
where median_rating = 8 and  date_published between '2018-04-01' AND '2019-04-01'
group by median_rating;            

-- 361 movies were released between 1 April 2018 and 1 April 2019 with a median rating of 8.

-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Solution :

-- Approach 1:
select languages , sum(total_votes) as 'votes'
from movie  as m inner join ratings as r on m.id=r.movie_id
where languages like '%German%' 
union
select languages , sum(total_votes) as 'votes'
from movie  as m inner join ratings as r on m.id=r.movie_id
where languages like '%Italian%'
order  by votes desc;

-- Approach 2: By country column
SELECT country, sum(total_votes) as total_votes
FROM movie AS m
	INNER JOIN ratings as r ON m.id=r.movie_id
WHERE country = 'Germany' or country = 'Italy'
GROUP BY country;
-- 
WITH VOTES_SUMMARY AS 
(
SELECT languages, SUM(total_votes) AS VOTES 
FROM MOVIE AS M
INNER JOIN RATINGS AS R 
ON R.MOVIE_ID = M.ID
WHERE languages like '%Italian%'
UNION
SELECT languages, SUM(total_votes) AS VOTES 
FROM MOVIE AS M
INNER JOIN RATINGS AS R 
ON R.MOVIE_ID = M.ID
WHERE languages like '%GERMAN%'
),
LANGUAGE_VOTE AS
(
SELECT languages FROM VOTES_SUMMARY
ORDER BY VOTES DESC
LIMIT 1)

SELECT IF (languages LIKE 'GERMAN' , 'YES', 'NO') AS ANSWER
FROM LANGUAGE_VOTE ;

-- By observation, German movies received the highest number of votes when queried against language and country columns.
-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/

-- Segment 3:


-- Q18. Which columns in the names table have null values??
-- Solution:

select count(name) as 'name_nulls'
from names
where name is null;

select count(height) as 'height_nulls'
from names
where height is null;
            
select count(date_of_birth) as 'date_of_birth_nulls'
from names
where date_of_birth is null;
            
select count(known_for_movies) as 'known_for_movies_nulls'
from names
where known_for_movies is NULL;

-- Approach 2:
SELECT 
		SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls, 
		SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
		SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
		SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM names;

-- Height, date_of_birth, known_for_movies columns contain NULLS


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
-- Solution:

-- Using CTE -
WITH top_3_genres AS
(
           SELECT     genre,
                      Count(m.id)                            AS movie_count ,
                      Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
           FROM       movie                                  AS m
           INNER JOIN genre                                  AS g
           ON         g.movie_id = m.id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id
           WHERE      avg_rating > 8
           GROUP BY   genre limit 3 )
SELECT     n.NAME            AS director_name ,
           Count(d.movie_id) AS movie_count
FROM       director_mapping  AS d
INNER JOIN genre G
using     (movie_id)
INNER JOIN names AS n
ON         n.id = d.name_id
INNER JOIN top_3_genres
using     (genre)
INNER JOIN ratings
using      (movie_id)
WHERE      avg_rating > 8
GROUP BY   NAME
ORDER BY   movie_count DESC limit 3 ;

-- James Mangold , Joe Russo and Anthony Russo are top three directors in the top three genres whose movies have an average rating > 8


/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
-- Solution: 

SELECT N.name          AS actor_name,
       Count(movie_id) AS movie_count
FROM   role_mapping AS RM
       INNER JOIN movie AS M
               ON M.id = RM.movie_id
       INNER JOIN ratings AS R USING(movie_id)
       INNER JOIN names AS N
               ON N.id = RM.name_id
WHERE  R.median_rating >= 8
AND category = 'ACTOR'
GROUP  BY actor_name
ORDER  BY movie_count DESC
LIMIT  2; 


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
-- Solution:
SELECT     production_company,
           Sum(total_votes)                            AS vote_count,
           Rank() OVER(ORDER BY Sum(total_votes) DESC) AS prod_comp_rank
FROM       movie                                       AS m
INNER JOIN ratings                                     AS r
ON         r.movie_id = m.id
GROUP BY   production_company limit 3;

-- 'Marvel Studios', 'Twentieth Century Fox' and 'Warner Bros.'  are the top three production houses based on the number of votes received by their movies


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

with actor_summary as
(
select n.name as 'actor_name', r.total_votes, count(r.movie_id) as 'movie_count',
            (round(sum(r.avg_rating*r.total_votes)/sum(r.total_votes),2)) as 'avg _actor_rating'
            from movie as m
            inner join  ratings as r on m.id=r.movie_id
            inner join role_mapping as rm on rm.movie_id=m.id
            inner join names as n on n.id=rm.movie_id
            where rm.category = 'ACTOR' and m.country = 'india'
            group by n.name
            having movie_count >=5
            )
select *, rank() over (order by 'avg_actor_rating' desc) as actor_rank
 from actor_summary;            
            

-- Top actor is Vijay Sethupathi followed by Fahadh Faasil and Yogi Babu.


-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
WITH actress_summary AS
(
           SELECT     n.NAME AS actress_name,
                      total_votes,
                      Count(r.movie_id)                                     AS movie_count,
                      Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
           FROM       movie                                                 AS m
           INNER JOIN ratings                                               AS r
           ON         m.id=r.movie_id
           INNER JOIN role_mapping AS rm
           ON         m.id = rm.movie_id
           INNER JOIN names AS n
           ON         rm.name_id = n.id
           WHERE      category = 'ACTRESS'
           AND        country = "INDIA"
           AND        languages LIKE '%HINDI%'
           GROUP BY   NAME
           HAVING     movie_count>=3 )
SELECT   *,
         Rank() OVER(ORDER BY actress_avg_rating DESC) AS actress_rank
FROM     actress_summary LIMIT 5;

-- Top five actresses in Hindi movies released in India based on their average ratings are Taapsee Pannu, Kriti Sanon, Divya Dutta, Shraddha Kapoor, Kriti Kharbanda


-- Now let us divide all the thriller movies in the following categories and find out their numbers.*/


-- Q24. Select thriller movies as per avg rating and classify them in the following category: 
-- Solution:
with thriller_movies as
(
select distinct title, avg_rating
from movie as m 
inner join ratings as r on m.id=r.movie_id
inner join genre as g on g.movie_id=m.id
where genre = 'Thriller' 
)
select *, 
case when	avg_rating > 8 then 'Superhit movies'
		  when  avg_rating between 7 and 8 then  'Hit movies'
		  when avg_rating between 5 and 7 then 'One-time-watch movies'
		  else 'Flop movies'
          end as avg_rating_category
          from thriller_movies;


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
-- Solution: 
SELECT genre,
		ROUND(AVG(duration),2) AS avg_duration,
        SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
        AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)
WITH top_genres AS
(
           SELECT     genre,
                      Count(g.movie_id)                            AS movie_count,
                      Rank() OVER(ORDER BY Count(g.movie_id) DESC) AS genre_rank
           FROM       genre                                        AS g
           INNER JOIN movie                                        AS m
           ON         g.movie_id=m.id
           INNER JOIN ratings AS r
           ON         r.movie_id=m.id
           WHERE      avg_rating>8
           GROUP BY   g.genre limit 3 ), movie_summary AS
(
           SELECT     genre,
                      year,
                      title                                                                                                                                      AS movie_name,
                      Cast(Replace(Replace(Ifnull(worlwide_gross_income,0),'INR',''), '$', '') AS DECIMAL(10))                                                   AS worldwide_gross,
                      Dense_rank() OVER(partition BY year ORDER BY Cast(Replace(Replace(Ifnull(worlwide_gross_income,0),'INR',''),'$','') AS DECIMAL(10)) DESC ) AS movie_rank
           FROM       movie                                                                                                                                      AS m
           INNER JOIN genre                                                                                                                                      AS g
           ON         m.id=g.movie_id
           WHERE      genre IN
                      (
                             SELECT genre
                             FROM   top_genres)
           GROUP BY   movie_name )
SELECT   *
FROM     movie_summary
WHERE    movie_rank>=5
ORDER BY year;



-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
-- Solution:

select production_company, count(movie_id) as movie_count, rank() over (order by count(movie_id) desc) as prod_comp_rank
from movie as m
inner join ratings as r on m.id=r.movie_id
where median_rating>=8 and production_company is not null
           and position(',' in languages)>0
group by production_company
order by movie_count desc
limit 2;           

--  'Star Cinema' and 'Twentieth Century Fox'  are the top two production houses that have produced the highest number of hits among multilingual movies.


-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
-- Solution:
WITH actress_summary AS
(
           SELECT     n.NAME AS actress_name,
                      SUM(total_votes) AS total_votes,
                      Count(r.movie_id)                                     AS movie_count,
                      Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
           FROM       movie                                                 AS m
           INNER JOIN ratings                                               AS r
           ON         m.id=r.movie_id
           INNER JOIN role_mapping AS rm
           ON         m.id = rm.movie_id
           INNER JOIN names AS n
           ON         rm.name_id = n.id
           INNER JOIN GENRE AS g
           ON g.movie_id = m.id
           WHERE      category = 'ACTRESS'
           AND        avg_rating>8
           AND genre = "Drama"
           GROUP BY   NAME )
SELECT   *,
         Rank() OVER(ORDER BY movie_count DESC) AS actress_rank
FROM     actress_summary LIMIT 3;

-- Top 3 actresses based on number of Super Hit movies are Parvathy Thiruvothu, Susan Brown and Amanda Lawrence

	

--  Q29. Get the following details for top 9 directors (based on number of movies)
-- Solution:
WITH next_date_published_summary AS
(
            SELECT     d.name_id,
                      NAME,
                      d.movie_id,
                      duration,
                      r.avg_rating,
                      total_votes,
                      m.date_published,
                      Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
           FROM       director_mapping                                                                      AS d
           INNER JOIN names                                                                                 AS n
           ON         n.id = d.name_id
           INNER JOIN movie AS m
           ON         m.id = d.movie_id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id ), top_director_summary AS
(
       SELECT *,
              Datediff(next_date_published, date_published) AS date_difference
       FROM   next_date_published_summary )
SELECT   name_id                       AS director_id,
         NAME                          AS director_name,
         Count(movie_id)               AS number_of_movies,
         Round(Avg(date_difference),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2)               AS avg_rating,
         Sum(total_votes)              AS total_votes,
         Min(avg_rating)               AS min_rating,
         Max(avg_rating)               AS max_rating,
         Sum(duration)                 AS total_duration
FROM     top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;