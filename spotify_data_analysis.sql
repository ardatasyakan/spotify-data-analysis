SELECT *
FROM spotify_staging;

-- Most Listened Tracks (With the artists)
CREATE TABLE top_tracks AS
	SELECT track_name, artist_name, SUM(ms_played) AS total_ms_played
	FROM spotify_staging
	GROUP BY track_name, artist_name
	ORDER BY total_ms_played DESC;

SELECT *
FROM top_tracks;

-- Most Listened Albums (With the artists)
CREATE TABLE top_albums AS
SELECT album_name, artist_name, SUM(ms_played) AS total_ms_played
FROM spotify_staging
GROUP BY album_name, artist_name
ORDER BY total_ms_played DESC;

SELECT *
FROM top_albums;

-- Most Listened Artists
CREATE TABLE top_artists AS
SELECT artist_name, SUM(ms_played) AS total_ms_played
FROM spotify_staging
GROUP BY artist_name
ORDER BY total_ms_played DESC;

SELECT *
FROM top_artists;

-- Most Listened Tracks At Night (9.00 P.M. - 4.00 A.M.)
CREATE TABLE night_tracks AS
SELECT track_name, artist_name, SUM(ms_played) AS total_ms_played
FROM spotify_staging
WHERE
	times < '04:00:00' OR times > '21:00:00'
GROUP BY track_name, artist_name
ORDER BY total_ms_played DESC
;

SELECT *
FROM night_tracks;

-- Favorite Tracks of Winter
CREATE TABLE winter_favorites AS
	SELECT track_name, artist_name, SUM(ms_played) AS total_ms_played
	FROM spotify_staging
	WHERE MONTH(dates) IN (12, 1, 2)
	GROUP BY track_name, artist_name
	ORDER BY total_ms_played DESC
;

SELECT *
FROM winter_favorites
;


-- Favorite Tracks of Winter
CREATE TABLE summer_favorites AS
SELECT track_name, artist_name, SUM(ms_played) total_ms_played
FROM spotify_staging
WHERE MONTH(dates) IN (6, 7, 8)
GROUP BY track_name, artist_name
ORDER BY total_ms_played DESC
;

SELECT *
FROM summer_favorites
;

-- Best Albums of 2015
CREATE TABLE 2015_albums AS
SELECT track_name, artist_name, SUM(ms_played) total_ms_played
FROM spotify_staging
WHERE YEAR(dates) IN (2015)
GROUP BY track_name, artist_name
ORDER BY total_ms_played DESC
;

SELECT *
FROM 2015_albums;

-- Yearly Performance
CREATE TABLE yearly_perf AS
SELECT YEAR(dates) AS years, SUM(ms_played) AS total_ms_played
FROM spotify_staging
GROUP BY years
ORDER BY years ASC
;

SELECT *
FROM yearly_perf;

SELECT *
FROM spotify_staging;

-- Best Artists of Each Year
CREATE TABLE yearly_best AS
WITH best_of_each AS (
	SELECT YEAR(dates) AS years, artist_name, SUM(ms_played) AS total_ms_played,
	ROW_NUMBER() OVER (PARTITION BY YEAR(dates) ORDER BY SUM(ms_played) DESC) AS rownum
	FROM spotify_staging
	GROUP BY YEAR(dates), artist_name )
SELECT *
FROM best_of_each
WHERE rownum = 1
;

SELECT *
FROM yearly_best;

-- Yearly Seconds
CREATE TABLE yearly_second AS
WITH second_of_each AS
	(
	SELECT YEAR(dates) years, artist_name, SUM(ms_played) total_ms_played,
	ROW_NUMBER() OVER(PARTITION BY YEAR(dates) ORDER BY SUM(ms_played) DESC) AS rownum
	FROM spotify_staging
	GROUP BY years, artist_name
    )
SELECT *
FROM second_of_each
WHERE rownum = 2
;

-- Yearly Thirds
SELECT *
FROM yearly_third;

CREATE TABLE yearly_third AS
WITH third_of_each AS
	(
	SELECT YEAR(dates) years, artist_name, SUM(ms_played) total_ms_played,
	ROW_NUMBER() OVER(PARTITION BY YEAR(dates) ORDER BY SUM(ms_played) DESC) AS rownum
	FROM spotify_staging
	GROUP BY years, artist_name
    )
SELECT *
FROM third_of_each
WHERE rownum = 3
;

SELECT *
FROM yearly_third;