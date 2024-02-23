-- 1) (5 pts) What are the last names and emails of all customer who made purchased in the store?
SELECT LastName, Email FROM customers;

-- 2) (5 pts) What are the names of each album and the artist who created it?
SELECT albums.Title AS "Album Title", artists.Name AS "Artist Name"
FROM albums
INNER JOIN artists ON albums.ArtistId = artists.ArtistId;

-- 3) (10 pts) What are the total number of unique customers for each state, ordered alphabetically by state?
SELECT count(CustomerId) AS "Unique Customers", State 
FROM customers
GROUP BY State
ORDER BY State;

-- 4) (10 pts) Which states have more than 10 unique customers?
SELECT count(CustomerId) AS "Unique Customers", State 
FROM customers
GROUP BY State
HAVING ("Unique Customers" > 10);

-- 5) (10 pts) What are the names of the artists who made an album containing the substring "symphony" in the album title?
SELECT artists.Name
FROM albums
INNER JOIN artists ON albums.ArtistId = artists.ArtistId
WHERE Title LIKE '%symphony%';

-- 6) (15 pts) What are the names of all artists who performed MPEG (video or audio) tracks 
-- in either the "Brazilian Music" or the "Grunge" playlists?
SELECT DISTINCT artists.Name
FROM albums
INNER JOIN artists ON albums.ArtistId = artists.ArtistId
INNER JOIN tracks ON albums.AlbumId = tracks.AlbumId
INNER JOIN media_types ON tracks.MediaTypeId = media_types.MediaTypeId
INNER JOIN playlist_track ON playlist_track.TrackId = tracks.TrackId
INNER JOIN playlists ON playlist_track.PlaylistId = playlists.PlaylistId
WHERE media_types.Name LIKE '%MPEG%'
AND(playlists.Name = "Brazilian Music" OR playlists.Name = "Grunge");

-- 7) (20 pts) How many artists published at least 10 MPEG tracks?
SELECT count(artistName) 
FROM(
SELECT DISTINCT artists.Name AS artistName 
FROM artists
WHERE
(SELECT count(media_types.name)
FROM albums
INNER JOIN artists ON albums.ArtistId = artists.ArtistId
INNER JOIN tracks ON albums.AlbumId = tracks.AlbumId
INNER JOIN media_types ON tracks.MediaTypeId = media_types.MediaTypeId
WHERE media_types.Name LIKE '%MPEG%' AND artists.Name=artistName) >= 10);

-- 8) (25 pts) What is the total length of each playlist in hours? 
-- I used left join to get all playlists, even those with null values
-- Using inner join will only give me playlists with values
SELECT playlists.PlaylistId, playlists.Name, SUM(tracks.Milliseconds) / (1000*60*60) AS Hours
FROM  playlists
LEFT JOIN playlist_track ON playlists.PlaylistId = playlist_track.PlaylistId
LEFT JOIN tracks ON playlist_track.TrackId = tracks.TrackId
GROUP BY playlists.PlaylistId
--List the playlist id and name of only those playlists that are longer than 2 hours, along with the length in hours rounded to two decimals.
-- Here, I used an inner join to avoid the null values
SELECT playlists.PlaylistId, playlists.Name, ROUND(SUM(tracks.Milliseconds) / (1000.0 * 60 * 60), 2) AS Hours
FROM  playlists
INNER JOIN playlist_track ON playlists.PlaylistId = playlist_track.PlaylistId
INNER JOIN tracks ON playlist_track.TrackId = tracks.TrackId
GROUP BY playlists.PlaylistId
HAVING hours > 2

-- 9) (25 pts) Creative addition: Define a new meaningful query using at least three tables, 
--and some window function. Explain clearly what your query achieves, and what the results mean
-- My query: Get the names and track amounts of all playlists with an above average amount of tracks, 
-- excluding playlists with no tracks
SELECT playlists.Name, COUNT(tracks.TrackId) AS TrackCount
FROM playlists
LEFT JOIN playlist_track ON playlists.PlaylistId = playlist_track.PlaylistId
LEFT JOIN tracks ON playlist_track.TrackId = tracks.TrackId
GROUP BY playlists.Name
HAVING TrackCount > (
    SELECT AVG(TrackCount) 
    FROM (
        SELECT COUNT(TrackId) AS TrackCount
        FROM playlist_track
        GROUP BY PlaylistId
    )
);
-- The query returns only two playlists, as those made the average amount of tracks per playlist extremely high