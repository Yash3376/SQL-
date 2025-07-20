CREATE DATABASE spotify;
USE spotify;

########## Calling the table #######

SELECT * FROM spotify;

########## Question are as follow ####

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT *
FROM spotify
WHERE Stream > 1000000000;

-- 2. List all albums along with their respective artists.

SELECT album, artist
FROM spotify
GROUP BY 1,2;

-- 3. Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(Comments) AS total_number_of_comment
FROM spotify
WHERE licensed = 'True';

-- 4. Find all tracks that belong to the album type single.

SELECT track
FROM spotify
WHERE album_type = 'single';

-- 5. Count the total number of tracks by each artist.

SELECT artist, COUNT(track) AS total_number_of_track
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;

-- 6. Calculate the average danceability of tracks in each album.

SELECT album, ROUND(AVG(danceabIlity),2) AS average_dance 
 FROM spotify
 GROUP BY 1;

-- 7. Find the top 5 tracks with the highest energy values.

SELECT track, energy
FROM spotify
GROUP BY 1,2
ORDER BY 2 DESC
LIMIT 5;

-- 8. List all tracks along with their views and likes where official_video = TRUE.

SELECT DISTINCT track, SUM(views) AS total_number_of_views, SUM(likes) AS total_number_of_views
FROM spotify
WHERE official_video = 'True'
GROUP BY 1
ORDER BY 2 DESC;

-- 9. For each album, calculate the total views of all associated tracks.

SELECT track, album, SUM(views) AS total_number_of_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT *
FROM (SELECT track,
	  IFNULL(SUM(CASE 
			WHEN most_playedon = 'Youtube' THEN stream 
		END), 0) AS stream_on_youtube,
        IFNULL(SUM(CASE 
			WHEN most_playedon = 'Spotify' THEN stream
		END), 0) AS stream_on_spotify
FROM spotify
GROUP BY 1) AS sub
WHERE stream_on_youtube > stream_on_spotify;

-- 11. Find the top 3 most-viewed tracks for each artist using window functions?

SELECT artist, track, stream
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY artist ORDER BY stream DESC) AS rnk
    FROM spotify
) AS ranked
WHERE rnk <= 3;

-- 11. Write a query to find tracks where the liveness score is above the average.
SELECT 
    *
FROM
    spotify
WHERE
    liveness > (SELECT 
            AVG(liveness)
        FROM
            spotify);

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.


WITH cte AS (
SELECT  DISTINCT album,
	    MAX(energy) AS  highest_energy_value,
        MIN(energy) AS lowest_energy_value
FROM spotify
GROUP BY 1
ORDER BY 1)

SELECT *, 
	   highest_energy_value - lowest_energy_value
FROM cte;