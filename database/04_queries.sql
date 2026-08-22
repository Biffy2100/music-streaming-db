USE music_streaming_db;

-- =========================================
-- 1. USER & ACCOUNT QUERIES
-- =========================================

-- Get full profile and subscription details for a specific user (User_ID = 1)
SELECT 
    u.User_ID, 
    u.Name, 
    u.Email, 
    u.Date_Joined,
    s.Plan_Type, 
    s.Start_Date AS Subscription_Start, 
    s.End_Date AS Subscription_End
FROM users u
LEFT JOIN subscription s ON u.User_ID = s.User_ID
WHERE u.User_ID = 1;

-- Get all artists followed by a specific user (User_ID = 1)
SELECT 
    a.Artist_ID, 
    a.Artist_Name, 
    a.Country
FROM artist a
JOIN user_artist ua ON a.Artist_ID = ua.Artist_ID
WHERE ua.User_ID = 1;


-- =========================================
-- 2. PLAYLIST & MUSIC CONTENT QUERIES
-- =========================================

-- Fetch full playlist tracklist with artist, album, and genre details (Playlist_ID = 1)
SELECT 
    p.Playlist_Name,
    s.Title AS Song_Title,
    a.Artist_Name,
    alb.Album_Name,
    g.Genre_Name,
    CONCAT(FLOOR(s.Duration / 60), ':', LPAD(s.Duration % 60, 2, '0')) AS Duration_Formatted
FROM playlist p
JOIN playlist_song ps ON p.Playlist_ID = ps.Playlist_ID
JOIN song s ON ps.Song_ID = s.Song_ID
JOIN album alb ON s.Album_ID = alb.Album_ID
JOIN genre g ON s.Genre_ID = g.Genre_ID
JOIN artist_song `as` ON s.Song_ID = `as`.Song_ID
JOIN artist a ON `as`.Artist_ID = a.Artist_ID
WHERE p.Playlist_ID = 1;

-- Search for songs by title, artist, or genre (e.g., search term 'Sunset')
SELECT 
    s.Song_ID, 
    s.Title AS Song_Title, 
    alb.Album_Name, 
    a.Artist_Name, 
    g.Genre_Name
FROM song s
JOIN album alb ON s.Album_ID = alb.Album_ID
JOIN genre g ON s.Genre_ID = g.Genre_ID
JOIN artist_song `as` ON s.Song_ID = `as`.Song_ID
JOIN artist a ON `as`.Artist_ID = a.Artist_ID
WHERE s.Title LIKE '%Sunset%' 
   OR a.Artist_Name LIKE '%Sunset%' 
   OR g.Genre_Name LIKE '%Sunset%';


-- =========================================
-- 3. LISTENING HISTORY QUERIES
-- =========================================

-- Unified listening history (Songs + Podcasts) for a user (User_ID = 1)
SELECT 
    s.Title AS Item_Title, 
    a.Artist_Name AS Creator_Name,
    'Song' AS Content_Type, 
    lh.Played_At
FROM listening_history lh
JOIN song s ON lh.Song_ID = s.Song_ID
JOIN artist_song `as` ON s.Song_ID = `as`.Song_ID
JOIN artist a ON `as`.Artist_ID = a.Artist_ID
WHERE lh.User_ID = 1

UNION ALL

SELECT 
    e.Title AS Item_Title, 
    p.Podcast_Name AS Creator_Name,
    'Podcast Episode' AS Content_Type, 
    ue.Played_At
FROM user_episode ue
JOIN episode e ON ue.Episode_ID = e.Episode_ID
JOIN podcast p ON e.Podcast_ID = p.Podcast_ID
WHERE ue.User_ID = 1

ORDER BY Played_At DESC;


-- =========================================
-- 4. ANALYTICS & AGGREGATION QUERIES
-- =========================================

-- Top 5 most played songs across all users
SELECT 
    s.Song_ID, 
    s.Title AS Song_Title, 
    a.Artist_Name,
    COUNT(lh.History_ID) AS Total_Plays
FROM song s
JOIN listening_history lh ON s.Song_ID = lh.Song_ID
JOIN artist_song `as` ON s.Song_ID = `as`.Song_ID
JOIN artist a ON `as`.Artist_ID = a.Artist_ID
GROUP BY s.Song_ID, s.Title, a.Artist_Name
ORDER BY Total_Plays DESC
LIMIT 5;

-- Total listening time per user in minutes (Songs only)
SELECT 
    u.User_ID, 
    u.Name, 
    ROUND(SUM(s.Duration) / 60, 2) AS Total_Listening_Minutes
FROM users u
JOIN listening_history lh ON u.User_ID = lh.User_ID
JOIN song s ON lh.Song_ID = s.Song_ID
GROUP BY u.User_ID, u.Name
ORDER BY Total_Listening_Minutes DESC;