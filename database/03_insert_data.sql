USE music_streaming_db;

-- =========================================
-- 1. USERS
-- =========================================
INSERT INTO users (Name, Email, Date_Joined) VALUES
('Alice Smith', 'alice@example.com', '2023-01-15'),
('Bob Jones', 'bob@example.com', '2023-02-20'),
('Charlie Brown', 'charlie@example.com', '2023-03-10'),
('Diana Prince', 'diana@example.com', '2023-04-05'),
('Evan Wright', 'evan@example.com', '2023-05-12');

-- =========================================
-- 2. SUBSCRIPTION
-- =========================================
INSERT INTO subscription (Plan_Type, Start_Date, End_Date, User_ID) VALUES
('Premium Individual', '2023-01-15', '2024-01-15', 1),
('Free', '2023-02-20', NULL, 2),
('Premium Student', '2023-03-10', '2024-03-10', 3),
('Family Plan', '2023-04-05', '2024-04-05', 4),
('Free', '2023-05-12', NULL, 5);

-- =========================================
-- 3. ARTIST
-- =========================================
INSERT INTO artist (Artist_Name, Country) VALUES
('The Midnight', 'United States'),
('Dua Lipa', 'United Kingdom'),
('Miles Davis', 'United States'),
('Daft Punk', 'France'),
('Taylor Swift', 'United States');

-- =========================================
-- 4. GENRE
-- =========================================
INSERT INTO genre (Genre_Name) VALUES
('Synthwave'),
('Pop'),
('Jazz'),
('Electronic'),
('Rock');

-- =========================================
-- 5. ALBUM
-- =========================================
INSERT INTO album (Album_Name, Release_Date, Artist_ID) VALUES
('Endless Summer', '2016-08-05', 1),
('Future Nostalgia', '2020-03-27', 2),
('Kind of Blue', '1959-08-17', 3),
('Random Access Memories', '2013-05-17', 4),
('1989', '2014-10-27', 5);

-- =========================================
-- 6. SONG
-- =========================================
-- Duration is stored in seconds
INSERT INTO song (Title, Duration, Album_ID, Genre_ID) VALUES
('Sunset', 326, 1, 1),
('Vampires', 317, 1, 1),
('Don\'t Start Now', 183, 2, 2),
('Levitating', 203, 2, 2),
('So What', 562, 3, 3),
('Get Lucky', 248, 4, 4),
('Blank Space', 231, 5, 2),
('Shake It Off', 219, 5, 2);

-- =========================================
-- 7. PLAYLIST
-- =========================================
INSERT INTO playlist (Playlist_Name, Created_Date, User_ID) VALUES
('Night Drives', '2023-01-20', 1),
('Workout Energy', '2023-02-25', 2),
('Focus & Study', '2023-03-15', 3),
('Party Mix', '2023-04-10', 4);

-- =========================================
-- 8. PLAYLIST_SONG
-- =========================================
INSERT INTO playlist_song (Playlist_ID, Song_ID) VALUES
(1, 1), -- Night Drives: Sunset
(1, 2), -- Night Drives: Vampires
(1, 6), -- Night Drives: Get Lucky
(2, 3), -- Workout Energy: Don't Start Now
(2, 4), -- Workout Energy: Levitating
(2, 8), -- Workout Energy: Shake It Off
(3, 5), -- Focus & Study: So What
(4, 3), -- Party Mix: Don't Start Now
(4, 4), -- Party Mix: Levitating
(4, 6); -- Party Mix: Get Lucky

-- =========================================
-- 9. ARTIST_SONG
-- =========================================
INSERT INTO artist_song (Artist_ID, Song_ID) VALUES
(1, 1), -- The Midnight -> Sunset
(1, 2), -- The Midnight -> Vampires
(2, 3), -- Dua Lipa -> Don't Start Now
(2, 4), -- Dua Lipa -> Levitating
(3, 5), -- Miles Davis -> So What
(4, 6), -- Daft Punk -> Get Lucky
(5, 7), -- Taylor Swift -> Blank Space
(5, 8); -- Taylor Swift -> Shake It Off

-- =========================================
-- 10. USER_ARTIST (Followed Artists)
-- =========================================
INSERT INTO user_artist (User_ID, Artist_ID) VALUES
(1, 1), (1, 4),
(2, 2), (2, 5),
(3, 3),
(4, 2), (4, 4), (4, 5);

-- =========================================
-- 11. LISTENING_HISTORY
-- =========================================
INSERT INTO listening_history (User_ID, Song_ID, Played_At) VALUES
(1, 1, '2023-06-01 08:30:00'),
(1, 2, '2023-06-01 08:35:30'),
(2, 3, '2023-06-01 12:15:00'),
(2, 4, '2023-06-01 12:18:10'),
(3, 5, '2023-06-02 14:00:00'),
(4, 6, '2023-06-02 18:45:00'),
(1, 6, '2023-06-03 21:10:00');

-- =========================================
-- 12. PODCAST
-- =========================================
INSERT INTO podcast (Podcast_Name, Description) VALUES
('Tech Daily', 'Daily insights into technology and software development.'),
('The Joe Rogan Experience', 'Long-form conversations with various guests.'),
('Crime Junkie', 'A weekly true crime podcast.');

-- =========================================
-- 13. EPISODE
-- =========================================
-- Duration in seconds
INSERT INTO episode (Title, Duration, Release_Date, Podcast_ID) VALUES
('The Future of AI', 1800, '2023-05-01', 1),
('Building Scalable Web Apps', 2400, '2023-05-08', 1),
('Episode #1900 - Tech Special', 7200, '2023-04-12', 2),
('Infamous Cold Case Solved', 2700, '2023-05-15', 3);

-- =========================================
-- 14. USER_EPISODE
-- =========================================
INSERT INTO user_episode (User_ID, Episode_ID, Played_At) VALUES
(1, 1, '2023-05-02 09:00:00'),
(1, 2, '2023-05-09 10:30:00'),
(3, 3, '2023-04-13 15:00:00'),
(5, 4, '2023-05-16 20:15:00');