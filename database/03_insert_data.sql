USE music_streaming_db;

-- Clear every table before loading the sample dataset.
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM user_episode;

DELETE FROM listening_history;

DELETE FROM user_artist;

DELETE FROM artist_song;

DELETE FROM playlist_song;

DELETE FROM episode;

DELETE FROM podcast;

DELETE FROM song;

DELETE FROM playlist;

DELETE FROM album;

DELETE FROM genre;

DELETE FROM artist;

DELETE FROM subscription;

DELETE FROM users;

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
    ('A.R. Rahman', 'India'),
    ('Shreya Ghoshal', 'India'),
    ('The Weeknd', 'Canada'),
    ('Coldplay', 'United Kingdom'),
    (
        'Taylor Swift',
        'United States'
    ),
    ('Amit Trivedi', 'India'),
    ('Armaan Malik', 'India'),
    ('Tame Impala', 'Australia'),
    ('jschlatt', 'United States'),
    ('Radiohead', 'United Kingdom');

INSERT INTO
    genre (Genre_Name)
VALUES ('Bollywood'),
    ('R&B'),
    ('Rock'),
    ('Pop'),
    ('Indie'),
    ('Electronic'),
    ('Christmas');

INSERT INTO
    album (
        Album_Name,
        Release_Date,
        Artist_ID
    )
VALUES ('Aashiqui 2', '2013-04-26', 1),
    ('Tamasha', '2015-11-06', 1),
    ('Rockstar', '2011-11-15', 2),
    ('Tamasha', '2015-11-06', 2),
    ('Devdas', '2002-07-12', 3),
    (
        'After Hours',
        '2020-03-20',
        4
    ),
    ('Parachutes', '2000-07-10', 5),
    (
        'A Rush of Blood to the Head',
        '2002-08-26',
        5
    ),
    ('1989', '2014-10-27', 6),
    ('folklore', '2020-07-24', 6),
    ('Dev.D', '2009-02-06', 7),
    (
        'Wake Up Sid',
        '2009-10-02',
        7
    ),
    ('Azhar', '2016-05-13', 8),
    ('Hero', '2015-09-11', 8),
    ('Currents', '2015-07-17', 9),
    (
        'A Very 1999 Christmas (Deluxe)',
        '2025-12-04',
        10
    ),
    (
        'In Rainbows',
        '2007-10-10',
        11
    );

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
    ('Hum Mar Jayenge', 245, 1, 1),
    (
        'Agar Tum Saath Ho',
        341,
        2,
        1
    ),
    ('Kun Faya Kun', 470, 3, 1),
    ('Nadaan Parindey', 396, 3, 1),
    ('Matargashti', 302, 4, 1),
    ('Dola Re Dola', 367, 5, 1),
    (
        'Silsila Ye Chahat Ka',
        295,
        5,
        1
    ),
    ('Maar Dala', 284, 5, 1),
    ('Blinding Lights', 200, 6, 2),
    ('Save Your Tears', 216, 6, 2),
    ('After Hours', 361, 6, 2),
    ('Yellow', 266, 7, 3),
    ('Shiver', 304, 7, 3),
    ('Clocks', 307, 8, 3),
    ('Blank Space', 231, 9, 4),
    ('Style', 231, 9, 4),
    ('Wildest Dreams', 220, 9, 4),
    ('cardigan', 239, 10, 5),
    (
        'Emosanal Atyachar',
        212,
        11,
        1
    ),
    ('Pardesi', 270, 11, 1),
    ('Iktara', 288, 12, 1),
    ('Bol Do Na Zara', 221, 13, 4),
    (
        'Main Hoon Hero Tera',
        225,
        14,
        4
    ),
    (
        'The Less I Know the Better',
        216,
        15,
        5
    ),
    ('Eventually', 318, 15, 5),
    ('Let It Happen', 430, 15, 6),
    (
        'Let It Snow! Let It Snow! Let It Snow!',
        119,
        16,
        7
    ),
    (
        'Santa Claus Is Coming to Town',
        137,
        16,
        7
    ),
    (
        'Baby, It''s Cold Outside',
        196,
        16,
        7
    ),
    ('White Christmas', 166, 16, 7),
    (
        'It''s the Most Wonderful Time of the Year',
        132,
        16,
        7
    ),
    (
        'The Christmas Song',
        190,
        16,
        7
    ),
    (
        'Have Yourself a Merry Little Christmas',
        180,
        16,
        7
    ),
    ('Happy Holiday', 133, 16, 7),
    (
        '(Everybody''s Waitin'' for) The Man with the Bag',
        137,
        16,
        7
    ),
    (
        'Mele Kalikimaka (Merry Christmas)',
        155,
        16,
        7
    ),
    ('Sleigh Ride', 159, 16, 7),
    ('15 Step', 238, 17, 3),
    ('Bodysnatchers', 242, 17, 3),
    ('Nude', 255, 17, 3),
    (
        'Weird Fishes/Arpeggi',
        318,
        17,
        3
    ),
    ('All I Need', 228, 17, 3),
    ('Faust Arp', 129, 17, 3),
    ('Reckoner', 290, 17, 3),
    ('House of Cards', 328, 17, 3),
    (
        'Jigsaw Falling into Place',
        248,
        17,
        3
    ),
    ('Videotape', 279, 17, 3);

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
    ),
    (
        'Bollywood Gold',
        '2024-02-14',
        1
    ),
    (
        'Late Night R&B',
        '2024-04-05',
        2
    ),
    (
        'Rock Classics',
        '2024-06-15',
        3
    ),
    (
        'Pop Essentials',
        '2024-07-20',
        4
    ),
    (
        'Indie Discoveries',
        '2024-08-01',
        1
    ),
    (
        'Christmas Countdown',
        '2024-11-01',
        2
    ),
    (
        'Rainy Day Radiohead',
        '2024-08-12',
        3
    ),
    (
        'Workout Energy',
        '2024-08-18',
        4
    ),
    (
        'Study Session',
        '2024-09-02',
        1
    ),
    (
        'Road Trip Mix',
        '2024-09-10',
        2
    ),
    (
        'Acoustic Evenings',
        '2024-09-18',
        3
    ),
    (
        'All-Time Favorites',
        '2024-10-01',
        4
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
    ),
    (
        'Chuckle Sandwich',
        'A comedy podcast featuring conversations, stories, and absurd debates.'
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
    ),
    (
        'The Internet Is Weird',
        1980,
        '2024-08-12',
        3
    ),
    (
        'The Sandwich Debate',
        2240,
        '2024-08-19',
        3
    ),
    (
        'A Very Serious Conversation',
        1760,
        '2024-08-26',
        3
    );

