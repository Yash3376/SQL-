----- Calling the tables in the PgAdmin -------
SELECT
	*
FROM
	NETFLIX
WHERE
	COUNTRY = 'India';

------ Answering the question --------
-- 15 Business Problems & Solutions
--1. Count the number of Movies vs TV Shows
SELECT
	TYPE,
	COUNT(TYPE)
FROM
	NETFLIX
GROUP BY
	1
ORDER BY
	1;

--2. Find the most common rating for movies and TV shows?
WITH
	RANK_1 AS (
		SELECT
			TYPE,
			RATING,
			CNT_TYPE,
			CNT_RATING,
			RANK() OVER (
				PARTITION BY
					TYPE
				ORDER BY
					CNT_RATING DESC
			) AS RANKING
		FROM
			(
				SELECT
					TYPE,
					RATING,
					COUNT(TYPE) AS CNT_TYPE,
					COUNT(RATING) AS CNT_RATING
				FROM
					NETFLIX
				GROUP BY
					1,
					2
			) AS SUB
	)
SELECT
	*
FROM
	RANK_1
WHERE
	RANKING = 1;

--3. List all movies released in a specific year (e.g., 2020)?
SELECT
	*
FROM
	NETFLIX
WHERE
	RELEASE_YEAR = '2020';

--4. Find the top 5 countries with the most content on Netflix?
UPDATE NETFLIX
SET
	COUNTRY = 'Not Disclosed'
WHERE
	COUNTRY IS NULL;

SELECT
	COUNTRY,
	COUNT(TYPE) AS CONTENT
FROM
	NETFLIX
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT
	5;

--5. Identify the longest movie
SELECT
	*
FROM
	NETFLIX
WHERE
	RELEASE_YEAR = '2020';

--6. Find content added in the last 5 years
SELECT
	COUNTRY,
	COUNT(TYPE) AS CONTENT
FROM
	NETFLIX
GROUP BY
	1
ORDER BY
	2 DESC;

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'?
SELECT
	TYPE,
	TITLE,
	DIRECTOR
FROM
	(
		SELECT
			*,
			UNNEST(STRING_TO_ARRAY(DIRECTOR, ',')) AS DIRECTOR_NAME
		FROM
			NETFLIX
	)
WHERE
	DIRECTOR = 'Rajiv Chilaka';

--8. List all TV shows with more than 5 seasons?
WITH
	SERIES AS (
		SELECT
			TYPE,
			TITLE,
			CAST(SPLIT_PART(DURATION, ' ', 1) AS INTEGER) AS DURATION
		FROM
			NETFLIX
		WHERE
			DURATION LIKE '%Seasons'
	)
SELECT
	TYPE,
	DURATION
FROM
	SERIES
WHERE
	TYPE = 'TV Show'
	AND DURATION > 5;

--9. Count the number of content items in each genre?
SELECT
	*,
	COUNT(GENRE) AS NUMBER_OF_CONTENT
FROM
	(
		SELECT
			UNNEST(STRING_TO_ARRAY(LISTED_IN, ',')) AS GENRE
		FROM
			NETFLIX
	) AS SUB
GROUP BY
	GENRE
ORDER BY
	2 DESC;

--10.Find each year and the average numbers of content release in India on netflix and
--return top 5 year with highest avg content release?
SELECT
	RELEASE_YEAR,
	COUNT(SHOW_ID)
FROM
	NETFLIX
GROUP BY
	1;

--11. List all movies that are documentaries
SELECT
	TYPE,
	TITLE,
	CONTENT
FROM
	(
		SELECT
			TYPE,
			TITLE,
			UNNEST(STRING_TO_ARRAY(LISTED_IN, ',')) AS CONTENT
		FROM
			NETFLIX
	) AS
ADD
WHERE
	TYPE = 'Movie'
	AND CONTENT = 'Documentaries';

--12. Find all content without a director
SELECT
	*
FROM
	NETFLIX
WHERE
	DIRECTOR IS NULL;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT
	*
FROM
	(
		SELECT
			TYPE,
			TITLE,
			DIRECTOR,
			TRIM(UNNEST(STRING_TO_ARRAY(CASTS, ','))) AS CASTS,
			RELEASE_YEAR
		FROM
			NETFLIX
		WHERE
			DIRECTOR IS NOT NULL
	) AS AF
WHERE
	RELEASE_YEAR BETWEEN 
	CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT) - 11 
	AND 
	CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT)
	AND 
	CASTS = 'Salman Khan';

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	*,
	COUNT(CASTS) AS NUMBER_OF_TIME
FROM
(
SELECT
	COUNTRY,
	TRIM(UNNEST(STRING_TO_ARRAY(CASTS, ','))) AS CASTS
FROM
	NETFLIX) AS SUB
WHERE
	COUNTRY = 'India'
GROUP BY 
	COUNTRY,
    CASTS
ORDER BY 
	NUMBER_OF_TIME DESC
LIMIT 10;

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
SELECT category,
	COUNT(*)
FROM 
(SELECT 
      CASE 
          WHEN DESCRIPTION ILIKE '%kill%' AND DESCRIPTION ILIKE 'violence' THEN 'bad'
          ELSE 'Good'
      END AS category
FROM NETFLIX) AS sub
GROUP BY 1;