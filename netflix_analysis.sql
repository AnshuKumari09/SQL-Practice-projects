SELECT * FROM netflix;

-- 15 Business Problems & Solutions


-- 1. Count the number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*) AS total_count
FROM netflix
GROUP BY type
ORDER BY total_count DESC;

-- 2. Find the most common rating for movies and TV shows
SELECT 
  type,
  rating,
  COUNT(*) AS totalCount
FROM netflix
GROUP BY type, rating
ORDER BY type, totalCount DESC;

-- -------------------------
WITH RatingCounts AS(SELECT type,rating,COUNT(*) AS rating_count
FROM netflix
GROUP BY type,rating),
RankedRatings AS (
SELECT type,rating,rating_count,RANK() OVER (PARTITION BY  type ORDER BY rating_count DESC) AS rank
FROM RatingCounts
)
SELECT type,rating AS most_frequent_rating
FROM RankedRatings
WHERE rank=1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT type,title
FROM netflix 
WHERE type='Movie' AND release_year=2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT country,COUNT(show_id) AS content
FROM netflix
GROUP BY country 
ORDER BY content DESC
LIMIT 5;

SELECT t1.country,t1.total_content FROM 
(SELECT 
UNNEST(STRING_TO_ARRAY(country,',')) AS country,COUNT(*) AS total_content
FROM netflix
GROUP BY country)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;


-- 6. Find content added in the last 5 years
SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
ORDER BY release_year DESC;



-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * 
FROM netflix 
WHERE director = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix 
WHERE type='TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5;

-- 9. Count the number of content items in each genre
SELECT listed_in,COUNT(*) AS countOfeach
FROM netflix
GROUP BY listed_in
ORDER BY countOfeach DESC;


SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,COUNT(*) AS countOfeach
FROM netflix
GROUP BY listed_in;

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT COUNT(type)AS avgContent,release_year,UNNEST(STRING_TO_ARRAY(country,',')) AS country
FROM netflix
WHERE country='India'
GROUP BY type,release_year,country
ORDER BY avgContent DESC
LIMIT 5;

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT title
FROM netflix 
WHERE type='Movie' AND listed_in='Documentaries';

SELECT title
FROM netflix 
WHERE listed_in LIKE '%Documentaries';

-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.



SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2




