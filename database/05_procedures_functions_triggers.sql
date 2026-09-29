USE music_streaming_db;

DROP PROCEDURE IF EXISTS sp_user_listening_history;

DROP PROCEDURE IF EXISTS sp_artist_catalog_summary;

DROP FUNCTION IF EXISTS fn_song_play_count;

DROP FUNCTION IF EXISTS fn_playlist_song_count;

DROP TRIGGER IF EXISTS trg_playlist_before_insert;

DROP TRIGGER IF EXISTS trg_playlist_before_update;

DELIMITER $$

-- Scenario: generate one user's listening report row by row using a cursor.
CREATE PROCEDURE sp_user_listening_history(IN p_user_id INT)
BEGIN
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_song_title VARCHAR(150);
    DECLARE v_played_at DATETIME;
    DECLARE history_cursor CURSOR FOR
        SELECT s.Title, lh.Played_At
        FROM listening_history AS lh
        JOIN song AS s ON s.Song_ID = lh.Song_ID
        WHERE lh.User_ID = p_user_id
        ORDER BY lh.Played_At DESC;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS tmp_user_listening_history;
    CREATE TEMPORARY TABLE tmp_user_listening_history (
        Song_Title VARCHAR(150) NOT NULL,
        Played_At DATETIME NOT NULL
    );

    OPEN history_cursor;
    history_loop: LOOP
        FETCH history_cursor INTO v_song_title, v_played_at;
        IF v_done THEN
            LEAVE history_loop;
        END IF;
        INSERT INTO tmp_user_listening_history (Song_Title, Played_At)
        VALUES (v_song_title, v_played_at);
    END LOOP;
    CLOSE history_cursor;

    SELECT Song_Title, Played_At
    FROM tmp_user_listening_history
    ORDER BY Played_At DESC;
    DROP TEMPORARY TABLE tmp_user_listening_history;
END$$

-- Scenario: produce a catalog report for every artist, including artists with no songs.
CREATE PROCEDURE sp_artist_catalog_summary()
BEGIN
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_artist_id INT;
    DECLARE v_artist_name VARCHAR(100);
    DECLARE v_song_count INT;
    DECLARE artist_cursor CURSOR FOR
        SELECT Artist_ID, Artist_Name
        FROM artist
        ORDER BY Artist_Name;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS tmp_artist_catalog_summary;
    CREATE TEMPORARY TABLE tmp_artist_catalog_summary (
        Artist_ID INT NOT NULL,
        Artist_Name VARCHAR(100) NOT NULL,
        Song_Count INT NOT NULL
    );

    OPEN artist_cursor;
    artist_loop: LOOP
        FETCH artist_cursor INTO v_artist_id, v_artist_name;
        IF v_done THEN
            LEAVE artist_loop;
        END IF;
        SELECT COUNT(*) INTO v_song_count
        FROM artist_song
        WHERE Artist_ID = v_artist_id;
        INSERT INTO tmp_artist_catalog_summary (Artist_ID, Artist_Name, Song_Count)
        VALUES (v_artist_id, v_artist_name, v_song_count);
    END LOOP;
    CLOSE artist_cursor;

    SELECT Artist_ID, Artist_Name, Song_Count
    FROM tmp_artist_catalog_summary
    ORDER BY Song_Count DESC, Artist_Name;
    DROP TEMPORARY TABLE tmp_artist_catalog_summary;
END$$

-- Scenario: return the number of listening-history plays for a selected song.
CREATE FUNCTION fn_song_play_count(p_song_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_play_count INT;
    SELECT COUNT(*) INTO v_play_count
    FROM listening_history
    WHERE Song_ID = p_song_id;
    RETURN v_play_count;
END$$

-- Scenario: return the number of songs currently assigned to a selected playlist.
CREATE FUNCTION fn_playlist_song_count(p_playlist_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_song_count INT;
    SELECT COUNT(*) INTO v_song_count
    FROM playlist_song
    WHERE Playlist_ID = p_playlist_id;
    RETURN v_song_count;
END$$

-- Scenario: normalize a new playlist name and reject blank names before insert.
CREATE TRIGGER trg_playlist_before_insert
BEFORE INSERT ON playlist
FOR EACH ROW
BEGIN
    SET NEW.Playlist_Name = TRIM(NEW.Playlist_Name);
    IF NEW.Playlist_Name IS NULL OR CHAR_LENGTH(NEW.Playlist_Name) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Playlist name cannot be blank';
    END IF;
END$$

-- Scenario: prevent a playlist name from becoming blank during an update.
CREATE TRIGGER trg_playlist_before_update
BEFORE UPDATE ON playlist
FOR EACH ROW
BEGIN
    SET NEW.Playlist_Name = TRIM(NEW.Playlist_Name);
    IF NEW.Playlist_Name IS NULL OR CHAR_LENGTH(NEW.Playlist_Name) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Playlist name cannot be blank';
    END IF;
END$$



delimiter ;
-- After executing this file, reset the MySQL Workbench delimiter with: DELIMITER ;

-- Example calls for MySQL Workbench:
-- CALL sp_user_listening_history(1);
-- CALL sp_artist_catalog_summary();
-- SELECT fn_song_play_count(1);
-- SELECT fn_playlist_song_count(1);