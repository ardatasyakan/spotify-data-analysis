SELECT *
FROM spotify_data.spotify_history;

ALTER TABLE spotify_history
RENAME COLUMN ï»¿spotify_track_uri to spotify_track_uri;

-- Data Cleaning Project

-- Create a staging table so that we will not alter the original data
CREATE TABLE spotify_data.spotify_staging 
LIKE spotify_history;

INSERT spotify_staging
SELECT * FROM spotify_history;

SELECT *
FROM spotify_staging;

-- 1. Remove Duplicates
SELECT rownum
FROM 
	(SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY spotify_track_uri, ts, platform, ms_played, reason_start, reason_end, shuffle, skipped) AS rownum
	FROM spotify_staging
	) AS removeduplicate
GROUP BY rownum;
-- Since there is only one row number, it means that every row is a unique one. Thus, no duplicates.

-- 2. Standardization

-- timestamp, seperate time and date
SELECT ts, LEFT(ts, 10) AS dates, RIGHT(ts, 8) AS times
FROM spotify_history;

ALTER TABLE spotify_staging
ADD dates date;

ALTER TABLE spotify_staging
ADD times time;

UPDATE spotify_staging ss
JOIN spotify_history sh ON ss.spotify_track_uri = sh.spotify_track_uri
SET ss.times = RIGHT(sh.ts, 8)
;

UPDATE spotify_staging
SET dates = LEFT(ts, 10);

UPDATE spotify_staging
SET times = RIGHT(ts, 8);

ALTER TABLE spotify_staging
DROP ts;

--

SELECT DISTINCT track_name
FROM spotify_staging;
-- Some tracks are just different variants of the others (e.g., a song and its live performance, or remastered) so let's put them under same name to avoid confusion.

UPDATE spotify_staging
SET track_name = TRIM(SUBSTRING_INDEX(track_name, ' - ', 1));

SELECT track_name, SUM(ms_played) AS total_ms_played
FROM spotify_staging
GROUP BY track_name;

--

SELECT *
FROM spotify_staging
;

SELECT DISTINCT album_name
FROM spotify_staging;

-- There are two albums that correspond to As/Is Live. 
UPDATE spotify_staging
SET album_name = 'As/Is - Live'
WHERE album_name = 'As/Is: Live In Cleveland/Cincinnati, OH - 8/03-8/04/04'
;

-- Exile On Main St and Exile On Main Street exist seperately
UPDATE spotify_staging
SET album_name = 'Exile On Main Street'
WHERE album_name = 'Exile On Main St'
;

--

