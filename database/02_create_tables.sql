user music_streaming_db;

CREATE TABLE `USERS`(
    User_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Date_Joined DATE NOT NULL
);

