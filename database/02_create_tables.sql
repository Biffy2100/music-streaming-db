USE music_streaming_db;

DROP TABLE IF EXISTS subscription, users, artist, album, genre; 

CREATE TABLE USERS(
    User_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Date_Joined DATE NOT NULL
);

CREATE TABLE subscription(
    Subscription_ID INT PRIMARY KEY AUTO_INCREMENT,
    Plan_Type VARCHAR(50) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE,
    User_ID INT NOT NULL UNIQUE,

    FOREIGN KEY (User_ID) REFERENCES USERS(User_ID)
);

CREATE TABLE artist(
    Artist_ID INT PRIMARY KEY AUTO_INCREMENT,
    Artist_Name VARCHAR(100) NOT NULL,
    Country VARCHAR(100)
);

CREATE TABLE genre(
    Genre_ID INT PRIMARY KEY AUTO_INCREMENT,
    Genre_Name VARCHAR(50) NOT NULL UNIQUE
);

create table album(
    Album_id int primary key AUTO_INCREMENT,
    Album_Name varchar(100) not NULL,
    Release_date DATE
);