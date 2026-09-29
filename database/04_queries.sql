USE music_streaming_db;

SELECT * FROM ARTIST;
select * from playlist;
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

    select * from song;
-- DML Query 1 — Display all songs
-- English: Display the title and duration of all songs.

SELECT Title, Duration FROM SONG;

-- DML Query 2 — Songs longer than 4 minutes
-- English: Display all songs having a duration greater than 4 minutes.

SELECT Title, Duration FROM SONG WHERE Duration > 240;

-- DML Query 3 — Songs sorted by duration
-- English: Display all songs in descending order of their duration.

SELECT Title, Duration FROM SONG ORDER BY Duration DESC;

-- DML Query 4 — Songs with album names
-- English: Display each song along with its album name.

SELECT S.Title, A.Album_Name
FROM SONG S
    JOIN ALBUM A ON S.Album_ID = A.Album_ID;

-- DML Query 5 — Songs with artist names
-- English: Display each song along with the name of its artist.

SELECT S.Title, AR.Artist_Name
FROM
    SONG S
    JOIN ARTIST_SONG ASG ON S.Song_ID = ASG.Song_ID
    JOIN ARTIST AR ON ASG.Artist_ID = AR.Artist_ID;

-- DML Query 6 — Number of songs per artist
-- English: Display each artist and the number of songs associated with them.

SELECT AR.Artist_Name, COUNT(ASG.Song_ID) AS Song_Count
FROM ARTIST AR
    JOIN ARTIST_SONG ASG ON AR.Artist_ID = ASG.Artist_ID
GROUP BY
    AR.Artist_ID,
    AR.Artist_Name;

-- DML Query 7 — Artists with more than 3 songs
-- English: Display artists who have more than three songs.

SELECT AR.Artist_Name, COUNT(ASG.Song_ID) AS Song_Count
FROM ARTIST AR
    JOIN ARTIST_SONG ASG ON AR.Artist_ID = ASG.Artist_ID
GROUP BY
    AR.Artist_ID,
    AR.Artist_Name
HAVING
    COUNT(ASG.Song_ID) > 3;

-- DML Query 8 — Songs in a particular playlist
-- English: Display all songs belonging to a selected playlist.

SELECT P.Playlist_Name, S.Title
FROM
    PLAYLIST P
    JOIN PLAYLIST_SONG PS ON P.Playlist_ID = PS.Playlist_ID
    JOIN SONG S ON PS.Song_ID = S.Song_ID
WHERE
    P.Playlist_ID = 1;

-- DML Query 9 — Listening history of a user
-- English: Display the songs listened to by a selected user along with the date and time they were played.

SELECT U.Name, S.Title, LH.Played_At
FROM
    LISTENING_HISTORY LH
    JOIN USERS U ON LH.User_ID = U.User_ID
    JOIN SONG S ON LH.Song_ID = S.Song_ID
WHERE
    U.User_ID = 1
ORDER BY LH.Played_At DESC;

-- DML Query 10 — Most listened-to songs
-- English: Display the songs that have been listened to the most.

SELECT S.Title, COUNT(LH.Song_ID) AS Times_Played
FROM SONG S
    JOIN LISTENING_HISTORY LH ON S.Song_ID = LH.Song_ID
GROUP BY
    S.Song_ID,
    S.Title
ORDER BY Times_Played DESC;