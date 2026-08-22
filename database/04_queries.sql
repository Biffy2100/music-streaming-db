USE music_streaming_db;

SELECT * FROM ARTIST;

SELECT * FROM GENRE;

SELECT * FROM ALBUM;

SELECT * FROM SONG;

SELECT Song_ID, Title, Album_ID FROM SONG ORDER BY Song_ID;

SELECT COUNT(*) AS total_songs FROM song;

SELECT a.Artist_Name, COUNT(*) AS song_count
FROM
    artist a
    JOIN artist_song artist_map ON a.Artist_ID = artist_map.Artist_ID
GROUP BY
    a.Artist_ID,
    a.Artist_Name
ORDER BY a.Artist_ID;

-- =========================================
-- DATABASE VERIFICATION
-- =========================================

-- Expected catalog and relationship counts
SELECT 'users' AS table_name, COUNT(*) AS row_count
FROM users
UNION ALL
SELECT 'subscription', COUNT(*)
FROM subscription
UNION ALL
SELECT 'artist', COUNT(*)
FROM artist
UNION ALL
SELECT 'genre', COUNT(*)
FROM genre
UNION ALL
SELECT 'album', COUNT(*)
FROM album
UNION ALL
SELECT 'song', COUNT(*)
FROM song
UNION ALL
SELECT 'playlist', COUNT(*)
FROM playlist
UNION ALL
SELECT 'playlist_song', COUNT(*)
FROM playlist_song
UNION ALL
SELECT 'artist_song', COUNT(*)
FROM artist_song
UNION ALL
SELECT 'user_artist', COUNT(*)
FROM user_artist
UNION ALL
SELECT 'listening_history', COUNT(*)
FROM listening_history
UNION ALL
SELECT 'podcast', COUNT(*)
FROM podcast
UNION ALL
SELECT 'episode', COUNT(*)
FROM episode
UNION ALL
SELECT 'user_episode', COUNT(*)
FROM user_episode;

-- Every song must have an artist, album, and genre
SELECT s.Song_ID, s.Title
FROM
    song s
    LEFT JOIN album alb ON s.Album_ID = alb.Album_ID
    LEFT JOIN genre g ON s.Genre_ID = g.Genre_ID
    LEFT JOIN artist_song artist_map ON s.Song_ID = artist_map.Song_ID
WHERE
    alb.Album_ID IS NULL
    OR g.Genre_ID IS NULL
    OR artist_map.Song_ID IS NULL;

-- Album artists and song artists must agree
SELECT
    s.Song_ID,
    s.Title,
    alb.Album_Name,
    alb.Artist_ID AS album_artist_id,
    artist_map.Artist_ID AS song_artist_id
FROM
    song s
    JOIN album alb ON s.Album_ID = alb.Album_ID
    JOIN artist_song artist_map ON s.Song_ID = artist_map.Song_ID
WHERE
    alb.Artist_ID <> artist_map.Artist_ID;

-- Confirm the two requested catalog sections
SELECT a.Artist_Name, alb.Album_Name, COUNT(*) AS song_count
FROM artist a
    JOIN album alb ON a.Artist_ID = alb.Artist_ID
    JOIN song s ON alb.Album_ID = s.Album_ID
WHERE
    a.Artist_Name IN ('jschlatt', 'Radiohead')
GROUP BY
    a.Artist_Name,
    alb.Album_Name;

-- Confirm Chuckle Sandwich is populated
SELECT p.Podcast_Name, COUNT(e.Episode_ID) AS episode_count
FROM podcast p
    LEFT JOIN episode e ON p.Podcast_ID = e.Podcast_ID
WHERE
    p.Podcast_Name = 'Chuckle Sandwich'
GROUP BY
    p.Podcast_ID,
    p.Podcast_Name;