-- Many-to-many relationships
INSERT INTO
    playlist_song (Playlist_ID, Song_ID)
VALUES (1, 1),
    (1, 11),
    (1, 14),
    (1, 17),
    (1, 26),
    (2, 5),
    (2, 15),
    (2, 20),
    (2, 42),
    (2, 45),
    (3, 4),
    (3, 12),
    (3, 19),
    (3, 28),
    (3, 39),
    (3, 49);

INSERT INTO
    artist_song (Artist_ID, Song_ID)
VALUES (1, 1),
    (1, 2),
    (1, 3),
    (1, 4),
    (2, 5),
    (2, 6),
    (2, 7),
    (3, 8),
    (3, 9),
    (3, 10),
    (4, 11),
    (4, 12),
    (4, 13),
    (5, 14),
    (5, 15),
    (5, 16),
    (6, 17),
    (6, 18),
    (6, 19),
    (6, 20),
    (7, 21),
    (7, 22),
    (7, 23),
    (8, 24),
    (8, 25),
    (9, 26),
    (9, 27),
    (9, 28),
    (10, 29),
    (10, 30),
    (10, 31),
    (10, 32),
    (10, 33),
    (10, 34),
    (10, 35),
    (10, 36),
    (10, 37),
    (10, 38),
    (10, 39),
    (11, 40),
    (11, 41),
    (11, 42),
    (11, 43),
    (11, 44),
    (11, 45),
    (11, 46),
    (11, 47),
    (11, 48),
    (11, 49);

INSERT INTO
    user_artist (User_ID, Artist_ID)
VALUES (1, 1),
    (1, 2),
    (1, 4),
    (1, 10),
    (1, 11),
    (2, 3),
    (2, 4),
    (2, 5),
    (2, 6),
    (2, 10),
    (3, 2),
    (3, 5),
    (3, 9),
    (3, 11),
    (4, 1),
    (4, 4),
    (4, 6),
    (4, 8),
    (4, 10);

-- Playback history
INSERT INTO
    listening_history (User_ID, Song_ID, Played_At)
VALUES (1, 1, '2024-08-10 08:15:00'),
    (1, 11, '2024-08-10 08:20:00'),
    (1, 14, '2024-08-10 08:24:00'),
    (1, 40, '2024-08-10 08:30:00'),
    (1, 29, '2024-08-11 22:15:00'),
    (1, 42, '2024-08-12 22:20:00'),
    (1, 1, '2024-08-13 08:10:00'),
    (1, 11, '2024-08-14 08:12:00'),
    (2, 3, '2024-08-11 09:00:00'),
    (2, 7, '2024-08-11 09:05:00'),
    (2, 15, '2024-08-12 09:10:00'),
    (2, 20, '2024-08-13 09:15:00'),
    (2, 30, '2024-08-14 18:00:00'),
    (2, 41, '2024-08-15 18:05:00'),
    (3, 9, '2024-08-12 18:30:00'),
    (3, 16, '2024-08-12 18:36:00'),
    (3, 26, '2024-08-13 19:00:00'),
    (3, 43, '2024-08-14 19:05:00'),
    (3, 44, '2024-08-15 19:10:00'),
    (3, 28, '2024-08-16 19:20:00'),
    (4, 1, '2024-08-13 20:00:00'),
    (4, 3, '2024-08-13 20:05:00'),
    (4, 18, '2024-08-14 20:10:00'),
    (4, 24, '2024-08-15 20:15:00'),
    (4, 31, '2024-08-16 20:20:00'),
    (4, 49, '2024-08-17 20:25:00');

INSERT INTO
    user_episode (
        User_ID,
        Episode_ID,
        Played_At
    )
VALUES (1, 1, '2024-08-10 10:00:00'),
    (1, 2, '2024-08-11 10:00:00'),
    (1, 4, '2024-08-12 10:00:00'),
    (1, 5, '2024-08-13 10:00:00'),
    (2, 3, '2024-08-12 07:30:00'),
    (2, 4, '2024-08-13 07:35:00'),
    (2, 6, '2024-08-14 07:40:00'),
    (3, 1, '2024-08-13 12:15:00'),
    (3, 3, '2024-08-14 12:20:00'),
    (4, 2, '2024-08-14 16:45:00'),
    (4, 5, '2024-08-15 16:50:00');