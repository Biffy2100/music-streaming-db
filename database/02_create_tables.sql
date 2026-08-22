USE music_streaming_db;

-- =========================================
-- DROP EXISTING TABLES
-- =========================================

DROP TABLE IF EXISTS user_episode;
DROP TABLE IF EXISTS listening_history;
DROP TABLE IF EXISTS user_artist;
DROP TABLE IF EXISTS artist_song;
DROP TABLE IF EXISTS playlist_song;
DROP TABLE IF EXISTS episode;
DROP TABLE IF EXISTS podcast;
DROP TABLE IF EXISTS song;
DROP TABLE IF EXISTS playlist;
DROP TABLE IF EXISTS album;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS subscription;
DROP TABLE IF EXISTS users;


-- =========================================
-- 1. USERS
-- =========================================

CREATE TABLE users(
    User_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Date_Joined DATE NOT NULL
);


-- =========================================
-- 2. SUBSCRIPTION
-- =========================================

CREATE TABLE subscription(
    Subscription_ID INT PRIMARY KEY AUTO_INCREMENT,
    Plan_Type VARCHAR(50) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE,
    User_ID INT NOT NULL UNIQUE,

    FOREIGN KEY (User_ID) REFERENCES users(User_ID)
);


-- =========================================
-- 3. ARTIST
-- =========================================

CREATE TABLE artist(
    Artist_ID INT PRIMARY KEY AUTO_INCREMENT,
    Artist_Name VARCHAR(100) NOT NULL,
    Country VARCHAR(100)
);


-- =========================================
-- 4. GENRE
-- =========================================

CREATE TABLE genre(
    Genre_ID INT PRIMARY KEY AUTO_INCREMENT,
    Genre_Name VARCHAR(50) NOT NULL UNIQUE
);


-- =========================================
-- 5. ALBUM
-- =========================================

CREATE TABLE album(
    Album_ID INT PRIMARY KEY AUTO_INCREMENT,
    Album_Name VARCHAR(100) NOT NULL,
    Release_Date DATE,
    Artist_ID INT NOT NULL,

    FOREIGN KEY (Artist_ID) REFERENCES artist(Artist_ID)
);


-- =========================================
-- 6. SONG
-- =========================================

CREATE TABLE song(
    Song_ID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(150) NOT NULL,
    Duration INT NOT NULL,
    Album_ID INT NOT NULL,
    Genre_ID INT NOT NULL,

    FOREIGN KEY (Album_ID) REFERENCES album(Album_ID),
    FOREIGN KEY (Genre_ID) REFERENCES genre(Genre_ID),

    CHECK (Duration > 0)
);


-- =========================================
-- 7. PLAYLIST
-- =========================================

CREATE TABLE playlist(
    Playlist_ID INT PRIMARY KEY AUTO_INCREMENT,
    Playlist_Name VARCHAR(100) NOT NULL,
    Created_Date DATE NOT NULL,
    User_ID INT NOT NULL,

    FOREIGN KEY (User_ID) REFERENCES users(User_ID)
);


-- =========================================
-- 8. PLAYLIST_SONG
-- =========================================

CREATE TABLE playlist_song(
    Playlist_ID INT NOT NULL,
    Song_ID INT NOT NULL,

    PRIMARY KEY (Playlist_ID, Song_ID),

    FOREIGN KEY (Playlist_ID) REFERENCES playlist(Playlist_ID),
    FOREIGN KEY (Song_ID) REFERENCES song(Song_ID)
);


-- =========================================
-- 9. ARTIST_SONG
-- =========================================

CREATE TABLE artist_song(
    Artist_ID INT NOT NULL,
    Song_ID INT NOT NULL,

    PRIMARY KEY (Artist_ID, Song_ID),

    FOREIGN KEY (Artist_ID) REFERENCES artist(Artist_ID),
    FOREIGN KEY (Song_ID) REFERENCES song(Song_ID)
);


-- =========================================
-- 10. USER_ARTIST
-- =========================================

CREATE TABLE user_artist(
    User_ID INT NOT NULL,
    Artist_ID INT NOT NULL,

    PRIMARY KEY (User_ID, Artist_ID),

    FOREIGN KEY (User_ID) REFERENCES users(User_ID),
    FOREIGN KEY (Artist_ID) REFERENCES artist(Artist_ID)
);


-- =========================================
-- 11. LISTENING_HISTORY
-- =========================================

CREATE TABLE listening_history(
    History_ID INT PRIMARY KEY AUTO_INCREMENT,
    User_ID INT NOT NULL,
    Song_ID INT NOT NULL,
    Played_At DATETIME NOT NULL,

    FOREIGN KEY (User_ID) REFERENCES users(User_ID),
    FOREIGN KEY (Song_ID) REFERENCES song(Song_ID)
);


-- =========================================
-- 12. PODCAST
-- =========================================

CREATE TABLE podcast(
    Podcast_ID INT PRIMARY KEY AUTO_INCREMENT,
    Podcast_Name VARCHAR(150) NOT NULL,
    Description TEXT
);


-- =========================================
-- 13. EPISODE
-- =========================================

CREATE TABLE episode(
    Episode_ID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(150) NOT NULL,
    Duration INT NOT NULL,
    Release_Date DATE,
    Podcast_ID INT NOT NULL,

    FOREIGN KEY (Podcast_ID) REFERENCES podcast(Podcast_ID),

    CHECK (Duration > 0)
);


-- =========================================
-- 14. USER_EPISODE
-- =========================================

CREATE TABLE user_episode(
    User_ID INT NOT NULL,
    Episode_ID INT NOT NULL,
    Played_At DATETIME NOT NULL,

    PRIMARY KEY (User_ID, Episode_ID, Played_At),

    FOREIGN KEY (User_ID) REFERENCES users(User_ID),
    FOREIGN KEY (Episode_ID) REFERENCES episode(Episode_ID)
);
