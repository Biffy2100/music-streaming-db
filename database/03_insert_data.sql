USE music_streaming_db;

-- Clear every table before loading the sample dataset.
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM user_episode;

DELETE FROM listening_history;

DELETE FROM user_artist;

DELETE FROM artist_song;

DELETE FROM playlist_song;

DELETE FROM episode;

DELETE FROM song;

DELETE FROM playlist;

DELETE FROM album;

DELETE FROM genre;

DELETE FROM artist;

DELETE FROM subscription;

DELETE FROM users;

ALTER TABLE user_episode AUTO_INCREMENT = 1;

ALTER TABLE listening_history AUTO_INCREMENT = 1;

ALTER TABLE episode AUTO_INCREMENT = 1;

ALTER TABLE podcast AUTO_INCREMENT = 1;

ALTER TABLE song AUTO_INCREMENT = 1;

ALTER TABLE playlist AUTO_INCREMENT = 1;

ALTER TABLE album AUTO_INCREMENT = 1;

ALTER TABLE genre AUTO_INCREMENT = 1;

ALTER TABLE artist AUTO_INCREMENT = 1;

ALTER TABLE subscription AUTO_INCREMENT = 1;

ALTER TABLE users AUTO_INCREMENT = 1;

SET FOREIGN_KEY_CHECKS = 1;

-- Base entities
INSERT INTO
    users (Name, Email, Date_Joined)
VALUES (
        'Aarav Mehta',
        'aarav@example.com',
        '2024-01-15'
    ),
    (
        'Maya Chen',
        'maya@example.com',
        '2024-03-02'
    ),
    (
        'Noah Williams',
        'noah@example.com',
        '2024-05-21'
    ),
    (
        'Sofia Garcia',
        'sofia@example.com',
        '2024-07-09'
    );

INSERT INTO
    subscription (
        Plan_Type,
        Start_Date,
        End_Date,
        User_ID
    )
VALUES (
        'Premium',
        '2024-01-15',
        NULL,
        1
    ),
    (
        'Family',
        '2024-03-02',
        NULL,
        2
    ),
    ('Free', '2024-05-21', NULL, 3),
    (
        'Premium',
        '2024-07-09',
        '2025-07-09',
        4
    );

INSERT INTO
    artist (Artist_Name, Country)
VALUES ('Arijit Singh', 'India'),
    ('The Weeknd', 'Canada'),
    ('Coldplay', 'United Kingdom'),
    (
        'Taylor Swift',
        'United States'
    ),
    ('Tame Impala', 'Australia');

INSERT INTO
    genre (Genre_Name)
VALUES ('Bollywood'),
    ('R&B'),
    ('Rock'),
    ('Pop'),
    ('Indie');

INSERT INTO
    album (
        Album_Name,
        Release_Date,
        Artist_ID
    )
VALUES ('Tum Hi Ho', '2013-04-26', 1),
    (
        'After Hours',
        '2020-03-20',
        2
    ),
    ('Parachutes', '2000-07-10', 3),
    ('1989', '2014-10-27', 4),
    ('Currents', '2015-07-17', 5);

INSERT INTO
    song (
        Title,
        Duration,
        Album_ID,
        Genre_ID
    )
VALUES ('Tum Hi Ho', 262, 1, 1),
    (
        'Chahun Main Ya Naa',
        277,
        1,
        1
    ),
    ('Blinding Lights', 200, 2, 2),
    ('Save Your Tears', 216, 2, 2),
    ('Yellow', 266, 3, 3),
    ('Shiver', 304, 3, 3),
    ('Blank Space', 231, 4, 4),
    ('Style', 231, 4, 4),
    (
        'The Less I Know the Better',
        216,
        5,
        5
    ),
    ('Eventually', 318, 5, 5);

-- User-created collections and podcasts
INSERT INTO
    playlist (
        Playlist_Name,
        Created_Date,
        User_ID
    )
VALUES (
        'Aarav Favorites',
        '2024-01-20',
        1
    ),
    (
        'Morning Commute',
        '2024-03-10',
        2
    ),
    (
        'Weekend Mix',
        '2024-06-01',
        3
    );

INSERT INTO
    podcast (Podcast_Name, Description)
VALUES (
        'The Daily Byte',
        'Short conversations about technology and culture.'
    ),
    (
        'History Unpacked',
        'Accessible stories from around the world.'
    );

INSERT INTO
    episode (
        Title,
        Duration,
        Release_Date,
        Podcast_ID
    )
VALUES (
        'How Streaming Changed Music',
        1840,
        '2024-08-01',
        1
    ),
    (
        'Designing Better Recommendations',
        2110,
        '2024-08-08',
        1
    ),
    (
        'The Silk Road in Three Objects',
        2360,
        '2024-08-05',
        2
    );

-- Many-to-many relationships
INSERT INTO
    playlist_song (Playlist_ID, Song_ID)
VALUES (1, 1),
    (1, 3),
    (1, 5),
    (1, 7),
    (2, 3),
    (2, 5),
    (2, 9),
    (3, 2),
    (3, 4),
    (3, 6),
    (3, 8),
    (3, 10);

INSERT INTO
    artist_song (Artist_ID, Song_ID)
VALUES (1, 1),
    (1, 2),
    (2, 3),
    (2, 4),
    (3, 5),
    (3, 6),
    (4, 7),
    (4, 8),
    (5, 9),
    (5, 10);

INSERT INTO
    user_artist (User_ID, Artist_ID)
VALUES (1, 1),
    (1, 2),
    (1, 3),
    (2, 3),
    (2, 4),
    (3, 2),
    (3, 5),
    (4, 1),
    (4, 4);

-- Playback history
INSERT INTO
    listening_history (User_ID, Song_ID, Played_At)
VALUES (1, 1, '2024-08-10 08:15:00'),
    (1, 3, '2024-08-10 08:20:00'),
    (1, 5, '2024-08-10 08:24:00'),
    (2, 3, '2024-08-11 09:00:00'),
    (2, 7, '2024-08-11 09:05:00'),
    (3, 9, '2024-08-12 18:30:00'),
    (4, 1, '2024-08-13 20:00:00'),
    (4, 3, '2024-08-13 20:05:00');

INSERT INTO
    user_episode (
        User_ID,
        Episode_ID,
        Played_At
    )
VALUES (1, 1, '2024-08-10 10:00:00'),
    (1, 2, '2024-08-11 10:00:00'),
    (2, 3, '2024-08-12 07:30:00'),
    (3, 1, '2024-08-13 12:15:00'),
    (4, 2, '2024-08-14 16:45:00');